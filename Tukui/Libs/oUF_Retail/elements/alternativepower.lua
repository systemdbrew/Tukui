--[[
# Element: Alternative Power Bar

Handles the visibility and updating of a status bar that displays encounter- or quest-related power information, such as
the number of hour glass charges during the Murozond encounter in the dungeon End Time.

## Widget

AlternativePower - A `StatusBar` used to represent the unit's alternative power.

## Notes

If mouse interactivity is enabled for the widget, `OnEnter` and/or `OnLeave` handlers will be set to display a tooltip.
A default texture will be applied if the widget is a StatusBar and doesn't have a texture set.
--]]

local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private
local unitSelectionType = Private.unitSelectionType
local issecretvalue = issecretvalue

-- sourced from Blizzard_UnitFrame/UnitPowerBarAlt.lua
local ALTERNATE_POWER_INDEX = Enum.PowerType.Alternate or 10
local ALTERNATE_POWER_NAME = 'ALTERNATE'
local IS_MIDNIGHT = (oUF.Interface or 0) >= 120000

local function updateTooltip(self)
	local name, tooltip = GetUnitPowerBarStringsByID(self.__barID)
	GameTooltip:SetText(name or '', 1, 1, 1)
	GameTooltip:AddLine(tooltip or '', nil, nil, nil, true)
	GameTooltip:Show()
end

local function onEnter(self)
	if(not self:IsVisible()) then return end
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:UpdateTooltip()
end

local function onLeave()
	GameTooltip:Hide()
end

local function UpdateColor(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= ALTERNATE_POWER_NAME) then return end
	local element = self.AlternativePower

	local r, g, b, color
	if(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		color = self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorPower) then
		color = self.colors.power[ALTERNATE_POWER_INDEX]
	elseif(element.colorClass and UnitIsPlayer(unit))
		or (element.colorClassNPC and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		color = self.colors.class[class]
	elseif(element.colorSelection and unitSelectionType(unit, element.considerSelectionInCombatHostile)) then
		color = self.colors.selection[unitSelectionType(unit, element.considerSelectionInCombatHostile)]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		color = self.colors.reaction[UnitReaction(unit, 'player')]
	elseif(element.colorSmooth) then
		if IS_MIDNIGHT then
			-- 12.1 alternative power can be secret. Do not compare/add/divide it in
			-- addon Lua; use the static alternate-power color while Blizzard owns
			-- the protected StatusBar value.
			color = self.colors.power[ALTERNATE_POWER_INDEX] or self.colors.health
		else
			local adjust = 0 - (element.min or 0)
			r, g, b = oUF:ColorGradient((element.cur or 1) + adjust, (element.max or 1) + adjust, unpack(element.smoothGradient or self.colors.smooth))
		end
	end

	if(color) then
		r, g, b = color[1], color[2], color[3]
	end

	if(b) then
		element:SetStatusBarColor(r, g, b)

		local bg = element.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

local function Update(self, event, unit, powerType)
	if(self.unit ~= unit or powerType ~= ALTERNATE_POWER_NAME) then return end
	local element = self.AlternativePower

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur, max, min
	local barInfo = element.__barInfo
	if(barInfo) then
		cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
		max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
		min = barInfo.minPower or 0
		element:SetMinMaxValues(min, max)
		element:SetValue(cur)
	end

	element.cur = cur
	element.min = min
	element.max = max

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, min, max)
	end
end

local function Path(self, ...)
	(self.AlternativePower.Override or Update) (self, ...)
	(self.AlternativePower.UpdateColor or UpdateColor) (self, ...)
end

local function Visibility(self, event, unit)
	if(unit ~= self.unit) then return end
	local element = self.AlternativePower

	local barID = UnitPowerBarID(unit)
	local barInfo = GetUnitPowerBarInfoByID(barID)
	element.__barID = barID
	element.__barInfo = barInfo

	local inParty = UnitInParty(unit)
	local inRaid = UnitInRaid(unit)
	local membershipSecret = issecretvalue and (issecretvalue(inParty) or issecretvalue(inRaid))
	local showOnRaid = barInfo and barInfo.showOnRaid and not membershipSecret and (inParty or inRaid)
	local isPlayer = UnitIsUnit(unit, 'player')
	local playerSecret = issecretvalue and issecretvalue(isPlayer)

	if(barInfo and (showOnRaid or not barInfo.hideFromOthers or (not playerSecret and isPlayer))) then
		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
		self:RegisterEvent('UNIT_MAXPOWER', Path)
		element:Show()
		Path(self, event, unit, ALTERNATE_POWER_NAME)
	else
		self:UnregisterEvent('UNIT_POWER_UPDATE', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
		element:Hide()
	end
end

local function VisibilityPath(self, ...)
	return (self.AlternativePower.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.AlternativePower
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_BAR_SHOW', VisibilityPath)
		self:RegisterEvent('UNIT_POWER_BAR_HIDE', VisibilityPath)

		if(element:IsObjectType('StatusBar') and not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if(element:IsMouseEnabled()) then
			if(not element:GetScript('OnEnter')) then element:SetScript('OnEnter', onEnter) end
			if(not element:GetScript('OnLeave')) then element:SetScript('OnLeave', onLeave) end
			if(not element.UpdateTooltip) then element.UpdateTooltip = updateTooltip end
		end

		if(unit == 'player' and PlayerPowerBarAlt) then
			PlayerPowerBarAlt:UnregisterEvent('UNIT_POWER_BAR_SHOW')
			PlayerPowerBarAlt:UnregisterEvent('UNIT_POWER_BAR_HIDE')
			PlayerPowerBarAlt:UnregisterEvent('PLAYER_ENTERING_WORLD')
		end

		return true
	end
end

local function Disable(self, unit)
	local element = self.AlternativePower
	if(element) then
		element:Hide()
		self:UnregisterEvent('UNIT_POWER_BAR_SHOW', VisibilityPath)
		self:UnregisterEvent('UNIT_POWER_BAR_HIDE', VisibilityPath)

		if(unit == 'player' and PlayerPowerBarAlt) then
			PlayerPowerBarAlt:RegisterEvent('UNIT_POWER_BAR_SHOW')
			PlayerPowerBarAlt:RegisterEvent('UNIT_POWER_BAR_HIDE')
			PlayerPowerBarAlt:RegisterEvent('PLAYER_ENTERING_WORLD')
		end
	end
end

oUF:AddElement('AlternativePower', VisibilityPath, Enable, Disable)
