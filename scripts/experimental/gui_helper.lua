local gui_helper = {}

---@param parent LuaGuiElement|LuaGui
---@param name string
---@return LuaGuiElement|nil
function gui_helper.find_element_recursive(parent, name)

    ---@param parent LuaGuiElement|LuaGui
    ---@return LuaGuiElement|nil
    local function recursive_search(parent)
        for _,element in pairs(parent.children or {}) do
            if element.name == name then
                return element
            end
        end

        for _,element in pairs(parent.children or {}) do
            local result = recursive_search(element)
            if result then
                return result
            end
        end

        return nil
    end

    return recursive_search(parent)
end


---@param parent LuaGuiElement|LuaGui
---@param name string
---@return LuaGuiElement|nil
function gui_helper.find_element_iterative(parent, name)
    local stack = {parent}

    while #stack > 0 do
        local current = table.remove(stack)
        local current_parent = current.parent

        for _, element in pairs(current_parent.children or {}) do
            if element.name == name then
                return element
            end
        end

        for _, element in pairs(current_parent.children or {}) do
            table.insert(stack, element)
        end
    end

    return nil
end


return gui_helper