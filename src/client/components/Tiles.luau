--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages

--// Dependencies

local Fusion = require(Packages.Fusion)

local Constants = require("../config/Constants")
local TileRow = require("./TileRow")

--// Public

local New, Computed = Fusion.New, Fusion.Computed

local function Tiles(props: { guesses: any })
	local rows = {}

	for i = 1, Constants.NUM_GUESSES do
		rows[i] = TileRow({
			order = i,
			guess = Computed(function()
				return props.guesses:get()[i]
			end),
		})
	end

	return {
		New("UIListLayout")({
			FillDirection = "Vertical",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Center",
		}),
		rows,
	}
end

--// Export

return Tiles
