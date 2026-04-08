# Rounded Corners Frame

Implementation file: `frames.lua`

A rounded corners frame is a standard World of Warcraft frame with rounded borders. It works by using a circle texture (`Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall`) which is split into four quadrants — each quadrant is placed at the corresponding corner of the frame. The space between the corners is filled with solid-color textures (top edge, bottom edge, and a center block) to complete the panel.

The frame automatically handles resizing: when the frame height drops below 32 pixels, corner textures are rescaled so the panel still renders correctly at small sizes.

---

## Entry Points

### `detailsFramework:CreateRoundedPanel(parent, name, optionsTable)`

Creates a new rounded corner frame from scratch.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `parent` | `frame` | The parent frame. |
| `name` | `string\|nil` | Global name for the frame, or `nil` for anonymous. |
| `optionsTable` | `table\|nil` | Options to override defaults (see Options Table below). |

**Returns:** `df_roundedpanel` — A new frame with rounded corners, border, title bar, and scale bar as configured.

**Example — Basic panel:**
```lua
local panel = DetailsFramework:CreateRoundedPanel(UIParent, "MyPanel", {
    width = 300,
    height = 200,
})
panel:SetPoint("center", UIParent, "center", 0, 0)
```

**Example — Panel with title bar and scale bar:**
```lua
local panel = DetailsFramework:CreateRoundedPanel(UIParent, "MyFancyPanel", {
    width = 400,
    height = 300,
    use_titlebar = true,
    use_scalebar = true,
    title = "My Window",
    scale = 1.0,
})
panel:SetPoint("center", UIParent, "center", 0, 0)
panel:SetColor(.1, .1, .1, 1)
panel:SetTitleBarColor(.2, .2, .2, .5)
panel:SetBorderCornerColor(.2, .2, .2, .5)
panel:SetRoundness(3)
```

---

### `detailsFramework:AddRoundedCornersToFrame(frame, preset)`

Adds rounded corners to an already existing frame. If the frame already has rounded corners (`__rcorners` flag), the call is ignored. If the frame has a visible backdrop border, a warning is printed since backdrop borders conflict with the rounded corner visuals.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `frame` | `frame` | An existing WoW frame (or a DetailsFramework widget with a `.widget` field). |
| `preset` | `df_roundedpanel_preset\|nil` | A preset table to configure appearance (see Preset Table below). If `nil`, a default preset is applied. |

**Returns:** Nothing. The frame is modified in place.

**Example — Using the default preset:**
```lua
local myFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
myFrame:SetSize(200, 100)
myFrame:SetPoint("center")
DetailsFramework:AddRoundedCornersToFrame(myFrame)
```

**Example — Using a custom preset:**
```lua
DetailsFramework:AddRoundedCornersToFrame(myFrame, {
    border_color = {0, 0, 0, 0.9},
    color = {0.15, 0.15, 0.15, 1},
    roundness = 5,
})
```

---

## Options Table

Used with `CreateRoundedPanel`. Any field not provided falls back to the default value.

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `200` | Width of the panel. |
| `height` | `number` | `200` | Height of the panel. |
| `use_titlebar` | `boolean` | `false` | Creates a title bar at the top of the panel. |
| `use_scalebar` | `boolean` | `false` | Creates a scale bar (requires a title bar or attaches to the panel). |
| `title` | `string` | `""` | Title text (used with the title bar). |
| `scale` | `number` | `1` | Initial scale of the panel (used with the scale bar). |
| `roundness` | `number` | `0` | How rounded the corners are. Higher values produce more rounded corners. |
| `color` | `table` | `{0.98, 0.98, 0.98, 1}` | Background color as `{r, g, b, a}`. |
| `border_color` | `table` | `{0.98, 0.98, 0.98, 1}` | Border color as `{r, g, b, a}`. |
| `corner_texture` | `string` | `Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall` | Texture used for the corner rounding. |

---

## Preset Table

Used with `AddRoundedCornersToFrame`. All fields are optional.

| Key | Type | Description |
|---|---|---|
| `border_color` | `table` | Border color as `{r, g, b, a}`. |
| `color` | `table` | Background color as `{r, g, b, a}`. |
| `roundness` | `number` | Corner roundness. If omitted, defaults to `1`. |
| `use_titlebar` | `boolean` | If `true`, creates a title bar on the frame. |
| `horizontal_border_size_offset` | `number` | Pixel offset added to horizontal border edges (for fine-tuning at small frame heights). |

