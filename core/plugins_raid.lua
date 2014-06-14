--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _math_floor = math.floor --lua local
	
	local gump = _detalhes.gump --details local
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local modo_raid = _detalhes._detalhes_props["MODO_RAID"]
	local modo_alone = _detalhes._detalhes_props["MODO_ALONE"]
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions	
	
	function _detalhes.RaidTables:DisableRaidMode (instance)
		--free
		self:SetInUse (instance.current_raid_plugin, nil)
		--hide
		local current_plugin_object = _detalhes:GetPlugin (instance.current_raid_plugin)
		if (current_plugin_object) then
			current_plugin_object.Frame:Hide()
		end
		instance.current_raid_plugin = nil
	end
	
	function _detalhes:RaidPluginInstalled (plugin_name)
		if (self.waiting_raid_plugin) then
			--print (self.meu_id, 2, self.last_raid_plugin, " == ", plugin_name)
			if (self.last_raid_plugin == plugin_name) then
				if (self.waiting_pid) then
					self:CancelTimer (self.waiting_pid, true)
				end
				self:CancelWaitForPlugin()
				_detalhes.RaidTables:EnableRaidMode (self, plugin_name)
			end
		end
	end
	
	function _detalhes.RaidTables:EnableRaidMode (instance, plugin_name, from_cooltip, from_mode_menu)

		--> check if came from cooltip
		if (from_cooltip) then
			self = _detalhes.RaidTables
			instance = plugin_name
			plugin_name = from_cooltip
		end
	
		--> set the mode
		if (instance.modo == modo_alone) then
			instance:SoloMode (false)
		end
		instance.modo = modo_raid
		
		--> hide rows, scrollbar
		gump:Fade (instance, 1, nil, "barras")
		if (instance.rolagem) then
			instance:EsconderScrollBar (true) --> hida a scrollbar
		end
		_detalhes:ResetaGump (instance)
		instance:AtualizaGumpPrincipal (true)
		
		--> get the plugin name
		
		--if the desired plugin isn't passed, try to get the latest used.
		if (not plugin_name) then
			local last_plugin_used = instance.last_raid_plugin
			if (last_plugin_used) then
				if (self:IsAvailable (last_plugin_used, instance)) then
					plugin_name = last_plugin_used
				end
			end
		end

		--if we still doesnt have a name, try to get the first available
		if (not plugin_name) then
			local available = self:GetAvailablePlugins()
			if (#available == 0) then
				if (not instance.wait_for_plugin_created or not instance.WaitForPlugin) then
					instance:CreateWaitForPlugin()
				end
				return instance:WaitForPlugin()
			end
			
			plugin_name = available [1] [4]
		end

		--last check if the name is okey
		if (self:IsAvailable (plugin_name, instance)) then
			self:switch (nil, plugin_name, instance)
			
			if (from_mode_menu) then
				--refresh
				instance.baseframe.cabecalho.modo_selecao:GetScript ("OnEnter")(instance.baseframe.cabecalho.modo_selecao)
			end
		else
			if (not instance.wait_for_plugin) then
				instance:CreateWaitForPlugin()
			end
			return instance:WaitForPlugin()
		end

	end

	function _detalhes.RaidTables:GetAvailablePlugins()
		local available = {}
		for index, plugin in ipairs (self.Menu) do
			if (not self.PluginsInUse [ plugin [4] ] and plugin [3].__enabled) then -- 3 = plugin object 4 = absolute name
				tinsert (available, plugin)
			end
		end
		return available
	end
	
	function _detalhes.RaidTables:IsAvailable (plugin_name, instance)
		--check if is installed
		if (not self.NameTable [plugin_name]) then
			return false
		end

		--check if is enabled
		if (not self.NameTable [plugin_name].__enabled) then
			return false
		end
		
		--check if is available
		local in_use = self.PluginsInUse [ plugin_name ]
		
		if (in_use and in_use ~= instance:GetId()) then
			return false
		else
			return true
		end
	end
	
	function _detalhes.RaidTables:SetInUse (absolute_name, instance_number)
		if (absolute_name) then
			self.PluginsInUse [ absolute_name ] = instance_number
		end
	end

	----------------
	
	function _detalhes.RaidTables:switch (_, plugin_name, instance)
	
		local update_menu = false
		if (not self) then --came from cooltip
			self = _detalhes.RaidTables
			update_menu = true
		end
	
		--only hide the current plugin shown
		if (not plugin_name) then
			if (instance.current_raid_plugin) then
				--free
				self:SetInUse (instance.current_raid_plugin, nil)
				--hide
				local current_plugin_object = _detalhes:GetPlugin (instance.current_raid_plugin)
				if (current_plugin_object) then
					current_plugin_object.Frame:Hide()
				end
				instance.current_raid_plugin = nil
			end
			return
		end
		
		--check if is realy available
		if (not self:IsAvailable (plugin_name, instance)) then
			instance.last_raid_plugin = plugin_name
			if (not instance.wait_for_plugin) then
				instance:CreateWaitForPlugin()
			end
			return instance:WaitForPlugin()
		end
		
		--hide current shown plugin
		if (instance.current_raid_plugin) then
			--free
			self:SetInUse (instance.current_raid_plugin, nil)
			--hide
			local current_plugin_object = _detalhes:GetPlugin (instance.current_raid_plugin)
			if (current_plugin_object) then
				current_plugin_object.Frame:Hide()
			end
		end
		
		local plugin_object = _detalhes:GetPlugin (plugin_name)

		if (plugin_object and plugin_object.__enabled and plugin_object.Frame) then
			instance.last_raid_plugin = plugin_name
			instance.current_raid_plugin = plugin_name
			
			self:SetInUse (plugin_name, instance:GetId())
			plugin_object.instance_id = instance:GetId()
			plugin_object.Frame:SetPoint ("TOPLEFT", instance.bgframe)
			plugin_object.Frame:Show()
			instance:ChangeIcon (plugin_object.__icon)--; print (instance:GetId(),"icon",plugin_object.__icon)
			_detalhes:SendEvent ("DETAILS_INSTANCE_CHANGEATTRIBUTE", nil, instance, instance.atributo, instance.sub_atributo)
			
			if (update_menu) then
				GameCooltip:ExecFunc (instance.baseframe.cabecalho.atributo)
				--instance _detalhes.popup:ExecFunc (DeleteButton)
			end
		else
			if (not instance.wait_for_plugin) then
				instance:CreateWaitForPlugin()
			end
			return instance:WaitForPlugin()
		end

	end
