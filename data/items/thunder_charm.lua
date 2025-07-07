require("scripts/multi_events")

local item = ...
local game = item:get_game()

local RANGE = 180
local MAGIC_COST = 85
--The variant will determine the number of lightning bolts called

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_thunder_charm")
  item:set_assignable(true)
end)

item:register_event("on_obtained", function(self, variant, savegame_variable)
  if variant == 4 then
    game:set_value("quest_heron_doors", 1) --quest complete
    sol.achievements.unlock("ach_seabird_tear") --set achievement
  else --manually force refresh of quest --TODO quest log issue #76
    local quest_id = "quest.side.heron_doors"
    local status = game.objectives:get_objective(quest_id):refresh()
    if status and game.objectives.on_quest_updated then
      game.objectives:on_quest_updated(status, quest_id) --call event if it exists
    end
  end
end)


item:register_event("on_variant_changed", function(self, variant)
  if variant == 4 then
    game:set_value("quest_heron_doors", 1) --quest complete
    sol.achievements.unlock("ach_seabird_tear") --set achievement
  end
end)


item:register_event("on_using", function(self)
  if game:get_magic() < MAGIC_COST then sol.audio.play_sound("no") item:set_finished()
  else
    game:remove_magic(MAGIC_COST)
    local map = item:get_map()
    local hero = game:get_hero()

    local summoning_state = sol.state.create()
    summoning_state:set_can_control_movement(false)
    summoning_state:set_can_be_hurt(true)
    summoning_state:set_can_use_sword(false)
    summoning_state:set_can_use_item(false)
    summoning_state:set_can_interact(false)
    summoning_state:set_can_grab(false)
    summoning_state:set_can_pick_treasure(false)
    hero:start_state(summoning_state)

    local lightning_damage = 5 + (item:get_variant() * 3)

    hero:set_animation("charging")
    sol.audio.play_sound("charge_1")

    sol.timer.start(game, 500, function()
      sol.audio.play_sound("thunder3")

      local map = game:get_map()
      if map:has_entities("seabird_tear_door") then
        for door in map:get_entities("seabird_tear_door") do
          if door:get_distance(map:get_hero()) < 240 and
          door:is_in_same_region(map:get_hero()) then
            local x, y, l = door:get_position()
            local lightning = map:create_custom_entity{
            name = "lightning_attack",
            direction = 0,
            layer = l + 1,
            x = x + 8,
            y = y + 8,
            width = 16,
            height = 16,
            sprite = "entities/lightning_bolt_attack",
            model = "damaging_sparkle"
            }
            map:create_poof(x + 8, y + 8, l + 1)
            map:open_doors(door:get_name())
          end
        end
      end

      local i = 0
      for entity in map:get_entities() do
        if entity:get_type() == "enemy" and not string.match(entity:get_breed(), "misc")
        and entity:get_distance(hero) <= RANGE then
          i = i + 1
          local x, y, layer = entity:get_position()
          if not string.match(entity:get_breed(), "misc") then
            local lightning = map:create_custom_entity{
              name = "lightning_attack",direction = 0,
              layer = layer,x = x,y = y,width = 16,height = 16,
              sprite = "entities/lightning_bolt_attack",
              model = "damaging_sparkle"
            }
            lightning:set_damage(lightning_damage)
            entity:hit_by_lightning()
            sol.timer.start(map, 2000, function() lightning:remove() end)
          end
          if i >= item:get_variant() then
            hero:unfreeze()
            item:set_finished()
            return
          end
        end
      end
      hero:unfreeze()

      item:set_finished()

    end) --end of warmup timer callback
  end --end of if has enough magic
end)
