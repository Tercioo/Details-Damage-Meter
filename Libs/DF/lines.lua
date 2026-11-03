
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _

--lines drawn between two points or two frames: a straight line, a hanging rope and a rope with physics, each solid or dashed
--every shape is a path of points drawn with one blizzard line region per straight piece

---@alias df_linetype
---| "line" straight line between the two ends
---| "rope" rope hanging between the two ends, the shape is calculated once each time an end moves
---| "physics" rope simulated with gravity, it swings and settles when an end moves

---@class df_line_options : table
---@field line_type df_linetype
---@field thickness number
---@field color number[] an {r, g, b, a}
---@field texture string|number texture drawn along each piece, it is tinted by color
---@field draw_layer drawlayer
---@field sub_level number
---@field dash_length number length of each dash in pixels, 0 draws a solid line
---@field gap_length number empty space between two dashes in pixels, 0 draws a solid line
---@field segments number rope only: amount of straight pieces the curve is drawn with
---@field slack number rope and physics: rope length as a multiple of the distance between the two ends, used when rope_length is 0
---@field extra_length number rope and physics: pixels added to the slack length, with slack at 1 a near and a far rope hang by a similar amount
---@field rope_length number rope and physics: fixed rope length in pixels, 0 uses slack and extra_length instead
---@field simulation_points number physics only: amount of points simulated along the rope
---@field smoothing number physics only: amount of pieces drawn between two simulated points
---@field gravity number physics only: pixels per second squared, negative pulls down
---@field damping number physics only: fraction of the velocity kept on each step, lower settles faster
---@field stiffness number physics only: amount of passes to keep the rope length on each step, lower makes the rope stretchy
---@field impulse_variation number physics only: 0 to 1, how different each push from ApplyImpulse() is, 0 makes every push swing the same
---@field auto_update boolean follow anchored frames every frame, when false call Refresh() after they move (physics always updates)

---@type df_line_options
local defaultLineOptions = {
	line_type = "line",
	thickness = 2,
	color = {1, 1, 1, 1},
	texture = [[Interface\Buttons\WHITE8X8]],
	draw_layer = "overlay",
	sub_level = 0,
	dash_length = 0,
	gap_length = 0,
	segments = 24,
	slack = 1.25,
	extra_length = 0,
	rope_length = 0,
	simulation_points = 16,
	smoothing = 3,
	gravity = -1200,
	damping = 0.98,
	stiffness = 20,
	impulse_variation = 0,
	auto_update = true,
}

--constants
--where each anchor point sits inside a frame, as a fraction of its width and height from the bottom left corner
local POINT_FRACTIONS = {
	topleft = {0, 1},
	top = {0.5, 1},
	topright = {1, 1},
	left = {0, 0.5},
	center = {0.5, 0.5},
	right = {1, 0.5},
	bottomleft = {0, 0},
	bottom = {0.5, 0},
	bottomright = {1, 0},
}

local LINE_TYPES = {
	line = true,
	rope = true,
	physics = true,
}

---@class df_line_anchor : table
---@field isSet boolean
---@field frame uiobject? when nil the end is a fixed position
---@field point string
---@field offsetX number
---@field offsetY number
---@field x number fixed position, in pixels from the bottom left corner of the line frame
---@field y number

---@class df_line : frame, df_linemixin, df_optionsmixin
---@field options df_line_options
---@field startAnchor df_line_anchor
---@field endAnchor df_line_anchor
---@field Segments line[] every line region created, reused between redraws
---@field amountOfSegmentsShown number
---@field pathX number[] points of the path being drawn, reused between redraws
---@field pathY number[]
---@field pathSize number
---@field drawnStartX number? positions of the two ends on the last redraw
---@field drawnStartY number?
---@field drawnEndX number?
---@field drawnEndY number?
---@field Rope df_physicsrope? created the first time the line type is set to physics
---@field needsRopeReset boolean

