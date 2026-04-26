
buildmenu.lua documentation
Part 1: widget type registry and core local helper functions

Overview
- buildmenu.lua is the menu construction layer used by DetailsFramework options panels.
- It consumes a menuOptions table (array of widget descriptors), creates UI widgets,
	wires callbacks, applies localization, and refreshes state.
- The same helper functions are used by both DetailsFramework:BuildMenu() and
	DetailsFramework:BuildMenuVolatile().

=====================================================================
1) detailsFramework.ValidBuildMenuWidgetTypes
=====================================================================

Purpose
- This table is the whitelist used to validate whether a widget type can be
	consumed by the menu builder.
- detailsFramework:IsValidWidgetForBuildMenu(widgetType) is a direct lookup in
	this table.

Registered keys and practical meaning
- label: static text row (or dynamic text via get callback).
- select: generic dropdown selector.
- toggle: boolean switch / checkbox style control.
- range: slider control with min/max/step.
- color: color picker button.
- execute: push button that runs func(param1, param2).
- textentry: text input field.
- image: texture row.
- breakline: column break marker. Forces the layout cursor to jump to the
	next column regardless of remaining vertical space (when use_scrollframe
	is true) or when current column exceeds the height threshold (when false).
- space: accepted alias, normalized to blank.
- blank: spacing row / empty row.
- group: visual container that draws a background/border behind member widgets.
	The group entry itself does not consume a layout row. Other widget entries
	reference the group by setting widgetTable.group = "groupName". After the
	build loop, applyGroupFrames() computes a bounding box over all member
	widgets and positions the group frame behind them. Supports both plain
	color-texture and BackdropTemplate appearances.

- fontdropdown: accepted alias, normalized to selectfont.
- texturedropdown: accepted alias, normalized to selectstatusbartexture.
- colordropdown: accepted alias, normalized to selectcolor.
- outlinedropdown: accepted alias, normalized to selectoutline.
- anchordropdown: accepted alias, normalized to selectanchor.
- audiodropdown: accepted alias, normalized to selectaudio.
- dropdown: accepted alias, normalized to select.
- switch: accepted alias, normalized to toggle.
- slider: accepted alias, normalized to range.
- button: accepted alias, normalized to execute.

- selectfont: specialized dropdown generator for font lists.
- selectstatusbartexture: specialized dropdown generator for statusbar textures.
- selectcolor: specialized dropdown generator for color presets.
- selectoutline: specialized dropdown generator for font outlines.
- selectanchor: specialized dropdown generator for anchor points.
- selectaudio: specialized dropdown generator for sound assets.
- selectframestrata: specialized dropdown generator for frame strata values.
- backgrounddropdown: accepted alias, normalized to selectbackgroundtexture.
- selectbackgroundtexture: specialized dropdown generator for background textures.
- borderdropdown: accepted alias, normalized to selectbordertexture.
- selectbordertexture: specialized dropdown generator for border textures.

Important context
- parseOptionsTypes() performs normalization before widget creation. Because of
	that, aliases above are fully supported input types in menuOptions.

Specialized dropdown get/set value reference
- Specialized types auto-generate their values() from DF list generators
	(defined in dropdown.lua). The consumer only needs to provide set and get;
	values is ignored because the generator wires onclick directly to set.
- The set callback signature for all specialized types is:
	function(dropdownObject, fixedValue, selectedValue)
- selectfont:
	- Generator: DF:CreateFontListGenerator(set, include_default).
	- get() should return the SharedMedia font name string (e.g. "Friz Quadrata TT").
	- set receives the selected font name string as the third argument.
	- Optional field: include_default (boolean) — when true, adds a "Default"
	  entry at the top of the font list.
- selectstatusbartexture:
	- Generator: DF:CreateStatusbarTextureListGenerator(set).
	- get() should return the SharedMedia statusbar texture name string.
	- set receives the selected texture name string.
	- Dropdown rows display a statusbar preview of each texture.
- selectbackgroundtexture:
	- Alias of selectstatusbartexture after normalization. Same generator and
	  get/set contract — SharedMedia statusbar texture name strings.
	  Semantically used for background textures but technically identical.
- selectbordertexture:
	- Alias of selectstatusbartexture after normalization. Same generator and
	  get/set contract — SharedMedia statusbar texture name strings.
	  Semantically used for border textures but technically identical.
- selectcolor:
	- Generator: DF:CreateColorListGenerator(set).
	- get() should return a color table {r, g, b, a} or the string "blank".
	- set receives the selected color table (or "blank" for no color).
	- Options come from DF:GetDefaultColorList() plus a "no color" entry.
- selectoutline:
	- Generator: DF:CreateOutlineListGenerator(set).
	- get() should return a font outline flag string: "", "OUTLINE", or
	  "THICKOUTLINE" (values from DF.FontOutlineFlags).
	- set receives the selected outline flag string.
- selectanchor:
	- Generator: DF:CreateAnchorPointListGenerator(set).
	- get() should return an anchor point index (integer, 1-based index into
	  DF.AnchorPoints: 1=topleft, 2=left, 3=bottomleft, etc.).
	- set receives the selected index number.
- selectaudio:
	- Generator: DF:CreateAudioListGenerator(set).
	- get() should return a SharedMedia sound file path string.
	- set receives the selected sound file path string.
	- Options come from LibSharedMedia "sound" hash table, sorted alphabetically.
- selectframestrata:
	- Generator: DF:CreateFrameStrataListGenerator(set).
	- get() should return a frame strata string (e.g. "LOW", "MEDIUM", "HIGH").
	- set receives the selected strata string.
	- Options come from DF.FrameStrataLevels.

=====================================================================
2) Local helper function behavior
=====================================================================

onWidgetSetInUse(widget, widgetTable)
Purpose
- Applies generic enable/disable and child-follow metadata to a created widget.
Behavior
- Copies widgetTable.childrenids into widget.childrenids when present.
- Copies widgetTable.children_follow_enabled into widget.children_follow_enabled.
- If widgetTable.disabled is true, calls widget:Disable().
- Otherwise, if the widget supports IsEnabled and is currently disabled, calls
	widget:Enable().
Why it matters
- Centralizes final state setup used by all widget creation paths.

setWidgetId(parent, widgetTable, widgetObject)
Purpose
- Registers created widgets for later lookup and stores back-reference.
Behavior
- If widgetTable.id exists, writes parent.widgetids[widgetTable.id] = widgetObject.
- Always stores widgetTable.widget = widgetObject.
Why it matters
- Enables parent:GetWidgetById(id) and features such as child-toggle dependency
	chains and disableif checks.

onEnterHighlight(self)
Purpose
- Mouse-enter handler used by row highlight overlay frames.
Behavior
- Shows self.highlightTexture.
- If the parent widget has an OnEnter script, forwards the call to parent.
Why it matters
- Keeps hover highlight visuals in sync while preserving original tooltip/
	hover behavior owned by the parent widget.

onLeaveHighlight(self)
Purpose
- Mouse-leave counterpart of onEnterHighlight.
Behavior
- Hides self.highlightTexture.
- If parent has OnLeave script, forwards the event.
Why it matters
- Restores normal row visuals and correctly triggers parent leave behavior.

processTexture(widget, widgetTable)
Purpose
- Adds or removes an auxiliary icon texture near a widget label.
Behavior
- Normalizes widget = widget.widget or widget.
- If widgetTable.texture is present:
	- Creates widget.IconTexture once (overlay layer), anchored to widget right.
	- Accepts string or number texture paths/ids and applies width/height from
		widgetTable.texture_width/texture_height (or widget height fallback).
	- If widget has a label, stores its original anchor point the first time,
		then reanchors label to the right of the icon texture.
- If widgetTable.texture is not present and an icon is currently shown:
	- Hides widget.IconTexture.
	- Restores label original point when it was saved.
Why it matters
- Gives any row control a compact, optional icon without permanently breaking
	label anchoring.

getNamePhraseID(widgetTable, languageAddonId, languageTable, bIgnoreEmbed)
Purpose
- Resolves which localization phrase id should represent widget name text.
Behavior
- Returns widgetTable.namePhraseId immediately when explicitly provided.
- Returns nil when no language table is available.
- Base key comes from widgetTable.name.
- Special case for label widgets with widgetTable.get: uses get() return value
	when it is a string.
- Supports embedded phrase syntax inside names: @PHRASE_ID@.
- Verifies phrase existence through
	DetailsFramework.Language.DoesPhraseIDExistsInDefaultLanguage().
- Returns:
	- embedPhraseId and true when embedded id is found and bIgnoreEmbed is false.
	- keyName otherwise.
	- nil when no valid phrase id exists.
Why it matters
- Standardizes localization key discovery and supports dynamic or embedded
	phrase naming patterns.

formatOptionNameWithColon(text, useColon)
Purpose
- Minimal formatting helper for fallback non-localized labels.
Behavior
- If text exists:
	- Returns text .. ":" when useColon is true.
	- Returns text unchanged otherwise.
- Returns nil when text is nil.
Why it matters
- Ensures consistent label style in menus that use name-value visual patterns.

getNamePhraseText(languageTable, widgetTable, useColon, languageAddonId)
Purpose
- Produces final human-facing widget name text, with localization fallback chain.
Behavior
- Calls getNamePhraseID() to identify candidate phrase id.
- Tries lookup order in languageTable:
	- languageTable[namePhraseId]
	- languageTable[widgetTable.namePhraseId]
	- languageTable[widgetTable.name]
- If the name used embedded syntax and widgetTable.name exists, substitutes the
	localized phrase back into the original string.
- Final fallback order when no localization hit:
	- formatOptionNameWithColon(widgetTable.name, useColon)
	- widgetTable.namePhraseId
	- widgetTable.name
	- "-?-"
Why it matters
- Acts as the central text resolver for labels, dropdown labels, and button text.

processLabelIcon(label, widgetTable, languageTable, textTemplate, useColon, languageAddonId)
Purpose
- Applies text template and optional inline icon escape sequence into a label.
Behavior
- Applies label:SetTemplate(textTemplate) when provided.
- Resolves base label text through getNamePhraseText().
- If widgetTable.icontexture exists:
	- Uses iconcoords (default .1,.9,.1,.9).
	- Uses iconfilesize (default 64x64).
	- Uses iconsize or current font height as icon dimensions.
	- Builds texture info with detailsFramework:CreateTextureInfo().
	- Injects texture markup into text via detailsFramework:AddTextureToText().
- Stores final string at label.text.
Why it matters
- Provides a consistent way to show semantic icons next to option names without
	creating extra texture widgets for every row.

createOptionHighlightFrame(frame, label, widgetWidth)
Purpose
- Creates a reusable clickable/hoverable row overlay used by paired layouts.
Behavior
- Accepts wrapper objects or raw widgets by normalizing frame = frame.widget or frame
	and label = label.widget or label.
- Creates a button overlay parented to frame, with mouse enabled and frame level
	slightly below the widget.
- Sizes and anchors overlay to cover both label and widget width.
- Wires OnEnter/OnLeave to highlight handlers above.
- Creates:
	- highlightTexture (overlay, alpha 0.1) shown on hover only.
	- backgroundTexture (artwork) with alternating shade per row using
		bHighlightColorOne toggle.
- Stores references:
	- highlightFrame.highlightTexture
	- highlightFrame.parent = frame
- Returns the created highlight frame.
Why it matters
- Delivers row-level hover affordance and enables click-forwarding behaviors used
	by controls like toggle rows in align_as_pairs mode.

=====================================================================
End of Part 1
=====================================================================

=====================================================================
Part 2: widget property setup functions
=====================================================================

Context for this section
- These functions are the per-widget setup stage used by both
	DetailsFramework:BuildMenu() and DetailsFramework:BuildMenuVolatile().
- Each function receives the current widget plus the corresponding menuOptions
	entry (widgetTable), then applies behavior, sizing, hooks, positioning,
	and registration.
- Most of them return updated layout metrics (maxColumnWidth, maxWidgetWidth,
	and occasionally extra values) consumed by the main builder loop.

setLabelProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template)
Purpose
- Initializes a label/text row widget.
Behavior
- Binds widget._get and marks widget.widget_type = "label".
- Positions the label at currentXOffset/currentYOffset.
- Applies either widgetTable.text_template/template or fallback font size.
- Applies custom font face from widgetTable.font when provided.
- Registers widget id/reference through setWidgetId().
- Applies disabled/children state through onWidgetSetInUse().
Why it matters
- This is the minimal setup path that still keeps labels fully compatible with
	refresh and disable dependency logic used by all other widget types.

setDropdownProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth)
Purpose
- Configures select/dropdown widgets after their option generator is assigned.
Behavior
- Sets widget._get and widget_type = "select".
- Refreshes dropdown contents and selects current value from widgetTable.get().
- Applies base template and optional width/height overrides.
- Registers widget id/reference via setWidgetId().
- Reanchors label + widget based on layout mode:
	- align_as_pairs: label anchored to row start; widget aligned at fixed text gap.
	- normal mode: widget placed to the right of label.
- In paired mode, creates highlight overlay row frame if missing.
- Hooks valueChangeHook to OnOptionSelected when provided.
- Applies any custom widgetTable.hooks entries.
- Updates maxColumnWidth and maxWidgetWidth using effective widget + label size.
- Calls onWidgetSetInUse().
Returns
- maxColumnWidth, maxWidgetWidth.
Why it matters
- Standardizes dropdown presentation across generic and specialized select types,
	while preserving shared layout accounting logic.

highlightFrameOnClickToggle(highlightFrame, mouseButton)
Purpose
- Click-forward helper so clicking a paired row background toggles the switch.
Behavior
- Resolves toggle widget from highlightFrame parent (parent.MyObject).
- Computes new state as not widget._get().
- Calls widget.OnSwitch(widget, nil, bNewState) to run the configured setter.
- Updates visual value with widget:SetValue(true/false).
- Triggers widget._valueChangeHook() when present.
Why it matters
- Makes paired toggle rows easier to use: the full highlighted row is clickable,
	not only the switch control itself.

setToggleProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, switchIsCheckbox, bUseBoxFirstOnAllWidgets, menuOptions, index, maxWidgetWidth)
Purpose
- Configures toggle/switch widgets, including child dependency behavior.
Behavior
- Sets widget._get, widget._set, widget_type = "toggle", and OnSwitch callback.
- Optional checkbox style via switchIsCheckbox.
- Handles children_follow_enabled mode:
	- Wraps SetValue to enable/disable child widgets listed in childrenids.
	- Supports children_follow_reverse behavior.
	- Preserves original SetValue in SetValueOriginal and restores it when needed.
- Applies current value from widgetTable.get().
- Applies width/height overrides and template.
- Registers widget via setWidgetId().
- Reanchors label + switch based on layout mode:
	- Paired mode: creates row highlight frame, anchors switch to row right,
		and binds row click to highlightFrameOnClickToggle().
	- Non-paired mode: supports box-first layout and extra spacing heuristics
		based on upcoming widget type.
- Hooks global valueChangeHook on OnSwitch, then applies custom hooks.
- Updates maxColumnWidth/maxWidgetWidth.
- Calls processTexture() to handle optional icon texture attachment.
- Calls onWidgetSetInUse().
Returns
- maxColumnWidth, maxWidgetWidth, extraPaddingY.
Why it matters
- It is the most behavior-rich setup path, because toggles can control other
	rows and need both visual and interaction affordances.

setRangeProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bIsDecimals, bAttachSliderButtonsToLeft)
Purpose
- Configures slider/range widgets.
Behavior
- Sets widget._get and widget_type = "range".
- Applies template and slider button side preference.
- Reads current value from get() and configures step mode:
	- decimal mode uses step 0.01.
	- integer mode uses widgetTable.step or 1 and floors current value.
- Applies min/max and current slider value.
- Applies width/height overrides.
- Hooks OnValueChange to widgetTable.set and optional valueChangeHook.
- Applies thumb scaling from widgetTable.thumbscale or default 1.3x.
- Applies custom hooks list.
- Registers widget via setWidgetId().
- Reanchors in paired or normal layout mode; paired mode creates highlight frame
	and forces buttons-on-left behavior.
- Updates maxColumnWidth/maxWidgetWidth.
- Calls onWidgetSetInUse().
Returns
- maxColumnWidth, maxWidgetWidth.
Why it matters
- Encapsulates numeric input behavior consistently, including decimal support
	and per-row slider appearance tuning.

setColorProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, bUseBoxFirstOnAllWidgets, extraPaddingY)
Purpose
- Configures color picker rows.
Behavior
- Sets widget._get and widget_type = "color".
- Reads current color through detailsFramework:ParseColors(widgetTable.get()).
- Applies color_callback and OnColorChanged hook to widgetTable.set.
- Applies optional global valueChangeHook and custom hook list.
- Applies template and fixed 18x18 button size.
- Registers widget via setWidgetId().
- Reanchors in paired or normal layout mode:
	- Paired mode creates row highlight frame and aligns picker to row right.
	- Normal mode supports box-first placement and optional extra padding.
- Updates maxColumnWidth/maxWidgetWidth.
- Calls onWidgetSetInUse().
Returns
- maxColumnWidth, maxWidgetWidth, extraPaddingY.
Why it matters
- Keeps color options compact and consistent while still integrating with the
	same refresh/hook/disable infrastructure as other controls.

setExecuteProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate, latestInlineWidget)
Purpose
- Configures action button rows (execute/button).
Behavior
- Sets widget._get and widget_type = "execute".
- Applies template and final size (global override or per-widget width/height).
- Binds click function with optional param1/param2 payload.
- Optional button icon via widgetTable.icontexture/icontexcoords.
- Resolves text styling from widgetTable.text_template, provided textTemplate,
	or ORANGE_FONT_TEMPLATE fallback.
- Applies custom hooks list.
- Registers widget via setWidgetId().
- Reanchors in paired or normal layout mode:
	- Paired mode anchors by label and uses ">" as row marker label text.
	- Normal mode supports inline chaining using latestInlineWidget.
- Updates maxColumnWidth/maxWidgetWidth.
- Calls onWidgetSetInUse().
Returns
- maxColumnWidth, maxWidgetWidth, latestInlineWidget.
Why it matters
- Handles command/action rows, including inline button groups and iconized
	actions without adding special-case code to the main loop.

setImageProperties(parent, widget, widgetTable, currentXOffset, currentYOffset)
Purpose
- Configures texture/image rows.
Behavior
- Accepts either color tables or texture paths/ids:
	- table => ParseColors + SetColorTexture.
	- string/number => SetTexture with optional filterType.
- Applies width/height from widgetTable.
- Applies texcoord crop (defaults 0,1,0,1).
- Applies optional vertexcolor (or defaults to white).
- Registers widget via setWidgetId().
- Clears anchors and places image at current row position.
Why it matters
- Provides non-interactive visual rows with the same positioning/id behavior as
	interactive controls.

setTextEntryProperties(parent, widget, widgetTable, currentXOffset, currentYOffset, template, widgetWidth, widgetHeight, bAlignAsPairs, nAlignAsPairsLength, valueChangeHook, maxColumnWidth, maxWidgetWidth, textTemplate, latestInlineWidget)
Purpose
- Configures editable text entry rows.
Behavior
- Sets widget._get, initial text from get(), and widget_type = "textentry".
- Applies template chain (widgetTable.template/button_template/fallback template).
- Applies final size from global/per-widget options.
- Sets commit function from widgetTable.func or widgetTable.set.
- Hooks both OnEnterPressed and OnEditFocusLost to:
	- call func/set,
	- then call optional valueChangeHook.
- Resolves text styling template similarly to execute widgets.
- Applies custom hooks list.
- Registers widget via setWidgetId().
- Reanchors in paired or normal layout mode; paired mode creates highlight frame.
- Updates maxColumnWidth/maxWidgetWidth.
- Calls onWidgetSetInUse().
Returns
- maxColumnWidth, maxWidgetWidth.
Why it matters
- Ensures text edits are committed on both enter and focus loss, which keeps
	menu state synchronized even when users do not press Enter explicitly.

=====================================================================
End of Part 2
=====================================================================

=====================================================================
Part 3: menu helper functions
=====================================================================

Context for this section
- These helpers are shared by BuildMenu() and BuildMenuVolatile() to normalize
	input options, prepare panel state, and keep widgets synchronized after build.
- They do not create option semantics by themselves; instead, they orchestrate
	how already-created widgets are updated, grouped, and looked up.

getOrCreateGroupFrame(parent, groupName, widgetTable, isVolatile, indexTable)
Purpose
- Creates or reuses a BackdropTemplate frame that acts as the visual background
	container for a group of widgets.
Parameters
- parent: the options panel frame.
- groupName: string identifier matching the group= field on member widgets.
- widgetTable: the df_menu_group descriptor (carries color, UseBackdrop, etc.).
- isVolatile: when true, reuses frames from parent.widget_list_by_type["group"]
	pool using indexTable counters.
- indexTable: volatile pool index table (nil for non-volatile builds).
Behavior
- In volatile mode, retrieves the next frame from the pool or creates a new one
	on cache miss, then advances the pool counter.
- In non-volatile mode, always creates a new frame.
- Creates a backgroundTexture child (background layer, all-points) for plain
	color mode.
- Sets groupFrame.groupName, resets frame level to parent level, clears anchors,
	and hides the frame (it will be shown later by applyGroupFrames).
- Applies visual style based on widgetTable:
	- If UseBackdrop is set: calls SetBackdrop() with the provided table, applies
		BackgroundColor and BackdropBorderColor, and hides the plain texture.
	- Otherwise: clears backdrop, applies color via SetColorTexture on the
		backgroundTexture, and shows it.
Returns
- The created or reused group frame.
Why it matters
- Separates frame lifecycle management from the post-build layout pass. The
	group frame is invisible until applyGroupFrames positions and sizes it.

applyGroupFrames(parent, menuOptions)
Purpose
- Post-build pass that positions all group frames and reparents member widgets
	into their group.
Behavior
- First pass: collects group definitions (type == "group" with a .widget
	back-reference) into groupFrames and groupSettings maps keyed by name.
- Second pass: collects member widgets (type ~= "group" with a .group field and
	a .widget back-reference) into groupWidgets map keyed by group name.
- For each group with at least one member:
	- Computes a bounding box over all member widget frames.
	- Uses getRegionBounds() helper to safely handle both regular frames and
		FontStrings (labels), which may not have valid bounds from GetLeft/GetTop
		before the first render pass.
	- For non-label widgets, also includes the hasLabel companion label in the
		bounding box computation.
	- If widgetTable.width or widgetTable.height is set, uses those values
		instead of the computed dimensions (but still uses the computed top-left
		anchor position).
	- Anchors the group frame to the parent at the computed position with a 4
		pixel padding margin.
	- Shows the group frame.
	- Reparents all member widget frames (and their hasLabel companions) to the
		group frame. Sets their frame level above the group background. Guards
		SetFrameLevel with a type check to avoid errors on FontStrings.
- Groups with no members are hidden.
Called from
- Both BuildMenu and BuildMenuVolatile, after the main widget-creation loop
	completes.
Why it matters
- This is the core of the group feature: it turns independent widget entries
	into visually grouped sets by computing layout from their actual screen
	positions. The two-pass approach (collect then compute) allows group
	definitions and member widgets to appear in any order in menuOptions.

checkForDisableIF(parent)
Purpose
- Applies dynamic enabled/disabled state from widgetTable.disableif callbacks.
Behavior
- Iterates parent.widget_to_disable_check.
- For each widgetTable with disableif:
	- Calls disableif().
	- If result is true and widget supports Disable, calls widget:Disable().
	- Otherwise, if widget is locked down or currently disabled, calls widget:Enable().
Important clarification
- In the current implementation, disableif does not hide the option.
- It disables/enables the widget state.
Why it matters
- Central place to reevaluate conditional availability during initial build and
	each refresh pass.

onMenuBuilt(parent)
Purpose
- Post-build reconciliation for parent/child toggle dependencies.
Behavior
- Scans parent.build_menu_options for widgets using children_follow_enabled.
- Reads each parent widget current value and enables/disables child widgets
	listed in childrenids.
- Honors children_follow_reverse for inverted behavior.
- Calls checkForDisableIF(parent) at the end.
Why it matters
- Ensures dependent rows are correctly enabled/disabled even after external
	state changes or delayed widget creation order.

refreshOptions(self)
Purpose
- Refresh routine attached to options panels to sync UI from model getters.
Behavior
- Iterates self.widget_list.
- For widgets that expose _get, updates by widget_type:
	- label: SetText(_get()) when not language-managed.
	- select: Select(_get()).
	- toggle/range: SetValue(_get()).
	- textentry: SetText(_get()).
	- color: supports either packed table return or r,g,b,a tuple return.
- Calls checkForDisableIF(self).
- Calls onMenuBuilt(self).
- Exported as detailsFramework.internalFunctions.RefreshOptionsPanel.
Why it matters
- Keeps all controls in sync with source data and reapplies dependency/disable
	rules after values change.

