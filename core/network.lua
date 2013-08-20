--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	function _detalhes:CheckDetailsUsers()
		
		if (true) then --> disabled
			return
		end
	
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do 
				if (_detalhes.details_users [ UnitName ("raid"..i)]) then
				end
			end
		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers()-1 do
				if (_detalhes.details_users [ UnitName ("party"..i)]) then
				end
			end
		end
	end

	local temp = {}

	function _detalhes:RaidComm (_, data, _, source)
	
		local type, player, realm, dversion, arg6, arg7 =  select (2, _detalhes:Deserialize (data))
		
		if (_detalhes.debug) then
			print ("comm received", type)
		end
		
		if (type == "highfive") then
			if (player ~= _detalhes.playername and not _detalhes.details_users [player]) then
				_detalhes.details_users [player] = {player, realm, dversion}
			end
			
		elseif (type == "petowner") then
			local serial = player
			local nome = realm
			local owner_table = dversion
			
			if (not _detalhes.container_pets.pets [serial]) then
				_detalhes.container_pets.pets [serial] = owner_table
				local petActor = _detalhes.tabela_vigente[1]:PegarCombatente (_, nome)
				if (petActor) then
					local ownerActor = _detalhes.tabela_vigente[1]:PegarCombatente (owner_table[2], owner_table[1], owner_table[3], true)
					ownerActor.total = ownerActor.total + petActor.total
					if (_detalhes.debug) then
						_detalhes:Msg ("Received owner for pet ",nome, "assigned to", owner_table[1])
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
			local owner_table = _detalhes.container_pets.pets [petserial]
			
			if (owner_table) then
				if (realm ~= GetRealmName()) then
					player = player .."-"..realm
				end
				if (_detalhes.debug) then
					_detalhes:Msg ("Received pet owner request of pet, sending owner")
				end
				_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("petowner", petserial, petnome, owner_table), "WHISPER", player)
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
								local nname, server = UnitName ("raid"..i)
								if (server) then
									nname = nname.."-"..server
								end
								if (nname == name) then
									actor = container:PegarCombatente (UnitGUID ("raid"..i), name, 0x00000417, true)
									break
								end
							else
								if (UnitName ("raid"..i) == name) then
									actor = container:PegarCombatente (UnitGUID ("raid"..i), name, 0x00000417, true)
									break
								end
							end

						end
					elseif (IsInGroup()) then
						for i = 1, GetNumGroupMembers()-1 do
							if (name:find ("-")) then --> other realm
								local nname, server = UnitName ("party"..i)
								if (server) then
									nname = nname.."-"..server
								end
								if (nname == name) then
									actor = container:PegarCombatente (UnitGUID ("party"..i), name, 0x00000417, true)
									break
								end
							else
								if (UnitName ("party"..i) == name or _detalhes.playername == name) then
									actor = container:PegarCombatente (UnitGUID ("party"..i), name, 0x00000417, true)
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
						print ("Actor not found on cloud data received", name, atributo_name)
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
				for i = 1, math.min (6, #container) do 
					local actor = container [i]
					
					if (not actor.grupo) then
						break
					end
					
					export [#export+1] = {actor.nome, actor [atributo_name]}
				end
				
				_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatareceived", atributo, atributo_name, export), "WHISPER", _detalhes.host_of)
				table.wipe (temp)
			end
			
		elseif (type == "foundcloud") then
		
			if (_detalhes.host_by) then
				return
			end
		
			if (realm ~= GetRealmName()) then
				player = player .."-"..realm
			end
			_detalhes.host_by = player
			
			if (_detalhes.debug) then
				print ("Details found a cloud for disabled captures.")
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
			_detalhes:OnReceiveCustom (select (3, _detalhes:Deserialize (data)))
			
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
	
	function _detalhes:SendRaidData (type, ...)
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize (type, UnitName ("player"), GetRealmName(), _detalhes.realversion, ...), "RAID")
	end
	
	function _detalhes:SendHighFive()
		if (true) then --> disabled
			return
		end
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("highfive", UnitName ("player"), GetRealmName(), _detalhes.realversion), "RAID")
	end
	
	function _detalhes:SendPetOwnerRequest (petserial, petnome)
		if (_detalhes.debug) then
			_detalhes:Msg ("Sent request for a pet",petserial, petnome)
		end
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("needpetowner", UnitName ("player"), GetRealmName(), _detalhes.realversion, petserial, petnome), "RAID")
	end
	
	function _detalhes:SendCloudRequest()
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("needcloud", UnitName ("player"), GetRealmName(), _detalhes.realversion), "RAID")
	end
	
	function _detalhes:SendCloudResponse (player, realm)
		if (realm ~= GetRealmName()) then
			player = player .."-"..realm
		end
		_detalhes.host_of = player
		if (_detalhes.debug) then
			_detalhes:Msg ("Sent request for a cloud parser")
		end
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("foundcloud", UnitName ("player"), GetRealmName(), _detalhes.realversion), "WHISPER", player)
	end

	function _detalhes:RequestData()
	
		_detalhes.last_data_requested = _detalhes._tempo
	
		for index = 1, #_detalhes.tabela_instancias do
			local instancia = _detalhes.tabela_instancias [index]
			if (instancia.ativa) then
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