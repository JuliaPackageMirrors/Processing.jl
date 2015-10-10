function loadColors!(vertexData, colorMat, vertexStride, shapeStride)
	if size(colorMat, 1) == 1
		@inbounds vertexData[4:vertexStride:end] = colorMat[1].r
		@inbounds vertexData[5:vertexStride:end] = colorMat[1].g
		@inbounds vertexData[6:vertexStride:end] = colorMat[1].b
		@inbounds vertexData[7:vertexStride:end] = 1.0
	else
		for c = 1:size(colorMat, 1)
			@inbounds vertexData[(c-1)*shapeStride+4:vertexStride:c*shapeStride] = colorMat[c].r
			@inbounds vertexData[(c-1)*shapeStride+5:vertexStride:c*shapeStride] = colorMat[c].g
			@inbounds vertexData[(c-1)*shapeStride+6:vertexStride:c*shapeStride] = colorMat[c].b
			@inbounds vertexData[(c-1)*shapeStride+7:vertexStride:c*shapeStride] = 1.0
		end
	end
end
