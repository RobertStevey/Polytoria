--[[
	https://github.com/gre/bezier-easing
	BezierEasing - use bezier curve for transition easing function
	by Gaëtan Renaudeau 2014 - 2015 – MIT License
--]]

-- These values are established by empiricism with tests (tradeoff: performance VS precision)
local NEWTON_ITERATIONS = 4 
local NEWTON_MIN_SLOPE = 0.001 
local SUBDIVISION_PRECISION = 0.0000001 
local SUBDIVISION_MAX_ITERATIONS = 10 

local KSplineTableSize = 11 
local KSampleStepSize = 1.0 / (KSplineTableSize - 1.0) 

-- local float32ArraySupported = typeof Float32Array === 'function' 

function A(AA1, AA2)
	return 1.0 - 3.0 * AA2 + 3.0 * AA1 
end
function B(AA1, AA2)
	return 3.0 * AA2 - 6.0 * AA1 
end
function C(AA1)
	return 3.0 * AA1 
end

-- Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
function CalcBezier(AT, AA1, AA2)
	return ((A(AA1, AA2) * AT + B(AA1, AA2)) * AT + C(AA1)) * AT 
end

-- Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
function GetSlope(AT, AA1, AA2)
	return 3.0 * A(AA1, AA2) * AT * AT + 2.0 * B(AA1, AA2) * AT + C(AA1) 
end

function BinarySubdivide(AX, AA, AB, MX1, MX2)
	local CurrentX, CurrentT, i = 0, 0, 0
	repeat
		CurrentT = AA + (AB - AA) / 2.0 
		CurrentX = CalcBezier(CurrentT, MX1, MX2) - AX 
		if (CurrentX > 0) then
			AB = CurrentT 
		else
			AA = CurrentT 
		end
		i = i + 1 -- Pre-increment later. Not a catch-all.
	until not (math.abs(CurrentX) > SUBDIVISION_PRECISION and i < SUBDIVISION_MAX_ITERATIONS)

	return CurrentT 
end

function NewtonRaphsonIterate(AX, AGuessT, MX1, MX2)
	for i = 0, NEWTON_ITERATIONS - 1 do
		local CurrentSlope = GetSlope(AGuessT, MX1, MX2) 
		if (CurrentSlope == 0) then
			return AGuessT 
		end
		local CurrentX = CalcBezier(AGuessT, MX1, MX2) - AX 
		AGuessT = AGuessT - CurrentX / CurrentSlope 
	end
	return AGuessT 
end

function Bezier(MX1, MY1, MX2, MY2, x)
	if not (0 <= MX1 and MX1 <= 1 and 0 <= MX2 and MX2 <= 1) then
		error('bezier x values must be in [0, 1] range') 
	end
	
	if (MX1 == MY1 and MX2 == MY2) then
		return x
	end

	-- Precompute samples table
	local SampleValues = {}
	if (MX1 ~= MY1 or MX2 ~= MY2) then
		for i = 0, KSplineTableSize - 1 do
			SampleValues[i] = CalcBezier(i * KSampleStepSize, MX1, MX2) 
		end
	end

	local function GetTForX (AX)
		local IntervalStart = 0.0 
		local CurrentSample = 1 
		local LastSample = KSplineTableSize - 1 

		while CurrentSample ~= LastSample and SampleValues[CurrentSample] <= AX do
			IntervalStart = IntervalStart + KSampleStepSize 
			CurrentSample = CurrentSample + 1
		end
		CurrentSample = CurrentSample - 1

		-- Interpolate to provide an initial guess for t
		local Dist = (AX - SampleValues[CurrentSample]) / (SampleValues[CurrentSample + 1] - SampleValues[CurrentSample]) 
		local GuessForT = IntervalStart + Dist * KSampleStepSize 

		local InitialSlope = GetSlope(GuessForT, MX1, MX2) 
		if (InitialSlope >= NEWTON_MIN_SLOPE) then
			return NewtonRaphsonIterate(AX, GuessForT, MX1, MX2) 
		elseif (InitialSlope == 0) then
			return GuessForT 
		else
			return BinarySubdivide(AX, IntervalStart, IntervalStart + KSampleStepSize, MX1, MX2) 
		end
	end

	return CalcBezier(GetTForX(x), MY1, MY2)
end

return Bezier
