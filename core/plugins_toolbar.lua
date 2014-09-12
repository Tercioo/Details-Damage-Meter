--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	-- none

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions

	--> create a button which will be displayed on tooltip
	function _detalhes.ToolBar:NewPluginToolbarButton (func, icon, pluginname, tooltip, w, h, framename)

		--> random name if nameless
		if (not framename) then
			framename = "DetailsToolbarButton" .. math.random (1, 100000)
		end

		--> create button from template
		local button = CreateFrame ("button", framename, _detalhes.listener, "DetailsToolbarButton")
		
		--> sizes
		if (w) then
			button:SetWidth (w)
		end
		if (h) then
			button:SetHeight (h)
		end
		
		button.x = 0
		button.y = 0
		
		--> tooltip and function on click
		button.tooltip = tooltip
		button:SetScript ("OnClick", func)

		--> textures
		button:SetNormalTexture (icon)
		button:SetPushedTexture (icon)
		button:SetDisabledTexture (icon)
		button:SetHighlightTexture (icon, "ADD")
		button.__icon = icon
		button.__name = pluginname
		
		--> blizzard built-in animation
		local FourCornerAnimeFrame = CreateFrame ("frame", framename.."Blink", button, "IconIntroAnimTemplate")
		FourCornerAnimeFrame:SetPoint ("center", button)
		FourCornerAnimeFrame:SetWidth (w or 14)
		FourCornerAnimeFrame:SetHeight (w or 14)
		FourCornerAnimeFrame.glow:SetScript ("OnFinished", nil)
		button.blink = FourCornerAnimeFrame
		
		_detalhes.ToolBar.AllButtons [#_detalhes.ToolBar.AllButtons+1] = button
		
		return button
	end
	
	--> show your plugin icon on tooltip
	function _detalhes:ShowToolbarIcon (Button, Effect)

		local LastIcon
		
		--> get the lower number instance
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (not lower_instance) then
			return
		end
		
		local instance = _detalhes:GetInstance (lower_instance)
		
		if (#_detalhes.ToolBar.Shown > 0) then
			--> already shown
			if (_detalhes:tableIN (_detalhes.ToolBar.Shown, Button)) then
				return
			end
			LastIcon = _detalhes.ToolBar.Shown [#_detalhes.ToolBar.Shown]
		else
			LastIcon = instance.baseframe.cabecalho.report
		end
		
		local x = 0
		if (instance.consolidate) then
			LastIcon = instance.consolidateButtonTexture
			x = x - 3
		end

		_detalhes.ToolBar.Shown [#_detalhes.ToolBar.Shown+1] = Button
		Button:SetPoint ("left", LastIcon.widget or LastIcon, "right", Button.x + x, Button.y)
		Button:Show()
		
		if (Effect) then
			if (type (Effect) == "string") then
				if (Effect == "blink") then
					Button.blink.glow:Play()
				elseif (Effect == "star") then
					Button.StarAnim:Play()
				end
			elseif (Effect) then
				Button.blink.glow:Play()
			end
		end
		
		_detalhes.ToolBar:ReorganizeIcons (true)
		
		return true
	end

	--> hide your plugin icon from toolbar
	function _detalhes:HideToolbarIcon (Button)
		
		local index = _detalhes:tableIN (_detalhes.ToolBar.Shown, Button)
		
		if (not index) then
			--> current not shown
			return
		end
		
		Button:Hide()
		table.remove (_detalhes.ToolBar.Shown, index)
		
		--> reorganize icons
		_detalhes.ToolBar:ReorganizeIcons (true)
		
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions

	--[[global]] function DetailsToolbarButtonOnEnter (button)
	
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (lower_instance) then
			_detalhes.OnEnterMainWindow (_detalhes:GetInstance (lower_instance), button, 3)
		end
	
		if (button.tooltip) then
		
			GameCooltip:Reset()
			
			--GameCooltip:SetOption ("FixedWidth", 200)
			GameCooltip:SetOption ("ButtonsYMod", -3)
			GameCooltip:SetOption ("YSpacingMod", -3)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)
			
			GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
			
			--[[title]] GameCooltip:AddLine (button.__name, nil, 1, "orange", nil, 12, SharedMedia:Fetch ("font", "Friz Quadrata TT"))
				GameCooltip:AddIcon (button.__icon, 1, 1, 16, 16)
			----[[desc]] GameCooltip:AddLine (button.tooltip)
			
			GameCooltip:ShowCooltip (button, "tooltip")
		end
	end
	--[[global]] function DetailsToolbarButtonOnLeave (button)
	
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (lower_instance) then
			_detalhes.OnLeaveMainWindow (_detalhes:GetInstance (lower_instance), button, 3)
		end
	
		if (button.tooltip) then
			_detalhes.popup:ShowMe (false)
		end
	end	

	_detalhes:RegisterEvent (_detalhes.ToolBar, "DETAILS_INSTANCE_OPEN", "OnInstanceOpen")
	_detalhes:RegisterEvent (_detalhes.ToolBar, "DETAILS_INSTANCE_CLOSE", "OnInstanceClose")
	_detalhes.ToolBar.Enabled = true --> must have this member or wont receive the event
	_detalhes.ToolBar.__enabled = true

	function _detalhes.ToolBar:OnInstanceOpen() 
		_detalhes.ToolBar:ReorganizeIcons (true)
	end
	function _detalhes.ToolBar:OnInstanceClose() 
		_detalhes.ToolBar:ReorganizeIcons (true)
	end

	function _detalhes.ToolBar:ReorganizeIcons (just_refresh)
		--> get the lower number instance
		local lower_instance = _detalhes:GetLowerInstanceNumber()
	
		if (not lower_instance) then
			for _, ThisButton in ipairs (_detalhes.ToolBar.Shown) do 
				ThisButton:Hide()
			end
			return
		end

		local instance = _detalhes:GetInstance (lower_instance)

		if (not just_refresh) then
			for _, instancia in pairs (_detalhes.tabela_instancias) do 
				if (instancia.baseframe and instancia:IsAtiva()) then
					instancia:ReajustaGump()
				end
			end

			instance:ChangeSkin()
		else
			--instance:SetMenuAlpha()
			instance:ToolbarMenuButtons()
		end
		
		return true
	end
