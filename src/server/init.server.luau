--// Dependencies

local api = require(script.api)

--// Private

local AMOUNT = 1
local LENGTH = 5

local GENERATED_WORD = api.generate(AMOUNT, LENGTH)[1]

local function compare(guess: string): ComparedLetters
	local comparedLetters = table.create(LENGTH, "Miss")
	local used = table.create(LENGTH, false)

	for i = 1, LENGTH do
		local guessChar = guess:sub(i, i)
		local generatedChar = GENERATED_WORD:sub(i, i)

		if generatedChar == guessChar then
			comparedLetters[i] = "Match"
			used[i] = true
		end
	end

	for i = 1, LENGTH do
		if comparedLetters[i] ~= "Match" then
			local guessChar = guess:sub(i, i)

			for j = 1, LENGTH do
				if not used[j] then
					local generatedChar = GENERATED_WORD:sub(j, j)

					if generatedChar == guessChar then
						comparedLetters[i] = "Partial"
						used[j] = true
						break
					end
				end
			end
		end
	end

	return comparedLetters
end

--// Public

export type ComparedLetters = { [number]: "Match" | "Partial" | "Miss" }

local function onSubmit(_: Player, guess: string): (boolean, string | ComparedLetters)
	if type(guess) ~= "string" then
		return false, "Guess must be a string"
	end

	if #guess ~= LENGTH then
		return false, `Guess must be {LENGTH} letters`
	end

	guess = string.lower(guess)

	if not api.validate(guess) then
		return false, "Guess is not a valid word"
	end

	return true, compare(guess)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.remotes
local SubmitGuess = Remotes.SubmitGuess

SubmitGuess.OnServerInvoke = onSubmit
