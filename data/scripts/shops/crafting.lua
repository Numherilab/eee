local multi_events = require"scripts/multi_events"

local crafting_menu = {x=0, y=0}
multi_events:enable(crafting_menu)

local font, font_size = require("scripts/language_manager"):get_menu_font()

--Recipes List--------------------
local unlocked_recipes = {}

local all_recipes = {
  {
    item_name = "elixer",
    ingredients = {{"kingscrown", 1}, {"ghost_orchid", 1}, {"firethorn_berries", 3}},
    unlock_variable = "is_craftable_elixer"
  },
  {
    item_name = "potion_magic_restoration",
    ingredients = {{"witch_hazel", 2}, {"mandrake", 1}, {"monster_guts", 3}},
    unlock_variable = "is_craftable_potion_magic_restoration"
  },
  {
    item_name = "potion_stoneskin",
    ingredients = {{"mandrake_white", 1}, {"geode", 3}, {"monster_bones", 3}},
    unlock_variable = "is_craftable_potion_stoneskin"
  },
  {
    item_name = "potion_burlyblade",
    ingredients = {{"kingscrown", 1}, {"burdock", 3}, {"monster_guts", 3}},
    unlock_variable = "is_craftable_potion_burlyblade"
  },
  {
    item_name = "potion_fleetseed",
    ingredients = {{"ghost_orchid", 1}, {"lavendar", 3}, {"monster_guts", 3}},
    unlock_variable = "is_craftable_potion_fleetseed"
  },
  {
    item_name = "ether_bombs",
    ingredients = {{"mandrake", 2}, {"lavendar", 2}, {"chamomile", 2}},
    unlock_variable = "is_craftable_ether_bombs",
    amount_created = 5,
  },
  {
    item_name = "iron_candle",
    ingredients = {{"monster_bones", 2}, {"geode", 2}, {"witch_hazel", 2}},
    unlock_variable = "is_craftable_salt_candles",
    amount_created = 5,
  },
  {
    item_name = "homing_eye",
    ingredients = {{"monster_eye", 3}, {"burdock", 2}, {"firethorn_berries", 2}},
    unlock_variable = "is_craftable_seeker_eyes",
    amount_created = 5,
  },

}



--Surfaces, etc.------------------
function crafting_menu:initialize()
  self.cursor_index = 0
  self.menu_surface = sol.surface.create()
  --initialize background (basically just the frame)
  self.menu_dark_overlay = sol.surface.create("menus/dark_overlay.png")
  self.menu_dark_overlay:draw(self.menu_surface)
  self.menu_background = sol.surface.create("menus/crafting_background.png")
  self.menu_background:draw(self.menu_surface)
  --initialize the cursor
  self.cursor_sprite = sol.sprite.create("menus/cursor")
  self.recipes_surface = sol.surface.create(208, 192)
  self.ingredients_surface = sol.surface.create()
  --Set the title of the menu
  self.title_surface = sol.text_surface.create{
    vertical_alignment="top",
    font = font, font_size = font_size,
    text_key="menu.crafting.crafting_title",
  }
  self.title_surface:draw(self.menu_surface, 208, 36)
end


--Menu Functions-----------------

function crafting_menu:on_started()
  sol.main.get_game():set_suspended(true)
  crafting_menu:initialize()
  crafting_menu:update_recipes()
  crafting_menu:update_ingredients()
  self.menu_surface:fade_in(5)
  self.ingredients_surface:fade_in(5)
end

function crafting_menu:on_finished()
  sol.main.get_game():set_suspended(false)
end

function crafting_menu:update_recipes()
  self.recipes_surface:clear()
  --put all unlocked recipes in unlocked_recipes
  unlocked_recipes = {}
  local game = sol.main.get_game()
  for i=1, #all_recipes do
    if game:get_value(all_recipes[i].unlock_variable) then
      table.insert(unlocked_recipes, all_recipes[i])
    end
  end
  --draw unlocked recipes
  for i=1, #unlocked_recipes do
    local recipe_surface = sol.text_surface.create{
      vertical_alignment="top",
      font = font, font_size = font_size,
      text_key="item."..unlocked_recipes[i].item_name..".1" --all crafting ingredients are variant 1
    }
    if not crafting_menu:can_make_recipe(unlocked_recipes[i]) then
      recipe_surface:set_color_modulation{170,170,170,200}
    end
    recipe_surface:draw(self.recipes_surface, 0, 18 * i - 18)
  end
  self.recipes_surface:draw(self.menu_surface, 208, 56)