parseOptionsTypes(menuOptions)
Purpose
- Normalizes legacy/alias widget type names into canonical builder types.
Behavior
- Rewrites specific aliases in-place, for example:
	- space -> blank
	- fontdropdown -> selectfont
	- texturedropdown -> selectstatusbartexture
	- backgrounddropdown -> selectbackgroundtexture
	- borderdropdown -> selectbordertexture
	- colordropdown -> selectcolor
	- outlinedropdown -> selectoutline
	- anchordropdown -> selectanchor
	- audiodropdown -> selectaudio
	- dropdown -> select
	- switch -> toggle
	- slider -> range
	- button -> execute
Why it matters
- Lets callers use older or alternative naming styles while keeping downstream
	build logic simple and consistent.

parseOptionsTable(menuOptions)
Purpose
- Extracts and returns global menu layout/configuration flags.
Behavior
- Reads options such as:
	- always_boxfirst
	- widget_width / widget_height
	- align_as_pairs
	- align_as_pairs_string_space
	- align_as_pairs_spacing
	- slider_buttons_to_left
	- use_scrollframe
	- language_addonId
- Returns a fixed tuple consumed by both build functions.
Why it matters
- Centralizes menu-level defaults so per-widget code stays focused on widget
	behavior instead of parsing global options repeatedly.

parseParent(bUseScrollFrame, parent, height, yOffset)
Purpose
- Resolves the effective build parent and vertical space policy.
Behavior
- If using a scrollframe:
	- Uses parent:GetScrollChild() as target parent.
	- Resizes child canvas to parent size.
- Otherwise:
	- Computes a negative height threshold when explicit height is provided
		(adjusted by yOffset).
	- Falls back to parent:GetHeight() when no explicit numeric height exists.
- Returns normalized parent and height.
Why it matters
- Unifies geometry behavior between fixed panels and scrollable panels.

parseLanguageTable(languageAddonId)
Purpose
- Resolves localization table for this menu build.
Behavior
- If languageAddonId exists, loads it using
	DetailsFramework.Language.GetLanguageTable(languageAddonId).
- Otherwise returns nil.
Why it matters
- Keeps localization optional while giving name/description helpers a consistent
	language table source when localization is enabled.

getFrameById(self, id)
Purpose
- Simple id lookup helper for widget retrieval.
Behavior
- Returns self.widgetids[id].
Why it matters
- Used by parent/child dependency logic and any external code needing direct
	access to a built widget by id.

detailsFramework:ClearOptionsPanel(frame)
Purpose
- Clears current option panel visibility/state without destroying widget objects.
Behavior
- Hides every widget in frame.widget_list.
- Clears text of labels attached via hasLabel.
- Wipes frame.widgetids mapping.
Why it matters
- Key for volatile menus: old widget instances are recycled but removed from
	the current visible configuration.

detailsFramework:SetAsOptionsPanel(frame)
Purpose
- Initializes a frame with the options-panel mixin data structures.
Behavior
- Assigns frame.RefreshOptions = refreshOptions.
- Initializes:
	- frame.widget_list
	- frame.widget_list_by_type pools (dropdown/switch/slider/color/button/
		textentry/label/image)
	- frame.widgetids
	- frame.widget_to_disable_check
- Assigns frame.GetWidgetById = getFrameById.
Why it matters
- Establishes the panel contract expected by BuildMenu and BuildMenuVolatile,
	including pooling structures used by volatile rebuilds.

=====================================================================
End of Part 3
=====================================================================

=====================================================================
Part 4: volatile menu construction
=====================================================================

Context for this section
- The volatile menu path is designed for dynamic menus that are rebuilt often
	(e.g. search/filter UIs where option rows change frequently).
- Instead of always creating fresh widgets, BuildMenuVolatile reuses pooled
	widgets and reapplies properties each rebuild.

getMenuWidgetVolative(parent, widgetType, indexTable)
Purpose
- Returns a reusable widget instance for the requested widgetType.
- Creates a new widget only when the pool has no available instance at the
	current index.
Behavior
- Uses parent.widget_list_by_type[widgetType][indexTable[widgetType]] as pool
	lookup.
- On cache miss, creates the control and inserts it into both:
	- parent.widget_list (global panel list)
	- parent.widget_list_by_type[widgetType] (type-specific pool)
- Reused control cleanup:
	- Clears hooks for interactive widgets.
	- Clears dropdown label text when reusing dropdown widgets.
- Increments indexTable[widgetType] after each acquisition.
- Removes the widget from widgetsToDisableOnCombat if previously tracked.
- Clears old childrenids and children_follow_enabled state to avoid stale
	dependency behavior from previous builds.
- Returns widgetObject.
Why it matters
- This is the core of volatility: fast rebuilds with reduced allocation and less
	frame churn, while still resetting behavioral state that could leak across
	build passes.

getDescPhraseText(languageTable, widgetTable)
Purpose
- Resolves tooltip/description text for a menu option.
Behavior
- First tries localized values using languageTable:
	- languageTable[widgetTable.descPhraseId]
	- languageTable[widgetTable.desc]
- Fallback order:
	- widgetTable.descPhraseId
	- widgetTable.desc
	- widgetTable.name
	- "-?-"
Why it matters
- Ensures every row can produce a tooltip string even when localization keys are
	missing.

getDescripttionPhraseID(widgetTable, languageAddonId, languageTable)
Purpose
- Returns the description phrase id key used by the non-volatile BuildMenu path
	for language registration.
Behavior
- If widgetTable.descPhraseId exists, returns it immediately.
- If languageTable is missing, returns nil.
- Validates widgetTable.desc against default language phrase ids via
	DetailsFramework.Language.DoesPhraseIDExistsInDefaultLanguage().
- Returns widgetTable.desc when the key exists; otherwise nil.
Why it matters
- Separates phrase-id resolution from direct phrase text resolution. This allows
	non-volatile builds to register objects/tables for automatic language updates.

detailsFramework:BuildMenuVolatile(parent, menuOptions, xOffset, yOffset, height, useColon, textTemplate, dropdownTemplate, switchTemplate, switchIsCheckbox, sliderTemplate, buttonTemplate, valueChangeHook)
Purpose
- Builds or rebuilds an options panel using reusable widgets from internal pools.
- Intended for menus that can change repeatedly at runtime.

High-level flow
1) Panel/bootstrap
- If parent is not an options panel yet, calls detailsFramework:SetAsOptionsPanel(parent).
- Wipes parent.widget_to_disable_check.
- Wraps valueChangeHook with a short debounce timer (0.05s) that calls
	parent:RefreshOptions(), unless menuOptions.no_refresh_on_change is set.
- Calls detailsFramework:ClearOptionsPanel(parent) to hide and reset current
	visible mapping before rebuilding.
- Resets alternating highlight row state (bHighlightColorOne = true).

2) Parse/global setup
- Initializes layout counters and pooling index table (label/dropdown/switch/
	slider/color/button/textentry).
- Normalizes option types via parseOptionsTypes(menuOptions).
- Extracts menu-level settings via parseOptionsTable(menuOptions).
- Resolves effective parent/height via parseParent(...).
- Resolves localization table via parseLanguageTable(languageAddonId).
- Stores parent.build_menu_options = menuOptions.

3) Main build loop
- Iterates menuOptions (loop starts around line 1314 in the source).
- Skips hidden rows (widgetTable.hidden).
- Skips rows marked novolatile (widgetTable.novolatile).
- For each supported type, acquires a pooled widget with getMenuWidgetVolative,
	then calls the corresponding setup path:
	- label/text -> setLabelProperties
	- select* -> setDropdownProperties
	- toggle/switch -> setToggleProperties
	- range -> setRangeProperties
	- color -> setColorProperties
	- execute/button -> setExecuteProperties
	- textentry -> setTextEntryProperties
	- image -> setImageProperties
- Applies per-row tooltip and localized label text helpers where relevant.
- Tracks widgetTable.widget back-reference and collects disableif rows into
	parent.widget_to_disable_check.
- Shows each created/reused widget after setup.

4) Layout controls and special row options
- .inline:
	- Keeps widgets on the same line when true, using latestInlineWidget logic.
- .spacement:
	- Adds extra vertical spacing between rows (larger Y offset decrement).
- type == "blank" / "space":
	- Adds vertical spacing row (no control creation).
- type == "breakline":
	- Starts a new column.
	- In scrollframe mode, tracks widest/highest layout metrics for canvas growth.
	- In fixed mode, wraps to next column when breakline or vertical limit reached.
- .nocombat:
	- Adds built widget into widgetsToDisableOnCombat; later controlled by combat
	state handlers via detailsFramework.RefreshUnsafeOptionsWidgets().

5) Post-build finalize
- If using scrollframe, forwards RefreshOptions call to the scrollframe parent.
- Calls detailsFramework.RefreshUnsafeOptionsWidgets().
- Calls onMenuBuilt(parent) to enforce children dependencies and disableif.
- Calls parent:RefreshOptions() to sync display values with getters.

Why it matters
- BuildMenuVolatile is the dynamic/reusable counterpart to BuildMenu.
- It preserves performance and responsiveness when menus are rebuilt frequently,
	while still supporting localization, dependency rules, disable logic, and
	layout features such as inline rows and multi-column breaklines.

=====================================================================
End of Part 4
=====================================================================

=====================================================================
Part 5: BuildMenu — the permanent menu construction path
=====================================================================

Context for this section
- detailsFramework:BuildMenu() is the "set in stone" counterpart to
	BuildMenuVolatile().
- Every call creates brand new widget instances. There is no widget pool and no
	reuse counter. Once the menu is built the widgets are expected to live for
	the lifetime of the parent frame.
- Because widgets are never recycled, BuildMenu does not call ClearOptionsPanel
	before the loop. It calls SetAsOptionsPanel lazily: if parent.widget_list
	does not yet exist the panel is initialized exactly once.
- The same per-widget setup functions (setLabelProperties, setDropdownProperties,
	setToggleProperties, setRangeProperties, setColorProperties,
	setExecuteProperties, setImageProperties, setTextEntryProperties) and the
	same layout helpers (parseOptionsTypes, parseOptionsTable, parseParent,
	parseLanguageTable) are shared with BuildMenuVolatile.
- Language registration uses getDescripttionPhraseID() — the phrase-id resolver
	that also records the phrase default — rather than getDescPhraseText() which
	is the simpler text-only lookup used in the volatile path.

---------------------------------------------------------------------
detailsFramework:BuildMenu(parent, menuOptions, xOffset, yOffset,
    height, useColon, textTemplate, dropdownTemplate, switchTemplate,
    switchIsCheckbox, sliderTemplate, buttonTemplate, valueChangeHook)
---------------------------------------------------------------------

Source note
- The source file contains two function definitions for
	detailsFramework:BuildMenu at lines 1566 and 1574. The first (lines 1565-1571)
	is a commented-out debug/profiling wrapper that times execution via
	debugprofilestop() and prints elapsed milliseconds. It is wrapped in --[=[...]=]
	and never runs. The second definition (line 1574) is the active implementation
	documented below. The first definition is left in the source as a developer
	convenience — uncomment it and rename the second to :BuildMenu22 to profile
	menu construction time.

Purpose
- Builds a permanent options panel by creating one widget instance per entry in
	menuOptions. The result is not intended to be rebuilt.

Parameters
- parent: the frame that will host the widgets. Receives widget_list and related
	tables via SetAsOptionsPanel if they are not already present.
- menuOptions: the array of widgetTable descriptors. Also carries optional
	top-level configuration keys consumed by parseOptionsTable.
- xOffset, yOffset: starting layout cursor position (defaults to 0, 0).
- height: used as column-break threshold when not using a scroll frame.
- useColon: when true, formatOptionNameWithColon appends ":" to label text.
- textTemplate: default font-size / template applied to all label widgets.
- dropdownTemplate: template forwarded to all dropdown constructors.
- switchTemplate: template forwarded to all switch/toggle constructors.
- switchIsCheckbox: when true, toggles are styled as checkboxes globally.
- sliderTemplate: template forwarded to all slider/range constructors.
- buttonTemplate: template forwarded to all button/execute constructors.
- valueChangeHook: optional caller-supplied callback fired after any widget
	changes its value.

Initialization sequence
- Resets bHighlightColorOne to true so paired-row highlight colors start from
	the first shade.
