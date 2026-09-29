
--the parts of a details! window the designer section lets the user click, the options shown for each part and
--the details! setter that applies each option

local Details = _G.Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")

local _ = nil

--constants
--every registration is rooted at the window object itself, because for details! a window *is* its settings
--table: instance.row_info.height is both the stored setting and what the renderer reads. so subTablePath is
--always empty and every key below is a full path from the window
local SUBTABLE_PATH = ""
--maps a built-in editor attribute onto a key no window has, which is how the framework's own widget for it
--is suppressed
local SUPPRESSED_KEY = "designer_suppressed_attribute"
--every built-in attribute the editor offers for a Frame, a Button or a StatusBar, all pointed at a key nothing
--holds.
--the framework only drops a built-in widget when its key resolves to nothing, and an empty map falls through to
--the attribute's own lowercase name. a window resolves an unknown key through its metatable onto the details!
--object itself, so an empty map could sprout a widget bound to whatever details! keeps under 'width' or
--'alpha'. every built-in is therefore suppressed by name
local FRAME_KEY_MAP = {
	width = SUPPRESSED_KEY,
	height = SUPPRESSED_KEY,
	alpha = SUPPRESSED_KEY,
	framestrata = SUPPRESSED_KEY,
	anchor = SUPPRESSED_KEY,
	anchoroffsetx = SUPPRESSED_KEY,
	anchoroffsety = SUPPRESSED_KEY,
}
--the same for a FontString, whose built-in set is much larger. the text settings are named through
--extraOptions instead, because details! stores them per window rather than per fontstring
local FONTSTRING_KEY_MAP = {
	text = SUPPRESSED_KEY,
	size = SUPPRESSED_KEY,
	font = SUPPRESSED_KEY,
	color = SUPPRESSED_KEY,
	alpha = SUPPRESSED_KEY,
	shadow = SUPPRESSED_KEY,
	shadowcolor = SUPPRESSED_KEY,
	shadowoffsetx = SUPPRESSED_KEY,
	shadowoffsety = SUPPRESSED_KEY,
	outline = SUPPRESSED_KEY,
	rotation = SUPPRESSED_KEY,
	scale = SUPPRESSED_KEY,
	anchor = SUPPRESSED_KEY,
	anchoroffsetx = SUPPRESSED_KEY,
	anchoroffsety = SUPPRESSED_KEY,
}
--the buttons drawn on the title bar, in the order their setter takes them: mode, segment, attribute, report,
--reset, close
local TOOLBAR_BUTTON_PARTS = {"modo_selecao", "segmento", "atributo", "report", "reset", "fechar"}
--which entry of row_info.texts each half of a bar's text reads. index 1 is the unit name; 2 to 4 are the value
--columns and share one setting, so index 2 is the one bound and the setters carry the change to 3 and 4
local NAME_TEXT_INDEX = 1
local VALUE_TEXT_INDEX = 2
--the same two halves as the setters name them
local NAME_TEXT_SIDE = "left"
local VALUE_TEXT_SIDE = "right"
--the fontstrings a row draws: the unit name on the left and the three value columns on the right. all four
--select the bar texts object. lineText11 to lineText14 are a second set the apocalypse path never fills
local ROW_TEXT_FIELDS = {"lineText1", "lineText2", "lineText3", "lineText4"}
--the frame strata a window may sit in
local STRATA_NAMES = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG"}

---@class details_options_designer_objects : table
Details222.OptionsDesignerObjects = {}

--when the designer last wrote a setting, in game time.
--details! announces every option change with one debounced event that does not say who made it, so the
--designer tells its own edits from someone else's by how recent they are
local lastEditTime = 0

--the game time at which the designer last applied an edit
---@return number
function Details222.OptionsDesignerObjects:GetLastEditTime()
	return lastEditTime
end

--returns the window the options window is editing, the one picked in its dropdown at the top right. every
--edit lands on it; the option tables call this rather than holding a window, so a change of window needs no
--rebuild
---@return instance
local getEditedInstance = function()
	return Details222.OptionsPanel.GetCurrentInstanceInOptionsPanel()
end

--------------- applying a change ---------------

--every apply below calls the setter for that setting rather than writing the key and refreshing. the setters
--do work no refresh can recover: SetBarSettings recomputes row_height from height and spacing, resolves a
--SharedMedia name into the *_file key the renderer reads and parses colours. writing the key then refreshing
--applies about half of any given setting.
--
--the editor has already written the key by the time these run, so each one reads the value back off the window
--and hands it to the setter. that makes every apply idempotent, which the framework requires anyway.

--bars: geometry, textures and colours
---@param instanceObject instance
local applyBarHeight = function(instanceObject)
	instanceObject:SetBarSettings(instanceObject.row_info.height)
end

---@param instanceObject instance
local applyBarSpacing = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.space.between)
end

---@param instanceObject instance
local applyBarTexture = function(instanceObject)
	instanceObject:SetBarSettings(nil, instanceObject.row_info.texture)
end

---@param instanceObject instance
local applyBarClassColor = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, instanceObject.row_info.texture_class_colors)
end

---@param instanceObject instance
local applyBarColor = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, instanceObject.row_info.fixed_texture_color)
end

---@param instanceObject instance
local applyBarAlpha = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.alpha)
end

---@param instanceObject instance
local applyBarBackgroundTexture = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, instanceObject.row_info.texture_background)
end

