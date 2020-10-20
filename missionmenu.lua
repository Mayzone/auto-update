function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end
if not is_playing() then 
	return
end
function is_server() -- Is host check
	return Network.is_server(Network)
end

function can_interact()
	return true
end

level = managers.job:current_level_id()
--interact by tweak
local function interactbytweak(...)
	local player = managers.player:player_unit()
	if not player then
		return
	end
	
	local tweaks = {}
	for _,arg in pairs({...}) do
		if type(arg) == 'string' then
			tweaks[arg] = true
			managers.mission._fading_debug_output:script().log(string.format("Hack %s ACTIVATED", arg),  Color.green)
		end
	end
	
	local interacts = {}
	local interaction
	for _,unit in pairs(managers.interaction._interactive_units) do
		if not alive(unit) then break end
		interaction = unit:interaction()
		if interaction and tweaks[interaction.tweak_data] then
			table.insert(interacts, interaction)
		end
	end
	
	for _,unit in pairs(World:find_units_quick("all", 1)) do
		interaction = unit:interaction()
		if interaction and tweaks[interaction.tweak_data] then
			table.insert(interacts, interaction)
		end
	end
	
	for _,int in pairs(interacts) do
		int.can_interact = can_interact
		int:interact(player)
		int.can_interact = nil
	end
end

-- Overdrill
local overdrill = function(element_id)
	local player = managers.player:player_unit()
	if not player or not alive(player) then
		return
	end

	for _, data in pairs(managers.mission._scripts) do
		for id, element in pairs(data:elements()) do
			if id == element_id then
				if Network:is_server() then
					element:on_executed(player)
				end
				break
			end
		end
	end
	managers.mission._fading_debug_output:script().log('Overdrill ACTIVATED',  Color.green)
end

local sequence_unit = function(name)
	for _, unit in pairs( World:find_units_quick('all') ) do
		if unit:damage() and unit:damage():has_sequence( name ) then
			unit:damage():run_sequence_simple( name ) 
			managers.network:session():send_to_peers_synched('run_mission_door_device_sequence', unit, name)
		end
	end
end

--barricade
barricades = function()
	--boarding after board
	local orig = UseInteractionExt.interact
	local barricades = { stash_planks = true, need_boards = true }
	global_toggle_planks_on = global_toggle_planks_on or function (self)
		orig(self)
		if barricades[self.tweak_data] and managers.player._players[1] then
			self:set_active(true, managers.player._players[1])
		end
		return
	end
	UseInteractionExt.interact = global_toggle_planks_on
	--board
	interactbytweak('stash_planks','need_boards')
end

--hack everything electric
local hack = function()
	interactbytweak(
	'hold_hlm_open_circuitbreaker',
	'invisible_interaction_open_box','security_station_keyboard',
	'vit_search_clues','hold_charge_gun',
	'hold_new_hack_tag','tag_laptop',
	'hold_new_hack','hold_type_in_password',
	'hold_search_computer','disable_lasers',
	'cas_customer_database','are_laptop',
	'mcm_laptop_code','mcm_laptop',
	'move_ship_gps_coords','hack_ship_control',
	'hold_download_keys','enter_code',
	'uload_database_jammed','uload_database',
	'laptop_objective','big_computer_server',
	'security_station','hack_suburbia_jammed',
	'hack_suburbia',
	'use_ticket',
	'hack_electric_box','big_computer_not_hackable',
	'hack_skylight_barrier','timelock_hack',
	'use_chainsaw','start_hack',
	'state_interaction_enabled_usb','big_computer_hackable',
	'pickup_phone','pickup_tablet',
	'use_computer','stash_server_pickup',
	'hospital_phone','phone',
	'crate_loot_crowbar','crate_loot',
	'invisible_interaction_searching','invisible_interaction_open',
	'hold_open_xmas_present','drill_upgrade',
	'drill_jammed','lance_upgrade',
	'lance_jammed','huge_lance_jammed',
	'invisible_interaction_open_axis_sah',
	'open_slash_close_sec_box','numpad',
	'invisible_interaction_open_axis_rvd','hold_open',
	'invisible_interaction_open_axis','hack_suburbia_axis',
	'hold_place_device','open_door',
	'hack_ipad','hold_turn_off_light',
	'invisible_interaction_open_axis_rvd','hold_disable_alarm',
	'hold_relay_locke','circuit_breaker',
	'hold_hack_server_room','hold_new_hack',
	'hold_open_door','hold_electric_lock',
	'hack_dah_jammed_x','rewire_timelock'
	)
	DelayedCalls:Add( "start_vote", 3, function() interactbytweak('hack_suburbia_outline','hack_suburbia_jammed_y','drk_hold_hack_computer','hold_cut_wires','hack_electric_box','circuit_breaker_off','use_server_device','hospital_security_cable_red','rewire_friend_fuse_box','votingmachine1','votingmachine2','votingmachine3','votingmachine4','votingmachine5','votingmachine6','rewire_electric_box') end)
	managers.mission._fading_debug_output:script().log('Wait 3 sec', Color.green)
