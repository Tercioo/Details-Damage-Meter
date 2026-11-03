
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _

--constants
local FIXED_TIME_STEP = 1 / 60 --the rope simulation always advances in steps of this size, which keeps it stable on any frame rate
local MAX_STEPS_PER_UPDATE = 4 --time beyond this many steps in a single update is dropped, so a frame hitch never makes the simulation snowball
local SLEEP_MOVEMENT = 0.02 --a point moving less than this many pixels per step counts as still
local SLEEP_STEPS = 30 --amount of consecutive still steps before the rope goes to sleep

---@class df_physics : table
---@field GetQuadraticBezierPoint fun(t:number, startX:number, startY:number, controlX:number, controlY:number, endX:number, endY:number) : number, number return the point at t (0-1) of a quadratic bezier curve
---@field GetCatmullRomPoint fun(t:number, x0:number, y0:number, x1:number, y1:number, x2:number, y2:number, x3:number, y3:number) : number, number return the point at t (0-1) between the second and third points of a catmull-rom spline
---@field GetRopeSag fun(distance:number, ropeLength:number) : number return how far below the middle of its two ends a hanging rope dips
---@field GetRopeControlPoint fun(startX:number, startY:number, endX:number, endY:number, ropeLength:number) : number, number return the quadratic bezier control point that draws a hanging rope between two points
---@field CreateRope fun(amountOfPoints:number) : df_physicsrope create a rope simulation made of amountOfPoints points

detailsFramework.Physics = {}

---return the point at t (0-1) of a quadratic bezier curve
---@param t number
---@param startX number
---@param startY number
---@param controlX number
---@param controlY number
---@param endX number
---@param endY number
---@return number, number
function detailsFramework.Physics.GetQuadraticBezierPoint(t, startX, startY, controlX, controlY, endX, endY)
	local inverseT = 1 - t
	local startWeight = inverseT * inverseT
	local controlWeight = 2 * inverseT * t
	local endWeight = t * t

	local x = startWeight * startX + controlWeight * controlX + endWeight * endX
	local y = startWeight * startY + controlWeight * controlY + endWeight * endY
	return x, y
end

---return the point at t (0-1) between the second and third points of a catmull-rom spline
---the curve passes through every point it is given, the first and fourth points only shape the bend
---@param t number
---@param x0 number
---@param y0 number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@return number, number
function detailsFramework.Physics.GetCatmullRomPoint(t, x0, y0, x1, y1, x2, y2, x3, y3)
	local tSquared = t * t
	local tCubed = tSquared * t

	local x = 0.5 * ((2 * x1) + (x2 - x0) * t + (2 * x0 - 5 * x1 + 4 * x2 - x3) * tSquared + (3 * x1 - x0 - 3 * x2 + x3) * tCubed)
	local y = 0.5 * ((2 * y1) + (y2 - y0) * t + (2 * y0 - 5 * y1 + 4 * y2 - y3) * tSquared + (3 * y1 - y0 - 3 * y2 + y3) * tCubed)
	return x, y
end

---return how far below the middle of its two ends a hanging rope dips
---the result matches a parabola for a nearly tight rope and a rope folded in half when both ends meet
---@param distance number distance between the two ends of the rope
---@param ropeLength number
---@return number
function detailsFramework.Physics.GetRopeSag(distance, ropeLength)
	if (ropeLength <= distance) then
		return 0
	end

	return math.sqrt(3 * (ropeLength * ropeLength - distance * distance)) / 4
end

---return the quadratic bezier control point that draws a hanging rope between two points
---the middle of a quadratic bezier sits halfway between the control point and the middle of the two ends, so the control point goes twice as deep as the sag
---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param ropeLength number
---@return number, number
function detailsFramework.Physics.GetRopeControlPoint(startX, startY, endX, endY, ropeLength)
	local deltaX = endX - startX
	local deltaY = endY - startY
	local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
	local sag = detailsFramework.Physics.GetRopeSag(distance, ropeLength)

	local controlX = (startX + endX) * 0.5
	local controlY = (startY + endY) * 0.5 - sag * 2
	return controlX, controlY
end

