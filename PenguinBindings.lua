--PenguinBindVars (name of my saved variable)
local bindMode,currentProfile = false,1
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
		PenguinBindVars[currentProfile].bindsSpell[key] = spellName
		SetBinding(key)
		return SetBindingSpell(key,spellName)
	end,
	["item"] = function(key,itemName)
		PenguinBindVars[currentProfile].bindsItem[key] = itemName
		SetBinding(key)
		return SetBindingItem(key,itemName)
	end,
	["macro"] = function(key,macroId)
		PenguinBindVars[currentProfile].bindsMacro[key] = macroId
		SetBinding(key)
		return SetBindingMacro(key,macroId)
	end
}
-- Clears a binding
local function clearBind(key)
	if PenguinBindVars[currentProfile].bindsMacro[key] then PenguinBindVars[currentProfile].bindsMacro[key] = nil end
	if PenguinBindVars[currentProfile].bindsSpell[key] then PenguinBindVars[currentProfile].bindsSpell[key] = nil end
	if PenguinBindVars[currentProfile].bindsItem[key] then PenguinBindVars[currentProfile].bindsItem[key] = nil end
	SetBinding(key)
end
local function clearSpellBinding()
	for k,v in pairs(PenguinBindVars[currentProfile].bindsSpell) do
		SetBinding(k)
	end
end
local function clearItemBinding()
	for k,v in pairs(PenguinBindVars[currentProfile].bindsItem) do
		SetBinding(k)
	end
end
local function clearMacroBinding()
	for k,v in pairs(PenguinBindVars[currentProfile].bindsMacro) do
		SetBinding(k)
	end
end
local function clearAllBindings()
	clearSpellBinding()
	clearItemBinding()
	clearMacroBinding()
end
-- Switches bindings on keys in the profile
local function profileBind()
	for k,v in pairs(PenguinBindVars[currentProfile].bindsSpell) do
		SetBindingSpell(k,v)
	end
	for k,v in pairs(PenguinBindVars[currentProfile].bindsItem) do
		SetBindingItem(k,v)
	end
	for k,v in pairs(PenguinBindVars[currentProfile].bindsMacro) do
		SetBindingMacro(k,v)
	end
end