end

local function openalldoors()
	for _, unit in pairs(World:find_units_quick('all')) do
		if (level == 'sah' or level == 'red2') then
			local open_door_elem = 'open_door'
			if unit:damage() and unit:damage():has_sequence(open_door_elem) then
				unit:damage():run_sequence_simple(open_door_elem)
				managers.network:session():send_to_peers_synched('run_mission_door_device_sequence', unit, open_door_elem)
			end
		elseif (level == 'big') then
			local open_door_elem = 'open'
			if unit:damage() and unit:damage():has_sequence(open_door_elem) then
				unit:damage():run_sequence_simple(open_door_elem)
				managers.network:session():send_to_peers_synched('run_mission_door_device_sequence', unit, open_door_elem)
			end
		end
	end
	
	--insta drill
	if not global_toggle_drill_off then
		dofile("mods/hook/content/scripts/drill.lua")
	end
	
	-- PLACE DRILL ON DOORS / RESTART DRILL
	interactbytweak('drill','lance','huge_lance','drill_upgrade','lance_upgrade','huge_lance_upgrade','drill_jammed','lance_jammed','huge_lance_jammed')
	
	--open most
	interactbytweak('weapon_case','hold_open_door','hold_search_drawer','hold_search_shower','hold_search_luggage','hold_search_steel_cabinet','hold_search_drawers','hold_search_cigar_boxes','hold_search_cart','hold_search_fridge','hold_search_capsule','hold_search_bookshelf','hold_open_window','cas_security_door','cas_open_securityroom_door','hold_blow_torch','gen_pku_blow_torch','test_interactive_door','key','timelock_panel','atm_interaction','sewer_manhole','apply_thermite_paste','cut_fence','crate_loot_crowbar','crate_loot','uno_open_door','press_knock_on_door','breach_crowbar','pry_open_door_elevator','glc_open_door','man_trunk_picklock','cas_open_door','cas_elevator_door_open','open_train_cargo_door','breach_door','embassy_door','open_door','elevator_button_roof','elevator_button','suburbia_door_crowbar','cas_use_elevator_key','use_hotel_room_key_no_access','use_hotel_room_key','panic_room_key','mcm_panicroom_keycard_2','mcm_panicroom_keycard','hold_unlock_car','open_door_with_keys','vit_keycard_use','dah_panicroom_keycard','mask_off_pickup','hold_insert_keycard_hlp','pick_lock_deposit_transport','pick_lock_easy_no_skill','pick_lock_hard_no_skill','pick_lock_hard','open_from_inside','open_train_cargo_door','pick_lock_easy','drill','drill_upgrade','drill_jammed','lance_upgrade','lance_jammed','huge_lance_jammed')
	
	--depositboxes
	DelayedCalls:Add( "open_deposit_boses_delay", 2, function()
		interactbytweak('pick_lock_deposit_transport','lockpick_locker')
		if global_toggle_drill_off then
			dofile("mods/hook/content/scripts/drill.lua")
		end
	end)
end

