PLEASE READ.

This is a system interpreting rig format, a custom format specialized for AnimationEngine system.

underneath here is an example of an R6 Rig parsed into this RigSystem.

```luau
return {
    Joints = {
        {
            Name     = "RootJoint",
            Root     = "HumanoidRootPart",
            Target   = "Torso",
            C0       = { 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0 },
            C1       = { 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0 },
            Children = {
                {
                    Name   = "Neck",
                    Root   = "Torso",
                    Target = "Head",
                    C0     = { 0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0 },
                    C1     = { 0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0 },
                },
                {
                    Name   = "Left Shoulder",
                    Root   = "Torso",
                    Target = "Left Arm",
                    C0     = { -1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0 },
                    C1     = {  0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0 },
                },
                {
                    Name   = "Right Shoulder",
                    Root   = "Torso",
                    Target = "Right Arm",
                    C0     = {  1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0 },
                    C1     = { -0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0 },
                },
                {
                    Name   = "Left Hip",
                    Root   = "Torso",
                    Target = "Left Leg",
                    C0     = { -1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0 },
                    C1     = {  -0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0 },
                },
                {
                    Name   = "Right Hip",
                    Root   = "Torso",
                    Target = "Right Leg",
                    C0     = {  1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0 },
                    C1     = { 0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0 },
                },
            },
        },
    },
}
```
