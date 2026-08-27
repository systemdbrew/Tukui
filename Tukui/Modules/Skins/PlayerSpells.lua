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

local function SkinDropDown(dropdown)
	if not dropdown or dropdown.TukuiDropDownSkinned then return end
	if dropdown.StripTextures then dropdown:StripTextures() end
	if dropdown.CreateBackdrop then dropdown:CreateBackdrop() end
	local button = dropdown.Button or dropdown.DropDownButton
	if button then Skins:SkinButton(button) end
	local text = dropdown.Text or dropdown.SelectionDetails and dropdown.SelectionDetails.SelectionName
	if text and text.SetFontObject then
		text:SetFontObject(Font)
		text:SetTextColor(1, 1, 1)
	end
	dropdown.TukuiDropDownSkinned = true
end

local function SkinSpellButton(button)
	if not button then return end
	local icon = button.Icon or button.IconTexture or button.icon
	if not icon then return end

	for _, key in ipairs({"Ring", "CircleMask", "Border", "IconBorder", "NameFrame", "SlotArt", "HighlightTexture"}) do
		HideRegion(button[key])
	end
	if icon.SetTexCoord then icon:SetTexCoord(unpack(T.IconCoord)) end
	if button.CreateBackdrop and not button.Backdrop then button:CreateBackdrop() end
	if icon.SetInside then icon:SetInside(button.Backdrop or button) end
	if button.StyleButton and not button.TukuiSpellButtonSkinned then button:StyleButton() end

	for _, text in ipairs({button.SpellName, button.SpellSubName, button.spellString, button.subSpellString, button.Name}) do
		if text and text.SetFontObject then
			text:SetFontObject(Font)
			text:SetTextColor(1, 1, 1)
		end
	end
	button.TukuiSpellButtonSkinned = true
end

local function CleanRegions(frame, depth)
	if not frame or depth > 5 then return end
	if frame.GetRegions then
		for _, region in ipairs({frame:GetRegions()}) do
			if region and region.GetObjectType then
				local kind = region:GetObjectType()
				if kind == "Texture" then
					local atlas = region.GetAtlas and region:GetAtlas()
					local texture = region.GetTexture and region:GetTexture()
					local name = region.GetDebugName and region:GetDebugName() or ""
					local marker = string.lower(tostring(atlas or texture or name or ""))
					if marker:find("book") or marker:find("parch") or marker:find("page") or marker:find("divider") or marker:find("header") then
						region:SetAlpha(0)
					end
				elseif kind == "FontString" then
					region:SetFontObject(Font)
					region:SetTextColor(1, 1, 1)
				end
			end
		end
	end
	if frame.GetChildren then
		for _, child in ipairs({frame:GetChildren()}) do CleanRegions(child, depth + 1) end
	end
end

local function ScanSpellButtons(frame, depth)
	if not frame or depth > 6 or not frame.GetChildren then return end
	for _, child in ipairs({frame:GetChildren()}) do
		if child then
			local icon = child.Icon or child.IconTexture or child.icon
			if icon and (child.SpellName or child.SpellSubName or child.spellString or child.spellID or child.GetID) then SkinSpellButton(child) end
			ScanSpellButtons(child, depth + 1)
		end
	end
end

local function SkinPagingButton(button)
	if not button then return end
	if not button.TukuiPagingSkinned then Skins:SkinButton(button) end
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	if normal then normal:SetVertexColor(1, 1, 1); normal:SetAlpha(1) end
	button.TukuiPagingSkinned = true
end

local function SkinSpellBook(frame)
	if not frame then return end
	if not frame.TukuiBookBaseSkinned then
		if frame.StripTextures then frame:StripTextures() end
		if frame.CreateBackdrop and not frame.Backdrop then frame:CreateBackdrop("Transparent") end
		frame.TukuiBookBaseSkinned = true
	end

	Skins:SkinEditBox(frame.SearchBox)
	HideRegion(frame.TopBar)
	HideRegion(frame.BookCornerFlipbook)
	if frame.HelpPlateButton and frame.HelpPlateButton.Ring then HideRegion(frame.HelpPlateButton.Ring) end

	if frame.CategoryTabSystem then for _, tab in ipairs({frame.CategoryTabSystem:GetChildren()}) do Skins:SkinTab(tab) end end

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
			if controls.PageText then controls.PageText:SetFontObject(Font); controls.PageText:SetTextColor(1, 1, 1) end
			SkinPagingButton(controls.PrevPageButton)
			SkinPagingButton(controls.NextPageButton)
		end
	end

	CleanRegions(frame, 0)
	ScanSpellButtons(frame, 0)
