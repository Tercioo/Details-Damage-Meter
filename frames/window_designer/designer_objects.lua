
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
--which entry of row_info.texts each half of a bar's text reads. index 1 is the unit name; 2 to 4 are the value
--columns and share one setting, so index 2 is the one bound and the setters carry the change to 3 and 4
local NAME_TEXT_INDEX = 1
local VALUE_TEXT_INDEX = 2
--the same two halves as the setters name them
local NAME_TEXT_SIDE = "left"
local VALUE_TEXT_SIDE = "right"
--the fontstrings a row draws: the unit name on the left, which selects the bar unit name object, and the three
--value columns on the right, which select the bar values object. lineText11 to lineText14 are a second set the
--apocalypse path never fills
local NAME_TEXT_FIELDS = {"lineText1"}
local VALUE_TEXT_FIELDS = {"lineText2", "lineText3", "lineText4"}
--the two sides of a bar's text that carry their own color, size, font and vertical offset: which entries of
--row_info.texts each covers, and the prefix of its keys in textStyleMirror
local NAME_TEXT_STYLE = {keyPrefix = "nameText", indexes = {1}}
local VALUE_TEXT_STYLE = {keyPrefix = "valueText", indexes = {2, 3, 4}}
--what follows a side's prefix in each of its textStyleMirror keys
local TEXT_COLOR_SUFFIX = "Color"
local TEXT_SIZE_SUFFIX = "Size"
local TEXT_FONT_SUFFIX = "Font"
local TEXT_Y_OFFSET_SUFFIX = "YOffset"
--the frame strata a window may sit in
local STRATA_NAMES = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG"}
--the characters the classic right text may use, the same the bars texts section offers. "NONE" uses none
local SEPARATOR_VALUES = {",", ".", ";", "-", "|", "/", "\\", "~"}
local BRACKET_VALUES = {"(", "{", "[", "<"}
local NO_CHARACTER_VALUE = "NONE"
--the value columns the classic column offset sliders move, leftmost first. text 1 is the unit name
local VALUE_COLUMN_INDEXES = {2, 3, 4}
--the preview always draws the total bar on its first row, so the player bars start at the second
local TOTAL_BAR_ROW_INDEX = 1
local FIRST_PLAYER_ROW_INDEX = 2
--the keys the icon set dropdown and the custom icon path read from iconSetMirror. two keys because the editor
--tells widgets apart by key, and both show the same setting
local ICON_SET_KEY = "iconSet"
local CUSTOM_ICON_SET_KEY = "customIconSet"
--a custom icon set path containing this is a specialization set, the same test the bars section used
local SPEC_ICON_PATH_PATTERN = "spec_"
--the custom bar texture path that means none is used
local NO_CUSTOM_TEXTURE = ""
--the icon on the button that clears the custom bar texture
local REMOVE_ICON = [[Interface\Buttons\UI-GroupLoot-Pass-Down]]
--the two directions the bars can grow and be sorted in, with the arrow the dropdowns show for each
local GROW_TOP_TO_BOTTOM = 1
local GROW_BOTTOM_TO_TOP = 2
local SORT_DESCENDING = 1
local SORT_ASCENDING = 2
local ARROW_ICON = [[Interface\Calendar\MoreArrow]]
local ARROW_ICON_SIZE = {14, 14}
local ARROW_DOWN_TEXCOORD = {0, 1, 0, 0.7}
local ARROW_UP_TEXCOORD = {0, 1, 0.7, 0}

---@class details_options_designer_objects : table
Details222.OptionsDesignerObjects = {}

--when the designer last wrote a setting, in game time.
--details! announces every option change with one debounced event that does not say who made it, so the
--designer tells its own edits from someone else's by how recent they are
local lastEditTime = 0

--rebuilds the open option menu; the designer supplies it
local menuRefreshFunc = nil

--enables and disables the options of the open menu to match the window, without rebuilding it; the designer
--supplies it
local disabledRefreshFunc = nil

--the value column offsets on the classic versions, as the sliders show them.
--details! stores each offset negated, and at a different place depending on whether auto align chains the
--columns, so the sliders cannot be bound to a key of the window the way every other option is. the editor reads
--and writes this table instead, SeedMirrors fills it from the window being edited, and the options' own setter
--hands the value to details!
local columnOffsetMirror = {}

--the option tables of the column offset sliders, kept so SeedMirrors can set their ranges. empty on retail
local columnOffsetOptions = {}

--the column layout of the window the mirror was last filled from, see getColumnLayout
local seededColumnLayout = ""

--the icon set the bars draw, as the icon set options show it.
--details! keeps a class icon set in row_info.icon_file and a specialization set in row_info.spec_file with
--row_info.use_spec_icons switched on, so no single key of the window holds it. the editor reads and writes this
--table instead, SeedMirrors fills it from the window being edited, and applyIconSet hands the value to details!
local iconSetMirror = {}

--the color, size, font and vertical offset of each side of a bar's text, as the text options show them.
--details! keeps them per text in row_info.texts, but a text never given its own value leaves the key empty and
--draws with the one every text shares, and the editor shows no widget for an empty key. the editor reads and
--writes this table instead, SeedMirrors fills it with what each side really draws, and the text style applies
--write the value onto every text of that side
local textStyleMirror = {}

--describes how a window lays its value columns out on the classic versions: whether they are aligned and
--whether they chain onto each other. the column offset sliders mean something different in each layout
---@param instanceObject instance
---@return string
local getColumnLayout = function(instanceObject)
	return tostring(instanceObject.use_multi_fontstrings) .. tostring(instanceObject.use_auto_align_multi_fontstrings)
end

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

--the custom texture is a path under Interface\ that replaces the top texture while it is not empty
---@param instanceObject instance
local applyBarCustomTexture = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.texture_custom)
end

---@param instanceObject instance
local clearBarCustomTexture = function(instanceObject)
	instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, NO_CUSTOM_TEXTURE)
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

--the overlay texture and its color share one setter, so both are passed every time
---@param instanceObject instance
local applyBarOverlay = function(instanceObject)
	instanceObject:SetBarOverlaySettings(instanceObject.row_info.overlay_texture, instanceObject.row_info.overlay_color)
end

---@param instanceObject instance
local applyBarGrowDirection = function(instanceObject)
	instanceObject:SetBarGrowDirection(instanceObject.bars_grow_direction)
end

--the settings with no setter that every render reads: the bar highlight, always show me, the sort order and
--the arena team colors. the redraw applyAndRedraw does after every apply is all they need
---@param instanceObject instance
local applyOnRedraw = function(instanceObject)
end

--bar icons
--the arena role icon and its size share one setter, so both are passed every time
---@param instanceObject instance
local applyArenaRoleIcon = function(instanceObject)
	instanceObject:SetBarArenaRoleIconSettings(instanceObject.row_info.show_arena_role_icon, instanceObject.row_info.arena_role_icon_size_offset)
end

--returns the icon set a window's bars draw
---@param instanceObject instance
---@return string
local getIconSet = function(instanceObject)
	local rowInfo = instanceObject.row_info

	if (rowInfo.use_spec_icons) then
		return rowInfo.spec_file
	end

	return rowInfo.icon_file
end

