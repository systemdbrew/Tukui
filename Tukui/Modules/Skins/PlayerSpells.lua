local T, C, L = unpack((select(2, ...)))
if not T.Retail then return end

local Skins = T["Skins"]
local Loader = CreateFrame("Frame")

local function SkinDialog(dialog)
	if not dialog then return end
	Skins:SkinFrame(dialog, true)
	Skins:SkinButton(dialog.AcceptButton)
	Skins:SkinButton(dialog.CancelButton)
	Skins:SkinButton(dialog.DeleteButton)
	if dialog.NameControl then Skins:SkinEditBox(dialog.NameControl.EditBox) end
	Skins:SkinEditBox(dialog.LoadoutName)
end

local function SkinSpellBook(frame)
	if not frame then return end
	Skins:SkinEditBox(frame.SearchBox)
	if frame.TopBar then frame.TopBar:SetAlpha(0) end
	if frame.BookCornerFlipbook then frame.BookCornerFlipbook:Hide() end
	if frame.HelpPlateButton and frame.HelpPlateButton.Ring then frame.HelpPlateButton.Ring:Hide() end
	if frame.CategoryTabSystem then
		for _, tab in ipairs({frame.CategoryTabSystem:GetChildren()}) do Skins:SkinTab(tab) end
	end
	local paged = frame.PagedSpellsFrame
	if paged and paged.PagingControls then
		local controls = paged.PagingControls
		if controls.PageText then controls.PageText:SetTextColor(1, 1, 1) end
		Skins:SkinButton(controls.PrevPageButton)
		Skins:SkinButton(controls.NextPageButton)
	end
end

local function SkinPlayerSpells()
	local frame = _G.PlayerSpellsFrame
	if not frame then return end
	Skins:SkinFrame(frame, true)
	Skins:SkinCloseButton(frame.CloseButton)
	if frame.PortraitContainer then frame.PortraitContainer:SetAlpha(0) end
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
		frame:HookScript("OnShow", function() C_Timer.After(0, SkinPlayerSpells) end)
		frame.TukuiRefreshHook = true
	end
end

Loader:RegisterEvent("ADDON_LOADED")
Loader:SetScript("OnEvent", function(_, _, addon)
	if addon == "Blizzard_PlayerSpells" then SkinPlayerSpells() end
end)
