-- || Services || --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- ||  Directories || --
local SharedFolder = ReplicatedStorage.Shared
-- || Imports || --
local StateManager = require(SharedFolder.StateManager)

Players.PlayerAdded:Connect(function(LocalPlayer)
    LocalPlayer.CharacterAdded:Connect(function(Character)
        StateManager.Initiate(Character)
    end)
    LocalPlayer.CharacterRemoving:Connect(function(Character)
        StateManager:Remove(Character)
    end)
end)
