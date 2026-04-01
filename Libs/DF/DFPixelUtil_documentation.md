DFPixelUtil.lua documentation

=====================================================================
Overview
=====================================================================

DFPixelUtil is a DetailsFramework polyfill for Blizzard's built-in
PixelUtil API. It provides pixel-perfect sizing and positioning of
UI elements by snapping measurements to the nearest physical pixel
boundary.

WoW's UI coordinate system uses abstract "UI units" rather than
physical pixels. At different screen resolutions and UI scale
settings, a single UI unit may span a fractional number of pixels,
causing blurry edges on thin borders or 1px lines. DFPixelUtil
solves this by rounding all sizes and offsets to exact pixel
boundaries.

The module is loaded early via load.xml (line 3) and consumed
throughout the framework via the alias pattern:

    local PixelUtil = PixelUtil or DFPixelUtil

This means Blizzard's native PixelUtil is used when available
(Retail), and DFPixelUtil serves as the fallback on Classic-era
clients where PixelUtil may not exist.

Global table
    DFPixelUtil = {}

Consumers (non-exhaustive)
    - cooltip.lua (line 32)
    - fw.lua (line 102) — border rendering, template sizing
    - buildmenu.lua — widget positioning and sizing
    - core/plugins.lua (line 4) — plugin frame layout
    - loadconditions.lua (line 29)


=====================================================================
1) GetPixelToUIUnitFactor()
=====================================================================

Location
    DFPixelUtil.lua line 3

Signature
    DFPixelUtil.GetPixelToUIUnitFactor()

Purpose
    Returns the conversion factor from physical pixels to UI units.
    This is the foundational value used by all other functions in
    the module.

Parameters
    None.

Returns
    (number) The UI-unit size of one physical pixel.

Behavior
    Calls GetPhysicalScreenSize() to get the monitor's native
    resolution, then computes:

        factor = 768.0 / physicalHeight

    The value 768 is WoW's reference UI height — the UI is
    designed so that at 768 physical pixels tall, 1 UI unit = 1
    pixel (factor = 1.0). At higher resolutions, the factor
    shrinks (e.g., 768/1080 ≈ 0.711), meaning each physical pixel
    is smaller than one UI unit.

Example
    -- On a 1920×1080 monitor:
    local factor = DFPixelUtil.GetPixelToUIUnitFactor()
    -- factor ≈ 0.7111  (768 / 1080)

    -- On a 2560×1440 monitor:
    -- factor ≈ 0.5333  (768 / 1440)


=====================================================================
2) GetNearestPixelSize()
=====================================================================

Location
    DFPixelUtil.lua line 8

Signature
    DFPixelUtil.GetNearestPixelSize(uiUnitSize, layoutScale,
        minPixels)

Purpose
    Converts a desired UI-unit size into the nearest size that maps
    to an exact integer number of physical pixels. This eliminates
    sub-pixel rendering artifacts.

Parameters
    uiUnitSize  (number, required)
        The desired size in UI units.

    layoutScale (number, required)
        The effective scale of the region being sized. Typically
        obtained via region:GetEffectiveScale().

    minPixels   (number|nil, optional)
        Minimum number of physical pixels the result must occupy.
        Guarantees visibility of thin elements (e.g., 1px borders).

Returns
    (number) The snapped size in UI units.

Behavior
    1. Short-circuit: if uiUnitSize == 0 and minPixels is nil or 0,
       returns 0 immediately.

    2. Gets the pixel-to-UI-unit factor via GetPixelToUIUnitFactor().

    3. Converts to pixel count:
           numPixels = Round((uiUnitSize * layoutScale) / factor)

    4. Applies minPixels enforcement:
       - If uiUnitSize is negative and numPixels > -minPixels:
         clamps to -minPixels.
       - If uiUnitSize is positive and numPixels < minPixels:
         clamps to minPixels.

    5. Converts back to UI units:
           result = numPixels * factor / layoutScale

Math breakdown
    Given a 1080p screen (factor = 0.7111) and effective scale 1.0:

    GetNearestPixelSize(0.5, 1.0)
        numPixels = Round(0.5 / 0.7111) = Round(0.703) = 1
        result = 1 * 0.7111 / 1.0 = 0.7111

    The input 0.5 UI units would land between pixels. The function
    rounds up to 1 physical pixel and returns the UI-unit size for
    exactly 1 pixel.

Example
    -- Snap a 2px border to exact pixels:
    local snapped = DFPixelUtil.GetNearestPixelSize(2, frame:GetEffectiveScale(), 1)


=====================================================================
3) SetWidth()
=====================================================================

Location
    DFPixelUtil.lua line 31

Signature
    DFPixelUtil.SetWidth(region, width, minPixels)

Purpose
    Sets a region's width snapped to the nearest physical pixel.

Parameters
    region      (region/frame, required)
        Any WoW UI region (frame, texture, fontstring, etc.).

    width       (number, required)
        Desired width in UI units.

    minPixels   (number|nil, optional)
        Minimum pixel width. Pass 1 to guarantee at least 1px.

Behavior
    Calls:
        region:SetWidth(GetNearestPixelSize(width,
            region:GetEffectiveScale(), minPixels))

