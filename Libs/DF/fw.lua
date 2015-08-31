
local major, minor = "DetailsFramework-1.0", 8
local DF, oldminor = LibStub:NewLibrary (major, minor)

if (not DF) then
	DetailsFrameworkCanLoad = false
	return 
end

DetailsFrameworkCanLoad = true

local _type = type
local _unpack = unpack
local _
local upper = string.upper

DF.LabelNameCounter = 1
DF.PictureNameCounter = 1
DF.BarNameCounter = 1
DF.DropDownCounter = 1
DF.PanelCounter = 1
DF.ButtonCounter = 1
DF.SliderCounter = 1
DF.SplitBarCounter = 1

LibStub:GetLibrary("AceTimer-3.0"):Embed (DF)

do
	local path = string.match (debugstack (1, 1, 0), "AddOns\\(.+)fw.lua")
	if (path) then
		DF.folder = "Interface\\AddOns\\" .. path
	else
		DF.folder = ""
	end
end

DF.debug = false

_G ["DetailsFramework"] = DF

DF.embeds = DF.embeds or {}
local embed_functions = {
	"RemoveRealName",
	"table",
	"BuildDropDownFontList",
	"SetFontSize",
	"SetFontFace",
	"SetFontColor",
	"GetFontSize",
	"GetFontFace",
	"SetFontOutline",
	"trim",
	"Msg",
	"CreateFlashAnimation",
	"Fade",
	"NewColor",
	"IsHtmlColor",
	"ParseColors",
	"BuildMenu",
	"ShowTutorialAlertFrame",
	"GetNpcIdFromGuid",
	"ShowFeedbackPanel",
	"SetAsOptionsPanel",
	
	"CreateDropDown",
	"CreateButton",
	"CreateColorPickButton",
	"CreateLabel",
	"CreateBar",
	"CreatePanel",
	"CreateFillPanel",
	"ColorPick",
	"IconPick",
	"CreateSimplePanel",
	"CreateChartPanel",
	"CreateImage",
	"CreateScrollBar",
	"CreateSwitch",
	"CreateSlider",
	"CreateSplitBar",
	"CreateTextEntry",
	"Create1PxPanel",
	"CreateFeedbackButton",
	"CreateOptionsFrame",
	"NewSpecialLuaEditorEntry",
	"ShowPromptPanel",
	"ShowTextPromptPanel",
	"www_icons",
	"GetTemplate",
	"GetFrameworkFolder",
}

DF.table = {}

function DF:GetFrameworkFolder()
	return DF.folder
end

function DF.table.reverse (t)
	local new = {}
	local index = 1
	for i = #t, 1, -1 do
		new [index] = t[i]
		index = index + 1
	end
	return new
end

--> copy from table2 to table1 overwriting values
function DF.table.copy (t1, t2)
	for key, value in pairs (t2) do 
		if (type (value) == "table") then
			t1 [key] = t1 [key] or {}
			DF.table.copy (t1 [key], t2 [key])
		else
			t1 [key] = value
		end
	end
	return t1
end

--> copy values that does exist on table2 but not on table1
function DF.table.deploy (t1, t2)
	for key, value in pairs (t2) do 
		if (type (value) == "table") then
			t1 [key] = t1 [key] or {}
			DF.table.deploy (t1 [key], t2 [key])
		elseif (t1 [key] == nil) then
			t1 [key] = value
		end
	end
end

function DF.table.dump (t, s, deep)
	s = s or ""
	deep = deep or 0
	local space = ""
	for i = 1, deep do
		space = space .. "   "
	end
	for key, value in pairs (t) do
		local tpe = _type (value)
		if (type (key) ~= "string") then
			key = "unknown?"
		end		
		if (tpe == "table") then
			s = s .. space .. "[" .. key .. "] = |cFFa9ffa9table {|r\n"
			s = s .. DF.table.dump (value, nil, deep+1)
			s = s .. space .. "|cFFa9ffa9}|r\n"
		elseif (tpe == "string") then
			s = s .. space .. "[" .. key .. "] = '|cFFfff1c1" .. value .. "|r'\n"
		elseif (tpe == "number") then
			s = s .. space .. "[" .. key .. "] = |cFFffc1f4" .. value .. "|r\n"
		elseif (tpe == "function") then
			s = s .. space .. "[" .. key .. "] = function()\n"
		elseif (tpe == "boolean") then
			s = s .. space .. "[" .. key .. "] = |cFF99d0ff" .. (value and "true" or "false") .. "|r\n"
		end
	end
	return s
