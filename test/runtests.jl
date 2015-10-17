# matlab estimate of isi = 0.0177
# julia/glfw estimate of isi = 0.0166 (monitor is at 60Hz. 1/60 = 0.016666...)
#
# a basic draw test was:
#	- draw 100 randomly placed ellipses, with random widths and heights
#	- make sure each ellipse has a randomly assigned fill color and stroke
#	  color
# for this test:
#	fastest matlab roundtrip time = ~0.007860 secs
#	fastest julia roundtrip time = ~0.001945 secs
#
# julia is faster (~4x faster) and its timing fluctuates much less than
# matlab's. plus, it appears that julia accurately syncs to vertical refresh,
# even on OS X.
#
# (however, i'm not sure if this is an illusion or a mistake on my part...)
#
# anyway, "test.tsv" contains timing data for Processing.jl that was generated
# by the script below. the times are how long it takes from the top of the
# animation loop to the screen being updated. if we have proper vsync, then
# this should always be 0.01666... secs. "test.tsv" shows that this is the
# case, at an average frame time of 0.016649 secs with a fluctuation error of
# ~0.0012 secs.
#
# note that, all of this here is without any of the special psychtoolbox tricks
# that try to make stuff sync with the monitor via tweaks. its just standard
# opengl and glfw commands, although we are using the commands that are some
# of the fastest for rendering.
#
# the julia code is also easier to write, understand, and maintain.

using Processing

window = screen()
ftbf = zeros(600)
ft = zeros(600)
x = 1
t = 0

image = loadImage(Pkg.dir()*"/Processing/test/image.png")
tex = texture(image)

@time while x < 600
	st = time_ns()
	background(0.94, 0.92, 0.9, 1.0)
	strokecol(0, 0, 0, 1)
	fillcol(0.7, 0.7, 0.7, 1.0)
	ellipse(0, 0, 0.3, 0.5)
	ellipse(-.5, .5, 0.2, 0.2)
	triangle(.3, .75, .58, .20, .86, .75)
	triangle(.3, .6, .58, .40, .86, .7)
	strokeWeight(5)
	point(randn(10), randn(10))
	text("Processing.jl", 0.25, -0.85)
	strokeWeight(1)
	fillcol(0, 0, 0.9, 1)
	quad(-.3, -.75, -.58, -.20, -.86, -.75, -.2, -.4)
	line(.5, -.4, .7, -.5)
	noFill()
	rect(-.6, -.4, .2, .5)
	line(.7, -.4, .5, -.5)
	strokecol(0.9, 0, 0, 1)
	arc(-.6, .6, .3, .3, 0.4pi, pi)
	strokecol(0, 0.9, 0, 1)
	fillcol(1.0, 1.0, 1.0, 1.0)
	ellipse(0, 0, 0.2, 0.2)
	noStroke()
	fillcol(sin(t)/2+0.5, cos(t)/2+0.5, (sin(t)*cos(t))/2+0.5, 1.0)
	pushMatrix()
	rotateY(pi/10*t)
	rotateX(pi/10*t)
	translate(0.2, -0.5, 0)
	box(0.15)
	popMatrix()
	fillcol(1, 1, 1, 1)
	rect(-0.1, 0.6, 0.2, 0.2, tex)
	if keyPress(window, GLFW.KEY_SPACE)
		save("screenshot.tiff")
		println("key pressed and screenshot saved.")
	end
	if mousePress(window, GLFW.MOUSE_BUTTON_LEFT)
		println("bye!")
		break
	end
	ftbf[frameCount()+1] = time_ns() - st
	animate(window)
	ft[frameCount()] = time_ns() - st
	t += 1/60
	x += 1
end

endDrawing(window)
