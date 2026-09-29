
--the live preview shown by the designer section of the options window: a real details! window, built detached
--inside the designer so it is never one of the user's windows, pinned to a sample session and stripped of the
--interaction a window on the screen has

local Details = _G.Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = _G.DetailsFramework

local _ = nil

--constants
--the preview window's height; its width is whatever the options window leaves beside the editor, which the
--designer measures and passes to Create
local PREVIEW_WINDOW_HEIGHT = 260
--clears the caption drawn across the top of the host frame
local PREVIEW_WINDOW_TOP_INSET = -20
--the scripts a details! row installs on itself and on its class icon. every one of them assumes a window the
--user owns and live combat data, so all of them come off the preview
local ROW_SCRIPTS = {"OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp", "OnClick"}
local ROW_ICON_SCRIPTS = {"OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp"}
--the scripts details! installs on the window body and on the invisible strips above and below it. a mouse
--down on any of them starts moving the window, and hovering them fades in the resize grips and the lock button
local WINDOW_SCRIPTS = {"OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp"}
--the title text is drawn on the preview whether or not the setting is on, so it can always be clicked; how
--strongly it is drawn is what says which it is
local TITLE_TEXT_ENABLED_ALPHA = 1
local TITLE_TEXT_DISABLED_ALPHA = 0.35
--where the title text's own click target sits, counted from the base frame.
--
--the editor builds one overlay per registered object at the object's frame level plus one. a fontstring has
--no frame level of its own, so the editor reads its parent's, and the title text's parent is the base frame,
--exactly like the title bar frame. both overlays would then land at base + 2 over the same strip of the window
--and which one takes a click is arbitrary.
--
--  base + 1  titleBar, UPFrame            overlays at base + 2 and base + 3
--  base + 2  the four toolbar buttons     overlays at base + 3
--  base + 5  the display mode button      overlay at base + 6
--
--base + 3 is the lowest level that clears the title bar outright. its overlay lands at base + 4, under the
--display mode button and over everything else in the strip. the toolbar buttons do not overlap it: details!
--sizes the title text to stop short of them.
local TITLE_TEXT_CLICK_LEVEL_OFFSET = 3
--how far past the drawn text the click target reaches, on the right. the fontstring box is sized to the
--window width less the toolbar buttons, so pinning the target to that box would give the title text almost
--the whole title bar; the target is sized to the glyphs instead
local TITLE_TEXT_CLICK_PADDING = 4
--what the target falls back to when there is no text to measure
local TITLE_TEXT_MIN_CLICK_WIDTH = 24

---@class details_options_designer_preview : table
Details222.OptionsDesignerPreview = {}

--the hosted window, nil until the designer is first shown or when details! had no id left to build one
---@type instance|nil
local previewInstance = nil

--the frame registered for the title text, standing in for a fontstring the editor cannot rank against its
--neighbours. see forceTitleTextVisible
---@type frame
local titleTextClickTarget = nil

--returns the hosted window, or nil when there is none
---@return instance|nil
function Details222.OptionsDesignerPreview:GetInstance()
	return previewInstance
end

