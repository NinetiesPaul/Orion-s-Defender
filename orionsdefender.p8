pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- general code

function _init()
	-- encounters variable
	encounters = {}
	move_pirate_sprite = "up"
	pirate_sprite_y = 2

	-- general purpose variables
	--[[
		1,	-- 1 world
		2,	-- 2 battle
		3,	-- 3 rewards
		4,	-- 4 store
		5,	-- 5 game over
		6,	-- 6 start screen
		7 	-- 7 tutorial
	]]--
	pirate_rep = 0
	clock = 0
	current_view = 6
	pause_menu = false
	pause_menu_option = 1
	pause_menu_myship = false
	pause_menu_myship_page = 0
	pause_menu_battlerep = false
	pause_menu_battlerep_page = 0
	pause_menu_quest_text = false
	help_text_y = 0
	stars = {}

	-- player variables
	scraps = 30
	ship_spr = 017
	ship_x = 64
	ship_y = 118
	health_spr = 1
	armor_spr =  1
	fuel_spr = 1
	max_fuel = 15
	fuel_comsumption = 0.0075
	bullets = {}
	ammo_mode = {
		"laser", -- 1
		"missile", -- 2
		"cluster", -- 3
		"stun" -- 4
	}
	encounters_spr = {
		64,
		72,
		96
	}

	stat_lvl = { 5, 10, 15 }
	current_ammo_mode = 1
	special_ammo_lvls = { 4, 6, 8 }

	laser_cooldown_lvls = { 75, 45, 15 }
	laser_damage_lvls = { 1.7, 2.4, 2.9 }
	laser_damage = laser_damage_lvls[1]
	laser_cooldown_rate = laser_cooldown_lvls[1]
	laser_cooldown = false
	laser_cooldown_counter = 0

	missile_cooldown_lvls = { 120, 90, 75 }
	missile_damage_lvls = { 2.5, 3.2, 4.1 }
	missile_damage = missile_damage_lvls[1]
	missile_cooldown_rate = missile_cooldown_lvls[1]
	missile_cooldown = false
	missile_cooldown_counter = 0
	missile_locked_on_enemy = 1

	stun_cooldown_lvls = { 100, 75, 45 }
	stun_damage_lvls = { 1, 1.2, 1.4 }
	stun_proximity_damage_lvs = { 0.16, 0.22, 0.28 }
	stun_damage = stun_damage_lvls[1]
	stun_proximity_damage = stun_proximity_damage_lvs[1]
	stun_cooldown_rate = stun_cooldown_lvls[1]
	stun_cooldown = false
	stun_cooldown_counter = 0

	cluster_cooldown_lvls = { 95, 70, 35 }
	cluster_damage_lvls = { 0.85, 1.1, 1.3 }
	cluster_frag_damage_lvls = { 1.2, 1.35, 1.45 }
	cluster_damage = cluster_damage_lvls[1]
	cluster_frag_damage = cluster_frag_damage_lvls[1]
	cluster_cooldown_rate = cluster_cooldown_lvls[1]
	cluster_cooldown = false
	cluster_cooldown_counter = 0

	player = {
		fuel = 15,
		max_fuel = 15,

		health_lvl = 1,
		health_max_lvl = 3,
		health = stat_lvl[1],
		max_health = stat_lvl[1],

		armor_lvl = 1,
		armor_max_lvl = 3,
		armor = stat_lvl[1],
		max_armor = stat_lvl[1],

		missile_lvl = 1,
		missile_max_lvl = 3,
		missile_n = 4,
		missile_max_capacity = special_ammo_lvls[1],

		stun_lvl = 1,
		stun_max_lvl = 3,
		stun_n = 0,
		stun_max_capacity = special_ammo_lvls[1],

		cluster_lvl = 1,
		cluster_max_lvl = 3,
		cluster_n = 0,
		cluster_max_capacity = special_ammo_lvls[1],
		
		laser_lvl = 1,
		laser_max_lvl = 3,

		weapon_system_lvl = 1,
		weapon_system_max_lvl = 3
	}

	game_random_factor = 0.95
	collateral_type =
	{
		1,	-- motor damage
		2,	-- aiming damage
		3 	-- firing damage
	}
	score = 0
	total_enemies_destroyed = 0
	missiles = {}

	-- shop
	pirate_store = false
	shop_selector_spr = 002
	shop_selector_y = 16
	shop_selector = 1
	current_shop_item = {}
	shop_last_bought = ""
	shop_items = {}
	all_shop_items = {
		{
			name = "fuel",
			formatted_name = "fuel",
			price = 3,
			shops = "both",
			compare_with = "max_fuel",
			enabled = true
		},
		{
			name = "health",
			price = 4,
			formatted_name = "health",
			shops = "both",
			compare_with = "max_health",
			enabled = true
		},
		{
			name = "health_lvl",
			price = 50 * player.health_lvl,
			formatted_name = "health upgrade",
			shops = "civ",
			compare_with = "health_max_lvl",
			relates_to = "health",
			enabled = true
		},
		{
			name = "armor",
			price = 4,
			formatted_name = "armor",
			shops = "both",
			compare_with = "max_armor",
			enabled = true
		},
		{
			name = "armor_lvl",
			price = 65 * player.armor_lvl,
			formatted_name = "armor upgrade",
			shops = "civ",
			compare_with = "armor_max_lvl",
			relates_to = "armor",
			enabled = true
		},
		{
			name = "weapon_system_lvl",
			price = 75 * player.weapon_system_lvl,
			formatted_name = "weapon system upgrade",
			shops = "civ",
			compare_with = "weapon_system_max_lvl",
			enabled = true
		},
		{
			name = "laser_lvl",
			price = 55 * player.laser_lvl,
			formatted_name = "laser upgrade",
			shops = "civ",
			compare_with = "laser_max_lvl",
			enabled = true
		},
		{
			name = "missile_n",
			price = 7,
			formatted_name = "missile ammo",
			shops = "both",
			compare_with = "missile_max_capacity",
			enabled = true
		},
		{
			name = "missile_lvl",
			price = 55 * player.missile_lvl,
			formatted_name = "missile upgrade",
			shops = "civ",
			compare_with = "missile_max_lvl",
			relates_to = "missile_n",
			enabled = true
		},
		{
			name = "cluster_n",
			price = 3,
			formatted_name = "cluster ammo",
			shops = "both",
			compare_with = "cluster_max_capacity",
			enabled = true
		},
		{
			name = "cluster_lvl",
			price = 35 * player.cluster_lvl,
			formatted_name = "cluster upgrade",
			shops = "civ",
			compare_with = "cluster_max_lvl",
			relates_to = "cluster_n",
			enabled = true
		},
		{
			name = "stun_n",
			price = 4,
			formatted_name = "stun ammo",
			shops = "both",
			compare_with = "stun_max_capacity",
			enabled = true
		},
		{
			name = "stun_lvl",
			price = 45 * player.stun_lvl,
			formatted_name = "stun upgrade",
			shops = "civ",
			compare_with = "stun_max_lvl",
			relates_to = "stun_n",
			enabled = true
		},
		{
			name = "pirate_bribe",
			price = 125 * pirate_rep,
			formatted_name = "bribe pirate faction",
			shops = "pirate",
			enabled = true
		}
	}

	-- enemy and battle
	enemy_list = 
	{
		{
			id = 1,
			name = "ant",
			spr = 009,
			spr_damage = 025,
			b_health = 3,
			b_energy = 3,
			b_damage = 1,
			b_shot_speed = 1.5,
			b_speed =  0.75,
			b_cdr = 90,
			score = 100,
			reward = 8,
			n_destroyed = 0,
			knowledge_level = 0
		},
		{
			id = 2,
			name = "ghost",
			spr = 010,
			spr_damage = 026,
			b_health = 3.5,
			b_energy = 3,
			b_damage = 2,
			b_shot_speed = 1.0,
			b_speed =  1,
			b_cdr = 75,
			score = 125,
			reward = 12,
			n_destroyed = 0,
			knowledge_level = 0
		},
		{
			id = 3,
			name = "eagle",
			spr = 011,
			spr_damage = 027,
			b_health = 4,
			b_energy = 3.8,
			b_damage = 1,
			b_shot_speed = 1.5,
			b_speed =  1.3,
			b_cdr = 60,
			score = 150,
			reward = 14,
			n_destroyed = 0,
			knowledge_level = 0
		},
		{
			id = 4,
			name = "spectre",
			spr = 012,
			spr_damage = 028,
			b_health = 4.2,
			b_energy = 5,
			b_damage = 2,
			b_shot_speed = 1.8,
			b_speed =  1.5,
			b_cdr = 50,
			score = 175,
			reward = 16,
			n_destroyed = 0,
			knowledge_level = 0
		},
		{
			id = 5,
			name = "sentinel",
			spr = 013,
			spr_damage = 029,
			b_health = 5,
			b_energy = 7,
			b_damage = 3,
			b_shot_speed = 2,
			b_speed =  1.7,
			b_cdr = 50,
			score = 250,
			reward = 20,
			n_destroyed = 0,
			knowledge_level = 0
		},
		{
			id = 6,
			name = "spider",
			spr = 061,
			spr_damage = 029,
			b_health = 7,
			b_energy = 6,
			b_damage = 4,
			b_shot_speed = 2.5,
			b_speed =  2,
			b_cdr = 55,
			score = 300,
			reward = 30,
			n_destroyed = 0,
			knowledge_level = 0
		}
	}
	enemies = {}
	enemy_bullets = {}
	explosions = {}
	warnings = {}
	positions = {
		{8,14},
		{21,51},
		{39,25},
		{51,61},
		{77,55},
		{89,35},
		{102,14},
		{112,61},
	}
	battle_rewards = 0
	battle_started = false
	
	transition_animation = false
	hold_transition = false
	skip_transition_hold = false
	left_side = 0
	right_side = 127
	animation_direction = "in"

	-- music variables
	can_leave_screen = false
	music_view_1_playing = false
	music_batttle_player = false
	music_battle_end_playing = false

	siren_spr = 015

	-- quests
	current_quest = 0
	current_quest_text = "no quest ongoing"
	showing_quest_prompt = false
	current_quest_option = false
	quest_enemy_warned = false
	quest_ended_message = false
	quest_reward = 0
	hunt_quest_enemies_destroyed = 0