local pickupengine = function()
	local function interactbytweak_ex( key, tweak, alt )
		if not key or not tweak then
			return
		end
		local player = managers.player:local_player()
		if not alive( player ) then
			return
		end
		for _,unit in pairs(managers.interaction._interactive_units) do
			local interaction = unit.interaction
			interaction = interaction and interaction( unit )
			local carry_data = unit.carry_data
			carry_data = carry_data and carry_data( unit )
			if interaction then
				local tweak_d = interaction.tweak_data
				if key == 0 and tweak_d == tweak and carry_data and carry_data:carry_id() == alt then
					interaction:interact( player )
					return true
				elseif tweak_d == tweak and unit:name():key() == key then
					interaction:interact( player )
					return true
				end
			end
		end
	end

	local function find_engine()
		local script = managers.mission:script("default")
		local fusion_engine = script._elements[103718]._values.on_executed[1].id
		local table_t = { 
			["103717"] = "engine_12", ["103716"] = "engine_11", ["103715"] = "engine_10", ["103714"] = "engine_09", ["103711"] = "engine_08", ["103709"] = "engine_07", ["103708"] = "engine_06", ["103707"] = "engine_05", ["103706"] = "engine_04", ["103705"] = "engine_03", ["103704"] = "engine_02", ["103703"] = "engine_01" 
		}
		local table_k = {
			engine_01 = 'f0e7a7f29fc87c44', engine_02 = 'db218f98a571c0b1', engine_03 = 'c717770fadc88e04', engine_04 = '5fb0a3191c4b8202', engine_05 = '0b2ecebcf49765b9', engine_06 = 'b531a6b7026ad84f', engine_07 = 'e191b6d86e655e23', engine_08 = '5aabe6e626f00bd4', engine_09 = '5afbe85d94046cbe', engine_10 = '9f316997306803b9', engine_11 = 'b2560b63edcda138', engine_12 = 'ee644ab092313077', --v=xE23YXNGkKE,
		}
		local ret = table_t[tostring(fusion_engine)]
		if ret then
			return ret, table_k[ret]
		end
		return ""
	end
	local e,k = find_engine()
	if e == "" then
		return
	end
	local found = interactbytweak_ex(k, "gen_pku_fusion_reactor")
	if not found then
		interactbytweak_ex(0, "carry_drop", e)
	end
	managers.mission._fading_debug_output:script().log('Engine Pickup ACTIVATED', Color.green)
end

local inf_cam_feed = function()
	global_inf_cam_feed = global_inf_cam_feed or false
	if not global_inf_cam_feed then
		infinite_concurrent_camera_loops = true	-- client too
		camera_loop_duration_multiplier = 2		-- def 1. host only
		if not global_inf_cam_feed_toggle then global_inf_cam_feed_toggle = SecurityCamera._start_tape_loop end
		local old_start = old_start or SecurityCamera._start_tape_loop
		function SecurityCamera:_start_tape_loop(tape_loop_t)
			old_start(self, tape_loop_t * camera_loop_duration_multiplier)
			if infinite_concurrent_camera_loops then SecurityCamera.active_tape_loop_unit = nil end
		end
		managers.mission._fading_debug_output:script().log('Infinate Camera Feed ACTIVATED', Color.green)
	else
		infinite_concurrent_camera_loops = false	-- client too
		camera_loop_duration_multiplier = 1		-- def 1. host only
		if global_inf_cam_feed_toggle then SecurityCamera._start_tape_loop = global_inf_cam_feed_toggle end
		managers.mission._fading_debug_output:script().log('Infinate Camera Feed DEACTIVATED', Color.red)
	end
	global_inf_cam_feed = not global_inf_cam_feed
end

local function disable_lasers()
	global_disable_lasers = global_disable_lasers or false
	if not global_disable_lasers then
		if not global_laser_trigger then global_laser_trigger = ElementLaserTrigger.on_executed end
		function ElementLaserTrigger:on_executed(instigator, alternative) end
		managers.mission._fading_debug_output:script().log('Toggle Lasers ACTIVATED', Color.green)
	else
		if global_laser_trigger then ElementLaserTrigger.on_executed = global_laser_trigger end
		managers.mission._fading_debug_output:script().log('Toggle Lasers DEACTIVATED', Color.red)
	end
	global_disable_lasers = not global_disable_lasers
end

