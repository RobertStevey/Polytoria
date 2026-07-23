local function lerp(a, b, c)
	return a + (b - a) * c
end

local Crossfade = {}
Crossfade.__index = Crossfade

function Crossfade.new(start, goal, duration)
	local this = {}
	this._StartTime = os.clock()
	this._Duration = duration
	this._Start = start
	this._Goal = goal

	return setmetatable(this, Crossfade)
end

function Crossfade:SetGoal(newGoal, duration)
	-- Fixed: Ensure GetValue() is called before overwriting _StartTime
	self._Start = self:GetValue() 
	self._Goal = newGoal
	self._StartTime = os.clock()
	self._Duration = duration
end

-- Returns the current value and whether the crossfade has completed
function Crossfade:GetValue()
	if self._Duration == 0 then
		return self._Goal, true
	end
	

	local progress = math.clamp((os.clock() - self._StartTime) / self._Duration, 0, 1)
	local value = lerp(self._Start, self._Goal, progress)
	
	return value, progress >= 1 
end

function Crossfade:IsComplete()
	local _, completed = self:GetValue()
	return completed
end

return Crossfade
