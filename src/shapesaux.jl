function loadColors!(colData, colorMat, shapeStride)
	if size(colorMat, 1) == 1
		colData[1:4:end] = colorMat[1].r
		colData[2:4:end] = colorMat[1].g
		colData[3:4:end] = colorMat[1].b
		colData[4:4:end] = 1.0
	else
		@inbounds @simd for c = 1:size(colorMat, 1)
			colData[(c-1)*shapeStride+1:4:c*shapeStride] = colorMat[c].r
			colData[(c-1)*shapeStride+2:4:c*shapeStride] = colorMat[c].g
			colData[(c-1)*shapeStride+3:4:c*shapeStride] = colorMat[c].b
			colData[(c-1)*shapeStride+4:4:c*shapeStride] = 1.0
		end
	end
end
