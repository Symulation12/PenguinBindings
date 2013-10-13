--PenguinBindVars (name of my saved variable)
local loaded = false
local bindMode = false
-- Chat frame print function
local function pPrint(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

local penguinFrame = CreateFrame("Frame")
-- Checks if key is bound to spell
local function checkBind(key)
	return GetBindingAction(key,true)
end
-- Creating a binding for a spell and registers it with the mod
local createBinding = {
	["spell"] = function(key,spellName)
		PenguinBindVars.bindsSpell[key] = spellName
		SetBinding(key)
		return SetBindingSpell(key,spellName)
	end,
	["item"] = function(key,itemName)
		PenguinBindVars.bindsItem[key] = itemName
		SetBinding(key)
		return SetBindingItem(key,itemName)
	end,
	["macro"] = function(key,macroId)
		PenguinBindVars.bindsMacro[key] = macroId
		SetBinding(key)
		return SetBindingMacro(key,macroId)
	end
}
-- Clears a binding
local function clearBind(key)
	SetBinding(key)
end

-- ALL THE EVENTS!
local function onEvent(self,event,...)
	if event == "ADDON_LOADED" then --on load
		if not loaded then
			if not PenguinBindVars then
				PenguinBindVars = {
					bindsSpell = {},
					bindsItem = {},
					bindsMacro = {}
				}
			end
			StaticPopupDialogs["PENGUINBIND_ENABLEBINDMODE"] = {
				text = "Enable Bind Mode?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function()
					bindMode = true;
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopupDialogs["PENGUINBIND_DISABLEBINDMODE"] = {
				text = "Disable Bind Mode?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function()
					bindMode = false;
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopupDialogs["PENGUINBIND_BINDKEY"] = {
				text = "Do you want to bind %s to %s?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function(self,bindType,bindKey,bindValue)
					createBinding[self.bindType](self.bindKey,self.bindValue)
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopupDialogs["PENGUINBIND_BINDOVERRIDE"] = {
				text = "%s is already bound to %s, do you want to override binding?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function(self,bindType,bindKey,bindValue)
					createBinding[self.bindType](self.bindKey,self.bindValue)
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopupDialogs["PENGUINBIND_CLEARBIND"] = {
				text = "Clear binding on %s?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function(self,bindKey)
					clearBind(self.bindKey)
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopupDialogs["PENGUINBIND_SETBIND"] = {
				text = "Click button when binding is right",
				button1 = "Looks Good",
				OnAccept = function(self,bindValue,bindType)
					local bStr = checkBind(self.button1:GetText())
					local dialog = nil
					if bStr == "" then
						dialog = StaticPopup_Show("PENGUINBIND_BINDKEY",self.bindValue,self.button1:GetText())
					else
						dialog = StaticPopup_Show("PENGUINBIND_BINDOVERRIDE",self.button1:GetText(),bStr)
					end
					if dialog then
						dialog.bindType = self.bindType
						dialog.bindKey = self.button1:GetText()
						dialog.bindValue = self.bindValue
					end
					
						
					
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			--Load bindings
			for k,v in pairs(PenguinBindVars.bindsSpell) do
				SetBindingSpell(k,v)
			end
		end
		loaded = true
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then --on spec change
		pPrint("You changed talents!")
	elseif event == "UPDATE_SHAPESHIFT_FORM" then --TRANSFORM!
	elseif event == "PLAYER_LOGOUT" then
		SaveBindings(2)
	end
end

-- Handler for spell info in tooltip
local function spellSelected(tooltip)
	local sName,sRank,sID = tooltip:GetSpell()
	if bindMode then
		local mFocus = GetMouseFocus()
		local script1,script2 = mFocus:GetScript("OnMouseWheel"),mFocus:GetScript("OnLeave")
		mFocus:SetScript("OnMouseWheel",function(self,delta)
			if delta == 1 then
				local dialog = StaticPopup_Show("PENGUINBIND_SETBIND")
				if dialog then
					dialog.bindValue = sName
					dialog.bindType = "spell"
					local script = dialog.button1:GetScript("OnMouseUp") -- dialog.button3:SetScript("OnKeyDown",script)
					dialog.button1:SetScript("OnKeyDown",function(self,button)
						if string.find(button,"SHIFT") or string.find(button,"CTRL") or string.find(button,"ALT") then return end
						if IsShiftKeyDown() then
							button = "SHIFT-"..button
						end
						if IsControlKeyDown() then
							button = "CTRL-"..button
						end
						if IsAltKeyDown() then
							button ="ALT-"..button
						end
						self:SetText(button)
					end)
					
				end
			else
				local bKey = GetBindingKey("SPELL "..sName)
				if bKey then
					local dialog = StaticPopup_Show("PENGUINBIND_CLEARBIND",sName)
					if dialog then
						dialog.bindKey = bKey
					end
				end
			end
		end)
		mFocus:SetScript("OnLeave",function(self,motion)
			mFocus:SetScript("OnMouseWheel",script1)
			tooltip:Hide()
			mFocus:SetScript("OnLeave",script2)
		end)
	end
	local boundKey = GetBindingKey("SPELL "..sName)
	if boundKey then
		tooltip:AddLine("Bound to: "..boundKey)
	end
end

-- Slash Command
SLASH_PENGUINBINDINGS1,SLASH_PENGUINBINDINGS2 = "/pb","/penguinbindings"
SlashCmdList["PENGUINBINDINGS"] = function(argString,editbox)
	local args = {}
	for x in argString:gmatch("%S+") do
		table.insert(args,x)
	end
	if args[1] == "bind" then
		if not bindMode then
			if not StaticPopup_Show("PENGUINBIND_ENABLEBINDMODE") then pPrint("It didn't work :(") end
		else
			if not StaticPopup_Show("PENGUINBIND_DISABLEBINDMODE") then pPrint("It didn't work :(") end
		end
	elseif args[1] == "save" then
		SaveBindings(tonumber(args[2]))
	end
	
end

penguinFrame:RegisterEvent("ADDON_LOADED") --The addon was loaded
penguinFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")-- You changed specs
penguinFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- YOU TRANSFORMED!
penguinFrame:RegisterEvent("PLAYER_LOGOUT")
penguinFrame:SetScript("OnEvent",onEvent) --A thing happened!
GameTooltip:HookScript("OnTooltipSetSpell", spellSelected) --Tooltip has spell in it!