module Processing2D

using Tk, Cairo, Colors, Tau, Graphics

import Cairo: rotate, translate, scale, arc

# include("constants.jl")

export animate, coordSystem
export Height, Width, displayHeight, displayWidth
# export size
export focused, cursor, noCursor
# export frameCount, frameRate
# export createShape, loadShape
export arc, ellipse, line, point, quad, rect, triangle
export bezier
# export bezierDetail, bezierPoint, bezierTangent, curve, curveDetail, curvePoint, curveTangent, curveTightness
export strokeWeight, strokeCap, strokeJoin, noSmooth, smooth
export ellipseMode, rectMode
# export beginShape, endShape, vertex
# export bezierVertex, curveVertex, quadraticVertex
# export shape, shapeMode
export mouseButton, mouseClicked, mouseDragged, mouseMoved, mousePressed
export mouseReleased, mouseWheel, mouseX, mouseY, pmouseX, pmouseY
export save
export background, fill, noFill, colorMode, noStroke, stroke
# export applyMatrix
export popMatrix, printMatrix, pushMatrix, resetMatrix, rotate
export scale, shearX, shearY, translate
export alpha, blue, brightness, color, green, hue, lerpColor, red, saturation
# export createImage
export image, loadImage, noTint
# export imageMode, tint, requestImage
# export texture, textureMode, textureWrap
# export blend, copy, filter, get, loadPixels, set, updatePixels
# export blendMode
# export createGraphics
export createFont, text, textFont
# export loadFont
export textSize, textWidth, textExtents
# export textAlign, textLeading, textMode
# export textAscent, textDescent

# state variables

# bgCol = RGB(0.94, 0.92, 0.9) #pleasant default background color from Jeff Bezanson's Fractals iJulia notebook (http://nbviewer.ipython.org/url/beowulf.csail.mit.edu/18.337/fractals.ipynb)
# fillStuff = true #should drawing elements be filled or not?
# fillCol = RGB(0.7,0.7,0.7) #color to be used for filling elements
# strokeStuff = true #should drawing elements be stroked or not?
# strokeCol = RGB(0,0,0) #color to be used for stroking elements
# h = 275 #height of display window
# w = 275 #width of display window
# left = -1 #scaling of left-hand of x-axis in plotting coordinate system
# right = 1 #scaling of right-hand of x-axis in plotting coordinate system
# top = 1 #scaling of top-hand of x-axis in plotting coordinate system
# bottom = -1 #scaling of bottom-hand of x-axis in plotting coordinate system
# cMode = "RGB" #what color space are we using for colors?
# title = "Processing.jl" #window title
# ellipseMode = CENTER #specify ellipses center, width, and height when drawing it by default
# rectMode = CORNER #specficy rects upper-left corner coordinate and its width and height when drawing it by default
# cmX
# cmY
# pmX
# pmY
# mouse1Pressed
# mouse2Pressed
# mouse3Pressed
# mouse1Released
# mouse2Released
# mouse3Released
# mouse1Dragged

# state structure

type stateStruct
    bgCol::Color
    fillStuff::Bool
    fillCol::Color
    strokeStuff::Bool
    strokeCol::Color
    h::Int
    w::Int
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    cMode::AbstractString
    title::AbstractString
    tintStuff::Bool
    ellipseMode::AbstractString
    rectMode::AbstractString
    cmX::Int
    cmY::Int
    pmX::Int
    pmY::Int
    mouse1Pressed::Bool
    mouse2Pressed::Bool
    mouse3Pressed::Bool
    mouse1Released::Bool
    mouse2Released::Bool
    mouse3Released::Bool
    mouse1Dragged::Bool
end

windows = Tk.TkWidget[]
canvases = Tk.Canvas[]
bpcontext = Cairo.CairoContext[]
contexts = Cairo.CairoContext[]
bpsurface = Cairo.CairoSurface[]
surfaces = Cairo.CairoSurface[]
states = stateStruct[]

