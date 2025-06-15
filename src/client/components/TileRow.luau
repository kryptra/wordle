--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages

--// Dependencies

local Fusion = require(Packages.Fusion)

local Constants = require("../config/Constants")
local Tile = require("./Tile")

--// Public

local New, Computed, Children = Fusion.New, Fusion.Computed, Fusion.Children

local function TileRow(props: { order: number, guess: any })
	local columns = {}

	for i = 1, Constants.WORD_LENGTH do
		columns[i] = Tile({
			order = i,
			letter = Computed(function()
				return props.guess:get().text:sub(i, i)
			end),
			comparedLetter = Computed(function()
				return props.guess:get().comparedLetters[i]
			end),
		})
	end

	return New("Frame")({
		Name = "TileRow",

		Size = UDim2.fromScale(1, 1 / Constants.NUM_GUESSES),
		BackgroundTransparency = 1,

		[Children] = {
			New("UIAspectRatioConstraint")({
				AspectRatio = Constants.WORD_LENGTH,
			}),
			New("UIListLayout")({
				FillDirection = "Horizontal",
				Padding = UDim.new(0.025, 0),
			}),
			columns,
		},
	})
end

--// Export

return TileRow
