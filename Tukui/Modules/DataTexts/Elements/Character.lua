local T, C, L = unpack((select(2, ...)))

local DataText = T["DataTexts"]
local ClassColor = T.RGBToHex(unpack(T.Colors.class[T.MyClass]))

-- Retail no longer has a ranged weapon slot, while cloaks do have durability.
-- Keep a dedicated modern slot list instead of relying on the old locale table.
local DurabilitySlots = T.Retail and {
	{INVSLOT_HEAD, "Head", 1000},
	{INVSLOT_SHOULDER, "Shoulder", 1000},
	{INVSLOT_CHEST, "Chest", 1000},
	{INVSLOT_WAIST, "Waist", 1000},
	{INVSLOT_WRIST, "Wrist", 1000},
	{INVSLOT_HAND, "Hands", 1000},
	{INVSLOT_LEGS, "Legs", 1000},
	{INVSLOT_FEET, "Feet", 1000},
	{INVSLOT_BACK, "Back", 1000},
	{INVSLOT_MAINHAND, "Main Hand", 1000},
	{INVSLOT_OFFHAND, "Off Hand", 1000},
} or L.DataText.Slots

local Update = function(self)
	local Lowest = 1
	local FoundDurability = false

	for _, Slot in ipairs(DurabilitySlots) do
		-- Reset stale values first. An empty/indestructible slot returns nil.
		Slot[3] = 1000

		local Current, Max = GetInventoryItemDurability(Slot[1])
		if Current and Max and Max > 0 then
			local Value = Current / Max
			Slot[3] = Value
			FoundDurability = true

			if Value < Lowest then
				Lowest = Value
			end
		end
	end

	-- A character with no durability-bearing gear should read as 100%, not the
	-- old 1000 sentinel multiplied into 100000%.
	local durability = floor((FoundDurability and Lowest or 1) * 100)
	local r, g, b = T.ColorGradient(durability, 100, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)

	self.Text:SetFormattedText("Durability |cff%02x%02x%02x%s%%|r", r * 255, g * 255, b * 255, durability)
end

local OnEnter = function(self)
	PaperDollFrame_UpdateStats()

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()

	if T.Retail then
		-- Set attributes (WIP)
		GameTooltip:AddDoubleLine(ClassColor..T.MyName.."|r", T.MyRealm)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|CFFFFFFFF"..PET_BATTLE_STATS_LABEL.."|r")
		GameTooltip:AddDoubleLine("|CF00FFF00"..LEVEL.."|r", UnitLevel("player"))
		GameTooltip:AddDoubleLine("|CF00FFF00"..ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL.."|r", GetAverageItemLevel())
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|CF00FFF00"..SPELL_STAT1_NAME.."|r", UnitStat("player", LE_UNIT_STAT_STRENGTH))
		GameTooltip:AddDoubleLine("|CF00FFF00"..SPELL_STAT2_NAME.."|r", UnitStat("player", LE_UNIT_STAT_AGILITY))
		GameTooltip:AddDoubleLine("|CF00FFF00"..SPELL_STAT3_NAME.."|r", UnitStat("player", LE_UNIT_STAT_INTELLECT))
		GameTooltip:AddDoubleLine("|CF00FFF00"..SPELL_STAT4_NAME.."|r", UnitStat("player", LE_UNIT_STAT_STAMINA))
		GameTooltip:AddLine(" ")
	end

	if T.Classic then
		GameTooltip:AddDoubleLine(ClassColor..T.MyName.."|r "..UnitLevel("player"), T.MyRealm)
		GameTooltip:AddLine(" ")

		if CharacterStatFrame then
			for _, Frame in pairs(CharacterStatFrame) do
				local Name = _G[Frame.."Label"]
				local Value = _G[Frame.."StatText"]
				local Tooltip = _G[Frame].tooltip2
				local StatName, StatValue

				if Name:GetText() then
					StatName = "|cffff8000"..Name:GetText().."|r"
				end

				if Value:GetText() then
					StatValue = "|cffffffff"..Value:GetText().."|r"
				end

				if StatName and StatValue then
					if IsAlternativeTooltip then
						GameTooltip:AddLine("|CF00FFF00"..StatName.."|r |CFFFFFFFF"..StatValue.."|r")
					else
						GameTooltip:AddDoubleLine("|CF00FFF00"..StatName.."|r", "|CFFFFFFFF"..StatValue.."|r")
					end

					if Tooltip and IsAlternativeTooltip then
						Tooltip = string.gsub(Tooltip, "\n\n", " ")
						GameTooltip:AddLine(Tooltip, .75, .75, .75)
						GameTooltip:AddLine(" ")
					end
				end
			end
		end

		if not IsShiftKeyDown() then
			GameTooltip:AddLine(" ")
		end
	end

	local Lowest = 1
	for _, Slot in ipairs(DurabilitySlots) do
		if Slot[3] ~= 1000 and Slot[3] < Lowest then
			Lowest = Slot[3]
		end
	end

	GameTooltip:AddDoubleLine("|CFFFF8000"..DURABILITY..":|r", floor(Lowest * 100).."%")

	for _, Slot in ipairs(DurabilitySlots) do
		if Slot[3] ~= 1000 then
			local Green = Slot[3] * 2
			local Red = 1 - Green

			GameTooltip:AddDoubleLine(Slot[2]..":", floor(Slot[3] * 100).."%", .75, .75, .75, Red + 1, Green, 0)
		end
	end

	GameTooltip:Show()
end

local ToggleCharacter = function(self)
	if InCombatLockdown() then
		T.Print(ERR_NOT_IN_COMBAT)
		return
	end

	ToggleCharacter("PaperDollFrame")
end

local Enable = function(self)
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnMouseDown", ToggleCharacter)
	self:Update()
	self.Text:SetText(ClassColor..T.MyName.."|r")
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end

DataText:Register("Character", Enable, Disable, Update)