end

function _draw()
	cls()

	-- spr(siren_spr,64,72)
	-- rect(0,0,127,127, 7)
	if (current_view == 1 or current_view == 2 or current_view == 4) draw_ui()
	if (current_view == 1 or current_view == 2 or current_view == 6) foreach(stars, draw_star)
	if (current_view == 1 or current_view == 2 and not transition_animation) spr(ship_spr,ship_x,ship_y)

	draw_transition_animation()
	if current_view == 1 then -- world
		if (pirate_rep > 0) draw_threat()
		foreach(encounters, draw_encounter)

		if pause_menu then
			rect(24,24,104,104, 11)
			palt(0, false) rectfill(25,25,103,103, 0) palt(0, true)

			-- line(64,0,64,127, 7)

			if not showing_quest_prompt then
				if not pause_menu_myship and not pause_menu_battlerep and not pause_menu_quest_text then
					print("ship systems", 40, 58, (pause_menu_option == 1) and 7 or 11)
					print("battle report", 38, 64, (pause_menu_option == 2) and 7 or 11)
					print("current quest", 38, 70, (pause_menu_option == 3) and 7 or 11)
				end

				if pause_menu_battlerep then
					print("battle report", 26, 26, 11)
					spr(enemy_list[pause_menu_battlerep_page].spr, 26, 39)
					print("the " .. "\""..enemy_list[pause_menu_battlerep_page].name.."\"", 37, 40, 7)

					print("hull: " .. enemy_list[pause_menu_battlerep_page].b_health, 26, 48, 7)
					print("shield: " .. enemy_list[pause_menu_battlerep_page].b_energy, 26, 54, 7)
					print("speed: " .. enemy_list[pause_menu_battlerep_page].b_speed, 26, 60, 7)
					print("shot speed: " .. enemy_list[pause_menu_battlerep_page].b_shot_speed, 26, 66, 7)
					print("damage: " .. enemy_list[pause_menu_battlerep_page].b_damage, 26, 72, 7)
					print("cooldown: " .. enemy_list[pause_menu_battlerep_page].b_cdr, 26, 78, 7)
					
					threath = (pause_menu_battlerep_page == 1) and "low" or (pause_menu_battlerep_page == 2 or pause_menu_battlerep_page == 3) and "mid" or "high"
					print("threath level: " .. threath, 26, 84, 7)
					print("confirmed kills: " .. enemy_list[pause_menu_battlerep_page].n_destroyed, 26, 90, 7)
					print("proficiency: " .. enemy_list[pause_menu_battlerep_page].knowledge_level, 26, 96, 7)
				end

				if pause_menu_myship then
					if pause_menu_myship_page == 1 then
						print("ship systems", 26, 26, 11)

						spr(003, 26, 40)
						print("health", 34, 41, 7)
						print(player.health.."/"..player.max_health, 92, 41, 7)
						print("current ver: ", 26, 49, 7)
						print(player.health_lvl .. "/3", 92, 49, 7)

						spr(004, 26, 55)
						print("armor", 34, 56, 7)
						print(player.armor.."/"..player.max_armor, 92, 56, 7)
						print("current ver: ", 26, 64, 7)
						print(player.armor_lvl .. "/3", 92, 64, 7)

						spr(005, 26, 70)
						print("fuel", 34, 71, 7)
						print(flr(player.fuel).."/"..player.max_fuel, 84, 71, 7)
					elseif pause_menu_myship_page == 2 then
						print("laser weapon", 26, 26, 11)

						print("system lv", 26, 40, 7)
						print(player.laser_lvl, 100, 40, 7)
						print("damage", 26, 46, 7)
						print(laser_damage, 92, 46, 7)
						print("reload time", 26, 52, 7)
						print(laser_cooldown_rate, 96, 52, 7)
					elseif pause_menu_myship_page == 3 then
						print("guided shot", 26, 26, 11)

						print("system lv", 26, 40, 7)
						print(player.missile_lvl, 100, 40, 7)
						print("damage", 26, 46, 7)
						print(missile_damage, 92, 46, 7)
						print("reload time", 26, 52, 7)
						print(missile_cooldown_rate, 92, 52, 7)
						print("stockpile", 26, 58, 7)
						print(player.missile_n.."/"..player.missile_max_capacity, 92, 58, 7)
					elseif pause_menu_myship_page == 4 then
						print("cluster shot", 26, 26, 11)

						if player.weapon_system_lvl >= 2 then
							print("system lv", 26, 40, 7)
							print(player.cluster_lvl, 100, 40, 7)
							print("damage", 26, 46, 7)
							print(cluster_damage, 92, 46, 7)
							print("cluster damage", 26, 52, 7)
							print(cluster_frag_damage, 88, 52, 7)
							print("reload time", 26, 58, 7)
							print(cluster_cooldown_rate, 96, 58, 7)
							print("stockpile", 26, 64, 7)
							print(player.cluster_n.."/"..player.cluster_max_capacity, 92, 64, 7)
						else
							print("unavailable", 26, 40, 7)
						end
					elseif pause_menu_myship_page == 5 then
						print("stun shot", 26, 26, 11)

						if player.weapon_system_lvl == 3 then
							print("system lv", 26, 40, 7)
							print(player.stun_lvl, 100, 40, 7)
							print("damage", 26, 46, 7)
							print(stun_damage, 92, 46, 7)
							print("prox damage", 26, 52, 7)
							print(stun_proximity_damage, 92, 52, 7)
							print("reload time", 26, 58, 7)
							print(stun_cooldown_rate, 92, 58, 7)
							print("stockpile", 26, 64, 7)
							print(player.stun_n.."/"..player.stun_max_capacity, 92, 64, 7)
						else
							print("unavailable", 26, 40, 7)
						end
					end
				end

				if pause_menu_quest_text then
					print(current_quest_text, 26, 26, 7)
				end
			else
				print(showing_quest_prompt, 26, 26, 7)
				print("[z/🅾️] accept", 26, 92, 7)
				if (current_quest != 2) print("[x/❎] decline", 26, 98, 7)
			end
		end
	end

	if current_view == 2 then -- battle
		foreach(enemies, draw_enemy)
		foreach(enemy_bullets, draw_enemy_bullet)
		foreach(bullets, draw_bullet)
		foreach(missiles, draw_missile)
		foreach(explosions, draw_explosion)
		foreach(warnings, print_warning)
		if (count(warnings) == 0) foreach(enemies, create_enemy_bullet)
	end

	if current_view == 3 then -- rewards
		print("victory!", 48,64, 0)
		print("found " .. battle_rewards .. " scraps", 35,72, 0)
		if (quest_ended_message) print(quest_ended_message, 35,78, 0)
		if (stat(54) == 0) print("press z or x to continue", 18, 104, 0)
	end

	if current_view == 4 and not transition_animation then -- shop
		i = 0
		for item in all (shop_items) do 
			price = (pirate_store == false) and item.price or (item.name == "pirate_bribe") and item.price or ceil(item.price/2)

			print(item.formatted_name, 14, 16 + i * 6, 7)
			if (item.enabled) print("$", 100, 16 + i * 6, 3)
			if (item.enabled) print(price, 104, 16 + i * 6, 7)
			i += 1
		end

		rectfill(0,121,127,127, 7)

		if (clock % 90 == 0) shop_last_bought = ""
		print(shop_last_bought, 1, 122, 0)

		print("z/🅾️ [buy]", 88, 1, 0)
		print("x/❎ [exit]", 84, 7, 0)

		animate_shop_selector()
	end

	if current_view == 5 then -- gameover
		print("game over", 44, 64, 0)
		print("final score:" .. score, 38, 70, 0)
		print("press any key", 38, 82, 0)
	end

	if current_view == 6 then -- start
		spr(128,24,44,9,3)
		print("z/🅾️ to start", 40, 84,7)
		print("x/❎ to help", 42, 92,7)
	end

	if current_view == 7 then -- help
		print("*** basic gameplay", 2, 8 + help_text_y, 7)
		print("when travelling, pick fights by\nentering the battle encounter\nicon or go to shops to refuel\nand buy goods and ship upgrades", 2, 16 + help_text_y, 7)

		spr(064, 0, 38 + help_text_y, 2, 2)
		print("this is a battle encounter!\nload up!", 17, 41 + help_text_y)

		spr(072, 0, 52 + help_text_y, 2, 2)
		print("regular shop. refuel, rearm\nand upgrade", 17, 55 + help_text_y)

		spr(072, 0, 69 + help_text_y, 2, 2)
		spr(046, 7, 75 + help_text_y)
		spr(062, 7, 75 + help_text_y)
		print("pirate owned shop. it's\ncheaper but sell no upgrade", 17, 72 + help_text_y)

		print("press z/🅾️ while travelling,\nto show the pause menu. on it,\nyou can get a view on your ship\nstats and current loadout.", 2, 86 + help_text_y, 7)

		print("you can also see the enemy\ndatabase with valuable\ninformation about the enemy\nships, as well as how many you\nhave destroyed and how\nproficient you are.", 2, 110 + help_text_y, 7)

		print("*** fighting", 2, 148 + help_text_y, 7)

		print("by entering the battle\nencounter you'll start a ship\nfight! be careful to start one\nwith sufficient health as once\nstarted you can't escape it", 2, 156 + help_text_y)

		spr(001, 2, 192 + help_text_y)
		print("when in battle, press x/❎ to\nswitch between different kind\nof ammo. press z/🅾️ to shoot", 11, 188 + help_text_y, 7)

		spr(016, 2, 208 + help_text_y)
		print("in missile mode, press ⬆️ or\n⬇️ to switch targets", 11, 208 + help_text_y, 7)

		print("the more you destroy an enemy\nof a particular class, the more\nknowledge you acquire about\nthat class and with that you\nimprove your chances of giving\ncollateral damage.", 2, 222 + help_text_y, 7)

		spr(030, 2, 270 + help_text_y)
		spr(062, 2, 270 + help_text_y)
		print("as you fight and destroy\npirates, your wanted level\nincreases. the skull icon\nindicates this. ", 11, 260 + help_text_y, 7)

		print("greater wanted levels increases\nthe difficulty (more enemies to\nfight, enemies of increased\nthreat level), but also\nincreases your rewards.", 2, 286 + help_text_y, 7)

		print("you can pay a tax to the pirate\ntribe to decrease your wanted\nlevel at the pirate shop", 2, 318 + help_text_y, 7)

		rectfill(0,0, 127,6, 7)
		rect(0,0,127,127,7)
		print("game help", 40, 1, 0)
	end
