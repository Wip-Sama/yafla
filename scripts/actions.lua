--[[
    {
        tick (tick the action should be executed)
        action (function to be executed)
        data (data/parameters to be passed to the function)
    }
--]]
Actions_to_be_executed = Actions_to_be_executed or {}
--[[
    {
        next_execution (tick the action should be executed)
        interval (interval between executions expressed in updates (ticks))
        action (function to be executed)
        data (data/parameters to be passed to the function)
    }
--]]
Actions_to_be_looped = Actions_to_be_looped or {}

local actions = {}

--[[   
    WARNING: the parameters will be passed as a table so imagine your function in this way:
    `fucntion(self)
        print(self.something)
    end`
--]]
---@param delay number How many ticks to wait before executing the action
---@param action function The function to be executed
---@param custom_data any|nil The data to be passed to the function
---@return nil
function actions.delay_action(delay, action, custom_data)
    local tick = game.tick + delay

    table.insert(Actions_to_be_executed, {
        tick = tick,
        action = action,
        data = custom_data
    })
end

--[[   
    WARNING: the parameters will be passed as a **table** so imagine your function in this way:
    '' fucntion(self)
        print(self.something)
    end ''
--]]
---@param interval number How many ticks to wait before executing the action
---@param action function The function to be executed
---@param last_execution_tick number|nil The tick the action was last executed
---@param custom_data any|nil The data to be passed to the function
---@return string action_id
function actions.loop_action(interval, action, last_execution_tick, custom_data)
    if game == nil then
        game = { tick = 0 }
    end
    local action_id = tostring(game.tick).."_"..tostring(#Actions_to_be_looped)

    Actions_to_be_looped[action_id] = {
        next_execution = game.tick + interval,
        last_execution_tick = last_execution_tick or -1,
        interval = interval,
        action = action,
        data = custom_data,
    }
    return action_id
end

---@param action_id string The id of the action to be retrived
---@return table|nil
function actions.get_loop_action(action_id)
    if Actions_to_be_looped[action_id] then
        return Actions_to_be_looped[action_id]
    end
    return nil
end

---@param action_id string The id of the action to be stopped
---@return nil
function actions.stop_loop_action(action_id)
    if action_id ~= nil and Actions_to_be_looped[action_id] then
        Actions_to_be_looped[action_id] = nil
    end
end

---@return nil
function actions.stop_all_actions()
    Actions_to_be_looped = nil
end

local function execute_delayed_actions(event)
    for k, action in pairs(Actions_to_be_executed) do
        if event.tick >= action.tick then
            if action.data then
                action['action'](action['data'])
            else
                action['action']()
            end
            Actions_to_be_executed[k] = nil
        end
    end
    for k, action in pairs(Actions_to_be_looped) do
        if event.tick >= action.next_execution then
            if action.data then
                action['action'](action['data'])
            else
                action['action']()
            end
            if action.last_execution_tick and action.last_execution_tick ~= -1 and (event.tick + action.interval) > action.last_execution_tick then
                Actions_to_be_looped[k] = nil
            else
                Actions_to_be_looped[k].next_execution = event.tick + action.interval
            end
        end
    end
end

script.on_nth_tick(1, execute_delayed_actions)

return actions