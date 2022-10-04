
--todo: GetText(addonId, phraseId)
--todo: SetText(addonId, phraseId, FontString, ...)
--todo: embed on FontString .SetTextByPhraseID(fontString, addonId, phraseId, ...)

--[=[
    DetailsFramework.Language.Register(addonId, languageId, gameLanguageOnly)
        create a language table within an addon namespace
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
        @gameLanguageOnly: if true won't allow to register a language not supported by the game, a supported language is any language returnted by GetLocale()
        return value: return a table named languageTable, this table holds translations for the registered language

        The returned table can be used to add localized phrases:
        --example 1:
        local newLanguageTable = DetailsFramework.Language.Register("Details", "enUS", true)
        newLanguageTable["My Phrase"] = "My Phrase"

        --example 2:
        local newLanguageTable = DetailsFramework.Language.Register(_G.Details, "valyrianValyria", false)
        newLanguageTable["STRING_MY_PHRASE"] = "ñuha udrir"

    DetailsFramework.Language.GetLanguageTable(addonId, languageId)
        get the languageTable for the requested languageId within the addon namespace
        if languageId is not passed, uses the current language set for the addonId
        the default languageId for the addon is the first language registered with DetailsFramework.Language.Register()
        the languageId will be overrided when the language used by the client is registered with DetailsFramework.Language.Register()
        the default languageId can also be changed by calling DetailsFramework.Language.SetCurrentLanguage() as seen below
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
        return value: languageTable

        --example 1:
        local languageTable = DetailsFramework.Language.GetLanguageTable("Details")
        fontString:SetText(languageTable["My Phrase"])
        --example 2:
        local languageTable = DetailsFramework.Language.GetLanguageTable("Details", "valyrianValyria")
        fontString:SetText(languageTable["STRING_MY_PHRASE"])

    DetailsFramework.Language.SetCurrentLanguage(addonId, languageId)
        set the language used by default when retriving a languageTable with DF.Language.GetLanguageTable() and not passing the second argument (languageId) within the call
        use this in combination with a savedVariable to use a language of the user choice
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)

    DetailsFramework.Language.RegisterFontString(addonId, fontString, phraseId, silent, ...)
        when setting a languageId with DetailsFramework.Language.SetCurrentLanguage(), automatically change the text of all registered FontStrings
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @fontString: a UIObject FontString
        @phraseId: any string to identify the a translated text, example: "My Phrase", "STRING_TEXT_LENGTH", text: "This is my phrase"
        @silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId
        @vararg: arguments to pass for format(text, ...)

    DetailsFramework.Language.UpdateFontStringArguments(addonId, fontString, ...)
        update the arguments (...) of a registered FontString, if no argument passed it'll erase the arguments previously set
        the FontString need to be already registered with DetailsFramework.Language.RegisterFontString()
        the font string text will be changed to update the text with the new arguments
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @fontString: a UIObject FontString
        @vararg: arguments to pass for format(text, ...)
--]=]