---@class df_linemixin : table
---@field SetStartAnchor fun(self:df_line, frame:uiobject, point:string?, offsetX:number?, offsetY:number?) attach the start of the line to a point of a frame
---@field SetEndAnchor fun(self:df_line, frame:uiobject, point:string?, offsetX:number?, offsetY:number?) attach the end of the line to a point of a frame
---@field SetStartPosition fun(self:df_line, x:number, y:number) place the start of the line at a fixed position, in pixels from the bottom left corner of the line frame
---@field SetEndPosition fun(self:df_line, x:number, y:number) place the end of the line at a fixed position, in pixels from the bottom left corner of the line frame
---@field SetLineType fun(self:df_line, lineType:df_linetype)
---@field GetLineType fun(self:df_line) : df_linetype
---@field SetThickness fun(self:df_line, thickness:number)
---@field SetColor fun(self:df_line, red:any, green:number?, blue:number?, alpha:number?) accepts any color format the framework parses
---@field SetTexture fun(self:df_line, texture:string|number)
---@field SetLineDrawLayer fun(self:df_line, drawLayer:drawlayer, subLevel:number?)
---@field SetDashes fun(self:df_line, dashLength:number, gapLength:number) 0 for either draws a solid line
---@field SetSegments fun(self:df_line, segments:number)
---@field SetSlack fun(self:df_line, slack:number)
---@field SetExtraLength fun(self:df_line, extraLength:number)
---@field SetRopeLength fun(self:df_line, ropeLength:number) 0 uses the slack and extra length instead
---@field SetSimulationPoints fun(self:df_line, amountOfPoints:number)
---@field SetSmoothing fun(self:df_line, smoothing:number)
---@field SetGravity fun(self:df_line, gravity:number)
---@field SetDamping fun(self:df_line, damping:number)
---@field SetStiffness fun(self:df_line, stiffness:number)
---@field SetImpulseVariation fun(self:df_line, variation:number) 0 to 1, how different each push from ApplyImpulse() is
---@field SetAutoUpdate fun(self:df_line, isEnabled:boolean)
---@field ApplyImpulse fun(self:df_line, impulseX:number, impulseY:number, variation:number?) physics only: push the rope, in pixels per step, variation (0-1) defaults to the impulse_variation option
---@field Refresh fun(self:df_line) redraw the line now

---return the position of a line end, in pixels from the bottom left corner of the line frame
---return nil when the end is not set or its frame has no position yet
---@param lineFrame df_line
---@param anchor df_line_anchor
---@return number?, number?
local resolveAnchor = function(lineFrame, anchor)
	if (not anchor.isSet) then
		return
	end

	local anchorFrame = anchor.frame
	if (not anchorFrame) then
		return anchor.x, anchor.y
	end

	--a frame without points, or one that was never laid out, has no rect yet
	local left, bottom, width, height = anchorFrame:GetRect()
	local lineLeft, lineBottom = lineFrame:GetRect()
	if (not left or not lineLeft) then
		return
	end

	--the anchor frame and the line frame can have different scales, bring the point into the line frame scale
	local scale = anchorFrame:GetEffectiveScale() / lineFrame:GetEffectiveScale()
	local pointFraction = POINT_FRACTIONS[anchor.point]
	local x = (left + width * pointFraction[1] + anchor.offsetX) * scale - lineLeft
	local y = (bottom + height * pointFraction[2] + anchor.offsetY) * scale - lineBottom
	return x, y
end

---return the rope length for the current distance between the two ends
---@param lineFrame df_line
---@param distance number
---@return number
local getRopeLength = function(lineFrame, distance)
	local options = lineFrame.options
	if (options.rope_length > 0) then
		return options.rope_length
	end

	return distance * options.slack + options.extra_length
end

---apply the look of the line to one line region
---@param lineFrame df_line
---@param segment line
local applySegmentStyle = function(lineFrame, segment)
	local options = lineFrame.options
	segment:SetTexture(options.texture)
	segment:SetVertexColor(options.color[1], options.color[2], options.color[3], options.color[4])
	segment:SetThickness(options.thickness)
	segment:SetDrawLayer(options.draw_layer, options.sub_level)
end

