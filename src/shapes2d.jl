export arc, ellipse, line, point, quad, rect, triangle
export ellipseMode, rectMode
export strokeWeight, shapeMode
export beginShape, vertex, vertices, endShape

include("shapesaux.jl")

#createShape
#loadShape

## 2D Primitives

function arc(xc, yc, zc, w, h, start, stop)
	if state.ellipseMode == "CENTER"
		w = w ./ 2
		h = h ./ 2
	elseif state.ellipseMode == "CORNER"
		w = w ./ 2
		h = h ./ 2
		xc = xc .+ w
		yc = yc .+ h
	elseif state.ellipseMode == "CORNERS"
		xc = (w .- xc)./2
		yc = (h .- yc)./2
		w = w ./ 2
		h = h ./ 2
	end

	numSlices = 200+1
	cs = Array{Float64}(2, length(xc), numSlices-1)
	for x = 1:length(xc)
		@inbounds cs[1,x,:] = cos(linspace(start[x], stop[x], numSlices-1))
		@inbounds cs[2,x,:] = sin(linspace(start[x], stop[x], numSlices-1))
	end

	posStride = numSlices*3
	posData = zeros(GLfloat, numSlices*3*length(xc))
	for x = 1:length(xc)
		@inbounds cw = [xc[x]; vec(cs[1,x,:]) .* w[x] .+ xc[x]]
		@inbounds ch = [yc[x]; vec(cs[2,x,:]) .* h[x] .+ yc[x]]
		@inbounds posData[(x-1)*posStride+1:3:x*posStride] = cw
		@inbounds posData[(x-1)*posStride+2:3:x*posStride] = ch
		if zc == 0
			@inbounds posData[(x-1)*posStride+3:3:x*posStride] = eps(Float32)*x
		else
			@inbounds posData[(x-1)*posStride+3:3:x*posStride] = zc
		end
	end

	glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
	glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

	# textures aren't properly implemented for arcs yet.
	# if state.drawTexture
	#	# texcoords
	#	texData = zeros(GLfloat, numSlices*4*length(xc))
	#	@inbounds texData[8:texStride:end] = 0
	#	@inbounds texData[9:texStride:end] = 0

	#	@inbounds texData[17:texStride:end] = 1
	#	@inbounds texData[18:texStride:end] = 0

	#	@inbounds texData[26:texStride:end] = 1
	#	@inbounds texData[27:texStride:end] = 1

	# glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
    # glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
	# end

	colData = []
	if state.fillStuff || state.strokeStuff
		colData = zeros(GLfloat, numSlices*4*length(xc))
	end

	shapeStride = numSlices
	if state.fillStuff
		loadColors!(colData, state.fillCol, numSlices*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		# textures aren't properly implemented for arcs yet.
		# does it even make senes to do so? it could produce funky
		# results that might be useful.
		# glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_TRIANGLE_FAN, (x-1)*shapeStride, shapeStride)
		end
	end
	if state.strokeStuff
		loadColors!(colData, state.strokeCol, numSlices*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_LINES, (x-1)*shapeStride+1, shapeStride-1)
		end
	end
end

function arc(xc, yc, zc, w, h, start, stop, tex::GLuint)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	arc(xc, yc, zc, w, h, start, stop)
	switchShader("basicShapes")
end

arc(xc, yc, w, h, start, stop, tex::GLuint) = arc(xc, yc, 0, w, h, start, stop, tex::GLuint)
arc(xc, yc, w, h, start, stop) = arc(xc, yc, 0, w, h, start, stop)

function ellipse(xc, yc, zc, w, h)
	if state.ellipseMode == "CENTER"
		w = w ./ 2
		h = h ./ 2
	elseif state.ellipseMode == "CORNER"
		w = w ./ 2
		h = h ./ 2
		xc = xc .+ w
		yc = yc .+ h
	elseif state.ellipseMode == "CORNERS"
		xc = (w .- xc)./2
		yc = (h .- yc)./2
		w = w ./ 2
		h = h ./ 2
	end

	numSlices = 200+1
	c = cos(linspace(0, 2pi, numSlices-1))
	s = sin(linspace(0, 2pi, numSlices-1))

	posStride = numSlices*3
	posData = zeros(GLfloat, numSlices*3*length(xc))
	for x = 1:length(xc)
		@inbounds cw = [xc[x]; c .* w[x] .+ xc[x]]
		@inbounds ch = [yc[x]; s .* h[x] .+ yc[x]]
		@inbounds posData[(x-1)*posStride+1:3:x*posStride] = cw
		@inbounds posData[(x-1)*posStride+2:3:x*posStride] = ch
		if zc == 0
			@inbounds posData[(x-1)*posStride+3:3:x*posStride] = eps(Float32)*x
		else
			@inbounds posData[(x-1)*posStride+3:3:x*posStride] = zc
		end
	end

	glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
	glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

	# if state.drawTexture
	#	# texcoords
	#	texData = zeros(GLfloat, numSlices*4*length(xc))
	#	@inbounds texData[8:vertexStride:end] = 0
	#	@inbounds texData[9:vertexStride:end] = 0

	#	@inbounds texData[17:vertexStride:end] = 1
	#	@inbounds texData[18:vertexStride:end] = 0

	#	@inbounds texData[26:vertexStride:end] = 1
	#	@inbounds texData[27:vertexStride:end] = 1

	# glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
	# glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
	# end

	colData = []
	if state.fillStuff || state.strokeStuff
		colData = zeros(GLfloat, numSlices*4*length(xc))
	end

	shapeStride = numSlices
	if state.fillStuff
		loadColors!(colData, state.fillCol, numSlices*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_TRIANGLE_FAN, (x-1)*shapeStride, shapeStride)
		end
	end
	if state.strokeStuff
		loadColors!(colData, state.strokeCol, numSlices*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*shapeStride+1, shapeStride-1)
		end
	end
end

function ellipse(xc, yc, zc, w, h, tex::GLuint)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	ellipse(xc, yc, zc, w, h)
	switchShader("basicShapes")
end

ellipse(xc, yc, w, h, tex::GLuint) = ellipse(xc, yc, 0, w, h, tex::GLuint)
ellipse(xc, yc, w, h) = ellipse(xc, yc, 0, w, h)

function line(x1, y1, z1, x2, y2, z2)
	if state.strokeStuff
		posData = zeros(GLfloat, 2*3*length(x1))
		@inbounds posData[1:6:end] = x1
		@inbounds posData[2:6:end] = y1

		@inbounds posData[4:6:end] = x2
		@inbounds posData[5:6:end] = y2

		if z1 == 0 && z2 == 0
			@inbounds posData[3:6:end] = eps(Float32)*(1:length(x1))
			@inbounds posData[6:6:end] = eps(Float32)*(1:length(x1))
		else
			@inbounds posData[3:6:end] = z1
			@inbounds posData[6:6:end] = z2
		end

		glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

		shapeStride = 2*4
		colData = zeros(GLfloat, 2*4*length(x1))
		if size(state.strokeCol, 1) == 1
			@inbounds colData[1:8:end] = state.strokeCol[1].r
			@inbounds colData[2:8:end] = state.strokeCol[1].g
			@inbounds colData[3:8:end] = state.strokeCol[1].b
			@inbounds colData[4:8:end] = 1.0

			@inbounds colData[5:8:end] = state.strokeCol[1].r
			@inbounds colData[6:8:end] = state.strokeCol[1].g
			@inbounds colData[7:8:end] = state.strokeCol[1].b
			@inbounds colData[8:8:end] = 1.0
		else
			for c = 1:size(state.strokeCol, 1)
				@inbounds colData[(c-1)*shapeStride+1:shapeStride:c*shapeStride] = state.strokeCol[c].r
				@inbounds colData[(c-1)*shapeStride+2:shapeStride:c*shapeStride] = state.strokeCol[c].g
				@inbounds colData[(c-1)*shapeStride+3:shapeStride:c*shapeStride] = state.strokeCol[c].b
				@inbounds colData[(c-1)*shapeStride+4:shapeStride:c*shapeStride] = 1.0

				@inbounds colData[(c-1)*shapeStride+5:shapeStride:c*shapeStride] = state.strokeCol[c].r
				@inbounds colData[(c-1)*shapeStride+6:shapeStride:c*shapeStride] = state.strokeCol[c].g
				@inbounds colData[(c-1)*shapeStride+7:shapeStride:c*shapeStride] = state.strokeCol[c].b
				@inbounds colData[(c-1)*shapeStride+8:shapeStride:c*shapeStride] = 1.0
			end
		end

		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		glDrawArrays(GL_LINES, 0, 2*length(x1))
	end
end

function line(x1, y1, z1, x2, y2, z2, tex::GLuint)
	println("does it make sense to map a texture to a line?")
end

line(x1, y1, x2, y2, tex::GLuint) = line(x1, y1, 0, x2, y2, 0, tex::GLuint)
line(x1, y1, x2, y2) = line(x1, y1, 0, x2, y2, 0)

function point(x, y, z)
	if state.strokeStuff
		posData = zeros(GLfloat, 3*length(x))
		@inbounds posData[1:3:end] = x
		@inbounds posData[2:3:end] = y
		if z == 0
			@inbounds posData[3:3:end] = eps(Float32)*(1:length(x))
		else
			@inbounds posData[3:3:end] = z
		end


		glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

		colData = zeros(GLfloat, 4*length(x))
		loadColors!(colData, state.strokeCol, 1)

		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		glDrawArrays(GL_POINTS, 0, length(x))
	end
end

function point(x, y, tex::GLuint)
	println("does it make sense to map a texture to a point?")
end

point(x, y, tex::GLuint) = point(x, y, 0, tex::GLuint)
point(x, y) = point(x, y, 0)

function quad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
	posStride = 4*3
	posData = zeros(GLfloat, 4*3*length(x1))
	# vertices
	@inbounds posData[1:posStride:end] = x1
	@inbounds posData[2:posStride:end] = y1

	@inbounds posData[4:posStride:end] = x2
	@inbounds posData[5:posStride:end] = y2

	@inbounds posData[7:posStride:end] = x3
	@inbounds posData[8:posStride:end] = y3

	@inbounds posData[10:posStride:end] = x4
	@inbounds posData[11:posStride:end] = y4

	if z1 == 0 && z2 == 0 && z3 == 0 && z4 == 0
		@inbounds posData[3:posStride:end] = eps(Float32)*(1:length(x1))
		@inbounds posData[6:posStride:end] = eps(Float32)*(1:length(x1))
		@inbounds posData[9:posStride:end] = eps(Float32)*(1:length(x1))
		@inbounds posData[12:posStride:end] = eps(Float32)*(1:length(x1))
	else
		@inbounds posData[3:posStride:end] = z1
		@inbounds posData[6:posStride:end] = z2
		@inbounds posData[9:posStride:end] = z3
		@inbounds posData[12:posStride:end] = z4
	end

	glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
	glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

	if state.drawTexture
		# texcoords
		# texData = zeros(GLfloat, numSlices*4*length(xc))
		# @inbounds texData[8:vertexStride:end] = 0
		# @inbounds texData[9:vertexStride:end] = 0

		# @inbounds texData[17:vertexStride:end] = 1
		# @inbounds texData[18:vertexStride:end] = 0

		# @inbounds texData[26:vertexStride:end] = 1
		# @inbounds texData[27:vertexStride:end] = 1

		# glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
		# glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
	end

	elements = zeros(GLuint, 6*length(x1))

	@inbounds elements[1] = 0
	@inbounds elements[2] = 1
	@inbounds elements[3] = 2
	@inbounds elements[4] = 2
	@inbounds elements[5] = 3
	@inbounds elements[6] = 0

	index = 7
	for x = 2:length(x1)
		@inbounds elements[index] = elements[index-6] + 4
		@inbounds elements[index+1] = elements[(index-6)+1] + 4
		@inbounds elements[index+2] = elements[(index-6)+2] + 4
		@inbounds elements[index+3] = elements[(index-6)+3] + 4
		@inbounds elements[index+4] = elements[(index-6)+4] + 4
		@inbounds elements[index+5] = elements[(index-6)+5] + 4
		index += 6
	end

	colData = []
	if state.fillStuff || state.strokeStuff
		colData = zeros(GLfloat, 4*4*length(x1))
	end

	if state.fillStuff
		loadColors!(colData, state.fillCol, 4*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		glDrawElements(GL_TRIANGLES, 6*length(x1), GL_UNSIGNED_INT, C_NULL)
	end
	if state.strokeStuff
		loadColors!(colData, state.strokeCol, 4*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		shapeStride = 4
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*shapeStride, shapeStride)
		end
	end
end

function quad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, tex::GLuint)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	quad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
	switchShader("basicShapes")
end

quad(x1, y1, x2, y2, x3, y3, x4, y4, tex::GLuint) = quad(x1, y1, 0, x2, y2, 0, x3, y3, 0, x4, y4, 0, tex::GLuint)
quad(x1, y1, x2, y2, x3, y3, x4, y4) = quad(x1, y1, 0, x2, y2, 0, x3, y3, 0, x4, y4, 0)

function rect(xtopleft, ytopleft, ztopleft, width, height)
	if state.rectMode == "CENTER"
		@inbounds xtopleft = xtopleft .- width./2
		@inbounds ytopleft = ytopleft .- height./2
	elseif state.rectMode == "RADIUS"
		@inbounds xtopleft = xtopleft .- width
		@inbounds ytopleft = ytopleft .- height
		@inbounds width = 2 .* width
		@inbounds height = 2 .* height
	elseif state.rectMode == "CORNERS"
		@inbounds width = width .- xtopleft
		@inbounds height = height .- ytopleft
	end

	@inbounds x1 = xtopleft
	@inbounds y1 = ytopleft
	@inbounds x2 = xtopleft .+ width
	@inbounds y2 = ytopleft
	@inbounds x3 = xtopleft .+ width
	@inbounds y3 = ytopleft .- height
	@inbounds x4 = xtopleft
	@inbounds y4 = ytopleft .- height

	posStride = 4*3
	posData = zeros(GLfloat, 4*3*length(xtopleft))
	# vertices
	@inbounds posData[1:posStride:end] = x1
	@inbounds posData[2:posStride:end] = y1

	@inbounds posData[4:posStride:end] = x2
	@inbounds posData[5:posStride:end] = y2

	@inbounds posData[7:posStride:end] = x3
	@inbounds posData[8:posStride:end] = y3

	@inbounds posData[10:posStride:end] = x4
	@inbounds posData[11:posStride:end] = y4

	if ztopleft == 0
		@inbounds posData[3:posStride:end] = eps(Float32)*(1:length(xtopleft))
		@inbounds posData[6:posStride:end] = eps(Float32)*(1:length(xtopleft))
		@inbounds posData[9:posStride:end] = eps(Float32)*(1:length(xtopleft))
		@inbounds posData[12:posStride:end] = eps(Float32)*(1:length(xtopleft))
	else
		@inbounds posData[3:posStride:end] = ztopleft
		@inbounds posData[6:posStride:end] = ztopleft
		@inbounds posData[9:posStride:end] = ztopleft
		@inbounds posData[12:posStride:end] = ztopleft
	end

	glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
	glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

	if state.drawTexture
		# texcoords
		texStride = 4*2
		texData = zeros(GLfloat, 4*2*length(xtopleft))
		@inbounds texData[1:texStride:end] = 0
		@inbounds texData[2:texStride:end] = 0

		@inbounds texData[3:texStride:end] = 1
		@inbounds texData[4:texStride:end] = 0

		@inbounds texData[5:texStride:end] = 1
		@inbounds texData[6:texStride:end] = 1

		@inbounds texData[7:texStride:end] = 0
		@inbounds texData[8:texStride:end] = 1

		glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
	end

	elements = zeros(GLuint, 6*length(xtopleft))

	@inbounds elements[1] = 0
	@inbounds elements[2] = 1
	@inbounds elements[3] = 2
	@inbounds elements[4] = 2
	@inbounds elements[5] = 3
	@inbounds elements[6] = 0

	index = 7
	for x = 2:length(x1)
		@inbounds elements[index] = elements[index-6] + 4
		@inbounds elements[index+1] = elements[(index-6)+1] + 4
		@inbounds elements[index+2] = elements[(index-6)+2] + 4
		@inbounds elements[index+3] = elements[(index-6)+3] + 4
		@inbounds elements[index+4] = elements[(index-6)+4] + 4
		@inbounds elements[index+5] = elements[(index-6)+5] + 4
		index += 6
	end

	colData = []
	if state.fillStuff || state.strokeStuff
		colData = zeros(GLfloat, 4*4*length(xtopleft))
	end

	if state.fillStuff
		loadColors!(colData, state.fillCol, 4*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		glDrawElements(GL_TRIANGLES, 6*length(xtopleft), GL_UNSIGNED_INT, C_NULL)
	end
	if state.strokeStuff
		loadColors!(colData, state.strokeCol, 4*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		shapeStride = 4
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*shapeStride, shapeStride)
		end
	end
end

function rect(xtopleft, ytopleft, ztopleft, width, height, tex::GLuint)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	rect(xtopleft, ytopleft, ztopleft, width, height)
	switchShader("basicShapes")
end

rect(xtopleft, ytopleft, width, height, tex::GLuint) = rect(xtopleft, ytopleft, 0, width, height, tex::GLuint)
rect(xtopleft, ytopleft, width, height) = rect(xtopleft, ytopleft, 0, width, height)

function triangle(x1, y1, z1, x2, y2, z2, x3, y3, z3)
	posStride = 3*3
	posData = zeros(GLfloat, 3*3*length(x1))
	@inbounds posData[1:posStride:end] = x1
	@inbounds posData[2:posStride:end] = y1

	@inbounds posData[4:posStride:end] = x2
	@inbounds posData[5:posStride:end] = y2

	@inbounds posData[7:posStride:end] = x3
	@inbounds posData[8:posStride:end] = y3

	if z1 == 0 && z2 == 0 && z3 == 0
		@inbounds posData[3:posStride:end] = eps(Float32)*(1:length(x1))
		@inbounds posData[6:posStride:end] = eps(Float32)*(1:length(x1))
		@inbounds posData[9:posStride:end] = eps(Float32)*(1:length(x1))
	else
		@inbounds posData[3:posStride:end] = z1
		@inbounds posData[6:posStride:end] = z2
		@inbounds posData[9:posStride:end] = z3
	end

	glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
	glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)

	if state.drawTexture
		# texcoords
		# texData = zeros(GLfloat, numSlices*4*length(xc))
		# @inbounds texData[8:vertexStride:end] = 0
		# @inbounds texData[9:vertexStride:end] = 0

		# @inbounds texData[17:vertexStride:end] = 1
		# @inbounds texData[18:vertexStride:end] = 0

		# @inbounds texData[26:vertexStride:end] = 1
		# @inbounds texData[27:vertexStride:end] = 1
		#
		# glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
    # glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
	end

	colData = []
	if state.fillStuff || state.strokeStuff
		colData = zeros(GLfloat, 4*3*length(x1))
	end

	shapeStride = 3
	if state.fillStuff
		loadColors!(colData, state.fillCol, 3*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_TRIANGLES, (x-1)*shapeStride, shapeStride)
		end
	end
	if state.strokeStuff
		loadColors!(colData, state.strokeCol, 3*4)
		glBindBuffer(GL_ARRAY_BUFFER, globjs.colvbos[globjs.colind])
		glBufferData(GL_ARRAY_BUFFER, sizeof(colData), colData, GL_STATIC_DRAW)
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*shapeStride, shapeStride)
		end
	end
