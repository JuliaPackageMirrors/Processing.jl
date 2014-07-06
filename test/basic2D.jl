using Processing
@Processing.version "2D"
@Processing.load

ellipse(0,0,0.3,0.5)
ellipse(0,0,0.2,0.2)
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
arc(-.6, .6, .3, 0.4pi, pi)
animate()

x = 0
while true
	fill(sin(x)/2+0.5,cos(x)/2+0.5,(sin(x)*cos(x))/2+0.5,1)
	ellipse(0,0,0.2,0.2)
	point(0, 0)
	animate()
	x = x + 0.01
end
