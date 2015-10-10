include(Pkg.dir()*"/Processing/src/Processing2D.jl")

Processing2D.coordSystem(-1, 1, 1, -1) # user-defined coordinate system (x-axis min = -1,
						  # x-axis max = 1, y-axis min = -1, y-axis max = 1,
						  # xcent = 0, ycent = 0)
						  #
						  # I can just think easier this way...
						  #
						  # default coordinate system is in units of pixels with
						  # top-left corner of drawing surface labeled (0,0),
						  # just like Processing's default coordinate system
Processing2D.smooth()

Processing2D.ellipse(0,0,0.3,0.5)
Processing2D.ellipse(-.5,.5,0.2,0.2)
Processing2D.triangle(.3, .75, .58, .20, .86, .75)
Processing2D.triangle(.3, .6, .58, .40, .86, .7)
Processing2D.point(0, 0)
Processing2D.fill(1,0,0,1)
Processing2D.quad(-.3, -.75, -.58, -.20, -.86, -.75, -.2, -.4)
Processing2D.noFill()
Processing2D.rect(-.6, -.6, .2, .5)
Processing2D.line(.5, -.4, .7, -.5)
Processing2D.line(.7, -.4, .5, -.5)
Processing2D.strokeWeight(1)
Processing2D.stroke(0.9, 0, 0, 1)
Processing2D.arc(-.6, .6, .3, .3, 0.4pi, pi, CHORD)
Processing2D.animate()

x = 0
while true
	Processing2D.fill(sin(x)/2+0.5,cos(x)/2+0.5,(sin(x)*cos(x))/2+0.5,1)
	Processing2D.ellipse(0,0,0.2,0.2)
	Processing2D.point(0, 0)
	Processing2D.animate()
	x = x + 0.01
	if Processing2D.mousePressed()
		println("mouse pressed")
	end
end
