export cursor, focused, frameCount, frameRate
export height, noCursor, noSmooth, smooth, width

function cursor(window)
	GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
	GLFW.SetCursor(window, GLFW.ARROW_CURSOR)
end

function cursor(window, cursorType)
	GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
	if cursorType == "HAND"
		GLFW.SetCursor(window, GLFW.HAND_CURSOR)
	elseif cursorType == "ARROW"
		GLFW.SetCursor(window, GLFW.ARROW_CURSOR)
	elseif cursorType == "CROSS"
		GLFW.SetCursor(window, GLFW.CROSSHAIR_CURSOR)
	elseif cursorType == "MOVE"
		GLFW.SetCursor(window, GLFW.HRESIZE_CURSOR)
	elseif cursorType == "TEXT"
		GLFW.SetCursor(window, GLFW.IBEAM_CURSOR)
	elseif cursorType == "WAIT"
		# GLFW.SetCursor(window, GLFW.HAND_CURSOR)
	end
end

function focused(window)
    if GLFW.GetWindowAttrib(window, GLFW.FOCUSED)
        return true
    else
        return false
    end
end

function frameCount()
	return state.frameCount
end

function frameRate()
	return state.frameRate
end

function frameRate(fRate)
	state.frameRate = fRate
	return nothing
end

function height()
	return state.height
end

function noCursor(window)
	GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_HIDDEN)
end

function noSmooth()
	glDisable(GL_MULTISAMPLE)
end

function smooth()
	glEnable(GL_MULTISAMPLE)
end

function width()
	return state.width
end
