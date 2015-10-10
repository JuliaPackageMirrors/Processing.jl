function initShaders()
	# basicShapes
	const vshBS = """
	$(get_glsl_version_string())

	in vec3 position;
	in vec4 color;

	out vec4 vColor;

	uniform mat4 MVP;

	void main() {
		vColor = color;
		gl_Position = MVP * vec4(position, 1.0);
	}
	"""

	# const gshBS = """
	# $(get_glsl_version_string())

	# #extension GL_EXT_gpu_shader4 : enable
	# #extension GL_EXT_geometry_shader4 : enable

	# varying in vec3 vertWorldPos[3];
	# varying in vec3 vertWorldNormal[3];
	# varying in vec4 vColor[4];

	# varying out vec3 worldNormal;
	# varying out vec3 worldPos;
	# varying out vec4 OUTColor;

	# uniform vec2 WIN_SCALE;

	# noperspective varying vec3 dist;

	# void main(void)
	# {
	#	vec2 p0 = WIN_SCALE * gl_PositionIn[0].xy/gl_PositionIn[0].w;
	#	vec2 p1 = WIN_SCALE * gl_PositionIn[1].xy/gl_PositionIn[1].w;
	#	vec2 p2 = WIN_SCALE * gl_PositionIn[2].xy/gl_PositionIn[2].w;

	#	vec2 v0 = p2-p1;
	#	vec2 v1 = p2-p0;
	#	vec2 v2 = p1-p0;

	#	float area = abs(v1.x*v2.y - v1.y * v2.x);

	#	dist = vec3(area/length(v0),0,0);
	#	worldPos = vertWorldPos[0];
	#	worldNormal = vertWorldNormal[0];
	#	gl_Position = gl_PositionIn[0];
	#	EmitVertex();

	#	dist = vec3(0,area/length(v1),0);
	#	worldPos = vertWorldPos[1];
	#	worldNormal = vertWorldNormal[1];
	#	gl_Position = gl_PositionIn[1];
	#	EmitVertex();

	#	dist = vec3(0,0,area/length(v2));
	#	worldPos = vertWorldPos[2];
	#	worldNormal = vertWorldNormal[2];
	#	gl_Position = gl_PositionIn[2];
	#	EmitVertex();

	#	EndPrimitive();
	# }
	# """

	const fshBS = """
	$(get_glsl_version_string())

	in vec4 vColor;

	out vec4 outColor;

	void main() {
		outColor = vColor;
	}
	"""

	# texturedShapes
	const vshTS = """
	$(get_glsl_version_string())

	in vec3 position;
	in vec4 color;
	in vec2 texcoord;

	out vec4 vColor;
	out vec2 Texcoord;

	uniform mat4 MVP;

	void main() {
		vColor = color;
		Texcoord = texcoord;
		gl_Position = MVP * vec4(position, 1.0);
	}
	"""

	const fshTS = """
	$(get_glsl_version_string())

	in vec4 vColor;
	in vec2 Texcoord;

	out vec4 outColor;

	uniform sampler2D tex;

	void main() {
		outColor = texture(tex, Texcoord) * vColor;
	}
	"""

	# fontDrawing
	const vshFD = """
	$(get_glsl_version_string())

	in vec4 position;
	in vec4 texcoord;

	out vec2 TexCoord;

	uniform mat4 proj;

	void main()
	{
		gl_Position = proj * position;
		TexCoord = texcoord.xy;
	}
	"""

	const fshFD = """
	$(get_glsl_version_string())

	in vec2 TexCoord;

	out vec4 color;

	uniform sampler2D text;
	uniform vec3 textColor;

	void main()
	{
		vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, TexCoord).r);
		color = vec4(textColor, 1.0) * sampled;
	}
	"""

	# framebuffer
	const vshDFB = """
	$(get_glsl_version_string())

	in vec2 position;
	in vec2 texcoord;

	out vec2 Texcoord;

	void main() {
		Texcoord = texcoord;
		gl_Position = vec4(position, 0.0, 1.0);
	}
	"""

	const fshDFB = """
	$(get_glsl_version_string())

	in vec2 Texcoord;

	out vec4 outColor;

	uniform sampler2D texFramebuffer;

	void main() {
		outColor = texture(texFramebuffer, Texcoord);
	}
	"""

	push!(globjs.vaos, glGenVertexArray()) # basic shape
	glBindVertexArray(globjs.vaos[1])
    push!(globjs.vbos, glGenBuffer()) # basic shape
    glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[1])
    push!(globjs.ebos,  glGenBuffer()) # basic shape
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, globjs.ebos[1])

    vertexShader = createShader(vshBS, GL_VERTEX_SHADER)
    fragmentShader = createShader(fshBS, GL_FRAGMENT_SHADER)
    state.program = createShaderProgram(vertexShader, fragmentShader)
    shaderBank["basicShapes"] = state.program
    glUseProgram(shaderBank["basicShapes"])

    positionAttribute = glGetAttribLocation(state.program, "position")
    glEnableVertexAttribArray(positionAttribute)
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, false, 9*sizeof(GLfloat), 0)

    colorAttribute = glGetAttribLocation(state.program, "color")
    glEnableVertexAttribArray(colorAttribute)
    glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 3*sizeof(GLfloat))

	glUniformMatrix4fv(glGetUniformLocation(state.program, "MVP"), 1, false, GLmatState.currMatrix)

	push!(globjs.vaos, glGenVertexArray()) # textured shapes
	glBindVertexArray(globjs.vaos[2])
    push!(globjs.vbos, glGenBuffer()) # textured shapes
    glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[2])
    push!(globjs.ebos,  glGenBuffer()) # textured shapes
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, globjs.ebos[2])

	vertexShader = createShader(vshTS, GL_VERTEX_SHADER)
	fragmentShader = createShader(fshTS, GL_FRAGMENT_SHADER)
	shaderBank["texturedShapes"] = createShaderProgram(vertexShader, fragmentShader)
	glUseProgram(shaderBank["texturedShapes"])

	positionAttribute = glGetAttribLocation(shaderBank["texturedShapes"], "position")
	glEnableVertexAttribArray(positionAttribute)
	glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, false, 9*sizeof(GLfloat), 0)

	colorAttribute = glGetAttribLocation(shaderBank["texturedShapes"], "color")
	glEnableVertexAttribArray(colorAttribute)
	glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 3*sizeof(GLfloat))

	texAttrib = glGetAttribLocation(shaderBank["texturedShapes"], "texcoord")
	glEnableVertexAttribArray(texAttrib)
	glVertexAttribPointer(texAttrib, 2, GL_FLOAT, false, 9*sizeof(GLfloat), 7*sizeof(GLfloat))

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["texturedShapes"], "MVP"), 1, false, GLmatState.currMatrix)
	glUniform1i(glGetUniformLocation(shaderBank["texturedShapes"], "tex"), 2)

	push!(globjs.vaos, glGenVertexArray()) # font drawing
	glBindVertexArray(globjs.vaos[3])
	push!(globjs.vbos, glGenBuffer()) # font drawing
	glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[3])

	vertexShader = createShader(vshFD, GL_VERTEX_SHADER)
	fragmentShader = createShader(fshFD, GL_FRAGMENT_SHADER)
	shaderBank["fontDrawing"] = createShaderProgram(vertexShader, fragmentShader)
	glUseProgram(shaderBank["fontDrawing"])

	positionAttribute = glGetAttribLocation(shaderBank["fontDrawing"], "position")
	glEnableVertexAttribArray(positionAttribute)
	glVertexAttribPointer(positionAttribute, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 0)

	texAttrib = glGetAttribLocation(shaderBank["fontDrawing"], "texcoord")
	glEnableVertexAttribArray(texAttrib)
	glVertexAttribPointer(texAttrib, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 4*sizeof(GLfloat))

	glUniform3f(glGetUniformLocation(shaderBank["fontDrawing"], "textColor"), GLfloat(state.fillCol[1].r), GLfloat(state.fillCol[1].g), GLfloat(state.fillCol[1].b))

	# by default, we always use texture 1 for fonts
	glUniform1i(glGetUniformLocation(shaderBank["fontDrawing"], "text"), 1)

	# text is rendered with an orthographic projection
	projection = GLfloat[2/state.width 0 0 -1;
						0 2/state.height 0 -1;
						0 0 -1 0;
						0 0 0 1]

	glUniformMatrix4fv(glGetUniformLocation(shaderBank["fontDrawing"], "proj"), 1, false, projection)

	push!(globjs.vaos, glGenVertexArray()) # quad with framebuffer texture
	glBindVertexArray(globjs.vaos[4])
	push!(globjs.vbos, glGenBuffer()) # quad with framebuffer texture
	glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[4])

	vertexShader = createShader(vshDFB, GL_VERTEX_SHADER)
	fragmentShader = createShader(fshDFB, GL_FRAGMENT_SHADER)
	shaderBank["drawFramebuffer"] = createShaderProgram(vertexShader, fragmentShader)
	glUseProgram(shaderBank["drawFramebuffer"])

	positionAttribute = glGetAttribLocation(shaderBank["drawFramebuffer"], "position")
	glEnableVertexAttribArray(positionAttribute)
	glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, false, 4*sizeof(GLfloat), 0)

	texAttrib = glGetAttribLocation(shaderBank["drawFramebuffer"], "texcoord")
	glEnableVertexAttribArray(texAttrib)
	glVertexAttribPointer(texAttrib, 2, GL_FLOAT, false, 4*sizeof(GLfloat), 2*sizeof(GLfloat))

	glUniform1i(glGetUniformLocation(shaderBank["drawFramebuffer"], "texFramebuffer"), 0)

	# fill the quad data on the gpu for later when we render the
	# framebuffer texture to the screen.
	# this only needs to be done once.
	glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW)
