--[[ quest_log.lua
	version 1.0.1
	25 Aug 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This menu script displays a list of objectives (i.e. quests) that are currently active
	or have previously been completed by the player. The player can traverse the list with
	the up/down keys, and the currently selected objective displays a detailed description
	of subtasks to be completed by the player along with the current status (incomplete or
	complete) and gets updated dynamically as each subtask is finished.
	
	There are two completely different lists of quests that are displayed: main quests and
	side quests. Functionally they behave the same and get displayed on separate tabs that
	the player can switch between using the left/right keys.
	
	The "scripts/menus/quest_log.data" data file is used by default to configure the sizes
	and positions of menu elements. If a data file exists in the languages directory, then
	it will be used instead (e.g. "languages/en/quest_log.dat"). This allows for adjusting
	the menu as needed on a per-language basis to accomodate alternate fonts and sizing.
--]]

local multi_events = require"scripts/multi_events"
local ui = require"scripts/menus/ui/ui"
local util = require"scripts/menus/ui/util"
local default_quest_data = require"scripts/menus/quest_log.dat"
local quest_data = default_quest_data --tentative

local quest_log = {x=0, y=0}
multi_events:enable(quest_log)

--tab names and their corresponding index
local LIST_TYPES = {
	"main",
	"side",
} for i,v in ipairs(LIST_TYPES) do LIST_TYPES[v]=i end --add reverse lookup

--additional setter functions to call when creating a new ui component (if a given function exists), order not guaranteed
	--key: property name of the ui component being created
	--value: function to call as method using property value as an argument, i.e. ui_component[value](ui_component, value_of_property(key))
local COMPONENT_FUNCS = {
	is_top_edge = "set_is_top_edge",
	fill = "set_fills",
	subcomponent = "set_subcomponents",
	gap = "set_gap",
	text = "set_text",
	text_key = "set_text_key",
	opacity = "set_opacity",
}

local LIST_VISIBLE_MAX_COUNT --(number, positive integer) - how many quests can be viewed in sidebar at one time

local active_list = {} --(table, array) list of objectives to be displayed in quest log in the displayed order (active first followed by completed)
local active_tab_index = 1 --(number, positive integer) index of active tab: 1="main", 2="side"
local sel_index = 1 --(number, positive integer) position of highlight box, 1 to LIST_VISIBLE_MAX_COUNT
local list_index = 1 --(number, positive integer) selected index of current list
local top_index = 1 --(number, positive integer) list index appearing at top of visibile objectives in sidebar
local is_highlight = true --(boolean) if true then highlight box is visible (hidden when no quests in log)
local is_debug_mode = false --(boolean) if true then debug functions are enabled

