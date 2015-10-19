letters = ['a':'z';
		'A':'Z';
		'1':'9';
		' ';
		'	';
		'.';
		'"';
		'!';
		'?';
		'/';
		'(';
		')';
		'[';
		']';
		'{';
		'}';
		'\\']

function setupFontCharacters()
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1)

	tex = GLuint[0]
	glGenTextures(1, tex)
	glActiveTexture(GL_TEXTURE1)
	glBindTexture(GL_TEXTURE_2D, tex[1])

	fontState.textAtlas = tex[1]

	w = 0
	h = 0
	for c in letters
		img, metric = renderface(fontState.face, c)
		w += size(img, 1)
		h = max(h, size(img, 2))
	end
	fontState.atlasWidth = w
	fontState.atlasHeight = h

	# glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, w, h, 0, GL_RED, GL_FLOAT, C_NULL)
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, w, h, 0, GL_RED, GL_UNSIGNED_BYTE, C_NULL)
	glGenerateMipmap(GL_TEXTURE_2D)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
	max_aniso = [Float32(0.0)]
	glGetFloatv(GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso)
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16)

	x = 0
	for c in letters
		img, metric = renderface(fontState.face, c)

		w = size(img, 1)
		h = size(img, 2)
		# w1 = w
		# h1 = h

		# the following uses a modification of the signed distance transform
		# that comes from GLVisualize.jl. it follows some of the ideas from
		# https://www.mapbox.com/blog/text-signed-distance-fields/.
		# what we need to do is turn the glyph image into an array of Boolean
		# values. 'true' where the character is and 'false' where it is not.
		# then, we can run the sdf routine on that and save that as our
		# texture. the font shader then takes care of turning this into a
		# textual element.

		# this pads the image so that we can later downsample it properly
		# restrict_steps = 2
		# halfpad = 2*(2^restrict_steps)
		# w = w + 2*halfpad
		# h = h + 2*halfpad
		# in_or_out = zeros(Bool, w, h)

		# for x = 1:w
		#	for y = 1:h
		#		i = x-halfpad
		#		j = y-halfpad
		#		if checkbounds(Bool, size(img), i, j)
		#			in_or_out[i, j] = (img[i, j] >  0.5)
		#		else
		#			in_or_out[i, j] = false
		#		end
		#	end
		# end

		# sd = sdf(in_or_out)

		# for x = 1:restrict_steps
		#	w1, h1 = Images.restrict_size(w1), Images.restrict_size(h1)
		#	sd = Images.restrict(sd)
		# end

		# maxlen = norm([size(img, 1), size(img, 2)])

		# distfield = zeros(Float32, size(sd, 1), size(sd, 2))
		# for x = 1:size(sd, 1)
		#	for y = 1:size(sd, 2)
		#		distfield[x, y] = clamp(sd[x, y]/maxlen, -1, 1)
		#	end
		# end

		# glTexSubImage2D(GL_TEXTURE_2D, 0, x, 0, w, h, GL_RED, GL_FLOAT, distfield)
		glTexSubImage2D(GL_TEXTURE_2D, 0, x, 0, w, h, GL_RED, GL_UNSIGNED_BYTE, img)

        @inbounds character = textCharacter([w, h],
					[metric.horizontal_bearing[1], metric.horizontal_bearing[2]],
					[metric.advance[1], metric.advance[2]],
					x / fontState.atlasWidth)
        @inbounds fontState.characters[c] = character
        x += w
	end

    glPixelStorei(GL_UNPACK_ALIGNMENT, 0)
    FT_Done_Face(fontState.face[1])
end