end

function crafting_menu:update_ingredients()
  local game = sol.main.get_game()
  local current_recipe = unlocked_recipes[self.cursor_index + 1]
  local ingredients = current_recipe.ingredients
  self.ingredients_surface:clear()
  --where to draw the ingredients
  local locations = {
    {x=96, y=114},
    {x=144, y=146},
    {x=96, y=178},
  }
  for i=1, #ingredients do
    local sprite = sol.sprite.create("entities/items")
    sprite:set_animation(ingredients[i][1])
    sprite:draw(self.ingredients_surface, locations[i].x, locations[i].y)
    local qty_surface = sol.text_surface.create{
      vertical_alignment="top",
      font="white_digits",
      text = game:get_item(ingredients[i][1]):get_amount() .. "/" .. ingredients[i][2]
    }
    -- grey out number if insufficient
    if game:get_item(ingredients[i][1]):get_amount() < ingredients[i][2] then
      qty_surface:set_color_modulation{100,100,100}
    end
    qty_surface:draw(self.ingredients_surface, locations[i].x - 4, locations[i].y + 6)
  end
end


--Crafting Functions---------------------

function crafting_menu:can_make_recipe(recipe)
  local can_indeed_make = true
  local game = sol.main.get_game()
  for i=1, #recipe.ingredients do
    local ingredient = recipe.ingredients[i]
    local item = game:get_item(ingredient[1])
    if item:get_amount() < ingredient[2] then
      can_indeed_make = false
    end
  end
  return can_indeed_make
end


function crafting_menu:craft_item(recipe)
  local game = sol.main.get_game()
  local item = game:get_item(recipe.item_name)
  sol.audio.play_sound"treasure"
  game:start_dialog("_game.crafted_item")
  if not game:has_item(recipe.item_name) then
    item:set_variant(1)
  end
  item:add_amount(recipe.amount_created or 1)
  for i=1, #recipe.ingredients do
    local ingredient = recipe.ingredients[i]
    local ingredient_item = game:get_item(ingredient[1])
    ingredient_item:remove_amount(ingredient[2])
  end
  crafting_menu:update_ingredients()
  crafting_menu:update_recipes()
end



-----Command Inputs-------------------
function crafting_menu:on_command_pressed(command)
  local game = sol.main.get_game()
  local handled = false
  if not handled then
    if command == "up" then
      self.cursor_index = self.cursor_index - 1
      if self.cursor_index < 0 then self.cursor_index = #unlocked_recipes - 1 end
      sol.audio.play_sound"cursor"
      crafting_menu:update_ingredients()
      handled = true

    elseif command == "down" then
      self.cursor_index = self.cursor_index + 1
      if self.cursor_index >= #unlocked_recipes then self.cursor_index = 0 end
      sol.audio.play_sound"cursor"
      crafting_menu:update_ingredients()
      handled = true

    elseif command == "action" then
      local current_recipe = unlocked_recipes[self.cursor_index + 1]
      if crafting_menu:can_make_recipe(current_recipe) then
        crafting_menu:craft_item(current_recipe)
      else
        sol.audio.play_sound"no"
        game:get_map():get_camera():shake({count=3,amplitude=2})
      end
      handled = true

    elseif command == "attack" then
      self.menu_surface:fade_out(5)
      self.ingredients_surface:fade_out(5)
      sol.timer.start(game, 200, function() sol.menu.stop(self) end)
      handled = true

    elseif command == "pause" then
      sol.menu.stop(self)
      handled = true

    end
    return handled
  end
end

--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}

function crafting_menu:on_joypad_axis_moved(axis, state)

  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state

  return handled
end



--From llamazing's pause menu system, in case I ever want to incorporate this into the pause menu
--// Gets/sets the x,y position of the menu in pixels
function crafting_menu:get_xy() return self.x, self.y end
function crafting_menu:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")

	self.x = math.floor(x)
	self.y = math.floor(y)
end



function crafting_menu:on_draw(dst)
  self.menu_surface:draw(dst)
  self.ingredients_surface:draw(dst)
  self.cursor_sprite:draw(dst, 200, 60 + self.cursor_index * 18)
end


return crafting_menu
