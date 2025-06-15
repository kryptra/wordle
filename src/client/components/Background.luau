--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages
local Remotes = ReplicatedStorage.remotes

local SubmitGuess: RemoteFunction = Remotes.SubmitGuess

--// Dependencies

local Fusion = require(Packages.Fusion)

local SoundController = require("../controllers/SoundController")
local Theme = require("../config/Theme")
local Constants = require("../config/Constants")

local Container = require("./Container")

--// Public

local Value = Fusion.Value
local New, Children = Fusion.New, Fusion.Children

local function Background()
	local currentGuess = 0
	local newGuesses = table.create(Constants.NUM_GUESSES)
	local guesses = Value()

	for i = 1, Constants.NUM_GUESSES do
		newGuesses[i] = { text = "", comparedLetters = table.create(Constants.WORD_LENGTH, "unknown") }
	end

	guesses:set(newGuesses)
	currentGuess = 1

	local function onTyped(key: string)
		if currentGuess > Constants.NUM_GUESSES then
			SoundController.play("NoType")
			return
		end

		local allGuesses = guesses:get()
		local thisGuess = allGuesses[currentGuess]

		if key == "Backspace" then
			if #thisGuess.text > 0 then
				thisGuess.text = thisGuess.text:sub(1, -2)
				SoundController.play("Backspace")
			else
				SoundController.play("NoType")
				return
			end
		elseif key == "Return" then
			local success, result = SubmitGuess:InvokeServer(thisGuess.text)
			if success then
				thisGuess.comparedLetters = result
				currentGuess += 1
				SoundController.play("Enter")
			else
				warn(result)
				SoundController.play("NoType")
			end
		else
			if #thisGuess.text < Constants.WORD_LENGTH then
				thisGuess.text ..= key
				SoundController.play("Key")
			else
				SoundController.play("NoType")
				return
			end
		end

		guesses:set(allGuesses)
	end

	return New("Frame")({
		Name = "Background",

		BackgroundColor3 = Theme.background,
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			New("Frame")({
				Name = "AspectRatio",

				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				[Children] = {
					New("UISizeConstraint")({
						MaxSize = Vector2.new(500, math.huge),
					}),

					Container({
						guesses = guesses,
						onTyped = onTyped,
					}),
				},
			}),
		},
	})
end

--// Export

return Background
