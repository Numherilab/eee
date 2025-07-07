local enemy = ...
local map = enemy:get_map()
local particles = {}
local MAX_PARTICLES = 5
local PARTICLE_SPEED = 11
enemy.immobilize_immunity = true
enemy.lighting_effect = 1
enemy.height = 16

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 55,
  damage = 30,
  normal_speed = 20,
  faster_speed = 75,
  detection_distance = 120,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 6000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 5000,
  orbit_attack_sound = "gravel",
  orbit_attack_launch_sound = "shoot",
  orbit_attack_num_projectiles = 5,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 200,
  orbit_attack_projectile_breed = "misc/blue_fire",
  orbit_attack_radius = 16,

  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 6500,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "running",
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
  local smoke_sprite = enemy:create_sprite("entities/ghost_smoke")
  enemy:bring_sprite_to_back(smoke_sprite)
--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(100,250), function()
    particles[i] = sol.sprite.create("entities/yarrow_bloom_particle")
    particles[i]:set_xy(math.random(-16, 16), math.random(-24, 0))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
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