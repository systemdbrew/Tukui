local T, C, L = unpack((select(2, ...)))

local Tooltip = T["Tooltips"]
local HealthBar = GameTooltipStatusBar
local GetMouseFocus = GetMouseFocus or GetMouseFoci
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local GetItemQualityColor = (C_Item and C_Item.GetItemQualityColor) or GetItemQualityColor

local Classification = {
	worldboss = "|cffAF5050B |r",
	rareelite = "|cffAF5050R+ |r",
	elite = "|cffAF5050+ |r",
	rare = "|cffAF5050R |r",
}

Tooltip.BackdropStyle = {
	bgFile = C.Medias.Blank,
}

function Tooltip:CreateAnchor()
	self.Anchor = CreateFrame("Frame", "TukuiTooltipAnchor", UIParent)
	self.Anchor:SetSize(200, 21)
	self.Anchor:SetFrameStrata("TOOLTIP")
	self.Anchor:SetFrameLevel(20)
	self.Anchor:SetClampedToScreen(true)
	self.Anchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -28, 240)
	self.Anchor:SetMovable(true)
end

function Tooltip:SetTooltipDefaultAnchor(parent)
	local Anchor = Tooltip.Anchor
	if C.Tooltips.MouseOver then
		if parent ~= UIParent then
			self:ClearAllPoints()
			self:SetPoint("BOTTOMRIGHT", Anchor, "TOPRIGHT", 0, 9)
		else
			self:SetOwner(parent, "ANCHOR_CURSOR")
		end
	else
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", Anchor, "TOPRIGHT", 0, 9)
	end
end

function Tooltip:GetTextColor(unit)
	if not unit then return end
	if UnitIsPlayer(unit) then
		local Class = select(2, UnitClass(unit))
		local Color = T.Colors.class[Class]
		if not Color then return end
		local Hex = T.RGBToHex(unpack(T.Colors.class[Class]))
		return Hex, Color.r, Color.g, Color.b
	else
		local Reaction = UnitReaction(unit, "player")
		local Color = T.Colors.reaction[Reaction]
		if not Color then return end
		local Hex = T.RGBToHex(unpack(Color))
		return Hex, Color.r, Color.g, Color.b
	end
end

function Tooltip:OnTooltipSetUnit()
	local NumLines = self:NumLines()
	local MouseFocus = GetMouseFocus()
	local Unit = select(2, self:GetUnit()) or (MouseFocus and MouseFocus.GetAttribute and MouseFocus:GetAttribute("unit"))
	if not Unit and UnitExists("mouseover") then Unit = "mouseover" end
	if not Unit then self:Hide(); return end
	if UnitIsUnit(Unit, "mouseover") then Unit = "mouseover" end

	local Line1 = GameTooltipTextLeft1
	local Race = UnitRace(Unit)
	local Class = UnitClass(Unit)
	local Level = UnitLevel(Unit)
	local Guild = GetGuildInfo(Unit)
	local Name, Realm = UnitName(Unit)
	local CreatureType = UnitCreatureType(Unit)
	local CreatureClassification = UnitClassification(Unit)
	local Title = UnitPVPName(Unit)
	local IsEnemy = UnitIsEnemy("player", Unit)
	local Color = Tooltip:GetTextColor(Unit) or "|CFFFFFFFF"
	local Difficulty = GetQuestDifficultyColor(Level)
	local R, G, B = Difficulty.r, Difficulty.g, Difficulty.b

	if Name then
		local Extra = ""
		if UnitIsPlayer(Unit) and not Realm then Realm = T.MyRealm end
		if Realm then
			local RealmColor = IsEnemy and "|cffDE5E5E" or "|cff4AAB4D"
			Extra = RealmColor.."["..Realm.."]|r"
		end
		if C.Tooltips.DisplayTitle and Title then Name = Title end
		Line1:SetFormattedText("%s%s%s %s", Color, Name, "|r", Extra)
	end

	if UnitIsPlayer(Unit) and UnitIsFriend("player", Unit) then
		if UnitIsAFK(Unit) then self:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(Unit) then self:AppendText((" %s"):format(CHAT_FLAG_DND)) end
	end

	for i = 2, NumLines do
		local Line = _G["GameTooltipTextLeft"..i]
		if UnitIsPlayer(Unit) and Guild and Line and Line:GetText() and Line:GetText():find(Guild) then
			Line:SetText("|cff00ff00"..Guild.."|r")
		end
		if Line and Line:GetText() and Line:GetText():find("^" .. LEVEL) then
			if UnitIsPlayer(Unit) and Race then
				Line:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", R*255,G*255,B*255, Level > 0 and Level or "|cffAF5050??|r", Race, Color, Class.."|r")
			else
				Line:SetFormattedText("|cff%02x%02x%02x%s|r %s%s", R*255,G*255,B*255, Level > 0 and Level or "|cffAF5050??|r", Classification[CreatureClassification] or "", CreatureType or "".."|r")
			end
			break
		end
	end

	if UnitExists(Unit.."target") then
		local UnitTarget = Unit.."target"
		local TargetClass = select(2, UnitClass(UnitTarget))
		local Reaction = UnitReaction(UnitTarget, "player")
		local r,g,b
		if UnitIsPlayer(UnitTarget) then r,g,b = unpack(T.Colors.class[TargetClass])
		elseif Reaction then r,g,b = unpack(T.Colors.reaction[Reaction])
		else r,g,b = 1,1,1 end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(UnitName(UnitTarget), r,g,b)
	end

	if C.Tooltips.UnitHealthText then Tooltip.SetHealthValue(HealthBar, Unit) end
