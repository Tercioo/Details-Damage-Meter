
local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return 
end

function DF:UnitDistance (unit1, unit2)
	if (UnitExists (unit1) and UnitExists (unit2)) then
		local u1X, u1Y = UnitPosition (unit1)
		local u2X, u2Y = UnitPosition (unit2)
		
		local dX = u2X-u1X
		local dY = u2Y-u1Y
		
		return sqrt ((dX*dX) + (dY*dY))
	end
	return 0
end