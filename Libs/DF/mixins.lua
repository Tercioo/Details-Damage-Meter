
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _

local getFrame = function(frame)
	return rawget(frame, "widget") or frame
end

detailsFramework.WidgetFunctions = {
	GetCapsule = function(self)
		return self.MyObject
	end,

	GetObject = function(self)
		return self.MyObject
	end,
}

detailsFramework.DefaultMetaFunctionsGet = {
	parent = function(object)
		return object:GetParent()
	end,

	shown = function(object)
		return object:IsShown()
	end,
}

detailsFramework.TooltipHandlerMixin = {
	SetTooltip = function(self, tooltip)
		if (tooltip) then
			if (detailsFramework.Language.IsLocTable(tooltip)) then
				--register the locTable as a tableKey
				local locTable = tooltip
				detailsFramework.Language.RegisterTableKeyWithLocTable(self, "have_tooltip", locTable)
			else
				self.have_tooltip = tooltip
			end
		else
			self.have_tooltip = nil
		end
	end,

	GetTooltip = function(self)
		return self.have_tooltip
	end,

	ShowTooltip = function(self)
		local tooltipText = self:GetTooltip()

		if (type(tooltipText) == "function") then
			local tooltipFunction = tooltipText
			local gotTooltip, tooltipString = xpcall(tooltipFunction, geterrorhandler())
			if (gotTooltip) then
				tooltipText = tooltipString
			end
		end

		if (tooltipText and tooltipText ~= "") then
			GameCooltip:Preset(2)
			GameCooltip:AddLine(tooltipText)
			--GameCooltip:ShowRoundedCorner() --disabled rounded corners by default
			GameCooltip:ShowCooltip(getFrame(self), "tooltip")
		end
	end,

	HideTooltip = function(self)
		local tooltipText = self:GetTooltip()
		if (tooltipText) then
			if (GameCooltip:IsOwner(getFrame(self))) then
				GameCooltip:Hide()
			end
		end
	end,
}

detailsFramework.DefaultMetaFunctionsSet = {
	parent = function(object, value)
		return object:SetParent(value)
	end,

	show = function(object, value)
		if (value) then
			return object:Show()
		else
			return object:Hide()
		end
	end,

	hide = function(object, value)
		if (value) then
			return object:Hide()
		else
			return object:Show()
		end
	end,
}

detailsFramework.DefaultMetaFunctionsSet.shown = detailsFramework.DefaultMetaFunctionsSet.show

detailsFramework.LayeredRegionMetaFunctionsSet = {
	drawlayer = function(object, value)
		object.image:SetDrawLayer(value)
	end,

	sublevel = function(object, value)
		local drawLayer = object:GetDrawLayer()
		object:SetDrawLayer(drawLayer, value)
	end,
}

detailsFramework.LayeredRegionMetaFunctionsGet = {
	drawlayer = function(object)
		return object.image:GetDrawLayer()
	end,

	sublevel = function(object)
		local _, subLevel = object.image:GetDrawLayer()
		return subLevel
	end,
}

detailsFramework.FrameMixin = {
	SetFrameStrata = function(self, strata)
		self = getFrame(self)
		if (type(strata) == "table" and strata.GetObjectType) then
			local UIObject = strata
			self:SetFrameStrata(UIObject:GetFrameStrata())
		else
			self:SetFrameStrata(strata)
		end
	end,

	SetFrameLevel = function(self, level, UIObject)
		self = getFrame(self)
		if (not UIObject) then
			self:SetFrameLevel(level)
		else
			local framelevel = UIObject:GetFrameLevel(UIObject) + level
			self:SetFrameLevel(framelevel)
		end
	end,

	SetSize = function(self, width, height)
		self = getFrame(self)
		if (width) then
			self:SetWidth(width)
		end
		if (height) then
			self:SetHeight(height)
		end
	end,

	SetBackdrop = function(self, ...)
		self = getFrame(self)
		self:SetBackdrop(...)
	end,

	SetBackdropColor = function(self, ...)
		self = getFrame(self)
		self:SetBackdropColor(...)
	end,

	SetBackdropBorderColor = function(self, ...)
		self = getFrame(self)
		self:SetBackdropBorderColor(...)
	end,
}

