local extended_table = require("__yafla__.scripts.extended_table")
local gui_builder = {}

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
            -- don't copy factorio rich objects
        elseif object.__self then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}

        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end

        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- id of the element, function,
if not global.handlers then
    global.handlers = {}
end

Gui_handlers = Gui_handlers or {}

-- Assembler
local function add_custom_style(parent, style)
    if not parent.style then
        parent["style"] = {}
    end

    for k, v in pairs(style) do
        parent.style[k] = v
    end
end

local function add_advanced_properties(parent, parameters)
    for k, v in pairs(parameters) do
        parent[k] = v
    end
end

local function handle_events(event)
    if global.handlers[event.element.index] then
        for k, v in pairs(global.handlers[event.element.index]) do
            if k == event.name then
                Gui_handlers[script.mod_name][v](event)
            end
        end
    end
end

local actions_conversions = {
    on_click = defines.events.on_gui_click,
    on_selection_changed = defines.events.on_gui_selection_state_changed,
    on_elem_changed = defines.events.on_gui_elem_changed,
    on_text_changed = defines.events.on_gui_text_changed,
}

local function add_actions(element, actions)
    if not global.handlers[element.index] then
        global.handlers[element.index] = {}
    else
        error("Element with index " .. element.index .. " already has handlers")
    end

    for k, v in pairs(actions) do
        global.handlers[element.index][actions_conversions[k]] = global.handlers[element.index][actions_conversions[k]] or
            {}
        table.insert(global.handlers[element.index], actions_conversions[k], v)
    end
end

function gui_builder.register_handler(name, func)
    if not Gui_handlers[script.mod_name] then
        Gui_handlers[script.mod_name] = {}
    end
    if Gui_handlers[script.mod_name][name] then
        error("Handler with name " .. name .. " already exists")
    end
    Gui_handlers[script.mod_name][name] = func
end

function gui_builder.build(parent, elements)
    if #elements > 0 then
        for _, v in pairs(elements) do
            gui_builder.build(parent, v)
        end
        return
    end

    local childrens
    local actions
    local advanced_properties
    if elements.elements then
        childrens = elements.elements
        elements.elements = nil
    end
    if elements.actions then
        actions = elements.actions
        elements.actions = nil
    end
    if elements.advanced_properties then
        advanced_properties = elements.advanced_properties
        elements.advanced_properties = nil
    end

    local element = parent.add(elements)

    if elements.styles and type(elements.styles) == "table" then
        add_custom_style(element, elements.styles)
    end
    if advanced_properties then
        add_advanced_properties(element, advanced_properties)
    end
    if actions then
        add_actions(element, actions)
    end

    if childrens then
        for _, v in pairs(childrens) do
            gui_builder.build(element, v)
        end
    end

    return element
end

-- Components
local function add_parameters(element, parameters)
    if parameters then
        for k, v in pairs(parameters) do
            element[k] = v
        end
    end
end

local function validate_base_parameters(self)
    return {
        name = self.name,
        caption = self.caption,
        tooltip = self.tooltip,
        enabled = self.enabled,
        visible = self.visible,
        ignored_by_interaction = self.ignored_by_interaction,
        tags = self.tags,
        index = self.index,
        anchor = self.anchor,
        game_controller_interaction = self.game_controller_interaction,
        raise_hover_events = self.raise_hover_events,
        style = self.style
    }
end