end

function switchShader(whichShader)
	if whichShader == "basicShapes"
		glBindVertexArray(globjs.vaos[1])
		glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[1])
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, globjs.ebos[1])
	elseif whichShader == "texturedShapes"
		glBindVertexArray(globjs.vaos[2])
		glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[2])
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, globjs.ebos[2])
	elseif whichShader == "fontDrawing"
		glBindVertexArray(globjs.vaos[3])
		glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[3])
	elseif whichShader == "drawFramebuffer"
		glBindVertexArray(globjs.vaos[4])
		glBindBuffer(GL_ARRAY_BUFFER, globjs.vbos[4])
	end

	state.program = shaderBank[whichShader]
	glUseProgram(shaderBank[whichShader])

	if whichShader == "texturedShapes"
		state.drawTexture = true
	elseif whichShader == "basicShapes"
		state.drawTexture = false
	end

	if whichShader == "basicShapes" || whichShader == "texturedShapes"
		positionAttribute = glGetAttribLocation(state.program, "position")
		glEnableVertexAttribArray(positionAttribute)
		glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, false, 9*sizeof(GLfloat), 0)

		colorAttribute = glGetAttribLocation(state.program, "color")
		glEnableVertexAttribArray(colorAttribute)
		glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 3*sizeof(GLfloat))

		glUniformMatrix4fv(glGetUniformLocation(state.program, "MVP"), 1, false, GLmatState.currMatrix)
	end

	if whichShader == "texturedShapes"
		texAttrib = glGetAttribLocation(state.program, "texcoord")
		glEnableVertexAttribArray(texAttrib)
		glVertexAttribPointer(texAttrib, 2, GL_FLOAT, false, 9*sizeof(GLfloat), 7*sizeof(GLfloat))

		glUniform1i(glGetUniformLocation(state.program, "tex"), 2)
	end

	if whichShader == "fontDrawing"
		positionAttribute = glGetAttribLocation(state.program, "position")
		glEnableVertexAttribArray(positionAttribute)
		glVertexAttribPointer(positionAttribute, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 0)

		texAttrib = glGetAttribLocation(state.program, "texcoord")
		glEnableVertexAttribArray(texAttrib)
		glVertexAttribPointer(texAttrib, 4, GL_FLOAT, false, 9*sizeof(GLfloat), 4*sizeof(GLfloat))

		glUniform3f(glGetUniformLocation(state.program, "textColor"), GLfloat(state.fillCol[1].r), GLfloat(state.fillCol[1].g), GLfloat(state.fillCol[1].b))

		# by default, we always use texture 1 for fonts
		glUniform1i(glGetUniformLocation(state.program, "text"), 1)

		# text is rendered with an orthographic projection
		projection = GLfloat[2/state.width 0 0 -1;
		0 2/state.height 0 -1;
		0 0 -1 0;
		0 0 0 1]

		glUniformMatrix4fv(glGetUniformLocation(state.program, "proj"), 1, false, projection)
	end

	if whichShader == "drawFramebuffer"
		positionAttribute = glGetAttribLocation(state.program, "position")
		glEnableVertexAttribArray(positionAttribute)
		glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, false, 4*sizeof(GLfloat), 0)

		texAttrib = glGetAttribLocation(state.program, "texcoord")
		glEnableVertexAttribArray(texAttrib)
		glVertexAttribPointer(texAttrib, 2, GL_FLOAT, false, 4*sizeof(GLfloat), 2*sizeof(GLfloat))

		glUniform1i(glGetUniformLocation(state.program, "texFramebuffer"), 0)
	end
end
