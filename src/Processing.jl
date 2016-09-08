VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Processing

using ModernGL, GLFW, Colors, Tau, Images
using FreeType, FreeTypeAbstraction
using GLAbstraction, GeometryTypes, Packing

# the following isn't defined in ModernGL.jl yet.
# it is borrowed from the GLVisualize.jl package.
const GL_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE

include("constants.jl")
include("shaders.jl")

shaderBank = Dict("basicShapes" => GLuint(0),
                "texturedShapes" => GLuint(0),
                "fontDrawing" => GLuint(0),
                "drawFramebuffer" => GLuint(0))

type stateStruct
    bgCol::Array{RGB{Float64}, 1}
    fillStuff::Bool
    fillCol::Array{RGB{Float64}, 1}
    strokeStuff::Bool
    strokeCol::Array{RGB{Float64}, 1}
    tintStuff::Bool
    tintCol::Array{RGB{Float64}, 1}
    program::GLuint
    drawTexture::Bool
    aspectRatio::Float32
    preserveAspectRatio::Bool
    fbSize::Tuple{Int32,Int32}
    strokeWeight::Float32
    fontFace::AbstractString
    textSize::Float32
    height::Int
    width::Int
    left::Float32
    right::Float32
    top::Float32
    bottom::Float32
    cMode::AbstractString
    title::AbstractString
    ellipseMode::AbstractString
    rectMode::AbstractString
    shapeMode::AbstractString
    imageMode::AbstractString
    frameRate::Int
    frameCount::Int
    fontsInitialized::Bool
    alternateShader::Union{Shader,Void}
end

# need to generalize font system
state = stateStruct([RGB(0.8, 0.8, 0.8)], true, [RGB(1.0, 1.0, 1.0)], true, [RGB(0.0, 0.0, 0.0)], false, [RGB(0.0, 0.0, 0.0)], GLuint(0), false, 1., true, (Int32(0), Int32(0)), 1.0, "", 0.4, 275, 275, -1., 1., 1., -1., "RGB", "Processing.jl", "CENTER", "CORNER", "CORNER", "CORNER", 60, 0, false, nothing)

# by default, use system fonts that are known to basically always be available
@windows_only state.fontFace = "C:/Windows/Fonts/arial.ttf"
@linux_only state.fontFace = "/usr/share/fonts/DejaVu/DejaVuSansMono.ttf"
@osx_only state.fontFace = "/System/Library/Fonts/Menlo.ttc"

type vertexStruct
    shapeVertices::Array{GLfloat, 1}
    textureCoords::Array{GLfloat, 1}
    vertexStride::Int
    nVertices::Int
    shapeType::GLuint
end

shapeData = vertexStruct(GLfloat[], GLfloat[], -1, -1, GL_POINTS)

include("openglaux.jl")
include("color.jl")
include("environment.jl")
include("image.jl")
include("input.jl")
include("pixels.jl")
include("rendering.jl")
include("shapes2d.jl")
include("shapes3d.jl")
include("textures.jl")

type GLmatStruct
    currMatrix::Array{GLfloat, 2}
    matrixStack::Array{Array{GLfloat, 2}, 1}
end

# start with default identity matrix, as expected.
GLmatState = GLmatStruct(GLfloat[1 0 0 0;
                                0 1 0 0;
                                0 0 1 0;
                                0 0 0 1],
                                GLfloat[])
include("transform.jl")

include("typography.jl")

type textCharacter
    size::Array{Int, 1}
    bearing::Array{Float64, 1}
    advance::Array{Float64, 1}
    atlasOffset::Float64
end

blankChar = textCharacter(Float64[], Float64[], Float64[], 0.)

type fontStruct
    characters::Dict{Char, textCharacter}
    textAtlas::GLuint
    atlasWidth::Float64
    atlasHeight::Float64
    maxLineLength::Int
    face::Array{Ptr{FreeType.FT_FaceRec}, 1}
    fontWidth::Int
    fontHeight::Int
end

# 80 characters is choosen as the default line length, just like on Unix :)
fontState = fontStruct(Dict(' ' => blankChar), GLuint(0), 0., 0., 80, Ptr{FreeType.FT_FaceRec}[], 0, 48)

