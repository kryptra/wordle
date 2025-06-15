--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages

--// Dependencies

local Fusion = require(Packages.Fusion)

local Keyboard = require("./Keyboard")
local Tiles = require("./Tiles")

--// Public

local New, Children = Fusion.New, Fusion.Children

local function Container(props: { guesses: any, onTyped: (key: string) -> () })
	return {
		New("Frame")({
			Name = "KeyboardContainer",

			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.new(1, 0, 0, 200),
			BackgroundTransparency = 1,

			[Children] = Keyboard({
				guesses = props.guesses,
				onTyped = props.onTyped,
			}),
		}),

		New("Frame")({
			Name = "TilesContainer",

			Position = UDim2.new(0.5, 0, 0, 36),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(1, 0, 1, -200 - 36),
			BackgroundTransparency = 1,

			[Children] = {
				New("UISizeConstraint")({
					MaxSize = Vector2.new(400, math.huge),
				}),

				Tiles({
					guesses = props.guesses,
				}),
			},
		}),
	}
end

--// Export

return Container
