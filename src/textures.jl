export texture, textureMode, textureWrap, delTextures

function texture(img)
	imagesep = separate(img)
	imagedata = reinterpret(Float64, map(Float64, data(imagesep)))

	# the following takes the image and turns into a 1D array that opengl
	# expects (i.e., the first 3 elements are the RGB values of the first
	# pixel, the next 3 elements are the RGB values of the second pixel, and
	# so on).
	# there must be an easier and faster way to do this with some sort of
	# opengl trick, though.
	if imagesep.properties["colordim"] == 3
		w = size(imagedata,2)
		h = size(imagedata,1)
		imageGL = Array(Float64, w*h*3)
		@inbounds for y=1:h
			row = 3 * w * (y - 1)
			for x=1:w
				col = 3 * (x - 1)
		        @simd for l=1:3
		            imageGL[row+col+l] = imagedata[y,x,l]
		        end
		    end
		end
	elseif imagesep.properties["colordim"] == 1
		w = size(imagedata,2)
		h = size(imagedata,3)
		imageGL = Array(Float64, w*h*3)
		@inbounds for y=1:h
			row = 3 * w * (y - 1)
			for x=1:w
				col = 3 * (x - 1)
		        @simd for l=1:3
		            imageGL[row+col+l] = imagedata[l,x,y]
		        end
		    end
		end
	end

	tex = GLuint[0]
	glGenTextures(1, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex[1])
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, w, h, 0, GL_RGB, GL_FLOAT, map(Float32, imageGL))
	glGenerateMipmap(GL_TEXTURE_2D)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
	max_aniso = [Float32(0.0)]
	glGetFloatv(GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso)
	# glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso[1])
	# this will require some performance testing. it might be too heavy for
	# psychophysics
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16)

	return tex[1], w/state.width, h/state.height
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
	glDeleteTextures(length(texs), collect(texs))
end