end

DF.www_icons = {
	texture = "feedback_sites",
	wowi = {0, 0.7890625, 0, 37/128},
	curse = {0, 0.7890625, 38/123, 79/128},
	mmoc = {0, 0.7890625, 80/123, 123/128},
}

function DF:Embed (target)
	for k, v in pairs (embed_functions) do
		target[v] = self[v]
	end
	self.embeds [target] = true
	return target
end

function DF:RemoveRealName (name)
	return name:gsub (("%-.*"), "")
end

function DF:SetFontSize (fontString, ...)
	local fonte, _, flags = fontString:GetFont()
	fontString:SetFont (fonte, max (...), flags)
end
function DF:SetFontFace (fontString, fontface)
	local _, size, flags = fontString:GetFont()
	fontString:SetFont (fontface, size, flags)
end
function DF:SetFontColor (fontString, r, g, b, a)
	r, g, b, a = DF:ParseColors (r, g, b, a)
	fontString:SetTextColor (r, g, b, a)
end

function DF:GetFontSize (fontString)
	local _, size = fontString:GetFont()
	return size
end
function DF:GetFontFace (fontString)
	local fontface = fontString:GetFont()
	return fontface
end

function DF:SetFontOutline (fontString, outline)
	local fonte, size = fontString:GetFont()
	if (outline) then
		if (_type (outline) == "boolean" and outline) then
			outline = "OUTLINE"
		elseif (outline == 1) then
			outline = "OUTLINE"
		elseif (outline == 2) then
			outline = "THICKOUTLINE"
		end
	end

	fontString:SetFont (fonte, size, outline)
end

function DF:trim (s)
	local from = s:match"^%s*()"
	return from > #s and "" or s:match(".*%S", from)
end

function DF:Msg (msg)
	print ("|cFFFFFFAA" .. self.__name .. "|r " .. msg)
end

function DF:GetNpcIdFromGuid (guid)
	local NpcId = select ( 6, strsplit ( "-", guid ) )
	if (NpcId) then
		return tonumber ( NpcId )
	end
	return 0
end

local onFinish = function (self)
	if (self.showWhenDone) then
		self.frame:SetAlpha (1)
	else
		self.frame:SetAlpha (0)
		self.frame:Hide()
	end
	
	if (self.onFinishFunc) then
		self:onFinishFunc (self.frame)
	end
end

local stop = function (self)
	local FlashAnimation = self.FlashAnimation
	FlashAnimation:Stop()
end

local flash = function (self, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, loopType)
	
	local FlashAnimation = self.FlashAnimation
	
	local fadeIn = FlashAnimation.fadeIn
	local fadeOut = FlashAnimation.fadeOut
	
	fadeIn:Stop()
	fadeOut:Stop()

	fadeIn:SetDuration (fadeInTime or 1)
	fadeIn:SetEndDelay (flashInHoldTime or 0)
	
	fadeOut:SetDuration (fadeOutTime or 1)
	fadeOut:SetEndDelay (flashOutHoldTime or 0)

	FlashAnimation.duration = flashDuration
	FlashAnimation.loopTime = FlashAnimation:GetDuration()
	FlashAnimation.finishAt = GetTime() + flashDuration
	FlashAnimation.showWhenDone = showWhenDone
	
	FlashAnimation:SetLooping (loopType or "REPEAT")
	
	self:Show()
	self:SetAlpha (0)
	FlashAnimation:Play()
end