---show the line region at index, creating it if needed, and stretch it between two points
---@param lineFrame df_line
---@param index number
---@param startX number
---@param startY number
---@param endX number
---@param endY number
local placeSegment = function(lineFrame, index, startX, startY, endX, endY)
	local segment = lineFrame.Segments[index]
	if (not segment) then
		segment = lineFrame:CreateLine(nil, lineFrame.options.draw_layer, nil, lineFrame.options.sub_level)
		applySegmentStyle(lineFrame, segment)
		lineFrame.Segments[index] = segment
	end

	segment:SetStartPoint("bottomleft", lineFrame, startX, startY)
	segment:SetEndPoint("bottomleft", lineFrame, endX, endY)
	segment:Show()
end

---hide the line regions from index fromIndex onwards
---@param lineFrame df_line
---@param fromIndex number
local hideSegments = function(lineFrame, fromIndex)
	for i = fromIndex, lineFrame.amountOfSegmentsShown do
		lineFrame.Segments[i]:Hide()
	end

	lineFrame.amountOfSegmentsShown = math.min(lineFrame.amountOfSegmentsShown, fromIndex - 1)
end

---fill pathX and pathY with the points of the line shape
---@param lineFrame df_line
---@param startX number
---@param startY number
---@param endX number
---@param endY number
local buildPath = function(lineFrame, startX, startY, endX, endY)
	local options = lineFrame.options
	local pathX = lineFrame.pathX
	local pathY = lineFrame.pathY
	local lineType = options.line_type

	if (lineType == "line") then
		pathX[1] = startX
		pathY[1] = startY
		pathX[2] = endX
		pathY[2] = endY
		lineFrame.pathSize = 2

	elseif (lineType == "rope") then
		local deltaX = endX - startX
		local deltaY = endY - startY
		local ropeLength = getRopeLength(lineFrame, math.sqrt(deltaX * deltaX + deltaY * deltaY))
		local controlX, controlY = detailsFramework.Physics.GetRopeControlPoint(startX, startY, endX, endY, ropeLength)
		local segments = options.segments

		for i = 0, segments do
			pathX[i + 1], pathY[i + 1] = detailsFramework.Physics.GetQuadraticBezierPoint(i / segments, startX, startY, controlX, controlY, endX, endY)
		end

		lineFrame.pathSize = segments + 1

	elseif (lineType == "physics") then
		--the simulated points are few, a catmull-rom curve through them draws a smooth rope
		local rope = lineFrame.Rope
		local amountOfPoints = rope:GetAmountOfPoints()
		local smoothing = options.smoothing
		local pathSize = 0

		for i = 1, amountOfPoints - 1 do
			local x0, y0 = rope:GetPoint(math.max(i - 1, 1))
			local x1, y1 = rope:GetPoint(i)
			local x2, y2 = rope:GetPoint(i + 1)
			local x3, y3 = rope:GetPoint(math.min(i + 2, amountOfPoints))

			for step = 0, smoothing - 1 do
				pathSize = pathSize + 1
				pathX[pathSize], pathY[pathSize] = detailsFramework.Physics.GetCatmullRomPoint(step / smoothing, x0, y0, x1, y1, x2, y2, x3, y3)
			end
		end

		pathSize = pathSize + 1
		pathX[pathSize], pathY[pathSize] = rope:GetPoint(amountOfPoints)
		lineFrame.pathSize = pathSize
	end
end