---@param instanceObject instance
local applyBarBackgroundClassColor = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, instanceObject.row_info.texture_background_class_color)
end

---@param instanceObject instance
local applyBarBackgroundColor = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, instanceObject.row_info.fixed_texture_background_color)
end

--the four backdrop keys share one setter, so all four are passed every time
---@param instanceObject instance
local applyBarBackdrop = function(instanceObject)
	local backdropSettings = instanceObject.row_info.backdrop
	instanceObject:SetBarBackdropSettings(backdropSettings.enabled, backdropSettings.size, backdropSettings.color, backdropSettings.use_class_colors)
end

--bar icons
---@param instanceObject instance
local applyIconSizeOffset = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.icon_size_offset)
end

---@param instanceObject instance
local applyBarStartAfterIcon = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.start_after_icon)
end

--there is no setter for the icon greyscale flag, so the rows are rebuilt
---@param instanceObject instance
local applyIconGrayscale = function(instanceObject)
	instanceObject:InstanceRefreshRows()
end

--bar texts
---@param instanceObject instance
local applyTextColor = function(instanceObject)
	instanceObject:SetBarTextFixedColor(instanceObject.row_info.fixed_text_color)
end

---@param instanceObject instance
local applyTextSize = function(instanceObject)
	instanceObject:SetBarTextFontSize(instanceObject.row_info.font_size)
end

---@param instanceObject instance
local applyTextFont = function(instanceObject)
	instanceObject:SetBarTextFontFace(instanceObject.row_info.font_face)
end

---@param instanceObject instance
local applyTextYOffset = function(instanceObject)
	instanceObject:SetBarTextYOffset(instanceObject.row_info.text_yoffset)
end

---@param instanceObject instance
local applyTextNameOffset = function(instanceObject)
	instanceObject:SetBarTextNameOffset(instanceObject.row_info.textL_offset)
end

---@param instanceObject instance
local applyShowRankNumber = function(instanceObject)
	instanceObject:SetBarTextSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.textL_show_number)
end

---@param instanceObject instance
local applyPercentType = function(instanceObject)
	instanceObject:SetBarTextSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.percent_type)
end

--the per-slot text settings.
--a row draws four texts and row_info.texts holds one settings table each: index 1 is the unit name and 2 to 4
--are the value columns. the setters take the side rather than the index and fan a change across every index
--that side owns, so the options read index 1 for the name and index 2 for the columns.
--these apply straight onto the fontstrings, so they do not depend on which render path the window is using
---@param instanceObject instance
local applyNameClassColor = function(instanceObject)
	instanceObject:SetBarTextClassColor(NAME_TEXT_SIDE, instanceObject.row_info.texts[NAME_TEXT_INDEX].color.byClass)
end

---@param instanceObject instance
local applyValueClassColor = function(instanceObject)
	instanceObject:SetBarTextClassColor(VALUE_TEXT_SIDE, instanceObject.row_info.texts[VALUE_TEXT_INDEX].color.byClass)
end

---@param instanceObject instance
local applyNameOutline = function(instanceObject)
	instanceObject:SetBarTextOutline(NAME_TEXT_SIDE, instanceObject.row_info.texts[NAME_TEXT_INDEX].font.outline)
end

---@param instanceObject instance
local applyValueOutline = function(instanceObject)
	instanceObject:SetBarTextOutline(VALUE_TEXT_SIDE, instanceObject.row_info.texts[VALUE_TEXT_INDEX].font.outline)
end

---@param instanceObject instance
local applyNameShadowColor = function(instanceObject)
	instanceObject:SetBarTextShadowColor(NAME_TEXT_SIDE, instanceObject.row_info.texts[NAME_TEXT_INDEX].shadow.color)
end

---@param instanceObject instance
local applyValueShadowColor = function(instanceObject)
	instanceObject:SetBarTextShadowColor(VALUE_TEXT_SIDE, instanceObject.row_info.texts[VALUE_TEXT_INDEX].shadow.color)
end

--the two axes share one setter, so both are passed every time
---@param instanceObject instance
local applyNameShadowOffset = function(instanceObject)
	local shadowOffset = instanceObject.row_info.texts[NAME_TEXT_INDEX].shadow.offset
	instanceObject:SetBarTextShadowOffset(NAME_TEXT_SIDE, shadowOffset[1], shadowOffset[2])
end

---@param instanceObject instance
local applyValueShadowOffset = function(instanceObject)
	local shadowOffset = instanceObject.row_info.texts[VALUE_TEXT_INDEX].shadow.offset
	instanceObject:SetBarTextShadowOffset(VALUE_TEXT_SIDE, shadowOffset[1], shadowOffset[2])
end

--how the value columns are laid out: aligned in fixed columns, or run together into one formatted string.
--stored as two mutually exclusive flags and the editor only wrote one of them, so the other is derived here.
--it is a setting on details! itself rather than on a window, which is why its option carries the global scope
---@param instanceObject instance
local applyRightTextMode = function(instanceObject)
	Details.righttext_simple_formatting.enabled = not Details.righttext_simple_formatting.use_alignment

	--the columns are anchored off each other and switching mode changes which fontstrings carry which value,
	--so the old strings are cleared before the padding is resolved again and the rows redrawn
	instanceObject:InstanceClearTexts()
	instanceObject:AdjustInLineTextPadding()
	instanceObject:InstanceRefreshRows()
end

