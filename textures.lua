
---@type details
local Details = Details

function Details:GetTextureAtlas(atlasName)
    return Details.TextureAtlas[atlasName]
end

--atlasinfo
Details.TextureAtlas = {

    ["segment-icon-mythicplus-overall"] = {
        file = [[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]],
        width = 16,
        height = 16,
        leftTexCoord = 48/64,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        nativeWidth = 64,
        nativeHeight = 16,
    },

    ["segment-icon-mythicplus"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        width = 14,
        height = 10,
        leftTexCoord = 479/512,
        rightTexCoord = 510/512,
        topTexCoord = 24/512,
        bottomTexCoord = 51/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-empty"] = {
        file = [[Interface\AddOns\Details\images\empty16]],
        width = 12,
        height = 12,
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-broom"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        width = 12,
        height = 16,
        leftTexCoord = 14/512,
        rightTexCoord = 58/512,
        topTexCoord = 98/512,
        bottomTexCoord = 160/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-skull"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        width = 16,
        height = 16,
        leftTexCoord = 0.96875,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 0.03125,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-arena"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        width = 16,
        height = 12,
        leftTexCoord = 0.251953125,
        rightTexCoord = 0.306640625,
        topTexCoord = 0.205078125,
        bottomTexCoord = 0.248046875,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-boss"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        width = 16,
        height = 16,
        leftTexCoord = 0.96875,
        rightTexCoord = 1,
        topTexCoord = 0.0625,
        bottomTexCoord = 0.09375,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-regular"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-current"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        colorName = "orange",
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-overall"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        colorName = "orange",
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["broom"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        width = 44,
        height = 68,
        leftTexCoord = 14/512,
        rightTexCoord = 58/512,
        topTexCoord = 98/512,
        bottomTexCoord = 160/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-love-is-in-the-air"] = {
        leftTexCoord = 165/512,
        rightTexCoord = 201/512,
        topTexCoord = 98/512,
        bottomTexCoord = 131/512,
        width = 10,
        height = 9,
        tilesVertically = false,
        tilesHorizontally = false,
        file = [[Interface\AddOns\Details\images\icons]],
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["breakdown-icon-reportbutton"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        leftTexCoord = 249/512,
        rightTexCoord = 270/512,
        topTexCoord = 110/512,
        bottomTexCoord = 142/512,
        nativeWidth = 512,
        nativeHeight = 512,
        width = 10,
        height = 14,
        colorName = "silver",
    },

    ["breakdown-icon-optionsbutton"] = {
        file = [[Interface\AddOns\Details\images\icons]],
        leftTexCoord = 211/512,
        rightTexCoord = 243/512,
        topTexCoord = 110/512,
        bottomTexCoord = 139/512,
        nativeWidth = 512,
        nativeHeight = 512,
        width = 12,
        height = 12,
        colorName = "silver",
    }
}

C_Timer.After(1, function()
    --DetailsFramework:PreviewTexture(Details.TextureAtlas["segment-icon-arena"])
end)