end

function _update()
	clock+=1

	if (clock % 1 == 0) siren_spr += 16
	if (siren_spr > 31) siren_spr = 015

	if (count(warnings) == 0) move()
	update_threat()
	update_icons()

	if current_view == 1 then -- world
		if not pause_menu then
			player.fuel -= fuel_comsumption
			if (clock % 60 == 0 and not transition_animation) create_encounter()
			if (player.fuel <= 0) transition_animation = true
			foreach(encounters, move_encounter)
			if (btnp(4)) pause_menu = true
		else
			if not showing_quest_prompt then
				if btnp(3) then
					if (pause_menu_option < 3) pause_menu_option += 1
				elseif btnp(2) then
					if (pause_menu_option > 1) pause_menu_option -= 1
				end

				if btnp(0) then
					if (pause_menu_myship and pause_menu_myship_page > 1) pause_menu_myship_page -= 1
					if (pause_menu_battlerep and pause_menu_battlerep_page > 1) pause_menu_battlerep_page -= 1
				elseif btnp(1) then
					if (pause_menu_myship and pause_menu_myship_page < 6) pause_menu_myship_page += 1
					if (pause_menu_battlerep and pause_menu_battlerep_page < 6) pause_menu_battlerep_page += 1
				end

				if btnp(4) then
					if (pause_menu_option == 1) pause_menu_myship = true pause_menu_myship_page = 1 pause_menu_battlerep = false
					if (pause_menu_option == 2) pause_menu_myship = false pause_menu_battlerep = true pause_menu_battlerep_page = 1
					if (pause_menu_option == 3) pause_menu_quest_text = true
				end
			else
				if btnp(4) then
					if current_quest == 2 then
						scraps += 90
						reset_quest_params()
					else 
						current_quest = current_quest_option
						current_quest_text = showing_quest_prompt
						showing_quest_prompt = false
					end
					pause_menu = false
				end
			end

			if btnp(5) then
				if (not pause_menu_myship and not pause_menu_battlerep and not pause_menu_quest_text) pause_menu = false showing_quest_prompt = false
				if (pause_menu_myship) pause_menu_myship_page = 0 pause_menu_myship = false
				if (pause_menu_battlerep) pause_menu_battlerep_page = 0 pause_menu_battlerep = false
				if (pause_menu_quest_text) pause_menu_quest_text = false
			end
		end
	end

	if current_view == 2 then
		if (not battle_started and not transition_animation) start_battle()
		if count(warnings) == 0 then
			fire()
			foreach(enemies, move_enemy)
			foreach(bullets, move_bullet)
			foreach(enemy_bullets, move_enemy_bullet)
			foreach(explosions, animate_explosion)
		end
		foreach(warnings, move_warning)

		if (battle_started and count(enemies) > 0 and current_ammo_mode == 2 and not missile_cooldown) missile_ui()
		foreach(missiles, move_missile)
		if (battle_started and count(explosions) == 0 and count(enemies) == 0) transition_animation = true
	end

	if current_view == 3 then
		if stat(54) == 0 then
			if btnp(4) or btnp(5) and not transition_animation then
				resume_transition()
			end
		end
	end

	if current_view == 4 then
		nav_store()
	end

	if current_view == 5 then
		restart_from_gameover()
	end

	if current_view == 6 or current_view == 7 then
		start()

		if (btn(2)) help_text_y += 5
		if (btn(3)) help_text_y -= 5
		if (help_text_y > 0) help_text_y = 0
		if (help_text_y < -210) help_text_y = -210
	end

	-- music control

	if current_view == 6 or current_view == 7 or current_view == 1 then
		if music_view_1_playing == false then
			music_view_1_playing = true
			music(9)
		end
	else
		music_view_1_playing = false
	end

	if current_view == 2 then
		if music_battle_playing == false then
			music_battle_playing = true
			music(10)
		end
	else
		music_battle_playing = false
	end

	if current_view == 3 then
		if music_battle_end_playing == false then
			music_battle_end_playing = true
			music(11)
		end
	else
		music_battle_end_playing = false
	end

	if current_view == 1 or current_view == 2 or current_view == 6 then
		create_stars()
		foreach(stars, move_star)
	end

	update_transition_animation()
end

function create_stars()
	interval = rnd({15, 5})
	if clock % interval == 0 then 
		local star = {}
		star.x = rnd({ 12, 24, 48, 56, 72, 82, 96})
		star.y = 12
		star.type = rnd({ "far", "near"})
		add(stars, star)
	end
end

function draw_star(s)
	star_spr = (s.type == "far") and 044 or 042
	if (clock % 1.5 == 0) then
		star_spr = (s.type == "far") and 043 or 041
	end
	spr(star_spr, s.x, s.y)
end

function move_star(s)
	divider = (current_view == 2) and 0.5 or 1 
	s.y += (s.type == "far") and 1.5 * divider or 3 * divider

	if s.y >= 128 then
		del(stars,s)
	end
end

function draw_transition_animation()
	if transition_animation or hold_transition then
		rectfill(0, 0, left_side, 128, 7)
		rectfill(127, 0, right_side, 128, 7)
	end
end

function update_transition_animation()
	if transition_animation then
		if animation_direction == "in" then
			right_side -= 5
			left_side += 5

			if right_side < 64 and left_side > 64 then
				transition_animation = false
				hold_transition = true

				if (battle_started and count(explosions) == 0 and count(enemies) == 0) current_view = 3
				if (player.fuel <= 0 or player.health <= 0) current_view = 5
				if (skip_transition_hold != false) resume_transition()
			end
		else
			right_side += 5
			left_side -= 5

			if right_side > 127 and left_side < 0 then
				transition_animation = false
				hold_transition = false
				animation_direction = "in" 
 
				if (current_view == 3) scraps += battle_rewards current_view = 1 reset()
				if (current_view == 5) _init()
				if (skip_transition_hold != false) current_view = skip_transition_hold skip_transition_hold = false
			end
		end
	end
end

function resume_transition()
	animation_direction = "out"
	transition_animation = true
	hold_transition = false
end

function reset_transition_animation()
	left_side = 0
	right_side = 127
	animation_direction = "in"
	ship_x = 64
end

function draw_missile(m)
	spr(016,m.x,m.y)
end

function move_missile(m)
	target_x = enemies[missile_locked_on_enemy].x
	target_y = enemies[missile_locked_on_enemy].y

	angle = atan2(target_x - m.x, target_y - m.y)
	m.x += cos(angle) * m.v
	m.y += sin(angle) * m.v

	if m.x >= target_x and
	m.x <= target_x+8 and
	m.y >= target_y-2 and
	m.y <= target_y+6 then
		sfx(04)
		e = enemies[missile_locked_on_enemy]
		e.health -= m.damage
		del(missiles, m)
		if e.health <= 0 then
			missile_locked_on_enemy = 1
			destroy_enemy(e)
		end
	end
end

function print_warning(w)
	print(w.msg, w.x, w.y, 7)
end

function move_warning(w)
	if clock % 15 == 0 and w.duration > 0 then
		w.y -= 4
		w.duration -= 1
		if (w.duration == 0) del(warnings, w)
	end
end

