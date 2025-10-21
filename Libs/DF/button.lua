
--[=[
	callback format:
	function(blizzardButton, clickType, param1, param2)
	end

	Use .MyObject to get the framework button object
--]=]

local detailsFramework = _G["DetailsFramework"]

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local unpack = unpack
local emptyFunction = function() end
local APIButtonFunctions = false

do
	local metaPrototype = {
		WidgetType = "button",
		dversion = detailsFramework.dversion
	}

	--check if there's a metaPrototype already existing
	if (_G[detailsFramework.GlobalWidgetControlNames["button"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[detailsFramework.GlobalWidgetControlNames["button"]]
		--check if is older
		if ( (not oldMetaPrototype.dversion) or (oldMetaPrototype.dversion < detailsFramework.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(metaPrototype) do
				oldMetaPrototype[funcName] = metaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[detailsFramework.GlobalWidgetControlNames["button"]] = metaPrototype
	end
end

local ButtonMetaFunctions = _G[detailsFramework.GlobalWidgetControlNames["button"]]

detailsFramework:Mixin(ButtonMetaFunctions, detailsFramework.SetPointMixin)
detailsFramework:Mixin(ButtonMetaFunctions, detailsFramework.FrameMixin)
detailsFramework:Mixin(ButtonMetaFunctions, detailsFramework.TooltipHandlerMixin)
detailsFramework:Mixin(ButtonMetaFunctions, detailsFramework.ScriptHookMixin)

------------------------------------------------------------------------------------------------------------
--metatables

	ButtonMetaFunctions.__call = function(self)
		local frameWidget = self.widget
		detailsFramework:CoreDispatch((frameWidget:GetName() or "Button") .. ":__call()", self.func, frameWidget, "LeftButton", self.param1, self.param2)
	end

------------------------------------------------------------------------------------------------------------
--members

	--tooltip
	local gmember_tooltip = function(object)
		return object:GetTooltip()
	end

	--shown
	local gmember_shown = function(object)
		return object:IsShown()
	end
	--frame width
	local gmember_width = function(object)
		return object.button:GetWidth()
	end

	--frame height
	local gmember_height = function(object)
		return object.button:GetHeight()
	end

	--text
	local gmember_text = function(object)
		return object.button.text:GetText()
	end

	--function
	local gmember_function = function(object)
		return rawget(object, "func")
	end

	--text color
	local gmember_textcolor = function(object)
		return object.button.text:GetTextColor()
	end

	--text font
	local gmember_textfont = function(object)
		local fontface = object.button.text:GetFont()
		return fontface
	end

	--text size
	local gmember_textsize = function(object)
		local _, fontsize = object.button.text:GetFont()
		return fontsize
	end

	--texture
	local gmember_texture = function(object)
		return {object.button:GetNormalTexture(), object.button:GetHighlightTexture(), object.button:GetPushedTexture(), object.button:GetDisabledTexture()}
	end

	--locked
	local gmember_locked = function(object)
		return rawget(object, "is_locked")
	end

	ButtonMetaFunctions.GetMembers = ButtonMetaFunctions.GetMembers or {}
	ButtonMetaFunctions.GetMembers["tooltip"] = gmember_tooltip
	ButtonMetaFunctions.GetMembers["shown"] = gmember_shown
	ButtonMetaFunctions.GetMembers["width"] = gmember_width
	ButtonMetaFunctions.GetMembers["height"] = gmember_height
	ButtonMetaFunctions.GetMembers["text"] = gmember_text
	ButtonMetaFunctions.GetMembers["clickfunction"] = gmember_function
	ButtonMetaFunctions.GetMembers["texture"] = gmember_texture
	ButtonMetaFunctions.GetMembers["locked"] = gmember_locked
	ButtonMetaFunctions.GetMembers["fontcolor"] = gmember_textcolor
	ButtonMetaFunctions.GetMembers["fontface"] = gmember_textfont
	ButtonMetaFunctions.GetMembers["fontsize"] = gmember_textsize
	ButtonMetaFunctions.GetMembers["textcolor"] = gmember_textcolor --alias
	ButtonMetaFunctions.GetMembers["textfont"] = gmember_textfont --alias
	ButtonMetaFunctions.GetMembers["textsize"] = gmember_textsize --alias

	ButtonMetaFunctions.__index = function(object, key)
		local func = ButtonMetaFunctions.GetMembers[key]
		if (func) then
			return func(object, key)
		end

		local alreadyHaveKey = rawget(object, key)
		if (alreadyHaveKey) then
			return alreadyHaveKey
		end

		return ButtonMetaFunctions[key]
	end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--tooltip
	local smember_tooltip = function(object, value)
		return object:SetTooltip (value)
	end

	--show
	local smember_show = function(object, value)
		if (value) then
			return object:Show()
		else
			return object:Hide()
		end
	end

	--hide
	local smember_hide = function(object, value)
		if (not value) then
			return object:Show()
		else
			return object:Hide()
		end
	end

	--frame width
	local smember_width = function(object, value)
		return object.button:SetWidth(value)
	end

	--frame height
	local smember_height = function(object, value)
		return object.button:SetHeight(value)
	end

	--text
	local smember_text = function(object, value)
		return object.button.text:SetText(value)
	end

	--function
	local smember_function = function(object, value)
		return rawset(object, "func", value)
	end

	--param1
	local smember_param1 = function(object, value)
		return rawset(object, "param1", value)
	end

	--param2
	local smember_param2 = function(object, value)
		return rawset(object, "param2", value)
	end

	--text color
	local smember_textcolor = function(object, value)
		local value1, value2, value3, value4 = detailsFramework:ParseColors(value)
		return object.button.text:SetTextColor(value1, value2, value3, value4)
	end

	--text font
	local smember_textfont = function(object, value)
		return detailsFramework:SetFontFace (object.button.text, value)
	end

	--text size
	local smember_textsize = function(object, value)
		return detailsFramework:SetFontSize(object.button.text, value)
	end

	--texture
	local smember_texture = function(object, value)
		return detailsFramework:SetButtonTexture(object, value, 0, 1, 0, 1)
	end

	--locked
	local smember_locked = function(object, value)
		if (value) then
			object.button:SetMovable(false)
			return rawset(object, "is_locked", true)
		else
			object.button:SetMovable(true)
			rawset(object, "is_locked", false)
			return
		end
	end

	--text align
	local smember_textalign = function(object, value)
		if (value == "left" or value == "<") then
			object.button.text:SetPoint("left", object.button, "left", 2, 0)
			object.capsule_textalign = "left"

		elseif (value == "center" or value == "|") then
			object.button.text:SetPoint("center", object.button, "center", 0, 0)
			object.capsule_textalign = "center"

		elseif (value == "right" or value == ">") then
			object.button.text:SetPoint("right", object.button, "right", -2, 0)
			object.capsule_textalign = "right"
		end
	end

	ButtonMetaFunctions.SetMembers= ButtonMetaFunctions.SetMembers or {}
	ButtonMetaFunctions.SetMembers["tooltip"] = smember_tooltip
	ButtonMetaFunctions.SetMembers["show"] = smember_show
	ButtonMetaFunctions.SetMembers["hide"] = smember_hide
	ButtonMetaFunctions.SetMembers["width"] = smember_width
	ButtonMetaFunctions.SetMembers["height"] = smember_height
	ButtonMetaFunctions.SetMembers["text"] = smember_text
	ButtonMetaFunctions.SetMembers["clickfunction"] = smember_function
	ButtonMetaFunctions.SetMembers["param1"] = smember_param1
	ButtonMetaFunctions.SetMembers["param2"] = smember_param2
	ButtonMetaFunctions.SetMembers["textcolor"] = smember_textcolor
	ButtonMetaFunctions.SetMembers["textfont"] = smember_textfont
	ButtonMetaFunctions.SetMembers["textsize"] = smember_textsize
	ButtonMetaFunctions.SetMembers["fontcolor"] = smember_textcolor--alias
	ButtonMetaFunctions.SetMembers["fontface"] = smember_textfont--alias
	ButtonMetaFunctions.SetMembers["fontsize"] = smember_textsize--alias
	ButtonMetaFunctions.SetMembers["texture"] = smember_texture
	ButtonMetaFunctions.SetMembers["locked"] = smember_locked
	ButtonMetaFunctions.SetMembers["textalign"] = smember_textalign

	ButtonMetaFunctions.__newindex = function(object, key, value)
		local func = ButtonMetaFunctions.SetMembers[key]
		if (func) then
			return func(object, value)
		else
			return rawset(object, key, value)
		end
	end

------------------------------------------------------------------------------------------------------------
--methods

	---change the function which will be called when the button is pressed
	---callback function will receive the blizzard button as first parameter, click type as second, param1 and param2 as third and fourth
	---@param func function
	---@param param1 any
	---@param param2 any
	---@param clickType string|nil
	function ButtonMetaFunctions:SetClickFunction(func, param1, param2, clickType)
		if (not clickType or string.find(string.lower(clickType), "left")) then
			if (func) then
				rawset(self, "func", func)
			else
				rawset(self, "func", emptyFunction)
			end

			if (param1 ~= nil) then
				rawset(self, "param1", param1)
			end
			if (param2 ~= nil) then
				rawset(self, "param2", param2)
			end

		elseif (clickType or string.find(string.lower(clickType), "right")) then
			if (func) then
				rawset(self, "funcright", func)
			else
				rawset(self, "funcright", emptyFunction)
			end
		end
	end

	function ButtonMetaFunctions:SetParameters(param1, param2)
		if (param1 ~= nil) then
			rawset(self, "param1", param1)
		end
		if (param2 ~= nil) then
			rawset(self, "param2", param2)
		end
	end

	---set the text shown on the button
	---@param text string
	function ButtonMetaFunctions:SetText(text)
		self.button.text:SetText(text)
	end

	---set the text shown on the button and truncate it if it's too long
	function ButtonMetaFunctions:SetTextTruncated(text, maxWidth)
		self.button.text:SetText(text)
		detailsFramework:TruncateText(self.button.text, maxWidth)
	end

	---set the color of the button text
	---@param ... any
	function ButtonMetaFunctions:SetTextColor(...)
		local red, green, blue, alpha = detailsFramework:ParseColors(...)
		self.button.text:SetTextColor(red, green, blue, alpha)
	end
	ButtonMetaFunctions.SetFontColor = ButtonMetaFunctions.SetTextColor --alias

	---set the size of the button text
	---@param ... number
	function ButtonMetaFunctions:SetFontSize(...)
		detailsFramework:SetFontSize(self.button.text, ...)
	end

	---set the font into the button text
	---@param font string
	function ButtonMetaFunctions:SetFontFace(font)
		detailsFramework:SetFontFace(self.button.text, font)
	end

	---comment
	---@param normalTexture any
	---@param highlightTexture any
	---@param pressedTexture any
	---@param disabledTexture any
	function ButtonMetaFunctions:SetTexture(normalTexture, highlightTexture, pressedTexture, disabledTexture)
		if (normalTexture) then
			self.button:SetNormalTexture(normalTexture)
		elseif (type(normalTexture) ~= "boolean") then
			self.button:SetNormalTexture("")
		end

		if (type(highlightTexture) == "boolean") then
			if (highlightTexture and normalTexture and type(normalTexture) ~= "boolean") then
				self.button:SetHighlightTexture(normalTexture, "ADD")
			end
		elseif (highlightTexture == nil) then
			self.button:SetHighlightTexture("")
		else
			self.button:SetHighlightTexture(highlightTexture, "ADD")
		end

		if (type(pressedTexture) == "boolean") then
			if (pressedTexture and normalTexture and type(normalTexture) ~= "boolean") then
				self.button:SetPushedTexture(normalTexture)
			end
		elseif (pressedTexture == nil) then
			self.button:SetPushedTexture("")
		else
			self.button:SetPushedTexture(pressedTexture, "ADD")
		end

		if (type(disabledTexture) == "boolean") then
			if (disabledTexture and normalTexture and type(normalTexture) ~= "boolean") then
				self.button:SetDisabledTexture(normalTexture)
			end
		elseif (disabledTexture == nil) then
			self.button:SetDisabledTexture("")
		else
			self.button:SetDisabledTexture(disabledTexture, "ADD")
		end
	end

	---return the texture set into the icon with SetIcon()
	---@return number|nil texture
	function ButtonMetaFunctions:GetIconTexture()
		if (self.icon) then
			return self.icon:GetTexture()
		end
	end

	local noColor = {1, 1, 1, 1}

	---add an icon to the left of the button text
	---short method truncates the text: false = do nothing, nil = increate the button width, 1 = decrease the font size, 2 = truncate the text
	---@param self table
	---@param texture any
	---@param width number|nil
	---@param height number|nil
	---@param layout "background|border|overlay|artwork"|nil
	---@param texcoord table|nil
	---@param overlay any
	---@param textDistance number|nil
	---@param leftPadding number|nil
	---@param textHeight number|nil
	---@param shortMethod any
	---@param filterMode any
	function ButtonMetaFunctions:SetIcon(texture, width, height, layout, texcoord, overlay, textDistance, leftPadding, textHeight, shortMethod, filterMode)
		if (not self.icon) then
			self.icon = self:CreateTexture(nil, "artwork")
			self.icon:SetSize(self.height * 0.8, self.height * 0.8)
			self.icon:SetPoint("left", self.widget, "left", 4 + (leftPadding or 0), 0)
			self.icon.leftPadding = leftPadding or 0
			self.widget.text:ClearAllPoints()
			self.widget.text:SetPoint("left", self.icon, "right", textDistance or 2, 0 + (textHeight or 0))
		end

		overlay = overlay or noColor
		local red, green, blue, alpha = detailsFramework:ParseColors(overlay or noColor)

		local left, right, top, bottom = texcoord and texcoord[1], texcoord and texcoord[2], texcoord and texcoord[3], texcoord and texcoord[4]
		texture, width, height, left, right, top, bottom, red, green, blue, alpha = detailsFramework:ParseTexture(texture, width, height, left, right, top, bottom, red, green, blue, alpha)

		if (red == nil) then
			red, green, blue, alpha = 1, 1, 1, 1
		end

		if (type(texture) == "string") then
			local isAtlas = C_Texture.GetAtlasInfo(texture)
			if (isAtlas) then
				self.icon:SetAtlas(texture)

			elseif (detailsFramework:IsHtmlColor(texture)) then
				local r, g, b, a = detailsFramework:ParseColors(texture)
				self.icon:SetColorTexture(r, g, b, a)
			else
				self.icon:SetTexture(texture, nil, nil, filterMode)
			end
		else
			self.icon:SetTexture(texture, nil, nil, filterMode)
		end

		self.icon:SetSize(width or self.height * 0.8, height or self.height * 0.8)

		self.icon:SetDrawLayer(layout or "artwork")

		self.icon:SetTexCoord(left, right, top, bottom)

		self.icon:SetVertexColor(red, green, blue, alpha)

		local buttonWidth = self.button:GetWidth()
		local iconWidth = self.icon:GetWidth()
		local textWidth = self.button.text:GetStringWidth()
		if (textWidth > buttonWidth - 15 - iconWidth) then
			if (shortMethod == false) then

			elseif (not shortMethod) then
				local new_width = textWidth + 15 + iconWidth
				self.button:SetWidth(new_width)

			elseif (shortMethod == 1) then
				local loop = true
				local textSize = 11
				while (loop) do
					if (textWidth + 15 + iconWidth < buttonWidth or textSize < 8) then
						loop = false
						break
					else
						detailsFramework:SetFontSize(self.button.text, textSize)
						textWidth = self.button.text:GetStringWidth()
						textSize = textSize - 1
					end
				end

			elseif (shortMethod == 2) then
				detailsFramework:TruncateText(self.button.text, self:GetWidth() - self.icon:GetWidth() - 15)
			end
		end
	end

	---@param self df_button
	---@param filterMode texturefilter
	function ButtonMetaFunctions:SetIconFilterMode(filterMode)
		if (self.icon) then
			self.icon:SetTexture(self.icon:GetTexture(), nil, nil, filterMode)
		end
	end

	---query if the button is enabled or not
	---@return boolean
	function ButtonMetaFunctions:IsEnabled()
		return self.button:IsEnabled()
	end

	---enable the button making it clickable and not grayed out
	---@return unknown
	function ButtonMetaFunctions:Enable()
		return self.button:Enable()
	end

	---disable the button making it unclickable and grayed out
	---@return unknown
	function ButtonMetaFunctions:Disable()
		if (self.color_texture) then
			self.color_texture:SetVertexColor(0.14, 0.14, 0.14)
		end
		return self.button:Disable()
	end

	---@param enable boolean
	function ButtonMetaFunctions:SetEnabled(enable)
		if (enable) then
			self:Enable()
		else
			self:Disable()
		end
	end

	---simulate a click on the button
	function ButtonMetaFunctions:Exec()
		local frameWidget = self.widget
		detailsFramework:CoreDispatch((frameWidget:GetName() or "Button") .. ":Exec()", self.func, frameWidget, "LeftButton", self.param1, self.param2)
	end

	---simulate a click on the button, but this function is called with a different name
	function ButtonMetaFunctions:Click()
		local frameWidget = self.widget
		detailsFramework:CoreDispatch((frameWidget:GetName() or "Button") .. ":Click()", self.func, frameWidget, "LeftButton", self.param1, self.param2)
	end

	---simulate a right click on the button
	function ButtonMetaFunctions:RightClick()
		local frameWidget = self.widget
		detailsFramework:CoreDispatch((frameWidget:GetName() or "Button") .. ":RightClick()", self.funcright, frameWidget, "RightButton", self.param1, self.param2)
	end

--custom textures
	function ButtonMetaFunctions:InstallCustomTexture()
		--function deprecated, now just set a the standard template
		self:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
	end

------------------------------------------------------------------------------------------------------------
--scripts

	local OnEnter = function(button)
		local object = button.MyObject

		local kill = object:RunHooksForWidget("OnEnter", button, object)
		if (kill) then
			return
		end

		object.is_mouse_over = true

		if (button.texture) then
			if (button.texture.coords) then
				button.texture:SetTexCoord(unpack(button.texture.coords.Highlight))
			else
				button.texture:SetTexCoord(0, 1, 0.24609375, 0.49609375)
			end
		end

		if (object.onenter_backdrop_border_color) then
			button:SetBackdropBorderColor(unpack(object.onenter_backdrop_border_color))
		end

		if (object.onenter_backdrop) then
			button:SetBackdropColor(unpack(object.onenter_backdrop))
		end

		object:ShowTooltip()
	end

	local OnLeave = function(button)
		local object = button.MyObject

		local kill = object:RunHooksForWidget("OnLeave", button, object)
		if (kill) then
			return
		end

		object.is_mouse_over = false

		if (button.texture and not object.is_mouse_down) then
			if (button.texture.coords) then
				button.texture:SetTexCoord(unpack(button.texture.coords.Normal))
			else
				button.texture:SetTexCoord(0, 1, 0, 0.24609375)
			end
		end

		if (object.onleave_backdrop_border_color) then
			button:SetBackdropBorderColor(unpack(object.onleave_backdrop_border_color))
		end

		if (object.onleave_backdrop) then
			button:SetBackdropColor(unpack(object.onleave_backdrop))
		end

		object:HideTooltip()
	end

	local OnHide = function(button)
		local object = button.MyObject
		local kill = object:RunHooksForWidget("OnHide", button, object)
		if (kill) then
			return
		end
	end

	local OnShow = function(button)
		local object = button.MyObject
		local kill = object:RunHooksForWidget("OnShow", button, object)
		if (kill) then
			return
		end
	end

	local OnMouseDown = function(button, buttontype)
		if (not button:IsEnabled()) then
			return
		end

		local object = button.MyObject

		local kill = object:RunHooksForWidget("OnMouseDown", button, object)
		if (kill) then
			return
		end

		object.is_mouse_down = true

		if (button.texture) then
			if (button.texture.coords) then
				button.texture:SetTexCoord(unpack(button.texture.coords.Pushed))
			else
				button.texture:SetTexCoord(0, 1, 0.5078125, 0.75)
			end
		end

		if (object.capsule_textalign) then
			if (object.icon) then
				object.icon:SetPoint("left", button, "left", 5 + (object.icon.leftPadding or 0), -1)

			elseif (object.capsule_textalign == "left") then
				button.text:SetPoint("left", button, "left", 3, -1)

			elseif (object.capsule_textalign == "center") then
				button.text:SetPoint("center", button, "center", 1, -1)

			elseif (object.capsule_textalign == "right") then
				button.text:SetPoint("right", button, "right", -1, -1)
			end
		else
			if (object.icon) then
				object.icon:SetPoint("left", button, "left", 5 + (object.icon.leftPadding or 0), -1)
			else
				button.text:SetPoint("center", button,"center", 1, -1)
			end
		end

		button.mouse_down = GetTime()
		local x, y = GetCursorPosition()
		button.x = math.floor(x)
		button.y = math.floor(y)

		if (not object.container.isLocked and object.container:IsMovable()) then
			if (not button.isLocked and button:IsMovable()) then
				object.container.isMoving = true
				object.container:StartMoving()
			end
		end

		if (object.options.OnGrab) then
			if (type(object.options.OnGrab) == "string" and object.options.OnGrab == "PassClick") then
				if (buttontype == "LeftButton") then
					detailsFramework:CoreDispatch((button:GetName() or "Button") .. ":OnMouseDown()", object.func, button, buttontype, object.param1, object.param2)
				else
					detailsFramework:CoreDispatch((button:GetName() or "Button") .. ":OnMouseDown()", object.funcright, button, buttontype, object.param1, object.param2)
				end
			end
		end
	end

	local OnMouseUp = function(button, buttonType)
		if (not button:IsEnabled()) then
			return
		end

		local object = button.MyObject

		local kill = object:RunHooksForWidget("OnMouseUp", button, object)
		if (kill) then
			return
		end

		object.is_mouse_down = false

		if (button.texture) then
			if (button.texture.coords) then
				if (object.is_mouse_over) then
					button.texture:SetTexCoord(unpack(button.texture.coords.Highlight))
				else
					--button.texture:SetTexCoord(unpack(coords.Normal))
				end
			else
				if (object.is_mouse_over) then
					button.texture:SetTexCoord(0, 1, 0.24609375, 0.49609375)
				else
					button.texture:SetTexCoord(0, 1, 0, 0.24609375)
				end
			end
		end

		if (object.capsule_textalign) then
			if (object.icon) then
				object.icon:SetPoint("left", button, "left", 4 + (object.icon.leftPadding or 0), 0)

			elseif (object.capsule_textalign == "left") then
				button.text:SetPoint("left", button, "left", 2, 0)

			elseif (object.capsule_textalign == "center") then
				button.text:SetPoint("center", button, "center", 0, 0)

			elseif (object.capsule_textalign == "right") then
				button.text:SetPoint("right", button, "right", -2, 0)
			end
		else
			if (object.icon) then
				object.icon:SetPoint("left", button, "left", 4 + (object.icon.leftPadding or 0), 0)
			else
				button.text:SetPoint("center", button,"center", 0, 0)
			end
		end

		if (object.container.isMoving) then
			object.container:StopMovingOrSizing()
			object.container.isMoving = false
		end

		local x, y = GetCursorPosition()
		x = math.floor(x)
		y = math.floor(y)

		button.mouse_down = button.mouse_down or 0 --avoid issues when the button was pressed while disabled and release when enabled

		if ((x == button.x and y == button.y) or (button.mouse_down + 0.5 > GetTime() and button:IsMouseOver())) then
			if (buttonType == "LeftButton") then
				xpcall(object.func, geterrorhandler(), button, buttonType, object.param1, object.param2)
			else
				xpcall(object.funcright, geterrorhandler(), button, buttonType, object.param1, object.param2)
			end
		end
	end

------------------------------------------------------------------------------------------------------------

---receives a table where the keys are settings and the values are the values to set
---this is the list of keys the table support:
---width, height, icon|table, textcolor, textsize, textfont, textalign, backdrop, backdropcolor, backdropbordercolor, onentercolor, onleavecolor, onenterbordercolor, onleavebordercolor
---@param template table|string
function ButtonMetaFunctions:SetTemplate(template)
	template = detailsFramework:ParseTemplate(self.type, template)

	if (not template) then
		detailsFramework:Error("template not found")
		return
	end

	if (template.width) then
		PixelUtil.SetWidth(self.button, template.width)
	end

	if (template.height) then
		PixelUtil.SetHeight(self.button, template.height)
	end

	if (template.backdrop) then
		self:SetBackdrop(template.backdrop)
	end

	if (template.backdropcolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.backdropcolor)
		self:SetBackdropColor(r, g, b, a)
		self.onleave_backdrop = {r, g, b, a}
	end

	if (template.backdropbordercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.backdropbordercolor)
		self:SetBackdropBorderColor(r, g, b, a)
		self.onleave_backdrop_border_color = {r, g, b, a}
	end

	if (template.onentercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onentercolor)
		self.onenter_backdrop = {r, g, b, a}
	end

	if (template.onleavecolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onleavecolor)
		self.onleave_backdrop = {r, g, b, a}
	end

	if (template.onenterbordercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onenterbordercolor)
		self.onenter_backdrop_border_color = {r, g, b, a}
	end

	if (template.onleavebordercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onleavebordercolor)
		self.onleave_backdrop_border_color = {r, g, b, a}
	end

	if (template.icon) then
		local iconInfo = template.icon
		self:SetIcon(iconInfo.texture, iconInfo.width, iconInfo.height, iconInfo.layout, iconInfo.texcoord, iconInfo.color, iconInfo.textdistance, iconInfo.leftPadding)
	end

	if (template.textsize) then
		self.textsize = template.textsize
	end

	if (template.textfont) then
		self.textfont = template.textfont
	end

	if (template.textcolor) then
		self.textcolor = template.textcolor
	end

	if (template.textalign) then
		self.textalign = template.textalign
	end

	if (template.rounded_corner) then
		self:SetBackdrop(nil)
		detailsFramework:AddRoundedCornersToFrame(self.widget or self, template.rounded_corner)

		--check if this is a color picker button
		if (self.__iscolorpicker) then
			self.color_texture:SetTexture([[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]], "CLAMP", "CLAMP", "TRILINEAR")
			self.color_texture:SetDrawLayer("overlay", 7)
			self.color_texture:SetPoint("topleft", self.widget, "topleft", 2, -2)
			self.color_texture:SetPoint("bottomright", self.widget, "bottomright", -2, 2)

			self.background_texture:SetDrawLayer("overlay", 6)
			self.background_texture:SetPoint("topleft", self.color_texture, "topleft", 2, -2)
			self.background_texture:SetPoint("bottomright", self.color_texture, "bottomright", -2, 2)

			self.widget.texture_disabled:SetTexture([[Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall]], "CLAMP", "CLAMP", "TRILINEAR")
		end
	end
end

------------------------------------------------------------------------------------------------------------
--object constructor
	local onDisableFunc = function(self)
		self.texture_disabled:Show()
		self.texture_disabled:SetVertexColor(0.1, 0.1, 0.1)
		self.texture_disabled:SetAlpha(.834)
	end

	local onEnableFunc = function(self)
		self.texture_disabled:Hide()
	end

	local createButtonWidgets = function(self)
		self:SetSize(100, 20)

		self.text = self:CreateFontString("$parent_Text", "ARTWORK", "GameFontNormal")
		self.text:SetJustifyH("CENTER")
		self.text:SetPoint("CENTER", self, "CENTER", 0, 0)
		self:SetFontString(self.text)
		detailsFramework:SetFontSize(self.text, 10)

		self.texture_disabled = self:CreateTexture("$parent_TextureDisabled", "OVERLAY")
		self.texture_disabled:SetAllPoints()
		self.texture_disabled:Hide()
		self.texture_disabled:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")

		self:SetScript("OnDisable", onDisableFunc)
		self:SetScript("OnEnable", onEnableFunc)
	end

	---@class df_blizzbutton : button
	---@field text fontstring
	---@field MyObject df_button

	---@class df_button : button, df_scripthookmixin, df_widgets
	---@field widget df_blizzbutton
	---@field button df_blizzbutton
	---@field tooltip string
	---@field shown boolean
	---@field width number
	---@field height number
	---@field text string
	---@field clickfunction function
	---@field texture string
	---@field locked boolean
	---@field fontcolor any
	---@field fontface string
	---@field fontsize number
	---@field textcolor any
	---@field textfont string
	---@field textsize number
	---@field icon texture created after calling SetIcon()
	---@field SetTemplate fun(self: df_button, template: table|string) set the button visual by a template
	---@field RightClick fun(self: df_button) right click the button executing its right click function
	---@field Exec fun(self: df_button) execute the button function for the left button
	---@field Disable fun(self: df_button) disable the button
	---@field Enable fun(self: df_button) enable the button
	---@field SetEnabled fun(self: df_button, enable: boolean) enable or disable the button
	---@field IsEnabled fun(self: df_button) : boolean returns true if the button is enabled
	---@field SetIcon fun(self: df_button,texture: string|number, width: number|nil, height: number|nil, layout: string|nil, texcoord: table|nil, overlay: table|nil, textDistance: number|nil, leftPadding: number|nil, textHeight: number|nil, shortMethod: any|nil)
	---@field GetIconTexture fun(self: df_button) : string returns the texture path of the button icon
	---@field SetTexture fun(self: df_button, normalTexture: any, highlightTexture: any, pressedTexture: any, disabledTexture: any) set the regular button textures
	---@field SetFontFace fun(self: df_button, font: string) set the button font
	---@field SetFontSize fun(self: df_button, size: number) set the button font size
	---@field SetTextColor fun(self: df_button, color: any) set the button text color
	---@field SetText fun(self: df_button, text: string) set the button text
	---@field SetTextTruncated fun(self: df_button, text: string, maxWidth: number) set the button text and truncate it if it's too long
	---@field SetParameters fun(self: df_button, param1: any, param2: any) set the parameters for the button callback function
	---@field SetClickFunction fun(self: df_button, func: function, param1: any, param2: any, clickType: "left"|"right"|nil)
	---@field SetIconFilterMode fun(self: df_button, filterMode: any) set the filter mode for the icon, execute after SetIcon()

	---create a Details Framework button
	---@param parent frame
	---@param callback function
	---@param width number
	---@param height number
	---@param text any
	---@param param1 any|nil
	---@param param2 any|nil
	---@param texture any|nil
	---@param member string|nil
	---@param name string|nil
	---@param shortMethod boolean|nil
	---@param buttonTemplate table|nil
	---@param textTemplate table|nil
	---@return df_button
	function detailsFramework:CreateButton(parent, callback, width, height, text, param1, param2, texture, member, name, shortMethod, buttonTemplate, textTemplate)
		return detailsFramework:NewButton(parent, parent, name, member, width, height, callback, param1, param2, texture, text, shortMethod, buttonTemplate, textTemplate)
	end

	---@return df_button
	function detailsFramework:NewButton(parent, container, name, member, width, height, func, param1, param2, texture, text, shortMethod, buttonTemplate, textTemplate)
		if (not parent) then
			error("Details! FrameWork: parent not found.", 2)
		end

		if (not name) then
			local parentName = parent:GetName()
			if (parentName) then
				name = parentName .. "Button" .. detailsFramework.ButtonCounter
			else
				name = "DetailsFrameworkButtonNumber" .. detailsFramework.ButtonCounter
			end
			detailsFramework.ButtonCounter = detailsFramework.ButtonCounter + 1
		end

		local buttonObject = {type = "button", dframework = true}

		if (member) then
			parent[member] = buttonObject
		end

		if (parent.dframework) then
			parent = parent.widget
		end

		--container is used to move the 'container' frame when attempt to move the button
		buttonObject.container = container or parent

		--default members
		buttonObject.is_locked = true
		buttonObject.options = {OnGrab = false}

		buttonObject.button = CreateFrame("button", name, parent, "BackdropTemplate")
		detailsFramework:Mixin(buttonObject.button, detailsFramework.WidgetFunctions)

		createButtonWidgets(buttonObject.button)
		PixelUtil.SetSize(buttonObject.button, width or 100, height or 20)
		buttonObject.widget = buttonObject.button
		buttonObject.button.MyObject = buttonObject

		if (not APIButtonFunctions) then
			APIButtonFunctions = true
			local idx = getmetatable(buttonObject.button).__index
			for funcName, funcAddress in pairs(idx) do
				if (not ButtonMetaFunctions[funcName]) then
					ButtonMetaFunctions[funcName] = function(object, ...)
						local x = loadstring("return _G['"..object.button:GetName().."']:"..funcName.."(...)")
						return x(...)
					end
				end
			end
		end

		buttonObject.text_overlay = _G[name .. "_Text"]
		buttonObject.disabled_overlay = _G[name .. "_TextureDisabled"]

		texture = texture or ""
		
		--check for atlas
		local bSetTexture = false
		if (type(texture) == "string") then
			local isAtlas = C_Texture.GetAtlasInfo(texture)
			if (isAtlas) then
				buttonObject.button:SetNormalTexture("")
				buttonObject.button:GetNormalTexture():SetAtlas(texture)
				buttonObject.button:SetPushedTexture("")
				buttonObject.button:GetPushedTexture():SetAtlas(texture)
				buttonObject.button:SetDisabledTexture("")
				buttonObject.button:GetDisabledTexture():SetAtlas(texture)
				buttonObject.button:SetHighlightTexture("")
				buttonObject.button:GetHighlightTexture():SetAtlas(texture)
				bSetTexture = true

			elseif (detailsFramework:IsHtmlColor(texture)) then
				local r, g, b, a = detailsFramework:ParseColors(texture)
				self.icon:SetColorTexture(r, g, b, a)
				bSetTexture = true

			elseif (texture == "") then
				bSetTexture = true -- setting textures with an empty string causes green rectangles
			end
		end

		if (not bSetTexture) then
			buttonObject.button:SetNormalTexture(texture)
			buttonObject.button:SetPushedTexture(texture)
			buttonObject.button:SetDisabledTexture(texture)
			buttonObject.button:SetHighlightTexture(texture, "ADD")
		end

		local locTable = text
		detailsFramework.Language.SetTextWithLocTableWithDefault(buttonObject.button.text, locTable, text)

		buttonObject.button.text:SetPoint("center", buttonObject.button, "center")

		local textWidth = buttonObject.button.text:GetStringWidth()
		if (textWidth > width - 15 and buttonObject.button.text:GetText() ~= "") then
			if (shortMethod == false) then --if is false, do not use auto resize
				--do nothing
			elseif (not shortMethod) then --if the value is omitted, use the default resize
				local newWidth = textWidth + 15
				PixelUtil.SetWidth(buttonObject.button, newWidth)

			elseif (shortMethod == 1) then
				local loop = true
				local textsize = 11
				while (loop) do
					if (textWidth + 15 < width or textsize < 8) then
						loop = false
						break
					else
						detailsFramework:SetFontSize(buttonObject.button.text, textsize)
						textWidth = buttonObject.button.text:GetStringWidth()
						textsize = textsize - 1
					end
				end
			elseif (shortMethod == 2) then

			end
		end

		buttonObject.func = func or emptyFunction
		buttonObject.funcright = emptyFunction
		buttonObject.param1 = param1
		buttonObject.param2 = param2
		buttonObject.short_method = shortMethod

		if (textTemplate) then
			if (textTemplate.size) then
				detailsFramework:SetFontSize(buttonObject.button.text, textTemplate.size)
			end

			if (textTemplate.color) then
				local r, g, b, a = detailsFramework:ParseColors(textTemplate.color)
				buttonObject.button.text:SetTextColor(r, g, b, a)
			end

			if (textTemplate.font) then
				local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
				local font = SharedMedia:Fetch("font", textTemplate.font)
				detailsFramework:SetFontFace(buttonObject.button.text, font)
			end
		end

		--hooks
		buttonObject.HookList = {
			OnEnter = {},
			OnLeave = {},
			OnHide = {},
			OnShow = {},
			OnMouseDown = {},
			OnMouseUp = {},
		}

		buttonObject.button:SetScript("OnEnter", OnEnter)
		buttonObject.button:SetScript("OnLeave", OnLeave)
		buttonObject.button:SetScript("OnHide", OnHide)
		buttonObject.button:SetScript("OnShow", OnShow)
		buttonObject.button:SetScript("OnMouseDown", OnMouseDown)
		buttonObject.button:SetScript("OnMouseUp", OnMouseUp)

		setmetatable(buttonObject, ButtonMetaFunctions)

		if (buttonTemplate) then
			buttonObject:SetTemplate(buttonTemplate)
		end

		return buttonObject
	end

------------------------------------------------------------------------------------------------------------
--color picker button
	local pickcolorCallback = function(self, red, green, blue, alpha, button)
		alpha = math.max(0, math.min(1, alpha))
		button.MyObject.color_texture:SetVertexColor(red, green, blue, alpha)

		--safecall
		detailsFramework:CoreDispatch((self:GetName() or "ColorPicker") .. ".pickcolor_callback()", button.MyObject.color_callback, button.MyObject, red, green, blue, alpha)
		button.MyObject:RunHooksForWidget("OnColorChanged", button.MyObject, red, green, blue, alpha)
	end

	local pickcolor = function(self)
		local red, green, blue, alpha = self.MyObject.color_texture:GetVertexColor()
		alpha = math.max(0, math.min(1, alpha))
		detailsFramework:ColorPick(self, red, green, blue, alpha, pickcolorCallback)
	end

	local setColorPickColor = function(button, ...)
		local red, green, blue, alpha = detailsFramework:ParseColors(...)
		button.color_texture:SetVertexColor(red, green, blue, alpha)
	end

	local colorpickCancel = function(self)
		ColorPickerFrame:Hide()
	end

	local getColorPickColor = function(self)
		return self.color_texture:GetVertexColor()
	end

	---@class df_colorpickbutton : df_button
	---@field color_callback function
	---@field Cancel function
	---@field SetColor function
	---@field GetColor function
	---@field __iscolorpicker boolean
	---@field color_texture texture
	---@field background_texture texture

	---create a button which opens a color picker when clicked
	---@param parent table
	---@param name string|nil
	---@param member string|nil
	---@param callback function
	---@param alpha number|nil
	---@param buttonTemplate table|nil
	---@return df_colorpickbutton
	function detailsFramework:CreateColorPickButton(parent, name, member, callback, alpha, buttonTemplate)
		return detailsFramework:NewColorPickButton(parent, name, member, callback, alpha, buttonTemplate)
	end

	function detailsFramework:NewColorPickButton(parent, name, member, callback, alpha, buttonTemplate)
		local colorPickButton = detailsFramework:NewButton(parent, _, name, member, 16, 16, pickcolor, alpha, "param2")
		---@cast colorPickButton df_colorpickbutton

		colorPickButton.color_callback = callback
		colorPickButton.Cancel = colorpickCancel
		colorPickButton.SetColor = setColorPickColor
		colorPickButton.GetColor = getColorPickColor
		colorPickButton.__iscolorpicker = true

		colorPickButton.HookList.OnColorChanged = {}

		--background showing a grid to indicate the transparency
		local background = colorPickButton:CreateTexture("$parentBackgroupTransparency", "background", nil, 2)
		background:SetPoint("topleft", colorPickButton.widget, "topleft", 0, 0)
		background:SetPoint("bottomright", colorPickButton.widget, "bottomright", 0, 0)
		background:SetAtlas("AnimCreate_Icon_Texture")
		background:SetAlpha(0.3)
		colorPickButton.background_texture = background

		--texture which shows the texture color
		local colorTexture = colorPickButton:CreateTexture("$parentTex", "overlay")
		colorTexture:SetColorTexture(1, 1, 1)
		colorTexture:SetPoint("topleft", colorPickButton.widget, "topleft", 0, 0)
		colorTexture:SetPoint("bottomright", colorPickButton.widget, "bottomright", 0, 0)
		colorTexture:SetDrawLayer("background", 3)
		colorPickButton.color_texture = colorTexture

		if (not buttonTemplate) then
			colorPickButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
		else
			colorPickButton:SetTemplate(buttonTemplate)
		end

		return colorPickButton
	end

	---set the texture of all 4 textures of a button to the same texture
	---@param button button
	---@param texture textureid|texturepath
	---@param left coordleft|table|nil
	---@param right coordright|nil
	---@param top coordtop|nil
	---@param bottom coordbottom|nil
    function detailsFramework:SetButtonTexture(button, texture, left, right, top, bottom)
        if (type(left) == "table") then
            left, right, top, bottom = unpack(left)
        end

        if (not left) then
            left, right, top, bottom = 0, 1, 0, 1
        end

        local atlas
        if (type(texture) == "string") then
            atlas = C_Texture.GetAtlasInfo(texture)
			if (atlas) then
				atlas = texture
			end
		end

		local normalTexture = button:GetNormalTexture()
		local pushedTexture = button:GetPushedTexture()
		local highlightTexture = button:GetHighlightTexture()
		local disabledTexture = button:GetDisabledTexture()

		if (type(texture) == "table") then
			local normalTexturePath, pushedTexturePath, highlightTexturePath, disabledTexturePath = unpack(texture)
			---@cast right number
			---@cast top number
			---@cast bottom number

			if (normalTexturePath) then
				normalTexture:SetTexture(normalTexturePath)
				normalTexture:SetTexCoord(left, right, top, bottom)
			end

			if (pushedTexturePath) then
				pushedTexture:SetTexture(pushedTexturePath)
				pushedTexture:SetTexCoord(left, right, top, bottom)
			end

			if (highlightTexturePath) then
				highlightTexture:SetTexture(highlightTexturePath)
				highlightTexture:SetTexCoord(left, right, top, bottom)
			end

			if (disabledTexturePath) then
				disabledTexture:SetTexture(disabledTexturePath)
				disabledTexture:SetTexCoord(left, right, top, bottom)
			end

        elseif (atlas) then
            normalTexture:SetAtlas(atlas)
            pushedTexture:SetAtlas(atlas)
            highlightTexture:SetAtlas(atlas)
            disabledTexture:SetAtlas(atlas)

        else
            normalTexture:SetTexture(texture)
            pushedTexture:SetTexture(texture)
            highlightTexture:SetTexture(texture)
            disabledTexture:SetTexture(texture)

			---@cast right number
			---@cast top number
			---@cast bottom number
            normalTexture:SetTexCoord(left, right, top, bottom)
            pushedTexture:SetTexCoord(left, right, top, bottom)
            highlightTexture:SetTexCoord(left, right, top, bottom)
            disabledTexture:SetTexCoord(left, right, top, bottom)
        end
    end

	---set the vertex color of all 4 textures of a button to the same color
	---@param button button
	---@param red any
	---@param green number|nil
	---@param blue number|nil
	---@param alpha number|nil
	function detailsFramework:SetButtonVertexColor(button, red, green, blue, alpha)
        red, green, blue, alpha = detailsFramework:ParseColor(red, green, blue, alpha)
        local normalTexture = button:GetNormalTexture()
        local pushedTexture = button:GetPushedTexture()
        local highlightTexture = button:GetHighlightTexture()
        local disabledTexture = button:GetDisabledTexture()

        normalTexture:SetVertexColor(red, green, blue, alpha)
        pushedTexture:SetVertexColor(red, green, blue, alpha)
        highlightTexture:SetVertexColor(red, green, blue, alpha)
        disabledTexture:SetVertexColor(red, green, blue, alpha)
    end


------------------------------------------------------------------------------------------------------------
--tab button

---@class df_tabbutton : button
---@field LeftTexture texture
---@field RightTexture texture
---@field MiddleTexture texture
---@field SelectedTexture texture
---@field Text fontstring
---@field CloseButton df_closebutton
---@field leftTextureName string
---@field rightTextureName string
---@field middleTextureName string
---@field leftTextureSelectedName string
---@field rightTextureSelectedName string
---@field middleTextureSelectedName string
---@field bIsSelected boolean
---@field SetText fun(self: df_tabbutton, text: string) --set the tab text
---@field SetSelected fun(self: df_tabbutton, selected: boolean) --highlight the tab textures to indicate the tab is selected
---@field SetShowCloseButton fun(self: df_tabbutton, show: boolean) --set if the close button can be shown or not
---@field GetFontString fun(self: df_tabbutton) : fontstring --get the fontstring used to display the tab text
---@field IsSelected fun(self: df_tabbutton): boolean --get a boolean representing if the tab is selected
---@field Reset fun(self: df_tabbutton) --set all textures to their default values, set the text to an empty string, set the selected state to false

detailsFramework.TabButtonMixin = {
	---set the text of the tab button
	---@param self df_tabbutton
	---@param text string
	SetText = function(self, text)
		self.Text:SetText(text)
		--adjust the width of the tab button to fit the text
		local fontStringLength = self.Text:GetStringWidth()
		self:SetWidth(fontStringLength + 20)
	end,

	---highlight the tab textures to indicate the tab is selected
	---@param self df_tabbutton
	---@param selected boolean
	SetSelected = function(self, selected)
		self.LeftTexture:SetAtlas(selected and self.leftTextureSelectedName or self.leftTextureName)
		self.RightTexture:SetAtlas(selected and self.rightTextureSelectedName or self.rightTextureName)
		self.MiddleTexture:SetAtlas(selected and self.middleTextureSelectedName or self.middleTextureName)
		self.SelectedTexture:SetShown(selected)
		self.bIsSelected = selected
	end,

	---set if the close button can be shown or not
	---@param self df_tabbutton
	---@param show boolean
	SetShowCloseButton = function(self, show)
		self.CloseButton:SetShown(show)
	end,

	---get a boolean representing if the tab is selected
	---@param self df_tabbutton
	---@return boolean
	IsSelected = function(self)
		return self.bIsSelected
	end,

	---set all textures to their default values, set the text to an empty string, set the selected state to false
	---@param self df_tabbutton
	Reset = function(self)
		self.LeftTexture:SetAtlas(self.leftTextureName)
		self.RightTexture:SetAtlas(self.rightTextureName)
		self.MiddleTexture:SetAtlas(self.middleTextureName)
		self.Text:SetText("")
		self.bIsSelected = false
		self.SelectedTexture:Hide()
	end,

	---get the fontstring used to display the tab text
	---@param self df_tabbutton
	---@return fontstring
	GetFontString = function(self)
		return self.Text
	end,
}

---create a button which can be used as a tab button, has textures for left, right, middle and a text
---@param parent frame
---@param frameName string|nil
---@return df_tabbutton
function detailsFramework:CreateTabButton(parent, frameName)
	---@type df_tabbutton
	local tabButton = CreateFrame("button", frameName, parent, "BackdropTemplate")
	tabButton:SetSize(50, 20)
	tabButton.bIsSelected = false

	detailsFramework:Mixin(tabButton, detailsFramework.TabButtonMixin)

	tabButton.LeftTexture = tabButton:CreateTexture(nil, "artwork")
	tabButton.RightTexture = tabButton:CreateTexture(nil, "artwork")
	tabButton.MiddleTexture = tabButton:CreateTexture(nil, "artwork")
	tabButton.SelectedTexture = tabButton:CreateTexture(nil, "overlay")
	tabButton.SelectedTexture:SetBlendMode("ADD")
	tabButton.SelectedTexture:SetAlpha(0.5)
	tabButton.SelectedTexture:Hide()
	tabButton.Text = tabButton:CreateFontString(nil, "overlay", "GameFontNormal")
	tabButton.CloseButton = detailsFramework:CreateCloseButton(tabButton, "$parentCloseButton")
	tabButton.CloseButton:SetSize(10, 10)
	tabButton.CloseButton:SetAlpha(0.6)
	tabButton.CloseButton:Hide()

	tabButton.Text:SetPoint("center", tabButton, "center", 0, 0)
	tabButton.CloseButton:SetPoint("topright", tabButton, "topright", 0, 0)

	tabButton.LeftTexture:SetPoint("bottomleft", tabButton, "bottomleft", 0, 0)
	tabButton.LeftTexture:SetPoint("topleft", tabButton, "topleft", 0, 0)

	tabButton.RightTexture:SetPoint("bottomright", tabButton, "bottomright", 0, 0)
	tabButton.RightTexture:SetPoint("topright", tabButton, "topright", 0, 0)

	tabButton.MiddleTexture:SetPoint("topleft", tabButton.LeftTexture, "topright", 0, 0)
	tabButton.MiddleTexture:SetPoint("topright", tabButton.RightTexture, "topleft", 0, 0)

	tabButton.SelectedTexture:SetAllPoints(tabButton.MiddleTexture)

	tabButton.leftTextureName = "Options_Tab_Left"
	tabButton.rightTextureName = "Options_Tab_Right"
	tabButton.middleTextureName = "Options_Tab_Middle"

	tabButton.leftTextureSelectedName = "Options_Tab_Active_Left"
	tabButton.rightTextureSelectedName = "Options_Tab_Active_Right"
	tabButton.middleTextureSelectedName = "Options_Tab_Active_Middle"

	tabButton.LeftTexture:SetAtlas(tabButton.leftTextureName)
	tabButton.LeftTexture:SetWidth(2)

	tabButton.RightTexture:SetAtlas(tabButton.rightTextureName)
	tabButton.RightTexture:SetWidth(2)

	tabButton.MiddleTexture:SetAtlas(tabButton.middleTextureName)
	tabButton.MiddleTexture:SetHeight(20)

	tabButton.SelectedTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight-yellow]])

	tabButton.Text:SetText("")

	return tabButton
end

--[=[
	--example:
	local frame = CreateFrame("frame", "MyTestFrameForTabutton", UIParent)
	frame:SetSize(650, 100)
	frame:SetPoint("center", UIParent, "center", 0, 0)
	DetailsFramework:ApplyStandardBackdrop(frame)
	frame.TabButtons = {}

	local tabOnClickCallback = function(self)
		for _, tab in ipairs(frame.TabButtons) do
			tab:SetSelected(false)
		end
		self:SetSelected(true)
	end

	for i = 1, 5 do
		local tabButton = DetailsFramework:CreateTabButton(frame, "$parentTabButton" .. i)
		tabButton:SetPoint("bottomleft", frame, "topleft", (i-1) * 130, 0)
		tabButton:SetText("Tab " .. i)
		tabButton:SetWidth(128)

		table.insert(frame.TabButtons, tabButton)
		tabButton:SetScript("OnClick", tabOnClickCallback)
	end

	--select a tab to be the default selected (if wanted)
	frame.TabButtons[1]:SetSelected(true)

	--set shown state of the close button (if wanted)
	frame.TabButtons[2]:SetShowCloseButton(true)
--]=]

------------------------------------------------------------------------------------------------------------
--close button

detailsFramework.CloseButtonMixin = {
	OnClick = function(self)
		self:GetParent():Hide()
	end,

	OnEnter = function(self)
		self:GetNormalTexture():SetVertexColor(1, 0, 0)
	end,

	OnLeave = function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
	end,
}

---@class df_closebutton : button
---@field OnClick fun(self: df_closebutton)
---@field OnEnter fun(self: df_closebutton)
---@field OnLeave fun(self: df_closebutton)

---create a close button which when clicked will hide the parent frame
---@param parent frame
---@param frameName string|nil
---@return df_closebutton
function detailsFramework:CreateCloseButton(parent, frameName)
	---@type df_closebutton
	local closeButton = CreateFrame("button", frameName, parent, "UIPanelCloseButton")
	closeButton:SetFrameLevel(parent:GetFrameLevel() + 1)
	closeButton:SetSize(16, 16)

	detailsFramework:Mixin(closeButton, detailsFramework.CloseButtonMixin)

	local normalTexture = closeButton:GetNormalTexture()
	local pushedTexture = closeButton:GetPushedTexture()
	local highlightTexture = closeButton:GetHighlightTexture()
	local disabledTexture = closeButton:GetDisabledTexture()

	normalTexture:SetAtlas("RedButton-Exit")
	highlightTexture:SetAtlas("RedButton-Highlight")
	pushedTexture:SetAtlas("RedButton-exit-pressed")
	disabledTexture:SetAtlas("RedButton-Exit-Disabled")

	normalTexture:SetDesaturated(true)
	highlightTexture:SetDesaturated(true)
	pushedTexture:SetDesaturated(true)

	closeButton:SetAlpha(0.7)
	closeButton:SetScript("OnClick", closeButton.OnClick)
	closeButton:SetScript("OnEnter", closeButton.OnEnter)
	closeButton:SetScript("OnLeave", closeButton.OnLeave)

	return closeButton
end

--[=[
	--example:
	local frame = CreateFrame("frame", "MyTestFrameForCloseButton", UIParent)
	frame:SetSize(200, 200)
	frame:SetPoint("center", UIParent, "center", 0, 0)

	local closeButton = detailsFramework:CreateCloseButton(frame, "$parentCloseButton")
	closeButton:SetPoint("topright", frame, "topright", 0, 0)
--]=]
