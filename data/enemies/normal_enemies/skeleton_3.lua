local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local being_attacked

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 8,
  damage = 4,
  normal_speed = 20,
  faster_speed = 55,
  detection_distance = 120,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 800,
  melee_distance = 70,
  melee_attack_cooldown = 5000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/sword_slash"},

  sword_consequence = function()
      local sprite = enemy:get_sprite()
      local hero = map:get_hero()
      if sprite:get_animation() == "walking" then
        sprite:set_animation("blocking", function() sprite:set_animation("walking") end)
        hero:freeze()
        sol.audio.play_sound("sword_tapping")
        local m = sol.movement.create("straight")
        local angle = enemy:get_angle(hero)
        m:set_angle(angle)
        m:set_max_distance(24)
        m:set_speed(200)
        m:start(hero, function() hero:unfreeze() end)
        function m:on_obstacle_reached() hero:unfreeze() end
      else
        if not being_attacked then
          enemy:hurt(1)
          being_attacked = true
          sol.timer.start(map, 400, function() being_attacked = false end)
        end
      end
  end,
  arrow_consequence = 4,  

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 35 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_bones",
     treasure_variant = 2,
     }
  end
end
