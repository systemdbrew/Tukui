local T, C, L = unpack((select(2, ...)))

local Loading = CreateFrame("Frame")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

function Loading:StoreDefaults()
	T.Defaults = {}

	for group, options in pairs(C) do
		if (not T.Defaults[group]) then
			T.Defaults[group] = {}
		end

		for option, value in pairs(options) do
			T.Defaults[group][option] = value

			if (type(C[group][option]) == "table") then
				if C[group][option].Options then
					T.Defaults[group][option] = value.Value
				else
					T.Defaults[group][option] = value
				end
			else
				T.Defaults[group][option] = value
			end
		end
	end
end

function Loading:LoadCustomSettings()
	local Settings = TukuiDatabase.Settings[T.MyRealm][T.MyName]

	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						Settings[group][option] = nil
					else
						Count = Count + 1

						if (type(C[group][option]) == "table") then
							if C[group][option].Options then
								C[group][option].Value = value
							else
								C[group][option] = value
							end
						else
							C[group][option] = value
						end
					end
				end
			end

			if (Count == 0) then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end

function Loading:LoadProfiles()
	local Profiles = C.General.Profiles
	local Menu = Profiles.Options
	local Data = TukuiDatabase.Variables
	local GUISettings = TukuiDatabase.Settings
	local Nickname = T.MyName
	local Server = T.MyRealm

	if not GUISettings then
		return
	end

	for Index, Table in pairs(GUISettings) do
		local Server = Index

		for Nickname, Settings in pairs(Table) do
			local ProfileName = Server.."-"..Nickname
			local MyProfileName = T.MyRealm.."-"..T.MyName

			if MyProfileName ~= ProfileName then
				Menu[ProfileName] = ProfileName
			end
		end
	end
end

function Loading:Enable()
	local Toolkit = T.Toolkit

	self:StoreDefaults()
	self:LoadProfiles()
	self:LoadCustomSettings()

	Toolkit.Settings.BackdropColor = C.General.BackdropColor
	Toolkit.Settings.BorderColor = C.General.ClassColorBorder and T.Colors.class[T.MyClass] or C.General.BorderColor
	Toolkit.Settings.UIScale = C.General.UIScale

	if C.General.HideShadows then
		Toolkit.Settings.ShadowTexture = ""
	end
end

function Loading:MergeDatabase()
	if TukuiData then
		TukuiDatabase["Variables"] = TukuiData
		TukuiData = nil
	end

	if TukuiSettingsPerCharacter then
		TukuiDatabase["Settings"] = TukuiSettingsPerCharacter
		TukuiSettingsPerCharacter = nil
	end

	if TukuiGold then
		TukuiDatabase["Gold"] = TukuiGold
		TukuiGold = nil
	end

	if TukuiChatHistory then
		TukuiDatabase["ChatHistory"] = TukuiChatHistory
		TukuiChatHistory = nil
	end
end

function Loading:VerifyDatabase()
	if not TukuiDatabase then TukuiDatabase = {} end
	if not TukuiDatabase.Variables then TukuiDatabase.Variables = {} end
	if not TukuiDatabase.Variables[T.MyRealm] then TukuiDatabase.Variables[T.MyRealm] = {} end
	if not TukuiDatabase.Variables[T.MyRealm][T.MyName] then TukuiDatabase.Variables[T.MyRealm][T.MyName] = {} end
	if not TukuiDatabase.Variables[T.MyRealm][T.MyName].Move then TukuiDatabase.Variables[T.MyRealm][T.MyName].Move = {} end
	if not TukuiDatabase.Variables[T.MyRealm][T.MyName].ActionBars then TukuiDatabase.Variables[T.MyRealm][T.MyName].ActionBars = {} end
	if not TukuiDatabase.Variables[T.MyRealm][T.MyName].Tracking then
		TukuiDatabase.Variables[T.MyRealm][T.MyName].Tracking = { PvP = {}, PvE = {} }
	end

	if (not TukuiDatabase.Variables[T.MyRealm][T.MyName].DataTexts) then
		T.DataTexts:AddDefaults()
	end

	if not TukuiDatabase.Variables[T.MyRealm][T.MyName].Chat then
		TukuiDatabase.Variables[T.MyRealm][T.MyName].Chat = { Positions = T.Chat.Positions }
	elseif not TukuiDatabase.Variables[T.MyRealm][T.MyName].Chat.Positions then
		TukuiDatabase.Variables[T.MyRealm][T.MyName].Chat = { Positions = T.Chat.Positions }
		T.Print("|CFFFF0000WARNING:|r Your chat position have been reset to default")
	end

	if not TukuiDatabase.Variables[T.MyRealm][T.MyName].Misc then TukuiDatabase.Variables[T.MyRealm][T.MyName].Misc = {} end
	if not TukuiDatabase.Variables[T.MyRealm][T.MyName].Installation then TukuiDatabase.Variables[T.MyRealm][T.MyName].Installation = {} end
	if not TukuiDatabase.Settings then TukuiDatabase.Settings = {} end
	if not TukuiDatabase.Settings[T.MyRealm] then TukuiDatabase.Settings[T.MyRealm] = {} end
	if not TukuiDatabase.Settings[T.MyRealm][T.MyName] then TukuiDatabase.Settings[T.MyRealm][T.MyName] = {} end
	if not TukuiDatabase.ChatHistory then TukuiDatabase.ChatHistory = {} end
	if not TukuiDatabase.Gold then TukuiDatabase.Gold = {} end
