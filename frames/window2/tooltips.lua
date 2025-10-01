
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow

local damageTooltip = function(headerColumnFrame, actorObjects, windowFrame, line)
        windowFrame.atributo = 1
        windowFrame.sub_atributo = 1

        --back compatibility
        windowFrame.row_info = windowFrame.row_info or {}
        windowFrame.row_info.textL_translit_text = true

        Details.BuildInstanceBarTooltip(windowFrame, headerColumnFrame)

        GameCooltip:SetOption("MinWidth", 200)

        local keyDown = false
        actorObjects[1]:ToolTip_DamageDone(windowFrame, 1, 1, keyDown) --instance, numero, barra, keydown

        Details:PostBuildInstanceBarTooltip(actorObjects[1])
end

local tooltipScripts = {
    ---@param windowFrame details_allinonewindow_frame
    ---@param actorObjects actor[]
    ---@param headerColumnFrame details_allinonewindow_frame
    ---@param line details_allinonewindow_line
    ["dmg"] = function(headerColumnFrame, actorObjects, windowFrame, line)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line)
    end,
    ["dps"] = function(headerColumnFrame, actorObjects, windowFrame, line)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line)
    end,
    ["dmgdps"] = function(headerColumnFrame, actorObjects, windowFrame, line)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line)
    end,
    ["dmgdpspercent"] = function(headerColumnFrame, actorObjects, windowFrame, line)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line)
    end,

}

AllInOneWindow.TooltipScripts = tooltipScripts