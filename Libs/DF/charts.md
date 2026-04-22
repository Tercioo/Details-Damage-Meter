charts.lua documentation
Part 1: object creation, mixins, and constructor

=====================================================================
Overview
=====================================================================

- charts.lua implements the DetailsFramework chart system for plotting
  data as multi-line graphs within World of Warcraft addon UI.
- The chart supports multiple data lines, each with independent color,
  smoothing method, and name. It is designed for visualizing time-series
  data such as damage-per-second, healing-over-time, or resource usage
  during a boss encounter.
- The single public entry point for creating a chart is:
      DF:CreateGraphicMultiLineFrame(parent, name)
- The returned object (df_chartmulti) is a Blizzard frame enriched with
  three mixins that provide value tracking, multi-chart management, and
  shared chart utilities (axes, labels, indicators, smoothing).

=====================================================================
1) Object architecture
=====================================================================

A DetailsFramework chart is a Blizzard frame (df_chartmulti) with three
mixins mixed into it. Each mixin adds a set of methods and fields.

Layer diagram:

    df_chartmulti (the chart you interact with)
     ├── ValueMixin            -- min/max value tracking
     ├── MultiChartFrameMixin  -- multi-line management, AddData, Plot
     ├── ChartFrameSharedMixin -- axes, labels, indicators, smoothing
     ├── .plotFrame             -- child frame that holds all drawn lines
     └── .chartFrames[]         -- array of df_chart sub-frames (one per line)

Key types:
- df_chartmulti: the main chart object. This is what
  CreateGraphicMultiLineFrame returns. It is a frame that manages
  multiple df_chart sub-frames.
- df_chart: an internal sub-frame created automatically for each data
  line added via AddData(). Each one holds its own data, lines, color,
  and can independently Plot its line. Users do not create these
  directly.
- df_chartline: a line texture used to draw individual segments of the
  graph. Managed internally by each df_chart.


=====================================================================
2) DF:CreateGraphicMultiLineFrame — the public constructor
=====================================================================

Signature
    DF:CreateGraphicMultiLineFrame(parent, name)

Returns
    df_chartmulti — the chart frame object.

Parameter reference

    parent (frame, required)
        The frame that will own this chart. Typically UIParent or a
        custom settings frame.

    name (string or nil)
        Global name for the underlying Blizzard frame. If nil, a random
        name is generated: "DetailsMultiChartFrameID" .. math.random().


=====================================================================
3) Construction sequence
=====================================================================

What happens inside CreateGraphicMultiLineFrame, step by step:

    1. Name generation: if name is nil, generates a random unique name.

    2. Frame creation: calls CreateFrame("frame", name, parent,
       "BackdropTemplate") to create the raw Blizzard frame.

    3. Mixin: ValueMixin
       Mixed in via DF:Mixin. Adds min/max value tracking methods
       (see section 4).

    4. Mixin: MultiChartFrameMixin
       Mixed in via DF:Mixin. Adds all multi-chart management methods:
       AddData, GetChart, Plot, Reset, etc. (see section 5).

    5. Mixin: ChartFrameSharedMixin
       Mixed in via DF:Mixin. Adds shared utilities: axes creation,
       backdrop indicators, fill controls, data shrinking, and more.
       (Will be documented in Part 2.)

    6. ValueConstructor call:
       Initializes minValue = 0, maxValue = 1 via ResetMinMaxValues().

    7. MultiChartFrameConstructor call:
       Initializes multi-chart state (see section 5 for details).
       Also internally calls chartFrameSharedConstructor to set shared
       defaults (see section 6).

    8. Plot frame creation:
       Calls createPlotFrame(chartFrame) which:
       - Creates a child frame named "$parentPlotFrame" with
         BackdropTemplate.
       - Anchors it to fill the entire chart frame via SetAllPoints().
       - Stores it as chartFrame.plotFrame.
       The plotFrame is the actual area where lines are drawn. When axes
       are created later, the plotFrame is resized to leave room for
       axis labels.

    9. Return: returns the completed df_chartmulti object.


=====================================================================
4) ValueMixin (from mixins.lua)
=====================================================================

Purpose
    Provides min/max value tracking. The chart uses these values to
    determine the vertical scale: minValue is the bottom of the chart
    area and maxValue is the top.

Methods

    ValueConstructor()
        Initializes minValue and maxValue by calling ResetMinMaxValues().

    SetMinMaxValues(minValue, maxValue)
        Set both min and max values at once.
        Example: chart:SetMinMaxValues(0, 10000)

    GetMinMaxValues()
        Returns minValue, maxValue.
        Example: local min, max = chart:GetMinMaxValues()

    ResetMinMaxValues()
        Resets to minValue = 0, maxValue = 1.

    GetMinValue()
        Returns the current minValue.

    GetMaxValue()
        Returns the current maxValue.

    SetMinValue(minValue)
        Set the minimum value directly.

    SetMaxValue(maxValue)
        Set the maximum value directly.

    SetMinValueIfLower(...)
        Updates minValue only if any of the passed numbers is lower than
        the current minValue. Uses math.min.
        Example: chart:SetMinValueIfLower(dataMin)

    SetMaxValueIfBigger(...)
        Updates maxValue only if any of the passed numbers is bigger than
        the current maxValue. Uses math.max.
        Example: chart:SetMaxValueIfBigger(dataMax)


=====================================================================
5) MultiChartFrameMixin
=====================================================================

Purpose
    Manages the collection of chart sub-frames (one per data line),
    handles data addition, coordinates the final Plot() call, and
    provides reset/cleanup.