Example
    -- Set a border texture to exactly 1 pixel wide:
    DFPixelUtil.SetWidth(borderTexture, 1, 1)


=====================================================================
4) SetHeight()
=====================================================================

Location
    DFPixelUtil.lua line 35

Signature
    DFPixelUtil.SetHeight(region, height, minPixels)

Purpose
    Sets a region's height snapped to the nearest physical pixel.

Parameters
    region      (region/frame, required)
    height      (number, required) Desired height in UI units.
    minPixels   (number|nil, optional) Minimum pixel height.

Behavior
    Calls:
        region:SetHeight(GetNearestPixelSize(height,
            region:GetEffectiveScale(), minPixels))

Example
    DFPixelUtil.SetHeight(separatorLine, 1, 1)


=====================================================================
5) SetSize()
=====================================================================

Location
    DFPixelUtil.lua line 39

Signature
    DFPixelUtil.SetSize(region, width, height, minWidthPixels,
        minHeightPixels)

Purpose
    Sets both width and height snapped to nearest physical pixels.

Parameters
    region              (region/frame, required)
    width               (number, required)
    height              (number, required)
    minWidthPixels      (number|nil, optional)
    minHeightPixels     (number|nil, optional)

Behavior
    Calls SetWidth then SetHeight.

Example
    -- 32×32 icon snapped to exact pixels:
    DFPixelUtil.SetSize(iconTexture, 32, 32)

    -- Highlight frame with minimum 1px in each dimension:
    DFPixelUtil.SetSize(highlightFrame, widgetWidth, height, 1, 1)


=====================================================================
6) SetPoint()
=====================================================================

Location
    DFPixelUtil.lua line 44

Signature
    DFPixelUtil.SetPoint(region, point, relativeTo, relativePoint,
        offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)

Purpose
    Anchors a region with offsets snapped to the nearest physical
    pixel. Prevents sub-pixel positioning that causes blurry or
    misaligned elements.

Parameters
    region              (region/frame, required)
    point               (string, required) Anchor point on region
                        ("TOPLEFT", "CENTER", etc.).
    relativeTo          (frame, required) The reference frame.
    relativePoint       (string, required) Anchor point on the
                        reference frame.
    offsetX             (number, required) X offset in UI units.
    offsetY             (number, required) Y offset in UI units.
    minOffsetXPixels    (number|nil, optional) Minimum X offset
                        in pixels.
    minOffsetYPixels    (number|nil, optional) Minimum Y offset
                        in pixels.

Behavior
    Calls region:SetPoint() with both offsets individually snapped:
        region:SetPoint(point, relativeTo, relativePoint,
            GetNearestPixelSize(offsetX, scale, minOffsetXPixels),
            GetNearestPixelSize(offsetY, scale, minOffsetYPixels))

Example
    -- Position a widget at an exact pixel offset:
    DFPixelUtil.SetPoint(label, "topleft", parent, "topleft", 10, -5)

    -- Border texture with guaranteed 1px offset:
    DFPixelUtil.SetPoint(border, "topleft", frame, "topleft",
        -1, 1, 1, 1)


=====================================================================
7) SetStatusBarValue()
=====================================================================

Location
    DFPixelUtil.lua line 51

Signature
    DFPixelUtil.SetStatusBarValue(statusBar, value)

Purpose
    Sets a StatusBar's value such that the fill edge lands on an
    exact pixel boundary. Without this, partial-fill bars can have
    a blurry or jittering right edge.

Parameters
    statusBar   (StatusBar frame, required)
    value       (number, required) The value to set.

Behavior
    1. Gets the bar's current width. If width is 0 or nil, falls
       back to plain statusBar:SetValue(value).

    2. Computes the fill percentage:
           percent = ClampedPercentageBetween(value, min, max)

    3. Edge cases: if percent is exactly 0.0 or 1.0 (empty or
       full), sets the value directly — no rounding needed.

    4. Otherwise, snaps the fill width to the nearest pixel:
           numPixels = GetNearestPixelSize(width * percent, scale)

    5. Reverse-maps back to a bar value:
           roundedValue = Lerp(min, max, numPixels / width)

    6. Sets statusBar:SetValue(roundedValue).

    This ensures the bar's fill texture always ends on a pixel
    boundary, producing a clean edge.

Example
    -- Update a health bar with pixel-perfect fill:
    DFPixelUtil.SetStatusBarValue(healthBar, currentHP)


=====================================================================
Function quick reference
=====================================================================

    ┌─────────────────────────┬────────────────────────────────────┐
    │ Function                │ Purpose                            │
    ├─────────────────────────┼────────────────────────────────────┤
    │ GetPixelToUIUnitFactor  │ 768 / screenHeight conversion     │
    │ GetNearestPixelSize     │ Snap UI units to pixel boundary   │
    │ SetWidth                │ Pixel-perfect width                │
    │ SetHeight               │ Pixel-perfect height               │
    │ SetSize                 │ Pixel-perfect width + height       │
    │ SetPoint                │ Pixel-perfect anchor offsets       │
    │ SetStatusBarValue       │ Pixel-perfect bar fill edge        │
    └─────────────────────────┴────────────────────────────────────┘
