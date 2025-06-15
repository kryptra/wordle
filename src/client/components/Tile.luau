--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages

--// Dependencies

local Fusion = require(Packages.Fusion)

local Constants = require("../config/Constants")
local Theme = require("../config/Theme")

--// Public

local New, Computed, Children, Value, Spring = Fusion.New, Fusion.Computed, Fusion.Children, Fusion.Value, Fusion.Spring

local function Tile(props: { order: number, letter: any, comparedLetter: any })
	local hasLetter = Computed(function()
		return props.letter:get() ~= ""
	end)

	local showingCompared = Computed(function()
		return props.comparedLetter:get() ~= "Unknown"
	end)

	local showingComparedDelayed = Value(showingCompared:get())
	local cachedLetter

	do
		local cached = ""
		cachedLetter = Computed(function()
			local letter = props.letter:get()
			if letter == "" then
				return cached
			else
				cached = letter
				return letter
			end
		end)
	end

	local backgroundColor = Spring(
		Computed(function()
			if not showingComparedDelayed:get() then
				return if hasLetter:get() then Theme.tileUnknown else Theme.tileMiss
			end

			local result = props.comparedLetter:get()
			return if result == "Match"
				then Theme.tileMatch
				elseif result == "Partial" then Theme.tilePartialMatch
				elseif result == "Miss" then Theme.tileMiss
				else Theme.tileUnknown
		end),
		20
	)

	return New("Frame")({
		Name = "TileContainer",
		Size = UDim2.fromScale(1 / Constants.WORD_LENGTH, 0.9),
		BackgroundColor3 = backgroundColor,
		LayoutOrder = props.order,
		ClipsDescendants = true,

		[Children] = {
			New("UICorner")({
				CornerRadius = UDim.new(0, 8),
			}),

			New("UIStroke")({
				Color = Color3.fromRGB(30, 30, 30),
				Thickness = 1.5,
				Transparency = 0.2,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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

			New("TextLabel")({
				Name = "TileLetter",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,

				Font = Enum.Font.GothamBold,
				Text = cachedLetter,
				TextScaled = true,
				TextColor3 = Theme.text,
				TextTransparency = Spring(
					Computed(function()
						return if hasLetter:get() then 0 else 1
					end),
					30
				),

				ZIndex = 10,

				[Children] = {
					New("UIScale")({
						Scale = Spring(
							Computed(function()
								return if hasLetter:get() then 1 else 0
							end),
							30
						),
					}),
				},
			}),
		},
	})
end

--// Export

return Tile