--strips the interaction a details! window installs on itself.
--the window is built by the same code as the user's windows, which is the only way to get a preview that is
--honestly the real thing, and that code assumes a window sitting on the screen. dragging it, resizing it or
--opening a menu from it are all wrong inside the options window.
---@param instanceObject instance
local deFangWindow = function(instanceObject)
	local baseFrame = instanceObject.baseframe

	baseFrame:SetMovable(false)
	baseFrame:SetResizable(false)
	baseFrame:RegisterForDrag()
	baseFrame:SetScript("OnDragStart", nil)
	baseFrame:SetScript("OnDragStop", nil)
	baseFrame:SetScript("OnSizeChanged", nil)

	--every frame that moves the window on a mouse down: the base frame, the background behind the rows, the
	--window switch button, and the invisible strips over the title bar and the status bar.
	--the scripts come off rather than the mouse: the click-through settings turn the mouse back on for all of
	--these on every skin change, while the scripts are only ever set once, when the window is built
	local movingFrames = {
		baseFrame,
		instanceObject.windowBackgroundDisplay,
		instanceObject.windowSwitchButton,
		baseFrame.UPFrame,
		baseFrame.UPFrameConnect,
		baseFrame.UPFrameLeftPart,
		baseFrame.DOWNFrame,
	}

	for index, movingFrame in ipairs(movingFrames) do
		for scriptIndex, scriptName in ipairs(WINDOW_SCRIPTS) do
			movingFrame:SetScript(scriptName, nil)
		end
	end

	--the window is also locked, so any path left that tries to move it refuses on its own: a new row arrives
	--with a script that moves an unlocked window before DeFangRows reaches it.
	--no lock or unlock reaches the preview afterwards: lock all and unlock all walk only the user's windows,
	--and the lock button that toggles a single window is hidden below
	instanceObject:LockInstance(true)

	--the grips and the lock button position and resize a window on the screen; the host decides the geometry
	baseFrame.button_stretch:Hide()
	baseFrame.resize_direita:Hide()
	baseFrame.resize_esquerda:Hide()
	baseFrame.lock_button:Hide()

	--the toolbar buttons open menus over segments, displays and reports, none of which mean anything for a
	--window showing a fixed sample.
	--baseframe.cabecalho is a plain lua table holding the toolbar's parts, not a frame. some parts are
	--framework widgets, whose frame sits behind a .widget field, and some are textures with no mouse at all.
	for key, toolbarPart in pairs(baseFrame.cabecalho) do
		local toolbarFrame = toolbarPart

		if (type(toolbarPart) == "table" and toolbarPart.widget) then
			toolbarFrame = toolbarPart.widget
		end

		if (type(toolbarFrame) == "table" and toolbarFrame.EnableMouse) then
			toolbarFrame:EnableMouse(false)
		end
	end

	instanceObject.windowSwitchButton:Hide()
end

--strips the scripts details! installs on every bar of a window.
--rows are created as data arrives, so this runs after the preview is fed and again after every edit.
--a tooltip over a sample row, or a breakdown window opened from one, is wrong in the options window no matter
--what it reports, so every script comes off.
---@param instanceObject instance
local deFangRows = function(instanceObject)
	for index, rowFrame in ipairs(instanceObject.barras) do
		for scriptIndex, scriptName in ipairs(ROW_SCRIPTS) do
			rowFrame:SetScript(scriptName, nil)
		end

		for scriptIndex, scriptName in ipairs(ROW_ICON_SCRIPTS) do
			rowFrame.icon_frame:SetScript(scriptName, nil)
		end
	end
end

--pins the title text's click target over the glyphs the fontstring is drawing, rather than over the box it
--reserves. two points down the left edge take the height from the fontstring and leave the width ours to set;
--the text is left aligned, so measuring from the left edge covers exactly what the user sees.
---@param instanceObject instance
local resizeTitleTextClickTarget = function(instanceObject)
	local titleTextFontString = instanceObject:GetTitleBarFontString():GetUIObject()

	titleTextClickTarget:ClearAllPoints()
	titleTextClickTarget:SetPoint("topleft", titleTextFontString, "topleft", 0, 0)
	titleTextClickTarget:SetPoint("bottomleft", titleTextFontString, "bottomleft", 0, 0)

	local drawnWidth = titleTextFontString:GetStringWidth() + TITLE_TEXT_CLICK_PADDING

	if (drawnWidth < TITLE_TEXT_MIN_CLICK_WIDTH) then
		drawnWidth = TITLE_TEXT_MIN_CLICK_WIDTH
	end

	titleTextClickTarget:SetWidth(drawnWidth)
end

