--Maintain Separation between game hotkeys and mine
--PenguinBindVars 
local loaded = false
local function pPrint(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

local penguinFrame = CreateFrame("Frame")



local function onEvent(self,event,...)
	if event == "ADDON_LOADED" then
		if not loaded then
			pPrint("I was loaded!")
		end
		loaded = true
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		pPrint("You changed talents!")
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
	end
end


SLASH_PENGUINBINDINGS1 = "/pb"
SlashCmdList["PENGUINBINDINGS"] = function(argString,editbox)
	local args = {}
	for x in argString:gmatch("%S+") do
		table.insert(args,x)
	end
	if args[1] == "set" then
		SetBindingSpell("Q","Penance")
	else
		pPrint(GetBindingAction("X"))
	end
end

penguinFrame:RegisterEvent("ADDON_LOADED")
penguinFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
penguinFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
penguinFrame:SetScript("OnEvent",onEvent)