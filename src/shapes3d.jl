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

	posStride = 35*3
	posData = zeros(GLfloat, 35*3*length(s))

	for x = 1:35
		@inbounds posData[3*(x-1)+1] = cubeVertices[3*(x-1)+1]
		@inbounds posData[3*(x-1)+2] = cubeVertices[3*(x-1)+2]
		@inbounds posData[3*(x-1)+3] = cubeVertices[3*(x-1)+3]
	end

	glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
	glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

	# if state.drawTexture
	#	# texcoords
	#	texData = zeros(GLfloat, numSlices*4*length(xc))
	#	texData[8:vertexStride:end] = 0
	#	texData[9:vertexStride:end] = 0

	#	texData[17:vertexStride:end] = 1
	#	texData[18:vertexStride:end] = 0

	#	texData[26:vertexStride:end] = 1
	#	texData[27:vertexStride:end] = 1

	#	texData[35:vertexStride:end] = 0
	#	texData[36:vertexStride:end] = 1
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

	colData = []
	if state.fillStuff || state.strokeStuff
		colData = zeros(GLfloat, 35*4*length(s))
	end

	shapeStride = 35
	if state.fillStuff
		loadColors!(colData, state.fillCol, 35*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(s)
			@inbounds glDrawArrays(GL_TRIANGLES, (x-1)*shapeStride, shapeStride)
		end
		# glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		# glDrawElements(GL_TRIANGLES, 6*length(xtopleft), GL_UNSIGNED_INT, C_NULL)
	end
	if state.strokeStuff
		loadColors!(colData, state.strokeCol, 35*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(s)
			glDrawArrays(GL_LINE_LOOP, (x-1)*shapeStride, shapeStride)
		end
	end
end

function sphere(r)
	shapeStride = 35
	if state.fillStuff
		loadColors!(colData, state.fillCol, 35*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(s)
			@inbounds glDrawArrays(GL_TRIANGLES, (x-1)*shapeStride, shapeStride)
		end
		# glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		# glDrawElements(GL_TRIANGLES, 6*length(xtopleft), GL_UNSIGNED_INT, C_NULL)
	end
	# if state.strokeStuff
	#	loadColors!(colData, state.strokeCol, 35*4)
	#	glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
	#	for x = 1:length(x1)
	#		glDrawArrays(GL_LINE_LOOP, (x-1)*shapeStride, shapeStride)
	#	end
	# end
end
