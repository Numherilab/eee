local multi_events = require"scripts/multi_events"

local inventory = {x=0, y=0}
multi_events:enable(inventory)

--All items that could ever show up in the inventory:
local all_equipment_items = {
    {item = "bow", assignable = true,},
    {item = "bombs_counter_2", assignable = true,},
    {item = "barrier", assignable = true,},
    {item = "ball_and_chain", assignable = true},
    {item = "boomerang", assignable = true,},
    {item = "spear", assignable = true,},
    {item = "bow_warp", assignable = true,},
    {item = "bow_bombs", assignable = true,},
    {item = "bow_fire", assignable = true,},
    {item = "iron_candle", assignable = true},
    {item = "ether_bombs", assignable = true},
    {item = "homing_eye", assignable = true},
    {item = "berries", assignable = false,},
    {item = "apples", assignable = false,},
    {item = "bread", assignable = false,},
    {item = "elixer", assignable = false,},
    {item = "thunder_charm", assignable = true,},
    {item = "leaf_tornado", assignable = true,},
    {item = "potion_magic_restoration", assignable = false,},
    {item = "potion_stoneskin", assignable = false,},
    {item = "potion_burlyblade", assignable = false,},
    {item = "potion_fleetseed", assignable = false,},
    {item = "gust", assignable = true,},
--    {item = "crystal_spark", assignable = true,},
    {item = "abyssal_flame", assignable = true,},
--    {item = "cyclone_charm", assignable = true,},
--    {item = "unattainable_collectable", assignable = false},
--    {item = "unattainable_collectable", assignable = false},
--    {item = "unattainable_collectable", assignable = false},
--    {item = "unattainable_collectable", assignable = false},
}

--All collectable items
local all_collectables = {
  "coral_ore",
  "unattainable_collectable",
  "unattainable_collectable",
  "unattainable_collectable",
  "burdock",
  "chamomile",
--  "dandelion_seeds",
  "firethorn_berries",
--  "forsythia",
  "ghost_orchid",
  "kingscrown",
  "lavendar",
--  "violets",
  "witch_hazel",
  "unattainable_collectable",
  "mandrake_white",
  "mandrake",
--  "monkshood",
  "geode",
  "monster_bones",
  "monster_eye",
  "monster_guts",
  "monster_heart",
--  "monster_horn",
}

--All plants (for achievement)
local all_plants = {
  "burdock",
  "chamomile",
  "firethorn_berries",
  "ghost_orchid",
  "kingscrown",
  "lavendar",
  "witch_hazel",
}

--All monster parts (for achievement)
local all_monster_parts = {
  "mandrake_white",
  "mandrake",
  "geode",
  "monster_bones",
  "monster_eye",
  "monster_guts",
  "monster_heart",
}

--constants:
local GRID_ORIGIN_X = 26
local GRID_ORIGIN_Y = 72
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local ROWS = 4
local COLUMNS = 6
local MAX_INDEX = ROWS*COLUMNS --when every slot is full of an item, this should equal #all_equipment_items

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
  --handle life and magic
  self.life_surface = sol.surface.create()
  self.magic_surface = sol.surface.create()
-- idk why I initially put this function on a timer?...
--  sol.timer.start(require"scripts/menus/pause_menu", 10, function() inventory:update_life_and_magic() end)
  self:update_life_and_magic()

    --set the cursor index, or which item the cursor is over
    --remember, the cursor index is 0 based but the all_equipment_items table starts at 1
    --since the cursor index is zero based, so are rows and columns.
    --So if ROWS is set to 4, that means you have rows 0, 1, 2, and 3. I'm writing this here because I'm gonna forget.
    cursor_index = game:get_value("inventory_cursor_index") or 0
    --initialize cursor's row and column
    self.cursor_column = 0
    self.cursor_row = 0
    --update cursor's row and column
    self:update_cursor_position(cursor_index)
    --initialize background (basically just the frame)
    if not self.menu_background then
      self.menu_background = sol.surface.create("menus/inventory/inventory_background.png")
    end
    --initialize the cursor
    self.cursor_sprite = sol.sprite.create("menus/inventory/selector")

    --pull correct font for language
    local font, font_size = require("scripts/language_manager"):get_dialog_font()

    --set the description panel text
    self.description_panel = sol.text_surface.create{
      font = font, font_size = font_size,
      horizontal_alignment = "center",
      vertical_alignment = "top",
    }
    --make some tables to store the item sprites and their numbers for amounts
    self.equipment_sprites = {}
    self.counters = {}
    self.collectable_sprites = {}
    self.collectable_counters = {}

    --create the item sprites:
    for i=1, #all_equipment_items do
        local item_name = all_equipment_items[i].item
        if item_name ~= "" then
            local item = game:get_item(item_name)
            local variant = item:get_variant()
            if variant > 0 then
                --initialize the sprite
                local equipment_sprite = sol.sprite.create("entities/items")
                equipment_sprite:set_animation(item_name)