function screen(w, h)
    push!(states, stateStruct(RGB(0.8, 0.8, 0.8), true, RGB(1.0,1.0,1.0), true, RGB(0,0,0), 275, 275, -1., 1., 1., -1., "RGB", "Processing.jl", false, "CENTER", "CORNER", 0, 0, 0, 0, false, false, false, true, true, true, false))

    states[end].w = w
    states[end].h = h

    push!(windows, Tk.Window(states[end].title, states[end].w, states[end].h))
    push!(canvases, Tk.Canvas(windows[end]))
    Tk.pack(canvases[end])
    push!(contexts, Tk.getgc(canvases[end]))
    push!(surfaces, Tk.cairo_surface(canvases[end]))

    canvases[end].mouse.button1press = (c, x, y) -> begin
        states[end].mouse1Pressed = true
    end
    canvases[end].mouse.button2press = (c, x, y) -> begin
        states[end].mouse2Pressed = true
    end
    canvases[end].mouse.button3press = (c, x, y) -> begin
        states[end].mouse3Pressed = true
    end
    canvases[end].mouse.button1release = (c, x, y) -> begin
        states[end].mouse1Pressed = false
        states[end].mouse1Dragged = false
    end
    canvases[end].mouse.button2release = (c, x, y) -> begin
        states[end].mouse2Pressed = false
    end
    canvases[end].mouse.button3release = (c, x, y) -> begin
        states[end].mouse3Pressed = false
    end
    canvases[end].mouse.motion = (c, x, y) -> begin
        states[end].pmX = states[end].cmX; states[end].pmY = states[end].cmY
        states[end].cmX = x; states[end].cmY = y
    end
    canvases[end].mouse.button1motion = (c, x, y) -> begin
        states[end].pmX = states[end].cmX; states[end].pmY = states[end].cmY
        states[end].cmX = x; states[end].cmY = y
        states[end].mouse1Dragged = true
    end

    # initialize simulated Processing environment

    Cairo.set_source(contexts[end], states[end].bgCol)
    Cairo.paint(contexts[end])
    Cairo.set_source(contexts[end], states[end].strokeCol)
    Tk.reveal(canvases[end])
    Tk.update()

    Cairo.set_line_width(contexts[end], 1)

    return length(windows)
end

# special Processing.jl animate() command for smoother animations
function animate(wi)
    if Tk.tcl("winfo", "exists", windows[wi]) == "1"
        Tk.reveal(canvases[wi])
        Tk.update()
        Cairo.new_path(contexts[wi])
    else
        println("Window is no longer open.")
    end
end

# allow user to control coordinate system
function coordSystem(wi, left, right, top, bottom)
    Graphics.set_coords(contexts[wi], 0, 0, states[wi].w, states[wi].h, left, right, top, bottom)
end

# Environment

# exported environment variables
displayHeight(wi) = Tk.tcl("winfo", "screenwidth", windows[wi])
displayWidth(wi) = Tk.tcl("winfo", "screenheight", windows[wi])

function cursor(cursorType)
    if cursorType == ARROW
        Tk.tcl("cursors", "arrow")
    elseif cursorType == CROSS
        Tk.tcl("cursors", "cross")
    elseif cursorType == HAND
        @linux_only Tk.tcl("cursors", "hand1")
        @windows_only Tk.tcl("cursors", "hand1")
        @osx_only Tk.tcl("cursors", "pointinghand")
    elseif cursorType == MOVE
        @linux_only Tk.tcl("cursors", "target")
        @windows_only Tk.tcl("cursors", "size")
        @osx_only Tk.tcl("cursors", "pointinghand")
    elseif cursorType == TEXT
        Tk.tcl("cursors", "ibeam")
    elseif cursorType == WAIT
        @linux_only Tk.tcl("cursors", "clock")
        @windows_only Tk.tcl("cursors", "wait")
        @osx_only Tk.tcl("cursors", "spinning")
    end
end

function focused()
    if isempty(Tk.tcl("focus"))
        return false
    else
        return true
    end
end

#frameCount
#frameRate

function Height(wi)
	return states[wi].h
end

function noCursor()
    @windows_only Tk.tcl("cursors", "no")
end

function Width(wi)
	return states[wi].w
end

# Shape

#createShape
#loadShape

## 2D Primitives

