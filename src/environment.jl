export cursor, focused, frameCount, frameRate
export height, noCursor, noSmooth, smooth, width

# start with arrow cursor by default, as expected
currCursor = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)

function cursor(window)
	GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
	GLFW.SetCursor(window, currCursor)
end

function cursor(window, cursorType)
	GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
	if cursorType == "HAND"
		currCursor = GLFW.CreateStandardCursor(GLFW.HAND_CURSOR)
	elseif cursorType == "ARROW"
		currCursor = GLFW.CreateStandardCursor(GLFW.ARROW_CURSOR)
	elseif cursorType == "CROSS"
		currCursor = GLFW.CreateStandardCursor(GLFW.CROSSHAIR_CURSOR)
	elseif cursorType == "MOVE"
		currCursor = GLFW.CreateStandardCursor(GLFW.IBEAM_CURSOR)
	elseif cursorType == "TEXT"
		currCursor = GLFW.CreateStandardCursor(GLFW.IBEAM_CURSOR)
	elseif cursorType == "WAIT"
		# currCursor = GLFW.CreateStandardCursor(GLFW.HAND_CURSOR)
	end
	GLFW.SetCursor(window, currCursor)
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
