local multi_events = require"scripts/multi_events"

local inventory = {x=0, y=0}
multi_events:enable(inventory)

--All items that could ever show up in the shop:
local all_items = {
    {item = "berries", price = 5, variant = 3,
      availability_variable = "available_in_shop_berries"},
    {item = "apples", price = 12, variant = 2,
      availability_variable = "available_in_shop_apples"},
    {item = "bread", price = 45, variant = 2,
      availability_variable = "available_in_shop_bread"},
    {item = "elixer", price = 100, variant = 1,
      availability_variable = "available_in_shop_elixer"},
    {item = "potion_magic_restoration", price = 50, variant = 1,
      availability_variable = "available_in_shop_magic_restoring_potion"},
    {item = "unattainable_collectable",price=0,variant=1,availability_variable="nil"},
    {item = "arrow", price = 10, variant = 3,
      availability_variable = "available_in_shop_arrows"},
    {item = "bomb", price = 30, variant = 3,
      availability_variable = "available_in_shop_bombs"},
    {item = "berries", price = 20, variant = 4,
      availability_variable = "available_in_shop_berries"},
    {item = "apples", price = 40, variant = 4,
      availability_variable = "available_in_shop_apples"},
    {item = "bread", price = 90, variant = 3,
      availability_variable = "available_in_shop_bread"},
    {item = "potion_stoneskin", price = 80, variant = 1,
      availability_variable = "available_in_shop_stoneskin_potion"},
    {item = "potion_burlyblade", price = 80, variant = 1,
      availability_variable = "available_in_shop_burlyblade_potion"},
    {item = "unattainable_collectable",price=0,variant=1,availability_variable="nil"},
    {item = "arrow", price = 40, variant = 5,
      availability_variable = "available_in_shop_arrows"},
    {item = "bomb", price = 60, variant = 4,
      availability_variable = "available_in_shop_bombs"},
}

--constants:
local GRID_ORIGIN_X = 48
local GRID_ORIGIN_Y = 121
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local ROWS = 2
local COLUMNS = 8
local MAX_INDEX = ROWS*COLUMNS - 1 --when every slot is full of an item, this should equal #all_items

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


--Set different array of items and prices for a shop to sell:
function inventory:set_items_for_sale(new_items)
  all_items = new_items
end


function inventory:initialize(game, item_array)
    --first, we don't need the hero walking around with the menu open, so
    game:get_hero():freeze()
    --if you provide an array of items, use that instead of that standard one
    if item_array then all_items = item_array end
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
    self.prices = {}

    --create the item sprites:
    for i=1, #all_items do
        if all_items[i].item ~= "" then
            local item = game:get_item(all_items[i].item)
            local variant = all_items[i].variant
                  --initialize the sprite if you can purchase this item
            if game:get_value(all_items[i].availability_variable) then
                self.item_sprites[i] = sol.sprite.create("entities/items")
                self.item_sprites[i]:set_animation(all_items[i].item)
                self.item_sprites[i]:set_direction(variant - 1)
                self.prices[i] = sol.text_surface.create{
                    horizontal_alignment = "center",
                    vertical_alignment = "top",
                    text = tostring(all_items[i].price),
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
end

function inventory:update_description_panel()
    --update description panel
    local game = sol.main.get_game()
    local item_info = all_items[cursor_index + 1]
    if self:get_item_at_current_index() and self.description_panel
    and game:get_value(item_info.availability_variable) then
        local desc_key = "item_desc.%s.%d" --key to lookup in strings.dat for item description
        self.description_panel:set_text_key(desc_key:format(item_info.item, item_info.variant))
        local price_string = sol.language.get_string("menu.shop.item_price")
        assert(price_string, "Error: strings.dat entry 'menu.shop.item_price' not found")
        self.price_panel:set_text(price_string:format(item_info.price))
    elseif self.description_panel then
        self.description_panel:set_text("")
        self.price_panel:set_text(" ")
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
        if game:get_value(all_items[cursor_index + 1].availability_variable) then
          game:start_dialog("_shop.purchase_confirm", function(answer)
            if answer == 2 then
              local current_item = all_items[cursor_index + 1]
              local current_amount
              local max_amount
              if current_item.item == "arrow" then
                current_amount = game:get_item("bow"):get_amount()
                max_amount = game:get_item("bow"):get_max_amount()

              elseif current_item.item == "bomb" then
                current_amount = game:get_item("bombs_counter_2"):get_amount()
                max_amount = game:get_item("bombs_counter_2"):get_max_amount()

              else
                current_amount = game:get_item(current_item.item):get_amount()
                max_amount = game:get_item(current_item.item):get_max_amount()
              end
              if current_amount == max_amount then
                --you don't have room for more
                game:start_dialog("_shop.no_room")
              elseif game:get_money() >= current_item.price then
                game:get_hero():start_treasure(current_item.item, current_item.variant)
                game:get_hero():freeze()
                game:remove_money(current_item.price)
              elseif game:get_money() < current_item.price then
                game:start_dialog"_game.insufficient_funds"
              end
            else
              --decided not to buy
            end
          end)
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
--            self.prices[i]:draw(dst_surface, x+8 + self.x, y+4 + self.y )
        end
    end
end

return inventory
