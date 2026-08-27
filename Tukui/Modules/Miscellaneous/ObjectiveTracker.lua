local T, C, L = unpack((select(2, ...)))

if not T.Retail then return end

local ObjectiveTracker = CreateFrame("Frame")
local Misc = T["Miscellaneous"]
local ClassColor = T.Colors.class[T.MyClass]
local Font = T.GetFont(C.Misc.ObjectiveTrackerFont or C.UnitFrames.Font)
local hooked = {}

local function SetTrackerFont(fontString, size, r, g, b)
	if not fontString then return end
	local path = select(1, fontString:GetFont())
	fontString:SetFont(path or C.Medias.Font, size or 12, "OUTLINE")
	fontString:SetShadowOffset(0, 0)
	if r then fontString:SetTextColor(r, g, b) end
end

local function SkinQuestButton(button)
	if not button or button.TukuiSkinned then return end

	local icon = button.icon or button.Icon
	button:SetSize(26, 26)

	if button.SetNormalTexture then button:SetNormalTexture("") end
	if button.SetPushedTexture then button:SetPushedTexture("") end
	if button.CreateBackdrop then
		button:CreateBackdrop()
		if button.Backdrop and button.Backdrop.CreateShadow then button.Backdrop:CreateShadow() end
	end
	if button.StyleButton then button:StyleButton() end

	if icon then
		if icon.SetInside then icon:SetInside(button.Backdrop or button) end
		icon:SetTexCoord(unpack(T.IconCoord))
	end

	local count = button.Count or button.count
	if count then SetTrackerFont(count, 11, 1, 1, 1) end

	local hotkey = button.HotKey or button.hotKey
	if hotkey then hotkey:SetAlpha(0) end

	button.TukuiSkinned = true
end

local function SkinBlock(_, block)
	if not block then return end
	SkinQuestButton(block.ItemButton)
	SkinQuestButton(block.itemButton)

	-- Current Retail uses slightly different fields depending on tracker type.
	-- Style whichever text regions are present without depending on one module.
	SetTrackerFont(block.HeaderText, 12, 1, 1, 1)
	SetTrackerFont(block.Title, 12, 1, .82, 0)
	SetTrackerFont(block.QuestTitle, 12, 1, .82, 0)
	SetTrackerFont(block.Text, 11, .85, .85, .85)

	if block.lines then
		for _, line in pairs(block.lines) do
			if line then
				SetTrackerFont(line.Text or line.text, 11, .82, .82, .82)
				SetTrackerFont(line.Dash or line.dash, 11, .55, .55, .55)
			end
		end
	end

	local check = block.currentLine and block.currentLine.Check
	if check and not check.TukuiSkinned then
		if check.SetAtlas then check:SetAtlas("checkmark-minimal") end
		check:SetDesaturated(true)
		check:SetVertexColor(0, 1, 0)
		check.TukuiSkinned = true
	end
end

local function SkinBar(bar)
	if not bar or bar.TukuiSkinned then return end

	if bar.StripTextures then bar:StripTextures() end
	bar:SetStatusBarTexture(T.GetTexture(C["Textures"].QuestProgressTexture))
	bar:SetStatusBarColor(unpack(ClassColor))
	bar:SetHeight(18)

	if bar.CreateBackdrop then
		bar:CreateBackdrop()
		if bar.Backdrop then
			bar.Backdrop:SetBackdropColor(ClassColor[1] * .12, ClassColor[2] * .12, ClassColor[3] * .12)
			if bar.Backdrop.CreateShadow then bar.Backdrop:CreateShadow() end
		end
	end

	local label = bar.Label
	if label then
		SetTrackerFont(label, 11, 1, 1, 1)
		label:ClearAllPoints()
		label:SetPoint("CENTER", bar)
	end

	local icon = bar.Icon
	if icon then
		if icon.SetMask then icon:SetMask("") end
		icon:SetTexCoord(unpack(T.IconCoord))
	end

	bar.TukuiSkinned = true
end

