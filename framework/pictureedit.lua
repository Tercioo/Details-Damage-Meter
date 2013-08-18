local _detalhes = _G._detalhes
local g = _detalhes.gump


	local window = g:NewPanel (UIParent, _, "DetailsImageEdit", _, 100, 100, false)
	window:SetPoint ("center", UIParent, "center")
	window:SetResizable (true)
	window:SetMovable (true)
	tinsert (UISpecialFrames, "DetailsImageEdit")
	
	local background = g:NewImage (window, _, "$parentBackground", _, _, _, nil, "background")
	background:SetAllPoints()
	background:SetTexture (0, 0, 0, .8)
	
	local edit_texture = g:NewImage (window, _, "$parentImage", _, 300, 250, nil, "artwork")
	edit_texture:SetPoint ("center", window, "center")
	
	local haveHFlip = false
	local haveVFlip = false
	
--> Top Slider
	
		local topCoordTexture = g:NewImage (window, _, "$parentImageTopCoord", _, _, _, _, "overlay")
		topCoordTexture:SetPoint ("topleft", window, "topleft")
		topCoordTexture:SetPoint ("topright", window, "topright")
		topCoordTexture.color = "red"
		topCoordTexture.height = 1
		topCoordTexture.alpha = .2
		
		local topSlider = g:NewSlider (window, _, "$parentTopSlider", "topSlider", 100, 100, 0.1, 100, 0.1, 0)
		topSlider:SetAllPoints (window.widget)
		topSlider:SetOrientation ("VERTICAL")
		topSlider.backdrop = nil
		topSlider.fractional = true
		topSlider:SetHook ("OnEnter", function() return true end)
		topSlider:SetHook ("OnLeave", function() return true end)

		local topSliderThumpTexture = topSlider:CreateTexture (nil, "overlay")
		topSliderThumpTexture:SetTexture (1, 1, 1)
		topSliderThumpTexture:SetWidth (512)
		topSliderThumpTexture:SetHeight (3)
		topSlider:SetThumbTexture (topSliderThumpTexture)

		topSlider:SetHook ("OnValueChange", function (_, _, value)
			topCoordTexture.image:SetHeight (window.frame:GetHeight()/100*value)
		end)
		
		topSlider:Hide()

--> Bottom Slider

		local bottomCoordTexture = g:NewImage (window, _, "$parentImageBottomCoord", _, _, _, _, "overlay")
		bottomCoordTexture:SetPoint ("bottomleft", window, "bottomleft", 0, 0)
		bottomCoordTexture:SetPoint ("bottomright", window, "bottomright", 0, 0)
		bottomCoordTexture.color = "red"
		bottomCoordTexture.height = 1
		bottomCoordTexture.alpha = .2

		local bottomSlider= g:NewSlider (window, _, "$parentBottomSlider", "bottomSlider", 100, 100, 0.1, 100, 0.1, 100)
		bottomSlider:SetAllPoints (window.widget)
		bottomSlider:SetOrientation ("VERTICAL")
		bottomSlider.backdrop = nil
		bottomSlider.fractional = true
		bottomSlider:SetHook ("OnEnter", function() return true end)
		bottomSlider:SetHook ("OnLeave", function() return true end)

		local bottomSliderThumpTexture = bottomSlider:CreateTexture (nil, "overlay")
		bottomSliderThumpTexture:SetTexture (1, 1, 1)
		bottomSliderThumpTexture:SetWidth (512)
		bottomSliderThumpTexture:SetHeight (3)
		bottomSlider:SetThumbTexture (bottomSliderThumpTexture)

		bottomSlider:SetHook ("OnValueChange", function (_, _, value)
			value = math.abs (value-100)
			bottomCoordTexture.image:SetHeight (math.max (window.frame:GetHeight()/100*value, 1))
		end)
		
		bottomSlider:Hide()
		