function arc(wi, xcent, ycent, ellipseW, ellipseH, angle1, angle2, mode)
    Cairo.save(contexts[wi])
    Cairo.translate(contexts[wi], xcent, ycent)
    Cairo.scale(contexts[wi], ellipseW, ellipseH)
    Cairo.new_sub_path(contexts[wi])
    if mode == OPEN || mode == CHORD
        Cairo.arc(contexts[wi], 0, 0, 1, angle1, angle2)
    elseif mode == PIE
    end
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke_preserve(contexts[wi])
    end
    if states[wi].fillStuff
        Cairo.set_source(contexts[wi], states[wi].fillCol)
        Cairo.fill(contexts[wi])
    end
    if mode == CHORD
        Cairo.move_to(contexts[wi], cos(angle1), sin(angle1))
        Cairo.line_to(contexts[wi], cos(angle2), sin(angle2))
    end
    Cairo.restore(contexts[wi])
end

function ellipse(wi, xcent, ycent, ellipseW, ellipseH)
    Cairo.save(contexts[wi])
    if states[wi].ellipseMode == "RADIUS"
        Cairo.translate(contexts[wi], xcent, ycent)
        Cairo.scale(contexts[wi], ellipseW/2, ellipseH/2)
    elseif states[wi].ellipseMode == "CENTER"
        Cairo.translate(contexts[wi], xcent, ycent)
        Cairo.scale(contexts[wi], ellipseW, ellipseH)
    elseif states[wi].ellipseMode == "CORNER"
        Cairo.translate(contexts[wi], xcent+ellipseW/2, ycent+ellipseH/2)
        Cairo.scale(contexts[wi], ellipseW, ellipseH)
    elseif states[wi].ellipseMode == "CORNERS"
        Cairo.translate(contexts[wi], xcent, ycent)
        Cairo.scale(contexts[wi], ellipseW, ellipseH)
    end
    Cairo.new_sub_path(contexts[wi])
    Cairo.arc(contexts[wi], 0, 0, 1, 0, 2*pi)
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke_preserve(contexts[wi])
    end
    if states[wi].fillStuff
        Cairo.set_source(contexts[wi], states[wi].fillCol)
        Cairo.fill(contexts[wi])
    end
    Cairo.restore(contexts[wi])
end

function line(wi, x1, y1, x2, y2)
    Cairo.move_to(contexts[wi],x1,y1)
    Cairo.line_to(contexts[wi],x2,y2)
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke(contexts[wi])
    end
end

function point(wi, x, y)
    Cairo.move_to(contexts[wi],x,y)
    dx, dy = Cairo.device_to_user_distance!(contexts[wi],[1., 0.])
    Cairo.rectangle(contexts[wi],x,y,dx,dx)
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke(contexts[wi])
    end
end

function quad(wi, x1, y1, x2, y2, x3, y3, x4, y4)
    Cairo.move_to(contexts[wi], x1, y1)
    Cairo.line_to(contexts[wi], x2, y2)
    Cairo.line_to(contexts[wi], x3, y3)
    Cairo.line_to(contexts[wi], x4, y4)
    Cairo.close_path(contexts[wi])
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke_preserve(contexts[wi])
    end
    if states[wi].fillStuff
        Cairo.set_source(contexts[wi], states[wi].fillCol)
        Cairo.fill(contexts[wi])
    end
end

function rect(wi, xtopleft, ytopleft, width, height)
    if states[wi].rectMode == "CORNER"
        Cairo.rectangle(contexts[wi], xtopleft, ytopleft, width, height)
    elseif states[wi].rectMode == "CORNERS" # in this case, width and height are
                                     # reinterpreted as (x,y) coords of
                                     # bottom-right corner
        Cairo.rectangle(contexts[wi], xtopleft, ytopleft, width-xtopleft, height-ytopleft)
    elseif states[wi].rectMode == "CENTER"
        Cairo.rectangle(contexts[wi], xtopleft-width/2, ytopleft-height/2, width, height)
    elseif states[wi].rectMode == "RADIUS"
        Cairo.rectangle(contexts[wi], xtopleft-width/2, ytopleft-height/2, width/2, height/2)
    end
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke_preserve(contexts[wi])
    end
    if states[wi].fillStuff
        Cairo.set_source(contexts[wi], states[wi].fillCol)
        Cairo.fill(contexts[wi])
    end
end

function triangle(wi,x1,y1,x2,y2,x3,y3)
    Cairo.move_to(contexts[wi], x1, y1)
    Cairo.line_to(contexts[wi], x2, y2)
    Cairo.line_to(contexts[wi], x3, y3)
    Cairo.close_path(contexts[wi])
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke_preserve(contexts[wi])
    end
    if states[wi].fillStuff
        Cairo.set_source(contexts[wi], states[wi].fillCol)
        Cairo.fill(contexts[wi])
    end