---column_alignments
local function validate_style_parameters(self)
    return {
        minimal_width = self.minimal_width,
        maximal_width = self.maximal_width,
        minimal_height = self.minimal_height,
        maximal_height = self.maximal_height,
        natural_width = self.natural_width,
        natural_height = self.natural_height,
        top_padding = self.top_padding,
        right_padding = self.right_padding,
        bottom_padding = self.bottom_padding,
        left_padding = self.left_padding,
        top_margin = self.top_margin,
        right_margin = self.right_margin,
        bottom_margin = self.bottom_margin,
        left_margin = self.left_margin,
        horizontal_align = self.horizontal_align,
        vertical_align = self.vertical_align,
        font_color = self.font_color,
        font = self.font,
        top_cell_padding = self.top_cell_padding,
        right_cell_padding = self.right_cell_padding,
        bottom_cell_padding = self.bottom_cell_padding,
        left_cell_padding = self.left_cell_padding,
        horizontally_stretchable = self.horizontally_stretchable,
        vertically_stretchable = self.vertically_stretchable,
        horizontally_squashable = self.horizontally_squashable,
        vertically_squashable = self.vertically_squashable,
        rich_text_setting = self.rich_text_setting,
        hovered_font_color = self.hovered_font_color,
        clicked_font_color = self.clicked_font_color,
        disabled_font_color = self.disabled_font_color,
        pie_progress_color = self.pie_progress_color,
        clicked_vertical_offset = self.clicked_vertical_offset,
        selected_font_color = self.selected_font_color,
        selected_hovered_font_color = self.selected_hovered_font_color,
        selected_clicked_font_color = self.selected_clicked_font_color,
        strikethrough_color = self.strikethrough_color,
        draw_grayscale_picture = self.draw_grayscale_picture,
        horizontal_spacing = self.horizontal_spacing,
        vertical_spacing = self.vertical_spacing,
        use_header_filler = self.use_header_filler,
        bar_width = self.bar_width,
        color = self.color,
        --column_alignments = self.column_alignments,
        single_line = self.single_line,
        extra_top_padding_when_activated = self.extra_top_padding_when_activated,
        extra_bottom_padding_when_activated = self.extra_bottom_padding_when_activated,
        extra_left_padding_when_activated = self.extra_left_padding_when_activated,
        extra_right_padding_when_activated = self.extra_right_padding_when_activated,
        extra_top_margin_when_activated = self.extra_top_margin_when_activated,
        extra_bottom_margin_when_activated = self.extra_bottom_margin_when_activated,
        extra_left_margin_when_activated = self.extra_left_margin_when_activated,
        extra_right_margin_when_activated = self.extra_right_margin_when_activated,
        stretch_image_to_widget_size = self.stretch_image_to_widget_size,
        badge_font = self.badge_font,
        badge_horizontal_spacing = self.badge_horizontal_spacing,
        default_badge_font_color = self.default_badge_font_color,
        selected_badge_font_color = self.selected_badge_font_color,
        disabled_badge_font_color = self.disabled_badge_font_color,
        width = self.width,
        height = self.height,
        size = self.size,
        padding = self.padding,
        margin = self.margin,
        cell_padding = self.cell_padding,
        extra_padding_when_activated = self.extra_padding_when_activated,
        extra_margin_when_activated = self.extra_margin_when_activated,
    }
end

local function inplement_parameters(element, parameters)
    add_parameters(element, validate_base_parameters(parameters))

    local style_parameters = validate_style_parameters(parameters)

    if not extended_table.is_empty(style_parameters) then
        element["styles"] = {}
        for k, v in pairs(style_parameters) do
            element.styles[k] = v
        end
    end
end