end

function triangle(x1, y1, z1, x2, y2, z2, x3, y3, z3, tex::GLuint)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	triangle(x1, y1, z1, x2, y2, z2, x3, y3, z3)
	switchShader("basicShapes")
end

triangle(x1, y1, x2, y2, x3, y3, tex::GLuint) = triangle(x1, y1, 0, x2, y2, 0, x3, y3, 0, tex::GLuint)
triangle(x1, y1, x2, y2, x3, y3) = triangle(x1, y1, 0, x2, y2, 0, x3, y3, 0)

## Curves

# function bezier(x1, y1, x2, y2, x3, y3, x4, y4)
#
# end

#Double quadratic Bezier curve (from Colors.jl)
function Bezier{T<:Real}(t::T, p0::T, p2::T, q0::T, q1::T, q2::T)
	B(t,a,b,c)=a*(1.0-t)^2.0+2.0b*(1.0-t)*t+c*t^2.0
	if t <= 0.5
		return B(2.0t, p0, q0, q1)
    else #t > 0.5
	return B(2.0(t-0.5), q1, q2, p2)
    end
end

#bezierDetail
#bezierPoint
#bezierTangent
#curve
#curveDetail
#curvePoint
#curveTangent
#curveTightness

## Attributes

function ellipseMode(eMode)
	state.ellipseMode = eMode