end

## Curves

function bezier(wi, x1, y1, x2, y2, x3, y3, x4, y4)
    Cairo.move_to(contexts[wi], x1, y1);
    Cairo.curve_to(contexts[wi], x2, y2, x3, y3, x4, y4);
    if states[wi].strokeStuff
        Cairo.set_source(contexts[wi], states[wi].strokeCol)
        Cairo.stroke_preserve(contexts[wi])
    end
end

#bezierDetail
#bezierPoint
#bezierTangent
#curve
#curveDetail
#curvePoint
#curveTangent
#curveTightness

## Attributes

function ellipseMode(wi, eMode::AbstractString)
    states[wi].ellipseMode = eMode
end

function noSmooth(wi)
    Cairo.set_antialias(contexts[wi], Cairo.ANTIALIAS_NONE)
end

function rectMode(wi, rMode::AbstractString)
    states[wi].rectMode = rMode
end

function smooth(wi)
    Cairo.set_antialias(contexts[wi], Cairo.ANTIALIAS_BEST)
end

function strokeCap(wi, capType)
    if capType == ROUND
        Cairo.set_line_cap(contexts[wi], Cairo.CAIRO_LINE_CAP_ROUND)
    elseif capType == SQUARE
        Cairo.set_line_cap(contexts[wi], Cairo.CAIRO_LINE_CAP_BUTT)
    elseif capType == PROJECT
        Cairo.set_line_cap(contexts[wi], Cairo.CAIRO_LINE_CAP_SQUARE)
    end
end

function strokeJoin(wi, joinType)
    if joinType == MITER
        Cairo.set_line_cap(contexts[wi], Cairo.CAIRO_LINE_JOIN_MITER)
    elseif joinType == BEVEL
        Cairo.set_line_cap(contexts[wi], Cairo.CAIRO_LINE_JOIN_BEVEL)
    elseif joinType == ROUND
        Cairo.set_line_cap(contexts[wi], Cairo.CAIRO_LINE_JOIN_ROUND)
    end
end

function strokeWeight(wi, newWeight)
    Cairo.set_line_width(contexts[wi], newWeight)
end

## Vertex

# function beginShape()
#
# end

#bezierVertex
#curveVertex

# function endShape()
#
# end

#quadraticVertex

# function vertex(x,y)
#
# end

## Loading & Displaying

#shape
#shapeMode

## Input

# Mouse

function mouseButton(wi)
    if states[wi].mouse1Pressed
        return LEFT
    elseif states[wi].mouse2Pressed
        return CENTER
    elseif states[wi].mouse3Pressed
        return RIGHT
    end
end

function mouseClicked()

end

function mouseDragged()

end

function mouseMoved()

end

function mousePressed(wi)
    if states[wi].mouse1Pressed || states[wi].mouse2Pressed || states[wi].mouse3Pressed
        return true
    else
        return false
    end
end

function mouseReleased()

end

function mouseWheel()

end

function mouseX(wi)
    return states[wi].cmX
end

function mouseY(wi)
    return states[wi].cmX
end

function pmouseX(wi)
    return states[wi].pmX
end

function pmouseY(wi)
    return states[wi].pmY
end

function save(wi, fname::AbstractString)
    Cairo.write_to_png(surfaces[wi], fname)
    # surface = Cairo.CairoPDFSurface(filename, width, height)
    # CairoRenderer(surface)
    # finish(surface)
end

function PDFContext(wi, fn)
    push!(bpsurface, surfaces[wi])
    surfaces[wi] = Cairo.CairoPDFSurface(fn, Width(wi), Height(wi))
    push!(bpcontext, contexts[wi])
    contexts[wi] = Cairo.CairoContext(surfaces[wi])
    Cairo.set_source(contexts[wi], states[wi].bgCol)
    Cairo.paint(contexts[wi])
    Cairo.set_source(contexts[wi], states[wi].strokeCol)
end

function popContext(wi)
    surfaces[wi] = pop!(bpsurface)
    contexts[wi] = pop!(bpcontext)
end

## Transform

#applyMatrix()