--whether the percent column is drawn beside the value columns. the three row_info.textR_show_data flags are
--not used here: the renderer on this client never reads them
---@param instanceObject instance
local applyShowPercent = function(instanceObject)
	instanceObject:SetSimpleFormattingSettings(instanceObject.row_info.show_percent)
	--the aligned columns re-anchor off each other, so their padding is resolved again before the redraw
	instanceObject:AdjustInLineTextPadding()
	instanceObject:InstanceRefreshRows()
end

--title bar
--the four title bar keys share one setter, so all four are passed every time
---@param instanceObject instance
local applyTitleBar = function(instanceObject)
	instanceObject:SetTitleBarSettings(instanceObject.titlebar_shown, instanceObject.titlebar_height, instanceObject.titlebar_texture, instanceObject.titlebar_texture_color)
	instanceObject:RefreshTitleBar()
end

--the title text setter takes every one of its settings positionally and applies only the ones it is given.
--passing all of them every time is what makes a font change land on its own
---@param instanceObject instance
local applyTitleText = function(instanceObject)
	local titleText = instanceObject.attribute_text
	instanceObject:AttributeMenu(
		titleText.enabled,
		titleText.anchor[1],
		titleText.anchor[2],
		titleText.text_face,
		titleText.text_size,
		titleText.text_color,
		titleText.side,
		titleText.shadow,
		titleText.show_timer
	)
end

--the six title bar buttons share one setter, so all six are passed every time
---@param instanceObject instance
local applyToolbarButtons = function(instanceObject)
	local menuIcons = instanceObject.menu_icons
	instanceObject:ToolbarMenuSetButtons(menuIcons[1], menuIcons[2], menuIcons[3], menuIcons[4], menuIcons[5], menuIcons[6])
end

--spacing and the button shadow share one setter
---@param instanceObject instance
local applyToolbarButtonOptions = function(instanceObject)
	local menuIcons = instanceObject.menu_icons
	instanceObject:ToolbarMenuSetButtonsOptions(menuIcons.space, menuIcons.shadow)
end

---@param instanceObject instance
local applyAutoHideMenu = function(instanceObject)
	instanceObject:SetAutoHideMenu(instanceObject.auto_hide_menu.left)
end

---@param instanceObject instance
local applyHideIcon = function(instanceObject)
	instanceObject:HideMainIcon(instanceObject.hide_icon)
end

---@param instanceObject instance
local applyDesaturatedMenu = function(instanceObject)
	instanceObject:DesaturateMenu(instanceObject.desaturated_menu)
end

---@param instanceObject instance
local applyMenuIconSize = function(instanceObject)
	instanceObject:ToolbarMenuButtonsSize(instanceObject.menu_icons_size)
end

--window body
---@param instanceObject instance
local applySkinColor = function(instanceObject)
	local skinColor = instanceObject.color
	instanceObject:InstanceColor(skinColor[1], skinColor[2], skinColor[3], skinColor[4], nil, true)
end

--the second argument spreads the scale across the snap group. it is left off because the callback below
--already decides whether an edit reaches the group, from the "editing group" checkbox
---@param instanceObject instance
local applyWindowScale = function(instanceObject)
	instanceObject:SetWindowScale(instanceObject.window_scale)
end

--exposed as two calls rather than one flag
---@param instanceObject instance
local applySideBars = function(instanceObject)
	if (instanceObject.show_sidebars) then
		instanceObject:ShowSideBars()
	else
		instanceObject:HideSideBars()
	end
end

---@param instanceObject instance
local applyBackdropTexture = function(instanceObject)
	instanceObject:SetBackdropTexture(instanceObject.backdrop_texture)
end

---@param instanceObject instance
local applyStrata = function(instanceObject)
	instanceObject:SetFrameStrata(instanceObject.strata)
end

---@param instanceObject instance
local applyRowAreaAlpha = function(instanceObject)
	instanceObject:SetBackgroundAlpha(instanceObject.bg_alpha)
end

--the three window border keys share one setter
---@param instanceObject instance
local applyWindowBorder = function(instanceObject)
	instanceObject:UpdateFullBorder(instanceObject.fullborder_shown, instanceObject.fullborder_color, instanceObject.fullborder_size)
end

--rounded corners are part of the skin, so the whole skin is re-applied
---@param instanceObject instance
local applyRoundedCorners = function(instanceObject)
	instanceObject:ChangeSkin()
end

--status bar
---@param instanceObject instance
local applyShowStatusBar = function(instanceObject)
	if (instanceObject.show_statusbar) then
		instanceObject:ShowStatusBar()
	else
		instanceObject:HideStatusBar()
	end
end

---@param instanceObject instance
local applyStatusBarColor = function(instanceObject)
	local overlayColor = instanceObject.statusbar_info.overlay
	instanceObject:StatusBarColor(overlayColor[1], overlayColor[2], overlayColor[3], instanceObject.statusbar_info.alpha)
end

---@param instanceObject instance
local applyMicroDisplayLock = function(instanceObject)
	instanceObject:MicroDisplaysLock(instanceObject.micro_displays_locked)
end

--------------- the write path ---------------

