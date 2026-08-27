local _, ns = ...
local oUF = ns.oUF

-- sourced from Blizzard_UnitFrame/TargetFrame.lua
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5

-- sourced from Blizzard_FrameXMLBase/Shared/Constants.lua
local MEMBERS_PER_RAID_GROUP = _G.MEMBERS_PER_RAID_GROUP or 5

local hookedFrames = {}
local hookedNameplates = {}
local isArenaHooked = false
local isBossHooked = false
local isPartyHooked = false

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local function insecureHide(self)
	self:Hide()
end

local function resetParent(self, parent)
	if(parent ~= hiddenParent) then
		self:SetParent(hiddenParent)
	end
end

local function handleFrame(baseName, doNotReparent)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		if(not doNotReparent) then
			frame:SetParent(hiddenParent)

			if(not hookedFrames[frame]) then
				hooksecurefunc(frame, 'SetParent', resetParent)

				hookedFrames[frame] = true
			end
		end

		local health = frame.healthBar or frame.healthbar or frame.HealthBar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar or frame.ManaBar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar or frame.CastingBarFrame
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt or frame.PowerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end

		local buffFrame = frame.BuffFrame
		if(buffFrame) then
			buffFrame:UnregisterAllEvents()
		end

		local petFrame = frame.petFrame or frame.PetFrame
		if(petFrame) then
			petFrame:UnregisterAllEvents()
		end

		local totFrame = frame.totFrame
		if(totFrame) then
			totFrame:UnregisterAllEvents()
		end

		local classPowerBar = frame.classPowerBar
		if(classPowerBar) then
			classPowerBar:UnregisterAllEvents()
		end

		local ccRemoverFrame = frame.CcRemoverFrame
		if(ccRemoverFrame) then
			ccRemoverFrame:UnregisterAllEvents()
		end

		local debuffFrame = frame.DebuffFrame
		if(debuffFrame) then
			debuffFrame:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		handleFrame(PlayerFrame)
	elseif(unit == 'pet') then
		handleFrame(PetFrame)
	elseif(unit == 'target') then
		handleFrame(TargetFrame)
	elseif(unit == 'focus') then
		handleFrame(FocusFrame)
	elseif(unit:match('boss%d?$')) then
		if(not isBossHooked) then
			isBossHooked = true

			handleFrame(BossTargetFrameContainer)

			for i = 1, MAX_BOSS_FRAMES do
				handleFrame('Boss' .. i .. 'TargetFrame', true)
			end
		end
	elseif(unit:match('party%d?$')) then
		if(not isPartyHooked) then
			isPartyHooked = true

			handleFrame(PartyFrame)

			for frame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
				handleFrame(frame, true)
			end

			for i = 1, MEMBERS_PER_RAID_GROUP do
				handleFrame('CompactPartyFrameMember' .. i)
			end
		end
	elseif(unit:match('arena%d?$')) then
		if(not isArenaHooked) then
			isArenaHooked = true

			handleFrame(CompactArenaFrame)

			for _, frame in next, CompactArenaFrame.memberUnitFrames do
				handleFrame(frame, true)
			end
		end
	end
end

function oUF:DisableNamePlate(frame)
	if(not(frame and frame.UnitFrame)) then return end
	if(frame.UnitFrame:IsForbidden()) then return end

	if(not hookedNameplates[frame]) then
		frame.UnitFrame:HookScript('OnShow', insecureHide)

		hookedNameplates[frame] = true
	end

	-- Retail 12.1 can re-show/reinitialize the stock nameplate UnitFrame after
	-- acquisition. Hiding it in place is no longer sufficient and leaves the
	-- Blizzard name/health text drawn underneath Tukui's plate. Reparent the
	-- stock frame to our hidden parent, matching current oUF behavior.
	handleFrame(frame.UnitFrame)
end
