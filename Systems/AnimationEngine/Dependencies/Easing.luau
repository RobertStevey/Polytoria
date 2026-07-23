local function Easing(easingType, direction)
    local easings = {
        Linear = {
            In    = function(step) return step end,
            Out   = function(step) return step end,
            InOut = function(step) return step end,
        },
        Quad = {
            In    = function(step) return step ^ 2 end,
            Out   = function(step) return 1 - (1 - step) ^ 2 end,
            InOut = function(step)
                if step < 0.5 then return 2 * step ^ 2
                else return 1 - (-2 * step + 2) ^ 2 * 0.5 end
            end,
        },
        Cube = {
            In    = function(step) return step ^ 3 end,
            Out   = function(step) return 1 - (1 - step) ^ 3 end,
            InOut = function(step)
                if step < 0.5 then return 4 * step ^ 3
                else return 1 - (-2 * step + 2) ^ 3 * 0.5 end
            end,
        },
        Quart = {
            In    = function(step) return step ^ 4 end,
            Out   = function(step) return 1 - (1 - step) ^ 4 end,
            InOut = function(step)
                if step < 0.5 then return 8 * step ^ 4
                else return 1 - (-2 * step + 2) ^ 4 * 0.5 end
            end,
        },
        Sine = {
            In    = function(step) return 1 - math.cos(step * math.pi * 0.5) end,
            Out   = function(step) return math.sin(step * math.pi * 0.5) end,
            InOut = function(step) return 0.5 + math.cos(step * math.pi) * -0.5 end,
        },
    }

    local easing = easings[easingType]
    assert(easing, "Unknown easing type: " .. tostring(easingType))

    local fn = easing[direction or "In"]
    assert(fn, "Unknown direction: " .. tostring(direction))

    return fn
end

return Easing
