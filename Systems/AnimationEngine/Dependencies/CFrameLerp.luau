--Credits again to AxisAngles for this CFrame Lerp code.

local invroot2 = 1/math.sqrt(2)
local CFrame = require(game.ScriptService["CFrame"])

return function(c0, c1, t)
    local _, _, _, xx, yx, zx,
    xy, yy, zy,
    xz, yz, zz = (c0:Inverse()*c1):GetComponents()

    local cosTheta = (xx + yy + zz - 1)/2

    -- Vector3.New (capital N) for Polytoria
    local rotationAxis = Vector3.New(yz-zy, zx-xz, xy-yx)

    -- Use .x/.y/.z directly since that's what the CFrame module stores
    local positionDelta = Vector3.New(c1.x - c0.x, c1.y - c0.y, c1.z - c0.z)

    local theta

    if cosTheta >= 0.999 then
        return c0 + positionDelta*t
    elseif cosTheta <= -0.999 then
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
                rotationAxis = Vector3.New(invroot2, 0, invroot2)
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
        theta = math.acos(cosTheta)
    end

    -- Guard: if theta is essentially 0, just interpolate position
    if not theta or theta < 1e-6 then
        return c0 + positionDelta * t
    end

    return c0 * CFrame.fromAxisAngle(rotationAxis, theta*t) + positionDelta*t
end
