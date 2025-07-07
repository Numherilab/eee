--Generic manager for achievements- will call to Steam or other specific achievement systems
--Reads achievement IDs from scripts/achievements/achievements, and saves them in a savegame variable "achievement_status_{achievement ID}"
--Functions should only be called when the game is running, as achievements are stored as savegame values
--Usage to unlock an achievement: sol.achievements.unlock(achievement_id)

sol.achievements = {}
local ach_list = require"scripts/achievements/achievements"


--Make sure all unlocked achievements are updated, useful in case of connection problems
function sol.achievements.update()
  --print"Updating Achievement"
  local game = sol.main.get_game()
  for _, ach_id in ipairs(ach_list) do
    --print("Achievement ID:", ach_id, "Status:", game:get_value("achievement_status_" .. ach_id))
    if game:get_value("achievement_status_" .. ach_id) then sol.achievements.unlock(ach_id) end
  end
end


function sol.achievements.get_achievement_status(ach_id)
  local game = sol.main.get_game()
  return game:get_value("achievement_status_" .. ach_id)
end


--Unlock a single achievement
function sol.achievements.unlock(ach_id)
  --print("Unlocked Achievement:", ach_id)
  local game = sol.main.get_game()
  if not game:get_value("achievement_status_" .. ach_id) then
    game:set_value("achievement_status_" .. ach_id, true)
  else
    --print("Achievement " .. ach_id .. " already unlocked")
  end
  --Steam Achievements
  if sol.steam and sol.steam.unlock_achievement then
    sol.steam.unlock_achievement(ach_id)
  end
end


--Reset all achievements. Useful for development
function sol.achievements.reset_all()
  local game = sol.main.get_game()
  for i, ach_id in ipairs(ach_list) do
    game:set_value("achievement_status_" .. ach_id, nil)
  end
  --Reset in Steam
  if sol.steam and sol.steam.userStats and sol.steam.userStats.resetAllStats then
    sol.steam.userStats.resetAllStats(true)
  end
  print"All achievements reset"
end
