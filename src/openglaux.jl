# Borrowed from the ModernGL.jl example created by Simon Danisch
# Apparently, this might originally come from @yurivish (https://github.com/yurivish)
# The copy here has only been very slightly modified to add convience functions
# for generating frame and render buffers.

function glGetInfoLog(obj::GLuint)
	isShader = glIsShader(obj)
	getiv = isShader == GL_TRUE ? glGetShaderiv : glGetProgramiv
	getInfo = isShader == GL_TRUE ? glGetShaderInfoLog : glGetProgramInfoLog

	int = GLint[0]
	getiv(obj, GL_INFO_LOG_LENGTH, int)
	maxlength = int[1]

	if maxlength > 0
		buffer = zeros(GLchar, maxlength)
		sizei = GLsizei[0]
		getInfo(obj, maxlength, sizei, buffer)
		length = sizei[1]
		bytestring(pointer(buffer), length)
	else
		""
	end
end

function validateShader(shader)
	success = GLint[0]
	glGetShaderiv(shader, GL_COMPILE_STATUS, success)
	success[1] == GL_TRUE
end

function glErrorMessage()
	err = glGetError()
	err == GL_NO_ERROR ? "" :
	err == GL_INVALID_ENUM ? "GL_INVALID_ENUM: An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag." :
	err == GL_INVALID_VALUE ? "GL_INVALID_VALUE: A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag." :
	err == GL_INVALID_OPERATION ? "GL_INVALID_OPERATION: The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag." :
	err == GL_INVALID_FRAMEBUFFER_OPERATION ? "GL_INVALID_FRAMEBUFFER_OPERATION: The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag." :
	err == GL_OUT_OF_MEMORY ? "GL_OUT_OF_MEMORY: There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded." : "Unknown OpenGL error with error code $err."
end

function glCheckError(actionName="")
	message = glErrorMessage()
	if length(message) > 0
		if length(actionName) > 0
			error("Error ", actionName, ": ", message)
		else
			error("Error: ", message)
		end
	end
end

function glGenOne(glGenFn)
	id = GLuint[0]
	glGenFn(1, id)
	glCheckError("generating a buffer, array, or texture")
	id[1]
end

glGenBuffer() = glGenOne(glGenBuffers)
glGenFramebuffer() = glGenOne(glGenFramebuffers)
glGenRenderbuffer() = glGenOne(glGenRenderbuffers)
glGenVertexArray() = glGenOne(glGenVertexArrays)
glGenTexture() = glGenOne(glGenTextures)

global GLSL_VERSION = ""

function createcontextinfo()
	global GLSL_VERSION

	glsl = split(bytestring(glGetString(GL_SHADING_LANGUAGE_VERSION)), ['.', ' '])
	if length(glsl) >= 2
		glsl = VersionNumber(int(glsl[1]), int(glsl[2]))
		GLSL_VERSION = string(glsl.major) * rpad(string(glsl.minor),2,"0")
	else
		error("Unexpected version number string. Please report this bug! GLSL version string: $(glsl)")
	end

	glv = split(bytestring(glGetString(GL_VERSION)), ['.', ' '])
	if length(glv) >= 2
		glv = VersionNumber(int(glv[1]), int(glv[2]))
	else
		error("Unexpected version number string. Please report this bug! OpenGL version string: $(glv)")
	end

	dict = (Symbol => Any)[]
	dict[:glsl_version]	= glsl
	dict[:gl_version] = glv
	dict[:gl_vendor] = bytestring(glGetString(GL_VENDOR))
	dict[:gl_renderer]	= bytestring(glGetString(GL_RENDERER))
	dict
end

function get_glsl_version_string()
	if isempty(GLSL_VERSION)
		error("couldn't get GLSL version, GLUTils not initialized, or context not created?")
	end

	return "#version $(GLSL_VERSION)\n"
end

function createShader(source, typ)
	shader = glCreateShader(typ)::GLuint
	if shader == 0
		error("Error creating shader: ", glErrorMessage())
	end
	glShaderSource(shader, 1, convert(Ptr{Uint8}, pointer([convert(Ptr{GLchar}, pointer(source))])), C_NULL)
	glCompileShader(shader)
	!validateShader(shader) && error("Shader creation error: ", glGetInfoLog(shader))
	return shader
end

function createShaderProgram(f, vertexShader, fragmentShader)
	prog = glCreateProgram()
	if prog == 0
		error("Error creating shader program: ", glErrorMessage())
	end

	glAttachShader(prog, vertexShader)
	glCheckError("attaching vertex shader")

	glAttachShader(prog, fragmentShader)
	glCheckError("attaching fragment shader")
	f(prog)

	glLinkProgram(prog)
	status = GLint[0]

	glGetProgramiv(prog, GL_LINK_STATUS, status)
	println(status)

	if status[1] == GL_FALSE
		glDeleteProgram(prog)
		error("Error linking shader: ", glGetInfoLog(prog))
	end
	prog
end

createShaderProgram(vertexShader, fragmentShader) = createShaderProgram(prog->0, vertexShader, fragmentShader)