--applies one change to one window and then redraws that window from its data.
--several setters clear the bar texts on their way through, InstanceReset and InstanceClearTexts, and leave it
--to a later render to put them back. that render is RefreshMainWindow(-1), which walks Details.tabela_instancias
--and nothing else, and the preview is deliberately not in that container, so on the preview those setters
--would blank the text and nothing would refill it. RefreshInstanceWindow is the per-window half of the same
--render; it costs one render of one window
---@param instanceObject instance
---@param applyFunc fun(instanceObject:instance)
local applyAndRedraw = function(instanceObject, applyFunc)
	applyFunc(instanceObject)
	Details:RefreshInstanceWindow(instanceObject, true)
end

--copies one setting onto a window the editor did not write to, then applies it.
--a colour is copied element by element rather than assigned, because details! holds references to its colour
--tables and replacing one would leave the window painting from a table nothing else knows about
---@param instanceObject instance
---@param applyFunc fun(instanceObject:instance)
---@param profileKey string
---@param value any
local copyAndApply = function(instanceObject, applyFunc, profileKey, value)
	local currentValue = detailsFramework.table.getfrompath(instanceObject, profileKey)

	if (type(value) == "table" and type(currentValue) == "table") then
		for index = 1, #value do
			currentValue[index] = value[index]
		end
	else
		detailsFramework.table.setfrompath(instanceObject, profileKey, value)
	end

	applyAndRedraw(instanceObject, applyFunc)
end

--applies one change to the window being edited, to the rest of its snap group while "editing group" is on,
--and to the preview, so a single edit shows up everywhere it should.
--
--this runs from the registration's callback rather than from each option's setter. the framework calls a
--setter once per member widget and the callback once per edit, and the bar objects register every bar in the
--preview as a member, so a setter would repeat the whole apply eight times for one slider tick
---@param applyByKey table<string, fun(instanceObject:instance)>
---@param isGlobalByKey table<string, boolean>
---@return function
local makeCallback = function(applyByKey, isGlobalByKey)
	return function(object, optionKey, value, profileTable, profileKey)
		local applyFunc = applyByKey[optionKey]
		local editedInstance = getEditedInstance()
		local previewInstance = Details222.OptionsDesignerPreview:GetInstance()
		--a global setting is stored on details! itself rather than on a window, so there is no value to
		--copy anywhere: only the apply travels
		local bIsGlobalSetting = isGlobalByKey[optionKey]

		lastEditTime = GetTime()

		applyAndRedraw(editedInstance, applyFunc)

		if (bIsGlobalSetting) then
			--a global setting already changed for every window, so every window is redrawn rather than only
			--the snap group, the same as InstanceCallDetailsFunc does for the other sections
			for index, instanceObject in Details:ListInstances() do
				--a window created but never opened has no frames behind it and every setter reaches for them
				if (instanceObject ~= editedInstance and instanceObject:IsStarted()) then
					applyAndRedraw(instanceObject, applyFunc)
				end
			end

			applyAndRedraw(previewInstance, applyFunc)
		else
			--the other sections spread a per-window edit across the whole snap group while editing group is
			--on, which is its default; matching it keeps the sections agreeing about what one edit means
			if (Details.options_group_edit) then
				for index, groupInstance in ipairs(editedInstance:GetInstanceGroup()) do
					if (groupInstance ~= editedInstance) then
						copyAndApply(groupInstance, applyFunc, profileKey, value)
					end
				end
			end

			copyAndApply(previewInstance, applyFunc, profileKey, value)
		end

		--a change may have added rows, and a new row arrives with its click and hover scripts on it
		Details222.OptionsDesignerPreview:DeFangRows()
	end
end

--collects the apply function each option carries, and which options are stored on details! itself rather than
--on a window, into the lookups the callback dispatches through
---@param extraOptions table[]
---@return table<string, fun(instanceObject:instance)>, table<string, boolean>
local buildApplyMap = function(extraOptions)
	local applyByKey = {}
	local isGlobalByKey = {}

	for index, optionTable in ipairs(extraOptions) do
		if (optionTable.applyFunc) then
			applyByKey[optionTable.key] = optionTable.applyFunc
			isGlobalByKey[optionTable.key] = optionTable.isGlobalSetting
		end
	end

	return applyByKey, isGlobalByKey
end

--shorthand for one option and the setter that applies it
---@param profileKey string
---@param widgetType string
---@param label string
---@param applyFunc fun(instanceObject:instance)
---@return table
local option = function(profileKey, widgetType, label, applyFunc)
	return {
		key = profileKey,
		widget = widgetType,
		label = label,
		--read by buildApplyMap; the editor ignores fields it does not know
		applyFunc = applyFunc,
	}
end

--adds slider bounds to an option built by option()
---@param optionTable table
---@param minValue number
---@param maxValue number
---@param stepValue number
---@param bUseDecimals boolean|nil
---@return table
local withRange = function(optionTable, minValue, maxValue, stepValue, bUseDecimals)
	optionTable.minvalue = minValue
	optionTable.maxvalue = maxValue
	optionTable.step = stepValue
	optionTable.usedecimals = bUseDecimals
	return optionTable
end

--adds a dropdown list to an option built by option()
---@param optionTable table
---@param listFunc function
---@return table
local withList = function(optionTable, listFunc)
	optionTable.dropdownFunc = listFunc
	return optionTable
end

--adds the tooltip shown while the mouse is over an option built by option()
---@param optionTable table
---@param descriptionText string
---@return table
local withDescription = function(optionTable, descriptionText)
	optionTable.desc = descriptionText
	return optionTable
end

