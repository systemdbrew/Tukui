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

local function SkinStatHeader(frame)
	if not frame or frame.TukuiStatHeaderSkinned then return end

	HideTexture(frame.Background)
	if frame.StripTextures then frame:StripTextures() end
	if frame.CreateBackdrop and not frame.Backdrop then
		frame:CreateBackdrop("Transparent")
	end

	if frame.Backdrop then
		frame.Backdrop:ClearAllPoints()
		frame.Backdrop:SetPoint("CENTER", frame, "CENTER", 0, 0)
		frame.Backdrop:SetSize(150, 18)
	end

	frame.TukuiStatHeaderSkinned = true
end

local function SkinStatsPane()
	local pane = _G.CharacterStatsPane
	if not pane then return end

	if not pane.TukuiBaseSkinned then
		if pane.StripTextures then pane:StripTextures() end
		pane.TukuiBaseSkinned = true
	end

	local itemLevel = pane.ItemLevelFrame
	if itemLevel then
		SkinStatHeader(itemLevel)
		if itemLevel.Value then
			itemLevel.Value:SetFontObject(Font)
			itemLevel.Value:SetTextColor(1, 1, 1)
		end
	end

	for _, key in ipairs({"ItemLevelCategory", "AttributesCategory", "EnhancementsCategory"}) do
		SkinStatHeader(pane[key])
	end

	if pane.statsFramePool then
		for stat in pane.statsFramePool:EnumerateActive() do
			HideTexture(stat.Background)
			if stat.Label then stat.Label:SetFontObject(Font) end
			if stat.Value then stat.Value:SetFontObject(Font) end
		end
	end
end

local function SkinBottomTabs()
	for i = 1, 4 do
		local tab = _G["CharacterFrameTab" .. i]
		if tab and not tab.TukuiTabSkinned then
			if tab.StripTextures then tab:StripTextures() end
			if tab.CreateBackdrop and not tab.Backdrop then tab:CreateBackdrop("Transparent") end
			if tab.Text then tab.Text:SetFontObject(Font) end
			if tab.SkinTab then tab:SkinTab() end
			tab.TukuiTabSkinned = true
		end
	end
end

local function SkinSidebarTabs()
	for i = 1, 4 do
		local tab = _G["PaperDollSidebarTab" .. i]
		if tab and not tab.TukuiSidebarSkinned then
			if tab.StripTextures then tab:StripTextures() end
			if tab.CreateBackdrop and not tab.Backdrop then tab:CreateBackdrop() end

			local icon = tab.Icon or tab.icon
			if icon then
				icon:SetTexCoord(unpack(T.IconCoord))
				if icon.SetInside then icon:SetInside(tab.Backdrop or tab) end
			end

			HideTexture(tab.TabBg)
			HideTexture(tab.Hider)
			tab.TukuiSidebarSkinned = true
		end
	end
end

local function SkinEquipmentSlots()
	if not _G.PaperDollItemsFrame then return end

	for _, child in ipairs({_G.PaperDollItemsFrame:GetChildren()}) do
		if child and (child:IsObjectType("Button") or child:IsObjectType("ItemButton")) and not child.TukuiCharacterSlotSkinned then
			Skins:SkinItemButton(child)
			if child.icon then
				child.icon:SetTexCoord(unpack(T.IconCoord))
				if child.icon.SetInside then child.icon:SetInside(child) end
			end
			child.TukuiCharacterSlotSkinned = true
		end
	end
end

local function ApplyCharacterVisuals()
	local frame = _G.CharacterFrame
	if not frame then return end

	-- Blizzard restores several regions during PaperDoll refreshes, so visual
	-- cleanup is deliberately safe to repeat.
	HideTexture(_G.CharacterFramePortrait)

	local portraitContainer = frame.PortraitContainer
	if portraitContainer then
		if portraitContainer.portrait then HideTexture(portraitContainer.portrait) end
		if portraitContainer.CircleMask then HideTexture(portraitContainer.CircleMask) end
		if portraitContainer.PortraitRing then HideTexture(portraitContainer.PortraitRing) end
		if portraitContainer.SetAlpha then portraitContainer:SetAlpha(0) end
	end

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
	if model and model.Backdrop then
		model.Backdrop:SetBackdropColor(0, 0, 0, .75)
	end

	SkinStatsPane()
	SkinBottomTabs()
	SkinSidebarTabs()
	SkinEquipmentSlots()
end

local function SkinCharacterFrame()
	local frame = _G.CharacterFrame
	if not frame then return end

	if not frame.TukuiCharacterBaseSkin then
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

		local model = _G.CharacterModelScene
		if model then
			if model.StripTextures then model:StripTextures() end
			if model.CreateBackdrop and not model.Backdrop then
				model:CreateBackdrop("Transparent")
			end
		end

		if frame.CloseButton and frame.CloseButton.SkinCloseButton then
			frame.CloseButton:SkinCloseButton()
		end

		frame:HookScript("OnShow", function()
			ApplyCharacterVisuals()
			C_Timer.After(0, ApplyCharacterVisuals)
		end)

		frame.TukuiCharacterBaseSkin = true
	end

	ApplyCharacterVisuals()
	C_Timer.After(0, ApplyCharacterVisuals)
end

CharacterSkin:RegisterEvent("ADDON_LOADED")
CharacterSkin:RegisterEvent("PLAYER_LOGIN")
CharacterSkin:SetScript("OnEvent", function(_, event, addon)
	if event == "PLAYER_LOGIN" or addon == "Blizzard_UIPanels_Game" then
		SkinCharacterFrame()
	end
end)

if type(_G.PaperDollFrame_UpdateStats) == "function" then
	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		SkinStatsPane()
		C_Timer.After(0, ApplyCharacterVisuals)
	end)
end
