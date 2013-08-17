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
--> api

	local temp = {}

	function _detalhes:RaidComm (_, data, _, source)
		local type =  select (2, _detalhes:Deserialize (data))
		
		if (_detalhes.debug) then
			print ("comm received", type)
		end
		
		if (type == "highfive") then
			local player, realm, dversion = select (3, _detalhes:Deserialize (data))
			if (player ~= _detalhes.playername) then
				_detalhes.details_users [#_detalhes.details_users+1] = {player, realm, dversion}
			end
		
		elseif (type == "clouddatareceived") then
		
			local atributo, atributo_name, data = select (3, _detalhes:Deserialize (data))
			
			local container = _detalhes.tabela_vigente [atributo]
			
			for i = 1, #data do 
				local _this = data [i]
				
				local name = _this [1]
				local actor = container:PegarCombatente (_, name)
				
				if (not actor) then
					if (IsInRaid()) then
						for i = 1, GetNumGroupMembers() do 
							if (UnitName ("raid"..i) == name) then
								actor = container:PegarCombatente (UnitGUID ("raid"..i), name, 0x00000417, true)
								break
							end
						end
					elseif (IsInGroup()) then
						for i = 1, GetNumGroupMembers()-1 do
							if (UnitName ("party"..i) == name or _detalhes.playername == name) then
								actor = container:PegarCombatente (UnitGUID ("party"..i), name, 0x00000417, true)
								break
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
		
			local atributo, subatributo = select (3, _detalhes:Deserialize (data))
			
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
		
			local player, realm, dversion = select (3, _detalhes:Deserialize (data))
			if (realm ~= GetRealmName()) then
				player = player .."-"..realm
			end
			_detalhes.host_by = player
			
			if (_detalhes.debug) then
				print ("Details found a cloud for disabled captures.")
			end
			
			_detalhes.cloud_process = _detalhes:ScheduleRepeatingTimer ("RequestData", 7)
			
		elseif (type == "needcloud") then
			local player, realm, dversion = select (3, _detalhes:Deserialize (data))
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
			
				local player, realm, dversion, receivedActor = select (3, _detalhes:Deserialize (data))
				
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
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("highfive", UnitName ("player"), GetRealmName(), _detalhes.realversion), "RAID")
	end
	
	function _detalhes:SendCloudRequest()
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("needcloud", UnitName ("player"), GetRealmName(), _detalhes.realversion), "RAID")
	end
	
	function _detalhes:SendCloudResponse (player, realm)
		if (realm ~= GetRealmName()) then
			player = player .."-"..realm
		end
		_detalhes.host_of = player
		_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("foundcloud", UnitName ("player"), GetRealmName(), _detalhes.realversion), "WHISPER", player)
	end

	function _detalhes:RequestData()
		for index = 1, #_detalhes.tabela_instancias do
			local instancia = _detalhes.tabela_instancias [index]
			if (instancia.ativa) then
				_detalhes:SendCommMessage ("details_comm", _detalhes:Serialize ("clouddatarequest", instancia.atributo, instancia.sub_atributo), "WHISPER", _detalhes.host_by)
				break
			end
		end
	end