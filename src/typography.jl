include("typographyaux.jl")

export text, textFont, textSize
export textWidth, textHeight, textAscent, textDescent

## Loading & Displaying

#loadFont

function text(str::String, x, y)
	x = ((x+1)/2)*state.width
    xo = x
	y = ((y+1)/2)*state.height
    yo = y

	switchShader("fontDrawing")
	glActiveTexture(GL_TEXTURE1)
    glEnable(GL_CULL_FACE)
	# glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[2])

    vertexData = zeros(GLfloat, 6*9*length(str))

    n = 0
    totyadv = 0
    nforline = 0
	for c in str
        # if we hit a newline character or we reach the max line
        # length, then move to next line, where the next line is
        # determined by the average y advance from the characters
        # of the previous line.
        if c == '\n' || nforline == fontState.maxLineLength
            cht = fontState.characters[str[1]]
            x = xo
            y -= totyadv/nforline
            totyadv = 0
            nforline = 0
            continue
        end

		ch = fontState.characters[c]

		@inbounds xpos = x + ch.bearing[1] * state.textSize
        @inbounds ypos = y - (ch.size[2] - ch.bearing[2]) * state.textSize

        @inbounds w = ch.size[1] * state.textSize
        @inbounds h = ch.size[2] * state.textSize

        @inbounds totyadv += ch.advance[2] * state.textSize

        if w == 0 || h == 0
            continue
        end

        @inbounds vertexData[n+1] = xpos
        @inbounds vertexData[n+2] = ypos + h
        @inbounds vertexData[n+3] = 0.0
        @inbounds vertexData[n+4] = 1.0

        @inbounds vertexData[n+5] = ch.atlasOffset
        @inbounds vertexData[n+6] = 0.0
        @inbounds vertexData[n+7] = 0.0
        @inbounds vertexData[n+8] = 0.0
        @inbounds vertexData[n+9] = 0.0

		@inbounds vertexData[n+10] = xpos
        @inbounds vertexData[n+11] = ypos
        @inbounds vertexData[n+12] = 0.0
        @inbounds vertexData[n+13] = 1.0

        @inbounds vertexData[n+14] = ch.atlasOffset
        @inbounds vertexData[n+15] = ch.size[2] / fontState.atlasHeight
        @inbounds vertexData[n+16] = 0.0
        @inbounds vertexData[n+17] = 0.0
        @inbounds vertexData[n+18] = 0.0

        @inbounds vertexData[n+19] = xpos + w
        @inbounds vertexData[n+20] = ypos
        @inbounds vertexData[n+21] = 0.0
        @inbounds vertexData[n+22] = 1.0

        @inbounds vertexData[n+23] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        @inbounds vertexData[n+24] = ch.size[2] / fontState.atlasHeight
        @inbounds vertexData[n+25] = 0.0
        @inbounds vertexData[n+26] = 0.0
        @inbounds vertexData[n+27] = 0.0

        @inbounds vertexData[n+28] = xpos
        @inbounds vertexData[n+29] = ypos + h
        @inbounds vertexData[n+30] = 0.0
        @inbounds vertexData[n+31] = 1.0

        @inbounds vertexData[n+32] = ch.atlasOffset
        @inbounds vertexData[n+33] = 0.0
        @inbounds vertexData[n+34] = 0.0
        @inbounds vertexData[n+35] = 0.0
        @inbounds vertexData[n+36] = 0.0

        @inbounds vertexData[n+37] = xpos + w
        @inbounds vertexData[n+38] = ypos
        @inbounds vertexData[n+39] = 0.0
        @inbounds vertexData[n+40] = 1.0

        @inbounds vertexData[n+41] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        @inbounds vertexData[n+42] = ch.size[2] / fontState.atlasHeight
        @inbounds vertexData[n+43] = 0.0
        @inbounds vertexData[n+44] = 0.0
        @inbounds vertexData[n+45] = 0.0

        @inbounds vertexData[n+46] = xpos + w
        @inbounds vertexData[n+47] = ypos + h
        @inbounds vertexData[n+48] = 0.0
        @inbounds vertexData[n+49] = 1.0

        @inbounds vertexData[n+50] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        @inbounds vertexData[n+51] = 0.0
        @inbounds vertexData[n+52] = 0.0
        @inbounds vertexData[n+53] = 0.0
        @inbounds vertexData[n+54] = 0.0

		@inbounds x += ch.advance[1] * state.textSize
        n += 6*9
        nforline += 1
	end
    # glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertexData), vertexData)
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_DYNAMIC_DRAW)
    glDrawArrays(GL_TRIANGLES, 0, 6*length(str))

    glDisable(GL_CULL_FACE)
	switchShader("basicShapes")
	# glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[1])
end

function textFont(fontname::String)
    # for the time being, we only allow system fonts or those that have been
    # installed directly into the main system storage
    @windows_only state.fontFace = "C:/Windows/Fonts/"*fontname
    @linux_only state.fontFace = "/usr/share/fonts/"*fontname
    @osx_only state.fontFace = "/System/Library/Fonts/"*fontname
    fontState = fontStruct(newface(state.fontFace), Dict(' ' => blankChar), 0, 12)
	setpixelsize(fontState.face, fontState.fontWidth, fontState.fontHeight)
	setupFontCharacters()
end

## Attributes

#function textAlign()
#
#end

#textLeading
#textMode

function textSize(size)
	state.textSize = size
end

function textWidth(str::String)
    # extents = Cairo.text_extents(cr, str)
    # return extents[1]
end

function textHeight(str::String)
    # extents = Cairo.text_extents(cr, str)
    # return extents[2]
end

## Metrics

function textAscent(str::String)
   # extents = Cairo.scaled_font_extents(cr, str)
   # return extents[1]
end

function textDescent(str::String)
   # extents = Cairo.scaled_font_extents(cr, str)
   # return extents[2]
end

function textLineLength(l)
    fontState.maxLineLength = l
end
