module ProcessingStd

using Tk
using Cairo
using Color
using Tau

include("constants.jl")

export animate, coordSystem
export Height, Width, displayHeight, displayWidth
export focused
# export cursor, frameCount, frameRate, noCursor
# export createShape, loadShape
export arc, ellipse, line, point, quad, rect, triangle
export bezier
# export bezierDetail, bezierPoint, bezierTangent, curve, curveDetail, curvePoint, curveTangent, curveTightness
export strokeWeight, strokeCap, strokeJoin, noSmooth, smooth
# export ellipseMode, rectMode
# export beginShape, endShape, vertex
# export bezierVertex, curveVertex, quadraticVertex
# export shape, shapeMode
export background, fill, noFill, colorMode, noStroke, stroke
# export applyMatrix, popMatrix, printMatrix
# export pushMatrix, resetMatrix, rotate, rotateX, rotateY, rotateZ, scale, shearX, shearY, translate
export alpha, blue, brightness, color, green, hue, lerpColor, red, saturation
# export createImage
# export image, imageMode, loadImage, noTint, requestImage, tint
# export texture, textureMode, textureWrap
# export blend, copy, filter, get, loadPixels, set, updatePixels
# export blendMode
# export createGraphics
export createFont, text, textFont
# export loadFont
export textSize, textWidth
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

# state structure

type stateStruct
    bgCol::ColorValue
    fillStuff::Bool
    fillCol::ColorValue
    strokeStuff::Bool
    strokeCol::ColorValue
    h::Int
    w::Int
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    cMode::String
    title::String
end

# initialize state structure and open drawing window
state = stateStruct(RGB(0.94, 0.92, 0.9), true, RGB(0.7,0.7,0.7), true, RGB(0,0,0), 275, 275, -1., 1., 1., -1., "RGB", "Processing.jl")
export state

win = Tk.Window(state.title, state.w, state.h) #main drawing window
c = Tk.Canvas(win)
Tk.pack(c)
cr = Tk.getgc(c) #main drawing context
s = Tk.cairo_surface(c) #main drawing surface

# initialize simulated Processing environment

Cairo.set_source(cr, state.bgCol)
Cairo.paint(cr)
Cairo.set_source(cr, state.strokeCol)
Tk.reveal(c)
Tk.update()

Cairo.set_line_width(cr, 1) # a pleasing default line width

# special Processing.jl animate() command for smoother animations
function animate()
    Tk.reveal(c)
    Tk.update()
    Cairo.new_path(cr)
end

# allow user to control coordinate system
function coordSystem(left, right, top, bottom)
    Base.Graphics.set_coords(cr, 0, 0, state.w, state.h, left, right, top, bottom)
end

# Environment

# exported environment variables
displayHeight = tcl("winfo", "screenwidth", win)
displayWidth = tcl("winfo", "screenheight", win)

#cursor

function focused()
    if isempty(tcl("focus"))
        return false
    else
        return true
    end
end

#frameCount
#frameRate

function Height()
	return state.h
end

#noCursor

function Width()
	return state.w
end

# Shape

#createShape
#loadShape

## 2D Primitives

function arc(xcent, ycent, radius, angle1, angle2)
    Cairo.new_sub_path(cr)
    Cairo.arc(cr, xcent, ycent, radius, angle1, angle2)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
    end
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill(cr)
    end
end

function ellipse(xcent, ycent, ellipseW, ellipseH)
    Cairo.save(cr)
    Cairo.move_to(cr, xcent, ycent)
    Cairo.scale(cr, ellipseW, ellipseH)
    Cairo.new_sub_path(cr)
    Cairo.arc(cr, 0, 0, 1, 0, 2*pi)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
    end
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill(cr)
    end
    Cairo.restore(cr)
end

function line(x1, y1, x2, y2)
    Cairo.move_to(cr,x1,y1)
    Cairo.line_to(cr,x2,y2)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke(cr)
    end
end

function point(x, y)
    Cairo.move_to(cr,x,y)
    dx, dy = Cairo.device_to_user_distance!(cr,[1., 0.])
    Cairo.rectangle(cr,x,y,dx,dx)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke(cr)
    end
end

function quad(x1, y1, x2, y2, x3, y3, x4, y4)
    Cairo.move_to(cr, x1, y1)
    Cairo.line_to(cr, x2, y2)
    Cairo.line_to(cr, x3, y3)
    Cairo.line_to(cr, x4, y4)
    Cairo.close_path(cr)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
    end
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill(cr)
    end
end

function rect(xcent, ycent, width, height)
    Cairo.rectangle(cr, xcent, ycent, width, height)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
    end
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill(cr)
    end
end

