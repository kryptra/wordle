--// Public

local ContextActionService = game:GetService("ContextActionService")

local function bind_key(key: Enum.KeyCode, callback: (input: InputObject, is_pressed: boolean) -> ...any)
	assert(typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode, "Expected a KeyCode")
	assert(typeof(callback) == "function", "Expected a function")

	ContextActionService:BindActionAtPriority(
		`Keybind_{key}`,
		function(_: string, inputState: Enum.UserInputState, inputObject: InputObject): Enum.ContextActionResult?
			if inputState ~= Enum.UserInputState.Begin and inputState ~= Enum.UserInputState.End then
				return Enum.ContextActionResult.Pass
			end

			local is_pressed = inputState == Enum.UserInputState.Begin and true or false

			task.spawn(pcall, callback, inputObject, is_pressed)

			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.ContextActionPriority.High.Value,
		key
	)
end

--// Export

return table.freeze({
	bind_key = bind_key,
})