end

function rectMode(rMode)
	state.rectMode = rMode
end

# function strokeCap(capType)
#
# end

# function strokeJoin(joinType)
#
# end

function strokeWeight(newWeight)
	glPointSize(newWeight)
	state.strokeWeight = newWeight
end

## Vertex

function beginShape(sType)
	if sType == "POINTS"
		shapeData.shapeType = GL_POINTS
	elseif sType == "LINES"
		shapeData.shapeType = GL_LINES
	elseif sType == "TRIANGLES"
		shapeData.shapeType = GL_TRIANGLES
	elseif sType == "TRIANGLE_FAN"
		shapeData.shapeType = GL_TRIANGLE_FAN
	elseif sType == "TRIANGLE_STRIP"
		shapeData.shapeType = GL_TRIANGLE_STRIP
	elseif sType == "QUADS"
		shapeData.shapeType = GL_QUADS
	elseif sType == "QUAD_STRIP"
		shapeData.shapeType = GL_QUAD_STRIP
	end
	shapeData.shapeVertices = zeros(GLfloat, 9)
end

function vertex(v)
	vertexStride = 9
	if size(shapeData.shapeVertices) > 9
		push!(shapeData.shapeVertices, v[1])
		push!(shapeData.shapeVertices, v[2])
	else
		shapeData.shapeVertices[1] = v[1]
		shapeData.shapeVertices[2] = v[2]
	end
