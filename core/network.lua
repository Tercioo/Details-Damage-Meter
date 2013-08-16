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

	function _detalhes:RaidComm (_, data, _, source)
		local type =  select (2, _detalhes:Deserialize (data))
		
		if (_detalhes.debug) then
			print ("comm received", type)
		end
		
		if (type == "custom_broadcast") then
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

