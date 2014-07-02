--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local _UnitName = UnitName
	local _GetRealmName = GetRealmName
	local _select = select
	local _table_wipe = table.wipe
	local _math_min = math.min
	local _string_gmatch = string.gmatch
	local _
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	function _detalhes:CheckDetailsUsers()
		
		if (true) then --> disabled
			return
		end
	
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do 
				if (_detalhes.details_users [ _UnitName ("raid"..i)]) then
				end
			end
		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers()-1 do
				if (_detalhes.details_users [ _UnitName ("party"..i)]) then
				end
			end
		end
	end

	local temp = {}

	function _detalhes:RaidComm (_, data, _, source)
	
		local type, player, realm, dversion, arg6, arg7 =  _select (2, _detalhes:Deserialize (data))
		
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) network received:", type, "length:",string.len (data))
		end
		
		if (type == "highfive") then
			
			_detalhes:SendRaidData ("highfive_response")
		
		elseif (type == "highfive_response") then
			
			if (_detalhes.sent_highfive and _detalhes.sent_highfive+30 > GetTime()) then
				_detalhes.users [#_detalhes.users+1] = {player, realm, dversion}
			end
		
		elseif (type == "petowner") then
			
			dversion, serial, nome, owner_table = player, realm, dversion, arg6
			
			if (dversion ~= _detalhes.realversion) then
				return
			end
			
			--> check for miss timing when combat finishes
			if (not _detalhes.sent_pets) then
				_detalhes.sent_pets = {n = time()}
			else
				if (_detalhes.sent_pets.n+20 < time()) then
					_table_wipe (_detalhes.sent_pets)
					_detalhes.sent_pets.n = time()
				end
			end
			
			_detalhes.sent_pets [serial] = true
			
			if (not _detalhes.tabela_pets.pets [serial]) then
				_detalhes.tabela_pets.pets [serial] = owner_table
				local petActor = _detalhes.tabela_vigente[1]:PegarCombatente (nil, nome)
				if (petActor) then
				
					local ownerActor = _detalhes.tabela_vigente[1]:PegarCombatente (owner_table[2], owner_table[1], owner_table[3], true)
					ownerActor.total = ownerActor.total + petActor.total
					ownerActor.pets [#ownerActor.pets+1] = nome
					
					if (_detalhes.debug) then
						_detalhes:Msg ("(debug) received owner for pet ",nome, "assigned to", owner_table[1])
					end
					
					local combat = _detalhes:GetCombat ("current")
					combat[1].need_refresh = true
				end
			end
		
		elseif (type == "needpetowner") then
		
			if (dversion ~= _detalhes.realversion) then
				return
			end
		
			local petserial = arg6
			local petnome = arg7
			
			--> check for miss timing on combat finishes
			if (not _detalhes.sent_pets) then
				_detalhes.sent_pets = {n = time()}
			else
				if (_detalhes.sent_pets.n+20 < time()) then
					_table_wipe (_detalhes.sent_pets)
					_detalhes.sent_pets.n = time()
				end
			end
			
			--> already sent
			if (_detalhes.sent_pets [petserial]) then
				return
			else
				_detalhes.sent_pets [petserial] = true
			end
			
			local owner_table = _detalhes.tabela_pets.pets [petserial]
			
			if (owner_table) then
				
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) received pet owner request, sending owner")
				end
				
				_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("petowner", _detalhes.realversion, petserial, petnome, owner_table), "RAID")
				--_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("petowner", petserial, petnome, owner_table), "WHISPER", player)
			end
		
		elseif (type == "clouddatareceived") then
		
			--local atributo, atributo_name, data = select (3, _detalhes:Deserialize (data))
			local atributo, atributo_name, data = player, realm, dversion
			
			local container = _detalhes.tabela_vigente [atributo]
			
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
		
		elseif (type == "clouddatarequest") then
		
			if (not _detalhes.host_of) then
				--> delayed response
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
				
				_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatareceived", atributo, atributo_name, export), "WHISPER", _detalhes.host_of)
				_table_wipe (temp)
			end
			
		elseif (type == "foundcloud") then
		
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
			
			_detalhes.cloud_process = _detalhes:ScheduleRepeatingTimer ("RequestData", 7)
			_detalhes.last_data_requested = _detalhes._tempo
			
		elseif (type == "needcloud") then

			if (_detalhes.debug) then
				print (player, _detalhes.host_of, _detalhes:CaptureIsAllEnabled(), dversion == _detalhes.realversion)
			end
			if (player ~= _detalhes.playername) then
				if (not _detalhes.host_of and _detalhes:CaptureIsAllEnabled() and dversion == _detalhes.realversion) then
					_detalhes:SendCloudResponse (player, realm)
				end
			end
			
		elseif (type == "custom_broadcast") then
			_detalhes:OnReceiveCustom (_select (3, _detalhes:Deserialize (data)))
			
		elseif (type == "equalize_actors") then
		
			if (not _detalhes.in_combat) then
			
				local receivedActor = arg6
				
				if (dversion ~= _detalhes.realversion) then
					return
				end
				
				_detalhes:MakeEqualizeOnActor (player, realm, receivedActor)
			end
		end
	end

	_detalhes:RegisterComm ("details_comm", "RaidComm")
	
	function _detalhes:SendCustomRaidData (type, player, realm, ...)
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
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize (type, player, realm, _detalhes.realversion, ...), "RAID")
	end
	function _detalhes:SendRaidData (type, ...)
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize (type, _UnitName ("player"), _GetRealmName(), _detalhes.realversion, ...), "RAID")
	end
	
	function _detalhes:SendHighFive()
		if (true) then --> disabled
			return
		end
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("highfive", _UnitName ("player"), _GetRealmName(), _detalhes.realversion), "RAID")
	end
	
	function _detalhes:SendPetOwnerRequest (petserial, petnome)
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) sent request for a pet",petserial, petnome)
		end
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("needpetowner", _UnitName ("player"), _GetRealmName(), _detalhes.realversion, petserial, petnome), "RAID")
	end
	
	function _detalhes:ScheduleSendCloudRequest()
		_detalhes:ScheduleTimer ("SendCloudRequest", 1)
	end
	function _detalhes:SendCloudRequest()
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("needcloud", _UnitName ("player"), _GetRealmName(), _detalhes.realversion), "RAID")
	end
	
	function _detalhes:SendCloudResponse (player, realm)
		if (realm ~= _GetRealmName()) then
			player = player .."-"..realm
		end
		_detalhes.host_of = player
		if (_detalhes.debug) then
			_detalhes:Msg ("(debug) sent 'okey' answer for a cloud parser request.")
		end
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("foundcloud", _UnitName ("player"), _GetRealmName(), _detalhes.realversion), "WHISPER", player)
	end

	function _detalhes:RequestData()
	
		_detalhes.last_data_requested = _detalhes._tempo
	
		for index = 1, #_detalhes.tabela_instancias do
			local instancia = _detalhes.tabela_instancias [index]
			if (instancia.ativa and _detalhes.host_by) then
				local atributo = instancia.atributo
				if (atributo == 1 and not _detalhes:CaptureGet ("damage")) then
					_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatarequest", atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				elseif (atributo == 2 and (not _detalhes:CaptureGet ("heal") or _detalhes:CaptureGet ("aura"))) then
					_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatarequest", atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				elseif (atributo == 3 and not _detalhes:CaptureGet ("energy")) then
					_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatarequest", atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				elseif (atributo == 4 and not _detalhes:CaptureGet ("miscdata")) then
					_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatarequest", atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
					break
				end
			end
		end
	end


	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> update

	function _detalhes:CheckVersion()

		local room_name = "DetailsVCheck"
		
		local CONST_VERSION_CHECK = "VCHECK"
		local CONST_VERSION = "VERSION"
		local CONST_SEND_OWNER = "SOWNER"
		local CONST_OWNER_OUTDATE = "OWNEROUT"
		
		local waiting_version = false
		local waiting_owner = false
		
		--entrar na sala
		JoinChannelByName (room_name)
		
		function _detalhes:GetChannelId()
			local list = {GetChannelList()}
			for i = 1, #list, 2 do
				if (list [i+1] == room_name) then
					return list [i]
				end
			end
			return nil
		end
		
		function _detalhes:GetChannelInternalId()
			for id = 1, GetNumDisplayChannels() do 
				local name = GetChannelDisplayInfo (id)
				if (name == room_name) then
					return id
				end
			end 
		end

		function _detalhes:IamOwner()

			local channel_id = _detalhes:GetChannelId()
			local channel_id_internal = _detalhes:GetChannelInternalId()

			if (not channel_id or not channel_id_internal) then
				return
			end
			
			SetSelectedDisplayChannel (channel_id)
			
			local name, _, _, _, count = GetChannelDisplayInfo (channel_id_internal)
			
			if (name ~= room_name) then
				return
			end

			for i = 1, count do
				local name, owner = GetChannelRosterInfo (channel_id_internal, i)
				
				if (name and name == _detalhes.playername) then
					return owner
				end
			end
		end
		
		function _detalhes:LeaveChannel (force_leave)
			if (_detalhes:IamOwner() and not force_leave) then
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) fail to leave the channel, we are the owner.")
				end
				return
			end
			
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) leaving the update channel.")
			end
			
			LeaveChannelByName (room_name)
		end
	
		function _detalhes:CheckVersionChannel()
		
			local channel_id = _detalhes:GetChannelId()
			
			if (_detalhes.debug) then
				_detalhes:Msg ("(debug) requesting version on update channel: ", channel_id)
			end
			
			if (not channel_id) then
				return
			end
			
			waiting_version = true
			SendChatMessage (room_name .. CONST_VERSION_CHECK .. " " .. _detalhes.build_counter, "CHANNEL", nil, channel_id)
		end
		
		_detalhes:ScheduleTimer ("CheckVersionChannel", 4)

		self.listener:RegisterEvent ("CHAT_MSG_CHANNEL")
		function _detalhes.parser_functions:CHAT_MSG_CHANNEL (...)
			
			local channel_id = _detalhes:GetChannelId()
			
			if (not channel_id) then
				return
			end
			
			local message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter, guid = ...
			
			if (channelName == room_name) then
				local key, value, extra = message:gsub (room_name, ""):match ("^(%S*)%s*(.-)$")
				value, extra = value:match ("^(%S*)%s*(.-)$")
				
				if (_detalhes.debug) then
					_detalhes:Msg ("(debug) update channel received command: ", key, value, extra)
				end
				
				--> send version
				if (key == CONST_VERSION_CHECK) then
					if (_detalhes:IamOwner()) then
						if (IsInRaid() or IsInGroup()) then
							SendChatMessage (room_name .. CONST_VERSION .. " " .. _detalhes.build_counter .. " 1", "CHANNEL", nil, channel_id)
							waiting_owner = true
							if (_detalhes.debug) then
								_detalhes:Msg ("(debug) version sent (we need a new owner).")
							end
						else
							SendChatMessage (room_name .. CONST_VERSION .. " " .. _detalhes.build_counter, "CHANNEL", nil, channel_id)
							if (_detalhes.debug) then
								_detalhes:Msg ("(debug) version sent.")
							end
						end
					end
				
				elseif (key == CONST_VERSION and waiting_version) then
					waiting_version = false
					value = tonumber (value)
					
					if (value > _detalhes.build_counter) then
						--> nova versao encontrada
						-- avisar o jogador
						_detalhes:ScheduleTimer ("LeaveChannel", 5)
						
						local lower_instance = _detalhes:GetLowerInstanceNumber()
						if (lower_instance) then
							lower_instance = _detalhes:GetInstance (lower_instance)
							if (lower_instance) then
								lower_instance:InstanceAlert ("Update Available!", {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 60, {function() _detalhes:Msg ("Check curse client to download the newer version.") end})
							end
						end
			
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) found a new version.")
						end
						
					elseif (value == _detalhes.build_counter) then
						--> mesma versao
						
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) no newer version found.")
						end
						
						if (extra and tonumber (extra)) then
							if (not IsInRaid() and not IsInGroup()) then
								if (_detalhes.debug) then
									_detalhes:Msg ("(debug) owner need to leave, we can be the new owner.")
								end
								SendChatMessage (room_name .. CONST_SEND_OWNER, "CHANNEL", nil, channel_id)
							end
						end
						
						_detalhes:ScheduleTimer ("LeaveChannel", 10)
						
					elseif (value < _detalhes.build_counter) then
						--> a versao do owner esta desatualizada
						SendChatMessage (room_name .. CONST_OWNER_OUTDATE, "CHANNEL", nil, channel_id)
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) owner have a out date version, warning him.")
						end
					end
					
				elseif (key == CONST_SEND_OWNER) then
					if (_detalhes:IamOwner() and waiting_owner) then
						SetChannelOwner (room_name, sender)
						waiting_owner = false
						_detalhes:ScheduleTimer ("LeaveChannel", 5)
						
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) we found a new owner, leaving the channel.")
						end
					end
					
				elseif (key == CONST_OWNER_OUTDATE) then
					if (_detalhes:IamOwner()) then
						_detalhes:ScheduleTimer ("LeaveChannel", 5, true)
						if (_detalhes.debug) then
							_detalhes:Msg ("(debug) Oh ho, we are owner and our version is old, leaving...")
						end
					end
					
				end
				
			end
		end
	
	end

