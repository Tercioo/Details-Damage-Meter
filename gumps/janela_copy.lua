do

	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump
	local _
--> panel
	
	function _detalhes:CreateCopyPasteWindow()
		local panel = DetailsFrameWork:NewPanel (UIParent, _, "DetailsCopy", _, 512, 128, false)
		tinsert (UISpecialFrames, "DetailsCopy")
		panel:SetFrameStrata ("FULLSCREEN")
		panel:SetPoint ("center", UIParent, "center")
		panel.locked = false
		
		DetailsFrameWork:NewImage (panel, "Interface\\AddOns\\Details\\images\\copy", 512, 128, "background", nil, "background", "$parentBackGround")
		panel.background:SetPoint()
		
		--> title
		DetailsFrameWork:NewLabel (panel, _, "$parentTitle", "title", "Paste & Copy", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
		panel.title:SetPoint ("center", panel, "center")
		panel.title:SetPoint ("top", panel, "top", 0, -18)
		
		--> close
		panel.fechar = CreateFrame ("Button", nil, panel.widget, "UIPanelCloseButton")
		panel.fechar:SetWidth (32)
		panel.fechar:SetHeight (32)
		panel.fechar:SetPoint ("TOPRIGHT", panel.widget, "TOPRIGHT", -1, -8)
		panel.fechar:SetText ("X")
		panel.fechar:SetFrameLevel (panel:GetFrameLevel()+2)
		
		panel.fechar:SetScript ("OnClick", function() 
			panel:Hide()
		end)
		
		DetailsFrameWork:NewTextEntry (panel, _, "$parentTextEntry", "text", 476, 14)
		panel.text:SetPoint (20, -106)
		panel.text:SetHook ("OnEditFocusLost", function() panel:Hide() end)
		panel.text:SetHook ("OnChar", function() panel:Hide() end)
		
		DetailsFrameWork:NewLabel (panel, _, _, "desc", "paste on your web browser address bar", "OptionsFontHighlightSmall", 12)
		panel.desc:SetPoint (340, -54)
		panel.desc.width = 150
		panel.desc.height = 25
		panel.desc.align = "|"
		panel.desc.color = "gray"
		
		panel:Hide()
	end
	
	function _detalhes:CopyPaste (link)
		_G.DetailsCopy.MyObject.text.text = link
		_G.DetailsCopy.MyObject.text:HighlightText()
		_G.DetailsCopy.MyObject:Show()
		_G.DetailsCopy.MyObject.text:SetFocus()

	end
end