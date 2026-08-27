local T, C, L = unpack((select(2, ...)))

if not T.Retail then return end

local Skins = T["Skins"]

function Skins:SkinFrame(frame, transparent)
	if not frame or frame.TukuiSkinned then return end
	if frame.StripTextures then frame:StripTextures() end
	if frame.CreateBackdrop then
		frame:CreateBackdrop(transparent and "Transparent" or nil)
		if frame.Backdrop and frame.Backdrop.CreateShadow then frame.Backdrop:CreateShadow() end
	end
	frame.TukuiSkinned = true
end

function Skins:SkinItemButton(button)
	if not button or button.TukuiSkinned then return end
	local icon = button.icon or button.Icon or button.IconTexture
	if button.StripTextures then button:StripTextures() end
	if button.CreateBackdrop then
		button:CreateBackdrop()
		if button.Backdrop and button.Backdrop.CreateShadow then button.Backdrop:CreateShadow() end
	end
	if button.StyleButton then button:StyleButton() end
	if icon then
		if icon.SetInside then icon:SetInside(button.Backdrop or button) end
		icon:SetTexCoord(unpack(T.IconCoord))
	end
	local border = button.IconBorder or button.iconBorder
	if border and border.SetTexture then border:SetTexture(nil) end
	button.TukuiSkinned = true
end

function Skins:SkinButton(button)
	if not button or button.TukuiButtonSkinned then return end
	if button.StripTextures then button:StripTextures() end
	if button.CreateBackdrop then button:CreateBackdrop() end
	if button.StyleButton then button:StyleButton() end
	button.TukuiButtonSkinned = true
end

function Skins:SkinEditBox(editbox)
	if not editbox or editbox.TukuiEditBoxSkinned then return end
	if editbox.StripTextures then editbox:StripTextures() end
	if editbox.CreateBackdrop then editbox:CreateBackdrop() end
	editbox.TukuiEditBoxSkinned = true
end

function Skins:SkinTab(tab)
	if not tab or tab.TukuiTabSkinned then return end
	if tab.StripTextures then tab:StripTextures() end
	if tab.CreateBackdrop then tab:CreateBackdrop() end
	if tab.StyleButton then tab:StyleButton() end
	local text = tab.Text or (tab.GetFontString and tab:GetFontString())
	if text then text:SetFontObject(T.GetFont(C["UnitFrames"].Font)) end
	tab.TukuiTabSkinned = true
end

function Skins:SkinIcon(icon, parent)
	if not icon or icon.TukuiIconSkinned then return end
	icon:SetTexCoord(unpack(T.IconCoord))
	local owner = parent or (icon.GetParent and icon:GetParent())
	if owner and owner.CreateBackdrop and not owner.Backdrop then owner:CreateBackdrop() end
	if icon.SetInside and owner then icon:SetInside(owner.Backdrop or owner) end
	icon.TukuiIconSkinned = true
end

function Skins:SkinStatusBar(bar)
	if not bar or bar.TukuiStatusBarSkinned then return end
	if bar.SetStatusBarTexture then bar:SetStatusBarTexture(T.GetTexture(C["Textures"].UFHealthTexture)) end
	if bar.CreateBackdrop then bar:CreateBackdrop() end
	bar.TukuiStatusBarSkinned = true
end

function Skins:SkinCloseButton(button)
	if not button or button.TukuiCloseSkinned then return end
	if button.SkinCloseButton then
		button:SkinCloseButton()
	else
		self:SkinButton(button)
	end
	button.TukuiCloseSkinned = true
end
