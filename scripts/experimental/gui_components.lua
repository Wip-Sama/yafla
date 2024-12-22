local gui_builder = require("gui_builder")

local destroy_element = function(event)
    event.element.parent.parent.destroy()
    -- event.element.parent.parent.visible = false
end

gui_builder.register_handler("close", destroy_element)

function Close_button(extra_parameters)
    local element = {
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = "Close the window",
        style = "close_button",
        on_click = "close"
    }
    if not extra_parameters then return SPRITE_BUTTON(element) end
    for k, v in pairs(extra_parameters) do
        element[k] = v
    end
    return SPRITE_BUTTON(element)
end

function Pin_button(extra_parameters)
    local element = {
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = "Close the window",
        auto_toggle = true,
        style = "close_button",
    }
    if not extra_parameters then return SPRITE_BUTTON(element) end
    for k, v in pairs(extra_parameters) do
        element[k] = v
    end
    return SPRITE_BUTTON(element)
end

function Aritmetic_dropdown(extra_parameters)
    local element = {
        width = 60,
        items = {
            ">",
            "<",
            "=",
            "≥",
            "≤",
            "≠"
        },
        selected_index = 1,
    }
    if not extra_parameters then return DROP_DOWN(element) end
    for k, v in pairs(extra_parameters) do
        element[k] = v
    end
    return DROP_DOWN(element)
end

function Surface_dropdown(extra_parameters)
    local element = {
        items = {},
        selected_index = 1,
    }
    for _, v in pairs(game.surfaces) do
        table.insert(element.items, v.name)
    end
    if not extra_parameters then return DROP_DOWN(element) end
    for k, v in pairs(extra_parameters) do
        element[k] = v
    end
    return DROP_DOWN(element)
end

function Time_dropdown(extra_parameters)
    local element = {
        width = 80,
        items = {
            "sec",
            "min",
            "hours",
            "day",
            "month",
            "year"
        },
        selected_index = 1,
    }
    if not extra_parameters then return DROP_DOWN(element) end
    for k, v in pairs(extra_parameters) do
        element[k] = v
    end
    return DROP_DOWN(element)
end

---@param parent LuaGuiElement|nil Optional frame to move the parent from the hotbar
---@param pinnable boolean|nil If the hotbar should be pinnable
function Hotbar(parent, pinnable, close_button, extra_button, icon, title)
    return {
        FLOW {
            direction = "horizontal",
            style = "yafla_hotbar_flow",
            drag_target = parent,
            icon and SPRITE {
                sprite = icon,
                ignored_by_interaction = true,
                style = "yafla_hotbar_sprite"
            } or nil,
            title and LABEL {
                caption = title,
                ignored_by_interaction = true,
                style = "frame_title"
            } or nil,
            EMPTY_WIDGET {
                ignored_by_interaction = true,
                style = "yafla_drag_handle"
            },
            pinnable and Pin_button() or nil,
            close_button and Close_button() or nil,
            extra_button and extra_button or nil
        }
    }
end

function Window(player, extra_parameters)
    -- local element = {
    --     type = "frame",
    --     direction = "vertical",
    --     ref = { "window" },
    -- }

    local element = FRAME {
        direction = "vertical",
        ref = { "window" },
    }

    if extra_parameters then
        for k, v in pairs(BASE_PARAMETERS(extra_parameters)) do
            element[k] = v
        end
    end

    local window = player.gui.screen.add(element)

    if extra_parameters then
        for k, v in pairs(STYLE_PARAMETERS(extra_parameters)) do
            window.style[k] = v
        end
    end

    if not extra_parameters.extra_button then
        extra_parameters["extra_button"] = nil
    end
    if not extra_parameters.pinnable then
        extra_parameters["pinnable"] = false
    end
    if not extra_parameters.closable then
        extra_parameters["closable"] = false
    end

    gui_builder.build(
        window,
        Hotbar(window, extra_parameters.pinnable, extra_parameters.closable, extra_parameters.extra_button, extra_parameters.window_icon, extra_parameters.window_title),
        player.index
    )

    return window
end