
--todo: GetText(addonId, phraseId)
--todo: SetText(addonId, phraseId, FontString, ...)

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

local functionSignature = {
    ["RegisterLanguage"] = "RegisterLanguage(addonID, languageID [, gameLanguageOnly])",
    ["SetCurrentLanguage"] = "SetCurrentLanguage(addonID, languageID)",
    ["GetLanguageTable"] = "GetLanguageTable(addonID [, languageID])",
    ["RegisterFontString"] = "RegisterFontString(addonID, fontString, phraseID [, silent] [, ...]])",
    ["UpdateFontStringArguments"] = "UpdateFontStringArguments(addonID, fontString, ...)",
    ["GetText"] = "GetText(addonID, phraseID [, silent])",
}

local functionCallPath = {
    ["RegisterLanguage"] = "DetailsFramework.Language.RegisterLanguage",
    ["SetCurrentLanguage"] = "DetailsFramework.Language.SetCurrentLanguage",
    ["GetLanguageTable"] = "DetailsFramework.Language.GetLanguageTable",
    ["RegisterFontString"] = "DetailsFramework.Language.RegisterFontString",
    ["UpdateFontStringArguments"] = "DetailsFramework.Language.UpdateFontStringArguments",
    ["GetText"] = "DetailsFramework.Language.GetText",
}

local errorText = {
    ["AddonID"] = "require a valid addonID (table or string) on #%d argument",
    ["LanguageID"] = "require a languageID supported by the game on #%d argument",
    ["PhraseID"] = "require a string on #%d argument",
    ["NoLanguages"] = "no languages registered for addonId",
    ["LanguageIDNotRegistered"] = "languageID not registered",
    ["PhraseIDNotRegistered"] = "phraseID not registered",
    ["FontString"] = "require a FontString on #%d argument",
    ["FontStringNotRegistered"] = "FontString not registered yet",
}


--create languages namespace
DF.Language = {
    RegisteredNamespaces = {},
}

--internal functions

local isValid_AddonID = function(addonId)
    if (type(addonId) ~= "string" and type(addonId) ~= "table") then
        return false
    end
    return true
end

local isValid_PhraseID = function(phraseId)
    return type(phraseId) == "string"
end

local isValid_Text = function(text)
    return type(text) == "string"
end

local isValid_FontString = function(fontString)
    if (type(fontString) ~= "table" or not fontString.GetObjectType or fontString:GetObjectType() ~= "FontString") then
        return false
    end
    return true
end


