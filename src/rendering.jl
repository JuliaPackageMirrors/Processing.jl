export blendMode

function blendMode(mode)
	if mode == "REPLACE"
		glBlendEquation(GL_FUNC_ADD)
		glBlendFunc(GL_ONE, GL_ZERO)
	elseif mode == "BLEND"
		# glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD)
		glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE)
	elseif mode == "ADD"
		# glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD)
		glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE, GL_ONE, GL_ONE)
	elseif mode == "SUBTRACT"
		# glBlendEquationSeparate(GL_FUNC_REVERSE_SUBTRACT, GL_FUNC_ADD);
		glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE, GL_ONE, GL_ONE)
	elseif mode == "LIGHTEST"
		# glBlendEquationSeparate(GL_FUNC_MAX, GL_FUNC_ADD);
		glBlendFuncSeparate(GL_ONE, GL_ONE, GL_ONE, GL_ONE)
	elseif mode == "DARKEST"
		# glBlendEquationSeparate(GL_FUNC_MIN, GL_FUNC_ADD);
		glBlendFuncSeparate(GL_ONE, GL_ONE, GL_ONE, GL_ONE)
	elseif mode == "EXCLUSION"
		# glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD)
		glBlendFuncSeparate(GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR, GL_ONE, GL_ONE)
	elseif mode == "MULTIPLY"
		# glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD)
		glBlendFuncSeparate(GL_ZERO, GL_SRC_COLOR, GL_ONE, GL_ONE)
	elseif mode == "SCREEN"
		# glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD)
		glBlendFuncSeparate(GL_ONE_MINUS_DST_COLOR, GL_ONE, GL_ONE, GL_ONE)
	end
end

#createGraphics
