----------------------------------------------------------------
-- Initiation of Tukui engine
----------------------------------------------------------------

-- [[ Build the engine ]] --
local AddOn, Engine = ...
local Resolution = select(1, GetPhysicalScreenSize()).."x"..select(2, GetPhysicalScreenSize())
local Windowed = Display_DisplayModeDropDown and Display_DisplayModeDropDown:windowedmode()
local Fullscreen = Display_DisplayModeDropDown and Display_DisplayModeDropDown:fullscreenmode()
local Toc = select(4, GetBuildInfo())
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
	error("This Tukui fork supports World of Warcraft Retail only.")
end

-- Retail 12.1 removed the old global action-button overlay glow entry points.
-- Some legacy Tukui code still hooks them. Provide inert compatibility shims so
-- the action bar module can finish loading; proc glow will be ported to the
-- current Retail highlight API separately.
if not ActionButton_ShowOverlayGlow then
	function ActionButton_ShowOverlayGlow() end
end

if not ActionButton_HideOverlayGlow then
	function ActionButton_HideOverlayGlow() end
end

Engine[1] = CreateFrame("Frame")
Engine[2] = {}
Engine[3] = {}
Engine[4] = {}

local function ParseVersionString()
	local version = strsub(GetAddOnMetadata(AddOn, 'Version'), 2)
	if not strfind(version, '%-') then
		return tonumber(version), version
	elseif strfind(version, 'project%-version') then
		return 99999, 'Development'
	else
		return 99999, version
	end
end

function Engine:unpack()
	return self[1], self[2], self[3], self[4]
end

-- This branch intentionally targets Retail only. Keep one explicit client flag
-- for existing Tukui code and expose the current expansion generation.
Engine[1].Retail = true
Engine[1].Midnight = Toc >= 120000 and Toc < 130000
-- Keep the older modern-Retail compatibility flag true for code paths that
-- were introduced during The War Within and still apply to Midnight.
Engine[1].TWW = Toc >= 110000 and Toc < 130000
Engine[1].WindowedMode = Windowed
Engine[1].FullscreenMode = Fullscreen
Engine[1].Resolution = Resolution or (Windowed and GetCVar("gxWindowedResolution")) or GetCVar("gxFullscreenResolution")
Engine[1].ScreenHeight = select(2, GetPhysicalScreenSize())
Engine[1].ScreenWidth = select(1, GetPhysicalScreenSize())
Engine[1].PerfectScale = min(1, max(0.3, 768 / string.match(Resolution, "%d+x(%d+)")))
Engine[1].MyName = UnitName("player")
Engine[1].MyClass = select(2, UnitClass("player"))
Engine[1].MyLevel = UnitLevel("player")
Engine[1].MyFaction = select(2, UnitFactionGroup("player"))
Engine[1].MyRace = select(2, UnitRace("player"))
Engine[1].MyRealm = GetRealmName()
Engine[1].VersionNumber, Engine[1].Version = ParseVersionString()
Engine[1].WoWPatch, Engine[1].WoWBuild, Engine[1].WoWPatchReleaseDate, Engine[1].TocVersion = GetBuildInfo()
Engine[1].WoWBuild = tonumber(Engine[1].WoWBuild)
Engine[1].Hider = CreateFrame("Frame", "TukuiHider", UIParent)
Engine[1].PetHider = CreateFrame("Frame", "TukuiPetHider", UIParent, "SecureHandlerStateTemplate")
Engine[1].OffScreen = CreateFrame("Frame", "TukuiOffScreen", UIParent)

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

Tukui = Engine
