
--the designer section of the options window: a live preview of a details! window beside an object editor.
--the user clicks a part of the preview to select it and every edit lands at once on the window picked in the
--options window's dropdown at the top right, and on the preview

local Details = _G.Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

local _ = nil

--constants
--where the designer sits inside the options window, measured from the options window itself rather than from
--the section frame, which is offset from it. the left edge lines up with the buttons at the top of the window
--and the top clears the window dropdown at the top right
local DESIGNER_LEFT = 152
local DESIGNER_TOP = -73
local DESIGNER_BOTTOM_INSET = 10
--the editor's center column. its rows are a label column then a widget column, starting at x = 2, and the row
--highlight reaches 2 + label + widget + 5, so label + widget + 7 has to fit the column or the colour swatches
--and checkboxes on the right are clipped. 150 + 160 + 7 = 317 fits 320
local OPTIONS_WIDTH = 320
local OPTIONS_LABEL_WIDTH = 150
local OPTIONS_WIDGET_WIDTH = 160
--the object list only has to fit the longest part name
local OBJECT_LIST_WIDTH = 110
--the framework's scrollbar gutter: the editor puts it between the object list and the canvas, and it is used
--again between the canvas and the preview, where the canvas draws its own scrollbar
local COLUMN_GUTTER = 30
--editor width = object_list_width + gutter + options_width
local EDITOR_WIDTH = OBJECT_LIST_WIDTH + COLUMN_GUTTER + OPTIONS_WIDTH
--object list lines = floor(object_list_height / (line_height + 1)), so the list fills the editor
local OBJECT_LIST_LINE_HEIGHT = 20
--room left under the object list and the canvas for the undo and redo buttons the editor anchors to its
--bottom right corner, 22 px tall and 6 px up
local UNDO_BAR_HEIGHT = 30
--the space kept between the preview window and the right border of the options window
local PREVIEW_RIGHT_INSET = 10
--the caption drawn above the preview window
local PREVIEW_HOST_CAPTION_HEIGHT = 20
--the note below the preview window
local PREVIEW_HINT_SPACING = 8
--the editor paints a magenta wash over the selected object by default
local SELECTION_TINT = {0, 0, 0, 0}
--details! debounces its options-modified event by 0.3 s, so an edit of ours can come back to us up to that
--long after we made it. anything inside this window is treated as our own and does not rebuild the widget
--the user is still holding
local OWN_EDIT_ECHO_WINDOW = 0.5

--the object editor, nil until the section is shown for the first time
---@type df_editor
local editorFrame = nil

--points every registered object at the window now being edited and rebuilds the open option menu.
--re-pointing alone changes nothing on screen: the editor's widgets capture their value at build time, so the
--refresh is the half the user sees
local repointEditorAtTarget = function()
	editorFrame:UpdateProfileTableOnAllRegisteredObjects(Details222.OptionsDesignerObjects:GetEditedInstance())
	editorFrame:Refresh()
end

--builds the frame the preview window lives in, to the right of the editor, with a caption above it and a
--note below it saying how the section works
---@param designerFrame frame
---@param editorCanvasFrame frame
---@param optionsFrame frame
---@return instance|nil
local buildPreviewHost = function(designerFrame, editorCanvasFrame, optionsFrame)
	--the preview takes every pixel the options window leaves to the right of the editor, less a small margin,
	--so it follows the options window if its width changes
	local previewWidth = optionsFrame:GetWidth() - DESIGNER_LEFT - EDITOR_WIDTH - COLUMN_GUTTER - PREVIEW_RIGHT_INSET
	local previewHeight = Details222.OptionsDesignerPreview:GetWindowHeight()

	local previewHost = CreateFrame("frame", "$parentPreviewHost", designerFrame)
	previewHost:SetSize(previewWidth, previewHeight + PREVIEW_HOST_CAPTION_HEIGHT)
	previewHost:SetPoint("topleft", editorCanvasFrame, "topright", COLUMN_GUTTER, 0)
	designerFrame.PreviewHost = previewHost

	local previewLabel = detailsFramework:CreateLabel(previewHost, Loc["STRING_OPTIONS_DESIGNER_PREVIEW"], 11, "gray")
	previewLabel:SetPoint("topleft", previewHost, "topleft", 2, -2)

	local hintLabel = detailsFramework:CreateLabel(previewHost, Loc["STRING_OPTIONS_DESIGNER_HINT"], 10, "gray")
	hintLabel:SetPoint("topleft", previewHost, "bottomleft", 2, -PREVIEW_HINT_SPACING)
	hintLabel:SetWidth(previewWidth - 4)

	local createdInstance = Details222.OptionsDesignerPreview:Create(previewHost, previewWidth)

	--details! had no id left for a detached window: there is nothing to click, so the section says so and the
	--designer is not built
	if (not createdInstance) then
		local missingLabel = detailsFramework:CreateLabel(previewHost, Loc["STRING_OPTIONS_DESIGNER_PREVIEW_MISSING"], 11, "silver")
		missingLabel:SetPoint("topleft", previewHost, "topleft", 2, -PREVIEW_HOST_CAPTION_HEIGHT)
		missingLabel:SetWidth(previewWidth - 4)
	end

	return createdInstance
end