- Calls parseOptionsTypes(menuOptions) to normalize alias type names in-place.
- Calls parseOptionsTable(menuOptions) to extract layout flags:
	bUseBoxFirstOnAllWidgets, widgetWidth, widgetHeight, bAlignAsPairs,
	nAlignAsPairsLength, nAlignAsPairsSpacing, bUseScrollFrame, languageAddonId,
	bAttachSliderButtonsToLeft.
- Calls parseParent() to optionally substitute a scroll child for parent and
	adjust height.
- Calls parseLanguageTable(languageAddonId) to fetch the active language lookup
	table.
- Stores menuOptions at parent.build_menu_options for later refresh access.
- Calls SetAsOptionsPanel(parent) when parent.widget_list is nil, creating
	widget_list, widget_list_by_type, widgetids, and wiring RefreshOptions.
- Wraps the caller's valueChangeHook in a debounced closure:
	- The wrapper always calls the original hook when present.
	- Skips refresh when menuOptions.no_refresh_on_change is set.
	- Deduplicates rapid successive changes with a 0.1-second C_Timer.
	- On expiry resets the timer reference and calls parent:RefreshOptions().

Main build loop
- Iterates ipairs(menuOptions); skips entries where widgetTable.hidden is true.
- Inline continuation: if latestInlineWidget is set and the current entry does
	not carry .inline, clears latestInlineWidget and subtracts 28 from
	currentYOffset to compensate for the row height consumed by the inline group.

Widget types handled
- blank / space: no widget created; Y cursor advanced by the standard step.
- label / text: creates a label via detailsFramework:CreateLabel. Resolves name
	phrase id; if found, registers the label widget for live language updates via
	DetailsFramework.Language.RegisterObject; otherwise sets text directly from
	get() or widgetTable.text. Stored into widget_list_by_type.label.
- select (all variants): creates the appropriate specialized or generic dropdown.
	Tooltip registered via getDescripttionPhraseID and
	RegisterTableKeyWithDefault. A companion label is created and registered via
	getNamePhraseID and RegisterObjectWithDefault. A language-change callback and
	a deferred 0.1-second timer ensure the dropdown re-selects the correct value
	after localization switches. setDropdownProperties applies layout. Stored
	into widget_list_by_type.dropdown.
- toggle: creates a switch via detailsFramework:NewSwitch. Tooltip and name
	registered the same way as dropdowns. setToggleProperties applies layout.
	Stored into widget_list_by_type.switch.
- range: creates a slider via detailsFramework:NewSlider. Tooltip and name
	registered the same way. setRangeProperties applies layout. Stored into
	widget_list_by_type.slider.
- color: creates a color pick button via detailsFramework:NewColorPickButton.
	Tooltip and name registered. setColorProperties applies layout. Stored into
	widget_list_by_type.color.
- execute / button: creates a button via detailsFramework:NewButton. Name
	registered on the widget itself (not a separate label) via
	RegisterObjectWithDefault. Tooltip registered via getDescripttionPhraseID.
	setExecuteProperties applies layout and inline placement. Stored into
	widget_list_by_type.button.
- textentry: creates a text entry via detailsFramework:CreateTextEntry. Tooltip
	and name registered. alignment stored from widgetTable.align or "left".
	setTextEntryProperties applies layout. Stored into
	widget_list_by_type.textentry.
- image: creates a raw texture on the parent frame. setImageProperties applies
	layout. Y cursor adjusted by widget height. Stored into
	widget_list_by_type.textentry (note: this reuses the textentry bucket; this
	appears to be an intentional shortcut rather than a bug, as images do not
	need their own typed collection).

Per-entry post-processing (same as BuildMenuVolatile)
- nocombat: if widgetTable.nocombat is true, the created widget is appended to
	the module-level widgetsToDisableOnCombat table so that
	RefreshUnsafeOptionsWidgets() can lock/unlock it around combat transitions.
- Y advancement:
	- Inline widgets do not advance the Y cursor.
	- Non-inline widgets with widgetTable.spacement advance by 30; all others
		advance by 20.
- widgetTable.widget is set to the created widget object.
- disableif: if present, the widgetTable is inserted into
	parent.widget_to_disable_check so that checkForDisableIF re-evaluates the
	function on each refresh.
- extraPaddingY: if the setup function (toggle or color in boxfirst mode)
	returned a non-zero extra padding, the Y cursor is decremented further.

Column break and scroll frame behavior
- With bUseScrollFrame:
	- breakline entries advance the X cursor and reset Y to yOffset.
	- biggestColumnHeight tracks the deepest Y point across all columns.
	- After the loop, parent height is set to biggestColumnHeight * -1 (negative
		because WoW Y coordinates grow downward).
	- canvasFrame parent's RefreshOptions is wired to delegate to
		parent:RefreshOptions() so the scroll-frame owner can trigger refreshes.
- Without bUseScrollFrame:
	- A breakline entry or a Y position that falls below height triggers a
		column break: Y resets to yOffset and X advances by maxColumnWidth + 20.

Post-loop sequence
- detailsFramework.RefreshUnsafeOptionsWidgets(): locks any nocombat widgets if
	the player is currently in combat.
- onMenuBuilt(parent): fires per-widget hooks, wires search-bar support, and
	runs a first pass of checkForDisableIF.
- parent:RefreshOptions(): calls all widget .get() functions to populate initial
	displayed values.

Key differences from BuildMenuVolatile
- No widget pooling. Each call allocates new WoW frame objects.
- No ClearOptionsPanel call. Existing widget_list is appended to, not cleared.
	SetAsOptionsPanel is only called if the list is absent entirely.
- Widget names use "$parentWidget" .. index and "$parentLabel" .. index patterns
	tied to the parent frame name, making them stable across UI reloads.
- Uses getDescripttionPhraseID() for tooltip localization instead of
	getDescPhraseText().
- Intended for one-time construction of settings panels that persist for the
	session, such as addon configuration screens.

Why it matters
- BuildMenu is the primary API used by addons to construct persistent options
	panels. Because it does not pool or recycle, widget references stored in
	parent.widgetids remain valid indefinitely and can be accessed anytime via
	parent:GetWidgetById(id). The trade-off against BuildMenuVolatile is memory:
	every call to BuildMenu leaves frames allocated even when the panel is
	hidden, while BuildMenuVolatile amortizes that cost across many rebuilds.

=====================================================================
End of Part 5
=====================================================================

=====================================================================
Part 6: global menuOptions fields — top-level configuration keys
=====================================================================

Context for this section
- Both detailsFramework:BuildMenu() and detailsFramework:BuildMenuVolatile()
	accept a menuOptions table that is an array of widgetTable descriptors.
- In addition to the array entries, menuOptions can carry top-level keys that
	control the behavior of the entire menu. These are not widget descriptors;
	they are panel-wide configuration.
- parseOptionsTable(menuOptions) reads these keys before the widget loop starts
	and distributes the extracted values to every widget setup function.
- parseParent() and the valueChangeHook wrapper also consume one key each.

---------------------------------------------------------------------
always_boxfirst
---------------------------------------------------------------------
Type: boolean (default nil / false)

Purpose
- Forces every toggle and color widget in the menu to use the box-first layout,
	regardless of whether the individual widgetTable sets .boxfirst.

Behavior
- Passed as bUseBoxFirstOnAllWidgets to setToggleProperties and
	setColorProperties.
- In box-first mode the control (the switch or color swatch) is anchored to the
	topleft of the row at currentXOffset/currentYOffset, and the label is
	positioned immediately to the right of the widget using
	label:SetPoint("left", widget, "right", 2, 0).
- In the default (non-box-first) mode the label leads on the left and the widget
	follows to its right.
- For toggles in box-first mode an extra 4 pixels of bottom padding
	(extraPaddingY) is added when the next row is not a blank, breakline, toggle,
	or color row, to separate the stacked controls visually.

Why it matters
- Makes it easy to produce a checkbox-list style panel without having to set
	.boxfirst on every individual entry. Consistent with patterns seen in addon
	configuration panels that list many boolean options in a compact column.

---------------------------------------------------------------------
widget_width
---------------------------------------------------------------------
Type: number (default nil)

Purpose
- Overrides the default width of all interactive widgets in the menu.

Behavior
- Passed as widgetWidth to every widget setup function.
- When non-nil, each setup function calls widget:SetWidth(widgetWidth) after the
	widget is constructed, replacing the widget-type-specific default (typically
	120–160 pixels depending on type).
- Also used as the widget column width in align_as_pairs column break
	calculations: when bUseScrollFrame is true a breakline advances X by
	nAlignAsPairsLength + widgetWidth + nAlignAsPairsSpacing.

Why it matters
- Allows a caller to produce a uniform-width panel without per-entry overrides.
	Particularly useful for dropdown-heavy panels where the default 140-pixel
	width needs to be wider to accommodate longer value strings.

---------------------------------------------------------------------
widget_height
---------------------------------------------------------------------
Type: number (default nil)

Purpose
- Overrides the default height of all interactive widgets in the menu.

Behavior
- Passed as widgetHeight to every widget setup function.
- When non-nil, each setup function calls widget:SetHeight(widgetHeight) after
	construction, replacing per-type defaults (typically 18 pixels).
- Does not affect image rows; those use widgetTable.height exclusively.

Why it matters
- Enables scaled or high-density layouts where a larger tap target or a more
	spacious visual style is preferred globally, without per-entry height fields.

---------------------------------------------------------------------
align_as_pairs
---------------------------------------------------------------------
Type: boolean (default nil / false)

Purpose
- Switches the entire menu to a two-column form layout: labels on the left in a
	fixed-width text column, interactive widgets on the right in a widget column
	aligned to the same X offset on every row.

Behavior
Without align_as_pairs (default):
- Each row is laid out by anchoring the label to the topleft of the parent at
	currentXOffset/currentYOffset, and then anchoring the widget immediately to
	the right of the label:
		label:SetPoint("topleft", parent, "topleft", currentXOffset, currentYOffset)
		widget:SetPoint("left", label, "right", 2, 0)
- The widget column therefore shifts left or right depending on how wide each
	label string happens to be. Rows with short labels have their widgets closer
	to the left; rows with long labels push their widgets further right.

With align_as_pairs = true:
- Every row uses a fixed horizontal split. The label is always anchored to
	currentXOffset on the parent:
		PixelUtil.SetPoint(label, "topleft", parent, "topleft", currentXOffset, currentYOffset)
- The widget is then placed at a fixed offset of nAlignAsPairsLength pixels from
	the label's own left edge (not its right edge):
		PixelUtil.SetPoint(widget.widget, "left", label, "left", nAlignAsPairsLength, 0)
- Because both points are measured from the same left anchor, all widget inputs
	line up at the same X coordinate regardless of label text length. This
	produces the visual appearance of a classic settings form: a left column of
	option names and a right column of controls.
- A createOptionHighlightFrame is created (once, then cached in
	widget.highlightFrame) for every row in paired mode. The highlight frame
	spans the full row width: nAlignAsPairsLength + widgetWidth + 5 pixels. It
	provides the row hover highlight and, for toggle rows, makes the entire row
	clickable to toggle the value.
- For toggle rows in paired mode the widget is anchored to the right edge of the
	highlight frame instead of the left edge of the label, so the checkbox/switch
	sits flush against the right margin of the row:
		PixelUtil.SetPoint(widget.widget, "right", widget.highlightFrame, "right", -3, 0)
- For range/slider rows in paired mode bAttachButtonsToLeft is always forced to
	true, keeping the +/- adjustment buttons from overlapping the right-aligned
	widget column.

Why it matters
- align_as_pairs is the primary layout mode for serious options panels. It allows
  a panel with mixed widget types (dropdowns, sliders, toggles, color pickers)
  to look uniform and readable because every input control starts at the same
  horizontal pixel. Without it, varying label lengths produce a ragged right
  boundary that looks inconsistent. The hover highlight and full-row click
  behavior that comes with this mode also improves usability, especially for
  dense configuration screens.

⚠️ CRITICAL REQUIREMENT: align_as_pairs REQUIRES canvasFrame
---------------------------------------------------------------------
When using `align_as_pairs = true`, you MUST pass a canvasFrame to BuildMenu
instead of a regular frame. A canvasFrame is created using the
`detailsFramework:CreateCanvasScrollBox()` function.

Why this requirement exists:
- The align_as_pairs layout mode creates highlight frames and performs anchoring
  operations that require the special properties of a canvas scroll child.
- Using a regular frame with align_as_pairs will result in incorrect widget
  positioning, missing hover highlights, or complete layout failures.
- This is NOT optional — it is a hard requirement for proper functionality.

