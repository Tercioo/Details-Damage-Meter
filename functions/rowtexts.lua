--Description:
	-- per fontstring configuration for the bar rows (row_info.texts)
	--
	-- a row shows four texts: index 1 is the unit name, indexes 2 to 4 are the value columns
	-- (usually total, per second and percent). each row owns two parallel fontstring sets,
	-- 'lineText1' to 'lineText4' and 'lineText11' to 'lineText14'; both are styled from the
	-- same settings index.
	--
	-- ANCHORS ARE SET IN EXACTLY TWO PLACES: when the fontstrings are created (Details:CreateRow
	-- calls ApplyAnchors) and when an option changes an anchor setting (the Set* methods on
	-- Details call ApplyAnchors again). Nothing else may move a row text. In particular the row
	-- refresh does not: 'ApplyStyleToRow' deliberately never touches SetPoint, so the bars cannot
	-- fight the settings, and there's one obvious place to look when a text sits in the wrong spot.
	--
	-- windows using inverted bars get a mirrored layout derived from the same settings, see
	-- 'mirrorAnchor'. the settings themselves always describe the non inverted layout.
	--
	-- NO ROW TEXT MAY CARRY A WIDTH. all eight are placed by one anchor point and size themselves
	-- to their string; a box on one of them does not justify its text the way you would expect and
	-- pushes its chained neighbours around by the width of the box. the unit name is kept off the
	-- value columns by trimming its string instead, see 'FitNameText'.
	--
	-- this file also keeps the compatibility layer for the flat 'textL_' and 'textR_' keys that
	-- lived in row_info before. 'Migrate' folds those values into row_info.texts and 'EnsureShim'
	-- attaches a metatable translating legacy reads and writes onto the new table, so old skins,
	-- imported skin strings and third party plugins keep working.
	--
	-- known limitation of the shim: reading a table valued legacy key returns the live table of
	-- the first index it maps to, so mutating it in place only affects that index. assign a new
	-- table instead of mutating when the key fans out (any 'textR_' key covers indexes 2 to 4).

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local Details = _G.Details
	local detailsFramework = _G.DetailsFramework
	local addonName, Details222 = ...

	local unpack = unpack
	local rawget = rawget
	local rawset = rawset
	local setmetatable = setmetatable
	local getmetatable = getmetatable

	Details222.RowTexts = Details222.RowTexts or {}
	local rowTexts = Details222.RowTexts

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants

	--stored inside row_info.texts, tells the migration already ran on this table
	local CONST_TEXTS_VERSION = 1

	--index 1 is the unit name, 2 to 4 are the value columns
	local CONST_NAME_INDEX = 1
	local CONST_FIRST_VALUE_INDEX = 2
	local CONST_LAST_VALUE_INDEX = 4

	--the parallel fontstring set ('lineText11' to 'lineText14') sits at index + this offset
	local CONST_SECONDARY_OFFSET = 10

	--every fontstring set, styled and anchored from the same settings index
	local CONST_SET_OFFSETS = {0, CONST_SECONDARY_OFFSET}

	--horizontal mirror used when the window has inverted bars
	local CONST_MIRRORED_POINTS = {
		["left"] = "right",
		["right"] = "left",
		["topleft"] = "topright",
		["topright"] = "topleft",
		["bottomleft"] = "bottomright",
		["bottomright"] = "bottomleft",
		["top"] = "top",
		["bottom"] = "bottom",
		["center"] = "center",
	}

	--tokens accepted in anchor.relativeTo; the settings must hold a string and not a frame,
	--since row_info is serialized into savedvariables and into skins
	local CONST_RELATIVE_FRAMES = {
		["icon"] = function(row) return row.icone_classe end,
		["statusbar"] = function(row) return row.statusbar end,
		["row"] = function(row) return row end,
	}

	--legacy flat key -> which indexes it covers and where it lands inside the settings entry.
	--a read resolves against the first index, a write fans out to every index listed.
	local CONST_LEGACY_MAP = {
		["textL_class_colors"] =   {indexes = {1},       path = {"color", "byClass"}},
		["textR_class_colors"] =   {indexes = {2, 3, 4}, path = {"color", "byClass"}},
		["textL_outline_mode"] =   {indexes = {1},       path = {"font", "outline"}},
		["textR_outline_mode"] =   {indexes = {2, 3, 4}, path = {"font", "outline"}},
		["textL_shadow_color"] =   {indexes = {1},       path = {"shadow", "color"},  isTable = true},
		["textR_shadow_color"] =   {indexes = {2, 3, 4}, path = {"shadow", "color"},  isTable = true},
		["textL_shadow_offset"] =  {indexes = {1},       path = {"shadow", "offset"}, isTable = true},
		["textR_shadow_offset"] =  {indexes = {2, 3, 4}, path = {"shadow", "offset"}, isTable = true},
	}

	--instance root keys that held the value column offsets; the stored anchor x is the negated value
	local CONST_LEGACY_ANCHOR_KEYS = {
		["fontstrings_text2_anchor"] = 2,
		["fontstrings_text3_anchor"] = 3,
		["fontstrings_text4_anchor"] = 4,
	}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--defaults

	---build a fresh settings entry
	---@param point string
	---@param relativeTo string
	---@param relativePoint string
	---@param x number
	---@param justifyH string
	---@return table
	local buildEntry = function(point, relativeTo, relativePoint, x, justifyH, gap)
		return {
			--x is the offset used when this text anchors to a frame of the row. gap is the offset
			--used instead when the text chains onto its right hand neighbour, which is what the
			--auto align setting does to the value columns; only texts 2 and 3 ever chain.
			anchor = {point = point, relativeTo = relativeTo, relativePoint = relativePoint, x = x, y = 0, gap = gap},
			justifyH = justifyH,
			justifyV = "middle",
			width = nil, --nil means let the fontstring size itself
			font = {size = nil, face = nil, outline = ""}, --nil size or face inherits row_info.font_size and row_info.font_face_file
			shadow = {color = {0, 0, 0, 1}, offset = {1, -1}},
			color = {byClass = false, fixed = nil}, --nil fixed inherits row_info.fixed_text_color
		}
	end

	---return a fresh copy of the default settings for the four texts of a row
	---@return table
	function rowTexts.GetDefaultTexts()
		local texts = {
			[1] = buildEntry("left", "icon", "right", 3, "left"),
			[2] = buildEntry("right", "statusbar", "right", -73, "right", -4),
			[3] = buildEntry("right", "statusbar", "right", -38, "right", -4),
			--text 4 is the chain anchor, it always sits against the statusbar and never gets a gap
			[4] = buildEntry("right", "statusbar", "right", 0, "right"),
			__version = CONST_TEXTS_VERSION,
		}

		if (detailsFramework.IsAddonApocalypseWow()) then
			--the unit name is top aligned on this client
			texts[1].justifyV = "top"
		end

		return texts
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--migration and compatibility

	---walk a dotted path inside a settings entry, returning the table holding the last key plus that key
	---@param entry table
	---@param path table
	---@return table, string
	local resolvePath = function(entry, path)
		local holder = entry
		for i = 1, #path - 1 do
			holder = holder[path[i]]
			if (not holder) then
				return nil, nil
			end
		end
		return holder, path[#path]
	end

	---read a legacy key out of the new settings table
	---@param texts table
	---@param legacyKey string
	---@return any
	local readLegacy = function(texts, legacyKey)
		local map = CONST_LEGACY_MAP[legacyKey]
		local entry = texts[map.indexes[1]]
		if (not entry) then
			return nil
		end

		local holder, key = resolvePath(entry, map.path)
		if (not holder) then
			return nil
		end

		return holder[key]
	end

	---write a legacy key into the new settings table, fanning out to every index it covers
	---@param texts table
	---@param legacyKey string
	---@param value any
	local writeLegacy = function(texts, legacyKey, value)
		local map = CONST_LEGACY_MAP[legacyKey]

		for _, index in ipairs(map.indexes) do
			local entry = texts[index]
			if (entry) then
				local holder, key = resolvePath(entry, map.path)
				if (holder) then
					if (map.isTable and type(value) == "table") then
						--overwrite the contents instead of storing the reference, so the indexes
						--never end up sharing a table inside savedvariables
						local target = holder[key]
						if (type(target) ~= "table") then
							target = {}
							holder[key] = target
						end
						table.wipe(target)
						for i = 1, #value do
							target[i] = value[i]
						end
					else
						holder[key] = value
					end
				end
			end
		end
	end

	---fold the flat legacy keys of a row_info into row_info.texts.
	---
	---idempotent by construction rather than by a version gate: the defaults are always
	---backfilled (a skin can replace row_info.texts with a partial table, and LoadInstanceConfig
	---only fills defaults two levels deep so it cannot reach the leaves), and folding a legacy
	---key is a no-op once that key is gone.
	---@param instance table the window owning this row_info, needed for the instance root anchor keys
	---@param rowInfo table
	function rowTexts.Migrate(instance, rowInfo)
		if (not rowInfo) then
			return
		end

		local texts = rawget(rowInfo, "texts")
		if (not texts) then
			texts = {}
			rawset(rowInfo, "texts", texts)
		end

		Details.table.deploy(texts, rowTexts.GetDefaultTexts())

		--fold in the flat keys that are still present, then drop them
		for legacyKey in pairs(CONST_LEGACY_MAP) do
			local value = rawget(rowInfo, legacyKey)
			if (value ~= nil) then
				writeLegacy(texts, legacyKey, value)
				rawset(rowInfo, legacyKey, nil)
			end
		end

		--the legacy value column offsets live on the instance itself and not on row_info. they are
		--not in instance_defaults, so once removed here they don't come back on the next login.
		if (instance) then
			for legacyKey, index in pairs(CONST_LEGACY_ANCHOR_KEYS) do
				local value = rawget(instance, legacyKey)
				if (type(value) == "number") then
					texts[index].anchor.x = -value
					rawset(instance, legacyKey, nil)
				end
			end
		end
	end

	local legacyShim = {
		__index = function(rowInfo, key)
			local map = CONST_LEGACY_MAP[key]
			if (not map) then
				return nil
			end

			local texts = rawget(rowInfo, "texts")
			if (not texts) then
				return nil
			end

			return readLegacy(texts, key)
		end,

		__newindex = function(rowInfo, key, value)
			local map = CONST_LEGACY_MAP[key]
			if (not map) then
				rawset(rowInfo, key, value)
				return
			end

			local texts = rawget(rowInfo, "texts")
			if (not texts) then
				--nothing to translate onto yet, keep the value so a later Migrate picks it up
				rawset(rowInfo, key, value)
				return
			end

			--deliberately not rawset: keeping the legacy key absent is what makes this
			--metamethod fire again on the next write
			writeLegacy(texts, key, value)
		end,
	}

	---attach the legacy key translation metatable. Details.CopyTable does not carry metatables,
	---so this has to run again every time row_info is created or replaced wholesale.
	---@param rowInfo table
	function rowTexts.EnsureShim(rowInfo)
		if (not rowInfo) then
			return
		end

		if (getmetatable(rowInfo) ~= legacyShim) then
			setmetatable(rowInfo, legacyShim)
		end
	end

	---migrate then shim a window's row_info, the pair almost every caller wants.
	---
	---every caller reaches this because row_info was just replaced wholesale: a config reset, a
	---profile being applied or a skin being changed. that swaps the entire texts table, and a skin
	---carries bars_inverted too, so the rows have to be re-anchored from the settings that just
	---landed. this is a settings change and not a refresh, so anchoring here is allowed; rows that
	---do not exist yet get anchored by CreateNewLine instead.
	---@param instance table
	function rowTexts.Prepare(instance)
		if (not instance or not instance.row_info) then
			return
		end

		rowTexts.Migrate(instance, instance.row_info)
		rowTexts.EnsureShim(instance.row_info)
		rowTexts.ApplyAnchorsToAllRows(instance)
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--applying

	---mirror an anchor horizontally for a window using inverted bars.
	---
	---the settings always store the non inverted (left to right) layout; this is the only place
	---that derives the mirrored one. flipping the orientation is an option, so it re-anchors and
	---refreshes through Details:SetBarOrientationDirection rather than being recomputed per frame.
	---@param point string
	---@param relativePoint string
	---@param x number
	---@return string, string, number
	local mirrorAnchor = function(point, relativePoint, x)
		return CONST_MIRRORED_POINTS[point] or point,
			CONST_MIRRORED_POINTS[relativePoint] or relativePoint,
			-x
	end

	---is this window packing its value columns against each other rather than positioning each one
	---against the statusbar? that is what the auto align setting now means: text 4 stays anchored to
	---the statusbar's right edge and texts 3 and 2 hang off the left edge of their right hand
	---neighbour, so a wide value pushes the columns to its left instead of overlapping them.
	---@param instance table
	---@return boolean
	local isChained = function(instance)
		--this client positions the columns by a fixed spacing of its own, see ResolveAnchor
		if (detailsFramework.IsAddonApocalypseWow()) then
			return false
		end

		return instance.use_multi_fontstrings and instance.use_auto_align_multi_fontstrings
	end

	rowTexts.IsChained = isChained

	---resolve the final anchor for one text of a row, honouring the icon substitution, the chained
	---value columns and the Apocalypse column spacing
	---@param instance table
	---@param row table
	---@param index number
	---@param setOffset number? 0 for lineText1 to 4, CONST_SECONDARY_OFFSET for lineText11 to 14
	---@return string point
	---@return table relativeFrame
	---@return string relativePoint
	---@return number x
	---@return number y
	function rowTexts.ResolveAnchor(instance, row, index, setOffset)
		setOffset = setOffset or 0

		local rowInfo = instance.row_info
		local anchor = rowInfo.texts[index].anchor

		local point = anchor.point
		local relativeToken = anchor.relativeTo
		local relativePoint = anchor.relativePoint
		local x = anchor.x
		local y = anchor.y

		--set directly when the text chains onto a sibling fontstring instead of a frame of the row
		local relativeFrame

		--the name string hangs off the class icon; with no icon it falls back to the statusbar's own edge
		if (relativeToken == "icon" and rowInfo.no_icon) then
			relativeToken = "statusbar"
			relativePoint = point
		end

		--the name string carries its own user offset, the same way every text carries text_yoffset
		if (index == CONST_NAME_INDEX) then
			x = x + rowInfo.textL_offset
		end

		--this client spaces the value columns evenly instead of using per column offsets
		if (detailsFramework.IsAddonApocalypseWow() and index >= CONST_FIRST_VALUE_INDEX) then
			local spacing = Details.righttext_simple_formatting.alignment_space
			point = "right"
			relativeToken = "statusbar"
			relativePoint = "right"
			x = -spacing * (CONST_LAST_VALUE_INDEX - index)

		elseif (index >= CONST_FIRST_VALUE_INDEX and index < CONST_LAST_VALUE_INDEX and isChained(instance)) then
			--chain onto the neighbour of the same fontstring set, so lineText2 follows lineText3 and
			--lineText12 follows lineText13
			relativeFrame = row["lineText" .. (index + 1 + setOffset)]
			point = "right"
			relativePoint = "left"
			x = anchor.gap or 0
			--the neighbour already carries text_yoffset, so only this text's own tweak applies
			y = anchor.y

			if (instance.bars_inverted) then
				point, relativePoint, x = mirrorAnchor(point, relativePoint, x)
			end

			return point, relativeFrame, relativePoint, x, y
		end

		if (instance.bars_inverted) then
			point, relativePoint, x = mirrorAnchor(point, relativePoint, x)
		end

		y = y + rowInfo.text_yoffset

		local getFrame = CONST_RELATIVE_FRAMES[relativeToken] or CONST_RELATIVE_FRAMES["statusbar"]

		return point, getFrame(row), relativePoint, x, y
	end

	---resolve the horizontal justification of one text. this mirrors with the orientation for the
	---same reason the anchor does: a text anchored by its right edge has to be right justified or
	---it drifts away from its anchor as soon as the fontstring is wider than its string.
	---@param instance table
	---@param index number
	---@return string
	function rowTexts.ResolveJustifyH(instance, index)
		local justifyH = instance.row_info.texts[index].justifyH

		if (instance.bars_inverted) then
			return CONST_MIRRORED_POINTS[justifyH] or justifyH
		end

		return justifyH
	end

	---anchor every text of a row from row_info.texts.
	---
	---ONE OF THE TWO PLACES ALLOWED TO MOVE A ROW TEXT. Call it when the fontstrings are created
	---and when an option changes an anchor setting. Do not call it from a refresh path.
	---@param instance table
	---@param row table
	function rowTexts.ApplyAnchors(instance, row)
		--anchor the rightmost value column first and walk left, so a chained text is positioned
		--after the neighbour it hangs off. the name comes last, it never chains.
		for index = CONST_LAST_VALUE_INDEX, CONST_NAME_INDEX, -1 do
			--each fontstring set is resolved on its own, since a chained text points at the
			--neighbour within its own set
			for _, offset in ipairs(CONST_SET_OFFSETS) do
				local fontString = row["lineText" .. (index + offset)]
				if (fontString) then
					local point, relativeFrame, relativePoint, x, y = rowTexts.ResolveAnchor(instance, row, index, offset)
					fontString:ClearAllPoints()
					fontString:SetPoint(point, relativeFrame, relativePoint, x, y)
				end
			end
		end
	end

	---anchor every text of every row of a window
	---@param instance table
	function rowTexts.ApplyAnchorsToAllRows(instance)
		if (not instance.barras) then
			return
		end

		for _, row in ipairs(instance.barras) do
			rowTexts.ApplyAnchors(instance, row)
		end
	end

	---restyle every text of every row of a window, without touching anchors
	---@param instance table
	function rowTexts.ApplyStyleToAllRows(instance)
		if (not instance.barras) then
			return
		end

		for _, row in ipairs(instance.barras) do
			rowTexts.ApplyStyleToRow(instance, row)
		end
	end

	---style one fontstring; called twice per settings index, once for each parallel set.
	---deliberately does not touch SetPoint, see the note at the top of this file.
	local applyStyleToFontString = function(fontString, settings, justifyH, face, size, outline, shadow, fixedColor)
		if (not fontString) then
			return
		end

		--the font goes first: this reaches FontString:SetFont, and it is not worth depending on
		--that leaving justification, shadow and spacing alone
		detailsFramework:SetFont(fontString, face, size, outline)

		fontString:SetJustifyH(justifyH)
		fontString:SetJustifyV(settings.justifyV)

		fontString:SetShadowColor(unpack(shadow.color))
		fontString:SetShadowOffset(unpack(shadow.offset))

		--0 means "size to the string". always write it, never leave a stale width behind: with auto
		--align the value columns chain onto each other's edges, so a fontstring that is wider than
		--its text pushes its neighbours out by the width of the box instead of the width of the text
		fontString:SetWidth(settings.width or 0)

		--class colored texts are recolored by the per bar refresh instead, so fixedColor is nil there
		if (fixedColor) then
			fontString:SetTextColor(fixedColor[1], fixedColor[2], fixedColor[3], fixedColor[4])
		end
	end

	---style every text of a row from row_info.texts: justify, font, shadow, width and colour.
	---anchors are NOT part of this, they belong to ApplyAnchors.
	---@param instance table
	---@param row table
	function rowTexts.ApplyStyleToRow(instance, row)
		local rowInfo = instance.row_info
		local texts = rowInfo.texts

		local inheritedFace = rowInfo.font_face_file or "GameFontHighlight"
		local inheritedSize = rowInfo.font_size or rowInfo.height * 0.75
		local inheritedColor = rowInfo.fixed_text_color

		for index = CONST_NAME_INDEX, CONST_LAST_VALUE_INDEX do
			local settings = texts[index]

			local font = settings.font
			local shadow = settings.shadow
			local color = settings.color

			local face = font.face or inheritedFace
			local size = font.size or inheritedSize
			local outline = font.outline or ""

			local fixedColor
			if (not color.byClass) then
				fixedColor = color.fixed or inheritedColor
			end

			--justification mirrors with the orientation, the same way the anchor does
			local justifyH = rowTexts.ResolveJustifyH(instance, index)

			--both the primary and the parallel fontstring set are styled from this same entry
			applyStyleToFontString(row["lineText" .. index], settings, justifyH, face, size, outline, shadow, fixedColor)
			applyStyleToFontString(row["lineText" .. (index + CONST_SECONDARY_OFFSET)], settings, justifyH, face, size, outline, shadow, fixedColor)
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--keeping the unit name clear of the value columns

	---how far into the row the value columns reach, measured from the statusbar edge they hang off.
	---only the columns actually showing something count: an empty column still has a position, but
	---nothing is drawn there, so the name is free to use that space.
	---@param row table
	---@param instance table
	---@return number? nil when a width could not be read, in which case do not resize anything
	function rowTexts.GetValueColumnsExtent(row, instance)
		local texts = instance.row_info.texts
		local bChained = isChained(instance)

		local extent = 0
		local isApocalypse = detailsFramework.IsAddonApocalypseWow()

		for index = CONST_LAST_VALUE_INDEX, CONST_FIRST_VALUE_INDEX, -1 do
			local fontString = row["lineText" .. index]
			local text = fontString and fontString:GetText()

			local stringWidth = 0
			if (text and text ~= "") then
				stringWidth = fontString:GetStringWidth()
				if (isApocalypse and issecretvalue(stringWidth)) then
					return nil
				end
			end

			if (stringWidth > 0) then
				if (bChained) then
					--the columns hang off each other, so widths and gaps accumulate. the gap is
					--stored negative, it pulls this column back towards its right hand neighbour
					extent = extent + stringWidth - (texts[index].anchor.gap or 0)
				else
					--each column sits at its own distance from the statusbar edge, so the one
					--reaching furthest in is the only one that bounds the name
					local reach = -texts[index].anchor.x + stringWidth
					if (reach > extent) then
						extent = reach
					end
				end
			end
		end

		return extent
	end

	---trim the unit name so it stops clear of the value columns.
	---
	---NO ROW TEXT MAY CARRY A WIDTH, which is why this trims the string instead of sizing the
	---fontstring. all eight are placed by a single anchor point and size themselves to their
	---string, and that is what makes the layout work: the value columns chain onto each other's
	---edges under auto align, so a box wider than its text would push its neighbours out by the
	---width of the box rather than the width of the text. the name is anchored by the edge facing
	---the icon, so a box would have to justify its text against that same edge to stay put - and it
	---does not. give the name a box and the glyphs draw against the box's left edge whatever the
	---justification says, which on a right to left row is the far end from the icon, while GetPoint,
	---GetLeft/GetRight and even GetJustifyH all keep reporting the layout you asked for.
	---
	---the row's own width is used rather than instance.cached_bar_width so this stays correct while
	---a window is being dragged wider, which is when the cached value is stale.
	---@param row table
	---@param instance table
	---@param padding number? space left between the name and the columns, defaults to 20
	function rowTexts.FitNameText(row, instance, padding)
		local extent = rowTexts.GetValueColumnsExtent(row, instance)
		if (not extent) then
			return
		end

		--the 'unit name size offset' option tunes how much room the name gets, positive for more
		local userOffset = instance.fontstrings_text_limit_offset or 0

		detailsFramework:TruncateTextSafe(row.lineText1, row:GetWidth() - extent - (padding or 20) + userOffset)
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--options panel entry point

	---write a single setting on one text of a window
	---@param instance table
	---@param index number which text, 1 is the unit name and 2 to 4 the value columns
	---@param path string dotted path inside the settings entry, e.g. "anchor.x" or "font.outline"
	---@param value any
	function rowTexts.Set(instance, index, path, value)
		local settings = instance.row_info.texts[index]
		if (not settings) then
			return
		end

		local keys = {strsplit(".", path)}
		local holder = settings

		for i = 1, #keys - 1 do
			holder = holder[keys[i]]
			if (not holder) then
				return
			end
		end

		holder[keys[#keys]] = value
	end

	---read a single setting off one text of a window
	---@param instance table
	---@param index number
	---@param path string
	---@return any
	function rowTexts.Get(instance, index, path)
		local settings = instance.row_info.texts[index]
		if (not settings) then
			return nil
		end

		local keys = {strsplit(".", path)}
		local holder = settings

		for i = 1, #keys - 1 do
			holder = holder[keys[i]]
			if (not holder) then
				return nil
			end
		end

		return holder[keys[#keys]]
	end
