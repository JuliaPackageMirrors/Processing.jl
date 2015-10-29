export keyPress, keyWait, spaceWait
export mousePress, mouseX, mouseY

function keyPress(window, button)
	GLFW.PollEvents()
	if GLFW.GetKey(window, button) == GLFW.PRESS
		return true
	else
		return false
	end
end

function spaceWait(window)
	while true
		GLFW.WaitEvents()
		if GLFW.GetKey(window, GLFW.KEY_SPACE) == GLFW.PRESS
			break
		end
	end
end

function mousePress(window, button)
	GLFW.PollEvents()
	if GLFW.GetMouseButton(window, button) == GLFW.PRESS
		return true
	else
		return false
	end
end

function mouseRelease(window, button)
	GLFW.PollEvents()
	if GLFW.GetMouseButton(window, button) == GLFW.RELEASE
		return true
	else
		return false
	end
end

function mouseX(window)
	GLFW.PollEvents()
	x, y = GLFW.GetCursorPos(window)
	return x
end

function mouseY(window)
	GLFW.PollEvents()
	x, y = GLFW.GetCursorPos(window)
	return y
end