Constructor: MultiChartFrameConstructor()
.....................................................................
    Called during CreateGraphicMultiLineFrame. Initializes:
        .nextChartselframe       = 1
        .biggestDataValue        = 0
        .lineThickness           = 2
        .nextChartFrame          = 1
        .chartFrames             = {}      (array of df_chart sub-frames)
        .lineNameIndicators      = {}      (legend labels at top-right)
        .amountOfBackgroundProcess = 0

    Then calls chartFrameSharedConstructor(self) to set shared defaults
    (see section 6).

Methods

    IsMultiChart()
        Returns true. Distinguishes multi-chart from single chart.

    AddData(data, smoothingMethod, smoothnessLevel, name, red, green, blue, alpha)
    .....................................................................
    Purpose
        Add a data line to the chart. Each call creates (or reuses) an
        internal df_chart sub-frame and assigns data to it.

    Parameters
        data             (table, required)
            Array of numeric values. Each entry is one data point.
            Example: {1, 5, 12, 8, 3, 15, 22, 18}

        smoothingMethod  (string or nil)
            The smoothing algorithm to apply. Default: "sma".
            Accepted values:
            - "sma"   — Simple Moving Average
            - "loess" — Local Regression (LOESS)

        smoothnessLevel  (number or nil)
            Controls how much smoothing is applied. Default: 3.
            Higher values = smoother line (but less detail).

        name             (string or nil)
            Display name shown in the legend at the top-right corner.
            If not provided or empty string, no legend entry is shown.

        red, green, blue, alpha (color values or nil)
            Line color. The red parameter also accepts color name
            strings ("red", "lime"), tables ({1, 0, 0, 1}), or HTML
            hex strings ("#FF0000"). Defaults to white (1, 1, 1, 1).

    Behavior
        1. Calls GetChart() to get or create a df_chart sub-frame.
        2. Sets the line color via chartFrame:SetColor().
        3. Stores the chart name in chartFrame.chartName.
        4. Calls chartFrame:SetData(data, payload) which starts a
           background smoothing process. The data is not immediately
           plotted — Plot() must be called after all lines are added.

    Example
        chart:AddData({1, 5, 12, 8}, "sma", 3, "Player 1", "lime")
        chart:AddData({3, 7, 4, 10}, "loess", 50, "Player 2", "red")
        chart:Plot()


    GetChart()
    .....................................................................
        Returns the next available df_chart sub-frame. Creates a new one
        if needed. Internally increments nextChartFrame.
        Newly created sub-frames are anchored to fill the entire chart
        via SetAllPoints().

    GetCharts()
        Returns the chartFrames array (all df_chart sub-frames).

    GetAmountCharts()
        Returns the number of chart sub-frames currently in use
        (nextChartFrame - 1).

    HideCharts()
        Hides all df_chart sub-frames.

    Reset()
    .....................................................................
    Purpose
        Prepare the chart for new data. Call this before adding new
        lines if you want to discard previous data.

    Behavior
        1. Hides all chart sub-frames.
        2. Resets min/max values to defaults.
        3. Resets all backdrop indicators.
        4. Resets nextChartFrame to 1 and biggestDataValue to 0.

    Example
        chart:Reset()
        chart:AddData(newData1, "sma", 2, "Line 1", "white")
        chart:Plot()


    SetChartsMinMaxValues(minValue, maxValue)
        Sets the min/max values on all existing df_chart sub-frames.
        Used when you want all lines to share the same vertical scale.

    SetMaxDataSize(dataSize)
        Updates biggestDataValue if dataSize is larger than the current
        value. Used internally by Plot() to determine line width.

    GetMaxDataSize()
        Returns biggestDataValue — the size of the largest dataset.

    SetLineThickness(value)
        Sets the line thickness for drawing. Applied to all lines
        during Plot(). Default: 2.
        Example: chart:SetLineThickness(3)

    UpdateChartNamesIndicator()
    .....................................................................
    Purpose
        Updates the legend labels at the top-right corner of the chart.
        Each label shows a color swatch and the line name.

    Behavior
        Iterates all chart sub-frames in reverse order. For each one
        with a non-empty chartName, creates (or reuses) an indicator
        frame containing a color texture and a FontString. Indicators
        are anchored right-to-left starting from the top-right corner
        of the chart frame.

    Called automatically by Plot().


    WaitForBackgroundProcess()
    .....................................................................
    Purpose
        Starts a 0.1-second ticker that polls HasBackgroundProcess().
        When all background smoothing is finished, calls Plot()
        automatically. This is called internally by Plot() when it
        detects that smoothing is still in progress.


    Plot()
    .....................................................................
    Purpose
        Draws all data lines. This is the final call after adding data.

    Behavior
        1. If a background smoothing process is still running, starts
           the WaitForBackgroundProcess ticker and returns early.
        2. Iterates all chart sub-frames and collects min/max/average
           values.
        3. Calculates eachLineWidth = plotAreaWidth / maxDataSize.
        4. For each chart sub-frame:
           a. Synchronizes offsets from the parent.
           b. Sets line thickness and fixed line width.
           c. Assigns depth order based on average (highest average
              draws behind lower ones for better visual layering).
           d. Computes yPointScale = chartFrame.maxValue / multiChartMaxValue
              to normalize the vertical position of labels.
           e. Calls chartFrame:Plot(yPointScale, false, lineIndex).
        5. Shows backdrop indicators.
        6. Updates axis label values.
        7. Updates chart name legend indicators.

    Example
        chart:Plot()

    Important
        Plot() should only be called after all AddData() calls are
        complete. If smoothing is enabled (the default), Plot() will
        automatically wait for the background smoothing to finish
        before drawing.