function DF:CreateFlashAnimation (frame, onFinishFunc, onLoopFunc)
	local FlashAnimation = frame:CreateAnimationGroup() 
	
	FlashAnimation.fadeOut = FlashAnimation:CreateAnimation ("Alpha") --> fade out anime
	FlashAnimation.fadeOut:SetOrder (1)
	FlashAnimation.fadeOut:SetChange (1)
	
	FlashAnimation.fadeIn = FlashAnimation:CreateAnimation ("Alpha") --> fade in anime
	FlashAnimation.fadeIn:SetOrder (2)
	FlashAnimation.fadeIn:SetChange (-1)
	
	frame.FlashAnimation = FlashAnimation
	FlashAnimation.frame = frame
	FlashAnimation.onFinishFunc = onFinishFunc
	
	FlashAnimation:SetScript ("OnLoop", onLoopFunc)
	FlashAnimation:SetScript ("OnFinished", onFinish)
	
	frame.Flash = flash
	frame.Stop = stop
end

-----------------------------------------

local fade_IN_finished_func = function (frame)
	if (frame.fading_in) then
		frame.hidden = true
		frame.faded = true
		frame.fading_in = false
		frame:Hide()
	end
end

local fade_OUT_finished_func = function (frame)
	if (frame:IsShown() and frame.fading_out) then
		frame.hidden = false
		frame.faded = false
		frame.fading_out = false
	else
		frame:SetAlpha(0)
	end
end

local just_fade_func = function (frame)
	frame.hidden = false
	frame.faded = true
	frame.fading_in = false
end

local anim_OUT_alpha_func = function (frame)
	frame.fading_out = false
end

local anim_IN_alpha_func = function (frame)
	frame.fading_in = false
end

function DF:Fade (frame, tipo, velocidade, parametros)
	
	if (_type (frame) == "table") then 
		if (frame.dframework) then
			frame = frame.widget
		end
	end
	
	velocidade = velocidade or 0.3
	
	if (upper (tipo) == "IN") then

		if (frame:GetAlpha() == 0 and frame.hidden and not frame.fading_out) then --> ja esta escondida
			return
		elseif (frame.fading_in) then --> ja esta com uma animação, se for true
			return
		end
		
		if (frame.fading_out) then --> se tiver uma animação de aparecer em andamento se for true
			frame.fading_out = false
		end

		UIFrameFadeIn (frame, velocidade, frame:GetAlpha(), 0)
		frame.fading_in = true
		
		frame.fadeInfo.finishedFunc = fade_IN_finished_func
		frame.fadeInfo.finishedArg1 = frame
		
	elseif (upper (tipo) == "OUT") then --> aparecer
		if (frame:GetAlpha() == 1 and not frame.hidden and not frame.fading_in) then --> ja esta na tela
			return
		elseif (frame.fading_out) then --> já ta com fading out
			return
		end
		
		if (frame.fading_in) then --> se tiver uma animação de hidar em andamento se for true
			frame.fading_in = false
		end
		
		frame:Show()
		UIFrameFadeOut (frame, velocidade, frame:GetAlpha(), 1.0)
		frame.fading_out = true
		
		frame.fadeInfo.finishedFunc = fade_OUT_finished_func
		frame.fadeInfo.finishedArg1 = frame
			
	elseif (tipo == 0) then --> força o frame a ser mostrado
		frame.hidden = false
		frame.faded = false
		frame.fading_out = false
		frame.fading_in = false
		frame:Show()
		frame:SetAlpha (1)
		
	elseif (tipo == 1) then --> força o frame a ser hidado
		frame.hidden = true
		frame.faded = true
		frame.fading_out = false
		frame.fading_in = false
		frame:SetAlpha (0)
		frame:Hide()
		
	elseif (tipo == -1) then --> apenas da fade sem hidar
		if (frame:GetAlpha() == 0 and frame.hidden and not frame.fading_out) then --> ja esta escondida
			return
		elseif (frame.fading_in) then --> ja esta com uma animação, se for true
			return
		end
		
		if (frame.fading_out) then --> se tiver uma animação de aparecer em andamento se for true
			frame.fading_out = false
		end

		UIFrameFadeIn (frame, velocidade, frame:GetAlpha(), 0)
		frame.fading_in = true
		frame.fadeInfo.finishedFunc = just_fade_func
		frame.fadeInfo.finishedArg1 = frame

	elseif (upper (tipo) == "ALPHAANIM") then

		local value = velocidade
		local currentApha = frame:GetAlpha()
		frame:Show()
		
		if (currentApha < value) then
			if (frame.fading_in) then --> se tiver uma animação de hidar em andamento se for true
				frame.fading_in = false
				frame.fadeInfo.finishedFunc = nil
			end
			UIFrameFadeOut (frame, 0.3, currentApha, value)
			frame.fading_out = true

			frame.fadeInfo.finishedFunc = anim_OUT_alpha_func
			frame.fadeInfo.finishedArg1 = frame

		else
			if (frame.fading_out) then --> se tiver uma animação de hidar em andamento se for true
				frame.fading_out = false
				frame.fadeInfo.finishedFunc = nil
			end
			UIFrameFadeIn (frame, 0.3, currentApha, value)
			frame.fading_in = true
			
			frame.fadeInfo.finishedFunc = anim_IN_alpha_func
			frame.fadeInfo.finishedArg1 = frame
		end

	elseif (upper (tipo) == "ALPHA") then --> setando um alpha determinado
		if (frame.fading_in or frame.fading_out) then
			frame.fadeInfo.finishedFunc = nil
			UIFrameFadeIn (frame, velocidade, frame:GetAlpha(), frame:GetAlpha())
		end
		frame.hidden = false
		frame.faded = false
		frame.fading_in = false
		frame.fading_out = false
		frame:Show()
		frame:SetAlpha (velocidade)
	end
