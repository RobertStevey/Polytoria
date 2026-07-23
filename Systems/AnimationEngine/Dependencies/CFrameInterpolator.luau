-- The math below is byte-for-byte identical to the original Roblox version by AxisAngles, credit to them.

local CFrame = require(ScriptService["CFrame"])

local invroot2 = 1/math.sqrt(2)

return function(c0, c1) -- (CFrame from, CFrame to) -> (float fraction -> CFrame between)
	-- The expanded matrix
	local _, _, _, xx, yx, zx,
	xy, yy, zy,
	xz, yz, zz = (c0:Inverse()*c1):GetComponents()



	-- The cos-theta of the axisAngles from
	local cosTheta = (xx + yy + zz - 1)/2

	-- Rotation axis
	local rotationAxis = Vector3.New(yz-zy, zx-xz, xy-yx)

	-- The position to tween through
	local positionDelta = (c1.Position - c0.Position)

	-- Theta
	local theta;

	-- Catch degenerate cases
	if cosTheta >= 0.999 then
		-- Case same rotation, just return an interpolator over the positions
		return function(t)
			return c0 + positionDelta*t
		end
	elseif cosTheta <= -0.999 then
		-- Case exactly opposite rotations, disambiguate
		theta = math.pi
		xx = (xx + 1) / 2
		yy = (yy + 1) / 2
		zz = (zz + 1) / 2
		if xx > yy and xx > zz then
			if xx < 0.001 then
				rotationAxis = Vector3.New(0, invroot2, invroot2)
			else
				local x = math.sqrt(xx)
				xy = (xy + yx) / 4
				xz = (xz + zx) / 4
				rotationAxis = Vector3.New(x, xy/x, xz/x)
			end
		elseif yy > zz then
			if yy < 0.001 then
				rotationAxis = Vector3.new(invroot2, 0, invroot2)
			else
				local y = math.sqrt(yy)
				xy = (xy + yx) / 4
				yz = (yz + zy) / 4
				rotationAxis = Vector3.New(xy/y, y, yz/y)
			end
		else
			if zz < 0.001 then
				rotationAxis = Vector3.New(invroot2, invroot2, 0)
			else
				local z = math.sqrt(zz)
				xz = (xz + zx) / 4
				yz = (yz + zy) / 4
				rotationAxis = Vector3.New(xz/z, yz/z, z)
			end
		end
	else
		-- Normal case, get theta from cosTheta
		theta = math.acos(cosTheta)
	end

	-- Return the interpolator
	return function(t)
		return c0*CFrame.fromAxisAngle(rotationAxis, theta*t) + positionDelta*t
	end
end
