--// Public

local sounds = script.Parent.Parent.sounds

local function get(name: "Backspace" | "Enter" | "Key" | "NoType"): Sound?
	return sounds:FindFirstChild(name)
end

local function play(name: "Backspace" | "Enter" | "Key" | "NoType")
	local sound = get(name)

	if not sound then
		return
	end

	sound:Play()
end

--// Export

return table.freeze({
	get = get,
	play = play,
})
