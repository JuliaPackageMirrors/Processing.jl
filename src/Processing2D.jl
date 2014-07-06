module ProcessingStd

using Tk
using Cairo
using Color

import Base.Graphics: width, height

#include("constants.jl")

export animate, coordSystem
export height, width, displayHeight, displayWidth
# export cursor focused, frameCount, frameRate, noCursor
# export createShape, loadShape
export arc, ellipse, line, point, quad, rect, triangle
# export bezier, bezierDetail, bezierPoint, bezierTangent, curve, curveDetail, curvePoint, curveTangent, curveTightness
export strokeWeight
# export ellipseMode, noSmooth, rectMode, smooth, strokeCap, strokeJoin
# export beginShape, endShape, vertex
# export bezierVertex, curveVertex, quadraticVertex
# export shape, shapeMode
export background, fill, noFill
export colorMode, noStroke, stroke
# export alpha, blue, brightness, color, green, hue, lerpColor, red, saturation
# export createImage
# export image, imageMode, loadImage, noTint, requestImage, tint
# export texture, textureMode, textureWrap
# export blend, copy, filter, get, loadPixels, set, updatePixels
# export blendMode
# export createGraphics, hint
# export loadShader, resetShader, shader
# export createFont, loadFont, text, textFont
# export textAlign, textLeading, textMode, textSize, textWidth,
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
#focused
#frameCount
#frameRate

function height(howHigh)
	state.h = howHigh
    tcl("wm", "geometry", win, "$(w)x$(h)")
end

#noCursor

function width(howWide)
	state.w = howWide
    tcl("wm", "geometry", win, "$(w)x$(h)")
end

# Shape

#createShape
#loadShape

## 2D Primitives

function arc(xcent, ycent, radius, angle1, angle2)
    Cairo.new_path(cr)
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
    Cairo.new_path(cr)
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
    Cairo.new_path(cr)
    Cairo.move_to(cr,x1,y1)
    Cairo.line_to(cr,x2,y2)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke_preserve(cr)
    end
    if state.fillStuff
        Cairo.set_source(cr, state.fillCol)
        Cairo.fill(cr)
    end
end

function point(x, y)
    Cairo.new_path(cr)
    Cairo.move_to(cr,x,y)
    dx, dy = Cairo.device_to_user_distance!(cr,[1., 0.])
    Cairo.rectangle(cr,x,y,dx,dx)
    if state.strokeStuff
        Cairo.set_source(cr, state.strokeCol)
        Cairo.stroke(cr)
    end
end

function quad(x1, y1, x2, y2, x3, y3, x4, y4)
    Cairo.new_path(cr)
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
    Cairo.new_path(cr)
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
    Cairo.new_path(cr)
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

#bezier
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
#noSmooth
#rectMode
#smooth
#strokeCap
#strokeJoin

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

# Color

## Setting

function background(r, g, b, a)
    state.bgCol = RGBA(r, g, b, a)
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

#alpha
#blue
#brightness
#color
#green
#hue
#lerpColor
#red
#saturation

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
#     glEnable(GL_SRC_ALPHA, GL_ONE)
# end

#createGraphics
#hint

## Shaders

#loadShader
#resetShader
#shader

# Typography

## Loading & Displaying

#createFont
#loadFont
#text
#textFont

## Attributes

#textAlign
#textLeading
#textMode
#textSize
#textWidth

## Metrics

#textAscent
#textDescent

end # module Processing