---draw the path with line regions, solid or dashed
---@param lineFrame df_line
local drawPath = function(lineFrame)
	local options = lineFrame.options
	local pathX = lineFrame.pathX
	local pathY = lineFrame.pathY
	local pathSize = lineFrame.pathSize
	local amountOfSegments = 0

	local dashLength = options.dash_length
	local patternLength = dashLength + options.gap_length
	local isDashed = dashLength > 0 and options.gap_length > 0

	--stretching each solid piece into the next one covers the notch a thick line shows on a bend
	local jointOverlap = options.thickness * 0.5

	--how far the walk along the path is inside the current dash and gap pattern
	local distanceInPattern = 0

	for i = 1, pathSize - 1 do
		local startX = pathX[i]
		local startY = pathY[i]
		local deltaX = pathX[i + 1] - startX
		local deltaY = pathY[i + 1] - startY
		local pieceLength = math.sqrt(deltaX * deltaX + deltaY * deltaY)

		if (pieceLength > 0) then
			local directionX = deltaX / pieceLength
			local directionY = deltaY / pieceLength

			if (not isDashed) then
				local drawnLength = pieceLength
				if (i < pathSize - 1) then
					drawnLength = pieceLength + jointOverlap
				end

				amountOfSegments = amountOfSegments + 1
				placeSegment(lineFrame, amountOfSegments, startX, startY, startX + directionX * drawnLength, startY + directionY * drawnLength)
			else
				--walk the piece, drawing the parts that fall inside a dash, a dash crossing two pieces is drawn in two parts
				local walkedLength = 0
				while (walkedLength < pieceLength) do
					local isInDash = distanceInPattern < dashLength
					local lengthLeftInPhase
					if (isInDash) then
						lengthLeftInPhase = dashLength - distanceInPattern
					else
						lengthLeftInPhase = patternLength - distanceInPattern
					end

					local stepLength = math.min(lengthLeftInPhase, pieceLength - walkedLength)

					if (isInDash) then
						local fromLength = walkedLength
						local toLength = walkedLength + stepLength
						amountOfSegments = amountOfSegments + 1
						placeSegment(lineFrame, amountOfSegments, startX + directionX * fromLength, startY + directionY * fromLength, startX + directionX * toLength, startY + directionY * toLength)
					end

					walkedLength = walkedLength + stepLength
					distanceInPattern = (distanceInPattern + stepLength) % patternLength
				end
			end
		end
	end

	hideSegments(lineFrame, amountOfSegments + 1)
	lineFrame.amountOfSegmentsShown = amountOfSegments
end

---bring the line up to date: follow the two ends, advance the rope simulation and redraw when something changed
---@param lineFrame df_line
---@param deltaTime number
---@param isForced boolean redraw even if nothing moved
local updateLine = function(lineFrame, deltaTime, isForced)
	local startX, startY = resolveAnchor(lineFrame, lineFrame.startAnchor)
	local endX, endY = resolveAnchor(lineFrame, lineFrame.endAnchor)

	--an end without a position hides the line until it gets one
	if (not startX or not endX) then
		hideSegments(lineFrame, 1)
		lineFrame.drawnStartX = nil
		lineFrame.needsRopeReset = true
		return
	end

	if (lineFrame.options.line_type == "physics") then
		local rope = lineFrame.Rope
		local deltaX = endX - startX
		local deltaY = endY - startY
		local ropeLength = getRopeLength(lineFrame, math.sqrt(deltaX * deltaX + deltaY * deltaY))

		--a new rope starts at rest in the shape of a hanging rope, so it does not fall from a straight line
		if (lineFrame.needsRopeReset) then
			local controlX, controlY = detailsFramework.Physics.GetRopeControlPoint(startX, startY, endX, endY, ropeLength)
			rope:Reset(startX, startY, endX, endY, controlX, controlY)
			lineFrame.needsRopeReset = false
			isForced = true
		end

		rope:SetAnchors(startX, startY, endX, endY)
		rope:SetSegmentLength(ropeLength / (rope:GetAmountOfPoints() - 1))

		local hasMoved = rope:Update(deltaTime)
		if (hasMoved or isForced) then
			buildPath(lineFrame, startX, startY, endX, endY)
			drawPath(lineFrame)
		end
		return
	end

	local hasMoved = startX ~= lineFrame.drawnStartX or startY ~= lineFrame.drawnStartY or endX ~= lineFrame.drawnEndX or endY ~= lineFrame.drawnEndY
	if (hasMoved or isForced) then
		buildPath(lineFrame, startX, startY, endX, endY)
		drawPath(lineFrame)
		lineFrame.drawnStartX = startX
		lineFrame.drawnStartY = startY
		lineFrame.drawnEndX = endX
		lineFrame.drawnEndY = endY
	end
end

---OnUpdate script of the line frame, it runs only while the line follows its anchors or simulates a rope
---@param lineFrame df_line
---@param deltaTime number
local onUpdate = function(lineFrame, deltaTime)
	updateLine(lineFrame, deltaTime, false)