end

function Loading:RemoveEditFrame(frame)
	if not T.Retail then return end

	for i, f in pairs(EditModeManagerFrame.registeredSystemFrames) do
		local Name = f:GetName()
		if frame == Name then
			table.remove(EditModeManagerFrame.registeredSystemFrames, i)
		end
	end
end

function Loading:OnEvent(event)
	self:VerifyDatabase()
	self:MergeDatabase()

	if (event == "PLAYER_LOGIN") then
		T["Inventory"]:Enable()
		T["Auras"]:Enable()
		T["Maps"]["Minimap"]:Enable()
		T["Maps"]["Zonemap"]:Enable()
		T["Maps"]["Worldmap"]:Enable()
		T["DataTexts"]:Enable()
		T["Chat"]:Enable()

		if not T.Retail then
			T["ActionBars"]:Enable()
		end

		T["Cooldowns"]:Enable()
		T["Miscellaneous"]:Enable()
		T["UnitFrames"]:Enable()
		T["Tooltips"]:Enable()

		if T.Retail then
			T["PetBattles"]:Enable()
		end

		SlashCmdList["STOPWATCH"] = Stopwatch_Toggle
	elseif (event == "PLAYER_ENTERING_WORLD") then
		-- WoW 12.1 replaced the legacy ObjectiveTrackerFrame implementation.
		-- Keep Blizzard's current objective tracker untouched until Tukui's
		-- tracker skin is rewritten for the modern Retail tracker APIs.
		local ObjectiveTracker = T["Miscellaneous"] and T["Miscellaneous"]["ObjectiveTracker"]
		if ObjectiveTracker and ObjectiveTracker.Enable then
			ObjectiveTracker:Enable()
		end
	elseif (event == "VARIABLES_LOADED") then
		local Locale = GetLocale()

		T["Loading"]:Enable()

		if (Locale ~= "koKR" and Locale and "zhTW" and Locale ~= "zhCN" and Locale ~= "ruRU") then
			C.Medias.Font = C.General.GlobalFont.Value
			TukuiFont:SetFont(C.Medias.Font, 12, "")
			TukuiFontOutline:SetFont(C.Medias.Font, 12, "THINOUTLINE")
		end

		if (Locale ~= "koKR" and Locale ~= "zhTW" and Locale ~= "zhCN") then
			T["Fonts"]:Enable()
		end

		T["GUI"]:Enable()
		T["Profiles"]:Enable()
		T["Help"]:Enable()
	elseif (event == "SETTINGS_LOADED") then
		T["ActionBars"]:Enable()
	end

	if T.Retail and EditModeManagerFrame then
		EditModeManagerFrame:UnregisterAllEvents()
		EditModeManagerFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
	end
end

Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("VARIABLES_LOADED")
Loading:RegisterEvent("PLAYER_ENTERING_WORLD")

if T.Retail then
	Loading:RegisterEvent("SETTINGS_LOADED")
end

Loading:SetScript("OnEvent", Loading.OnEvent)
T["Loading"] = Loading
