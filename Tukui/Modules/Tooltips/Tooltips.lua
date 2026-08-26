local T, C, L = unpack((select(2, ...)))

local Tooltip = T["Tooltips"]
local HealthBar = GameTooltipStatusBar
local TruncateWhenZero = C_StringUtil and C_StringUtil.TruncateWhenZero

-- WoW 12.1 can return secret unit-health values. Blizzard's string helper is
-- allowed to consume those values, while addon-side comparisons/arithmetic are
-- not. Keep Tukui's health text without routing secret values through ShortValue.
local function FormatHealthValue(value)
	if T.Midnight then
		return TruncateWhenZero and TruncateWhenZero(value) or nil
	end

	return T.ShortValue(value)
end

-- Preserve the rest of Tukui's tooltip implementation below.