--always create a new namespace if isn't registered yet
local getOrCreateAddonNamespace = function(addonId, languageId)
    local addonNamespaceTable = DF.Language.RegisteredNamespaces[addonId]
    if (not addonNamespaceTable) then
        addonNamespaceTable = {
            addonId = addonId,
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

--just get the addon namespace returning nil if not registered yet
local getAddonNamespace = function(addonId)
    return DF.Language.RegisteredNamespaces[addonId]
end

local getLanguageTable = function(addonNamespaceTable, languageId)
    local languageTable = addonNamespaceTable.languages[languageId]
    if (not languageTable) then
        return false
    end
    return languageTable
end

local getCurrentLanguageId = function(addonNamespaceTable)
    return addonNamespaceTable.currentLanguageId
end

local getTextFromLangugeTable = function(languageTable, phraseId)
    return languageTable[phraseId]
end

local getRegisteredFontStrings = function(addonNamespaceTable)
    return addonNamespaceTable.fontStrings
end

local getText = function(addonNamespaceTable, phraseId)
    local currentLanguageId = getCurrentLanguageId(addonNamespaceTable) --never nil
    local languageTable = getLanguageTable(addonNamespaceTable, currentLanguageId) --can be nil if the languageId isn't registered yet

    --if the languageTable is invalid, let the function caller handle it
    --note: languageTable is always valid when the callstack started at from DF.Language.SetCurrentLanguage
    if (not languageTable) then
        return false
    end

    local text = getTextFromLangugeTable(languageTable, phraseId)
    if (isValid_Text(text)) then
        return text
    end

    --attempt to get the text from the default language used in the client
    local clientLanguage = GetLocale()
    if (currentLanguageId ~= clientLanguage) then
        languageTable = getLanguageTable(addonNamespaceTable, clientLanguage)
        text = getTextFromLangugeTable(languageTable, phraseId)
        if (isValid_Text(text)) then
            return text
        end
    end

    --attempt to get from english
    if (currentLanguageId ~= CONST_LANGAGEID_ENUS and clientLanguage ~= CONST_LANGAGEID_ENUS) then
        languageTable = getLanguageTable(addonNamespaceTable, CONST_LANGAGEID_ENUS)
        text = getTextFromLangugeTable(languageTable, phraseId)
        if (isValid_Text(text)) then
            return text
        end
    end

    return false
end

local setLanguageTable = function(addonNamespaceTable, languageId, languageTable)
    addonNamespaceTable.languages[languageId] = languageTable
    return languageTable
end

local setCurrentLanguageId = function(addonNamespaceTable, languageId)
    addonNamespaceTable.currentLanguageId = languageId
end

local getFontStringTable = function(addonNamespaceTable, fontString)
    return addonNamespaceTable.fontStrings[fontString]
end

local parseFontStringArguments = function(...)
    local argumentAmount = select("#", ...)
    if (argumentAmount > 0) then
        return {...}
    else
        return nil
    end
end

local updateFontStringTable_Arguments = function(fontStringTable, ...)
    fontStringTable.arguments = parseFontStringArguments(...)
end

local updateFontStringTable_PhraseId = function(fontStringTable, phraseId)
    fontStringTable.phraseId = phraseId
end

local setFontString_InternalMembers = function(fontString, addonId, phraseId, arguments)
    fontString.__languageAddonId = addonId or fontString.__languageAddonId
    fontString.__languagePhraseId = phraseId or fontString.__languagePhraseId
    fontString.__languageArguments = arguments or fontString.__languageArguments
end

local setFontString_Text = function(fontString, fontStringTable, text)
    if (fontStringTable.arguments) then
        fontString:SetText(format(text, unpack(fontStringTable.arguments)))
    else
        fontString:SetText(text)
    end
end

--this method only exists on registered FontStrings
local fontStringMethod_SetTextByPhraseID = function(fontString, phraseId, ...)
    local addonId = fontString.__languageAddonId
    local addonNamespaceTable = getAddonNamespace(addonId)

    local fontStringTable = getFontStringTable(addonNamespaceTable, fontString)
    updateFontStringTable_PhraseId(fontStringTable, phraseId)
    updateFontStringTable_Arguments(fontStringTable, ...)
    setFontString_InternalMembers(fontString, addonId, phraseId, fontStringTable.arguments)

    local text = getText(addonNamespaceTable, phraseId)
    setFontString_Text(fontString, fontStringTable, text)

    return true
end

local registerFontString = function(addonNamespaceTable, fontString, phraseId, ...)
    local fontStringTable = {phraseId = phraseId}
    fontStringTable.arguments = parseFontStringArguments(...)

    addonNamespaceTable.fontStrings[fontString] = fontStringTable

    --save internal information about the language directly in the FontString
    setFontString_InternalMembers(fontString, addonNamespaceTable.addonId, phraseId, fontStringTable.arguments)

    fontString.SetTextByPhraseID = fontStringMethod_SetTextByPhraseID

    return fontStringTable
end

--iterate among all registered fontStrings of an addon namespace and set the new text on them
local updateAllRegisteredFontStringText = function(addonNamespaceTable, languageTable)
    local fontStrings = getRegisteredFontStrings(addonNamespaceTable)
    for fontString, fontStringTable in pairs(fontStrings) do
        local phraseId = fontStringTable.phraseId
        --note: text is always valid when the callstack started at from DF.Language.SetCurrentLanguage
        local text = getText(addonNamespaceTable, phraseId)
        setFontString_Text(fontString, fontStringTable, text)
    end
end


--create a language table within an addon namespace
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
--@gameLanguageOnly: if true won't allow to register a language not supported by the game, a supported language is any language returnted by GetLocale()
--return value: return a languageTable, this table holds translations for the registered language
function DF.Language.RegisterLanguage(addonId, languageId, gameLanguageOnly)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["RegisterLanguage"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")

    elseif (gameLanguageOnly and not supportedGameLanguages[languageId]) then
        error(functionCallPath["RegisterLanguage"] .. ": " .. format(errorText["LanguageID"], 2) .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
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
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["GetLanguageTable"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["GetLanguageTable"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["GetLanguageTable"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    --if languageId was not been passed, use the current language
    if (not languageId) then
        languageId = getCurrentLanguageId(addonNamespaceTable)
    end

    local languageTable = getLanguageTable(addonNamespaceTable, languageId)
    if (not languageTable) then
        error(functionCallPath["GetLanguageTable"] .. ": " .. errorText["LanguageIDNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    return languageTable
end


--set the language used when retriving a languageTable with DF.Language.GetLanguageTable() without passing the second argument (languageId)
--use this in combination with a savedVariable to use a language of the user choice
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
function DF.Language.SetCurrentLanguage(addonId, languageId)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["SetCurrentLanguage"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["SetCurrentLanguage"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["SetCurrentLanguage"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    local languageTable = getLanguageTable(addonNamespaceTable, languageId)
    if (not languageTable) then
        error(functionCallPath["SetCurrentLanguage"] .. ": " .. errorText["LanguageIDNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
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
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["RegisterFontString"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["RegisterFontString"] .. ".")
    end

    if (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["RegisterFontString"] .. ": " .. format(errorText["PhraseID"], 3) .. ", use: " .. functionSignature["RegisterFontString"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["RegisterFontString"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (type(fontString) ~= "table" or not fontString.GetObjectType or fontString:GetObjectType() ~= "FontString") then
        error(functionCallPath["RegisterFontString"] .. ": " .. format(errorText["FontString"], 2) .. ", use: " .. functionSignature["RegisterFontString"] .. ".")
    end

    local fontStringTable = registerFontString(addonNamespaceTable, fontString, phraseId, ...)

    local text = getText(addonNamespaceTable, phraseId)
    if (not isValid_Text(text)) then
        if (not silent) then
            error(functionCallPath["RegisterFontString"] .. ": " .. errorText["PhraseIDNotRegistered"] .. ", use: " .. functionSignature["GetLanguageTable"] .. "['PhraseID'] = 'translated text'.")
        else
            text = phraseId
        end
    end

    setFontString_Text(fontString, fontStringTable, text)
    return true
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@fontString: a UIObject FontString
--@vararg: arguments to pass for format(text, ...)
function DF.Language.UpdateFontStringArguments(addonId, fontString, ...)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["UpdateFontStringArguments"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["UpdateFontStringArguments"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["UpdateFontStringArguments"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (not isValid_FontString(fontString)) then
        error(functionCallPath["UpdateFontStringArguments"] .. ": " .. format(errorText["FontString"], 2) .. ", use: " .. functionSignature["UpdateFontStringArguments"] .. ".")
    end

    local fontStringTable = getFontStringTable(addonNamespaceTable, fontString)
    if (not fontStringTable) then
        error(functionCallPath["UpdateFontStringArguments"] .. ": " .. errorText["FontStringNotRegistered"] .. ", use: " .. functionSignature["RegisterFontString"] .. ".")
    end
    updateFontStringTable_Arguments(fontStringTable, ...)

    local text = getText(addonNamespaceTable, fontStringTable.phraseId)
    setFontString_Text(fontString, fontStringTable, text)
    return true
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@phraseId: any string to identify the a translated text, example: phraseId: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
--@silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId
function DF.Language.GetText(addonId, phraseId, silent)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["GetText"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["GetText"] .. ".")

    elseif (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["GetText"] .. ": " .. format(errorText["PhraseID"], 2) .. ", use: " .. functionSignature["GetText"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["GetText"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    local text = getText(addonNamespaceTable, phraseId)
    if (isValid_Text(text)) then
        return text
    end

    if (not silent) then
        error(functionCallPath["GetText"] .. ": " .. errorText["PhraseIDNotRegistered"] .. ", use: " .. functionSignature["GetLanguageTable"] .. "['PhraseID'] = 'translated text'.")
    end

    return phraseId
end