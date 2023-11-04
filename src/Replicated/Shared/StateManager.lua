-- || Services || --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- || Directories || --
local UtilityFolder = ReplicatedStorage.Utility
-- || Imports || --
local Utilities = require(UtilityFolder.UtiliModule)
local StatePresets = require(script.Parent.StatePresets)
-- || Module || --
if RunService:IsClient() then
    local StateWrapper = {}

    function StateWrapper.Initiate(Character)
        StateWrapper[Character] = {
            InitiatedTime = os.clock(),
            Presets = Utilities.GetDeepCopy(StatePresets)
        }
        return StateWrapper[Character]
    end

    function StateWrapper:Remove(Character)
        StateWrapper[Character] = nil
    end

    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character

    local CurrentState = StateWrapper.Initiate(Character)

    LocalPlayer.CharacterAdded:Connect(function(Character)
        CurrentState = StateWrapper.Initiate(Character)
    end)

    LocalPlayer.CharacterRemoving:Connect(function(Character)
        StateWrapper:Remove(Character)
        CurrentState = nil
    end)


    return StateWrapper
elseif RunService:IsServer() then
    local BranchDictionary = {
		["NormalInteger"] = function(BranchTree, PathIndex)
			if os.clock() - BranchTree.StartTime >= BranchTree.Duration then
				return true
			else
				return false
			end
		end,

		["SpecialInteger"] = function(BranchTree, PathIndex)
			if os.clock() - BranchTree.StartTime <= BranchTree.Duration then
				return true
			else
				return false
			end
		end,

		["Boolean"] = function(BranchTree,PathIndex)
			if BranchTree["Is"..PathIndex] then
				return BranchTree["Is"..PathIndex]
			end
		end
	}

    local StateWrapper = {}
	
	function StateWrapper.Initiate(Character)
		StateWrapper[Character] = {
			InitiatedTime = os.clock(),
			StateData = Utilities.GetDeepCopy(StatePresets)
		}
		return StateWrapper[Character]
	end

	function StateWrapper:Remove(Character)
		StateWrapper[Character] = nil
	end
	
	function StateWrapper:ChangeState(Character, Path, Value, Data)
		local BranchTree = StateWrapper:ReturnData(Character, Path)
		if type(BranchTree) == "table" then
			if BranchTree.Type == "NormalInteger" or BranchTree.Type == "SpecialInteger" then

				BranchTree.StartTime = os.clock()
				BranchTree.Duration = Value

				if Data then
					for State, Value in pairs(BranchTree) do
						if Data[State] then
							BranchTree[State] = Data[State]
						end
					end
				end

			else
				BranchTree.StartTime = os.clock()
				BranchTree.Duration = 0 

				BranchTree["Is"..Path] = Value

				if Data then
					for State,Value in pairs(BranchTree) do
						if Data[State] then
							BranchTree[State] = Data[State]

						end
					end
				end
			end

			local ValidPlayer = Players:GetPlayerFromCharacter(Character)	 
		end		
	end
	
	function StateWrapper:Peek(Character, Path)
		local BranchTree = StateWrapper:ReturnData(Character, Path)

		return type(BranchTree) == "table" and BranchDictionary[BranchTree.Type](BranchTree, Path) or nil
	end

	function StateWrapper:ReturnData(Character, Path)
		if not Character then warn(Character.."has left game or disconnected") return end

		return StateWrapper[Character] and StateWrapper[Character].StateData[Path] or nil
	end

	function StateWrapper:AppendState(Character, StateData)
		local StateType = StateData.Type or warn"No StateData Type"
		local StateName = StateData.Name  or warn"No StateName"

		local StateToAppend = {
			StartTime = os.clock(),
			Duration = 0,

			["Is"..StateData.Name] = false,

			Type = StateType
		}

		StateWrapper[Character].StateData[StateWrapper] = StateToAppend
	end
	
	return StateWrapper
end