--// Parses quest_log.dat and creates the corresponding ui components
local load_quest_data --(function) only runs once, does nothing if called a second time
do
	local loaded_language = false --don't reload data if needed data matches loaded data - lang id string or true for default data
	load_quest_data = function()
		local current_language = sol.language.get_language()
		if current_language then
			local lang_data_path = "languages/"..current_language.."/quest_log.dat"
			if sol.file.exists(lang_data_path) then
				if loaded_language ~= current_language then
					--attempt to load language-specific quest log menu data
					local lang_quest_data = sol.main.load_file(lang_data_path) --use load_file instead of require to clear data from memory when language changed
					lang_quest_data = lang_quest_data and lang_quest_data()
					if type(lang_quest_data)=="table" then
						quest_data = lang_quest_data
					else  --failed, use default data
						quest_data = default_quest_data
						current_language = true
					end
				end --otherwise language-specific data already loaded so do nothing
			else --language-specific data not found, use default data
				quest_data = default_quest_data
				current_language = true
			end
		else --language not set, use default data
			quest_data = default_quest_data
			current_language = true
		end
		
		if current_language ~= loaded_language then --only load menu data if first time or if language changed
			assert(type(quest_data)=="table", "Bad data in 'quest_log.dat' (table expected)")
			
			--load menu subcomponents
			for i,entry in ipairs(quest_data) do
				assert(type(entry.layer)=="string", "Bad property ["..i.."].layer to 'quest_log.dat' (string expected)")
				local component = ui.create_preset(entry.layer, entry.width, entry.height)
		
				--handle special keys in quest_log.dat
				for key,func_name in pairs(COMPONENT_FUNCS) do
					if entry[key]~=nil and type(component[func_name])=="function" then
						component[func_name](component, entry[key])
					end
				end
				
				local subcomponents = {}
				for _,subentry in ipairs(entry) do
					if type(subentry.layer)=="string" then
						local sub = ui.create_preset(subentry.layer, subentry.width, subentry.height)
						if sub then table.insert(subcomponents, {sub, subentry.x, subentry.y}) end
					end
				end
				if #subcomponents > 0 and component.set_subcomponents then
					component:set_subcomponents(subcomponents)
				end
		
				--save reference to components in quest_data using value of entry_id as key
				local entry_id = entry.id --convenience
				if entry_id then
					assert(type(entry_id)=="string", "Bad property ["..i.."].id to 'quest_log.dat' (string or nil expected)")
					assert(not quest_log[entry_id], "Bad property ["..i.."].id to 'quest_log.dat', duplicate entry: "..entry_id)
					assert(entry_id:match"^[%w_]+$", "Bad property ["..i.."].id to 'quest_log.dat', only alpha-numeric characters and underscore allowed")
			
					quest_log[entry_id] = component
					if not quest_data[entry_id] then quest_data[entry_id] = entry end --add reverse lookup to quest_data
				end
		
				table.insert(quest_log, {component, entry.x, entry.y})
			end
			
			quest_log.menu = ui.new_group(quest_log) --create a new group containing all the menu components
			quest_log.inactive_tab:set_xy(56,0) --move the inactive tab over to become the second tab
	
			quest_log.side_tab_text:set_all("set_enabled", false) --grey text of side tab because it is the inactive tab
			if quest_log.tabs_left_arrow then
				quest_log.tabs_left_arrow:set_visible(false) --hide left arrow because main tab is active
			end
			
			if quest_log.desc_items then
				quest_log.desc_items:set_all("set_visible", false) --hide until needed (only if defined in quest_log.dat)
			end
			
			--// populate subcomponents of each list entry group
			
			local group_data = quest_data.list_entry
			assert(type(group_data)=="table", "Bad property list_entry to 'quest_log.dat' (table expected)")
			
			for _,group in quest_log.list_entries:ipairs() do
				local group_list = {} --list of components to be added to this group
				for i,entry in ipairs(group_data) do
					local subcomponent = ui.create_preset(entry.layer, entry.width, entry.height)
					
					--handle special keys in quest_log.dat
					for key,func_name in pairs(COMPONENT_FUNCS) do
						if entry[key]~=nil and type(subcomponent[func_name])=="function" then
							subcomponent[func_name](subcomponent, entry[key])
						end
					end
					
					--setup accessing subcomponent using sub_id key
					local sub_id = entry.sub_id
					assert(type(sub_id)=="string", "Bad property list_entry["..i.."].sub_id to 'quest_log.dat' (string expected)")
					assert(not rawget(group,sub_id), "Bad property list_entry["..i.."].sub_id to 'quest_log.dat' (must be unique)")
					group[sub_id] = subcomponent
					
					table.insert(group_list, {subcomponent, entry.x, entry.y})
				end
				
				group:set_subcomponents(group_list)
			end
			
			local item_entry = quest_data.desc_item
			assert(type(item_entry)=="table", "Bad property list_entry to 'quest_log.dat' (table expected)")
			
			for _,group in quest_log.desc_items:ipairs() do
				local group_list = {} --list of components to be added to this group
				for i,entry in ipairs(item_entry) do
					local subcomponent = ui.create_preset(entry.layer, entry.width, entry.height)
					
					--handle special keys in quest_log.dat
					for key,func_name in pairs(COMPONENT_FUNCS) do
						if entry[key]~=nil and type(subcomponent[func_name])=="function" then
							subcomponent[func_name](subcomponent, entry[key])
						end
					end
					
					--setup accessing subcomponent using sub_id key
					local sub_id = entry.sub_id
					assert(type(sub_id)=="string", "Bad property list_entry["..i.."].sub_id to 'quest_log.dat' (string expected)")
					assert(not rawget(group,sub_id), "Bad property list_entry["..i.."].sub_id to 'quest_log.dat' (must be unique)")
					group[sub_id] = subcomponent
					
					table.insert(group_list, {subcomponent, entry.x, entry.y})
				end
				
				group:set_subcomponents(group_list)
			end
			
			if quest_log.back_prompt then
				local prompt_text = sol.language.get_string"menu.quest_log.back_prompt" or ""
				quest_log.back_prompt:set_text(prompt_text)
			end
			
			--// verify remaining data is valid
			
			local tab_offset_x = tonumber(quest_data.tab_offset_x or 0)
			assert(type(tab_offset_x)=="number", "Bad property tab_offset_x to 'quest_log.dat' (number or nil expected)")
			quest_data.tab_offset_x = math.floor(tab_offset_x)
			
			local tab_offset_y = tonumber(quest_data.tab_offset_y or 0)
			assert(type(tab_offset_y)=="number", "Bad property tab_offset_y to 'quest_log.dat' (number or nil expected)")
			quest_data.tab_offset_y = math.floor(tab_offset_y)
			
			if quest_data.highlight_scroll_time then
				local highlight_scroll_time = tonumber(quest_data.highlight_scroll_time)
				assert(type(highlight_scroll_time)=="number", "Bad property highlight_scroll_time to 'quest_log.dat' (number or nil expected)")
				assert(highlight_scroll_time>0 and highlight_scroll_time<1, "Bad property highlight_scroll_time to 'quest_log.dat' (number between 0 & 1 or nil expected)")
				quest_data.highlight_scroll_time = highlight_scroll_time
			end
		
			LIST_VISIBLE_MAX_COUNT = quest_log.list_entries:get_count()
			
			--call this event (if defined) when initialization is done so other scripts can customize quest log
			if quest_log.on_initialized then quest_log:on_initialized() end
		
			loaded_language = current_language --keep track of the loaded language (true if default data instead)
		end
	end
