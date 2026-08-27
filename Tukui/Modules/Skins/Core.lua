local T, C, L = unpack((select(2, ...)))

if not T.Retail then return end

local Skins = T["Skins"]

function Skins:SkinFrame(frame, transparent)
	if not frame or frame.TukuiSkinned then return end

	if frame.StripTextures then
		frame:StripTextures()
	end

	if frame.CreateBackdrop then
		frame:CreateBackdrop(transparent and "Transparent" or nil)
		if frame.Backdrop and frame.Backdrop.CreateShadow then
			frame.Backdrop:CreateShadow()
		end
	end

	frame.TukuiSkinned = true
end

function Skins:SkinItemButton(button)
	if not button or button.TukuiSkinned then return end

	local icon = button.icon or button.Icon or button.IconTexture

	if button.StripTextures then
		button:StripTextures()
	end

	if button.CreateBackdrop then
		button:CreateBackdrop()
		if button.Backdrop and button.Backdrop.CreateShadow then
			button.Backdrop:CreateShadow()
		end
	end

	if button.StyleButton then
		button:StyleButton()
	end

	if icon then
		if icon.SetInside then
			icon:SetInside(button.Backdrop or button)
		end
		icon:SetTexCoord(unpack(T.IconCoord))
	end

	local border = button.IconBorder or button.iconBorder
	if border then
		border:SetTexture(nil)
	end

	button.TukuiSkinned = true
end