end

local function SkinTalents(talents)
	if not talents then return end

	-- Keep Blizzard's class/spec artwork and the talent-node graph intact.
	-- Only Tukui-skin the surrounding controls and utility panels.
	HideRegion(talents.BlackBG)
	HideRegion(talents.BottomBar)

	Skins:SkinButton(talents.ApplyButton)
	Skins:SkinButton(talents.InspectCopyButton)
	Skins:SkinEditBox(talents.SearchBox)

	if talents.LoadSystem then
		SkinDropDown(talents.LoadSystem.Dropdown)
		if talents.LoadSystem.CreateButton then Skins:SkinButton(talents.LoadSystem.CreateButton) end
		if talents.LoadSystem.DeleteButton then Skins:SkinButton(talents.LoadSystem.DeleteButton) end
	end

	if talents.SearchPreviewContainer then Skins:SkinFrame(talents.SearchPreviewContainer, true) end
	if talents.PvPTalentList then Skins:SkinFrame(talents.PvPTalentList) end

	for _, display in ipairs({talents.ClassCurrencyDisplay, talents.SpecCurrencyDisplay}) do
		if display then
			local label = display.CurrencyLabel
			local amount = display.CurrentAmountContainer and display.CurrentAmountContainer.CurrencyAmount
			if label and label.SetFontObject then label:SetFontObject(Font); label:SetTextColor(1, 1, 1) end
			if amount and amount.SetFontObject then amount:SetFontObject(Font); amount:SetTextColor(1, 1, 1) end
		end
	end

	local hero = talents.HeroTalentsContainer
	if hero and hero.HeroSpecLabel and hero.HeroSpecLabel.SetFontObject then
		hero.HeroSpecLabel:SetFontObject(Font)
		hero.HeroSpecLabel:SetTextColor(1, 1, 1)
	end

	if not talents.TukuiTalentBackdrop and talents.CreateBackdrop then
		-- A subtle border around the whole talent canvas, without covering the art.
		talents:CreateBackdrop("Transparent")
		if talents.Backdrop then
			talents.Backdrop:SetFrameLevel(math.max(0, talents:GetFrameLevel() - 1))
		end
		talents.TukuiTalentBackdrop = true
	end
end

local function SkinPlayerSpells()
	local frame = _G.PlayerSpellsFrame
	if not frame then return end
	Skins:SkinFrame(frame, true)
	Skins:SkinCloseButton(frame.CloseButton)
	HideRegion(frame.PortraitContainer)
	HideRegion(_G.PlayerSpellsFramePortrait)

	if frame.TabSystem then for _, tab in ipairs({frame.TabSystem:GetChildren()}) do Skins:SkinTab(tab) end end
	SkinTalents(frame.TalentsFrame)
	SkinSpellBook(frame.SpellBookFrame)
	SkinDialog(_G.ClassTalentLoadoutImportDialog)
	SkinDialog(_G.ClassTalentLoadoutCreateDialog)
	SkinDialog(_G.ClassTalentLoadoutEditDialog)

	local heroSelect = _G.HeroTalentsSelectionDialog
	if heroSelect then
		Skins:SkinFrame(heroSelect, true)
		Skins:SkinCloseButton(heroSelect.CloseButton)
	end

	if not frame.TukuiRefreshHook then
		frame:HookScript("OnShow", function()
			C_Timer.After(0, SkinPlayerSpells); C_Timer.After(.1, SkinPlayerSpells); C_Timer.After(.5, SkinPlayerSpells)
		end)
		frame.TukuiRefreshHook = true
	end
end

Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(_, _, addon) if addon == "Blizzard_PlayerSpells" then SkinPlayerSpells() end end)
