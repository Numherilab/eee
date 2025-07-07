require"scripts/multi_events"
require("scripts/meta/hero")


local enemy_meta = sol.main.get_metatable("enemy")

function enemy_meta:set_consequence_for_all_attacks(consequence)
  -- "sword", "thrown_item", "explosion", "arrow", "hookshot", "boomerang" or "fire"
  self:set_attack_consequence("sword", consequence)
  self:set_attack_consequence("thrown_item", consequence)
  self:set_attack_consequence("explosion", consequence)
  self:set_attack_consequence("arrow", consequence)
  self:set_attack_consequence("hookshot", consequence)
  self:set_attack_consequence("boomerang", consequence)
  self:set_attack_consequence("fire", consequence)
end


--redefine enemy:remove_life() to add some stuff
function enemy_meta:remove_life(damage)
  local game = sol.main.get_game()
  --make enemies a litttttle bit spongier for hard mode
  if game:get_value"hard_mode" and game:get_value"hard_mode_enemy_life" then damage = damage * .8 end

  self:set_life(self:get_life() - damage)
end


function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)
  local game = self:get_game()
  local sword_damage = game:get_value("sword_damage")
  local hero_state = hero:get_state()
  if hero_state == "sword spin attack" or hero_state == "running" then
    sword_damage = sword_damage * 2.5
  end
  if game.tilia_damage_multiplier then sword_damage = sword_damage * game.tilia_damage_multiplier end

  self:remove_life(sword_damage)

end




-- Helper function to inflict an explicit reaction from a scripted weapon.
-- TODO this should be in the Solarus API one day
function enemy_meta:receive_attack_consequence(attack, reaction)

  if type(reaction) == "number" then
    self:hurt(reaction)
  elseif reaction == "immobilized" then
    if not self.immobilize_immunity then
      self:immobilize()
    end
  elseif reaction == "protected" then
    sol.audio.play_sound("sword_tapping")
  elseif reaction == "custom" then
    if self.on_custom_attack_received ~= nil then
      self:on_custom_attack_received(attack)
    end
  end

end


function enemy_meta:on_hurt(attack)
    --screen shake
  local game = self:get_game()
  local map = self:get_map()
  local camera = map:get_camera()
  if not game.enemy_hitstop_cooldown then
    game.enemy_hitstop_cooldown = true
    game:set_suspended(true)
    sol.timer.start(game, 30, function()
      game:set_suspended(false)
      map:get_camera():shake({count = 4, amplitude = 4, speed = 100, zoom_factor = 1.005})
     end) --end of timer
    sol.timer.start(game, 500, function() game.enemy_hitstop_cooldown = false end)
  end

  if attack == "explosion" then
    local game = self:get_game()
    local bomb_pain = game:get_value("bomb_damage")
    self:remove_life(bomb_pain)
    self:react_to_bomb()

  end

  if attack == "fire" then
    local game = self:get_game()
    local fire_damage = game:get_value("sword_damage")
    if self.weak_to_fire then fire_damage = fire_damage * 2.5 end
    self:react_to_fire()
    self:remove_life(fire_damage)
  end

  --particle effect
  local hurt_particles = {}
  if self:get_life() >= 0 then --make sure there is a sprite
    local sprite_height
    if self:get_sprite() then
      _, sprite_height = self:get_sprite():get_size()
    else
      sprite_height = 16
    end
    local NUM_PARTICLES = sprite_height / 3
    local x,y,z = self:get_position()
    for i=1, NUM_PARTICLES do
      hurt_particles[i] = map:create_custom_entity{x=x,y=y,layer=z,width=8,height=8,direction=0,
        model="ephemeral_effect",sprite="entities/pollution_ash"}
      hurt_particles[i]:set_duration(500)
      hurt_particles[i]:start()
      local m = sol.movement.create"straight"
      m:set_max_distance(math.random(25,38))
      m:set_speed(200)
      m:set_ignore_obstacles()
      local angle = map:get_hero():get_angle(self)
      m:set_angle(angle + math.random(1,300) / 300)
      m:start(hurt_particles[i])
    end
  end

end


--Allow to go "behind" taller enemies without taking damage
enemy_meta:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)
  if enemy.height and enemy:get_attacking_collision_mode() == "sprite" and enemy_sprite == enemy:get_sprite() then
    local hx,hy,hz = hero:get_position()
    local ex,ey,ez = enemy:get_position()
    if hy + enemy.height < ey then
      --nothing, hero "behind" enemy
--      elseif hy > ey + 20 then --allow for hero's head to overlap enemy some
      --nothing again
    else
      hero:start_hurt(enemy, enemy:get_damage())
    end
  else
    hero:start_hurt(enemy, enemy:get_damage())
  end
end)


--Here's some methods you can redefine for each enemy. This allows for certain weaknesses.
function enemy_meta:react_to_fire()
end

function enemy_meta:react_to_bomb()
end

function enemy_meta:hit_by_toss_ball()
end

function enemy_meta:hit_by_lightning()
end


--Common Methods:
------------------------------------------------------

function enemy_meta:propagate_fire()
  local enemy = self
  if enemy.reacting_to_fire then return end
  enemy.reacting_to_fire = true
  sol.audio.play_sound"fire_burst_3"
  sol.timer.start(enemy, 800, function() enemy.reacting_to_fire = false end)
  local map = enemy:get_map()
  local x,y,z = enemy:get_position()
  local dx = {12,0,-12,0}
  local dy = {0,-12,0,12}
  local NUM_FLAMES = 6
  for i=1, NUM_FLAMES do
    local flame = map:create_fire{
      x=x, y=y, layer=z
    }
    local m = sol.movement.create"straight"
    m:set_angle(2 * math.pi / NUM_FLAMES * i)
    m:set_max_distance(16)
    m:set_speed(110)
    m:start(flame)
  end
end

function enemy_meta:is_on_screen()
  local enemy = self
  local map = enemy:get_map()
  local camera = map:get_camera()
  local camx, camy = camera:get_position()
  local camwi, camhi = camera:get_size()
  local enemyx, enemyy = enemy:get_position()

  local on_screen = enemyx >= camx and enemyx <= (camx + camwi) and enemyy >= camy and enemyy <= (camy + camhi)
  return on_screen
end

return true