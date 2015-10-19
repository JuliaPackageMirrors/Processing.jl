export applyMatrix, popMatrix, pushMatrix, resetMatrix
export rotate, Scale, shearX, shearY, translate

function applyMatrix(n00, n01, n02, n03, n10, n11, n12, n13, n20, n21, n22, n23, n30, n31, n32, n33)
	m = GLfloat[n00 n01 n02 n03;
		n10 n11 n12 n13;
		n20 n21 n22 n23;
		n30 n31 n32 n33]

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function popMatrix()
	GLmatState.currMatrix = pop!(GLmatState.matrixStack)

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function pushMatrix()
	push!(GLmatState.matrixStack, GLmatState.currMatrix)
end

function resetMatrix()
	GLmatState.currMatrix = GLfloat[1 0 0 0;
		0 1 0 0;
		0 0 1 0;
		0 0 0 1]

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function rotate(angle, x, y, z)
	m = GLfloat[cos(angle) -sin(angle) 0 0;
		sin(angle) cos(angle) 0 0;
		0 0 1 0;
		0 0 0 1]

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function rotateX(angle)
	m = rotationmatrix_x(angle)
	m = map(Float32, convert(Array, m)) # GLfloat = float32

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function rotateY(angle)
	m = rotationmatrix_y(angle)
	m = map(Float32, convert(Array, m)) # GLfloat = float32

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function rotateZ(angle)
	m = rotationmatrix_z(angle)
	m = map(Float32, convert(Array, m)) # GLfloat = float32

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function Scale(x, y, z)
	m = GLfloat[x 0 0 0;
				0 y 0 0;
				0 0 z 0;
				0 0 0 1]

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function shearX(angle)
	m = [1 tan(angle) 0 0;
		0 1 0 0;
		0 0 1 0;
		0 0 0 1]

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function shearY(angle)
	m = [1 0 0 0;
		tan(angle) 1 0 0;
		0 0 1 0;
		0 0 0 1]

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function translate(x, y, z)
	m = GLfloat[1 0 0 x;
				0 1 0 y;
				0 0 1 z;
				0 0 0 1]

	GLmatState.currMatrix = m * GLmatState.currMatrix

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["basicShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
end

function printMatrix()
	print(GLmatState.currMatrix)
end