function update_icons()
	health_pct = player.health/player.max_health
	health_spr = (health_pct == 1) and 8 or flr(health_pct * 10)

	fuel_pct = player.fuel/player.max_fuel
	fuel_spr = (fuel_pct == 1) and 8 or flr(fuel_pct * 10)

	armor_pct = player.armor/player.max_armor
	armor_spr = (armor_pct == 1) and 8 or flr(armor_pct * 10)
end

function create_warning(msg, e)
	local warning = {}

	warning.x = e.x+10
	warning.y = e.y
	warning.msg = msg
	warning.duration = 6
	add(warnings, warning)
end

function start_battle()
	enemy_type_pool = {}
	enemy_by_difficulty ={ { 1,2 }, { 2, 3 }, { 3, 4 } }

	local pirate_rep = (pirate_rep == 0) and 1 or pirate_rep

	enemy_count = rnd(enemy_by_difficulty[pirate_rep])

	if pirate_rep == 1 then
		add(enemy_type_pool, enemy_list[1])
	elseif pirate_rep == 2 then
		add(enemy_type_pool, enemy_list[2])
		add(enemy_type_pool, enemy_list[3])
	elseif pirate_rep == 3 then
		add(enemy_type_pool, enemy_list[4])
		add(enemy_type_pool, enemy_list[5])
	end

	while(enemy_count > 0)
	do
		enemy_data = rnd(enemy_type_pool)
		proccess_enemy(enemy_data)
		enemy_count -= 1
	end

	if current_quest > 0 then
		if (current_quest == 2 and rnd() > 0.7) proccess_enemy(enemy_list[6])
		if (current_quest == 1 and rnd() > 0.5) for i=0,2 do proccess_enemy(enemy_list[6]) end
	end

	battle_started = true
end

function proccess_enemy(enemy_data)
	local pirate_rep = (pirate_rep == 0) and 1 or pirate_rep
	bounty_chance = { 0.8, 0.7, 0.6 }
	bounty_lvls = { 20, 40, 60 }

	local enemy = {}
	for k, v in pairs(enemy_data) do
		enemy[k] = v
	end

	enemy.id = enemy_data.id
	enemy.health = enemy_data.b_health
	enemy.max_health = enemy_data.b_health
	enemy.energy = enemy_data.b_energy
	enemy.max_energy = enemy_data.b_energy
	enemy.current_speed = 0
	enemy.max_speed = enemy_data.b_speed
	enemy.clock = 0
	enemy.bounty = (rnd() > bounty_chance[pirate_rep]) and flr(rnd(bounty_lvls[pirate_rep]) + (bounty_lvls[pirate_rep] / 2)) or 0
	enemy.x = flr(rnd(48)) + 48
	enemy.y = flr(rnd(24)) + 24
	enemy.angle = 0
	enemy.from_x = 0
	enemy.to_x = 0
	enemy.to_y = 0
	enemy.moving = false
	enemy.stunned = false
	enemy.energy_reboot = 300
	enemy.energy_reboot_counter = 0
	enemy.fire = true
	enemy.collateral = false
	add(enemies, enemy)
end

function animate_explosion(exp)
	if (clock % 2 == 0) exp.stage += 1

	if exp.stage == 4 then
		exp.base_stg4_px1 = flr(rnd(3))+1
		exp.base_stg4_py1 = flr(rnd(3))+1
		exp.base_stg4_px2 = flr(rnd(3))+1
		exp.base_stg4_py2 = flr(rnd(3))+1
		exp.base_stg4_px3 = flr(rnd(3))+1
		exp.base_stg4_py3 = flr(rnd(3))+1
		exp.base_stg4_px4 = flr(rnd(3))+1
		exp.base_stg4_py4 = flr(rnd(3))+1
		exp.base_stg4_px5 = flr(rnd(3))+1
		exp.base_stg4_py5 = flr(rnd(3))+1
		exp.base_stg4_px6 = flr(rnd(3))+1
		exp.base_stg4_py6 = flr(rnd(3))+1
		exp.base_stg4_px7 = flr(rnd(3))+1
		exp.base_stg4_px8 = flr(rnd(3))+1
	end

	if exp.stage == 8 then
		del(explosions, exp)
	end
end

function draw_explosion(exp)
	if exp.stage < 4 then
		if (exp.stage == 2)	exp.spr = 055
		if (exp.stage == 3)	exp.spr = 056
		spr(exp.spr,exp.px,exp.py)	
	elseif exp.stage == 4 then
		exp.spr = 057
		spr(exp.spr,exp.px-exp.base_stg4_px1,exp.py-exp.base_stg4_py1)	
		spr(exp.spr,exp.px-exp.base_stg4_px2,exp.py+exp.base_stg4_py2)	
		spr(exp.spr,exp.px+exp.base_stg4_px3,exp.py-exp.base_stg4_py3)	
		spr(exp.spr,exp.px-exp.base_stg4_px4,exp.py+exp.base_stg4_py4)	
		spr(exp.spr,exp.px+exp.base_stg4_px5,exp.py+exp.base_stg4_py5)	
		spr(exp.spr,exp.px+exp.base_stg4_px6,exp.py+exp.base_stg4_py6)	
		spr(exp.spr,exp.px-exp.base_stg4_px7,exp.py)	
		spr(exp.spr,exp.px+exp.base_stg4_px8,exp.py)
	elseif exp.stage == 5 then
		exp.spr = 058
		spr(exp.spr,exp.px-(exp.base_stg4_px1+2),exp.py-(exp.base_stg4_py1+2))	
		spr(exp.spr,exp.px-(exp.base_stg4_px2+2),exp.py+(exp.base_stg4_py2+2))	
		spr(exp.spr,exp.px+(exp.base_stg4_px3+2),exp.py-(exp.base_stg4_py3+2))	
		spr(exp.spr,exp.px-(exp.base_stg4_px4+2),exp.py+(exp.base_stg4_py4+2))	
		spr(exp.spr,exp.px+(exp.base_stg4_px5+2),exp.py+(exp.base_stg4_py5+2))	
		spr(exp.spr,exp.px+(exp.base_stg4_px6+2),exp.py+(exp.base_stg4_py6+2))	
		spr(exp.spr,exp.px-(exp.base_stg4_px7+2),exp.py)	
		spr(exp.spr,exp.px+(exp.base_stg4_px8+2),exp.py)
	elseif exp.stage == 6 then
		exp.spr = 059
		spr(exp.spr,exp.px-(exp.base_stg4_px1+4),exp.py-(exp.base_stg4_py1+4))	
		spr(exp.spr,exp.px-(exp.base_stg4_px2+4),exp.py+(exp.base_stg4_py2+4))	
		spr(exp.spr,exp.px+(exp.base_stg4_px3+4),exp.py-(exp.base_stg4_py3+4))	
		spr(exp.spr,exp.px-(exp.base_stg4_px4+4),exp.py+(exp.base_stg4_py4+4))	
		spr(exp.spr,exp.px+(exp.base_stg4_px5+4),exp.py+(exp.base_stg4_py5+4))	
		spr(exp.spr,exp.px+(exp.base_stg4_px6+4),exp.py+(exp.base_stg4_py6+4))	
		spr(exp.spr,exp.px-(exp.base_stg4_px7+4),exp.py)	
		spr(exp.spr,exp.px+(exp.base_stg4_px8+4),exp.py)
	elseif exp.stage == 7 then
		exp.spr = 060
		spr(exp.spr,exp.px-(exp.base_stg4_px1+6),exp.py-(exp.base_stg4_py1+6))	
		spr(exp.spr,exp.px-(exp.base_stg4_px2+6),exp.py+(exp.base_stg4_py2+6))	
		spr(exp.spr,exp.px+(exp.base_stg4_px3+6),exp.py-(exp.base_stg4_py3+6))	
		spr(exp.spr,exp.px-(exp.base_stg4_px4+6),exp.py+(exp.base_stg4_py4+6))	
		spr(exp.spr,exp.px+(exp.base_stg4_px5+6),exp.py+(exp.base_stg4_py5+6))	
		spr(exp.spr,exp.px+(exp.base_stg4_px6+6),exp.py+(exp.base_stg4_py6+6))	
		spr(exp.spr,exp.px-(exp.base_stg4_px7+6),exp.py)	
		spr(exp.spr,exp.px+(exp.base_stg4_px8+6),exp.py)
	end
end

function reset()
	enemies = {}
	enemy_bullets = {}
	bullets = {}
	encounters = {}
	explosions = {}
	warnings = {}
	missiles = {}
	missile_locked_on_enemy = 1
	battle_started = false
	battle_rewards = 0
	laser_cooldown = false
	laser_cooldown_counter = 0
	missile_cooldown = false
	missile_cooldown_counter = 0
	stun_cooldown = false
	stun_cooldown_counter = 0
	cluster_cooldown = false
	cluster_cooldown_counter = 0
	current_ammo_mode = 1
end

