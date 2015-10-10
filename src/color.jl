export background, colorMode, fillcol, noFill, noStroke
export strokecol, alpha, blue, brightness, color, green, hue
export lerpColor, red, saturation

## Setting

function background(r, g, b, a)
    glClearColor(r, g, b, a)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
end

function colorMode(mode::String)
    state.cMode = mode
end

function fillcol(r, g, b, a)
    if state.fillStuff == false
        state.fillStuff = true
    end
    if state.cMode == "RGB"
        state.fillCol = RGB[]
        for x = 1:length(r)
            push!(state.fillCol, RGB(r[x], g[x], b[x]))
        end
    else
    end
end

function noFill()
    state.fillStuff = false
end

function noStroke()
    state.strokeStuff = false
end

function strokecol(r, g, b, a)
    if state.strokeStuff == false
        state.strokeStuff = true
    end
    if state.cMode == "RGB"
        state.strokeCol = RGB[]
        for x = 1:length(r)
            push!(state.strokeCol, RGB(r[x], g[x], b[x]))
        end
    else
    end
end

## Creating & Reading

function alpha(c::Color)
    return c.a
end

function blue(c::Color)
    return c.b
end

function brightness(c::Color)
    hsv = convert(HSV, c)
    return hsv.v
end

function color(r, g, b)
    return RGB(r, g, b)
end

function green(c::Color)
    return c.g
end

function hue(c::Color)
    hsv = convert(HSV, c)
    return hsv.h
end

function lerpColor(c1::Color, c2::Color, amt)
    return weighted_color_mean(amt, c1, c2)
end

function red(c::Color)
    return c.r
end

function saturation(c::Color)
    hsv = convert(HSV, c)
    return hsv.s
end
