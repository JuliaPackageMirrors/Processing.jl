export box

function box(s)
	cubeVertices = GLfloat[
		-1.0, -1.0, -1.0,
		-1.0, -1.0,  1.0,
		-1.0,  1.0,  1.0,
		1.0,  1.0, -1.0,
		-1.0, -1.0, -1.0,
		-1.0,  1.0, -1.0,
		1.0, -1.0,  1.0,
		-1.0, -1.0, -1.0,
		1.0, -1.0, -1.0,
		1.0,  1.0, -1.0,
		1.0, -1.0, -1.0,
		-1.0, -1.0, -1.0,
		-1.0, -1.0, -1.0,
		-1.0,  1.0,  1.0,
		-1.0,  1.0, -1.0,
		1.0, -1.0,  1.0,
		-1.0, -1.0,  1.0,
		-1.0, -1.0, -1.0,
		-1.0,  1.0,  1.0,
		-1.0, -1.0,  1.0,
		1.0, -1.0,  1.0,
		1.0,  1.0,  1.0,
		1.0, -1.0, -1.0,
		1.0,  1.0, -1.0,
		1.0, -1.0, -1.0,
		1.0,  1.0,  1.0,
		1.0, -1.0,  1.0,
		1.0,  1.0,  1.0,
		1.0,  1.0, -1.0,
		-1.0,  1.0, -1.0,
		1.0,  1.0,  1.0,
		-1.0,  1.0, -1.0,
		-1.0,  1.0,  1.0,
		1.0,  1.0,  1.0,
		-1.0,  1.0,  1.0,
		1.0, -1.0,  1.0]

	cubeVertices = cubeVertices * s

	vertexStride = 35*9
	vertexData = zeros(GLfloat, 35*9*length(s))

	for x = 1:35
		@inbounds vertexData[9*(x-1)+1] = cubeVertices[3*(x-1)+1]
		@inbounds vertexData[9*(x-1)+2] = cubeVertices[3*(x-1)+2]
		@inbounds vertexData[9*(x-1)+3] = cubeVertices[3*(x-1)+3]
	end

	# if state.drawTexture
	#	# texcoords
	#	vertexData[8:vertexStride:end] = 0
	#	vertexData[9:vertexStride:end] = 0

	#	vertexData[17:vertexStride:end] = 1
	#	vertexData[18:vertexStride:end] = 0

	#	vertexData[26:vertexStride:end] = 1
	#	vertexData[27:vertexStride:end] = 1

	#	vertexData[35:vertexStride:end] = 0
	#	vertexData[36:vertexStride:end] = 1
	# end

	# elements = zeros(GLuint, 6*length(x1))

	# elements[1] = 0
	# elements[2] = 1
	# elements[3] = 2
	# elements[4] = 2
	# elements[5] = 3
	# elements[6] = 0

	# index = 7
	# for x = 2:length(x1)
	#	elements[index] = elements[index-6] + 4
	#	elements[index+1] = elements[(index-6)+1] + 4
	#	elements[index+2] = elements[(index-6)+2] + 4
	#	elements[index+3] = elements[(index-6)+3] + 4
	#	elements[index+4] = elements[(index-6)+4] + 4
	#	elements[index+5] = elements[(index-6)+5] + 4
	#	index += 6
	# end

	dataStride = 35
	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, 35*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(s)
			@inbounds glDrawArrays(GL_TRIANGLES, (x-1)*dataStride, dataStride)
		end
		# glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		# glDrawElements(GL_TRIANGLES, 6*length(xtopleft), GL_UNSIGNED_INT, C_NULL)
	end
	# if state.strokeStuff
	#	loadColors!(vertexData, state.strokeCol, 9, 35*9)
	#	glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
	#	dataStride = 35
	#	for x = 1:length(x1)
	#		glDrawArrays(GL_LINE_LOOP, (x-1)*dataStride, dataStride)
	#	end
	# end
end

function sphere(r)
	dataStride = 35
	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, 35*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(s)
			@inbounds glDrawArrays(GL_TRIANGLES, (x-1)*dataStride, dataStride)
		end
		# glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		# glDrawElements(GL_TRIANGLES, 6*length(xtopleft), GL_UNSIGNED_INT, C_NULL)
	end
	# if state.strokeStuff
	#	loadColors!(vertexData, state.strokeCol, 9, 35*9)
	#	glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
	#	dataStride = 35
	#	for x = 1:length(x1)
	#		glDrawArrays(GL_LINE_LOOP, (x-1)*dataStride, dataStride)
	#	end
	# end
end