--tells whether an icon set holds specialization icons rather than class icons. a set from the dropdown says
--so itself; a path typed by hand is judged by its name
---@param iconSet string
---@return boolean
local isSpecIconSet = function(iconSet)
	for index, iconSetEntry in ipairs(Details222.BarIconSetList) do
		if (iconSetEntry.value == iconSet) then
			return iconSetEntry.isSpec and true or false
		end
	end

	return iconSet:find(SPEC_ICON_PATH_PATTERN) ~= nil
end

--switches the icon set a window's bars draw, see iconSetMirror
---@param instanceObject instance
---@param iconSet string
local applyIconSet = function(instanceObject, iconSet)
	--the editor runs the callback for every widget each time it builds the menu, and switching the set resets
	--the window, so a set the window already draws is left alone
	if (iconSet == getIconSet(instanceObject)) then
		return
	end

	if (isSpecIconSet(iconSet)) then
		instanceObject:SetBarSpecIconSettings(true, iconSet, true)
	else
		instanceObject:SetBarSettings(nil, nil, nil, nil, nil, nil, nil, nil, iconSet)

		if (instanceObject.row_info.use_spec_icons) then
			instanceObject:SetBarSpecIconSettings(false)
		end
	end
end

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
--the color, size, font and vertical offset of one side of a bar's text, see textStyleMirror.
--each apply reads what the side draws off its first text and leaves the window alone when the value is the
--same: the editor runs the callback for every widget each time it builds the menu, and writing then would give
--a side that inherits the shared value one of its own just by opening the menu

--returns the name LibSharedMedia registered a font file under, or nil for a file it does not know
---@param fontFile string
---@return string|nil
local getFontName = function(fontFile)
	for fontName, fontPath in pairs(SharedMedia:HashTable("font")) do
		if (fontPath == fontFile) then
			return fontName
		end
	end
end

---@param instanceObject instance
---@param textIndexes number[]
---@param color table
local applyTextStyleColor = function(instanceObject, textIndexes, color)
	local _, _, currentColor = Details222.RowTexts.ResolveStyle(instanceObject, textIndexes[1])
	local alpha = color[4] or 1

	if (currentColor[1] == color[1] and currentColor[2] == color[2] and currentColor[3] == color[3] and (currentColor[4] or 1) == alpha) then
		return
	end

	for index, textIndex in ipairs(textIndexes) do
		--a table each, so the texts never share one inside savedvariables
		instanceObject.row_info.texts[textIndex].color.fixed = {color[1], color[2], color[3], alpha}
	end

	Details222.RowTexts.ApplyStyleToAllRows(instanceObject)
end

---@param instanceObject instance
---@param textIndexes number[]
---@param fontSize number
local applyTextStyleSize = function(instanceObject, textIndexes, fontSize)
	local _, currentSize = Details222.RowTexts.ResolveStyle(instanceObject, textIndexes[1])

	if (currentSize == fontSize) then
		return
	end

	for index, textIndex in ipairs(textIndexes) do
		instanceObject.row_info.texts[textIndex].font.size = fontSize
	end

	Details222.RowTexts.ApplyStyleToAllRows(instanceObject)
end

--the dropdown lists fonts by name, the texts store the file
---@param instanceObject instance
---@param textIndexes number[]
---@param fontName string
local applyTextStyleFont = function(instanceObject, textIndexes, fontName)
	local fontFile = SharedMedia:Fetch("font", fontName)
	local currentFile = Details222.RowTexts.ResolveStyle(instanceObject, textIndexes[1])

	if (currentFile == fontFile) then
		return
	end

	for index, textIndex in ipairs(textIndexes) do
		instanceObject.row_info.texts[textIndex].font.face = fontFile
	end

	Details222.RowTexts.ApplyStyleToAllRows(instanceObject)
end

--every text already sits at the shared row_info.text_yoffset plus a tweak of its own in anchor.y. the option
--shows the sum, which is where the side really sits, and stores the tweak
---@param instanceObject instance
---@param textIndexes number[]
---@param yOffset number
local applyTextStyleYOffset = function(instanceObject, textIndexes, yOffset)
	local rowInfo = instanceObject.row_info
	local textYOffset = yOffset - rowInfo.text_yoffset

	if (rowInfo.texts[textIndexes[1]].anchor.y == textYOffset) then
		return
	end

	for index, textIndex in ipairs(textIndexes) do
		rowInfo.texts[textIndex].anchor.y = textYOffset
	end

	--the offset feeds the anchors, so the texts are anchored again rather than restyled
	Details222.RowTexts.ApplyAnchorsToAllRows(instanceObject)
end

--fills textStyleMirror for one side of a bar's text with what that side draws on a window
---@param instanceObject instance
---@param textStyle table NAME_TEXT_STYLE or VALUE_TEXT_STYLE
local seedTextStyle = function(instanceObject, textStyle)
	local rowInfo = instanceObject.row_info
	local firstIndex = textStyle.indexes[1]
	local keyPrefix = textStyle.keyPrefix
	local fontFile, fontSize, fixedColor = Details222.RowTexts.ResolveStyle(instanceObject, firstIndex)

	--a copy: the color widget writes into the table it is given, and this one must not be the window's
	textStyleMirror[keyPrefix .. TEXT_COLOR_SUFFIX] = {fixedColor[1], fixedColor[2], fixedColor[3], fixedColor[4] or 1}
	textStyleMirror[keyPrefix .. TEXT_SIZE_SUFFIX] = fontSize
	--a font file LibSharedMedia does not list shows as the shared font
	textStyleMirror[keyPrefix .. TEXT_FONT_SUFFIX] = getFontName(fontFile) or rowInfo.font_face
	textStyleMirror[keyPrefix .. TEXT_Y_OFFSET_SUFFIX] = rowInfo.text_yoffset + rowInfo.texts[firstIndex].anchor.y
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
local applyTranslitName = function(instanceObject)
	instanceObject:SetBarTextSettings(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, instanceObject.row_info.textL_translit_text)
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

--whether the percent column is drawn beside the value columns, on retail. the three row_info.textR_show_data
--flags are the classic versions' equivalent: the retail renderer never reads them
---@param instanceObject instance
local applyShowPercent = function(instanceObject)
	instanceObject:SetSimpleFormattingSettings(instanceObject.row_info.show_percent)
	--the aligned columns re-anchor off each other, so their padding is resolved again before the redraw
	instanceObject:AdjustInLineTextPadding()
	instanceObject:InstanceRefreshRows()
end

--the right text on the classic versions: which of total, per second and percent it shows. the three flags share
--one setter, so all three are passed every time
---@param instanceObject instance
local applyRightTextData = function(instanceObject)
	local showData = instanceObject.row_info.textR_show_data
	instanceObject:SetBarRightTextSettings(showData[1], showData[2], showData[3])
end

--the character wrapping the per second and percent block, on the classic versions
---@param instanceObject instance
local applyRightTextBracket = function(instanceObject)
	instanceObject:SetBarRightTextSettings(nil, nil, nil, instanceObject.row_info.textR_bracket)
end

--the character between the per second and the percent amounts, on the classic versions
---@param instanceObject instance
local applyRightTextSeparator = function(instanceObject)
	instanceObject:SetBarRightTextSettings(nil, nil, nil, nil, instanceObject.row_info.textR_separator)
