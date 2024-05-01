local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local type= type  --lua local
local ipairs = ipairs --lua local
local pairs = pairs --lua local
local _math_floor = math.floor --lua local
local _table_remove = table.remove --lua local
local _string_len = string.len --lua local
local _unpack = unpack --lua local
local _cstr = string.format --lua local
local _SendChatMessage = SendChatMessage --wow api locals
local _UnitExists = UnitExists --wow api locals
local _UnitName = UnitName --wow api locals
local _UnitIsPlayer = UnitIsPlayer --wow api locals
local _UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned --wow api locals

local segmentClass = Details.historico
local combatClass = Details.combate

local Details = 		_G.Details
local _
local addonName, Details222 = ...
local gump = 			Details.gump

local modo_raid = Details._detalhes_props["MODO_RAID"]
local modo_alone = Details._detalhes_props["MODO_ALONE"]
local modo_grupo = Details._detalhes_props["MODO_GROUP"]
local modo_all = Details._detalhes_props["MODO_ALL"]

local atributos = Details.atributos
local sub_atributos = Details.sub_atributos

--STARTUP reativa as instancias e regenera as tabelas das mesmas
	function Details:RestartInstances()
		return Details:ReativarInstancias()
	end

	function Details:ReativarInstancias()
		Details.opened_windows = 0

		--set metatables
		for index = 1, #Details.tabela_instancias do
			local instancia = Details.tabela_instancias[index]
			if (not getmetatable(instancia)) then
				setmetatable(Details.tabela_instancias[index], Details)
			end
		end

		--create frames
		for index = 1, #Details.tabela_instancias do
			local instancia = Details.tabela_instancias [index]
			if (instancia:IsEnabled()) then
				Details.opened_windows = Details.opened_windows + 1
				instancia:RestauraJanela(index, nil, true)
			else
				instancia.iniciada = false
			end
		end

		--load
		for index = 1, #Details.tabela_instancias do
			local instancia = Details.tabela_instancias [index]
			if (instancia:IsEnabled()) then
				instancia.iniciada = true
				instancia:AtivarInstancia()
				instancia:ChangeSkin()
			end
		end

		--send open event
		for index = 1, #Details.tabela_instancias do
			local instancia = Details.tabela_instancias[index]
			if (instancia:IsEnabled()) then
				if (not Details.initializing) then
					Details:SendEvent("DETAILS_INSTANCE_OPEN", nil, instancia)
				end
			end
		end
	end

------------------------------------------------------------------------------------------------------------------------

---call a function to all enabled instances
---@param func function|string
---@vararg any
function Details:InstanceCall(func, ...)
	if (type(func) == "string") then
		func = Details[func]
	end
	for index, instance in ipairs(Details.tabela_instancias) do
		if (instance:IsAtiva()) then
			func(instance, ...)
		end
	end
end

---run a function on all enabled instances
---@param func function
---@vararg any
function Details:InstanceCallDetailsFunc(func, ...)
	for index, instance in ipairs(Details.tabela_instancias) do
		---@cast instance instance
		if (instance:IsEnabled()) then
			func(nil, instance, ...)
		end
	end
end

---run a function on all instances (enabled or disabled)
---@param func function
---@vararg any
function Details:InstanciaCallFunctionOffline(func, ...)
	for index, instancia in ipairs(Details.tabela_instancias) do
		func(nil, instancia, ...)
	end
end

---run a function on all instances in the group
---@param instance instance
---@param funcName string
---@vararg any
function Details:InstanceGroupCall(instance, funcName, ...)
	for _, thisInstance in ipairs(instance:GetInstanceGroup()) do
		thisInstance[funcName](thisInstance, ...)
	end
end

---change a settings on all windows in the group
---@param instance instance
---@param keyName string
---@param value any
function Details:InstanceGroupEditSetting(instance, keyName, value)
	for _, thisInstance in ipairs(instance:GetInstanceGroup()) do
		thisInstance[keyName] = value
	end
end

---change a settings on all windows in the group
---@param instance instance
---@param table1Key string|number
---@param table2Key string|number
---@param table3Key string|number
---@param value any
function Details:InstanceGroupEditSettingOnTable(instance, table1Key, table2Key, table3Key, value)
	for _, thisInstance in ipairs(instance:GetInstanceGroup()) do
		if (value == nil) then
			local value1 = table3Key
			local table1 = thisInstance[table1Key]
			table1[table2Key] = value1
		else
			local table1 = thisInstance[table1Key]
			table1[table2Key][table3Key] = value
		end
	end
end

---get the instanceId of the opened instance with the lowest id
---@return instanceid|nil
function Details:GetLowerInstanceNumber()
	local lower = 999
	for index, instancia in ipairs(Details.tabela_instancias) do
		if (instancia.ativa and instancia.baseframe) then
			if (instancia.meu_id < lower) then
				lower = instancia.meu_id
			end
		end
	end
	if (lower == 999) then
		Details.lower_instance = 0
		return nil
	else
		Details.lower_instance = lower
		return lower
	end
end

