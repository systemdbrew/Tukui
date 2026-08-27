local T, C, L = unpack((select(2, ...)))

if not T.Retail then return end

local Skins = T["Skins"]
local CharacterSkin = CreateFrame("Frame")

local function SkinCharacterFrame()
	local frame = _G.CharacterFrame
	if not frame or frame.TukuiSkinned then return end

	Skins:SkinFrame(frame, true)

	if _G.CharacterFrameInset and _G.CharacterFrameInset.StripTextures then
		_G.CharacterFrameInset:StripTextures()
	end

	if _G.CharacterFrameInsetRight and _G.CharacterFrameInsetRight.StripTextures then
		_G.CharacterFrameInsetRight:StripTextures()
	end

	if _G.CharacterModelScene then
		Skins:SkinFrame(_G.CharacterModelScene)
	end

	if _G.CharacterFramePortrait then
		_G.CharacterFramePortrait:SetAlpha(0)
	end

	if _G.CharacterFrame.CloseButton and _G.CharacterFrame.CloseButton.SkinCloseButton then
		_G.CharacterFrame.CloseButton:SkinCloseButton()
	end

	if _G.PaperDollItemsFrame then
		for _, child in ipairs({_G.PaperDollItemsFrame:GetChildren()}) do
			if child and (child:IsObjectType("Button") or child:IsObjectType("ItemButton")) then
				Skins:SkinItemButton(child)
			end
		end
	end

	if _G.CharacterStatsPane and _G.CharacterStatsPane.ItemLevelFrame then
		local itemLevel = _G.CharacterStatsPane.ItemLevelFrame
		if itemLevel.Background then
			itemLevel.Background:SetAlpha(0)
		end
		if itemLevel.Value then
			itemLevel.Value:SetFontObject(T.GetFont(C["UnitFrames"].Font))
		end
	end

	local tabs = {
		_G.CharacterFrameTab1,
		_G.CharacterFrameTab2,
		_G.CharacterFrameTab3,
	}

	for _, tab in ipairs(tabs) do
		if tab and tab.SkinTab then
			tab:SkinTab()
		end
	end

	frame.TukuiSkinned = true
end

CharacterSkin:RegisterEvent("ADDON_LOADED")
CharacterSkin:RegisterEvent("PLAYER_LOGIN")
CharacterSkin:SetScript("OnEvent", function(_, event, addon)
	if event == "PLAYER_LOGIN" or addon == "Blizzard_UIPanels_Game" then
		SkinCharacterFrame()
	end
end)
