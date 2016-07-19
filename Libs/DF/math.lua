

local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return 
end

local UnitExists = UnitExists
local atan2 = math.atan2
local pi = math.pi

--find distance between two players
function DF:GetDistance_Unit (unit1, unit2)
	if (UnitExists (unit1) and UnitExists (unit2)) then
		local u1X, u1Y = UnitPosition (unit1)
		local u2X, u2Y = UnitPosition (unit2)
		
		local dX = u2X - u1X
		local dY = u2Y - u1Y
		
		return ((dX*dX) + (dY*dY)) ^ .5
	end
	return 0
end

--find distance between two points
function DF:GetDistance_Point (x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return ((dx * dx) + (dy * dy)) ^ .5
end

--find a rotation for an object from a point to another point
function DF:FindLookAtRotation (x1, y1, x2, y2)
	return atan2 (y2 - y1, x2 - x1) + pi
end

--find the value scale between two given values. e.g: value of 500 in a range 0-100 result in 10 in a scale for 0-10
function DF:MapRangeClamped (inputX, inputY, outputX, outputY, value)
	return DF:GetRangeValue (outputX, outputY, Clamp (DF:GetRangePercent (inputX, inputY, value), 0, 1))
end

--find the value scale between two given values. e.g: value of 75 in a range 0-100 result in 7.5 in a scale for 0-10
function DF:MapRangeUnclamped (inputX, inputY, outputX, outputY, value)
	return DF:GetRangeValue (outputX, outputY, DF:GetRangePercent (inputX, inputY, value))
end

--find the normalized percent fo the value in the range. e.g range of 200-400 and a value of 250 result in 0.25
function DF:GetRangePercent (minValue, maxValue, value)
	return (value - minValue) / (maxValue - minValue)
end

--find the value in the range given from a normalized percent. e.g range of 200-400 and a percent of 0.8 result in 360
function DF:GetRangeValue (minValue, maxValue, percent)
	return Lerp (minValue, maxValue, percent)
end

--dot product of two vectors
function DF:GetDotProduct (v1, v2)
	return (v1.x * v2.x) + (v1.y * v2.y)
end

--normalized value 0-1 result in the value on the range given, e.g 200-400 range with a value of .5 result in 300
function DF:LerpNorm (minValue, maxValue, value)
	return (minValue + value * (maxValue - minValue))
end