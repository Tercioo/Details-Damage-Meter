buildmenu search panel documentation

Purpose
- Explain how to build a search panel for options created with
  DetailsFramework:BuildMenu() / DetailsFramework:BuildMenuVolatile().
- This guide is based on two real patterns:
  1) Details options search (live search on typing).
  2) Plater options search (submit search on Enter, with a global entry box).

=====================================================================
1) Core idea
=====================================================================

BuildMenu does not provide a built-in cross-tab search index.
Search works by rebuilding a temporary menu (usually with BuildMenuVolatile)
using matched widget tables from previously built menuOptions arrays.

BuildMenuVolatile vs BuildMenu:
- BuildMenu creates persistent widgets on the parent frame.
- BuildMenuVolatile wipes previous widgets (clears widget_to_disable_check)
  and sets up a refresh timer to prevent rapid re-calls when values change.
  This makes it ideal for search results that get rebuilt on each query.

In practice, you need to:
- Keep references to all option sub-frames.
- Keep references to each sub-frame menuOptions table.
- Flatten these menuOptions into an index.
- Filter the index by query (name and tags).
- Build a "results menu" on a dedicated search frame.

=====================================================================
2) Important architecture rule
=====================================================================

Most options windows have several sub-frames, each one with its own BuildMenu()
call and its own menuOptions table.

To make search work across the entire options UI, every searchable section
must be registered when it is created.

If a frame/menuOptions pair is not stored, the search algorithm cannot find
options from that section.

Recommended registration shape:

	searchableSections[#searchableSections+1] = {
		frame = sectionFrame,
		header = "Display",       -- tab/section title shown in results
		menuOptions = sectionOptions,
	}

=====================================================================
3) Tags support (.tags in widgetTable)
=====================================================================

Each widget table inside menuOptions can optionally include:

	tags = {"keyword1", "keyword2", ...}

Use tags when the visible option name is not enough for good discovery.
Example for a color setting:

	tags = {"color", "background", "alpha", "rgb"}

Search should check both:
- widgetTable.name
- widgetTable.tags entries

This gives better matches for alternate wording and user vocabulary.

=====================================================================
4) Data model used by the search algorithm
=====================================================================

When flattening all sections, keep these fields per option:

- setting: the original widget table from menuOptions.
- header: section title (tab name).
- label: nearest previous label row (type == "label") for context grouping.
- searchText: normalized combined text used for matching.

Recommended searchText content:
- lower(name)
- lower(desc) (optional but useful)
- lower(concatenated tags)

=====================================================================
5) Full comprehensive example
=====================================================================

The snippet below shows a complete pattern:
- multiple sections registered,
- dedicated search results frame,
- search box,
- optional global search box,
- tags-aware filtering,
- grouped BuildMenuVolatile result rendering.

