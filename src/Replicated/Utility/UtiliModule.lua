--|| Services ||--
local RunService = game:GetService("RunService")
local UtiliModule = {}

function UtiliModule.GetDeepCopy(Table)
	local Copy = {}

	for Index, Value in pairs(Table) do
		local IndexType, ValueType = type(Index), type(Value)

		if IndexType == "table" and ValueType == "table" then
			Index, Value = UtiliModule.GetDeepCopy(Index), UtiliModule.GetDeepCopy(Value)
		elseif ValueType == "table" then
			Value = UtiliModule.GetDeepCopy(Value)
		elseif IndexType == "table" then
			Index = UtiliModule.GetDeepCopy(Index)
		end

		Copy[Index] = Value
	end

	return Copy
end 

function UtiliModule:FastWait(YieldTime, Yield)
	Yield = Yield or RunService.Stepped
	local StartTime = os.clock()
	while os.clock() - StartTime < YieldTime do
		Yield:Wait()
	end
end

return UtiliModule