function popMatrix(wi)
    Cairo.restore(contexts[wi])
end

function printMatrix(wi)
    println(Cairo.get_matrix(contexts[wi]))
end

function pushMatrix(wi)
    Cairo.save(contexts[wi])
end

function resetMatrix(wi)
    Cairo.identity_matrix(contexts[wi])
end

function rotate(wi, ang)
    Cairo.rotate(contexts[wi], ang)
end

function scale(wi, sx, sy)
    Cairo.scale(contexts[wi], sx, sy)
end

#shearX()
#shearY()

function translate(wi, x, y)
    Cairo.translate(contexts[wi], x, y)
end

# Color

## Setting

function background(wi, r, g, b, a)
    states[wi].bgCol = RGB(r, g, b)
    Cairo.set_source(contexts[wi], states[wi].bgCol)
    Cairo.paint(contexts[wi])
    Cairo.set_source(contexts[wi], states[wi].strokeCol)
end

function colorMode(wi, mode::AbstractString)
    states[wi].cMode = mode
end

function fill(wi, r, g, b, a)
    if states[wi].fillStuff == false
        states[wi].fillStuff = true
    end
    if states[wi].cMode == "RGB"
        states[wi].fillCol = RGB(r, g, b)
    else
    end
end

function noFill(wi)
    states[wi].fillStuff = false
end

function noStroke(wi)
    states[wi].strokeStuff = false
end

function stroke(wi, r, g, b, a)
    if states[wi].strokeStuff == false
        states[wi].strokeStuff = true
    end
    if states[wi].cMode == "RGB"
        states[wi].strokeCol = RGB(r, g, b)
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

function lerpColor(c1::Color, c2::Color, amt::Float32)
    return weighted_color_mean(amt, c1, c2)
end

function red(c::Color)
    return c.r
end

function saturation(c::Color)
    hsv = convert(HSV, c)
    return hsv.s
end

# Image

#function createImage(x, y, colorSpace::AbstractString)
#
#end

## Loading & Displaying

function image(wi, img, x, y, w, h)
    Cairo.image(contexts[wi], img, x, y, w, h)
end

#imageMode

function loadImage(fileName::AbstractString)
    return Cairo.read_from_png(fileName)
end

function noTint(wi)
    states[wi].tintStuff = false
end

#requestImage

#function tint()
#
#end

## Textures

#texture
#textureMode
#textureWrap

## Pixels

#blend
#copy
#filter
#get
#loadPixels
#set
#updatePixels

# Rendering

# function blendMode()
#
# end

#createGraphics

# Typography

## Loading & Displaying

function createFont(wi, fontName::AbstractString, fontSize)
    Cairo.select_font_face(contexts[wi], fontName, Cairo.FONT_SLANT_NORMAL,
                 Cairo.FONT_WEIGHT_NORMAL)
    Cairo.set_font_size(contexts[wi], fontSize)
end

#loadFont

function text(wi, str::AbstractString, x, y; kwargs...)
    Cairo.text(contexts[wi], x, y, str; markup=false, kwargs...)

    # Cairo.text_path(contexts[wi], str)
    # if states[wi].fillStuff
    #     Cairo.set_source(contexts[wi], states[wi].fillCol)
    #     Cairo.fill_preserve(contexts[wi])
    # end
    # if states[wi].strokeStuff
    #     Cairo.set_source(contexts[wi], states[wi].strokeCol)
    #     Cairo.stroke(contexts[wi])
    # end
end

function textFont(wi, fontName::AbstractString)
    Cairo.set_font_face(contexts[wi], fontName)
end

## Attributes

#function textAlign()
#
#end

#textLeading
#textMode

function textSize(wi, fontSize)
    Cairo.set_font_size(contexts[wi], fontSize)
end

function textWidth(wi, str::AbstractString)
    extents = Cairo.text_extents(contexts[wi], str)
    return extents[3]
end

function textExtents(wi, str::AbstractString)
    return Cairo.text_extents(contexts[wi], str)
end

## Metrics

#function textAscent(str::AbstractString)
#    extents = Cairo.scaled_font_extents(contexts[wi], str)
#    return extents[1]
#end

#function textDescent(str::AbstractString)
#    extents = scaled_font_extents(contexts[wi], str)
#    return extents[2]
#end

end # module Processing
