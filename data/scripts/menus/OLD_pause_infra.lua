--

pause_infra = {}

local current_log = sol.surface.create(144, 72)

local stats_box = sol.surface.create(144, 48)

local inventory_box = sol.surface.create(78, 152)

local pause_img = sol.surface.create("hud/pause_infra.png")

 
local text_surface = sol.text_surface.create({
        font = "oceansfont",
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
--note that a size is not specified for a text surface, it will be as big as the text it contains
 



--Returns iterator to split text at line breaks
local function line_it(text)
    assert(type(text)=="string", "Bad argument #1 to 'line_it' (string expected, got "..type(text)..")")
 
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n").."\n" --convert instances of \r to \n and add line break to end
    return text:gmatch("([^\n]*)\n") -- Each line including empty ones.
end





function pause_infra:update_game(game)

    current_log:clear()
    stats_box:clear()
    inventory_box:clear()

--Quest Log
    local log_a_text = game:get_value("quest_log_a") --the string saved to the game value "quest_log_a" should match a key in strings.dat
    local next_line = line_it(sol.language.get_string(log_a_text)) --gets localized string in current language
 
    text_surface:set_text(next_line()) --line 1 of quest_log_a
    text_surface:draw(current_log, 0, 0) --renders first line of quest_log_a text and draws on current_log surface
 
    text_surface:set_text(next_line()) --line 2 of quest_log_a
    text_surface:draw(current_log, 0, 16)
 
    --NOTE: if quest_log_a contains more than 2 lines of text then the extra lines do not get drawn
 
    local log_b_text = game:get_value("quest_log_b")
    next_line = line_it(sol.language.get_string(log_b_text)) 
 
    text_surface:set_text(next_line()) --line 1 of quest_log_b
    text_surface:draw(current_log, 0, 39)
 
    text_surface:set_text(next_line()) --line 2 of quest_log_b
    text_surface:draw(current_log, 0, 55)
 
    --Now current_log contains an image rendered from text strings of log A & log B (up to 4 lines)
    --content won't change while pause menu open


--Stats
    local sword_dmg = game:get_value("sword_damage")
    text_surface:set_text(sword_dmg)
    text_surface:draw(stats_box, 4, 0)

    local bow_dmg = game:get_value("bow_damage")
    text_surface:set_text(bow_dmg)
    text_surface:draw(stats_box, 52, 0)

    local def = game:get_value("defense")
    text_surface:set_text(def)
    text_surface:draw(stats_box, 104, 0)


--Inventory
    local elixers = game:get_value("amount_elixer")
    text_surface:set_text(elixers)
    text_surface:draw(inventory_box, 0, 0)

    local coral = game:get_value("amount_coral_ore")
    text_surface:set_text(coral)
    text_surface:draw(inventory_box, 0, 16)

    local baits = game:get_value("amount_bait")
    text_surface:set_text(baits)
    text_surface:draw(inventory_box, 0, 32)

    local fireberry = game:get_value("amount_firethorn_berries")
    text_surface:set_text(fireberry)
    text_surface:draw(inventory_box, 0, 48)

    local geode = game:get_value("amount_geode")
    text_surface:set_text(geode)
    text_surface:draw(inventory_box, 0, 64)

    local bones = game:get_value("amount_bones")
    text_surface:set_text(bones)
    text_surface:draw(inventory_box, 0, 80)

    local guts = game:get_value("amount_guts")
    text_surface:set_text(guts)
    text_surface:draw(inventory_box, 0, 96)

    local kingscrown = game:get_value("amount_kingscrown")
    text_surface:set_text(kingscrown)
    text_surface:draw(inventory_box, 36, 0)

    local orchid = game:get_value("amount_ghost_orchid")
    text_surface:set_text(orchid)
    text_surface:draw(inventory_box, 36, 16)

    local wman = game:get_value("amount_mandrake_white")
    text_surface:set_text(wman)
    text_surface:draw(inventory_box, 36, 32)

    local mandrake = game:get_value("amount_mandrake")
    text_surface:set_text(mandrake)
    text_surface:draw(inventory_box, 36, 48)


end
 
 
 


function pause_infra:on_draw(dst_surface)
  --draw menu architecture
  pause_img:draw(dst_surface)
  --draw quest log A
  current_log:draw(dst_surface, 93, 27) --specify coordinates for where you want to draw it on the screen

  stats_box:draw(dst_surface, 115, 129)

  inventory_box:draw(dst_surface, 265, 33)

end