---@class df_physicsrope : table
---@field amountOfPoints number
---@field positionX number[]
---@field positionY number[]
---@field previousX number[] position of each point on the previous step, the distance to it is the point velocity
---@field previousY number[]
---@field segmentLength number distance each pair of neighbour points tries to keep
---@field gravityX number pixels per second squared
---@field gravityY number pixels per second squared, negative pulls down
---@field damping number fraction of the velocity kept on each step
---@field iterations number amount of passes to bring every pair of points back to the segment length on each step
---@field isStartPinned boolean
---@field isEndPinned boolean
---@field startX number
---@field startY number
---@field endX number
---@field endY number
---@field timeAccumulator number
---@field stillSteps number
---@field isSleeping boolean
---@field Reset fun(self:df_physicsrope, startX:number, startY:number, endX:number, endY:number, controlX:number, controlY:number) place all points at rest along a quadratic bezier curve
---@field SetAnchors fun(self:df_physicsrope, startX:number, startY:number, endX:number, endY:number) set where the two ends of the rope are held, wakes the rope if they moved
---@field SetSegmentLength fun(self:df_physicsrope, segmentLength:number)
---@field SetGravity fun(self:df_physicsrope, gravityX:number, gravityY:number)
---@field SetDamping fun(self:df_physicsrope, damping:number)
---@field SetIterations fun(self:df_physicsrope, iterations:number)
---@field SetPinned fun(self:df_physicsrope, isStartPinned:boolean, isEndPinned:boolean) set which ends are held by the anchors, a free end hangs
---@field ApplyImpulse fun(self:df_physicsrope, impulseX:number, impulseY:number, variation:number?) push every free point, in pixels per step, variation (0-1) makes each push a little different
---@field Wake fun(self:df_physicsrope)
---@field IsSleeping fun(self:df_physicsrope) : boolean
---@field Update fun(self:df_physicsrope, deltaTime:number) : boolean advance the simulation, return true if any point moved
---@field Step fun(self:df_physicsrope)
---@field GetAmountOfPoints fun(self:df_physicsrope) : number
---@field GetPoint fun(self:df_physicsrope, index:number) : number, number

