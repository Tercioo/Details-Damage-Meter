
	---@type details
	local Details = _G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
	local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
	local detailsFramework = _G.DetailsFramework

	local DEFAULT_CHILD_WIDTH = 60
	local DEFAULT_CHILD_HEIGHT = 16
	local DEFAULT_CHILD_FONTFACE = "Friz Quadrata TT"
	local DEFAULT_CHILD_FONTCOLOR = {1, 0.733333, 0, 1}
	local DEFAULT_CHILD_FONTSIZE = 10
	local _

	local unpack = unpack

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local ipairs = ipairs --api local
	local UnitGroupRolesAssigned = DetailsFramework.UnitGroupRolesAssigned

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--status bar core functions

	--hida all micro frames
	function Details.StatusBar:Hide(instance, side)
		if (not side) then
			if (instance.StatusBar.center and instance.StatusBar.left and instance.StatusBar.right) then
				instance.StatusBar.center.frame:Hide()
				instance.StatusBar.left.frame:Hide()
				instance.StatusBar.right.frame:Hide()
			end
		end
	end

	function Details.StatusBar:Show(instance, side)
		if (not side) then
			if (instance.StatusBar.center and instance.StatusBar.left and instance.StatusBar.right) then
				instance.StatusBar.center.frame:Show()
				instance.StatusBar.left.frame:Show()
				instance.StatusBar.right.frame:Show()
			end
		end
	end

	function Details.StatusBar:LockDisplays(instance, locked)
		if (instance.StatusBar.center and instance.StatusBar.left and instance.StatusBar.right) then
			if (locked) then
				instance.StatusBar.center.frame:EnableMouse(false)
				instance.StatusBar.left.frame:EnableMouse(false)
				instance.StatusBar.right.frame:EnableMouse(false)
			else
				instance.StatusBar.center.frame:EnableMouse(true)
				instance.StatusBar.left.frame:EnableMouse(true)
				instance.StatusBar.right.frame:EnableMouse(true)
			end
		end
	end

	--create a plugin child for an instance
	function Details.StatusBar:CreateStatusBarChildForInstance(instance, pluginName)
		local PluginObject = Details.StatusBar.NameTable[pluginName]
		if (PluginObject) then
			local newChild = PluginObject:CreateChildObject(instance)
			if (newChild) then
				instance.StatusBar[#instance.StatusBar+1] = newChild
				newChild.enabled = false
				return newChild
			end
		end
		return nil
	end

	--functions to set the three statusbar places: left, center and right
		function Details.StatusBar:SetCenterPlugin(instance, childObject, fromStartup)
			childObject.frame:Show()
			childObject.frame:ClearAllPoints()

			childObject.options.textAlign = 2

			if (instance.micro_displays_side == 2) then --default - bottom
				childObject.frame:SetPoint("center", instance.baseframe.rodape.StatusBarCenterAnchor, "center")

			elseif (instance.micro_displays_side == 1) then --top side
				childObject.frame:SetPoint("center", instance.baseframe.cabecalho.StatusBarCenterAnchor, "center")
			end

			childObject.text:ClearAllPoints()
			childObject.text:SetPoint("center", childObject.frame, "center", childObject.options.textXMod, childObject.options.textYMod)

			instance.StatusBar.center = childObject
			childObject.anchor = "center"
			childObject.enabled = true
			if (childObject.OnEnable) then
				childObject:OnEnable()
			end

			if (fromStartup and childObject.options.isHidden) then
				childObject.frame.text:Hide()
				if (childObject.frame.texture) then
					childObject.frame.texture:Hide()
				end
			end

			return true
		end

		function Details.StatusBar:SetLeftPlugin(instance, childObject, fromStartup)
			if (not childObject) then
				return
			end

			childObject.frame:Show()
			childObject.frame:ClearAllPoints()

			childObject.options.textAlign = 1

			if (instance.micro_displays_side == 2) then --default - bottom
				childObject.frame:SetPoint("left", instance.baseframe.rodape.StatusBarLeftAnchor,  "left")

			elseif (instance.micro_displays_side == 1) then --top side
				childObject.frame:SetPoint("left", instance.baseframe.cabecalho.StatusBarLeftAnchor,  "left")
			end

			childObject.text:ClearAllPoints()
			childObject.text:SetPoint("left", childObject.frame, "left", childObject.options.textXMod, childObject.options.textYMod)

			instance.StatusBar.left = childObject
			childObject.anchor = "left"
			childObject.enabled = true
			if (childObject.OnEnable) then
				childObject:OnEnable()
			end

			if (fromStartup and childObject.options.isHidden) then
				childObject.frame.text:Hide()
				if (childObject.frame.texture) then
					childObject.frame.texture:Hide()
				end
			end

			return true
		end

		function Details.StatusBar:SetRightPlugin(instance, childObject, fromStartup)
			childObject.frame:Show()
			childObject.frame:ClearAllPoints()

			childObject.options.textAlign = 3

			if (instance.micro_displays_side == 2) then --default - bottom
				childObject.frame:SetPoint("right", instance.baseframe.rodape.direita, "right", -20, 10)

			elseif (instance.micro_displays_side == 1) then --top side
				childObject.frame:SetPoint("right", instance.baseframe.cabecalho.StatusBarRightAnchor, "right")
			end

			childObject.text:ClearAllPoints()
			childObject.text:SetPoint("right", childObject.frame, "right", childObject.options.textXMod, childObject.options.textYMod)

			instance.StatusBar.right = childObject
			childObject.anchor = "right"
			childObject.enabled = true
			if (childObject.OnEnable) then
				childObject:OnEnable()
			end

			if (fromStartup and childObject.options.isHidden) then
				childObject.frame.text:Hide()
				if (childObject.frame.texture) then
					childObject.frame.texture:Hide()
				end
			end

			return true
		end

	--disable all plugin childs attached to an specified instance and reactive the childs taking the instance statusbar anchors
	function Details.StatusBar:ReloadAnchors(instance)
		for _, child in ipairs(instance.StatusBar) do
			child.frame:ClearAllPoints()
			child.frame:Hide()
			child.anchor = nil
			child.enabled = false
			if (child.OnDisable) then
				child:OnDisable()
			end
		end

		--enable only needed plugins
		if (instance.StatusBar.right) then
			Details.StatusBar:SetRightPlugin(instance, instance.StatusBar.right)
		end
		if (instance.StatusBar.center) then
			Details.StatusBar:SetCenterPlugin(instance, instance.StatusBar.center)
		end
		if (instance.StatusBar.left) then
			Details.StatusBar:SetLeftPlugin(instance, instance.StatusBar.left)
		end

		if (not instance.show_statusbar and instance.micro_displays_side == 2) then
			Details.StatusBar:Hide(instance)
		end
	end

	--select a new plugin in for an instance anchor
	local ChoosePlugin = function(_, _, index, childObject, anchor)
		GameCooltip:Close()

		if (type(index) == "table") then
			index, childObject, anchor = unpack(index)
		end

		if (index and index == -1) then --hide
			Details.StatusBar:ApplyOptions(childObject, "hidden", true)
			return
		else
			Details.StatusBar:ApplyOptions(childObject, "hidden", false)
			childObject.frame.text:Show()
			if (childObject.frame.texture) then
				childObject.frame.texture:Show()
			end
		end

		local pluginMestre = Details.StatusBar.Plugins[index]
		if (not pluginMestre) then
			if (anchor == "left") then
				pluginMestre = Details.StatusBar.Plugins[2]

			elseif (anchor == "center") then
				pluginMestre = Details.StatusBar.Plugins[4]

			elseif (anchor == "right") then
				pluginMestre = Details.StatusBar.Plugins[1]
			end
		end

		local instance = childObject.instance --instance que estamos usando agora

		local chosenChild = nil

		--procura pra ver se ja tem uma criada
		for _, childCreated in ipairs(instance.StatusBar) do
			if (childCreated.mainPlugin == pluginMestre) then
				chosenChild = childCreated
				break
			end
		end

		--se nao tiver cria uma
		if (not chosenChild) then
			chosenChild = Details.StatusBar:CreateStatusBarChildForInstance(childObject.instance, pluginMestre.real_name)
		end

		instance.StatusBar[anchor] = chosenChild
		--copia os atributos do current para o chosen
		local optionsTable = Details.CopyTable(childObject.options)

		if (chosenChild and chosenChild.anchor) then
			--o widget escolhido ja estava sendo mostrado...
			--copia os atributos do chosen para o current
			childObject.options = Details.CopyTable(chosenChild.options)
			instance.StatusBar[chosenChild.anchor] = childObject
		end

		chosenChild.options = optionsTable

		Details.StatusBar:ReloadAnchors(instance)
		Details.StatusBar:UpdateOptions(instance)
	end

	function Details.StatusBar:SetPlugin(instance, absoluteName, anchor)
		if (absoluteName == -1) then --none
			anchor = string.lower(anchor)
			ChoosePlugin(nil, nil, -1, instance.StatusBar[anchor], anchor)
		else
			local index = Details.StatusBar:GetIndexFromAbsoluteName(absoluteName)
			if (index and anchor) then
				anchor = string.lower(anchor)
				ChoosePlugin(nil, nil, index, instance.StatusBar[anchor], anchor)
			end
		end
	end

	--on enter
	local onEnterCooltipTexts = {
		{text = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:14:0:1:512:512:8:70:224:306|t " .. Loc ["STRING_PLUGIN_TOOLTIP_LEFTBUTTON"]},
		{text = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:14:0:1:512:512:8:70:328:409|t " .. Loc ["STRING_PLUGIN_TOOLTIP_RIGHTBUTTON"]}
	}
	local on_enter_backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16}

	local OnEnter = function(frame)
		local instance = frame.child.instance

		Details.OnEnterMainWindow(instance)

		frame:SetBackdrop(on_enter_backdrop)
		frame:SetBackdropColor(0.7, 0.7, 0.7, 0.6)

		GameCooltip:Reset()
		GameCooltip:AddFromTable(onEnterCooltipTexts)
		GameCooltip:SetOption("TextSize", 9)
		GameCooltip:SetWallpaper(1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)

		GameCooltip:SetOption("ButtonHeightMod", -4)
		GameCooltip:SetOption("ButtonsYMod", -4)
		GameCooltip:SetOption("YSpacingMod", -4)
		GameCooltip:SetOption("FixedHeight", 46)

		GameCooltip:ShowCooltip(frame, "tooltip")

		return true
	end

	--on leave
	local OnLeave = function(frame)
		frame:SetBackdrop(nil)
		Details.OnLeaveMainWindow(frame.child.instance)
		Details.popup:Hide()
		return true
	end

	local OnMouseUp = function(frame, mouse)
		if (mouse == "LeftButton") then
			if (not frame.child.Setup) then
				print(Loc ["STRING_STATUSBAR_NOOPTIONS"])
				return
			end
			frame.child:Setup()
		else
			GameCooltip:Reset()
			GameCooltip:SetType("menu")

			GameCooltip:AddMenu(1, ChoosePlugin, -1, frame.child, frame.child.anchor, Loc ["STRING_PLUGIN_CLEAN"], [[Interface\Buttons\UI-GroupLoot-Pass-Down]], true)

			local currentIndex

			for index, thisNameIconTable in ipairs(Details.StatusBar.Menu) do
				GameCooltip:AddMenu(1, ChoosePlugin, {index, frame.child, frame.child.anchor}, nil, nil, thisNameIconTable[1], thisNameIconTable[2], true)
				local pluginMestre = Details.StatusBar.Plugins[index]
				if (pluginMestre and pluginMestre.real_name == frame.child.mainPlugin.real_name) then
					currentIndex = index + 1
				end
			end

			if (currentIndex) then
				GameCooltip:SetLastSelected(1, currentIndex)
			else
				GameCooltip:SetOption("NoLastSelectedBar", true)
			end

			GameCooltip:SetOption("HeightAnchorMod", -12)
			GameCooltip:SetWallpaper(1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
			GameCooltip:ShowCooltip(frame, "menu")
		end

		return true
	end

	--reset micro frames
	function Details.StatusBar:Reset(instance)
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textcolor", {1, 0.82, 0, 1})
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textcolor", {1, 0.82, 0, 1})
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textcolor", {1, 0.82, 0, 1})

		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textface", "Friz Quadrata TT")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textface", "Friz Quadrata TT")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textface", "Friz Quadrata TT")

		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textsize", 9)
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textsize", 9)
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textsize", 9)
	end

	function Details.StatusBar:GetIndexFromAbsoluteName(absoluteName)
		for index, object in ipairs(Details.StatusBar.Plugins) do
			if (object.real_name == absoluteName) then
				return index
			end
		end
	end

	function Details.StatusBar:UpdateOptions(instance)
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textcolor")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textsize")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textface")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textxmod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textymod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "hidden")

		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textcolor")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textsize")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textface")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textxmod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textymod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "hidden")

		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textcolor")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textsize")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textface")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textxmod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textymod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "hidden")
	end

	function Details.StatusBar:UpdateChilds(instance)
		local left = instance.StatusBarSaved.left
		local center = instance.StatusBarSaved.center
		local right = instance.StatusBarSaved.right

		local left_index = Details.StatusBar:GetIndexFromAbsoluteName(left)
		ChoosePlugin(nil, nil, left_index, instance.StatusBar.left, "left")

		local center_index = Details.StatusBar:GetIndexFromAbsoluteName(center)
		ChoosePlugin(nil, nil, center_index, instance.StatusBar.center, "center")

		local right_index = Details.StatusBar:GetIndexFromAbsoluteName(right)
		ChoosePlugin(nil, nil, right_index, instance.StatusBar.right, "right")

		if (instance.StatusBarSaved.options and instance.StatusBarSaved.options[left]) then
			instance.StatusBar.left.options = Details.CopyTable(instance.StatusBarSaved.options[left])
		end

		if (instance.StatusBarSaved.options and instance.StatusBarSaved.options[center]) then
			instance.StatusBar.center.options = Details.CopyTable(instance.StatusBarSaved.options[center])
		end

		if (instance.StatusBarSaved.options and instance.StatusBarSaved.options[right]) then
			instance.StatusBar.right.options = Details.CopyTable(instance.StatusBarSaved.options[right])
		end

		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textcolor")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textsize")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textface")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textxmod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "textymod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.left, "hidden")

		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textcolor")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textsize")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textface")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textxmod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "textymod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.center, "hidden")

		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textcolor")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textsize")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textface")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textxmod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "textymod")
		Details.StatusBar:ApplyOptions(instance.StatusBar.right, "hidden")
	end

	--build-in function for create a frame for an plugin child
	function Details.StatusBar:CreateChildFrame(instance, frameName, width, height)
		--local frame = _detalhes.gump:NewPanel(instance.baseframe.cabecalho.fechar, nil, name..instance:GetInstanceId(), nil, w or DEFAULT_CHILD_WIDTH, h or DEFAULT_CHILD_HEIGHT, false)
		local frame = detailsFramework:NewPanel(instance.baseframe, nil, frameName .. instance:GetInstanceId(), nil, width or DEFAULT_CHILD_WIDTH, height or DEFAULT_CHILD_HEIGHT, false)
		frame:SetFrameLevel(instance.baseframe:GetFrameLevel() + 4)

		--create widgets
		local newLabel = detailsFramework:NewLabel(frame, nil, "$parentText", "text", "0")
		newLabel:SetPoint("right", frame, "right", 0, 0)
		newLabel:SetJustifyH("right")
		Details:SetFontSize(newLabel, 9.8)

		frame:SetHook("OnEnter", OnEnter)
		frame:SetHook("OnLeave", OnLeave)
		frame:SetHook("OnMouseUp", OnMouseUp)
		return frame
	end

	--built-in function for create an table for the plugin child
	function Details.StatusBar:CreateChildTable(instance, mainObject, frame)
		local childTable = {}

		--treat as a class
		setmetatable(childTable, mainObject)

		--default members
		childTable.instance = instance
		childTable.frame = frame
		childTable.text = frame.text
		childTable.mainPlugin = mainObject

		--options table
		childTable.options = instance.StatusBar.options[mainObject.real_name]
		if (instance.StatusBar.options[mainObject.real_name]) then
			childTable.options = instance.StatusBar.options[mainObject.real_name]
		else
			childTable.options = {
			textStyle = 2,
			textColor = {unpack(DEFAULT_CHILD_FONTCOLOR)},
			textSize = DEFAULT_CHILD_FONTSIZE,
			textAlign = 0,
			textXMod = 0,
			textYMod = 0,
			textFace = DEFAULT_CHILD_FONTFACE}
			instance.StatusBar.options[mainObject.real_name] = childTable.options
		end

		Details.StatusBar:ApplyOptions(childTable, "textcolor")
		Details.StatusBar:ApplyOptions(childTable, "textsize")
		Details.StatusBar:ApplyOptions(childTable, "textface")

		Details.StatusBar:ReloadAnchors(instance)

		--table reference on frame widget
		frame.frame.child = childTable

		--adds this new child to parent child container
		mainObject.childs[#mainObject.childs+1] = childTable

		return childTable
	end

	function Details.StatusBar:ApplyOptions(child, option, value)
		option = string.lower(option)

		if (option == "textxmod") then
			if (value == nil) then
				value = child.options.textXMod
			end
			child.options.textXMod = value
			Details.StatusBar:ReloadAnchors(child.instance)

		elseif (option == "textymod") then
			if (value == nil) then
				value = child.options.textYMod
			end
			child.options.textYMod = value
			Details.StatusBar:ReloadAnchors(child.instance)

		elseif (option == "textcolor") then
			if (value == nil) then
				value = child.options.textColor
			end
			child.options.textColor = value
			local r, g, b, a = detailsFramework:ParseColors(child.options.textColor)
			child.text:SetTextColor(r, g, b, a)

		elseif (option == "textsize") then
			if (value == nil) then
				value = child.options.textSize
			end
			child.options.textSize = value or 9
			child:SetFontSize(child.text, child.options.textSize)

		elseif (option == "textface") then
			if (value == nil) then
				value = child.options.textFace
			end
			child.options.textFace = value
			child:SetFontFace(child.text, SharedMedia:Fetch("font", child.options.textFace))

		elseif (option == "hidden") then
			if (value == nil) then
				value = child.options.isHidden
			end
			child.options.isHidden = value

			if (value) then
				child.frame.text:Hide()
				if (child.frame.texture) then
					child.frame.texture:Hide()
				end
			else
				child.frame.text:Show()
				if (child.frame.texture) then
					child.frame.texture:Show()
				end
			end
		else
			if (child[option] and type(child[option]) == "function") then
				child[option](nil, child, value)
			end
		end
	end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BUILT-IN DPS PLUGIN
do
	--Create the plugin Object[1] = frame name on _G[2] options[3] plugin type
	local PDps = Details:NewPluginObject("Details_StatusBarDps", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")

	--handle event "COMBAT_PLAYER_ENTER"
	function PDps:PlayerEnterCombat()
		for index, child in ipairs(PDps.childs) do
			if (child.enabled and child.instance:GetSegment() == 0) then
				child.tick = Details:ScheduleRepeatingTimer("PluginDpsUpdate", 1, child)
			end
		end
	end

	--handle event "COMBAT_PLAYER_LEAVE"
	function PDps:PlayerLeaveCombat()
		for index, child in ipairs(PDps.childs) do
			if (child.tick) then
				Details:CancelTimer(child.tick)
				child.tick = nil
			end
		end
	end

	--handle event "DETAILS_INSTANCE_CHANGESEGMENT"
	function PDps:ChangeSegment(instance, segment)
		for index, child in ipairs(PDps.childs) do
			if (child.enabled and child.instance == instance) then
				Details:PluginDpsUpdate(child)
			end
		end
	end

	--handle event "DETAILS_DATA_RESET"
	function PDps:DataReset()
		for index, child in ipairs(PDps.childs) do
			if (child.enabled) then
				child.text:SetText("0")
			end
		end
	end

	function PDps:Refresh(child)
		Details:PluginDpsUpdate(child)
	end

	--still a little buggy, working on
	function Details:PluginDpsUpdate(child)
		--showing is the combat table which is current shown on instance
		if (child.instance:GetCombat() and not child.instance:GetCombat().__destroyed) then
			--GetCombatTime() return the time length of combat
			local combatTime = child.instance:GetCombat():GetCombatTime()
			if (combatTime < 1) then
				return child.text:SetText("0")
			end

			--GetTotal(attribute, sub attribute, onlyGroup) return the total of requested attribute
			local total = child.instance:GetCombat():GetTotal(child.instance.atributo, child.instance.sub_atributo, true)

			local dps = math.floor(total / combatTime)

			local textStyle = child.options.textStyle
			if (textStyle == 1) then
				child.text:SetText(Details:ToK(dps))

			elseif (textStyle == 2) then
				child.text:SetText(Details:CommaValue(dps))

			else
				child.text:SetText(dps)
			end
		end
	end

	--Create Plugin Frames
	function PDps:CreateChildObject(instance)
		--create main frame and widgets
		--a statusbar frame is made of a panel with a member called 'text' which is a label
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsStatusBarDps", DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PDps, childFrame)
		return newChild
	end

	--Handle events(must have, we'll use direct call to functions)
	function PDps:OnDetailsEvent(event)
		return
	end

	--Install
	--_detalhes:InstallPlugin( Plugin Type | Plugin Display Name | Plugin Icon | Plugin Object | Plugin Real Name )
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_PDPSNAME"], "Interface\\Icons\\Achievement_brewery_3", PDps, "DETAILS_STATUSBAR_PLUGIN_PDPS")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end

	--Register needed events
	--here we are redirecting the event to an specified function, otherwise events need to be handle inside "PDps:OnDetailsEvent(event)"
	Details:RegisterEvent(PDps, "DETAILS_INSTANCE_CHANGESEGMENT", PDps.ChangeSegment)
	Details:RegisterEvent(PDps, "DETAILS_DATA_RESET", PDps.DataReset)
	Details:RegisterEvent(PDps, "COMBAT_PLAYER_ENTER", PDps.PlayerEnterCombat)
	Details:RegisterEvent(PDps, "COMBAT_PLAYER_LEAVE", PDps.PlayerLeaveCombat)
end

---------BUILT-IN SEGMENT PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
	--Create the plugin Object
	local PSegment = Details:NewPluginObject("Details_Segmenter", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PSegment:OnDetailsEvent(event)
		return
	end

	--initialize and reset 'can_schedule' variable
	function PSegment:NewCombat()
		PSegment.can_schedule = 1
		PSegment:Change()
	end

	function PSegment:OnSegmentChange()
		PSegment.can_schedule = 1
		PSegment:Change()
	end

	--on 'can_schedule' timeout, re-run the Change() function
	function PSegment:SchduleGetName()
		PSegment:Change()
	end

	function PSegment:Change()
		for index, child in ipairs(PSegment.childs) do
			if (child.enabled and child.instance:IsEnabled()) then
				child.options.segmentType = child.options.segmentType or 2

				if (not child.instance:GetCombat()) then
					return child.text:SetText(Loc ["STRING_EMPTY_SEGMENT"])
				end

				if (child.instance:GetSegmentId() == DETAILS_SEGMENTID_OVERALL) then
					child.text:SetText(Loc ["STRING_OVERALL"])

				elseif (child.instance:GetSegmentId() == DETAILS_SEGMENTID_CURRENT) then
					if (child.options.segmentType == 1) then
						child.text:SetText(Loc ["STRING_CURRENT"])
					else
						local combatName = Details:GetCurrentCombat():GetCombatName(false, true)

						if (combatName and combatName ~= Loc ["STRING_UNKNOW"]) then
							if (child.options.segmentType == 2) then
								child.text:SetText(combatName)

							elseif (child.options.segmentType == 3) then
								child.text:SetText(combatName)
							end
						else
							child.text:SetText(Loc ["STRING_CURRENT"])
							if (Details.in_combat and PSegment.can_schedule <= 2) then
								PSegment:ScheduleTimer("SchduleGetName", 2)
								PSegment.can_schedule = PSegment.can_schedule + 1
								return
							end
						end
					end

				else --some other segment in the segment container
					if (child.options.segmentType == 1) then
						child.text:SetText(Loc ["STRING_FIGHTNUMBER"] .. child.instance:GetSegmentId())

					else
						local combatName = child.instance:GetCombat():GetCombatName(false, true)
						if (combatName ~= Loc ["STRING_UNKNOW"]) then
							if (child.options.segmentType == 2) then
								child.text:SetText(combatName)

							elseif (child.options.segmentType == 3) then
								child.text:SetText(combatName .. " #" .. child.instance:GetSegmentId())
							end
						else
							if (child.options.segmentType == 2) then
								child.text:SetText(Loc ["STRING_UNKNOW"])

							elseif (child.options.segmentType == 3) then
								child.text:SetText(Loc ["STRING_UNKNOW"] .. " #" .. child.instance:GetSegmentId())
							end
						end
					end
				end
			end
		end
	end

	function PSegment:ExtraOptions()
		--all widgets need to be placed on a table
		local widgets = {}
		--reference of extra window for custom options
		local window = _G.DetailsStatusBarOptions2.MyObject

		--build widgets
		detailsFramework:NewLabel(window, nil, "$parentSegmentOptionLabel", "segmentOptionLabel", Loc ["STRING_PLUGIN_SEGMENTTYPE"])
		window.segmentOptionLabel:SetPoint(10, -15)

		local onSelectSegmentType = function(_, childObject, thisType)
			childObject.options.segmentType = thisType
			PSegment:Change()
		end

		local segmentTypes = {
			{value = 1, label = Loc ["STRING_PLUGIN_SEGMENTTYPE_1"], onclick = onSelectSegmentType, icon = [[Interface\ICONS\Ability_Rogue_KidneyShot]]},
			{value = 2, label = Loc ["STRING_PLUGIN_SEGMENTTYPE_2"], onclick = onSelectSegmentType, icon = [[Interface\ICONS\Achievement_Boss_Ra_Den]]},
			{value = 3, label = Loc ["STRING_PLUGIN_SEGMENTTYPE_3"], onclick = onSelectSegmentType, icon = [[Interface\ICONS\Achievement_Boss_Durumu]]},
		}

		detailsFramework:NewDropDown(window, nil, "$parentSegmentTypeDropdown", "segmentTypeDropdown", 200, 20, function() return segmentTypes end, 1) --func, default
		window.segmentTypeDropdown:SetPoint("left", window.segmentOptionLabel, "right", 2)

		--insert all widgets created on widgets table
		table.insert(widgets, window.segmentOptionLabel)
		table.insert(widgets, window.segmentTypeDropdown)

		--after first call, replace this function with widgets table
		PSegment.ExtraOptions = widgets
	end

	--ExtraOptionsOnOpen is called when options are opened and plugin have custom options
	--here we setup options widgets for get the values of clicked child and also for tell options window what child we are configuring
	function PSegment:ExtraOptionsOnOpen(child)
		_G.DetailsStatusBarOptions2SegmentTypeDropdown.MyObject:SetFixedParameter(child)
		_G.DetailsStatusBarOptions2SegmentTypeDropdown.MyObject:Select(child.options.segmentType, true)
	end

	--Create Plugin Frames(must have)
	function PSegment:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPSegmentInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PSegment, childFrame)
		newChild.options.segmentType = newChild.options.segmentType or 2
		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_PSEGMENTNAME"], "Interface\\Icons\\inv_misc_enchantedscroll", PSegment, "DETAILS_STATUSBAR_PLUGIN_PSEGMENT")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end

	--Register needed events
	Details:RegisterEvent(PSegment, "DETAILS_INSTANCE_CHANGESEGMENT", PSegment.OnSegmentChange)
	Details:RegisterEvent(PSegment, "DETAILS_DATA_RESET", PSegment.Change)
	Details:RegisterEvent(PSegment, "COMBAT_PLAYER_ENTER", PSegment.NewCombat)
end

---------BUILT-IN ATTRIBUTE PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	--Create the plugin Object
	local PAttribute = Details:NewPluginObject("Details_Attribute", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PAttribute:OnDetailsEvent(event)
		return
	end

	function PAttribute:Change(instance)
		if (not instance) then
			instance = self.instance
		end

		for index, child in ipairs(PAttribute.childs) do
			if (child.instance == instance and child.enabled and child.instance:IsEnabled()) then
				local sName = child.instance:GetInstanceAttributeText()
				child.text:SetText(sName)
			end
		end
	end

	function PAttribute:OnEnable()
		self:Change()
	end

	--Create Plugin Frames(must have)
	function PAttribute:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPAttributeInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PAttribute, childFrame)
		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_PATTRIBUTENAME"], "Interface\\Icons\\inv_misc_emberclothbolt", PAttribute, "DETAILS_STATUSBAR_PLUGIN_PATTRIBUTE")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end

	--Register needed events
	Details:RegisterEvent(PAttribute, "DETAILS_INSTANCE_CHANGEATTRIBUTE", PAttribute.Change)
end

---------BUILT-IN CLOCK PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	--Create the plugin Object
	local Clock = Details:NewPluginObject("Details_Clock", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events --must have this function
	function Clock:OnDetailsEvent(event)
		return
	end

	--enter combat
	function Clock:PlayerEnterCombat()
		Clock.tick = Details:ScheduleRepeatingTimer("ClockPluginTick", 1)
	end

	--leave combat
	function Clock:PlayerLeaveCombat()
		Details:CancelTimer(Clock.tick)
	end

	function Details:ClockPluginTickOnSegment()
		Details:ClockPluginTick(true)
	end

	--1 sec tick
	function Details:ClockPluginTick(force)
		for index, childObject in ipairs(Clock.childs) do
			---@type instance
			local instance = childObject.instance
			if (childObject.enabled and instance:IsEnabled()) then
				---@type combat
				local combatObject = instance:GetCombat()
				if (combatObject and not combatObject.__destroyed and ((instance:GetSegmentId() ~= DETAILS_SEGMENTID_OVERALL) or (instance:GetSegmentId() == DETAILS_SEGMENTID_OVERALL and not Details.in_combat) or force)) then
					local timeType = childObject.options.timeType
					if (timeType == 1) then
						local combatTime = combatObject:GetCombatTime()
						local minutos, segundos = math.floor(combatTime/60), math.floor(combatTime%60)
						childObject.text:SetText(minutos .. "m " .. segundos .. "s")

					elseif (timeType == 2) then
						local combatTime = combatObject:GetCombatTime()
						childObject.text:SetText(combatTime .. "s")

					elseif (timeType == 3) then
						local segmentId = instance:GetSegmentId()

						if (segmentId < 1) then
							segmentId = 1
						elseif (segmentId > Details.segments_amount) then
							segmentId = Details.segments_amount
						else
							segmentId = segmentId + 1
						end

						local lastFight = Details:GetCombat(segmentId)
						local currentCombatTime = combatObject:GetCombatTime()

						if (lastFight) then
							childObject.text:SetText(currentCombatTime - lastFight:GetCombatTime() .. "s")
						else
							childObject.text:SetText(currentCombatTime .. "s")
						end
					end
				end
			end
		end
	end

	--on reset
	function Clock:DataReset()
		for index, child in ipairs(Clock.childs) do
			if (child.enabled and child.instance:IsEnabled()) then
				child.text:SetText("0m 0s")
			end
		end
	end

	--this is a fixed member, put all your widgets for custom options inside this function
	--if ExtraOptions isn't preset, secondary options box will be hided and only default options will be show
	function Clock:ExtraOptions()
		--all widgets need to be placed on a table
		local widgets = {}
		--reference of extra window for custom options
		local window = _G.DetailsStatusBarOptions2.MyObject

		--build all your widgets
		detailsFramework:NewLabel(window, nil, "$parentClockTypeLabel", "ClockTypeLabel", Loc ["STRING_PLUGIN_CLOCKTYPE"])
		window.ClockTypeLabel:SetPoint(10, -15)

		local onSelectClockType = function(_, child, thistype)
			child.options.timeType = thistype
			Details:ClockPluginTick()
		end

		local clockTypes = {
			{value = 1, label = Loc ["STRING_PLUGIN_MINSEC"], onclick = onSelectClockType},
			{value = 2, label = Loc ["STRING_PLUGIN_SECONLY"], onclick = onSelectClockType},
			{value = 3, label = Loc ["STRING_PLUGIN_TIMEDIFF"], onclick = onSelectClockType}
		}

		detailsFramework:NewDropDown(window, nil, "$parentClockTypeDropdown", "ClockTypeDropdown", 200, 20, function() return clockTypes end, 1) --func, default
		window.ClockTypeDropdown:SetPoint("left", window.ClockTypeLabel, "right", 2)

		--insert all widgets created on widgets table
		table.insert(widgets, window.ClockTypeLabel)
		table.insert(widgets, window.ClockTypeDropdown)

		--after first call we replace this function with widgets table
		Clock.ExtraOptions = widgets
	end

	--ExtraOptionsOnOpen is called when options are opened and plugin have custom options
	--here we setup options widgets for get the values of clicked child and also for tell options window what child we are configuring
	function Clock:ExtraOptionsOnOpen(child)
		_G.DetailsStatusBarOptions2ClockTypeDropdown.MyObject:SetFixedParameter(child)
		_G.DetailsStatusBarOptions2ClockTypeDropdown.MyObject:Select(child.options.timeType, true)
	end

	--Create Plugin Frames
	function Clock:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsClockInstance"..instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, Clock, childFrame)

		--default text
		newChild.text:SetText("0m 0s")

		--some changes from default options
		if (newChild.options.textXMod == 0) then
			newChild.options.textXMod = 6
		end

		--here we are adding a new option member
		newChild.options.timeType = newChild.options.timeType or 1

		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_CLOCKNAME"], "Interface\\Icons\\Achievement_BG_grab_cap_flagunderXseconds", Clock, "DETAILS_STATUSBAR_PLUGIN_CLOCK")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end

	--Register needed events
	Details:RegisterEvent(Clock, "COMBAT_PLAYER_ENTER", Clock.PlayerEnterCombat)
	Details:RegisterEvent(Clock, "COMBAT_PLAYER_LEAVE", Clock.PlayerLeaveCombat)
	Details:RegisterEvent(Clock, "DETAILS_INSTANCE_CHANGESEGMENT", Details.ClockPluginTickOnSegment)
	Details:RegisterEvent(Clock, "DETAILS_DATA_SEGMENTREMOVED", Details.ClockPluginTick)
	Details:RegisterEvent(Clock, "DETAILS_DATA_RESET", Clock.PlayerLeaveCombat)
	Details:RegisterEvent(Clock, "DETAILS_DATA_SEGMENTREMOVED", Clock.PlayerLeaveCombat)
end

---------BUILT-IN THREAT PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	local _UnitDetailedThreatSituation = UnitDetailedThreatSituation --wow api

	--Create the plugin Object
	local Threat = Details:NewPluginObject("Details_TargetThreat", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events
	function Threat:OnDetailsEvent(event)
		return
	end

	Threat.isTank = nil

	function Threat:PlayerEnterCombat()
		local role = UnitGroupRolesAssigned("player")
		if (role == "TANK") then
			Threat.isTank = true
		else
			Threat.isTank = nil
		end
		Threat.tick = Details:ScheduleRepeatingTimer("ThreatPluginTick", 1)
	end

	function Threat:PlayerLeaveCombat()
		Details:CancelTimer(Threat.tick)
	end

	function Details:ThreatPluginTick()
		for index, child in ipairs(Threat.childs) do
			local instance = child.instance
			if (child.enabled and instance:IsEnabled()) then
				local isTanking, status, threatPercent, rawthreatpct, threatvalue = _UnitDetailedThreatSituation("player", "target")
				if (threatPercent) then
					child.text:SetText(math.floor(threatPercent).."%")
					if (Threat.isTank) then
						child.text:SetTextColor(math.abs(threatPercent - 100) * 0.01, threatPercent * 0.01, 0, 1)
					else
						child.text:SetTextColor(threatPercent * 0.01, math.abs(threatPercent - 100) * 0.01, 0, 1)
					end
				else
					child.text:SetText("0%")
					child.text:SetTextColor(1, 1, 1, 1)
				end
			end
		end
	end

	--Create Plugin Frames
	function Threat:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsThreatInstance"..instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, Threat, childFrame)

		childFrame.widget:RegisterEvent("PLAYER_TARGET_CHANGED")
		childFrame.widget:SetScript("OnEvent", function()
			Details:ThreatPluginTick()
		end)

		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_THREATNAME"], "Interface\\Icons\\Ability_Hunter_ResistanceIsFutile", Threat, "DETAILS_STATUSBAR_PLUGIN_THREAT")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end

	--Register needed events
	Details:RegisterEvent(Threat, "COMBAT_PLAYER_ENTER", Threat.PlayerEnterCombat)
	Details:RegisterEvent(Threat, "COMBAT_PLAYER_LEAVE", Threat.PlayerLeaveCombat)
end

---------BUILT-IN PFS PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
	--Create the plugin Object
	local PFps = Details:NewPluginObject("Details_Statusbar_Fps", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PFps:OnDetailsEvent(event)
		return
	end

	function PFps:UpdateFps()
		self.text:SetText(math.floor(GetFramerate()) .. " fps")
	end

	function PFps:OnDisable()
		self:CancelTimer(self.srt, true)
	end

	function PFps:OnEnable()
		self.srt = self:ScheduleRepeatingTimer("UpdateFps", 1, self)
		self:UpdateFps()
	end

	function PFps:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPFpsInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PFps, childFrame)
		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_FPS"], "Interface\\Icons\\Spell_Shadow_MindTwisting", PFps, "DETAILS_STATUSBAR_PLUGIN_PFPS")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end
end

---------BUILT-IN LATENCY PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	--Create the plugin Object
	local PLatency = Details:NewPluginObject("Details_Statusbar_Latency", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PLatency:OnDetailsEvent(event)
		return
	end

	function PLatency:UpdateLatency()
		local _, _, _, lagWorld = GetNetStats()
		self.text:SetText(math.floor(lagWorld) .. " ms")
	end

	function PLatency:OnDisable()
		self:CancelTimer(self.srt, true)
	end

	function PLatency:OnEnable()
		self.srt = self:ScheduleRepeatingTimer("UpdateLatency", 30, self)
		self:UpdateLatency()
	end

	function PLatency:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPLatencyInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PLatency, childFrame)
		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_LATENCY"], "Interface\\FriendsFrame\\PlusManz-BattleNet", PLatency, "DETAILS_STATUSBAR_PLUGIN_PLATENCY")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end
end

---------BUILT-IN DURABILITY PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	local _GetInventoryItemDurability = GetInventoryItemDurability

	--Create the plugin Object
	local PDurability = Details:NewPluginObject("Details_Statusbar_Latency", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PDurability:OnDetailsEvent(event)
		return
	end

	function PDurability:UpdateDurability()
		local percent, items = 0, 0
		for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
			local durability, maxdurability = _GetInventoryItemDurability(i)
			if (durability and maxdurability) then
				local durabilityPercent = durability / maxdurability * 100
				percent = percent + durabilityPercent
				items = items + 1
			end
		end

		if (items == 0) then
			self.text:SetText(Loc ["STRING_UPTADING"])
			return self:ScheduleTimer("UpdateDurability", 5, self)
		end

		percent = percent / items
		self.text:SetText(math.floor(percent) .. "%")
	end

	function PDurability:OnDisable()
		self.frame.widget:UnregisterEvent("PLAYER_DEAD")
		self.frame.widget:UnregisterEvent("PLAYER_UNGHOST")
		self.frame.widget:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		self.frame.widget:UnregisterEvent("MERCHANT_SHOW")
		self.frame.widget:UnregisterEvent("MERCHANT_CLOSED")
		self.frame.widget:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	end

	function PDurability:OnEnable()
		self.frame.widget:RegisterEvent("PLAYER_DEAD")
		self.frame.widget:RegisterEvent("PLAYER_UNGHOST")
		self.frame.widget:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
		self.frame.widget:RegisterEvent("MERCHANT_SHOW")
		self.frame.widget:RegisterEvent("MERCHANT_CLOSED")
		self.frame.widget:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:UpdateDurability()
	end

	function PDurability:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPDurabilityInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PDurability, childFrame)

		local durabilityTexture = childFrame:CreateTexture(nil, "overlay")
		durabilityTexture:SetTexture("Interface\\AddOns\\Details\\images\\icons")
		durabilityTexture:SetPoint("right", childFrame.text.widget, "left", -2, -1)
		durabilityTexture:SetWidth(10)
		durabilityTexture:SetHeight(10)
		durabilityTexture:SetTexCoord(0.216796875, 0.26171875, 0.0078125, 0.052734375)
		childFrame.texture = durabilityTexture

		childFrame.widget:SetScript("OnEvent", function()
			newChild:UpdateDurability()
		end)

		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_DURABILITY"], "Interface\\ICONS\\INV_Chest_Chain_10", PDurability, "DETAILS_STATUSBAR_PLUGIN_PDURABILITY")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end
end

---------BUILT-IN GOLD PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	--Create the plugin Object
	local PGold = Details:NewPluginObject("Details_Statusbar_Gold", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PGold:OnDetailsEvent(event)
		return
	end

	function PGold:GoldPluginTick()
		for index, child in ipairs(PGold.childs) do
			local instance = child.instance
			if (child.enabled and instance:IsEnabled()) then
				child:UpdateGold()
			end
		end
	end

	function PGold:UpdateGold()
		self.text:SetText(math.floor(GetMoney() / 100 / 100))
	end

	function PGold:OnEnable()
		self:UpdateGold()
	end

	function PGold:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPGoldInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PGold, childFrame)

		local coinTexture = childFrame:CreateTexture(nil, "overlay")
		coinTexture:SetTexture("Interface\\MONEYFRAME\\UI-GoldIcon")
		coinTexture:SetPoint("right", childFrame.text.widget, "left")
		coinTexture:SetWidth(12)
		coinTexture:SetHeight(12)
		childFrame.texture = coinTexture

		childFrame.widget:RegisterEvent("PLAYER_MONEY")
		childFrame.widget:RegisterEvent("PLAYER_ENTERING_WORLD")
		childFrame.widget:SetScript("OnEvent", function(event)
			if (event == "PLAYER_ENTERING_WORLD") then
				return PGold:ScheduleTimer("GoldPluginTick", 10)
			end
			PGold:GoldPluginTick()
		end)

		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_GOLD"], "Interface\\Icons\\INV_Ore_Gold_01", PGold, "DETAILS_STATUSBAR_PLUGIN_PGold")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end
end

---------BUILT-IN TIME PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
do
	--Create the plugin Object
	local PTime = Details:NewPluginObject("Details_Statusbar_Time", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
	--Handle events(must have)
	function PTime:OnDetailsEvent(event)
		return
	end

	function PTime:UpdateClock()
		if (self.options.timeType == 1) then
			self.text:SetText(date("%I:%M %p"))

		elseif (self.options.timeType == 2) then
			self.text:SetText(date("%H:%M"))
		end
	end

	function PTime:OnDisable()
		self:CancelTimer(self.srt, true)
	end

	function PTime:OnEnable()
		self.srt = self:ScheduleRepeatingTimer("UpdateClock", 60, self)
		self:UpdateClock()
	end

	function PTime:ExtraOptions()
		--all widgets need to be placed on a table
		local widgets = {}
		--reference of extra window for custom options
		local window = _G.DetailsStatusBarOptions2.MyObject

		--build all your widgets
		detailsFramework:NewLabel(window, _, "$parentTimeTypeLabel", "TimeTypeLabel", Loc ["STRING_PLUGIN_CLOCKTYPE"])
		window.TimeTypeLabel:SetPoint(10, -15)

		local onSelectClockType = function(_, childObject, thisType)
			childObject.options.timeType = thisType
			childObject:UpdateClock()
		end

		local clockTypes = {
			{value = 1, label = date("%I:%M %p"), onclick = onSelectClockType},
			{value = 2, label = date("%H:%M"), onclick = onSelectClockType}
		}

		detailsFramework:NewDropDown(window, _, "$parentTimeTypeDropdown", "TimeTypeDropdown", 200, 20, function() return clockTypes end, 1) --func, default
		window.TimeTypeDropdown:SetPoint("left", window.TimeTypeLabel, "right", 2)

		--now we insert all widgets created on widgets table
		table.insert(widgets, window.TimeTypeLabel)
		table.insert(widgets, window.TimeTypeDropdown)

		--after first call we replace this function with widgets table
		PTime.ExtraOptions = widgets
	end

	--ExtraOptionsOnOpen is called when options are opened and plugin have custom options
	--here we setup options widgets for get the values of clicked child and also for tell options window what child we are configuring
	function PTime:ExtraOptionsOnOpen(child)
		_G.DetailsStatusBarOptions2TimeTypeDropdown.MyObject:SetFixedParameter(child)
		_G.DetailsStatusBarOptions2TimeTypeDropdown.MyObject:Select(child.options.timeType, true)
	end

	--Create Plugin Frames(must have)
	function PTime:CreateChildObject(instance)
		local childFrame = Details.StatusBar:CreateChildFrame(instance, "DetailsPTimeInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
		local newChild = Details.StatusBar:CreateChildTable(instance, PTime, childFrame)
		newChild.options.timeType = newChild.options.timeType or 1
		return newChild
	end

	--Install
	local install = Details:InstallPlugin("STATUSBAR", Loc ["STRING_PLUGIN_TIME"], "Interface\\Icons\\Spell_Shadow_LastingAfflictions", PTime, "DETAILS_STATUSBAR_PLUGIN_PTIME")
	if (type(install) == "table" and install.error) then
		print(install.errortext)
		return
	end
end

---------default options panel ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--create the options window
	local window = detailsFramework:NewPanel(UIParent, nil, "DetailsStatusBarOptions", nil, 300, 180)
	tinsert(UISpecialFrames, "DetailsStatusBarOptions")
	window:SetPoint("center", UIParent, "center")
	window.locked = false
	window.close_with_right = true
	window.child = nil
	window.instance = nil
	window:SetFrameStrata("FULLSCREEN")
	DetailsFramework:ApplyStandardBackdrop(window)

	local extraWindow = detailsFramework:NewPanel(window, nil, "DetailsStatusBarOptions2", "extra", 300, 180)
	extraWindow:SetPoint("left", window, "right")
	extraWindow.close_with_right = true
	extraWindow.locked = false
	extraWindow:Hide()
	DetailsFramework:ApplyStandardBackdrop(extraWindow)

	extraWindow:SetHook("OnHide", function()
		window:Hide()
	end)

--text style
	detailsFramework:NewLabel(window, _, "$parentTextStyleLabel", "textstyle", Loc ["STRING_PLUGINOPTIONS_TEXTSTYLE"])
	window.textstyle:SetPoint(10, -15)

	local onSelectTextStyle = function(_, child, style)
		window.instance.StatusBar.left.options.textStyle = style
		window.instance.StatusBar.center.options.textStyle = style
		window.instance.StatusBar.right.options.textStyle = style

		if (window.instance.StatusBar.left.Refresh and type(window.instance.StatusBar.left.Refresh) == "function") then
			window.instance.StatusBar.left:Refresh(window.instance.StatusBar.left)
		end

		if (window.instance.StatusBar.center.Refresh and type(window.instance.StatusBar.center.Refresh) == "function") then
			window.instance.StatusBar.center:Refresh(window.instance.StatusBar.center)
		end

		if (window.instance.StatusBar.right.Refresh and type(window.instance.StatusBar.right.Refresh) == "function") then
			window.instance.StatusBar.right:Refresh(window.instance.StatusBar.right)
		end
	end

	local textStyleDropdownFunc = function()
		local textStyle = {
			{value = 1, label = Loc ["STRING_PLUGINOPTIONS_ABBREVIATE"] .. "(105.5K)", onclick = onSelectTextStyle},
			{value = 2, label = Loc ["STRING_PLUGINOPTIONS_COMMA"] .. "(105.500)", onclick = onSelectTextStyle},
			{value = 3, label = Loc ["STRING_PLUGINOPTIONS_NOFORMAT"] .. "(105500)", onclick = onSelectTextStyle}
		}
		return textStyle
	end

	detailsFramework:NewDropDown(window, _, "$parentTextStyleDropdown", "textstyleDropdown", 200, 20, textStyleDropdownFunc, 1) --func, default
	window.textstyleDropdown:SetPoint("left", window.textstyle, "right", 2)

--text color
	detailsFramework:NewLabel(window, _, "$parentTextColorLabel", "textcolor", Loc ["STRING_PLUGINOPTIONS_TEXTCOLOR"])
	window.textcolor:SetPoint(10, -35)

	local selectedColor = function()
		local r, g, b, a = ColorPickerFrame:GetColorRGB()
		window.textcolortexture:SetTexture(r, g, b, a)
		--_detalhes.StatusBar:ApplyOptions(window.child, "textcolor", {r, g, b, a})

		local color = {r, g, b, a}
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.left, "textcolor", color)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.center, "textcolor", color)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.right, "textcolor", color)
	end

	local canceledColor = function()
		local r, g, b, a = unpack(ColorPickerFrame.previousValues)
		window.textcolortexture:SetTexture(r, g, b, a)
		local color = {r, g, b, a}
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.left, "textcolor", color)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.center, "textcolor", color)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.right, "textcolor", color)
	end

	local colorpick = function()
		ColorPickerFrame.func = selectedColor
		ColorPickerFrame.cancelFunc = canceledColor
		ColorPickerFrame.opacityFunc = nil
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame.previousValues = window.child.options.textColor
		ColorPickerFrame:SetParent(window.widget)
		ColorPickerFrame:SetColorRGB(unpack(window.child.options.textColor))
		ColorPickerFrame:Show()
	end

	detailsFramework:NewImage(window, nil, 160, 16, nil, nil, "textcolortexture", "$parentTextColorTexture")
	window.textcolortexture:SetPoint("left", window.textcolor, "right", 2)
	window.textcolortexture:SetTexture(1, 1, 1)

	detailsFramework:NewButton(window, _, "$parentTextColorButton", "textcolorbutton", 160, 20, colorpick)
	window.textcolorbutton:SetPoint("left", window.textcolor, "right", 2)

--text size
	detailsFramework:NewLabel(window, _, "$parentFontSizeLabel", "fonsizeLabel", Loc ["STRING_PLUGINOPTIONS_TEXTSIZE"])
	window.fonsizeLabel:SetPoint(10, -55)

	detailsFramework:NewSlider(window, _, "$parentSliderFontSize", "fonsizeSlider", 170, 20, 7, 20, 1, 1)
	window.fonsizeSlider:SetPoint("left", window.fonsizeLabel, "right", 2)
	window.fonsizeSlider:SetThumbSize(50)

	window.fonsizeSlider:SetHook("OnValueChange", function(self, child, amount)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.left, "textsize", amount)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.center, "textsize", amount)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.right, "textsize", amount)
	end)