local function SkinProgressBar(tracker, key)
	if not tracker then return end
	local progress = tracker.usedProgressBars and tracker.usedProgressBars[key]
	SkinBar(progress and progress.Bar)
end

local function SkinTimerBar(tracker, key)
	if not tracker then return end
	local timer = tracker.usedTimerBars and tracker.usedTimerBars[key]
	SkinBar(timer and timer.Bar)
end

local function SkinHeader(header, mainHeader)
	if not header or header.TukuiSkinned then return end

	if header.Background then
		if header.Background.SetAtlas then header.Background:SetAtlas(nil) end
		header.Background:SetAlpha(0)
	end

	local text = header.Text or header.HeaderText
	if text then
		SetTrackerFont(text, mainHeader and 12 or 12, 1, 1, 1)
		text:SetJustifyH("LEFT")
	end

	local bar = CreateFrame("StatusBar", nil, header)
	bar:SetHeight(mainHeader and 3 or 2)
	bar:SetPoint("BOTTOMLEFT", header, 0, 0)
	bar:SetPoint("BOTTOMRIGHT", header, 0, 0)
	bar:SetStatusBarTexture(C.Medias.Blank)
	bar:SetStatusBarColor(unpack(ClassColor))
	if bar.CreateBackdrop then bar:CreateBackdrop() end
	header.TukuiHeaderBar = bar

	local minimize = header.MinimizeButton
	if minimize then
		if minimize.StripTextures then minimize:StripTextures() end
		minimize:SetSize(14, 14)
		if minimize.CreateBackdrop then minimize:CreateBackdrop() end
	end

	header.TukuiSkinned = true
end

local function HookTracker(tracker)
	if not tracker or hooked[tracker] then return end
	hooked[tracker] = true

	SkinHeader(tracker.Header, false)

	if type(tracker.AddBlock) == "function" then hooksecurefunc(tracker, "AddBlock", SkinBlock) end
	if type(tracker.GetProgressBar) == "function" then hooksecurefunc(tracker, "GetProgressBar", SkinProgressBar) end
	if type(tracker.GetTimerBar) == "function" then hooksecurefunc(tracker, "GetTimerBar", SkinTimerBar) end

	-- Skin blocks that already existed before Tukui loaded.
	if tracker.usedBlocks then
		for _, block in pairs(tracker.usedBlocks) do
			SkinBlock(tracker, block)
		end
	end
end

local function SkinAll()
	local main = _G.ObjectiveTrackerFrame
	if not main then return end

	SkinHeader(main.Header, true)

	local trackers = {
		_G.ScenarioObjectiveTracker,
		_G.UIWidgetObjectiveTracker,
		_G.CampaignQuestObjectiveTracker,
		_G.QuestObjectiveTracker,
		_G.AdventureObjectiveTracker,
		_G.AchievementObjectiveTracker,
		_G.MonthlyActivitiesObjectiveTracker,
		_G.ProfessionsRecipeTracker,
		_G.BonusObjectiveTracker,
		_G.WorldQuestObjectiveTracker,
		_G.InitiativeTasksObjectiveTracker,
	}

	for _, tracker in pairs(trackers) do HookTracker(tracker) end
end

function ObjectiveTracker:Toggle()
	local frame = _G.ObjectiveTrackerFrame
	if not frame then return end
	if frame:IsShown() then frame:Hide() else frame:Show() end
end

function ObjectiveTracker:Enable()
	if not C.Misc.ObjectiveTracker or self.Enabled then return end
	self.Enabled = true

	SkinAll()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(_, event, addon)
		if event ~= "ADDON_LOADED" or addon == "Blizzard_ObjectiveTracker" then SkinAll() end
	end)

	self.ToggleButton = CreateFrame("Button", "TukuiObjectiveTrackerToggleButton", UIParent, "SecureActionButtonTemplate")
	self.ToggleButton:SetScript("OnClick", function() ObjectiveTracker:Toggle() end)
	SetOverrideBindingClick(self.ToggleButton, true, "SHIFT-O", "TukuiObjectiveTrackerToggleButton")
end

Misc.ObjectiveTracker = ObjectiveTracker