❌ INCORRECT usage (will not work properly):
```lua
-- Creating a regular frame
local optionsFrame = CreateFrame("frame", nil, parent)
optionsFrame:SetPoint("topleft", parent, "topleft", 0, 0)
optionsFrame:SetPoint("bottomright", parent, "bottomright", 0, 0)

local menuOptions = {
    align_as_pairs = true,  -- This will NOT work correctly!
    {type = "toggle", name = "Option 1", get = GetOpt1, set = SetOpt1},
}

DF:BuildMenu(optionsFrame, menuOptions)  -- WRONG! Using regular frame
```

✅ CORRECT usage (required for align_as_pairs):
```lua
-- Create a canvas scroll frame using CreateCanvasScrollBox
local canvasFrame = detailsFramework:CreateCanvasScrollBox(optionsPanel, nil, "MyCanvasFrame")
canvasFrame:SetPoint("topleft", optionsPanel, "topleft", 0, -2)
canvasFrame:SetPoint("bottomright", optionsPanel, "bottomright", -26, 25)

-- Store reference if needed for later access
optionsPanel.canvasFrame = canvasFrame

local menuOptions = {
    align_as_pairs = true,  -- This WILL work correctly!
    {type = "toggle", name = "Option 1", get = GetOpt1, set = SetOpt1},
    {type = "range", name = "Option 2", get = GetOpt2, set = SetOpt2, min = 0, max = 100},
}

-- Pass the canvasFrame (not the regular frame) to BuildMenu
DF:BuildMenu(canvasFrame, menuOptions)
```

Complete working example:
```lua
local parent = SomeExistingFrame
local optionsPanel = CreateFrame("frame", "MyOptionsPanel", parent, "BackdropTemplate")
optionsPanel:SetSize(500, 400)
optionsPanel:SetPoint("center", parent, "center")

-- Step 1: Create canvas scroll box
local canvasFrame = detailsFramework:CreateCanvasScrollBox(optionsPanel, nil, "OptionsCanvas")
canvasFrame:SetPoint("topleft", optionsPanel, "topleft", 0, -2)
canvasFrame:SetPoint("bottomright", optionsPanel, "bottomright", -26, 25)

-- Step 2: Define menu options with align_as_pairs
local menuOptions = {
    align_as_pairs = true,
    align_as_pairs_string_space = 180,  -- Optional: customize label column width
    
    {type = "label", get = function() return "Settings:" end,
     text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
    
    {type = "toggle", name = "Enable Feature",
     get = function() return MyDB.enabled end,
     set = function(_, _, v) MyDB.enabled = v end},
    
    {type = "range", name = "Slider Value",
     get = function() return MyDB.sliderValue end,
     set = function(_, _, v) MyDB.sliderValue = v end,
     min = 0, max = 100, step = 1},
    
    {type = "select", name = "Dropdown Option",
     get = function() return MyDB.dropdownValue end,
     values = function()
         return {
             {value = 1, label = "Option A"},
             {value = 2, label = "Option B"},
             {value = 3, label = "Option C"},
         }
     end},
}

-- Step 3: Build menu using canvasFrame (NOT optionsPanel)
DF:BuildMenu(canvasFrame, menuOptions, 10, -10, nil, false,
    DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"),
    DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"),
    DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE"),
    true,
    DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE"))
```

Key points to remember:
1. Always use `CreateCanvasScrollBox()` when you need `align_as_pairs = true`
2. Pass the returned canvasFrame to BuildMenu, not the parent frame
3. The canvasFrame handles scrolling automatically for content that exceeds bounds
4. Without this requirement met, widgets may appear misaligned or highlights may fail

---------------------------------------------------------------------
align_as_pairs_string_space
---------------------------------------------------------------------
Type: number (default 160)

Purpose
- Controls the pixel width reserved for the label (text) column when
	align_as_pairs is active.

Behavior
- Stored as nAlignAsPairsLength and passed to every widget setup function.
- Used as the horizontal offset from label.left to widget.left (see
	align_as_pairs above).
- Also used as the first term of the column-break X advance formula when
	use_scrollframe is true:
		currentXOffset = currentXOffset + nAlignAsPairsLength + widgetWidth + nAlignAsPairsSpacing
- Also used as the assumed label-column contribution to the highlight frame
	width: nAlignAsPairsLength + widgetWidth + 5.

Why it matters
- Increasing this value gives more horizontal space to label text, preventing
	truncation for panels with long option names. Decreasing it produces a
	tighter left column that leaves more room for the widget column on narrower
	parent frames.

---------------------------------------------------------------------
align_as_pairs_spacing
---------------------------------------------------------------------
Type: number (default 20)

Purpose
- Sets the gap between columns when use_scrollframe multi-column layout is
	combined with align_as_pairs.

Behavior
- Stored as nAlignAsPairsSpacing.
- Only used in the column-break X advance calculation when bUseScrollFrame is
	true and a breakline entry is encountered:
		currentXOffset = currentXOffset + nAlignAsPairsLength + widgetWidth + nAlignAsPairsSpacing
- Has no effect when use_scrollframe is false; in that case column breaks always
	add a fixed 20-pixel gap regardless of this setting.

Why it matters
- Allows callers to control the visual breathing room between columns in
	multi-column scrollable panels without changing the label or widget widths.

---------------------------------------------------------------------
slider_buttons_to_left
---------------------------------------------------------------------
Type: boolean (default nil / false)

Purpose
- Moves the increment/decrement buttons on slider (range) widgets from the
	default right side to the left side.

Behavior
- Stored as bAttachSliderButtonsToLeft and written into every slider widget as
	widget.bAttachButtonsToLeft before the slider renders.
- When a range widget is in align_as_pairs mode this flag is always forced to
	true regardless of this menu-level setting, because the paired right column
	leaves no room to the right of the slider for extra buttons.

Why it matters
- Some panel layouts have very little horizontal space to the right of the
	slider track. Placing the buttons on the left keeps the panel tidy and avoids
	controls overflowing the parent frame or overlapping adjacent widgets.

---------------------------------------------------------------------
use_scrollframe
---------------------------------------------------------------------
Type: boolean (default nil / false)

Purpose
- Redirects the parent frame to the scroll child of a scroll widget and enables
	automatic height resizing and multi-column scroll layout.

Behavior
- Read by parseParent(). When true:
	- The scroll child of the passed parent frame is extracted via
		parent:GetScrollChild().
	- The scroll child is resized to match the scroll frame's current width and
		height, becoming the new parent for all widget creation.
	- The original frame (canvasFrame) is kept for post-loop scroll plumbing.
- During the widget loop the full column-break behavior changes:
	- breakline entries always break and track biggestColumnHeight across columns.
	- At loop end parent:SetHeight(biggestColumnHeight * -1) resizes the scroll
		child to exactly fit its contents.
	- canvasFrame:GetParent().RefreshOptions is wired to delegate to the scroll
		child's RefreshOptions so the scroll frame owner can trigger refreshes.
- In BuildMenuVolatile, bUseScrollFrame only redirects parent; the per-volatile-
	rebuild ClearOptionsPanel and widget pooling still operate on the scroll child
	as normal.

Why it matters
- Enables options panels that are taller than the visible area. The scroll frame
	clips and scrolls the child, which acts as the true canvas for all widgets.
	Without this flag the caller would have to manually manage the scroll child
	relationship and column sizing.

---------------------------------------------------------------------
language_addonId
---------------------------------------------------------------------
Type: string (default nil)

Purpose
- Activates the DetailsFramework localization system for all text and tooltip
	content in the menu.

Behavior
- Passed to parseLanguageTable(languageAddonId), which calls
	DetailsFramework.Language.GetLanguageTable(languageAddonId) to retrieve the
	active locale string table for that addon.
- When non-nil, every widget name and tooltip lookup goes through the language
	table first (see getNamePhraseID, getNamePhraseText, getDescPhraseText,
	getDescripttionPhraseID).
- In BuildMenu, language registration calls (RegisterObject,
	RegisterObjectWithDefault, RegisterTableKeyWithDefault) are only made when
	languageAddonId is non-nil, and a language-change callback is registered on
	dropdowns to re-select their current value after the locale switches.
- When nil the menu falls back to plain widgetTable.name / widgetTable.desc
	strings with no live language update capability.

Why it matters
- This is the entry point for multi-language support in any options panel.
	Setting this to the addon's registered language ID is sufficient to make all
	option labels and tooltips respond to locale changes at runtime without
	rebuilding the menu.

---------------------------------------------------------------------
no_refresh_on_change (supplementary field, consumed by valueChangeHook wrapper)
---------------------------------------------------------------------
Type: boolean (default nil / false)

Purpose
- Suppresses the automatic panel refresh that would otherwise fire 0.1 seconds
	after any widget value changes.

Behavior
- Checked inside the debounced valueChangeHook closure created by both
	BuildMenu and BuildMenuVolatile.
- When true the closure returns immediately after calling the caller's original
	hook, skipping the C_Timer and the subsequent parent:RefreshOptions() call.
- The caller's own valueChangeHook (if any) still fires unconditionally.

Why it matters
- Useful for menus whose widgets have independent effects and do not need to
	cross-update each other. Disabling the auto-refresh eliminates the 0.1-second
	timer overhead and prevents unintended side effects when one widget changing
	its value would incorrectly reset another widget's displayed state.

=====================================================================
End of Part 6
=====================================================================

=====================================================================
Part 7: combat protection — locking unsafe widgets during combat
=====================================================================

Context for this section
- World of Warcraft's protected action system (InCombatLockdown) prevents addons
	from changing certain frame properties while the player is in active combat.
	Secure frames such as action buttons, pet bars, and vehicle controls are under
	this restriction.
- The menu builder extends this concept to any widget that an addon author marks
	as .nocombat = true in its widgetTable. These are typically widgets whose
	callbacks would manipulate protected frames or trigger protected API calls
	that are forbidden in combat.
- The combat protection system in buildmenu.lua is self-contained: it maintains a
	module-level list of all registered nocombat widgets, listens to the game's
	combat state events, and exposes a public refresh function so that callers can
	also trigger it manually.

---------------------------------------------------------------------
widgetsToDisableOnCombat (module-level table)
---------------------------------------------------------------------
Purpose
- Accumulates every widget created with widgetTable.nocombat = true across all
	calls to BuildMenu and BuildMenuVolatile.

Behavior
- Declared as a local table at module scope, shared across all menu builds in
	the same Lua file load.
- Each time BuildMenu or BuildMenuVolatile encounters a widgetTable.nocombat
	entry it appends the created widget to this table via
	table.insert(widgetsToDisableOnCombat, widgetCreated).
- The table is never cleared between builds; widgets accumulate over the addon
	session.

Why it matters
- Centralizing all nocombat widgets into a single flat list makes the lock and
	unlock passes O(n) simple iterations with no per-panel bookkeeping.

---------------------------------------------------------------------
lockNotSafeWidgetsForCombat()
---------------------------------------------------------------------
Purpose
- Disables every widget in widgetsToDisableOnCombat so the player cannot
	interact with them while in combat.

Behavior
- Iterates ipairs(widgetsToDisableOnCombat).
- Calls widget:Disable() on each widget.
- No return value; purely a side-effect loop.

Why it matters
- Prevents users from triggering callbacks that would call protected API (e.g.
	moving frames, changing action bar bindings) while the combat lockdown is
	active, avoiding Lua errors and taint.

---------------------------------------------------------------------
unlockNotSafeWidgetsForCombat()
---------------------------------------------------------------------
Purpose
- Re-enables every widget in widgetsToDisableOnCombat after combat ends.

Behavior
- Iterates ipairs(widgetsToDisableOnCombat).
- Calls widget:Enable() on each widget.
- No return value.

Why it matters
- Restores full interaction to all nocombat widgets as soon as it is safe to do
	so, without requiring the user to rebuild or refresh the panel manually.

---------------------------------------------------------------------
detailsFramework.RefreshUnsafeOptionsWidgets()
---------------------------------------------------------------------
Purpose
- Public entry point that applies the correct lock or unlock state based on the
	current combat flag.

Behavior
- Reads detailsFramework.PlayerHasCombatFlag.
- If true, calls lockNotSafeWidgetsForCombat().
- If false, calls unlockNotSafeWidgetsForCombat().
- Called at the end of both BuildMenu and BuildMenuVolatile immediately after the
	widget loop, ensuring newly created nocombat widgets are in the correct state
	from the moment the panel is built.

Why it matters
- Decouples the lock/unlock decision from the event handler. Any code path that
	needs to force a sync (e.g., after adding new widgets dynamically) can call
	this function directly without needing to know whether the player is in combat.

