local circuit_network_events = {}
local event_groups = {
    on_created_entity = {
        defines.events.on_built_entity,
        defines.events.on_robot_built_entity,
        defines.events.on_space_platform_built_entity,
        defines.events.script_raised_built,
        defines.events.script_raised_revive,
    },
    on_removed_entity = {
        defines.events.on_player_mined_entity,
        defines.events.on_robot_mined_entity,
        defines.events.on_space_platform_mined_entity,
        defines.events.script_raised_destroy,
        defines.events.on_entity_died
    }
}

defines.events = {
    -- Entities ignore biters stuff for now
    --yafla_on_pre_created_entity = {}, --TODO
    yafla_on_created_entity = {},
    --yafla_on_pre_removed_entity = {}, --TODO
    yafla_on_removed_entity = {},
    --yafla_on_pre_circuit_network_changed = {}, --TODO
    yafla_on_circuit_network_changed = {}
}


-- ------------------------------
-- Merged events
-- ------------------------------
script.on_event(event_groups.on_created_entity, function(event)
    if event.entity and event.entity.valid then
        --script.raise_event(defines.events.yafla_on_pre_created_entity, event)
        script.raise_event(defines.events.yafla_on_created_entity, event)
    end
end)

script.on_event(event_groups.on_removed_entity, function(event)
    if event.entity then
        --script.raise_event(defines.events.yafla_on_pre_removed_entity, event)
        script.raise_event(defines.events.yafla_on_removed_entity, event)
    end
end)


-- ------------------------------
-- Circuit network changed events
-- ------------------------------
local function player_has_circuit_wire_in_hand(player)
    if not (player and player.valid) then return false end
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read then
        if cursor_stack.name == "red-wire" or cursor_stack.name == "green-wire" then
            return true
        end
    end
    return false
end

local function entity_is_circuit_network_entity(entity)
    if not (entity and entity.valid) then return false end
    if entity.get_circuit_network(defines.wire_type.red) ~= nil then
        return true
    end
    if entity.get_circuit_network(defines.wire_type.green) ~= nil then
        return true
    end
    return false
end

script.on_event(defines.events.yafla_on_created_entity, function(event)
    if not (event.entity and event.entity.valid) then return end

    if not entity_is_circuit_network_entity(event.entity) then
        return
    end

    script.raise_event(defines.events.yafla_on_circuit_network_changed, event)
end)

script.on_event(defines.events.yafla_on_removed_entity, function(event)



    --script.raise_event(defines.events.yafla_on_circuit_network_changed, event)
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    if not (event.player_index) then return end
    local player = game.get_player(event.player_index)
    if player == nil then return end
    if player.is_cursor_empty() then return end
    if not player_has_circuit_wire_in_hand(player) or not player.selected then return end

    --???

    --script.raise_event(defines.events.yafla_on_circuit_network_changed, event)
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)


    --script.raise_event(defines.events.yafla_on_circuit_network_changed, event)
end)
