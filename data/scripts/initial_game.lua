-- This script initializes game values for a new savegame file.
-- You should modify the initialize_new_savegame() function below
-- to set values like the initial life and equipment
-- as well as the starting location.
--
-- Usage:
-- local initial_game = require("scripts/initial_game")
-- initial_game:initialize_new_savegame(game)

local initial_game = {}

-- Sets initial values to a new savegame file.
function initial_game:initialize_new_savegame(game)

  game:set_starting_location("new_limestone/new_limestone_island", "intro_cutscene")
--  game:set_starting_location("debug_room", "destination")

  sol.audio.set_music_volume(90)
  game:set_value("music_volume", 90)

--Little check to make sure savegame file is not totally corrupted
  game:set_value("aaaaaa_savegame_file_check", "1234asdf")

-- hero stats
  game:set_max_life(6)
  game:set_life(game:get_max_life())
  game:set_max_money(9999)
  game:set_money(40)
  game:set_max_magic(100)
  game:set_magic(100)
  game:set_ability("jump_over_water", 1)
  game:set_ability("swim", 0)
  game:set_ability("run", 0)
  game:set_ability("lift", 0)
  game:set_ability("sword", 0)
  game:set_ability("sword_knowledge", 0)
  game:set_value("defense", 2)
  game:set_value("sword_damage", 1)
  game:set_value("bow_damage", 3)
  game:set_value("bomb_damage", 8)
  game:set_value("fire_damage", 3)
  game:set_value("amount_bow", 0)
  game:set_value("elixer_restoration_level", 6) --starts at 6 (3 hearts), then goes to 12, then 18, then 24

--system stuff
  game:set_value("quest_log_a", 0) --deprecated
  game:set_value("quest_log_b", 0) --deprecated
  game:set_value("reveal_quest_totals", false) --for quest log menu

--side quests
  game:set_value("lighthouses_quest_num_lit", 0)

--shop item availability
  game:set_value("available_in_shop_berries", true)
  game:set_value("available_in_shop_apples", true)
  game:set_value("available_in_shop_bread", true)
  game:set_value("available_in_shop_arrows", false)
  game:set_value("available_in_shop_bombs", false)
  game:set_value("available_in_shop_magic_restoring_potion", true)
  game:set_value("available_in_shop_stoneskin_potion", true)
  game:set_value("available_in_shop_burlyblade_potion", true)
  game:set_value("available_in_shop_elixer", true)
--craftable item availability
  game:set_value("is_craftable_elixer", true)
  game:set_value("is_craftable_potion_magic_restoration", true)
  game:set_value("is_craftable_potion_stoneskin", true)
  game:set_value("is_craftable_potion_burlyblade", true)
  game:set_value("is_craftable_potion_fleetseed", true)
  game:set_value("is_craftable_ether_bombs", true)
  game:set_value("is_craftable_salt_candles", true)
  game:set_value("is_craftable_seeker_eyes", true)

--Default hard mode settings;
  game:set_value("hard_mode_enemy_damage", true)
  game:set_value("hard_mode_enemy_life", true)
  game:set_value("hard_mode_healing_items", false)
  game:set_value("hard_mode_iframes", false)

end

return initial_game
