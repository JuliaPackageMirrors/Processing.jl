export arc, ellipse, line, point, quad, rect, triangle
export ellipseMode, rectMode
export strokeWeight, shapeMode
export beginShape, vertex, vertices, endShape

include("shapesaux.jl")

#createShape
#loadShape

## 2D Primitives

function arc(xc, yc, w, h, start, stop)
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

	vertexData = zeros(GLfloat, numSlices*9*length(xc))
	vertexStride = numSlices*9
	for x = 1:length(xc)
		@inbounds cw = [xc[x]; vec(cs[1,x,:]) .* w[x] .+ xc[x]]
		@inbounds ch = [yc[x]; vec(cs[2,x,:]) .* h[x] .+ yc[x]]
		@inbounds vertexData[(x-1)*vertexStride+1:9:x*vertexStride] = cw
		@inbounds vertexData[(x-1)*vertexStride+2:9:x*vertexStride] = ch
		@inbounds vertexData[(x-1)*vertexStride+3:9:x*vertexStride] = eps(Float32)*x
	end

	if state.drawTexture
		# texcoords
		@inbounds vertexData[8:vertexStride:end] = 0
		@inbounds vertexData[9:vertexStride:end] = 0

		@inbounds vertexData[17:vertexStride:end] = 1
		@inbounds vertexData[18:vertexStride:end] = 0

		@inbounds vertexData[26:vertexStride:end] = 1
		@inbounds vertexData[27:vertexStride:end] = 1
	end

	dataStride = numSlices
	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, numSlices*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_TRIANGLE_FAN, (x-1)*dataStride, dataStride)
		end
	end
	if state.strokeStuff
		loadColors!(vertexData, state.strokeCol, 9, numSlices*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_LINE_STRIP, (x-1)*dataStride+1, dataStride-1)
		end
	end
end

function arc(xc, yc, w, h, start, stop, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	arc(xc, yc, w, h, start, stop)
	switchShader("basicShapes")
end

function ellipse(xc, yc, w, h)
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

	vertexData = zeros(GLfloat, numSlices*9*length(xc))
	vertexStride = numSlices*9
	for x = 1:length(xc)
		@inbounds cw = [xc[x]; c .* w[x] .+ xc[x]]
		@inbounds ch = [yc[x]; s .* h[x] .+ yc[x]]
		@inbounds vertexData[(x-1)*vertexStride+1:9:x*vertexStride] = cw
		@inbounds vertexData[(x-1)*vertexStride+2:9:x*vertexStride] = ch
		@inbounds vertexData[(x-1)*vertexStride+3:9:x*vertexStride] = eps(Float32)*x
	end

	if state.drawTexture
		# texcoords
		@inbounds vertexData[8:vertexStride:end] = 0
		@inbounds vertexData[9:vertexStride:end] = 0

		@inbounds vertexData[17:vertexStride:end] = 1
		@inbounds vertexData[18:vertexStride:end] = 0

		@inbounds vertexData[26:vertexStride:end] = 1
		@inbounds vertexData[27:vertexStride:end] = 1
	end

	dataStride = numSlices
	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, numSlices*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_TRIANGLE_FAN, (x-1)*dataStride, dataStride)
		end
	end
	if state.strokeStuff
		loadColors!(vertexData, state.strokeCol, 9, numSlices*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(xc)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*dataStride+1, dataStride-1)
		end
	end
end

