local T, C, L = unpack((select(2, ...)))
if not T.Retail then return end

local Skins = T["Skins"]
local Loader = CreateFrame("Frame")
local Font = T.GetFont(C["UnitFrames"].Font)

local function HideRegion(region)
	if region and region.SetAlpha then region:SetAlpha(0) end
end

local function SkinDialog(dialog)
	if not dialog then return end
	Skins:SkinFrame(dialog, true)
	Skins:SkinButton(dialog.AcceptButton)
	Skins:SkinButton(dialog.CancelButton)
	Skins:SkinButton(dialog.DeleteButton)
	if dialog.NameControl then Skins:SkinEditBox(dialog.NameControl.EditBox) end
	Skins:SkinEditBox(dialog.LoadoutName)
end

local function SkinSpellButton(button)
	if not button or button.TukuiSpellButtonSkinned then return end

	local icon = button.Icon or button.IconTexture or button.icon
	if not icon then return end

	if button.Ring then button.Ring:Hide() end
	if button.CircleMask then button.CircleMask:Hide() end
	if button.Border then HideRegion(button.Border) end
	if button.IconBorder then HideRegion(button.IconBorder) end
	if button.NameFrame then HideRegion(button.NameFrame) end

	if icon.SetTexCoord then icon:SetTexCoord(unpack(T.IconCoord)) end
	if button.CreateBackdrop and not button.Backdrop then button:CreateBackdrop() end
	if icon.SetInside then icon:SetInside(button.Backdrop or button) end
	if button.StyleButton then button:StyleButton() end

	for _, text in ipairs({button.SpellName, button.SpellSubName, button.spellString, button.subSpellString, button.Name}) do
		if text and text.SetFontObject then
			text:SetFontObject(Font)
			text:SetTextColor(1, 1, 1)
		end
	end

	button.TukuiSpellButtonSkinned = true
end

local function ScanSpellButtons(frame, depth)
	if not frame or depth > 5 or not frame.GetChildren then return end
	for _, child in ipairs({frame:GetChildren()}) do
		if child then
			local icon = child.Icon or child.IconTexture or child.icon
			if icon and (child.SpellName or child.SpellSubName or child.spellString or child.spellID or child.GetID) then
				SkinSpellButton(child)
			end
			ScanSpellButtons(child, depth + 1)
		end
	end
end

local function SkinPagingButton(button)
	if not button or button.TukuiPagingSkinned then return end
	Skins:SkinButton(button)
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	if normal then
		normal:SetVertexColor(1, 1, 1)
		normal:SetAlpha(1)
	end
	button.TukuiPagingSkinned = true
end

local function SkinSpellBook(frame)
	if not frame then return end

	-- Current Retail still renders the old parchment/book art inside this frame.
	-- Strip the container art but leave child spell icons/text intact.
	if not frame.TukuiBookBaseSkinned then
		if frame.StripTextures then frame:StripTextures() end
		if frame.CreateBackdrop and not frame.Backdrop then frame:CreateBackdrop("Transparent") end
		frame.TukuiBookBaseSkinned = true
	end

	Skins:SkinEditBox(frame.SearchBox)
	if frame.TopBar then frame.TopBar:SetAlpha(0) end
	if frame.BookCornerFlipbook then frame.BookCornerFlipbook:Hide() end
	if frame.HelpPlateButton and frame.HelpPlateButton.Ring then frame.HelpPlateButton.Ring:Hide() end

	if frame.CategoryTabSystem then
		for _, tab in ipairs({frame.CategoryTabSystem:GetChildren()}) do Skins:SkinTab(tab) end
	end

	local paged = frame.PagedSpellsFrame
	if paged then
		for _, viewName in ipairs({"View1", "View2"}) do
			local view = paged[viewName]
			if view then
				if view.StripTextures and not view.TukuiViewSkinned then view:StripTextures() end
				if view.CreateBackdrop and not view.Backdrop then view:CreateBackdrop("Transparent") end
				view.TukuiViewSkinned = true
			end
		end

		if paged.PagingControls then
			local controls = paged.PagingControls
			if controls.PageText then
				controls.PageText:SetFontObject(Font)
				controls.PageText:SetTextColor(1, 1, 1)
			end
			SkinPagingButton(controls.PrevPageButton)
			SkinPagingButton(controls.NextPageButton)
		end
	end

	ScanSpellButtons(frame, 0)
end

local function SkinPlayerSpells()
	local frame = _G.PlayerSpellsFrame
	if not frame then return end

	Skins:SkinFrame(frame, true)
	Skins:SkinCloseButton(frame.CloseButton)
	if frame.PortraitContainer then frame.PortraitContainer:SetAlpha(0) end
	HideRegion(_G.PlayerSpellsFramePortrait)

	if frame.TabSystem then
		for _, tab in ipairs({frame.TabSystem:GetChildren()}) do Skins:SkinTab(tab) end
	end

	local talents = frame.TalentsFrame
	if talents then
		if talents.BlackBG then talents.BlackBG:SetAlpha(0) end
		if talents.BottomBar then talents.BottomBar:SetAlpha(0) end
		Skins:SkinButton(talents.ApplyButton)
		Skins:SkinButton(talents.InspectCopyButton)
		Skins:SkinEditBox(talents.SearchBox)
		if talents.SearchPreviewContainer then Skins:SkinFrame(talents.SearchPreviewContainer, true) end
		if talents.PvPTalentList then Skins:SkinFrame(talents.PvPTalentList) end
	end

	SkinSpellBook(frame.SpellBookFrame)
	SkinDialog(_G.ClassTalentLoadoutImportDialog)
	SkinDialog(_G.ClassTalentLoadoutCreateDialog)
	SkinDialog(_G.ClassTalentLoadoutEditDialog)

	if not frame.TukuiRefreshHook then
		frame:HookScript("OnShow", function()
			C_Timer.After(0, SkinPlayerSpells)
			C_Timer.After(.1, SkinPlayerSpells)
		end)
		frame.TukuiRefreshHook = true
	end
end

Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(_, _, addon)
	if addon == "Blizzard_PlayerSpells" then SkinPlayerSpells() end
end)
