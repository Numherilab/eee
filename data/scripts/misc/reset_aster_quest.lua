local manager = {}

function manager:reset(game)
  local save_values = {
  "quest_phantom_squid_contracts",
  "aster_murdered",
  "phantom_squid_quest_completed",
  "talked_to_eamon",
  "quest_phantom_squid",
  "phantom_squid_quest_accepted",
  "taken_eamons_reward",
  "found_crabhook_contract",
  "squid_fled",
  "squid_quest_hidden_sensor_tripped",
  "goatshead_harbor_footprints_visible",
  "barbell_brutes_defeated",
  "barbell_boss_bested",
  "accepted_merchant_guild_contracts_quest",
  "aster_house_pressed_sesecret_switch",
  "possession_aster_note",
  "accepted_barbell_brute_quest",
  "barbell_guard_lets_you_in",
  }

  for k, v in pairs(save_values) do
  	game:set_value(v, nil)
  end

  game:get_item("contract"):set_variant(0)

end

return manager