local util = require("util")
local extended_table = {}

function extended_table.deepcopy(tbl)
    return util.table.deepcopy(tbl)
end

function extended_table.is_empty(tbl)
    return next(tbl) == nil
end

function extended_table.is_present(tbl, element)
    for _, v in pairs(tbl) do
        if v == element then
            return true
        end
    end
    return false
end

function extended_table.to_set(tbl)
    local set = {}
    for _, v in pairs(tbl) do
        set[v] = true
    end
    return set
end

function extended_table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

function extended_table.extend_table(target, source)
    for _, value in pairs(source) do
        table.insert(target, value)
    end
end

function extended_table.merge_tables(target, source)
    for key, value in pairs(source) do
        target[key] = value
    end
end

return extended_table