--------------------------------------------------------------------------------
--                Polytoria Custom Weld Module (CFrame Powered)             --
-- 				IT NEEDS GplateGummy's Polytoria CFrame Module implementation     --
--------------------------------------------------------------------------------
local CFrameModule = require(ScriptService["CFrame"]) 
local Weld = {}
Weld.__index = Weld

local activeMotors = {}

-- rendering update loop
local function updateMotors(dt)
	for _, motor in ipairs(activeMotors) do
		local root = motor.Root
		local target = motor.Target
		
		if root and target then
			-- Grab matrix using CFrame module method
			local rootCF = CFrameModule.GetCFrame(root)
			
			-- Weld Formula: Final = Root * C0 * C1:Inverse()
			local jointHubCF = rootCF * motor.C0 
			local targetDestinationCF = jointHubCF * motor.C1:Inverse()
			
			-- Extract and assign global position and orientation back to engine parts
			target.Position = Vector3.New(targetDestinationCF.x, targetDestinationCF.y, targetDestinationCF.z)
			target.Rotation = targetDestinationCF:ToPolyRotation()
		end
	end
end

game.Rendered:Connect(updateMotors)

-- Constructor to initialize the motor joint
function Weld.new(rootPart, targetPart)
	targetPart.Anchored = true
	
	print(rootPart)
	local rootCF = CFrameModule.GetCFrame(rootPart)
	local targetCF = CFrameModule.GetCFrame(targetPart)
	
	local self = setmetatable({
		Root = rootPart,
		Target = targetPart,
		
		C0 = CFrameModule.identity, 
		C1 = CFrameModule.identity,
		--if you want your welds to stay in position of where you placed it, 
		-- replace the 48th line with: targetCF:Inverse() * rootCF  
	}, Weld)
	
	table.insert(activeMotors, self)
	return self
end


-- Break weld
function Weld:Break()
	for index, motor in ipairs(activeMotors) do
		if motor == self then
			table.remove(activeMotors, index)
			break
		end
	end
end

return Weld
