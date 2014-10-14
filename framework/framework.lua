--> details main objects
local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local _type = type
local _unpack = unpack
local _
gump.LabelNameCounter = 1
gump.PictureNameCounter = 1
gump.BarNameCounter = 1
gump.DropDownCounter = 1
gump.PanelCounter = 1
gump.ButtonCounter = 1

gump.debug = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> points
function gump:CheckPoints (v1, v2, v3, v4, v5, object)

	--bg_esq:SetPoint ("topleft", DmgRankFrame, 10, -215)

	if (not v1 and not v2) then
		return "topleft", object.widget:GetParent(), "topleft", 0, 0
	end
	
	if (_type (v1) == "string") then
		local frameGlobal = _G [v1]
		if (frameGlobal and frameGlobal.GetObjectType) then
			return gump:CheckPoints (frameGlobal, v2, v3, v4, v5, object)
		end
		
	elseif (_type (v2) == "string") then
		local frameGlobal = _G [v2]
		if (frameGlobal and frameGlobal.GetObjectType) then
			return gump:CheckPoints (v1, frameGlobal, v3, v4, v5, object)
		end
	end
	
	if (_type (v1) == "string" and _type (v2) == "table") then --> :setpoint ("left", frame, _, _, _)
		if (not v3 or _type (v3) == "number") then --> :setpoint ("left", frame, 10, 10)
			v1, v2, v3, v4, v5 = v1, v2, v1, v3, v4
		--else
			--> :setpoint ("left", frame, "left", 10, 10)
		end
		
	elseif (_type (v1) == "string" and _type (v2) == "number") then --> :setpoint ("topleft", x, y)
		v1, v2, v3, v4, v5 = v1, object.widget:GetParent(), v1, v2, v3
		
	elseif (_type (v1) == "number") then --> :setpoint (x, y) 
		v1, v2, v3, v4, v5 = "topleft", object.widget:GetParent(), "topleft", v1, v2

	elseif (_type (v1) == "table") then --> :setpoint (frame, x, y)
		v1, v2, v3, v4, v5 = "topleft", v1, "topleft", v2, v3
		
	end
	
	if (not v2) then
		v2 = object.widget:GetParent()
	elseif (v2.dframework) then
		v2 = v2.widget
	end
	
	return v1 or "topleft", v2, v3 or "topleft", v4 or 0, v5 or 0
end
	

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> color scheme

function gump:NewColor (_colorname, _colortable, _green, _blue, _alpha)

	if (_type (_colorname) ~= "string") then
		return _detalhes:NewError ("color name must be a string.")
	end

	if (gump.alias_text_colors [_colorname]) then
		return _detalhes:NewError (_colorname .. " already exists.")
	end
	
	if (_type (_colortable) == "table") then
		if (_colortable[1] and _colortable[2] and _colortable[3]) then
			_colortable[4] = _colortable[4] or 1
			gump.alias_text_colors [_colorname] = _colortable
		else
			return _detalhes:NewError ("invalid color table.")
		end
	elseif (_colortable and _green and _blue) then
		_alpha = _alpha or 1
		gump.alias_text_colors [_colorname] = {_colortable, _green, _blue, _alpha}
	else
		return _detalhes:NewError ("invalid parameter.")
	end
	
	return true
end

function gump:IsHtmlColor (color)
	return gump.alias_text_colors [color]
end

local tn = tonumber
function gump:ParseColors (_arg1, _arg2, _arg3, _arg4)
	if (_type (_arg1) == "table") then
		_arg1, _arg2, _arg3, _arg4 = _unpack (_arg1)
	
	elseif (_type (_arg1) == "string") then
	
		if (string.find (_arg1, "#")) then
			_arg1 = _arg1:gsub ("#","")
			if (string.len (_arg1) == 8) then --alpha
				_arg1, _arg2, _arg3, _arg4 = tn ("0x" .. _arg1:sub (3, 4))/255, tn ("0x" .. _arg1:sub (5, 6))/255, tn ("0x" .. _arg1:sub (7, 8))/255, tn ("0x" .. _arg1:sub (1, 2))/255
			else
				_arg1, _arg2, _arg3, _arg4 = tn ("0x" .. _arg1:sub (1, 2))/255, tn ("0x" .. _arg1:sub (3, 4))/255, tn ("0x" .. _arg1:sub (5, 6))/255, 1
			end
		
		else
			local color = gump.alias_text_colors [_arg1]
			if (color) then
				_arg1, _arg2, _arg3, _arg4 = _unpack (color)
			else
				_arg1, _arg2, _arg3, _arg4 = _unpack (gump.alias_text_colors.none)
			end
		end
	end
	
	if (not _arg1) then
		_arg1 = 1
	end
	if (not _arg2) then
		_arg2 = 1
	end
	if (not _arg3) then
		_arg3 = 1
	end
	if (not _arg4) then
		_arg4 = 1
	end
	
	return _arg1, _arg2, _arg3, _arg4
end

