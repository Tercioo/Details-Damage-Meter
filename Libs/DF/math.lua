
local DF = _G["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local UnitExists = UnitExists
local atan2 = math.atan2
local pi = math.pi
local abs = math.abs
local UnitPosition = UnitPosition
local Clamp = Clamp
local max = max
local Lerp = Lerp

SMALL_FLOAT = 0.000001

--namespace
DF.Math = {}

---@class df_math : table
---@field GetUnitDistance fun(unitId1: unit, unitId2: unit) : number find distance between two units
---@field GetPointDistance fun(x1: number, y1: number, x2: number, y2: number) : number find distance between two points
---@field FindLookAtRotation fun(x1: number, y1: number, x2: number, y2: number) : number find a rotation for an object from a point to another point
---@field MapRangeClamped fun(inputX: number, inputY: number, outputX: number, outputY: number, value: number) : number find the value scale between two given values. e.g: value of 500 in a range 0-100 result in 10 in a scale for 0-10
---@field MapRangeUnclamped fun(inputX: number, inputY: number, outputX: number, outputY: number, value: number) : number find the value scale between two given values. e.g: value of 75 in a range 0-100 result in 7.5 in a scale for 0-10
---@field GetRangePercent fun(minValue: number, maxValue: number, value: number) : number find the normalized percent of the value in the range. e.g range of 200-400 and a value of 250 result in 0.25
---@field GetRangeValue fun(minValue: number, maxValue: number, percent: number) : number find the value in the range given from a normalized percent. e.g range of 200-400 and a percent of 0.8 result in 360
---@field GetColorRangeValue fun(r1: number, g1: number, b1: number, r2: number, g2: number, b2: number, value: number) : number, number, number interpolate each channel between two colors using a normalized percent. e.g (1,0,0) and (0,0,1) at 0.5 result in (0.5, 0, 0.5)
---@field GetDotProduct fun(value1: table, value2: table) : number dot product of two 2D Vectors
---@field GetBezierPoint fun(value: number, point1: number, point2: number, point3: number) : number find a point in a quadratic bezier curve (operates on scalar values)
---@field LerpNorm fun(minValue: number, maxValue: number, value: number) : number normalized value 0-1 result in the value on the range given, e.g 200-400 range with a value of .5 result in 300
---@field LerpLinearColor fun(deltaTime: number, interpSpeed: number, r1: number, g1: number, b1: number, r2: number, g2: number, b2: number) : number, number, number change the color by the deltaTime, deltaTime*interpSpeed is clamped to [0,1] to prevent overshoot
---@field InvertInRange fun(minValue: number, maxValue: number, value: number) : number invert the value in a range, example: InvertInRange(0, 1, 0.75) return 0.25, InvertInRange(0, 100, 75) return 25, InvertInRange(-1, 1, 0.5) return -0.5, InvertInRange(-3, 1, -0.75) return -1.25
---@field IsNearlyEqual fun(value1: number, value2: number, tolerance: number) : boolean check if a number is near another number by a tolerance
---@field IsNearlyZero fun(value: number, tolerance: number) : boolean check if a number is near zero
---@field IsWithin fun(minValue: number, maxValue: number, value: number, isInclusive: boolean) : boolean check if a number is within a two other numbers, if isInclusive is true, it'll  include the max value
---@field Clamp fun(minValue: number, maxValue: number, value: number) : number dont allow a number ot be lower or bigger than a certain range
---@field Round fun(num: number, numDecimalPlaces: number) : number cut fractions on a float
---@field GetObjectCoordinates fun(object: uiobject) : objectcoordinates return the coordinates of the four corners of an object
---@field MultiplyBy fun(value: number, ...) : ... multiply all the passed values by value.
---@field MapRangeColor fun(inputX: number, inputY: number, outputX: number, outputY: number, red: number, green: number, blue: number) : number, number, number
---@field RandomFraction fun(minValue: number, maxValue: number) : number
---@field GetNinePoints fun(object: uiobject) : df_ninepoints
---@field GetClosestPoint fun(ninePoints: df_ninepoints, coordinate: df_coordinate) : anchorid
---@field GetVectorLength fun(vectorX: number, vectorY: number, vectorZ: number?) : number return the magnitude of a vector
---@field GetSortFractionFromString fun(str: string) : number return a fraction based on the string first two leters, useful for sorting cases where the number repeats
---@field PositiveNonZero fun(value: number) : number return the value or a small float if the value is zero or negative
---@field Percentile fun(t: number[], p: number) : number? return the p-th percentile of t (p is normalized 0-1, e.g. 0.95 = 95th percentile). Uses linear interpolation between ranks. Returns nil for empty input. Does not mutate t.
---@field MovingAverage fun(t: number[], window: number) : number[] return a new array of centered moving averages over `window` samples. Edges use a truncated window. Useful for smoothing per-second damage curves.
---@field SafeDivide fun(a: number, b: number, fallback: number?) : number return a/b, or `fallback` (default 0) if b is zero
---@field StandardDeviation fun(t: number[]) : number return the population standard deviation of t. Returns 0 for empty or single-element input.



---@class df_coordinate : table
---@field x number
---@field y number

---@class df_ninepoints : df_coordinate[]
---@field GetClosestPoint fun(ninePoints: df_ninepoints, coordinate: df_coordinate) : anchorid

---this function receives a df_ninepoints and a df_coordinate, iterates among the points and return the closest point to the given coordinate
---@param ninePoints df_ninepoints
---@param coordinate df_coordinate
---@return anchorid, number, number, number, number
function DF.Math.GetClosestPoint(ninePoints, coordinate)
	local closestPoint = 1
	local closestDistance = DF.Math.GetPointDistance(ninePoints[1].x, ninePoints[1].y, coordinate.x, coordinate.y)

	--get the x and y offset from the closest point to the given coordinate
	local offsetX = coordinate.x - ninePoints[1].x
	local offsetY = coordinate.y - ninePoints[1].y

	for i = 2, #ninePoints do
		local distance = DF.Math.GetPointDistance(ninePoints[i].x, ninePoints[i].y, coordinate.x, coordinate.y)
		if (distance < closestDistance) then
			closestDistance = distance
			closestPoint = i

			--updade the offset
			offsetX = coordinate.x - ninePoints[i].x
			offsetY = coordinate.y - ninePoints[i].y
		end
	end

	return closestPoint, offsetX, offsetY, ninePoints[closestPoint].x, ninePoints[closestPoint].y
end

---this function receives an object and get the location of the topleft, left, bottomleft, bottom, bottomright, right, topright, top and center points
---return a table with subtables with x and y values for each point
---@param object uiobject
---@return df_ninepoints
function DF.Math.GetNinePoints(object)
	local centerX, centerY = object:GetCenter()
	local width = object:GetWidth()
	local height = object:GetHeight()

	if (not centerX or not centerY) then
		error("Object has no center point: " .. tostring(object:GetName()))
	end

	local halfWidth = width / 2
	local halfHeight = height / 2

	---@type df_ninepoints
	---@diagnostic disable-next-line: missing-fields
	local ninePoints = {
		{x = centerX - halfWidth, y = centerY + halfHeight}, --topleft 1
		{x = centerX - halfWidth, y = centerY}, --left 2
		{x = centerX - halfWidth, y = centerY - halfHeight}, --bottomleft 3
		{x = centerX, y = centerY - halfHeight}, --bottom 4
		{x = centerX + halfWidth, y = centerY - halfHeight}, --bottomright 5
		{x = centerX + halfWidth, y = centerY}, --right 6
		{x = centerX + halfWidth, y = centerY + halfHeight}, --topright 7
		{x = centerX, y = centerY + halfHeight}, --top 8
		{x = centerX, y = centerY}, --center 9
		GetClosestPoint = DF.Math.GetClosestPoint
	}

	--debug
	--[=[
	local f = CreateFrame("frame", nil, UIParent)
	f:SetFrameStrata("TOOLTIP")
	f:SetSize(1, 1)
	f:SetPoint("center", UIParent, "center", 0, 0)
	for i = 1, #ninePoints do
		local point = ninePoints[i]

		local t = f:CreateTexture(nil, "overlay")
		t:SetColorTexture(1, 0, 0, 1)
		t:SetSize(2, 2)
		t:SetPoint("bottomleft", UIParent, "bottomleft", point.x, point.y)
	end
	--]=]

	return ninePoints
end

--produces a small fraction derived from the first two characters of str. abs(byte - 91) is intentional: it inverts the alphabet so 'A' has the largest weight and 'Z' the smallest, giving a reverse-alphabetical tie-breaker when added to a primary sort key.
function DF.Math.GetSortFractionFromString(str)
	local name = string.upper(str) .. "ZZ"
	local byte1 = abs(string.byte(name, 2)-91) / 1000000
	return byte1 + abs(string.byte(name, 1)-91) / 10000
end

function DF.Math.GetVectorLength(vectorX, vectorY, vectorZ)
	if (not vectorZ) then
		return (vectorX * vectorX + vectorY * vectorY) ^ 0.5
	end
	return (vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ) ^ 0.5
end

---return a random fraction between two values, example: RandomFraction(.2, .3) returns a number between .2 and .3, 0.25, 0.28, 0.21, etc
function DF.Math.RandomFraction(minValue, maxValue)
    minValue = minValue or 0
    maxValue = maxValue or 1
    return DF.Math.MapRangeClamped(0, 1, minValue, maxValue, math.random())
end

---invert the value in a range, example: InvertInRange(0, 1, 0.75) return 0.25, InvertInRange(0, 100, 75) return 25, InvertInRange(-1, 1, 0.5) return -0.5, InvertInRange(-3, 1, -0.75) return -1.25
function DF.Math.InvertInRange(minValue, maxValue, value)
	return DF.Math.GetRangeValue(minValue, maxValue, 1 - DF.Math.GetRangePercent(minValue, maxValue, value))
end

---find distance between two units
---@param unitId1 string
---@param unitId2 string
function DF.Math.GetUnitDistance(unitId1, unitId2)
	if (UnitExists(unitId1) and UnitExists(unitId2)) then
		--UnitPosition returns posY, posX, posZ, instanceID; the labels are flipped for distance, but the result is the same
		local u1A, u1B = UnitPosition(unitId1)
		local u2A, u2B = UnitPosition(unitId2)

		local dA = u2A - u1A
		local dB = u2B - u1B

		return ((dA*dA) + (dB*dB)) ^ .5
	end
	return 0
end

function DF.Math.GetPointDistance(x1, y1, x2, y2)
	local dX = x2 - x1
	local dY = y2 - y1
	return ((dX * dX) + (dY * dY)) ^ .5
end

function DF.Math.FindLookAtRotation(x1, y1, x2, y2)
	return atan2(y2 - y1, x2 - x1) + pi
end

function DF.Math.MapRangeClamped(inputX, inputY, outputX, outputY, value)
	return DF.Math.GetRangeValue(outputX, outputY, Clamp(DF.Math.GetRangePercent(inputX, inputY, value), 0, 1))
end

---*Receives a color, the range of the color and a range to map the color to, returns the color in the new range
---*Example: MapRangeColor(0, 1, 0, 255, 0.5, 0.5, 0.5) returns 127.5, 127.5, 127.5
---@param inputX number X range of the original color
---@param inputY number Y range of the original color
---@param outputX number X range of the new color
---@param outputY number Y range of the new color
---@param red number
---@param green number
---@param blue number
---@return number, number, number
function DF.Math.MapRangeColor(inputX, inputY, outputX, outputY, red, green, blue)
	local newR = DF.Math.MapRangeClamped(inputX, inputY, outputX, outputY, red)
	local newG = DF.Math.MapRangeClamped(inputX, inputY, outputX, outputY, green)
	local newB = DF.Math.MapRangeClamped(inputX, inputY, outputX, outputY, blue)
	return newR, newG, newB
end

function DF.Math.MultiplyBy(value, ...)
	local values = {}
	for i = 1, select("#", ...) do
		values[i] = select(i, ...) * value
	end
	return unpack(values)
end

function DF.Math.PositiveNonZero(value)
	return max(value, 0.001)
end

function DF.Math.MapRangeUnclamped(inputX, inputY, outputX, outputY, value)
	return DF.Math.GetRangeValue(outputX, outputY, DF.Math.GetRangePercent(inputX, inputY, value))
end

function DF.Math.GetRangePercent(minValue, maxValue, value)
	return (value - minValue) / max((maxValue - minValue), SMALL_FLOAT)
end

function DF.Math.GetRangeValue(minValue, maxValue, percent)
	return Lerp(minValue, maxValue, percent)
end

function DF.Math.GetColorRangeValue(r1, g1, b1, r2, g2, b2, value)
	local newR = DF.Math.LerpNorm(r1, r2, value)
	local newG = DF.Math.LerpNorm(g1, g2, value)
	local newB = DF.Math.LerpNorm(b1, b2, value)
	return newR, newG, newB
end

function DF.Math.GetDotProduct(value1, value2)
	return (value1.x * value2.x) + (value1.y * value2.y)
end

function DF.Math.GetBezierPoint(value, point1, point2, point3)
	local bP1 = Lerp(point1, point2, value)
	local bP2 = Lerp(point2, point3, value)
	return Lerp(bP1, bP2, value)
end

function DF.Math.LerpNorm(minValue, maxValue, value)
	return (minValue + value * (maxValue - minValue))
end

function DF.Math.LerpLinearColor(deltaTime, interpSpeed, r1, g1, b1, r2, g2, b2)
	--clamp to [0,1] so a long frame (large deltaTime) cannot push the color past the target
	local t = Clamp(deltaTime * interpSpeed, 0, 1)
	local r = r1 + (r2 - r1) * t
	local g = g1 + (g2 - g1) * t
	local b = b1 + (b2 - b1) * t
	return r, g, b
end

function DF.Math.IsNearlyEqual(value1, value2, tolerance)
	tolerance = tolerance or SMALL_FLOAT
	return abs(value1 - value2) <= tolerance
end

function DF.Math.IsNearlyZero(value, tolerance)
	tolerance = tolerance or SMALL_FLOAT
	return abs(value) <= tolerance
end

function DF.Math.IsWithin(minValue, maxValue, value, isInclusive)
	if (isInclusive) then
		return ((value >= minValue) and (value <= maxValue))
	else
		return ((value >= minValue) and (value < maxValue))
	end
end

function DF.Math.Clamp(minValue, maxValue, value)
	return value < minValue and minValue or value < maxValue and value or maxValue
end

function DF.Math.Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

---divide a by b, returning fallback (default 0) when b is zero. Useful at boundaries where a zero divisor is plausible (empty windows, no-damage segments, etc).
---@param a number
---@param b number
---@param fallback number?
---@return number
function DF.Math.SafeDivide(a, b, fallback)
	if (b == 0) then
		return fallback or 0
	end
	return a / b
end

---return the population standard deviation of the values in t. Returns 0 for empty or single-element input.
---@param t number[]
---@return number
function DF.Math.StandardDeviation(t)
	local n = #t
	if (n < 2) then
		return 0
	end

	local sum = 0
	for i = 1, n do
		sum = sum + t[i]
	end
	local mean = sum / n

	local sqDiff = 0
	for i = 1, n do
		local d = t[i] - mean
		sqDiff = sqDiff + d * d
	end

	return (sqDiff / n) ^ 0.5
end

---return the p-th percentile of the values in t. p is normalized 0-1 (e.g. 0.95 = 95th percentile). Uses linear interpolation between ranks. Returns nil for empty input. Does not mutate t.
---@param t number[]
---@param p number
---@return number?
function DF.Math.Percentile(t, p)
	local n = #t
	if (n == 0) then
		return nil
	elseif (n == 1) then
		return t[1]
	end

	--copy then sort so the caller's array is untouched
	local sorted = {}
	for i = 1, n do
		sorted[i] = t[i]
	end
	table.sort(sorted)

	p = Clamp(p, 0, 1)

	--linear interpolation between rank floor and rank ceil
	local rank = p * (n - 1) + 1
	local lower = math.floor(rank)
	local upper = math.ceil(rank)
	if (lower == upper) then
		return sorted[lower]
	end
	local frac = rank - lower
	return sorted[lower] + (sorted[upper] - sorted[lower]) * frac
end

---return a new array where each entry is the centered moving average of t across `window` samples. window is floored and clamped to a minimum of 1. At array edges the window is truncated to the available samples (so the first/last entries average over fewer values).
---@param t number[]
---@param window number
---@return number[]
function DF.Math.MovingAverage(t, window)
	local n = #t
	local result = {}
	if (n == 0) then
		return result
	end

	window = max(math.floor(window), 1)
	local half = math.floor(window / 2)

	for i = 1, n do
		local lo = max(1, i - half)
		local hi = math.min(n, i + half)
		local sum = 0
		for j = lo, hi do
			sum = sum + t[j]
		end
		result[i] = sum / (hi - lo + 1)
	end

	return result
end

--old calls, keeping for compatibility
function DF:GetDistance_Unit(unit1, unit2)
	return DF.Math.GetUnitDistance(unit1, unit2)
end
function DF:GetDistance_Point(x1, y1, x2, y2)
	return DF.Math.GetPointDistance(x1, y1, x2, y2)
end
--find a rotation for an object from a point to another point
function DF:FindLookAtRotation(x1, y1, x2, y2)
	return DF.Math.FindLookAtRotation(x1, y1, x2, y2)
end
--find the value scale between two given values. e.g: value of 500 in a range 0-100 result in 10 in a scale for 0-10
function DF:MapRangeClamped(inputX, inputY, outputX, outputY, value)
	return DF:GetRangeValue(outputX, outputY, Clamp(DF:GetRangePercent(inputX, inputY, value), 0, 1))
end
--find the value scale between two given values. e.g: value of 75 in a range 0-100 result in 7.5 in a scale for 0-10
function DF:MapRangeUnclamped(inputX, inputY, outputX, outputY, value)
	return DF:GetRangeValue(outputX, outputY, DF:GetRangePercent(inputX, inputY, value))
end
--find the normalized percent of the value in the range. e.g range of 200-400 and a value of 250 result in 0.25
function DF:GetRangePercent(minValue, maxValue, value)
	return (value - minValue) / max((maxValue - minValue), SMALL_FLOAT)
end
--find the value in the range given from a normalized percent. e.g range of 200-400 and a percent of 0.8 result in 360
function DF:GetRangeValue(minValue, maxValue, percent)
	return Lerp(minValue, maxValue, percent)
end
function DF:GetColorRangeValue(r1, g1, b1, r2, g2, b2, value)
	return DF.Math.GetColorRangeValue(r1, g1, b1, r2, g2, b2, value)
end
--dot product of two 2D Vectors
function DF:GetDotProduct(value1, value2)
	return (value1.x * value2.x) + (value1.y * value2.y)
end
function DF:GetBezierPoint(value, point1, point2, point3)
	return DF.Math.GetBezierPoint(value, point1, point2, point3)
end

function DF:GetVectorLength(vectorX, vectorY, vectorZ)
	if (not vectorZ) then
		return (vectorX * vectorX + vectorY * vectorY) ^ 0.5
	end
	return (vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ) ^ 0.5
end

--normalized value 0-1 result in the value on the range given, e.g 200-400 range with a value of .5 result in 300
function DF:LerpNorm(minValue, maxValue, value)
	return (minValue + value * (maxValue - minValue))
end
--change the color by the deltaTime
function DF:LerpLinearColor(deltaTime, interpSpeed, r1, g1, b1, r2, g2, b2)
	return DF.Math.LerpLinearColor(deltaTime, interpSpeed, r1, g1, b1, r2, g2, b2)
end

--check if a number is near another number by a tolerance
function DF:IsNearlyEqual(value1, value2, tolerance)
	tolerance = tolerance or SMALL_FLOAT
	return abs(value1 - value2) <= tolerance
end

--check if a number is near zero
function DF:IsNearlyZero(value, tolerance)
	tolerance = tolerance or SMALL_FLOAT
	return abs(value) <= tolerance
end

--check if a number is within a two other numbers, if isInclusive is true, it'll  include the max value
function DF:IsWithin(minValue, maxValue, value, isInclusive)
	if (isInclusive) then
		return ((value >= minValue) and (value <= maxValue))
	else
		return ((value >= minValue) and (value < maxValue))
	end
end

--dont allow a number ot be lower or bigger than a certain range
function DF:Clamp(minValue, maxValue, value)
	return value < minValue and minValue or value < maxValue and value or maxValue
end

--from http://lua-users.org/wiki/SimpleRound cut fractions on a float
function DF:Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local BoundingBox = {}
BoundingBox.CoordinatesData = {
	["topleft"] = {["x"] = 'number', ["y"] = 'number'},
	["topright"] = {["x"] = 'number', ["y"] = 'number'},
	["bottomleft"] = {["x"] = 'number', ["y"] = 'number'},
	["bottomright"] = {["x"] = 'number', ["y"] = 'number'},
	["center"] = {["x"] = 'number', ["y"] = 'number'},
	["width"] = 'number',
	["height"] = 'number',
}

---@class objectcoordinates
---@field topleft {["x"]: number, ["y"]: number}
---@field topright {["x"]: number, ["y"]: number}
---@field bottomleft {["x"]: number, ["y"]: number}
---@field bottomright {["x"]: number, ["y"]: number}
---@field center {["x"]: number, ["y"]: number}
---@field width number
---@field height number
---@field left number
---@field right number
---@field top number
---@field bottom number

---return the coordinates of the four corners of an object
---@param object uiobject
---@return objectcoordinates
function DF:GetObjectCoordinates(object)
	local centerX, centerY = object:GetCenter()
	local width = object:GetWidth()
	local height = object:GetHeight()

	local halfWidth = width / 2
	local halfHeight = height / 2

	return {
		["width"] = width,
		["height"] = height,
		["left"] = centerX - halfWidth,
		["right"] = centerX + halfWidth,
		["top"] = centerY + halfHeight,
		["bottom"] = centerY - halfHeight,
		["center"] = {x = centerX, y = centerY},
		["topleft"] = {x = centerX - halfWidth, y = centerY + halfHeight},
		["topright"] = {x = centerX + halfWidth, y = centerY + halfHeight},
		["bottomleft"] = {x = centerX - halfWidth, y = centerY - halfHeight},
		["bottomright"] = {x = centerX + halfWidth, y = centerY - halfHeight},
	}
end

function DF:ScaleBack()

end