end

--the aligned text columns switches of the classic versions: whether the value columns are aligned at all, and
--whether they chain onto each other. both only decide where the columns are anchored, so the anchors are
--resolved again before the rows are rebuilt
---@param instanceObject instance
local applyAlignedColumns = function(instanceObject)
	instanceObject:AdjustInLineTextPadding()
	instanceObject:InstanceRefreshRows()
end

--how much room the unit name leaves the aligned columns, on the classic versions. there is no setter: the rows
--are rebuilt and the window reset, the same as the bars texts section does
---@param instanceObject instance
local applyNameSizeOffset = function(instanceObject)
	instanceObject:InstanceRefreshRows()
	instanceObject:InstanceReset()
end

--the faction icon beside players of the opposite faction, drawn only on the classic versions. the two keys share
--one setter, so both are passed every time
---@param instanceObject instance
local applyFactionIcon = function(instanceObject)
	instanceObject:SetBarFactionIconSettings(instanceObject.row_info.show_faction_icon, instanceObject.row_info.faction_icon_size_offset)
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

--total bar
--there is no setter: the rows are rebuilt and the window reset, the same as the bars section does
---@param instanceObject instance
local applyTotalBar = function(instanceObject)
	instanceObject:InstanceRefreshRows()
	instanceObject:InstanceReset()
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
--and to the preview. used where there is no stored value to copy, only an apply to run on each window
---@param applyFunc fun(instanceObject:instance)
local applyToEditedWindows = function(applyFunc)
	local editedInstance = getEditedInstance()

	applyAndRedraw(editedInstance, applyFunc)

	if (Details.options_group_edit) then
		for index, groupInstance in ipairs(editedInstance:GetInstanceGroup()) do
			if (groupInstance ~= editedInstance) then
				applyAndRedraw(groupInstance, applyFunc)
			end
		end
	end

	applyAndRedraw(Details222.OptionsDesignerPreview:GetInstance(), applyFunc)
end

--applies one change to the window being edited, to the rest of its snap group while "editing group" is on,
--and to the preview, so a single edit shows up everywhere it should.
--
--this runs from the registration's callback rather than from each option's setter. the framework calls a
--setter once per member widget and the callback once per edit, and the bar objects register every bar in the
--preview as a member, so a setter would repeat the whole apply eight times for one slider tick
---@param optionByKey table<string, table>
---@return function
local makeCallback = function(optionByKey)
	return function(object, optionKey, value, profileTable, profileKey)
		local optionTable = optionByKey[optionKey]
		local applyFunc = optionTable.applyFunc
		local editedInstance = getEditedInstance()
		local previewInstance = Details222.OptionsDesignerPreview:GetInstance()
		--a global setting is stored on details! itself rather than on a window, so there is no value to
		--copy anywhere: only the apply travels
		local bIsGlobalSetting = optionTable.isGlobalSetting

		lastEditTime = GetTime()

		if (optionTable.applyValueFunc) then
			--a mirrored setting is not stored under a key the windows have, so nothing is copied: the value
			--itself is handed to every window through the option's own setter
			applyToEditedWindows(function(instanceObject)
				optionTable.applyValueFunc(instanceObject, value)
			end)

		elseif (bIsGlobalSetting) then
			applyAndRedraw(editedInstance, applyFunc)

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
			applyAndRedraw(editedInstance, applyFunc)

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

		--a toggle other options depend on has just changed, so they are enabled or disabled to match. done in
		--place rather than by rebuilding the menu, which would scroll it back to the top
		if (optionTable.childKeys and disabledRefreshFunc) then
			disabledRefreshFunc()
		end

		--the option may have changed what other options mean, so the open menu is rebuilt when it did. the
		--editor also runs this callback for every widget each time it builds the menu, with the value unchanged,
		--so the layout is compared rather than trusted: rebuilding on every call would rebuild forever.
		--deferred by a frame: rebuilding now would destroy the widget whose change is still being handled
		local bLayoutChanged = getColumnLayout(editedInstance) ~= seededColumnLayout
		if (optionTable.refreshesMenu and bLayoutChanged) then
			C_Timer.After(0, menuRefreshFunc)
		end
	end
end

--clears the custom bar texture, for the button beside its path. a button writes no value the editor tracks,
--so no callback runs for it: the change is applied here, and the menu rebuilt so the path box shows it empty
local removeCustomTexture = function()
	lastEditTime = GetTime()
	applyToEditedWindows(clearBarCustomTexture)
	Details222.OptionsDesignerPreview:DeFangRows()
	--deferred by a frame: rebuilding now would destroy the button whose click is still being handled
	C_Timer.After(0, menuRefreshFunc)
end

--collects every option that applies a change, keyed by the key the editor reports it by, into the lookup the
--callback dispatches through
---@param extraOptions table[]
---@return table<string, table>
local buildOptionMap = function(extraOptions)
	local optionByKey = {}

	for index, optionTable in ipairs(extraOptions) do
		if (optionTable.applyFunc or optionTable.applyValueFunc) then
			optionByKey[optionTable.key] = optionTable
		end
	end

	return optionByKey
end

