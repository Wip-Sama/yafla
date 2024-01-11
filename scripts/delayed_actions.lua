--[[
    nth_tick (tick the action should be executed)
    action (function to be executed)
    data (data/parameters to be passed to the function)
    WARNING: to ensure thath function work correctly assume that the function will be calld like this:
    fucntion(self)
        self.something
--]]
Actions_to_be_executed = Actions_to_be_executed or {}

function Delay_action(delay, action, custom_data)
    local tick = game.tick + delay

    table.insert(Actions_to_be_executed, {
        tick = tick,
        action = action,
        data = custom_data
    })
end

local function execute_delayed_actions(event)
    for k, v in pairs(Actions_to_be_executed) do
        if event.tick >= v.tick then
            if v.data then
                v['action'](v['data'])
            else
                v['action']()
            end
            Actions_to_be_executed[k] = nil
        end
    end
end

script.on_nth_tick(1, execute_delayed_actions)