--marks an option as stored on details! itself rather than on the window being edited, and points the editor at
--that table. without the override the key would still resolve, because a window falls through to the details!
--object for any key it does not hold, but it would do so by accident and read as a per-window setting
---@param optionTable table
---@return table
local asGlobalSetting = function(optionTable)
	optionTable.profileTable = Details
	--read by buildApplyMap; the editor ignores fields it does not know
	optionTable.isGlobalSetting = true
	return optionTable
end

--------------- shared dropdown lists ---------------

--builds a sorted dropdown list from one LibSharedMedia category
---@param mediaType string
---@param previewField string|nil the option field that renders a swatch of the media
---@return table
local buildMediaList = function(mediaType, previewField)
	local mediaList = {}

	for mediaName, mediaPath in pairs(SharedMedia:HashTable(mediaType)) do
		local mediaEntry = {value = mediaName, label = mediaName}

		if (previewField) then
			mediaEntry[previewField] = mediaPath
		end

		mediaList[#mediaList + 1] = mediaEntry
	end

	table.sort(mediaList, function(firstEntry, secondEntry)
		return firstEntry.label < secondEntry.label
	end)

	return mediaList
end

--every statusbar texture registered with LibSharedMedia
---@return table
local buildStatusBarTextureList = function()
	return buildMediaList("statusbar", "statusbar")
end

--every font registered with LibSharedMedia
---@return table
local buildFontList = function()
	return buildMediaList("font", "font")
end

--every background texture registered with LibSharedMedia
---@return table
local buildBackgroundList = function()
	return buildMediaList("background", nil)
end

--the two things a bar's percentage can be measured against
---@return table
local buildPercentTypeList = function()
	return {
		{value = 1, label = Loc["STRING_OPTIONS_DESIGNER_PERCENT_OF_TOTAL"]},
		{value = 2, label = Loc["STRING_OPTIONS_DESIGNER_PERCENT_OF_TOP"]},
	}
end

--the frame strata a window may sit in
---@return table
local buildStrataList = function()
	local strataList = {}

	for index, strataName in ipairs(STRATA_NAMES) do
		strataList[#strataList + 1] = {value = strataName, label = strataName}
	end

	return strataList
end

--returns the real game object behind a framework widget.
--every framework constructor returns a lua table wrapping the object, with the object itself under .widget.
--the game's own api rejects the wrapper when it is passed as an argument, and the editor hands every registered
--object to selectButton:SetAllPoints(). a window is built partly with CreateFrame and partly with the
--framework, and the field name does not say which, so every object taken from the preview goes through here
---@param widgetOrWrapper table
---@return table
local unwrapWidget = function(widgetOrWrapper)
	if (widgetOrWrapper.widget) then
		return widgetOrWrapper.widget
	end

	return widgetOrWrapper
end

--collects the same widget from every bar in the preview, so clicking any bar selects the same entry.
--the framework takes an array as the registered object and gives every member its own click overlay while
--showing one row in the object list; all members share a widget type because they are the same field of
--identical rows
---@param previewInstance instance
---@param widgetField string
---@return table[]
local collectBarWidgets = function(previewInstance, widgetField)
	local barWidgets = {}

	for index, rowFrame in ipairs(previewInstance.barras) do
		barWidgets[#barWidgets + 1] = unwrapWidget(rowFrame[widgetField])
	end

	return barWidgets
end

--collects every fontstring every bar in the preview draws, so one registration covers the unit name and the
--value columns alike. all four are children of the same border frame, so their overlays land on one frame
--level and none of them can steal a click from another
---@param previewInstance instance
---@return table[]
local collectBarTextWidgets = function(previewInstance)
	local textWidgets = {}

	for index, rowFrame in ipairs(previewInstance.barras) do
		for fieldIndex, widgetField in ipairs(ROW_TEXT_FIELDS) do
			textWidgets[#textWidgets + 1] = unwrapWidget(rowFrame[widgetField])
		end
	end

	return textWidgets
end

--collects the title bar's buttons, so clicking any of them selects the same entry. the reset and close buttons
--are raw frames and the other four framework buttons; once unwrapped they report the same object type, which a
--multi-member registration requires
---@param previewInstance instance
---@return table[]
local collectToolbarButtons = function(previewInstance)
	local toolbarButtons = {}
	local toolbar = previewInstance.baseframe.cabecalho

	for index, partName in ipairs(TOOLBAR_BUTTON_PARTS) do
		toolbarButtons[#toolbarButtons + 1] = unwrapWidget(toolbar[partName])
	end

	return toolbarButtons
end

--------------- the registrations ---------------

--each function below describes one part of a window the designer lets the user click: the preview widget
--that selects it, the id the editor tracks it by, and the options shown when it is selected. the profile
--table is not here: the designer supplies it, because it changes when another window is picked for editing.
--
--they are one function each rather than one list because lua allows a closure only 60 upvalues, and a single
--function naming every apply function and every helper went past that

---@param previewInstance instance
---@return table
local buildWindowRegistration = function(previewInstance)
	return {
		id = "WINDOW",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_WINDOW"],
		Object = unwrapWidget(previewInstance.baseframe),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			{key = "color", widget = "color", label = Loc["STRING_OPTIONS_WINDOW_SKIN_COLOR"],
				applyFunc = applySkinColor},
			withRange(option("window_scale", "range", Loc["STRING_OPTIONS_WINDOW_SCALE"], applyWindowScale), 0.65, 1.5, 0.02, true),
			option("show_sidebars", "toggle", Loc["STRING_OPTIONS_SHOW_SIDEBARS"], applySideBars),
			withList(option("backdrop_texture", "select", Loc["STRING_OPTIONS_INSTANCE_BACKDROP"], applyBackdropTexture), buildBackgroundList),
			withList(option("strata", "select", Loc["STRING_OPTIONS_INSTANCE_STRATA"], applyStrata), buildStrataList),
			{widget = "blank"},
			withRange(option("bg_alpha", "range", Loc["STRING_OPTIONS_DESIGNER_ROW_AREA_ALPHA"], applyRowAreaAlpha), 0, 1, 0.01, true),
			option("rounded_corner_enabled", "toggle", Loc["STRING_OPTIONS_DESIGNER_ROUNDED_CORNERS"], applyRoundedCorners),
			{widget = "blank"},
			option("fullborder_shown", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_WINDOW_BORDER"], applyWindowBorder),
			{key = "fullborder_color", widget = "color", label = Loc["STRING_OPTIONS_DESIGNER_BORDER_COLOR"],
				applyFunc = applyWindowBorder},
			withRange(option("fullborder_size", "range", Loc["STRING_OPTIONS_DESIGNER_BORDER_THICKNESS"], applyWindowBorder), 0, 5, 0.5, true),
		},
	}
end

---@param previewInstance instance
---@return table
local buildTitleBarRegistration = function(previewInstance)
	return {
		id = "TITLEBAR",
		label = Loc["STRING_OPTIONSMENU_TITLEBAR"],
		--baseframe.cabecalho holds the toolbar's parts but is a plain lua table, so the frame the title bar
		--draws into is used instead. it exists and is clickable even while the custom title bar is switched
		--off, which is what lets the user reach the setting that turns it on
		Object = unwrapWidget(previewInstance.baseframe.titleBar),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			option("titlebar_shown", "toggle", Loc["STRING_OPTIONS_DESIGNER_TITLEBAR_ENABLED"], applyTitleBar),
			withRange(option("titlebar_height", "range", Loc["STRING_OPTIONS_DESIGNER_TITLEBAR_HEIGHT"], applyTitleBar), 0, 32, 1),
			withList(option("titlebar_texture", "select", Loc["STRING_TEXTURE"], applyTitleBar), buildStatusBarTextureList),
			{key = "titlebar_texture_color", widget = "color", label = Loc["STRING_COLOR"],
				applyFunc = applyTitleBar},
		},
	}
end

---@param previewInstance instance
---@return table
local buildTitleTextRegistration = function(previewInstance)
	return {
		id = "TITLETEXT",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_TITLETEXT"],
		--a frame of the preview's own, pinned over the title text, rather than the fontstring itself: the
		--fontstring is only anchored while the title text is on, and it carries no frame level, so the title
		--bar won every click. designer_preview.lua deals with both. the object is a frame, so the frame
		--built-ins are the ones to suppress
		Object = Details222.OptionsDesignerPreview:GetTitleTextClickTarget(),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			option("attribute_text.enabled", "toggle", Loc["STRING_OPTIONS_DESIGNER_TITLE_TEXT_ENABLED"], applyTitleText),
			withRange(option("attribute_text.text_size", "range", Loc["STRING_OPTIONS_TEXT_SIZE"], applyTitleText), 5, 32, 1),
			{key = "attribute_text.text_color", widget = "color", label = Loc["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR"],
				applyFunc = applyTitleText},
			withList(option("attribute_text.text_face", "select", Loc["STRING_OPTIONS_TEXT_FONT"], applyTitleText), buildFontList),
			option("attribute_text.shadow", "toggle", Loc["STRING_OPTIONS_TEXT_LOUTILINE"], applyTitleText),
			{widget = "blank"},
			withRange(option("attribute_text.anchor[1]", "range", Loc["STRING_OPTIONS_DESIGNER_TEXT_X_OFFSET"], applyTitleText), -30, 300, 1),
			withRange(option("attribute_text.anchor[2]", "range", Loc["STRING_OPTIONS_DESIGNER_TEXT_Y_OFFSET"], applyTitleText), -100, 50, 1),
			option("attribute_text.show_timer", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_ENCOUNTER_TIMER"], applyTitleText),
		},
	}
end

---@param previewInstance instance
---@return table
local buildTitleButtonsRegistration = function(previewInstance)
	return {
		id = "TITLEBUTTONS",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_TITLEBUTTONS"],
		Object = collectToolbarButtons(previewInstance),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			withRange(option("menu_icons_size", "range", Loc["STRING_OPTIONS_DESIGNER_MENU_ICON_SIZE"], applyMenuIconSize), 0.4, 1.6, 0.05, true),
			withRange(option("menu_icons.space", "range", Loc["STRING_OPTIONS_DESIGNER_MENU_ICON_SPACING"], applyToolbarButtonOptions), -5, 10, 1),
			option("menu_icons.shadow", "toggle", Loc["STRING_OPTIONS_TEXT_LOUTILINE"], applyToolbarButtonOptions),
			option("desaturated_menu", "toggle", Loc["STRING_OPTIONS_DESIGNER_DESATURATED_MENU"], applyDesaturatedMenu),
			option("auto_hide_menu.left", "toggle", Loc["STRING_OPTIONS_MENU_AUTOHIDE_LEFT"], applyAutoHideMenu),
			option("hide_icon", "toggle", Loc["STRING_OPTIONS_HIDE_ICON"], applyHideIcon),
			{widget = "blank"},
			--a label row takes its content from 'text'; built with 'label' it renders blank
			{widget = "label", text = Loc["STRING_OPTIONS_DESIGNER_WHICH_BUTTONS"]},
			option("menu_icons[1]", "toggle", Loc["STRING_OPTIONS_DESIGNER_BUTTON_MODE"], applyToolbarButtons),
			option("menu_icons[2]", "toggle", Loc["STRING_SEGMENT"], applyToolbarButtons),
			option("menu_icons[3]", "toggle", Loc["STRING_OPTIONSMENU_DISPLAY"], applyToolbarButtons),
			option("menu_icons[4]", "toggle", Loc["STRING_REPORT_TEXT"], applyToolbarButtons),
			option("menu_icons[5]", "toggle", Loc["STRING_OPTIONS_SPELL_RESET"], applyToolbarButtons),
			option("menu_icons[6]", "toggle", Loc["STRING_OPTIONS_WC_CLOSE"], applyToolbarButtons),
		},
	}
end

---@param previewInstance instance
---@return table
local buildBarsRegistration = function(previewInstance)
	return {
		id = "BARS",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_BARS"],
		Object = collectBarWidgets(previewInstance, "statusbar"),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			withRange(option("row_info.height", "range", Loc["STRING_OPTIONS_BAR_HEIGHT"], applyBarHeight), 10, 30, 1),
			withRange(option("row_info.space.between", "range", Loc["STRING_OPTIONS_BAR_SPACING"], applyBarSpacing), -2, 10, 1),
			withList(option("row_info.texture", "select", Loc["STRING_TEXTURE"], applyBarTexture), buildStatusBarTextureList),
			option("row_info.texture_class_colors", "toggle", Loc["STRING_OPTIONS_DESIGNER_COLOR_BY_CLASS"], applyBarClassColor),
			{key = "row_info.fixed_texture_color", widget = "color", label = Loc["STRING_COLOR"],
				applyFunc = applyBarColor},
			--an alpha of exactly zero is skipped by the setter, so the slider stops just above it
			withRange(option("row_info.alpha", "range", Loc["STRING_OPTIONS_DESIGNER_BAR_ALPHA"], applyBarAlpha), 0.01, 1, 0.01, true),
			{widget = "blank"},
			withList(option("row_info.texture_background", "select", Loc["STRING_OPTIONS_INSTANCE_BACKDROP"], applyBarBackgroundTexture), buildStatusBarTextureList),
			option("row_info.texture_background_class_color", "toggle", Loc["STRING_OPTIONS_DESIGNER_BACKGROUND_BY_CLASS"], applyBarBackgroundClassColor),
			{key = "row_info.fixed_texture_background_color", widget = "color", label = Loc["STRING_OPTIONS_BAR_BCOLOR"],
				applyFunc = applyBarBackgroundColor},
			{widget = "blank"},
			option("row_info.backdrop.enabled", "toggle", Loc["STRING_OPTIONS_DESIGNER_BAR_BORDER"], applyBarBackdrop),
			{key = "row_info.backdrop.color", widget = "color", label = Loc["STRING_OPTIONS_DESIGNER_BORDER_COLOR"],
				applyFunc = applyBarBackdrop},
			--the bars section slider is 0 to 10 while the default is 12, so the upper bound covers the default
			withRange(option("row_info.backdrop.size", "range", Loc["STRING_OPTIONS_DESIGNER_BORDER_THICKNESS"], applyBarBackdrop), 0, 16, 1),
		},
	}
end

---@param previewInstance instance
---@return table
local buildBarTextsRegistration = function(previewInstance)
	return {
		id = "BARTEXTS",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_BARTEXTS"],
		Object = collectBarTextWidgets(previewInstance),
		profileKeyMap = FONTSTRING_KEY_MAP,
		--a row draws four texts: the unit name, and three value columns which share one set of settings. the
		--options are grouped the same way, because that is the only division the user can act on
		extraOptions = {
			{key = "row_info.fixed_text_color", widget = "color", label = Loc["STRING_OPTIONS_TEXT_FIXEDCOLOR"],
				applyFunc = applyTextColor},
			withRange(option("row_info.font_size", "range", Loc["STRING_OPTIONS_TEXT_SIZE"], applyTextSize), 5, 32, 1),
			withList(option("row_info.font_face", "select", Loc["STRING_OPTIONS_TEXT_FONT"], applyTextFont), buildFontList),
			withRange(option("row_info.text_yoffset", "range", Loc["STRING_OPTIONS_DESIGNER_TEXT_Y_OFFSET"], applyTextYOffset), -10, 10, 1),
			withList(option("row_info.percent_type", "select", Loc["STRING_OPTIONS_DESIGNER_PERCENT_TYPE"], applyPercentType), buildPercentTypeList),
			{widget = "blank"},

			{widget = "label", text = Loc["STRING_OPTIONS_DESIGNER_NAME_TEXT"]},
			option("row_info.textL_show_number", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_RANK_NUMBER"], applyShowRankNumber),
			withRange(option("row_info.textL_offset", "range", Loc["STRING_OPTIONS_DESIGNER_NAME_OFFSET"], applyTextNameOffset), -10, 50, 1),
			option("row_info.texts[1].color.byClass", "toggle", Loc["STRING_OPTIONS_DESIGNER_COLOR_BY_CLASS"], applyNameClassColor),
			option("row_info.texts[1].font.outline", "selectoutline", Loc["STRING_OPTIONS_DESIGNER_TEXT_OUTLINE"], applyNameOutline),
			{key = "row_info.texts[1].shadow.color", widget = "color", label = Loc["STRING_OPTIONS_TEXT_SHADOWCOLOR"],
				applyFunc = applyNameShadowColor},
			withRange(option("row_info.texts[1].shadow.offset[1]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_X"], applyNameShadowOffset), -5, 5, 1),
			withRange(option("row_info.texts[1].shadow.offset[2]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_Y"], applyNameShadowOffset), -5, 5, 1),
			{widget = "blank"},

			{widget = "label", text = Loc["STRING_OPTIONS_DESIGNER_VALUE_TEXT"]},
			option("row_info.texts[2].color.byClass", "toggle", Loc["STRING_OPTIONS_DESIGNER_COLOR_BY_CLASS"], applyValueClassColor),
			option("row_info.texts[2].font.outline", "selectoutline", Loc["STRING_OPTIONS_DESIGNER_TEXT_OUTLINE"], applyValueOutline),
			{key = "row_info.texts[2].shadow.color", widget = "color", label = Loc["STRING_OPTIONS_TEXT_SHADOWCOLOR"],
				applyFunc = applyValueShadowColor},
			withRange(option("row_info.texts[2].shadow.offset[1]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_X"], applyValueShadowOffset), -5, 5, 1),
			withRange(option("row_info.texts[2].shadow.offset[2]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_Y"], applyValueShadowOffset), -5, 5, 1),
			withDescription(
				option("row_info.show_percent", "toggle", Loc["STRING_OPTIONS_TEXT_SHOW_PERCENT"], applyShowPercent),
				Loc["STRING_OPTIONS_DESIGNER_SHOW_PERCENT_DESC"]
			),
			withDescription(
				asGlobalSetting(option("righttext_simple_formatting.use_alignment", "toggle", Loc["STRING_OPTIONS_DESIGNER_ALIGN_COLUMNS"], applyRightTextMode)),
				Loc["STRING_OPTIONS_DESIGNER_ALIGN_COLUMNS_DESC"]
			),
		},
	}