-- If an item is assignable, it might have variants
-- If it isn't assignable, it likely has "amounts" as variants, which we don't want to show up in the inventory
                if all_equipment_items[i].assignable then
                  equipment_sprite:set_direction(variant - 1)
                else
                  equipment_sprite:set_direction(0)
                end
                self.equipment_sprites[i] = equipment_sprite

                --if the item has an amount, make a counter in the counters table
                if item:has_amount() then
                    local amount = item:get_amount()
                    local font = "white_digits"
                    if amount >= item:get_max_amount() then font = "green_digits" end
                    self.counters[i] = sol.text_surface.create{
                        horizontal_alignment = "center",
                        vertical_alignment = "top",
                        text = item:get_amount(),
                        font = font
                    }
                end
            end
        end
    end

    --create collectable item sprites
    for i=1, #all_collectables do
      if all_collectables[i] then
        local collectable_string = all_collectables[i]
        local item = game:get_item(collectable_string)
        local variant = item:get_variant()
        if variant > 0 then
          local sprite = sol.sprite.create("entities/items")
          sprite:set_animation(collectable_string)
          sprite:set_direction(0)
          self.collectable_sprites[i] = sprite
          local amount = item:get_amount()
          local font = "white_digits"
          if amount >= item:get_max_amount() then font = "green_digits" end
          self.collectable_counters[i] = sol.text_surface.create{
              horizontal_alignment = "center",
              vertical_alignment = "top",
              text = item:get_amount(),
              font = font
          }
        end
      end
    end

    --Icons for passive items: charms, curse
    self.oak_charm_sprite = sol.sprite.create("entities/items")
    self.oak_charm_sprite:set_animation"oak_charm"
    if game:has_item("oak_charm") then
      self.oak_charm_sprite:set_opacity(255)
    else
      self.oak_charm_sprite:set_opacity(0)
    end

    self.dandelion_sprite = sol.sprite.create("entities/items")
    self.dandelion_sprite:set_animation"dandelion_charm"
    if game:has_item("dandelion_charm") then
      self.dandelion_sprite:set_opacity(255)
    else
      self.dandelion_sprite:set_opacity(0)
    end


    --get assigned item sprites
    self:initialize_assigned_item_sprites(game)

end

function inventory:update_life_and_magic()
  local game = sol.main.get_game()
  local has_half_heart = game:get_life() % 2
  self.max_life = math.floor(game:get_max_life() / 2)
  self.life = math.floor(game:get_life() / 2)
  self.magic = math.floor(game:get_magic() / 3)
  for i=1, self.max_life do
    local stitch
    if i <= self.life then
      stitch = sol.sprite.create("menus/inventory/life_stitch")
    elseif has_half_heart == 1 and i == self.life + 1 then
      stitch = sol.sprite.create("menus/inventory/life_half_stitch")
    else
      stitch = sol.sprite.create("menus/inventory/life_empty_stitch")
    end
    stitch:draw(self.life_surface, i * 8 - 4, 8)
  end
  for i=1, self.magic do
    local stitch = sol.sprite.create("menus/inventory/magic_stitch")
    stitch:draw(self.magic_surface, i * 4, 8)
  end

end