=====================================================================
6) Shared constructor defaults (chartFrameSharedConstructor)
=====================================================================

Purpose
    Called internally by MultiChartFrameConstructor. Sets default values
    for fields used by ChartFrameSharedMixin methods (documented in
    Part 2).

Fields initialized:
    .xAxisDataType       = "number"  -- axis label format
    .lineThickness       = 2         -- default line width in pixels
    .xAxisDataNumber     = 0         -- time/number data for x-axis
    .xAxisDataValues     = {}        -- value-type x-axis labels
    .xAxisLabels         = {}        -- horizontal axis label fontstrings
    .yAxisLabels         = {}        -- vertical axis label fontstrings
    .chartLeftOffset     = 0         -- px offset for axis label space
    .chartBottomOffset   = 0         -- px offset for axis label space
    .xAxisLabelsYOffset  = -6        -- y offset for x-axis labels
    .smoothnessLevel     = 0         -- default smoothing (none)
    .backdropIndicators  = {}        -- time-range highlight indicators
    .nextBackdropIndicator = 1       -- next available indicator index


=====================================================================
7) The plot frame (createPlotFrame)
=====================================================================

Purpose
    Creates the child frame where all chart lines are actually drawn.

What it creates
    - A child frame named "$parentPlotFrame" with BackdropTemplate.
    - Anchored via SetAllPoints() to fill the entire chart frame.
    - Stored as chartFrame.plotFrame.

Why it exists
    The plotFrame provides a separate coordinate space for line drawing.
    When axes are created via CreateAxesLines (Part 2), the plotFrame is
    resized and repositioned to make room for axis labels on the left
    and bottom. This means lines are always drawn within the correct
    area regardless of whether axes are enabled or not.


=====================================================================
8) Usage examples
=====================================================================

Minimal chart (single line):
    local chart = DF:CreateGraphicMultiLineFrame(UIParent, "MyChart")
    chart:SetPoint("CENTER")
    chart:SetSize(800, 600)

    local data = {1, 5, 12, 8, 3, 15, 22, 18, 10, 5}
    chart:AddData(data, "sma", 3, "DPS", 1, 1, 1, 1)
    chart:Plot()

Multi-line chart with colors and legend:
    local chart = DF:CreateGraphicMultiLineFrame(UIParent, "RaidChart")
    chart:SetPoint("CENTER")
    chart:SetSize(800, 600)

    chart:Reset()  -- clear any previous data
    chart:AddData(dpsData,     "sma",  2, "DPS",     "lime")
    chart:AddData(healingData, "sma",  2, "Healing",  "purple")
    chart:AddData(damageData,  "loess", 50, "Damage", "orange")
    chart:Plot()

Chart with axes and time labels:
    local chart = DF:CreateGraphicMultiLineFrame(UIParent, "TimeChart")
    chart:SetPoint("CENTER")
    chart:SetSize(800, 600)

    chart:CreateAxesLines(48, 28, "left", 1, 10, 10, 1, 1, 1, 1)
    chart:SetXAxisDataType("time")
    chart:SetXAxisData(300) -- 5 minutes

    chart:AddData(myData, "sma", 3, "Player DPS", "white")
    chart:Plot()

Adjusting line thickness:
    chart:SetLineThickness(3)
    chart:Plot()

Using height scale for Plot:
    -- When using a single df_chart sub-frame directly:
    chartFrame:Plot(1.2)  -- 1.2x vertical scale


=====================================================================
End of Part 1
=====================================================================


=====================================================================
Part 2: ChartFrameSharedMixin methods and smoothing algorithms
=====================================================================

The ChartFrameSharedMixin is mixed into both df_chartmulti and df_chart.
It provides shared utilities for:
- Fill control (drawing filled areas under chart lines)
- Data shrinking (reducing data set size)
- Background process tracking (async smoothing awareness)
- Axis creation, styling, and label management
- Backdrop indicators (highlighting time ranges on the chart)


=====================================================================
9) SetFillChart
=====================================================================

Signature
    chart:SetFillChart(bFill, lineThickness)

Purpose
    Enables or disables fill mode. When fill is enabled, an extra line
    is drawn at the bottom of each chart line to close the area,
    creating a filled polygon effect under the line.

Parameters
    bFill          (boolean, required)
        true to enable fill, false to disable.

    lineThickness  (number or nil)
        Thickness of the fill line at the bottom. Default: 1.

Behavior
    Sets self.bFillChart and self.fillChartLineThickness. These values
    are read during Plot() to decide whether to draw fill lines.

Example
    chart:SetFillChart(true, 2)
    chart:Plot()


=====================================================================
10) GetFillState
=====================================================================

Signature
    chart:GetFillState()

Returns
    bFillChart         (boolean) — whether fill is enabled.
    fillLineThickness  (number) — the fill line thickness.

Example
    local isFilled, thickness = chart:GetFillState()


=====================================================================
11) ShrinkData
=====================================================================

Signature
    chart:ShrinkData(data, shrinkBy, bJustDrop)

Purpose
    Reduces the number of data points in a table. Useful when the
    original data is too dense for the chart width or when you want to
    reduce rendering cost.

