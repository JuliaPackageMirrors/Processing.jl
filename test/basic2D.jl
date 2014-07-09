using Processing
@Processing.version "2D"
@Processing.load

coordSystem(-1, 1, 1, -1) # user-defined coordinate system (x-axis min = -1,
						  # x-axis max = 1, y-axis min = -1, y-axis max = 1,
						  # xcent = 0, ycent = 0)
						  #
						  # I can just think easier this way...
						  #
						  # default coordinate system is in units of pixels with
						  # top-left corner of drawing surface labeled (0,0),
						  # just like Processing's default coordinate system
smooth()

ellipse(0,0,0.3,0.5)
ellipse(-.5,.5,0.2,0.2)
triangle(.3, .75, .58, .20, .86, .75)
triangle(.3, .6, .58, .40, .86, .7)
point(0, 0)
fill(1,0,0,1)
quad(-.3, -.75, -.58, -.20, -.86, -.75, -.2, -.4)
noFill()
rect(-.6, -.6, .2, .5)
line(.5, -.4, .7, -.5)
line(.7, -.4, .5, -.5)
strokeWeight(1)
stroke(0.9, 0, 0, 1)
arc(-.6, .6, .3, .3, 0.4pi, pi, CHORD)
animate()

x = 0
while true
	fill(sin(x)/2+0.5,cos(x)/2+0.5,(sin(x)*cos(x))/2+0.5,1)
	ellipse(0,0,0.2,0.2)
	point(0, 0)
	animate()
	x = x + 0.01
	if mousePressed()
		println("mouse pressed")
	end
end
