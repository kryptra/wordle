--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages

--// Dependencies

local Fusion = require(Packages.Fusion)

local Constants = require("../config/Constants")
local Key = require("./Key")

--// Public

local New, Computed, ForPairs, Children, cleanup =
	Fusion.New, Fusion.Computed, Fusion.ForPairs, Fusion.Children, Fusion.cleanup

local function Keyboard(props: { guesses: any, onTyped: (key: string) -> () })
	local comparedKeys = Computed(function()
		local comparisons = {}

		for _: number, char: string in Constants.LETTERS do
			comparisons[char] = "Unknown"
		end

		for _: number, guess: { text: string, comparedLetters: { [number]: string } } in props.guesses:get() do
			for index: number, comparedLetter in ipairs(guess.comparedLetters) do
				if comparedLetter ~= "Unknown" then
					local guessSub = guess.text:sub(index, index)
					local guessCompare = comparisons[guessSub]

					if
						comparedLetter == "Match"
						or (comparedLetter == "Partial" and guessCompare ~= "Match")
						or (comparedLetter == "Miss" and guessCompare ~= "Match" and guessCompare ~= "Partial")
					then
						comparisons[guessSub] = comparedLetter
					end
				end
			end
		end

		return comparisons
	end)

	return {
		New("UIListLayout")({
			FillDirection = "Vertical",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Bottom",
		}),
		New("UIPadding")({
			PaddingTop = Constants.KEYBOARD_KEY_HALF_PADDING,
			PaddingBottom = Constants.KEYBOARD_KEY_HALF_PADDING,
			PaddingLeft = Constants.KEYBOARD_KEY_HALF_PADDING,
			PaddingRight = Constants.KEYBOARD_KEY_HALF_PADDING,
		}),

		ForPairs(Constants.KEYBOARD_LAYOUT, function(rowIndex, rowKeyCodes)
			return rowIndex,
				New("Frame")({
					Name = "KeyRow",

					Size = UDim2.fromScale(1, 1 / #Constants.KEYBOARD_LAYOUT),
					LayoutOrder = rowIndex,
					BackgroundTransparency = 1,

					[Children] = {
						New("UIListLayout")({
							FillDirection = "Horizontal",
							HorizontalAlignment = "Center",
						}),

						ForPairs(rowKeyCodes, function(order: number, key: string)
							return order,
								Key({
									order = order,
									key = key,
									label = if key == "Return"
										then "Enter"
										elseif key == "Backspace" then "◀ Bksp"
										else key,
									large = key == "Return" or key == "Backspace",
									comparedKeys = Computed(function()
										return comparedKeys:get()[key] or "unknown"
									end),
									onTyped = props.onTyped,
								})
						end, cleanup),
					},
				})
		end, cleanup),
	}
end

--// Export

return Keyboard
