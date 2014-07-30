--

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	
	_detalhes.network = {}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _UnitName = UnitName
	local _GetRealmName = GetRealmName
	local _select = select
	local _table_wipe = table.wipe
	local _math_min = math.min
	local _string_gmatch = string.gmatch
	local _pairs = pairs

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local CONST_DETAILS_PREFIX = "DTLS"

	local CONST_HIGHFIVE_REQUEST = "HI"
	local CONST_HIGHFIVE_DATA = "HF"
	
	local CONST_VERSION_CHECK = "CV"
	
	local CONST_CLOUD_REQUEST = "CR"
	local CONST_CLOUD_FOUND = "CF"
	local CONST_CLOUD_DATARQ = "CD"
	local CONST_CLOUD_DATARC = "CE"
	local CONST_CLOUD_EQUALIZE = "EQ"
	
	_detalhes.network.ids = {
		["HIGHFIVE_REQUEST"] = CONST_HIGHFIVE_REQUEST,
		["HIGHFIVE_DATA"] = CONST_HIGHFIVE_DATA,
		["VERSION_CHECK"] = CONST_VERSION_CHECK,
		["CLOUD_REQUEST"] = CONST_CLOUD_REQUEST,
		["CLOUD_FOUND"] = CONST_CLOUD_FOUND,
		["CLOUD_DATARQ"] = CONST_CLOUD_DATARQ,
		["CLOUD_DATARC"] = CONST_CLOUD_DATARC,
		["CLOUD_EQUALIZE"] = CONST_CLOUD_EQUALIZE,
	}
	
	local plugins_registred = {}
	
	local temp = {}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> comm functions

	function _detalhes.network.HighFive_Request()
		return _detalhes:SendRaidData (CONST_HIGHFIVE_DATA, _detalhes.userversion)
	end
	
	function _detalhes.network.HighFive_DataReceived (player, realm, core_version, user_version)
		if (_detalhes.sent_highfive and _detalhes.sent_highfive + 30 > GetTime()) then
			_detalhes.users [#_detalhes.users+1] = {player, realm, (user_version or "") .. " (" .. core_version .. ")"}
		end
	end
	
	function _detalhes.network.Update_VersionReceived (player, realm, core_version, build_number)
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) received version alert ", build_number)
		end
	
		build_number = tonumber (build_number)
	
		if (not _detalhes.build_counter or not _detalhes.lastUpdateWarning or not build_number) then
			return
		end
	
		if (build_number > _detalhes.build_counter) then
			if (time() > _detalhes.lastUpdateWarning + 72000) then
				local lower_instance = _detalhes:GetLowerInstanceNumber()
				if (lower_instance) then
					lower_instance = _detalhes:GetInstance (lower_instance)
					if (lower_instance) then
						lower_instance:InstanceAlert ("Update Available!", {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 360, {_detalhes.OpenUpdateWindow})
					end
				end
				_detalhes.lastUpdateWarning = time()
			end
		end
	end
	
	function _detalhes.network.Cloud_Request (player, realm, core_version, ...)
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug)", player, _detalhes.host_of, _detalhes:CaptureIsAllEnabled(), core_version == _detalhes.realversion)
		end
		if (player ~= _detalhes.playername) then
			if (not _detalhes.host_of and _detalhes:CaptureIsAllEnabled() and core_version == _detalhes.realversion) then
				if (realm ~= _GetRealmName()) then
					player = player .."-"..realm
				end
				_detalhes.host_of = player
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) sent 'okey' answer for a cloud parser request.")
				end
				_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (_detalhes.network.ids.CLOUD_FOUND, _UnitName ("player"), _GetRealmName(), _detalhes.realversion), "WHISPER", player)
			end
		end
	end
	
	function _detalhes.network.Cloud_Found (player, realm, core_version, ...)
		if (_detalhes.host_by) then
			return
		end
	
		if (realm ~= _GetRealmName()) then
			player = player .."-"..realm
		end
		_detalhes.host_by = player
		
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) cloud found for disabled captures.")
		end
		
		_detalhes.cloud_process = _detalhes:ScheduleRepeatingTimer ("RequestCloudData", 10)
		_detalhes.last_data_requested = _detalhes._tempo
	end
	
	function _detalhes.network.Cloud_DataRequest (player, realm, core_version, ...)
		if (not _detalhes.host_of) then
			return
		end
		
		local atributo, subatributo = player, realm
		
		local data
		local atributo_name = _detalhes:GetInternalSubAttributeName (atributo, subatributo)
		
		if (atributo == 1) then
			data = _detalhes.atributo_damage:RefreshWindow ({}, _detalhes.tabela_vigente, nil, { key = atributo_name, modo = _detalhes.modos.group })
		elseif (atributo == 2) then
			data = _detalhes.atributo_heal:RefreshWindow ({}, _detalhes.tabela_vigente, nil, { key = atributo_name, modo = _detalhes.modos.group })
		elseif (atributo == 3) then
			data = _detalhes.atributo_energy:RefreshWindow ({}, _detalhes.tabela_vigente, nil, { key = atributo_name, modo = _detalhes.modos.group })
		elseif (atributo == 4) then
			data = _detalhes.atributo_misc:RefreshWindow ({}, _detalhes.tabela_vigente, nil, { key = atributo_name, modo = _detalhes.modos.group })
		else
			return
		end
		
		if (data) then
			local export = temp
			local container = _detalhes.tabela_vigente [atributo]._ActorTable
			for i = 1, _math_min (6, #container) do 
				local actor = container [i]
				if (actor.grupo) then
					export [#export+1] = {actor.nome, actor [atributo_name]}
				end
			end
			
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) requesting data from the cloud.")
			end
			
			_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (CONST_CLOUD_DATARC, atributo, atributo_name, export), "WHISPER", _detalhes.host_of)
			_table_wipe (temp)
		end
	end
	
	function _detalhes.network.Cloud_DataReceived	(player, realm, core_version, ...)
		local atributo, atributo_name, data = player, realm, core_version
		
		local container = _detalhes.tabela_vigente [atributo]
		
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) received data from the cloud.")
		end
		
		for i = 1, #data do 
			local _this = data [i]
			
			local name = _this [1]
			local actor = container:PegarCombatente (nil, name)
			
			if (not actor) then
				if (IsInRaid()) then
					for i = 1, GetNumGroupMembers() do 
						if (name:find ("-")) then --> other realm
							local nname, server = _UnitName ("raid"..i)
							if (server and server ~= "") then
								nname = nname.."-"..server
							end
							if (nname == name) then
								actor = container:PegarCombatente (UnitGUID ("raid"..i), name, 0x514, true)
								break
							end
						else
							if (_UnitName ("raid"..i) == name) then
								actor = container:PegarCombatente (UnitGUID ("raid"..i), name, 0x514, true)
								break
							end
						end

					end
				elseif (IsInGroup()) then
					for i = 1, GetNumGroupMembers()-1 do
						if (name:find ("-")) then --> other realm
							local nname, server = _UnitName ("party"..i)
							if (server and server ~= "") then
								nname = nname.."-"..server
							end
							if (nname == name) then
								actor = container:PegarCombatente (UnitGUID ("party"..i), name, 0x514, true)
								break
							end
						else
							if (_UnitName ("party"..i) == name or _detalhes.playername == name) then
								actor = container:PegarCombatente (UnitGUID ("party"..i), name, 0x514, true)
								break
							end
						end
					end
				end
			end

			if (actor) then
				actor [atributo_name] = _this [2]
				container.need_refresh = true
			else
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) actor not found on cloud data received", name, atributo_name)
				end
			end
		end
	end
	
	function _detalhes.network.Cloud_Equalize (player, realm, core_version, data)
		if (not _detalhes.in_combat) then
			if (core_version ~= _detalhes.realversion) then
				return
			end
			_detalhes:MakeEqualizeOnActor (player, realm, data)
		end
	end
	
	_detalhes.network.functions = {
		[CONST_HIGHFIVE_REQUEST] = _detalhes.network.HighFive_Request,
		[CONST_HIGHFIVE_DATA] = _detalhes.network.HighFive_DataReceived,
		[CONST_VERSION_CHECK] = _detalhes.network.Update_VersionReceived,
		
		[CONST_CLOUD_REQUEST] = _detalhes.network.Cloud_Request,
		[CONST_CLOUD_FOUND] = _detalhes.network.Cloud_Found,
		[CONST_CLOUD_DATARQ] = _detalhes.network.Cloud_DataRequest,
		[CONST_CLOUD_DATARC] = _detalhes.network.Cloud_DataReceived,
		[CONST_CLOUD_EQUALIZE] = _detalhes.network.Cloud_Equalize,
	}
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> register comm

	function _detalhes:CommReceived (_, data, _, source)
		local type, player, realm, dversion, arg6, arg7, arg8, arg9 =  _select (2, _detalhes:Deserialize (data))
		
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) network received:", type, "length:",string.len (data))
		end
		
		local func = _detalhes.network.functions [type]
		if (func) then
			func (player, realm, dversion, arg6, arg7, arg8, arg9)
		else
			local t = plugins_registred [type]
			if (t) then
				func (player, realm, dversion, t[3], arg6, arg7, arg8, arg9)
			else
				_detalhes:Msg ("comm type not found:", type)
			end
		end
	end

	_detalhes:RegisterComm ("DTLS", "CommReceived")
	
	function _detalhes:RegisterPluginComm (name, prefix, func, version)
		assert (type (name) == "string" and string.len (name) > 3, "RegisterPluginComm expects a string with at least 4 characters on #1 argument.")
		assert (type (prefix) == "string" and string.len (prefix) == 2, "RegisterPluginComm expects a string with 2 characters on #2 argument.")
		assert (type (func) == "function", "RegisterPluginComm expects a function on #3 argument.")
		assert (plugins_registred [prefix] == nil, "Prefix " .. prefix .. " already in use.")
		assert (_detalhes.network.functions [prefix] == nil, "Prefix " .. prefix .. " already in use.")
		
		plugins_registred [prefix] = {func, name, version}
	end
	
	function _detalhes:UnregisterPluginComm (name)
		local prefix
		for p, t in _pairs (plugins_registred) do 
			if (t [2] == name) then
				prefix = p
				break
			end
		end
		if (prefix) then
			plugins_registred [prefix] = nil
		end
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> send functions
	
	function _detalhes:SendPluginCommMessage (name, channel, ...)
		local prefix
		for p, t in _pairs (plugins_registred) do 
			if (t [2] == name) then
				prefix = p
				break
			end
		end
		if (prefix) then
			
		else
			self:Msg ("comm not registred:", name)
		end
	end
	
	--> send as
	function _detalhes:SendRaidDataAs (type, player, realm, ...)
		if (not realm) then
			--> check if realm is already inside player name
			for _name, _realm in _string_gmatch (player, "(%w+)-(%w+)") do
				if (_realm) then
					player = _name
					realm = _realm
				end
			end
		end
		if (not realm) then
			--> doesn't have realm at all, so we assume the actor is in same realm as player
			realm = _GetRealmName()
		end
		_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (type, player, realm, _detalhes.realversion, ...), "RAID")
	end
	
	function _detalhes:SendRaidData (type, ...)
		if (IsInGroup (LE_PARTY_CATEGORY_INSTANCE) and IsInInstance()) then
			_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (type, _UnitName ("player"), _GetRealmName(), _detalhes.realversion, ...), "INSTANCE_CHAT")
		else
			_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (type, _UnitName ("player"), _GetRealmName(), _detalhes.realversion, ...), "RAID")
		end
	end
	
	function _detalhes:SendPartyData (type, ...)
		if (IsInGroup (LE_PARTY_CATEGORY_INSTANCE) and IsInInstance()) then
			_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (type, _UnitName ("player"), _GetRealmName(), _detalhes.realversion, ...), "INSTANCE_CHAT")
		else
			_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (type, _UnitName ("player"), _GetRealmName(), _detalhes.realversion, ...), "PARTY")
		end
	end
	
	function _detalhes:SendGuildData (type, ...)
		_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (type, _UnitName ("player"), _GetRealmName(), _detalhes.realversion, ...), "GUILD")
	end
	


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> cloud

	function _detalhes:SendCloudRequest()
		_detalhes:SendRaidData (_detalhes.network.ids.CLOUD_REQUEST)
	end
	
	function _detalhes:ScheduleSendCloudRequest()
		_detalhes:ScheduleTimer ("SendCloudRequest", 1)
	end

	function _detalhes:RequestCloudData()
		_detalhes.last_data_requested = _detalhes._tempo

		if (not _detalhes.host_by) then
			return
		end
	
		for index = 1, #_detalhes.tabela_instancias do
			local instancia = _detalhes.tabela_instancias [index]
			if (instancia.ativa) then
				local atributo = instancia.atributo
				if (atributo == 1 and not _detalhes:CaptureGet ("damage")) then
					_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (CONST_CLOUD_DATARQ, atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				elseif (atributo == 2 and (not _detalhes:CaptureGet ("heal") or _detalhes:CaptureGet ("aura"))) then
					_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (CONST_CLOUD_DATARQ, atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				elseif (atributo == 3 and not _detalhes:CaptureGet ("energy")) then
					_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (CONST_CLOUD_DATARQ, atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				elseif (atributo == 4 and not _detalhes:CaptureGet ("miscdata")) then
					_detalhes:SendCommMessage (CONST_DETAILS_PREFIX, _detalhes:Serialize (CONST_CLOUD_DATARQ, atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				end
			end
		end
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> update

	function _detalhes:CheckVersion (send_to_guild)
		if (IsInRaid()) then
			_detalhes:SendRaidData (_detalhes.network.ids.VERSION_CHECK, _detalhes.build_counter)
		elseif (IsInGroup()) then
			_detalhes:SendPartyData (_detalhes.network.ids.VERSION_CHECK, _detalhes.build_counter)
		end
		
		if (send_to_guild) then
			_detalhes:SendGuildData (_detalhes.network.ids.VERSION_CHECK, _detalhes.build_counter)
		end
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> sharer

	--> entrar no canal após logar no servidor
	function _detalhes:EnterChatChannel()
		
		if (_detalhes.schedule_chat_leave) then
			_detalhes:CancelTimer (_detalhes.schedule_chat_leave)
			_detalhes.schedule_chat_leave = nil
		end
		_detalhes.schedule_chat_enter = nil
	
		local realm = GetRealmName()
		realm = realm or ""
		
		if (realm ~= "Azralon") then
			return
		end
	
		--> room name
		local room_name = "Details"
		
		--> already in?
		for room_index = 1, 10 do
			local _, name = GetChannelName (room_index)
			if (name == room_name) then
				return --> already in the room
			end
		end
		
		--> enter
		--print ("entrando no canal")
		JoinChannelByName (room_name)
	end
	
	function _detalhes:LeaveChatChannel()
	
		if (_detalhes.schedule_chat_enter) then
			_detalhes:CancelTimer (_detalhes.schedule_chat_enter)
			_detalhes.schedule_chat_enter  = nil
		end
		_detalhes.schedule_chat_leave = nil
	
		local realm = GetRealmName()
		realm = realm or ""
		
		if (realm ~= "Azralon") then
			return
		end
		
		--> room name
		local room_name = "Details"
		local is_in = false
		--> already in?
		for room_index = 1, 10 do
			local _, name = GetChannelName (room_index)
			if (name == room_name) then
				is_in = true
			end
		end
		
		if (is_in) then
			--print ("saindo do canal")
			LeaveChannelByName (room_name)
		end
	end
	
	--> sair do canal quando estiver em grupo
	local event_handler = {Enabled = true, __enabled = true, teste = " teste"}
	function event_handler:ZONE_TYPE_CHANGED (zone_type)
		--print (zone_type)
		if (zone_type == "none") then
			if (not _detalhes:InGroup()) then
				if (_detalhes.schedule_chat_leave) then
					_detalhes:CancelTimer (_detalhes.schedule_chat_leave)
				end
				if (not _detalhes.schedule_chat_enter) then
					_detalhes.schedule_chat_enter = _detalhes:ScheduleTimer ("EnterChatChannel", 2)
				end
			end
		else
			if (_detalhes:InGroup()) then
				if (_detalhes.schedule_chat_enter) then
					_detalhes:CancelTimer (_detalhes.schedule_chat_enter)
				end
				if (not _detalhes.schedule_chat_leave) then
					_detalhes.schedule_chat_leave = _detalhes:ScheduleTimer ("LeaveChatChannel", 2)
				end
			end
		end
	end
	
	function event_handler:GROUP_ONENTER()
		if (zone_type ~= "none") then
			if (_detalhes.schedule_chat_enter) then
				_detalhes:CancelTimer (_detalhes.schedule_chat_enter)
			end
			if (not _detalhes.schedule_chat_leave) then
				_detalhes.schedule_chat_leave = _detalhes:ScheduleTimer ("LeaveChatChannel", 2)
			end
		end
	end
	
	function event_handler:GROUP_ONLEAVE()
		if (zone_type == "none") then
			if (_detalhes.schedule_chat_leave) then
				_detalhes:CancelTimer (_detalhes.schedule_chat_leave)
			end
			if (not _detalhes.schedule_chat_enter) then
				_detalhes.schedule_chat_enter = _detalhes:ScheduleTimer ("EnterChatChannel", 2)
			end
		end
	end
	
	_detalhes:RegisterEvent (event_handler, "GROUP_ONENTER", "GROUP_ONENTER")
	_detalhes:RegisterEvent (event_handler, "GROUP_ONLEAVE", "GROUP_ONLEAVE")
	_detalhes:RegisterEvent (event_handler, "ZONE_TYPE_CHANGED", "ZONE_TYPE_CHANGED")
	