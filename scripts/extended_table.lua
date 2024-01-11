local extended_table = {}

function extended_table.is_empty(table)
    if #table > 0 then
        return false
    end

    for _, _ in pairs(table) do
        return false
    end

    return true
end

function extended_table.is_present(table, element)
    for _, v in pairs(table) do
        if v == element then
            return true
        end
    end
    return false
end

function extended_table.slice(table, first, last, step)
    local sliced = {}

    for i = first or 1, last or #table, step or 1 do
        sliced[#sliced+1] = table[i]
    end

    return sliced
end

return extended_table