--get sprites for assigned items
function inventory:initialize_assigned_item_sprites(game)
    if game:get_item_assigned(1) then
        local assigned_sprite = sol.sprite.create("entities/items")
        local ass_item = game:get_item_assigned(1) or game:get_item("unattainable_collectable")
        assigned_sprite:set_animation(ass_item:get_name())
        assigned_sprite:set_direction(ass_item:get_variant()-1)
        self.assigned_item_sprite_1 = assigned_sprite
    else
      self.assigned_item_sprite_1 = nil
    end
    if game:get_item_assigned(2) then
        local assigned_sprite = sol.sprite.create("entities/items")
        local ass_item = game:get_item_assigned(2) or game:get_item("unattainable_collectable")
        assigned_sprite:set_animation(ass_item:get_name() or "empty")
        assigned_sprite:set_direction(ass_item:get_variant()-1)
        self.assigned_item_sprite_2 = assigned_sprite
    else
      self.assigned_item_sprite_2 = nil
    end
end


function inventory:on_started()
    assert(sol.main.get_game(), "Error: cannot start inventory menu because no game is currently running")
    local game = sol.main.get_game()
    self:update_description_panel()

    --if in hard mode, display an icon
    if game:get_value"hard_mode" then
      self.curse_icon = sol.sprite.create"menus/curse_icon"
    else
      self.curse_icon = nil
    end

    --Check if every item has been collected for achievement
    local has_all_items = true
    for i, v in ipairs(all_equipment_items) do
      if not game:has_item(v.item) then has_all_items = false end
    end
    if has_all_items then sol.achievements.unlock("ach_all_items") end

    --Check if every ingredient has been collected for achievement
    local has_all_plants = true
    for i, v in ipairs(all_plants) do
      if not game:has_item(v) then has_all_plants = false end
    end
    if has_all_plants then sol.achievements.unlock("ach_all_plants") end

    local has_all_monster_parts = true
    for i, v in ipairs(all_monster_parts) do
      if not game:has_item(v) then has_all_monster_parts = false end
    end
    if has_all_monster_parts then sol.achievements.unlock("ach_all_monster_parts") end

    --Check if all 4 magic spells have been collected for achievement
    local magic_spells = {"thunder_charm", "leaf_tornado", "abyssal_flame", "gust"}
    local has_all_spells = true
    for _, v in ipairs(magic_spells) do
      if not game:has_item(v) then has_all_spells = false end
    end
    if has_all_spells then sol.achievements.unlock("ach_magic_spells") end

end


--new_index is 0 based
function inventory:update_cursor_position(new_index)
    local game = sol.main.get_game()
    if(new_index < MAX_INDEX and new_index >= 0) then cursor_index = new_index end
    local new_column = (cursor_index % COLUMNS)
    self.cursor_column = new_column
    local new_row = math.floor(cursor_index / COLUMNS)
    if new_row < ROWS then self.cursor_row = new_row end
    game:set_value("inventory_cursor_index", cursor_index)
    self:update_description_panel()
--    print("column: " .. self.cursor_column .. " row: " .. self.cursor_row)
end

function inventory:update_description_panel()
    --update description panel
    if self.description_panel then
        local item = self:get_item_at_current_index()
        if item then
--          local item_desc = sol.language.get_string("item."..item:get_name().."." .. item:get_variant()) or ""
--          local item_desc = sol.language.get_string("item."..item:get_name()..".1") or ""
          local item_desc
          if all_equipment_items[cursor_index + 1].assignable then
            item_desc = sol.language.get_string("item."..item:get_name().."." .. item:get_variant()) or ""
          else
            item_desc = sol.language.get_string("item."..item:get_name()..".1") or ""
          end
--
          self.description_panel:set_text(item_desc)
        else self.description_panel:set_text("")
        end
    end
end