end

---a physics rope shown again starts at rest, the time it was hidden is not simulated
---@param lineFrame df_line
local onShow = function(lineFrame)
	lineFrame.needsRopeReset = true
end

---turn the OnUpdate script on when the line needs to follow its ends or simulate the rope, and off otherwise
---@param lineFrame df_line
local updateScriptState = function(lineFrame)
	local options = lineFrame.options
	if (options.auto_update or options.line_type == "physics") then
		lineFrame:SetScript("OnUpdate", onUpdate)
	else
		lineFrame:SetScript("OnUpdate", nil)
	end
end

---create the rope simulation with the amount of points and the settings in the options
---@param lineFrame df_line
local createRope = function(lineFrame)
	local options = lineFrame.options
	local rope = detailsFramework.Physics.CreateRope(options.simulation_points)
	rope:SetGravity(0, options.gravity)
	rope:SetDamping(options.damping)
	rope:SetIterations(options.stiffness)
	lineFrame.Rope = rope
	lineFrame.needsRopeReset = true
end

---set one end of the line to a point of a frame
---@param lineFrame df_line
---@param anchor df_line_anchor
---@param frame uiobject
---@param point string?
---@param offsetX number?
---@param offsetY number?
local setAnchorToFrame = function(lineFrame, anchor, frame, point, offsetX, offsetY)
	point = string.lower(point or "center")
	assert(POINT_FRACTIONS[point], "df_line: invalid anchor point '" .. point .. "'.")

	--a physics rope moved to another frame starts at rest instead of swinging across from the old one
	if (frame ~= anchor.frame) then
		lineFrame.needsRopeReset = true
	end

	anchor.isSet = true
	anchor.frame = frame
	anchor.point = point
	anchor.offsetX = offsetX or 0
	anchor.offsetY = offsetY or 0
end

---set one end of the line to a fixed position
---@param anchor df_line_anchor
---@param x number
---@param y number
local setAnchorToPosition = function(anchor, x, y)
	anchor.isSet = true
	anchor.frame = nil
	anchor.x = x
	anchor.y = y
end

---apply the look of the line to every line region already created
---@param lineFrame df_line
local applyStyleToAllSegments = function(lineFrame)
	for index, segment in ipairs(lineFrame.Segments) do
		applySegmentStyle(lineFrame, segment)
	end
end

