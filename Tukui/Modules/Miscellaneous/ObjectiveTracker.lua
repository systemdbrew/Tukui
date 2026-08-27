local T, C, L = unpack((select(2, ...)))

if not T.Retail then return end

local ObjectiveTracker = CreateFrame("Frame")
local Misc = T["Miscellaneous"]
local ClassColor = T.Colors.class[T.MyClass]
local Font = T.GetFont(C.Misc.ObjectiveTrackerFont or C.UnitFrames.Font)
local hooked = {}

local function SkinQuestButton(button)
	if not button or button.TukuiSkinned then return end

	local icon = button.icon or button.Icon
	button:SetSize(26, 26)

	if button.SetNormalTexture then button:SetNormalTexture("") end
	if button.SetPushedTexture then button:SetPushedTexture("") end
	if button.CreateBackdrop then
		button:CreateBackdrop()
		if button.Backdrop and button.Backdrop.CreateShadow then
			button.Backdrop:CreateShadow()
		end
	end
	if button.StyleButton then button:StyleButton() end

	if icon then
		if icon.SetInside then icon:SetInside(button.Backdrop or button) end
		icon:SetTexCoord(unpack(T.IconCoord))
	end

	local count = button.Count or button.count
	if count then
		count:SetFontObject(Font)
	end

	local hotkey = button.HotKey or button.hotKey
	if hotkey then hotkey:SetAlpha(0) end

	button.TukuiSkinned = true
end

local function SkinBlock(_, block)
	if not block then return end
	SkinQuestButton(block.ItemButton)
	SkinQuestButton(block.itemButton)

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

	if bar.CreateBackdrop then
		bar:CreateBackdrop()
		if bar.Backdrop then
			bar.Backdrop:SetBackdropColor(ClassColor[1] * .15, ClassColor[2] * .15, ClassColor[3] * .15)
			if bar.Backdrop.CreateShadow then bar.Backdrop:CreateShadow() end
		end
	end

	local label = bar.Label
	if label then
		label:SetFontObject(Font)
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
	local bar = progress and progress.Bar
	SkinBar(bar)
end

local function SkinTimerBar(tracker, key)
	if not tracker then return end
	local timer = tracker.usedTimerBars and tracker.usedTimerBars[key]
	local bar = timer and timer.Bar
	SkinBar(bar)
end

local function SkinHeader(header)
	if not header or header.TukuiSkinned then return end

	if header.Background then
		if header.Background.SetAtlas then header.Background:SetAtlas(nil) end
		header.Background:SetAlpha(0)
	end

	local text = header.Text or header.HeaderText
	if text then
		text:SetFontObject(Font)
		text:SetTextColor(1, 1, 1)
	end

	local bar = CreateFrame("StatusBar", nil, header)
	bar:SetHeight(2)
	bar:SetPoint("BOTTOMLEFT", header, 0, 0)
	bar:SetPoint("BOTTOMRIGHT", header, 0, 0)
	bar:SetStatusBarTexture(C.Medias.Blank)
	bar:SetStatusBarColor(unpack(ClassColor))
	if bar.CreateBackdrop then bar:CreateBackdrop() end
	header.TukuiHeaderBar = bar

	local minimize = header.MinimizeButton
	if minimize then
		minimize:SetSize(15, 15)
	end

	header.TukuiSkinned = true
end

local function HookTracker(tracker)
	if not tracker or hooked[tracker] then return end
	hooked[tracker] = true

	SkinHeader(tracker.Header)

	if type(tracker.AddBlock) == "function" then
		hooksecurefunc(tracker, "AddBlock", SkinBlock)
	end
	if type(tracker.GetProgressBar) == "function" then
		hooksecurefunc(tracker, "GetProgressBar", SkinProgressBar)
	end
	if type(tracker.GetTimerBar) == "function" then
		hooksecurefunc(tracker, "GetTimerBar", SkinTimerBar)
	end
end

local function SkinAll()
	local main = _G.ObjectiveTrackerFrame
	if not main then return end

	SkinHeader(main.Header)

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

	for _, tracker in pairs(trackers) do
		HookTracker(tracker)
	end
end

function ObjectiveTracker:Toggle()
	local frame = _G.ObjectiveTrackerFrame
	if not frame then return end

	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
	end
end

function ObjectiveTracker:Enable()
	if not C.Misc.ObjectiveTracker or self.Enabled then return end
	self.Enabled = true

	SkinAll()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", function(_, event, addon)
		if event ~= "ADDON_LOADED" or addon == "Blizzard_ObjectiveTracker" then
			SkinAll()
		end
	end)

	self.ToggleButton = CreateFrame("Button", "TukuiObjectiveTrackerToggleButton", UIParent, "SecureActionButtonTemplate")
	self.ToggleButton:SetScript("OnClick", function() ObjectiveTracker:Toggle() end)
	SetOverrideBindingClick(self.ToggleButton, true, "SHIFT-O", "TukuiObjectiveTrackerToggleButton")
end

Misc.ObjectiveTracker = ObjectiveTracker
