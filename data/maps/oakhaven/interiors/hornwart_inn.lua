local map = ...
local game = map:get_game()
local hero = map:get_hero()
local inn_script = require"scripts/shops/inn"


map:register_event("on_started", function()
  if game:get_value("quest_hazel") >= 2 then map:set_doors_open("hazel_door") end
  if game:get_value("quest_manna_oaks") then hazel:set_enabled(false) end
  if not game:get_value("found_hazel_in_archives") then
    hazel:set_enabled(false)
  else
    for book in map:get_entities("new_book") do book:set_enabled(true) end
  end
  if game:get_value("quest_mangrove_sword") and game:get_value("quest_mangrove_sword") < 4 then
      hazel:set_enabled(false)
  end
end)


function beaufort:on_interaction()
  game:start_dialog("_oakhaven.npcs.inn.beaufort.staying_question", function(answer)
    if answer == 3 then --staying
      inn_script:start()
    elseif answer == 4 then --asking questions
      if game:get_value("hornwart_know_hazel") == true then
        game:start_dialog("_oakhaven.npcs.inn.beaufort.3")
      elseif game:get_value("grover_counter") ~= nil and game:get_value("grover_counter") >= 1 then
        game:start_dialog("_oakhaven.npcs.inn.beaufort.2")
        game:set_value("hornwart_know_hazel", true)
      elseif game:get_value("grover_counter") == nil then
        game:start_dialog("_oakhaven.npcs.inn.beaufort.1")
      end
    end
  end)
end

for book in map:get_entities("hazel_room_book") do
  function book:on_interaction()
    game:start_dialog(book:get_property("dialog"))
    if game:get_value("hornwart_checkout_books_first_time") ~= true then
      game:set_value("visited_hazel_room", true)
      game:set_value("quest_hazel", 3) --quest log
      game:set_value("hornwart_checkout_books_first_time", true)
    end
  end
end



function hazel:on_interaction()

  --get back from the archives
  if game:get_value("quest_hazel") < 7 then
    game:start_dialog("_oakhaven.npcs.hazel.inn.1", function()
      game:set_value("quest_mangrove_sword", 0) --start sword quest
      game:set_value("quest_hazel", 7) --end hazel quest log
      game:set_value("hazel_is_currently_following_you", true)
      end)

  --finished sword quest
  elseif game:get_value("quest_mangrove_sword") == 4 then
      --manna oaks quest
      if not game:get_value("quest_manna_oaks") then
        game:start_dialog("_oakhaven.npcs.hazel.inn.4gochecktrees")
        game:set_value("quest_manna_oaks", 0)
      elseif game:get_value("quest_manna_oaks") == 0 then
        game:start_dialog("_oakhaven.npcs.hazel.inn.5gogettwigs")
      end
  end
end