local DF = _G["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local CONST_LANGUAGETABLE_NOTFOUND = "!languageTable"
local CONST_LANGAGEID_ENUS = "enUS"

local supportedGameLanguages = {
    ["deDE"] = true,
    [CONST_LANGAGEID_ENUS] = true,
    ["esES"] = true,
    ["esMX"] = true,
    ["frFR"] = true,
    ["itIT"] = true,
    ["koKR"] = true,
    ["ptBR"] = true,
    ["ruRU"] = true,
    ["zhCN"] = true,
    ["zhTW"] = true,
}

--create languages namespace
DF.Language = {
    RegisteredNamespaces = {},
}

--internal functions

local setLanguageTable = function(addonNamespaceTable, languageId, languageTable)
    addonNamespaceTable.languages[languageId] = languageTable
    return languageTable
end

local getLanguageTable = function(addonNamespaceTable, languageId)
    local languageTable = addonNamespaceTable.languages[languageId]
    if (not languageTable) then
        return false
    end
    return languageTable
end

local getRegisteredFontStrings = function(addonNamespaceTable)
    return addonNamespaceTable.fontStrings
end

local getTextFromLangugeTable = function(languageTable, phraseId)
    return languageTable and languageTable[phraseId] or phraseId
end

local getCurrentLanguageId = function(addonNamespaceTable)
    return addonNamespaceTable.currentLanguageId
end

local setCurrentLanguageId = function(addonNamespaceTable, languageId)
    addonNamespaceTable.currentLanguageId = languageId
end

local getText = function(addonNamespaceTable, phraseId)
    local currentLanguageId = getCurrentLanguageId(addonNamespaceTable) --never nil
    local languageTable = getLanguageTable(addonNamespaceTable, currentLanguageId) --can be nil if the languageId isn't registered yet

    --if the languageTable is invalid, let the function caller handle it
    --note: languageTable is always valid when the callstack started at from DF.Language.SetCurrentLanguage
    if (not languageTable) then
        return CONST_LANGUAGETABLE_NOTFOUND
    end

    --getTextFromLangugeTable always return the text found or the phraseId if the text isn't found
    local text = getTextFromLangugeTable(languageTable, phraseId)
    if (text ~= phraseId) then
        return text
    end

    --attempt to get the text from the default language used in the client
    local clientLanguage = GetLocale()
    if (currentLanguageId ~= clientLanguage) then
        languageTable = getLanguageTable(addonNamespaceTable, clientLanguage)
        text = getTextFromLangugeTable(languageTable, phraseId)
    end
    if (text ~= phraseId) then
        return text
    end

    --attempt to get from english
    if (currentLanguageId ~= CONST_LANGAGEID_ENUS and clientLanguage ~= CONST_LANGAGEID_ENUS) then
        languageTable = getLanguageTable(addonNamespaceTable, CONST_LANGAGEID_ENUS)
        text = getTextFromLangugeTable(languageTable, phraseId)
    end

    return text
end

local isAddonIDValid = function(addonId)
    if (type(addonId) ~= "string" and type(addonId) ~= "table") then
        return false
    end
    return true
end

local isFontStringValid = function(fontString)
    if (type(fontString) ~= "table" or not fontString.GetObjectType or fontString:GetObjectType() ~= "FontString") then
        return false
    end
    return true
end

local updateFontStringTableArguments = function(fontStringTable, ...)
    local argumentAmount = select("#", ...)
    if (argumentAmount > 0) then
        fontStringTable.arguments = {...}
    else
        fontStringTable.arguments = nil
    end
end

local registerFontString = function(addonNamespaceTable, fontString, phraseId, ...)
    local argumentAmount = select("#", ...)
    local fontStringTable = {phraseId = phraseId}

    if (argumentAmount > 0) then
        fontStringTable.arguments = {...}
    end

    addonNamespaceTable.fontStrings[fontString] = fontStringTable
    return fontStringTable
end

local setFontStringText = function(fontString, fontStringTable, text)
    if (fontStringTable.arguments) then
        fontString:SetText(format(text, unpack(fontStringTable.arguments)))
    else
        fontString:SetText(text)
    end
end

local getFontStringTable = function(addonNamespaceTable, fontString)
    return addonNamespaceTable.fontStrings[fontString]
end

--iterate among all registered fontStrings of an addon namespace and set the new text on them
local updateAllRegisteredFontStringText = function(addonNamespaceTable, languageTable)
    local fontStrings = getRegisteredFontStrings(addonNamespaceTable)
    for fontString, fontStringTable in pairs(fontStrings) do
        local phraseId = fontStringTable.phraseId
        --note: text is always valid when the callstack started at from DF.Language.SetCurrentLanguage
        local text = getText(addonNamespaceTable, phraseId)
        setFontStringText(fontString, fontStringTable, text)
    end
end

--always create a new namespace if isn't registered yet
local getOrCreateAddonNamespace = function(addonId, languageId)
    local addonNamespaceTable = DF.Language.RegisteredNamespaces[addonId]
    if (not addonNamespaceTable) then
        addonNamespaceTable = {
            --by default, the current language is the first registered language
            currentLanguageId = languageId,
            languages = {},
            fontStrings = {},
        }
        DF.Language.RegisteredNamespaces[addonId] = addonNamespaceTable
    end

    --if the language being register is the language being in use by the client, set this language as current language
    --this can be changed later with DF.Language.SetCurrentLanguage(addonId, languageId)
    local clientLanguage = GetLocale()
    if (languageId == clientLanguage) then
        addonNamespaceTable.currentLanguageId = languageId
    end

    return addonNamespaceTable
end

local getAddonNamespace = function(addonId)
    return DF.Language.RegisteredNamespaces[addonId]
end

--create a language table within an addon namespace
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
--@gameLanguageOnly: if true won't allow to register a language not supported by the game, a supported language is any language returnted by GetLocale()
--return value: return a languageTable, this table holds translations for the registered language
function DF.Language.Register(addonId, languageId, gameLanguageOnly)
    if (not isAddonIDValid(addonId)) then
        error("DetailsFramework.Language.Register: require a table or string on #1 argument, use: .Register(addonId, languageID [, gameLanguageOnly]).")

    elseif (gameLanguageOnly and not supportedGameLanguages[languageId]) then
        error("DetailsFramework.Language.Register: require a languageID supported by the game on #2 argument, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    --get the language namespace, the namespace can be a string or a table.
    --if the namespace isn't created yet, this function will create
    local addonNamespaceTable = getOrCreateAddonNamespace(addonId, languageId)

    --create a table to hold traslations for this languageId
    local languageTable = {}
    setLanguageTable(addonNamespaceTable, languageId, languageTable)

    return languageTable
end

--get the languageTable for the requested languageId within the addon namespace
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
--return value: languageTable
function DF.Language.GetLanguageTable(addonId, languageId)
    if (not isAddonIDValid(addonId)) then
        error("DetailsFramework.Language.GetLanguageTable: require a table or string on #1 argument, use: .Get(addonId [, languageID]).")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error("DetailsFramework.Language.GetLanguageTable: no languages registered for this addonId, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    --if languageId was not been passed, use the current language
    if (not languageId) then
        languageId = getCurrentLanguageId(addonNamespaceTable)
    end

    local languageTable = getLanguageTable(addonNamespaceTable, languageId)
    if (not languageTable) then
        error("DetailsFramework.Language.GetLanguageTable: languageID not registered, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    return languageTable
end

--set the language used when retriving a languageTable with DF.Language.GetLanguageTable() without passing the second argument (languageId)
--use this in combination with a savedVariable to use a language of the user choice
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
function DF.Language.SetCurrentLanguage(addonId, languageId)
    if (not isAddonIDValid(addonId)) then
        error("DetailsFramework.Language.SetCurrentLanguage: require a table or string on #1 argument, use: .SetCurrentLanguage(addonId, languageID).")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error("DetailsFramework.Language.GetLanguageTable: no languages registered for this addonId, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    local languageTable = getLanguageTable(addonNamespaceTable, languageId)
    if (not languageTable) then
        error("DetailsFramework.Language.SetCurrentLanguage: languageID not registered, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    setCurrentLanguageId(languageId)

    --go into the registered FontStrings and change their text
    updateAllRegisteredFontStringText(addonNamespaceTable, languageTable)
    return true
end

--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@fontString: a UIObject FontString
--@phraseId: any string to identify the a translated text, example: token: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
--@silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId
--@vararg: arguments to pass for format(text, ...)
function DF.Language.RegisterFontString(addonId, fontString, phraseId, silent, ...)
    if (not isAddonIDValid(addonId)) then
        error("DetailsFramework.Language.RegisterFontString: require a table or string on #1 argument, use: .RegisterFontString(addonId, fontString, token, silent, ...).")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error("DetailsFramework.Language.RegisterFontString: no languages registered for this addonId, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    if (type(fontString) ~= "table" or not fontString.GetObjectType or fontString:GetObjectType() ~= "FontString") then
        error("DetailsFramework.Language.RegisterFontString: require a FontString on #2 argument, use: .RegisterFontString(addonId, fontString, token, silent, ...).")
    end

    local fontStringTable = registerFontString(addonNamespaceTable, fontString, phraseId, ...)

    local text = getText(addonNamespaceTable, phraseId)
    if (text == CONST_LANGUAGETABLE_NOTFOUND) then
        if (not silent) then
            error("DetailsFramework.Language.RegisterFontString: require a table or string on #1 argument, use: .RegisterFontString(addonId, fontString, token, silent, ...).")
        else
            fontString:SetText(phraseId)
            return true
        end
    end

    if (text == phraseId and not silent) then
        error("DetailsFramework.Language.RegisterFontString: token not found, use: .Get(addonId, languageId)['TOKEN'] = 'translated text'.")
    end

    setFontStringText(fontString, fontStringTable, text)
    return true
end

--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@fontString: a UIObject FontString
--@vararg: arguments to pass for format(text, ...)
function DF.Language.UpdateFontStringArguments(addonId, fontString, ...)
    if (not isAddonIDValid(addonId)) then
        error("DetailsFramework.Language.UpdateFontStringArguments: require a table or string on #1 argument, use: .RegisterFontString(addonId, fontString, token, silent, ...).")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error("DetailsFramework.Language.UpdateFontStringArguments: no languages registered for this addonId, use: .Register(addonId, languageID [, gameLanguageOnly]).")
    end

    if (not isFontStringValid(fontString)) then
        error("DetailsFramework.Language.UpdateFontStringArguments: require a FontString on #2 argument, use: .UpdateFontStringArguments(addonId, fontString, ...).")
    end

    local fontStringTable = getFontStringTable(addonNamespaceTable, fontString)
    if (not fontStringTable) then
        error("DetailsFramework.Language.UpdateFontStringArguments: FontString not registered for the addonId, use: .RegisterFontString(addonId, fontString, phraseId, silent, ...).")
    end
    updateFontStringTableArguments(fontStringTable, ...)

    local text = getText(addonNamespaceTable, fontStringTable.phraseId)
    setFontStringText(fontString, fontStringTable, text)
    return true
end