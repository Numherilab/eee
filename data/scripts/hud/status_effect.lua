local status_menu = {}

local key_sprite = sol.sprite.create("hud/small_key_icon")
local key_surface = sol.surface.create()

local sprites = {}
local attack_sprite = sol.sprite.create"hud/status_attack"
local defense_sprite = sol.sprite.create"hud/status_defense"
local speed_sprite = sol.sprite.create"hud/status_speed"
local plus_sprite = sol.sprite.create"hud/status_plus"
status_menu.attack_surface = sol.surface.create(16,16)
status_menu.defense_surface = sol.surface.create(16,16)
status_menu.speed_surface = sol.surface.create(16,16)


function status_menu:on_started()
  local X = 4
  local Y = 8
  plus_sprite:draw(status_menu.speed_surface,X+5,Y-1)
  speed_sprite:draw(status_menu.speed_surface,X,Y)
  plus_sprite:draw(status_menu.defense_surface,X+5,Y-1)
  defense_sprite:draw(status_menu.defense_surface,X,Y)
  plus_sprite:draw(status_menu.attack_surface,X+5,Y-1)
  attack_sprite:draw(status_menu.attack_surface,X,Y)
  status_menu.attack_surface:set_opacity(0)
  status_menu.defense_surface:set_opacity(0)
  status_menu.speed_surface:set_opacity(0)

end

function status_menu:on_draw(dst)
  local X = 400
  local Y = 200
  status_menu.attack_surface:draw(dst,X,Y - 25)
  status_menu.defense_surface:draw(dst,X,Y - 12)
  status_menu.speed_surface:draw(dst,X,Y)
end

return status_menu