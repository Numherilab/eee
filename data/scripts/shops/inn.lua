local inn = {}

function inn:start(cost)
  local game = sol.main:get_game()
  local map = game:get_map()
  local black = sol.surface.create()
  black:fill_color({0,0,0})
  black:set_opacity(0)
  local hero = map:get_hero()
  local sprite = hero:get_sprite()
  local price = cost or 30
  game:start_dialog("_shop.inn", price, function(answer)
    if answer == 3 and game:get_money() < price then
      game:start_dialog("_game.insufficient_funds")
    elseif answer == 3 and game:get_money() >= price then
      game:remove_money(price)
      local npx,npy,npz = hero:get_position()
      local random = math.random(1,100)
      local sleep_on_floor = true
      if map:has_entities("sleep_spot") and random > 1 then
        sleep_on_floor = false
        npx,npy,npz = map:get_entity("sleep_spot"):get_position()
      end
      black:fade_in(20, function()
        hero:freeze()
        hero:set_position(npx,npy,npz)
        sprite:set_animation("asleep")
        sol.timer.start(map, 100, function() --this is how long you "sleep" for
          black:fade_out(30, function()
            game:set_life(game:get_max_life())
            sol.timer.start(map, 500, function()
              sprite:set_animation("waking_up", function()
                sprite:set_animation("stopped")
                hero:start_jumping(4, 24, true)
                sol.timer.start(map, 500, function()
                  hero:unfreeze()
                  if sleep_on_floor then game:start_dialog("_generic_dialogs.shop.inn_sleep_on_floor") end
                end)
              end)
            end) --end of timer

          end) --end of fade out
        end) -- end of timer
      end) --end of fade in
    end
  end)

  function map:on_draw(dst)
    black:draw(dst)
  end

end

return inn