Parameters
    data       (table, required)
        An array of numeric values to shrink.

    shrinkBy   (number, required)
        Controls how many data points get collapsed into one. For
        example, shrinkBy = 3 means every 3 consecutive values become
        a single value.

    bJustDrop  (boolean or nil)
        - false or nil (default): averages each group of `shrinkBy`
          values into one data point. This preserves the general shape.
        - true: drops values by stepping through the array every
          `shrinkBy` entries, keeping only every Nth value.

Returns
    A new table with the reduced data.

Example
    local denseData = {1, 2, 3, 4, 5, 6, 7, 8, 9}
    local averaged = chart:ShrinkData(denseData, 3, false)
    -- averaged = {2, 5, 8}  (averages of groups of 3)

    local dropped = chart:ShrinkData(denseData, 3, true)
    -- dropped = {1, 4, 7}   (every 3rd value kept)


=====================================================================
12) HasBackgroundProcess
=====================================================================

Signature
    chart:HasBackgroundProcess()

Returns
    boolean — true if an async background process (smoothing) is
    still running.

Why it matters
    When AddData() is called with a smoothing method, the data is
    processed asynchronously via a lazy ticker that runs over multiple
    frames (to avoid freezing the UI). Plot() checks this function and
    if it returns true, it defers drawing until all smoothing finishes.


=====================================================================
13) SetBackgroundProcessState
=====================================================================

Signature
    chart:SetBackgroundProcessState(bRunning)

Purpose
    Tracks the number of active background processes. When bRunning is
    true, the internal counter (amountOfBackgroundProcess) increments.
    When false, it decrements. The chart is considered "busy" whenever
    the counter is above zero.

Parameters
    bRunning  (boolean, required)
        true when a new background process starts, false when one ends.

Behavior
    - true: amountOfBackgroundProcess += 1, bRunningInBackground = true.
    - false: amountOfBackgroundProcess -= 1. When counter reaches 0,
      bRunningInBackground = false.

This is called internally by the smoothing functions (calcSMA,
calcLOESS). Users do not normally call this directly.


=====================================================================
14) SetAxesColor
=====================================================================

Signature
    chart:SetAxesColor(red, green, blue, alpha)

Purpose
    Sets the color of both axis lines (yAxisLine and xAxisLine) and
    all their associated labels (yAxisLabels and xAxisLabels).

Parameters
    red    (number, string, table, or nil)
        Accepts the same flexible color formats as DF:ParseColors:
        a number (0-1), a color name string ("red"), a table
        ({r, g, b, a}), or a hex string ("#FF0000").

    green, blue, alpha  (number or nil)
        Standard color components when red is a number.

Returns
    boolean — true if the color was set, false if the axis lines have
    not been created yet (CreateAxesLines was not called).

Example
    chart:SetAxesColor(0.8, 0.8, 0.8, 1)   -- light gray
    chart:SetAxesColor("white")              -- named color


=====================================================================
15) SetAxesThickness
=====================================================================

Signature
    chart:SetAxesThickness(thickness)

Purpose
    Sets the thickness (in pixels) of both axis lines.

Parameters
    thickness  (number, required)

Returns
    boolean — true if the thickness was set, false if the axis lines
    have not been created yet.

Example
    chart:SetAxesThickness(2)


=====================================================================
16) CreateAxesLines
=====================================================================

Signature
    chart:CreateAxesLines(xOffset, yOffset, whichSide, thickness,
                          amountYLabels, amountXLabels,
                          red, green, blue, alpha)

Purpose
    Creates the vertical and horizontal axis lines along with their
    label fontstrings. This reshapes the plotFrame to leave room for
    labels on the left/right and bottom.

Parameters
    xOffset        (number, default 48)
        Pixels from the left edge of the chart frame to the axis line.
        This space is reserved for y-axis labels.

    yOffset        (number, default 28)
        Pixels from the bottom edge of the chart frame to the axis
        line. This space is reserved for x-axis labels.

    whichSide      (string: "left" or "right", default "left")
        Which side the vertical axis line is placed on.

    thickness      (number, default 1)
        Line thickness in pixels for both axis lines.

    amountYLabels  (number, default 10)
        How many labels to create along the vertical axis.

    amountXLabels  (number, default 10)
        How many labels to create along the horizontal axis.

    red, green, blue, alpha  (color, defaults to 1,1,1,1)
        Color applied to both axis lines and their labels.

Returns
    boolean — true on success, false if axes were already created
    (axes can only be created once per chart).

Behavior
    1. Sets chartLeftOffset and chartBottomOffset.
    2. Resizes and re-anchors the plotFrame to leave room for labels:
       width = chartWidth - xOffset - 10
       height = chartHeight - yOffset - 20
    3. Creates yAxisLine (vertical) anchored on whichSide.
    4. Creates xAxisLine (horizontal) anchored at bottom.
    5. Applies color and thickness via SetAxesColor/SetAxesThickness.
    6. Generates amountYLabels vertical labels with guide lines and
       circle textures.
    7. Generates amountXLabels horizontal labels.
    8. Sets axisCreated = true (prevents double-creation).

Example
    chart:CreateAxesLines(48, 28, "left", 1, 10, 10, 1, 1, 1, 1)

Why it matters
    Without calling CreateAxesLines, the chart has no visual scale
    reference. The axes give context to the plotted data by showing
    value ranges on the y-axis and time/number/value labels on the
    x-axis.


=====================================================================
17) SetXAxisDataType
=====================================================================

Signature
    chart:SetXAxisDataType(dataType)

Purpose
    Sets how the horizontal axis labels are formatted.

