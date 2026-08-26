-- Tukui Retail 12.1 compatibility shim
--
-- Midnight marks unit health, incoming-heal, and absorb values as secret.
-- This bundled legacy oUF HealthPrediction element performs Lua arithmetic and
-- comparisons on those values, which is forbidden and causes taint errors.
--
-- Keep the element registered so existing Tukui layouts can still assign
-- self.HealthPrediction without breaking oUF initialization, but do not
-- register prediction events or evaluate protected values. This will be
-- replaced with the modern CreateUnitHealPredictionCalculator-based
-- implementation in a later port.

local _, ns = ...
local oUF = ns.oUF

local function Path()
	-- Intentionally disabled on Retail 12.1.
end

local function Enable(self)
	local element = self.HealthPrediction
	if not element then
		return
	end

	element.__owner = self
	element.ForceUpdate = Path

	-- Ensure any legacy overlay bars remain visually inert.
	if element.myBar then
		element.myBar:SetValue(0)
		element.myBar:Hide()
	end
	if element.otherBar then
		element.otherBar:SetValue(0)
		element.otherBar:Hide()
	end
	if element.absorbBar then
		element.absorbBar:SetValue(0)
		element.absorbBar:Hide()
	end
	if element.healAbsorbBar then
		element.healAbsorbBar:SetValue(0)
		element.healAbsorbBar:Hide()
	end
	if element.overAbsorb then
		element.overAbsorb:Hide()
	end
	if element.overHealAbsorb then
		element.overHealAbsorb:Hide()
	end

	return true
end

local function Disable(self)
	local element = self.HealthPrediction
	if not element then
		return
	end

	if element.myBar then element.myBar:Hide() end
	if element.otherBar then element.otherBar:Hide() end
	if element.absorbBar then element.absorbBar:Hide() end
	if element.healAbsorbBar then element.healAbsorbBar:Hide() end
	if element.overAbsorb then element.overAbsorb:Hide() end
	if element.overHealAbsorb then element.overHealAbsorb:Hide() end
end

oUF:AddElement('HealthPrediction', Path, Enable, Disable)
