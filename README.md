Processing.jl
=============

A port of the Processing language (https://www.processing.org) to Julia.

It mainly uses ModernGL.jl and GLFW.jl behind the scenes. Please note that this package assumes that you have a graphics card/driver which supports OpenGL 3.2 or greater. If your computer is about 4-5 years old, then that is most likely the case. A convience function will soon be added to easily report what versions of OpenGL your card supports.

At the moment, this package is based on "hand-written" code, in order to see how much speed can be attained in a raw OpenGL setting. That code is slowly being transferred to the GLAbstraction.jl, GLWindow.jl, and GLVisualize.jl packages and those packages will eventually become the main support for Processing.jl. This development will take place in a separate branch. The master branch will remain the recommended version for the time being, since it is tested and mostly stable. Any bug fixes will be ported to both branches.

# Installation

## Mac OS X

This package is developed on a 13" Macbook Pro with an Intel card. So far, my experience is that on OS X 10.10 and 10.11, everything just works. However, the assumption is made that you have a Retina screen if you are using a Mac. This will be amended soon. Anyway, to install, just run the following:

```julia
Pkg.clone("https://github.com/SimonDanisch/FreeTypeAbstraction.jl.git")
Pkg.clone("https://github.com/rennis250/Processing.jl.git")
```

## Linux

Only tested on Ubuntu 14.04 LTS with the opensource ATI drivers. First, make sure that the required packages for GLFW.jl are installed:

```julia
sudo apt-get update
sudo apt-get install cmake xorg-dev libglu1-mesa-dev
```

(Note: I found that cmake was not installed on the machine that I was using. The GLFW C code assumes that you have cmake installed, so we installed via apt-get here.)

Then, install the rest as usual:

```julia
Pkg.clone("https://github.com/SimonDanisch/FreeTypeAbstraction.jl.git")
Pkg.clone("https://github.com/rennis250/Processing.jl.git")
```

## Windows

Only tested on a Windows 7 machine with an ATI card. So far, Images is failing during pre-compiliation on Windows, which removes any image related functionality from this package on Windows for the time being (e.g., loading images or drawing textures). However, that is being worked on. Aside, from that, install the package as usual:

```julia
Pkg.clone("https://github.com/SimonDanisch/FreeTypeAbstraction.jl.git")
Pkg.clone("https://github.com/rennis250/Processing.jl.git")
```

# Caveats

For some features, such as alpha blending or point smoothing, we ask OpenGL to simply perform this operation. This means that it will depend on the algorithms that your graphics card supplier/driver has implemented. I have already noticed visible differences between rendering on Windows and Mac. These differences should soon be amended with our own shader-based implementations of these functions.

# Credit

Processing is an open graphics programming language developed by Ben Fry & Casey Reas. This port was developed by Robert Ennis with the help of @SimonDanisch and @o-jasper. It is mainly maintained by Robert Ennis.
