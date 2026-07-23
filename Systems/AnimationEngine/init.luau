-- AnimationEngine.lua
local Dependencies = script["Dependencies"]
local AnimationDependencies = script["AnimationDependencies"]
local AnimationTracks = require(AnimationDependencies["AnimationTracks"])
local AnimationClip = require(AnimationDependencies["AnimationClip"])
local Crossfade = require(AnimationDependencies["Crossfade"])
local CFrameModule = require(ScriptService["CFrame"])
local CFrameLerp = require(Dependencies["CFrameLerp"])

local AnimationEngine = {}

local Meta = {
	__index = function(self, index)
		if AnimationEngine[index] then
			return AnimationEngine[index]
		elseif index == "Enabled" then
			return self._Enabled
		end
	end,
	__newindex = function(self, index, value)
		if index == "Enabled" and type(value) == "boolean" then
			self._Enabled = value
			if value then
				spawn(function()
					self:_Start()
				end)
			end
		else
			rawset(self, index, value)
		end
	end,
}

function AnimationEngine.New(Rig)
	local Props = {}

	Props.Rig = Rig
	Props.RigJoints = Rig.Joints
	Props.Tracks = {}
	Props.FadingTracks = {}
	Props.PlayingTracks = {}
	Props.UpdateRate = 0
	Props._ElapsedTime = 0
	Props._Enabled = false
	Props._Connection = nil

	return setmetatable(Props, Meta)
end

function AnimationEngine:AddAnimation(Anim, Name)
	local AnimClip = AnimationClip.New(Anim)
	local AnimTrack = AnimationTracks.New(self.Rig, AnimClip)

	if Name then
		self.Tracks[Name] = AnimTrack
		return self.Tracks[Name]
	else
		local AnimTable = require(Anim)
		self.Tracks[AnimTable.Name] = AnimTrack
		return self.Tracks[AnimTable.Name]
	end
end

function AnimationEngine:RemoveAnimation(Name)
	local FindResult = table.find(self.PlayingTracks, self.Tracks[Name])
	if FindResult then
		table.remove(self.PlayingTracks, FindResult)
	end
	if self.Tracks[Name] then
		self.Tracks[Name] = nil
	end
end

function AnimationEngine:_Start()
	-- Disconnect old connection if it exists
	if self._Connection then
		self._Connection:Disconnect()
		self._Connection = nil
	end

	self._Connection = Hooks.Updated:Connect(function(DT)
		if self._Enabled then
			self:_Update(DT)
		elseif self._Connection then
			self._Connection:Disconnect()
			self._Connection = nil
		end
	end)
end

function AnimationEngine:Play(TrackName, StartGoal, Priority)
	local Track = self.Tracks[TrackName]
	if not Track then
		error("AnimationEngine :: track '" .. TrackName .. "' not found")
	end

	local FadingNum = table.find(self.FadingTracks, Track)
	if FadingNum then
		warn("AnimationEngine :: currently fading, cannot intervene")
		return false, nil
	end

	if Priority ~= nil then
		Track:SetPriority(Priority)
	end
	Track.Time = 0
	local AlreadyPlaying = table.find(self.PlayingTracks, Track)
	if not AlreadyPlaying then
		table.insert(self.PlayingTracks, Track)
	end

	--table.insert(self.PlayingTracks, Track)
	Track.Crossfade:SetGoal((StartGoal or 1), 0)
	Track:_Play(false)
	return true, Track
end

function AnimationEngine:Stop(TrackName)
	local Track = self.Tracks[TrackName]
	if not Track then
		error("AnimationEngine :: track '" .. TrackName .. "' not found")
	end

	local Result = table.find(self.PlayingTracks, Track)
	if Result then
		table.remove(self.PlayingTracks, Result)
	end
	Track:_Stop()
end

function AnimationEngine:CrossFade(TrackName, FadeLength, Goal)
	local FadeLength = FadeLength or 0.3
	local Track = self.Tracks[TrackName]
	if not Track then
		error("AnimationEngine :: track '" .. TrackName .. "' not found")
	end

	local Num = table.find(self.PlayingTracks, Track)
	local Result = self.PlayingTracks[Num]
	if Result then
		-- guard against inserting the same track twice into FadingTracks
		-- (this was the stale-duplicate-entry bug from fading up then back down)
		if not table.find(self.FadingTracks, Result) then
			table.insert(self.FadingTracks, Result)
		end
		Result.Crossfade:SetGoal(Goal, FadeLength)
	end