---@type df_physicsrope
---@diagnostic disable-next-line: missing-fields
detailsFramework.PhysicsRopeMixin = {
	Reset = function(self, startX, startY, endX, endY, controlX, controlY)
		local amountOfPoints = self.amountOfPoints

		for i = 1, amountOfPoints do
			local t = (i - 1) / (amountOfPoints - 1)
			local x, y = detailsFramework.Physics.GetQuadraticBezierPoint(t, startX, startY, controlX, controlY, endX, endY)
			self.positionX[i] = x
			self.positionY[i] = y
			self.previousX[i] = x
			self.previousY[i] = y
		end

		self.startX = startX
		self.startY = startY
		self.endX = endX
		self.endY = endY
		self.timeAccumulator = 0
		self:Wake()
	end,

	SetAnchors = function(self, startX, startY, endX, endY)
		local hasMoved = startX ~= self.startX or startY ~= self.startY or endX ~= self.endX or endY ~= self.endY
		if (hasMoved) then
			self.startX = startX
			self.startY = startY
			self.endX = endX
			self.endY = endY
			self:Wake()
		end
	end,

	SetSegmentLength = function(self, segmentLength)
		if (segmentLength ~= self.segmentLength) then
			self.segmentLength = segmentLength
			self:Wake()
		end
	end,

	SetGravity = function(self, gravityX, gravityY)
		self.gravityX = gravityX
		self.gravityY = gravityY
		self:Wake()
	end,

	SetDamping = function(self, damping)
		self.damping = damping
		self:Wake()
	end,

	SetIterations = function(self, iterations)
		self.iterations = iterations
		self:Wake()
	end,

	SetPinned = function(self, isStartPinned, isEndPinned)
		self.isStartPinned = isStartPinned
		self.isEndPinned = isEndPinned
		self:Wake()
	end,

	ApplyImpulse = function(self, impulseX, impulseY, variation)
		local amountOfPoints = self.amountOfPoints
		variation = variation or 0

		--with variation each push gets a random strength, leans toward one end and drifts to one side, so no two pushes swing the same
		local strength = 1
		local lean = 0
		local pushX = impulseX
		local pushY = impulseY
		if (variation > 0) then
			strength = 1 + (math.random() * 2 - 1) * variation * 0.5
			lean = (math.random() * 2 - 1) * variation

			--the drift is at a right angle to the push
			local drift = (math.random() * 2 - 1) * variation * 0.5
			pushX = impulseX - impulseY * drift
			pushY = impulseY + impulseX * drift
		end

		--moving the previous position back is the same as adding velocity on a verlet point
		for i = 1, amountOfPoints do
			--where the point sits along the rope, -1 at the start and 1 at the end
			local alongRope = (i - 1) / (amountOfPoints - 1) * 2 - 1
			local weight = strength * (1 + lean * alongRope)
			self.previousX[i] = self.previousX[i] - pushX * weight
			self.previousY[i] = self.previousY[i] - pushY * weight
		end

		self:Wake()
	end,

	Wake = function(self)
		self.isSleeping = false
		self.stillSteps = 0
	end,

	IsSleeping = function(self)
		return self.isSleeping
	end,

	Update = function(self, deltaTime)
		if (self.isSleeping) then
			return false
		end

		local maxTime = FIXED_TIME_STEP * MAX_STEPS_PER_UPDATE
		self.timeAccumulator = math.min(self.timeAccumulator + deltaTime, maxTime)

		local hasStepped = false
		while (self.timeAccumulator >= FIXED_TIME_STEP) do
			self:Step()
			self.timeAccumulator = self.timeAccumulator - FIXED_TIME_STEP
			hasStepped = true
		end

		return hasStepped
	end,

	Step = function(self)
		local amountOfPoints = self.amountOfPoints
		local positionX = self.positionX
		local positionY = self.positionY
		local previousX = self.previousX
		local previousY = self.previousY
		local damping = self.damping
		local gravityStepX = self.gravityX * FIXED_TIME_STEP * FIXED_TIME_STEP
		local gravityStepY = self.gravityY * FIXED_TIME_STEP * FIXED_TIME_STEP

		--verlet integration: each point keeps the velocity it had on the last step, plus gravity
		for i = 1, amountOfPoints do
			local x = positionX[i]
			local y = positionY[i]
			local velocityX = (x - previousX[i]) * damping
			local velocityY = (y - previousY[i]) * damping
			previousX[i] = x
			previousY[i] = y
			positionX[i] = x + velocityX + gravityStepX
			positionY[i] = y + velocityY + gravityStepY
		end

		--pinned ends sit on their anchor and carry no velocity
		if (self.isStartPinned) then
			positionX[1] = self.startX
			positionY[1] = self.startY
			previousX[1] = self.startX
			previousY[1] = self.startY
		end

		if (self.isEndPinned) then
			positionX[amountOfPoints] = self.endX
			positionY[amountOfPoints] = self.endY
			previousX[amountOfPoints] = self.endX
			previousY[amountOfPoints] = self.endY
		end

		--pull every pair of neighbour points back to the segment length, more passes make a stiffer rope
		local segmentLength = self.segmentLength
		local isStartPinned = self.isStartPinned
		local isEndPinned = self.isEndPinned

		for pass = 1, self.iterations do
			for i = 1, amountOfPoints - 1 do
				local deltaX = positionX[i + 1] - positionX[i]
				local deltaY = positionY[i + 1] - positionY[i]
				local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)

				if (distance > 0) then
					--fraction of the distance between the two points that has to be corrected
					local difference = (distance - segmentLength) / distance
					local correctionX = deltaX * difference
					local correctionY = deltaY * difference
					local isFirstFree = i > 1 or not isStartPinned
					local isSecondFree = i + 1 < amountOfPoints or not isEndPinned

					if (isFirstFree and isSecondFree) then
						positionX[i] = positionX[i] + correctionX * 0.5
						positionY[i] = positionY[i] + correctionY * 0.5
						positionX[i + 1] = positionX[i + 1] - correctionX * 0.5
						positionY[i + 1] = positionY[i + 1] - correctionY * 0.5

					elseif (isFirstFree) then
						positionX[i] = positionX[i] + correctionX
						positionY[i] = positionY[i] + correctionY

					elseif (isSecondFree) then
						positionX[i + 1] = positionX[i + 1] - correctionX
						positionY[i + 1] = positionY[i + 1] - correctionY
					end
				end
			end
		end

		--the rope sleeps after it stays still for a while, and wakes when an anchor moves or a setting changes
		local largestMovement = 0
		for i = 1, amountOfPoints do
			local movement = math.abs(positionX[i] - previousX[i]) + math.abs(positionY[i] - previousY[i])
			if (movement > largestMovement) then
				largestMovement = movement
			end
		end

		if (largestMovement < SLEEP_MOVEMENT) then
			self.stillSteps = self.stillSteps + 1
			if (self.stillSteps >= SLEEP_STEPS) then
				self.isSleeping = true
				self.timeAccumulator = 0
			end
		else
			self.stillSteps = 0
		end
	end,

	GetAmountOfPoints = function(self)
		return self.amountOfPoints
	end,

	GetPoint = function(self, index)
		return self.positionX[index], self.positionY[index]
	end,
}

---create a rope simulation made of amountOfPoints points, both ends pinned
---call Reset() to place it, then SetAnchors() and Update() every frame and read the points with GetPoint()
---@param amountOfPoints number at least 2
---@return df_physicsrope
function detailsFramework.Physics.CreateRope(amountOfPoints)
	assert(type(amountOfPoints) == "number" and amountOfPoints >= 2, "Physics.CreateRope(amountOfPoints): amountOfPoints must be a number of at least 2.")

	---@type df_physicsrope
	---@diagnostic disable-next-line: missing-fields
	local rope = {
		amountOfPoints = amountOfPoints,
		positionX = {},
		positionY = {},
		previousX = {},
		previousY = {},
		segmentLength = 10,
		gravityX = 0,
		gravityY = -1200,
		damping = 0.98,
		iterations = 20,
		isStartPinned = true,
		isEndPinned = true,
		startX = 0,
		startY = 0,
		endX = 0,
		endY = 0,
		timeAccumulator = 0,
		stillSteps = 0,
		isSleeping = false,
	}

	detailsFramework:Mixin(rope, detailsFramework.PhysicsRopeMixin)
	rope:Reset(0, 0, 0, 0, 0, 0)

	return rope
end
