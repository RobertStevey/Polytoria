local CFrameModule = require(ScriptService["CFrame"]) 
local AnimatableJoint = {}
AnimatableJoint.__index = AnimatableJoint

local activeMotors = {}

local function updateMotors(dt)
	for _, motor in ipairs(activeMotors) do
		local root = motor.Root
		local target = motor.Target
		
		if root and target then
			
			local rootCF = CFrameModule.GetCFrame(root)
			
			local jointHubCF = rootCF * motor.C0 * motor.Transform
			local targetDestinationCF = jointHubCF * motor.C1:Inverse()
			
			target.Position = Vector3.New(targetDestinationCF.x, targetDestinationCF.y, targetDestinationCF.z)
			target.Rotation = targetDestinationCF:ToPolyRotation()
		end
	end
end


game.Rendered:Connect(updateMotors)


function AnimatableJoint.new(rootPart, targetPart)
	targetPart.Anchored = true
	
	
	local rootCF = CFrameModule.GetCFrame(rootPart)
	local targetCF = CFrameModule.GetCFrame(targetPart)
	
	local self = setmetatable({
		Root = rootPart,
		Target = targetPart,
		C0 = CFrameModule.identity, 
		C1 = targetCF:Inverse() * rootCF,                 
		Transform = CFrameModule.identity
	}, AnimatableJoint)
	
	table.insert(activeMotors, self)
	return self
end



function AnimatableJoint:Break()
	for index, motor in ipairs(activeMotors) do
		if motor == self then
			table.remove(activeMotors, index)
			break
		end
	end
end

return AnimatableJoint
