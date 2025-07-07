sol.steam = require"luasteam"

if not sol.steam.init() then
  error("Steam couldn't initialize")
  print("Could be missing luasteam.dll or steam_api64.dll from the directory with the game launcher or exe")
end

sol.timer.start(sol.main, 50, function()
  sol.steam.runCallbacks()
  return true
end)

sol.timer.start(sol.main, 20, function()
  print("Steam user ID:", sol.steam.user.getSteamID())
  assert(sol.steam.userStats.requestCurrentStats(), "No Steam user is logged in. Cannot do achievements and stuff")
end)



function sol.steam.userStats.onUserStatsReceived(data)
  sol.steam.can_use_stats = true
end


function sol.steam.unlock_achievement(ach_id)
  if sol.steam.can_use_stats then
    sol.steam.userStats.requestCurrentStats()
    if not sol.steam.userStats.setAchievement(ach_id) then
      print("Could not update achievement. Achievement ID: ", ach_id)
    end
    sol.steam.userStats.storeStats() -- shows overlay notification
  elseif not sol.steam.schedule_update_timer then
    --Can't use stats right now, schedule later update
    sol.steam.schedule_update_timer = sol.timer.start(sol.main, 3000, function()
      sol.steam.schedule_update_timer = nil
      sol.achievements.update()
    end)
  end
end