--> Left Slider
		
		local leftCoordTexture = g:NewImage (window, _, "$parentImageLeftCoord", _, _, _, _, "overlay")
		leftCoordTexture:SetPoint ("topleft", window, "topleft", 0, 0)
		leftCoordTexture:SetPoint ("bottomleft", window, "bottomleft", 0, 0)
		leftCoordTexture.color = "red"
		leftCoordTexture.width = 1
		leftCoordTexture.alpha = .2
		
		local leftSlider = g:NewSlider (window, _, "$parentLeftSlider", "leftSlider", 100, 100, 0.1, 100, 0.1, 0.1)
		leftSlider:SetAllPoints (window.widget)
		leftSlider.backdrop = nil
		leftSlider.fractional = true
		leftSlider:SetHook ("OnEnter", function() return true end)
		leftSlider:SetHook ("OnLeave", function() return true end)
		
		local leftSliderThumpTexture = leftSlider:CreateTexture (nil, "overlay")
		leftSliderThumpTexture:SetTexture (1, 1, 1)
		leftSliderThumpTexture:SetWidth (3)
		leftSliderThumpTexture:SetHeight (512)
		leftSlider:SetThumbTexture (leftSliderThumpTexture)
		
		leftSlider:SetHook ("OnValueChange", function (_, _, value)
			leftCoordTexture.image:SetWidth (window.frame:GetWidth()/100*value)
		end)
		
		leftSlider:Hide()
		
--> Right Slider
		
		local rightCoordTexture = g:NewImage (window, _, "$parentImageRightCoord", _, _, _, _, "overlay")
		rightCoordTexture:SetPoint ("topright", window, "topright", 0, 0)
		rightCoordTexture:SetPoint ("bottomright", window, "bottomright", 0, 0)
		rightCoordTexture.color = "red"
		rightCoordTexture.width = 1
		rightCoordTexture.alpha = .2
		
		local rightSlider = g:NewSlider (window, _, "$parentRightSlider", "rightSlider", 100, 100, 0.1, 100, 0.1, 100)
		rightSlider:SetAllPoints (window.widget)
		rightSlider.backdrop = nil
		rightSlider.fractional = true
		rightSlider:SetHook ("OnEnter", function() return true end)
		rightSlider:SetHook ("OnLeave", function() return true end)
		--[
		local rightSliderThumpTexture = rightSlider:CreateTexture (nil, "overlay")
		rightSliderThumpTexture:SetTexture (1, 1, 1)
		rightSliderThumpTexture:SetWidth (3)
		rightSliderThumpTexture:SetHeight (512)
		rightSlider:SetThumbTexture (rightSliderThumpTexture)
		--]]
		rightSlider:SetHook ("OnValueChange", function (_, _, value)
			value = math.abs (value-100)
			rightCoordTexture.image:SetWidth (math.max (window.frame:GetWidth()/100*value, 1))
		end)
		
		rightSlider:Hide()
		
