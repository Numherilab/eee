--[[ objectives_manager.lua
	version 1.0.1
	30 Dec 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script manages a list of objectives (i.e. quests) displayed in a quest log, which
	are defined in the scripts/objectives.dat data file. The objectives are accessed using
	game.objectives. The quest log menu script used to display these objectives is located
	at scripts/menus/quest_log.lua.

	Local variables used internally by objective object (table):
	* index (number, integer): number to determine sort order (low to high beginning at 1). Added automatically at creation
	* objective_type (string): keyword corresponding to which objective list the objective belongs to ("main" or "side")
	* dialog_id (string): id of dialogs.dat entry to use for the description and title text of this objective
		> description string comes from dialog.text and title string comes from dialog.title
	* alternate_key (string): savegame variable to use as alternate quest identifier and to save the master index of active alternate quest
	* location (string or table): strings.dat key(s) to use for location string in a given phase
		(string): strings.dat key to use for the location string for this objective during all phases
		(table, indexed): strings.dat key to use for the location string for each phase of the objective, where the table index corresponds to the phase
			table values of false indicate to use an empty string for the location name
	* is_done (boolean): true if all phases of objective complete
	* calc_phase (string): The current phase is determined by the value of this save game key
		(table, combo): uses a custom callback to determine the current phase
	* replace_s (table, combo, optional): a custom callback to make substitutions to the description text using strings.dat values
	* s_keys (table, indexed): values to use for $s substitutions given the current state of save game values (must be refreshed when save game values change)
	* replace_v (table, combo, optional): a custom callback to make substitutions to the description text using numeric or save game values
	* v_values (table, indexed): values to use for $v substitutions given the current state of save game values (must be refreshed when save game values change)
	* num_phases (number, integer): The number of phases for this objective, determined by @ character count in dialog text
	* current_phase (number): current phase of the objective, false:not in player's log, 0:in log, no tasks complete, 1:first task complete, etc. done when equal to num phases

	Special Characters allowed in dialogs.text:
	Line beginning with '@' (ignore whitespace) - place a checkmark on this line when phase complete (one per phase)
	Line beginning with ';' (ignore whitespace) - manually sets which line the transition between phases occurs (max 1 between two @ lines); if omitted uses first blank line
	Line beginning with '?' (ignore whitespace) - hidden objective that is not revealed until task is complete
	Line beginning with '!' (ignore whitespace) - minor objective that is only shown during that phase (hidden before and after)
	Line beginning with '#' (ignore whitespace) - persistent descriptor that is visible every phase (and doesn't get greyed out until all quest objectives finished)
	Line beginning with '#!' (ignore whitespace) - Behaves like '#' in that it is shown from the start but will be hidden after passing that phase
	Line can begin with '@?' or '@!' and has same behavior as '?' and '!' respectively but adds checkmark on that line

	Determining which phase(s) description text from a quest will be visible:
	A quest can be comprised of multiple phases (subtasks), where the number of lines that
	begin with '@' in the dialog.dat text determines the number of phases. When the player
	has not received a quest, the phase will be false. Otherwise it is equal to the number
	of subtasks that the player has completed for that quest.

	When the player first starts a quest, the description text only reveals the lines that
	correspond up through the first phase, which is determined by the first line beginning
	with '@', including up to the first empty line. Upon completion of the fist task, more
	lines of text will be revealed, up to the first empty line following the next instance
	of a line that begins with '@'. A checkmark will also be placed on the line containing
	the first '@' with the text greyed out signifying that the first task is now complete.

	Certain special characters placed at the beginning of a line can influence whether the
	line will be visible or not. Whitespace is ignored when considering whether they occur
	at the beginning of a line or not. Any tab characters are removed from the description
	text, but spaces remain and can be used to indent the text of a line. This also allows
	for special characters at the beginning of a line to be followed by a tab character so
	that their text lines up with lines that begin with a tab but no special characters.

	Variable Substitution:
	'$v1' through '$v9' can appear in dialogs.text (multiple instances allowed) and can be
	used for the substitution of a numerical value or savegame variable (no translation is
	needed). For more info see replace_v in scripts/objectives.dat.

	'$s1' through '$s9' can appear in dialogs.text (multiple instances allowed) and can be
	used for the substitution of a strings.dat string (where translation is required). For
	more info see replace_s in scripts/objectives.dat.

	Note that $s substitutions are performed before $v substitutions, so it is possible to
	have $s make a substitution whose text includes $v, which will again be substituted.
--]]
local objectives_manager = {}

local STATUS_LIST = {
	"alternate_swap",
	"side_advanced_again",
	"main_advanced_again",
	"progressed_quest_item",
	"new_checkmark",
	"side_advanced",
	"main_advanced",
	"side_started",
	"main_started",
	"side_completed",
	"main_completed",
} for i,v in ipairs(STATUS_LIST) do STATUS_LIST[v]=i end --reverse look-up

--// Creates an objectives manager to create & update list of objectives, accessible through game.objectives
	--game: game datatype for the current game
	--no return value
function objectives_manager.create(game)
	local objectives = {} --table to be returned, contains functions to manage objectives, access using game.objectives

	--data tables
	local objectives_list = { --(table, key/value) master set of all objectives, 1 entry per menu sidebar tab
		main={completed_count=0, alternates_count=0}, --(table, combo) main quest list
		side={completed_count=0, alternates_count=0}, --(table, combo) side quest list
			--table indices: list of objectives (table) of this type, order determines display order
			--completed_count: (number, integer) the number of quests the player has completed from this list
			--alternates_count: (number, integer) each alternate quest beyond the first in a set increments value by 1, subtract this number from the total quest count for the player to complete
	}
	local alternates_list = {} --(table, key/value) set of alternate quest keys (string) with the objective_type (string) as the value
	local save_val_list = {} --(table, array) set with keys of savegame variable names (string) that when changed will cause the objectives to be refreshed
		--(table, array) values are a table that lists all the objectives (table) that are affected by that save game variable
	local map_val_list = {} --(table, array) list of objectives that need to be refreshed whenever the map changes
	local ids = {} --(table, key/value) set with dialog_ids (string) as keys and the corresponding objective (table) as the value, no duplicate dialog_ids allowed
	local active_npcs = {} --(table, key/value) set with npc entity ids (string) as keys, value is set to true if the npc is related to an active quest, otherwise nil

	--settings
	local is_new_task = false --(boolean) true if new task is available in quest log
	--| set to false using objective_manager:clear_new_tasks() whenever quest log is opened

	--// Cycles through all objectives and updates list of NPCs related to an active objective
	--call this after refreshing objective(s), also called during initialization
	local function refresh_npcs()
		active_npcs = {}
		for _,sub_list in pairs(objectives_list) do
			for _,objective in ipairs(sub_list) do
				if objective:is_active_alt()~=false and not objective:is_done() then
					local npc = objective:get_active_npc()
					if npc then active_npcs[npc] = true end
				end
			end
		end
	end

	--// Refreshes all objectives, starting with active alternate quests
	--does not trigger the game.objectives:on_quest_updated() event
	local function initial_refresh()
		local refreshed = {} --keep track of objectives that have been refreshed

		--first refresh active alternate quests
		for alt_key,_ in pairs(alternates_list) do
			local alt_id = game:get_value(alt_key)
			if alt_id then
				local objective = ids[alt_id]
				if objective and objective:get_alternate_key()==alt_key then
					objective:refresh()
					refreshed[objective] = true
				else game:set_value(alt_key, nil) end --invalid alternate index saved; remove it
			end
		end

		--now refresh all other quests
		for _,sub_list in pairs(objectives_list) do
			for _,objective in ipairs(sub_list) do
				if not refreshed[objective] then objective:refresh() end --don't refresh a second time
			end
		end
	end


	local MAP_VALUES = {
		MAP_ID = "get_id",
		MAP_WORLD = "get_world",
		MAP_FLOOR = "get_floor",
	}

	--// Converts list of inputs for a custom function to their current values
		--data (table, array) list of strings indicating the input to use
			--if entirely alpha-numeric characters and underscore then treated as the name of a savegame variable, whose current value is returned
			--if string begins with an "@" character then the characters that follow are interpreted as a map property key, whose current value is returned
			--if string begins with an "$" character then the characters that follow are interpreted as a special keyword:
				--"$MAP_ID" - value returned is the id (string) of the current map, or nil if the game is not running
				--"$MAP_WORLD" - value returned is the word name (string) of the current map, or nil if it is not defined or if the game is not running
				--"$MAP_FLOOR" - value returned is the floor number (number, integer), or nil if is not defined or if the game is not running
		--returns (table, array) table with the same number of entries as data argument, each corresponding to its associated value
			--the returned table contains key "n" which is equal to the number of entries in the data argument, which is useful if some values are nil
	local function get_values(data)
		local values = {n=#data} --store number of data entries since #values is unreliable if some values are nil
		local data = data
		local map = game:get_map()

		for i,entry in ipairs(data) do
			local map_val = entry:match"^%$(.*)"
			if map_val then
				if map then --special keywords begin with $
					local func_name = MAP_VALUES[map_val]
					if func_name then values[i] = map[func_name](map) end
				end
			else
				local map_property = entry:match"^%@(.*)"
				if map_property then
					if map then --map properties begin with @
						--TODO when maps can be assigned properties
						--values[i] = map:get_property(map_property)
					end
				else values[i] = game:get_value(entry) end --may be nil
			end
		end

		return values
	end


	--## Load Objectives Data File ##--

	--// Loads a data file and creates new objectives for each entry
	--see scripts/objectives.dat for info on the data file format
		--file (string, optional) - file path of the data file to load
			--default: "scripts/objectives.dat"
	function objectives:load_data(file)
		local file = file or "scripts/objectives.dat"
		assert(type(file)=="string", "Bad argument #2 to 'load_data' (string or nil expected)")

		--how to parse the data file
		local env = {}
		function env.print(...) print(...) end --DEBUG
		setmetatable(env, { __index = function(_, name)
			if objectives_list[name] then
				return function(properties) objectives:add_objective(properties, name) end
			else return function() end end --ignore anything else
		end})

		--load objectives.dat data file and save in objectives_list
		local chunk = sol.main.load_file(file)
		assert(chunk, "Unable to load file: "..file)
		setfenv(chunk, env)
		chunk()
	end

	--// Creates new objective from properties table, validating data, then adds to objectives_list
		--properties (table): key/value table describing objective characteristics (see scripts/objectives.dat)
		--objective_type (string): keyword for which objective list to add it to ("main" or "side")
		--returns newly created objective object (table)
	function objectives:add_objective(properties, objective_type)
		local new_objective = {} --(table, key/value) contains objective data for single quest

		--settings defined by data file property values and their default values
		local dialog_id = properties.dialog_id --(string) dialogs.dat key for title and description of this objective
		local alternate_key = properties.alternate_key --(string or nil) unique id for the set of alternate quests this quest belongs to, if any. If nil then is not an alternate quest
		local calc_phase = properties.calc_phase --(string) save value key or (table) contains save value keys and callback function (see scripts/objectives.dat)
		local location = properties.location or {} --(string or table, array) strings.dat key(s) giving the location text to display for the current quest phase (see scripts/objectives.dat)
		local npc_ids = properties.npc or {} --(table, array) list of NPC entity ids (string) that need to be interacted with in a given phase, or false if no NPC for that phase
		local replace_s = properties.replace_s --(table, combo or nil) list of save val keys and callback function to perform string substitution on desc string, if nil then no substitutions
		local replace_v = properties.replace_v --(table, combo or nil) list of save val keys and callback function to perform value substitution on desc string, if nil then no substitutions
		local checkmarks = properties.checkmarks --(table, combo or nil) list of save val keys and callback function to determine state of dynamic checkmarks, if nil then no dynamic checkmarks
		local item_info = {} --(table, array) list of item ids corresponding to each quest item associated with this quest

		--additional settings
		local save_vals = {} --(table, key/value) set with keys of savegame variable names (string) that affect this objective, values are true
		local is_map_refresh = false --(boolean) if true then this objective needs to be refreshed every time the map changes
		local objective_type = objective_type --(string) keyword for which objective list this quest belongs to ("main" or "side")
		local num_phases = 0 --(number, integer) the number of subtasks (phases) present in this quest
		local index --(number, positive integer) the index value assigned to this quest, corresponds to the order in which the quest is defined in objectives.dat

		--constants
		local full_list = objectives_list[objective_type] --convenience, (table, array) list of objectives (table) for this objective_type

		--updated on refresh
		local is_done --(boolean) true if all phases of this quest complete
		local current_phase --(number, non-negative integer or nil) the current phase of this quest, is 0 when added to log,
		--| quest is complete when equal to number of phases, nil if not in log
		local reached_phase = -1 --(number, integer) the highest phase the player has reached for this quest, reset each play session
		local s_keys --(table, array or false) list of up to 9 strings.dat keys (string) whose value is used for string substitutions,
		--| where the first entry substitutes for $s1, the second for $s2, etc. false if no substitutions
		local v_values --(table, array or false) list of up to 9 values (any) whose value is used for value substitutions after conversion to a string,
		--| where the first entry substitutes for $v1, the second for $v2, etc. false if no substitutions
		local checkmark_states --(table, array or false) list of up to 9 dynamic checkmark states (boolean or nil),
		--| where the first entry substitutes for $@1, the second for $@2, etc. false if no substitutions. Possible values:
			--nil - dynamic checkmark is not drawn
			--false - dynamic checkmark displays as a bullet (not complete)
			--true - dynamic checkmark displays as complete
		local active_npc --(string) npc entity id corresponding to the npc (max 1 at any given time) related to the current phase of this quest
		--| interacting with the npc will either add the quest to the player's log or advance it to the next phase
		local active_item_index --(number, positive integer) index of objectives.dat item with highest rank that is currently in player inventory
		local active_items = {} --(table, key,value) status of first 9 quest items, keys are the number of the quest item, values are true if that item is currently in the player's inventory
		local is_all_items --(boolean or nil) true if player has all quest items
		local latest_status = nil --(string or false or nil) string describing the latest update status for this quest, or false if it hasn't been updated
		--| value is nil prior to initial loading and becomes false when loading is done

		local function add_custom_input(keyword)
			local map_val = keyword:match"^%$(.*)"
			if map_val and not is_map_refresh then --TODO also need to refresh for map user-defined properties once implemented
				local func_name = MAP_VALUES[map_val]
				if func_name then is_map_refresh = true end
			else save_vals[keyword] = true end
		end


		--// validate data file property values

		assert(type(properties)=="table", "Bad argument #2 to 'add_objective' (table expected)")

		--validate objective_type
		assert(type(objective_type)=="string", "Bad argument #3 to 'add_objective' (string expected)")

		--validate full_list
		assert(full_list, "Bad argument #3 to 'add_objective', invalid objective type: "..objective_type)

		--validate dialog_id
		assert(type(dialog_id)=="string", "Bad property dialog_id to 'add_objective' (string expected)")
		assert(not ids[dialog_id], "Bad property dialog_id to 'add_objective' (2 objectives cannot have the same id)")
		local dialog = sol.language.get_dialog(dialog_id) --temporary, dialogs.dat entry for this quest (table, key/value)
		assert(dialog, "Bad property dialog to 'add_objective', dialogs.dat id not found: "..dialog_id)
		ids[dialog_id] = new_objective

		--validate alternate_key
		if alternate_key then
			assert(type(alternate_key)=="string", "Bad property alternate_key to 'add_objective' (string or nil expected)")
			if not alternates_list[alternate_key] then --this is the first alternate quest with this key
				alternates_list[alternate_key] = {
					new_objective, --add first alternate quest to list
					objective_type = objective_type, --future alternate quests must match type
				}
			else
				assert(
					alternates_list[alternate_key].objective_type == objective_type,
					"Bad property alternate_key to 'add_objective', alternate quests must be of the same type (i.e. main or side)"
				)

				table.insert(alternates_list[alternate_key], new_objective)
				full_list.alternates_count = full_list.alternates_count + 1 --alternate quests beyond the first one do not count toward total quest counts
			end
		end

		--validate calc_phase
		assert(type(calc_phase)=="string" or type(calc_phase)=="table",
			"Bad property calc_phase to 'add_objective' (string or table expected)"
		)
		if type(calc_phase)=="table" then
			assert(type(properties.calc_phase.callback)=="function",
				"Bad property calc_phase to 'add_objective' (function expected for calc_phase table key 'callback')"
			)
			for i,save_key in ipairs(properties.calc_phase) do
				assert(type(save_key)=="string", "Bad property calc_phase to 'add_objective' (string expected for index "..i..")")
				add_custom_input(save_key)
			end
		else add_custom_input(calc_phase) end

		--validate location
		assert(type(location)=="table" or type(location)=="string",
			"Bad property location to 'add_objective' (table or string or nil expected)"
		)
		if type(location)=="table" then --verify table entries and substitute values for true
			for _,loc in ipairs(location) do
				assert(not loc or type(loc)=="string", "Bad property location to 'add_objective' (table values must be a string or nil/false)")
				assert(not loc or sol.language.get_string(loc), "Bad property location to 'add_objective', invalid string.dat key: "..tostring(loc))
			end
		end

		--validate npc_ids
		assert(type(npc_ids)=="table", "Bad property npc to 'add_objective' (table or nil expected)")
		for _,npc in ipairs(npc_ids) do
			assert(not npc or type(npc)=="string", "Bad property npc to 'add_objective' (string or nil expected as table values)")
		end

		--validate replace_s
		if replace_s then --is table
			assert(type(replace_s)=="table", "Bad property replace_s to 'add_objective' (table or nil expected)")
			assert(type(replace_s.callback)=="function",
				"Bad property replace_s to 'add_objective' (function expected for replace_s table key 'callback')"
			)
			for i,save_val in ipairs(replace_s) do
				assert(type(save_val)=="string", "Bad property replace_s to 'add_objective' (string expected for index "..i..")")
				add_custom_input(save_val)
			end
		end

		--validate replace_v
		assert(not replace_v or type(replace_v)=="table", "Bad property replace_v to 'add_objective' (table or nil expected)")
		if replace_v then --is table
			assert(not replace_v.callback or type(replace_v.callback)=="function",
				"Bad property replace_v to 'add_objective' (function or nil expected for replace_v table key 'callback')"
			)
			for i,save_val in ipairs(replace_v) do
				assert(type(save_val)=="string", "Bad property replace_v to 'add_objective' (string expected for index "..i..")")
				add_custom_input(save_val)
			end
		end

		--validate checkmarks
		assert(not checkmarks or type(checkmarks)=="table", "Bad property checkmarks to 'add_objective' (table or nil expected)")
		if checkmarks then --is table
			assert(type(checkmarks.callback)=="function",
				"Bad property checkmarks to 'add_objective' (function expected for checkmarks table key 'callback')"
			)
			for i,save_val in ipairs(checkmarks) do
				assert(type(save_val)=="string", "Bad property checkmarks to 'add_objective' (string expected for index "..i..")")
				add_custom_input(save_val)
			end
		end

		--validate item_info
		local items = properties.items --convenience, list of quest items (table, array or nil), entries with higher index take precedence
		if items then --is table
			assert(type(items)=="table", "Bad property items to 'add_objective' (table or nil expected)")
			for i,item_str in ipairs(items) do
				assert(type(item_str)=="string", "Bad property items["..i.."] to 'add_objective' (string expected)")

				local item_id, variant = item_str:match"^([_%w]+)%.(%d+)$"
				variant = tonumber(variant)
				assert(item_id and variant, "Bad property items["..i.."] to 'add_objective', item identifier must be 'item_id.variant' where variant is a number")
				--TODO verify variant is valid number

				local item = game:get_item(item_id)
				assert(item, "Bad property items["..i.."] to 'add_objective', item not found: "..item_id)

				local item_key = "item."..item_str
				local save_val = item:get_savegame_variable()

				if save_val then
					add_custom_input(save_val)
					table.insert(item_info, {
						id = item_id,
						variant = variant,
						name_key = item_key, --strings.dat entry giving name of item
						item = item, --sol.item object
						save_val = save_val, --name of savegame variable for item
					})
				end
			end
		end
		items = nil --no longer needed


		--// implementation

		--add save vals to master save_val_list
		for save_val,_ in pairs(save_vals) do
			if not save_val_list[save_val] then save_val_list[save_val] = {} end

			table.insert(save_val_list[save_val], new_objective)
		end

		--add objective to mav_val_list if it needs refresh when changing maps
		if is_map_refresh then table.insert(map_val_list, new_objective) end

		--determine number of phases
		local desc_text = "\n"..dialog.text --temporary
		for _ in desc_text:gmatch"[\n\r]%s*(%@)" do --find each line beginning with @ (excluding leading whitespace)
			num_phases = num_phases + 1
		end
		num_phases = math.max(num_phases, 1) --must have at least one phase
		desc_text = nil --don't keep, outdated when language changed
		dialog = nil --don't keep, outdated when language changed

		--add new_objective to master list
		index = #full_list + 1 --save index to keep track of sort order
		table.insert(full_list, new_objective)

		--// Updates objective based on the current state of save game values
			--objective (table): the objective to be refreshed
			--returns string indicating status of how objective was updated, or false or nil
				--The status returned is the following priority (ones above override ones below):
				--"main_completed" or "side_completed" - quest advanced past final phase
				--"main_started" or "side_started" - quest was added to player's log
				--"main_advanced" or "side_advanced" - quest phase increased
				--"new_checkmark" - at least one dynamic checkmark previously unchecked became checked
				--"progressed_quest_item" - the player obtained a quest item ranked higher than any quest items previously in possession
				--false - nothing changed worth noting
				--nil - quest was already complete, did not check status
		function new_objective:refresh()
			--save old values before they are updated
			local prev_phase = current_phase
			local prev_item_index = active_item_index or 0
			local prev_checkmarks = {}
			for i=1,9 do prev_checkmarks[i] = checkmark_states and checkmark_states[i] end

			if not is_done then --note: value of is_done has not been updated yet, assumes quest won't ever go from done back to not done
				--determine current phase
				if type(calc_phase)=="string" then
					current_phase = tonumber(game:get_value(calc_phase))
				else
					local values = get_values(calc_phase)

					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = prev_phase --can't use current_phase because it hasn't been calculated yet, so use prev_phase instead
					values.num_phases = num_phases
					values.location_key = self:get_location_key()
					values.npc_id = active_npc --npc from prev phase
					values.item_id = active_item_index and item_info[active_item_index].id --item from prev phase

					current_phase = tonumber(calc_phase.callback(values) or false) --TODO should allow implicit return of nil?
				end

				--determine if alternate quest that became active or became in-active
				if alternate_key then
					if current_phase and not prev_phase then --is alternate quest that was just started
						--do not start quest if an alternate quest is already active
						local alternate_objective = alternates_list[alternate_key].active
						if alternate_objective and alternate_objective ~= self --already an active alternate quest
						and alternate_objective:get_current_phase() then --alternate quest is active
							current_phase = nil --do not start this quest because alternate quest already active
							return false --status is not worth noting
						end

						--this quest becomes the active alternate quest
						local dialog_id = self:get_dialog_id()
						game:set_value(alternate_key, dialog_id) --TODO alternate id
						alternates_list[alternate_key].active = self
					elseif prev_phase and not current_phase then --is alternate quest that went from active to in-active
						--the quest is no longer the active alternate quest
						game:set_value(alternate_key, nil)
						alternates_list[alternate_key].active = nil
					end
				end

				--determine if player has quest item in inventory
				active_item_index = nil --start fresh
				is_all_items = #item_info>0 --assume true until proven false, quest must have at least one quest item
				active_items = {}
				for i=#item_info,1,-1 do --iterate backwards to find highest index of item in player's inventory
					local item_save_val = item_info[i].save_val
					if game:get_value(item_save_val) then
						if not active_item_index then active_item_index = i end --only save first entry
						if i<=9 then active_items[i] = true end
					else is_all_items = false end
				end

				--determine the active npc, if any
				if not current_phase then
					active_npc = npc_ids.start --npc that gives the quest
				elseif not is_done then
					active_npc = npc_ids[current_phase + 1]
				else active_npc = false end

				--generate substitution string keys
				if replace_s then
					local values = get_values(replace_s) --list of values obtained from save game variables

					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = current_phase
					values.num_phases = num_phases
					values.location_key = self:get_location_key()
					values.npc_id = active_npc
					values.item_id = active_item_index and item_info[active_item_index].id

					s_keys = replace_s.callback(values) --list of strings.dat keys for substitution
					assert(type(s_keys)=="table", "Bad return value from replace_s callback in 'refresh' (table expected)")
				else s_keys = false end --no values to substitute

				--generate substitution values
				if replace_v then
					local values = get_values(replace_v) --list of values obtained from save game variables

					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = current_phase
					values.num_phases = num_phases
					values.location_key = self:get_location_key()
					values.npc_id = active_npc
					values.item_id = active_item_index and item_info[active_item_index].id

					if replace_v.callback then --use callback function if it exists
						v_values = replace_v.callback(values) --list of numeric values for substitution
						assert(type(v_values)=="table", "Bad return value from replace_v callback in 'refresh' (table expected)")
					else v_values = values end --use game save vals directly
				else v_values = false end --no values to substitute

				--determine state of dynamic checkmarks
				if checkmarks then
					local values = get_values(checkmarks) --list of values obtained from save game variables

					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = current_phase
					values.num_phases = num_phases
					values.location_key = self:get_location_key()
					values.npc_id = active_npc
					values.item_id = active_item_index and item_info[active_item_index].id

					checkmark_states = checkmarks.callback(values) --list of strings.dat keys for substitution
					assert(type(checkmark_states)=="table", "Bad return value from checkmarks callback in 'refresh' (table expected)")
				else checkmark_states = false end --no values to substitute

				--determine if quest is now done
				if current_phase and current_phase >= num_phases then
					is_done = true
					--increment completed count, must only happen one time max per objective
					full_list.completed_count = full_list.completed_count + 1
				else is_done = false end
			else return end --if objective is already done then nothing to refresh

			--determine what was updated for this objective
			local status = false --tentative; string indicating how quest was updated
			if current_phase then --only check status of quests in player's log
				if prev_phase~=current_phase then
					if is_done then --quest completed
						status = objective_type.."_completed"
					elseif not prev_phase then --quest started
						status = objective_type.."_started"
					elseif current_phase > prev_phase then
						if current_phase > reached_phase then
							status = objective_type.."_advanced"
						else status = objective_type.."_advanced_again" end
					end --else status is false (not worth noting progress went backwards)
				else
					--check if any dynamic checkmarks became checked
					local is_new_checkmark = false --tentative
					if checkmark_states then
						for i=1,9 do
							if checkmark_states[i] and not prev_checkmarks[i] then
								is_new_checkmark = true
								break
							end
						end
					end

					if is_new_checkmark then --dynamic checkmark became checked
						status = "new_checkmark"
					elseif (active_item_index or 0) > prev_item_index then
						status = "progressed_quest_item"
					end --else status is false (nothing updated worth noting)
				end
			end

			--update highest reached phase
			if current_phase and current_phase > reached_phase then
				reached_phase = current_phase
			end

			if latest_status~=nil then --not the first time updating
				latest_status = status or latest_status --save latest status
			else latest_status = false end --ignore any status updates for initial loading

			return status
		end

		--// Returns the latest status update, which persists until new_objective:clear_status() is called
			-- returns (string or false) string describing the latest status, or false if no new status
		function new_objective:get_status() return latest_status end

		--// Reset objective status so no longer considered to have new updates
		function new_objective:clear_status() latest_status = false end

		--// Returns a string of the title of the objective localized in the current language
		function new_objective:get_title()
			 return sol.language.get_dialog(dialog_id).title or ""
		end

		--// Returns a string localized in current language representing the location of the objective for the current phase
			--phase (number, positive integer, optional) - manually force the phase to be shown (for debugging)
		function new_objective:get_location(phase)
			local location = self:get_location_key(phase) --may be false
			if location then
				return sol.language.get_string(location) or ""
			else return "" end
		end

		--// Returns a strings.dat key corresponding ot the the location of the objective for the current phase
			--phase (number, positive integer, optional) - manually force the phase to be shown (for debugging)
		function new_objective:get_location_key(phase)
			if type(location)=="string" then
				return location
			elseif type(location)=="table" then
				if not current_phase then return false end --quest has not started

				--use specified phase argument if is a number, otherwise use current phase
				local phase = tonumber(phase)
				if phase then
					phase = math.floor(phase)
				else phase = current_phase end

				--determine location text
				local location_key
				if phase>=num_phases then
					location_key = location[num_phases] --when done continues to display last location
				else location_key = location[phase + 1] end --add 1 because location is for the task that is going to be completed next

				if location_key then --value is a string
					return location_key
				else return false end --invalid location, display empty string instead
			else return false end --invalid location, display empty string instead
		end

		--// Returns NPC id string for the current phase
			--phase (number, positive integer, optional) - use the specified phase instead of the current phase (for debugging)
		function new_objective:get_npc_id(phase)
			local phase = tonumber(phase)
			if phase then
				phase = math.floor(phase)
			else phase = current_phase end

			if not phase then return npc_ids.start or false end --quest has not started yet

			if phase>=num_phases then return false end --no npc when quest is done
			return npc_ids[phase + 1] or false
		end
		function new_objective:get_active_npc() return active_npc end

		--// Returns the equipment item id of the highest ranked quest item in the player's inventory
			--returns (string or nil) - equipment item id, or nil if the player doesn't have any quest items
		function new_objective:get_active_item_id()
			return active_item_index and item_info[active_item_index].id
		end

		--// Returns the item index of the highest ranked quest item in the player's inventory
			--returns (number, positive integer or nil) - item index, or nil if the player doesn't gave any quest items
		function new_objective:get_active_item_index() return active_item_index end

		--// Returns the item id and variant of the quest item with the given index
			--index (number, positive integer, optional) - quest item index (first quest item is 1)
		function new_objective:get_item_id(index)
			if index then
				index = tonumber(index)
				assert(index, "Bad argument #2 to 'get_item_sprite_info' (number or nil expected)")
			elseif active_item_index then
				index = active_item_index
			else return nil, nil end

			local info = item_info[index]
			if not info then return nil, nil end

			return info.id, info.variant
		end

		--// Returns the savegame variable for the quest item with the specified index
			--index (number, positive integer, optional) - quest item index (first quest item is 1)
			--returns (string or nil)
		function new_objective:get_item_save_val(index)
			return item_info[index] and item_info[index].save_val
		end

		--// Custom iterator to get $s strings.dat keys for current variable substitution values (does not expose internal table)
			--usage: for i,str_key in new_objective:iter_s_keys() do
		function new_objective:iter_s_keys()
			local iter,_,start_val = ipairs(s_keys)
			return function(_,i) return iter(s_keys, i) end, {}, start_val
		end

		--// Custom iterator to get $v values for current variable substitution values (does not expose internal table)
			--usage: for i,str_key in new_objective:iter_v_values() do
		function new_objective:iter_v_values()
			local iter,_,start_val = ipairs(v_values)
			return function(_,i) return iter(v_values, i) end, {}, start_val
		end

		--// Custom iterator to get $@ states for dynamic checkmarks (does not expose internal table)
			--usage: for i,state in new_objective:iter_checkmarks() do
		function new_objective:iter_checkmarks()
			local iter,_,start_val = ipairs(checkmark_states)
			return function(_,i) return iter(checkmark_states, i) end, {}, start_val
		end

		--handling rules based on up to two first special characters of a line
		local SPECIAL_CHARSET = "#%?!%%@;" --All special characters; include % escape char where applicable
		local SPECIAL_VISIBLE = "#%?!%%" --These special characters determine whether line is visible in a given phase; include % escape char where applicable
		local IGNORE_CHARSET = "%s@;" --These characters are ignored because they do not affect visibility; include % escape char where applicable
		local SPECIAL_CHAR_VISIBILITY = { --conditions for whether a line is visible based on the first two special characters (order matters!)
			--rank (number): assigned to each line, incrementing based on where @ and blank lines occur
			--phase (number): current phase for a given objective (equal to number of subtasks completed)
			--returns true if the line should be visible for a given phase based on its rank
			['#'] = function(rank, phase) return true end, --visible for every phase
			[''] = function(rank, phase) return phase >= rank end,
			['!'] = function(rank, phase) return phase == rank end,
			['?'] = function(rank, phase) return phase > rank end,
			['#!'] = function(rank, phase) return phase <= rank end,
			['?!'] = function(rank, phase) return false end, --never visible
		} --do not include % escape char
		SPECIAL_CHAR_VISIBILITY['##'] = SPECIAL_CHAR_VISIBILITY['#'] --visibility behavior is the same (coloring is not)
		SPECIAL_CHAR_VISIBILITY['!?'] = SPECIAL_CHAR_VISIBILITY['?!'] --allow reverse order
		SPECIAL_CHAR_VISIBILITY.default = SPECIAL_CHAR_VISIBILITY['']

		--// Returns indexed table with entry for each line of description from dialogs.dat
			--phase (number, optional) specifies phase to use when determining which subtasks are complete (for debugging)
				--use nil to use the in-game current phase as determined by current state of savegame_variables
			--subs_s (table, indexed) list of substitutions to make for $s1-$s9 (for debugging)
				--use nil to use the normal substitutions as determined by in-game logic
			--subs_v (table, indexed) list of substitutions to make for $v1-$v9 (for debugging)
				--use nil to use the normal substitutions as determined by in-game logic
		--//Each entry of returned table contains the following key/values:
			--text (string): line of text localized for current language
			--is_active (boolean): false indicates the text should be greyed out because the player has already completed that task
			--is_check (boolean): true indicates that this line begins with @ for a checkmark
				--note the checkmark should only be shown if is_active also is false
			--rank (number): internal use only
			--is_visible (boolean): internal use only (will be true for all)
			--is_persistent (boolean): true if line begins with # (also true for #!)
			--do_not_grey (boolean): internal use only, true if always is_active (unless quest is done, then false)
			--note: lines that are not visible are omitted
		function new_objective:get_description(phase, subs_s, subs_v, subs_check)
			if phase then
				phase = tonumber(phase)
				assert(phase, "Bad argument #2 to 'get_description' (number or nil expected)")
			else phase = current_phase or 0 end --ensure number if equal to false (quest not yet given to player)
			--TODO should lines be visible if player hasn't received quest yet?

			assert(not subs_s or type(subs_s)=="table", "Bad argument #3 to 'get_description' (table or nil expected)")
			assert(not subs_v or type(subs_v)=="table", "Bad argument #4 to 'get_description' (table or nil expected)")
			assert(not subs_check or type(subs_check)=="table", "Bad argument #5 to 'get_description' (table or nil expected)")

			--use specified substitution valies if provided (for debugging)
			--otherwise use normal substitutions determined based on current state of savegame variables
			subs_s = subs_s or s_keys or {}
			subs_v = subs_v or v_values or {}
			subs_check = subs_check or checkmark_states or {}

			local dialog = sol.language.get_dialog(dialog_id) --dialog.text is desc text, dialog.title is title
			--strip out tab characters and standardize all line breaks to '\n'
			local desc_text = dialog.text:gsub("\t", ""):gsub("\r\n", "\n"):gsub("\r","\n")

			--perform $s substitutions (text values from strings.dat)
			--note performed first because may substitute for text containing $v needing additional substitution(s)
			for i=1,9 do
				local sub_text = subs_s[i] and sol.language.get_string(subs_s[i]) or "" --get strings.dat text
				desc_text = desc_text:gsub("%$s"..i, tostring(sub_text))
			end

			--perform $v substitutions (numerical values or from save game variables)
			for i=1,9 do
				--TODO convert values of true to empty string?
				local sub_text = tostring(subs_v[i] or "")
				desc_text = desc_text:gsub("%$v"..i, sub_text)
			end

			local item_positions = {} --index of first line containing $i
			local phase_breaks = {} --list of line indicies where phase break occurs
			local first_filler_line --line where first "visible" filler occurs (add extra blank lines here)
			local look_for_next_break = false --while true, finding a ; or beginning with @ will cause a phase break
			local first_line_break --line where first blank line after line beginning with @ occurs
				--need to remember this retroactively in case no beginning ; found between lines with @

			--get description text line by line and find phase breaks (first pass)
			local lines = {} --includes invisible lines

			--first pass: parse special characters and calculate rank of each line
			for line in desc_text:gmatch"([^\n]*)\n" do --each line including including empty ones
				local entry = {}
				table.insert(lines, entry)

				--// parse $ITEM_NAME and replace with name of active quest item

				local item_name_key = active_item_index and item_info[active_item_index].name_key

				local sub_item_name
				if item_name_key then
					sub_item_name = sol.language.get_string(item_name_key) or ""
				else sub_item_name = "" end

				line = line:gsub("%$ITEM_NAME", sub_item_name)

				--// strip out special characters and comments

				entry.is_filler = not not line:match"^%s*#?::" --line begins with ::
				if entry.is_filler then line = line:gsub("::", "", 1) end --remove first instance of ::

				entry.is_hard_break = not not line:match"^%s*#?;;" --line begins with ;; (also counts as phase break)
				if entry.is_hard_break then line = line:gsub(";;", ";", 1) end --remove first instance of ;;

				--strip %0 thru %9 characters (max of 1 per line)
				local char = line:match"^%s*#?%%(.)"
				local digit = tonumber(char)
				if char=="=" or char=="~" or char=="&" then digit = char end
				if digit then --contains instance of %0 thru %9 or %= or %~ or %&
					line = line:gsub("%%.", "", 1) --remove first instance of %0-%9 or %= or %~ or %&
					entry.item_marker = digit
				end

				--create string for current line stripped of comments and leading special characters
				local stripped_text = line:match"^(.-)%-%-//" --remove comments
				if stripped_text then
					if stripped_text:match"^%s*$" then entry.is_comment = true end --line contains exclusively whitespace and comments
				else stripped_text = line end --line is already stripped of comments

				--strip leading special characters
				local search_pattern = "^%s*["..SPECIAL_CHARSET.."]["..SPECIAL_CHARSET
					.."]?["..SPECIAL_CHARSET.."]?(.*)" --only want to remove leading whitespace if there is at least one special char
				stripped_text = stripped_text:match(search_pattern) or stripped_text --special chars now removed from body text
				entry.line = line --line preserves beginning special characters

				--// determine where to place item icons then strip out special characters

				item_positions[#lines] = {}

				--look for and save misc_item icon placeholder text, make substitution later
				local misc_item_text --text for misc_item icon placeholder, may be nil if not present
				local item_id, variant = stripped_text:match"%$ITEM{([_%w]+)%.(%d+)}"
				if item_id then misc_item_text = "%$ITEM{"..item_id.."%."..variant.."}" end

				--check for first instance of item image marker $i, additional instances ignored
				local pre_text, icon_num = stripped_text:match"^(.-)%$i(%d)" --text preceding $i
				while pre_text do
					if not item_positions[#lines][icon_num] then
						if misc_item_text then --remove any misc item markers so doesn't affect position
							pre_text = pre_text:gsub(misc_item_text, "")
						end

						pre_text = pre_text:gsub("%$@%d", " "):gsub("%$%d", "") --remove dynamic checkmarks so doesn't affect position
						pre_text = pre_text:gsub("%$%!", ""):gsub("%$%?", "")

						item_positions[#lines][icon_num] = pre_text
					end
					stripped_text = stripped_text:gsub("%$i"..icon_num, "") --remove matching $i instances, no longer needed
					pre_text, icon_num = stripped_text:match"^(.-)%$i(%d)" --text preceding $i for next loop
				end

				--substitute for misc_item icon
				if misc_item_text then
					pre_text = stripped_text:match("^(.-)"..misc_item_text)

					pre_text = pre_text:gsub("%$@%d", " "):gsub("%$%d", "") --remove dynamic checkmarks so doesn't affect position
					pre_text = pre_text:gsub("%$[%!%?]", "")

					item_positions[#lines]['11'] = pre_text --TODO allow more than one misc_item icon?
					item_positions.item_id = item_id
					item_positions.variant = variant
					stripped_text = stripped_text:gsub(misc_item_text, "")
				end

				--// parse dynamic checkmarks: $@1 to $@9 and $1 to $9

				local check_index --which dynamic checkmark index the line is associated with (e.g. $@5 is index of 5, as is $5)

				local check_position = stripped_text:find"%$@%d"
				if check_position then --has dynamic checkmark on this line
					check_index = tonumber(stripped_text:match"%$@(%d)")
					pre_text = stripped_text:sub(1,check_position-1) --save text preceding checkmark
					pre_text = pre_text:gsub("%$[%!%?]", "")

					entry.check_index = check_index
					entry.check_position = pre_text
				else check_index = tonumber(stripped_text:match"%$(%d)") end --only look for $1-$9 instances if no dynamic checkmark on the line

				--ignore index values of zero
				if check_index==0 then
					check_index = nil
					check_position = nil
				end

				--strip out dynamic checkmark characters now that info is saved
				for i=1,9 do
					stripped_text = stripped_text:gsub("%$@"..i, " "):gsub("%$"..i, "")
				end

				--// parse split line special characters: $! & $?

				--find first instance of either '$!' or '$?'
				local start,_,char = stripped_text:find"%$([%!%?])"
				if start then
					entry.split1_index = start - 1
					entry.split1_char = char
					stripped_text = stripped_text:gsub("%$[%"..char.."]", "") --remove all instances

					--now search for just the opposite character
					char = char=="!" and "?" or "!"
					start = stripped_text:find("%$(%"..char..")")
					if start then
						entry.split2_index = start - 1
						entry.split2_char = char
						stripped_text = stripped_text:gsub("%$[%"..char.."]", "") --remove all instances
					end
				end


				--// handle special characters at beginning of line

				entry.text = stripped_text

				--look for special characters at beginning of line that affect how it is displayed
				entry.is_check = not not line:match"^%s*@" --line begins with @ (has checkmark)
				entry.is_persistent = not not line:match"^%s*[@;]?#" --line beginning with # (always active/visible)
				entry.do_not_grey = not not (line:match"^%s*[;]?##" or line:match"^%s*#%%") --line must begin with ## or #% in order to not be greyed out
				local is_empty = line:match"^%s*$" and not entry.is_filler and not digit --non-nil if line contains entirely whitespace (no special chars or comments either)
				local is_phase_break = line:match"^%s*;" --non-nil if line begins with ;
				if entry.is_hard_break or entry.is_filler then entry.is_comment = true end

				--determine where phase breaks occur
				if look_for_next_break then --search for first ; or first empty line or @
					if is_empty then
						if not first_line_break then first_line_break = #lines end
						--look_for_next_break = false
					elseif is_phase_break then
						phase_breaks[#lines] = true
						look_for_next_break = false
						first_line_break = nil --ignore first line break because ; overrides
					elseif entry.is_check then --line begins with @
						if first_line_break then --found an empty line between here and last @
							phase_breaks[first_line_break] = true --set break where empty line occurred
						else phase_breaks[#lines] = true end --set break on this line

						first_line_break = nil --reset for stretch up to next @
						look_for_next_break = true
					end
				elseif entry.is_check then look_for_next_break = true end --only look for @ now
			end

			local visible_lines = {items={}} --(table, combo) list of lines to be visible in quest desc box, plus additional settings
				--items (table, array) - entries at indices 1 thru 9 for the first instance of corresponding $i1 thru $i9 among visible lines, nil if not present
					--(table, key/value) - contains the line number it is present on and preceding text to be able to calculate horz position of where it occurs
						--line (number, positive integer) - line number where the "%i"..n instance occurs counting visible lines only. First visible line is 1, etc.
						--text (string) - all the text on the line (special characters stripped out) before the "%i"..n instance, needed to calc horz position, may be empty string
				--filler (number, positive integer or nil) line to insert filler lines
				--(table, key/value) - indices contain table of properties for each visible line
					--line (string) - raw text of the current line (includes beginning special characters but comments removed)
					--text (string) - text of the current line with all special characters and comments removed
					--rank (number, non-negative integer) - each line is assigned a rank between 0 and the number of phases, increments at each phase break
					--is_visible (boolean) - true if the line should be visible, determined by the line's beginning special characters and the current phase
					--is_check (boolean) - true if line begins with "@" (has checkmark), leading whitespace ignored, else false
					--check_index (number, positive integer or nil) - which dynamic checkmark index the line is associated with (e.g. $@5 is index of 5, as is $5), otherwise nil
						--the first "$@"..n instance is used if it exists, otherwise the first "$"..n instance, otherwise nil
					--check_position (number, positive integer or nil) - text preceding first "$@"..n instance if it exists, otherwise of first "$"..n instance, otherwise nil
					--check_state (string or nil) - determines the sprite to use for the dynamic checkmark on this line. Possible values are "bullet" (incomplete objective) or "done" (checkmark). if nil then dynamic checkmark is hidden
					--is_persistent (boolean) - true if line begins with "#" (always visible), leading whitespace ignored, else false
					--is_grey (boolean) - true if the text on this line should be greyed out because its associated phase is completed
					--do_not_grey (boolean) - true if the text on this line does not grey out until the quest is complete (line begins with "##" or "#%" ignoring leading whitespace)
					--is_comment (true or nil) - true if the line contains a comment with nothing else besides whitespace, in which case the line will not be shown at all, otherwise nil
					--item_marker (number, non-negative integer or string ("=" or "~" or "&") or nil) - The value following the % character at the beginning of a line, otherwise nil
					--is_hard_break (boolean) - true if all text on this line and below should be ignored

			--second pass: determine visibility of each line based on its rank and the current phase
			local rank = 0
			for i,entry in ipairs(lines) do
				--determine rank of current line
				if phase_breaks[i] then rank = rank + 1 end
				entry.rank = rank

				--determine visibility
				local special_chars = entry.line:match("^["..IGNORE_CHARSET.."]*(["..SPECIAL_VISIBLE.."]*)")
				if special_chars then special_chars:sub(1,3) end --only care about the first (up to) 3 special chars
				local visibility = SPECIAL_CHAR_VISIBILITY[special_chars] or SPECIAL_CHAR_VISIBILITY.default --lookup function to use
				local is_visible = visibility(rank, phase)

				--additional visibility checks for item marker, may hide line
				local item_marker = entry.item_marker --convenience
				if item_marker and is_visible then --additional checks if line contained %0-%9,%= or %~
					if type(item_marker)=="number" then
						if not active_items[item_marker] then is_visible = false end --note %0 has no effect
					elseif item_marker=="=" then
						if not active_item_index then is_visible = false end
					elseif item_marker=="~" then
						if active_item_index then is_visible = false end
					elseif item_marker=="&" then
						if not is_all_items then is_visible = false end
					end
				end
				entry.is_visible = is_visible

				if entry.is_filler and is_visible and not visible_lines.filler then --look for first visible filler line
					visible_lines.filler = #visible_lines + 1
				end

				if entry.is_hard_break then
					local break_phase = phase + (phase_breaks[i] and 1 or 0) --if also a phase break then need to add 1 since it makes this line part of the next rank
					if break_phase == rank then
						break --remaining lines are not visible
					elseif entry.is_persistent and break_phase < rank then
						break --remaining lines are not visible
					end
				end

				if is_visible and not entry.is_comment then --don't bother with the rest if not visible
					if entry.split1_char then
						--hide stuff between hide_min and hide_max indices,
						--or everything after hide_min if hide_max is not defined
						local hide_min
						local hide_max

						local is_split1_visible = SPECIAL_CHAR_VISIBILITY[entry.split1_char](rank, phase)
						if entry.split2_char then
							local is_split2_visible = SPECIAL_CHAR_VISIBILITY[entry.split2_char](rank, phase)
							if not is_split1_visible and not is_split2_visible then
								hide_min = entry.split1_index
								entry.text = entry.text:sub(1, hide_min) --truncate line text
							elseif not is_split1_visible then
								hide_min = entry.split1_index
								hide_max = entry.split2_index
								local text0 = entry.text:sub(1, hide_min)
								local text2 = entry.text:sub(hide_max+1)
								entry.text = text0..text2
							elseif not is_split2_visible then
								hide_min = entry.split2_index
								entry.text = entry.text:sub(1, hide_min) --truncate line text
							end --if both split1 and split2 visible then don't need to do anything special
						elseif not is_split1_visible then --otherwise don't need to do anything special
							hide_min = entry.split1_index
							entry.text = entry.text:sub(1, hide_min) --truncate line text
						end

						--hide other dynamic elements on this line if within the hidden region of text
						if hide_min then
							--hide quest item icons, if applicable
							local line_items = item_positions[i] or {}
							for index,pre_text in pairs(line_items) do
								local len = pre_text:len()
								if len>hide_min and (not hide_max or len<=hide_max) then
									line_items[index] = nil
								end
							end

							--hide misc item icon, if applicable
							local misc_item_index = line_items['11']
							if misc_item_index and misc_item_index > hide_min
							and (not hide_max or misc_item_index<=hide_max) then
								line_items['11'] = nil
							end

							--hide dynamic checkmark, if applicable
							local check_index = entry.check_position
							if check_index and check_index > hide_min
							and (not hide_max or check_index<=hide_max) then
								entry.check_position = nil
								entry.check_index = nil
							end
						end
					end

					local primary_is_grey = not entry.do_not_grey and (phase>rank) --persistent lines never grey
					local dynamic_is_grey = subs_check[entry.check_index] or false

					if phase<num_phases then --quest not done
						if entry.check_index then
							entry.is_grey = primary_is_grey or dynamic_is_grey
						else entry.is_grey = primary_is_grey end
					else entry.is_grey = true end --always grey out text if quest is done

					if entry.check_position then
						if dynamic_is_grey then
							entry.check_state = "done"
						elseif dynamic_is_grey==false then
							entry.check_state = "bullet"
						end --else entry.check_state is implicitly nil
					end --else entry.check_state is implicitly nil

					table.insert(visible_lines, entry)

					--save first $i1 thru $i9 instance present in visible lines
					if item_positions[i] then
						for num,text in pairs(item_positions[i]) do
							local num_index = tonumber(num)
							if not visible_lines.items[num_index] then
								visible_lines.items[num_index] = {
									line = #visible_lines, --line number is when counting visible lines only
									text = text,
								}
								if num_index==11 then --is misc_item
									visible_lines.items[num_index].item_id = item_positions.item_id
									visible_lines.items[num_index].variant = tonumber(item_positions.variant)
								end
							end
						end
					end
				else item_positions[i] = nil end --disregard the $i instance on this line since it is not visible
			end

			return visible_lines
		end

		--// Returns number (or false) representing the current phase of the objective
			--false:the player hasn't started the quest
			--0:player has the quest in their log but has not completed any subtasks
			--1+:the player has completed this many subtasks
			--the quest is considered complete when the current phase is equal to the number of phases
		function new_objective:get_current_phase() return current_phase end

		-- Returns the highest phase the player has reached on this quest since loading or starting a new save game
		function new_objective:get_reached_phase() return reached_phase end

		--// Returns the number of phases (number) for the objective
		function new_objective:get_num_phases() return num_phases end

		--// Returns boolean that is true if the player has started the quest but is not yet complete
		function new_objective:is_active()
			return current_phase and current_phase < num_phases
		end

		--// Returns boolean that is true if the quest is complete (all objectives finished)
		function new_objective:is_done() return is_done end

		--// Returns index (number, integer) corresponding to sort order
		function new_objective:get_index() return index end

		--// Returns dialog dialogs.dat id (string) for the quest dialog
		function new_objective:get_dialog_id() return dialog_id end

		--// Returns the alternate_key (string or nil) for this quest, nil if not an alternate quest
		function new_objective:get_alternate_key() return alternate_key end

		--// Returns whether this objective is the one in the quest log among its alternates
			--possible return values:
				--true - this objective is present in the quest log (may or may not be done, may or may not have any alternates)
				--false - a different alternate objective is present in the quest log
				--nil - this objective is not present in the quest log and neither are any of the alternates (if any)
		function new_objective:is_active_alt()
			local alt_list = alternates_list[alternate_key]
			if alt_list then
				if alt_list.active then
					return self == alt_list.active
				else return nil end --there isn't an alternate in the quest log
			else return current_phase and true or nil end --has no alternate, return true if present in quest log, otherwise nil
		end

		--// Removes objective from quest log, internal use only
		function new_objective:deactivate()
			assert(alternate_key and not alternates_list[alternate_key].active, "Error in 'deactivate', unable to deactivate objective")
			current_phase = nil
		end

		return new_objective
	end


	--## Objectives Manager Functions ##--

	--// Refreshes only objectives influenced by the specified save game value
		--savegame_value (string, optional): name of save game value that has changed value
			--if "$MAP" then only refreshes objectives needing a refresh after a map change
			--if nil then refreshes all objectives
		--no return value
	function objectives:refresh(savegame_value)
		local status = 0 --tentative
		local status_dialog_id --dialog_id corresponding to status

		if savegame_value=="$MAP" then
			for _,objective in ipairs(map_val_list) do
				--only refresh objectives already in quest log that are not done yet
				if objective:get_current_phase() and not objective:is_done() then
					local new_status = STATUS_LIST[objective:refresh()] or 0
					if new_status > status then
						status = new_status
						status_dialog_id = objective:get_dialog_id()
					end
				end
			end
		elseif savegame_value then
			assert(type(savegame_value)=="string", "Bad argument #2 to 'refresh' (string expected)")
			local value = game:get_value(savegame_value, value)

			local to_refresh = save_val_list[savegame_value] or {}
			for _,objective in ipairs(to_refresh) do
				local new_status = STATUS_LIST[objective:refresh()] or 0
				if new_status > status then
					status = new_status
					status_dialog_id = objective:get_dialog_id()
				end
			end
		else --else have to refresh ALL objectives
			for _,sub_list in pairs(objectives_list) do
				for _,objective in ipairs(sub_list) do
					local new_status = STATUS_LIST[objective:refresh()] or 0
					if new_status > status then
						status = new_status
						status_dialog_id = objective:get_dialog_id()
					end
				end
			end
		end

		if status > 0 then --at least one objective advanced the phase
			is_new_task = true

			refresh_npcs() --update list of active npcs
			local status_name = STATUS_LIST[status]

			--change status if ALL quests are now complete
			local is_all_done --set to true if all main AND side quests are now done
			if status_name=="main_completed" then
				local completed_count,total_count = self:get_counts"main"
				if completed_count>=total_count then
					status_name = "main_all_completed"

					--do additional check to see if now ALL quests are done
					completed_count,total_count = self:get_counts"side"
					if completed_count>=total_count then is_all_done = true end
				end
			elseif status_name=="side_completed" then
				local completed_count,total_count = self:get_counts"side"
				if completed_count>=total_count then
					status_name = "side_all_completed"

					--do additional check to see if not ALL quests are done
					completed_count,total_count = self:get_counts"main"
					if completed_count>=total_count then is_all_done = true end
				end
			end

			if self.on_quest_updated then self:on_quest_updated(status_name, status_dialog_id) end --call event if it exists
			if is_all_done and self.on_all_quests_done then self:on_all_quests_done() end --call event if it exists
		end
	end

	--// Custom iterator to get entity names of active npcs (does not expose internal table)
		--usage: for npc_name in objectives:active_npcs() do
	function objectives:active_npcs()
		return function(_, key) return next(active_npcs,key) end, {}
	end
	--// Returns true if the NPC with the specified entity name is active
	function objectives:is_npc_active(name) return active_npcs[name] or false end

	--// Returns indexed table of active objectives followed by completed objectives.
	--// The order of the returned list matches the order defined in objectives.dat
		--objective_type (string) keyword corresponding to the objective list to use ("main" or "side")
	function objectives:get_objectives_list(objective_type)
		assert(type(objective_type)=="string", "Bad argument #2 to 'get_objectives_list' (string expected)")
		local full_list = objectives_list[objective_type] --convenience
		assert(full_list, "Bad argument #2 to 'get_objectives_list', invalid type: "..objective_type)

		local sorted_list = {} --list to be returned

		--add completed & updated objectives to sorted_list
		for _,objective in ipairs(full_list) do
			if objective:is_done() and objective:get_status() then
				table.insert(sorted_list, objective)
				sorted_list[tostring(objective:get_index())] = #sorted_list --reverse lookup
			end
		end

		--add active & updated objectives to sorted_list
		for _,objective in ipairs(full_list) do
			if objective:is_active() and objective:get_status() then
				table.insert(sorted_list, objective)
				sorted_list[tostring(objective:get_index())] = #sorted_list --reverse lookup
			end
		end

		--add active & non-updated objectives to sorted_list
		for _,objective in ipairs(full_list) do
			if objective:is_active() and not objective:get_status() then
				table.insert(sorted_list, objective)
				sorted_list[tostring(objective:get_index())] = #sorted_list --reverse lookup
			end
		end

		--add completed & non-updated objectives to sorted_list
		for _,objective in ipairs(full_list) do
			if objective:is_done() and not objective:get_status() then
				table.insert(sorted_list, objective)
				sorted_list[tostring(objective:get_index())] = #sorted_list --reverse lookup
			end
		end

		return sorted_list
	end

	--// Returns an objective object matching the specified dialogs.dat id string
		--id (string) - dialogs.dat id to identify the objective to be returned
		--returns (table) - objective object matching the specified id
	function objectives:get_objective(id)
		assert(type(id)=="string", "Bad argument #2 to 'get_objective' (string expected)")
		local objective = ids[id]
		assert(objective, "Bad argument #2 to 'get_objective', no objective found with id: "..id)

		return objective
	end

	--// Returns the objective object with the specified index for the specified objective type ("main" or "side")
		--index (number, positive integer) - index of the objective to be returned (corresponds to order defined in objectives.dat)
		--obj_type (string) - value can be "main" or "side", indicating which list the objective in question belongs to
		--returns (table or nil) - objective object matching the specified index and objective type, nil if does not exist
	function objectives:get_objective_by_index(index, obj_type)
		local index = tonumber(index)
		assert(index, "Bad argument #2 to 'get_objective_by_index' (number expected)")

		assert(type(obj_type)=="string", "Bad argument #3 to 'get_objective_by_index' (string expected)")
		local full_list = objectives_list[obj_type]
		assert(full_list, "Bad argument #3 to 'get_objective_by_index', obj_type string must be 'main' or 'side'")

		return full_list[index] --may be nil
	end

	--// objective_type (string): keyword for which objective list to use ("main" or "side")
		--returns (number, non-negative integer) - number of completed quests
		--returns (number, non-negative integer) - total quests from the list corresponding to objective_type
	function objectives:get_counts(objective_type)
		assert(type(objective_type)=="string", "Bad argument #2 to 'get_counts' (string expected)")
		local full_list = objectives_list[objective_type] --convenience
		assert(full_list, "Bad argument #2 to 'get_counts', invalid type: "..objective_type)

		return full_list.completed_count, #full_list - full_list.alternates_count
	end

	--// Returns the objective object that is active in the alternate group specified by alternate_key
		--alternate_key (string) - unique identifier string of the group of alternate quests
		--returns (table or nil) - the active objective object belonging to the specified alternate key, or nil if none are active
	function objectives:get_active_alternate(alternate_key)
		assert(type(alternate_key)=="string", "Bad argument #2 to 'get_active_alternate' (string expected)")
		local alt_info = alternates_list[alternate_key]
		assert(alt_info, "Bad argument #2 to 'get_active_alternate', invalid alternate key: "..alternate_key)

		return alt_info.active --may be nil
	end

	--// Call this function to switch the active quest
		--alt_key (string) - unique identifier string of the group of alternate quests
		--quest_id (string or number) - specify which quest to make active by giving the dialog id or an index
			--(string) - The dialog id of the alternate quest to make active
			--(number, positive integer) - index of the quest to make active, corresponds to order defined in objectives.dat
	function objectives:set_alternate(alt_key, quest_id)
		assert(type(alt_key)=="string", "Bad argument #2 to 'set_alternate' (string expected)")
		local alt_info = alternates_list[alt_key] --convenience
		local alt_type = alt_info and alt_info.objective_type
		assert(alt_type, "Bad argument #2 to 'set_alternate', alternate quest key not found: "..alt_key)

		local new_alt --objective (table) to set as the active alternate quest
		local quest_index = tonumber(quest_id)
		if quest_index then
			local list = objectives_list[alt_type]
			new_alt = list[quest_index]
			assert(new_alt, "Bad argument #3 to 'set_alternate', quest index not found: "..quest_index)
			assert(new_alt:get_alternate_key()==alt_key, "Bad argument #3 to 'set_alternate', quest index "..quest_index.." does not belong to alternate key: "..alt_key)
		else
			assert(type(quest_id)=="string", "Bad argument #3 to 'set_alternate' (string or number expected)")
			new_alt = ids[quest_id]
			assert(new_alt, "Bad argument #3 to 'set_alternate', invalid quest id: "..quest_id)
		end
		local alt_id = new_alt:get_dialog_id() --dialog id (string) associated with the newly set alternate quest

		--check if a different alternate quest is currently active
		local old_alt = alt_info.active
		if not old_alt or not old_alt:is_done() then --there is not an active alternate, or if there is it is not done
			--deactivate current alternate if there is one
			if old_alt then
				alt_info.active = nil
				old_alt:deactivate() --removes from quest log menu
			end

			game:set_value(alt_key, alt_id)
			new_alt:refresh() --updates new alternate quest, will only be added to quest log menu if phase calculation is non-nil

			--if fails to add new quest then need to refresh all other alternate quests to see if they activate
			if not alt_info.active then --new_alt did not start
				for _,next_alt in ipairs(alt_info) do
					if next_alt ~= new_alt then --don't refresh new_alt a second time
						next_alt:refresh()
						if alt_info.active then break end --quest activated, don't need to refresh any more
					end
				end
			end

			if old_alt ~= alt_info.active then --the active alternate changed
				refresh_npcs() --update list of active npcs
				local status_dialog_id = alt_info.active and alt_info.active:get_dialog_id() --dialog id of newly active alternate if there is one
				if self.on_quest_updated then self:on_quest_updated("alternate_swap", status_dialog_id) end --call event if it exists
			end
		end
	end

	--// Returns true if there have been any updates to the quest log menu since the last time the player opened it, else false
	function objectives:is_new_task() return is_new_task end

	--// Resets the status of game.objectives:is_new_task() to false. Called automatically whenever the quest log menu is opened
	function objectives:clear_new_tasks()
		is_new_task = false
		if self.on_tasks_cleared then self:on_tasks_cleared() end --call event if it exists
	end

	--// Manually force quest alerts to be triggered by calling objectives:on_quest_updated() event
		--it does not cause a refresh nor updates quest description text
	function objectives:force_update()
		if self.on_quest_updated then self:on_quest_updated"forced_update" end --call event if it exists
	end

	--// Hook API game:set_value function to be notified whenever savegame variables are updated
	--refresh objectives whenever a save game value is set
	local game_set_value_old = game.set_value
	function game.set_value(self, savegame_value, value, ...)
		--intermediate function so that game:set_value() is called first, followed by refresh while still capturing all return values
		local function do_refresh(savegame_value, ...)
			objectives:refresh(savegame_value)
			return ...
		end

		return do_refresh(savegame_value, game_set_value_old(self, savegame_value, value, ...))
	end

	objectives:load_data() --load objectives from objectives.dat
	initial_refresh() --refresh all objectives
	refresh_npcs() --update list of active npcs

	game.objectives = objectives --so any script that can access game can access the objectives
end

return objectives_manager

--[[ Copyright 2018-2019 Llamazing
  []
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  []
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  []
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
