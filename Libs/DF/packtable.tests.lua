
--this file isn't loaded, the tests need to be copied, loaded and run.

function PackTest()
    local table = {1, 2, 3, 4, 5}
    local packed = DetailsFramework.table.pack(table)
    print("Testing table.pack, table: {1, 2, 3, 4, 5}")
    local expected = "\"5,1,2,3,4,5\""
    print("Expected: string ", expected)
    print("Result:     " .. type(packed) .. "  \"" .. packed .. "\"")
end

function PackSubTest()
    local table = { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }
    local packed = DetailsFramework.table.packsub(table)
    print("Testing table.packsub, table: { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }")
    local expected = "\"3,1,2,3,3,4,5,6,3,7,8,9\""
    print("Expected: string ", expected)
    print("Result:     " .. type(packed) .. "  \"" .. packed .. "\"")
end

function PackSubMergeTest()
    local table = { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }
    local packed = DetailsFramework.table.packsubmerge(table)
    print("Testing table.packsubmerge, table: { {1, 2, 3}, {4, 5, 6}, {7, 8, 9} }")
    local expected = "\"9,1,2,3,4,5,6,7,8,9\""
    print("Expected: string ", expected)
    print("Result:     " .. type(packed) .. "  \"" .. packed .. "\"")
end

function UnpackTest()
    local packed = "5,1,2,3,4,5"
    local table, nextIndex = DetailsFramework.table.unpack(packed)
    print("Testing table.unpack, data: \"5,1,2,3,4,5\"")
    local expected = "table {1, 2, 3, 4, 5}, 0"
    print("Expected:", expected)
    print("Result:     " .. type(table) .. " {" .. table[1] .. ", " .. table[2] .. ", " .. table[3] .. ", " .. table[4] .. ", " .. table[5] .. "},", nextIndex)
end

function UnpackSecondTest()
    local packed = "5,1,2,3,4,5,2,5,4,3,1,2,3"
    local table, nextIndex = DetailsFramework.table.unpack(packed, 7)
    print("Testing table.unpack with Idx 7, data: \"5,1,2,3,4,5,2,5,4,3,1,2,3\"")
    local expected = "table {5, 4}, 10"
    print("Expected:", expected)
    print("Result:     " .. type(table) .. " {" .. table[1] .. ", " .. table[2] .. "},", nextIndex)
end

function UnpackSubTest()
    local packed = "3,1,2,3,3,4,5,6,3,7,8,9"
    local tables = DetailsFramework.table.unpacksub(packed)
    print("Testing table.unpacksub, data: \"3,1,2,3,3,4,5,6,3,7,8,9\"")
    local expected = "table {table {1, 2, 3}, table {4, 5, 6}, table {7, 8, 9}}"
    print("Expected:", expected)
    print("Result:     " .. type(tables) .. " {" .. type(tables[1]) .. " {" .. tables[1][1] .. ", " .. tables[1][2] .. ", " .. tables[1][3] .. "}, " .. type(tables[2]) .. " {" .. tables[2][1] .. ", " .. tables[2][2] .. ", " .. tables[2][3] .. "}, " .. type(tables[3]) .. " {" .. tables[3][1] .. ", " .. tables[3][2] .. ", " .. tables[3][3] .. "}}")
end