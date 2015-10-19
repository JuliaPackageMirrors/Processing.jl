export imageMode, loadImage, noTint, save

## Loading & Displaying

function imageMode(mode)
	state.imageMode = mode
end

function loadImage(filename::AbstractString)
    image = Images.imread(filename)
end

function noTint()
    state.tintStuff = false
end

function save(filename::AbstractString)
	data = Array{GLfloat}(3, state.width*2, state.height*2)
	glReadPixels(0, 0, state.width*2, state.height*2, GL_RGB, GL_FLOAT, data)
	data[1,:,:] = flipud(squeeze(data[1,:,:],1))
	data[2,:,:] = flipud(squeeze(data[2,:,:],1))
	data[3,:,:] = flipud(squeeze(data[3,:,:],1))
	img = Image(data, colorspace = "RGB", spatialorder = ["x", "y"], colordim = 1)
	Images.imwrite(img, filename)
end

# function tint()
#
# end