mission_table = {
	["absolute"] = {
	{ text = "All Map Secrets - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/waypoints.lua") end },
	{ text = "All Map Bags - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/waypoints2.lua") end },
	{},
	{ text = "Instant Timers - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/drill.lua") end },
	{ text = "Open All Doors - ON", callback_func = function() openalldoors() end },
	{ text = "Hack Electronic - ON", callback_func = function() hack() end },
	{ text = "Access Camera Feed - ON", callback_func = function() if (managers.player._current_state == "civilian") then return end interactbytweak('access_camera','access_camera_x_axis') end },
	{ text = "Infinate Camera Feed - ON/OFF", callback_func = function() inf_cam_feed() end },
	{ text = "Answer Pagers (Auto) - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/pageranswer.lua") end },
	{ text = "Pickup Gage Packages - ON", callback_func = function() interactbytweak('gage_assignment') end },
	{},
	},
	["roberts"] = {
	{ text = "Disable Laser Alarm - ON/OFF", callback_func = function() disable_lasers() end },
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('grenade_briefcase','timelock_panel','press_pick_up','bank_note','raise_balloon','sewer_manhole') end },
	},
	["man"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	},
	["big"] = {
	{ text = "Disable Laser Alarm - ON/OFF", callback_func = function() disable_lasers() end },
	},
	["cage"] = {
	{ text = "Take/Place C4 - ON/OFF", callback_func = function() interactbytweak('c4_bag','shape_charge_plantable') end },
	},
	["dark"] = {
	{ text = "Disable Laser Alarm - ON/OFF", callback_func = function() disable_lasers() end },
	{ text = "Show item locations - ON/OFF", callback_func = function() sequence_unit("enable_interaction") end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('open_train_cargo_door','pickup_harddrive','gen_pku_thermite_paste_z_axis','place_harddrive','pickup_keycard','drk_pku_blow_torch','hold_blow_torch','apply_thermite_paste') end },
	},
	--["pex"] = {
	--{ text = "Interact Objective - ON", callback_func = function() interactbytweak('pickup_evidence_pex','pex_place_evidance','pex_flammable_liquid','pex_set_burnable_liquid','pex_burn','hold_turn_off_sprinklers','pex_pickup_cutter','pex_cut_open_chains') end },
	--},
	["des"] = {
	{ text = "Ingredient A - ON/OFF", callback_func = function() interactbytweak('hold_add_compound_a') end },
	{ text = "Ingredient B - ON/OFF", callback_func = function() interactbytweak('hold_add_compound_b') end },
	{ text = "Ingredient C - ON/OFF", callback_func = function() interactbytweak('hold_add_compound_c') end },
	{ text = "Ingredient D - ON/OFF", callback_func = function() interactbytweak('hold_add_compound_d') end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('gen_pku_crowbar','push_button_secret','hold_aim_laser','hold_pull_switch','hold_fire_laser','hold_search_fridge','hold_search_documents','apply_concoction_paste','crate_loot_crowbar','hold_mix_concoction','hold_take_concoction') end },
	},
	["branchbank"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	},
	["red2"] = {
	{ text = "Overdrill Light - ON", callback_func = function() overdrill(104136) overdrill(104349) --[[ light/sound (overdrill)--]] end },
	{ text = "Overdrill Open Gate - ON", callback_func = function() overdrill(104180) --[[ open gate--]] end },
	{ text = "Overdrill Open Vault - ON", callback_func = function() overdrill(104192) overdrill(104198) overdrill(104303) --[[ disable puzzle/open vault/enable gold interaction--]] end },
	{ text = "Open/Close Shutters - ON", callback_func = function() interactbytweak('red_open_shutters','red_close_shutters') end },
	{ text = "Use Keycard - ON", callback_func = function() interactbytweak('pickup_keycard') DelayedCalls:Add( "keycardusepick", 1, function() interactbytweak('test_interactive_door','key') end) end },
	{ text = "Use/Place Drill - ON", callback_func = function() interactbytweak('drill','drill_jammed') end },
	},
	["mus"] = {
	{ text = "Use Keycard - ON", callback_func = function() interactbytweak('timelock_panel') end },
	{ text = "Cutt Glass - ON", callback_func = function() interactbytweak('cut_glass') end },
	{ text = "Use Thermite/Windows/Doors - ON", callback_func = function() interactbytweak('apply_thermite_paste') DelayedCalls:Add( "thermitewindow", 15, function() interactbytweak('pick_lock_easy_no_skill') end) end },
	{ text = "Diamond Path - ON", callback_func = function() dofile("mods/hook/content/scripts/diamondpath.lua") end },
	},
	["sah"] = {
	{ text = "Cutt Glass - ON", callback_func = function() interactbytweak('cut_glass') end },
	{ text = "Zipline Bag - ON", callback_func = function() interactbytweak('bag_zipline') end },
	},
	["welcome_to_the_jungle_2"] = {
	{ text = "Engine Pickup - ON", callback_func = function() if is_server() then pickupengine() end end },
	{ text = "Engine Print - ON", callback_func = function() dofile("mods/hook/content/scripts/menus/correctenginemenu.lua") end },
	},
	["crojob2"] = {
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Semi Auto - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker semi auto.lua") end },
	{ text = "AutoCooker - Spawn 1 More Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add more.lua") end },
	{ text = "AutoCooker - Spawn 1 Less Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add less.lua") end },
	{ text = "AutoCooker - Secure Bags On Spawn - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker secure.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	{ text = "AutoCooker - Less Spam Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker spam.lua") end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('c4_bag_dynamic','use_flare','uload_database','pickup_keycard','hold_call_captain','move_ship_gps_coords','atm_interaction') DelayedCalls:Add( "drill_after_cargo2", 1.5, function() interactbytweak('hack_ship_control','shape_charge_plantable','timelock_panel','hold_open_bomb_case') end) end },
	},
	["crojob3"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('grenade_briefcase','use_flare','take_chainsaw','shape_charge_plantable_c4_x1','crate_loot_crowbar','open_train_cargo_door','connect_hose') DelayedCalls:Add( "drill_after_cargo", 1.5, function() interactbytweak('hold_open_bomb_case','gen_pku_thermite_paste','connect_hose','c4_x1_bag','use_chainsaw','generator_start','drill','drill_jammed','apply_thermite_paste') end) end },
	{ text = "Zipline Bag - ON", callback_func = function() interactbytweak('bag_zipline') end },
	},
	["vit"] = {
	{ text = "Take Painting - ON", callback_func = function() interactbytweak('uno_hold_pku_gold_bar','uno_mayan_gold_bar', 'vit_remove_painting','hold_take_painting') end },
	{ text = "Open Bookcase - ON", callback_func = function() interactbytweak('vit_search') DelayedCalls:Add( "library_button", 1.5, function() interactbytweak('push_button') end) end },
	{ text = "Take Pardons - ON", callback_func = function() interactbytweak('take_pardons') end },
	{ text = "Activate Secret - ON", callback_func = function() managers.mission:call_global_event("uno_access_granted") end },
	{ text = "Take/Place Mayan Gold - ON", callback_func = function() interactbytweak('uno_hold_pku_gold_bar','uno_mayan_gold_bar') end },
	},
	["hox_3"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	{ text = "Open Windows and fences - ON", callback_func = function() interactbytweak('pick_lock_easy_no_skill','mcm_break_planks') end },
	{ text = "Use Keycards - ON", callback_func = function() interactbytweak('pickup_keycard','mcm_panicroom_keycard_2') end },
	},
	["dinner"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('invisible_interaction_open','c4_consume','gasoline','din_crane_control') end },
	},
	["gallery"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('hold_take_painting') end },
	},
	["framing_frame_1"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('hold_take_painting') end },
	},
	["alex_1"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Semi Auto - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker semi auto.lua") end },
	{ text = "AutoCooker - Spawn 1 More Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add more.lua") end },
	{ text = "AutoCooker - Spawn 1 Less Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add less.lua") end },
	{ text = "AutoCooker - Secure Bags On Spawn - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker secure.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	{ text = "AutoCooker - Less Spam Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker spam.lua") end },
	},
	["rat"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Semi Auto - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker semi auto.lua") end },
	{ text = "AutoCooker - Spawn 1 More Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add more.lua") end },
	{ text = "AutoCooker - Spawn 1 Less Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add less.lua") end },
	{ text = "AutoCooker - Secure Bags On Spawn - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker secure.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	{ text = "AutoCooker - Less Spam Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker spam.lua") end },
	},
	["mia_1"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Semi Auto - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker semi auto.lua") end },
	{ text = "AutoCooker - Spawn 1 More Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add more.lua") end },
	{ text = "AutoCooker - Spawn 1 Less Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add less.lua") end },
	{ text = "AutoCooker - Secure Bags On Spawn - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker secure.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	{ text = "AutoCooker - Less Spam Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker spam.lua") end },
	},
	["mex_cooking"] = {
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Semi Auto - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker semi auto.lua") end },
	{ text = "AutoCooker - Spawn 1 More Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add more.lua") end },
	{ text = "AutoCooker - Spawn 1 Less Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add less.lua") end },
	{ text = "AutoCooker - Secure Bags On Spawn - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker secure.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	{ text = "AutoCooker - Less Spam Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker spam.lua") end },
	},
	["cane"] = {
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Semi Auto - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker semi auto.lua") end },
	{ text = "AutoCooker - Spawn 1 More Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add more.lua") end },
	{ text = "AutoCooker - Spawn 1 Less Bag - ON", callback_func = function() dofile("mods/hook/content/scripts/autocooker add less.lua") end },
	{ text = "AutoCooker - Secure Bags On Spawn - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker secure.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	{ text = "AutoCooker - Less Spam Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker spam.lua") end },
	},
	["nail"] = {
	{ text = "AutoCooker - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker.lua") end },
	{ text = "AutoCooker - Announce Chat - ON/OFF", callback_func = function() dofile("mods/hook/content/scripts/autocooker announce.lua") end },
	},
	["family"] = {
	{ text = "Shatter Glass - ON", callback_func = function() sequence_unit("glass_shatter") sequence_unit("glass_shatter_01") end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('numpad_keycard') end },
	},
	["jewelry_store"] = {
	{ text = "Shatter Glass - ON", callback_func = function() sequence_unit("glass_shatter") sequence_unit("glass_shatter_01") end },
	},
	["ukrainian_job"] = {
	{ text = "Shatter Glass - ON", callback_func = function() sequence_unit("glass_shatter") sequence_unit("glass_shatter_01") end },
	},
	["arena"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('gen_pku_circle_cutter','hold_circle_cutter','answer_call','votingmachine2_jammed','are_laptop','c4_x10','hold_search_c4','push_button','pick_lock_hard_no_skill_deactivated') end },
	},
	["arm_for"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('pickup_harddrive','place_harddrive','pick_lock_x_axis','rewire_timelock','zipline_mount','rewire_timelock') end },
	},
	["pal"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('gen_pku_crowbar','suburbia_door_crowbar','invisible_interaction_open_axis_rvd','hack_suburbia_axis','shelf_sliding_suburbia','suburbia_iron_gate_crowbar','interaction_ball','water_tap','c4','press_plates','hold_insert_plates','sewer_manhole','hold_insert_paper_roll','hold_insert_printer_ink','hold_start_printer') end },
	},
	["nmh"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('hold_take_sample','press_insert_sample') end },
	},
	["fish"] = {
	{ text = "Disable Laser Alarm - ON/OFF", callback_func = function() disable_lasers() end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('hold_turn_off','press_insert_sample','push_button_secret','pickup_harddrive') end },
	},
	["peta"] = {
	{ text = "Show Goats - ON", callback_func = function() sequence_unit("state_interaction_enabled") end },
	},
	["peta2"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	},
	["flat"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('panic_room_key') end },
	},
	["bex"] = {
	{ text = "Code 0 - ON", callback_func = function() interactbytweak('cas_button_00') end },
	{ text = "Code 1 - ON", callback_func = function() interactbytweak('cas_button_01') end },
	{ text = "Code 2 - ON", callback_func = function() interactbytweak('cas_button_02') end },
	{ text = "Code 3 - ON", callback_func = function() interactbytweak('cas_button_03') end },
	{ text = "Code 4 - ON", callback_func = function() interactbytweak('cas_button_04') end },
	{ text = "Code 5 - ON", callback_func = function() interactbytweak('cas_button_05') end },
	{ text = "Code 6 - ON", callback_func = function() interactbytweak('cas_button_06') end },
	{ text = "Code 7 - ON", callback_func = function() interactbytweak('cas_button_07') end },
	{ text = "Code 8 - ON", callback_func = function() interactbytweak('cas_button_08') end },
	{ text = "Code 9 - ON", callback_func = function() interactbytweak('cas_button_09') end },
	{ text = "Code Enter - ON", callback_func = function() interactbytweak('cas_button_enter') end },
	{ text = "Code Clear - ON", callback_func = function() interactbytweak('cas_button_clear') end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('vit_search','invisible_interaction_open_axis_rvd','take_tape','bex_take_record_tape','press_take_folder','gen_pku_lance_part') end },
	},
	["kenaz"] = {
	{ text = "Code 0 - ON", callback_func = function() interactbytweak('cas_button_00') end },
	{ text = "Code 1 - ON", callback_func = function() interactbytweak('cas_button_01') end },
	{ text = "Code 2 - ON", callback_func = function() interactbytweak('cas_button_02') end },
	{ text = "Code 3 - ON", callback_func = function() interactbytweak('cas_button_03') end },
	{ text = "Code 4 - ON", callback_func = function() interactbytweak('cas_button_04') end },
	{ text = "Code 5 - ON", callback_func = function() interactbytweak('cas_button_05') end },
	{ text = "Code 6 - ON", callback_func = function() interactbytweak('cas_button_06') end },
	{ text = "Code 7 - ON", callback_func = function() interactbytweak('cas_button_07') end },
	{ text = "Code 8 - ON", callback_func = function() interactbytweak('cas_button_08') end },
	{ text = "Code 9 - ON", callback_func = function() interactbytweak('cas_button_09') end },
	{ text = "Code Enter - ON", callback_func = function() interactbytweak('cas_button_enter') end },
	{ text = "Code Clear - ON", callback_func = function() interactbytweak('cas_button_clear') end },
	{ text = "Take Gear - ON", callback_func = function() interactbytweak('cas_open_guitar_case') DelayedCalls:Add( "gear", 1, function() interactbytweak('cas_take_gear') end) DelayedCalls:Add( "gear2", 1.5, function() interactbytweak('cas_take_sleeping_gas') end) end },
	{ text = "Gas Security - ON", callback_func = function() interactbytweak('cas_vent_gas') end },
	{ text = "Disable Laser Alarm - ON/OFF", callback_func = function() disable_lasers() end },
	{ text = "Play Slots - ON", callback_func = function() interactbytweak('cas_slot_machine') end },
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('cas_open_briefcase','cas_take_usb_key','cas_copy_usb','cas_use_usb','computer_blueprints','use_blueprints','send_blueprints','cas_take_usb_key_data','take_bottle','pour_spiked_drink','pickup_hotel_room_keycard','c4_bag','shape_charge_plantable','use_flare','cas_screw_down','hack_skylight_barrier','cas_take_hook','cas_connect_winch_hook','cas_start_winch','cas_connect_power','cas_open_powerbox','cas_connect_power','cas_start_drill','cas_fix_bfd_drill') end },
	},
	["mex"] = {
	{ text = "Interact Objective - ON", callback_func = function() interactbytweak('mex_pickup_murky_uniforms') end },
	},
	["rvd1"] = {
	{ text = "Barricade All Windows - ON", callback_func = function() barricades() end },
	},
}

function mission_menu()
	local dialog_data = {    
		title = "Mission Menu",
		text = "Select Option",
		button_list = {}
	}
	
	local list = {
		"absolute",
		managers.job:current_level_id(),
	}
	for _, absolute_list in pairs(list) do
		if mission_table[absolute_list] then
			for _, mission_func in pairs(mission_table[absolute_list]) do
				table.insert(dialog_data.button_list, mission_func)
			end
		end
	end

	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, { text = managers.localization:text("dialog_cancel"), focus_callback_func = function () end, cancel_button = true }) 
	managers.system_menu:show_buttons(dialog_data)
end
mission_menu()