local doublePoint = {
	["lefts"] = true,
	["rights"] = true,
	["tops"] = true,
	["bottoms"] = true,

	["left-left"] = true,
	["right-right"] = true,
	["top-top"] = true,
	["bottom-bottom"] = true,

	["bottom-top"] = true,
	["top-bottom"] = true,
	["right-left"] = true,
	["left-right"] = true,
}

---@alias anchor_name "lefts" | "rights" | "tops" | "bottoms" | "left-left" | "right-right" | "top-top" | "bottom-bottom" | "bottom-top" | "top-bottom" | "right-left" | "left-right" | "topleft" | "topright" | "bottomleft" | "bottomright" | "left" | "right" | "top" | "bottom" | "center"

---@class df_setpoint : table
---@field SetPoint fun(self: table, anchorName1: anchor_name, anchorObject: table?, anchorName2: string?, xOffset: number?, yOffset: number?)
---@field SetPoints fun(self: table, anchorName1: anchor_name, anchorObject: table?, anchorName2: string?, xOffset: number?, yOffset: number?)

detailsFramework.SetPointMixin = {
	SetPoint = function(object, anchorName1, anchorObject, anchorName2, xOffset, yOffset)
		if (doublePoint[anchorName1]) then
			object:ClearAllPoints()
			local anchorTo
			if (anchorObject and type(anchorObject) == "table") then
				xOffset, yOffset = anchorName2 or 0, xOffset or 0
				anchorTo = getFrame(anchorObject)
			else
				xOffset, yOffset = anchorObject or 0, anchorName2 or 0
				anchorTo = object:GetParent()
			end

			--offset always inset to inner
			if (anchorName1 == "lefts") then
				object:SetPoint("topleft", anchorTo, "topleft", xOffset, -yOffset)
				object:SetPoint("bottomleft", anchorTo, "bottomleft", xOffset, yOffset)

			elseif (anchorName1 == "rights") then
				object:SetPoint("topright", anchorTo, "topright", xOffset, -yOffset)
				object:SetPoint("bottomright", anchorTo, "bottomright", xOffset, yOffset)

			elseif (anchorName1 == "tops") then
				object:SetPoint("topleft", anchorTo, "topleft", xOffset, -yOffset)
				object:SetPoint("topright", anchorTo, "topright", -xOffset, -yOffset)

			elseif (anchorName1 == "bottoms") then
				object:SetPoint("bottomleft", anchorTo, "bottomleft", xOffset, yOffset)
				object:SetPoint("bottomright", anchorTo, "bottomright", -xOffset, yOffset)

			elseif (anchorName1 == "left-left") then
				object:SetPoint("left", anchorTo, "left", xOffset, yOffset)

			elseif (anchorName1 == "right-right") then
				object:SetPoint("right", anchorTo, "right", xOffset, yOffset)

			elseif (anchorName1 == "top-top") then
				object:SetPoint("top", anchorTo, "top", xOffset, yOffset)

			elseif (anchorName1 == "bottom-bottom") then
				object:SetPoint("bottom", anchorTo, "bottom", xOffset, yOffset)

			elseif (anchorName1 == "bottom-top") then
				object:SetPoint("bottomleft", anchorTo, "topleft", xOffset, yOffset)
				object:SetPoint("bottomright", anchorTo, "topright", -xOffset, yOffset)

			elseif (anchorName1 == "top-bottom") then
				object:SetPoint("topleft", anchorTo, "bottomleft", xOffset, -yOffset)
				object:SetPoint("topright", anchorTo, "bottomright", -xOffset, -yOffset)

			elseif (anchorName1 == "right-left") then
				object:SetPoint("topright", anchorTo, "topleft", xOffset, -yOffset)
				object:SetPoint("bottomright", anchorTo, "bottomleft", xOffset, yOffset)

			elseif (anchorName1 == "left-right") then
				object:SetPoint("topleft", anchorTo, "topright", xOffset, -yOffset)
				object:SetPoint("bottomleft", anchorTo, "bottomright", xOffset, yOffset)
			end

			return
		end

		xOffset = xOffset or 0
		yOffset = yOffset or 0

		anchorName1, anchorObject, anchorName2, xOffset, yOffset = detailsFramework:CheckPoints(anchorName1, anchorObject, anchorName2, xOffset, yOffset, object)
		if (not anchorName1) then
			error("SetPoint: Invalid parameter.")
			return
		end

		if (not object.widget) then
			local SetPoint = getmetatable(object).__index.SetPoint
			return SetPoint(object, anchorName1, anchorObject, anchorName2, xOffset, yOffset)
		else
			return object.widget:SetPoint(anchorName1, anchorObject, anchorName2, xOffset, yOffset)
		end
	end,
}

