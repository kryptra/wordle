--// Private

local DICTIONARY_API = "https://api.dictionaryapi.dev/api/v2/entries/en/%s"
local WORD_API = "https://random-word-api.vercel.app/api?words=%d&length=%d"

--// Public

local HttpService = game:GetService("HttpService")

local function generate(amount: number, length: number): { [number]: string }
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = string.format(WORD_API, amount, length),
			Method = "GET",
		})
	end)

	if not success or success and not response.Success then
		return generate(amount, length)
	end

	local body = response.Body
	local data = HttpService:JSONDecode(body)

	return type(data) == "table" and data or generate(amount, length)
end

local function validate(guess: string): boolean
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = string.format(DICTIONARY_API, guess),
			Method = "GET",
		})
	end)

	if not success or success and not response.Success then
		return false
	end

	return true
end

--// Export

return table.freeze({
	generate = generate,
	validate = validate,
})