function draw_ui()
	rectfill(0,0,127,12, 7)

	if current_view == 2 then
		reloading = false
		out_of_ammo = false
		ammo_left = ""

		if current_ammo_mode == 1 then
			if (laser_cooldown) reloading = true
		elseif current_ammo_mode == 2 then
			if (missile_cooldown) reloading = true
			ammo_left = "X" .. player.missile_n
			if (player.missile_n == 0) out_of_ammo = true
		elseif current_ammo_mode == 3 then
			if (cluster_cooldown) reloading = true
			ammo_left = "X" .. player.cluster_n
			if (player.cluster_n == 0) out_of_ammo = true
		elseif current_ammo_mode == 4 then
			if (stun_cooldown) reloading = true
			ammo_left = "X" .. player.stun_n
			if (player.stun_n == 0) out_of_ammo = true
		end

		print(ammo_mode[current_ammo_mode] .. " " .. ammo_left, 1, 1, 0)
		if (reloading and not out_of_ammo) print("rELOADING", 1, 7, 0)
		if (out_of_ammo) print("oUT OF AMMO", 1, 7, 0)

		sspr(32, 0, 7, armor_spr, 103, 2)
		sspr(24, 0, 7, health_spr, 111, 2)
		sspr(40, 0, 7, fuel_spr, 119, 2)
	end

	if current_view != 2 then
		print((current_view == 1) and "travelling" or (pirate_store) and "pirate shop" or "shop", 1, 1, 0)
		print("funds: $" .. scraps .. ((current_view == 1) and (" /" .. " score: " .. score) or ""), 1, 7, 0)
	end
end

function update_threat()
	pirate_refresh_rate = (pirate_rep == 1) and 5 or (pirate_rep == 2) and 2 or 1
	if (clock % pirate_refresh_rate == 0) then
		if move_pirate_sprite == "up" then
			pirate_sprite_y -= 1
			if (pirate_sprite_y == 0) move_pirate_sprite = "down"
		end

		if move_pirate_sprite == "down" then
			pirate_sprite_y += 1
			if (pirate_sprite_y == 4) move_pirate_sprite = "up"
		end
	end
end

function draw_threat()
	rectfill(116,1,126,11, 0)
	pirate_sprite = (pirate_rep == 1) and 014 or (pirate_rep == 2) and 030 or 046
	pirate_mouth = 062

	spr(pirate_sprite, 118, pirate_sprite_y)
	spr(pirate_mouth, 118, 4)
end

function restart_from_gameover()
	if btnp(4) or btnp(5) and not transition_animation then
		resume_transition()
	end
end
-->8
-- encounters

function create_encounter()
	random_factor = rnd()
	quest_random_factor = (current_quest == 0) and 0.75 or 0.95
	type = (random_factor <= 0.6) and 1 or (random_factor <= quest_random_factor) and 2 or 3
	local pirate_shop = (type == 2 and rnd() <= 0.3) and true or false
	if (type == 3 and current_quest == 1) type = 1

	local encounter = {}
	encounter.x = rnd({ 12, 36, 64, 96, 108})
	encounter.y = 12
	encounter.type = type
	encounter.animate = false
	encounter.sprite = encounters_spr[type]
	encounter.pirate_shop = pirate_shop
	encounter.skull_y = encounter.y + 4
	encounter.skull_x = encounter.x - 4
	encounter.move_skull_left = true
	encounter.clock = 0
	encounter.quest_type = rnd({1, 2})
	encounter.escort_destination = (type == 3 and current_quest == 2) and true or false
	add(encounters, encounter)
end

function draw_encounter(e)
	if (e.escort_destination and e.type == 3) pal(5,3) pal(6,11)
	spr(e.sprite,e.x, e.y, 2, 2)
	pal()
	if (e.pirate_shop) spr(045, e.skull_x, e.skull_y)
end

function move_encounter(e)
	e.clock += 1
	e.y += 1

	if e.pirate_shop then
		e.skull_y += 1
		if e.move_skull_left then
			e.skull_x += 1
			if (e.skull_x >= e.x + 8) e.move_skull_left = false
		else
			e.skull_x -= 1
			if (e.skull_x <= e.x - 4) e.move_skull_left = true
		end
	end

	if e.x >= ship_x-8 and
	e.x <= ship_x+10 and
	e.y >= ship_y-8 and
	e.y <= ship_y+10 then
		encounters = {}
		if e.type == 1 then
			skip_transition_hold = 2
			transition_animation = true
		elseif e.type == 2 then
			shop_last_bought = ""
			pirate_store = false
			shop_selector = 1
			shop_items = {}

			skip_transition_hold = 4
			pirate_store = (e.pirate_shop) and true or false
			transition_animation = true
		else
			show_quest_prompt(e.quest_type)
		end
	end

	if e.clock % 45 == 0 then
		e.animate = true
	end

	if e.animate then
		if (e.clock % 1.5 == 0) e.sprite += 2
		if (e.type == 1 and e.sprite > 070) e.animate = false e.sprite = 064
		if (e.type == 2 and e.sprite > 078) e.animate = false e.sprite = 072
		if (e.type == 3 and e.sprite > 103) e.animate = false e.sprite = 096
	end	

	if (e.y >= 128) del(encounters,e)
end

function show_quest_prompt(q_type)
	pause_menu = true
	if current_quest == 2 then
		showing_quest_prompt = "thank you for\nhelping us out!\nhere's a little\nsomething for your\ntroubles"
	else
		current_quest_option = q_type
		current_quest_option = q_type
		pause_menu = true
		current_quest_option = q_type
		pause_menu = true
		showing_quest_prompt = (q_type == 1)
			and "there's a pirate\naround these parts\nthat is causing too\nmuch trouble! he's\nattacking and\npillaging every\nship he sees!\n\ncan you take care\nof this?"
			or "oh hi!\nwe need help getting\nto a planet, but\nit's dangerous to\ngo alone.\n\ncan you escort us\nto our destination?" 
	end
end

function reset_quest_params()
	current_quest = 0
	current_quest_text = "no quest ongoing"
	showing_quest_prompt = false
	current_quest_option = false
	quest_enemy_warned = false
	quest_reward = 0
	hunt_quest_enemies_destroyed = 0
end
-->8
-- player

function fire()
	if btnp(4) then
		if current_ammo_mode == 1 and not laser_cooldown then
			local bullet = {}
			bullet.mode = "laser"
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 001
			bullet.damage = laser_damage
			add(bullets, bullet)
			laser_cooldown = true
		elseif current_ammo_mode == 2 and player.missile_n > 0 and not missile_cooldown then
			local missile = {}
			missile.x = ship_x
			missile.y =ship_y - 8
			missile.v = 3
			missile.damage = missile_damage
			add(missiles, missile)
			missile_cooldown = true
			player.missile_n -= 1
		elseif current_ammo_mode == 3 and player.cluster_n > 0 and not cluster_cooldown then
			local bullet = {}
			bullet.mode = "cluster"
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 032
			bullet.damage = cluster_damage
			bullet.fuse = 15
			bullet.timer = 0
			bullet.frag_n = 3
			add(bullets, bullet)
			cluster_cooldown = true
			player.cluster_n -= 1
		elseif current_ammo_mode == 4 and player.stun_n > 0 and not stun_cooldown then
			local bullet = {}
			bullet.mode = "stun"
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 048
			bullet.damage = stun_damage
			bullet.proximity_damage = stun_proximity_damage
			add(bullets, bullet)
			stun_cooldown = true
			player.stun_n -= 1
		end
	end

	if btnp(5) then
		current_ammo_mode += 1

		if (player.weapon_system_lvl == 1 and current_ammo_mode > 2) current_ammo_mode = 1
		if (player.weapon_system_lvl == 2 and current_ammo_mode > 3) current_ammo_mode = 1
		if (current_ammo_mode > 4) current_ammo_mode = 1
	end

	if laser_cooldown then
		laser_cooldown_counter += 1
		if (laser_cooldown_counter % laser_cooldown_rate == 0) laser_cooldown_counter = 0 laser_cooldown = false
	end

	if missile_cooldown then
		missile_cooldown_counter += 1
		if (missile_cooldown_counter % missile_cooldown_rate == 0) missile_cooldown_counter = 0 missile_cooldown = false -- [detail] removed (and count(enemies) > 0)
	end

	if stun_cooldown then
		stun_cooldown_counter += 1
		if (stun_cooldown_counter % stun_cooldown_rate == 0) stun_cooldown_counter = 0 stun_cooldown = false
	end

	if cluster_cooldown then
		cluster_cooldown_counter += 1
		if (cluster_cooldown_counter % cluster_cooldown_rate == 0) cluster_cooldown_counter = 0 cluster_cooldown = false
	end
end

function draw_bullet(b)
	spr(b.spr,b.x,b.y)

	if b.mode == "stun" then
		for e in all(enemies) do
			if e.x >= b.x-20 and e.x <= b.x+20 and e.y >= b.y-20 and e.y <= b.y+20 then
				line_color = (clock % 2 == 0) and 12 or 7
				line(b.x+4, b.y+4, e.x+4, e.y+4, line_color)
			end
		end
	end
end

function missile_ui()
	last_enemy = count(enemies)

	if btnp(2) then
		missile_locked_on_enemy += 1
		if (missile_locked_on_enemy > last_enemy) missile_locked_on_enemy = 1
	end

	if btnp(3) then
		missile_locked_on_enemy -= 1
		if (missile_locked_on_enemy <= 0) missile_locked_on_enemy = last_enemy
	end
end