function __init__()
    FreeTypeAbstraction.init() # initialize FreeType
    fontState.face = newface(state.fontFace)
    FreeTypeAbstraction.setpixelsize(fontState.face, fontState.fontWidth, fontState.fontHeight)
end

# this will be the texture for rendering into our own framebuffer.
texColorBuffer = GLuint[0]
# this contains the coordinates for the framebuffer texture that we draw at
# the end of each render loop.
# yes, this is illegible.
quadPosCoords = GLfloat[-1.0, 1.0,
                        1.0, 1.0,
                        1.0, -1.0,
                        1.0, -1.0,
                        -1.0, -1.0,
                        -1.0, 1.0]
quadTexCoords = GLfloat[0.0, 1.0,
                        1.0, 1.0,
                        1.0, 0.0,
                        1.0, 0.0,
                        0.0, 0.0,
                        0.0, 1.0]

type GLobjs
    vaos::Array{GLuint, 1}
    posvbos::Array{GLuint, 1}
    posind::Int
    colvbos::Array{GLuint, 1}
    colind::Int
    texvbos::Array{GLuint, 1}
    texind::Int
    ebos::Array{GLuint, 1}
    fbos::Array{GLuint, 1}
    rbos::Array{GLuint, 1}
end

globjs = GLobjs(GLuint[], GLuint[], 0, GLuint[], 0, GLuint[], 0, GLuint[], GLuint[], GLuint[])

export screen, animate, endDrawing, drawingWindow

