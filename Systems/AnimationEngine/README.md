Documentation isn't ready yet. However, to set this up (Put all this on ScriptService):
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