end
	
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> points

	function DF:CheckPoints (v1, v2, v3, v4, v5, object)

		if (not v1 and not v2) then
			return "topleft", object.widget:GetParent(), "topleft", 0, 0
		end
		
		if (_type (v1) == "string") then
			local frameGlobal = _G [v1]
			if (frameGlobal and frameGlobal.GetObjectType) then
				return DF:CheckPoints (frameGlobal, v2, v3, v4, v5, object)
			end
			
		elseif (_type (v2) == "string") then
			local frameGlobal = _G [v2]
			if (frameGlobal and frameGlobal.GetObjectType) then
				return DF:CheckPoints (v1, frameGlobal, v3, v4, v5, object)
			end
		end
		
		if (_type (v1) == "string" and _type (v2) == "table") then --> :setpoint ("left", frame, _, _, _)
			if (not v3 or _type (v3) == "number") then --> :setpoint ("left", frame, 10, 10)
				v1, v2, v3, v4, v5 = v1, v2, v1, v3, v4
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
--> colors

	function DF:NewColor (_colorname, _colortable, _green, _blue, _alpha)
		assert (_type (_colorname) == "string", "NewColor: colorname must be a string.")
		assert (not DF.alias_text_colors [_colorname], "NewColor: colorname already exists.")

		if (_type (_colortable) == "table") then
			if (_colortable[1] and _colortable[2] and _colortable[3]) then
				_colortable[4] = _colortable[4] or 1
				DF.alias_text_colors [_colorname] = _colortable
			else
				error ("invalid color table.")
			end
		elseif (_colortable and _green and _blue) then
			_alpha = _alpha or 1
			DF.alias_text_colors [_colorname] = {_colortable, _green, _blue, _alpha}
		else
			error ("invalid parameter.")
		end
		
		return true
	end

	function DF:IsHtmlColor (color)
		return DF.alias_text_colors [color]
	end

	local tn = tonumber
	function DF:ParseColors (_arg1, _arg2, _arg3, _arg4)
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
				local color = DF.alias_text_colors [_arg1]
				if (color) then
					_arg1, _arg2, _arg3, _arg4 = _unpack (color)
				else
					_arg1, _arg2, _arg3, _arg4 = _unpack (DF.alias_text_colors.none)
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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> menus
	
	function DF:BuildMenu (parent, menu, x_offset, y_offset, height, use_two_points, text_template, dropdown_template, switch_template, switch_is_box, slider_template, button_template)
		
		if (not parent.widget_list) then
			DF:SetAsOptionsPanel (parent)
		end
		
		local cur_x = x_offset
		local cur_y = y_offset
		local max_x = 0
		
		height = abs ((height or parent:GetHeight()) - abs (y_offset) + 20)
		height = height*-1
		
		for index, widget_table in ipairs (menu) do 
		
			if (widget_table.type == "blank" or widget_table.type == "space") then
				-- do nothing
		
			elseif (widget_table.type == "label" or widget_table.type == "text") then
				local label = DF:CreateLabel (parent, widget_table.get() or widget_table.text, widget_table.text_template or text_template or widget_table.size, widget_table.color, widget_table.font, nil, "$parentWidget" .. index, "overlay")
				label._get = widget_table.get
				label.widget_type = "label"
				label:SetPoint (cur_x, cur_y)
				tinsert (parent.widget_list, label)
			
			elseif (widget_table.type == "select" or widget_table.type == "dropdown") then
				local dropdown = DF:NewDropDown (parent, nil, "$parentWidget" .. index, nil, 140, 18, widget_table.values, widget_table.get(), dropdown_template)
				dropdown.tooltip = widget_table.desc
				dropdown._get = widget_table.get
				dropdown.widget_type = "select"
				local label = DF:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name .. (use_two_points and ": " or ""), "GameFontNormal", widget_table.text_template or text_template or 12)
				dropdown:SetPoint ("left", label, "right", 2)
				label:SetPoint (cur_x, cur_y)
				
				local size = label.widget:GetStringWidth() + 140 + 4
				if (size > max_x) then
					max_x = size
				end
				
				tinsert (parent.widget_list, dropdown)
				
			elseif (widget_table.type == "toggle" or widget_table.type == "switch") then
				local switch = DF:NewSwitch (parent, nil, "$parentWidget" .. index, nil, 60, 20, nil, nil, widget_table.get(), nil, nil, nil, nil, switch_template)
				switch.tooltip = widget_table.desc
				switch._get = widget_table.get
				switch.widget_type = "toggle"
				switch.OnSwitch = widget_table.set
				
				if (switch_is_box) then
					switch:SetAsCheckBox()
				end
				
				local label = DF:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name .. (use_two_points and ": " or ""), "GameFontNormal", widget_table.text_template or text_template or 12)
				switch:SetPoint ("left", label, "right", 2)
				label:SetPoint (cur_x, cur_y)
				
				local size = label.widget:GetStringWidth() + 60 + 4
				if (size > max_x) then
					max_x = size
				end
				
				tinsert (parent.widget_list, switch)
				
			elseif (widget_table.type == "range" or widget_table.type == "slider") then
				local is_decimanls = widget_table.usedecimals
				local slider = DF:NewSlider (parent, nil, "$parentWidget" .. index, nil, 140, 20, widget_table.min, widget_table.max, widget_table.step, widget_table.get(),  is_decimanls, nil, nil, slider_template)
				slider.tooltip = widget_table.desc
				slider._get = widget_table.get
				slider.widget_type = "range"
				slider:SetHook ("OnValueChange", widget_table.set)
				
				local label = DF:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name .. (use_two_points and ": " or ""), "GameFontNormal", widget_table.text_template or text_template or 12)
				slider:SetPoint ("left", label, "right", 2)
				label:SetPoint (cur_x, cur_y)
				
				local size = label.widget:GetStringWidth() + 140 + 6
				if (size > max_x) then
					max_x = size
				end
				
				tinsert (parent.widget_list, slider)
				
			elseif (widget_table.type == "color" or widget_table.type == "color") then
				local colorpick = DF:NewColorPickButton (parent, "$parentWidget" .. index, nil, widget_table.set, nil, button_template)
				colorpick.tooltip = widget_table.desc
				colorpick._get = widget_table.get
				colorpick.widget_type = "color"

				local default_value, g, b, a = widget_table.get()
				if (type (default_value) == "table") then
					colorpick:SetColor (unpack (default_value))
				else
					colorpick:SetColor (default_value, g, b, a)
				end
				
				local label = DF:NewLabel (parent, nil, "$parentLabel" .. index, nil, widget_table.name .. (use_two_points and ": " or ""), "GameFontNormal", widget_table.text_template or text_template or 12)
				colorpick:SetPoint ("left", label, "right", 2)
				label:SetPoint (cur_x, cur_y)
				
				local size = label.widget:GetStringWidth() + 60 + 4
				if (size > max_x) then
					max_x = size
				end
				
				tinsert (parent.widget_list, colorpick)
				
			elseif (widget_table.type == "execute" or widget_table.type == "button") then
			
				local button = DF:NewButton (parent, nil, "$parentWidget" .. index, nil, 120, 18, widget_table.func, widget_table.param1, widget_table.param2, nil, widget_table.name, nil, button_template)
				if (not button_template) then
					button:InstallCustomTexture()
				end

				button:SetPoint (cur_x, cur_y)
				button.tooltip = widget_table.desc
				button.widget_type = "execute"
				
				local size = button:GetWidth() + 4
				if (size > max_x) then
					max_x = size
				end
				
				tinsert (parent.widget_list, button)
				
			end
		
			if (widget_table.spacement) then
				cur_y = cur_y - 30
			else
				cur_y = cur_y - 20
			end
			
			if (cur_y < height) then
				cur_y = y_offset
				cur_x = cur_x + max_x + 30
				
				max_x = 0
			end
		
		end
		
	end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> tutorials
	
	function DF:ShowTutorialAlertFrame (maintext, desctext, clickfunc)
		
		local TutorialAlertFrame = _G.DetailsFrameworkTutorialAlertFrame
		
		if (not TutorialAlertFrame) then
			
			TutorialAlertFrame = CreateFrame ("ScrollFrame", "DetailsFrameworkTutorialAlertFrame", UIParent, "DetailsFrameworkTutorialAlertFrameTemplate")
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
	
	local refresh_options = function (self)
		for _, widget in ipairs (self.widget_list) do
			if (widget._get) then
				if (widget.widget_type == "label") then
					if (widget._get()) then
						widget:SetText (widget._get())
					end
				elseif (widget.widget_type == "select") then
					widget:Select (widget._get())
				elseif (widget.widget_type == "toggle" or widget.widget_type == "range") then
					widget:SetValue (widget._get())
				elseif (widget.widget_type == "color") then
					local default_value, g, b, a = widget._get()
					if (type (default_value) == "table") then
						widget:SetColor (unpack (default_value))
					else
						widget:SetColor (default_value, g, b, a)
					end
				end
			end
		end
	end
	
	function DF:SetAsOptionsPanel (frame)
		frame.RefreshOptions = refresh_options
		frame.widget_list = {}
	end
	
	function DF:CreateOptionsFrame (name, title, template)
	
		template = template or 1
	
		if (template == 2) then
			local options_frame = CreateFrame ("frame", name, UIParent, "ButtonFrameTemplate")
			tinsert (UISpecialFrames, name)
			options_frame:SetSize (500, 200)
			options_frame.RefreshOptions = refresh_options
			options_frame.widget_list = {}
			
			options_frame:SetScript ("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then 
						self.moving = false
						self:StopMovingOrSizing()
					end
					return options_frame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)
			options_frame:SetScript ("OnMouseUp", function(self)
				if (self.moving) then 
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)
			
			options_frame:SetMovable (true)
			options_frame:EnableMouse (true)
			options_frame:SetFrameStrata ("DIALOG")
			options_frame:SetToplevel (true)
			
			options_frame:Hide()
			
			options_frame:SetPoint ("center", UIParent, "center")
			options_frame.TitleText:SetText (title)
			options_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
			
			return options_frame
	
		elseif (template == 1) then
		
			local options_frame = CreateFrame ("frame", name, UIParent)
			tinsert (UISpecialFrames, name)
			options_frame:SetSize (500, 200)
			options_frame.RefreshOptions = refresh_options
			options_frame.widget_list = {}

			options_frame:SetScript ("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then 
						self.moving = false
						self:StopMovingOrSizing()
					end
					return options_frame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)
			options_frame:SetScript ("OnMouseUp", function(self)
				if (self.moving) then 
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)
			
			options_frame:SetMovable (true)
			options_frame:EnableMouse (true)
			options_frame:SetFrameStrata ("DIALOG")
			options_frame:SetToplevel (true)
			
			options_frame:Hide()
			
			options_frame:SetPoint ("center", UIParent, "center")
			
			options_frame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			edgeFile = DF.folder ..  "border_2", edgeSize = 32,
			insets = {left = 1, right = 1, top = 1, bottom = 1}})
			options_frame:SetBackdropColor (0, 0, 0, .7)

			local texturetitle = options_frame:CreateTexture (nil, "artwork")
			texturetitle:SetTexture ([[Interface\CURSOR\Interact]])
			texturetitle:SetTexCoord (0, 1, 0, 1)
			texturetitle:SetVertexColor (1, 1, 1, 1)
			texturetitle:SetPoint ("topleft", options_frame, "topleft", 2, -3)
			texturetitle:SetWidth (36)
			texturetitle:SetHeight (36)
			
			local title = DF:NewLabel (options_frame, nil, "$parentTitle", nil, title, nil, 20, "yellow")
			title:SetPoint ("left", texturetitle, "right", 2, -1)
			DF:SetFontOutline (title, true)

			local c = CreateFrame ("Button", nil, options_frame, "UIPanelCloseButton")
			c:SetWidth (32)
			c:SetHeight (32)
			c:SetPoint ("TOPRIGHT",  options_frame, "TOPRIGHT", -3, -3)
			c:SetFrameLevel (options_frame:GetFrameLevel()+1)
			
			return options_frame
		end
	end	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> templates

