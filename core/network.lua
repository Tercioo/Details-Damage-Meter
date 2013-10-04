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
				local petActor = _detalhes.tabela_vigente[1]:PegarCombatente (_, nome)
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
				local actor = container:PegarCombatente (_, name)
				
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
				data = _detalhes.atributo_damage:RefreshWindow ({}, _detalhes.tabela_vigente, _, { key = atributo_name, modo = _detalhes.modos.group })
			elseif (atributo == 2) then
				data = _detalhes.atributo_heal:RefreshWindow ({}, _detalhes.tabela_vigente, _, { key = atributo_name, modo = _detalhes.modos.group })
			elseif (atributo == 3) then
				data = _detalhes.atributo_energy:RefreshWindow ({}, _detalhes.tabela_vigente, _, { key = atributo_name, modo = _detalhes.modos.group })
			elseif (atributo == 4) then
				data = _detalhes.atributo_misc:RefreshWindow ({}, _detalhes.tabela_vigente, _, { key = atributo_name, modo = _detalhes.modos.group })
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