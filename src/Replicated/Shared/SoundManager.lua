--|| Services ||--
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
--|| Imports ||--
local Properties = require(ReplicatedStorage.Misc.Functions.Properties)
local Client = require(ReplicatedStorage.Misc.Functions.Client)
local Table = require(ReplicatedStorage.Misc.Functions.Table)
local Create = require(ReplicatedStorage.Misc.Functions.Create)
--|| Variables ||--
local LocalPlayer = Players.LocalPlayer
local SoundWrapper = {
	CachedSounds = {},
	QueuedList = {},	
}
local SoundRemote -- local SoundRemote = YOURREMOTELOCATION
local Children = ReplicatedStorage.Sounds:GetDescendants()

for _,Sound in ipairs(Children) do
	if Sound:IsA("Sound") then
		SoundWrapper.CachedSounds[Sound.Name] = Sound
	end
end

local PlaySoundDictionary = {
	["Client"] = function(SoundName, SoundProperties, RemoteData)
		local Sound = Client(SoundWrapper.CachedSounds, SoundName, SoundProperties, RemoteData)
		return Sound
	end,

	["Table"] = function(SoundName, SoundProperties, RemoteData)
		local TableSound = Table(SoundWrapper.CachedSounds, SoundName, SoundProperties, RemoteData)
		return TableSound
	end,

	["CreateSound"] = function(SoundName, SoundProperties, RemoteData)
		local Sound = Create(SoundWrapper.CachedSounds, SoundName, SoundProperties, RemoteData)
		return Sound
	end,

	["Server"] = function(SoundName, SoundProperties, RemoteData)
		local Player = RemoteData.Player

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RenderPlayers = GetNearPlayers(Character, RemoteData.Distance)

		for _, Player in ipairs(RenderPlayers) do
			SoundRemote:FireClient(Player, SoundName, SoundProperties, "Play") 
		end		
	end,
}

local StopSoundDictionary = {
	["Client"] = function(SoundName, SoundProperties, Side, RemoteData)
		if not SoundWrapper.CachedSounds[SoundName] then warn(SoundName.." not found") return end

		for _,ObjectType in ipairs(SoundProperties.Parent:GetDescendants()) do
			if ObjectType:IsA("Sound") and ObjectType.Name == SoundName then
				local Sound = ObjectType
				Sound:Stop(); Sound:Destroy()
			end
		end	
	end,

	["Server"] = function(SoundName, SoundProperties, Side, RemoteData)
		local Player = RemoteData.Player

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RenderPlayers = GetNearPlayers(Character,RemoteData.Distance)

		for _,Player in ipairs(RenderPlayers) do
			SoundRemote:FireClient(Player, SoundName, SoundProperties, "Stop") 
		end	
	end,

	["RemoveCreatedSound"] = function(SoundName, SoundProperties, Side, RemoteData)
		if not SoundWrapper.CachedSounds[SoundName] then warn(SoundName.." not found") return end

		if SoundWrapper.CachedSounds[SoundName] then
			SoundWrapper.CachedSounds[SoundName]:Stop(); SoundWrapper.CachedSounds[SoundWrapper]:Destroy()
			SoundWrapper.CachedSounds[SoundName] = nil
		end
	end,	
}

function GetNearPlayers(Character,Radius)
	local Table = {}
	local PlayerList = Players:GetPlayers()

	local HumanoidRootPart = Character.PrimaryPart

	for _,Player in ipairs(PlayerList) do
		local EnemyCharacter = Player.Character;
		local EnemyRootPart = EnemyCharacter.PrimaryPart;

		if (EnemyRootPart.Position - HumanoidRootPart.Position).Magnitude <= Radius then
			Table[#Table + 1] = Player
		end
	end
	return Table
end

function SoundWrapper:AddSound(SoundName, SoundProperties, Side, RemoteData)
	local SoundInstance = PlaySoundDictionary[Side](SoundName, SoundProperties, RemoteData)
	return SoundInstance
end

function SoundWrapper:StopSound(SoundName, SoundProperties, Side, RemoteData)
	StopSoundDictionary[Side](SoundName, SoundProperties, RemoteData)
end

function SoundWrapper:AddQueue(SongTheme)
	SongTheme = (typeof(SongTheme) == "string" and SongTheme) or warn(Properties.INVALID_SOUND_ERROR)

	for _,QueuedStyle in ipairs(SoundWrapper.QueuedList) do
		if QueuedStyle == SongTheme then
			return
		end
	end
	SoundWrapper.QueuedList[#SoundWrapper.QueuedList + 1] = SongTheme
end

function SoundWrapper:RemoveQueue(SongTheme)
	SongTheme = (typeof(SongTheme) == "string" and SongTheme) or warn(Properties.INVALID_SOUND_ERROR)

	for _,QueuedStyle in ipairs(SoundWrapper.QueuedList) do
		if QueuedStyle == SongTheme then
			SoundWrapper.QueuedList[QueuedStyle] = nil
		end
	end
end

spawn(function()
	ContentProvider:PreloadAsync(Children)
	warn("[Client]: Preloaded Sound Assets")
end)

if RunService:IsClient() then
	local SoundSettings = {
		["Play"] = function(SoundName, Data)
			SoundWrapper:AddSound(SoundName, Data, "Client")
		end;
		["Stop"] = function(SoundName, Data)
			SoundWrapper:StopSound(SoundName, Data, "Client")
		end;
	}

	SoundRemote.OnClientEvent:Connect(function(SoundName,Data,Task)
		SoundSettings[Task](SoundName,Data)
	end)
end

return SoundWrapper
