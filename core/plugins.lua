	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _detalhes = _G._detalhes
	DETAILSPLUGIN_ALWAYSENABLED = 0x1
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions
	function _detalhes:GetPlugin (PAN) --plugin absolute name
		return _detalhes.SoloTables.NameTable [PAN] or _detalhes.RaidTables.NameTable [PAN] or _detalhes.ToolBar.NameTable [PAN] or _detalhes.StatusBar.NameTable [PAN] or _detalhes.PluginsLocalizedNames [PAN] or _detalhes.PluginsGlobalNames [PAN]
	end
	
	function _detalhes:GetPluginSavedTable (PluginAbsoluteName)
		return _detalhes.plugin_database [PluginAbsoluteName]
	end
	
	function _detalhes:UpdatePluginBarsConfig()
		local instance = self:GetPluginInstance()
		if (instance) then
			self.row_info = self.row_info or {}
			_detalhes.table.copy (self.row_info, instance.row_info)
			self.bars_grow_direction = instance.bars_grow_direction
			self.row_height = instance.row_height
			self:SetBarGrowDirection()
		end
	end
	
	function _detalhes:AttachToInstance()
		local instance = self:GetPluginInstance()
		if (instance) then
			local w, h = instance:GetSize()
			self.Frame:SetSize (w, h)
		end
	end
	
	function _detalhes:GetPluginInstance (PluginAbsoluteName)
		local plugin = self
		if (PluginAbsoluteName) then
			plugin = _detalhes:GetPlugin (PluginAbsoluteName)
		end
		
		local id = plugin.instance_id
		if (id) then
			return _detalhes:GetInstance (id)
		end
	end
	
	function _detalhes:IsPluginEnabled (PluginAbsoluteName)
		if (PluginAbsoluteName) then
			local plugin = _detalhes.plugin_database [PluginAbsoluteName]
			if (plugin) then
				return plugin.enabled
			end
		else
			return self.__enabled
		end
	end
	
	function _detalhes:SetPluginDescription (desc)
		self.__description = desc
	end
	function _detalhes:GetPluginDescription()
		return self.__description or ""
	end
	
	function _detalhes:DisablePlugin (AbsoluteName)
		local plugin = _detalhes:GetPlugin (AbsoluteName)
		
		if (plugin) then
			local saved_table = _detalhes:GetPluginSavedTable (AbsoluteName)
			
			saved_table.enabled = false
			plugin.__enabled = false
		
			_detalhes:SendEvent ("PLUGIN_DISABLED", plugin)
			
			_detalhes:DelayOptionsRefresh()
			return true
		end
	end
	
	function _detalhes:CheckDefaultTable (current, default)
		for key, value in pairs (default) do 
			if (type (value) == "table") then
				if (type (current [key]) ~= "table") then
					current [key] = table_deepcopy (value)
				else
					_detalhes:CheckDefaultTable (current [key], value)
				end
			else
				if (current [key] == nil) then
					current [key] = value
				--elseif (type (current [key]) ~= type (value)) then
				--	current [key] = value
				end
			end
		end
	end

	function _detalhes:InstallPlugin (PluginType, PluginName, PluginIcon, PluginObject, PluginAbsoluteName, MinVersion, Author, Version, DefaultSavedTable)

		if (MinVersion and MinVersion > _detalhes.realversion) then
			print (PluginName, Loc ["STRING_TOOOLD"])
			return _detalhes:NewError ("Details version is out of date.")
		end
		
		if (_detalhes.FILEBROKEN) then
			return _detalhes:NewError ("Game client needs to be restarted in order to finish Details! update.")
		end
		
		if (PluginType == "TANK") then
			PluginType = "RAID"
		end
	
		if (not PluginType) then
			return _detalhes:NewError ("InstallPlugin parameter 1 (plugin type) not especified")
		elseif (not PluginName) then
			return _detalhes:NewError ("InstallPlugin parameter 2 (plugin name) can't be nil")
		elseif (not PluginIcon) then
			return _detalhes:NewError ("InstallPlugin parameter 3 (plugin icon) can't be nil")
		elseif (not PluginObject) then
			return _detalhes:NewError ("InstallPlugin parameter 4 (plugin object) can't be nil")
		elseif (not PluginAbsoluteName) then
			return _detalhes:NewError ("InstallPlugin parameter 5 (plugin absolut name) can't be nil")
		end
		
		if (_G [PluginAbsoluteName]) then
			print (Loc ["STRING_PLUGIN_NAMEALREADYTAKEN"] .. ": " .. PluginName .. " name: " .. PluginAbsoluteName)
			return
		else
			_G [PluginAbsoluteName] = PluginObject
			PluginObject.real_name = PluginAbsoluteName
		end
		
		PluginObject.__name = PluginName
		PluginObject.__author = Author or "--------"
		PluginObject.__version = Version or "v1.0.0"
		PluginObject.__icon = PluginIcon or [[Interface\ICONS\Trade_Engineering]]
		PluginObject.real_name = PluginAbsoluteName
		
		_detalhes.PluginsGlobalNames [PluginAbsoluteName] = PluginObject
		_detalhes.PluginsLocalizedNames [PluginName] = PluginObject
		
		local saved_table
		
		if (PluginType ~= "STATUSBAR") then
			saved_table = _detalhes.plugin_database [PluginAbsoluteName]
			
			if (not saved_table) then
				saved_table = {enabled = true, author = Author or "--------"}
				_detalhes.plugin_database [PluginAbsoluteName] = saved_table
			end
			
			if (DefaultSavedTable) then
				_detalhes:CheckDefaultTable (saved_table, DefaultSavedTable)
			end
			
			PluginObject.__enabled = saved_table.enabled
		end
		
		if (PluginType == "SOLO") then
			if (not PluginObject.Frame) then
				return _detalhes:NewError ("plugin doesn't have a Frame, please check case-sensitive member name: Frame")
			end
			
			--> Install Plugin
			_detalhes.SoloTables.Plugins [#_detalhes.SoloTables.Plugins+1] = PluginObject
			_detalhes.SoloTables.Menu [#_detalhes.SoloTables.Menu+1] = {PluginName, PluginIcon, PluginObject, PluginAbsoluteName}
			_detalhes.SoloTables.NameTable [PluginAbsoluteName] = PluginObject
			_detalhes:SendEvent ("INSTALL_OKEY", PluginObject)
			
			_detalhes.PluginCount.SOLO = _detalhes.PluginCount.SOLO + 1

		elseif (PluginType == "RAID") then
			
			--> Install Plugin
			_detalhes.RaidTables.Plugins [#_detalhes.RaidTables.Plugins+1] = PluginObject
			_detalhes.RaidTables.Menu [#_detalhes.RaidTables.Menu+1] = {PluginName, PluginIcon, PluginObject, PluginAbsoluteName}
			_detalhes.RaidTables.NameTable [PluginAbsoluteName] = PluginObject
			_detalhes:SendEvent ("INSTALL_OKEY", PluginObject)
			
			_detalhes.PluginCount.RAID = _detalhes.PluginCount.RAID + 1
			
			_detalhes:InstanceCall ("RaidPluginInstalled", PluginAbsoluteName)
			
		elseif (PluginType == "TOOLBAR") then
			
			--> Install Plugin
			_detalhes.ToolBar.Plugins [#_detalhes.ToolBar.Plugins+1] = PluginObject
			_detalhes.ToolBar.Menu [#_detalhes.ToolBar.Menu+1] = {PluginName, PluginIcon, PluginObject, PluginAbsoluteName}
			_detalhes.ToolBar.NameTable [PluginAbsoluteName] = PluginObject
			_detalhes:SendEvent ("INSTALL_OKEY", PluginObject)
			
			_detalhes.PluginCount.TOOLBAR = _detalhes.PluginCount.TOOLBAR + 1
			
		elseif (PluginType == "STATUSBAR") then	
		
			--> Install Plugin
			_detalhes.StatusBar.Plugins [#_detalhes.StatusBar.Plugins+1] = PluginObject
			_detalhes.StatusBar.Menu [#_detalhes.StatusBar.Menu+1] = {PluginName, PluginIcon}
			_detalhes.StatusBar.NameTable [PluginAbsoluteName] = PluginObject
			_detalhes:SendEvent ("INSTALL_OKEY", PluginObject)
			
			_detalhes.PluginCount.STATUSBAR = _detalhes.PluginCount.STATUSBAR + 1
		end
		
		if (saved_table) then
			PluginObject.db = saved_table
		end
		
		if (PluginObject.__enabled) then
			return true, saved_table, true
		else
			return true, saved_table, false
		end
		
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions
	
	_detalhes.PluginCount = {
		["SOLO"] = 0,
		["RAID"] = 0,
		["TOOLBAR"] = 0,
		["STATUSBAR"] = 0
	}	
		
	local OnEnableFunction = function (self)
		self.__parent.Enabled = true
		--self = frame __parent = plugin object
		local instance = _detalhes:GetInstance (self.__parent.instance_id)
		if (instance) then
			self:SetParent (instance.baseframe)
		end
		_detalhes:SendEvent ("SHOW", self.__parent)
	end

	local OnDisableFunction = function (self)
		_detalhes:SendEvent ("HIDE", self.__parent)
		if (bit.band (self.__parent.__options, DETAILSPLUGIN_ALWAYSENABLED) == 0) then
			self.__parent.Enabled = false
		end
	end

	local BuildDefaultStatusBarMembers = function (self)
		self.childs = {}
		self.__index = self
		function self:Setup()
			_detalhes.StatusBar:OpenOptionsForChild (self)
		end
	end
	
	local temp_event_function = function()
		print ("=====================")
		print ("Hello There plugin developer!")
		print ("Please make sure you are declaring")
		print ("A member called 'OnDetailsEvent' on your plugin object")
		print ("With a function to receive the events like bellow:")
		print ("function PluginObject:OnDetailsEvent (event, ...) end")
		print ("Thank You Sir!===================")
	end

	local register_event_func = function (self, event)
		self.Frame:RegisterEvent (event)
	end
	local unregister_event_func = function (self, event)
		self.Frame:UnregisterEvent (event)
	end
	
	function _detalhes:NewPluginObject (FrameName, PluginOptions, PluginType)

		PluginOptions = PluginOptions or 0x0
		local NewPlugin = {__options = PluginOptions, __enabled = true, RegisterEvent = register_event_func, UnregisterEvent = unregister_event_func}
		
		local Frame = CreateFrame ("Frame", FrameName, UIParent)
		Frame:RegisterEvent ("ADDON_LOADED")
		Frame:RegisterEvent ("PLAYER_LOGOUT")
		Frame:SetScript ("OnEvent", function(event, ...) 
			if (NewPlugin.OnEvent) then
				return NewPlugin:OnEvent (event, ...) 
			end
		end)
		
		Frame:SetFrameStrata ("HIGH")
		Frame:SetFrameLevel (6)

		Frame:Hide()
		Frame.__parent = NewPlugin
		
		if (bit.band (PluginOptions, DETAILSPLUGIN_ALWAYSENABLED) ~= 0) then
			NewPlugin.Enabled = true
		else
			NewPlugin.Enabled = false
		end
		
		--> default members
		if (PluginType == "STATUSBAR") then
			BuildDefaultStatusBarMembers (NewPlugin)
		end
		
		NewPlugin.Frame = Frame
		
		Frame:SetScript ("OnShow", OnEnableFunction)
		Frame:SetScript ("OnHide", OnDisableFunction)
		
		--> temporary details event function
		NewPlugin.OnDetailsEvent = temp_event_function
		
		setmetatable (NewPlugin, _detalhes)
		
		return NewPlugin
	end

	function _detalhes:CreatePluginOptionsFrame (name, title, template)
	
		template = template or 1
	
		if (template == 2) then
			local options_frame = CreateFrame ("frame", name, UIParent, "ButtonFrameTemplate")
			tinsert (UISpecialFrames, name)
			options_frame:SetSize (500, 200)
			
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
			edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 32,
			insets = {left = 1, right = 1, top = 1, bottom = 1}})
			options_frame:SetBackdropColor (0, 0, 0, .7)

			local texturetitle = options_frame:CreateTexture (nil, "artwork")
			texturetitle:SetTexture ([[Interface\CURSOR\Interact]])
			texturetitle:SetTexCoord (0, 1, 0, 1)
			texturetitle:SetVertexColor (1, 1, 1, 1)
			texturetitle:SetPoint ("topleft", options_frame, "topleft", 2, -3)
			texturetitle:SetWidth (36)
			texturetitle:SetHeight (36)
			
			local title = _detalhes.gump:NewLabel (options_frame, nil, "$parentTitle", nil, title, nil, 20, "yellow")
			title:SetPoint ("left", texturetitle, "right", 2, -1)
			_detalhes:SetFontOutline (title, true)

			local bigdog = _detalhes.gump:NewImage (options_frame, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 110, 120, nil, {1, 0, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
			bigdog:SetPoint ("bottomright", options_frame, "bottomright", -3, 0)
			bigdog:SetAlpha (.25)
			
			local c = CreateFrame ("Button", nil, options_frame, "UIPanelCloseButton")
			c:SetWidth (32)
			c:SetHeight (32)
			c:SetPoint ("TOPRIGHT",  options_frame, "TOPRIGHT", -3, -3)
			c:SetFrameLevel (options_frame:GetFrameLevel()+1)
			
			return options_frame
		end
	end