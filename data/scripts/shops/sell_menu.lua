local multi_events = require"scripts/multi_events"

local inventory = {x=0, y=0}
multi_events:enable(inventory)

--All items that you could sell:
local all_items = {
    {item = "burdock", price = 5},
    {item = "chamomile", price = 5},
    {item = "firethorn_berries", price = 5},
    {item = "forsythia", price = 5},
    {item = "ghost_orchid", price = 35},
    {item = "kingscrown", price = 25},
    {item = "lavendar", price = 5},
    {item = "witch_hazel", price = 10},
    {item = "mandrake", price = 15},
    {item = "mandrake_white", price = 40},
    {item = "geode", price = 10},
    {item = "monster_bones", price = 10},
    {item = "monster_guts", price = 5},
    {item = "monster_eye", price = 35},
    {item = "monster_horn", price = 30},
    {item = "monster_heart", price = 100},
}

--constants:
local GRID_ORIGIN_X = 48
local GRID_ORIGIN_Y = 121
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local ROWS = 2
local COLUMNS = 8
local MAX_INDEX = ROWS*COLUMNS --when every slot is full of an item, this should equal #all_items

local cursor_index

--// Gets/sets the x,y position of the menu in pixels
function inventory:get_xy() return self.x, self.y end
function inventory:set_xy(x, y)
    x = tonumber(x)
    assert(x, "Bad argument #2 to 'set_xy' (number expected)")
    y = tonumber(y)
    assert(y, "Bad argument #3 to 'set_xy' (number expected)")

    self.x = math.floor(x)
    self.y = math.floor(y)
end


function inventory:initialize(game)
    --first, we don't need the hero walking around with the menu open, so
    game:get_hero():freeze()
    --set the cursor index, or which item the cursor is over
    --remember, the cursor index is 0 based but the all_items table starts at 1
    --since the cursor index is zero based, so are rows and columns.
    --So if ROWS is set to 4, that means you have rows 0, 1, 2, and 3. I'm writing this here because I'm gonna forget.
    cursor_index = 0
    --initialize cursor's row and column
    self.cursor_column = 0
    self.cursor_row = 0
    --update cursor's row and column
    self:update_cursor_position(cursor_index)
    --initialize background (basically just the frame)
    self.menu_dark_overlay = sol.surface.create("menus/dark_overlay.png")
    self.menu_background = sol.surface.create("menus/shop_background.png")
    --initialize the cursor
    self.cursor_sprite = sol.sprite.create("menus/inventory/selector")
    --set the description panel text
    --pull correct font for language
    local font, font_size = require("scripts/language_manager"):get_dialog_font()
    self.description_panel = sol.text_surface.create{
      font = font, font_size = font_size,
      horizontal_alignment = "left",
      vertical_alignment = "top",
    }
    self.price_panel = sol.text_surface.create{
      font = font, font_size = font_size,
      horizontal_alignment = "left",
      vertical_alignment = "top",
    }
    --make some tables to store the item sprites and their numbers for amounts
    self.item_sprites = {}
    self.amounts = {}

    --create the item sprites:
    for i=1, #all_items do
        if all_items[i].item ~= "" then
            local item = game:get_item(all_items[i].item)
            --initialize the sprite if you can purchase this item
            if game:has_item(all_items[i].item) then
                self.item_sprites[i] = sol.sprite.create("entities/items")
                self.item_sprites[i]:set_animation(all_items[i].item)
                self.item_sprites[i]:set_direction(0)
                self.amounts[i] = sol.text_surface.create{
                    horizontal_alignment = "center",
                    vertical_alignment = "top",
                    text = tostring(game:get_item(all_items[i].item):get_amount()),
                    font = "white_digits"
                }
            end
        end
    end

end


function inventory:on_started()
  assert(sol.main.get_game(), "Error: cannot start shop menu because no game is currently running")
  sol.main.get_game():set_suspended(true)
  self:update_description_panel()
  self.menu_background:fade_in(5)
  self.menu_dark_overlay:fade_in(5)
end

function inventory:on_finished()
  sol.main.get_game():set_suspended(false)
  sol.main.get_game():get_hero():unfreeze()
  self.menu_background:fade_out(5)
  self.menu_dark_overlay:fade_out(5)
end



function inventory:update_cursor_position(new_index)
    local game = sol.main.get_game()
    if(new_index <= MAX_INDEX and new_index >= 0) then cursor_index = new_index
    elseif new_index > MAX_INDEX then cursor_index = 0
    elseif new_index < 0 then cursor_index = MAX_INDEX end
    local new_column = (cursor_index % COLUMNS)
    local new_row = math.floor(cursor_index / COLUMNS)

    if new_column < 0 then self.cursor_column = COLUMNS - 1
    elseif new_column > COLUMNS then self.cursor_column = 0
    else self.cursor_column = new_column end

    if new_row < 0 then self.cursor_row = ROWS - 1
    elseif new_row > ROWS then self.cursor_row = 0
    else self.cursor_row = new_row end

    self:update_description_panel()