Parameters
    dataType  (string, required)
        One of three accepted values:
        - "time": labels are formatted as mm:ss timestamps.
        - "number": labels are formatted as plain numbers (using
          DF.FormatNumber for abbreviation).
        - "value": labels use the literal values passed via
          SetXAxisData().

Behavior
    - For "time" or "number": resets xAxisDataNumber to 0.
    - For "value": wipes xAxisDataValues table.

Example
    chart:SetXAxisDataType("time")
    chart:SetXAxisDataType("number")
    chart:SetXAxisDataType("value")


=====================================================================
18) SetXAxisData
=====================================================================

Signature
    chart:SetXAxisData(...)

Purpose
    Provides the data that populates the horizontal axis labels.

Behavior depends on the current xAxisDataType:

    If "time" or "number":
        Accepts a single number. The chart stores the largest value
        passed (via math.max), then distributes labels evenly from 0
        to that value.
        Example: chart:SetXAxisData(300)  -- 5 minutes for "time"

    If "value":
        Accepts a vararg list of values. Each value becomes a label.
        Example: chart:SetXAxisData("Phase 1", "Phase 2", "Phase 3")

Example (time axis — 5 minutes):
    chart:SetXAxisDataType("time")
    chart:SetXAxisData(300)
    -- Labels show: 0:30, 1:00, 1:30, ... 5:00

Example (number axis — 600 max):
    chart:SetXAxisDataType("number")
    chart:SetXAxisData(600)
    -- Labels show: 60, 120, 180, ... 600

Example (value axis — custom labels):
    chart:SetXAxisDataType("value")
    chart:SetXAxisData("hello", "world", 1, 2, 3, 4, "chart", 0, 1, 0)


=====================================================================
19) CreateBackdropIndicator
=====================================================================

Signature
    chart:CreateBackdropIndicator(nextIndicatorIndex)

Purpose
    Creates a new backdrop indicator frame. Backdrop indicators are
    colored rectangles drawn behind the chart lines to highlight a
    specific time range (e.g., a boss ability window or a cooldown).

Parameters
    nextIndicatorIndex  (number, required)
        The index used for naming and tracking the indicator.

Returns
    chart_backdropindicator — a frame with these sub-elements:
        .fieldTexture      — texture spanning the full indicator area.
        .fieldLabel        — fontstring at top-left of fieldTexture
                             showing the indicator name (small, 0.3 alpha).
        .indicatorTexture  — 10x10 color square for the legend entry
                             at the top-right of the chart.
        .indicatorLabel    — fontstring next to indicatorTexture
                             showing the indicator name in the legend.

The indicator frame is set one frame level below the plotFrame so
that chart lines are drawn on top.

This is called internally by GetBackdropIndicator. Users should use
AddBackdropIndicator() instead.


=====================================================================
20) GetBackdropIndicator
=====================================================================

Signature
    chart:GetBackdropIndicator()

Purpose
    Returns the next available backdrop indicator. Creates a new one
    if needed. Internally increments nextBackdropIndicator.

Returns
    chart_backdropindicator

This is called internally by AddBackdropIndicator.


=====================================================================
21) ResetBackdropIndicators
=====================================================================

Signature
    chart:ResetBackdropIndicators()

Purpose
    Hides all existing backdrop indicators and resets the
    nextBackdropIndicator counter to 1. Called automatically by
    Reset().

Behavior
    For each indicator in self.backdropIndicators:
    - Calls indicator:Hide()
    - Sets indicator.bInUse = false
    Sets self.nextBackdropIndicator = 1.


=====================================================================
22) AddBackdropIndicator
=====================================================================

Signature
    chart:AddBackdropIndicator(label, timeStart, timeEnd, red, green, blue, alpha)

Purpose
    The user-facing function for adding a backdrop indicator. It
    validates inputs, creates/reuses an indicator, and stores the
    time range and color for later rendering by ShowBackdropIndicators.

Parameters
    label      (string, required)
        Text displayed on the indicator and in the legend. Example:
        "Bloodlust", "Enrage", "Shadow Crash".

    timeStart  (number, required)
        The start position along the x-axis (in the same units as
        the x-axis data — seconds for "time", raw number otherwise).

    timeEnd    (number, required)
        The end position along the x-axis.

    red, green, blue, alpha  (color, optional)
        Color for the indicator rectangle and legend swatch. Parsed
        via DF:ParseColors, so accepts color names, tables, etc.

Returns
    true on success.

Example
    chart:AddBackdropIndicator("Bloodlust", 30, 70, 1, 0.8, 0, 0.5)
    chart:AddBackdropIndicator("Enrage", 120, 180, "red")

Important
    Indicators are not drawn until Plot() calls ShowBackdropIndicators
    internally. You must call Plot() after adding indicators.


=====================================================================
23) ShowBackdropIndicators
=====================================================================

Signature
    chart:ShowBackdropIndicators()

Purpose
    Called internally by Plot(). Iterates all in-use backdrop indicators
    and positions, colors, and shows them.

Behavior
    1. Reads xAxisDataType and xAxisDataNumber to determine the full
       data range.
    2. For each in-use indicator:
       a. Calculates pixel positions:
          startX = (startTime / dataSize) * plotFrameWidth
          endX = (endTime / dataSize) * plotFrameWidth
       b. Anchors the indicator from topleft to bottomright of the
          plotFrame.
       c. Sets the fieldTexture color and fieldLabel text.
       d. Sets the indicatorTexture color and indicatorLabel text.
       e. Positions the legend indicator (top-right, chained right to
          left for multiple indicators).
       f. Shows the indicator.

