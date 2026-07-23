local Dependencies = script.Parent.Parent["Dependencies"]
local Signal = require(ScriptService["SimpleSignal"])
local Crossfade = require(script.Parent["Crossfade"])
local CFrame = require(ScriptService["CFrame"])
local AnimFPS = 60
local WRAPMODE_ONCE = "Once"
local WRAPMODE_LOOP = "Loop"
local WRAPMODE_CLAMP_FOREVER = "ClampForever"
local WRAPMODE_PING_PONG = "PingPong"
local AnimationTracks = {}
AnimationTracks.__index = AnimationTracks

local function LerpNumber(A, B, C)
	return A + (B - A) * C
end
local function InvLerpNumber(A, B, C)
	return (C - A) / (B - A)
end
local function deepCopyTable(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopyTable(v)
		end
		copy[k] = v
	end
	return copy
end

function AnimationTracks.New(Rig, Anim)
	local self = setmetatable({}, AnimationTracks)
	self.Anim = Anim
	self.Speed = Anim.Clip.Speed
	self.Weight = Anim.Clip.Weight
	self.WrapMode = Anim.Clip.WrapMode
	self.Priority = Anim.Clip.Priority or 0 -- NEW: default priority if clip doesn't define one
	self.Playing = false
	self.Frames = Anim:GetFrames()
	self.Length = #Anim:GetFrames() / AnimFPS
	self.Time = 0.0
	self.NormalizedTime = 0.0
	self.FrameBuffer = {}
	self.Played = Signal.new()
	self.Stopped = Signal.new()
	self.Crossfade = Crossfade.new(0, 0, 0)
	return self
end

function AnimationTracks:SetSpeed(Speed)
	self.Speed = Speed
	self.Frames = self.Anim:SetSpeed(self.Speed)
end

function AnimationTracks:SetWeight(Weight)
	self.Weight = Weight
	self.Frames = self.Anim:SetWeight(self.Weight)
end

-- NEW: lets Play() override priority per-call, per your point 3
function AnimationTracks:SetPriority(Priority)
	self.Priority = Priority
end

function AnimationTracks:_Play(Resume)
	local Wrap = self.WrapMode
	if Wrap ~= WRAPMODE_CLAMP_FOREVER then
		if (not Resume) or (Wrap == WRAPMODE_ONCE) then
			self.Time = 0.0
		end
	end
	self.Playing = true
	self.Played:Fire()
end

function AnimationTracks:_Stop()
	if self.Playing then
		self.Time = 0.0
		self.Playing = false
		self.Stopped:Fire()
	end
end

function AnimationTracks:_BufferFrame(EndFrame, Alpha)
	local Buffer = {}
	for JointName, Lerp in pairs(EndFrame) do
		Buffer[JointName] = Lerp(Alpha)
	end
	return Buffer
end

function AnimationTracks:_GetCurrentFrame()
	local Frames = self.Frames
	local FrameCount = #self.Frames
	local CurrentTime = 0.0

	if self.WrapMode == WRAPMODE_LOOP then
		CurrentTime = self.Time % self.Length
	elseif self.WrapMode == WRAPMODE_PING_PONG then
		CurrentTime = self.Length - math.abs(self.Time % (2 * self.Length) - self.Length)
	elseif self.WrapMode == WRAPMODE_ONCE or self.WrapMode == WRAPMODE_CLAMP_FOREVER then
		CurrentTime = math.clamp(self.Time, 0, self.Length)

		if self.WrapMode == WRAPMODE_ONCE and self.Playing and self.Time >= self.Length then
			self.Time = self.Length
			local FadeValue, FadeComplete = self.Crossfade:GetValue()
			if FadeComplete or self.Time >= self.Length then -- Safety: stop after 0.1s past length regardless
				self:_Stop()
			end
		end
	end

	self.NormalizedTime = math.clamp(CurrentTime / self.Length, 0, 1)
	local TimeSampleStart, Alpha = math.modf((FrameCount - 1) * self.NormalizedTime)
	TimeSampleStart = TimeSampleStart + 1
	local TimeSampleEnd = TimeSampleStart % FrameCount + 1

	if self.NormalizedTime >= 1.0 then
		return self:_BufferFrame(Frames[FrameCount], 0), FrameCount, 1.0
	end

	local Result = self:_BufferFrame(Frames[TimeSampleEnd], Alpha)
	return Result, TimeSampleStart, self.NormalizedTime
end

return AnimationTracks