---------------------------------------------------------------------
ProtectCombatFrame (module-level event listener)
---------------------------------------------------------------------
Purpose
- Tracks the player's combat state and keeps detailsFramework.PlayerHasCombatFlag
	up to date, then immediately applies the corresponding widget lock state.

Behavior
- An invisible WoW frame created with CreateFrame("frame") at module load time.
- Registers for three events:
	- PLAYER_REGEN_ENABLED: fired when the player leaves combat. Sets
		PlayerHasCombatFlag = false and calls RefreshUnsafeOptionsWidgets().
	- PLAYER_REGEN_DISABLED: fired when the player enters combat. Sets
		PlayerHasCombatFlag = true and calls RefreshUnsafeOptionsWidgets().
	- PLAYER_ENTERING_WORLD: fired on login, reload, and zone transitions. Checks
		InCombatLockdown() to determine the correct initial flag value (the player
		may have reloaded the UI while already in combat) and calls
		RefreshUnsafeOptionsWidgets() to synchronize widget states immediately.
- detailsFramework.PlayerHasCombatFlag is initialized to false at module load
	and then corrected by the PLAYER_ENTERING_WORLD handler before any user
	interaction is possible.

Why it matters
- Using PLAYER_ENTERING_WORLD as an initialization event is essential: a plain
	false default would leave nocombat widgets enabled if the player reloads the
	UI mid-combat. The three-event pattern covers every transition reliably.

---------------------------------------------------------------------
detailsFramework:CreateInCombatTexture(frame)
---------------------------------------------------------------------
Purpose
- Attaches a self-managing visual combat overlay to any arbitrary frame, so the
	frame can communicate its restricted state to the user without being connected
	to the menu builder's widget list.

Parameters
- frame: the WoW frame that should display the combat overlay. In debug mode, an
	absent frame is a hard error.

Behavior
- Creates a semi-transparent red color texture (rgba 0.6, 0, 0, 0.1) covering
	the frame via detailsFramework:CreateImage. Hidden initially.
- Creates a "you are in combat" label at font size 24 in silver, anchored to the
	right edge of the texture with a 10-pixel inset. Hidden initially.
- Registers the passed frame for PLAYER_REGEN_DISABLED and PLAYER_REGEN_ENABLED
	events and installs an OnEvent script directly on the frame:
	- PLAYER_REGEN_DISABLED: shows both the texture and the label.
	- PLAYER_REGEN_ENABLED: hides both.
- Returns inCombatBackgroundTexture so the caller can further position or size
	the overlay.

Why it matters
- Provides a drop-in combat feedback affordance for frames that are not built
	through BuildMenu (e.g. custom drag handles, preview frames, or any panel that
	wants to signal unavailability during combat). Because the overlay registers
	its own events on the target frame, it requires no external wiring and is
	fully self-contained after the call returns.

=====================================================================
End of Part 7
=====================================================================

=====================================================================
Part 8: widgetTable field reference (consolidated lookup)
=====================================================================

Context for this section
- The fields used by BuildMenu / BuildMenuVolatile are spread across many
	setup helpers (setToggleProperties, setRangeProperties, setTextEntryProperties,
	etc).
- This section consolidates those fields into a practical lookup by scope and
	widget type.
- Scope rule:
	- menuOptions.<field> = panel-level setting (Part 6).
	- menuOptions[index].<field> = per-widget setting (this Part 8).

---------------------------------------------------------------------
A) Common per-widget fields (valid for most widget types)
---------------------------------------------------------------------

Field: type
- Required for all rows.
- Canonical values after parseOptionsTypes(): label, select, toggle, range,
	color, execute, textentry, image, blank, breakline.
- Aliases normalized automatically: space->blank, dropdown->select,
	switch->toggle, slider->range, button->execute, etc.

Field: name
- Primary user-visible label source for most interactive widgets.
- Also primary search text in most search-panel implementations.

Field: desc
- Tooltip fallback text when no descPhraseId localization key is resolved.

Field: id
- Optional.
- Registers widget in parent.widgetids[id] for GetWidgetById(id).
- Not required unless you want to fetch widgets through GetWidgetById().

Field: hidden
- If true, row is skipped during build loop (no widget created).

Field: inline
- Places the current row on the same line as previous inline-capable row
	(mainly execute/textentry behavior).

Field: spacement
- Adds extra vertical spacing below the row when not inline.

Field: nocombat
- Adds created widget to widgetsToDisableOnCombat list.

Field: disabled
- Initial disabled state applied by onWidgetSetInUse().

Field: disableif
- Function re-evaluated during refresh. True => Disable(), false/nil => Enable().

Optionality note for the commonly used behavior fields
- All of the following are optional keys (none is required for widget creation):
	id, hidden, inline, spacement, nocombat, disabled, disableif,
	childrenids, children_follow_enabled, children_follow_reverse,
	hooks, texture, namePhraseId, descPhraseId, tags, novolatile.
- If you wrote "disableid", this codebase uses disableif.

Field: childrenids
- List of widget ids controlled by parent-child toggle behavior.

Field: children_follow_enabled
- Enables parent-driven child activation logic (used by toggles).

Field: children_follow_reverse
- Inverts children_follow_enabled behavior for child activation.

Field: hooks
- Table of hookName->hookFunc pairs attached in setup function.
- Hook names must exist in the widget's HookList (or be consumed by its script
	hook mixin behavior).

Supported hook names by BuildMenu widget type
- execute (NewButton):
	OnEnter, OnLeave, OnHide, OnShow, OnMouseDown, OnMouseUp.
	Source: buttonObject.HookList in Libs/DF/button.lua.
- toggle (NewSwitch):
	OnEnter, OnLeave, OnHide, OnShow, OnMouseDown, OnMouseUp, OnSwitch.
	Source: slider.HookList.OnSwitch in Libs/DF/slider.lua + NewButton base hooks.
- color (NewColorPickButton):
	OnEnter, OnLeave, OnHide, OnShow, OnMouseDown, OnMouseUp, OnColorChanged.
	Source: colorPickButton.HookList.OnColorChanged in Libs/DF/button.lua +
	NewButton base hooks.
- select/dropdown (NewDropDown):
	OnEnter, OnLeave, OnHide, OnShow, OnOptionSelected.
	Source: dropDownObject.HookList in Libs/DF/dropdown.lua.
- range/slider (NewSlider):
	OnEnter, OnLeave, OnHide, OnShow, OnMouseDown, OnMouseUp,
	OnValueChange, OnValueChanged.
	Source: SliderObject.HookList in Libs/DF/slider.lua.
- textentry (CreateTextEntry/NewTextEntry):
	OnEnter, OnLeave, OnHide, OnShow, OnEnterPressed, OnEscapePressed,
	OnSpacePressed, OnEditFocusLost, OnEditFocusGained, OnChar,
	OnTextChanged, OnTabPressed.
	Source: newTextEntryObject.HookList in Libs/DF/textentry.lua.
- label:
	labelObject.HookList is initialized as an empty table in Libs/DF/label.lua.
	Also note: BuildMenu setLabelProperties currently does not consume
	widgetTable.hooks for label rows.

Field: texture
- For toggle rows: optional icon texture near label (processTexture()).

Field: namePhraseId
- Explicit localization phrase id for row name.

Field: descPhraseId
- Explicit localization phrase id for tooltip/description.

Field: tags
- Optional search metadata table (string list) for custom search indexing.
- Not consumed by BuildMenu internals directly; intended for external search
	algorithms.

---------------------------------------------------------------------
B) Volatile-only helper field
---------------------------------------------------------------------

Field: novolatile
- Used only by BuildMenuVolatile.
- If true, entry is skipped in volatile builds (no pooled widget acquired).

---------------------------------------------------------------------
C) Styling / template fields
---------------------------------------------------------------------

Field: template
- Per-widget template override used in some constructors (notably textentry).

Field: text_template
- Font/text style override for label text attached to the widget.
- Table format (same as DF.font_templates entries):
	{
		color = {r, g, b, a},  -- or a named color string like "orange", "yellow"
		size = number,         -- font size in points (e.g. 9.6, 11)
		font = string,         -- font file path or SharedMedia font name
	}
- Built-in templates accessible via DF:GetTemplate("font", name):
	- "OPTIONS_FONT_TEMPLATE": {color = {1, 1, 1, 0.9}, size = 9.6} — standard option label
	- "ORANGE_FONT_TEMPLATE": {color = {1, 0.8235, 0, 1}, size = 11} — section headers
	  (recommended for section header labels; see Part 7 section G for best practices)
	- "SMALL_SILVER": {color = "silver", size = 9} — de-emphasized text
- When text_template is set on a widgetTable, it overrides the textTemplate
	argument passed to BuildMenu for that widget's label only.
- The fallback chain is: widgetTable.text_template → BuildMenu's textTemplate
	argument → DF.font_templates["ORANGE_FONT_TEMPLATE"].
- See Part 8, section G "Section header best practices" for recommended patterns
	when organizing options into visually distinct groups.

Field: button_template
- Alternate template path used by some widgets (notably textentry fallback).

Field: width
- Per-widget width override (when setup path honors widgetTable.width).

Field: height
- Per-widget height override (or image row explicit height).

Field: icontexture
- Texture path or FileID for an icon prepended to the widget's label text.
- Used by processLabelIcon() (label icons on all widget types) and by
	setExecuteProperties() (button icons via SetIcon).
- When set on a label-bearing widget, the icon appears before the label text
	at the font height of the label.

Field: icontexcoords
- Table {left, right, top, bottom} UV coords for icontexture on execute
	widgets. Passed to SetIcon() in setExecuteProperties().
- Not used by processLabelIcon() — use iconcoords for label icons.

Field: iconcoords
- Table {left, right, top, bottom} UV coords for icontexture on label icons.
- Used by processLabelIcon(). Defaults to {.1, .9, .1, .9} when absent.
- Distinct from icontexcoords: iconcoords controls the label-prepended icon,
	icontexcoords controls the execute/button icon.

Field: iconsize
- Table {width, height} pixel dimensions for the label-prepended icon.
- Used by processLabelIcon(). Defaults to {fontHeight, fontHeight} — the
	icon matches the label font size when not specified.

Field: iconfilesize
- Table {width, height} pixel dimensions of the source texture file for the
	label-prepended icon.
- Used by processLabelIcon() to calculate correct tex coords when the source
	file is not the default 64x64. Defaults to {64, 64}.

---------------------------------------------------------------------
D) Widget-type reference
---------------------------------------------------------------------

1) label (and text alias)
- Typical fields: type, get, text, text_template, color, font, size,
	namePhraseId, id, hidden, disabled.
- Notes:
	- get() may return dynamic string each refresh. Using get() with a function
	  enables localization updates without rebuilding the menu.
	- text is fallback when get is absent.
	- For section header labels, always use get() with text_template set to
	  DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"). See Part 8, section G
	  "Section header best practices" for the complete recommended pattern.

2) select (and specialized select* types)
- Typical fields: type, get, set, values, name, desc, namePhraseId,
	descPhraseId, include_default, hooks, width, height, text_template,
	id, hidden, disabled, disableif.
- Notes:
	- values is the options-provider for the dropdown.
	- In BuildMenu usage, values should be a function that returns a table of
	  option entries each time the dropdown needs to populate.
	- Canonical pattern used in Details options:
		values = function()
			return buildAbbreviationMenu()
		end
	  where buildAbbreviationMenu() returns the actual options table.
	- Specialized types include selectfont, selectstatusbartexture,
	  selectcolor, selectoutline, selectanchor, selectaudio,
	  selectframestrata, selectbackgroundtexture, selectbordertexture.

Select values table format (dropdown option entries)
- values() must return an array-like table where each element is one option.
- Common option keys:
	- value: internal value selected when this row is clicked.
	- label: text shown in the dropdown row.
	- onclick: callback function(dropdownObject, fixedValue, value).
	- desc: optional description/tooltip text for the option row.
- Frequently used optional visual keys:
	- icon, iconcolor, iconsize, texcoord.
	- color, font, descfont.
- Advanced optional keys (supported by dropdown system):
	- rightbutton, rightbuttonicon, statusbar, statusbarcolor,
	  rightTexture, centerTexture, selected.