Why it matters
    Backdrop indicators provide visual context for time ranges during
    which a specific event was active (raid cooldowns, boss abilities,
    phase transitions). They help users correlate data spikes with
    game events.


=====================================================================
24) Smoothing: LOESS (Local Regression)
=====================================================================

Purpose
    LOESS (LOcally Estimated Scatterplot Smoothing) is a smoothing
    algorithm that fits a weighted linear regression to a local
    neighborhood around each data point. It produces a smooth curve
    that follows the general trend while removing noise.

How it works (as implemented in charts.lua):
    For each data point at index i in the dataset:

    1. Define a neighborhood: collect all points within a window of
       ±halfSpan around i (clamped to data boundaries).

    2. Calculate distance weights: for each neighbor point, compute
       a weight using a tricube function:
           weight = (1 - (distance / (halfSpan + 1))^3)^3
       Points closer to i get higher weights, distant points get
       lower weights, producing a smooth falloff.

    3. Fit a weighted linear regression: using the weighted points,
       solve for intercept and slope:
           denominator = sum_w * sum_wxx - sum_wx^2
           intercept = (sum_wy * sum_wxx - sum_wx * sum_wxy) / denominator
           slope = (sum_w * sum_wxy - sum_wx * sum_wy) / denominator

    4. Predict: the smoothed value at index i is:
           result[i] = max(0, intercept + slope * i)
       Values are clamped to a minimum of 0.

    5. Repeat for every data point.

Asynchronous execution
    Because LOESS can be expensive on large datasets, it runs as a
    background lazy process via DF.Schedules.LazyExecute. It processes
    100 data points per frame, so it does not freeze the UI. While
    running, the chart's background process state is set to true.
    When complete:
    - The raw smoothed result is stored via chartFrame:SetDataRaw().
    - The average is computed (sumTotal / dataSize).
    - Min/max values are updated.
    - Lines are hidden (ready for re-plot).
    - Background process state is set to false.

When to use LOESS
    Use LOESS when you want a very smooth curve that closely follows
    local trends. It is more computation-heavy than SMA but produces
    better results for noisy data or data with non-linear trends.

    In AddData, specify smoothingMethod = "loess" and pass the span
    (window size) as the smoothnessLevel parameter. Higher span values
    mean more smoothing.

Example
    chart:AddData(data, "loess", 50, "Player DPS", "lime")


=====================================================================
25) Smoothing: SMA (Simple Moving Average)
=====================================================================

Purpose
    Simple Moving Average (SMA) is a smoothing algorithm that replaces
    each data point with the average of the surrounding N values
    (where N = averageSize). It is a straightforward, fast algorithm
    that smooths out short-term fluctuations.

How it works (as implemented in charts.lua):
    Given a data array and an averageSize (window):

    1. Optionally pad the start: if bAddZeroPadding is true, insert
       (averageSize - 1) zeros at the beginning of the data to
       preserve the original data length in the output.

    2. Iterate through each data point at index i:
       a. Add data[i] to a running sum.
       b. When i >= averageSize:
          - If i > averageSize, subtract the value that just left the
            window: sum = sum - data[i - averageSize]
          - Append max(0, sum / averageSize) to the result.
       Values are clamped to a minimum of 0.

    3. Cleanup: if zero padding was added, remove the inserted zeros
       from the original data to restore it.

Asynchronous execution
    Like LOESS, SMA runs as a background lazy process via
    DF.Schedules.LazyExecute. It processes 300 data points per frame
    (faster than LOESS since the math is simpler). The same lifecycle
    applies:
    - Sets background process state to true on start.
    - On completion: stores smoothed result via SetDataRaw(), computes
      average, updates min/max, hides lines, clears background state.

When to use SMA
    Use SMA for quick, lightweight smoothing. It is much faster than
    LOESS and works well when the data trend is roughly linear or when
    you just need to remove high-frequency noise. The smoothnessLevel
    in AddData controls the window size: higher values = smoother but
    less responsive to rapid changes.

    In AddData, specify smoothingMethod = "sma" (or omit it, since
    "sma" is the default) and pass the window size as smoothnessLevel.

Example
    chart:AddData(data, "sma", 3, "Player DPS", "white")
    -- or equivalently, since "sma" is the default:
    chart:AddData(data, nil, 3, "Player DPS", "white")


=====================================================================
End of Part 2
=====================================================================


=====================================================================
Part 3: createChartFrame, ChartFrameMixin (df_chart), and field reference
=====================================================================


=====================================================================
26) createChartFrame — internal sub-frame factory
=====================================================================

Signature (local, not public)
    createChartFrame(parent, name)

Purpose
    Creates a single df_chart sub-frame. This is the internal factory
    used by MultiChartFrameMixin:GetChart() whenever a new data line
    is needed. Users do not call this directly — it is invoked
    automatically when AddData() requires a new chart sub-frame.

Parameters
    parent  (frame, required)
        The parent frame, typically the df_chartmulti itself.

    name    (string or nil)
        Global name for the Blizzard frame.

Returns
    df_chart — the initialized chart sub-frame.

