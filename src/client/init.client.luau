--// Variables

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.packages

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

--// Dependencies

local Fusion = require(Packages.Fusion)

local Background = require("@self/components/Background")

--// Public

PlayerGui.ScreenOrientation = "Portrait"

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
PlayerGui:GetPropertyChangedSignal("ScreenOrientation"):Connect(function()
	PlayerGui.ScreenOrientation = "Portrait"
end)

local New, Children = Fusion.New, Fusion.Children

New("ScreenGui")({
	Parent = Player.PlayerGui,

	Name = "WordleApp",
	IgnoreGuiInset = true,

	[Children] = Background(),
})