function move_bullet(b)
	if b.mode == "cluster" then
		b.timer += 1
		if (b.timer % b.fuse == 0) create_clusters(b)
	end

	if b.mode == "cluster_frag" then
		b.x += (b.angle / 2)
		b.y -= 3
	else
		b.y -= (b.mode == "laser") and 4 or 2
	end

	for e in all(enemies) do
		if b.mode == "stun" and e.energy > 0 then
			if e.x >= b.x-12 and e.x <= b.x+20 and e.y >= b.y-12 and e.y <= b.y+20 then
				e.energy -= b.proximity_damage
				e.stunned = true
			else
				e.stunned = false
			end
		end

		if e.x >= b.x-4 and e.x <= b.x+6 and e.y >= b.y-4 and e.y <= b.y+6 then
			damage = b.damage
			if rnd() > game_random_factor and b.mode == "laser" then
				damage = damage + (flr(rnd(2)) + 1)
				create_warning("critical\ndamage!", e)
			end

			if b.mode == "stun" and e.energy > 0 then
				e.energy -= damage
				e.stunned = false

				if (e.energy <= 0) create_warning("knocked out!", e)
			else 
				e.health -= damage

				if e.health <= 0 then
					destroy_enemy(e)
				else
					if e.collateral == false and b.mode == "laser"then
						for el in all(enemy_list) do
							if e.spr == el.spr_ok then
								local_random_factor = game_random_factor - (el.knowledge_level/10)
								if rnd() > local_random_factor then
									e.collateral = rnd(collateral_type)
									msg = ''
									if (e.collateral == 1) msg = "engine\ndamage!" 
									if (e.collateral == 2) msg = "aiming\ndamage!"
									if (e.collateral == 3) msg = "firing\ndamage!"
									create_warning(msg, e)
								end
							end
						end
					end
				end
			end
			sfx(04)
			del(bullets,b)
		end
	end
end

function create_clusters(b)
	pos_y = {-1, 0, 1}
	for i=1,b.frag_n do
		local bullet = {}
		bullet.mode = "cluster_frag"
		bullet.x = b.x + (8 * pos_y[i])
		bullet.y = b.y
		bullet.spr = 000
		bullet.damage = cluster_frag_damage
		bullet.angle = pos_y[i]
		add(bullets, bullet)
	end
	del(bullets,b)
end

function create_explosion(ex,ey)
	local explosion = {}
	explosion.spr = 054
	explosion.px = ex
	explosion.py = ey
	explosion.stage = 1
	explosion.base_stg4_px1 = 0
	explosion.base_stg4_py1 = 0
	explosion.base_stg4_px2 = 0
	explosion.base_stg4_py2 = 0
	explosion.base_stg4_px3 = 0
	explosion.base_stg4_py3 = 0
	explosion.base_stg4_px4 = 0
	explosion.base_stg4_py4 = 0
	explosion.base_stg4_px5 = 0
	explosion.base_stg4_py5 = 0
	explosion.base_stg4_px6 = 0
	explosion.base_stg4_py6 = 0
	explosion.base_stg4_px7 = 0
	explosion.base_stg4_px8 = 0

	sfx(07)
	add(explosions, explosion)
end

function move()
	if not pause_menu then -- [code improv] free movement only on free mode or on battle after battle started (enemy creation)
		if (btn(1) and ship_x < 120) ship_x+=2
		if (btn(0) and ship_x > 0) ship_x-=2
	end
end

function start()
	if btnp(4) then
		sfx(01)
		current_view = 1
	end

	if btnp(5) then
		sfx(01)
		current_view = 7
	end
end
-->8
-- enemies

function create_enemy_bullet(e)
	if e.fire == true and e.collateral != 3 then
		e.fire = false
		local enemy_bullet = {}
		enemy_bullet.x = e.x
		enemy_bullet.y = e.y+8
		enemy_bullet.angle = atan2(ship_x - e.x, ship_y - e.y)
		enemy_bullet.damage = e.b_damage
		enemy_bullet.v = e.b_shot_speed
		enemy_bullet.aimless = (e.collateral == 2) and true or false
		sfx(08)
		add(enemy_bullets,enemy_bullet)
	else
		if (e.clock % e.b_cdr == 0) e.fire = true
	end
end

function move_enemy_bullet(eb)
	eb.x += (eb.aimless == false) and cos(eb.angle) * eb.v or 0
	eb.y += (eb.aimless == false) and sin(eb.angle) * eb.v or eb.v

	if eb.x >= ship_x-4 and
	eb.x <= ship_x+6 and
	eb.y >= ship_y-4 and
	eb.y <= ship_y+6 then
		del(enemy_bullets,eb)
		sfx(06)

		if (player.armor == 0) player.health-=eb.damage
		if player.armor > 0 then 
			player.armor-=eb.damage
			if (player.armor < 0) player.armor = 0
		end
		if (player.health <= 0) transition_animation = true
	end
end

function move_enemy(e)
	if e.energy <= 0 then
		e.energy_reboot_counter += 1
		if (e.energy_reboot_counter % e.energy_reboot == 0) e.energy_reboot_counter = 0 e.energy = e.max_energy create_warning("back online!", e)
	else
		e.clock += 1
		e.max_speed = (e.stunned) and 0.15 or e.b_speed

		if e.collateral != 1 then
			if e.moving == false then
				e.moving = true
				rnd_pos = rnd(positions)
				e.from_x = e.x
				e.to_x = rnd_pos[1]
				e.to_y = rnd_pos[2]
				e.angle = atan2(e.to_x - e.x, e.to_y - e.y)
				e.current_speed = 0
			else
				if (e.current_speed < e.max_speed) e.current_speed += 0.05
				e.x += cos(e.angle) * e.current_speed
				e.y += sin(e.angle) * e.current_speed
				if e.from_x < e.x then
					if e.x > e.to_x then
						e.moving = false
					end
				end
				if e.from_x > e.x then
					if e.x < e.to_x then
						e.moving = false
					end
				end
				if e.y <= 0 or e.y >= 100 or
				 e.x <= 0 or e.x >= 128 then
					e.moving = false
				end
			end
		end
	end
end

function draw_enemy(e)
	enemy_sprite = (e.energy > 0) and e.spr or e.spr + 16
	spr(enemy_sprite,e.x,e.y)

	percentage = e.health/e.max_health
	color = (percentage == 1) and 11 or (percentage < 1 and percentage >= 0.5) and 10 or 8
	length = (percentage == 1) and 6 or (percentage < 1 and percentage >= 0.5) and 4 or (percentage < 0.5 and percentage > 0) and 2 or 0
	line(e.x + 1, e.y - 3, e.x + length, e.y - 3, color)

	energy_percentage = e.energy/e.max_energy
	energy_length = (energy_percentage == 1) and 6 or (energy_percentage < 1 and energy_percentage >= 0.5) and 4 or (energy_percentage < 0.5 and energy_percentage > 0) and 2 or 0
	if (e.energy > 0) line(e.x + 1, e.y - 5, e.x + energy_length, e.y - 5, 12)
	if (current_ammo_mode == 2) rect(enemies[missile_locked_on_enemy].x - 2, enemies[missile_locked_on_enemy].y - 2, enemies[missile_locked_on_enemy].x + 9, enemies[missile_locked_on_enemy].y + 9,8)
	if (e.spr == 061 and not quest_enemy_warned) quest_enemy_warned = true create_warning("quest\nenemy", e)
end

function draw_enemy_bullet(eb)
	spr(001,eb.x,eb.y)
end

function destroy_enemy(e)
	enemy_list[e.id].n_destroyed += 1
	if (enemy_list[e.id].n_destroyed % 5 == 0 and enemy_list[e.id].knowledge_level < 3) enemy_list[e.id].knowledge_level += 1

	total_enemies_destroyed += 1
	if (pirate_rep < 3 and total_enemies_destroyed % 10 == 0) pirate_rep += 1

	score += e.score
	battle_rewards += e.reward + e.bounty
	create_explosion(e.x,e.y)
	if (e.spr == 061 and current_quest == 1) create_warning("quest\nenemy\ndestroyed", e) hunt_quest_enemies_destroyed += 1
	if (hunt_quest_enemies_destroyed == 3) quest_reward = 270 battle_rewards += quest_reward reset_quest_params() quest_ended_message = "hunt quest complete!"
	sfx(05)
	del(enemies,e)
end
-->8
-- shop