end

--// Restores position of list from last time viewing menu; will call quest_log:set_selected()
	--tab (number, non-negative integer, optional) - 1 for main tab, 2 for side tab, default: active tab when menu was last closed
function quest_log:recall_saved_position(tab)
	local game = sol.main.get_game()
	local tab_index,tab_name
	
	if tab then --use the tab specified
		local tab_num = tonumber(tab)
		if tab_num then
			tab = LIST_TYPES[tab_num]
			assert(tab, "Bad argument #2 to 'recall_saved_position' (number, string or nil expected)")
		else
			assert(type(tab)=="string", "Bad argument #2 to 'recall_saved_position' (number, string or nil expected)")
		end
		
		tab_name = tab:lower()
		tab_index = LIST_TYPES[tab_name]
		assert(tab_index, "Bad argument #2 to 'recall_saved_position', invalid tab name: "..tab)
	else --use the most recent tab, the value of which is retrieved from savegame data
		tab_name = game:get_value"last_quest_log_tab" or "main"
		assert(type(tab_name), "Bad savegame data: 'last_quest_log_tab' (string expected)") --shouldn't be necessary
		tab_name = string.lower(tab_name)
	
		tab_index = LIST_TYPES[tab_name]
		assert(tab_index, "Bad savegame data: 'last_quest_log_tab' invalid tab name: "..tab_name.." ('main' or 'side' expected)")
		
		self:set_tab(tab_index) --change to specified tab
		return --self:set_tab() will call self:recall_saved_position() again
	end
	
	local last_master_index = tonumber(game:get_value("last_quest_log_"..tab_name)) --may be nil
	
	--determine value for last_list_index
	local last_list_index = 1 --tentative, use first entry if can't find better one
	if last_master_index then --try to use savegame value
		last_list_index = active_list[tostring(last_master_index)] --objective that was last selected, may be nil if objective is no longer in active list
		
		--if last selected was an alternate quest that is no longer in the quest log, see if one of the alternate variants is active and select that one instead
		if not last_list_index then --last viewed objective is no longer in player's quest log
			local last_objective = game.objectives:get_objective_by_index(last_master_index, tab_name)
			if last_objective then
				local alt_key = last_objective:get_alternate_key()
				if alt_key then
					local active_alt = game.objectives:get_active_alternate(alt_key)
					if active_alt then
						local new_master_index = active_alt:get_index()
						last_list_index = active_list[tostring(new_master_index)] --switch selected to new alternate quest
					end
				end
			end
		end
		
		if not last_list_index then --last viewed objective is no longer in player's quest log
			--choose next lower objective that is on active list instead, or use first entry
			for i,objective in ipairs(active_list) do
				if objective:get_index() < last_master_index then
					last_list_index = i
				else break end
			end
		end
	end
	
	if #active_list > 0 then --player has started at least 1 quest
		local sel_index = 1 --tentative, sets position of highlight box
		local top_index = last_list_index --tentative, index of objective at top of visible list (depends on scroll position)
		
		if #active_list <= LIST_VISIBLE_MAX_COUNT then --not enough entries for list to scroll
			sel_index = last_list_index
			top_index = 1
		elseif last_list_index > #active_list - LIST_VISIBLE_MAX_COUNT + 1 then --if true then highlighted position won't be at top of visible list because is too near bottom of list
			sel_index = LIST_VISIBLE_MAX_COUNT - (#active_list - last_list_index) --highlight position when scrolled all the way to bottom
			top_index = #active_list - LIST_VISIBLE_MAX_COUNT + 1 --index of objective at top of list when scrolled all the way to bottom
		end
		
		self:set_selected(last_list_index, top_index, sel_index)
	else self:set_selected(false) end --display special list when player has no quests in log
end

--// Save currently viewed list entry as savegame variable to recall next time menu is opened
function quest_log:save_position()
	local game = sol.main.get_game()
	
	local active_tab_name = LIST_TYPES[active_tab_index]
	local current_objective = active_list[list_index] --may be nil
	local master_index = current_objective and current_objective:get_index() --may be nil
	
	game:set_value("last_quest_log_tab", active_tab_name)
	game:set_value("last_quest_log_"..active_tab_name, master_index) --unsets value if nil (i.e. list is empty)
end

--// Sets which tab is visible in the sidebar
	--index (number, positive integer) - tab index to make active: 1 = main quests, 2 = side quests
function quest_log:set_tab(index)
	local index = tonumber(index)
	assert(type(index)=="number", "Bad argument #2 to 'set_tab' (number expected)")
	index = math.floor(index)
	assert(index>0, "Bad argument #2 to 'set_tab' (number must be positive)")
	assert(index<=#LIST_TYPES, "Bad argument #2 to 'set_tab' (maximum value: "..#LIST_TYPES)
	
	local game = sol.main.get_game()

	--configuration of components depends on the index value
	local components = {
		{ --if index == 1
			left_tab = self.active_tab,
			right_tab = self.inactive_tab,
			visible_arrow = self.tabs_right_arrow,
			invisible_arrow = self.tabs_left_arrow,
			enabled_text = self.main_tab_text,
			disabled_text = self.side_tab_text,
		},
		{ --if index == 2
			left_tab = self.inactive_tab,
			right_tab = self.active_tab,
			visible_arrow = self.tabs_left_arrow,
			invisible_arrow = self.tabs_right_arrow,
			enabled_text = self.side_tab_text,
			disabled_text = self.main_tab_text,
		},
	}
	
	local c = components[index] --convenience
	c.left_tab:set_xy(0,0)
	c.right_tab:set_xy(quest_data.tab_offset_x, quest_data.tab_offset_y)
	if c.visible_arrow then c.visible_arrow:set_visible(true) end
	if c.invisible_arrow then c.invisible_arrow:set_visible(false) end
	c.enabled_text:set_all("set_enabled", true)
	c.disabled_text:set_all("set_enabled", false)
	
	self:save_position() --save old tab position
	
	active_tab_index = index --change tabs
	
	local new_tab_name = LIST_TYPES[active_tab_index]
	active_list = game.objectives:get_objectives_list(new_tab_name) --update list of currently active objectives
	
	self:recall_saved_position(new_tab_name) --restores position of list for new tab from last time viewing it, uses specified tab instead of reading last tab from savegame variable
	
	--set quest completion rate text below sidebar
	if self.complete_status then
		local complete_status_text = sol.language.get_string"menu.quest_log.quests_count"
		assert(complete_status_text, "Error: strings.dat entry 'menu.quest_log.quests_count' not found")
		
		local v1,v2 = game.objectives:get_counts(new_tab_name)
		
		local milestone = quest_data.quest_totals_milestone --savegame variable to use to determine if milestone is reached
		if milestone and not game:get_value(milestone) then --hide total quest count if milestone defined and not yet reached
			local no_total_status_text = sol.language.get_string"menu.quest_log.quests_count_no_total"
			if no_total_status_text then --use alternate strings.dat entry if it is defined (excludes total count)
				complete_status_text = no_total_status_text --use alternate text instead
				v2 = nil --don't make $v2 substitution for total quest count
			else v2 = "?" end --alternate strings.dat entry is not defined, replace quest total with "?" instead (until milestone reached)
		end
		
		--substitute for $v1 (quests completed) & $v2 (total quest count)
		complete_status_text = util.substitute_text(
			complete_status_text,
			{v1,v2},
			"%$v"
		)
		self.complete_status:set_text(complete_status_text)
	end
end

--// Changes the selected quest in the menu sidebar
	--new_list_index (number, positive integer) - index of the quest to select, where the first sidebar entry is 1 and the last is equal to #active_list
	--new_top_index (number, positive integer, optional) - index of the quest to be the top visible entry in the sidebar (i.e. the scroll position), default: 1
	--new_sel_index (number, positive integer, optional) - index of the highlight box, 1 to LIST_VISIBLE_MAX_COUNT, default 1
function quest_log:set_selected(new_list_index, new_top_index, new_sel_index)
	if not new_list_index then
		self:set_description(false)
		self:set_top_position(false)
		self:set_highlight_position(false)
		return
	end
	
	local new_list_index = tonumber(new_list_index)
	assert(new_list_index, "Bad argument #2 to 'set_selected' (number or nil expected)")
	local new_top_index = tonumber(new_top_index or 1)
	assert(new_top_index, "Bad argument #3 to 'set_selected' (number or nil expected)")
	local new_sel_index = tonumber(new_sel_index or 1)
	assert(new_sel_index, "Bad argument #4 to 'set_selected' (number or nil expected)")
	
	list_index = new_list_index
	self:set_top_position(new_top_index)
	self:set_highlight_position(new_sel_index, false)
	
	self:set_description(list_index) --update description pane
end

--// Moves the selected sidebar list item up or down by the specified amount
--moving below the bottom of the list moves to the first entry
--moving above the top of the list moves to the last entry
	--amount (number, integer) - number of entries to move (positive is down, negative is up)
function quest_log:move_selection(amount)
	if not is_highlight then return end --don't do anything if highlight box not visible
	
	amount = tonumber(amount)
	assert(amount, "Bad argument #2 to 'move_selection' (number expected)")
	amount = math.floor(amount)
	
	sol.audio.play_sound"cursor_page"

	local new_index = list_index + amount
	local new_top_index
	
	if amount > 0 then --move down
		if list_index < #active_list then
			list_index = new_index
			
			local bottom_index = top_index + LIST_VISIBLE_MAX_COUNT - 1
			if list_index > bottom_index then --is offscreen below
				bottom_index = list_index
				if #active_list > LIST_VISIBLE_MAX_COUNT then
					new_top_index = bottom_index - LIST_VISIBLE_MAX_COUNT + 1
				end
			end
		else --move to first entry
			list_index = 1
			if #active_list > LIST_VISIBLE_MAX_COUNT then new_top_index = 1 end
		end
	elseif amount < 0 then --move up
		if list_index > 1 then
			list_index = new_index
			
			if list_index < top_index then --is offscreen above
				if #active_list > LIST_VISIBLE_MAX_COUNT then new_top_index = list_index end
			end
		else --move to last entry
			list_index = #active_list
			if #active_list > LIST_VISIBLE_MAX_COUNT then
				new_top_index = list_index - LIST_VISIBLE_MAX_COUNT + 1
			end
		end
	else return end --do nothing for amount of 0
	
	if new_top_index ~= top_index then self:set_top_position(new_top_index) end
	
	local new_sel_index = list_index - top_index + 1
	if sel_index ~= new_sel_index then self:set_highlight_position(new_sel_index) end
	
	self:set_description(list_index)
end

--// Updates description pane per the specified objective object
	--objective (table or number or nil) - specifies which objective to use
		--(table) - objective to use as basis for desc pane content
		--(number) - index of objective from active_list
		--(nil) - Display text that quest log is empty
	--phase (number, index, optional) - manually force the phase to be shown (for debugging)
function quest_log:set_description(objective, phase)
	local game = sol.main.get_game()
	
	if objective then
		if type(objective)~="table" then
			assert(type(objective)=="number", "Bad argument #2 to 'set_description' (table or number or nil expected)")
			local index = objective
			objective = active_list[index]
			assert(objective, "Bad argument #2 to 'set_description' (number out of range: "..index)
		end
		
		assert(type(objective)=="table", "Bad argument #2 to 'set_description' (table or number expected)")
		
		local phase = tonumber(phase)
		if phase then phase = math.floor(phase) end
		
		local description = objective:get_description(phase)
		local max_line = quest_data.desc_text.subcomponent.count --convenience
		
		--insert filler lines as needed
		local filler_count = 0 --assume 0 until proven otherwise
		local filler_line = description.filler
		if filler_line and max_line > #description then
			filler_count = max_line - #description
			local prev = description[filler_line - 1]
			local blank_line = {
				line = "",
				text = "",
				rank = prev and prev.rank or 0,
			}
			
			--insert blank filler lines
			for i=1,filler_count do
				table.insert(description, filler_line, blank_line)
			end
			
			--adjust line numbers of items if necessary
			for index,item_data in pairs(description.items) do
				local line = item_data.line
				if line >= filler_line then item_data.line = line + filler_count end
			end
		end
		
		if self.desc_title then self.desc_title:set_text(objective:get_title()) end
		if self.desc_location then self.desc_location:set_text(objective:get_location(phase)) end
		
		--set description pane text and font color depending on if active
		for i,subcomponent in self.desc_text:ipairs() do
			local entry = description[i] or {}
			
			subcomponent:set_text(entry.text or "")
			
			local is_grey = not not entry.is_grey
			subcomponent:set_enabled(not is_grey)
		end
		
		--set visibility/state of description pane checkmarks
		for i,subcomponent in self.desc_checkmarks:ipairs() do
			local entry = description[i] or {}
			subcomponent:set_visible(entry.is_check or false)
			subcomponent:set_animation(entry.is_grey and "done" or "bullet")
		end
		
		--set visibility/state of dynamic checkmarks in description pane
		for i,subcomponent in self.dynamic_checkmarks:ipairs() do
			local entry = description[i] or {}
			subcomponent:set_visible(not not entry.check_state)
			subcomponent:set_animation(entry.check_state or "bullet")
			
			if entry.check_position then
				--calculate x position of checkmark
				local text_component = self.desc_text:get_subcomponent(i)
				--local x = text_component:get_predicted_size(entry.check_position) --non-hack implementation
				local xtra_x = text_component:get_predicted_size(entry.check_position.."a") --HAX
				local xtra = text_component:get_predicted_size("a") --HAX
				local x = xtra_x - xtra --HAX --TODO workaround for Solarus issue #1025
				
				subcomponent:set_xy(x, 0)
			else subcomponent:set_xy(0,0) end
		end
		
		
		local items = description.items --convenience
		local line_height = quest_data.desc_text.subcomponent.height --convenience
		local gap_height = quest_data.desc_text.gap --convenience
		local line_spacing = line_height + gap_height
		
		--set visibility and position of desc_items icons
		if self.desc_items then --only draw item box if defined in quest_log.dat
			if objective:get_active_item_index() then --player has at least one quest item in inventory
				for i=0,9 do
					local sub_index = i==0 and 10 or i --$i0 uses subcomponent 10
					
					local info = items[i] --convenience
					if info and info.line <= max_line then --this line contains "$i"..i, ignore if line number is greater than the number displayed
						local item_group = self.desc_items:get_subcomponent(sub_index) --convenience
						local item_line = info.line --convenience
						local item_text = info.text --convenience
						
						local item_id,variant --may be nil
						local has_item = true --may prove to be false later
						if i>=1 then
							item_id,variant = objective:get_item_id(i)
							local current_variant = game:get_value(objective:get_item_save_val(i)) or 0
							local has_item = current_variant == variant
						else item_id,variant = objective:get_item_id() end
						
						if item_id and has_item then
							item_group:set_visible(true)
							
							--set sprite to corresponding item
							local sprite = item_group.item_sprite --convenience
							local animation = item_id --convenience
							local direction = variant - 1 --convenience
							sprite:set_animation(animation)
							sprite:set_direction(direction)
							sprite:set_xy(sprite:get_origin())
							
							--calculate horizontal position
							local text_component = self.desc_text:get_subcomponent(item_line)
							--local x = text_component:get_predicted_size(item_text) --non-hack implementation
							local xtra_x = text_component:get_predicted_size(item_text.."a") --HAX
							local xtra = text_component:get_predicted_size"a" --HAX
							local x = xtra_x - xtra --HAX --TODO workaround for Solarus issue #1025
							
							--calculate vertical position
							local group_width,group_height = item_group:get_size()
							local y = (item_line - 1)*line_spacing --top of sprite aligned to top of line
							
							item_group:set_xy(x, y)
						else item_group:set_visible(false) end --hide because player doesn't have this item
					else self.desc_items:get_subcomponent(sub_index):set_visible(false) end --don't show since it is an off-screen line
				end
			else self.desc_items:set_all("set_visible", false) end --player doesn't have any quest items, don't show any item sprites
		end
		
		--set visibility and position of misc_item icon
		if self.misc_items then --only draw misc item icon if defined in quest_log.dat
			local info = items[11] --convenience
			if info and info.line <= max_line then
				local item_group = self.misc_items --convenience
				local sprite = item_group:get_subcomponent(1) --convenience
				local item_line = info.line --convenience
				local item_text = info.text --convenience
				local item_id = info.item_id --convenience
				local variant = info.variant --convenience
				
				item_group:set_visible(true)
				
				local animation = item_id --convenience
				local direction = variant - 1 --convenience
				sprite:set_animation(animation)
				sprite:set_direction(direction)
				sprite:set_xy(sprite:get_origin())
				
				--calculate horizontal position
				local text_component = self.desc_text:get_subcomponent(item_line)
				--local x = text_component:get_predicted_size(item_text) --non-hack implementation
				local xtra_x = text_component:get_predicted_size(item_text.."a") --HAX
				local xtra = text_component:get_predicted_size"a" --HAX
				local x = xtra_x - xtra --HAX --TODO workaround for Solarus issue #1025
				
				--calculate vertical position
				local sprite_width,sprite_height = sprite:get_size()
				local y = (item_line - 1)*line_spacing - sprite_height + line_height --bottom of sprite aligned to bottom of line
				
				item_group:set_xy(x, y)
			else self.misc_items:set_visible(false) end --don't show not present or if it is an off-screen line
		end
		
		local is_done = objective:is_done()
		if phase then is_done = phase>=objective:get_num_phases() end
		if self.desc_complete then self.desc_complete:set_visible(is_done) end
		if self.desc_location then self.desc_location:set_enabled(not is_done) end
		
		objective:clear_status()
	else --display blank pane
		local TEXT_KEYS = {
			"menu.quest_log.no_main_quests", --blank display text for tab 1
			"menu.quest_log.no_side_quests", --blank display text for tab 2
		}
		
		if self.desc_title then self.desc_title:set_text"" end
		if self.desc_location then self.desc_location:set_text"" end
		self.desc_text:set_text_key(TEXT_KEYS[active_tab_index])
		self.desc_checkmarks:set_all("set_enabled", false)
		self.desc_checkmarks:set_all("set_visible", false)
		self.dynamic_checkmarks:set_all("set_enabled", false)
		self.dynamic_checkmarks:set_all("set_visible", false)
		if self.desc_complete then self.desc_complete:set_visible(false) end
		if self.desc_items then self.desc_items:set_all("set_visible", false) end
		if self.misc_items then self.misc_items:set_visible(false) end
	end
end

--// Updates quest entry at top of sidebar list to specified index of active_list
	--index (number, integer) - specifies new top position to use
function quest_log:set_top_position(index)
	local index = index or top_index --use current position if index not specified
	index = tonumber(index)
	assert(index, "Bad argument #2 to 'set_top_position' (number or nil expected)")
	index = math.min(math.max(math.floor(index), 1), #active_list)
	
	top_index = index --equal to zero if active_list is empty
	
	--set contents of sidebar list
	for i,group in self.list_entries:ipairs() do
		local objective = active_list[top_index + i - 1] --may be nil
		
		if objective then --populate contents per objective
			local is_done = objective:is_done()
			group.title:set_text(objective.get_title())
			group.title:set_enabled(not is_done)
			group.location:set_text(objective:get_location())
			group.location:set_enabled(not is_done)
			
			local status = not not objective:get_status()
			group.entry_checkmark:set_visible(is_done or status)
			if status then
				group.entry_checkmark:set_animation"new"
			else group.entry_checkmark:set_animation"done" end
		else --make blank entry
			group.title:set_text""
			group.title:set_enabled(true)
			group.location:set_text""
			group.entry_checkmark:set_visible(false)
		end
	end
	
	--set visibility of arrows based on current position
	local is_full = #active_list >= LIST_VISIBLE_MAX_COUNT
	if self.list_up_arrow then self.list_up_arrow:set_visible(is_full and top_index>1) end
	local bottom_index = top_index + LIST_VISIBLE_MAX_COUNT - 1
	if self.list_down_arrow then
		self.list_down_arrow:set_visible(is_full and bottom_index < #active_list)
	end
end

--// Sets highlight box to the specified index
	--index (number, index, optional) - index of where to set the highlight box, max value is number of visible lines in sidebar list
		--default: set highlight to position 0 and make invisible
	--is_animate (boolean, optional) - if true then highlight box will animate (slide) to specified position (default: true)
function quest_log:set_highlight_position(index, is_animate)
	local is_highlight_visible = not not index
	local index = tonumber(index or 1)
	assert(not is_highlight_visible or index, "Bad argument #2 to 'set_highlight_position' (number or nil expected)")
	index = math.min(math.min(math.max(math.floor(index), 1), LIST_VISIBLE_MAX_COUNT), #active_list) --zero if active_list is empty
	
	assert(not is_animate or type(is_animate)=="boolean", "Bad argument #3 to 'set_highlight' (boolean or nil expected)")
	local is_animate = is_animate~=false
	
	self.list_highlight:stop_movement() --in case an old movement is active
	local x,y = self.list_highlight:get_xy()
	
	local x_offset = tonumber(quest_data.list_highlight.x_offset) or 0
	local y_offset = tonumber(quest_data.list_highlight.y_offset) or 0
	
	local new_x = x_offset*(index - 1)
	local new_y = y_offset*(index - 1)
	
	if is_animate and quest_data.highlight_scroll_time then
		local delta_x = new_x - x
		local delta_y = new_y - y
		local distance = math.sqrt(delta_x*delta_x + delta_y*delta_y)
		local speed = distance/quest_data.highlight_scroll_time
		
		local movement = sol.movement.create"target"
		movement:set_speed(speed)
		movement:set_target(new_x, new_y)
		self.list_highlight:start_movement(movement)
	else self.list_highlight:set_xy(new_x, new_y) end
	
	--set visibility of highlight box
	is_highlight = is_highlight_visible
	self.list_highlight:set_visible(is_highlight_visible)
	
	sel_index = index
end

--// Gets/sets the x,y position of the menu in pixels
function quest_log:get_xy() return self.x, self.y end
function quest_log:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")
	
	self.x = math.floor(x)
	self.y = math.floor(y)
end

--// Enable/disable debug mode of the quest log menu
	--enabled (boolean, optional) - if true then debug mode is enabled, else false, default: disabled
	--Note: Debug mode allows changing the displayed phase for the currently selected quest in the quest log by using the number keys
function quest_log:set_debug_mode(enabled)
	enabled = enabled or false
	assert(type(enabled)=="boolean", "Bad argument #2 to 'set_debug_mode' (boolean or nil expected)")
	is_debug_mode = enabled
	print("Quest Log: Debug mode "..(is_debug_mode and "enabled" or "disabled")) --DEBUG
end

function quest_log:on_started()
	local game = sol.main.get_game()
	assert(game, "Error: cannot start quest log menu because no game is currently running")
	
	--generate ui components
	load_quest_data() --only loads on first call of function
	
	self:recall_saved_position() --restores position of list from last time viewing it
	
	game.objectives:clear_new_tasks() --reset when quest log menu is opened
end

function quest_log:on_finished()
	self:save_position()
end

function quest_log:on_command_pressed(command)
	if command=="up" then
		self:move_selection(-1)
		return true
	elseif command=="down" then
		self:move_selection(1)
		return true
	elseif command=="left" then
		sol.audio.play_sound"cursor_page_low"
		if active_tab_index==2 then
			self:set_tab(1)
			return true
		end
	elseif command=="right" then
		sol.audio.play_sound"cursor_page_low"
		if active_tab_index==1 then
			self:set_tab(2)
			return true
		end
	elseif command=="attack" then
		--TODO exit menu
		return true
	end
end

local PHASE_KEYS = {} for i=0,9 do PHASE_KEYS[tostring(i)]=true end --keys correspond to numeric keys
local MODIFIER_KEYS = {['left shift']=true, ['right shift']=true} --holding any of these keys down acts like a modifier
local pressed_phase_keys = {} --stores sequence of key presses while shift is held down, to be executed when shift is released

--// Called when the user presses a keyboard key while the menu is active
	--key (string) - name of the raw key that was pressed
	--modifiers (table) - table with keys corresponding to the modifiers that were held down during the key press
		--possible values: "shift", "control", "alt"
		--note: the value of the keys can be ignored
	--returns (boolean) - if true then the event won't be propagated to other objects (e.g. menus or game commands)
function quest_log:on_key_pressed(key, modifiers)
	--manually force the current phase for the displayed description text (for debugging)
	if is_debug_mode then
		if PHASE_KEYS[key] then --key pressed is 0 to 9
			if not modifiers.shift then
				local current_objective = active_list[list_index]
				self:set_description(current_objective, key) --DEBUG update the description pane to match the phase corresponding to the single pressed key
				print("DEBUG: Displaying description for phase "..key) --DEBUG
				
				pressed_phase_keys = {} --reset for next key press
				
				return true
			else table.insert(pressed_phase_keys, key) end --if shift is held down then capture sequence of key presses
		elseif MODIFIER_KEYS[key] then
			pressed_phase_keys = {} --reset sequence when modifier key is pressed down
			return true
		end
	end
end

function quest_log:on_key_released(key)
	--when shift is released, concatenate the list of key presses while it had been held down, convert to number and execute
	if is_debug_mode and MODIFIER_KEYS[key] and #pressed_phase_keys>0 then
		local pressed_num = tonumber(table.concat(pressed_phase_keys, ""))
		if pressed_num then --if sequence of key presses is a valid number
			local current_objective = active_list[list_index]
			self:set_description(current_objective, pressed_num) --DEBUG update the description pane to match the phase corresponding to the pressed key sequence
			print("DEBUG: Displaying description for phase "..pressed_num) --DEBUG
		end
		
		pressed_phase_keys = {} --reset for next key press
		
		return true
	end
end

function quest_log:on_draw(dst_surface)
	self.menu:draw(dst_surface, self.x, self.y)
end


--Avoid analog stick from jumping wildly:
local joy_avoid_repeat = {-2, -2}
function quest_log:on_joypad_axis_moved(axis, state)  

  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state      

  return handled
end

return quest_log

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