function inventory:on_command_pressed(command)
  local game = sol.main.get_game()
  local handled = false
  if not handled then
    if command == "right" then
        if self.cursor_column == COLUMNS - 1 then return false end
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index + 1)
        handled = true
    elseif command == "left" then
        if self.cursor_column == 0 then return false end
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index -1)
        handled = true
    elseif command == "up" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index - COLUMNS)
        handled = true
    elseif command == "down" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index + COLUMNS)
        handled = true

    elseif command == "item_1" then
        local item = self:get_item_at_current_index()
        if item and item:is_assignable() then
            game:set_item_assigned(1, item)
            sol.audio.play_sound("ok_l")
        else sol.audio.play_sound("no")
        end
        self:initialize_assigned_item_sprites(game)
        handled = true
    elseif command == "item_2" then
        local item = self:get_item_at_current_index()
        if item and item:is_assignable() then
            game:set_item_assigned(2, item)
            sol.audio.play_sound("ok_r")
        else sol.audio.play_sound("no")
        end
        self:initialize_assigned_item_sprites(game)
        handled = true
    elseif command == "action" then
        if all_equipment_items[cursor_index + 1] ~= nil
        and all_equipment_items[cursor_index + 1].assignable == false then
            local item = self:get_item_at_current_index()
            if item then item:on_using() end
            inventory:initialize(game)
            --use the item
        end
        handled = true
    end
    return handled
  end
end

function inventory:get_item_at_current_index()
    local game = sol.main.get_game()
    local item_entry = all_equipment_items[cursor_index + 1]
    if item_entry then
        local item = game:get_item(item_entry.item)
        if item:get_variant() > 0 then
            return item
        else return nil
        end
    else return nil
    end
end

function inventory:on_draw(dst_surface)
    --draw the elements
    self.menu_background:draw(dst_surface, self.x, self.y)
    self.cursor_sprite:draw(dst_surface, (self.cursor_column * 32 + GRID_ORIGIN_X + 32) + self.x,  (self.cursor_row * 32 + GRID_ORIGIN_Y) + self.y)
    self.description_panel:draw(dst_surface, ((COLUMNS * 32) / 2 + GRID_ORIGIN_X + 16) + self.x, (ROWS *32 + GRID_ORIGIN_Y - 8)+self.y)
    --draw health and magic
    self.life_surface:draw(dst_surface, 75 + self.x, 14 + self.y)
    self.magic_surface:draw(dst_surface, 75 + self.x, 22 + self.y)
    --draw assigned items:
      if self.assigned_item_sprite_1 then
        self.assigned_item_sprite_1:draw(dst_surface, self.x + 310, self.y + 35)
      end
      if self.assigned_item_sprite_2 then
        self.assigned_item_sprite_2:draw(dst_surface, self.x + 340, self.y + 35)
      end

    --Draw curse and charms
    if self.curse_icon then self.curse_icon:draw(dst_surface, self.x+328, self.y+216) end
    self.oak_charm_sprite:draw(dst_surface, self.x+280, self.y+216)
    self.dandelion_sprite:draw(dst_surface, self.x+304, self.y+216)

    --draw inventory items
    for i=1, #all_equipment_items do
        if self.equipment_sprites[i] then
            --draw the item's sprite from the sprites table
            local x = ((i-1)%COLUMNS) * 32 + GRID_ORIGIN_EQUIP_X + 32
            local y = math.floor((i-1) / COLUMNS) * 32 + GRID_ORIGIN_EQUIP_Y
            self.equipment_sprites[i]:draw(dst_surface, x + self.x, y + self.y)
            if self.counters[i] then
                --draw the item's counter
                self.counters[i]:draw(dst_surface, x+8 + self.x, y+4 + self.y )
            end
        end
    end

local COLLECT_COLUMNS = 4
local COLLECT_ROWS = 5
local COL_SQR_SIZE = 24
local GRID_ORIGIN_COLLECT_X = 260
local GRID_ORIGIN_COLLECT_Y = 48
    --draw collectable items
    for i=1, #all_collectables do
      if self.collectable_sprites[i] then
        local x = ((i-1)%COLLECT_COLUMNS) * COL_SQR_SIZE + GRID_ORIGIN_COLLECT_X + COL_SQR_SIZE
        local y = math.floor((i-1) / COLLECT_COLUMNS) * COL_SQR_SIZE + GRID_ORIGIN_COLLECT_Y + COL_SQR_SIZE
        self.collectable_sprites[i]:draw(dst_surface, x+self.x, y+self.y)
        self.collectable_counters[i]:draw(dst_surface, x+8 +self.x, y+2 + self.y)
      end
    end
end

--Avoid analog stick from jumping wildly:
local joy_avoid_repeat = {-2, -2}
function inventory:on_joypad_axis_moved(axis, state)  

  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state      

  return handled
end

return inventory