Construction sequence
    1. Creates the underlying Blizzard frame with BackdropTemplate.

    2. Mixes in four mixins:
       a. DataMixin — data storage, callbacks, iteration (from mixins.lua)
       b. ValueMixin — min/max value tracking (from mixins.lua)
       c. ChartFrameMixin — line management, color, Plot (see section 27)
       d. ChartFrameSharedMixin — axes, indicators, fill (Part 2)

    3. Calls constructors:
       a. DataConstructor() — initializes _dataInfo with empty data
          table, dataCurrentIndex = 1, and callbacks table.
       b. ValueConstructor() — sets minValue = 0, maxValue = 1.
       c. ChartFrameConstructor() — see section 27.

    4. Registers an onSetDataCallback via AddDataChangeCallback. This
       callback fires whenever SetData() is called on the sub-frame.
       It reads the smoothing parameters from the payload and routes
       to the appropriate algorithm:
       - "loess" → calcLOESS (async background process)
       - "sma" → calcSMA (async background process)
       - "smaz" → calcSMA with zero padding enabled
       - anything else (or empty) → stores data directly via
         SetDataRaw, computes min/max, and hides lines.

    5. Calls createPlotFrame() — creates the child plotFrame.

    6. Returns the completed df_chart.

Why it matters
    Each data line in a multi-chart gets its own independent df_chart
    sub-frame with its own data, color, lines, min/max, and plot frame.
    The onSetDataCallback is the bridge between AddData() and the
    smoothing system: when the multi-chart calls chartFrame:SetData(),
    the callback fires and kicks off async smoothing.


=====================================================================
27) ChartFrameMixin (df_chart methods)
=====================================================================

Purpose
    Provides all methods for a single chart sub-frame: line management,
    color control, sizing, data point hover callbacks, and the single-
    chart Plot() function.

Constructor: ChartFrameConstructor()
.....................................................................
    Called during createChartFrame. Initializes:
        .nextLine                = 1
        .minValue                = 0
        .maxValue                = 1
        .lineThickness           = 2
        .data                    = {}
        .lines                   = {}       (array of df_chartline)
        .color                   = {1, 1, 1, 1}  (white)
        .amountOfBackgroundProcess = 0

    Registers an OnSizeChanged script handler.
    Calls chartFrameSharedConstructor(self) for shared defaults.

Methods

    IsMultiChart()
        Returns false. Distinguishes single chart from multi-chart.

    GetColor()
    .....................................................................
        Returns red, green, blue, alpha from the chart's color table.

    SetColor(r, g, b, a)
    .....................................................................
        Sets the line color. Accepts flexible color formats via
        DF:ParseColors (number, name string, table, hex).
        Example: chartFrame:SetColor(1, 0, 0, 1)
                 chartFrame:SetColor("red")

    GetLine()
    .....................................................................
        Returns the next available df_chartline texture. Creates a new
        line in the plotFrame if needed. Increments nextLine.
        Lines are created at draw layer "overlay" with sub-level 5.

    GetLines()
        Returns the full lines array (all created line textures).

    GetAmountLines()
        Returns the number of lines in use (nextLine - 1).

    HideLines()
        Hides all line textures.

    Reset()
    .....................................................................
        Resets the single chart sub-frame:
        1. Hides all lines.
        2. Resets min/max values.
        3. Resets nextLine to 1.
        4. Resets xAxisDataNumber to 0.
        5. Resets backdrop indicators.

    SetLineThickness(value)
        Sets lineThickness for this chart sub-frame.

    GetLineWidth()
    .....................................................................
        Returns the width (in pixels) of each line segment.
        If fixedLineWidth is set, returns that value.
        Otherwise calculates: plotFrame:GetWidth() / dataSize.

    SetLineWidth(width)
        Sets a fixed line width, overriding the automatic calculation.

    CalcYAxisPointForValue(value, plotFrameHeightScaled)
    .....................................................................
        Converts a data value to a y-pixel position:
            return value / self.maxValue * plotFrameHeightScaled

    UpdateFrameSizeCache()
        Caches self.width and self.height from GetWidth/GetHeight.

    OnSizeChanged()
        Called by the frame's OnSizeChanged script. Updates the size
        cache.

    SetOnEnterFunction(onEnterFunc, ...)
    .....................................................................
        Sets a callback function for when the mouse hovers over a data
        point.
        Parameters:
            onEnterFunc  — the callback function.
            ...          — payload arguments passed to the callback.
        Stored in: dataPoint_OnEnterFunc, dataPoint_OnEnterPayload.

    SetOnLeaveFunction(onLeaveFunc, ...)
    .....................................................................
        Sets a callback function for when the mouse leaves a data point.
        Stored in: dataPoint_OnLeaveFunc, dataPoint_OnLeavePayload.

    GetOnEnterLeaveFunctions()
        Returns: onEnterFunc, onEnterPayload, onLeaveFunc, onLeavePayload.

    Plot(yPointScale, bUpdateLabels, lineId)
    .....................................................................
    Purpose
        Draws the chart lines for this single sub-frame.

    Parameters
        yPointScale    (number or nil, default 1)
            Vertical scale multiplier. Used by the multi-chart Plot()
            to normalize each sub-frame's data against the global max.

        bUpdateLabels  (boolean or nil, default true)
            Whether to update axis label values after plotting. When
            called from multi-chart Plot(), this is false (labels are
            updated once at the multi-chart level).

        lineId         (number or nil, default 1)
            Index of this line within the multi-chart, used for depth
            ordering.

    Behavior
        1. Updates frame size cache.
        2. Gets data size and first value.
        3. Calculates initial Y position via CalcYAxisPointForValue.
        4. Calculates line width via GetLineWidth().
        5. Resets data index.
        6. Launches a lazy async drawing process (50 lines per frame)
           that iterates through data points, creating line segments
           connecting consecutive (x, y) positions.
        7. If fill is enabled, draws additional fill lines.
        8. Shows backdrop indicators.
        9. If bUpdateLabels is true (or nil), updates axis label values.


