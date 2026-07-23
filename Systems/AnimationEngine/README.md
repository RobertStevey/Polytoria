HEADS UP, THIS IS NOT READY FOR GAMES AND MASSIVE CHANGES ARE GOING TO COME (possibly with no backwards compatibility but i will try to have it)

Documentation isn't ready yet, but for a basic animation:

```luau
local Rig           = require(ScriptService["RigSystem"])
local HumanoidFormat = require(script["RigFormatR6"])
local AnimationEngine = require(ScriptService["AnimationEngine"])

local myRig = Rig.New(script.Parent, HumanoidFormat)

local DanceTestClip = require(script["DanceTest"], 1)
local DanceTestClip2 = require(script["DanceTest2"],1)

local engine = AnimationEngine.New(myRig)
engine.Enabled = true
engine:AddAnimation(DanceTestClip, "DanceTest")
engine:AddAnimation(DanceTestClip2, "DanceTest2")

wait(5)
engine:Play("DanceTest", 0)
engine:CrossFade("DanceTest", 5, 1)
wait(10)
engine:CrossFade("DanceTest", 5, 0)
wait(2)
engine:Play("DanceTest2", 0)
engine:CrossFade("DanceTest2", 5, 1)

```


and, to set this up (Put all this on ScriptService):
<pre style="white-space: pre; overflow-x: auto; word-wrap: normal;">
<a href="https://github.com/RobertStevey/Polytoria/blob/main/Systems/RigSystem/init.luau">RigSystem.luau</a>
<a href="https://github.com/RobertStevey/Polytoria/blob/main/Modules/AnimatableJoint/AnimatableJoint.luau">AnimatableJoint.luau</a>
<a href="https://github.com/GplateGummy/Polytoria-CFrameModule/blob/main/Source.lua">CFrame.luau</a>

init.luau (Rename to AnimationEngine)
|— Dependencies (Folder)
|  |— CFrameInterpolator.luau
|  |— BezierEasing.luau
|  |— CFrameLerp.luau
|  |— Easing.luau
|
|— AnimationDependencies (Folder)
   |— AnimationClip.luau
   |— AnimationTracks.luau
   |— Croosfade.luau
</pre>
