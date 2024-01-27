local extended_table = {}

function extended_table.is_empty(tbl)
    if #tbl > 0 then
        return false
    end

    for _, _ in pairs(tbl) do
        return false
    end

    return true
end

function extended_table.is_present(tbl, element)
    for _, v in pairs(tbl) do
        if v == element then
            return true
        end
    end
    return false
end

function extended_table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

return extended_table