local T, C, L = unpack((select(2, ...)))

if not T.Retail then return end

local Skins = T["Skins"]
local CharacterSkin = CreateFrame("Frame")
local Font = T.GetFont(C["UnitFrames"].Font)

local function HideTexture(texture)
	if texture and texture.SetAlpha then
		texture:SetAlpha(0)
	end
end

local function SkinStatsPane()
	local pane = _G.CharacterStatsPane
	if not pane then return end

	if pane.StripTextures then pane:StripTextures() end
	if pane.CreateBackdrop and not pane.Backdrop then
		pane:CreateBackdrop("Transparent")
	end

	local itemLevel = pane.ItemLevelFrame
	if itemLevel then
		HideTexture(itemLevel.Background)
		if itemLevel.Value then
			itemLevel.Value:SetFontObject(Font)
			itemLevel.Value:SetTextColor(1, 1, 1)
		end
	end

	if pane.statsFramePool then
		for stat in pane.statsFramePool:EnumerateActive() do
			HideTexture(stat.Background)
			if stat.Label then stat.Label:SetFontObject(Font) end
			if stat.Value then stat.Value:SetFontObject(Font) end
		end
	end
end

local function SkinCharacterFrame()
	local frame = _G.CharacterFrame
	if not frame or frame.TukuiCharacterSkin then return end

	-- Main frame: remove the remaining Blizzard chrome and give it the same
	-- flat transparent panel treatment used throughout Tukui.
	if frame.StripTextures then frame:StripTextures() end
	if frame.CreateBackdrop and not frame.Backdrop then
		frame:CreateBackdrop("Transparent")
		if frame.Backdrop and frame.Backdrop.CreateShadow then
			frame.Backdrop:CreateShadow()
		end
	end

	if _G.CharacterFrameInset and _G.CharacterFrameInset.StripTextures then
		_G.CharacterFrameInset:StripTextures()
	end
	if _G.CharacterFrameInsetRight and _G.CharacterFrameInsetRight.StripTextures then
		_G.CharacterFrameInsetRight:StripTextures()
	end

	-- The modern model scene has several old paper-doll background pieces that
	-- survive a normal StripTextures call. Hide them explicitly.
	for _, name in ipairs({
		"CharacterModelFrameBackgroundTopLeft",
		"CharacterModelFrameBackgroundTopRight",
		"CharacterModelFrameBackgroundBotLeft",
		"CharacterModelFrameBackgroundBotRight",
		"CharacterModelFrameBackgroundOverlay",
	}) do
		HideTexture(_G[name])
	end

	local model = _G.CharacterModelScene
	if model then
		if model.StripTextures then model:StripTextures() end
		if model.CreateBackdrop and not model.Backdrop then
			model:CreateBackdrop("Transparent")
		end
	end

	-- Remove the empty circular portrait ornament left in the title bar.
	HideTexture(_G.CharacterFramePortrait)
	local portraitContainer = frame.PortraitContainer
	if portraitContainer then
		if portraitContainer.portrait then HideTexture(portraitContainer.portrait) end
		if portraitContainer.CircleMask then HideTexture(portraitContainer.CircleMask) end
		if portraitContainer.PortraitRing then HideTexture(portraitContainer.PortraitRing) end
		if portraitContainer.SetAlpha then portraitContainer:SetAlpha(0) end
	end

	if frame.CloseButton and frame.CloseButton.SkinCloseButton then
		frame.CloseButton:SkinCloseButton()
	end

	if _G.PaperDollItemsFrame then
		for _, child in ipairs({_G.PaperDollItemsFrame:GetChildren()}) do
			if child and (child:IsObjectType("Button") or child:IsObjectType("ItemButton")) then
				Skins:SkinItemButton(child)
			end
		end
	end

	SkinStatsPane()

	local tabs = {
		_G.CharacterFrameTab1,
		_G.CharacterFrameTab2,
		_G.CharacterFrameTab3,
		_G.CharacterFrameTab4,
	}
	for _, tab in ipairs(tabs) do
		if tab and tab.SkinTab and not tab.TukuiTabSkinned then
			tab:SkinTab()
			tab.TukuiTabSkinned = true
		end
	end

	-- Sidebar buttons (character/info, titles and equipment manager) retain a
	-- lot of Blizzard artwork on current Retail. Keep the icons but flatten the
	-- surrounding chrome.
	for i = 1, 4 do
		local tab = _G["PaperDollSidebarTab" .. i]
		if tab and not tab.TukuiSidebarSkinned then
			if tab.StripTextures then tab:StripTextures() end
			if tab.CreateBackdrop then tab:CreateBackdrop() end
			local icon = tab.Icon or tab.icon
			if icon then
				icon:SetTexCoord(unpack(T.IconCoord))
				if icon.SetInside then icon:SetInside(tab.Backdrop or tab) end
			end
			tab.TukuiSidebarSkinned = true
		end
	end

	frame.TukuiCharacterSkin = true
end

CharacterSkin:RegisterEvent("ADDON_LOADED")
CharacterSkin:RegisterEvent("PLAYER_LOGIN")
CharacterSkin:SetScript("OnEvent", function(_, event, addon)
	if event == "PLAYER_LOGIN" or addon == "Blizzard_UIPanels_Game" then
		SkinCharacterFrame()
	end
end)

if type(_G.PaperDollFrame_UpdateStats) == "function" then
	hooksecurefunc("PaperDollFrame_UpdateStats", SkinStatsPane)
end
