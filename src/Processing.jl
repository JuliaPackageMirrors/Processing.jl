global OpenGLver="3.3"
using OpenGL

module Processing

# necessary globals

global Sdet
global _no_fill

# Environment

#cursor
#displayHeight
#displayWidth
#focused
#frameCount
#frameRate
#height
#noCursor
#size
#width

# Shape

#createShape
#loadShape

## 2D Primitives

function arc
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
    global Sdet
    shapeList = glGenLists(1)
    glNewList(shapeList, GL_COMPILE)
        quad = gluNewQuadric()    
        gluQuadricDrawStyle(quad, GLU_FILL)
        glTranslate(xcent,ycent)
        gluSphere(quad,radius,Sdet,Sdet)
        glTranslate(-xcent,-ycent)
        gluDeleteQuadric(quad)
    glEndList()
end

function sphereDetail(detail)
    global Sdet = detail
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

function beginShape
    glBegin()
end

#bezierVertex
#curveVertex

function endShape
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
    global _no_fill
    if _no_fill == false
        glColor(r, g, b, a)
    end
end

function noFill()
    _no_fill = ( _no_fill ? false : true )
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

function blendMode
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

end