--shorthand for one option, the setter that applies it and the tooltip shown while the mouse is over it.
--an option whose name already says what it does is given no description, and its tooltip shows the name
---@param profileKey string
---@param widgetType string
---@param label string
---@param applyFunc fun(instanceObject:instance)
---@param descriptionText string|nil
---@return table
local option = function(profileKey, widgetType, label, applyFunc, descriptionText)
	return {
		key = profileKey,
		widget = widgetType,
		label = label,
		desc = descriptionText or label,
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

--makes a toggle built by option() enable the options listed while it is on and disable them while it is off.
--the options are named by their keys, and linkDependentOptions wires them up once the whole list exists
---@param optionTable table
---@param childKeys string[]
---@return table
local withChildren = function(optionTable, childKeys)
	--read by linkDependentOptions and the callback; the editor ignores fields it does not know
	optionTable.childKeys = childKeys
	return optionTable
end

--gives every option a toggle lists in its childKeys a disableif reading that toggle off the window being edited.
--the window is read rather than the toggle widget: the menu reuses its widgets between parts, and a reused
--widget can still hold another part's state when the menu decides what to disable
---@param extraOptions table[]
local linkDependentOptions = function(extraOptions)
	local optionByKey = {}

	for index, optionTable in ipairs(extraOptions) do
		if (optionTable.key) then
			optionByKey[optionTable.key] = optionTable
		end
	end

	for index, parentOption in ipairs(extraOptions) do
		if (parentOption.childKeys) then
			local parentKey = parentOption.key

			for childIndex, childKey in ipairs(parentOption.childKeys) do
				optionByKey[childKey].disableif = function()
					return not detailsFramework.table.getfrompath(getEditedInstance(), parentKey)
				end
			end
		end
	end
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

--marks an option as changing what other options mean, so the open menu is rebuilt after it is applied
---@param optionTable table
---@return table
local withMenuRefresh = function(optionTable)
	--read by the callback; the editor ignores fields it does not know
	optionTable.refreshesMenu = true
	return optionTable
end

--builds the slider for one classic value column offset. it reads and writes the mirror table rather than the
--window, see columnOffsetMirror, and is remembered so SeedMirrors can fill it
---@param columnIndex number the row text the slider moves, 2 to 4
---@param columnNumber number the number the slider is labelled with, 1 to 3
---@return table
local columnOffsetOption = function(columnIndex, columnNumber)
	local optionTable = {
		key = "column" .. columnIndex,
		widget = "range",
		label = string.format(Loc["STRING_OPTIONS_ALIGNED_TEXT_COLUMNS_OFFSET"], columnNumber),
		desc = Loc["STRING_OPTIONS_ALIGNED_TEXT_COLUMNS_OFFSET_DESC"],
		step = 1,
		profileTable = columnOffsetMirror,
		--read by SeedMirrors and the callback; the editor ignores fields it does not know
		columnIndex = columnIndex,
		applyValueFunc = function(instanceObject, value)
			instanceObject:SetBarTextAnchorOffset(columnIndex, value)
		end,
	}

	columnOffsetOptions[#columnOffsetOptions + 1] = optionTable
	return optionTable
end

--builds an icon set option. it reads and writes the mirror table rather than the window, see iconSetMirror
---@param optionKey string
---@param widgetType string
---@param label string
---@param descriptionText string
---@return table
local iconSetOption = function(optionKey, widgetType, label, descriptionText)
	return {
		key = optionKey,
		widget = widgetType,
		label = label,
		desc = descriptionText,
		profileTable = iconSetMirror,
		--read by the callback; the editor ignores fields it does not know
		applyValueFunc = applyIconSet,
	}
end

--------------- shared dropdown lists ---------------

--builds a dropdown list of characters, followed by the entry that uses none
---@param characterValues string[]
---@param noCharacterLabel string
---@return table
local buildCharacterList = function(characterValues, noCharacterLabel)
	local characterList = {}

	for index, characterValue in ipairs(characterValues) do
		characterList[#characterList + 1] = {value = characterValue, label = characterValue}
	end

	characterList[#characterList + 1] = {value = NO_CHARACTER_VALUE, label = noCharacterLabel}
	return characterList
end

--the characters that may separate the per second and the percent amounts, on the classic versions
---@return table
local buildSeparatorList = function()
	return buildCharacterList(SEPARATOR_VALUES, Loc["STRING_OPTIONS_DESIGNER_NO_SEPARATOR"])
end

--the characters that may wrap the per second and percent block, on the classic versions
---@return table
local buildBracketList = function()
	return buildCharacterList(BRACKET_VALUES, Loc["STRING_OPTIONS_DESIGNER_NO_BRACKET"])
end

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

--the two directions the bars can grow in
---@return table
local buildGrowDirectionList = function()
	return {
		{value = GROW_TOP_TO_BOTTOM, label = Loc["STRING_TOP_TO_BOTTOM"], icon = ARROW_ICON, iconsize = ARROW_ICON_SIZE, texcoord = ARROW_DOWN_TEXCOORD},
		{value = GROW_BOTTOM_TO_TOP, label = Loc["STRING_BOTTOM_TO_TOP"], icon = ARROW_ICON, iconsize = ARROW_ICON_SIZE, texcoord = ARROW_UP_TEXCOORD},
	}
end

--the two orders the bars can be ranked in
---@return table
local buildSortDirectionList = function()
	return {
		{value = SORT_DESCENDING, label = Loc["STRING_DESCENDING"], icon = ARROW_ICON, iconsize = ARROW_ICON_SIZE, texcoord = ARROW_DOWN_TEXCOORD},
		{value = SORT_ASCENDING, label = Loc["STRING_ASCENDING"], icon = ARROW_ICON, iconsize = ARROW_ICON_SIZE, texcoord = ARROW_UP_TEXCOORD},
	}
end

--every icon set the bars can draw, the built-in ones and those other addons registered.
--each entry is copied: the list is shared, and the editor writes its own click handler into every entry
--that has none
---@return table
local buildIconSetList = function()
	local iconSetList = {}

	for index, iconSetEntry in ipairs(Details222.BarIconSetList) do
		local listEntry = {}

		for fieldName, fieldValue in pairs(iconSetEntry) do
			listEntry[fieldName] = fieldValue
		end

		iconSetList[#iconSetList + 1] = listEntry
	end

	return iconSetList
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

--collects the same widget from every player bar in the preview, so clicking any of them selects the same entry.
--the framework takes an array as the registered object and gives every member its own click overlay while
--showing one row in the object list; all members share a widget type because they are the same field of
--identical rows.
--the first row is left out: the preview always draws the total bar there, which is a part of its own
---@param previewInstance instance
---@param widgetField string
---@return table[]
local collectBarWidgets = function(previewInstance, widgetField)
	local barWidgets = {}

	for rowIndex = FIRST_PLAYER_ROW_INDEX, #previewInstance.barras do
		barWidgets[#barWidgets + 1] = unwrapWidget(previewInstance.barras[rowIndex][widgetField])
	end

	return barWidgets
end

--collects the named fontstrings of every bar in the preview, so clicking any of them selects the same entry.
--all four texts of a row are children of the same border frame and do not overlap, so the unit name and the
--value columns can be separate entries without either stealing a click from the other
---@param previewInstance instance
---@param textFields string[] NAME_TEXT_FIELDS or VALUE_TEXT_FIELDS
---@return table[]
local collectBarTextWidgets = function(previewInstance, textFields)
	local textWidgets = {}

	--the total bar's texts are left out with the rest of the first row, see collectBarWidgets
	for rowIndex = FIRST_PLAYER_ROW_INDEX, #previewInstance.barras do
		for fieldIndex, widgetField in ipairs(textFields) do
			textWidgets[#textWidgets + 1] = unwrapWidget(previewInstance.barras[rowIndex][widgetField])
		end
	end

	return textWidgets
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
			option("color", "color", Loc["STRING_OPTIONS_WINDOW_SKIN_COLOR"], applySkinColor, Loc["STRING_OPTIONS_WINDOW_SKIN_COLOR_DESC"]),
			withRange(option("window_scale", "range", Loc["STRING_OPTIONS_WINDOW_SCALE"], applyWindowScale, Loc["STRING_OPTIONS_WINDOW_SCALE_DESC"]), 0.65, 1.5, 0.02, true),
			option("show_sidebars", "toggle", Loc["STRING_OPTIONS_SHOW_SIDEBARS"], applySideBars, Loc["STRING_OPTIONS_SHOW_SIDEBARS_DESC"]),
			withList(option("backdrop_texture", "select", Loc["STRING_OPTIONS_INSTANCE_BACKDROP"], applyBackdropTexture, Loc["STRING_OPTIONS_INSTANCE_BACKDROP_DESC"]), buildBackgroundList),
			withList(option("strata", "select", Loc["STRING_OPTIONS_INSTANCE_STRATA"], applyStrata, Loc["STRING_OPTIONS_INSTANCE_STRATA_DESC"]), buildStrataList),
			{widget = "blank"},
			withRange(option("bg_alpha", "range", Loc["STRING_OPTIONS_DESIGNER_ROW_AREA_ALPHA"], applyRowAreaAlpha), 0, 1, 0.01, true),
			option("rounded_corner_enabled", "toggle", Loc["STRING_OPTIONS_DESIGNER_ROUNDED_CORNERS"], applyRoundedCorners),
			{widget = "blank"},
			--the border color and thickness only mean anything while the border is shown
			withChildren(option("fullborder_shown", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_WINDOW_BORDER"], applyWindowBorder),
				{"fullborder_color", "fullborder_size"}),
			option("fullborder_color", "color", Loc["STRING_OPTIONS_DESIGNER_BORDER_COLOR"], applyWindowBorder),
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
		--off, which is what lets the user reach the setting that turns it on.
		--the title bar buttons are part of this object too: the preview takes the mouse off them, so a click on
		--one falls through to the title bar under it
		Object = unwrapWidget(previewInstance.baseframe.titleBar),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			--height, texture and color only mean anything while the custom title bar is on, so they are
			--disabled while it is off
			withChildren(option("titlebar_shown", "toggle", Loc["STRING_OPTIONS_DESIGNER_TITLEBAR_ENABLED"], applyTitleBar, Loc["STRING_OPTIONS_DESIGNER_TITLEBAR_ENABLED_DESC"]),
				{"titlebar_height", "titlebar_texture", "titlebar_texture_color"}),
			withRange(option("titlebar_height", "range", Loc["STRING_OPTIONS_DESIGNER_TITLEBAR_HEIGHT"], applyTitleBar), 0, 32, 1),
			withList(option("titlebar_texture", "select", Loc["STRING_TEXTURE"], applyTitleBar), buildStatusBarTextureList),
			option("titlebar_texture_color", "color", Loc["STRING_COLOR"], applyTitleBar),
			{widget = "blank"},

			--a label row takes its content from 'text'; built with 'label' it renders blank
			{widget = "label", text = Loc["STRING_OPTIONS_TITLEBAR_MENUBUTTONS_HEADER"]},
			withRange(option("menu_icons_size", "range", Loc["STRING_OPTIONS_DESIGNER_MENU_ICON_SIZE"], applyMenuIconSize, Loc["STRING_OPTIONS_MENU_BUTTONSSIZE_DESC"]), 0.4, 1.6, 0.05, true),
			withRange(option("menu_icons.space", "range", Loc["STRING_OPTIONS_DESIGNER_MENU_ICON_SPACING"], applyToolbarButtonOptions, Loc["STRING_OPTIONS_MENUS_SPACEMENT_DESC"]), -5, 10, 1),
			option("menu_icons.shadow", "toggle", Loc["STRING_OPTIONS_MENUS_SHADOW"], applyToolbarButtonOptions, Loc["STRING_OPTIONS_MENUS_SHADOW_DESC"]),
			option("desaturated_menu", "toggle", Loc["STRING_OPTIONS_DESIGNER_DESATURATED_MENU"], applyDesaturatedMenu, Loc["STRING_OPTIONS_DESATURATE_MENU_DESC"]),
			option("auto_hide_menu.left", "toggle", Loc["STRING_OPTIONS_MENU_AUTOHIDE_LEFT"], applyAutoHideMenu, Loc["STRING_OPTIONS_MENU_AUTOHIDE_DESC"]),
			option("hide_icon", "toggle", Loc["STRING_OPTIONS_HIDE_ICON"], applyHideIcon, Loc["STRING_OPTIONS_HIDE_ICON_DESC"]),
			{widget = "blank"},

			{widget = "label", text = Loc["STRING_OPTIONS_DESIGNER_WHICH_BUTTONS"]},
			option("menu_icons[1]", "toggle", Loc["STRING_OPTIONS_DESIGNER_BUTTON_MODE"], applyToolbarButtons, Loc["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"]),
			option("menu_icons[2]", "toggle", Loc["STRING_SEGMENT"], applyToolbarButtons, Loc["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"]),
			option("menu_icons[3]", "toggle", Loc["STRING_OPTIONSMENU_DISPLAY"], applyToolbarButtons, Loc["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"]),
			option("menu_icons[4]", "toggle", Loc["STRING_REPORT_TEXT"], applyToolbarButtons, Loc["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"]),
			option("menu_icons[5]", "toggle", Loc["STRING_OPTIONS_SPELL_RESET"], applyToolbarButtons, Loc["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"]),
			option("menu_icons[6]", "toggle", Loc["STRING_OPTIONS_WC_CLOSE"], applyToolbarButtons, Loc["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"]),
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
			--every other title text option only means anything while the title text is shown
			withChildren(option("attribute_text.enabled", "toggle", Loc["STRING_OPTIONS_DESIGNER_TITLE_TEXT_ENABLED"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED_DESC"]),
				{"attribute_text.text_size", "attribute_text.text_color", "attribute_text.text_face", "attribute_text.shadow",
				"attribute_text.anchor[1]", "attribute_text.anchor[2]", "attribute_text.show_timer"}),
			withRange(option("attribute_text.text_size", "range", Loc["STRING_OPTIONS_TEXT_SIZE"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE_DESC"]), 5, 32, 1),
			option("attribute_text.text_color", "color", Loc["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR_DESC"]),
			withList(option("attribute_text.text_face", "select", Loc["STRING_OPTIONS_TEXT_FONT"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_FONT_DESC"]), buildFontList),
			option("attribute_text.shadow", "toggle", Loc["STRING_OPTIONS_TEXT_LOUTILINE"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW_DESC"]),
			{widget = "blank"},
			withRange(option("attribute_text.anchor[1]", "range", Loc["STRING_OPTIONS_DESIGNER_TEXT_X_OFFSET"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX_DESC"]), -30, 300, 1),
			withRange(option("attribute_text.anchor[2]", "range", Loc["STRING_OPTIONS_DESIGNER_TEXT_Y_OFFSET"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY_DESC"]), -100, 50, 1),
			option("attribute_text.show_timer", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_ENCOUNTER_TIMER"], applyTitleText, Loc["STRING_OPTIONS_MENU_ATTRIBUTE_ENCOUNTERTIMER_DESC"]),
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
			withRange(option("row_info.height", "range", Loc["STRING_OPTIONS_BAR_HEIGHT"], applyBarHeight, Loc["STRING_OPTIONS_BAR_HEIGHT_DESC"]), 10, 30, 1),
			withRange(option("row_info.space.between", "range", Loc["STRING_OPTIONS_BAR_SPACING"], applyBarSpacing, Loc["STRING_OPTIONS_BAR_SPACING_DESC"]), -2, 10, 1),
			withList(option("row_info.texture", "select", Loc["STRING_TEXTURE"], applyBarTexture, Loc["STRING_OPTIONS_BAR_TEXTURE_DESC"]), buildStatusBarTextureList),
			option("row_info.texture_custom", "textentry", Loc["STRING_OPTIONS_BARS_CUSTOM_TEXTURE"], applyBarCustomTexture, Loc["STRING_CUSTOM_TEXTURE_GUIDE"]),
			{widget = "execute", label = Loc["STRING_OPTIONS_DESIGNER_REMOVE_CUSTOM_TEXTURE"], func = removeCustomTexture, icontexture = REMOVE_ICON},
			option("row_info.texture_class_colors", "toggle", Loc["STRING_OPTIONS_DESIGNER_COLOR_BY_CLASS"], applyBarClassColor, Loc["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"]),
			option("row_info.fixed_texture_color", "color", Loc["STRING_COLOR"], applyBarColor, Loc["STRING_OPTIONS_BAR_COLOR_DESC"]),
			asGlobalSetting(option("instances_disable_bar_highlight", "toggle", Loc["STRING_OPTIONS_DISABLE_BARHIGHLIGHT"], applyOnRedraw, Loc["STRING_OPTIONS_DISABLE_BARHIGHLIGHT_DESC"])),
			option("following.enabled", "toggle", Loc["STRING_OPTIONS_BAR_FOLLOWING"], applyOnRedraw, Loc["STRING_OPTIONS_BAR_FOLLOWING_DESC"]),
			withList(option("bars_grow_direction", "select", Loc["STRING_OPTIONS_BAR_GROW"], applyBarGrowDirection, Loc["STRING_OPTIONS_BAR_GROW_DESC"]), buildGrowDirectionList),
			withList(option("bars_sort_direction", "select", Loc["STRING_OPTIONS_BARSORT"], applyOnRedraw, Loc["STRING_OPTIONS_BARSORT_DESC"]), buildSortDirectionList),
			{widget = "blank"},
			withList(option("row_info.texture_background", "select", Loc["STRING_OPTIONS_INSTANCE_BACKDROP"], applyBarBackgroundTexture, Loc["STRING_OPTIONS_BAR_BTEXTURE_DESC"]), buildStatusBarTextureList),
			option("row_info.texture_background_class_color", "toggle", Loc["STRING_OPTIONS_DESIGNER_BACKGROUND_BY_CLASS"], applyBarBackgroundClassColor, Loc["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"]),
			option("row_info.fixed_texture_background_color", "color", Loc["STRING_OPTIONS_BAR_BCOLOR"], applyBarBackgroundColor, Loc["STRING_OPTIONS_BAR_COLOR_DESC"]),
			{widget = "blank"},

			{widget = "label", text = Loc["STRING_OPTIONS_DESIGNER_OVERLAY"]},
			withList(option("row_info.overlay_texture", "select", Loc["STRING_TEXTURE"], applyBarOverlay, Loc["STRING_OPTIONS_DESIGNER_OVERLAY_TEXTURE_DESC"]), buildStatusBarTextureList),
			option("row_info.overlay_color", "color", Loc["STRING_COLOR"], applyBarOverlay, Loc["STRING_COLOR"]),
			{widget = "blank"},

			--the arena team colors are stored on details! itself and color every window's arena bars
			{widget = "label", text = Loc["STRING_OPTIONS_DESIGNER_ARENA_TEAM_COLOR"]},
			asGlobalSetting(option("class_colors.ARENA_GREEN", "color", Loc["STRING_COLOR"], applyOnRedraw, Loc["STRING_OPTIONS_DESIGNER_ARENA_TEAM_COLOR"])),
			asGlobalSetting(option("class_colors.ARENA_YELLOW", "color", Loc["STRING_COLOR"], applyOnRedraw, Loc["STRING_OPTIONS_DESIGNER_ARENA_TEAM_COLOR"])),
			{widget = "blank"},

			--the bar border color and thickness only mean anything while the bar border is shown
			withChildren(option("row_info.backdrop.enabled", "toggle", Loc["STRING_OPTIONS_DESIGNER_BAR_BORDER"], applyBarBackdrop, Loc["STRING_OPTIONS_BAR_BACKDROP_ENABLED_DESC"]),
				{"row_info.backdrop.color", "row_info.backdrop.size", "row_info.backdrop.use_class_colors"}),
			option("row_info.backdrop.color", "color", Loc["STRING_OPTIONS_DESIGNER_BORDER_COLOR"], applyBarBackdrop, Loc["STRING_OPTIONS_BAR_BACKDROP_COLOR_DESC"]),
			--the bars section slider is 0 to 10 while the default is 12, so the upper bound covers the default
			withRange(option("row_info.backdrop.size", "range", Loc["STRING_OPTIONS_DESIGNER_BORDER_THICKNESS"], applyBarBackdrop, Loc["STRING_OPTIONS_BAR_BACKDROP_SIZE_DESC"]), 0, 16, 1),
			option("row_info.backdrop.use_class_colors", "toggle", Loc["STRING_OPTIONS_BAR_COLORBYCLASS"], applyBarBackdrop, Loc["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"]),
		},
	}
end

--the total bar, the first row of the preview. the preview draws it whatever these settings say, dimmed while
--they hide it, so it can always be clicked
---@param previewInstance instance
---@return table
local buildTotalBarRegistration = function(previewInstance)
	return {
		id = "TOTALBAR",
		label = Loc["STRING_OPTIONS_TOTALBAR_ANCHOR"],
		Object = unwrapWidget(previewInstance.barras[TOTAL_BAR_ROW_INDEX].statusbar),
		profileKeyMap = FRAME_KEY_MAP,
		extraOptions = {
			--only in group and the color only mean anything while the total bar is shown
			withChildren(option("total_bar.enabled", "toggle", Loc["STRING_ENABLED"], applyTotalBar, Loc["STRING_OPTIONS_SHOW_TOTALBAR_DESC"]),
				{"total_bar.only_in_group", "total_bar.color"}),
			option("total_bar.only_in_group", "toggle", Loc["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP"], applyTotalBar, Loc["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP_DESC"]),
			option("total_bar.color", "color", Loc["STRING_COLOR"], applyTotalBar, Loc["STRING_OPTIONS_SHOW_TOTALBAR_COLOR_DESC"]),
		},
	}
end

--appends every option of one list to another
---@param targetList table[]
---@param sourceList table[]
local appendOptions = function(targetList, sourceList)
	for index, optionTable in ipairs(sourceList) do
		targetList[#targetList + 1] = optionTable
	end
end

--builds the color, size, font and vertical offset options of one side of a bar's text. they read and write the
--mirror table rather than the window, see textStyleMirror
---@param textStyle table NAME_TEXT_STYLE or VALUE_TEXT_STYLE
---@param colorDescription string the color is the one style option whose name does not say it all
---@return table[]
local buildTextStyleOptions = function(textStyle, colorDescription)
	local textIndexes = textStyle.indexes

	local styleOption = function(keySuffix, widgetType, label, descriptionText, applyStyleFunc)
		return {
			key = textStyle.keyPrefix .. keySuffix,
			widget = widgetType,
			label = label,
			desc = descriptionText or label,
			profileTable = textStyleMirror,
			--read by the callback; the editor ignores fields it does not know
			applyValueFunc = function(instanceObject, value)
				applyStyleFunc(instanceObject, textIndexes, value)
			end,
		}
	end

	return {
		styleOption(TEXT_COLOR_SUFFIX, "color", Loc["STRING_OPTIONS_TEXT_FIXEDCOLOR"], colorDescription, applyTextStyleColor),
		withRange(styleOption(TEXT_SIZE_SUFFIX, "range", Loc["STRING_OPTIONS_TEXT_SIZE"], nil, applyTextStyleSize), 5, 32, 1),
		withList(styleOption(TEXT_FONT_SUFFIX, "select", Loc["STRING_OPTIONS_TEXT_FONT"], nil, applyTextStyleFont), buildFontList),
		withRange(styleOption(TEXT_Y_OFFSET_SUFFIX, "range", Loc["STRING_OPTIONS_DESIGNER_TEXT_Y_OFFSET"], nil, applyTextStyleYOffset), -10, 10, 1),
	}
end

--the unit name drawn on the left of every bar
---@param previewInstance instance
---@return table
local buildBarNameTextRegistration = function(previewInstance)
	local extraOptions = buildTextStyleOptions(NAME_TEXT_STYLE, Loc["STRING_OPTIONS_DESIGNER_NAME_TEXT_COLOR_DESC"])

	appendOptions(extraOptions, {
		{widget = "blank"},
		option("row_info.textL_show_number", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_RANK_NUMBER"], applyShowRankNumber, Loc["STRING_OPTIONS_TEXT_LPOSITION_DESC"]),
		withRange(option("row_info.textL_offset", "range", Loc["STRING_OPTIONS_DESIGNER_NAME_OFFSET"], applyTextNameOffset), -10, 50, 1),
		option("row_info.texts[1].color.byClass", "toggle", Loc["STRING_OPTIONS_DESIGNER_COLOR_BY_CLASS"], applyNameClassColor, Loc["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"]),
		option("row_info.texts[1].font.outline", "selectoutline", Loc["STRING_OPTIONS_DESIGNER_TEXT_OUTLINE"], applyNameOutline),
		option("row_info.texts[1].shadow.color", "color", Loc["STRING_OPTIONS_TEXT_SHADOWCOLOR"], applyNameShadowColor),
		withRange(option("row_info.texts[1].shadow.offset[1]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_X"], applyNameShadowOffset), -5, 5, 1),
		withRange(option("row_info.texts[1].shadow.offset[2]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_Y"], applyNameShadowOffset), -5, 5, 1),
	})

	--writing the unit name in latin letters is offered only on the classic versions
	if (not detailsFramework.IsAddonApocalypseWow()) then
		appendOptions(extraOptions, {
			{widget = "blank"},
			option("row_info.textL_translit_text", "toggle", Loc["STRING_OPTIONS_TEXT_LTRANSLIT"], applyTranslitName, Loc["STRING_OPTIONS_TEXT_LTRANSLIT_DESC"]),
		})
	end

	return {
		id = "BARNAMETEXT",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_BARNAMETEXT"],
		Object = collectBarTextWidgets(previewInstance, NAME_TEXT_FIELDS),
		profileKeyMap = FONTSTRING_KEY_MAP,
		extraOptions = extraOptions,
	}
end

--the value column options of retail: the percent column, and the simple or aligned layout details! applies to
--every window
---@return table[]
local buildRetailValueColumnOptions = function()
	return {
		option("row_info.show_percent", "toggle", Loc["STRING_OPTIONS_TEXT_SHOW_PERCENT"], applyShowPercent, Loc["STRING_OPTIONS_DESIGNER_SHOW_PERCENT_DESC"]),
		asGlobalSetting(option("righttext_simple_formatting.use_alignment", "toggle", Loc["STRING_OPTIONS_DESIGNER_ALIGN_COLUMNS"], applyRightTextMode, Loc["STRING_OPTIONS_DESIGNER_ALIGN_COLUMNS_DESC"])),
	}
end

--the value column options of the classic versions, the same the bars texts section shows there: what the right
--text shows and how it is punctuated, then the aligned text columns block
---@return table[]
local buildClassicValueColumnOptions = function()
	return {
		option("row_info.textR_show_data[1]", "toggle", Loc["STRING_OPTIONS_TEXT_SHOW_TOTAL"], applyRightTextData, Loc["STRING_OPTIONS_TEXT_SHOW_TOTAL_DESC"]),
		option("row_info.textR_show_data[2]", "toggle", Loc["STRING_OPTIONS_TEXT_SHOW_PS"], applyRightTextData, Loc["STRING_OPTIONS_TEXT_SHOW_PS_DESC"]),
		option("row_info.textR_show_data[3]", "toggle", Loc["STRING_OPTIONS_TEXT_SHOW_PERCENT"], applyRightTextData, Loc["STRING_OPTIONS_TEXT_SHOW_PERCENT_DESC"]),
		withList(option("row_info.textR_separator", "select", Loc["STRING_OPTIONS_TEXT_SHOW_SEPARATOR"], applyRightTextSeparator, Loc["STRING_OPTIONS_TEXT_SHOW_SEPARATOR_DESC"]), buildSeparatorList),
		withList(option("row_info.textR_bracket", "select", Loc["STRING_OPTIONS_TEXT_SHOW_BRACKET"], applyRightTextBracket, Loc["STRING_OPTIONS_TEXT_SHOW_BRACKET_DESC"]), buildBracketList),
		{widget = "blank"},

		{widget = "label", text = Loc["STRING_OPTIONS_ALIGNED_TEXT_COLUMNS"]},
		--both switches change where the columns are anchored, which changes what the offset sliders below
		--mean and how far they reach, so the menu is rebuilt after either
		withMenuRefresh(option("use_multi_fontstrings", "toggle", Loc["STRING_ENABLED"], applyAlignedColumns, Loc["STRING_OPTIONS_ALIGNED_TEXT_COLUMNS_DESC"])),
		withMenuRefresh(option("use_auto_align_multi_fontstrings", "toggle", Loc["STRING_OPTIONS_ALIGNED_TEXT_COLUMNS_AUTOALIGN"], applyAlignedColumns, Loc["STRING_OPTIONS_ALIGNED_TEXT_COLUMNS_AUTOALIGN_DESC"])),
		withRange(option("fontstrings_text_limit_offset", "range", Loc["STRING_OPTIONS_DESIGNER_NAME_SIZE_OFFSET"], applyNameSizeOffset, Loc["STRING_OPTIONS_DESIGNER_NAME_SIZE_OFFSET_DESC"]), -30, 30, 1),
		columnOffsetOption(VALUE_COLUMN_INDEXES[1], 1),
		columnOffsetOption(VALUE_COLUMN_INDEXES[2], 2),
		columnOffsetOption(VALUE_COLUMN_INDEXES[3], 3),
	}
end

--the three value columns drawn on the right of every bar, which share one set of settings. after their own
--options come the value column options of the game version it runs on: retail and the classic versions draw
--the value columns through different code, each reading its own settings
---@param previewInstance instance
---@return table
local buildBarValueTextRegistration = function(previewInstance)
	local extraOptions = buildTextStyleOptions(VALUE_TEXT_STYLE, Loc["STRING_OPTIONS_DESIGNER_VALUE_TEXT_COLOR_DESC"])

	appendOptions(extraOptions, {
		withList(option("row_info.percent_type", "select", Loc["STRING_OPTIONS_DESIGNER_PERCENT_TYPE"], applyPercentType, Loc["STRING_OPTIONS_PERCENT_TYPE_DESC"]), buildPercentTypeList),
		{widget = "blank"},
		option("row_info.texts[2].color.byClass", "toggle", Loc["STRING_OPTIONS_DESIGNER_COLOR_BY_CLASS"], applyValueClassColor, Loc["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"]),
		option("row_info.texts[2].font.outline", "selectoutline", Loc["STRING_OPTIONS_DESIGNER_TEXT_OUTLINE"], applyValueOutline),
		option("row_info.texts[2].shadow.color", "color", Loc["STRING_OPTIONS_TEXT_SHADOWCOLOR"], applyValueShadowColor),
		withRange(option("row_info.texts[2].shadow.offset[1]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_X"], applyValueShadowOffset), -5, 5, 1),
		withRange(option("row_info.texts[2].shadow.offset[2]", "range", Loc["STRING_OPTIONS_DESIGNER_SHADOW_OFFSET_Y"], applyValueShadowOffset), -5, 5, 1),
		{widget = "blank"},
	})

	if (detailsFramework.IsAddonApocalypseWow()) then
		appendOptions(extraOptions, buildRetailValueColumnOptions())
	else
		appendOptions(extraOptions, buildClassicValueColumnOptions())
	end

	return {
		id = "BARVALUETEXT",
		label = Loc["STRING_OPTIONS_DESIGNER_OBJECT_BARVALUETEXT"],
		Object = collectBarTextWidgets(previewInstance, VALUE_TEXT_FIELDS),
		profileKeyMap = FONTSTRING_KEY_MAP,
		extraOptions = extraOptions,
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
			withList(iconSetOption(ICON_SET_KEY, "select", Loc["STRING_TEXTURE"], Loc["STRING_OPTIONS_BAR_ICONFILE_DESC2"]), buildIconSetList),
			iconSetOption(CUSTOM_ICON_SET_KEY, "textentry", Loc["STRING_OPTIONS_BARS_CUSTOM_TEXTURE"], Loc["STRING_CUSTOM_TEXTURE_GUIDE"]),
			{widget = "blank"},
			withRange(option("row_info.icon_size_offset", "range", Loc["STRING_OPTIONS_DESIGNER_ICON_SIZE_OFFSET"], applyIconSizeOffset), -20, 20, 0.5, true),
			option("row_info.start_after_icon", "toggle", Loc["STRING_OPTIONS_DESIGNER_BAR_START_AFTER_ICON"], applyBarStartAfterIcon, Loc["STRING_OPTIONS_BARSTART_DESC"]),
			option("row_info.icon_grayscale", "toggle", Loc["STRING_OPTIONS_DESIGNER_ICON_GRAYSCALE"], applyIconGrayscale),
			{widget = "blank"},
			--the role icon size only means anything while the role icon is shown
			withChildren(option("row_info.show_arena_role_icon", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_ARENA_ROLE_ICON"], applyArenaRoleIcon),
				{"row_info.arena_role_icon_size_offset"}),
			withRange(option("row_info.arena_role_icon_size_offset", "range", Loc["STRING_OPTIONS_DESIGNER_ARENA_ROLE_ICON_SIZE_OFFSET"], applyArenaRoleIcon, Loc["STRING_OPTIONS_DESIGNER_ARENA_ROLE_ICON_SIZE_OFFSET"]), -20, 20, 0.5, true),
		},
	}
end

--the bar icons object. the faction icon is only drawn on the classic versions, so its options are only offered
--there: on retail the code that reads them never runs
---@param previewInstance instance
---@return table
local buildBarIconsRegistrationForVersion = function(previewInstance)
	local registration = buildBarIconsRegistration(previewInstance)

	if (not detailsFramework.IsAddonApocalypseWow()) then
		appendOptions(registration.extraOptions, {
			{widget = "blank"},
			option("row_info.show_faction_icon", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_FACTION_ICON"], applyFactionIcon, Loc["STRING_OPTIONS_DESIGNER_SHOW_FACTION_ICON_DESC"]),
			withRange(option("row_info.faction_icon_size_offset", "range", Loc["STRING_OPTIONS_DESIGNER_FACTION_ICON_SIZE_OFFSET"], applyFactionIcon), -20, 20, 0.5, true),
		})
	end

	return registration
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
			--the other status bar options only mean anything while the status bar is shown
			withChildren(option("show_statusbar", "toggle", Loc["STRING_OPTIONS_DESIGNER_SHOW_STATUSBAR"], applyShowStatusBar, Loc["STRING_OPTIONS_SHOW_STATUSBAR_DESC"]),
				{"statusbar_info.overlay", "statusbar_info.alpha", "micro_displays_locked"}),
			option("statusbar_info.overlay", "color", Loc["STRING_COLOR"], applyStatusBarColor, Loc["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR_DESC"]),
			withRange(option("statusbar_info.alpha", "range", Loc["STRING_OPTIONS_DESIGNER_BAR_ALPHA"], applyStatusBarColor), 0, 1, 0.01, true),
			option("micro_displays_locked", "toggle", Loc["STRING_OPTIONS_MICRODISPLAY_LOCK"], applyMicroDisplayLock, Loc["STRING_OPTIONS_MICRODISPLAY_LOCK_DESC"]),
		},
	}
end

--every part of a window the designer lets the user click, in the order they appear in the object list
---@param previewInstance instance
---@return table[]
function Details222.OptionsDesignerObjects:GetRegistrations(previewInstance)
	local registrations = {
		buildWindowRegistration(previewInstance),
		buildTitleBarRegistration(previewInstance),
		buildTitleTextRegistration(previewInstance),
		buildBarsRegistration(previewInstance),
		buildTotalBarRegistration(previewInstance),
		buildBarNameTextRegistration(previewInstance),
		buildBarValueTextRegistration(previewInstance),
		buildBarIconsRegistrationForVersion(previewInstance),
		buildStatusBarRegistration(previewInstance),
	}

	for index, registration in ipairs(registrations) do
		linkDependentOptions(registration.extraOptions)
	end

	return registrations
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
	return makeCallback(buildOptionMap(registration.extraOptions))
end

--stores the function that rebuilds the open option menu, called after an option that changes what other options
--mean
---@param refreshFunc function
function Details222.OptionsDesignerObjects:SetMenuRefreshFunc(refreshFunc)
	menuRefreshFunc = refreshFunc
end

--stores the function that enables and disables the options of the open menu to match the window, called after
--a toggle other options depend on
---@param refreshFunc function
function Details222.OptionsDesignerObjects:SetDisabledRefreshFunc(refreshFunc)
	disabledRefreshFunc = refreshFunc
end

--fills the mirror tables the icon set options, the bar text style options and the classic column offset sliders
--read, and sets each slider's range, from the window about to be edited. the designer calls this before every
--menu build: the editor reads each value once, when it builds the menu, and the column offset values and ranges
--depend on the window's auto align setting
---@param instanceObject instance
function Details222.OptionsDesignerObjects:SeedMirrors(instanceObject)
	local iconSet = getIconSet(instanceObject)
	iconSetMirror[ICON_SET_KEY] = iconSet
	iconSetMirror[CUSTOM_ICON_SET_KEY] = iconSet

	seedTextStyle(instanceObject, NAME_TEXT_STYLE)
	seedTextStyle(instanceObject, VALUE_TEXT_STYLE)

	seededColumnLayout = getColumnLayout(instanceObject)

	for index, optionTable in ipairs(columnOffsetOptions) do
		local columnIndex = optionTable.columnIndex
		local minValue, maxValue = instanceObject:GetBarTextAnchorOffsetRange(columnIndex)

		columnOffsetMirror[optionTable.key] = instanceObject:GetBarTextAnchorOffset(columnIndex)
		optionTable.minvalue = minValue
		optionTable.maxvalue = maxValue
	end
end