--> Edit Buttons

	local buttonsBackground = g:NewPanel (UIParent, _, "DetailsImageEditButtonsBg", _, 115, 225)
	buttonsBackground:SetPoint ("topleft", window, "topright", 2, 0)
	buttonsBackground:Hide()
	--buttonsBackground:SetMovable (true)
	tinsert (UISpecialFrames, "DetailsImageEditButtonsBg")
	
		local alphaFrameShown = false
	
		local editingSide = nil
		local lastButton = nil
		local alphaFrame
		local originalColor = {0.9999, 0.8196, 0}
		
		local enableTexEdit = function (side, _, button)
			
			if (alphaFrameShown) then
				alphaFrame:Hide()
				alphaFrameShown = false
				button.text:SetTextColor (unpack (originalColor))
			end
			
			if (ColorPickerFrame:IsShown()) then
				ColorPickerFrame:Hide()
			end
			
			if (lastButton) then
				lastButton.text:SetTextColor (unpack (originalColor))
			end
			
			if (editingSide == side) then
				window [editingSide.."Slider"]:Hide()
				editingSide = nil
				return
				
			elseif (editingSide) then
				window [editingSide.."Slider"]:Hide()
			end

			editingSide = side
			button.text:SetTextColor (1, 1, 1)
			lastButton = button
			
			window [side.."Slider"]:Show()
		end
		
		local leftTexCoordButton = g:NewButton (buttonsBackground, _, "$parentLeftTexButton", _, 100, 20, enableTexEdit, "left", _, _, "Crop Left")
		leftTexCoordButton:SetPoint ("topleft", window, "topright", 10, -10)
		local rightTexCoordButton = g:NewButton (buttonsBackground, _, "$parentRightTexButton", _, 100, 20, enableTexEdit, "right", _, _, "Crop Right")
		rightTexCoordButton:SetPoint ("topleft", window, "topright", 10, -30)
		local topTexCoordButton = g:NewButton (buttonsBackground, _, "$parentTopTexButton", _, 100, 20, enableTexEdit, "top", _, _, "Crop Top")
		topTexCoordButton:SetPoint ("topleft", window, "topright", 10, -50)
		local bottomTexCoordButton = g:NewButton (buttonsBackground, _, "$parentBottomTexButton", _, 100, 20, enableTexEdit, "bottom", _, _, "Crop Bottom")
		bottomTexCoordButton:SetPoint ("topleft", window, "topright", 10, -70)
		leftTexCoordButton:InstallCustomTexture()
		rightTexCoordButton:InstallCustomTexture()
		topTexCoordButton:InstallCustomTexture()
		bottomTexCoordButton:InstallCustomTexture()
		
		local Alpha = g:NewButton (buttonsBackground, _, "$parentBottomAlphaButton", _, 100, 20, alpha, _, _, _, "Transparency")
		Alpha:SetPoint ("topleft", window, "topright", 10, -110)
		Alpha:InstallCustomTexture()
		
	--> overlay color
		local selectedColor = function (default)
			if (default) then
				edit_texture:SetVertexColor (unpack (default))
			else
				edit_texture:SetVertexColor (ColorPickerFrame:GetColorRGB())
			end
		end
		
		local changeColor = function()
		
			ColorPickerFrame.func = nil
			ColorPickerFrame.opacityFunc = nil
			ColorPickerFrame.cancelFunc = nil
			ColorPickerFrame.previousValues = nil
			
			local r, g, b = edit_texture:GetVertexColor()
			ColorPickerFrame:SetColorRGB (r, g, b)
			ColorPickerFrame:SetParent (buttonsBackground.widget)
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.previousValues = {r, g, b}
			ColorPickerFrame.func = selectedColor
			ColorPickerFrame.cancelFunc = selectedColor
			ColorPickerFrame:ClearAllPoints()
			ColorPickerFrame:SetPoint ("left", buttonsBackground.widget, "right")
			ColorPickerFrame:Show()
			
			if (alphaFrameShown) then
				alphaFrame:Hide()
				alphaFrameShown = false
				Alpha.button.text:SetTextColor (unpack (originalColor))
			end	
			
			if (lastButton) then
				lastButton.text:SetTextColor (unpack (originalColor))
				if (editingSide) then
					window [editingSide.."Slider"]:Hide()
				end
			end
		end
		
		local changeColorButton = g:NewButton (buttonsBackground, _, "$parentOverlayColorButton", _, 100, 20, changeColor, _, _, _, "Overlay Color")
		changeColorButton:SetPoint ("topleft", window, "topright", 10, -90)
		changeColorButton:InstallCustomTexture()
		
		alphaFrame = g:NewPanel (buttonsBackground, _, "DetailsImageEditAlphaBg", _, 40, 225)
		alphaFrame:SetPoint ("topleft", buttonsBackground, "topright", 2, 0)
		alphaFrame:Hide() 
		local alphaSlider = g:NewSlider (alphaFrame, _, "$parentAlphaSlider", "alphaSlider", 30, 220, 1, 100, 1, edit_texture:GetAlpha()*100)
		alphaSlider:SetPoint ("top", alphaFrame, "top", 0, -5)
		alphaSlider:SetOrientation ("VERTICAL")
		alphaSlider.thumb:SetSize (40, 30)
		--leftSlider.backdrop = nil
		--leftSlider.fractional = true
		
		local alpha = function(_, _, button)
		
			if (ColorPickerFrame:IsShown()) then
				ColorPickerFrame:Hide()
			end
		
			if (lastButton) then
				lastButton.text:SetTextColor (unpack (originalColor))
				if (editingSide) then
					window [editingSide.."Slider"]:Hide()
				end
			end
		
			if (not alphaFrameShown) then
				alphaFrame:Show()
				alphaSlider:SetValue (edit_texture:GetAlpha()*100)
				alphaFrameShown = true
				button.text:SetTextColor (1, 1, 1)
			else
				alphaFrame:Hide()
				alphaFrameShown = false
				button.text:SetTextColor (unpack (originalColor))
			end
		end
		
		Alpha.clickfunction = alpha
		
		alphaSlider:SetHook ("OnValueChange", function (_, _, value)
			edit_texture:SetAlpha (value/100)
		end)

		local resizer = CreateFrame ("Button", nil, window.widget)
		resizer:SetNormalTexture ("Interface\\AddOns\\Details\\images\\ResizeGripD")
		resizer:SetHighlightTexture ("Interface\\AddOns\\Details\\images\\ResizeGripD")
		resizer:SetWidth (16)
		resizer:SetHeight (16)
		resizer:SetPoint ("BOTTOMRIGHT", window.widget, "BOTTOMRIGHT", 0, 0)
		resizer:EnableMouse (true)
		resizer:SetFrameLevel (window.widget:GetFrameLevel() + 2)
		
		resizer:SetScript ("OnMouseDown", function (self, button) 
			window.widget:StartSizing ("BOTTOMRIGHT")
		end)
		
		resizer:SetScript ("OnMouseUp", function (self, button) 
			window.widget:StopMovingOrSizing()
		end)
		
		window.widget:SetScript ("OnMouseDown", function()
			window.widget:StartMoving()
		end)
		window.widget:SetScript ("OnMouseUp", function()
			window.widget:StopMovingOrSizing()
		end)
		
		window.widget:SetScript ("OnSizeChanged", function()
			edit_texture.width = window.width
			edit_texture.height = window.height
			leftSliderThumpTexture:SetHeight (window.height)
			rightSliderThumpTexture:SetHeight (window.height)
			topSliderThumpTexture:SetWidth (window.width)
			bottomSliderThumpTexture:SetWidth (window.width)
			
			rightCoordTexture.image:SetWidth (math.max ( (window.frame:GetWidth() / 100 * math.abs (rightSlider:GetValue()-100)), 1))
			leftCoordTexture.image:SetWidth (window.frame:GetWidth()/100*leftSlider:GetValue())
			bottomCoordTexture:SetHeight (math.max ( (window.frame:GetHeight() / 100 * math.abs (bottomSlider:GetValue()-100)), 1))
			topCoordTexture:SetHeight (window.frame:GetHeight()/100*topSlider:GetValue())
		end)
		
	--> change size
		local resizeLabel = g:NewLabel (window, _, "$parentResizerIndicator", _, "RESIZE", _, 9)
		resizeLabel:SetPoint ("right", resizer, "left", -2, 0)
		
	--> flip
		local flip = function (side)
			if (side == 1) then
				if (not haveHFlip) then
					if (not haveVFlip) then
						edit_texture:SetTexCoord (1, 0, 0, 1)
					else
						edit_texture:SetTexCoord (1, 0, 1, 0)
					end
					rightCoordTexture:Hide()
					leftCoordTexture:Hide()
					rightSlider:Hide()
					leftSlider:Hide()
					leftTexCoordButton:Disable()
					rightTexCoordButton:Disable()
				else
					if (not haveVFlip) then
						edit_texture:SetTexCoord (0, 1, 0, 1)
					else
						edit_texture:SetTexCoord (0, 1, 1, 0)
					end
					rightCoordTexture:Show()
					leftCoordTexture:Show()
					leftTexCoordButton:Enable()
					rightTexCoordButton:Enable()
				end
				haveHFlip = not haveHFlip

			elseif (side == 2) then
				if (not haveVFlip) then
					if (not haveHFlip) then
						edit_texture:SetTexCoord (0, 1, 1, 0)
					else
						edit_texture:SetTexCoord (1, 0, 1, 0)
					end
					topCoordTexture:Hide()
					bottomCoordTexture:Hide()
					topSlider:Hide()
					bottomSlider:Hide()
					topTexCoordButton:Disable()
					bottomTexCoordButton:Disable()
				else
					if (not haveHFlip) then
						edit_texture:SetTexCoord (0, 1, 0, 1)
					else
						edit_texture:SetTexCoord (1, 0, 0, 1)
					end
					topCoordTexture:Show()
					bottomCoordTexture:Show()
					topTexCoordButton:Enable()
					bottomTexCoordButton:Enable()
				end
				haveVFlip = not haveVFlip
			end
		end
		
		local flipButtonH = g:NewButton (buttonsBackground, _, "$parentFlipButton", _, 100, 20, flip, 1, _, _, "Flip Horizontal")
		flipButtonH:SetPoint ("topleft", window, "topright", 10, -140)
		flipButtonH:InstallCustomTexture()
		--
		local flipButtonV = g:NewButton (buttonsBackground, _, "$parentFlipButton2", _, 100, 20, flip, 2, _, _, "Flip Vertical")
		flipButtonV:SetPoint ("topleft", window, "topright", 10, -160)
		flipButtonV:InstallCustomTexture()
		
	--> accept
		local accept = function()
			buttonsBackground:Hide()
			window:Hide()
			alphaFrame:Hide()
			ColorPickerFrame:Hide()
			
			local coords = {}
			if (haveHFlip) then
				coords [1] = 1
				coords [2] = 0
			else
				coords [1] = leftSlider.value/100
				coords [2] = rightSlider.value /100
			end
			
			if (haveVFlip) then
				coords [3] = 1
				coords [4] = 0
			else
				coords [3] = topSlider.value/100
				coords [4] = bottomSlider.value/100
			end

			return window.callback_func (edit_texture.width, edit_texture.height, {edit_texture:GetVertexColor()}, edit_texture:GetAlpha(), coords, window.extra_param)
		end
		
		local acceptButton = g:NewButton (buttonsBackground, _, "$parentAcceptButton", _, 100, 20, accept, _, _, _, "DONE")
		acceptButton:SetPoint ("topleft", window, "topright", 10, -200)
		acceptButton:InstallCustomTexture()

		-- fazer botao de editar a cor
		-- fazer botao de editar o tamanho
		-- fazer botao de okey e retornar os valores
		
		