end

function Tooltip:SetUnitBorderColor()
	local Unit = self
	local R,G,B
	local Reaction = Unit and UnitReaction(Unit, "player")
	local Player = Unit and UnitIsPlayer(Unit)
	local Friend = Unit and UnitIsFriend("player", Unit)
	if Player and Friend then
		local Class = select(2, UnitClass(Unit)); local Color = T.Colors.class[Class]
		R,G,B = Color[1],Color[2],Color[3]
	elseif Reaction then
		local Color = T.Colors.reaction[Reaction]; R,G,B = Color[1],Color[2],Color[3]
	end
	if R then
		HealthBar:SetStatusBarColor(R,G,B); HealthBar.Backdrop:SetBorderColor(R,G,B); GameTooltip.Backdrop:SetBorderColor(R,G,B)
	end
end

function Tooltip:Skin()
	if self:IsForbidden() then return end
	if not self.IsSkinned then
		self:StripTextures(); self:CreateBackdrop(); self:CreateShadow()
		if self.NineSlice then self.NineSlice:SetAlpha(0) end
		self.IsSkinned = true
	end
end

function Tooltip:SkinHealthBar()
	HealthBar:SetScript("OnValueChanged", self.OnValueChanged)
	HealthBar:SetStatusBarTexture(T.GetTexture(C.Textures.TTHealthTexture))
	HealthBar:CreateBackdrop(); HealthBar:ClearAllPoints()
	HealthBar:SetPoint("BOTTOMLEFT", HealthBar:GetParent(), "TOPLEFT", 0, 4)
	HealthBar:SetPoint("BOTTOMRIGHT", HealthBar:GetParent(), "TOPRIGHT", 0, 4)
	HealthBar.Backdrop:CreateShadow()
	if C.Tooltips.UnitHealthText then
		HealthBar.Text = HealthBar:CreateFontString(nil, "OVERLAY")
		HealthBar.Text:SetFontObject(T.GetFont(C.Tooltips.HealthFont))
		HealthBar.Text:SetPoint("CENTER", HealthBar, "CENTER", 0, 6)
	end
end

function Tooltip:SetItemBorderColor(tooltip)
	local Link = tooltip.GetItem and select(2, tooltip:GetItem())
	local Backdrop = tooltip.Backdrop
	if Backdrop then
		if Link then
			local Quality = select(3, GetItemInfo(Link))
			if Quality then Backdrop:SetBorderColor(GetItemQualityColor(Quality)) else Backdrop:SetBorderColor(unpack(C.General.BorderColor)) end
		else Backdrop:SetBorderColor(unpack(C.General.BorderColor)) end
	end
end

function Tooltip:OnTooltipSetItem()
	if IsShiftKeyDown() then
		local Link = self.GetItem and select(2, self:GetItem())
		if Link then
			local ID = "|cFFCA3C3CID|r "..Link:match(":(%w+)")
			local Level = GetDetailedItemLevelInfo(Link) or 1
			self:AddLine(" "); self:AddDoubleLine(ID, "|cFFCA3C3C"..ITEM_LEVEL_ABBR.."|r "..Level)
		end
	end
	if C.Tooltips.ItemBorderColor then Tooltip:SetItemBorderColor(self) end
