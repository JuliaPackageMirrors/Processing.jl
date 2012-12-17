require("GLU")
require("OpenGL")
using GLU
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
    glubegincurve()
    gluendcurve()
end

function ellipse(xcent,ycent,Mrad,mrad)
    shapeList = glgenlists(1)
    glnewlist(shapeList, GL_COMPILE)
        quad = glunewquadric()    
        gluquadricdrawstyle(quad, GLU_FILL)
        gltranslate(xcent,ycent)
        gludisk(quad,mrad,Mrad,10,10)
        gltranslate(-xcent,-ycent)
        gludeletequadric(quad)
    glendlist()
end

function line(x1,y1,x2,y2)
    glbegin(GL_LINE)
        glvertex(x1,y1)
        glvertex(x2,y2)
    glend()
end

function point(x,y)
    glbegin(GL_POINTS)
        glvertex(x,y)
    glend()
end

function quad(x1,y1,x2,y2,x3,y3,x4,y4)
    glbegin(GL_QUAD)
        glvertex(x1,y1)
        glvertex(x2,y2)
        glvertex(x3,y3)
        glvertex(x4,y4)
    glend()
end

function rect(xcent,ycent,width,height)
    glbegin(GL_QUAD)
        glvertex(xcent+width,ycent-height)
        glvertex(xcent+width,ycent+height)
        glvertex(xcent-width,ycent+height)
        glvertex(xcent-widht,ycent-height)
    glend()
end

function triangle(x1,y1,x2,y2,x3,y3)
    glbegin(GL_POLYGON)
        glvertex(x1,y1)
        glvertex(x2,y2)
        glvertex(x3,y3)
    glend()
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
    shapeList = glgenlists(1)
    glnewlist(shapeList, GL_COMPILE)
        quad = glunewquadric()    
        gluquadricdrawstyle(quad, GLU_FILL)
        gltranslate(xcent,ycent)
        glusphere(quad,radius,Sdet,Sdet)
        gltranslate(-xcent,-ycent)
        gludeletequadric(quad)
    glendlist()
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
    glbegin()
end

#bezierVertex
#curveVertex

function endShape
    glend()
end

#quadraticVertex

function vertex(x,y)
    glvertex(x,y)
end

## Loading & Displaying

#shape
#shapeMode

# Color

## Setting

function background(r, g, b, a)
    glclearcolor(r, g, b, a)
    glclear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glloadidentity()
end

#colorMode

function fill(r, g, b, a)
    global _no_fill
    if _no_fill == false
        glcolor(r, g, b, a)
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
    glenable(GL_SRC_ALPHA, GL_ONE)
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