end

---@param previewInstance instance
---@return table
local buildBarIconsRegistration = function(previewInstance)
	return {
		id = "BARICONS",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_BARICONS"],
		Object = collectBarWidgets(previewInstance, "icon_frame"),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			withRange(option("row_info.icon_size_offset", "range", Loc["STRING_OPTIONS_DESIGNER_ICON_SIZE_OFFSET"], applyIconSizeOffset), -20, 20, 0.5, true),
			option("row_info.start_after_icon", "toggle", Loc["STRING_OPTIONS_DESIGNER_BAR_START_AFTER_ICON"], applyBarStartAfterIcon),
			option("row_info.icon_grayscale", "toggle", Loc["STRING_OPTIONS_DESIGNER_ICON_GRAYSCALE"], applyIconGrayscale),
			--row_info.show_faction_icon and row_info.faction_icon_size_offset are deliberately not offered: the
			--only code reading them is Details:SetBarLeftText, on the legacy render path this client never takes
		},
	}
end

---@param previewInstance instance
---@return table
local buildStatusBarRegistration = function(previewInstance)
	return {
		id = "STATUSBAR",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_STATUSBAR"],
		Object = unwrapWidget(previewInstance.baseframe.statusbar),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			option("show_statusbar", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_STATUSBAR"], applyShowStatusBar),
			{key = "statusbar_info.overlay", widget = "color", label = Loc["STRING_COLOR"],
				applyFunc = applyStatusBarColor},
			withRange(option("statusbar_info.alpha", "range", Loc["STRING_OPTIONS_DESIGNER_BAR_ALPHA"], applyStatusBarColor), 0, 1, 0.01, true),
			option("micro_displays_locked", "toggle", Loc["STRING_OPTIONS_MICRODISPLAY_LOCK"], applyMicroDisplayLock),
		},
	}
end

--every part of a window the designer lets the user click, in the order they appear in the object list
---@param previewInstance instance
---@return table[]
function Details222.OptionsDesignerObjects:GetRegistrations(previewInstance)
	return {
		buildWindowRegistration(previewInstance),
		buildTitleBarRegistration(previewInstance),
		buildTitleTextRegistration(previewInstance),
		buildTitleButtonsRegistration(previewInstance),
		buildBarsRegistration(previewInstance),
		buildBarTextsRegistration(previewInstance),
		buildBarIconsRegistration(previewInstance),
		buildStatusBarRegistration(previewInstance),
	}
end

--returns the sub-table path every registration is rooted at
---@return string
function Details222.OptionsDesignerObjects:GetSubTablePath()
	return SUBTABLE_PATH
end

--returns the window every edit is written to
---@return instance
function Details222.OptionsDesignerObjects:GetEditedInstance()
	return getEditedInstance()
end

--builds the callback that applies one registration's edits. the framework calls it once per edit no matter
--how many member widgets the registration covers
---@param registration table
---@return function
function Details222.OptionsDesignerObjects:BuildCallback(registration)
	return makeCallback(buildApplyMap(registration.extraOptions))
end
