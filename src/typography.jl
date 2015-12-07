include("typographyaux.jl")

export text, textFont, textSize
export textWidth, textHeight, textAscent, textDescent

## Loading & Displaying

#loadFont

function text(str::AbstractString, x, y)
    xo = x
    yo = y
	x = ((x+1)/2)*state.width
	y = ((y+1)/2)*state.height

	switchShader("fontDrawing")
	glActiveTexture(GL_TEXTURE1)
    glEnable(GL_CULL_FACE)

    posData = zeros(GLfloat, 2*6*length(str))
    texData = zeros(GLfloat, 2*6*length(str))

    n = 0
    totyadv = 0
    nforline = 0
	@inbounds for c in str
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

		xpos = x + ch.bearing[1] * state.textSize
        ypos = y - (ch.size[2] - ch.bearing[2]) * state.textSize

        w = ch.size[1] * state.textSize
        h = ch.size[2] * state.textSize

        totyadv += ch.advance[2] * state.textSize

        if w == 0 || h == 0
            continue
        end

        posData[n+1] = xpos
        posData[n+2] = ypos + h

        posData[n+3] = xpos
        posData[n+4] = ypos

        posData[n+5] = xpos + w
        posData[n+6] = ypos

        posData[n+7] = xpos
        posData[n+8] = ypos + h

        posData[n+9] = xpos + w
        posData[n+10] = ypos

        posData[n+11] = xpos + w
        posData[n+12] = ypos + h

        texData[n+1] = ch.atlasOffset
        texData[n+2] = 0.0

        texData[n+3] = ch.atlasOffset
        texData[n+4] = ch.size[2] / fontState.atlasHeight

        texData[n+5] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        texData[n+6] = ch.size[2] / fontState.atlasHeight

        texData[n+7] = ch.atlasOffset
        texData[n+8] = 0.0

        texData[n+9] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        texData[n+10] = ch.size[2] / fontState.atlasHeight

        texData[n+11] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        texData[n+12] = 0.0

		x += ch.advance[1] * state.textSize
        n += 2*6
        nforline += 1
	end
    glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
    glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)
    glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
    glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
    glDrawArrays(GL_TRIANGLES, 0, 6*length(str))

    glDisable(GL_CULL_FACE)
	switchShader("basicShapes")

    sfx = state.fbSize[1]/state.width; sfy = state.fbSize[2]/state.height
    x = (x./state.width - 0.5)*sfx
    y = ((y - totyadv/nforline)./state.height - 0.5)*sfy
    return [xo, yo, x, y]
end

function textFont(fontname::AbstractString)
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

function textWidth(str::AbstractString)
    # extents = Cairo.text_extents(cr, str)
    # return extents[1]
end

function textHeight(str::AbstractString)
    # extents = Cairo.text_extents(cr, str)
    # return extents[2]
end

## Metrics

function textAscent(str::AbstractString)
   # extents = Cairo.scaled_font_extents(cr, str)
   # return extents[1]
end

function textDescent(str::AbstractString)
   # extents = Cairo.scaled_font_extents(cr, str)
   # return extents[2]
end

function textLineLength(l)
    fontState.maxLineLength = l
end
