require("scripts/multi_events")

local item = ...
local game = item:get_game()

local MAGIC_COST = 90

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_crystal_spark")
  item:set_assignable(true)
end)

item:register_event("on_obtaining", function(self)
  game:set_ability("sword", 1)
end)

item:register_event("on_using", function(self)
  if game:get_magic() < MAGIC_COST then sol.audio.play_sound("no") item:set_finished()
  else
    game:remove_magic(MAGIC_COST)
    local map = item:get_map()
    local hero = game:get_hero()
    local x, y, layer = hero:get_position()

    local PILLAR_RANGE = 125

    --charge for 500ms
  --  hero:freeze()
    local summoning_state = sol.state.create()
    summoning_state:set_can_control_movement(false)
    summoning_state:set_can_be_hurt(true)
    summoning_state:set_can_use_sword(false)
    summoning_state:set_can_use_item(false)
    summoning_state:set_can_interact(false)
    summoning_state:set_can_grab(false)
    summoning_state:set_can_pick_treasure(false)
    hero:start_state(summoning_state)

    hero:set_animation("charging")
    sol.audio.play_sound("charge_1")
    sol.timer.start(game, 1200, function()
      sol.audio.play_sound("fire_burst_1")
      --summon some stuff to hurt enemies
      local flame_pillars = {}
      for i = 1, 8 do
        flame_pillars[i] = map:create_custom_entity{
        name = "friendly_fire",
        direction = 0,
        layer = layer,
        x = x,
        y = y,
        width = 16,
        height = 16,
        sprite = "entities/flame_pillar",
        model = "damaging_sparkle"
        }
        flame_pillars[i]:set_damage((game:get_value("sword_damage") * 2) or 10)
  --      flame_pillars[i]:set_can_traverse_ground("wall", true)
      end

      local dx = {[0] = 24, [1] = 0, [2] = -24, [3] = 0}
      local dy = {[0] = 0, [1] = -24, [2] = 0, [3] = 24}
      sol.timer.start(map, 500, function()
        sol.audio.play_sound("fire_burst_1")
        for i = 9, 12 do
          flame_pillars[i] = map:create_custom_entity{
          name = "friendly_fire",
          direction = 0,
          layer = layer,
          x = x + dx[i-9],
          y = y + dy[i-9],
          width = 16,
          height = 16,
          sprite = "entities/flame_pillar",
          model = "damaging_sparkle"
          }
          flame_pillars[i]:set_damage((game:get_value("sword_damage") * 2) or 10)
        end
      end)

      local movements = {}
      for i = 1, 8 do
        movements[i] = sol.movement.create("straight")
        movements[i]:set_speed(130)
        movements[i]:set_angle((math.pi/4) * i)
        movements[i]:set_max_distance(PILLAR_RANGE)
        movements[i]:start(flame_pillars[i], function() flame_pillars[i]:remove() end)
      end


      sol.timer.start(game, 2000, function()
        for i=1,12 do
          if flame_pillars[i] then
            flame_pillars[i]:remove()
          end
        end
      end)

      hero:set_sword_sprite_id("hero/gust")
      hero:unfreeze()
      hero:start_attack()
      sol.audio.play_sound("sword_spin_attack_release")
      sol.audio.play_sound("thunk1")
      local sprite = hero:get_sprite()
      local animation = sprite:get_animation()
      function sprite:on_animation_finished()
        hero:set_sword_sprite_id("hero/sword1")
      end
      item:set_finished()


    end) --end of warmup timer callback
  end --end of if has enough magic
end)


--  hero:set_sword_sprite_id("hero/sword2")
--  hero:set_sword_sprite_id("hero/sword1")