--keeps the preview's title text placed and visible whatever its setting says.
--
--AttributeMenu returns the moment it has created the fontstring when the title text is switched off, which is
--the default, so the fontstring exists but was never anchored and has no rect. the editor sizes a click overlay
--with SetAllPoints(member), so an unanchored title text could not be clicked, and clicking it is the only way
--to reach the toggle that switches it on.
--
--placing it once is not enough: ChangeSkin, ToolbarSide and the fade handling all call AttributeMenu() with
--no arguments and every one of them would hide it again. so the preview gets its own AttributeMenu, which
--always takes the enabled path, the one that anchors the fontstring, then puts the stored setting back and
--says what the setting really is by dimming the text rather than hiding it. leaving the forced true in
--attribute_text.enabled would flip the designer's own checkbox.
---@param instanceObject instance
local forceTitleTextVisible = function(instanceObject)
	local baseFrame = instanceObject.baseframe

	--the frame the designer registers in the fontstring's place: a fontstring carries no frame level, so its
	--overlay would tie with the title bar's. a frame can be ranked, so the tie is decided here.
	--it is built before the override below, which resizes it on every call
	titleTextClickTarget = CreateFrame("frame", "DetailsOptionsDesignerTitleTextClickTarget", baseFrame)
	titleTextClickTarget:SetFrameLevel(baseFrame:GetFrameLevel() + TITLE_TEXT_CLICK_LEVEL_OFFSET)

	instanceObject.AttributeMenu = function(previewObject, bIsEnabled, ...)
		--the original treats anything but a boolean as "not given" and falls back to the stored value
		if (type(bIsEnabled) ~= "boolean") then
			bIsEnabled = previewObject.attribute_text.enabled
		end

		Details.AttributeMenu(previewObject, true, ...)

		previewObject.attribute_text.enabled = bIsEnabled

		local titleTextLabel = previewObject:GetTitleBarFontString()

		if (bIsEnabled) then
			titleTextLabel:SetAlpha(TITLE_TEXT_ENABLED_ALPHA)
		else
			titleTextLabel:SetAlpha(TITLE_TEXT_DISABLED_ALPHA)
		end

		--the font, the size and the anchor have all just been re-applied, so the text occupies a different
		--amount of room than it did a moment ago
		resizeTitleTextClickTarget(previewObject)
	end

	--the width AttributeMenu gives the fontstring comes from how many toolbar buttons are shown, a count only
	--set when the toolbar is laid out. a detached window does that only on some paths, so it is done here; the
	--call is idempotent
	instanceObject:ToolbarMenuSetButtons()

	--creates, anchors and sizes the fontstring, and through the override above pins the click target over it,
	--before the designer registers anything
	instanceObject:AttributeMenu()
end

--strips the interaction from every bar currently built on the preview. the designer calls this after
--anything that may have created new rows
function Details222.OptionsDesignerPreview:DeFangRows()
	deFangRows(previewInstance)
end

--builds a details! window inside the host frame, pins it to a sample session and strips its interaction.
--the window is detached: it is not counted by the window limit, not written to the profile, not listed in the
--window dropdown and no broadcast reaches it. it does not survive a reload, which is what a preview should do.
---@param hostFrame frame
---@param windowWidth number
---@return instance|nil
function Details222.OptionsDesignerPreview:Create(hostFrame, windowWidth)
	local createdInstance = Details:CreateDetachedInstance(hostFrame)

	--no free id left for a detached window; documented, and the designer says so instead of erroring
	if (not createdInstance) then
		return nil
	end

	previewInstance = createdInstance

	local baseFrame = createdInstance.baseframe
	baseFrame:ClearAllPoints()
	baseFrame:SetPoint("topleft", hostFrame, "topleft", 0, PREVIEW_WINDOW_TOP_INSET)
	baseFrame:SetSize(windowWidth, PREVIEW_WINDOW_HEIGHT)

	--a pinned session renders on every refresh, so the rows survive the refresh every settings change
	--triggers. Details:CreateTestBars is not an option: it writes fake actors into the current combat and so
	--reaches every window the user has open
	Details:FeedInstanceWithSession(createdInstance)

	deFangWindow(createdInstance)
	deFangRows(createdInstance)
	forceTitleTextVisible(createdInstance)

	return createdInstance
end

--returns the frame the designer registers for the title text. it is not the fontstring: see
--forceTitleTextVisible for why a frame has to stand in for it
---@return frame
function Details222.OptionsDesignerPreview:GetTitleTextClickTarget()
	return titleTextClickTarget
end

--returns the height the preview window is drawn at, so the designer can size the frame hosting it
---@return number
function Details222.OptionsDesignerPreview:GetWindowHeight()
	return PREVIEW_WINDOW_HEIGHT
end
