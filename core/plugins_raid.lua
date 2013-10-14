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
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions	

	function _detalhes:RaidMode (enable, instancia)
		if (enable) then

			_detalhes.RaidTables.instancia = instancia
			_detalhes.RaidTables.Mode = _detalhes.RaidTables.Mode or 1 --> solo mode

			instancia.modo = _detalhes._detalhes_props["MODO_RAID"]
			
			gump:Fade (instancia, 1, nil, "barras")
			
			if (instancia.rolagem) then
				instancia:EsconderScrollBar (true) --> hida a scrollbar
			end
			
			_detalhes:ResetaGump (instancia)
			instancia:DefaultIcons (true, false, true, false)
			
			_detalhes.raid = instancia.meu_id
			instancia:AtualizaGumpPrincipal (true)
			
			if (not _detalhes.RaidTables.Plugins [1]) then
				_detalhes:WaitForSoloPlugin (instancia)
			else
				if (not _detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode]) then
					_detalhes.RaidTables.Mode = 1
				end
				_detalhes.RaidTables:switch (nil, _detalhes.RaidTables.Mode)
			end
		
		else
			
			_detalhes.RaidTables:switch()
			_detalhes.raid = nil

			if (_G.DetailsWaitForPluginFrame:IsShown()) then
				_detalhes:CancelWaitForPlugin()
			end
			
			gump:Fade (instancia, 1, nil, "barras")
			gump:Fade (instancia.scroll, 0)
			
			if (instancia.need_rolagem) then
				instancia:MostrarScrollBar (true)
			else
				--> precisa verificar se ele precisa a rolagem certo?
				instancia:ReajustaGump()
			end
			
			instancia:DefaultIcons (true, true, true, true)
			
			--> calcula se existem barras, etc...
			if (not instancia.barrasInfo.cabem) then --> as barras não forma iniciadas ainda
				instancia.barrasInfo.cabem = _math_floor (instancia.baseframe.BoxBarrasAltura / instancia.barrasInfo.alturaReal)
				if (instancia.barrasInfo.criadas < instancia.barrasInfo.cabem) then
					for i  = #instancia.barras+1, instancia.barrasInfo.cabem do
						local nova_barra = gump:CriaNovaBarra (instancia, i, 30) --> cria nova barra
						nova_barra.texto_esquerdo:SetText (Loc ["STRING_NEWROW"])
						nova_barra.statusbar:SetValue (100) 
						instancia.barras [i] = nova_barra
					end
					instancia.barrasInfo.criadas = #instancia.barras
				end
			end
			
		end
	end

	function _detalhes:InstanciaCheckForDisabledRaid (instancia)

		if (not instancia) then
			instancia = self
		end
		
		if (instancia.modo == modo_raid) then
			if (instancia.iniciada) then
				_detalhes:AlteraModo (instancia, _detalhes._detalhes_props["MODO_GROUP"])
				instancia:RaidMode (false, instancia)
				_detalhes:ResetaGump (instancia)
			else
				instancia.modo = _detalhes._detalhes_props["MODO_GROUP"]
				instancia.last_modo = _detalhes._detalhes_props["MODO_GROUP"]
			end
		end
	end

	function _detalhes.RaidTables:switch (_, _switchTo)

		--> just hide all
		if (not _switchTo) then 
			if (#_detalhes.RaidTables.Plugins > 0) then --> have at least one plugin
				_detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode].Frame:Hide()
			end
			return
		end
		
		--> jump to the next
		if (_switchTo == -1) then
			_switchTo = _detalhes.RaidTables.Mode + 1
			if (_switchTo > #_detalhes.RaidTables.Plugins) then
				_switchTo = 1
			end
		end

		local ThisFrame = _detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode]
		if (not ThisFrame) then
			--> frame not found, try in few second again
			_detalhes.RaidTables.Mode = _switchTo
			_detalhes:WaitForSoloPlugin (_detalhes:GetRaidMode())
			return
		end

		--> hide current frame
		_detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode].Frame:Hide()
		--> switch mode
		_detalhes.RaidTables.Mode = _switchTo
		--> show and setpoint new frame

		_detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode].Frame:Show()
		_detalhes.RaidTables.Plugins [_detalhes.RaidTables.Mode].Frame:SetPoint ("TOPLEFT",_detalhes.RaidTables.instancia.bgframe)
		
		_detalhes.RaidTables.instancia:ChangeIcon (_detalhes.RaidTables.Menu [_detalhes.RaidTables.Mode] [2])
		
	end
