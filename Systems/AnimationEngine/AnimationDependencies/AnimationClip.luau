local Dependencies = script.Parent.Parent["Dependencies"]
local CFrameInterpolator = require(Dependencies["CFrameInterpolator"])
local CFrameLerp = require(Dependencies["CFrameLerp"])
local Easing = require(Dependencies["Easing"])
local BezierEasing = require(Dependencies["BezierEasing"])
local CFrame = require(ScriptService["CFrame"])

local AnimationClip = {}
AnimationClip.__index = AnimationClip

local ANIMCLIP_DEFAULT_NAME     = "AnimationClip"
local ANIMCLIP_DEFAULT_WRAP_MODE = "Once"
local ANIMCLIP_DEFAULT_WEIGHT   = 1.0
local ANIMCLIP_DEFAULT_SPEED    = 1.0

-- Maps easing style names to your Easing module's type keys
local EASING_STYLE_MAP = {
    Linear   = "Linear",
    Quad     = "Quad",
    Cubic    = "Cube",
    Quartic  = "Quart",
    Sine     = "Sine",
}

local function GetEasingAlpha(Step, EasingStyle, Direction)
    if typeof(EasingStyle) == "string" then
        if EasingStyle == "Constant" then
            return Step >= 0.5 and 1 or 0
        end

        local mappedStyle = EASING_STYLE_MAP[EasingStyle] or "Linear"
        local mappedDirection = Direction or "In"
        local easeFn = Easing(mappedStyle, mappedDirection)
        return easeFn(Step)

    elseif typeof(EasingStyle) == "table" then
        return BezierEasing(EasingStyle[1], EasingStyle[2], EasingStyle[3], EasingStyle[4], Step)
    else
        return Step
    end
end

local function ReadFormat(Input)
    local Format = {}
    local ClipData

    if type(Input) == "table" then
        Format = Input
        ClipData = Format
    elseif Input:IsDescendantOfClass("ModuleScript") then
        Format = require(Input)
        ClipData = Format
    end

    if type(ClipData.Joints) ~= "table" then
        error("AnimationClip :: 'Joints' table expected inside clip format", 3)
    end

    ClipData.Name     = Format.Name     or ANIMCLIP_DEFAULT_NAME
    ClipData.Weight   = Format.Weight   or ANIMCLIP_DEFAULT_WEIGHT
    ClipData.Speed    = Format.Speed and math.max(0, Format.Speed) or ANIMCLIP_DEFAULT_SPEED
    ClipData.WrapMode = Format.WrapMode or ANIMCLIP_DEFAULT_WRAP_MODE

    return ClipData
end

local function WriteToClip(Clip, FrameNum, JointName, Frames)
    local Location = FrameNum - 1

    for i, Cframe in pairs(Frames) do
        local Frame = Clip[Location + i]
        if not Frame then
            Frame = {}
            Clip[Location + i] = Frame
        end
        Frame[JointName] = Cframe
    end
end

local function SortKeyframes(Keyframes)
    table.sort(Keyframes, function(a, b)
        return a.Frame < b.Frame
    end)
end

local function GetJointStartingFrame(JointKeyframes)
    local StartFrame = 1
    for _, Goal in pairs(JointKeyframes) do
		
        StartFrame = math.min(StartFrame, Goal.Frame)
    end
    return StartFrame
end

local function RenderJointFrames(Keyframes, Speed)
    local Frames = {}

    SortKeyframes(Keyframes)

    local LastKeyframe = Keyframes[1]
    local FrameNum = 1

    for _, Keyframe in ipairs(Keyframes) do
        local EasingStyle = LastKeyframe.Easing
        local Direction   = LastKeyframe.Direction or nil

        local KeyframeTime = math.round((Keyframe.Frame - 1) * Speed) + 1
        local Interval     = KeyframeTime - FrameNum
        local StartCFrame  = LastKeyframe.Transform
        local GoalCFrame   = Keyframe.Transform
        local FrameGoal    = StartCFrame

        for i = 0, Interval do
            local Step        = Interval == 0 and 0 or (i / Interval)
            local Alpha       = GetEasingAlpha(Step, EasingStyle, Direction)
            local NewFrameGoal = CFrameLerp(StartCFrame, GoalCFrame, Alpha)

            Frames[FrameNum + i] = CFrameInterpolator(FrameGoal, NewFrameGoal)
            FrameGoal = NewFrameGoal
        end

        LastKeyframe = Keyframe
        FrameNum     = KeyframeTime
    end

    return Frames
end

local function RenderClip(Clip)
    local ClipFrames = {}
    local Speed = 1 / Clip.Speed

    for JointName, Keyframes in pairs(Clip.Joints) do
        local StartFrame  = GetJointStartingFrame(Keyframes)
        local JointFrames = RenderJointFrames(Keyframes, Speed)
        WriteToClip(ClipFrames, StartFrame, JointName, JointFrames)
    end

    return ClipFrames
end

function AnimationClip.New(Clip)
    local self = setmetatable({}, AnimationClip)
    self.Clip           = ReadFormat(Clip)
    self.RenderedFrames = RenderClip(self.Clip)
    return self
end

function AnimationClip:SetSpeed(Speed)
    self.Clip.Speed     = Speed
    self.RenderedFrames = RenderClip(self.Clip)
    return self.RenderedFrames
end

function AnimationClip:SetWrapMode(WrapMode)
    self.Clip.WrapMode  = WrapMode
    self.RenderedFrames = RenderClip(self.Clip)
    return self.RenderedFrames
end

function AnimationClip:SetWeight(Weight)
    self.Clip.Weight    = Weight
    self.RenderedFrames = RenderClip(self.Clip)
    return self.RenderedFrames
end

function AnimationClip:GetFrames()
    return self.RenderedFrames
end

return AnimationClip