function triangle(x1,y1,x2,y2,x3,y3)
    Cairo.move_to(cr, x1, y1)
    Cairo.line_to(cr, x2, y2)
    Cairo.line_to(cr, x3, y3)
    Cairo.close_path(cr)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
    end
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill(cr)
    end
end

## Curves

function bezier(x1, y1, x2, y2, x3, y3, x4, y4)
    Cairo.move_to(cr, x1, y1);
    Cairo.curve_to(cr, x2, y2, x3, y3, x4, y4);
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
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

#ellipseMode

function noSmooth()
    Cairo.set_antialias(cr, Cairo.ANTIALIAS_NONE)
end

#rectMode

function smooth()
    Cairo.set_antialias(cr, Cairo.ANTIALIAS_BEST)
end

function strokeCap(capType)
    if capType == ROUND
        Cairo.set_line_cap(cr, Cairo.CAIRO_LINE_CAP_ROUND)
    elseif capType == SQUARE
        Cairo.set_line_cap(cr, Cairo.CAIRO_LINE_CAP_BUTT)
    elseif capType == PROJECT
        Cairo.set_line_cap(cr, Cairo.CAIRO_LINE_CAP_SQUARE)
    end
end

function strokeJoin(joinType)
    if joinType == MITER
        Cairo.set_line_cap(cr, Cairo.CAIRO_LINE_JOIN_MITER)
    elseif joinType == BEVEL
        Cairo.set_line_cap(cr, Cairo.CAIRO_LINE_JOIN_BEVEL)
    elseif joinType == ROUND
        Cairo.set_line_cap(cr, Cairo.CAIRO_LINE_JOIN_ROUND)
    end
end

function strokeWeight(newWeight)
    Cairo.set_line_width(cr, newWeight)
end

## Vertex

# function beginShape()
#     glBegin()
# end

#bezierVertex
#curveVertex

# function endShape()
#     glEnd()
# end

#quadraticVertex

# function vertex(x,y)
#     glVertex(x,y)
# end

## Loading & Displaying

#shape
#shapeMode

## Transform

#applyMatrix()
#popMatrix()
#printMatrix()
#pushMatrix()
#resetMatrix()
#rotate()
#rotateX()
#rotateY()
#rotateZ()
#scale()
#shearX()
#shearY()
#translate()

# Color

## Setting

function background(r, g, b, a)
    state.bgCol = RGB(r, g, b)
    Cairo.set_source(cr, state.bgCol)
    Cairo.paint(cr)
end

function colorMode(mode::String)
    state.cMode = mode
end

function fill(r, g, b, a)
    if state.fillStuff == false
        state.fillStuff = true
    end
    if state.cMode == "RGB"
        state.fillCol = RGB(r, g, b)
    else
    end
end

function noFill()
    state.fillStuff = false
end

function noStroke()
    state.strokeStuff = false
end

function stroke(r, g, b, a)
    if state.strokeStuff == false
        state.strokeStuff = true
    end
    if state.cMode == "RGB"
        state.strokeCol = RGB(r, g, b)
    else
    end
end

## Creating & Reading

function alpha(c::ColorValue)
    return c.a
end

function blue(c::ColorValue)
    return c.b
end

function brightness(c::ColorValue)
    hsv = convert(HSV, c)
    return hsv.v
end

function color(r, g, b)
    return RGB(r, g, b)
end

function green(c::ColorValue)
    return c.g
end

function hue(c::ColorValue)
    hsv = convert(HSV, c)
    return hsv.h
end

function lerpColor(c1::ColorValue, c2::ColorValue, amt::Float32)
    return weighted_color_mean(amt, c1, c2)
end

function red(c::ColorValue)
    return c.r
end

function saturation(c::ColorValue)
    hsv = convert(HSV, c)
    return hsv.s
end

# Image

#createImage

## Loading & Displaying

#image
#imageMode
#loadImage
#noTint
#requestImage
#tint

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

function createFont(fontName::String, fontSize::Float32)
    Cairo.set_font_face(cr, fontName)
    Cairo.set_font_size(cr, fontSize)
end

#loadFont

function text(str::String, x, y)
    Cairo.move_to(cr, x, y);
    Cairo.text_path(cr, str);
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill_preserve(cr)
    end
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke(cr)
    end
end

function textFont(fontName::String)
    Cairo.set_font_face(cr, fontName)
end

## Attributes

#function textAlign()
#
#end

#textLeading
#textMode

function textSize(fontSize)
    Cairo.set_font_size(cr, fontSize)
end

function textWidth(str::String)
    extents = Cairo.text_extents(cr, str)
    return extents[3]
end

## Metrics

#function textAscent()
#    extents = Cairo.scaled_font_extents(cr, str)
#    return extents[1]
#end

#function textDescent()
#    extents = Cairo.scaled_font_extents(cr, str)
#    return extents[2]
#end

end # module Processing
