local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local frame_metatable = Private.frame_metatable

local colorMixin = {
	SetRGBA = function(self, r, g, b, a)
		if(r > 1 or g > 1 or b > 1) then
			r, g, b = r / 255, g / 255, b / 255
		end

		self.r = r
		self[1] = r
		self.g = g
		self[2] = g
		self.b = b
		self[3] = b
		self.a = a

		self.hex = string.format('ff%02x%02x%02x', self:GetRGBAsBytes())
	end,
	SetAtlas = function(self, atlas)
		self.atlas = atlas
	end,
	GetAtlas = function(self)
		return self.atlas
	end,
	GenerateHexColor = function(self)
		return self.hex
	end,
}

function oUF:CreateColor(r, g, b, a)
	local color = Mixin({}, ColorMixin, colorMixin)
	color:SetRGBA(r, g, b, a)

	return color
end

local colors = {
	smooth = {
		1, 0, 0,
		1, 1, 0,
		0, 1, 0
	},
	health = oUF:CreateColor(49, 207, 37),
	disconnected = oUF:CreateColor(0.6, 0.6, 0.6),
	tapped = oUF:CreateColor(0.6, 0.6, 0.6),
	runes = {
		oUF:CreateColor(247, 65, 57),
		oUF:CreateColor(148, 203, 247),
		oUF:CreateColor(173, 235, 66),
	},
	selection = {
		[ 0] = oUF:CreateColor(255, 0, 0),
		[ 1] = oUF:CreateColor(255, 129, 0),
		[ 2] = oUF:CreateColor(255, 255, 0),
		[ 3] = oUF:CreateColor(0, 255, 0),
		[ 4] = oUF:CreateColor(0, 0, 255),
		[ 5] = oUF:CreateColor(96, 96, 255),
		[ 6] = oUF:CreateColor(170, 170, 255),
		[ 7] = oUF:CreateColor(170, 255, 170),
		[ 8] = oUF:CreateColor(83, 201, 255),
		[ 9] = oUF:CreateColor(128, 128, 128),
		[12] = oUF:CreateColor(255, 255, 139),
		[13] = oUF:CreateColor(0, 153, 0),
	},
	class = {},
	debuff = {},
	reaction = {},
	power = {},
	threat = {},
}

local function customClassColors()
	if(_G.CUSTOM_CLASS_COLORS) then
		local function updateColors()
			for classToken, color in next, _G.CUSTOM_CLASS_COLORS do
				colors.class[classToken] = oUF:CreateColor(color.r, color.g, color.b)
			end

			for _, obj in next, oUF.objects do
				obj:UpdateAllElements('CUSTOM_CLASS_COLORS')
			end
		end

		updateColors()
		_G.CUSTOM_CLASS_COLORS:RegisterCallback(updateColors)

		return true
	end
end

if(not customClassColors()) then
	for classToken, color in next, _G.RAID_CLASS_COLORS do
		colors.class[classToken] = oUF:CreateColor(color.r, color.g, color.b)
	end

	local eventHandler = CreateFrame('Frame')
	eventHandler:RegisterEvent('ADDON_LOADED')
	eventHandler:SetScript('OnEvent', function(self)
		if(customClassColors()) then
			self:UnregisterEvent('ADDON_LOADED')
			self:SetScript('OnEvent', nil)
		end
	end)
end

local DebuffTypeColor = _G.DebuffTypeColor or {
	none = { r = 0.80, g = 0.00, b = 0.00 },
	Magic = { r = 0.20, g = 0.60, b = 1.00 },
	Curse = { r = 0.60, g = 0.00, b = 1.00 },
	Disease = { r = 0.60, g = 0.40, b = 0.00 },
	Poison = { r = 0.00, g = 0.60, b = 0.00 },
	Enrage = { r = 1.00, g = 0.50, b = 0.00 },
	Bleed = { r = 1.00, g = 0.20, b = 0.60 },
}

for debuffType, color in next, DebuffTypeColor do
	colors.debuff[debuffType] = oUF:CreateColor(color.r, color.g, color.b)
end

for eclass, color in next, _G.FACTION_BAR_COLORS do
	colors.reaction[eclass] = oUF:CreateColor(color.r, color.g, color.b)
