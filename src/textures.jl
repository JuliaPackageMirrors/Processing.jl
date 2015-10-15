export texture, textureMode, textureWrap, delTextures

function texture(img)
	imagesep = reinterpret(Float64, float64(data(separate(img))))

	# the following takes the image and turns into a 1D array that opengl
	# expects (i.e., the first 3 elements are the RGB values of the first
	# pixel, the next 3 elements are the RGB values of the second pixel, and
	# so on).
	# there must be an easier and faster way to do this with some sort of
	# opengl trick, though.
	if img.properties["colordim"] == 3
		w = size(imagesep,2)
		h = size(imagesep,1)
		imageGL = Array(Float64, w*h*3)
		for y=1:h
			row = 3 * w * (y - 1)
			for x=1:w
				col = 3 * (x - 1)
		        for l=1:3
		            imageGL[row+col+l] = imagesep[y,x,l]
		        end
		    end
		end
	elseif img.properties["colordim"] == 1
		w = size(imagesep,2)
		h = size(imagesep,3)
		imageGL = Array(Float64, w*h*3)
		for y=1:h
			row = 3 * w * (y - 1)
			for x=1:w
				col = 3 * (x - 1)
		        for l=1:3
		            imageGL[row+col+l] = imagesep[l,x,y]
		        end
		    end
		end
	end

	tex = GLuint[0]
	glGenTextures(1, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex[1])
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, w, h, 0, GL_RGB, GL_FLOAT, float32(imageGL))
	glGenerateMipmap(GL_TEXTURE_2D)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
	max_aniso = [float32(0.0)]
	glGetFloatv(GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso)
	# glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso[1])
	# this will require some performance testing. it might be too heavy for
	# psychophysics
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16)

	return tex[1]
end

function textureMode(mode)

end

function textureWrap(wrap)
	if wrap == "CLAMP"
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
	elseif wrap == "REPEAT"
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
	end
	return nothing
end

function delTextures(texs)
	glDeleteTextures(length(texs), [texs])
end