```lua
local DF = DetailsFramework

local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

local SEARCH_HEADER_TEMPLATE = {color = "gold", size = 14, font = DF:GetBestFontForLanguage()}

-- all registered sections that have BuildMenu-generated options
local searchableSections = {}

-- flattened cache used for searching
local allIndexedOptions = {}

-- Register each section right after creating and building its menu.
local function RegisterSearchableSection(sectionFrame, sectionHeader, sectionOptions)
	if not sectionFrame or not sectionOptions then
		return
	end

	sectionFrame.sectionOptions = sectionOptions -- keep reference for other systems too

	searchableSections[#searchableSections+1] = {
		frame = sectionFrame,
		header = sectionHeader or "Section",
		menuOptions = sectionOptions,
	}
end

local function NormalizeText(text)
	if type(text) ~= "string" then
		return ""
	end
	return string.lower(text)
end

local function BuildSearchText(setting)
	local parts = {}

	if type(setting.name) == "string" then
		parts[#parts+1] = setting.name
	end

	if type(setting.desc) == "string" then
		parts[#parts+1] = setting.desc
	end

	if type(setting.tags) == "table" then
		for i = 1, #setting.tags do
			local tagText = setting.tags[i]
			if type(tagText) == "string" and tagText ~= "" then
				parts[#parts+1] = tagText
			end
		end
	end

	return NormalizeText(table.concat(parts, " "))
end

local function RebuildSearchIndex()
	table.wipe(allIndexedOptions)

	for i = 1, #searchableSections do
		local sectionData = searchableSections[i]
		local sectionOptions = sectionData.menuOptions
		local lastLabel

		for k, setting in pairs(sectionOptions) do
			if type(setting) == "table" then
				if setting.type == "label" then
					lastLabel = setting
				end

				-- only visible widgets that represent actual options should be indexed
				if setting.name and not setting.hidden then
					allIndexedOptions[#allIndexedOptions+1] = {
						setting = setting,
						label = lastLabel,
						header = sectionData.header,
						searchText = BuildSearchText(setting),
					}
				end
			end
		end
	end
end

local function BuildResultOptions(queryText)
	local results = {}
	local normalizedQuery = NormalizeText(queryText)

	if normalizedQuery == "" then
		return results
	end

	local lastHeader
	local lastLabel

	for i = 1, #allIndexedOptions do
		local optionData = allIndexedOptions[i]
		if optionData.searchText:find(normalizedQuery, 1, true) then
			if optionData.header ~= lastHeader then
				if lastHeader ~= nil then
					-- visual separation between tab groups
					results[#results+1] = {
						type = "label",
						get = function() return "" end,
						text_template = options_text_template,
					}
				end

				results[#results+1] = {
					type = "label",
					get = function() return optionData.header end,
					text_template = SEARCH_HEADER_TEMPLATE,
				}

				lastHeader = optionData.header
				lastLabel = nil
			end

			if optionData.label and optionData.label ~= lastLabel then
				results[#results+1] = optionData.label
				lastLabel = optionData.label
			end

			results[#results+1] = optionData.setting
		end
	end

	-- global menu options flags
	results.always_boxfirst = true
	results.language_addonId = "YourAddonId"
	results.Name = "Options Search Results"

	return results
end

local function RenderSearchResults(searchFrame, queryText)
	local startX, startY, heightSize = 200, -80, 560
	local resultOptions = BuildResultOptions(queryText)

	DF:BuildMenuVolatile(
		searchFrame,
		resultOptions,
		startX,
		startY,
		heightSize,
		false,
		options_text_template,
		options_dropdown_template,
		options_switch_template,
		true,
		options_slider_template,
		options_button_template,
		nil
	)
end

-- Build search UI in your options window.
local function CreateOptionsSearchPanel(optionsContainerFrame, searchFrame, topOverlayFrame)
	local searchBox = DF:CreateTextEntry(
		searchFrame,
		function() end,
		160,
		20,
		"searchTextEntry",
		nil,
		nil,
		options_dropdown_template
	)
	searchBox:SetAsSearchBox()
	searchBox:SetPoint("topleft", searchFrame, "topleft", 10, -145)

	-- optional global search box (top-right) that redirects to search tab
	local mainSearchBox = DF:CreateTextEntry(
		topOverlayFrame,
		function() end,
		160,
		20,
		"mainSearchTextEntry",
		nil,
		nil,
		options_dropdown_template
	)
	mainSearchBox:SetAsSearchBox()
	mainSearchBox:SetPoint("topright", topOverlayFrame, "topright", -220, 0)

	-- Enter-to-search (Plater style)
	searchBox:SetHook("OnEnterPressed", function()
		RebuildSearchIndex()
		RenderSearchResults(searchFrame, searchBox.text or "")
	end)

	-- Optional live search style (Details style)
	-- searchBox:SetHook("OnChar", function()
	--     RebuildSearchIndex()
	--     RenderSearchResults(searchFrame, searchBox.text or "")
	-- end)

	mainSearchBox:SetHook("OnEnterPressed", function()
		searchBox:SetText(mainSearchBox:GetText() or "")
		-- RunHooksForWidget fires all registered hooks for the named script.
		-- This triggers the searchBox OnEnterPressed hook above, executing the search.
		searchBox:RunHooksForWidget("OnEnterPressed")
		-- switch to search tab/frame here
		-- optionsContainerFrame:SelectTabByIndex(SEARCH_TAB_INDEX)
	end)
end

---------------------------------------------------------------------
-- Example section registrations (three sub-frames, three BuildMenu calls)
---------------------------------------------------------------------

-- Section A
local sectionAOptions = {
	{
		type = "toggle",
		name = "Enable Backdrop",
		desc = "Enable or disable the panel backdrop.",
		tags = {"background", "backdrop", "panel", "style"},
		get = function() return MyDB.enableBackdrop end,
		set = function(_, _, value) MyDB.enableBackdrop = value end,
	},
}
-- DF:BuildMenu(sectionAFrame, sectionAOptions, ...)
-- RegisterSearchableSection(sectionAFrame, "Display", sectionAOptions)

-- Section B
local sectionBOptions = {
	{
		type = "color",
		name = "Backdrop Color",
		desc = "Main backdrop color.",
		tags = {"color", "background", "alpha", "rgb"},
		get = function() return {0.1, 0.1, 0.1, 0.8} end,
		set = function(_, r, g, b, a)
			MyDB.backdropColor = {r, g, b, a}
		end,
	},
}
-- DF:BuildMenu(sectionBFrame, sectionBOptions, ...)
-- RegisterSearchableSection(sectionBFrame, "Colors", sectionBOptions)

-- Section C
local sectionCOptions = {
	{
		type = "range",
		name = "Animation Speed",
		desc = "How fast animations should play.",
		tags = {"speed", "animation", "timing", "transition"},
		min = 0.1,
		max = 3,
		step = 0.1,
		usedecimals = true,
		get = function() return MyDB.animationSpeed end,
		set = function(_, _, value) MyDB.animationSpeed = value end,
	},
}
-- DF:BuildMenu(sectionCFrame, sectionCOptions, ...)
-- RegisterSearchableSection(sectionCFrame, "Behavior", sectionCOptions)
```

=====================================================================
6) Practical guidance and pitfalls
=====================================================================

- Rebuild index timing:
  RebuildSearchIndex() can be called once after all sections are initialized,
  and called again only when options tables change.

- Header mapping:
  If your tabs are dynamic or load on demand, ensure search starts only after
  all relevant tabs have sectionOptions available.

- Localization:
  If you use language tables, pass results.language_addonId so BuildMenu can
  resolve names/descriptions consistently in results.

- Hidden entries:
  If widgetTable.hidden is true when BuildMenu parses the options, the widget is
  skipped in UI. For search, decide if hidden entries should be indexed or not.
  Most UIs should skip them.

- Mutable shared setting tables:
  Because results reuse original widget tables, updates in one place affect
  everywhere. This is usually desired, but avoid mutating structural fields in
  the search algorithm.

- Match quality:
  tags are the easiest way to improve discoverability without changing labels.
  Keep tags short, lowercase-friendly, and user-language oriented.

=====================================================================
7) Minimum checklist
=====================================================================

1. Each sub-frame built with BuildMenu stores its menuOptions reference.
2. All searchable sections are registered in one collection.
3. Index builder captures setting + nearest label + section header.
4. Query matches both name and tags (optional: desc).
5. Results are grouped and rendered with BuildMenuVolatile.
6. Search tab/frame is shown when executing search.

=====================================================================
End of buildmenu search panel documentation
=====================================================================

