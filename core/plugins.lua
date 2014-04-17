--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _detalhes = _G._detalhes
	DETAILSPLUGIN_ALWAYSENABLED = 0x1
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details api functions
	function _detalhes:GetPlugin (PAN) --plugin absolute name
		return _detalhes.SoloTables.NameTable [PAN] or _detalhes.RaidTables.NameTable [PAN] or _detalhes.ToolBar.NameTable [PAN] or _detalhes.StatusBar.NameTable [PAN]
	end
	
	function _detalhes:GetPluginSavedTable (PluginAbsoluteName)
		return _detalhes.plugin_database [PluginAbsoluteName]
	end

	function _detalhes:InstallPlugin (PluginType, PluginName, PluginIcon, PluginObject, PluginAbsoluteName, MinVersion, Author, Version)

		if (MinVersion and MinVersion > _detalhes.realversion) then
			print (PluginName, Loc ["STRING_TOOOLD"])
			return _detalhes:NewError ("Details version is out of date.")
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
		
		local saved_table
		
		if (PluginType ~= "STATUSBAR") then
			saved_table = _detalhes.plugin_database [PluginAbsoluteName]
			if (not saved_table) then
				saved_table = {enabled = true, author = Author or "--------"}
				_detalhes.plugin_database [PluginAbsoluteName] = saved_table
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

		elseif (PluginType == "TANK") then
			
			--> Install Plugin
			_detalhes.RaidTables.Plugins [#_detalhes.RaidTables.Plugins+1] = PluginObject
			_detalhes.RaidTables.Menu [#_detalhes.RaidTables.Menu+1] = {PluginName, PluginIcon, PluginObject, PluginAbsoluteName}
			_detalhes.RaidTables.NameTable [PluginAbsoluteName] = PluginObject
			_detalhes:SendEvent ("INSTALL_OKEY", PluginObject)
			
			_detalhes.PluginCount.RAID = _detalhes.PluginCount.RAID + 1
			
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
		
		if (PluginObject.__enabled) then
			_detalhes:SendEvent ("PLUGIN_ENABLED", PluginObject)
		else
			_detalhes:SendEvent ("PLUGIN_DISABLED", PluginObject)
		end
		
		return true, saved_table
		
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

	function _detalhes:NewPluginObject (FrameName, PluginOptions, PluginType)

		PluginOptions = PluginOptions or 0x0
		local NewPlugin = {__options = PluginOptions, __enabled = true}
		
		local Frame = CreateFrame ("Frame", FrameName, UIParent)
		Frame:RegisterEvent ("ADDON_LOADED")
		Frame:RegisterEvent ("PLAYER_LOGOUT")
		Frame:SetScript ("OnEvent", function(event, ...) return NewPlugin:OnEvent (event, ...) end)
		
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