--registers every clickable part of the preview with the editor.
--the object is a preview widget, so that is what the user clicks and what the selection brackets land on. the
--profile table is the window being edited, a different object entirely, and that split is what lets the
--section show one window and configure another
---@param previewInstance instance
local registerPreviewObjects = function(previewInstance)
	local editedInstance = Details222.OptionsDesignerObjects:GetEditedInstance()
	local subTablePath = Details222.OptionsDesignerObjects:GetSubTablePath()

	for index, registration in ipairs(Details222.OptionsDesignerObjects:GetRegistrations(previewInstance)) do
		--RegisterObject deploys onto the options table it is passed, so each registration gets its own
		local objectOptions = {can_move = false, use_colon = true}

		editorFrame:RegisterObject(
			registration.Object,
			registration.label,
			registration.id,
			editedInstance,
			subTablePath,
			registration.profileKeyMap,
			registration.extraOptions,
			Details222.OptionsDesignerObjects:BuildCallback(registration),
			objectOptions
		)
	end
end

--subscribes to the details! events meaning what the designer shows is out of date.
--
--applying a profile rebuilds every window from the saved skins, so the values the editor captured are stale.
--
--DETAILS_OPTIONS_MODIFIED is the only signal that something changed, and it says neither what nor who. the
--designer ignores the echo of its own edits and only reacts while it is on screen; switching to it from
--another section already re-reads the window through RefreshOptions
---@param sectionFrame frame
local subscribeToDetailsEvents = function(sectionFrame)
	local detailsListener = Details:CreateEventListener()

	detailsListener:RegisterEvent("DETAILS_PROFILE_APPLYED", function()
		repointEditorAtTarget()
	end)

	detailsListener:RegisterEvent("DETAILS_OPTIONS_MODIFIED", function()
		if (not sectionFrame:IsVisible()) then
			return
		end

		if (GetTime() - Details222.OptionsDesignerObjects:GetLastEditTime() < OWN_EDIT_ECHO_WINDOW) then
			return
		end

		repointEditorAtTarget()
	end)
end

--builds the designer: the object editor on the left, the live preview beside it.
--runs the first time the section is shown rather than when the options window is built, the same laziness a
--framework tab container gives a tab: the preview is a whole details! window and most users never open this
--section
---@param sectionFrame frame
local buildDesigner = function(sectionFrame)
	local optionsFrame = sectionFrame:GetParent()
	local designerHeight = optionsFrame:GetHeight() + DESIGNER_TOP - DESIGNER_BOTTOM_INSET

	local designerFrame = CreateFrame("frame", "$parentDesigner", sectionFrame)
	designerFrame:SetPoint("topleft", optionsFrame, "topleft", DESIGNER_LEFT, DESIGNER_TOP)
	designerFrame:SetSize(EDITOR_WIDTH, designerHeight)
	--clicks on empty regions fall through; interactive children re-enable for themselves
	designerFrame:EnableMouse(false)
	sectionFrame.DesignerFrame = designerFrame

	local objectListHeight = designerHeight - UNDO_BAR_HEIGHT

	local editorOptions = {
		width = EDITOR_WIDTH,
		height = designerHeight,
		options_width = OPTIONS_WIDTH,
		options_label_width = OPTIONS_LABEL_WIDTH,
		options_widget_width = OPTIONS_WIDGET_WIDTH,
		object_list_width = OBJECT_LIST_WIDTH,
		object_list_height = objectListHeight,
		object_list_line_height = OBJECT_LIST_LINE_HEIGHT,
		object_list_lines = math.floor(objectListHeight / (OBJECT_LIST_LINE_HEIGHT + 1)),
		show_undo_buttons = true,
	}

	--the editor calls SetToplevel(true) on whatever it is handed as parent, which is why it gets the
	--designer frame and not the section frame the options window manages
	--a literal name: the editor builds its children's names by appending to this string, so a $parent token
	--here would be resolved again against each child's own parent
	editorFrame = detailsFramework:CreateEditor(designerFrame, "DetailsOptionsDesignerEditor", editorOptions)
	editorFrame:SetPoint("topleft", designerFrame, "topleft", 0, 0)
	editorFrame:EnableMouse(false)
	editorFrame:SetSelectedBackgroundColor(unpack(SELECTION_TINT))

	local previewInstance = buildPreviewHost(designerFrame, editorFrame:GetCanvasScrollBox(), optionsFrame)

	--with no preview there is nothing to click and nothing to register, so the editor is left empty
	if (not previewInstance) then
		return
	end

	registerPreviewObjects(previewInstance)

	--the options window calls this when the section is selected and when another window is picked in its
	--dropdown, which is what moves every edit onto the newly picked window
	sectionFrame.RefreshOptions = repointEditorAtTarget

	subscribeToDetailsEvents(sectionFrame)

	editorFrame:EditObjectByIndex(1)
end

--builds the designer section into the frame the options window created for it
---@param sectionFrame frame
local buildSection = function(sectionFrame)
	local isBuilt = false

	--HookScript rather than SetScript so nothing else the section frame runs on show is replaced
	sectionFrame:HookScript("OnShow", function()
		if (isBuilt) then
			return
		end

		isBuilt = true
		buildDesigner(sectionFrame)
	end)
end

Details.optionsSection[Details222.OptionsPanel.DESIGNER_SECTION_ID] = buildSection
