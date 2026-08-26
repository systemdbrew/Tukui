----------------------------------
-- Temporary code in this file! --
----------------------------------

local T, C, L = unpack((select(2, ...)))

local Temp = CreateFrame("Frame", nil, UIParent)

-- Midnight 12.1 can return secret values from unit health and power APIs.
-- Tukui's legacy formatting performs Lua comparisons/arithmetic on those
-- values, which is forbidden. Keep this compatibility layer temporary until
-- the unit-frame text paths are ported to the modern Retail APIs.
if T.Midnight then
	local UnitFrames = T["UnitFrames"]
	local issecretvalue = issecretvalue
	local TruncateWhenZero = C_StringUtil and C_StringUtil.TruncateWhenZero

	local function SecretSafeText(value)
		if issecretvalue and issecretvalue(value) then
			return TruncateWhenZero and TruncateWhenZero(value) or ""
		end

		return value
	end

	local LegacyShortValue = UnitFrames.ShortValue
	UnitFrames.ShortValue = function(self)
		if issecretvalue and issecretvalue(self) then
			return TruncateWhenZero and TruncateWhenZero(self) or ""
		end

		return LegacyShortValue(self)
	end

	UnitFrames.PostUpdatePower = function(self, unit, current, min, max)
		if not self.Value then
			return
		end

		local pType, pToken = UnitPowerType(unit)
		local Color = T.Colors.power[pToken]

		if Color then
			self.Value:SetTextColor(Color[1], Color[2], Color[3])
		end

		if UnitIsDead(unit) or UnitIsGhost(unit) then
			self.Value:SetText("")
		else
			self.Value:SetText(SecretSafeText(current) or "")
		end
	end

	UnitFrames.PostUpdateHealth = function(self, unit, min, max)
		if not self.Value then
			return
		end

		if not UnitIsConnected(unit) then
			self.Value:SetText("|cffD7BEA5" .. FRIENDS_LIST_OFFLINE .. "|r")
		elseif UnitIsDead(unit) then
			self.Value:SetText("|cffD7BEA5" .. DEAD .. "|r")
		elseif UnitIsGhost(unit) then
			self.Value:SetText("|cffD7BEA5" .. L.UnitFrames.Ghost .. "|r")
		else
			-- Do not compare, divide, or color-gradient secret health values.
			self.Value:SetTextColor(0.33, 0.59, 0.33)
			self.Value:SetText(SecretSafeText(min) or "")
		end
	end
end

-- TEMP for bugs fixes
function Temp:Enable()
	if T.Retail then
		-- Fix for right-cancel clicks not working on buff frame
		SetCVar("ActionButtonUseKeyDown", 0)
	end
	
	if T.WotLK then
		local Battleground = CreateFrame("Frame", nil, UIParent)
		Battleground:SetFrameStrata("HIGH")
		Battleground:SetSize(400, 60)
		Battleground:CreateBackdrop()
		Battleground:CreateShadow()
		Battleground:SetPoint("TOP", 0, -29)
		Battleground:Hide()
		Battleground:SetBorderColor(1.00, 0.95, 0.32)

		Battleground.Text1 = Battleground:CreateFontString(nil, "OVERLAY")
		Battleground.Text1:SetFontTemplate(C.Medias.Font, 16, "")
		Battleground.Text1:SetPoint("TOP", 0, -10)
		Battleground.Text1:SetTextColor(1.00, 0.95, 0.32)

		Battleground.Text2 = Battleground:CreateFontString(nil, "OVERLAY")
		Battleground.Text2:SetFontTemplate(C.Medias.Font, 16, "")
		Battleground.Text2:SetPoint("BOTTOM", 0, 10)
		Battleground.Text2:SetTextColor(1.00, 0.95, 0.32)
		Battleground.Text2:SetText("Right-click on minimap battleground button to enter")

		local Animation = Battleground:CreateAnimationGroup()
		Animation:SetLooping("BOUNCE")

		local FadeOut = Animation:CreateAnimation("Alpha")
		FadeOut:SetFromAlpha(1)
		FadeOut:SetToAlpha(0.8)
		FadeOut:SetDuration(0.2)
		FadeOut:SetSmoothing("IN_OUT")

		local function OnEvent()
			for i = 1, MAX_BATTLEFIELD_QUEUES do
				local Status, Map, InstanceID = GetBattlefieldStatus(i)

				if Status == "confirm" then
					local String = StaticPopup1Text:GetText()
					local Text = string.gsub(String, ",.*", "")

					StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")

					Battleground.Text1:SetText(Text)
					Battleground:Show()

					Animation:Play()

					T.Print(Text)

					return
				end
			end

			Battleground:Hide()
			Animation:Stop()
		end

		Battleground:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
		Battleground:SetScript("OnEvent", OnEvent)
	end
end

Temp:RegisterEvent("PLAYER_LOGIN")
Temp:SetScript("OnEvent", Temp.Enable)
