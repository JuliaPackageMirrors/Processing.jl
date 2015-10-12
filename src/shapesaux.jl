function loadColors!(colData, colorMat, shapeStride)
	if size(colorMat, 1) == 1
		@inbounds colData[1:4:end] = colorMat[1].r
		@inbounds colData[2:4:end] = colorMat[1].g
		@inbounds colData[3:4:end] = colorMat[1].b
		@inbounds colData[4:4:end] = 1.0
	else
		for c = 1:size(colorMat, 1)
			@inbounds colData[(c-1)*shapeStride+1:4:c*shapeStride] = colorMat[c].r
			@inbounds colData[(c-1)*shapeStride+2:4:c*shapeStride] = colorMat[c].g
			@inbounds colData[(c-1)*shapeStride+3:4:c*shapeStride] = colorMat[c].b
			@inbounds colData[(c-1)*shapeStride+4:4:c*shapeStride] = 1.0
		end
	end
end