=====================================================================
28) DataMixin (from mixins.lua)
=====================================================================

Purpose
    Mixed into each df_chart sub-frame. Provides a data storage layer
    with change callbacks, iteration, and min/max scanning.

Constructor: DataConstructor()
    Initializes self._dataInfo:
        .data              = {}     (the raw data array)
        .dataCurrentIndex  = 1     (for sequential iteration)
        .callbacks         = {}     (onChange callback registry)

Methods

    AddDataChangeCallback(func, ...)
        Registers a function to be called whenever SetData() is called.
        The payload (...) is stored and passed to the function.
        This is how the smoothing system hooks into data changes.

    RemoveDataChangeCallback(func)
        Unregisters a previously added callback.

    SetDataRaw(data)
        Sets the data table directly without firing callbacks.
        Resets the data index.

    SetData(data, anyValue)
        Sets the data table and fires all registered callbacks.
        Each callback receives: (data, anyValue, ...payload).
        This is what triggers the smoothing process when called from
        AddData().

    GetData()
        Returns the raw data table.

    GetDataNextValue()
        Returns the next value in sequence and its index. Advances the
        internal index. Used during Plot() to iterate data points.

    ResetDataIndex()
        Resets the iteration index to 1.

    GetDataSize()
        Returns the number of data points (#data).

    GetDataFirstValue()
        Returns data[1].

    GetDataLastValue()
        Returns data[#data].

    GetDataMinMaxValues()
        Scans the data array and returns (minValue, maxValue).
        Used after smoothing completes to set the chart's min/max.

    GetDataMinMaxValueFromSubTable(key)
        For data stored as sub-tables, scans data[i][key] and returns
        (minValue, maxValue).


=====================================================================
29) Complete field reference
=====================================================================

This section lists all fields on each class type as declared in the
source annotations. Fields documented in detail in previous sections
are listed with a brief note.

df_chartline
    .thickness      number — line thickness in pixels

df_chartshared (shared fields on both df_chart and df_chartmulti)
    .fillOrder              table — order of lines to fill
    .bFillChart             boolean — fill enabled/disabled
    .fillChartLineThickness number — fill line thickness
    .bRunningInBackground   boolean — async process active
    .waitForBackgroundProcessTicker  timer — polling ticker
    .amountOfBackgroundProcess       number — active process count
    .yAxisLine              line — vertical axis line
    .xAxisLine              line — horizontal axis line
    .xAxisDataNumber        any — numeric data for x-axis
    .xAxisDataValues        table — value-type x-axis labels
    .xAxisDataType          x_axisdatatype — "time"|"number"|"value"
    .yAxisLabels            chart_guideline[] — vertical axis labels
    .xAxisLabels            fontstring[] — horizontal axis labels
    .plotFrame              frame — child frame holding chart lines
    .lineThickness          number — line thickness in pixels
    .chartLeftOffset        number — offset for y-axis label space
    .chartBottomOffset      number — offset for x-axis label space
    .xAxisLabelsYOffset     number — y offset for x-axis labels (-6)
    .smoothnessLevel        number — default smoothing (0 = none)
    .backdropIndicators     chart_backdropindicator[] — indicators
    .nextBackdropIndicator  number — next available indicator index

df_chart (single chart sub-frame)
    ._dataInfo              df_data — DataMixin storage
    .average                number — average of all data points
    .depth                  number — draw order (set during Plot)
    .color                  number[] — {r, g, b, a}
    .height                 number — cached frame height
    .nextLine               number — next available line index
    .minValue               number — current min value
    .maxValue               number — current max value
    .data                   number[] — raw data array
    .lines                  df_chartline[] — line textures
    .fixedLineWidth         number — overrides auto line width
    .chartName              string — name shown in legend

    Callback fields:
    .dataPoint_OnEnterFunc     function — hover enter callback
    .dataPoint_OnEnterPayload  any[] — enter callback payload
    .dataPoint_OnLeaveFunc     function — hover leave callback
    .dataPoint_OnLeavePayload  any[] — leave callback payload

df_chartmulti (multi-chart frame — inherits df_chart + df_chartshared)
    .chartFrames            df_chart[] — array of sub-frames
    .nextChartselframe      number — internal selection counter
    .biggestDataValue       number — largest dataset size
    .nextChartFrame         number — next sub-frame index
    .lineNameIndicators     chart_nameindicator[] — legend entries

chart_guideline (y-axis label)
    .circleTexture          texture — small circle at axis line
    .guideLine              line — horizontal guide line

chart_nameindicator (legend entry at top-right)
    .Texture                texture — color swatch (12x12)
    .Label                  fontstring — chart name text

chart_backdropindicator (time range highlight)
    .fieldTexture           texture — spans the full indicator area
    .fieldLabel             fontstring — name at top-left of area
    .indicatorTexture       texture — 10x10 legend color square
    .indicatorLabel         fontstring — name next to legend square
    .bInUse                 boolean — whether indicator is active
    .startTime              number — start position on x-axis
    .endTime                number — end position on x-axis
    .labelText              string — display text
    .color                  color — {r, g, b, a}

x_axisdatatype (string enum)
    "time"   — labels formatted as mm:ss
    "number" — labels formatted as plain numbers
    "value"  — labels use literal values from SetXAxisData()


=====================================================================
End of Part 3
=====================================================================
