--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.packages
local Remotes = ReplicatedStorage.remotes

local SubmitGuess = Remotes.SubmitGuess
local RequestWord = Remotes.RequestWord

--// Dependencies

local Fusion = require(Packages.Fusion)

local SoundController = require("../controllers/SoundController")
local Theme = require("../config/Theme")
local Constants = require("../config/Constants")

local Container = require("./Container")

--// Public

local New, Value, Children, Computed, Spring = Fusion.New, Fusion.Value, Fusion.Children, Fusion.Computed, Fusion.Spring

local function Background()
	local currentGuess = 0
	local newGuesses = table.create(Constants.NUM_GUESSES)

	local guesses = Value()
	local word = Value("")

	for i = 1, Constants.NUM_GUESSES do
		newGuesses[i] = { text = "", comparedLetters = table.create(Constants.WORD_LENGTH, "unknown") }
	end

	guesses:set(newGuesses)
	currentGuess = 1

	local showRevealedWord = Computed(function()
		return word:get() ~= ""
	end)

	local revealedText = Computed(function()
		local current = word:get()
		return if current ~= "" then "The word was: " .. current else ""
	end)

	local function isCorrect(comparedLetters: { [number]: string }): boolean
		for _: number, value: string in comparedLetters do
			if value ~= "Match" then
				return false
			end
		end

		return true
	end

	local function revealWord()
		local result: string? = RequestWord:InvokeServer()

		if result then
			word:set(result)
		end
	end

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
				SoundController.play("Enter")

				if currentGuess == Constants.NUM_GUESSES or isCorrect(result) then
					revealWord()
				else
					currentGuess += 1
				end
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

					New("TextLabel")({
						Name = "RevealedWord",

						Visible = showRevealedWord,
						Text = revealedText,

						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(0.6, 0.05),

						BackgroundTransparency = 1,
						TextTransparency = Spring(
							Computed(function()
								return if showRevealedWord:get() then 0 else 1
							end),
							20
						),

						Font = Enum.Font.GothamBold,
						TextScaled = true,
						TextColor3 = Theme.text,

						ZIndex = 5,

						[Children] = {
							New("UIStroke")({
								Color = Color3.fromRGB(0, 0, 0),
								Transparency = 0.7,
								Thickness = 1,
							}),
							New("UITextSizeConstraint")({
								MaxTextSize = 28,
								MinTextSize = 10,
							}),
						},
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