Minimal example:

	local onSelectTimeAbbreviation = function(_, _, abbreviationType)
		Details.tooltip.abbreviation = abbreviationType
		afterUpdate()
	end

	local abbreviationOptions = {
		{value = 1, label = "None", onclick = onSelectTimeAbbreviation, desc = "305500"},
		{value = 2, label = "305.5K", onclick = onSelectTimeAbbreviation, desc = "305.500 -> 305.5K"},
	}

	local buildAbbreviationMenu = function()
		return abbreviationOptions
	end

	local widgetTable = {
		type = "select",
		get = function() return Details.tooltip.abbreviation end,
		values = function() return buildAbbreviationMenu() end,
		name = "Number Format",
		desc = "Choose abbreviation style",
	}

3) toggle
- Typical fields: type, get, set, name, desc, boxfirst, hooks,
	childrenids, children_follow_enabled, children_follow_reverse,
	texture, texture_width, texture_height, id, hidden, disabled,
	disableif, nocombat, text_template.
- Notes:
	- boxfirst can be overridden globally by menuOptions.always_boxfirst.
	- In align_as_pairs mode, row highlight frame can make whole row clickable.

4) range
- Typical fields: type, get, set, min, max, step, usedecimals,
	thumbscale, name, desc, hooks, id, hidden, disabled, disableif,
	nocombat, text_template, width, height.
- Notes:
	- usedecimals=true enables fractional behavior.
	- step is still used for slider construction; runtime SetValueStep differs
	  between decimal and integer setup paths.

5) color
- Typical fields: type, get, set, name, desc, boxfirst, hooks,
	id, hidden, disabled, disableif, nocombat, text_template.
- Notes:
	- get supports packed table or r,g,b,a parseable return.
	- set receives color components from color picker callbacks.

6) execute (button)
- Typical fields: type, func, param1, param2, name, desc,
	icontexture, icontexcoords, hooks, inline, id, hidden, disabled,
	disableif, nocombat, text_template, width, height.
- Notes:
	- func(param1, param2) is bound through SetClickFunction().
	- inline is most commonly used with execute rows.

7) textentry
- Typical fields: type, get, set or func, name, desc, align,
	hooks, inline, nocombat, id, hidden, disabled, disableif,
	template, button_template, text_template, width, height.
- Notes:
	- Commit path uses func first, then set as fallback.
	- OnEnterPressed and OnEditFocusLost both trigger commit.

8) image
- Typical fields: type, texture, width, height, filterType,
	texcoord, vertexcolor, id, hidden.
- Notes:
	- texture can be path/id or color table.
	- texcoord defaults to {0,1,0,1} when absent.

9) blank / space / breakline (layout rows)
- blank (or space alias): vertical spacer row, no widget construction.
  Recommended use: adding visual breathing room between sections.
- breakline: forces next column / wrap behavior depending on scrollframe mode.
  Recommended use: separating logical option sections with column breaks or
  layout wrapping. See Part 8, section G for the recommended section header pattern.
- Notes:
	- breakline is particularly useful before section headers (labels with
	  ORANGE_FONT_TEMPLATE) to provide clear visual separation.
	- In single-column layouts without use_scrollframe, use blank instead of
	  breakline for simpler spacing between sections.

10) group
- Typical fields: type, name, color, UseBackdrop, BackgroundColor,
	BackdropBorderColor, width, height, padding, id.
- Notes:
	- The group entry does not create a visible widget row; it reserves a
		background frame that is positioned after the build loop by
		applyGroupFrames().
	- Other widget entries reference the group via group = "groupName".
	- Any widget type (label, toggle, range, select, color, execute, textentry)
		can be a group member.
	- color sets the plain background color when UseBackdrop is nil.
	- UseBackdrop is a Blizzard backdrop table (e.g. with edgeFile, bgFile,
		edgeSize, insets); when set, the frame uses SetBackdrop instead of the
		plain color texture.
	- BackgroundColor and BackdropBorderColor are only used when UseBackdrop is
		set.
	- width and height override the auto-computed dimensions if provided.
		The top-left anchor position is still computed automatically.
	- padding adds extra pixels between the group border and the member widgets.

---------------------------------------------------------------------
E) Search-oriented best practices for widget fields
---------------------------------------------------------------------

- Always set name to a clear user-facing phrase.
- Use tags for synonyms and domain terms not present in name.
	Example: tags = {"color", "background", "alpha", "rgb"}
- Keep desc concise; it can be included in search text when needed.
- Ensure id is stable for rows participating in child dependency chains.

---------------------------------------------------------------------
F) Quick examples
---------------------------------------------------------------------

Toggle with dependencies and search tags:

	{
		type = "toggle",
		id = "enableBackdrop",
		name = "Enable Backdrop",
		desc = "Show or hide panel backdrop.",
		tags = {"background", "panel", "style"},
		get = function() return MyDB.enableBackdrop end,
		set = function(_, _, v) MyDB.enableBackdrop = v end,
		childrenids = {"backdropColor", "backdropAlpha"},
		children_follow_enabled = true,
		boxfirst = true,
	}

Range with decimals:

	{
		type = "range",
		id = "backdropAlpha",
		name = "Backdrop Alpha",
		desc = "Opacity of the panel background.",
		tags = {"alpha", "opacity", "transparency"},
		min = 0,
		max = 1,
		step = 0.05,
		usedecimals = true,
		get = function() return MyDB.backdropAlpha end,
		set = function(_, _, v) MyDB.backdropAlpha = v end,
	}

Image row:

	{
		type = "image",
		texture = "Interface\\AddOns\\MyAddon\\media\\banner",
		width = 256,
		height = 64,
		texcoord = {0, 1, 0, 1},
		vertexcolor = {1, 1, 1, 0.9},
	}

Breakline row (column break marker inside menuOptions):

	local sectionOptions = {
		{type = "label", name = "General"},
		{type = "toggle", name = "Option A", get = GetA, set = SetA},
		{type = "range",  name = "Option B", get = GetB, set = SetB, min = 1, max = 10, step = 1},

		{type = "breakline"}, -- next rows start in the next column

		{type = "label", name = "Advanced"},
		{type = "toggle", name = "Option C", get = GetC, set = SetC},
	}

	-- with use_scrollframe = true, breakline always starts a new column.
	-- without use_scrollframe, breakline also forces wrapping even if current
	-- column still has vertical space.

Group with plain background color:

	local menuOptions = {
		-- define the group (this does not create a visible row)
		{type = "group", name = "displayGroup", color = {0, 0, 0, 0.4}},
		-- label header inside the group
		{type = "label", get = function() return "Display Settings" end, text_template = subSectionTitleTextTemplate, group = "displayGroup"},
		-- widgets referencing the group
		{type = "toggle", name = "Show Bars", get = GetA, set = SetA, group = "displayGroup"},
		{type = "range", name = "Scale", get = GetB, set = SetB, min = 0.5, max = 2, step = 0.1, usedecimals = true, group = "displayGroup"},
	}

Group with BackdropTemplate border:

	local menuOptions = {
		{type = "group", name = "advancedGroup",
			UseBackdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}},
			BackgroundColor = {0, 0, 0, 0.8},
			BackdropBorderColor = {1, 1, 1, 0.6},
		},
		{type = "toggle", name = "Debug Mode", get = GetC, set = SetC, group = "advancedGroup"},
		{type = "toggle", name = "Verbose Logging", get = GetD, set = SetD, group = "advancedGroup"},
	}

Group with fixed width and height:

	{type = "group", name = "fixedGroup", color = {0.1, 0.1, 0.1, 0.5}, width = 300, height = 120}

---------------------------------------------------------------------
G) Section header best practices
---------------------------------------------------------------------

Context
- Options panels often group related settings into logical sections.
- A section typically starts with a visual label (header) that describes the
	section's purpose, followed by related widget rows.
- Between sections, a blank/breakline row provides visual separation.

Recommended section pattern
- Each section should follow this structure:

	{type = "breakline"},  -- separator between sections (or blank at start)
	{type = "label", get = function() return "Section Name:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
	-- section widgets follow below
	{type = "toggle", name = "Option 1", get = GetOpt1, set = SetOpt1, text_template = options_text_template},
	{type = "range",  name = "Option 2", get = GetOpt2, set = SetOpt2, min = 1, max = 10, step = 1, text_template = options_text_template},
	{type = "color",  name = "Option 3", get = GetOpt3, set = SetOpt3, text_template = options_text_template},

Section header guidelines

1) Always use get() function for dynamic localization support
   - Instead of: {type = "label", name = "Frame Settings:"}
   - Recommended: {type = "label", get = function() return "Frame Settings:" end}
   - This allows the text to update when the UI language changes without
     rebuilding the menu.

2) Always use ORANGE_FONT_TEMPLATE for visual distinction
   - text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")
   - This distinguishes section headers from regular option labels through
     color (orange) and size (11pt).
   - Alternatives include SMALL_SILVER for secondary sections or
     OPTIONS_FONT_TEMPLATE for subtle headers.

3) Use breakline before each section (except the first row)
   - {type = "breakline"} provides column/layout separation.
   - Alternatively, {type = "blank"} adds vertical spacing without layout
     side-effects (useful in single-column layouts).
   - Omit the separator before the very first section header.

4) Omit name field from section header label
   - The get() function supplies all needed text.
   - Setting both name and get() may cause unexpected behavior with
     localization systems.