window:Hide()
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		local ttexcoord
		function g:ImageEditor (callback, texture, texcoord, colors, width, height, extraParam)
		
			edit_texture:SetTexture (texture)
			edit_texture.width = width
			edit_texture.height = height
			
			colors = colors or {1, 1, 1, 1}
			edit_texture:SetVertexColor (colors [1], colors [2], colors [3])
			
			edit_texture:SetAlpha (colors [4] or 1)
			
			texcoord = texcoord or {0, 1, 0, 1}
			ttexcoord = texcoord
			
			_detalhes:ScheduleTimer ("RefreshImageEditor", 0.2)
			
			window:Show()
			window.callback_func = callback
			window.extra_param = extraParam
			buttonsBackground:Show()
		end
		
		function _detalhes:RefreshImageEditor()
		
			window.width = edit_texture.width
			window.height = edit_texture.height
			
			if (ttexcoord[1] == 1 and ttexcoord[2] == 0) then
				haveHFlip = false
				flip (1)
			else
				haveHFlip = true
				flip (1)
				leftSlider:SetValue (ttexcoord[1]*100)
				rightSlider:SetValue (ttexcoord[2]*100)
			end
			
			if (ttexcoord[3] == 1 and ttexcoord[4] == 0) then
				haveVFlip = false
				flip (2)
			else
				haveVFlip = true
				flip (2)
				topSlider:SetValue (ttexcoord[3]*100)
				bottomSlider:SetValue (ttexcoord[4]*100)
			end

		end
		