-- STRUCTURE ELEMENTS
-- flow, frame, label, table, empty-widget

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#frame
function FRAME(self, direction, ref, drag_target)
    local element = { type = "frame", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["direction"] = self.direction
    element["ref"] = self.ref

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    element["advanced_properties"]["drag_target"] = self.drag_target

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#flow
function FLOW(self, elements, base_parameters, style_parameters, direction, drag_target)
    local element = { type = "flow", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["direction"] = self.direction

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    element["advanced_properties"]["drag_target"] = self.drag_target

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#list-box
function LIST_BOX(self, items, base_parameters, style_parameters)
    local element = { type = "list-box", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["items"] = self.items

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#table
function TABLE(self, items, base_parameters, style_parameters)
    local element = { type = "table", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["column_count"] = self.column_count
    element["draw_vertical_lines"] = self.draw_vertical_lines
    element["draw_horizontal_lines"] = self.draw_horizontal_lines
    element["draw_horizontal_line_after_headers"] = self.draw_horizontal_line_after_headers
    element["vertical_centering"] = self.vertical_centering

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#scroll-pane
function SCROLL_PANE(self, items, base_parameters, style_parameters)
    local element = { type = "scroll-pane", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["horizontal_scroll_policy"] = self.horizontal_scroll_policy
    element["vertical_scroll_policy"] = self.vertical_scroll_policy

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

-- END ELEMENTS

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#sprite-button
function SPRITE_BUTTON(self)
    local element = { type = "sprite-button", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["sprite"] = self.sprite
    element["hovered_sprite"] = self.hovered_sprite
    element["clicked_sprite"] = self.clicked_sprite
    element["number"] = self.number
    element["show_percent_for_small_numbers"] = self.show_percent_for_small_numbers
    element["mouse_button_filter"] = self.mouse_button_filter
    element["auto_toggle"] = self.auto_toggle
    element["toggled"] = self.toggled

    element["actions"]["on_click"] = self.on_click

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#button
function BUTTON(self)
    local element = { type = "button", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["mouse_button_filter"] = self.mouse_button_filter
    element["auto_toggle"] = self.auto_toggle
    element["toggled"] = self.toggled

    element["actions"]["on_click"] = self.on_click

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#radiobutton
function RADIOBUTTON(self, base_parameters, style_parameters, state, on_click)
    local element = { type = "radiobutton", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["state"] = self.state

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    element["actions"]["on_click"] = self.on_click

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#sprite
function SPRITE(self, sprite, resize_to_sprite)
    local element = { type = "sprite", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["sprite"] = self.sprite
    element["resize_to_sprite"] = self.resize_to_sprite

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#label
function LABEL(self)
    local element = { type = "label", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#empty-widget
function EMPTY_WIDGET(self, drag_target)
    local element = { type = "empty-widget", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["advanced_properties"]["drag_target"] = self.drag_target

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#choose-elem-button
function CHOOSE_ELEM_BUTTON(self)
    local element = { type = "choose-elem-button", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["elem_type"] = self.elem_type
    element["item"] = self.item
    element["tile"] = self.tile
    element["entity"] = self.entity
    element["signal"] = self.signal
    element["fluid"] = self.fluid
    element["recipe"] = self.recipe
    element["decorative"] = self.decorative
    element["item-group"] = self.item_group
    element["achievement"] = self.achievement
    element["equipment"] = self.equipment
    element["technology"] = self.technology
    element["elem_filters"] = self.elem_filters

    element["actions"]["on_elem_changed"] = self.on_elem_changed

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#line
function LINE(self, direction)
    local element = { type = "line", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["direction"] = self.direction

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#drop-down
function DROP_DOWN(self, items, selected_index)
    local element = { type = "drop-down", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["items"] = self.items
    element["selected_index"] = self.selected_index
    element["actions"]["on_selection_changed"] = self.on_selection_changed

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#textfield
function TEXTFIELD(self, items, selected_index)
    local element = { type = "textfield", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["text"] = self.text
    element["numeric"] = self.numeric
    element["allow_decimal"] = self.allow_decimal
    element["allow_negative"] = self.allow_negative
    element["is_password"] = self.is_password
    element["lose_focus_on_confirm"] = self.lose_focus_on_confirm
    element["clear_and_focus_on_right_click"] = self.clear_and_focus_on_right_click

    element["actions"]["on_text_changed"] = self.on_text_changed

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end

---https://lua-api.factorio.com/latest/classes/LuaGuiElement.html#checkbox
function CHECKBOX(self, items, selected_index)
    local element = { type = "checkbox", advanced_properties = {}, actions = {} }

    inplement_parameters(element, self)

    element["state"] = self.state

    element["elements"] = {}
    for i = 1, #self do
        table.insert(element["elements"], self[i])
    end

    if extended_table.is_empty(element.advanced_properties) then element.advanced_properties = nil end
    if extended_table.is_empty(element.actions) then element.actions = nil end

    return element
end


function BASE_PARAMETERS(self, name, caption, tooltip, enabled, visible, ignored_by_interaction, tags, index, anchor,
                        game_controller_interaction, raise_hover_events, style)
    return {
        name = self.name,
        caption = self.caption,
        tooltip = self.tooltip,
        enabled = self.enabled,
        visible = self.visible,
        ignored_by_interaction = self.ignored_by_interaction,
        tags = self.tags,
        index = self.index,
        anchor = self.anchor,
        game_controller_interaction = self.game_controller_interaction,
        raise_hover_events = self.raise_hover_events,
        style = self.style
    }
end

function STYLE_PARAMETERS(self, minimal_width, maximal_width, minimal_height, maximal_height, natural_width,
                          natural_height, top_padding, right_padding, bottom_padding, left_padding, top_margin,
                          right_margin, bottom_margin, left_margin, horizontal_align, vertical_align, font_color, font,
                          top_cell_padding, right_cell_padding, bottom_cell_padding, left_cell_padding,
                          horizontally_stretchable, vertically_stretchable, horizontally_squashable,
                          vertically_squashable, rich_text_setting, hovered_font_colo, clicked_font_color,
                          disabled_font_color, pie_progress_color, clicked_vertical_offset,
                          selected_font_color, selected_hovered_font_color, selected_clicked_font_color,
                          strikethrough_color, draw_grayscale_picture, horizontal_spacing, vertical_spacing,
                          use_header_filler, bar_width, color, column_alignments, single_line,
                          extra_top_padding_when_activated, extra_bottom_padding_when_activated,
                          extra_left_padding_when_activated, extra_right_padding_when_activated,
                          extra_top_margin_when_activated, extra_bottom_margin_when_activated,
                          extra_left_margin_when_activated, extra_right_margin_when_activated,
                          stretch_image_to_widget_size, badge_font, badge_horizontal_spacing, default_badge_font_color,
                          selected_badge_font_color, disabled_badge_font_color, width, height, size, padding, margin,
                          cell_padding, extra_padding_when_activated, extra_margin_when_activated)
    return {
        minimal_width = self.minimal_width,
        maximal_width = self.maximal_width,
        minimal_height = self.minimal_height,
        maximal_height = self.maximal_height,
        natural_width = self.natural_width,
        natural_height = self.natural_height,
        top_padding = self.top_padding,
        right_padding = self.right_padding,
        bottom_padding = self.bottom_padding,
        left_padding = self.left_padding,
        top_margin = self.top_margin,
        right_margin = self.right_margin,
        bottom_margin = self.bottom_margin,
        left_margin = self.left_margin,
        horizontal_align = self.horizontal_align,
        vertical_align = self.vertical_align,
        font_color = self.font_color,
        font = self.font,
        top_cell_padding = self.top_cell_padding,
        right_cell_padding = self.right_cell_padding,
        bottom_cell_padding = self.bottom_cell_padding,
        left_cell_padding = self.left_cell_padding,
        horizontally_stretchable = self.horizontally_stretchable,
        vertically_stretchable = self.vertically_stretchable,
        horizontally_squashable = self.horizontally_squashable,
        vertically_squashable = self.vertically_squashable,
        rich_text_setting = self.rich_text_setting,
        hovered_font_color = self.hovered_font_color,
        clicked_font_color = self.clicked_font_color,
        disabled_font_color = self.disabled_font_color,
        pie_progress_color = self.pie_progress_color,
        clicked_vertical_offset = self.clicked_vertical_offset,
        selected_font_color = self.selected_font_color,
        selected_hovered_font_color = self.selected_hovered_font_color,
        selected_clicked_font_color = self.selected_clicked_font_color,
        strikethrough_color = self.strikethrough_color,
        draw_grayscale_picture = self.draw_grayscale_picture,
        horizontal_spacing = self.horizontal_spacing,
        vertical_spacing = self.vertical_spacing,
        use_header_filler = self.use_header_filler,
        bar_width = self.bar_width,
        color = self.color,
        column_alignments = self.column_alignments,
        single_line = self.single_line,
        extra_top_padding_when_activated = self.extra_top_padding_when_activated,
        extra_bottom_padding_when_activated = self.extra_bottom_padding_when_activated,
        extra_left_padding_when_activated = self.extra_left_padding_when_activated,
        extra_right_padding_when_activated = self.extra_right_padding_when_activated,
        extra_top_margin_when_activated = self.extra_top_margin_when_activated,
        extra_bottom_margin_when_activated = self.extra_bottom_margin_when_activated,
        extra_left_margin_when_activated = self.extra_left_margin_when_activated,
        extra_right_margin_when_activated = self.extra_right_margin_when_activated,
        stretch_image_to_widget_size = self.stretch_image_to_widget_size,
        badge_font = self.badge_font,
        badge_horizontal_spacing = self.badge_horizontal_spacing,
        default_badge_font_color = self.default_badge_font_color,
        selected_badge_font_color = self.selected_badge_font_color,
        disabled_badge_font_color = self.disabled_badge_font_color,
        width = self.width,
        height = self.height,
        size = self.size,
        padding = self.padding,
        margin = self.margin,
        cell_padding = self.cell_padding,
        extra_padding_when_activated = self.extra_padding_when_activated,
        extra_margin_when_activated = self.extra_margin_when_activated,
    }
end


script.on_event(defines.events.on_gui_text_changed, handle_events)
script.on_event(defines.events.on_gui_selection_state_changed, handle_events)
script.on_event(defines.events.on_gui_elem_changed, handle_events)
script.on_event(defines.events.on_gui_click, handle_events)

return gui_builder