function nav_store()
	if count(shop_items) == 0 then
		for item in all (all_shop_items) do
			if pirate_store == false then
				if (item.shops == "pirate") goto skip_to_next
			else
				if (item.shops == "civ") goto skip_to_next
			end

			local item_copy = {}
			for k, v in pairs(item) do
				item_copy[k] = v
			end
			if (item_copy.name == "pirate_bribe" and pirate_rep == 0) item_copy.enabled = false
			if ((item_copy.compare_with != nil) and player[item_copy.name] == player[item_copy.compare_with]) item_copy.enabled = false
			if ((item_copy.name == "cluster_n" or item_copy.name == "cluster_lvl") and player.weapon_system_lvl < 2) item_copy.enabled = false
			if ((item_copy.name == "stun_n" or item_copy.name == "stun_lvl") and player.weapon_system_lvl < 3) item_copy.enabled = false
			if (item_copy.shops == "civ") item_copy.price *= player[item_copy.name]
			add(shop_items, item_copy)

			::skip_to_next::
		end
	end

	current_shop_item = shop_items[shop_selector]

	if btnp(4) then
		price = (pirate_store == false) and current_shop_item.price or (current_shop_item.name == "pirate_bribe") and current_shop_item.price or ceil(current_shop_item.price/2)
		if scraps >= price then
			if current_shop_item.name == "pirate_bribe" then
				if pirate_rep > 0 then
					scraps -= price
					pirate_rep -= 1
					current_shop_item.price = pirate_rep * 75
					shop_last_bought = "pirate rep downgraded"
					if (pirate_rep == 0) current_shop_item.enabled = false
				else
					shop_last_bought = "already at minimum pirate rep"
				end
			elseif not current_shop_item.enabled then
				shop_last_bought = current_shop_item.formatted_name .. " unavailable"
				if (player[current_shop_item.name] == player[current_shop_item.compare_with]) shop_last_bought = current_shop_item.formatted_name .. " maxed out"
			elseif player[current_shop_item.name] < player[current_shop_item.compare_with] and current_shop_item.enabled then
				player[current_shop_item.name] = flr(player[current_shop_item.name])
				player[current_shop_item.name] += 1
				shop_last_bought = "bought " .. current_shop_item.formatted_name
				scraps -= price
				if current_shop_item.name == "armor_lvl" then
					player.max_armor = stat_lvl[player.armor_lvl]
				elseif current_shop_item.name == "health_lvl" then
					player.max_health = stat_lvl[player.health_lvl]
				elseif current_shop_item.name == "laser_lvl" then
					laser_damage = laser_damage_lvls[player.laser_lvl]
					laser_cooldown_rate = laser_cooldown_lvls[player.laser_lvl]
				elseif current_shop_item.name == "missile_lvl" then
					missile_damage = missile_damage_lvls[player.missile_lvl]
					missile_cooldown_rate = missile_cooldown_lvls[player.missile_lvl]
					player.missile_max_capacity = special_ammo_lvls[player.missile_lvl]
				elseif current_shop_item.name == "cluster_lvl" then
					cluster_damage = cluster_damage_lvls[player.cluster_lvl]
					cluster_frag_damage = cluster_frag_damage_lvls[player.cluster_lvl]
					cluster_cooldown_rate = cluster_cooldown_lvls[player.cluster_lvl]
					player.cluster_max_capacity = special_ammo_lvls[player.cluster_lvl]
				elseif current_shop_item.name == "stun_lvl" then
					stun_damage = stun_damage_lvls[player.stun_lvl]
					stun_proximity_damage = stun_proximity_damage_lvs[player.stun_lvl]
					stun_cooldown_rate = stun_cooldown_lvls[player.stun_lvl]
					player.stun_max_capacity = special_ammo_lvls[player.stun_lvl]
				elseif current_shop_item.name == "weapon_system_lvl" then
					-- this is for enabling the new weapon system and ammo as you upgrade the weapon system
					if player.weapon_system_lvl > 1 then
						for item in all(shop_items) do
							if (item.name == "cluster_n" or item.name == "cluster_lvl") and player.weapon_system_lvl == 2 then
								item.enabled = true
							end
							if (item.name == "stun_n" or item.name == "stun_lvl") and player.weapon_system_lvl == 3 then
								item.enabled = true
							end
						end
					end
				end

				-- this is for enabling the consumables once its related "parent" shop items are purchased
				if current_shop_item.relates_to != nil then
					for item in all(shop_items) do
						if item.name == current_shop_item.relates_to then
							item.enabled = true
						end
					end
				end

				if (player[current_shop_item.name] == player[current_shop_item.compare_with]) current_shop_item.enabled = false

				-- updating the price of upgrades
				if current_shop_item.shops == "civ" then
					current_shop_item.price = player[current_shop_item.name] * price
				end
			else
				current_shop_item.enabled = false
			end
		else
			shop_last_bought = "not enough credits"
		end
	end
 
	n_shop_items = count(shop_items)
	if btnp(3) then
		sfx(02)
		if (shop_selector < n_shop_items) shop_selector += 1
	end
	
	if btnp(2) then
		sfx(02)
		if (shop_selector > 1) shop_selector -= 1
	end

	if btnp(5) then
		sfx(00)
		skip_transition_hold = 1
		transition_animation = true
	end
end

function animate_shop_selector()
	if (clock % 5 == 0) shop_selector_spr += 16
	if (shop_selector_spr > 034) shop_selector_spr = 002
	spr(shop_selector_spr, 4, (shop_selector_y - 7) + shop_selector * 6)
