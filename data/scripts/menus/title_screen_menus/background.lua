local title_screen = {}

local background_sprite = sol.sprite.create("menus/title_screen/background")
local sea_sparkle = sol.sprite.create("menus/title_screen/sea_sparkle")
local sky = sol.surface.create("menus/title_screen/sky.png")
local seagull = sol.sprite.create("menus/title_screen/seagull")
local black_fill = sol.surface.create()
local title_surface = sol.surface.create("menus/title_card.png")
local leaf_surface = sol.surface.create()
local version_surface = sol.text_surface.create{font = "enter_command", font_size=15}
version_surface:set_text("© 2020 Max Mraz " .. sol.main.get_quest_version())
version_surface:set_opacity(150)

local leaves = {}
local clouds = {}


local function create_cloud()
  local speed
  local j = #clouds + 1
  if j % 2 == 0 then
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_" .. math.floor(math.random(1,8)))
    speed = 16
  else
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_" .. math.floor(math.random(1,8)))
    --special cloud for no. 1
    if j == 1 then
      clouds[j] = sol.sprite.create("menus/title_screen/cloud_5")
    end
    speed = 12
  end

  if j % 2 == 0 then
    clouds[j].y = 75
  else
    clouds[j].y = 5
  end
  local m1 = sol.movement.create("straight")
  m1:set_angle(0)
  m1:set_speed(speed)
  m1:set_max_distance(720)
  m1:start(clouds[j], function() table.remove(clouds, 1) end)
  
  --give first cloud a head start
  if j == 1 then
    clouds[j]:set_xy(250,0)
  end
end


function title_screen:on_started()

  title_surface:fade_in()
  sol.timer.start(self, 100, function()
    sol.audio.play_music("title_screen_piano_only")
  end)
  black_fill:fill_color({0,0,0, 255})
  black_fill:fade_out(40)
  sol.timer.start(title_screen, 0, function()
    create_cloud()
    return math.random(3000, 7000)
  end)


  sol.timer.start(title_screen, math.random(10, 20), function()
    local i = #leaves + 1
    leaves[i] = sol.sprite.create("entities/leaf_blowing")
    leaves[i]:set_xy(math.random(-100, 50), 0)
    --if it's the beginning of the title screen, let's move the leaves closer to onscreen
    if i < 4 then leaves[i]:set_xy(math.random(-60, 50), 0) end
    local m3 = sol.movement.create("straight")
    m3:set_angle(math.random(5.3, 6))
    m3:set_speed(25)
    m3:set_max_distance(700)
    m3:start(leaves[i], function() table.remove(leaves, 1) end)
    --if it's the very beginning of the title screen, we don't want to wait on our leaves
    if i < 4 then return i * 200 + math.random(100, 800)
    else return math.random(2400, 3500) end
  end)

  sol.timer.start(title_screen, math.random(2000, 3000), function()
    local pose = math.random()*100
    if pose < 35 then
      seagull:set_animation("looking")
      sol.timer.start(title_screen, 1999, function() seagull:set_animation("stopped") end)
    elseif pose >= 35 then
      seagull:set_animation("shuffling")
      sol.timer.start(title_screen, math.random(600, 1100), function() seagull:set_animation("stopped") end)
    end
    return math.random(2000, 3000)
  end)
end


function title_screen:on_draw(dst_surface)
  sky:draw(dst_surface)
  for i=1 , #clouds do
    clouds[i]:draw(dst_surface, -160, clouds[i].y)
  end
  background_sprite:draw(dst_surface)
  sea_sparkle:draw(dst_surface)
  seagull:draw(dst_surface, 340, 42)
  leaf_surface:draw(dst_surface)
  for i=1 , #leaves do
    leaves[i]:draw(dst_surface)
  end
  title_surface:draw(dst_surface, 6, 24)

  version_surface:draw(dst_surface, 4, 234)

  black_fill:draw(dst_surface)
end

return title_screen
