-- Rig.lua
local Motor6D       = require(game.ScriptService["AnimatableJoints"])
local CFrameModule  = require(game.ScriptService["CFrame"])

local function TableToCFrame(t)
    -- expects { x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 }
    return CFrameModule.New(table.unpack(t))
end

local Rig = {}
Rig.__index = Rig

local function BuildJoints(Model, JointDefs, JointsOut)
    for _, Def in ipairs(JointDefs) do
        local rootPart = nil
        local targetPart = nil

        -- If Def.Root is nil, that means "start paused" (no Root assigned yet)
        -- Otherwise, try to find the part by name
        if Def.Root ~= nil then
            rootPart = Model:FindChild(Def.Root)
        end

        if Def.Target ~= nil then
            targetPart = Model:FindChild(Def.Target)
        end

        -- Only warn if a name was GIVEN but the part was MISSING
        local rootMissing = (rootPart == nil and Def.Root ~= nil)
        local targetMissing = (targetPart == nil and Def.Target ~= nil)

        if rootMissing then
            warn("Rig :: could not find Root part '" .. Def.Root .. "' in model")
        elseif targetMissing then
            warn("Rig :: could not find Target part '" .. Def.Target .. "' in model")
        else
            local Joint = Motor6D.new(rootPart, targetPart)
            if Joint then
                if Def.C0 then Joint.C0 = TableToCFrame(Def.C0) end
                if Def.C1 then Joint.C1 = TableToCFrame(Def.C1) end
                JointsOut[Def.Name] = Joint
            end
        end

        if Def.Children then
            BuildJoints(Model, Def.Children, JointsOut)
        end
    end
end

function Rig.New(Model, RigFormat)
    local self = setmetatable({}, Rig)

    self.Model  = Model
    self.Joints = {}

    BuildJoints(Model, RigFormat.Joints, self.Joints)

    return self
end

function Rig:GetJoint(Name)
    local Joint = self.Joints[Name]
    if not Joint then
        warn("Rig :: joint '" .. Name .. "' not found")
    end
    return Joint
end

function Rig:ChangePart(Name, Which, newPart)
		local Joint = self:GetJoint(Name)
		if Which == "Root" then
			Joint:SetRoot(newPart)
		elseif Which == "Target" then
			Joint:SetTarget(newPart)
		end
end

function Rig:Destroy()
    for _, Joint in pairs(self.Joints) do
        Joint:Break()
    end
    self.Joints = {}
end

return Rig