**Default preset** (applied when no preset is passed to `AddRoundedCornersToFrame`):
```lua
{
    border_color = {.1, .1, .1, 0.834},
    color = {defaultRed, defaultGreen, defaultBlue}, -- DetailsFramework default backdrop color
    roundness = 3,
}
```

---

## Instance Methods

All methods below are available on a `df_roundedpanel` returned by `CreateRoundedPanel`, or on any frame after calling `AddRoundedCornersToFrame`.

### `panel:SetColor(red, green, blue, alpha)`

Sets the background color of the panel (corners and center fill). Color arguments can also be passed as a color table for the `red` parameter (any format accepted by `detailsFramework:ParseColors`).

When the panel has a border and alpha is below `0.98`, mask textures are shown on border corners to prevent overlapping alpha from producing a darker-than-expected appearance.

### `panel:SetBorderCornerColor(red, green, blue, alpha)`

Sets the color of the border (both corner textures and edge lines). If the border has not been created yet, it is created automatically on the first call.

### `panel:SetTitleBarColor(red, green, blue, alpha)`

Sets the color of the title bar. Does nothing if the panel has no title bar.

### `panel:SetRoundness(roundness)`

Sets how rounded the corners are. A value of `0` produces near-square corners; higher values increase roundness. This adjusts the size of the corner textures and recalculates border sizes. The corner texture base size is 16x16, so valid values generally range from `0` to about `15`.

### `panel:CreateTitleBar()`

Creates a title bar at the top of the panel. The title bar is itself a `df_roundedpanel` with a `Text` fontstring and a close button. The close button hides the parent panel when clicked.

**Returns:** `df_roundedpanel` — The title bar frame.

The title bar is stored at `panel.TitleBar`, and the title text fontstring is at `panel.TitleBar.Text`.

### `panel:CreateBorder()`

Creates the border around the panel. This is called automatically by `SetBorderCornerColor` if no border exists yet, so you typically don't need to call this directly.

The border consists of four corner textures (with mask textures for alpha blending) and four 1-pixel edge lines connecting the corners.

### `panel:GetCornerSize()`

**Returns:** `number, number` — The width and height of the corner textures.

### `panel:GetMaxFrameLevel()`

**Returns:** `number` — The highest frame level among all child frames of the panel.

### `panel:OnSizeChanged()`

Called automatically when the frame is resized. Recalculates corner texture sizes, border edge sizes, and title bar width. You don't need to call this manually — it is hooked into the frame's `OnSizeChanged` script.

### `panel:CalculateBorderEdgeSize(alignment)`

Calculates the length of a border edge line.

| Parameter | Type | Description |
|---|---|---|
| `alignment` | `"vertical"\|"horizontal"` | Which edge direction to calculate. |

**Returns:** `number` — The edge size in pixels.

---

## Internal Textures

These textures are accessible on the panel instance for advanced use cases:

| Field | Type | Description |
|---|---|---|
| `panel.CornerTextures` | `table` | Keyed by `"TopLeft"`, `"TopRight"`, `"BottomLeft"`, `"BottomRight"`. The corner textures. |
| `panel.CenterTextures` | `table` | Array containing the top horizontal edge, bottom horizontal edge, and center block. |
| `panel.BorderCornerTextures` | `table` | Keyed by corner name. Border corner textures (created by `CreateBorder`). |
| `panel.BorderEdgeTextures` | `table` | Keyed by `"Top"`, `"Left"`, `"Bottom"`, `"Right"`. The 1-pixel border edge lines. |
| `panel.TopHorizontalEdge` | `texture` | Fills the gap between the top-left and top-right corners. |
| `panel.BottomHorizontalEdge` | `texture` | Fills the gap between the bottom-left and bottom-right corners. |
| `panel.CenterBlock` | `texture` | Fills the center area between the top and bottom rows of corners. |
| `panel.TitleBar` | `df_roundedpanel` | The title bar frame (if created). |
| `panel.TitleBar.Text` | `fontstring` | The title bar's text fontstring. |

---

## How It Works

1. A circle texture is split into four quadrants using `SetTexCoord`. Each quadrant is placed at the corresponding corner of the frame.
2. Three solid-color textures fill the remaining space: one along the top edge (between the two top corners), one along the bottom edge, and one large block in the center.
3. An optional border is drawn using the same corner-splitting technique with an offset, plus four 1-pixel lines connecting the border corners.
4. When alpha is below `0.98` and a border exists, mask textures are enabled on border corners to prevent visual artifacts from overlapping semi-transparent textures.
5. When the frame height is less than 32 pixels, corner textures are scaled down and the center block is hidden so the panel remains visually correct.