--instance class prototype/mixin
local instanceMixins = {
	---check if the instance is the lower instance id
	---@param instance instance
	---@return boolean
	IsLowerInstance = function(instance)
		return Details:GetLowerInstanceNumber() == instance:GetId()
	end,

	---@param instance instance
	---@return boolean
	IsInteracting = function(instance)
		return instance.is_interacting
	end,

	---check if the instance is enabled
	---@param instance instance
	---@return boolean
	IsEnabled = function(instance)
		return instance.ativa
	end,

	---check if some basic aspects of the instance are valid
	---@param instance instance
	CheckIntegrity = function(instance)
		if (not instance.atributo) then
			instance.atributo = 1
			instance.sub_atributo = 1
		end

		if (not instance.showing[instance.atributo]) then
			instance.showing = Details:GetCurrentCombat()
		end

		instance.atributo = instance.atributo or 1
		instance.showing[instance.atributo].need_refresh = true
	end,

	---set the combatObject by the segmentId the instance is showing
	---@param instance instance
	RefreshCombat = function(instance)
		---@type segmentid
		local segmentId = instance:GetSegmentId()
		if (segmentId == DETAILS_SEGMENTID_OVERALL) then
			---@type combat
			local combatObject = Details:GetOverallCombat()
			if (combatObject.__destroyed) then
				combatObject = combatClass:NovaTabela()
			end
			instance.showing = combatObject

		elseif (segmentId == DETAILS_SEGMENTID_CURRENT) then
			---@type combat
			local combatObject = Details:GetCurrentCombat()
			if (combatObject.__destroyed) then
				combatObject = combatClass:NovaTabela(nil, Details.tabela_overall)
			end
			instance.showing = combatObject

		else
			---@type combat
			local combatObject = Details:GetCombat(segmentId)
			if (not combatObject) then
				instance:SetSegmentId(DETAILS_SEGMENTID_CURRENT)
				instance:RefreshCombat()
				return
			else
				if (combatObject.__destroyed) then
					table.remove(Details:GetCombatSegments(), segmentId)
					combatObject = combatClass:NovaTabela()
					table.insert(Details:GetCombatSegments(), segmentId, combatObject)
				end
			end
			instance.showing = combatObject
		end

		---@type combat
		local combatObject = instance:GetCombat()
		if (combatObject) then
			---@type attributeid
			local attributeId = instance:GetDisplay()
			combatObject[attributeId].need_refresh = true
		end
	end,

	---reset some of the instance properties needed to show a new segment
	---@param instance instance
	---@param resetType number|nil
	---@param segmentId segmentid|nil
	ResetWindow = function(instance, resetType, segmentId) --deprecates Details:ResetaGump()
		--check the reset type, 0x1: entering in combat
		if (resetType and resetType == 0x1) then
			--if is showing the overall data, do nothing
			if (instance:GetSegmentId() == DETAILS_SEGMENTID_OVERALL) then
				return
			end
		end

		if (segmentId and instance:GetSegmentId() ~= segmentId) then
			return
		end

		--reset some instance properties
		instance.barraS = {nil, nil}
		instance.rows_showing = 0
		instance.need_rolagem = false
		instance.bar_mod = nil

		--clean up all bars
		for i = 1, instance.rows_created do
			local thisBar = instance.barras[i]
			thisBar.minha_tabela = nil
			thisBar.animacao_fim = 0
			thisBar.animacao_fim2 = 0
			if thisBar.extraStatusbar then thisBar.extraStatusbar:Hide() end
		end

		if (instance.rolagem) then
			--hide the scroll bar
			instance:EsconderScrollBar()
		end
	end,

	---call a refresh in the data shown in the instance
	---@param instance instance
	---@param bForceRefresh boolean|nil
	RefreshData = function(instance, bForceRefresh) --deprecates Details:RefreshAllMainWindows()
		local combatObject = instance:GetCombat()

		--check if the combat object exists, if not, freeze the window
		if (not combatObject) then
			if (not instance.freezed) then
				return instance:Freeze()
			end
			return
		end

		--debug: check if the if combatObject has been destroyed
		if (combatObject.__destroyed) then
			Details:Msg("a deleted combat object was found refreshing a window, please report this bug on discord:")
			Details:Msg("combat destroyed by:", combatObject.__destroyedBy)
			local bForceChange = true
			instance:SetSegment(DETAILS_SEGMENTID_CURRENT, bForceChange)
			return
		end

		local mainAttribute, subAttribute = instance:GetDisplay()

		---@type actorcontainer
		local actorContainer = combatObject:GetContainer(mainAttribute)
		local needRefresh = actorContainer.need_refresh
		if (not needRefresh and not bForceRefresh) then
			return
		end

		if (mainAttribute == 1) then --damage
			Details.atributo_damage:RefreshWindow(instance, combatObject, bForceRefresh, nil, needRefresh)

		elseif (mainAttribute == 2) then --heal
			Details.atributo_heal:RefreshWindow(instance, combatObject, bForceRefresh, nil, needRefresh)

		elseif (mainAttribute == 3) then --energy
			Details.atributo_energy:RefreshWindow(instance, combatObject, bForceRefresh, nil, needRefresh)

		elseif (mainAttribute == 4) then --utility
			Details.atributo_misc:RefreshWindow(instance, combatObject, bForceRefresh, nil, needRefresh)

		elseif (mainAttribute == 5) then --custom
			Details.atributo_custom:RefreshWindow(instance, combatObject, bForceRefresh, nil, needRefresh)
		end
	end,

	---refresh the instance window
	---@param instance instance
	---@param bForceRefresh boolean|nil
	RefreshWindow = function(instance, bForceRefresh) --deprecates Details:RefreshMainWindow()
		if (not bForceRefresh) then
			Details.LastUpdateTick = Details._tempo
		end

		if (instance:IsEnabled()) then
			---@type modeid
			local modeId = instance:GetMode()

			if (modeId == DETAILS_MODE_GROUP or modeId == DETAILS_MODE_ALL) then
				instance:RefreshData(bForceRefresh)
			end

			if (instance:GetCombat()) then
				if (instance:GetMode() == DETAILS_MODE_GROUP or instance:GetMode() == DETAILS_MODE_ALL) then
					if (instance.atributo <= 4) then
						instance.showing[instance.atributo].need_refresh = false
					end
				end
			end

			--update player breakdown window if opened
			--if (not bForceRefresh) then
				if (Details:IsBreakdownWindowOpen()) then
					return Details:GetActorObjectFromBreakdownWindow():MontaInfo()
				end
			--end
		end
	end,

	---get the combat object which the instance is showing
	---@param instance instance
	---@return combat
	GetCombat = function(instance)
		return instance.showing
	end,

	---return the instance id
	---@param instance instance
	---@return instanceid
	GetId = function(instance)
		return instance.meu_id
	end,

	---@param instance instance
	---@return modeid
	GetMode = function(instance)
		---@type modeid
		local modeId = instance.modo
		return modeId
	end,

	---return the segmentId
	---@param instance instance
	---@return segmentid
	GetSegmentId = function(instance)
		return instance.segmento
	end,

	SetSegmentId = function(instance, segmentId)
		instance.segmento = segmentId
	end,

	---return the mais attribute id and the sub attribute
	---@param instance instance
	---@return attributeid
	---@return attributeid
	GetDisplay = function(instance)
		return instance.atributo, instance.sub_atributo
	end,

	---@param instance instance
	---@param modeId modeid
	SetMode = function(instance, modeId)
		instance.LastModo = instance.modo
		instance.modo = modeId
		instance:CheckIntegrity()
		Details222.Instances.OnModeChanged(instance)
	end,

	SetSegmentFromCooltip = function(_, instance, segmentId, bForceChange)
		return instance:SetSegment(segmentId, bForceChange)
	end,

	---change the segment shown in the instance, this changes the segmentID and also refresh the combat object in the instance
	---@param instance instance
	---@param segmentId segmentid
	---@param bForceChange boolean|nil
	SetSegment = function(instance, segmentId, bForceChange)
		local currentSegment = instance:GetSegmentId()
		if (segmentId ~= currentSegment or bForceChange) then
			--check if the instance is frozen
			if (instance.freezed) then
				instance:UnFreeze()
			end

			instance.segmento = segmentId
			instance:RefreshCombat()
			Details:SendEvent("DETAILS_INSTANCE_CHANGESEGMENT", nil, instance, segmentId)

			instance.v_barras = true
			instance:ResetWindow()
			instance:RefreshWindow(true)

			if (Details.instances_segments_locked) then
				---@param otherInstance instance
				for _, otherInstance in ipairs(Details:GetAllInstances()) do
					if (instance:GetId() ~= otherInstance:GetId() and otherInstance:IsEnabled() and not otherInstance._postponing_switch and not otherInstance._postponing_current) then
						if (segmentId ~= -1 and otherInstance:GetSegmentId() >= 0) then --not overall data
							if (otherInstance.modo == DETAILS_MODE_GROUP or otherInstance.modo == DETAILS_MODE_ALL) then
								--check if the instance is frozen
								if (otherInstance.freezed) then
									otherInstance:UnFreeze()
								end

								otherInstance.segmento = segmentId
								otherInstance:RefreshCombat()

								if (not otherInstance.showing) then
									otherInstance:Freeze()
									return
								end

								otherInstance.v_barras = true
								otherInstance.showing[otherInstance.atributo].need_refresh = true

								otherInstance:ResetWindow()
								otherInstance:RefreshWindow(true)

								Details:SendEvent("DETAILS_INSTANCE_CHANGESEGMENT", nil, otherInstance, segmentId)
							end
						end
					end
				end
			end
		end
	end,

    ---@param instance instance
	---@param segmentId segmentid
	---@param attributeId attributeid
	---@param subAttributeId attributeid
	---@param modeId modeid
	SetDisplay = function(instance, segmentId, attributeId, subAttributeId, modeId)
		--change the mode of the window if the mode is different
		---@type modeid
		local currentModeId = instance:GetMode()
		if (modeId and type(modeId) == "number" and currentModeId ~= modeId) then
			instance:SetMode(modeId)
			currentModeId = modeId
		end

		--change the segment of the window if the segment is different
		---@type segmentid
		local currentSegmentId = instance:GetSegmentId()
		if (segmentId and type(segmentId) == "number" and currentSegmentId ~= segmentId) then
			instance:SetSegment(segmentId)
		end

		---@type attributeid, attributeid
		local currentAttributeId, currentSubAttributeId = instance:GetDisplay()
		---@type boolean
		local bHasMainAttributeChanged = false

		if (not subAttributeId) then
			if (attributeId == currentAttributeId) then
				subAttributeId  = currentSubAttributeId
			else
				subAttributeId  = instance.sub_atributo_last[attributeId]
			end
		elseif (type(subAttributeId) ~= "number") then
			subAttributeId = instance.sub_atributo
		end

		--change the attributes, need to deal with plugins and custom displays
		if (type(attributeId) == "number" and type(subAttributeId) == "number") then
			if (Details222.Instances.ValidateAttribute(attributeId, subAttributeId)) then
				if (attributeId == DETAILS_ATTRIBUTE_CUSTOM) then
					if (#Details.custom < 1) then
						attributeId = 1
						subAttributeId = 1
					end
				end

				if (attributeId ~= currentAttributeId or (currentModeId == DETAILS_MODE_SOLO or currentModeId == DETAILS_MODE_RAID)) then
					if (currentModeId == DETAILS_MODE_SOLO) then
						return Details.SoloTables.switch(nil, nil, -1)

					elseif (currentModeId == DETAILS_MODE_RAID) then
						--do nothing when clicking in the button
						return
					end

					instance.atributo = attributeId
					instance.sub_atributo = instance.sub_atributo_last[attributeId]

					bHasMainAttributeChanged = true

					instance:ChangeIcon()
					Details:InstanceCall(Details.CheckPsUpdate)
					Details:SendEvent("DETAILS_INSTANCE_CHANGEATTRIBUTE", nil, instance, attributeId, subAttributeId)
				end
			end
		end

		if (type(subAttributeId) == "number" and subAttributeId ~= currentSubAttributeId or bHasMainAttributeChanged) then
			instance.sub_atributo = subAttributeId
			instance.sub_atributo_last[instance.atributo] = instance.sub_atributo
			instance:ChangeIcon()
			Details:InstanceCall(Details.CheckPsUpdate)
			Details:SendEvent("DETAILS_INSTANCE_CHANGEATTRIBUTE", nil, instance, attributeId, subAttributeId)
		end

		if (Details.BreakdownWindowFrame:IsShown() and instance == Details.BreakdownWindowFrame.instancia) then
			---@type combat
			local combatObject = instance:GetCombat()
			if (not combatObject or instance.atributo > 4) then
				Details:CloseBreakdownWindow()
			else
				---@type actor
				local actorObject = Details:GetActorObjectFromBreakdownWindow()
				if (actorObject) then
					Details:OpenBreakdownWindow(instance, actorObject, true)
				else
					Details:CloseBreakdownWindow()
				end
			end
		end

		--end of change attributes, mode and segment
		--if there's no combat object to show, freeze the window
		---@type combat
		local combatObject = instance:GetCombat()
		if (not combatObject) then
			instance:Freeze()
			return false
		end

		instance.v_barras = true
		combatObject[attributeId].need_refresh = true

		instance:ResetWindow()
		instance:RefreshWindow(true)
	end,
}

---get the table with all instances, these instance could be not initialized yet, some might be open, some not in use
---@return instance[]
function Details:GetAllInstances()
	return Details.tabela_instancias
end

function Details:GetInstance(id)
	return Details.tabela_instancias[id]
end

--user friendly alias
function Details:GetWindow(id)
	return Details.tabela_instancias[id]
end

function Details:GetNumInstances()
	return #Details.tabela_instancias
end

function Details:GetId()
	return self.meu_id
end
function Details:GetInstanceId()
	return self.meu_id
end

function Details:GetSegment()
	return self.segmento
end

function Details:GetSoloMode()
	return Details.tabela_instancias[Details.solo]
end
function Details:GetRaidMode()
	return Details.tabela_instancias[Details.raid]
end

function Details:IsSoloMode(offline)
	if (offline) then
		return self.modo == 1
	end
	if (not Details.solo) then
		return false
	else
		return Details.solo == self:GetInstanceId()
	end
end

function Details:IsRaidMode()
	return self.modo == Details._detalhes_props["MODO_RAID"]
end

function Details:IsGroupMode()
	return self.modo == Details._detalhes_props["MODO_GROUP"]
end

function Details:IsNormalMode()
	if (self:GetInstanceId() == 2 or self:GetInstanceId() == 3) then
		return true
	else
		return false
	end
end

function Details:GetShowingCombat()
	return self.showing
end

function Details:GetCustomObject (object_name)
	if (object_name) then
		for _, object in ipairs(Details.custom) do
			if (object.name == object_name) then
				return object
			end
		end
	else
		return Details.custom [self.sub_atributo]
	end
end

function Details:ResetAttribute()
	if (self.iniciada) then
		self:TrocaTabela(nil, 1, 1, true)
	else
		self.atributo = 1
		self.sub_atributo = 1
	end
end

function Details:ListInstances()
	return ipairs(Details.tabela_instancias)
end

function Details:GetPosition()
	return self.posicao
end

function Details:GetDisplay()
	return self.atributo, self.sub_atributo
end

function Details:GetMaxInstancesAmount()
	return Details.instances_amount
end

function Details:SetMaxInstancesAmount (amount)
	if (type(amount) == "number") then
		Details.instances_amount = amount
	end
end

function Details:GetFreeInstancesAmount()
	return Details.instances_amount - #Details.tabela_instancias
end

function Details:GetOpenedWindowsAmount()
	local amount = 0
	for _, instance in Details:ListInstances() do
		if (instance:IsEnabled()) then
			amount = amount + 1
		end
	end
	return amount
end

function Details:GetNumRows()
	return self.rows_fit_in_window
end

function Details:GetRow (index)
	return self.barras [index]
end

function Details:GetSkin()
	return Details.skins [self.skin]
end

function Details:GetSkinTexture()
	return Details.skins [self.skin] and Details.skins [self.skin].file
end

function Details:GetAllLines()
	return self.barras
end
function Details:GetLine(lineId) --alias of _detalhes:GetRow(index)
	return self.barras[lineId]
end
function Details:GetNumLinesShown() --alis of _detalhes:GetNumRows()
	return self.rows_fit_in_window
end

---comment
---@param displayId number
---@return actor
---@return actor
---@return actor
---@return actor
---@return actor
function Details:GetTop5Actors(displayId)
	local combatObject = self.showing
	local container = combatObject:GetContainer(displayId)
	local actorTable = container._ActorTable
	return actorTable[1], actorTable[2], actorTable[3], actorTable[4], actorTable[5]
end

---get the combat object which the instance is showing, get the display and subDisplay, then refresh the window in report mode and get the rankIndex actor
---@param self instance
---@param displayId attributeid
---@param subDisplayId attributeid
---@param rankIndex number
---@return actor
function Details:GetActorBySubDisplayAndRank(displayId, subDisplayId, rankIndex)
	local classObject = Details:GetDisplayClassByDisplayId(displayId)
	local combatObject = self:GetCombat()
	local bIsForceRefresh = false
	local bIsExport = true
	local totalDone, subDisplayName, firstPlaceTotal, actorAmount = classObject:RefreshWindow(self, combatObject, bIsForceRefresh, bIsExport)

	local actorContainer = combatObject:GetContainer(displayId)
	local actorTable = actorContainer:GetActorTable()

	return actorTable[rankIndex]
end

--@attributeId: DETAILS_ATTRIBUTE_DAMAGE, DETAILS_ATTRIBUTE_HEAL
--@rankIndex: the rank id of the actor shown in the window
---@param self instance
---@param displayId attributeid
---@param rankIndex number
function Details:GetActorByRank(displayId, rankIndex)
	local combatObject = self:GetCombat()
	if (combatObject) then
		local container = combatObject:GetContainer(displayId)
		if (container) then
			return container._ActorTable[rankIndex]
		end
	end

	--[=[
	local firstRow = window1:GetLine(1)
	if (firstRow and firstRow:IsShown()) then
		local actor = firstRow:GetActor()
		if (actor) then
			local total = actor.total
			local combatTime = Details:GetCurrentCombat():GetCombatTime()
			print("dps:", total/combatTime)
		end
	end

	local actorTable = container._ActorTable
	for i = 1, #actorTable do
		local actor = actorTable[rankIndex]
		return actor
	end
	--]=]
end

------------------------------------------------------------------------------------------------------------------------

--retorna se a inst�ncia esta ou n�o ativa
function Details:IsAtiva()
	return self.ativa
end

--english alias
function Details:IsShown()
	return self.ativa
end
function Details:IsEnabled()
	return self.ativa
end

function Details:IsStarted()
	return self.iniciada
end

------------------------------------------------------------------------------------------------------------------------

	function Details:LoadLocalInstanceConfig()
		local config = Details.local_instances_config [self.meu_id]
		if (config) then

			if (not Details.profile_save_pos) then
				self.posicao = Details.CopyTable(config.pos)
			end

			if (type(config.attribute) ~= "number") then
				config.attribute = 1
			end
			if (type(config.sub_attribute) ~= "number") then
				config.sub_attribute = 1
			end
			if (type(config.segment) ~= "number") then
				config.segment = 1
			end

			self.ativa = config.is_open
			self.atributo = config.attribute
			self.sub_atributo = config.sub_attribute
			self.modo = config.mode
			self.segmento = config.segment
			self.snap = config.snap and Details.CopyTable(config.snap) or {}
			self.horizontalSnap = config.horizontalSnap
			self.verticalSnap = config.verticalSnap
			self.sub_atributo_last = Details.CopyTable(config.sub_atributo_last)
			self.isLocked = config.isLocked
			self.last_raid_plugin = config.last_raid_plugin
		end
	end

	function Details:ShutDownAllInstances()
		for index, instance in ipairs(Details.tabela_instancias) do
			if (instance:IsEnabled() and instance.baseframe and not instance.ignore_mass_showhide) then
				instance:ShutDown(true)
			end
		end
	end

	--alias
	function Details:HideWindow(all)
		return self:DesativarInstancia(all)
	end
	function Details:ShutDown(all)
		return self:DesativarInstancia(all)
	end
	function Details:Shutdown(all)
		return self:DesativarInstancia(all)
	end

	function Details:GetNumWindows()

	end

--desativando a inst�ncia ela fica em stand by e apenas hida a janela ~shutdown ~close ~fechar
	function Details:DesativarInstancia(all)

		self.ativa = false
		Details.opened_windows = Details.opened_windows-1

		if (not self.baseframe) then
			--windown isn't initialized yet
			if (Details.debug) then
				Details:Msg("(debug) called HideWindow() but the window isn't initialized yet.")
			end
			return
		end

		local lower = Details:GetLowerInstanceNumber()
		Details:GetLowerInstanceNumber()

		if (lower == self.meu_id) then
			--os icones dos plugins estao hostiados nessa instancia.
			Details.ToolBar:ReorganizeIcons (true) --n�o precisa recarregar toda a skin
		end

		if (Details.switch.current_instancia and Details.switch.current_instancia == self) then
			Details.switch:CloseMe()
		end

		self:ResetaGump()

		Details.FadeHandler.Fader(self.baseframe.cabecalho.ball, 1)
		Details.FadeHandler.Fader(self.baseframe, 1)
		Details.FadeHandler.Fader(self.rowframe, 1)
		Details.FadeHandler.Fader(self.windowSwitchButton, 1)

		if (not all) then
			self:Desagrupar (-1)
		end

		if (self.modo == modo_raid) then
			Details.RaidTables:DisableRaidMode (self)

		elseif (self.modo == modo_alone) then
			Details.SoloTables:switch()
			self.atualizando = false
			Details.solo = nil
		end

		if (not Details.initializing) then
			Details:SendEvent("DETAILS_INSTANCE_CLOSE", nil, self)
		end
	end

------------------------------------------------------------------------------------------------------------------------

	function Details:InstanciaFadeBarras (instancia, segmento)
		local _fadeType, _fadeSpeed = _unpack(Details.row_fade_in)
		if (segmento) then
			if (instancia.segmento == segmento) then
				return Details.FadeHandler.Fader(instancia, _fadeType, _fadeSpeed, "barras")
			end
		else
			return Details.FadeHandler.Fader(instancia, _fadeType, _fadeSpeed, "barras")
		end
	end

	function Details:ToggleWindow (index)
		local window = Details:GetInstance(index)

		if (window and getmetatable (window)) then
			if (window:IsEnabled()) then
				window:ShutDown()
			else
				window:EnableInstance()

				if (window.meu_id == 1) then
					local instance2 = Details:GetInstance(2)
					if (instance2 and instance2:IsEnabled()) then
						Details.move_janela_func(instance2.baseframe, true, instance2, true)
						Details.move_janela_func(instance2.baseframe, false, instance2, true)
					end

				elseif (window.meu_id == 2) then
					Details.move_janela_func(window.baseframe, true, window, true)
					Details.move_janela_func(window.baseframe, false, window, true)
				end

			end
		end
	end

	function Details:CheckCoupleWindows (instance1, instance2)
		instance1 = instance1 or Details:GetInstance(1)
		instance2 = instance2 or Details:GetInstance(2)

		if (instance1 and instance2 and not instance1.ignore_mass_showhide and not instance1.ignore_mass_showhide) then

			instance1.baseframe:ClearAllPoints()
			instance2.baseframe:ClearAllPoints()

			instance1:RestoreMainWindowPosition()
			instance2:RestoreMainWindowPosition()

			instance1:AtualizaPontos()
			instance2:AtualizaPontos()

			local _R, _T, _L, _B = Details.VPL (instance2, instance1), Details.VPB (instance2, instance1), Details.VPR (instance2, instance1), Details.VPT (instance2, instance1)

			if (_R) then
				instance2:MakeInstanceGroup ({false, false, 1, false})
			elseif (_T) then
				instance2:MakeInstanceGroup ({false, false, false, 1})
			elseif (_L) then
				instance2:MakeInstanceGroup ({1, false, false, false})
			elseif (_B) then
				instance2:MakeInstanceGroup ({false, 1, false, false})
			end
		end

	end

	function Details:ToggleWindows()

		local instance

		for i = 1, #Details.tabela_instancias do
			local this_instance = Details:GetInstance(i)
			if (this_instance and not this_instance.ignore_mass_showhide) then
				instance = this_instance
				break
			end
		end

		if (instance) then
			if (instance:IsEnabled()) then
				Details:ShutDownAllInstances()
			else
				Details:ReabrirTodasInstancias()

				local instance1 = Details:GetInstance(1)
				local instance2 = Details:GetInstance(2)

				if (instance1 and instance2) then
					if (not Details.disable_window_groups) then
						if (not instance1.ignore_mass_showhide and not instance2.ignore_mass_showhide) then
							Details:CheckCoupleWindows (instance1, instance2)
						end
					end
				end
			end
		end
	end

	---reopen all closed windows that does not have the option "Ignore Mass Toogle" enabled
	---@param ... unknown
	---@return nil
	function Details:ReopenAllWindows(...)
		return Details:ReabrirTodasInstancias(...)
	end

	-- reabre todas as instancias
	function Details:ReabrirTodasInstancias (temp)
		for index = math.min (#Details.tabela_instancias, Details.instances_amount), 1, -1 do
			local instancia = Details:GetInstance(index)
			if (instancia and not instancia.ignore_mass_showhide) then
				instancia:AtivarInstancia (temp, true)
			end
		end
	end

	function Details:LockInstance (flag)

		if (type(flag) == "boolean") then
			self.isLocked = not flag
		end

		if (self.isLocked) then
			self.isLocked = false
			if (self.baseframe) then
				self.baseframe.isLocked = false
				self.baseframe.lock_button.label:SetText(Loc ["STRING_LOCK_WINDOW"])
				self.baseframe.lock_button:SetWidth(self.baseframe.lock_button.label:GetStringWidth()+2)
				self.baseframe.resize_direita:SetAlpha(0)
				self.baseframe.resize_esquerda:SetAlpha(0)
				self.baseframe.lock_button:ClearAllPoints()
				self.baseframe.lock_button:SetPoint("right", self.baseframe.resize_direita, "left", -1, 1.5)
			end
		else
			self.isLocked = true
			if (self.baseframe) then
				self.baseframe.isLocked = true
				self.baseframe.lock_button.label:SetText(Loc ["STRING_UNLOCK_WINDOW"])
				self.baseframe.lock_button:SetWidth(self.baseframe.lock_button.label:GetStringWidth()+2)
				self.baseframe.lock_button:ClearAllPoints()
				self.baseframe.lock_button:SetPoint("bottomright", self.baseframe, "bottomright", -3, 0)
				self.baseframe.resize_direita:SetAlpha(0)
				self.baseframe.resize_esquerda:SetAlpha(0)
			end
		end
	end

	function Details:TravasInstancias()
		for index, instancia in ipairs(Details.tabela_instancias) do
			instancia:LockInstance (true)
		end
	end

	function Details:DestravarInstancias()
		for index, instancia in ipairs(Details.tabela_instancias) do
			instancia:LockInstance (false)
		end
	end

	--alias
	function Details:ShowWindow (temp, all)
		return self:AtivarInstancia (temp, all)
	end
	function Details:EnableInstance (temp, all)
		return self:AtivarInstancia (temp, all)
	end

	function Details:AtivarInstancia (temp, all)
		self.ativa = true
		DetailsFramework:Mixin(self, instanceMixins)

		self.cached_bar_width = self.cached_bar_width or 0

		self.modo = self.modo or 2

		local lower = Details:GetLowerInstanceNumber()

		if (lower == self.meu_id) then
			--os icones dos plugins precisam ser hostiados nessa instancia.
			Details.ToolBar:ReorganizeIcons (true) --n�o precisa recarregar toda a skin
		end

		if (not self.iniciada) then
			self:RestauraJanela (self.meu_id, nil, true) --parece que esta chamando o ativar instance denovo... passei true no load_only vamos ver o resultado
			--tiny threat parou de funcionar depois de /reload depois dessa mudança, talvez tenha algo para carregar ainda
			self.iniciada = true
		else
			Details.opened_windows = Details.opened_windows+1
		end

		self:ChangeSkin() --carrega a skin aqui que era antes feito dentro do restaura janela
		Details:TrocaTabela(self, nil, nil, nil, true)

		if (self.hide_icon) then
			Details.FadeHandler.Fader(self.baseframe.cabecalho.atributo_icon, 1)
		else
			Details.FadeHandler.Fader(self.baseframe.cabecalho.atributo_icon, 0)
		end

		Details.FadeHandler.Fader(self.baseframe.cabecalho.ball, 0)
		Details.FadeHandler.Fader(self.baseframe, 0)
		Details.FadeHandler.Fader(self.rowframe, 0)
		Details.FadeHandler.Fader(self.windowSwitchButton, 0)

		self:SetMenuAlpha()
		self.baseframe.cabecalho.fechar:Enable()
		self:ChangeIcon()

		if (not temp) then
			if (self.modo == modo_raid) then
				Details.RaidTables:EnableRaidMode(self)

			elseif (self.modo == modo_alone) then
				self:SoloMode (true)
			end
		end

		if (Details.LastShowCommand and Details.LastShowCommand+10 > GetTime()) then
			self:ToolbarMenuButtons()
			self:ToolbarSide()
			self:AttributeMenu()
		else
			self:AdjustAlphaByContext(true)
		end

		self:DesaturateMenu()

		if (not all) then
			self:Desagrupar (-1)
		end

		self:CheckFor_EnabledTrashSuppression()

		if (not temp and not Details.initializing) then
			Details:SendEvent("DETAILS_INSTANCE_OPEN", nil, self)
		end

		if (self.modo == modo_raid) then
			Details.RaidTables:EnableRaidMode(self)

		elseif (self.modo == modo_alone) then
			self:SoloMode (true)
		end

	end

------------------------------------------------------------------------------------------------------------------------

--apaga de vez um inst�ncia
	function Details:ApagarInstancia (ID)
		return _table_remove(Details.tabela_instancias, ID)
	end

------------------------------------------------------------------------------------------------------------------------

--retorna quantas inst�ncia h� no momento
	function Details:GetNumInstancesAmount()
		return #Details.tabela_instancias
	end

	function Details:QuantasInstancias()
		return #Details.tabela_instancias
	end

------------------------------------------------------------------------------------------------------------------------

	function Details:DeleteInstance (id)
		local instance = Details:GetInstance(id)

		if (not instance) then
			return false
		end

		--break snaps of previous and next window
		local left_instance = Details:GetInstance(id-1)
		if (left_instance) then
			for snap_side, instance_id in pairs(left_instance.snap) do
				if (instance_id == id) then --snap na proxima instancia
					left_instance.snap [snap_side] = nil
				end
			end
		end
		local right_instance = Details:GetInstance(id+1)
		if (right_instance) then
			for snap_side, instance_id in pairs(right_instance.snap) do
				if (instance_id == id) then --snap na proxima instancia
					right_instance.snap [snap_side] = nil
				end
			end
		end

		--re align snaps for higher instances
		for i = id+1, #Details.tabela_instancias do
			local this_instance = Details:GetInstance(i)
			--fix the snaps
			for snap_side, instance_id in pairs(this_instance.snap) do
				if (instance_id == i+1) then --snap na proxima instancia
					this_instance.snap [snap_side] = i
				elseif (instance_id == i-1 and i-2 > 0) then --snap na instancia anterior
					this_instance.snap [snap_side] = i-2
				else
					this_instance.snap [snap_side] = nil
				end
			end
		end

		table.remove (Details.tabela_instancias, id)
	end


------------------------------------------------------------------------------------------------------------------------
--cria uma nova inst�ncia e a joga para o container de inst�ncias

	function Details:CreateInstance (id)
		return Details:CriarInstancia(_, id)
	end

	function Details:CriarInstancia(_, id)

		if (id and type(id) == "boolean") then

			if (#Details.tabela_instancias >= Details.instances_amount) then
				Details:Msg(Loc ["STRING_INSTANCE_LIMIT"])
				return false
			end

			local next_id = #Details.tabela_instancias+1

			if (Details.unused_instances [next_id]) then
				local new_instance = Details.unused_instances [next_id]
				Details.tabela_instancias [next_id] = new_instance
				Details.unused_instances [next_id] = nil
				new_instance:AtivarInstancia()
				return new_instance
			end

			local new_instance = Details:CreateNewInstance (next_id)

			if (Details.standard_skin) then
				for key, value in pairs(Details.standard_skin) do
					if (type(value) == "table") then
						new_instance [key] = Details.CopyTable(value)
					else
						new_instance [key] = value
					end
				end
				new_instance:ChangeSkin()

			else
				--se n�o tiver um padr�o, criar de outra inst�ncia j� aberta.
				local copy_from
				for i = 1, next_id-1 do
					local opened_instance = Details:GetInstance(i)
					if (opened_instance and opened_instance:IsEnabled() and opened_instance.baseframe) then
						copy_from = opened_instance
						break
					end
				end

				if (copy_from) then
					for key, value in pairs(copy_from) do
						if (Details.instance_defaults [key] ~= nil) then
							if (type(value) == "table") then
								new_instance [key] = Details.CopyTable(value)
							else
								new_instance [key] = value
							end
						end
					end
					new_instance:ChangeSkin()
				end
			end

			return new_instance

		elseif (id) then
			local instancia = Details.tabela_instancias [id]
			if (instancia and not instancia:IsAtiva()) then
				instancia:AtivarInstancia()
				Details:DelayOptionsRefresh (instancia)
				return instancia
			end
		end

		--antes de criar uma nova, ver se n�o h� alguma para reativar
		for index, instancia in ipairs(Details.tabela_instancias) do
			if (not instancia:IsAtiva()) then
				instancia:AtivarInstancia()
				return instancia
			end
		end

		if (#Details.tabela_instancias >= Details.instances_amount) then
			return Details:Msg(Loc ["STRING_INSTANCE_LIMIT"])
		end

		--verifica se n�o tem uma janela na pool de janelas fechadas
		local next_id = #Details.tabela_instancias+1

		if (Details.unused_instances [next_id]) then
			local new_instance = Details.unused_instances [next_id]
			Details.tabela_instancias [next_id] = new_instance
			Details.unused_instances [next_id] = nil
			new_instance:AtivarInstancia()

			Details:GetLowerInstanceNumber()

			return new_instance
		end

		--cria uma nova janela
		local new_instance = Details:CreateNewInstance (#Details.tabela_instancias+1)

		if (not Details.initializing) then
			Details:SendEvent("DETAILS_INSTANCE_OPEN", nil, new_instance)
		end

		Details:GetLowerInstanceNumber()

		return new_instance
	end
------------------------------------------------------------------------------------------------------------------------

--self � a inst�ncia que esta sendo movida.. instancia � a que esta parada
function Details:EstaAgrupada(esta_instancia, lado) --lado //// 1 = encostou na esquerda // 2 = escostou emaixo // 3 = encostou na direita // 4 = encostou em cima
	--local meu_snap = self.snap --pegou a tabela com {side, side, side, side}

	if (esta_instancia.snap [lado]) then
		return true --ha possui uma janela grudapa neste lado
	elseif (lado == 1) then
		if (self.snap [3]) then
			return true
		end
	elseif (lado == 2) then
		if (self.snap [4]) then
			return true
		end
	elseif (lado == 3) then
		if (self.snap [1]) then
			return true
		end
	elseif (lado == 4) then
		if (self.snap [2]) then
			return true
		end
	end

	return false --do contr�rio retorna false
end

function Details:BaseFrameSnap()
	local group = self:GetInstanceGroup()

	for meu_id, instancia in ipairs(group) do
		if (instancia:IsAtiva()) then
			instancia.baseframe:ClearAllPoints()
		end
	end

	local scale = self.window_scale
	for _, instance in ipairs(group) do
		instance:SetWindowScale (scale)
	end

	local my_baseframe = self.baseframe
	for lado, snap_to in pairs(self.snap) do
		local instancia_alvo = Details.tabela_instancias [snap_to]

		if (instancia_alvo) then
			if (instancia_alvo.ativa and instancia_alvo.baseframe) then
				if (lado == 1) then --a esquerda
					instancia_alvo.baseframe:SetPoint("TOPRIGHT", my_baseframe, "TOPLEFT", -Details.grouping_horizontal_gap, 0)

				elseif (lado == 2) then --em baixo
					local statusbar_y_mod = 0
					if (not self.show_statusbar) then
						statusbar_y_mod = 14
					end
					instancia_alvo.baseframe:SetPoint("TOPLEFT", my_baseframe, "BOTTOMLEFT", 0, -34 + statusbar_y_mod)

				elseif (lado == 3) then --a direita
					instancia_alvo.baseframe:SetPoint("BOTTOMLEFT", my_baseframe, "BOTTOMRIGHT", Details.grouping_horizontal_gap, 0)

				elseif (lado == 4) then --em cima
					local statusbar_y_mod = 0
					if (not instancia_alvo.show_statusbar) then
						statusbar_y_mod = -14
					end
					instancia_alvo.baseframe:SetPoint("BOTTOMLEFT", my_baseframe, "TOPLEFT", 0, 34 + statusbar_y_mod)

				end
			end
		end
	end

	--[
	--aqui precisa de um efeito reverso
	local reverso = self.meu_id - 2 --se existir
	if (reverso > 0) then --se tiver uma inst�ncia l� tr�s
		--aqui faz o efeito reverso:
		local inicio_retro = self.meu_id - 1
		for meu_id = inicio_retro, 1, -1 do
			local instancia = Details.tabela_instancias [meu_id]
			for lado, snap_to in pairs(instancia.snap) do
				if (snap_to < instancia.meu_id and snap_to ~= self.meu_id) then --se o lado que esta grudado for menor que o meu id... EX instnacia #2 grudada na #1

					--ent�o tenho que pegar a inst�ncia do snap

					local instancia_alvo = Details.tabela_instancias [snap_to]
					local lado_reverso
					if (lado == 1) then
						lado_reverso = 3
					elseif (lado == 2) then
						lado_reverso = 4
					elseif (lado == 3) then
						lado_reverso = 1
					elseif (lado == 4) then
						lado_reverso = 2
					end

					--fazer os setpoints
					if (instancia_alvo.ativa and instancia_alvo.baseframe) then

						if (lado_reverso == 1) then --a esquerda
							instancia_alvo.baseframe:SetPoint("BOTTOMLEFT", instancia.baseframe, "BOTTOMRIGHT", Details.grouping_horizontal_gap, 0)

						elseif (lado_reverso == 2) then --em baixo

							local statusbar_y_mod = 0
							if (not instancia_alvo.show_statusbar) then
								statusbar_y_mod = -14
							end

							instancia_alvo.baseframe:SetPoint("BOTTOMLEFT", instancia.baseframe, "TOPLEFT", 0, 34 + statusbar_y_mod) -- + (statusbar_y_mod*-1)

						elseif (lado_reverso == 3) then --a direita
							instancia_alvo.baseframe:SetPoint("TOPRIGHT", instancia.baseframe, "TOPLEFT", -Details.grouping_horizontal_gap, 0)

						elseif (lado_reverso == 4) then --em cima

							local statusbar_y_mod = 0
							if (not instancia.show_statusbar) then
								statusbar_y_mod = 14
							end

							instancia_alvo.baseframe:SetPoint("TOPLEFT", instancia.baseframe, "BOTTOMLEFT", 0, -34 + statusbar_y_mod)

						end
					end
				end
			end
		end
	end
	--]]

	for meu_id, instancia in ipairs(Details.tabela_instancias) do
		if (meu_id > self.meu_id) then
			for lado, snap_to in pairs(instancia.snap) do
				if (snap_to > instancia.meu_id and snap_to ~= self.meu_id) then
					local instancia_alvo = Details.tabela_instancias [snap_to]

					if (instancia_alvo.ativa and instancia_alvo.baseframe) then
						if (lado == 1) then --a esquerda
							instancia_alvo.baseframe:SetPoint("TOPRIGHT", instancia.baseframe, "TOPLEFT", -Details.grouping_horizontal_gap, 0)

						elseif (lado == 2) then --em baixo
							local statusbar_y_mod = 0
							if (not instancia.show_statusbar) then
								statusbar_y_mod = 14
							end
							instancia_alvo.baseframe:SetPoint("TOPLEFT", instancia.baseframe, "BOTTOMLEFT", 0, -34 + statusbar_y_mod)

						elseif (lado == 3) then --a direita
							instancia_alvo.baseframe:SetPoint("BOTTOMLEFT", instancia.baseframe, "BOTTOMRIGHT", Details.grouping_horizontal_gap, 0)

						elseif (lado == 4) then --em cima

							local statusbar_y_mod = 0
							if (not instancia_alvo.show_statusbar) then
								statusbar_y_mod = -14
							end

							instancia_alvo.baseframe:SetPoint("BOTTOMLEFT", instancia.baseframe, "TOPLEFT", 0, 34 + statusbar_y_mod)

						end
					end
				end
			end
		end
	end
end

function Details:agrupar_janelas(lados)

	local instancia = self

	for lado, esta_instancia in pairs(lados) do
		if (esta_instancia) then
			instancia.baseframe:ClearAllPoints()
			esta_instancia = Details.tabela_instancias [esta_instancia]

			instancia:SetWindowScale (esta_instancia.window_scale)

			if (lado == 3) then --direita
				--mover frame
				instancia.baseframe:SetPoint("TOPRIGHT", esta_instancia.baseframe, "TOPLEFT", -Details.grouping_horizontal_gap, 0)
				instancia.baseframe:SetPoint("RIGHT", esta_instancia.baseframe, "LEFT", -Details.grouping_horizontal_gap, 0)
				instancia.baseframe:SetPoint("BOTTOMRIGHT", esta_instancia.baseframe, "BOTTOMLEFT", -Details.grouping_horizontal_gap, 0)

				local _, height = esta_instancia:GetSize()
				instancia:SetSize(nil, height)

				--salva o snap
				self.snap [3] = esta_instancia.meu_id
				esta_instancia.snap [1] = self.meu_id

			elseif (lado == 4) then --cima
				--mover frame

				local statusbar_y_mod = 0
				if (not esta_instancia.show_statusbar) then
					statusbar_y_mod = 14
				end

				instancia.baseframe:SetPoint("TOPLEFT", esta_instancia.baseframe, "BOTTOMLEFT", 0, -34 + statusbar_y_mod)
				instancia.baseframe:SetPoint("TOP", esta_instancia.baseframe, "BOTTOM", 0, -34 + statusbar_y_mod)
				instancia.baseframe:SetPoint("TOPRIGHT", esta_instancia.baseframe, "BOTTOMRIGHT", 0, -34 + statusbar_y_mod)

				local _, height = esta_instancia:GetSize()
				instancia:SetSize(nil, height)

				--salva o snap
				self.snap [4] = esta_instancia.meu_id
				esta_instancia.snap [2] = self.meu_id

			elseif (lado == 1) then --esquerda
				--mover frame

				instancia.baseframe:SetPoint("TOPLEFT", esta_instancia.baseframe, "TOPRIGHT", Details.grouping_horizontal_gap, 0)
				instancia.baseframe:SetPoint("LEFT", esta_instancia.baseframe, "RIGHT", Details.grouping_horizontal_gap, 0)
				instancia.baseframe:SetPoint("BOTTOMLEFT", esta_instancia.baseframe, "BOTTOMRIGHT", Details.grouping_horizontal_gap, 0)

				local _, height = esta_instancia:GetSize()
				instancia:SetSize(nil, height)

				--salva o snap
				self.snap [1] = esta_instancia.meu_id
				esta_instancia.snap [3] = self.meu_id

			elseif (lado == 2) then --baixo
				--mover frame

				local statusbar_y_mod = 0
				if (not instancia.show_statusbar) then
					statusbar_y_mod = -14
				end

				instancia.baseframe:SetPoint("BOTTOMLEFT", esta_instancia.baseframe, "TOPLEFT", 0, 34 + statusbar_y_mod)
				instancia.baseframe:SetPoint("BOTTOM", esta_instancia.baseframe, "TOP", 0, 34 + statusbar_y_mod)
				instancia.baseframe:SetPoint("BOTTOMRIGHT", esta_instancia.baseframe, "TOPRIGHT", 0, 34 + statusbar_y_mod)

				local _, height = esta_instancia:GetSize()
				instancia:SetSize(nil, height)

				--salva o snap
				self.snap [2] = esta_instancia.meu_id
				esta_instancia.snap [4] = self.meu_id

			end

			if (not esta_instancia.ativa) then
				esta_instancia:AtivarInstancia()
			end

		end
	end

	if (not Details.disable_lock_ungroup_buttons) then
		instancia.break_snap_button:SetAlpha(1)
	end

	if (Details.tutorial.unlock_button < 4) then

		Details.temp_table1.IconSize = 32
		Details.temp_table1.TextHeightMod = -6
		Details.popup:ShowMe(instancia.break_snap_button, "tooltip", "Interface\\Buttons\\LockButton-Unlocked-Up", Loc ["STRING_UNLOCK"], 150, Details.temp_table1)

		--UIFrameFlash (instancia.break_snap_button, .5, .5, 5, false, 0, 0)
		Details.tutorial.unlock_button = Details.tutorial.unlock_button + 1
	end

	Details:DelayOptionsRefresh()

end

Details.MakeInstanceGroup = Details.agrupar_janelas

function Details:UngroupInstance()
	return self:Desagrupar(-1)
end

function Details:Desagrupar (instancia, lado, lado2)
	if (lado2 == -1) then
		instancia = lado
		self = instancia
		lado = lado2
	end

	if (self.meu_id and not lado2) then --significa que self � uma instancia
		lado = instancia
		instancia = self
	end

	if (type(instancia) == "number") then --significa que passou o n�mero da inst�ncia
		instancia =  Details.tabela_instancias [instancia]
	end

	Details:DelayOptionsRefresh (nil, true)

	if (not lado) then
		return
	end

	if (lado < 0) then --clicou no bot�o para desagrupar tudo
		local ID = instancia.meu_id

		for id, esta_instancia in ipairs(Details.tabela_instancias) do
			for index, iid in pairs(esta_instancia.snap) do -- index = 1 left , 3 right, 2 bottom, 4 top
				if (iid and (iid == ID or id == ID)) then -- iid = instancia.meu_id

					esta_instancia.snap [index] = nil

					if (instancia.verticalSnap or esta_instancia.verticalSnap) then
						if (not esta_instancia.snap [2] and not esta_instancia.snap [4]) then
							esta_instancia.verticalSnap = false
							esta_instancia.horizontalSnap = false
						end
					elseif (instancia.horizontalSnap or esta_instancia.horizontalSnap) then
						if (not esta_instancia.snap [1] and not esta_instancia.snap [3]) then
							esta_instancia.horizontalSnap = false
							esta_instancia.verticalSnap = false
						end
					end

					if (index == 2) then  -- index � o codigo do snap
						--esta_instancia.baseframe.rodape.StatusBarLeftAnchor:SetPoint("left", esta_instancia.baseframe.rodape.top_bg, "left", 5, 58)
						--esta_instancia.baseframe.rodape.StatusBarCenterAnchor:SetPoint("center", esta_instancia.baseframe.rodape.top_bg, "center", 0, 58)
						--esta_instancia.baseframe.rodape.esquerdo:SetTexture("Interface\\AddOns\\Details\\images\\bar_down_left")
						--esta_instancia.baseframe.rodape.esquerdo.have_snap = nil
					end

				end
			end
		end

		instancia.break_snap_button:SetAlpha(0)

		instancia.verticalSnap = false
		instancia.horizontalSnap = false
		return
	end

	local esta_instancia = Details.tabela_instancias [instancia.snap[lado]]

	if (not esta_instancia) then
		return
	end

	instancia.snap [lado] = nil

	if (lado == 1) then
		esta_instancia.snap [3] = nil
	elseif (lado == 2) then
		esta_instancia.snap [4] = nil
	elseif (lado == 3) then
		esta_instancia.snap [1] = nil
	elseif (lado == 4) then
		esta_instancia.snap [2] = nil
	end

	instancia.break_snap_button:SetAlpha(0)


	if (instancia.iniciada) then
		instancia:SaveMainWindowPosition()
		instancia:RestoreMainWindowPosition()
	end

	if (esta_instancia.iniciada) then
		esta_instancia:SaveMainWindowPosition()
		esta_instancia:RestoreMainWindowPosition()
	end
end

function Details:SnapTextures (remove)
	for id, esta_instancia in ipairs(Details.tabela_instancias) do
		if (esta_instancia:IsAtiva()) then
			if (esta_instancia.baseframe.rodape.esquerdo.have_snap) then
				if (remove) then
					--esta_instancia.baseframe.rodape.esquerdo:SetTexture("Interface\\AddOns\\Details\\images\\bar_down_left")
				else
					--esta_instancia.baseframe.rodape.esquerdo:SetTexture("Interface\\AddOns\\Details\\images\\bar_down_left_snap")
				end
			end
		end
	end
end

--cria uma janela para uma nova inst�ncia
	--search key: ~new ~nova
	function Details:CreateDisabledInstance(ID, skin_table)
	--first check if we can recycle a old instance
	if (Details.unused_instances [ID]) then
		local new_instance = Details.unused_instances [ID]
		Details.tabela_instancias [ID] = new_instance
		Details.unused_instances [ID] = nil
		--replace the values on recycled instance
			new_instance:ResetInstanceConfig()

		--copy values from a previous skin saved
			if (skin_table) then
				--copy from skin_table to new_instance
				Details.table.copy(new_instance, skin_table)
			end

		return new_instance
	end

	--must create a new one
		local new_instance = {
			--instance id
				meu_id = ID,
			--internal stuff
				barras = {}, --container que ir� armazenar todas as barras
				barraS = {nil, nil}, --de x at� x s�o as barras que est�o sendo mostradas na tela
				rolagem = false, --barra de rolagem n�o esta sendo mostrada
				largura_scroll = 26,
				bar_mod = 0,
				bgdisplay_loc = 0,

			--displaying row info
				rows_created = 0,
				rows_showing = 0,
				rows_max = 50,

			--saved pos for normal mode and lone wolf mode
				posicao = {
					["normal"] = {x = 1, y = 2, w = 300, h = 200},
					["solo"] = {x = 1, y = 2, w = 300, h = 200}
				},

			--save information about window snaps
				snap = {},

			--current state starts as normal
				mostrando = "normal",
			--menu consolidated
				consolidate = false, --deprecated
				icons = {true, true, true, true},

			--status bar stuff
				StatusBar = {options = {}},

			--more stuff
				atributo = 1, --dano
				sub_atributo = 1, --damage done
				sub_atributo_last = {1, 1, 1, 1, 1},
				segmento = 0, --combate atual
				modo = modo_grupo,
				last_modo = modo_grupo,
				LastModo = modo_grupo,
		}

		DetailsFramework:Mixin(new_instance, instanceMixins)

		setmetatable(new_instance, Details)
		Details.tabela_instancias[#Details.tabela_instancias+1] = new_instance

		--fill the empty instance with default values
		new_instance:ResetInstanceConfig()

		--copy values from a previous skin saved
		if (skin_table) then
			--copy from skin_table to new_instance
			Details.table.copy(new_instance, skin_table)
		end

		--setup default wallpaper
		new_instance.wallpaper.texture = "Interface\\AddOns\\Details\\images\\background"

		--finish
		return new_instance
	end

	---create a new instance of a Details! window in the user interface
	---@param instanceId instanceid
	---@return instance
	function Details:CreateNewInstance(instanceId)
		local newInstance = {}
		setmetatable(newInstance, Details)
		Details.tabela_instancias[#Details.tabela_instancias+1] = newInstance

		DetailsFramework:Mixin(newInstance, instanceMixins)

		--instance id
		newInstance.meu_id = instanceId

		--setup all config
		newInstance:ResetInstanceConfig()
		--setup default wallpaper
		newInstance.wallpaper.texture = "Interface\\AddOns\\Details\\images\\background"

		--internal stuff
		newInstance.barras = {} --store the bars which shows data to the user
		newInstance.barraS = {nil, nil} --range of bars showing on the window
		newInstance.rolagem = false --scroll is shown?
		newInstance.largura_scroll = 26
		newInstance.bar_mod = 0
		newInstance.bgdisplay_loc = 0
		newInstance.cached_bar_width = 0

		--displaying row info
		newInstance.rows_created = 0
		newInstance.rows_showing = 0
		newInstance.rows_max = 50
		newInstance.rows_fit_in_window = nil

		--saved pos for normal mode and lone wolf mode
		newInstance.posicao = {
			["normal"] = {x = 1, y = 2, w = 300, h = 200},
			["solo"] = {x = 1, y = 2, w = 300, h = 200}
		}

		--save information about window snaps
		newInstance.snap = {}

		--current state starts as normal
		newInstance.mostrando = "normal"

		--menu consolidated
		newInstance.consolidate = false
		newInstance.icons = {true, true, true, true}

		--create window frames
		local _baseframe, _bgframe, _bgframe_display, _scrollframe = gump:CriaJanelaPrincipal(instanceId, newInstance, true)
		newInstance.baseframe = _baseframe
		newInstance.bgframe = _bgframe
		newInstance.bgdisplay = _bgframe_display
		newInstance.scroll = _scrollframe

		--status bar stuff
		newInstance.StatusBar = {}
		newInstance.StatusBar.left = nil
		newInstance.StatusBar.center = nil
		newInstance.StatusBar.right = nil
		newInstance.StatusBar.options = {}

		--create some plugins in the statusbar
		local clock = Details.StatusBar:CreateStatusBarChildForInstance(newInstance, "DETAILS_STATUSBAR_PLUGIN_CLOCK")
		Details.StatusBar:SetCenterPlugin(newInstance, clock)

		local segment = Details.StatusBar:CreateStatusBarChildForInstance(newInstance, "DETAILS_STATUSBAR_PLUGIN_PSEGMENT")
		Details.StatusBar:SetLeftPlugin(newInstance, segment)

		local dps = Details.StatusBar:CreateStatusBarChildForInstance(newInstance, "DETAILS_STATUSBAR_PLUGIN_PDPS")
		Details.StatusBar:SetRightPlugin(newInstance, dps)

		--internal stuff
		newInstance.alturaAntiga = _baseframe:GetHeight()
		newInstance.atributo = 1 --dano
		newInstance.sub_atributo = 1 --damage done
		newInstance.sub_atributo_last = {1, 1, 1, 1, 1}
		newInstance.segmento = -1 --combate atual
		newInstance.modo = modo_grupo
		newInstance.last_modo = modo_grupo
		newInstance.LastModo = modo_grupo

		--change the attribute
		Details:TrocaTabela(newInstance, 0, 1, 1)

		--internal stuff
		newInstance.row_height = newInstance.row_info.height + newInstance.row_info.space.between
		newInstance.oldwith = newInstance.baseframe:GetWidth()
		newInstance.iniciada = true

		newInstance:SaveMainWindowPosition()
		newInstance:ReajustaGump()

		newInstance.rows_fit_in_window = _math_floor(newInstance.posicao[newInstance.mostrando].h / newInstance.row_height)

		--all done
		newInstance:AtivarInstancia()
		newInstance:ShowSideBars()

		newInstance.skin = "no skin"
		newInstance:ChangeSkin(Details.default_skin_to_use)

		return newInstance
	end

------------------------------------------------------------------------------------------------------------------------


--ao reiniciar o addon esta fun��o � rodada para recriar a janela da inst�ncia
--search key: ~restaura ~inicio ~start

function Details:RestoreWindow(index, temp, loadOnly)
	self:RestauraJanela (index, temp, loadOnly)
end

function Details:RestauraJanela(index, temp, load_only)

	DetailsFramework:Mixin(self, instanceMixins)

	--load
		self:LoadInstanceConfig()

	--reset internal stuff
		self.sub_atributo_last = self.sub_atributo_last or {1, 1, 1, 1, 1}
		self.rolagem = false
		self.need_rolagem = false
		self.barras = {}
		self.barraS = {nil, nil}
		self.rows_fit_in_window = nil
		self.consolidate = self.consolidate or false
		self.icons = self.icons or {true, true, true, true}
		self.rows_created = 0
		self.rows_showing = 0
		self.rows_max = 50
		self.largura_scroll = 26
		self.bar_mod = 0
		self.bgdisplay_loc = 0
		self.last_modo = self.last_modo or modo_grupo
		self.cached_bar_width = self.cached_bar_width or 0
		self.row_height = self.row_info.height + self.row_info.space.between
		self.rows_fit_in_window = _math_floor(self.posicao[self.mostrando].h / self.row_height)

	--create frames
		local isLocked = self.isLocked
		local _baseframe, _bgframe, _bgframe_display, _scrollframe = gump:CriaJanelaPrincipal (self.meu_id, self)
		self.baseframe = _baseframe
		self.bgframe = _bgframe
		self.bgdisplay = _bgframe_display
		self.scroll = _scrollframe
		_baseframe:EnableMouseWheel(false)
		self.alturaAntiga = _baseframe:GetHeight()

		--self.isLocked = isLocked --window isn't locked when just created it

	--change the attribute
		Details:TrocaTabela(self, self.segmento, self.atributo, self.sub_atributo, true) --passando true no 5� valor para a fun��o ignorar a checagem de valores iguais

	--set wallpaper
		if (self.wallpaper.enabled) then
			self:InstanceWallpaper (true)
		end

	--set the color of this instance window
		self:InstanceColor (self.color)

	--scrollbar
		self:EsconderScrollBar (true)

	--check snaps
		self.snap = self.snap or {}

	--status bar stuff
		self.StatusBar = {}
		self.StatusBar.left = nil
		self.StatusBar.center = nil
		self.StatusBar.right = nil
		self.StatusBarSaved = self.StatusBarSaved or {options = {}}
		self.StatusBar.options = self.StatusBarSaved.options

		if (self.StatusBarSaved.left and self.StatusBarSaved.left == "NONE") then
			self.StatusBarSaved.left = "DETAILS_STATUSBAR_PLUGIN_PSEGMENT"
		end
		local segment = Details.StatusBar:CreateStatusBarChildForInstance (self, self.StatusBarSaved.left or "DETAILS_STATUSBAR_PLUGIN_PSEGMENT")
		Details.StatusBar:SetLeftPlugin (self, segment, true)


		if (self.StatusBarSaved.center and self.StatusBarSaved.center == "NONE") then
			self.StatusBarSaved.center = "DETAILS_STATUSBAR_PLUGIN_CLOCK"
		end
		local clock = Details.StatusBar:CreateStatusBarChildForInstance (self, self.StatusBarSaved.center or "DETAILS_STATUSBAR_PLUGIN_CLOCK")
		Details.StatusBar:SetCenterPlugin (self, clock, true)


		if (self.StatusBarSaved.right and self.StatusBarSaved.right == "NONE") then
			self.StatusBarSaved.right = "DETAILS_STATUSBAR_PLUGIN_PDURABILITY"
		end
		local durability = Details.StatusBar:CreateStatusBarChildForInstance (self, self.StatusBarSaved.right or "DETAILS_STATUSBAR_PLUGIN_PDURABILITY")
		Details.StatusBar:SetRightPlugin (self, durability, true)


	--load mode

		if (self.modo == modo_alone) then
			if (Details.solo and Details.solo ~= self.meu_id) then --prote��o para ter apenas uma inst�ncia com a janela SOLO
				self.modo = modo_grupo
				self.mostrando = "normal"
			else
				self:SoloMode (true)
				Details.solo = self.meu_id
			end
		elseif (self.modo == modo_raid) then
			Details.raid = self.meu_id
		else
			self.mostrando = "normal"
		end

	--internal stuff
		self.oldwith = self.baseframe:GetWidth()

		self:RestoreMainWindowPosition()
		self:ReajustaGump()
		--self:SaveMainWindowPosition()
	
		--fix for the weird white window default skin
		--this is a auto detect for configuration corruption, happens usually when the user install Details! over old config settings
		--check if the skin used in the window is the default skin, check if statusbar is in use and if the color of the window is full white
		if (self.skin == Details.default_skin_to_use and self.show_statusbar) then
			if(self.color[1] == 1 and self.color[2] == 1 and self.color[3] == 1 and self.color[4] == 1) then
				Details:Msg("error 0xFF85DD")
				self.skin = "no skin"
				self:ChangeSkin(Details.default_skin_to_use)
			end
		end	
	
		if (not load_only) then
			self.iniciada = true
			self:AtivarInstancia (temp)
			self:ChangeSkin()
		end

	--all done
	return
end

function Details:SwitchBack()
	local previousSwitch = self.auto_switch_to_old

	if (previousSwitch) then
		if (self.modo ~= previousSwitch[1]) then
			self:SetMode(previousSwitch[1])
		end

		if (self.modo == Details._detalhes_props["MODO_RAID"]) then
			Details.RaidTables:switch(nil, previousSwitch [5], self)

		elseif (self.modo == Details._detalhes_props["MODO_ALONE"]) then
			Details.SoloTables:switch(nil, previousSwitch [6])

		else
			Details:TrocaTabela(self, previousSwitch [4], previousSwitch [2], previousSwitch [3])
		end

		self.auto_switch_to_old = nil
	end
end

function Details:SwitchTo (switch_table, nosave)
	if (not nosave) then
		self.auto_switch_to_old = {self.modo, self.atributo, self.sub_atributo, self.segmento, self:GetRaidPluginName(), Details.SoloTables.Mode}
	end

	if (switch_table [1] == "raid") then
		local plugin_global_name, can_switch = switch_table[2], true

		--plugin global name
		for _, instance in ipairs(Details.tabela_instancias) do
			if (instance ~= self and instance:IsEnabled() and instance.baseframe and instance.modo == modo_raid) then
				if (instance.current_raid_plugin == plugin_global_name) then
					can_switch = false
					break
				end
			end
		end

		if (can_switch) then
			Details.RaidTables:EnableRaidMode (self, switch_table [2])
		else
			local plugin = Details:GetPlugin (plugin_global_name)
			Details:Msg("Auto Switch: a window is already showing " .. (plugin.__name or "" .. ", please review your switch config."))
		end
	else
		--muda para um atributo normal
		if (self.modo ~= Details._detalhes_props["MODO_GROUP"]) then
			self:SetMode(Details._detalhes_props["MODO_GROUP"])
		end
		Details:TrocaTabela(self, nil, switch_table [1], switch_table [2])
	end
end

--backtable indexes: [1]: mode [2]: attribute [3]: sub attribute [4]: segment [5]: raidmode index [6]: solomode index
function Details:CheckSwitchOnCombatEnd (nowipe, warning)

	local old_attribute, old_sub_atribute = self:GetDisplay()

	self:SwitchBack()

	local role = _UnitGroupRolesAssigned("player")

	local got_switch = false

	if (role == "DAMAGER" and self.switch_damager) then
		self:SwitchTo (self.switch_damager, true)
		got_switch = true

	elseif (role == "HEALER" and self.switch_healer) then
		self:SwitchTo (self.switch_healer, true)
		got_switch = true

	elseif (role == "TANK" and self.switch_tank) then
		self:SwitchTo (self.switch_tank, true)
		got_switch = true

	elseif (role == "NONE" and Details.last_assigned_role ~= "NONE") then
		self:SwitchBack()
		got_switch = true

	end

	if (warning and got_switch) then
		local current_attribute, current_sub_atribute = self:GetDisplay()
		if (current_attribute ~= old_attribute or current_sub_atribute ~= old_sub_atribute) then
			local attribute_name = self:GetInstanceAttributeText()
			self:InstanceAlert (string.format(Loc ["STRING_SWITCH_WARNING"], attribute_name), {[[Interface\CHARACTERFRAME\UI-StateIcon]], 18, 18, false, 0.5, 1, 0, 0.5}, 4)
		end
	end

	if (self.switch_all_roles_after_wipe and not nowipe) then
		if (Details.tabela_vigente.is_boss and Details.tabela_vigente.instance_type == "raid" and not Details.tabela_vigente.is_boss.killed and Details.tabela_vigente.is_boss.name) then
			self:SwitchBack()
			self:SwitchTo (self.switch_all_roles_after_wipe)
		end
	end

end

function Details:CheckSwitchOnLogon (warning)
	for index, instancia in ipairs(Details.tabela_instancias) do
		if (instancia.ativa) then
			instancia:CheckSwitchOnCombatEnd (true, warning)
		end
	end
end

function Details:CheckSegmentForSwitchOnCombatStart()

end

function Details:CheckSwitchOnCombatStart (check_segment)

	self:SwitchBack()

	local all_roles = self.switch_all_roles_in_combat

	local role = _UnitGroupRolesAssigned("player")
	local got_switch = false

	if (role == "DAMAGER" and self.switch_damager_in_combat) then
		self:SwitchTo (self.switch_damager_in_combat)
		got_switch = true

	elseif (role == "HEALER" and self.switch_healer_in_combat) then
		self:SwitchTo (self.switch_healer_in_combat)
		got_switch = true

	elseif (role == "TANK" and self.switch_tank_in_combat) then
		self:SwitchTo (self.switch_tank_in_combat)
		got_switch = true

	elseif (self.switch_all_roles_in_combat) then
		self:SwitchTo (self.switch_all_roles_in_combat)
		got_switch = true

	end

	if (check_segment and got_switch) then
		if (self:GetSegment() ~= 0) then
			self:TrocaTabela(0)
		end
	end

end

local createStatusbarOptions = function(optionsTable)
	local newTable = {}
	newTable.textColor = optionsTable.textColor
	newTable.textSize = optionsTable.textSize
	newTable.textFace = optionsTable.textFace
	newTable.textXMod = optionsTable.textXMod
	newTable.textYMod = optionsTable.textYMod
	newTable.isHidden = optionsTable.isHidden
	newTable.segmentType = optionsTable.segmentType
	newTable.textAlign = optionsTable.textAlign
	newTable.timeType = optionsTable.timeType
	newTable.textStyle = optionsTable.textStyle

	return newTable
end

function Details:ExportSkin()

	--create the table
	local exported = {
		version = Details.preset_version --skin version
	}

	--export the keys
	for key, value in pairs(self) do
		if (Details.instance_defaults [key] ~= nil) then
			if (type(value) == "table") then
				exported [key] = Details.CopyTable(value)
			else
				exported [key] = value
			end
		end
	end

	--export size and positioning
	if (Details.profile_save_pos) then
		exported.posicao = self.posicao
	else
		exported.posicao = nil
	end

	--export mini displays
	if (self.StatusBar and self.StatusBar.left) then
		exported.StatusBarSaved = {
			["left"] = self.StatusBar.left.real_name or "NONE",
			["center"] = self.StatusBar.center.real_name or "NONE",
			["right"] = self.StatusBar.right.real_name or "NONE",
		}

		local leftOptions = createStatusbarOptions(self.StatusBar.left.options)
		local centerOptions = createStatusbarOptions(self.StatusBar.center.options)
		local rightOptions = createStatusbarOptions(self.StatusBar.right.options)

		exported.StatusBarSaved.options = {
			[exported.StatusBarSaved.left] = leftOptions,
			[exported.StatusBarSaved.center] = centerOptions,
			[exported.StatusBarSaved.right] = rightOptions,
		}

	elseif (self.StatusBarSaved) then
		local leftName = self.StatusBarSaved.left
		local centerName = self.StatusBarSaved.center
		local rightName = self.StatusBarSaved.right

		local options = self.StatusBarSaved.options

		local leftOptions = createStatusbarOptions(options[leftName])
		local centerOptions = createStatusbarOptions(options[centerName])
		local rightOptions = createStatusbarOptions(options[rightName])

		options[leftName] = leftOptions
		options[centerName] = centerOptions
		options[rightName] = rightOptions

		exported.StatusBarSaved = DetailsFramework.table.copy({}, self.StatusBarSaved)
	end
	return exported
end

function Details:ApplySavedSkin (style)

	if (not style.version or Details.preset_version > style.version) then
		return Details:Msg(Loc ["STRING_OPTIONS_PRESETTOOLD"])
	end

	--set skin preset
	local skin = style.skin
	self.skin = ""
	self:ChangeSkin (skin)

	--overwrite all instance parameters with saved ones
	for key, value in pairs(style) do
		if (key ~= "skin") then
			if (type(value) == "table") then
				self [key] = Details.CopyTable(value)
			else
				self [key] = value
			end
		end
	end

	--check for new keys inside tables
	for key, value in pairs(Details.instance_defaults) do
		if (type(value) == "table") then
			for key2, value2 in pairs(value) do
				if (self [key] [key2] == nil) then
					if (type(value2) == "table") then
						self [key] [key2] = Details.CopyTable(Details.instance_defaults [key] [key2])
					else
						self [key] [key2] = value2
					end
				end
			end
		end
	end

	self.StatusBarSaved = style.StatusBarSaved and Details.CopyTable(style.StatusBarSaved) or {options = {}}
	self.StatusBar.options = self.StatusBarSaved.options
	Details.StatusBar:UpdateChilds (self)

	--apply all changed attributes
	self:ChangeSkin()

	--export size and positioning
	if (Details.profile_save_pos) then
		self.posicao = style.posicao
		self:RestoreMainWindowPosition()
	else
		self.posicao = Details.CopyTable(self.posicao)
	end

end

------------------------------------------------------------------------------------------------------------------------

function Details:InstanceReset(instance)
	if (instance) then
		self = instance
	end

	Details.FadeHandler.Fader(self, "in", nil, "barras")
	self:UpdateCombatObjectInUse(self)
	self:AtualizaSoloMode_AfertReset()
	self:ResetaGump()

	if (not Details.initializing) then
		Details:RefreshMainWindow(self, true) --atualiza todas as instancias
	end
end

function Details:RefreshBars(instance)
	if (instance) then
		self = instance
	end
	self:InstanceRefreshRows(instance)
end

function Details:SetBackgroundColor(...)
	local red = select(1, ...)
	if (not red) then
		self.bgdisplay:SetBackdropColor(self.bg_r, self.bg_g, self.bg_b, self.bg_alpha)
		self.baseframe:SetBackdropColor(self.bg_r, self.bg_g, self.bg_b, self.bg_alpha)
		return
	end

	local r, g, b = gump:ParseColors(...)
	self.bgdisplay:SetBackdropColor(r, g, b, self.bg_alpha or Details.default_bg_alpha)
	self.baseframe:SetBackdropColor(r, g, b, self.bg_alpha or Details.default_bg_alpha)
	self.bg_r = r
	self.bg_g = g
	self.bg_b = b
end

function Details:SetBackgroundAlpha (alpha)
	if (not alpha) then
		alpha = self.bg_alpha
	end

	self.bgdisplay:SetBackdropColor(self.bg_r, self.bg_g, self.bg_b, alpha)
	self.baseframe:SetBackdropColor(self.bg_r, self.bg_g, self.bg_b, alpha)
	self.bg_alpha = alpha
end

function Details:GetSize()
	return self.baseframe:GetWidth(), self.baseframe:GetHeight()
end

function Details:GetRealSize()
	return self.baseframe:GetWidth() * self.baseframe:GetScale(), self.baseframe:GetHeight() * self.baseframe:GetScale()
end

function Details:GetPositionOnScreen()
	local xOfs, yOfs = self.baseframe:GetCenter()
	if (not xOfs) then
		return
	end
	-- credits to ckknight (http://www.curseforge.com/profiles/ckknight/)
	local _scale = self.baseframe:GetEffectiveScale()
	local _UIscale = UIParent:GetScale()
	xOfs = xOfs*_scale - GetScreenWidth()*_UIscale/2
	yOfs = yOfs*_scale - GetScreenHeight()*_UIscale/2
	return xOfs/_UIscale, yOfs/_UIscale
end

--alias
function Details:SetSize(w, h)
	return self:Resize (w, h)
end

function Details:Resize (w, h)
	if (w) then
		self.baseframe:SetWidth(w)
	end

	if (h) then
		self.baseframe:SetHeight(h)
	end

	self:SaveMainWindowPosition()

	return true
end

--/run Details:GetWindow(1):ToggleMaxSize()
function Details:ToggleMaxSize()
	if (self.is_in_max_size) then
		self.is_in_max_size = false
		self:SetSize(self.original_width, self.original_height)
	else
		local original_width, original_height = self:GetSize()
		self.original_width, self.original_height = original_width, original_height
		self.is_in_max_size = true
		self:SetSize(original_width, 450)

	end
end

------------------------------------------------------------------------------------------------------------------------

function Details:PostponeSwitchToCurrent(instance)
	if (
		not instance.last_interaction or
		(
			(instance.ativa) and
			(instance.last_interaction+3 < Details._tempo) and
			(not DetailsReportWindow or not DetailsReportWindow:IsShown()) and
			(not Details.BreakdownWindowFrame:IsShown())
		)
	) then
		instance._postponing_switch = nil
		if (instance.segmento > 0 and instance.auto_current) then
			instance:TrocaTabela(0) --muda o segmento pra current
			instance:InstanceAlert(Loc ["STRING_CHANGED_TO_CURRENT"], {[[Interface\AddOns\Details\images\toolbar_icons]], 18, 18, false, 32/256, 64/256, 0, 1}, 6)
			return
		else
			return
		end
	end
	if (instance.is_interacting and instance.last_interaction < Details._tempo) then
		instance.last_interaction = Details._tempo
	end
	--instance._postponing_switch = Details:ScheduleTimer("PostponeSwitchToCurrent", 1, instance)
	instance._postponing_switch = Details.Schedules.NewTimer(1, Details.PostponeSwitchToCurrent, Details, instance)
end

function Details:CheckSwitchToCurrent()
	for _, instance in ipairs(Details.tabela_instancias) do
		if (instance.ativa and instance.auto_current and instance.baseframe and instance.segmento > 0) then
			if (instance.is_interacting and instance.last_interaction < Details._tempo) then
				instance.last_interaction = Details._tempo
			end

			if ((instance.last_interaction and (instance.last_interaction+3 > Details._tempo)) or (DetailsReportWindow and DetailsReportWindow:IsShown()) or (Details.BreakdownWindowFrame:IsShown())) then
				--postpone
				--instance._postponing_switch = Details:ScheduleTimer("PostponeSwitchToCurrent", 1, instance)
				instance._postponing_switch = Details.Schedules.NewTimer(1, Details.PostponeSwitchToCurrent, Details, instance)
			else
				instance:TrocaTabela(0) --muda o segmento pra current
				instance:InstanceAlert (Loc ["STRING_CHANGED_TO_CURRENT"], {[[Interface\AddOns\Details\images\toolbar_icons]], 18, 18, false, 32/256, 64/256, 0, 1}, 6)
				instance._postponing_switch = nil
			end
		end
	end
end

function Details:Freeze(instancia)
	if (not instancia) then
		instancia = self
	end

	if (not Details.initializing) then
		instancia:ResetaGump()
		Details.FadeHandler.Fader(instancia, "in", nil, "barras")
	end

	instancia:InstanceMsg(Loc ["STRING_FREEZE"], [[Interface\CHARACTERFRAME\Disconnect-Icon]], "silver")

	--instancia.freeze_icon:Show()
	--instancia.freeze_texto:Show()
	--local width = instancia:GetSize()
	--instancia.freeze_texto:SetWidth(width-64)

	instancia.freezed = true
end

function Details:UnFreeze(instancia)
	if (not instancia) then
		instancia = self
	end

	self:InstanceMsg(false)

	--instancia.freeze_icon:Hide()
	--instancia.freeze_texto:Hide()
	instancia.freezed = false

	if (not Details.initializing) then
		--instancia:RestoreMainWindowPosition()
		instancia:ReajustaGump()
	end
end

--handle internal details! events
local eventListener = Details:CreateEventListener()
eventListener:RegisterEvent("DETAILS_DATA_SEGMENTREMOVED", function()
	Details:InstanceCallDetailsFunc(Details.UpdateCombatObjectInUse)
end)

function Details:UpdateCombatObjectInUse(instance)
	if (instance.iniciada) then
		if (instance.segmento == -1) then
			instance.showing = Details.tabela_overall

		elseif (instance.segmento == 0) then
			instance.showing = Details:GetCurrentCombat()
		else
			local segmentsTable = Details:GetCombatSegments()
			local combatObject = segmentsTable[instance.segmento]
			instance.showing = combatObject
		end
	end
end

function Details:AtualizaSegmentos_AfterCombat(instancia)
	if (instancia.freezed) then
		return
	end

	local segmento = instancia.segmento

	---@type combat[]
	local segmentsTable = Details:GetCombatSegments()

	local _fadeType, _fadeSpeed = _unpack(Details.row_fade_in)

	--todo: translate comments here

	if (segmento == Details.segments_amount) then --significa que o index [5] passou a ser [6] com a entrada da nova tabela
		instancia.showing = segmentsTable[Details.segments_amount] --ent�o ele volta a pegar o index [5] que antes era o index [4]
		--print("==> Changing the Segment now! - classe_instancia.lua 1942")
		Details.FadeHandler.Fader(instancia, _fadeType, _fadeSpeed, "barras")
		instancia.showing[instancia.atributo].need_refresh = true
		instancia.v_barras = true
		instancia:ResetaGump()
		instancia:RefreshMainWindow(true)
		Details:AtualizarJanela (instancia)

	elseif (segmento < Details.segments_amount and segmento > 0) then
		instancia.showing = segmentsTable[segmento]
		--print("==> Changing the Segment now! - classe_instancia.lua 1952")

		Details.FadeHandler.Fader(instancia, _fadeType, _fadeSpeed, "barras") --"in", nil
		instancia.showing[instancia.atributo].need_refresh = true
		instancia.v_barras = true
		instancia:ResetaGump()
		instancia:RefreshMainWindow(true)
		Details:AtualizarJanela (instancia)
	end
end

---return if the attribute and sub attribute passed are in range of valid attributes
---@param attributeId attributeid
---@param subAttributeId attributeid
---@return boolean
function Details222.Instances.ValidateAttribute(attributeId, subAttributeId)
	if (attributeId == 1) then
		if (subAttributeId < 0 or subAttributeId > Details.atributos[1]) then
			return false
		end

	elseif (attributeId == 2) then
		if (subAttributeId < 0 or subAttributeId > Details.atributos[2]) then
			return false
		end

	elseif (attributeId == 3) then
		if (subAttributeId < 0 or subAttributeId > Details.atributos[3]) then
			return false
		end

	elseif (attributeId == 4) then
		if (subAttributeId < 0 or subAttributeId > Details.atributos[4]) then
			return false
		end

	elseif (attributeId == 5) then
		return true
	else
		return false
	end

	return true
end

function Details:SetDisplay(segment, attribute, subAttribute, isInstanceStarup, instanceMode)
	if (not self.meu_id) then
		return
	end
	return self:TrocaTabela(self, segment, attribute, subAttribute, isInstanceStarup, instanceMode)
end

---change the data shown in the window (marked as legacy on June 27 2023, soon will be deprecated for instance:SetSegment, instance:SetDisplay and instance:SetMode)
---@param instance instance
---@param segmentId number
---@param attributeId number
---@param subAttributeId number
---@param fromInstanceStart any
---@param instanceMode any
---@return unknown
function Details:TrocaTabela(instance, segmentId, attributeId, subAttributeId, fromInstanceStart, instanceMode)
	if (self and self.meu_id and not instance) then
		instanceMode = fromInstanceStart
		fromInstanceStart = subAttributeId
		subAttributeId = attributeId
		attributeId = segmentId
		segmentId = instance
		instance = self
	end

	if (fromInstanceStart == "LeftButton") then
		fromInstanceStart = nil
	end

	if (type(instance) == "number") then
		subAttributeId = attributeId
		attributeId = segmentId
		segmentId = instance
		instance = self
	end

	if (instanceMode and instanceMode ~= instance:GetMode()) then
		instance:SetMode(instanceMode)
	end

	local update_coolTip = false
	local sub_attribute_click = false

	if (type(segmentId) == "boolean" and segmentId) then --clicou em um sub atributo
		sub_attribute_click = true
		segmentId = instance.segmento

	elseif (segmentId == -2) then --clicou para mudar de segmento
		segmentId = instance.segmento + 1

		if (segmentId > Details.segments_amount) then
			segmentId = -1
		end
		update_coolTip = true

	elseif (segmentId == -3) then --clicou para mudar de atributo
		segmentId = instance.segmento

		attributeId = instance.atributo+1
		if (attributeId > atributos[0]) then
			attributeId = 1
		end
		update_coolTip = true

	elseif (segmentId == -4) then --clicou para mudar de sub atributo
		segmentId = instance.segmento

		subAttributeId = instance.sub_atributo+1
		if (subAttributeId > atributos[instance.atributo]) then
			subAttributeId = 1
		end
		update_coolTip = true
	end

	--pega os atributos desta instancia
	local current_segmento = instance.segmento
	local current_atributo = instance.atributo
	local current_sub_atributo = instance.sub_atributo

	local atributo_changed = false

	--verifica se os valores passados s�o v�lidos

	if (not segmentId) then
		segmentId = instance.segmento

	elseif (type(segmentId) ~= "number") then
		segmentId = instance.segmento
	end

	if (not attributeId) then
		attributeId  = instance.atributo

	elseif (type(attributeId) ~= "number") then
		attributeId = instance.atributo
	end

	if (not subAttributeId) then
		if (attributeId == current_atributo) then
			subAttributeId  = instance.sub_atributo
		else
			subAttributeId  = instance.sub_atributo_last [attributeId]
		end

	elseif (type(subAttributeId) ~= "number") then
		subAttributeId = instance.sub_atributo
	end

	--j� esta mostrando isso que esta pedindo
	if (not fromInstanceStart and segmentId == current_segmento and attributeId == current_atributo and subAttributeId == current_sub_atributo and not Details.initializing) then
		return false
	end

	if (not Details222.Instances.ValidateAttribute(attributeId, subAttributeId)) then
		subAttributeId = 1
		attributeId = 1
		Details:Msg("invalid attribute, switching to damage done.")
	end

	if (Details.auto_swap_to_dynamic_overall and Details.in_combat and UnitAffectingCombat("player")) then
		if (segmentId >= 0) then
			if (attributeId == 5) then
				local dynamicOverallDataCustomID = Details222.GetCustomDisplayIDByName(Loc["STRING_CUSTOM_DYNAMICOVERAL"])
				if (dynamicOverallDataCustomID == subAttributeId) then
					attributeId = 1
					subAttributeId = 1
				end
			end

		elseif (segmentId == -1) then
			if (attributeId == 1) then
				if (subAttributeId == 1) then
					local dynamicOverallDataCustomID = Details222.GetCustomDisplayIDByName(Loc["STRING_CUSTOM_DYNAMICOVERAL"])
					if (dynamicOverallDataCustomID) then
						attributeId = 5
						subAttributeId = dynamicOverallDataCustomID
					end
				end
			end
		end
	end

	--Muda o segmento caso necess�rio
	if (segmentId ~= current_segmento or Details.initializing or fromInstanceStart) then
		--na troca de segmento, conferir se a instancia esta frozen
		if (instance.freezed) then
			if (not fromInstanceStart) then
				instance:UnFreeze()
			else
				instance.freezed = false
			end
		end

		instance.segmento = segmentId

		---@type combat[]
		local segmentsTable = Details:GetCombatSegments()

		if (segmentId == -1) then --overall
			instance.showing = Details:GetOverallCombat()

		elseif (segmentId == 0) then --combate atual
			instance.showing = Details:GetCurrentCombat()
		else
			instance.showing = segmentsTable[segmentId]
		end

		if (update_coolTip) then
			Details.popup:Select(1, segmentId+2)
		end

		Details:SendEvent("DETAILS_INSTANCE_CHANGESEGMENT", nil, instance, segmentId)

		if (Details.instances_segments_locked and not fromInstanceStart) then
			for _, thisInstance in ipairs(Details.tabela_instancias) do
				if (thisInstance.meu_id ~= instance.meu_id and thisInstance.ativa and not thisInstance._postponing_switch and not thisInstance._postponing_current) then
					--if (thisInstance:GetSegment() >= 0 and instance:GetSegment() ~= DETAILS_SEGMENTID_OVERALL) then
					if (true) then
						if (thisInstance.modo == 2 or thisInstance.modo == 3) then
							--check if the instance is frozen
							if (thisInstance.freezed) then
								if (not fromInstanceStart) then
									thisInstance:UnFreeze()
								else
									thisInstance.freezed = false
								end
							end

							thisInstance.segmento = segmentId

							if (segmentId == DETAILS_SEGMENTID_OVERALL) then
								thisInstance.showing = Details:GetOverallCombat()

							elseif (segmentId == DETAILS_SEGMENTID_CURRENT) then
								thisInstance.showing = Details:GetCurrentCombat()

							else
								thisInstance.showing = Details:GetCombat(segmentId)
							end

							if (not thisInstance.showing) then
								if (not fromInstanceStart) then
									thisInstance:Freeze()
								end
								return
							end

							thisInstance.v_barras = true
							thisInstance.showing [attributeId].need_refresh = true

							if (not Details.initializing and not fromInstanceStart) then
								thisInstance:ResetaGump()
								thisInstance:RefreshMainWindow(true)
							end

							Details:SendEvent("DETAILS_INSTANCE_CHANGESEGMENT", nil, thisInstance, segmentId)
						end
					end
				end
			end
		end
	end

	--if the main attibute is 5 (custom), check if there is any custom display, is isn't, change the attribute and sub attribute to 1 (damage done)
	if (attributeId == 5) then
		if (#Details.custom < 1) then
			attributeId = 1
			subAttributeId = 1
		end
	end

	if (attributeId ~= current_atributo or Details.initializing or fromInstanceStart or (instance.modo == modo_alone or instance.modo == modo_raid)) then
		if (instance.modo == modo_alone and not (Details.initializing or fromInstanceStart)) then
			if (Details.SoloTables.Mode == #Details.SoloTables.Plugins) then
				Details.popup:Select(1, 1)
			else
				if (Details.PluginCount.SOLO > 0) then
					Details.popup:Select(1, Details.SoloTables.Mode+1)
				end
			end
			return Details.SoloTables.switch (nil, nil, -1)

		elseif ((instance.modo == modo_raid) and not (Details.initializing or fromInstanceStart)) then --raid
			return --do nothing when clicking in the button
		end

		atributo_changed  = true
		instance.atributo = attributeId
		instance.sub_atributo = instance.sub_atributo_last[attributeId]

		--change icon
		instance:ChangeIcon()

		if (update_coolTip) then
			Details.popup:Select(1, attributeId)
			Details.popup:Select(2, instance.sub_atributo, attributeId)
		end

		Details:InstanceCall(Details.CheckPsUpdate)
		Details:SendEvent("DETAILS_INSTANCE_CHANGEATTRIBUTE", nil, instance, attributeId, subAttributeId)
	end

	if (subAttributeId ~= current_sub_atributo or Details.initializing or fromInstanceStart or atributo_changed) then
		instance.sub_atributo = subAttributeId

		if (sub_attribute_click) then
			instance.sub_atributo_last[instance.atributo] = instance.sub_atributo
		end

		if (instance.atributo == 5) then --custom
			instance:ChangeIcon()
		end

		Details:InstanceCall(Details.CheckPsUpdate)
		Details:SendEvent("DETAILS_INSTANCE_CHANGEATTRIBUTE", nil, instance, attributeId, subAttributeId)

		instance:ChangeIcon()
	end

	if (Details.BreakdownWindowFrame:IsShown() and instance == Details.BreakdownWindowFrame.instancia) then
		if (not instance.showing or instance.atributo > 4) then
			Details:CloseBreakdownWindow()
		else
			local actorObject = instance.showing (instance.atributo, Details.BreakdownWindowFrame.jogador.nome)
			if (actorObject) then
				Details:OpenBreakdownWindow(instance, actorObject, true)
			else
				Details:CloseBreakdownWindow()
			end
		end
	end

	--if there's no combat object to show, freeze the window
	if (not instance.showing) then
		if (not fromInstanceStart) then
			instance:Freeze()
		end
		return false
	else
		--refresh clock plugin
	end

	instance.v_barras = true
	instance.showing[attributeId].need_refresh = true

	if (not Details.initializing and not fromInstanceStart) then
		instance:ResetaGump()
		instance:RefreshMainWindow(true)
	end

	return true
end

function Details:GetRaidPluginName()
	return self.current_raid_plugin or self.last_raid_plugin
end

function Details:GetInstanceAttributeText()
	if (self.modo == modo_grupo or self.modo == modo_all) then
		local attribute = self.atributo
		local sub_attribute = self.sub_atributo
		local name = Details:GetSubAttributeName (attribute, sub_attribute)
		return name or "Unknown"

	elseif (self.modo == modo_raid) then
		local plugin_name = self.current_raid_plugin or self.last_raid_plugin
		if (plugin_name) then
			local plugin_object = Details:GetPlugin (plugin_name)
			if (plugin_object) then
				return plugin_object.__name
			else
				return "Unknown Plugin"
			end
		else
			return "Unknown Plugin"
		end

	elseif (self.modo == modo_alone) then
		local atributo = Details.SoloTables.Mode or 1
		local SoloInfo = Details.SoloTables.Menu [atributo]
		if (SoloInfo) then
			return SoloInfo [1]
		else
			return "Unknown Plugin"
		end
	end
end

function Details:MontaRaidOption (instancia)
	local available_plugins = Details.RaidTables:GetAvailablePlugins()

	if (#available_plugins == 0) then
		return false
	end

	local amount = 0
	for index, ptable in ipairs(available_plugins) do
		if (ptable [3].__enabled) then
			GameCooltip:AddMenu (1, Details.RaidTables.switch, ptable [4], instancia, nil, ptable [1], ptable [2], true) --PluginName, PluginIcon, PluginObject, PluginAbsoluteName
			amount = amount + 1
		end
	end

	if (amount == 0) then
		return false
	end

	GameCooltip:SetOption("NoLastSelectedBar", true)

	GameCooltip:SetWallpaper (1, Details.tooltip.menus_bg_texture, Details.tooltip.menus_bg_coords, Details.tooltip.menus_bg_color, true)
	return true
end

function Details:MontaSoloOption (instancia)
	for index, ptable in ipairs(Details.SoloTables.Menu) do
		if (ptable [3].__enabled) then
			GameCooltip:AddMenu (1, Details.SoloTables.switch, index, nil, nil, ptable [1], ptable [2], true)
		end
	end

	if (Details.SoloTables.Mode) then
		GameCooltip:SetLastSelected (1, Details.SoloTables.Mode)
	end

	GameCooltip:SetWallpaper (1, Details.tooltip.menus_bg_texture, Details.tooltip.menus_bg_coords, Details.tooltip.menus_bg_color, true)

	return true
end

-- ~menu
local menu_wallpaper_custom_color = {1, 0, 0, 1}
local wallpaper_bg_color = {.8, .8, .8, 0.2}
local menu_icones = {
	"Interface\\AddOns\\Details\\images\\atributos_icones_damage",
	"Interface\\AddOns\\Details\\images\\atributos_icones_heal",
	"Interface\\AddOns\\Details\\images\\atributos_icones_energyze",
	"Interface\\AddOns\\Details\\images\\atributos_icones_misc"
}

function Details:MontaAtributosOption (instancia, func)
	func = func or instancia.TrocaTabela

	local checked1 = instancia.atributo
	local atributo_ativo = instancia.atributo --pega o numero

	local options
	if (atributo_ativo == 5) then --custom
		options = {Loc ["STRING_CUSTOM_NEW"]}
		for index, custom in ipairs(Details.custom) do
			options [#options+1] = custom.name
		end
	else
		options = sub_atributos [atributo_ativo].lista
	end

	local CoolTip = _G.GameCooltip
	local p = 0.125 --32/256

	local gindex = 1
	for i = 1, atributos[0] do --[0] armazena quantos atributos existem

		CoolTip:AddMenu (1, func, nil, i, nil, atributos.lista[i], nil, true)
		CoolTip:AddIcon ("Interface\\AddOns\\Details\\images\\atributos_icones", 1, 1, 20, 20, p*(i-1), p*(i), 0, 1)

		if (Details.tooltip.submenu_wallpaper) then
			if (i == 1) then
				CoolTip:SetWallpaper (2, [[Interface\TALENTFRAME\WarlockDestruction-TopLeft]], {1, 0.22, 0, 0.55}, wallpaper_bg_color)
			elseif (i == 2) then
				CoolTip:SetWallpaper (2, [[Interface\TALENTFRAME\bg-priest-holy]], {1, .6, 0, .2}, wallpaper_bg_color)
			elseif (i == 3) then
				CoolTip:SetWallpaper (2, [[Interface\TALENTFRAME\ShamanEnhancement-TopLeft]], {0, 1, .2, .6}, wallpaper_bg_color)
			elseif (i == 4) then
				CoolTip:SetWallpaper (2, [[Interface\TALENTFRAME\WarlockCurses-TopLeft]], {.2, 1, 0, 1}, wallpaper_bg_color)
			end
		else
			--wallpaper = main window
			--CoolTip:SetWallpaper (2, _detalhes.tooltip.menus_bg_texture, _detalhes.tooltip.menus_bg_coords, _detalhes.tooltip.menus_bg_color, true)
		end

		local options = sub_atributos [i].lista

		if (not instancia.sub_atributo_last) then
			instancia.sub_atributo_last = {1, 1, 1, 1, 1}
		end

		for o = 1, atributos [i] do
			if (Details:CaptureIsEnabled ( Details.atributos_capture [gindex] )) then
				CoolTip:AddMenu (2, func, true, i, o, options[o], nil, true)
				CoolTip:AddIcon (menu_icones[i], 2, 1, 20, 20, p*(o-1), p*(o), 0, 1)
			else
				CoolTip:AddLine(options[o], nil, 2, .5, .5, .5, 1)
				CoolTip:AddMenu (2, func, true, i, o)
				CoolTip:AddIcon (menu_icones[i], 2, 1, 20, 20, p*(o-1), p*(o), 0, 1, {.3, .3, .3, 1})
			end

			gindex = gindex + 1
		end

		CoolTip:SetLastSelected (2, i, instancia.sub_atributo_last [i])
	end

	--custom

	--GameCooltip:AddLine("$div")
	CoolTip:AddLine("$div", nil, 1, -3, 1)

	CoolTip:AddMenu (1, func, nil, 5, nil, atributos.lista[5], nil, true)
	CoolTip:AddIcon ("Interface\\AddOns\\Details\\images\\atributos_icones", 1, 1, 20, 20, p*(5-1), p*(5), 0, 1)

	CoolTip:AddMenu (2, Details.OpenCustomDisplayWindow, nil, nil, nil, Loc ["STRING_CUSTOM_NEW"], nil, true)
	CoolTip:AddIcon ([[Interface\CHATFRAME\UI-ChatIcon-Maximize-Up]], 2, 1, 20, 20, 3/32, 29/32, 3/32, 29/32)

	CoolTip:AddLine("$div", nil, 2, nil, -8, -13)

	for index, custom in ipairs(Details.custom) do
		if (custom.temp) then
			CoolTip:AddLine(custom.name .. Loc ["STRING_CUSTOM_TEMPORARILY"], nil, 2)
		else
			CoolTip:AddLine(custom.name, nil, 2)
		end

		CoolTip:AddMenu (2, func, true, 5, index)
		CoolTip:AddIcon (custom.icon, 2, 1, 20, 20)
	end

	--set the wallpaper on custom
	if (Details.tooltip.submenu_wallpaper) then
		CoolTip:SetWallpaper (2, [[Interface\TALENTFRAME\WarriorArm-TopLeft]], menu_wallpaper_custom_color, wallpaper_bg_color)
	else
		--CoolTip:SetWallpaper (2, _detalhes.tooltip.menus_bg_texture, _detalhes.tooltip.menus_bg_coords, _detalhes.tooltip.menus_bg_color, true)
	end

	if (#Details.custom == 0) then
		CoolTip:SetLastSelected (2, 6, 2)
	else
		if (instancia.atributo == 5) then
			CoolTip:SetLastSelected (2, 6, instancia.sub_atributo+2)
		else
			CoolTip:SetLastSelected (2, 6, instancia.sub_atributo_last [5]+2)
		end
	end

	CoolTip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar4_vidro]])
	CoolTip:SetOption("ButtonsYMod", -7)
	CoolTip:SetOption("HeighMod", 7)

	CoolTip:SetOption("ButtonsYModSub", -7)
	CoolTip:SetOption("HeighModSub", 7)

	CoolTip:SetOption("SelectedTopAnchorMod", -2)
	CoolTip:SetOption("SelectedBottomAnchorMod", 2)

	CoolTip:SetOption("TextFont",  Details.font_faces.menus)

	Details:SetTooltipMinWidth()

	local last_selected = atributo_ativo
	if (atributo_ativo == 5) then
		last_selected = 6
	end
	CoolTip:SetLastSelected (1, last_selected)

	--removed the menu backdrop
	--CoolTip:SetWallpaper (1, _detalhes.tooltip.menus_bg_texture, _detalhes.tooltip.menus_bg_coords, _detalhes.tooltip.menus_bg_color, true)

	return menu_principal, sub_menus
end

local iconCoords = {
	[1] = {-1, 0, 0, 0, -1, -1, 0, 0}, --damage, dps, taken, friendldire, frags, enemy damage taken, auras, by spell
	[2] = {0, 1, 1, 1, 0, 0, 1}, --healing, hps, overheal, taken, enemyheal, damageprevented, healabsorbed
	[3] = {0, -2, -1, 0, 0, 0}, --mana, rage, energy, rune, other resources, alternate power
	[4] = {0, 0, -1, 0, 0, 0, 0, 0}, --ccBreak, res, kick, dispel, deaths, cooldowns, buffUptime, debuffUptime
}
local getFineTunedIconCoords = function(attribute, subAttribute)
	return iconCoords[attribute] and iconCoords[attribute][subAttribute] or 0
end

function Details:ChangeIcon(icon)
	local skin = Details.skins [self.skin]
	if (not skin) then
		skin = Details.skins [Details.default_skin_to_use]
	end

	local titleBarIconSize

	local iconSizeFromInstance = self.attribute_icon_size
	if (iconSizeFromInstance and iconSizeFromInstance ~= 0) then
		titleBarIconSize = iconSizeFromInstance

	elseif (skin.attribute_icon_size) then
		titleBarIconSize = skin.attribute_icon_size

	else
		titleBarIconSize = 16
	end

	if (not self.hide_icon) then
		if (skin.icon_on_top) then
			self.baseframe.cabecalho.atributo_icon:SetParent(self.floatingframe)
		else
			self.baseframe.cabecalho.atributo_icon:SetParent(self.baseframe)
		end
	end

	if (icon) then
		--plugin chamou uma troca de icone
		self.baseframe.cabecalho.atributo_icon:SetTexture(icon)
		self.baseframe.cabecalho.atributo_icon:SetTexCoord(5/64, 60/64, 3/64, 62/64)

		local icon_size = skin.icon_plugins_size
		self.baseframe.cabecalho.atributo_icon:SetSize(titleBarIconSize, titleBarIconSize)
		local icon_anchor = skin.icon_anchor_plugins

		self.baseframe.cabecalho.atributo_icon:ClearAllPoints()
		self.baseframe.cabecalho.atributo_icon:SetPoint("TOPRIGHT", self.baseframe.cabecalho.ball_point, "TOPRIGHT", icon_anchor[1], icon_anchor[2])

	elseif (self.modo == modo_alone) then --solo
		--icon is set by the plugin

	elseif (self.modo == modo_grupo or self.modo == modo_all) then --grupo

		if (self.atributo == 5) then
			--custom
			if (Details.custom [self.sub_atributo]) then
				local icon = Details.custom [self.sub_atributo].icon
				self.baseframe.cabecalho.atributo_icon:SetTexture(icon)
				self.baseframe.cabecalho.atributo_icon:SetTexCoord(5/64, 60/64, 3/64, 62/64)

				local icon_size = skin.icon_plugins_size
				self.baseframe.cabecalho.atributo_icon:SetSize(titleBarIconSize, titleBarIconSize)
				local icon_anchor = skin.icon_anchor_plugins

				self.baseframe.cabecalho.atributo_icon:ClearAllPoints()
				self.baseframe.cabecalho.atributo_icon:SetPoint("TOPRIGHT", self.baseframe.cabecalho.ball_point, "TOPRIGHT", icon_anchor[1], icon_anchor[2])
			end
		else
			--set the attribute icon
			self.baseframe.cabecalho.atributo_icon:SetTexture(menu_icones [self.atributo])

			if (self.icon_desaturated) then
				self.baseframe.cabecalho.atributo_icon:SetDesaturated(true)
			else
				self.baseframe.cabecalho.atributo_icon:SetDesaturated(false)
			end

			local p = 0.125 --32/256
			self.baseframe.cabecalho.atributo_icon:SetTexCoord(p * (self.sub_atributo-1), p * (self.sub_atributo), 0, 1)
			self.baseframe.cabecalho.atributo_icon:SetSize(titleBarIconSize, titleBarIconSize)

			self.baseframe.cabecalho.atributo_icon:ClearAllPoints()
			if (self.menu_attribute_string) then
				local yOffset = getFineTunedIconCoords(self.atributo, self.sub_atributo)
				self.baseframe.cabecalho.atributo_icon:SetPoint("right", self.menu_attribute_string.widget, "left", -4, 1 + yOffset)
			end

			if (skin.attribute_icon_anchor) then
				self.baseframe.cabecalho.atributo_icon:ClearAllPoints()
				self.baseframe.cabecalho.atributo_icon:SetPoint("topleft", self.baseframe.cabecalho.ball_point, "topleft", skin.attribute_icon_anchor[1], skin.attribute_icon_anchor[2])
			end
		end

	elseif (self.modo == modo_raid) then --raid
		--icon is set by the plugin
	end
end


---this function runs after the mode of a instance is changed
---@param instance instance
function Details222.Instances.OnModeChanged(instance)
	local modeId = instance:GetMode()
	
	if (modeId == modo_alone) then
		if (instance.LastModo == modo_raid) then
			Details.RaidTables:DisableRaidMode(instance)
		end

		--check if there's a disabled window with solo mode enabled
		Details:InstanciaCallFunctionOffline(Details.InstanciaCheckForDisabledSolo)
		instance:ChangeIcon()
		instance:SoloMode(true)

	elseif (modeId == modo_raid) then
		if (instance.LastModo == modo_alone) then
			instance:SoloMode(false)
		end
		instance:ChangeIcon()
		Details.RaidTables:EnableRaidMode(instance)

	elseif (modeId == modo_grupo or modeId == modo_all) then
		if (instance.LastModo == modo_alone) then
			instance:SoloMode(false)

		elseif (instance.LastModo == modo_raid) then
			Details.RaidTables:DisableRaidMode(instance)
		end

		Details:ResetaGump(instance)
		instance:RefreshMainWindow(true)
		Details:SendEvent("DETAILS_INSTANCE_CHANGEATTRIBUTE", nil, instance, instance.atributo, instance.sub_atributo)
	end

	instance:ChangeIcon()
	Details:SendEvent("DETAILS_INSTANCE_CHANGEMODE", nil, instance, modeId)
end

local function GetDpsHps (_thisActor, key)
	local keyname
	if (key == "dps") then
		keyname = "last_dps"
	elseif (key == "hps") then
		keyname = "last_hps"
	end

	if (_thisActor [keyname]) then
		return _thisActor [keyname]
	else
		if ((Details.time_type == 2 and _thisActor.grupo) or not Details:CaptureGet("damage") or Details.use_realtimedps) then
			local dps = _thisActor.total / _thisActor:GetCombatTime()
			_thisActor [keyname] = dps
			return dps
		else
			if (not _thisActor.on_hold) then
				local dps = _thisActor.total/_thisActor:Tempo() --calcula o dps deste objeto
				_thisActor [keyname] = dps --salva o dps dele
				return dps
			else
				if (_thisActor [keyname] == 0) then --n�o calculou o dps dele ainda mas entrou em standby
					local dps = _thisActor.total/_thisActor:Tempo()
					_thisActor [keyname] = dps
					return dps
				else
					return _thisActor [keyname]
				end
			end
		end
	end
end

-- table sent to report func / f1: format value1 / f2: format value2
-- report_table = a table header: {"report results for:"}
-- data = table with {{value1 (string), value2 ( the value)} , {value1 (string), value2 ( the value)}}

local default_format_value1 = function(v) return v end
local default_format_value2 = function(v) return v end
local default_format_value3 = function(i, v1, v2)
	return "" .. i .. ". " .. v1 .. " " .. v2
end

function Details:FormatReportLines (report_table, data, f1, f2, f3)
	f1 = f1 or default_format_value1
	f2 = f2 or default_format_value2
	f3 = f3 or default_format_value3

	if (not Details.fontstring_len) then
		Details.fontstring_len = Details.listener:CreateFontString(nil, "background", "GameFontNormal")
	end
	local _, fontSize = FCF_GetChatWindowInfo (1)
	if (fontSize < 1) then
		fontSize = 10
	end
	local fonte, _, flags = Details.fontstring_len:GetFont()
	Details.fontstring_len:SetFont(fonte, fontSize, flags)
	Details.fontstring_len:SetText("DEFAULT NAME")
	local biggest_len = Details.fontstring_len:GetStringWidth()

	for index, t in ipairs(data) do
		local v1 = f1 (t[1])
		Details.fontstring_len:SetText(v1)
		local len = Details.fontstring_len:GetStringWidth()
		if (len > biggest_len) then
			biggest_len = len
		end
	end

	if (biggest_len > 130) then
		biggest_len = 130
	end

	for index, t in ipairs(data) do
		local v1, v2 = f1 (t[1]), f2 (t[2])
		if (v1 and v2 and type(v1) == "string" and type(v2) == "string") then
			v1 = v1 .. " "
			Details.fontstring_len:SetText(v1)
			local len = Details.fontstring_len:GetStringWidth()

			while (len < biggest_len) do
				v1 = v1 .. "."
				Details.fontstring_len:SetText(v1)
				len = Details.fontstring_len:GetStringWidth()
			end

			report_table [#report_table+1] = f3 (index, v1, v2)
		end
	end

end

local report_name_function = function(name)
	local name, index = unpack(name)

	if (Details.remove_realm_from_name and name:find("-")) then
		return index .. ". " .. name:gsub(("%-.*"), "")
	else
		return index .. ". " .. name
	end
end

local report_amount_function = function(t)
	local amount, dps, percent, is_string, index = unpack(t)

	if (not is_string) then
		if (dps) then
			if (Details.report_schema == 1) then
				return Details:ToKReport (_math_floor(amount)) .. " (" .. Details:ToKMin (_math_floor(dps)) .. ", " .. percent .. "%)"
			elseif (Details.report_schema == 2) then
				return percent .. "% (" .. Details:ToKMin (_math_floor(dps)) .. ", " .. Details:ToKReport ( _math_floor(amount)) .. ")"
			elseif (Details.report_schema == 3) then
				return percent .. "% (" .. Details:ToKReport ( _math_floor(amount) ) .. ", " .. Details:ToKMin (_math_floor(dps)) .. ")"
			end
		else
			if (Details.report_schema == 1) then
				return Details:ToKReport (amount) .. " (" .. percent .. "%)"
			else
				return percent .. "% (" .. Details:ToKReport (amount) .. ")"
			end
		end
	else
		return amount
	end
end

local report_build_line = function(i, v1, v2)
	return v1 .. " " .. v2
end

--Reportar o que esta na janela da inst�ncia
function Details:monta_relatorio (este_relatorio, custom)
	if (custom) then
		--shrink
		local report_lines = {}
		for i = 1, Details.report_lines+1, 1 do  --#este_relatorio -- o +1 � pq ele conta o cabe�alho como uma linha
			report_lines [#report_lines+1] = este_relatorio[i] --este_relatorio is a nil value | bug report tells custom is true
		end

		return self:envia_relatorio (report_lines, true)
	end

	local amt = Details.report_lines

	local report_lines = {}

	if (self.atributo == 5) then --custom
		if (self.segmento == -1) then --overall
			report_lines [#report_lines+1] = "Details!: " .. Loc ["STRING_OVERALL"] .. " " .. self.customName .. " " .. Loc ["STRING_CUSTOM_REPORT"]
		else
			report_lines [#report_lines+1] = "Details!: " .. self.customName .. " " .. Loc ["STRING_CUSTOM_REPORT"]
		end

	else
		if (self.segmento == -1) then --overall
			report_lines [#report_lines+1] = "Details!: " .. Loc ["STRING_OVERALL"] .. " " .. Details.sub_atributos [self.atributo].lista [self.sub_atributo]
		else
			report_lines [#report_lines+1] = "Details!: " .. Details.sub_atributos [self.atributo].lista [self.sub_atributo]
		end
	end

	if (self.meu_id and self.atributo and self.sub_atributo and Details.report_where ~= "WHISPER" and Details.report_where ~= "WHISPER2") then
		local already_exists
		for index, reported in ipairs(Details.latest_report_table) do
			if (reported [1] == self.meu_id and reported [2] == self.atributo and reported [3] == self.sub_atributo and reported [5] == Details.report_where) then
				already_exists = index
				break
			end
		end

		if (already_exists) then
			--push it to  front
			local t = tremove(Details.latest_report_table, already_exists)
			t [4] = amt
			table.insert(Details.latest_report_table, 1, t)
		else
			if (self.atributo == 5) then
				local custom_name = self:GetCustomObject():GetName()
				table.insert(Details.latest_report_table, 1, {self.meu_id, self.atributo, self.sub_atributo, amt, Details.report_where, custom_name})
			else
				table.insert(Details.latest_report_table, 1, {self.meu_id, self.atributo, self.sub_atributo, amt, Details.report_where})
			end
		end

		tremove(Details.latest_report_table, 11)
	end

	local barras = self.barras
	local esta_barra
	local is_current = _G ["Details_Report_CB_1"]:GetChecked()
	local is_reverse = _G ["Details_Report_CB_2"]:GetChecked()
	local name_member = "nome"

	if (not is_current) then
		local total, keyName, keyNameSec, first
		local container_amount = 0
		local atributo = self.atributo
		local container = self.showing [atributo]._ActorTable

		if (atributo == 1) then --damage
			if (self.sub_atributo == 5) then --frags
				local frags = self.showing.frags
				local reportarFrags = {}
				for name, amount in pairs(frags) do
					--string para imprimir direto sem calculos
					reportarFrags [#reportarFrags+1] = {frag = tostring(amount), nome = name}
				end
				container = reportarFrags
				container_amount = #reportarFrags
				keyName = "frag"

			elseif (self.sub_atributo == 7) then --auras e voidzones

				total, keyName, first, container_amount, container, name_member = Details.atributo_damage:RefreshWindow (self, self.showing, true, true)

			elseif (self.sub_atributo == 8) then --damage taken by spell

				total, keyName, first, container_amount, container = Details.atributo_damage:RefreshWindow (self, self.showing, true, true)

				for _, t in ipairs(container) do
					t.nome = Details:GetSpellLink(t.spellid)
				end

			else
				total, keyName, first, container_amount = Details.atributo_damage:RefreshWindow (self, self.showing, true, true)
				if (self.sub_atributo == 1) then
					keyNameSec = "dps"
				elseif (self.sub_atributo == 2) then

				end
			end

		elseif (atributo == 2) then --heal
			total, keyName, first, container_amount = Details.atributo_heal:RefreshWindow (self, self.showing, true, true)

			if (self.sub_atributo == 1) then
				keyNameSec = "hps"
			end

		elseif (atributo == 3) then --energy
			total, keyName, first, container_amount = Details.atributo_energy:RefreshWindow (self, self.showing, true, true)

		elseif (atributo == 4) then --misc
			if (self.sub_atributo == 5) then --mortes

				local mortes = self.showing.last_events_tables
				local reportarMortes = {}
				for index, morte in ipairs(mortes) do
					reportarMortes [#reportarMortes+1] = {dead = morte [6], nome = morte [3]:gsub(("%-.*"), "")}
				end
				container = reportarMortes
				container_amount = #reportarMortes
				keyName = "dead"
			else
				total, keyName, first, container_amount = Details.atributo_misc:RefreshWindow (self, self.showing, true, true)
			end

		elseif (atributo == 5) then --custom

			if (Details.custom [self.sub_atributo]) then
				total, container, first, container_amount, nm = Details.atributo_custom:RefreshWindow (self, self.showing, true, true)
				if (nm) then
					name_member = nm
				end
				keyName = "report_value"
			else
				total, keyName, first, container_amount = Details.atributo_damage:RefreshWindow (self, self.showing, true, true)
				total = 1
				atributo = 1
				container = self.showing [atributo]._ActorTable
			end
		end

		amt = math.min (amt, container_amount or 0)
		local raw_data_to_report = {}

		for i = 1, container_amount do
			local actor = container [i]
			if (actor) then
				-- get the total
				local amount, is_string
				if (type(actor [keyName]) == "number") then
					amount = _math_floor(actor [keyName])
				else
					amount = actor [keyName]
					is_string = true
				end

				-- get the name
				local name = actor [name_member] or ""

				if (not is_string) then
					-- get the percent
					local percent
					if (self.atributo == 2 and self.sub_atributo == 3) then --overheal
						percent = _cstr ("%.1f", actor.totalover / (actor.totalover + actor.total) * 100)
					elseif (not is_string) then
						percent = _cstr ("%.1f", amount / max(total, 0.00001) * 100)
					end

					-- get the dps
					local dps = false
					if (keyNameSec) then
						dps = GetDpsHps (actor, keyNameSec)
					end

					raw_data_to_report [#raw_data_to_report+1] = {{name, i}, {amount, dps, percent, false}}
				else
					raw_data_to_report [#raw_data_to_report+1] = {{name, i}, {amount, false, false, true}}
				end

			else
				break
			end
		end

		if (is_reverse) then
			local t = {}
			for i = #raw_data_to_report, 1, -1 do
				table.insert(t, raw_data_to_report [i])
				if (#t >= amt) then
					break
				end
			end
			Details:FormatReportLines (report_lines, t, report_name_function, report_amount_function, report_build_line)
		else
			for i = #raw_data_to_report, amt+1, -1 do
				tremove(raw_data_to_report, i)
			end
			Details:FormatReportLines (report_lines, raw_data_to_report, report_name_function, report_amount_function, report_build_line)
		end
	else
		local raw_data_to_report = {}

		for i = 1, amt do
			local window_bar = self.barras [i]
			if (window_bar) then
				if (not window_bar.hidden or window_bar.fading_out) then
					raw_data_to_report [#raw_data_to_report+1] = {window_bar.lineText1:GetText(), window_bar.lineText4:GetText()}
				else
					break
				end
			else
				break
			end
		end

		Details:FormatReportLines (report_lines, raw_data_to_report, nil, nil, report_build_line)

	end

	return self:envia_relatorio (report_lines)
end

function Details:envia_relatorio (linhas, custom)
	local segmento = self.segmento
	local luta = nil
	local combatObject

	---@type combat[]
	local segmentsTable = Details:GetCombatSegments()

	if (not custom) then

		if (not linhas[1]) then
			return Details:Msg(Loc ["STRING_ACTORFRAME_NOTHING"])
		end

		if (segmento == -1) then --overall
			luta = Details.tabela_overall.overall_enemy_name
			combatObject = Details.tabela_overall

		elseif (segmento == 0) then --current

			if (Details.tabela_vigente.is_boss) then
				local encounterName = Details.tabela_vigente.is_boss.name
				if (encounterName) then
					luta = encounterName
				end

			elseif (Details.tabela_vigente.is_pvp) then
				local battleground_name = Details.tabela_vigente.is_pvp.name
				if (battleground_name) then
					luta = battleground_name
				end
			end

			local isMythicDungeon = Details.tabela_vigente:IsMythicDungeon()
			if (isMythicDungeon) then
				local mythicDungeonInfo = Details.tabela_vigente:GetMythicDungeonInfo()
				if (mythicDungeonInfo) then
					local isMythicOverallSegment, segmentID, mythicLevel, EJID, mapID, zoneName, encounterID, encounterName, startedAt, endedAt, runID = Details:UnpackMythicDungeonInfo (mythicDungeonInfo)

					if (isMythicOverallSegment) then
						luta = zoneName .. " +" .. mythicLevel .. " (" .. Loc ["STRING_SEGMENTS_LIST_OVERALL"] .. ")"
					else
						if (segmentID == "trashoverall") then
							luta = encounterName .. " (" .. Loc ["STRING_SEGMENTS_LIST_TRASH"] .. ")"
						else
							luta = encounterName .. " (" .. Loc ["STRING_SEGMENTS_LIST_BOSS"] .. ")"
						end
					end
				else
					luta = Loc ["STRING_SEGMENTS_LIST_TRASH"]
				end
			end

			if (not luta) then
				if (Details.tabela_vigente.enemy) then
					luta = Details.tabela_vigente.enemy
				end
			end

			if (not luta) then
				luta = Details.segmentos.current
			end

			combatObject = Details.tabela_vigente
		else
			if (segmento == 1) then

				if (segmentsTable[1].is_boss) then
					local encounterName = segmentsTable[1].is_boss.name
					if (encounterName) then
						luta = encounterName .. " (" .. Loc ["STRING_REPORT_LASTFIGHT"]  .. ")"
					end

				elseif (segmentsTable[1].is_pvp) then
					local battleground_name = segmentsTable[1].is_pvp.name
					if (battleground_name) then
						luta = battleground_name .. " (" .. Loc ["STRING_REPORT_LASTFIGHT"]  .. ")"
					end
				end

				local thisSegment = segmentsTable[1]
				local isMythicDungeon = thisSegment:IsMythicDungeon()
				if (isMythicDungeon) then
					local mythicDungeonInfo = thisSegment:GetMythicDungeonInfo()
					if (mythicDungeonInfo) then
						local isMythicOverallSegment, segmentID, mythicLevel, EJID, mapID, zoneName, encounterID, encounterName, startedAt, endedAt, runID = Details:UnpackMythicDungeonInfo (mythicDungeonInfo)

						if (isMythicOverallSegment) then
							luta = zoneName .. " +" .. mythicLevel .. " (" .. Loc ["STRING_SEGMENTS_LIST_OVERALL"] .. ")"
						else
							if (segmentID == "trashoverall") then
								luta = encounterName .. " (" .. Loc ["STRING_SEGMENTS_LIST_TRASH"] .. ")"
							else
								luta = encounterName .. " (" .. Loc ["STRING_SEGMENTS_LIST_BOSS"] .. ")"
							end
						end
					else
						luta = Loc ["STRING_SEGMENTS_LIST_TRASH"]
					end
				end

				if (not luta) then
					if (segmentsTable[1].enemy) then
						luta = segmentsTable[1].enemy .. " (" .. Loc ["STRING_REPORT_LASTFIGHT"]  .. ")"
					end
				end

				if (not luta) then
					luta = Loc ["STRING_REPORT_LASTFIGHT"]
				end

				combatObject = segmentsTable[1]
			else
				if (segmentsTable[segmento].is_boss) then
					local encounterName = segmentsTable[segmento].is_boss.name
					if (encounterName) then
						luta = encounterName .. " (" .. segmento .. " " .. Loc ["STRING_REPORT_PREVIOUSFIGHTS"] .. ")"
					end

				elseif (segmentsTable[segmento].is_pvp) then
					local battleground_name = segmentsTable[segmento].is_pvp.name
					if (battleground_name) then
						luta = battleground_name .. " (" .. Loc ["STRING_REPORT_LASTFIGHT"]  .. ")"
					end
				end

				local thisSegment = segmentsTable [segmento]
				local isMythicDungeon = thisSegment:IsMythicDungeon()
				if (isMythicDungeon) then
					local mythicDungeonInfo = thisSegment:GetMythicDungeonInfo()
					if (mythicDungeonInfo) then
						local isMythicOverallSegment, segmentID, mythicLevel, EJID, mapID, zoneName, encounterID, encounterName, startedAt, endedAt, runID = Details:UnpackMythicDungeonInfo (mythicDungeonInfo)

						if (isMythicOverallSegment) then
							luta = zoneName .. " +" .. mythicLevel .. " (" .. Loc ["STRING_SEGMENTS_LIST_OVERALL"] .. ")"
						else
							if (segmentID == "trashoverall") then
								luta = encounterName .. " (" .. Loc ["STRING_SEGMENTS_LIST_TRASH"] .. ")"
							else
								luta = encounterName .. " (" .. Loc ["STRING_SEGMENTS_LIST_BOSS"] .. ")"
							end
						end
					else
						luta = Loc ["STRING_SEGMENTS_LIST_TRASH"]
					end
				end

				if (not luta) then
					if (segmentsTable[segmento].enemy) then
						luta = segmentsTable[segmento].enemy .. " (" .. segmento .. " " .. Loc ["STRING_REPORT_PREVIOUSFIGHTS"] .. ")"
					end
				end

				if (not luta) then
					luta = " (" .. segmento .. " " .. Loc ["STRING_REPORT_PREVIOUSFIGHTS"] .. ")"
				end

				combatObject = segmentsTable[segmento]
			end
		end

		linhas[1] = linhas[1] .. " " .. Loc ["STRING_REPORT"] .. " " .. luta
	end

	--add the combat time
	local segmentTime = ""
	if (combatObject) then
		local combatTime = combatObject:GetCombatTime()
		segmentTime = Details.gump:IntegerToTimer(combatTime or 0)
	else
		combatObject = self:GetCombat()
		local combatTime = combatObject:GetCombatTime()
		segmentTime = Details.gump:IntegerToTimer(combatTime or 0)
	end

	--effective ou active time
	if (not custom) then
		if (Details.time_type == 2 or Details.use_realtimedps) then
			linhas[1] = linhas[1] .. " [" .. segmentTime .. " EF]"
		else
			linhas[1] = linhas[1] .. " [" .. segmentTime .. " AC]"
		end
	end

	local editbox = Details.janela_report.editbox
	if (editbox.focus) then --n�o precionou enter antes de clicar no okey
		local texto = Details:trim (editbox:GetText())
		if (_string_len (texto) > 0) then
			Details.report_to_who = texto
			editbox:AddHistoryLine (texto)
			editbox:SetText(texto)
		else
			Details.report_to_who = ""
			editbox:SetText("")
		end
		editbox.perdeu_foco = true --isso aqui pra quando estiver editando e clicar em outra caixa
		editbox:ClearFocus()
	end

	Details:DelayUpdateReportWindowRecentlyReported()

	if (Details.report_where == "COPY") then
		Details:SendReportTextWindow (linhas)
		return
	end

	local to_who = Details.report_where

	local channel = to_who:find("CHANNEL")
	local is_btag = to_who:find("REALID")

	local send_report_channel = function(timerObject)
		_SendChatMessage (timerObject.Arg1, timerObject.Arg2, timerObject.Arg3, timerObject.Arg4)
	end

	local sendReportBnet = function(timerObject)
		BNSendWhisper(timerObject.Arg1, timerObject.Arg2)
	end

	local delay = 200

	if (channel) then

		channel = to_who:gsub((".*|"), "")

		for i = 1, #linhas do
			if (channel == "Trade") then
				channel = "Trade - City"
			end

			local channelName = GetChannelName (channel)
			local timer = C_Timer.NewTimer(i * delay / 1000, send_report_channel)
			timer.Arg1 = linhas[i]
			timer.Arg2 = "CHANNEL"
			timer.Arg3 = nil
			timer.Arg4 = channelName
		end

		return

	elseif (is_btag) then
		local bnetAccountID = to_who:gsub((".*|"), "")
		bnetAccountID = tonumber(bnetAccountID)

		for i = 1, #linhas do
			local timer = C_Timer.NewTimer(i * delay / 1000, sendReportBnet)
			timer.Arg1 = bnetAccountID
			timer.Arg2 = linhas[i]
		end

		return

	elseif (to_who == "WHISPER") then --whisper

		local alvo = Details.report_to_who

		if (not alvo or alvo == "") then
			Details:Msg(Loc ["STRING_REPORT_INVALIDTARGET"])
			return
		end

		for i = 1, #linhas do
			local timer = C_Timer.NewTimer(i * delay / 1000, send_report_channel)
			timer.Arg1 = linhas[i]
			timer.Arg2 = to_who
			timer.Arg3 = nil
			timer.Arg4 = alvo
		end
		return

	elseif (to_who == "WHISPER2") then --whisper target
		to_who = "WHISPER"

		local alvo
		if (_UnitExists ("target")) then
			if (_UnitIsPlayer ("target")) then
				local nome, realm = _UnitName ("target")
				if (realm and realm ~= "") then
					nome = nome.."-"..realm
				end
				alvo = nome
			else
				Details:Msg(Loc ["STRING_REPORT_INVALIDTARGET"])
				return
			end
		else
			Details:Msg(Loc ["STRING_REPORT_INVALIDTARGET"])
			return
		end

		for i = 1, #linhas do
			local timer = C_Timer.NewTimer(i * delay / 1000, send_report_channel)
			timer.Arg1 = linhas[i]
			timer.Arg2 = to_who
			timer.Arg3 = nil
			timer.Arg4 = alvo
		end

		return
	end

	if (to_who == "RAID" or to_who == "PARTY") then
		if (GetNumGroupMembers (LE_PARTY_CATEGORY_INSTANCE) > 0) then
			to_who = "INSTANCE_CHAT"
		end
	end

	for i = 1, #linhas do
		local timer = C_Timer.NewTimer(i * delay / 1000, send_report_channel)
		timer.Arg1 = linhas[i]
		timer.Arg2 = to_who
		timer.Arg3 = nil
		timer.Arg4 = nil

	end

end

-- enda elsef
