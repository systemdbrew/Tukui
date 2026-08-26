local T, C, L = unpack((select(2, ...)))

local Auras = T["Auras"]
local unpack = unpack
local GetTime = GetTime
local DebuffTypeColor = DebuffTypeColor
local BuffFrame = BuffFrame
local DebuffFrame = DebuffFrame
local TemporaryEnchantFrame = TemporaryEnchantFrame
local InterfaceOptionsFrameCategoriesButton12 = InterfaceOptionsFrameCategoriesButton12
local UnitAura = UnitAura or T.UnitAura

Auras.Headers = {}
Auras.FlashTimer = 30

function Auras:DisableBlizzardAuras()
	-- WoW 12.1 removed SecureAuraHeaderTemplate and introduced AuraContainer.
	-- Keep Blizzard's player aura containers intact until Tukui's aura module is
	-- ported to the new Retail API; hiding them here would leave the player with
	-- no buff/debuff display at all.
	if T.Midnight then
		return
	end

	if BuffFrame then
		BuffFrame:SetParent(T.Hider)
	end
	
	if DebuffFrame then
		DebuffFrame:SetParent(T.Hider)
	end
	
	if TemporaryEnchantFrame then
		TemporaryEnchantFrame:SetParent(T.Hider)
	end
	
	if InterfaceOptionsFrameCategoriesButton12 then
		InterfaceOptionsFrameCategoriesButton12:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton12:SetAlpha(0)
	end
end

function Auras:StartOrStopFlash(timeleft)
	if(timeleft < Auras.FlashTimer) then
		if(not self:IsPlaying()) then
			self:Play()
		end
	elseif(self:IsPlaying()) then
		self:Stop()
	end
end

function Auras:OnUpdate(elapsed)
	local TimeLeft

	if(self.Enchant) then
		local Expiration = select(self.Enchant, GetWeaponEnchantInfo())

		if(Expiration) then
			TimeLeft = Expiration / 1e3
		else
			TimeLeft = 0
		end
	else
		TimeLeft = self.TimeLeft - elapsed
	end

	self.TimeLeft = TimeLeft

	if(TimeLeft <= 0) then
		self.TimeLeft = nil
		self.Duration:SetText("")

		if self.Enchant then
			self.Dur = nil
		end

		return self:SetScript("OnUpdate", nil)
	else
		local Text = T.FormatTime(TimeLeft)
		local r, g, b = T.ColorGradient(self.TimeLeft, self.Dur, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)

		if self.Enchant then
			self.Bar:SetMinMaxValues(0, self.Dur)
		end

		self.Bar:SetValue(self.TimeLeft)
		self.Bar:SetStatusBarColor(r, g, b)

		if(TimeLeft < 60.5) then
			if C.Auras.Flash then
				Auras.StartOrStopFlash(self.Animation, TimeLeft)
			end

			if(TimeLeft < 5) then
				self.Duration:SetTextColor(255/255, 20/255, 20/255)
			else
				self.Duration:SetTextColor(255/255, 165/255, 0/255)
			end
		else
			if self.Animation and self.Animation:IsPlaying() then
				self.Animation:Stop()
			end

			self.Duration:SetTextColor(.9, .9, .9)
		end

		self.Duration:SetText(Text)
	end
end

function Auras:UpdateAura(index)
	local Name, Icon, Count, DebuffType, Duration, ExpirationTime, Caster, CanStealOrPurge, NameplateShowPersonal, SpellID, CanApplyAura, IsBossDebuff, CastByPlayer, NameplateShowAll, TimeMod, Value1, Value2, Value3 = UnitAura("player", index, self.Filter)
	local Button = self

	if (not Name) then
		return
	end

	Button.Icon:SetTexture(Icon)
	Button.Count:SetText(Count > 1 and Count or "")
	Button.SpellID = SpellID
	Button.Caster = Caster
	Button.Filter = self.Filter
	Button.Duration:SetText("")
	Button.TimeLeft = nil
	Button.Dur = nil
	Button:SetScript("OnUpdate", nil)

	if (Duration and Duration > 0) then
		Button.TimeLeft = ExpirationTime - GetTime()
		Button.Dur = Duration
		Button:SetScript("OnUpdate", Auras.OnUpdate)
	end

	if (DebuffType and DebuffTypeColor and DebuffTypeColor[DebuffType]) then
		local Color = DebuffTypeColor[DebuffType]
		Button.Backdrop:SetBorderColor(Color.r, Color.g, Color.b)
	else
		Button.Backdrop:SetBorderColor(unpack(C.General.BorderColor))
	end
end

function Auras:OnEnterWorld()
	for _, Header in pairs(Auras.Headers) do
		local Child = Header:GetAttribute("child1")
		local i = 1
		while(Child) do
			Auras.UpdateAura(Child, Child:GetID())

			i = i + 1
			Child = Header:GetAttribute("child" .. i)
		end
	end
end

function Auras:LoadVariables() -- to be completed
	local Headers = Auras.Headers
	local Buffs = Headers[1]
	local Debuffs = Headers[2]

	if not Buffs or not Debuffs then
		return
	end

	local Position = Buffs:GetPoint()

	if Position and Position:match("LEFT") then
		Buffs:SetAttribute("xOffset", 35)
		Buffs:SetAttribute("point", Position)
		Debuffs:SetAttribute("xOffset", 35)
		Debuffs:SetAttribute("point", Position)
	end
end

function Auras:Enable()
	if not C.Auras.Enable then
		return
	end

	-- Retail 12.1 replaced SecureAuraHeaderTemplate with the new AuraContainer
	-- system. Do not create Tukui's legacy headers yet; leave Blizzard auras
	-- visible while the Tukui presentation is ported to AuraContainer.
	if T.Midnight then
		return
	end

	self:DisableBlizzardAuras()
	self:CreateHeaders()

	local EnterWorld = CreateFrame("Frame")
	EnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
	EnterWorld:SetScript("OnEvent", function(self, event)
		Auras:OnEnterWorld()
	end)
end