end
__gfx__
0000000000000000000000000e80880011111dd03303330000333300003333000033330000777700000770000777777077777777700770070666660000888000
000000000000000099999900efe8ee801cccc6d0003bbb300b7bbb300b7bbb300b7bbb300722227007722770722222277222222777722777666666600e7e8800
00060000000aa0009aaaaa908eeeee801ccccc1003bbbb3037bbbbb337bbbbb337b77bb378777787787227877227722772777727787227876066606087e88880
0067600000a7aa0009aaaaa98eeeee801ccccc103b5b5b303bbbbbb33bb77bb33b7bb7b37888888778877887787887870788887078722787600600608e888e80
00d6d00000aaaa0009aaaaa958eee85051ccc1503bb5bb303bbbbbb33bb77bb33b7bb7b3787887877e8888e7787ee7870787787077877877666066608888e780
000d0000009aa9009aaaaa90058e8500051c15003b5b5b303bbbbbb33bbbbbb33bb77bb307e77e7007e88e707e7777e7007ee700707ee70706666600888e7e80
00000000000990009999990000585000005150005333335003bbbb3003bbbb3003bbbb307e7007e707e77e7007700770007ee700007ee70006d6d6006ddddd50
00000000000000000000000000050000000500000555550000333300003333000033330007000070007007000700007000077000000770000000000055555550
00000000007007000000000000000000000000000000000000999900009999000099990000777700000770000777777077777777700770070666660000888000
0000000077000077000000000000000000000000000000000a7aaa900a7aaa900a7aaa90070000700770077070000007700000077770077766666660088e7e00
0008800075700757999999908eeeee801ccccc1003bbbb3097aaaaa997aaaaa997a77aa97077770770700707700770077077770770700707606660608888e780
008788007557755709aaaaa98eeeee801ccccc103b5b5b309aaaaaa99aa77aa99a7aa7a97000000770077007707007070700007070700707608680608e888e80
008888007571175709aaaaa958eee85051ccc1503bb5bb309aaaaaa99aa77aa99a7aa7a970700707700000077070070707077070770770776660666087e88880
002882007577775799999990058e8500051c15003b5b5b309aaaaaa99aaaaaa99aa77aa90707707007000070707777070070070070700707066666008e7e8880
00022000776666770000000000585000005150005333335009aaaa9009aaaa9009aaaa90707007070707707007700770007007000070070006d6d6006ddddd50
00000000077777700000000000050000000500000555550000999900009999000099990007000070007007000700007000077000000770000000000055555550
00000000000000000000000000000000000000000000000000222200002222000022220000050000000d00000000000000000000066666000666660000888000
00000000880000880000000000000000000000000000000008e8882008e8882008e88820000d00000006000000050000000d0000666666606666666008888800
000dd00080800808000000000000000000000000000000002e8888822e8888822e8ee8820006000000070000000d000000060000676667606866686088888880
00d7dd00800880080999999900000000000000000000000028888882288ee88228e88e825d666d50d67776d005d6d5000d676d00678687606886886088888880
00dddd00800880080999999908eee80001ccc1003bb5bb3028888882288ee88228e88e820006000000070000000d000000060000666766606660666088888880
005dd5008080080800000000058e8500051c15003b5b5b302888888228888882288ee882000d00000006000000050000000d0000066666000666660088888880
00055000800000080000000000585000005150005333335002888820028888200288882000050000000d0000000000000000000006d6d60006d6d6006ddddd50
00000000088888800000000000050000000500000555550000222200002222000022220000000000000000000000000000000000000000000000000055555550
00000000000000000000000000000000000000000000000000000000000000000099990000999900009099000090990000900900078778700000000000000000
000000000000000000000000000000000000000000000000000000000099990009aaaa900999aa900999aa900999aa90090900907ee88ee70000000000000000
000cc00000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa99a999a999a999a099099000090977e77e770000000000000000
00c7cc00000000000000000000000000000000000000000000999900099aa9909aaaaaa999aaaaa9999a99a99900900990000009007ee7000000000000000000
00cccc00000000000000000000000000000000000000000000999900099aa9909aaaaaa999a999a9099999000909900000000000787887870000000000000000
001cc10000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa9aa9900909999009009990000099077887700000000000000000
000110000000000000000000000800000001000003333300000000000099990009aaaa9009999a90099909900990009009000090070ee0700000000000000000
00000000000000000000000000050000000500000555550000000000000000000099990000999900000909000009090000090900070000700d6d6d0000000000
00000000000000000000000000000000000000000000000000000000000000000000000330000000000000033000000000000003300000000000000770000000
00000000000000000000000000000000000000000000000000000000000000000000000330000000000000033000000000000003300000000000000770000000
00600000000006000060000000000600006000000000070000700000000006000000033333333000000003333333300000000333377770000000077773333000
006600000000660000660000000066000066000000007700007700000000660000003bbbbbbb300000003bbbbbbb300000003bbb7777700000007777bbbb3000
00066000000660000006600000066000000660000007700000077000000660000003bbbbbbbb30000003bbbbbbbb30000003bbb7777770000007777bbbbb3000
00006600006600000000660000660000000066000077000000007700006600000003bbbbbbbb30000003bbbbbbbb30000003bb7777777000000777bbbbbb3000
00000660066000000000066006600000000006700770000000000760066000000003bbb3333330000003bbb3333330000003b7777777700000077bb333333000
00000066660000000000006666000000000000777700000000000066660000000003bbbbbbbb30000003bbbbbbbb300000037777777770000007bbbbbbbb3000
00000006600000000000000660000000000000077000000000000006600000000003bbbbbbbb30000003bbbbbbbb700000077777777730000003bbbbbbbb3000
0000006666000000000000666600000000000077770000000000006666000000000333333bbb3000000333333bb7700000077777777b3000000333333bbb3000
00050660066050000005066006707000000707700760500000050660066050000003bbbbbbbb30000003bbbbbb7770000007777777bb30000003bbbbbbbb3000
0000d600006d00000000d6000077000000007700006d00000000d600006d00000003bbbbbbbb30000003bbbbb7777000000777777bbb30000003bbbbbbbb3000
000d50000005d000000d500000077000000770000005d000000d50000005d0000003bbbbbbb300000003bbbb7777000000077777bbb300000003bbbbbbb30000
00d5050000505d0000d50500007077000077070000505d0000d5050000505d000003333333300000000333377770000000077773333000000003333333300000
00500000000005000050000000000700007000000000050000500000000005000000000330000000000000077000000000000003300000000000000330000000
00000000000000000000000000000000000000000000000000000000000000000000000330000000000000077000000000000003300000000000000330000000
00000555555000000000055555500000000005557770000000000777555000000000000000000000000000000000000000000000000000000000000000000000
00055666666550000005566666655000000556677777700000077776666550000000000000000000000000000000000000000000000000000000000000000000
00566666666675000056666666667500005666777777750000777766666675000000000000000000000000000000000000000000000000000000000000000000
05666500005667500566650000566750056665000077775007777500005667500000000000000000000000000000000000000000000000000000000000000000
05675000000567500567500000056750056750000007775007775000000567500000000000000000000000000000000000000000000000000000000000000000
05775000000566500577500000056670057750000007775007775000000566500000000000000000000000000000000000000000000000000000000000000000
00550000005665000055000000566700005500000077750000550000005665000000000000000000000000000000000000000000000000000000000000000000
00000000056650000000000005667000000000000777500000000000056650000000000000000000000000000000000000000000000000000000000000000000
00000000566500000000000056670000000000007775000000000000566500000000000000000000000000000000000000000000000000000000000000000000
00000005665000000000000566700000000000077750000000000005665000000000000000000000000000000000000000000000000000000000000000000000
00000056650000000000005667000000000000777500000000000056650000000000000000000000000000000000000000000000000000000000000000000000
00000057650000000000005777000000000000776500000000000057650000000000000000000000000000000000000000000000000000000000000000000000
00000005500000000000000770000000000000055000000000000005500000000000000000000000000000000000000000000000000000000000000000000000
00000056650000000000007777000000000000566500000000000056650000000000000000000000000000000000000000000000000000000000000000000000
00000057650000000000007777000000000000576500000000000057650000000000000000000000000000000000000000000000000000000000000000000000
00000005500000000000000770000000000000055000000000000005500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006dddd60006666660006600006666000066006600060006666660000000000000000000000000000000000000000000000000000000000000000000000000
0006dddddd606dddddd606dd6006dddd6006dd66dd606d606dddddd6000000000000000000000000000000000000000000000000000000000000000000000000
0006dd6ddd606dd6ddd60066006dddddd606dd66dd606d606dddddd6000000000000000000000000000000000000000000000000000000000000000000000000
00067766776067776776000000677677760677767760676067766666000000000000000000000000000000000000000000000000000000000000000000000000
00062266226062222226006600622662260622222260060062222226000000000000000000000000000000000000000000000000000000000000000000000000
00062226226062262260062260622262260622622260000066666226000000000000000000000000000000000000000000000000000000000000000000000000
00062222226062266226062260622222260622662260000062222226000000000000000000000000000000000000000000000000000000000000000000000000
00006222260062260626062260062222600622662260000062222226000000000000000000000000000000000000000000000000000000000000000000000000
00000666600006600060006600006666000066006600000006666660000000000000000000000000000000000000000000000000000000000000000000000000
00000000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006ddddd6000666600066660006666000660066000666600006666000666666000000000000000000000000000000000000000000000000000000000000
00000006dddddd606dddd606dddd606dddd606dd66dd606dddd6006dddd606dddddd600000000000000000000000000000000000000000000000000000000000
00000006dd6ddd606dd66606dd66606dd66606dd66dd606ddddd606dd66606dd6ddd600000000000000000000000000000000000000000000000000000000000
00000006776677606776000677600067760006777677606776776067760006777677600000000000000000000000000000000000000000000000000000000000
00000006226622606222600622260062226006222222606226226062226006222222600000000000000000000000000000000000000000000000000000000000
00000006222622606226000622600062260006226222606226226062260006226226000000000000000000000000000000000000000000000000000000000000
00000006222222606226660622600062266606226622606222226062266606226622600000000000000000000000000000000000000000000000000000000000
00000006222226006222260622600062222606226622606222260062222606226062600000000000000000000000000000000000000000000000000000000000
00000000666660000666600066000006666000660066000666600006666000660006000000000000000000000000000000000000000000000000000000000000
__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70777077007770000000000000000000000000000000000000000000000000000000000000000e800880000000000011111d000000000000b333300000000007
7077000700707000000000000000000000000000000000000000000000000000000000000000efe88ee80000000001ccccc6d0000000000b7bbbb30000000007
70077007007070000000000000000000000000000000000000000000000000000000000000008eeeeee80777000001cccccc1077700000b7bbbbb30777077707
70777007007070000000000000000000000000000000000000000000000000000000000000008eeeeee80700000001cccccc10700000003b5bb5b30007000707
70070077707770000000000000000000000000000000000000000000000000000000000000008eeeeee807770000001cccc100777000003bb55bb30777007707
700000000000000000000000000000000000000000000000000000000000000000000000000008eeee8000070000001cccc100007000003b5bb5b30700000707
7000070000000077700000000000000000000000000000000000000000000000000000000000008ee800077700000001cc1000777000003bbbbbb30777077707
70007770000000707000000000000000000000000000000000000000000000000000000000000008800000000000000011000000000000033333300000000007
70777777700000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70077777000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70070007000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000077777700aaa000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000070000007000a000000000000000000000000000000000000000000000000000000000000000000000000007
700000000000000000000000000000000000000007070070700aa000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000070077007000a000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000700770070aaa000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000707007070000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000770000770000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000fa00000000000000000000000000000000000000000000000000000000000000000007
700000000000000000000000000000000000000000000000000000000f7aa0000000000000000000000000000000000000000000000000000000000000000007
700000000000000000000000000000000000000000000000000000000aaaa0000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70700000070000000000000000000000000000000000000000000000000000000000000000000000770000770000000000000000000000000000000000000007
70707007070770000000000000000000000000000000000000000000000000000000000000000000707007070000000000000000000000000000000000000007
70700770070070000000000000000000000000000000000000000000000000000000000000000000700770070000000000000000000000000000000000000007
70700770070070000000000000000000000000000000000000000000000000000000000000000000700770070b00000000000000000000000000000000000007
70707007070070000000000000000000000000000000000000000000000000000000000000000000707007070b00000000000000000000000000000000000007
70770000770777000000000000000000000000000000000000000000000000000000000000000000700000070b00000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000077777700b00000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777

__sfx__
000100000000000000040000100000000230000000016000160003000029000060003007008000050002c070090000a0001100015000000001b0001e0002200031000280002a0002d00032000370003d00017000
0001000000000000000000000000000000000000000000000000000000000002a070000002e000300700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000350003a000120501405016050190501b0501e050200502305026070280702b0702f0502c0002f00000000320003700037000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000300502f050323502c3502c0502a050321502e1702b15022050292502525022250202502415022150211501805016050150500000000000000000000000000000000000000000
00020000000000000004500045002e6002e6002e6002c6702b670296702e60025670246702e6002e600206702e6001d6701a670196701667014670116700e6700d67005500006000060000600000000160001600
00030000086701d6701d6701d6701d6701d670146701d6701d6700f6701d6700c6701d6701d6701d67027500285002a5002c5002d5002e500315003150033500355003e6003e6003e6003e6003e6003e6003e600
0001000000000000000000000000000701a1701b1701c1701e17020170201702217024170261702717027170281702b1702d1702f100311003310036100361000000000000000000000000000000000000000000
01010000000000000000000000002f1502c150291502715026150251501b1501a1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000207500075020750007502075000750207500075020750c075020750c075020750c075020750c0750207500075020750007502075000750207500075020750c075020750c075020750c075020750c075
001400202b054290542b054270542b05427054220541f0541d0511d0521b0511b0521b0511b0521f05122052220541f0541d0541b0541b0541d0542205424054240542705424054220541f0541f0542205422054
1c1100000605204052060520405206052040520605204052080520505208052050520805205052080520505206052040520605204052060520405206052040520805205052080520505208052050520805205052
21110000290322903229032290322903229032290322903229032290322903229032290322903229032290322b0322b0322b0322b0322b0322b0322b0322b0322b0322b0322b0322b0322b0322b0322b0322b032
510d000013152131521315213152131521315217152181521a1521a1521a1521a1521a1521a15217152181521a1521a1521a1521a152131521315213152131521f1521f1521f1521f1521f1521f1521f1521f152
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 494a4344
03 0b0c4344
00 0d424344