function screen(width, height; fullScreen=false, preserveAspectRatio=true, GLmajv=3, GLminv=2)
    GLFW.Init()

    GLFW.WindowHint(GLFW.VISIBLE, true)

    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, GLmajv)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, GLminv)
    GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
    GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE)

    # try to activate 10 bpc support
    GLFW.WindowHint(GLFW.RED_BITS, 10)
    GLFW.WindowHint(GLFW.GREEN_BITS, 10)
    GLFW.WindowHint(GLFW.BLUE_BITS, 10)
    GLFW.WindowHint(GLFW.ALPHA_BITS, 8)

    # anti-aliasing by default
    GLFW.WindowHint(GLFW.SAMPLES, 4)
    GLFW.WindowHint(GLFW.RESIZABLE, false)

    if state.frameRate != 60
        GLFW.WindowHint(GLFW.REFRESH_RATE, state.frameRate)
    end

    if fullScreen
        priMon = GLFW.GetPrimaryMonitor()
        vidMode = GLFW.GetVideoMode(priMon)
        state.width = vidMode.width
        state.height = vidMode.height
        window = GLFW.CreateWindow(state.width, state.height, state.title, priMon)
    else
        state.width = width
        state.height = height
        window = GLFW.CreateWindow(state.width, state.height, state.title)
    end

    state.aspectRatio = state.width/state.height
    state.preserveAspectRatio = preserveAspectRatio

    GLFW.MakeContextCurrent(window)
    GLFW.ShowWindow(window)
    GLFW.SetWindowSize(window, state.width, state.height)

    state.fbSize = GLFW.GetFramebufferSize(window)

    glViewport(0, 0, state.fbSize[1], state.fbSize[2])
    GLFW.SwapInterval(1)

    createcontextinfo()

    # framebuffer stuff

    @windows_only begin glGenFramebuffer() end
    # (at least on the one windows 7 machine with an ATI card that I tested,
    # the first call to glGenFramebuffer fails and all subsequent calls
    # succeeed)
    push!(globjs.fbos,  glGenFramebuffer())
    glBindFramebuffer(GL_FRAMEBUFFER, globjs.fbos[1])

    glActiveTexture(GL_TEXTURE0)
    glGenTextures(1, texColorBuffer)
    glBindTexture(GL_TEXTURE_2D, texColorBuffer[1])

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, state.fbSize[1], state.fbSize[2], 0, GL_RGBA, GL_FLOAT, C_NULL)

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texColorBuffer[1], 0)

    # we also need to enable a depth buffer to attach to the framebuffer
    push!(globjs.rbos,  glGenRenderbuffer())
    glBindRenderbuffer(GL_RENDERBUFFER, globjs.rbos[1])
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, state.fbSize[1], state.fbSize[2])
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, globjs.rbos[1])

    if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE
        error("framebuffer not initialized.")
    end

    initShaders()

    glPointSize(2) # points are too small to see when 1-pixel big at high res

    # don't re-enable this until we have a better way of making
    # sure that vertices always wind in the correct direction.
    # currently, this is only enabled during text writing.
    # glEnable(GL_CULL_FACE)
    # glCullFace(GL_BACK)
    # glFrontFace(GL_CW)

    glEnable(GL_BLEND) # using blending by default
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE)

    glEnable(GL_MULTISAMPLE) # just be double sure that multisampling is on

    # glEnable(GL_TEXTURE_2D)

    glEnable(GL_LINE_SMOOTH)
    # glEnable(GL_POINT_SMOOTH)
    # glHint(GL_POINT_SMOOTH_HINT, GL_NICEST)

    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)

    if !state.fontsInitialized
        setupFontCharacters()
    end
    state.fontsInitialized = true

    # make the color attachment of the frame buffer the default drawing
    # location
    glDrawBuffers(1, [GL_COLOR_ATTACHMENT0])
    glBindFramebuffer(GL_FRAMEBUFFER, globjs.fbos[1])
    glEnable(GL_DEPTH_TEST)
    shader("basicShapes")
    glClearColor(state.bgCol[1].r, state.bgCol[1].g, state.bgCol[1].b, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glClearColor(1.0, 1.0, 1.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)
    glDisable(GL_DEPTH_TEST)
    shader("drawFramebuffer")

    # draw framebuffer texture to screen
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, texColorBuffer[1])
    glDrawArrays(GL_TRIANGLES, 0, 6)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

    glBindFramebuffer(GL_FRAMEBUFFER, globjs.fbos[1])
    glEnable(GL_DEPTH_TEST)
    shader("basicShapes")
    glClearColor(state.bgCol[1].r, state.bgCol[1].g, state.bgCol[1].b, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # for some reason, Windows 7 loses contact with the rendering context if
    # this check isn't made before every draw call
    @windows_only begin
        if GLFW.WindowShouldClose(window)
            GLFW.DestroyWindow(window)
        end
    end

    glErrorMessage()

    return window
end

screen(w; fullScreen=false, preserveAspectRatio=true, GLmajv=3, GLminv=2) = screen(w, w; fullScreen=fullScreen, preserveAspectRatio=preserveAspectRatio, GLmajv=GLmajv, GLminv=GLminv)
screen(; fullScreen=false, preserveAspectRatio=true, GLmajv=3, GLminv=2) = screen(state.width, state.height; fullScreen=fullScreen, preserveAspectRatio=preserveAspectRatio, GLmajv=GLmajv, GLminv=GLminv)

function animate(window)
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    # glClearColor(1.0, 1.0, 1.0, 1.0)
    # glClear(GL_COLOR_BUFFER_BIT)
    glDisable(GL_DEPTH_TEST)

    shader("drawFramebuffer")

    # draw framebuffer texture to screen
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, texColorBuffer[1])
    glDrawArrays(GL_TRIANGLES, 0, 6)

    GLFW.SwapBuffers(window)
    # for some reason, Windows 7 loses contact with the rendering context if
    # this command isn't run before every draw call
    @windows_only begin
        GLFW.PollEvents()
    end

    glBindFramebuffer(GL_FRAMEBUFFER, globjs.fbos[1])
    glEnable(GL_DEPTH_TEST)
    if state.alternateShader == nothing
        shader("basicShapes")
    else
        shader(state.alternateShader)
    end

    # for some reason, Windows 7 loses contact with the rendering context if
    # this check isn't made before every draw call
    @windows_only begin
        if GLFW.WindowShouldClose(window)
            GLFW.DestroyWindow(window)
        end
    end

    state.frameCount += 1
end

function animate(f::Function, window)
    while true
        f()
        animate(window)
    end
end

function endDrawing(window)
    GLFW.DestroyWindow(window)
end

function drawingWindow(window)
    GLFW.MakeContextCurrent(window)
    GLFW.ShowWindow(window)
end

end # module
