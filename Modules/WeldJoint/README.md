## WeldJoint

A module designed to replicate how weld joints act on rblx.

> :warning: This module can only run IF you have GplateGummy's CFrame Module, here is the module: https://github.com/GplateGummy/Polytoria-CFrameModule/tree/main Put it in ScriptService.

## API
`.New(Part0:Part, Part1:Part)`  
Returns a new weld between Part0 and Part1.

`.C0`  
Modifies the C0 CFrame.

`.C1`  
Modifies the C1 CFrame.

`:Break()`  
Breaks the part.

## How to use

```luau
local Weld = require(ScriptService["WeldJoints"])
local CFrame = require(ScriptService["CFrame"})
local root = script.Parent["Root"]
local target = script.Parent["Target"]
--make the weld
local Joint = Weld.new(root, target)
--modifies C0
Joint.C0 = CFrame.New(0,1,0)
```