end

local staggerIndices = {
	green = 1,
	yellow = 2,
	red = 3,
}

for power, color in next, PowerBarColor do
	if (type(power) == 'string') then
		if(color.r) then
			colors.power[power] = oUF:CreateColor(color.r, color.g, color.b)

			if(color.atlas) then
				colors.power[power]:SetAtlas(color.atlas)
			end
		else
			colors.power[power] = {}

			for name, color_ in next, color do
				local index = staggerIndices[name]
				if(index) then
					colors.power[power][index] = oUF:CreateColor(color_.r, color_.g, color_.b)

					if(color_.atlas) then
						colors.power[power][index]:SetAtlas(color_.atlas)
					end
				end
			end
		end
	end
end

colors.power[Enum.PowerType.Mana or 0] = colors.power.MANA
colors.power[Enum.PowerType.Rage or 1] = colors.power.RAGE
colors.power[Enum.PowerType.Focus or 2] = colors.power.FOCUS
colors.power[Enum.PowerType.Energy or 3] = colors.power.ENERGY
colors.power[Enum.PowerType.ComboPoints or 4] = colors.power.COMBO_POINTS
colors.power[Enum.PowerType.Runes or 5] = colors.power.RUNES
colors.power[Enum.PowerType.RunicPower or 6] = colors.power.RUNIC_POWER
colors.power[Enum.PowerType.SoulShards or 7] = colors.power.SOUL_SHARDS
colors.power[Enum.PowerType.LunarPower or 8] = colors.power.LUNAR_POWER
colors.power[Enum.PowerType.HolyPower or 9] = colors.power.HOLY_POWER
colors.power[Enum.PowerType.Maelstrom or 11] = colors.power.MAELSTROM
colors.power[Enum.PowerType.Insanity or 13] = colors.power.INSANITY
colors.power[Enum.PowerType.Fury or 17] = colors.power.FURY
colors.power[Enum.PowerType.Pain or 18] = colors.power.PAIN
colors.power[Enum.PowerType.Chi or 12] = colors.power.CHI
colors.power[Enum.PowerType.ArcaneCharges or 16] = colors.power.ARCANE_CHARGES
colors.power.ESSENCE = oUF:CreateColor(100, 173, 206)
colors.power[Enum.PowerType.Essence or 19] = colors.power.ESSENCE
colors.power.ALTERNATE = oUF:CreateColor(0.7, 0.7, 0.6)
colors.power[Enum.PowerType.Alternate or 10] = colors.power.ALTERNATE

for i = 0, 3 do
	colors.threat[i] = oUF:CreateColor(GetThreatStatusColor(i))
end

local function colorsAndPercent(a, b, ...)
	if(a <= 0 or b == 0) then
		return nil, ...
	elseif(a >= b) then
		return nil, select(-3, ...)
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf((a / b) * (num - 1))
	return relperc, select((segment * 3) + 1, ...)
end

function oUF:RGBColorGradient(a, b, ...)
	local relperc, r1, g1, b1, r2, g2, b2 = colorsAndPercent(a, b, ...)
	if(not relperc) then
		return r1, g1, b1
	end

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

function oUF:ColorGradient(a, b, ...)
	local colors_ = {...}
	local colorCount = #colors_
	if(colorCount == 0) then
		return
	elseif(colorCount == 1 or a <= 0) then
		return colors_[1]:GetRGB()
	elseif(a >= b) then
		return colors_[colorCount]:GetRGB()
	end

	local num = colorCount - 1
	local segment, relperc = math.modf((a / b) * num)
	local r1, g1, b1 = colors_[segment + 1]:GetRGB()
	local r2, g2, b2 = colors_[segment + 2]:GetRGB()

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

function oUF:UpdateAllColors()
	for _, obj in next, oUF.objects do
		obj:UpdateAllElements('UpdateAllColors')
	end
end

-- Frame userdata inherit methods through frame_metatable.__index. Assigning
-- colors directly to frame_metatable does not make self.colors visible to the
-- Health/Power elements. Put the shared palette on the actual __index object.
frame_metatable.__index.colors = colors
frame_metatable.colors = colors
oUF.colors = colors