function ellipse(xc, yc, w, h, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	ellipse(xc, yc, w, h)
	switchShader("basicShapes")
end

function line(x1, y1, x2, y2)
	if state.strokeStuff
		vertexStride = 9*2
		vertexData = zeros(GLfloat, 9*2*length(x1))
		@inbounds vertexData[1:vertexStride:end] = x1
		@inbounds vertexData[2:vertexStride:end] = y1
		@inbounds vertexData[3:vertexStride:end] = eps(Float32)*(1:length(x1))

		@inbounds vertexData[10:vertexStride:end] = x2
		@inbounds vertexData[11:vertexStride:end] = y2
		@inbounds vertexData[12:vertexStride:end] = eps(Float32)*(1:length(x1))

		if size(state.strokeCol, 1) == 1
			@inbounds vertexData[4:vertexStride:end] = state.strokeCol[1].r
			@inbounds vertexData[5:vertexStride:end] = state.strokeCol[1].g
			@inbounds vertexData[6:vertexStride:end] = state.strokeCol[1].b
			@inbounds vertexData[7:vertexStride:end] = 1.0

			@inbounds vertexData[13:vertexStride:end] = state.strokeCol[1].r
			@inbounds vertexData[14:vertexStride:end] = state.strokeCol[1].g
			@inbounds vertexData[15:vertexStride:end] = state.strokeCol[1].b
			@inbounds vertexData[16:vertexStride:end] = 1.0
		else
			for c = 1:size(state.strokeCol, 1)
				@inbounds vertexData[(c-1)*vertexStride+4:vertexStride:c*vertexStride] = state.strokeCol[c].r
				@inbounds vertexData[(c-1)*vertexStride+5:vertexStride:c*vertexStride] = state.strokeCol[c].g
				@inbounds vertexData[(c-1)*vertexStride+6:vertexStride:c*vertexStride] = state.strokeCol[c].b
				@inbounds vertexData[(c-1)*vertexStride+7:vertexStride:c*vertexStride] = 1.0

				@inbounds vertexData[(c-1)*vertexStride+13:vertexStride:c*vertexStride] = state.strokeCol[c].r
				@inbounds vertexData[(c-1)*vertexStride+14:vertexStride:c*vertexStride] = state.strokeCol[c].g
				@inbounds vertexData[(c-1)*vertexStride+15:vertexStride:c*vertexStride] = state.strokeCol[c].b
				@inbounds vertexData[(c-1)*vertexStride+16:vertexStride:c*vertexStride] = 1.0
			end
		end

		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		glDrawArrays(GL_LINES, 0, 2*length(x1))
	end
end

function line(x, y, tex)
	println("does it make sense to map a texture to a line?")
end

function point(x, y)
	if state.strokeStuff
		vertexStride = 9
		vertexData = zeros(GLfloat, 9*length(x))
		@inbounds vertexData[1:vertexStride:end] = x
		@inbounds vertexData[2:vertexStride:end] = y
		@inbounds vertexData[3:vertexStride:end] = eps(Float32)*(1:length(x))

		loadColors!(vertexData, state.strokeCol, vertexStride, 1)

		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		glDrawArrays(GL_POINTS, 0, length(x))
	end
end

function point(x, y, tex)
	println("does it make sense to map a texture to a point?")
end

function quad(x1, y1, x2, y2, x3, y3, x4, y4)
	vertexStride = 9*4
	vertexData = zeros(GLfloat, 9*4*length(x1))
	# vertices
	@inbounds vertexData[1:vertexStride:end] = x1
	@inbounds vertexData[2:vertexStride:end] = y1
	@inbounds vertexData[3:vertexStride:end] = eps(Float32)*(1:length(x1))

	@inbounds vertexData[10:vertexStride:end] = x2
	@inbounds vertexData[11:vertexStride:end] = y2
	@inbounds vertexData[12:vertexStride:end] = eps(Float32)*(1:length(x1))

	@inbounds vertexData[19:vertexStride:end] = x3
	@inbounds vertexData[20:vertexStride:end] = y3
	@inbounds vertexData[21:vertexStride:end] = eps(Float32)*(1:length(x1))

	@inbounds vertexData[28:vertexStride:end] = x4
	@inbounds vertexData[29:vertexStride:end] = y4
	@inbounds vertexData[30:vertexStride:end] = eps(Float32)*(1:length(x1))

	if state.drawTexture
		# texcoords
		@inbounds vertexData[8:vertexStride:end] = 0
		@inbounds vertexData[9:vertexStride:end] = 0

		@inbounds vertexData[17:vertexStride:end] = 1
		@inbounds vertexData[18:vertexStride:end] = 0

		@inbounds vertexData[26:vertexStride:end] = 1
		@inbounds vertexData[27:vertexStride:end] = 1
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

	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, 4*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		glDrawElements(GL_TRIANGLES, 6*length(x1), GL_UNSIGNED_INT, C_NULL)
	end
	if state.strokeStuff
		loadColors!(vertexData, state.fillCol, 9, 4*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		dataStride = 4
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*dataStride, dataStride)
		end
	end
end

function quad(x1, y1, x2, y2, x3, y3, x4, y4, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	quad(x1, y1, x2, y2, x3, y3, x4, y4)
	switchShader("basicShapes")
end

function rect(xtopleft, ytopleft, width, height)
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

	vertexStride = 4*9
	vertexData = zeros(GLfloat, 9*4*length(xtopleft))
	# vertices
	@inbounds vertexData[1:vertexStride:end] = x1
	@inbounds vertexData[2:vertexStride:end] = y1
	@inbounds vertexData[3:vertexStride:end] = eps(Float32)*(1:length(xtopleft))

	@inbounds vertexData[10:vertexStride:end] = x2
	@inbounds vertexData[11:vertexStride:end] = y2
	@inbounds vertexData[12:vertexStride:end] = eps(Float32)*(1:length(xtopleft))

	@inbounds vertexData[19:vertexStride:end] = x3
	@inbounds vertexData[20:vertexStride:end] = y3
	@inbounds vertexData[21:vertexStride:end] = eps(Float32)*(1:length(xtopleft))

	@inbounds vertexData[28:vertexStride:end] = x4
	@inbounds vertexData[29:vertexStride:end] = y4
	@inbounds vertexData[30:vertexStride:end] = eps(Float32)*(1:length(xtopleft))

	if state.drawTexture
		# texcoords
		@inbounds vertexData[8:vertexStride:end] = 0
		@inbounds vertexData[9:vertexStride:end] = 0

		@inbounds vertexData[17:vertexStride:end] = 1
		@inbounds vertexData[18:vertexStride:end] = 0

		@inbounds vertexData[26:vertexStride:end] = 1
		@inbounds vertexData[27:vertexStride:end] = 1

		@inbounds vertexData[35:vertexStride:end] = 0
		@inbounds vertexData[36:vertexStride:end] = 1
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

	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, 4*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(elements), elements, GL_STATIC_DRAW)
		glDrawElements(GL_TRIANGLES, 6*length(xtopleft), GL_UNSIGNED_INT, C_NULL)
	end
	if state.strokeStuff
		loadColors!(vertexData, state.strokeCol, 9, 4*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		dataStride = 4
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*dataStride, dataStride)
		end
	end
end

function rect(xtopleft, ytopleft, width, height, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	rect(xtopleft, ytopleft, width, height)
	switchShader("basicShapes")
end

function triangle(x1, y1, x2, y2, x3, y3)
	vertexStride = 9*3
	vertexData = zeros(GLfloat, 9*3*length(x1))
	@inbounds vertexData[1:vertexStride:end] = x1
	@inbounds vertexData[2:vertexStride:end] = y1
	@inbounds vertexData[3:vertexStride:end] = eps(Float32)*(1:length(x1))

	@inbounds vertexData[10:vertexStride:end] = x2
	@inbounds vertexData[11:vertexStride:end] = y2
	@inbounds vertexData[12:vertexStride:end] = eps(Float32)*(1:length(x1))

	@inbounds vertexData[19:vertexStride:end] = x3
	@inbounds vertexData[20:vertexStride:end] = y3
	@inbounds vertexData[21:vertexStride:end] = eps(Float32)*(1:length(x1))

	if state.drawTexture
		# texcoords
		@inbounds vertexData[8:vertexStride:end] = 0
		@inbounds vertexData[9:vertexStride:end] = 0

		@inbounds vertexData[17:vertexStride:end] = 1
		@inbounds vertexData[18:vertexStride:end] = 0

		@inbounds vertexData[26:vertexStride:end] = 1
		@inbounds vertexData[27:vertexStride:end] = 1
	end

	dataStride = 3
	if state.fillStuff
		loadColors!(vertexData, state.fillCol, 9, 3*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_TRIANGLES, (x-1)*dataStride, dataStride)
		end
	end
	if state.strokeStuff
		loadColors!(vertexData, state.strokeCol, 9, 3*9)
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW)
		for x = 1:length(x1)
			@inbounds glDrawArrays(GL_LINE_LOOP, (x-1)*dataStride, dataStride)
		end
	end
end

function triangle(x1, y1, x2, y2, x3, y3, tex)
	glActiveTexture(GL_TEXTURE2)
	glBindTexture(GL_TEXTURE_2D, tex)
	switchShader("texturedShapes")
	triangle(x1, y1, x2, y2, x3, y3)
	switchShader("basicShapes")
end

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
		@inbounds vertexData[8:shapeData.vertexStride:end] = 0
		@inbounds vertexData[9:shapeData.vertexStride:end] = 0

		@inbounds vertexData[17:shapeData.vertexStride:end] = 1
		@inbounds vertexData[18:shapeData.vertexStride:end] = 0

		@inbounds vertexData[26:shapeData.vertexStride:end] = 1
		@inbounds vertexData[27:shapeData.vertexStride:end] = 1

		@inbounds vertexData[34:shapeData.vertexStride:end] = 0
		@inbounds vertexData[35:shapeData.vertexStride:end] = 1
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