--    print("column: " .. self.cursor_column .. " row: " .. self.cursor_row)
end

function inventory:update_description_panel()
    --update description panel
    local game = sol.main.get_game()
    local item_info = all_items[cursor_index + 1]
    if self:get_item_at_current_index() and self.description_panel
    and game:has_item(item_info.item) then
        self.description_panel:set_text_key("item."..item_info.item..".1")
        local price_string = sol.language.get_string("menu.sell.item_price")
        assert(price_string, "Error: strings.dat entry 'menu.sell.item_price' not found")
        self.price_panel:set_text(price_string:format(item_info.price))
    elseif self.description_panel then
        self.description_panel:set_text("")
        self.price_panel:set_text(" ")
    end
end

function inventory:update_amounts()
  local game = sol.main.get_game()
  for i = 1, #all_items do
    local new_amount = game:get_item(all_items[i].item):get_amount()
    if self.amounts[i] then
      self.amounts[i]:set_text(new_amount)
    end
  end
end


function inventory:on_command_pressed(command)
    local game = sol.main.get_game()
    local handled = false

    if command == "right" then
        sol.audio.play_sound("cursor")
        if self.cursor_column == COLUMNS - 1 then self:update_cursor_position(cursor_index - COLUMNS + 1)
        else self:update_cursor_position(cursor_index + 1) end
        handled = true
    elseif command == "left" then
        sol.audio.play_sound("cursor")
        if self.cursor_column == 0 then self:update_cursor_position(cursor_index + COLUMNS - 1)
        else self:update_cursor_position(cursor_index - 1) end
        handled = true
    elseif command == "up" then
        sol.audio.play_sound("cursor")
        if self.cursor_row == 0 then self:update_cursor_position(cursor_index + (COLUMNS * (ROWS - 1)))
        else self:update_cursor_position(cursor_index - COLUMNS) end
        handled = true
    elseif command == "down" then
        sol.audio.play_sound("cursor")
        if self.cursor_row == ROWS -1  then self:update_cursor_position(cursor_index - (COLUMNS * (ROWS - 1)))
        else self:update_cursor_position(cursor_index + COLUMNS) end
        handled = true

    elseif command == "action" then
        --the item here is all_items[cursor_index + 1]
        local current_item = all_items[cursor_index + 1]
        if game:get_item(current_item.item):get_amount() > 0 then
          game:add_money(current_item.price)
          game:get_item(current_item.item):remove_amount(1)
          inventory:update_amounts()
        end
        handled = true

    elseif command == "pause" then
      handled = true
      sol.menu.stop(self)

    elseif command == "attack" then
      handled = true
      game:get_hero():unfreeze()
      sol.menu.stop(self)
    end
    return handled
end

--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}

function inventory:on_joypad_axis_moved(axis, state)

  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state

  return handled
end


function inventory:get_item_at_current_index()
    local game = sol.main.get_game()
    local item_entry = all_items[cursor_index + 1]
    local item
    if item_entry then item = game:get_item(item_entry.item) end
    return item
end

function inventory:on_draw(dst_surface)
    --draw the elements
    self.menu_dark_overlay:draw(dst_surface)
    self.menu_background:draw(dst_surface, self.x, self.y)
    self.cursor_sprite:draw(dst_surface, (self.cursor_column * 32 + GRID_ORIGIN_X + 48) + self.x,  (self.cursor_row * 32 + GRID_ORIGIN_Y) + self.y)
    self.description_panel:draw(dst_surface, (GRID_ORIGIN_X) + 8 + self.x, (ROWS *32 + GRID_ORIGIN_Y - 8)+self.y)
    self.price_panel:draw(dst_surface, (GRID_ORIGIN_X) + 8 + self.x, (ROWS *32 + GRID_ORIGIN_Y + 8)+self.y)

    --draw inventory items
    for i=1, #all_items do
        if self.item_sprites[i] then
            --draw the item's sprite from the sprites table
            local x = ((i-1)%COLUMNS) * 32 + GRID_ORIGIN_EQUIP_X + 48
            local y = math.floor((i-1) / COLUMNS) * 32 + GRID_ORIGIN_EQUIP_Y
            self.item_sprites[i]:draw(dst_surface, x + self.x, y + self.y)
            --draw the item's counter
            self.amounts[i]:draw(dst_surface, x+8 + self.x, y+4 + self.y )
        end
    end
end

return inventory