-- ALL THE EVENTS!
local function onEvent(self,event,...)
	if event == "ADDON_LOADED" then --on load
		local whichAddon = ...
		if whichAddon == "PenguinBindings" then
			if PenguinBindVars == nil then
				pPrint("First run!")
				PenguinBindVars = {
					profiles = {
						[1] = "default",
					},
					[1] = {
						bindsSpell = {},
						bindsItem = {},
						bindsMacro = {}
					},
					cP = 1
					
				}
			else
				pPrint(PenguinBindVars.cP)
				currentProfile = PenguinBindVars.cP
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
			StaticPopupDialogs["PENGUINBIND_CLEARCHECK"] = {
				text = "Do you really want to clear bindings on %s?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function(self,clearString)
					if self.clearString == "all" then
						clearAllBindings()
						PenguinBindVars[currentProfile] = nil
					elseif self.clearString == "spells" then
						clearSpellBinding()
						PenguinBindVars[currentProfile].bindsSpell = nil
					elseif self.clearString == "macros" then
						clearMacroBinding()
						PenguinBindVars[currentProfile].bindMacro = nil
					elseif self.clearString == "items" then
						clearItemBinding()
						PenguinBindVars[currentProfile].bindItem = nil
					end
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
		elseif whichAddon == "Blizzard_MacroUI" then
			--Hook into macro blizz addon
			MacroFrame:HookScript("OnShow",macroOpening)
			MacroFrameSelectedMacroButton:HookScript("OnEnter",function(self)
				local mName,mIconTexture,mBody,mIsLocal = GetMacroInfo(MacroFrame.selectedMacro)
				local boundKey = GetBindingKey("MACRO "..mName)
				if boundKey then
					pPrint(mName.." is bound to "..boundKey)
				end
			end)
		end
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then --on spec change
		pPrint("You changed talents!")
	elseif event == "UPDATE_SHAPESHIFT_FORM" then --TRANSFORM!
	elseif event == "PLAYER_LOGOUT" then -- Loging out, save things!
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

local function itemSelected(tooltip)
	local iName,iLink = tooltip:GetItem()
	if bindMode then
		local mFocus = GetMouseFocus()
		local script1,script2 = mFocus:GetScript("OnMouseWheel"),mFocus:GetScript("OnLeave")
		mFocus:SetScript("OnMouseWheel",function(self,delta)
			if delta == 1 then
				local dialog = StaticPopup_Show("PENGUINBIND_SETBIND")
				if dialog then
					dialog.bindValue = iName
					dialog.bindType = "item"
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
				local bKey = GetBindingKey("ITEM "..iName)
				if bKey then
					local dialog = StaticPopup_Show("PENGUINBIND_CLEARBIND",iName)
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
	local boundKey = GetBindingKey("ITEM "..iName)
	if boundKey then
		tooltip:AddLine("Bound to: "..boundKey)
	end
	
end

function macroOpening(mWindow)
	if bindMode then
		pPrint("Macro frame opened, stealing on mouse down event")
		local script1,script2 = MacroFrameSelectedMacroButton:GetScript("OnMouseWheel"),mWindow:GetScript("OnHide")
		MacroFrameSelectedMacroButton:SetScript("OnMouseWheel",function(self,delta)
			local mName,mIconTexture,mBody,mIsLocal = GetMacroInfo(MacroFrame.selectedMacro)
			if delta == 1 then
				local dialog = StaticPopup_Show("PENGUINBIND_SETBIND")
				if dialog then
					dialog.bindValue = mName
					dialog.bindType = "macro"
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
				local bKey = GetBindingKey("MACRO "..mName)
				if bKey then
					local dialog = StaticPopup_Show("PENGUINBIND_CLEARBIND",mName)
					if dialog then
						dialog.bindKey = bKey
					end
				end
			end
		end)
		mWindow:SetScript("OnHide",function(self)
			MacroFrameSelectedMacroButton:SetScript("OnMouseWheel",script1)
			self:SetScript("OnHide",script2)
		end)
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
		SaveBindings(tonumber(args[2] or 2))
	elseif args[1] == "profile" then
		if args[2] == "create" then
			table.insert(PenguinBindVars.profiles,args[3])
			table.insert(PenguinBindVars,{
						bindsSpell = {},
						bindsItem = {},
						bindsMacro = {}})
			pPrint("Profile created:"..args[3])
		elseif args[2] == "list" then
			pPrint("--------------PenguinBindings Profiles-----------------")
			for k,v in pairs(PenguinBindVars.profiles) do
				print(k.."."..v)
			end
		elseif args[2] == "delete" then
			if PenguinBindVars.profiles[tonumber(args[3])] then
				table.remove(PenguinBindVars.profiles,tonumber(args[3]))
				table.remove(PenguinBindVars,tonumber(args[3]))
				pPrint("Profile Deleted")
			else
				pPrint("Profile doesn't exist")
			end
		elseif args[2] == "select" then
			if PenguinBindVars.profiles[tonumber(args[3])] then
				pPrint("Profile changed")
				clearAllBindings()
				currentProfile = tonumber(args[3])
				PenguinBindVars.cP = tonumber(args[3])
				profileBind()
				SaveBindings(2)
			else
				pPrint("Profile doesn't exist")
			end
		elseif args[2] == nil then
			pPrint(currentProfile.."."..PenguinBindVars.profiles[currentProfile])
		end
	elseif args[1] == "clear" then
		if args[2] == "all" or args[2] == "spells" or args[2] == "macros" or args[2] == "items" then
			local dialog = StaticPopup_Show("PENGUINBINDINGS_CLEARCHECK")
			if dialog then
				dialog.clearString = args[2]
				pPrint("CLEARED!")
			end	
			
		end
	end
end

penguinFrame:RegisterEvent("ADDON_LOADED") --The addon was loaded
penguinFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")-- You changed specs
penguinFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- YOU TRANSFORMED!
penguinFrame:RegisterEvent("PLAYER_LOGOUT")
penguinFrame:SetScript("OnEvent",onEvent) --A thing happened!
GameTooltip:HookScript("OnTooltipSetSpell", spellSelected) --Tooltip has spell in it!
GameTooltip:HookScript("OnTooltipSetItem",itemSelected)