--text font
	local onSelectFont = function(_, child, fontName)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.left, "textface", fontName)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.center, "textface", fontName)
		Details.StatusBar:ApplyOptions(window.instance.StatusBar.right, "textface", fontName)
	end

	local buildFontMenu = function()
		local fontObjects = SharedMedia:HashTable("font")
		local fontTable = {}
		for name, fontPath in pairs(fontObjects) do
			fontTable[#fontTable+1] = {value = name, label = name, onclick = onSelectFont, font = fontPath}
		end
		return fontTable
	end

	detailsFramework:NewLabel(window, _, "$parentFontFaceLabel", "fontfaceLabel", Loc ["STRING_PLUGINOPTIONS_FONTFACE"])
	window.fontfaceLabel:SetPoint(10, -75)

	detailsFramework:NewDropDown(window, _, "$parentFontDropdown", "fontDropdown", 170, 20, buildFontMenu, nil)
	window.fontDropdown:SetPoint("left", window.fontfaceLabel, "right", 2)

	window:Hide()

--align mod X
	detailsFramework:NewLabel(window, _, "$parentAlignXLabel", "alignXLabel", Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_X"])
	window.alignXLabel:SetPoint(10, -115)

	detailsFramework:NewSlider(window, _, "$parentSliderAlignX", "alignXSlider", 160, 20, -20, 20, 1, 0)
	window.alignXSlider:SetPoint("left", window.alignXLabel, "right", 2)
	window.alignXSlider:SetThumbSize(40)
	window.alignXSlider:SetHook("OnValueChange", function(self, child, amount)
		Details.StatusBar:ApplyOptions(child, "textxmod", amount)
	end)

--align modY
	detailsFramework:NewLabel(window, _, "$parentAlignYLabel", "alignYLabel", Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_Y"])
	window.alignYLabel:SetPoint(10, -135)

	detailsFramework:NewSlider(window, _, "$parentSliderAlignY", "alignYSlider", 160, 20, -10, 10, 1, 0)
	window.alignYSlider:SetPoint("left", window.alignYLabel, "right", 2)
	window.alignYSlider:SetThumbSize(40)
	window.alignYSlider:SetHook("OnValueChange", function(self, child, amount)
		Details.StatusBar:ApplyOptions(child, "textymod", amount)
	end)

--right click to close
	local rightClickLabel = window:CreateRightClickLabel("short")
	rightClickLabel:SetPoint("bottomleft", window, "bottomleft", 8, 5)

--open options
function Details.StatusBar:OpenOptionsForChild(child)
	window.child = child
	window.instance = child.instance

	_G.DetailsStatusBarOptionsTextStyleDropdown.MyObject:Select(child.options.textStyle, true)

	_G.DetailsStatusBarOptionsTextColorTexture:SetColorTexture(child.options.textColor[1], child.options.textColor[2], child.options.textColor[3], child.options.textColor[4])

	_G.DetailsStatusBarOptionsSliderFontSize.MyObject:SetFixedParameter(child)
	_G.DetailsStatusBarOptionsSliderFontSize.MyObject:SetValue(child.options.textSize)

	_G.DetailsStatusBarOptionsFontDropdown.MyObject:SetFixedParameter(child)
	_G.DetailsStatusBarOptionsFontDropdown.MyObject:Select(child.options.textFace)

	_G.DetailsStatusBarOptionsSliderAlignX.MyObject:SetFixedParameter(child)
	_G.DetailsStatusBarOptionsSliderAlignX.MyObject:SetValue(child.options.textXMod)

	_G.DetailsStatusBarOptionsSliderAlignY.MyObject:SetFixedParameter(child)
	_G.DetailsStatusBarOptionsSliderAlignY.MyObject:SetValue(child.options.textYMod)

	_G.DetailsStatusBarOptions:Show()

	if (child.ExtraOptions) then
		if (type(child.ExtraOptions) == "function") then
			child.ExtraOptions()
		end

		extraWindow:HideWidgets()

		for _, widget in pairs(child.ExtraOptions) do
			widget:Show()
		end

		child:ExtraOptionsOnOpen(child)

		extraWindow:Show()
	else
		extraWindow:Hide()
	end
end