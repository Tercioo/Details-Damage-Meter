
--Details Framework examples for the lines.lua file
--a panel with four pairs of draggable knobs, each pair joined by a different kind of line
--drag the knobs around, click the physics knobs to shake the rope

local detailsFramework = DetailsFramework

local panel = DetailsFrameworkLinesExample or detailsFramework:CreateSimplePanel(UIParent, 640, 480, "Lines", "DetailsFrameworkLinesExample")
panel:SetPoint("center")

--creates a small square the user can drag inside the panel
local createKnob = function(x, y)
	local knob = CreateFrame("button", nil, panel, "BackdropTemplate")
	knob:SetSize(16, 16)
	knob:SetPoint("bottomleft", panel, "bottomleft", x, y)
	knob:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
	knob:SetBackdropColor(0.2, 0.2, 0.2, 1)
	knob:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
	knob:SetFrameLevel(panel:GetFrameLevel() + 10)
	knob:SetMovable(true)
	knob:SetClampedToScreen(true)
	knob:RegisterForDrag("LeftButton")
	knob:SetScript("OnDragStart", knob.StartMoving)
	knob:SetScript("OnDragStop", knob.StopMovingOrSizing)
	return knob
end

--straight solid line
local straightStart = createKnob(40, 400)
local straightEnd = createKnob(260, 420)
local straightLine = detailsFramework:CreateLine(panel, nil, {thickness = 2, color = {1, 0.82, 0, 1}})
straightLine:SetStartAnchor(straightStart, "center")
straightLine:SetEndAnchor(straightEnd, "center")

--dotted line: square dots, the gap twice the dot size
local dottedStart = createKnob(340, 400)
local dottedEnd = createKnob(580, 420)
local dottedLine = detailsFramework:CreateLine(panel, nil, {thickness = 3, dash_length = 3, gap_length = 6})
dottedLine:SetStartAnchor(dottedStart, "center")
dottedLine:SetEndAnchor(dottedEnd, "center")

--hanging rope, drawn as a curve each time a knob moves
local ropeStart = createKnob(40, 260)
local ropeEnd = createKnob(260, 260)
local hangingRope = detailsFramework:CreateLine(panel, nil, {line_type = "rope", thickness = 2, slack = 1.3, color = {0.6, 0.9, 0.3, 1}})
hangingRope:SetStartAnchor(ropeStart, "bottom")
hangingRope:SetEndAnchor(ropeEnd, "bottom")

--rope with physics, it swings when a knob moves and settles by itself
local physicsStart = createKnob(340, 260)
local physicsEnd = createKnob(580, 260)
--impulse_variation makes each click swing the rope a little differently
local physicsRope = detailsFramework:CreateLine(panel, nil, {line_type = "physics", thickness = 2, rope_length = 320, color = {0.4, 0.8, 1, 1}, impulse_variation = 0.6})
physicsRope:SetStartAnchor(physicsStart, "bottom")
physicsRope:SetEndAnchor(physicsEnd, "bottom")

local shakeRope = function()
	physicsRope:ApplyImpulse(0, 8)
end
physicsStart:SetScript("OnClick", shakeRope)
physicsEnd:SetScript("OnClick", shakeRope)

--a dashed rope with physics hanging from one fixed point and one knob
local dashedPhysicsEnd = createKnob(320, 120)
local dashedPhysicsRope = detailsFramework:CreateLine(panel, nil, {line_type = "physics", thickness = 2, dash_length = 8, gap_length = 4, slack = 1.5})
dashedPhysicsRope:SetStartPosition(100, 160)
dashedPhysicsRope:SetEndAnchor(dashedPhysicsEnd, "center")
