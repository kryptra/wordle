--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages

--// Dependencies

local Fusion = require(Packages.Fusion)

local KeyboardController = require("../controllers/KeyboardController")
local Constants = require("../config/Constants")
local Theme = require("../config/Theme")

--// Public

local New, Children, OnEvent, Spring, Computed, Value =
	Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.Spring, Fusion.Computed, Fusion.Value

local function Key(props: {
	order: number,
	key: string,
	label: string,
	large: boolean,
	comparedKeys: any,
	onTyped: (key: string) -> (),
})
	local isPressed = Value(false)

	KeyboardController.bind_key(Enum.KeyCode[props.key] :: any, function(_: InputObject, is_pressed: boolean): ...any
		isPressed:set(is_pressed)

		if is_pressed then
			props.onTyped(props.key)
		end
	end)

	return New("TextButton")({
		Name = "KeyContainer",

		Size = UDim2.fromScale((if props.large then 1.5 else 1) / Constants.KEYBOARD_NUM_KEYS_ACROSS, 1),
		LayoutOrder = props.order,

		BackgroundTransparency = 1,

		[OnEvent("MouseLeave")] = function()
			isPressed:set(false)
		end,

		[OnEvent("MouseButton1Down")] = function()
			isPressed:set(true)
			props.onTyped(props.key)
		end,

		[OnEvent("MouseButton1Up")] = function()
			isPressed:set(false)
		end,

		[Children] = {
			New("UIPadding")({
				PaddingTop = Constants.KEYBOARD_KEY_HALF_PADDING,
				PaddingBottom = Constants.KEYBOARD_KEY_HALF_PADDING,
				PaddingLeft = Constants.KEYBOARD_KEY_HALF_PADDING,
				PaddingRight = Constants.KEYBOARD_KEY_HALF_PADDING,
			}),

			New("TextLabel")({
				Name = "KeyVisual",

				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				BackgroundColor3 = Spring(Computed(function()
					local matchType = props.comparedKeys:get()
					return if matchType == "Match"
						then Theme.tileMatch
						elseif matchType == "Partial" then Theme.tilePartialMatch
						elseif matchType == "Miss" then Theme.tileMiss
						else Theme.tileUnknown
				end)),

				Font = "ArialBold",
				Text = props.label,
				TextSize = 14,
				TextColor3 = Theme.text,

				[Children] = {
					New("UICorner")({
						CornerRadius = UDim.new(0, 4),
					}),

					New("UIGradient")({
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 230)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200)),
						}),
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 0.1),
						}),
					}),

					New("UIScale")({
						Scale = Spring(
							Computed(function()
								return if isPressed:get() then 0.8 else 1
							end),
							50,
							0.8
						),
					}),
				},
			}),
		},
	})
end

--// Export

return Key