end

function AnimationEngine:_GetAllCurrentFrames()
	local Snapshot = table.clone(self.PlayingTracks)
	local Frames = {}
	for i = 1, #Snapshot do
		local CurrentTrack = Snapshot[i]
		local Frame, TimeSampleStart, NormalizedTime = CurrentTrack:_GetCurrentFrame()
		Frames[i] = { Frame, CurrentTrack }
	end
	return Frames
end

function AnimationEngine:_BlendAdditive()
	local Frames = self:_GetAllCurrentFrames()

	local JointContributions = {}
	local TracksToStop = {}

	for i, Entry in ipairs(Frames) do
		local FrameTable = Entry[1]
		local Track = Entry[2]

		-- Don't process frames from stopped tracks
		if not Track.Playing then
			TracksToStop[Track] = false
			continue
		end

		local FadeValue, FadeComplete = Track.Crossfade:GetValue()
		local EffectiveWeight = Track.Weight * FadeValue
		local Priority = Track.Priority or 0

		for JointName, Transform in pairs(FrameTable) do
			local Joint = self.RigJoints[JointName]
			if Joint then
				JointContributions[JointName] = JointContributions[JointName] or {}
				table.insert(JointContributions[JointName], {
					Transform = Transform,
					Weight = EffectiveWeight,
					Priority = Priority,
				})
			end
		end

		if FadeComplete then
			local FadingIdx = table.find(self.FadingTracks, Track)
			if FadingIdx then
				table.remove(self.FadingTracks, FadingIdx)
			end
		end

		local FadeFinished = (FadeValue == 0 and FadeComplete)
		if FadeFinished then
			TracksToStop[Track] = true
		end
	end

	local FrameResult = {}
	for JointName, Contributions in pairs(JointContributions) do
		local MaxPriority = -math.huge
		for _, C in ipairs(Contributions) do
			if C.Priority > MaxPriority then
				MaxPriority = C.Priority
			end
		end

		local TopTier = {}
		local TotalWeight = 0
		for _, C in ipairs(Contributions) do
			if C.Priority == MaxPriority then
				table.insert(TopTier, C)
				TotalWeight = TotalWeight + C.Weight
			end
		end

		if TotalWeight <= 0 then
			-- Nobody at the top tier has any real weight yet
			-- (e.g. a crossfade that hasn't ticked forward at all).
			FrameResult[JointName] = TopTier[1].Transform
		else
			local Result = TopTier[1].Transform
			local Accumulated = TopTier[1].Weight

			for idx = 2, #TopTier do
				local C = TopTier[idx]
				local Alpha = C.Weight / (Accumulated + C.Weight)
				Result = CFrameLerp(Result, C.Transform, Alpha)
				Accumulated = Accumulated + C.Weight
			end

			FrameResult[JointName] = Result
		end
	end

	for Track, WasFadeFinished in pairs(TracksToStop) do
		if WasFadeFinished then
			Track:_Stop()
		end
		local FadingIdx = table.find(self.FadingTracks, Track)
		if FadingIdx then
			table.remove(self.FadingTracks, FadingIdx)
		end
	end

	return FrameResult
end

function AnimationEngine:_Update(DT)
	self._ElapsedTime = self._ElapsedTime + DT

	if self._ElapsedTime >= self.UpdateRate then
		self._ElapsedTime = self._ElapsedTime - self.UpdateRate

		local Frames = self:_BlendAdditive()

		for JointName, Transform in pairs(Frames) do
			local Joint = self.RigJoints[JointName]
			if Joint then
				Joint.Transform = Transform
			end
		end
	end

	-- Time update loop
	local Snapshot = table.clone(self.PlayingTracks)
	for i = 1, #Snapshot do
		local CurrentTrack = Snapshot[i]
		local OldTime = CurrentTrack.Time
		CurrentTrack.Time = CurrentTrack.Time + (CurrentTrack.Speed * DT)
	end

	-- Removal loop
	for i = #self.PlayingTracks, 1, -1 do
		if not self.PlayingTracks[i].Playing then
			table.remove(self.PlayingTracks, i)
		end
	end
end

return AnimationEngine