---@type df_linemixin
---@diagnostic disable-next-line: missing-fields
detailsFramework.LineMixin = {
	SetStartAnchor = function(self, frame, point, offsetX, offsetY)
		setAnchorToFrame(self, self.startAnchor, frame, point, offsetX, offsetY)
		self:Refresh()
	end,

	SetEndAnchor = function(self, frame, point, offsetX, offsetY)
		setAnchorToFrame(self, self.endAnchor, frame, point, offsetX, offsetY)
		self:Refresh()
	end,

	SetStartPosition = function(self, x, y)
		setAnchorToPosition(self.startAnchor, x, y)
		self:Refresh()
	end,

	SetEndPosition = function(self, x, y)
		setAnchorToPosition(self.endAnchor, x, y)
		self:Refresh()
	end,

	SetLineType = function(self, lineType)
		assert(LINE_TYPES[lineType], "df_line:SetLineType(lineType): lineType must be 'line', 'rope' or 'physics'.")
		self.options.line_type = lineType

		if (lineType == "physics") then
			if (not self.Rope) then
				createRope(self)
			end

			self.needsRopeReset = true
		end

		updateScriptState(self)
		self:Refresh()
	end,

	GetLineType = function(self)
		return self.options.line_type
	end,

	SetThickness = function(self, thickness)
		self.options.thickness = thickness
		applyStyleToAllSegments(self)
		self:Refresh()
	end,

	SetColor = function(self, red, green, blue, alpha)
		local r, g, b, a = detailsFramework:ParseColors(red, green, blue, alpha)
		local color = self.options.color
		color[1] = r
		color[2] = g
		color[3] = b
		color[4] = a
		applyStyleToAllSegments(self)
	end,

	SetTexture = function(self, texture)
		self.options.texture = texture
		applyStyleToAllSegments(self)
	end,

	SetLineDrawLayer = function(self, drawLayer, subLevel)
		self.options.draw_layer = drawLayer
		self.options.sub_level = subLevel or 0
		applyStyleToAllSegments(self)
	end,

	SetDashes = function(self, dashLength, gapLength)
		self.options.dash_length = dashLength
		self.options.gap_length = gapLength
		self:Refresh()
	end,

	SetSegments = function(self, segments)
		self.options.segments = segments
		self:Refresh()
	end,

	SetSlack = function(self, slack)
		self.options.slack = slack
		self:Refresh()
	end,

	SetRopeLength = function(self, ropeLength)
		self.options.rope_length = ropeLength
		self:Refresh()
	end,

	SetExtraLength = function(self, extraLength)
		self.options.extra_length = extraLength
		self:Refresh()
	end,

	SetSimulationPoints = function(self, amountOfPoints)
		self.options.simulation_points = amountOfPoints
		if (self.Rope) then
			createRope(self)
		end

		self:Refresh()
	end,

	SetSmoothing = function(self, smoothing)
		self.options.smoothing = smoothing
		self:Refresh()
	end,

	SetGravity = function(self, gravity)
		self.options.gravity = gravity
		if (self.Rope) then
			self.Rope:SetGravity(0, gravity)
		end
	end,

	SetDamping = function(self, damping)
		self.options.damping = damping
		if (self.Rope) then
			self.Rope:SetDamping(damping)
		end
	end,

	SetStiffness = function(self, stiffness)
		self.options.stiffness = stiffness
		if (self.Rope) then
			self.Rope:SetIterations(stiffness)
		end
	end,

	SetImpulseVariation = function(self, variation)
		self.options.impulse_variation = variation
	end,

	SetAutoUpdate = function(self, isEnabled)
		self.options.auto_update = isEnabled
		updateScriptState(self)
	end,

	ApplyImpulse = function(self, impulseX, impulseY, variation)
		if (self.Rope) then
			--a rope waiting to restart at rest restarts now, or the restart would undo the push
			if (self.needsRopeReset) then
				self:Refresh()
			end

			self.Rope:ApplyImpulse(impulseX, impulseY, variation or self.options.impulse_variation)
		end
	end,

	Refresh = function(self)
		updateLine(self, 0, true)
	end,
}

---create a line between two points or two frames: a straight line, a hanging rope or a rope with physics, solid or dashed
---the line frame covers the parent, positions given with SetStartPosition() and SetEndPosition() are relative to its bottom left corner
---@param parent frame
---@param name string?
---@param options df_line_options?
---@return df_line
function detailsFramework:CreateLine(parent, name, options)
	---@type df_line
	local lineFrame = CreateFrame("frame", name, parent)
	lineFrame:SetAllPoints(parent)

	detailsFramework:Mixin(lineFrame, detailsFramework.OptionsFunctions)
	detailsFramework:Mixin(lineFrame, detailsFramework.LineMixin)

	lineFrame:BuildOptionsTable(defaultLineOptions, options)

	--the color can come in any format the framework parses, keep it as a {r, g, b, a}
	local r, g, b, a = detailsFramework:ParseColors(lineFrame.options.color)
	lineFrame.options.color = {r, g, b, a}

	assert(LINE_TYPES[lineFrame.options.line_type], "CreateLine(parent, name, options): options.line_type must be 'line', 'rope' or 'physics'.")

	lineFrame.startAnchor = {isSet = false, point = "center", offsetX = 0, offsetY = 0, x = 0, y = 0}
	lineFrame.endAnchor = {isSet = false, point = "center", offsetX = 0, offsetY = 0, x = 0, y = 0}
	lineFrame.Segments = {}
	lineFrame.amountOfSegmentsShown = 0
	lineFrame.pathX = {}
	lineFrame.pathY = {}
	lineFrame.pathSize = 0
	lineFrame.needsRopeReset = true

	if (lineFrame.options.line_type == "physics") then
		createRope(lineFrame)
	end

	lineFrame:SetScript("OnShow", onShow)
	updateScriptState(lineFrame)

	return lineFrame
end
