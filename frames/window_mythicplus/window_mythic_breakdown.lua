
local Details = _G.Details
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale( "Details" )
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local UIParent = UIParent
local addonName, Details222 = ...
local detailsFramework = DetailsFramework
local _

local mPlus = Details222.MythicPlusBreakdown

function mPlus.ShowSummary()
    if (not mPlus.MainFrame) then
        mPlus.CreateMainFrame()
    end
end

function mPlus.CreateMainFrame()
    local mPlusFrame = CreateFrame("frame", "DetailsMythicPlusBreakdownFrame", UIParent, "BackdropTemplate")
    detailsFramework:AddRoundedCornersToFrame(mPlusFrame, Details.PlayerBreakdown.RoundedCornerPreset)
    mPlus.MainFrame = mPlusFrame

    PixelUtil.SetPoint(mPlusFrame, "center", UIParent, "center", 0, 0)
    PixelUtil.SetSize(mPlusFrame, Details222.BreakdownWindow.width, Details222.BreakdownWindow.height)

    
end


