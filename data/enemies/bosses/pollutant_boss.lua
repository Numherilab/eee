local enemy = ...
local map = enemy:get_map()
local particles = {}
local MAX_PARTICLES = 5
local PARTICLE_SPEED = 11

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 50,
  damage = 10,
  normal_speed = 15,
  faster_speed = 40,
  detection_distance = 100,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
--  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 3000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

  has_ranged_attack = true,
  ranged_attack_distance = 170,
  ranged_attack_cooldown = 5000,
  ranged_attack_sound = "shoot",
  projectile_breed = "misc/energy_ball_black",
  projectile_split_children = 4,
--optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces, if the projectile breed will accept them!
  projectile_angle = "any",


  has_dash_attack = true,
  dash_attack_distance = 160,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 120,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "running",
}


properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(100,250), function()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(math.random(-20, 20), math.random(-24, 0))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
    m:set_ignore_suspend(false)
    m:start(particles[i])
    i = i + 1
    if i > MAX_PARTICLES then i = 0 end
    if enemy:exists() and enemy:is_enabled() then return true end
  end)
end)

--particle effect draw
function enemy:on_post_draw()
    local x, y, layer = enemy:get_position()
    for i=1, #particles do
      map:draw_visual(particles[i], x, y)
    end
end

function enemy:on_dying()
  random = math.random(100)
  if random < 8 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_heart",
     treasure_variant = 1,
     }
  end
end