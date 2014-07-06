global OpenGLver="3.2"

module Processing

using OpenGL
using SDL

#include("constants.jl")

export @setup, @draw
export displayHeight, displayWidth, height, winSize, width
# export cursor focused, frameCount, frameRate, noCursor
# export createShape, loadShape
export arc, ellipse, line, point, quad, rect, triangle
# export bezier, bezierDetail, bezierPoint, bezierTangent, curve, curveDetail, curvePoint, curveTangent, curveTightness
export sphere, sphereDetail
# export box
# export ellipseMode, noSmooth, rectMode, smooth, strokeCap, strokeJoin, strokeWeight
export beginShape, endShape, vertex
# export bezierVertex, curveVertex, quadraticVertex
# export shape, shapeMode
export background, fill, noFill
# export colorMode, noStroke, Stroke
# export alpha, blue, brightness, color, green, hue, lerpColor, red, saturation
# export createImage
# export image, imageMode, loadImage, noTint, requestImage, tint
# export texture, textureMode, textureWrap
# export blend, copy, filter, get, loadPixels, set, updatePixels
export blendMode
# export createGraphics, hint
# export loadShader, resetShader, shader
# export createFont, loadFont, text, textFont
# export textAlign, textLeading, textMode, textSize, textWidth,
# export textAscent, textDescent

# state structures

type stateStruct
	Sdet::Real #sphere detail
	noFill::Bool #should drawing elements be filled or not?
	h::Integer #height of display window
	w::Integer #width of display window
	dispH::Integer #height of display area
	dispW::Integer #width of display area
	winTitle::String #title of display window
	iconTitle::String #title of docked icon
	bpp::Integer #Bits Per Pixel (BPP)

	function stateStruct()
		new(
			5, #give spheres decent detail, but be kind to low-end systems
			1, #don't fill by default
			480, #Height - default = 480
			640, #Width - default = 640
			480, #Display height - default = 480
			640, #Display width - default = 640
			"Processing.jl",
			"Processing.jl",
			16 #BPP - default = 16bpp
			)
	end
end

# macros to simulate Processing environment

macro setup(body)
	processingState = stateStruct()
	println(processingState)

	SDL_Init(SDL_INIT_VIDEO)
	videoFlags = (SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE | SDL_RESIZABLE | SDL_HWSURFACE | SDL_HWACCEL)
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
	SDL_SetVideoMode(processingState.w, processingState.h, processingState.bpp, videoFlags)
	SDL_WM_SetCaption(processingState.winTitle, processingState.iconTitle)

	glViewport(0, 0, processingState.dispW, processingState.dispH)
	glClearColor(0.0, 0.0, 0.0, 0.0)
	glClearDepth(1.0)
	glDepthFunc(GL_LESS)
	glEnable(GL_DEPTH_TEST)
	glShadeModel(GL_SMOOTH)

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity()

	gluPerspective(45.0,processingState.w/processingState.h,0.1,100.0)

	glMatrixMode(GL_MODELVIEW)

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	glLoadIdentity()

	body

	SDL_GL_SwapBuffers()
end

macro draw(body)
	while true
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
		glLoadIdentity()

		body

		SDL_GL_SwapBuffers()
	end
end

# Environment

#cursor

function displayHeight(howHigh)
	processingState.dispH = howHigh
end

function displayWidth(howWide)
	processingState.dispW = howWide
end

#focused
#frameCount
#frameRate

function height(howHigh)
	processingState.h = howHigh
end

#noCursor

function winSize(howWide, howHigh)
	width(howWide)
	height(howHigh)
end

function width(howWide)
	processingState.w = howWide
end

# Shape

#createShape
#loadShape

## 2D Primitives

function arc()
    gluBeginCurve()
    gluEndCurve()
end

function ellipse(xcent,ycent,Mrad,mrad)
    shapeList = glGenLists(1)
    glNewList(shapeList, GL_COMPILE)
        quad = gluNewQuadric()
        gluQuadricDrawStyle(quad, GLU_FILL)
        glTranslate(xcent,ycent)
        gluDisk(quad,mrad,Mrad,10,10)
        glTranslate(-xcent,-ycent)
        gluDeleteQuadric(quad)
    glEndList()
end

function line(x1,y1,x2,y2)
    glBegin(GL_LINE)
        glVertex(x1,y1)
        glVertex(x2,y2)
    glEnd()
end

function point(x,y)
    glBegin(GL_POINTS)
        glVertex(x,y)
    glEnd()
end

function quad(x1,y1,x2,y2,x3,y3,x4,y4)
    glBegin(GL_QUAD)
        glVertex(x1,y1)
        glVertex(x2,y2)
        glVertex(x3,y3)
        glVertex(x4,y4)
    glEnd()
end

function rect(xcent,ycent,width,height)
    glBegin(GL_QUAD)
        glVertex(xcent+width,ycent-height)
        glVertex(xcent+width,ycent+height)
        glVertex(xcent-width,ycent+height)
        glVertex(xcent-widht,ycent-height)
    glEnd()
end

function triangle(x1,y1,x2,y2,x3,y3)
    glBegin(GL_POLYGON)
        glVertex(x1,y1)
        glVertex(x2,y2)
        glVertex(x3,y3)
    glEnd()
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

## 3D Primitives

#box

function sphere(xcent,ycent,radius)
    shapeList = glGenLists(1)
    glNewList(shapeList, GL_COMPILE)
        quad = gluNewQuadric()
        gluQuadricDrawStyle(quad, GLU_FILL)
        glTranslate(xcent,ycent)
        gluSphere(quad,radius,processingState.Sdet,processingState.Sdet)
        glTranslate(-xcent,-ycent)
        gluDeleteQuadric(quad)
    glEndList()
end

function sphereDetail(detail)
    processingState.Sdet = detail
end

## Attributes

#ellipseMode
#noSmooth
#rectMode
#smooth
#strokeCap
#strokeJoin
#strokeWeight

## Vertex

function beginShape()
    glBegin()
end

#bezierVertex
#curveVertex

function endShape()
    glEnd()
end

#quadraticVertex

function vertex(x,y)
    glVertex(x,y)
end

## Loading & Displaying

#shape
#shapeMode

# Color

## Setting

function background(r, g, b, a)
    glClearColor(r, g, b, a)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()
end

#colorMode

function fill(r, g, b, a)
    if processingState.noFill == false
        glColor(r, g, b, a)
    end
end

function noFill()
    processingState.noFill = (processingState.noFill ? false : true)
end

#noStroke
#stroke

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

function blendMode()
    glEnable(GL_SRC_ALPHA, GL_ONE)
end

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