end

function vertices(vs)
	shapeData.nVertices = size(vs, 2)
	shapeData.vertexStride = 9
	shapeData.shapeVertices = zeros(GLfloat, 9*size(vs, 2))
	@inbounds shapeData.shapeVertices[1:shapeData.vertexStride:end] = vs[1, :]
	@inbounds shapeData.shapeVertices[2:shapeData.vertexStride:end] = vs[2, :]
end

function vertices(vs, ts)
	shapeData.nVertices = size(vs, 2)
	shapeData.vertexStride = 9
	shapeData.shapeVertices = zeros(GLfloat, 9*size(vs, 2))
	@inbounds shapeData.shapeVertices[1:shapeData.vertexStride:end] = vs[1, :]
	@inbounds shapeData.shapeVertices[2:shapeData.vertexStride:end] = vs[2, :]

	if state.drawTexture
		# texcoords
		# texData = zeros(GLfloat, numSlices*4*length(xc))
		# @inbounds texData[8:shapeData.vertexStride:end] = 0
		# @inbounds texData[9:shapeData.vertexStride:end] = 0

		# @inbounds texData[17:shapeData.vertexStride:end] = 1
		# @inbounds texData[18:shapeData.vertexStride:end] = 0

		# @inbounds texData[26:shapeData.vertexStride:end] = 1
		# @inbounds texData[27:shapeData.vertexStride:end] = 1

		# @inbounds texData[34:shapeData.vertexStride:end] = 0
		# @inbounds texData[35:shapeData.vertexStride:end] = 1
	end
end

function endShape()
	if state.fillStuff && (shapeData.shapeType != GL_POINTS || shapeData.shapeType != GL_LINES || shapeData.shapeType != GL_LINE_LOOP || shapeData.shapeType != GL_LINE_STRIP)
		loadColors!(vertexData, state.fillCol, vertexStride)
		glBufferData(GL_ARRAY_BUFFER, sizeof(shapeData.shapeVertices), shapeData.shapeVertices, GL_STATIC_DRAW)
		glDrawArrays(shapeData.shapeType, 0, shapeData.nVertices)
	end

	if state.strokeStuff
		loadColors!(vertexData, state.strokeCol, vertexStride)
		if (shapeData.shapeType == GL_POINTS || shapeData.shapeType == GL_LINES || shapeData.shapeType == GL_LINE_STRIP)
			glDrawArrays(shapeData.shapeType, 0, shapeData.nVertices)
		else
			glDrawArrays(GL_LINE_LOOP, 0, shapeData.nVertices)
		end
	end
end

#bezierVertex
#curveVertex

#quadraticVertex

## Loading & Displaying

#shape

function shapeMode(mode)
	state.shapeMode = mode
end