DF.font_templates = {}
DF.font_templates ["ORANGE_FONT_TEMPLATE"] = {color = "orange", size = 11, font = "Accidental Presidency"}
DF.font_templates ["OPTIONS_FONT_TEMPLATE"] = {color = "yellow", size = 12, font = "Accidental Presidency"}

DF.dropdown_templates = {}
DF.dropdown_templates ["OPTIONS_DROPDOWN_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	onentercolor = {1, 1, 1, .5},
	onenterbordercolor = {1, 1, 1, 1},
}

DF.switch_templates = {}
DF.switch_templates ["OPTIONS_CHECKBOX_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	width = 18,
	height = 18,
	enabled_backdropcolor = {1, 1, 1, .5},
	disabled_backdropcolor = {1, 1, 1, .2},
	onenterbordercolor = {1, 1, 1, 1},
}
DF.switch_templates ["OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	width = 18,
	height = 18,
	enabled_backdropcolor = {1, 1, 1, .5},
	disabled_backdropcolor = {1, 1, 1, .5},
	onenterbordercolor = {1, 1, 1, 1},
}

DF.button_templates = {}
DF.button_templates ["OPTIONS_BUTTON_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
}

DF.slider_templates = {}
DF.slider_templates ["OPTIONS_SLIDER_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	onentercolor = {1, 1, 1, .5},
	onenterbordercolor = {1, 1, 1, 1},
	thumbtexture = [[Interface\Tooltips\UI-Tooltip-Background]],
	thumbwidth = 16,
	thumbheight = 14,
	thumbcolor = {0, 0, 0, 0.5},
}

function DF:GetTemplate (type, template_name)
	local template_table
	if (type == "font") then
		template_table = DF.font_templates
	elseif (type == "dropdown") then
		template_table = DF.dropdown_templates
	elseif (type == "button") then
		template_table = DF.button_templates
	elseif (type == "switch") then
		template_table = DF.switch_templates
	elseif (type == "slider") then
		template_table = DF.slider_templates
	end
	return template_table [template_name]
end
	