Full panel example with multiple sections

	local DF = DetailsFramework
	local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")

	local menuOptions = {
		-- Frame Settings section
		{type = "label", get = function() return "Frame Settings:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
		{type = "toggle", name = "Enabled", get = GetEnabled, set = SetEnabled, text_template = options_text_template},
		{type = "toggle", name = "Locked", get = GetLocked, set = SetLocked, text_template = options_text_template},
		{type = "toggle", name = "Show Title", get = GetShowTitle, set = SetShowTitle, text_template = options_text_template},
		{type = "range", name = "Scale", get = GetScale, set = SetScale, min = 0.5, max = 2, step = 0.1, usedecimals = true, text_template = options_text_template},

		-- Text Settings section
		{type = "breakline"},
		{type = "label", get = function() return "Text Settings:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
		{type = "range", name = "Font Size", get = GetFontSize, set = SetFontSize, min = 8, max = 24, step = 1, text_template = options_text_template},
		{type = "color", name = "Font Color", get = GetFontColor, set = SetFontColor, text_template = options_text_template},
		{type = "select", name = "Font Face", get = GetFontFace, values = BuildFontList, text_template = options_text_template},
		{type = "select", name = "Font Shadow", get = GetFontShadow, values = BuildShadowList, text_template = options_text_template},

		-- Color Settings section
		{type = "breakline"},
		{type = "label", get = function() return "Color Settings:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
		{type = "color", name = "Backdrop Color", get = GetBackdropColor, set = SetBackdropColor, text_template = options_text_template},
		{type = "color", name = "Highlight Color", get = GetHighlightColor, set = SetHighlightColor, text_template = options_text_template},
	}

	DF:BuildMenu(parentFrame, menuOptions, 7, -50, 500, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template)

Why this pattern matters
- Improves visual hierarchy and readability of complex option panels.
- get() function support enables real-time localization updates without
	panel rebuilds.
- ORANGE_FONT_TEMPLATE provides consistent visual styling across addons.
- breakline/blank separation improves scannability and UX.
- Reduces cognitive load by chunking related options into logical groups.

=====================================================================
End of Part 8
=====================================================================

=====================================================================

=====================================================================
Part 9: consumer API — interacting with the built panel
=====================================================================

Context for this section
- After BuildMenu or BuildMenuVolatile returns, the parent frame has been
	augmented with data structures and methods that the caller can use to
	interact with the panel at runtime. This section documents the public
	surface that consumers should rely on.

---------------------------------------------------------------------
9A) df_menu frame — fields and methods
---------------------------------------------------------------------

After SetAsOptionsPanel (called automatically by BuildMenu/BuildMenuVolatile
when parent.widget_list is nil), the parent frame gains these members:

Fields
- parent.widget_list: array of all created widget objects, in menuOptions
	order. Each entry is a DF widget (button, switch, slider, dropdown, etc.).
- parent.widget_list_by_type: table keyed by widget pool type name
	("dropdown", "switch", "slider", "color", "button", "textentry", "label",
	"image"). Each value is an array of widgets of that type.
- parent.widgetids: table keyed by widgetTable.id string/number → widget
	object. Only populated for entries that had an id field.
- parent.widget_to_disable_check: array of widgetTable entries that have a
	disableif function. Used internally by checkForDisableIF().
- parent.build_menu_options: reference to the menuOptions table passed to
	BuildMenu. Stored for refresh access.

Methods
- parent:RefreshOptions()
	Syncs all widget visuals from their model getters. For each widget in
	widget_list that has a _get function:
	  - label: calls SetText(_get()) when not language-managed.
	  - select/dropdown: calls Select(_get()) to update the selected value.
	  - toggle/switch: calls SetValue(_get()) to update the checked state.
	  - range/slider: calls SetValue(_get()) to update the thumb position.
	  - textentry: sets widget.text = _get().
	Also re-evaluates disableif for all registered widgets and re-syncs
	children_follow_enabled toggle chains.
	Call this after changing the backing data model to update the UI.

- parent:GetWidgetById(id)
	Returns the widget object registered under the given id, or nil if not
	found. Equivalent to parent.widgetids[id].
	Use case: programmatically enable/disable a specific widget, read its
	current value, or modify its properties after the menu has been built.

---------------------------------------------------------------------
9B) Typical post-build patterns
---------------------------------------------------------------------

Refreshing after external data changes:
	-- After importing a profile or resetting defaults:
	parent:RefreshOptions()

Disabling a specific widget programmatically:
	local widget = parent:GetWidgetById("myToggle")
	if widget then
		widget:Disable()
	end

Iterating all widgets of a type:
	for _, switch in ipairs(parent.widget_list_by_type.switch) do
		-- e.g. clear combat lockdown state
		switch.lockdown = nil
		switch:Enable()
	end

Accessing the widget created for a specific widgetTable entry:
	-- After BuildMenu, each widgetTable entry has a .widget back-reference:
	local myEntry = menuOptions[3]
	local widgetObj = myEntry.widget  -- the created DF widget object

=====================================================================
End of Part 9 — end of buildmenu.lua documentation
=====================================================================

=====================================================================
Example 1: Automation options panel — auto-switch and menu-alpha
Source: frames/window_options2_sections.lua  (~13 automation section)
=====================================================================

Overview
- This example is taken from the Details addon's Options window, section ~13
	(automation / auto-hide).
- It demonstrates a real-world BuildMenu call that uses multiple widget types,
	a globally-shared closure for values functions, the always_boxfirst panel
	flag, usedecimals on range sliders, and a conditionally hidden entry.
- The panel is split into two visual columns. BuildMenu handles only the left
	half; the right half (combat-alpha lines) is built manually with
	CreateFrame/NewSwitch/CreateSlider. BuildMenu is therefore called on a
	dedicated sub-frame (autoSwitchFrame) rather than sectionFrame directly.

---------------------------------------------------------------------
Template and constant setup (defined once outside the section closure)
---------------------------------------------------------------------

	local startX = 200        -- left margin for all Options sections
	local startY = -75        -- top margin for all Options sections
	local heightSize = 600    -- column-break height threshold

	-- shared template objects fetched from the framework
	local options_text_template     = DF:GetTemplate("font",     "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template   = DF:GetTemplate("switch",   "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template   = DF:GetTemplate("slider",   "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template   = DF:GetTemplate("button",   "OPTIONS_BUTTON_TEMPLATE")

	-- a smaller font template used for sub-section title labels
	local subSectionTitleTextTemplate = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

---------------------------------------------------------------------
Pre-built values table for a select widget
---------------------------------------------------------------------
The abbreviation dropdown illustrates the pattern where the options list is
constructed once at section-build time and then wrapped by a builder function:

	local onSelectTimeAbbreviation = function(_, _, abbreviationtype)
	    Details.ps_abbreviation = abbreviationtype
	    Details:UpdateToKFunctions()
	    afterUpdate()
	end

	local abbreviationOptions = {
	    {value = 1, label = Loc["STRING_OPTIONS_PS_ABBREVIATE_NONE"],  onclick = onSelectTimeAbbreviation,
	     desc = Loc["STRING_EXAMPLE"] .. ": 305.500 -> 305500"},
	    {value = 2, label = Loc["STRING_OPTIONS_PS_ABBREVIATE_TOK"],   onclick = onSelectTimeAbbreviation,
	     desc = Loc["STRING_EXAMPLE"] .. ": 305.500 -> 305.5K"},
	    -- ... more entries ...
	}

	local buildAbbreviationMenu = function()
	    return abbreviationOptions
	end

The values key of the select entry then calls buildAbbreviationMenu() so the
dropdown receives a fresh table reference each time it opens.

---------------------------------------------------------------------
The sectionOptions table (representative entries)
---------------------------------------------------------------------

	local sectionOptions = {

	    -- ── label: dynamic text via get, styled with text_template ────
	    -- get returns a string; used instead of a static 'name' field.
	    -- text_template applies a font/color template to the label widget.
	    {
	        type = "label",
	        get = function() return Loc["STRING_OPTIONS_GENERAL_ANCHOR"] end,
	        text_template = subSectionTitleTextTemplate,
	    },

	    -- ── toggle: checkbox-style boolean option ─────────────────────
	    -- boxfirst = true draws the checkbox to the left of the label text.
	    -- desc provides the tooltip shown on mouse-over.
	    {
	        type = "toggle",
	        get = function() return Details.use_row_animations end,
	        set = function(self, fixedparam, value)
	            Details:SetUseAnimations(value)
	            afterUpdate()
	        end,
	        name = Loc["STRING_OPTIONS_ANIMATEBARS"],
	        desc = Loc["STRING_OPTIONS_ANIMATEBARS_DESC"],
	        boxfirst = true,
	    },

	    -- ── range (integer): min/max/step, no fractions ───────────────
	    -- step = 1 and no usedecimals means the slider snaps to whole numbers.
	    {
	        type = "range",
	        get = function() return Details.scroll_speed end,
	        set = function(self, fixedparam, value)
	            Details.scroll_speed = value
	        end,
	        min = 1,
	        max = 3,
	        step = 1,
	        name = Loc["STRING_OPTIONS_WHEEL_SPEED"],
	        desc = Loc["STRING_OPTIONS_WHEEL_SPEED_DESC"],
	    },

	    -- ── range (decimal): usedecimals = true ───────────────────────
	    -- step = 0.05 and usedecimals = true allow fractional values.
	    -- The thumb label will display values like "0.25" instead of "0".
	    {
	        type = "range",
	        get = function() return Details.update_speed end,
	        set = function(self, fixedparam, value)
	            Details:SetWindowUpdateSpeed(value)
	            afterUpdate()
	        end,
	        min = 0.05,
	        max = 3,
	        step = 0.05,
	        usedecimals = true,
	        name = Loc["STRING_OPTIONS_WINDOWSPEED"],
	        desc = Loc["STRING_OPTIONS_WINDOWSPEED_DESC"],
	    },

	    -- ── select: dropdown backed by a local values-builder function ─
	    -- values is a function that returns the options table; it is called
	    -- each time the dropdown opens. Using a wrapper function (instead of
	    -- passing the table directly) allows the list to be rebuilt lazily or
	    -- shared with other entries.
	    {
	        type = "select",
	        get = function() return Details.ps_abbreviation end,
	        values = function()
	            return buildAbbreviationMenu()
	        end,
	        name = Loc["STRING_OPTIONS_PS_ABBREVIATE"],
	        desc = Loc["STRING_OPTIONS_PS_ABBREVIATE_DESC"],
	    },

	    {type = "blank"},   -- visual spacer; inserts an empty row

	    -- ── execute: action button with an embedded icon texture ───────
	    -- icontexture is a texture path/id placed to the left of the button text.
	    -- icontexcoords crops the texture file: {left, right, top, bottom} in 0-1 UV space.
	    -- func receives (self) when the button is clicked; param1/param2 are not used here.
	    {
	        type = "execute",
	        func = function(self)
	            local instanceLockButton = currentInstance.baseframe.lock_button
	            Details.lock_instance_function(instanceLockButton, "leftclick", true, true)
	        end,
	        icontexture = [[Interface\PetBattles\PetBattle-LockIcon]],
	        icontexcoords = {0.0703125, 0.9453125, 0.0546875, 0.9453125},
	        name = Loc["STRING_OPTIONS_WC_LOCK"],
	        desc = Loc["STRING_OPTIONS_WC_LOCK_DESC"],
	    },

	    -- ── color: color picker row ────────────────────────────────────
	    -- get returns a table {r, g, b, a}; set receives (self, r, g, b, a).
	    -- boxfirst = true places the color swatch to the left of the label.
	    {
	        type = "color",
	        get = function()
	            local r, g, b = unpack(Details.class_colors.SELF)
	            return {r, g, b, 1}
	        end,
	        set = function(self, r, g, b, a)
	            Details.class_colors.SELF[1] = r
	            Details.class_colors.SELF[2] = g
	            Details.class_colors.SELF[3] = b
	            afterUpdate()
	        end,
	        name = "Your Bar Color",
	        desc = "Your Bar Color",
	        boxfirst = true,
	    },

	    {type = "blank"},

	    -- ── textentry: single-line text input ─────────────────────────
	    -- get returns the initial string shown in the field.
	    -- func (not set) is called when the user presses Enter or leaves focus;
	    -- receives (self, _, text). Using func instead of set is the older
	    -- pattern; both work — set is the preferred modern key.
	    {
	        type = "textentry",
	        get = function()
	            return Details:GetNickname(_G.UnitName("player"), _G.UnitName("player"), true) or ""
	        end,
	        func = function(self, _, text)
	            local accepted, errortext = Details:SetNickname(text)
	            if (not accepted) then
	                Details:ResetPlayerPersona()
	                Details222.OptionsPanel.SetCurrentInstanceAndRefresh(currentInstance)
	            end
	            afterUpdate()
	        end,
	        name = Loc["STRING_OPTIONS_NICKNAME"],
	        desc = Loc["STRING_OPTIONS_NICKNAME"],
	    },

	    {type = "blank"},

	    -- ── toggle with hidden: conditionally absent at build time ─────
	    -- hidden is evaluated immediately when the table is constructed (not
	    -- lazily). If the expression is true the entry is silently skipped by
	    -- parseOptionsTable and no widget is ever created for it.
	    {
	        type = "toggle",
	        get = function() return Details.auto_swap_to_dynamic_overall end,
	        set = function(self, fixedparam, value)
	            Details.auto_swap_to_dynamic_overall = value
	            afterUpdate()
	        end,
	        name = "Use Dynamic Overall Damage",
	        desc = "When showing Damage Done Overall, swap to Dynamic Overall Damage on entering combat.",
	        boxfirst = true,
	        hidden = detailsFramework:IsAddonApocalypseWow(),  -- skipped on ApocalypseWow servers
	    },
	}

---------------------------------------------------------------------
Panel flag and BuildMenu call
---------------------------------------------------------------------
always_boxfirst is assigned to the sectionOptions table after construction,
not as a field inside it. parseOptionsTable reads it as a plain table key:

	sectionFrame.sectionOptions = sectionOptions   -- store reference for later refresh
	sectionOptions.always_boxfirst = true           -- all toggles render box-first globally

	DF:BuildMenu(
	    sectionFrame,             -- parent frame; all widgets anchored here
	    sectionOptions,           -- menuOptions array with panel flags
	    startX,                   -- xOffset  = 200
	    startY - 20,              -- yOffset  = -95  (extra 20px top margin)
	    heightSize + 40,          -- height   = 640  (column-break threshold)
	    false,                    -- useColon = false (no ":" appended to labels)
	    options_text_template,    -- textTemplate    for label widgets
	    options_dropdown_template,-- dropdownTemplate
	    options_switch_template,  -- switchTemplate
	    true,                     -- switchIsCheckbox: all toggles rendered as checkboxes
	    options_slider_template,  -- sliderTemplate
	    options_button_template   -- buttonTemplate  (no valueChangeHook passed)
	)

Notable patterns in this example
- always_boxfirst = true is set on the table after construction. Combined with
	switchIsCheckbox = true in the BuildMenu call, every toggle in the section
	renders as a left-aligned checkbox. The per-entry boxfirst = true fields
	would be redundant here but are left in as explicit intent markers.
- The select entry uses a wrapper function (buildAbbreviationMenu) instead of
	passing abbreviationOptions directly. This lets the list be rebuilt or
	replaced without changing the select entry itself.
- The execute entry uses icontexture + icontexcoords for a cropped icon. The
	UV coords {left, right, top, bottom} reference a region of the source file.
- The textentry uses func (the older commit key) rather than set. Both are
	handled identically by setTextEntryProperties — func takes priority when
	set is absent.
- hidden = detailsFramework:IsAddonApocalypseWow() is evaluated at Lua table
	construction time, not each time the menu is built. The entry is either
	always present or always absent for the lifetime of that table.
- No valueChangeHook is passed to BuildMenu; each set/func calls afterUpdate()
	directly, which is the standard pattern in Details Options panels.

=====================================================================
End of Example 1
=====================================================================