detailsFramework.SetPointMixin.SetPoints = detailsFramework.SetPointMixin.SetPoint

---mixin for options
---@class df_optionsmixin
---@field options table
---@field SetOption fun(self, optionName: string, optionValue: any)
---@field GetOption fun(self, optionName: string):any
---@field GetAllOptions fun(self):table
---@field BuildOptionsTable fun(self, defaultOptions: table, userOptions: table)
detailsFramework.OptionsFunctions = {
	SetOption = function(self, optionName, optionValue)
		if (self.options) then
			self.options [optionName] = optionValue
		else
			self.options = {}
			self.options [optionName] = optionValue
		end

		if (self.OnOptionChanged) then
			detailsFramework:Dispatch (self.OnOptionChanged, self, optionName, optionValue)
		end
	end,

	GetOption = function(self, optionName)
		return self.options and self.options [optionName]
	end,

	GetAllOptions = function(self)
		if (self.options) then
			local optionsTable = {}
			for key, _ in pairs(self.options) do
				optionsTable [#optionsTable + 1] = key
			end
			return optionsTable
		else
			return {}
		end
	end,

	BuildOptionsTable = function(self, defaultOptions, userOptions)
		self.options = self.options or {}
		detailsFramework.table.deploy(self.options, userOptions or {})
		detailsFramework.table.deploy(self.options, defaultOptions or {})
	end
}

--payload mixin
detailsFramework.PayloadMixin = {
	ClearPayload = function(self)
		self.payload = {}
	end,

	SetPayload = function(self, ...)
		self.payload = {...}
		return self.payload
	end,

	AddPayload = function(self, ...)
		local currentPayload = self.payload or {}
		self.payload = currentPayload

		for i = 1, select("#", ...) do
			local value = select(i, ...)
			currentPayload[#currentPayload+1] = value
		end

		return self.payload
	end,

	GetPayload = function(self)
		return self.payload
	end,

	DumpPayload = function(self)
		return unpack(self.payload)
	end,

	--does not copy wow objects, just pass them to the new table, tables strings and numbers are copied entirely
	DuplicatePayload = function(self)
		local duplicatedPayload = detailsFramework.table.duplicate({}, self.payload)
		return duplicatedPayload
	end,
}

---mixin to use with DetailsFramework:Mixin(table, detailsFramework.ScriptHookMixin)
---
---@class df_scripthookmixin
---@field HookList table
---@field SetHook fun(self: table, hookType: string, func: function)
---@field HasHook fun(self: table, hookType: string, func: function)
---@field RunHooksForWidget fun(self: table, event: string, ...)
---@field ClearHooks fun(self: table)

detailsFramework.ScriptHookMixin = {
	RunHooksForWidget = function(self, event, ...)
		local hooks = self.HookList[event]

		if (not hooks) then
			print(self.widget:GetName(), "no hooks for", event)
			return
		end

		for i, func in ipairs(hooks) do
			local success, canInterrupt = xpcall(func, geterrorhandler(), ...)

			if (not success) then
				--error("Details! Framework: " .. event .. " hook for " .. self:GetName() .. ": " .. canInterrupt)
				return false

			elseif (canInterrupt) then
				return true
			end
		end
	end,

	SetHook = function(self, hookType, func)
		if (self.HookList[hookType]) then
			if (type(func) == "function") then
				local isRemoval = false
				for i = #self.HookList[hookType], 1, -1 do
					if (self.HookList[hookType][i] == func) then
						table.remove(self.HookList[hookType], i)
						isRemoval = true
						break
					end
				end

				if (not isRemoval) then
					table.insert(self.HookList[hookType], func)
				end
			else
				if (detailsFramework.debug) then
					print(debugstack())
					error("Details! Framework: invalid function for widget " .. self.WidgetType .. ".")
				end
			end
		else
			if (detailsFramework.debug) then
				error("Details! Framework: unknown hook type for widget " .. self.WidgetType .. ": '" .. hookType .. "'.")
			end
		end
	end,

	HasHook = function(self, hookType, func)
		if (self.HookList[hookType]) then
			if (type(func) == "function") then
				for i = #self.HookList[hookType], 1, -1 do
					if (self.HookList[hookType][i] == func) then
						return true
					end
				end
			end
		end
	end,

	ClearHooks = function(self)
		for hookType, hookTable in pairs(self.HookList) do
			table.wipe(hookTable)
		end
	end,
}

--back compatibility, can be removed in the future (28/04/2023)
---@class DetailsFramework.ScrollBoxFunctions : df_scrollboxmixin

local SortMember = ""
local SortByMember = function(t1, t2)
	return t1[SortMember] > t2[SortMember]
end
local SortByMemberReverse = function(t1, t2)
	return t1[SortMember] < t2[SortMember]
end

---mixin to use with DetailsFramework:Mixin(table, detailsFramework.SortFunctions)
---adds the method Sort() to a table, this method can be used to sort another table by a member, can't sort itself

---@class df_sortmixin
detailsFramework.SortFunctions = {
	---sort a table by a member
	---@param self table
	---@param tThisTable table
	---@param sMemberName string
	---@param bIsReverse boolean
	Sort = function(self, tThisTable, sMemberName, bIsReverse)
		SortMember = sMemberName
		if (not bIsReverse) then
			table.sort(tThisTable, SortByMember)
		else
			table.sort(tThisTable, SortByMemberReverse)
		end
	end
}

---@class df_data : table
---@field _dataInfo {data: table, dataCurrentIndex: number, callbacks: function[]}
---@field callbacks table<function, any[]>
---@field dataCurrentIndex number
---@field DataConstructor fun(self: df_data)
---@field AddDataChangeCallback fun(self: df_data, callback: function, ...: any)
---@field RemoveDataChangeCallback fun(self: df_data, callback: function)
---@field GetData fun(self: df_data)
---@field GetDataSize fun(self: df_data) : number
---@field GetDataFirstValue fun(self: df_data) : any
---@field GetDataLastValue fun(self: df_data) : any
---@field GetDataMinMaxValues fun(self: df_data) : number, number
---@field GetDataMinMaxValueFromSubTable fun(self: df_data, key: string) : number, number when data uses sub tables, get the min max values from a specific index or key, if the value stored is number, return the min and max values
---@field SetData fun(self: df_data, data: table, anyValue: any)
---@field SetDataRaw fun(self: df_data, data: table) set the data without triggering callback
---@field GetDataNextValue fun(self: df_data) : any, number get the next value from the data table, return the value and the index
---@field ResetDataIndex fun(self: df_data)

---mixin to use with DetailsFramework:Mixin(table, detailsFramework.DataMixin)
---add 'data' to a table, this table can be used to store data for the object
---@class DetailsFramework.DataMixin
detailsFramework.DataMixin = {
	---initialize the data table
	---@param self table
	DataConstructor = function(self)
		self._dataInfo = {
			data = {},
			dataCurrentIndex = 1,
			callbacks = {},
		}
	end,

	---when data is changed, functions registered with this function will be called
	---@param self table
	---@param func function
	---@param ... unknown
	AddDataChangeCallback = function(self, func, ...)
		assert(type(func) == "function", "invalid function for AddDataChangeCallback.")
		local allCallbacks = self._dataInfo.callbacks
		allCallbacks[func] = {...}
	end,

	---remove a previous registered callback function
	---@param self table
	---@param func function
	RemoveDataChangeCallback = function(self, func)
		assert(type(func) == "function", "invalid function for RemoveDataChangeCallback.")
		local allCallbacks = self._dataInfo.callbacks
		allCallbacks[func] = nil
	end,

	---set the data without callback
	---@param self table
	---@param data table
	SetDataRaw = function(self, data)
		assert(type(data) == "table", "invalid table for SetData.")
		self._dataInfo.data = data
		self:ResetDataIndex()
	end,

	---set the data table
	---@param self table
	---@param data table
	---@param anyValue any @any value to pass to the callback functions before the payload is added
	SetData = function(self, data, anyValue)
		assert(type(data) == "table", "invalid table for SetData.")
		self._dataInfo.data = data
		self:ResetDataIndex()

		local allCallbacks = self._dataInfo.callbacks
		for	func, payload in pairs(allCallbacks) do
			xpcall(func, geterrorhandler(), data, anyValue, unpack(payload))
		end
	end,

	---get the data table
	---@param self table
	GetData = function(self)
		return self._dataInfo.data
	end,

	---get the next value from the data table
	---@param self table
	---@return any
	---@return number
	GetDataNextValue = function(self)
		local currentValue = self._dataInfo.dataCurrentIndex
		local value = self:GetData()[currentValue]
		self._dataInfo.dataCurrentIndex = self._dataInfo.dataCurrentIndex + 1
		return value, currentValue
	end,

	---reset the data index, making GetDataNextValue() return the first value again
	---@param self table
	ResetDataIndex = function(self)
		self._dataInfo.dataCurrentIndex = 1
	end,

	---get the size of the data table
	---@param self table
	---@return number
	GetDataSize = function(self)
		return #self:GetData()
	end,

	---get the first value from the data table
	---@param self table
	---@return any
	GetDataFirstValue = function(self)
		return self:GetData()[1]
	end,

	---get the last value from the data table
	---@param self table
	---@return any
	GetDataLastValue = function(self)
		local data = self:GetData()
		return data[#data]
	end,

	---get the min and max values from the data table, if the value stored is number, return the min and max values
	---could be used together with SetMinMaxValues from the df_value mixin
	---@param self table
	---@return number, number
	GetDataMinMaxValues = function(self)
		local minDataValue = 0
		local maxDataValue = 0

		local data = self:GetData()
		for i = 1, #data do
			local thisData = data[i]
			if (thisData > maxDataValue) then
				maxDataValue = thisData

			elseif (thisData < minDataValue) then
				minDataValue = thisData
			end
		end

		return minDataValue, maxDataValue
	end,

	---when data uses sub tables, get the min max values from a specific index or key, if the value stored is number, return the min and max values
	---@param self table
	---@param key string
	---@return number, number
	GetDataMinMaxValueFromSubTable = function(self, key)
		local minDataValue = 0
		local maxDataValue = 0

		local data = self:GetData()
		for i = 1, #data do
			local thisData = data[i]
			if (thisData[key] > maxDataValue) then
				maxDataValue = thisData[key]

			elseif (thisData[key] < minDataValue) then
				minDataValue = thisData[key]
			end
		end

		return minDataValue, maxDataValue
	end,
}

---@class df_value : table
---@field minValue number
---@field maxValue number
---@field ValueConstructor fun(self: df_value)
---@field SetMinMaxValues fun(self: df_value, minValue: number, maxValue: number)
---@field GetMinMaxValues fun(self: df_value) : number, number
---@field ResetMinMaxValues fun(self: df_value)
---@field GetMinValue fun(self: df_value) : number
---@field GetMaxValue fun(self: df_value) : number
---@field SetMinValue fun(self: df_value, minValue: number)
---@field SetMinValueIfLower fun(self: df_value, ...: number)
---@field SetMaxValue fun(self: df_value, maxValue: number)
---@field SetMaxValueIfBigger fun(self: df_value, ...: number)

---mixin to use with DetailsFramework:Mixin(table, detailsFramework.ValueMixin)
---add support to min value and max value into a table or object
---@class DetailsFramework.ValueMixin
detailsFramework.ValueMixin = {
	---initialize the value table
	---@param self table
	ValueConstructor = function(self)
		self:ResetMinMaxValues()
	end,

	---set the min and max values
	---@param self table
	---@param minValue number
	---@param maxValue number
	SetMinMaxValues = function(self, minValue, maxValue)
		self.minValue = minValue
		self.maxValue = maxValue
	end,

	---get the min and max values
	---@param self table
	---@return number, number
	GetMinMaxValues = function(self)
		return self.minValue, self.maxValue
	end,

	---reset the min and max values
	---@param self table
	ResetMinMaxValues = function(self)
		self.minValue = 0
		self.maxValue = 1
	end,

	---get the min value
	---@param self table
	---@return number
	GetMinValue = function(self)
		return self.minValue
	end,

	---get the max value
	---@param self table
	---@return number
	GetMaxValue = function(self)
		return self.maxValue
	end,

	---set the min value
	---@param self table
	---@param minValue number
	SetMinValue = function(self, minValue)
		self.minValue = minValue
	end,

	---set the min value if one of the values passed is lower than the current min value
	---@param self table
	---@param ... number
	SetMinValueIfLower = function(self, ...)
		self.minValue = math.min(self.minValue, ...)
	end,

	---set the max value
	---@param self table
	---@param maxValue number
	SetMaxValue = function(self, maxValue)
		self.maxValue = maxValue
	end,

	---set the max value if one of the values passed is bigger than the current max value
	---@param self table
	---@param ... number
	SetMaxValueIfBigger = function(self, ...)
		self.maxValue = math.max(self.maxValue, ...)
	end,
}


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--statusbar mixin

--[=[
	collection of functions to embed into a statusbar
	the statusBar need to have a member called 'barTexture' for the texture set on SetStatusBarTexture
	statusBar:GetTexture()
	statusBar:SetTexture(texture)
	statusBar:SetColor (unparsed color)
	statusBar:GetColor()
	statusBar:
	statusBar:
--]=]

---@class df_statusbarmixin : table
---@field SetTexture fun(self: table, texture: string, isTemporary: boolean)
---@field ResetTexture fun(self: table)
---@field GetTexture fun(self: table) : string
---@field SetAtlas fun(self: table, atlasName: string)
---@field GetAtlas fun(self: table) : string
---@field SetTexCoord fun(self: table, ...)
---@field GetTexCoord fun(self: table) : number, number, number, number
---@field SetColor fun(self: table, ...)
---@field GetColor fun(self: table) : number, number, number, number
---@field SetMaskTexture fun(self: table, texture: string)
---@field GetMaskTexture fun(self: table) : string
---@field SetMaskTexCoord fun(self: table, ...)
---@field GetMaskTexCoord fun(self: table) : number, number, number, number
---@field SetMaskAtlas fun(self: table, atlasName: string)
---@field GetMaskAtlas fun(self: table) : string
---@field AddMaskTexture fun(self: table, texture: string)
---@field SetBorderTexture fun(self: table, texture: string)
---@field GetBorderTexture fun(self: table) : string
---@field SetBorderColor fun(self: table, ...)
---@field GetBorderColor fun(self: table) : number, number, number, number
---@field SetDesaturated fun(self: table, bIsDesaturated: boolean)
---@field IsDesaturated fun(self: table) : boolean
---@field SetVertexColor fun(self: table, red: any, green: number?, blue: number?, alpha: number?)
---@field GetVertexColor fun(self: table) : number, number, number, number

detailsFramework.StatusBarFunctions = {
	SetTexture = function(self, texture, isTemporary)
		self.barTexture:SetTexture(texture)
		if (not isTemporary) then
			self.barTexture.currentTexture = texture
		end
	end,

	ResetTexture = function(self)
		self.barTexture:SetTexture(self.barTexture.currentTexture)
	end,

	GetTexture = function(self)
		return self.barTexture:GetTexture()
	end,

	SetDesaturated = function(self, bIsDesaturated)
		self.barTexture:SetDesaturated(bIsDesaturated)
	end,

	SetDesaturation = function(self, desaturationAmount)
		self.barTexture:SetDesaturation(desaturationAmount)
	end,

	IsDesaturated = function(self)
		return self.barTexture:IsDesaturated()
	end,

	SetVertexColor = function(self, red, green, blue, alpha)
		red, green, blue, alpha = detailsFramework:ParseColors(red, green, blue, alpha)
		self.barTexture:SetVertexColor(red, green, blue, alpha)
	end,

	GetVertexColor = function(self)
		return self.barTexture:GetVertexColor()
	end,

	SetAtlas = function(self, atlasName)
		self.barTexture:SetAtlas(atlasName)
	end,

	GetAtlas = function(self)
		self.barTexture:GetAtlas()
	end,

	SetTexCoord = function(self, ...)
		local left, right, top, bottom = ...
		return self.barTexture:SetTexCoord(...)
	end,

	GetTexCoord = function(self)
		return self.barTexture:GetTexCoord()
	end,

	SetColor = function(self, r, g, b, a)
		r, g, b, a = detailsFramework:ParseColors(r, g, b, a)
		self:SetStatusBarColor(r, g, b, a)
	end,

	GetColor = function(self)
		return self:GetStatusBarColor()
	end,

	SetMaskTexture = function(self, ...)
		if (not self:HasTextureMask()) then
			return
		end
		self.barTextureMask:SetTexture(...)
	end,

	GetMaskTexture = function(self)
		if (not self:HasTextureMask()) then
			return
		end
		self.barTextureMask:GetTexture()
	end,

	SetMaskAtlas = function(self, atlasName)
		if (not self:HasTextureMask()) then
			return
		end
		self.barTextureMask:SetAtlas(atlasName)
	end,

	GetMaskAtlas = function(self)
		if (not self:HasTextureMask()) then
			return
		end
		self.barTextureMask:GetAtlas()
	end,

	AddMaskTexture = function(self, object)
		if (not self:HasTextureMask()) then
			return
		end
		if (object.GetObjectType and object:GetObjectType() == "Texture") then
			object:AddMaskTexture(self.barTextureMask)
		else
			detailsFramework:Msg("Invalid 'Texture' to object:AddMaskTexture(Texture)", debugstack())
		end
	end,

	CreateTextureMask = function(self)
		local barTexture = self:GetStatusBarTexture() or self.barTexture
		if (not barTexture) then
			detailsFramework:Msg("Object doesn't not have a statubar texture, create one and object:SetStatusBarTexture(textureObject)", debugstack())
			return
		end

		if (self.barTextureMask) then
			return self.barTextureMask
		end

		--statusbar texture mask
		self.barTextureMask = self:CreateMaskTexture(nil, "artwork")
		self.barTextureMask:SetAllPoints()
		self.barTextureMask:SetTexture([[Interface\CHATFRAME\CHATFRAMEBACKGROUND]])

		--border texture
		self.barBorderTextureForMask = self:CreateTexture(nil, "overlay", nil, 7)
		self.barBorderTextureForMask:SetAllPoints()
		--self.barBorderTextureForMask:SetPoint("topleft", self, "topleft", -1, 1)
		--self.barBorderTextureForMask:SetPoint("bottomright", self, "bottomright", 1, -1)
		self.barBorderTextureForMask:Hide()

		barTexture:AddMaskTexture(self.barTextureMask)

		return self.barTextureMask
	end,

	HasTextureMask = function(self)
		if (not self.barTextureMask) then
			detailsFramework:Msg("Object doesn't not have a texture mask, create one using object:CreateTextureMask()", debugstack())
			return false
		end
		return true
	end,

	SetBorderTexture = function(self, texture)
		if (not self:HasTextureMask()) then
			return
		end

		texture = texture or ""

		self.barBorderTextureForMask:SetTexture(texture)

		if (texture == "") then
			self.barBorderTextureForMask:Hide()
		else
			self.barBorderTextureForMask:Show()
		end
	end,

	GetBorderTexture = function(self)
		if (not self:HasTextureMask()) then
			return
		end
		return self.barBorderTextureForMask:GetTexture()
	end,

	SetBorderColor = function(self, r, g, b, a)
		r, g, b, a = detailsFramework:ParseColors(r, g, b, a)

		if (self.barBorderTextureForMask and self.barBorderTextureForMask:IsShown()) then
			self.barBorderTextureForMask:SetVertexColor(r, g, b, a)

			--if there's a square border on the widget, remove its color
			if (self.border and self.border.UpdateSizes and self.border.SetVertexColor) then
				self.border:SetVertexColor(0, 0, 0, 0)
			end

			return
		end

		if (self.border and self.border.UpdateSizes and self.border.SetVertexColor) then
			self.border:SetVertexColor(r, g, b, a)

			--adjust the mask border texture ask well in case the user set the mask color texture before setting a texture on it
			if (self.barBorderTextureForMask) then
				self.barBorderTextureForMask:SetVertexColor(r, g, b, a)
			end
			return
		end
	end,

	GetBorderColor = function(self)
		if (self.barBorderTextureForMask and self.barBorderTextureForMask:IsShown()) then
			return self.barBorderTextureForMask:GetVertexColor()
		end

		if (self.border and self.border.UpdateSizes and self.border.GetVertexColor) then
			return self.border:GetVertexColor()
		end
	end,
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--frame mixin
local createTexture = CreateFrame('Frame').CreateTexture -- need a local "original" CreateFrame

detailsFramework.FrameFunctions = {
	CreateTexture = function(self, name, drawLayer, templateName, subLevel)
		local texture = createTexture(self, name, drawLayer, templateName, subLevel)
        -- pixel perfection
        texture:SetTexelSnappingBias(0)
        texture:SetSnapToPixelGrid(false)
        return texture
	end,
}