function gump:BuildMenu (parent, menu, x_offset, y_offset, height)
	
	local cur_x = x_offset
	local cur_y = y_offset
	local max_x = 0
	
	for index, widget_table in ipairs (menu) do 
	
		if (widget_table.type == "select" or widget_table.type == "dropdown") then
			local dropdown = self:NewDropDown (parent, nil, "$parentWidget" .. index, nil, 140, 18, widget_table.values, widget_table.get())
			dropdown.tooltip = widget_table.desc
			local label = self:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name, "GameFontNormal", 12)
			dropdown:SetPoint ("left", label, "right", 2)
			label:SetPoint (cur_x, cur_y)
			
			local size = label.widget:GetStringWidth() + 140 + 4
			if (size > max_x) then
				max_x = size
			end
			
		elseif (widget_table.type == "toggle" or widget_table.type == "switch") then
			local switch = self:NewSwitch (parent, nil, "$parentWidget" .. index, nil, 60, 20, nil, nil, widget_table.get())
			switch.tooltip = widget_table.desc
			switch.OnSwitch = widget_table.set
			
			local label = self:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name, "GameFontNormal", 12)
			switch:SetPoint ("left", label, "right", 2)
			label:SetPoint (cur_x, cur_y)
			
			local size = label.widget:GetStringWidth() + 60 + 4
			if (size > max_x) then
				max_x = size
			end
			
		elseif (widget_table.type == "range" or widget_table.type == "slider") then
			local is_decimanls = widget_table.usedecimals
			local slider = self:NewSlider (parent, nil, "$parentWidget" .. index, nil, 140, 20, widget_table.min, widget_table.max, widget_table.step, widget_table.get(),  is_decimanls)
			slider.tooltip = widget_table.desc
			slider:SetHook ("OnValueChange", widget_table.set)
			
			local label = self:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name, "GameFontNormal", 12)
			slider:SetPoint ("left", label, "right", 2)
			label:SetPoint (cur_x, cur_y)
			
			local size = label.widget:GetStringWidth() + 60 + 4
			if (size > max_x) then
				max_x = size
			end
			
		elseif (widget_table.type == "color" or widget_table.type == "color") then
			local colorpick = self:NewColorPickButton (parent, "$parentWidget" .. index, nil, widget_table.set)
			colorpick.tooltip = widget_table.desc

			local default_value, g, b, a = widget_table.get()
			if (type (default_value) == "table") then
				colorpick:SetColor (unpack (default_value))
			else
				colorpick:SetColor (default_value, g, b, a)
			end
			
			local label = self:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name, "GameFontNormal", 12)
			colorpick:SetPoint ("left", label, "right", 2)
			label:SetPoint (cur_x, cur_y)
			
			local size = label.widget:GetStringWidth() + 60 + 4
			if (size > max_x) then
				max_x = size
			end
			
		elseif (widget_table.type == "execute" or widget_table.type == "button") then
		
			local button = self:NewButton (parent, nil, "$parentWidget", nil, 120, 18, widget_table.func, widget_table.param1, widget_table.param2, nil, widget_table.name)
			button:InstallCustomTexture()
			button:SetPoint (cur_x, cur_y)
			button.tooltip = widget_table.desc
			
			local size = button:GetWidth() + 4
			if (size > max_x) then
				max_x = size
			end
			
		end
	
		cur_y = cur_y - 20
		if (cur_y > height) then
			cur_y = y_offset
			cur_x = max_x
		end
	
	end
	
end

function gump:ShowTutorialAlertFrame (maintext, desctext, clickfunc)
	
	local TutorialAlertFrame = _G.DetailsTutorialAlertFrame
	
	if (not TutorialAlertFrame) then
		
		TutorialAlertFrame = CreateFrame ("ScrollFrame", "DetailsTutorialAlertFrame", UIParent, "DetailsTutorialAlertFrameTemplate")
		TutorialAlertFrame.isFirst = true
		TutorialAlertFrame:SetPoint ("left", UIParent, "left", -20, 100)
		
		TutorialAlertFrame:SetWidth (290)
		TutorialAlertFrame.ScrollChild:SetWidth (256)
		
		local scrollname = TutorialAlertFrame.ScrollChild:GetName()
		_G [scrollname .. "BorderTopLeft"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "BorderTopRight"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "BorderBotLeft"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "BorderBotRight"]:SetVertexColor (1, 0.8, 0, 1)	
		_G [scrollname .. "BorderLeft"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "BorderRight"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "BorderBottom"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "BorderTop"]:SetVertexColor (1, 0.8, 0, 1)
		
		local iconbg = _G [scrollname .. "QuestIconBg"]
		iconbg:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		iconbg:SetTexCoord (0, 1, 0, 1)
		iconbg:SetSize (100, 100)
		iconbg:ClearAllPoints()
		iconbg:SetPoint ("bottomleft", TutorialAlertFrame.ScrollChild, "bottomleft")
		
		_G [scrollname .. "Exclamation"]:SetVertexColor (1, 0.8, 0, 1)
		_G [scrollname .. "QuestionMark"]:SetVertexColor (1, 0.8, 0, 1)
		
		_G [scrollname .. "TopText"]:SetText ("Details!") --string
		_G [scrollname .. "QuestName"]:SetText ("") --string
		_G [scrollname .. "BottomText"]:SetText ("") --string
		
		TutorialAlertFrame.ScrollChild.IconShine:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		
		TutorialAlertFrame:SetScript ("OnMouseUp", function (self) 
			if (self.clickfunc and type (self.clickfunc) == "function") then
				self.clickfunc()
			end
			self:Hide()
		end)
		TutorialAlertFrame:Hide()
	end
	
	if (type (maintext) == "string") then
		TutorialAlertFrame.ScrollChild.QuestName:SetText (maintext)
	else
		TutorialAlertFrame.ScrollChild.QuestName:SetText ("")
	end
	
	if (type (desctext) == "string") then
		TutorialAlertFrame.ScrollChild.BottomText:SetText (desctext)
	else
		TutorialAlertFrame.ScrollChild.BottomText:SetText ("")
	end
	
	TutorialAlertFrame.clickfunc = clickfunc
	TutorialAlertFrame:Show()
	DetailsTutorialAlertFrame_SlideInFrame (TutorialAlertFrame, "AUTOQUEST")
end