end

function Tooltip:SetHealthValue(unit)
	if UnitIsDeadOrGhost(unit) then
		self.Text:SetText(DEAD)
	elseif T.Midnight then
		-- Unit health is secret on 12.1. Do not compare, divide, concatenate, or
		-- pass it through Tukui's legacy ShortValue formatter.
		self.Text:SetText("")
	else
		local Health, MaxHealth = UnitHealth(unit), UnitHealthMax(unit)
		local String = (Health and MaxHealth and T.ShortValue(Health).." / "..T.ShortValue(MaxHealth)) or "???"
		if not self.Text:IsShown() then self.Text:Show() end
		self.Text:SetText(String)
	end
end

function Tooltip:OnValueChanged()
	if not C.Tooltips.UnitHealthText then return end
	local unit = select(2, self:GetParent():GetUnit())
	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then unit = GMF:GetAttribute("unit") end
	end
	if unit then Tooltip.SetHealthValue(HealthBar, unit) end
end

function Tooltip:HideInCombat(event)
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then GameTooltip_Hide() end
end

function Tooltip:SetCompareItemBorderColor()
	for i=1,2 do
		local TT = _G["ShoppingTooltip"..i]
		if TT:IsShown() then
			local FrameLevel = GameTooltip:GetFrameLevel(); local Item = TT.GetItem and select(2, TT:GetItem())
			if FrameLevel == TT:GetFrameLevel() then TT:SetFrameLevel(i+1) end
			if Item then
				local Quality = select(3, GetItemInfo(Item))
				if Quality then TT.Backdrop:SetBorderColor(GetItemQualityColor(Quality)) else TT.Backdrop:SetBorderColor(unpack(C.General.BorderColor)) end
			end
		end
	end
end

function Tooltip:ResetBorderColor()
	if self ~= GameTooltip then return end
	if self.Backdrop then self.Backdrop:SetBorderColor(unpack(C.General.BorderColor)) end
	if HealthBar then
		HealthBar.Backdrop:SetBorderColor(0,1,0)
		if HealthBar.Text then HealthBar.Text:Hide() end
		HealthBar:SetStatusBarColor(unpack(T.Colors.reaction[8]))
	end
end

function Tooltip:SetBackdropStyle()
	self:SetBackdrop(Tooltip.BackdropStyle); self:SetBackdropColor(unpack(C.General.BackdropColor)); self:SetBackdropBorderColor(unpack(C.General.BackdropColor))
end

function Tooltip:AddHooks()
	hooksecurefunc("GameTooltip_SetDefaultAnchor", self.SetTooltipDefaultAnchor)
	if C.Tooltips.UnitBorderColor then
		hooksecurefunc("GameTooltip_UnitColor", self.SetUnitBorderColor)
		hooksecurefunc("GameTooltip_ShowCompareItem", self.SetCompareItemBorderColor)
	end
	if C.Tooltips.UnitBorderColor or C.Tooltips.ItemBorderColor then hooksecurefunc("GameTooltip_ClearMoney", self.ResetBorderColor) end
	if T.Retail and select(4, GetBuildInfo()) > 100000 then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, self.OnTooltipSetItem)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, self.OnTooltipSetUnit)
	else
		GameTooltip:HookScript("OnTooltipSetUnit", self.OnTooltipSetUnit); GameTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
	end
end

function Tooltip:Enable()
	if not C.Tooltips.Enable then return end
	self:CreateAnchor(); self:AddHooks(); self:SkinHealthBar()
	if C.Tooltips.HideInCombat then
		self:RegisterEvent("PLAYER_REGEN_DISABLED"); self:RegisterEvent("PLAYER_REGEN_ENABLED"); self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:SetScript("OnEvent", Tooltip.HideInCombat)
	end
	SetCVar("alwaysCompareItems", C.Tooltips.AlwaysCompareItems and 1 or 0)
	Tooltip.Skin(GameTooltip); Tooltip.Skin(ItemRefTooltip); Tooltip.Skin(EmbeddedItemTooltip); Tooltip.Skin(ShoppingTooltip1); Tooltip.Skin(ShoppingTooltip2)
	HealthBar:SetStatusBarColor(unpack(T.Colors.reaction[8])); HealthBar:Hide()
	if T.Retail then ItemRefTooltip.CloseButton:SkinCloseButton() end
	T.Movers:RegisterFrame(self.Anchor, "Tooltip")
end