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
	pirate_rep = 1
	clock = 0
	current_view = 6
	show_stats = false
	stats_page = 1
	help_text_y = 0
	stars = {}

	-- player variables
	cooldown_lvls = {75, 45, 15}
	scraps = 30
	ship_spr = 017
	ship_x = 64
	ship_y = 118
	fuel = 15
	health_spr = 003
	armor_spr =  004
	fuel_spr = 005
	max_fuel = 15
	fuel_comsumption = 0.0075
	stat_multiplier = 5
	stat_lvl = {1,2,3}
	current_stat_armor_lvl = 1
	current_stat_health_lvl = 1
	current_stat_gun_lvl = 1
	current_stat_cooldown_lvl = 2
	current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier 
	current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
	current_weapon_system_level = 1 -- [wip] shopify ammo system upgrade
	health = current_max_health
	armor = current_max_armor
	bullet_damage = current_stat_gun_lvl
	bullet_cooldown = false -- [wip] rename bullet_cooldown to laser_cooldown
	bullet_cooldown_counter = 0
	bullet_cooldown_rate = cooldown_lvls[current_stat_cooldown_lvl]
	bullets = {}
	current_ammo_mode = 1
	ammo_mode = {
		"laser", -- 1
		"missile", -- 2
		"cluster", -- 3
		"stun" -- 4
	}
	missile_damage = 3
	missile_cooldown = false
	missile_cooldown_counter = 0
	missile_n = 2
	missile_max_capacity = 6 -- [wip] base missile capacity 4, make it an upgradable system
	current_enemy_locked_on = null
	stun_cooldown = false
	stun_cooldown_counter = 0
	stun_n = 4
	stun_max_capacity = 6
	cluster_cooldown = false
	cluster_cooldown_counter = 0
	cluster_n = 3
	cluster_max_capacity  = 4
	random_factor = 0.95
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
	current_shop_item = null
	shop_last_bought = ""
	shop_items = {}
	all_shop_items = {
		{
			["name"] = "fuel",
			["formatted_name"] = "fuel",
			["price"] = 3,
			["shops"] = "both"
		},
		{
			["name"] = "health",
			["price"] = 4,
			["formatted_name"] = "health",
			["shops"] = "both"
		},
		{
			["name"] = "armor",
			["price"] = 4,
			["formatted_name"] = "armor",
			["shops"] = "both"
		},
		{
			["name"] = "missile",
			["price"] = 7,
			["formatted_name"] = "missile",
			["shops"] = "both"
		},
		{
			["name"] = "stun_ammo",
			["price"] = 4,
			["formatted_name"] = "stun ammo",
			["shops"] = "both"
		},
		{
			["name"] = "health_upgrade",
			["price"] = 50 * current_stat_health_lvl,
			["formatted_name"] = "health upgrade",
			["shops"] = "civ"
		},
		{
			["name"] = "armor_upgrade",
			["price"] = 75 * current_stat_armor_lvl,
			["formatted_name"] = "armor upgrade",
			["shops"] = "civ"
		},
		{
			["name"] = "gun_damage_upgrade",
			["price"] = 100 * current_stat_gun_lvl,
			["formatted_name"] = "gun damage upgrade",
			["shops"] = "civ"
		},
		{
			["name"] = "gun_cooldown_upgrade",
			["price"] = 100 * current_stat_gun_lvl,
			["formatted_name"] = "gun cooldown upgrade",
			["shops"] = "civ"
		},
		{
			["name"] = "pirate_bribe",
			["price"] = 50 * pirate_rep,
			["formatted_name"] = "pirate bribe faction",
			["shops"] = "pirate"
		},
	}

	-- enemy and battle
	enemy_list = 
	{
		{
			["name"] = "ant",
			["spr_ok"] = 009,
			["spr_damage"] = 025,
			["b_health"] = 2,
			["b_energy"] = 4,
			["b_damage"] = 1,
			["b_shot_speed"] = 1.5,
			["b_speed"] =  0.75,
			["b_cdr"] = 90,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 100,
			["reward"] = 8
		},
		{
			["name"] = "ghost",
			["spr_ok"] = 010,
			["spr_damage"] = 026,
			["b_health"] = 3,
			["b_energy"] = 4,
			["b_damage"] = 2,
			["b_shot_speed"] = 1.0,
			["b_speed"] =  1,
			["b_cdr"] = 75,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 125,
			["reward"] = 12
		},
		{
			["name"] = "eagle",
			["spr_ok"] = 011,
			["spr_damage"] = 027,
			["b_health"] = 5,
			["b_energy"] = 4,
			["b_damage"] = 1,
			["b_shot_speed"] = 1.5,
			["b_speed"] =  1.7,
			["b_cdr"] = 60,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 150,
			["reward"] = 14
		},
		{
			["name"] = "spectre",
			["spr_ok"] = 012,
			["spr_damage"] = 028,
			["b_health"] = 4,
			["b_energy"] = 6,
			["b_damage"] = 2,
			["b_shot_speed"] = 1.3,
			["b_speed"] =  1.5,
			["b_cdr"] = 45,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 175,
			["reward"] = 16
		},
		{
			["name"] = "sentinel",
			["spr_ok"] = 013,
			["spr_damage"] = 029,
			["b_health"] = 5,
			["b_energy"] = 7,
			["b_damage"] = 3,
			["b_shot_speed"] = 1.7,
			["b_speed"] =  1.7,
			["b_cdr"] = 45,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 250,
			["reward"] = 20
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
	left_side = 0
	right_side = 127
	animation_direction = "in"

	enemy_by_difficulty ={
		{1,2},
		{3,4},
		{5,6}
	}

	-- music variables
	can_leave_screen = false
	music_view_1_playing = false
	music_batttle_player = false
	music_battle_end_playing = false

	
	siren_spr = 015
end

function _draw()
	cls()

	-- spr(siren_spr,64,72)
	-- rect(0,0,127,127, 7)
	if (current_view == 1 or current_view == 2 or current_view == 4) draw_ui()
	if (current_view == 1 or current_view == 2 or current_view == 6) foreach(stars, draw_star)

	if current_view == 1 then -- world
		draw_threat()
		spr(ship_spr,ship_x,ship_y)
		foreach(encounters, draw_encounter)

		if show_stats then
			rect(24,24,104,104, 7)
			palt(0, false) rectfill(25,25,103,103, 0) palt(0, true)

			linect = 0
			for e in all(enemy_list) do
				spr(e.spr_ok, 28, 38 + linect * 10)
				print(e.name, 40, 40 + linect * 10, 7)
				print(e.n_destroyed, 98, 40 + linect * 10, 7)
				linect+=1
			end

			if stats_page == 1 then
				print("confirmed kills", 35, 26, 7)
				print("total: ", 28, 96, 7)
				print(total_enemies_destroyed, 98, 96, 7)
			elseif stats_page == 2 then
				print("proficiency", 43, 26, 7)
			end
		end
	end

	if current_view == 2 then -- battle
		spr(ship_spr,ship_x,ship_y)
		print(ship_x, ship_x + 8, ship_y, 7)

		foreach(enemies, draw_enemy)
		foreach(enemy_bullets, draw_enemy_bullet)
		foreach(bullets, draw_bullet)
		foreach(missiles, draw_missile)
		foreach(explosions, draw_explosion)
		foreach(warnings, print_warning)
		if (count(warnings) == 0) foreach(enemies, create_enemy_bullet)
		if (transition_animation) draw_transition_animation()
	end

	if current_view == 3 then -- rewards
		draw_transition_animation()
		print("victory!", 48,64, 7)
		print("found " .. battle_rewards .. " scraps", 35,72, 7)
		if (stat(54) == 0) print("press z or x to continue", 18, 104, 0)
	end

	if current_view == 4 then -- shop
		current_shop_item = shop_items[shop_selector]

		i = 0
		for item in all (shop_items) do 
			price = (pirate_store == false) and item.price or (item.name == "pirate_bribe") and item.price or ceil(item.price/2)
			print(item.formatted_name, 14, 16 + i * 8, 7)
			print("$", 100, 16 + i * 8, 3)
			print(price, 104, 16 + i * 8, 7)
			i += 1
		end

		if (clock % 90 == 0) shop_last_bought = ""
		print(shop_last_bought, 1, 7, 0)
		print("⬆️⬇️ [select]", 2, 104, 7)
		print("z/🅾️ [buy]", 2,112, 7)
		print("x/❎ [leave]", 2, 120, 7)

		animate_shop_selector()
	end

	if current_view == 5 then -- gameover
		print("game over",44,64)
		if (health <= 0) print("you were destroyed",24,72)
		if (fuel <= 0) print("you ran out of fuel",23,72)
		print("press any key", 18, 104)
	end

	if current_view == 6 then -- start
		spr(128,24,44,9,3)
		print("z/🅾️ to start", 40, 84,7)
		print("x/❎ to help", 42, 92,7)
	end

	if current_view == 7 then -- help
		spr(017, 2, 16 + help_text_y)
		print("this is you! move sideways to\navoid getting shot", 11, 14 + help_text_y, 7)

		spr(001, 2, 32 + help_text_y)
		spr(016, 2, 49 + help_text_y)
		print("when in battle, press x/❎ to\nswitch between main gun and\nsecondary gun. z/🅾️ to shoot", 11, 28 + help_text_y, 7)
		print("in missile mode, press ⬆️ or\n⬇️ to switch targets", 11, 48 + help_text_y, 7)

		spr(009, 2, 64 + help_text_y)
		print("this is a pirate! fight them\nfor rewards", 11, 62 + help_text_y, 7)

		spr(030, 2, 83 + help_text_y)
		spr(062, 2, 83 + help_text_y)
		print("as you fight and destroy\npirates, your wanted level\nincreases. the skull icon\nindicates this. ", 11, 76 + help_text_y, 7)

		spr(064, 2, 100 + help_text_y, 2, 2)
		print("this is a battle encounter!\nload up!", 17, 103 + help_text_y)

		spr(072, 2, 117 + help_text_y, 2, 2)
		print("this is a shop encounter.\nrefuel, rearm and upgrade", 17, 120 + help_text_y)

		spr(072, 2, 140 + help_text_y, 2, 2)
		spr(046, 9, 148 + help_text_y)
		spr(062, 9, 148 + help_text_y)
		print("a pirate owned shop.\nit's cheaper due to the\nmysterious source of the\ngoods, but sell no\nupgrade.", 17, 136 + help_text_y)

		rectfill(0,0, 126,12, 7)
		print("help screen", 40, 3, 0)
		line(40, 9, 82, 9, 0)
	end
end

function _update()
	clock+=1

	if (clock % 1 == 0) siren_spr += 16
	if (siren_spr > 31) siren_spr = 015

	if (count(warnings) == 0) move()
	update_threat()
	update_icons()

	if current_view == 1 then
		if show_stats == false then
			fuel -= fuel_comsumption
			if (clock % 60 == 0) create_encounter()
			if (fuel <= 0) current_view = 5
			foreach(encounters, move_encounter)
		end

		if btnp(4) then
			if show_stats then
				show_stats = false
			else
				show_stats = true
			end
		end

		if show_stats then
			if btnp(0) then
				if (stats_page > 1) stats_page -=1
			elseif btnp(1) then
				if (stats_page < 2) stats_page +=1
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

		if (battle_started and count(enemies) > 0) missile_ui()
		foreach(missiles, move_missile)
		if (battle_started and count(explosions) == 0 and count(enemies) == 0) transition_animation = true
	end

	if current_view == 3 then
		if stat(54) == 0 then
			if btnp(4) or btnp(5) then
				scraps += battle_rewards
				animation_direction = "out"
				transition_animation = true
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

		if (btn(2)) help_text_y += 3
		if (btn(3)) help_text_y -= 3
		if (help_text_y > 0) help_text_y = 0
		if (help_text_y < -69) help_text_y = -69
	end

	if current_view != 1 then
		encounters = {}
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

	if (current_view == 2 or current_view == 3) update_transition_animation()
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
	rectfill(0, 0, left_side, 128, 1)
	rectfill(127, 0, right_side, 128, 1)
end

function update_transition_animation()
	if transition_animation then
		if animation_direction == "in" then
			right_side -= 5
			left_side += 5

			if right_side < 64 and left_side > 64 then
				if battle_started and count(explosions) == 0 and count(enemies) == 0 then
					transition_animation = false 
					current_view = 3
				else
					animation_direction = "out"
				end
			end
		else
			right_side += 5
			left_side -= 5

			if right_side > 127 and left_side < 0 then
				reset_transition_animation()
				transition_animation = false

				if (current_view == 3) reset() current_view = 1
			end
		end
	end
end

function reset_transition_animation()
	left_side = 0
	right_side = 127
	animation_direction = "in"
end

function draw_missile(m)
	spr(016,m.x,m.y)
end

function move_missile(m)
	if (current_enemy_locked_on == null) current_enemy_locked_on = 1 -- [wip] get enemy coordinates on missile launch, not during missile movement
	target_x = enemies[current_enemy_locked_on].x
	target_y = enemies[current_enemy_locked_on].y

	angle = atan2(target_x - m.x, target_y - m.y)
	m.x += cos(angle) * m.v
	m.y += sin(angle) * m.v

	if m.x >= target_x and
	m.x <= target_x+8 and
	m.y >= target_y-2 and
	m.y <= target_y+6 then
		sfx(04)
		e = enemies[current_enemy_locked_on]
		e.health -= m.damage
		del(missiles, m)
		if e.health <= 0 then
			current_enemy_locked_on = 1
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
	health_spr = (health/current_max_health == 1) and 003 or
	(health/current_max_health > 0.50 and health/current_max_health < 1) and 019 or 
	(health/current_max_health > 0.25 and health/current_max_health < 0.50) and 035 or 051

	fuel_spr = (fuel/max_fuel == 1) and 005 or 
	(fuel/max_fuel > 0.50 and fuel/max_fuel < 1) and 021 or 
	(fuel/max_fuel > 0.25 and fuel/max_fuel < 0.50) and 037 or 053

	armor_spr = (armor/current_max_armor == 1) and 004 or 
	(armor/current_max_armor > 0.50 and armor/current_max_armor < 1) and 020 or
	(armor/current_max_armor > 0.25 and armor/current_max_armor < 0.50) and 036 or 052
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
	enemy_count = rnd(enemy_by_difficulty[pirate_rep])

	while(enemy_count > 0)
	do
		enemy_data = rnd(enemy_list)
		local enemy = {}
		b_health = enemy_data.b_health + (pirate_rep - 1)
		b_energy = enemy_data.b_energy+ (pirate_rep - 1)

		enemy.spr = enemy_data.spr_ok
		enemy.spr_damage = enemy_data.spr_damage
		enemy.health = b_health
		enemy.max_health = b_health
		enemy.energy = b_energy
		enemy.max_energy = b_energy
		enemy.damage = enemy_data.b_damage + (pirate_rep - 1)
		enemy.shot_v = enemy_data.b_shot_speed + (pirate_rep - 1)
		enemy.v = enemy_data.b_speed
		enemy.base_v = enemy_data.b_speed
		enemy.score = enemy_data.score
		enemy.reward = enemy_data.reward
		enemy.cdr = enemy_data.b_cdr
		enemy.clock = 0

		enemy.x = flr(rnd(48))+48
		enemy.y = 18
		enemy.angle = 0
		enemy.from_x = 0
		enemy.to_x = 0
		enemy.to_y = 0
		enemy.moving = false
		enemy.locked_on = false
		enemy.stunned = false

		enemy.fire = true
		enemy.collateral = false
		add(enemies, enemy)
		enemy_count -= 1
	end

	ship_x = 64
	encounters = {}
	battle_started = true
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
	current_enemy_locked_on = null
	battle_started = false
	battle_rewards = 0
	bullet_cooldown = false
	bullet_cooldown_counter = 0
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
		print("weapon: " .. ammo_mode[current_ammo_mode], 1, 1, 0)
		reloading = false
		out_of_ammo = false
		ammo_left = ""

		if current_ammo_mode == 1 then
			if (bullet_cooldown) reloading = true
		elseif current_ammo_mode == 2 then
			if (missile_cooldown) reloading = true
			ammo_left = missile_n
			if (missile_n == 0) out_of_ammo = true
		elseif current_ammo_mode == 3 then
			if (cluster_cooldown) reloading = true
			ammo_left = cluster_n
			if (cluster_n == 0) out_of_ammo = true
		elseif current_ammo_mode == 4 then
			if (stun_cooldown) reloading = true
			ammo_left = stun_n
			if (stun_n == 0) out_of_ammo = true
		end
		
		if (reloading) print("rELOADING", 1, 7, 0)
		if (not reloading and out_of_ammo) print("oUT OF AMMO", 1, 7, 0)
		if (ammo_left != "") spr(016, 88, 2) print("x" .. ammo_left, 95, 4, 0)
	end

	if current_view != 2 then
		print("$" .. scraps,1,1, 0)
		if (current_view != 4) print("score: " .. score,1,7, 0)
	end

	if (armor > 0) spr(armor_spr,103,2)
	spr(health_spr,111,2)
	spr(fuel_spr,119,2)
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
	rectfill(62,1,72,11, 0)
	pirate_sprite = (pirate_rep == 1) and 014 or (pirate_rep == 2) and 030 or 046
	pirate_mouth = 062

	spr(pirate_sprite, 64, pirate_sprite_y)
	spr(pirate_mouth, 64, 4)
end

function restart_from_gameover()
	if btnp(4) or btnp(5) then
		_init()
	end
end
-->8
-- encounters

function create_encounter()
	local random_factor = rnd()
	type = (random_factor <= 0.7) and 1 or (random_factor <= 0.875) and 2 or 3

	local encounter = {}
	encounter.x = rnd({ 12, 36, 64, 96, 108})
	encounter.y = 12
	encounter.type = type
	encounter.animate = false
	encounter.sprite = (type == 1) and 064 or 072
	encounter.skull_y = (type == 3) and encounter.y + 4 or false
	encounter.skull_x = (type == 3) and encounter.x - 4 or false
	encounter.move_left = true
	encounter.clock = 0
	add(encounters, encounter)
end

function draw_encounter(e)
	spr(e.sprite,e.x, e.y, 2, 2)
	if (e.type == 3) spr(045, e.skull_x, e.skull_y)
end

function move_encounter(e)
	e.clock += 1
	e.y += 1

	if e.type == 3 then
		e.skull_y += 1
		if e.move_left then
			e.skull_x += 1
			if (e.skull_x >= e.x + 8) e.move_left = false
		else
			e.skull_x -= 1
			if (e.skull_x <= e.x - 4) e.move_left = true
		end
	end

	if e.x >= ship_x-8 and
	e.x <= ship_x+10 and
	e.y >= ship_y-8 and
	e.y <= ship_y+10 then
		del(encounters,e)
		if e.type == 1 then
			transition_animation = true
			current_view = 2
		end
		if e.type == 2 or e.type == 3 then
			current_view = 4
			if (e.type == 3) pirate_store = true
		end
	end

	if e.clock % 45 == 0 then
		e.animate = true
	end

	if e.animate then
		if (e.clock % 1.5 == 0) e.sprite += 2
		if e.type == 1 then
			if e.sprite > 070 then
				e.animate = false
				e.sprite = 064
			end
		else
			if e.sprite > 078 then
				e.animate = false
				e.sprite = 072
			end
		end
	end	

	if (e.y >= 128) del(encounters,e)
end

-->8
-- player

function fire()
	if btnp(4) then
		if current_ammo_mode == 1 and not bullet_cooldown then
			local bullet = {}
			bullet.mode = "laser"
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 001
			bullet.damage = bullet_damage
			add(bullets, bullet)
			bullet_cooldown = true
		elseif current_ammo_mode == 2 and missile_n > 0 and not missile_cooldown then
			local missile = {}
			missile.x = ship_x
			missile.y =ship_y - 8
			missile.v = 3
			missile.damage = missile_damage
			add(missiles, missile)
			missile_cooldown = true
			missile_n -= 1
		elseif current_ammo_mode == 3 and cluster_n > 0 and not cluster_cooldown then
			local bullet = {}
			bullet.mode = "cluster"
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 032
			bullet.damage = 0.5
			bullet.fuse = 15
			bullet.timer = 0
			bullet.frag_n = 3
			add(bullets, bullet)
			cluster_cooldown = true
			cluster_n -= 1
		elseif current_ammo_mode == 4 and stun_n > 0 and not stun_cooldown then
			local bullet = {}
			bullet.mode = "stun"
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 048
			bullet.damage = 0.5
			add(bullets, bullet)
			stun_cooldown = true
			stun_n -= 1
		end
	end
	if btnp(5) then
		current_ammo_mode += 1
		if (current_ammo_mode > 4) current_ammo_mode = 1

		if current_ammo_mode != 2 then
			for e in all (enemies) do
				e.locked_on = false
			end
		end
	end

	if bullet_cooldown then
		bullet_cooldown_counter += 1
		if (bullet_cooldown_counter % bullet_cooldown_rate == 0) bullet_cooldown_counter = 0 bullet_cooldown = false
	end

	if missile_cooldown then
		missile_cooldown_counter += 1
		if (missile_cooldown_counter % 90 == 0 and count(enemies) > 0) missile_cooldown_counter = 0 missile_cooldown = false
	end

	if stun_cooldown then
		stun_cooldown_counter += 1
		if (stun_cooldown_counter % 90 == 0) stun_cooldown_counter = 0 stun_cooldown = false
	end

	if cluster_cooldown then
		cluster_cooldown_counter += 1
		if (cluster_cooldown_counter % 90 == 0) cluster_cooldown_counter = 0 cluster_cooldown = false
	end
end

function draw_bullet(b)
	spr(b.spr,b.x,b.y)

	if b.mode == "stun" then
		for e in all(enemies) do
			if e.x >= b.x-12 and e.x <= b.x+20 and e.y >= b.y-12 and e.y <= b.y+20 then
				line_color = (clock % 2 == 0) and 12 or 7
				line(b.x+4, b.y+4, e.x+4, e.y+4, line_color)
			end
		end
	end
end

function missile_ui()
	if current_ammo_mode == 2 then
		if (current_enemy_locked_on == null) current_enemy_locked_on = 1
		last_enemy = count(enemies)

		if btnp(2) then
			enemies[current_enemy_locked_on].locked_on = false
			current_enemy_locked_on += 1
			if (current_enemy_locked_on > last_enemy) current_enemy_locked_on = 1
		end

		if btnp(3) then
			enemies[current_enemy_locked_on].locked_on = false
			current_enemy_locked_on -= 1
			if (current_enemy_locked_on <= 0) current_enemy_locked_on = last_enemy
		end

		enemies[current_enemy_locked_on].locked_on = true
	else
		for e in all(enemies) do
			e.locked_on = false
		end
	end
end

function move_bullet(b)
	if b.mode == "cluster" then
		b.timer += 1
		if (b.timer % b.fuse == 0) create_clusters(b)
	end

	if b.mode == "cluster_frag" then
		b.x += cos(45) * b.angle
		b.y -= 6
	else
		b.y -= (b.mode == "laser") and 4 or 2
	end

	for e in all(enemies) do
		if b.mode == "stun" then
			if e.x >= b.x-12 and e.x <= b.x+20 and e.y >= b.y-12 and e.y <= b.y+20 then
				e.energy -= 0.005
				e.stunned = true
			else
				e.stunned = false
			end
		end

		if e.x >= b.x-4 and e.x <= b.x+6 and e.y >= b.y-4 and e.y <= b.y+6 then
			damage = b.damage
			if rnd() > random_factor and b.mode == "laser" then
				damage = damage + (flr(rnd(2)) + 1)
				create_warning("critical\ndamage!", e)
			end
			if (b.mode == "laser") e.health -= damage
			if (b.mode == "stun") e.energy -= damage

			if e.health <= 0 then
				destroy_enemy(e)
			else
				if e.collateral == false and b.mode == "laser"then
					for el in all(enemy_list) do
						if e.spr == el.spr_ok then
							enemy_kl_factor = 0
							if (el.knowledge_level == 1) enemy_kl_factor = 0.100
							if (el.knowledge_level == 2) enemy_kl_factor = 0.200
							if (el.knowledge_level == 3) enemy_kl_factor = 0.300
							local_random_factor = random_factor - enemy_kl_factor
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
		bullet.damage = 1
		bullet.angle = pos_y[i]
		add(bullets, bullet)
	end
	del(bullets,b)
end

function destroy_enemy(e)
	for el in all(enemy_list) do
		if e.spr == el.spr_ok then
			el.n_destroyed += 1

			if el.n_destroyed % 5 == 0 and el.knowledge_level < 3 then
				el.knowledge_level += 1
			end
		end
	end

	total_enemies_destroyed += 1
	if (pirate_rep < 3 and total_enemies_destroyed % 15 == 0) pirate_rep += 1

	score += e.score
	battle_rewards += flr(10 + (e.reward * (pirate_rep/2)))
	create_explosion(e.x,e.y)
	sfx(05)
	del(enemies,e)
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
	if show_stats == false then
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
		enemy_bullet.damage = e.damage
		enemy_bullet.v = e.shot_v
		enemy_bullet.aimless = (e.collateral == 2) and true or false
		sfx(08)
		add(enemy_bullets,enemy_bullet)
	else
		if (e.clock % e.cdr == 0) e.fire = true
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

		if (armor == 0) health-=eb.damage
		if armor > 0 then 
			armor-=eb.damage
			if (armor < 0) armor = 0
		end
		if (health <= 0) current_view = 5
	end
end

function move_enemy(e)
	e.clock += 1
	e.v = (e.stunned) and 0.2 or e.base_v

	if e.collateral != 1 then
		if e.moving == false then
			e.moving = true
			rnd_pos = rnd(positions)
			e.from_x = e.x
			e.to_x = rnd_pos[1]
			e.to_y = rnd_pos[2]
			e.angle = atan2(e.to_x - e.x, e.to_y - e.y)
		else
			e.x += cos(e.angle) * e.v
			e.y += sin(e.angle) * e.v
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

function draw_enemy(e)
	spr(e.spr,e.x,e.y)

	percentage = e.health/e.max_health
	color = (percentage == 1) and 11 or (percentage < 1 and percentage >= 0.5) and 10 or 8
	length = (percentage == 1) and 6 or (percentage < 1 and percentage >= 0.5) and 4 or 2
	line(e.x + 1, e.y - 3, e.x + length, e.y - 3, color)

	energy_percentage = e.energy/e.max_energy
	length = (energy_percentage == 1) and 6 or (energy_percentage < 1 and energy_percentage >= 0.5) and 4 or 2
	line(e.x + 1, e.y - 5, e.x + length, e.y - 5, 12)
	if (e.locked_on) rect(e.x - 2, e.y - 2, e.x + 9, e.y + 9,8)
end

function draw_enemy_bullet(eb)
	spr(001,eb.x,eb.y)
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

			add(shop_items, item)

			::skip_to_next::
		end
	end

	if btnp(5) then
		sfx(00)
		shop_items = {}
		current_view = 1
		shop_last_bought = ""
		pirate_store = false
		shop_selector = 1
	end

	if btnp(4) then
		price = (pirate_store == false) and current_shop_item.price or (current_shop_item.name == "pirate_bribe") and current_shop_item.price or ceil(current_shop_item.price/2)
		if scraps >= price then
			if current_shop_item.name == "fuel" then
				if fuel < max_fuel then
					fuel = flr(fuel)
					fuel += 1
					shop_last_bought = "bought 1 fuel"
					scraps -= price
					if (fuel > max_fuel) fuel = max_fuel
				else
					shop_last_bought = "fuel at max capacity"
				end
			end
			if current_shop_item.name == "health" then
				if health < current_max_health then
					health += 1
					shop_last_bought = "bought 1 health"
					scraps -= price
				else
					shop_last_bought = "current at max health"
				end
			end
			if current_shop_item.name == "armor" then
				if armor < current_max_armor then
					armor += 1
					shop_last_bought = "bought 1 armor"
					scraps -= price
				else
					shop_last_bought = "current at max armor"
				end
			end
			if current_shop_item.name == "missile" then
				if missile_n < missile_max_capacity then
					missile_n += 1
					shop_last_bought = "bought 1 missile"
					scraps -= price
				else
					shop_last_bought = "missiles at max capacity"
				end
			end
			if current_shop_item.name == "stun_ammo" then
				if stun_n < stun_max_capacity then
					stun_n += 1
					shop_last_bought = "bought 1 stun ammo"
					scraps -= price
				else
					shop_last_bought = "stun ammo at max capacity"
				end
			end
			if current_shop_item.name == "health_upgrade" then
				if current_stat_health_lvl < 3 then
					scraps -= price
					current_stat_health_lvl += 1
					current_shop_item.price = price * current_stat_health_lvl
					current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier
					health = current_max_health
					shop_last_bought = "hull upgraded"
				else
					shop_last_bought = "hull upgrade maxed out"
				end
			end
			if current_shop_item.name == "armor_upgrade" then
				if current_stat_armor_lvl < 3 then
					scraps -= price
					current_stat_armor_lvl += 1
					current_shop_item.price = price * current_stat_armor_lvl
					current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
					armor = current_max_armor
					shop_last_bought = "armor upgraded"
				else
					shop_last_bought = "armor upgrade maxed out"
				end
			end
			if current_shop_item.name == "gun_damage_upgrade" then
				if current_stat_gun_lvl < 3 then
					scraps -= price
					current_stat_gun_lvl += 1
					bullet_damage = current_stat_gun_lvl
					current_shop_item.price = price * current_stat_gun_lvl
					shop_last_bought = "gun damage upgraded"
				else
					shop_last_bought = "gun damage upgrade maxed out"
				end
			end
			if current_shop_item.name == "gun_cooldown_upgrade" then
				if current_stat_cooldown_lvl < 3 then
					scraps -= price
					current_stat_cooldown_lvl += 1
					bullet_cooldown_rate = current_stat_cooldown_lvl
					current_shop_item.price = price * current_stat_cooldown_lvl
					shop_last_bought = "gun damage upgraded"
				else
					shop_last_bought = "gun cooldown upgrade maxed out"
				end
			end
			if current_shop_item.name == "pirate_bribe" then
				if pirate_rep > 1 then
					scraps -= price
					pirate_rep -= 1
					current_shop_item.price = pirate_rep * 50
					shop_last_bought = "pirate reputation diminished"
				else
					shop_last_bought = "already at minimum pirate rep level"
				end
			end
		else
			shop_last_bought = "too expensive"
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
end

function animate_shop_selector()
	if (clock % 5 == 0) shop_selector_spr += 16
	if (shop_selector_spr > 034) shop_selector_spr = 002
	spr(shop_selector_spr, 4, (shop_selector_y - 9) + shop_selector * 8)
end
__gfx__
0000000000000000000000000e80880011111dd03303330000333300003333000033330000777700000770000777777077777777700770070666660000888000
000000000000000099999900efe8ee801cccc6d0003bbb300b7bbb300b7bbb300b7bbb300722227007722770722222277888888777722777666666600e7e8800
00060000000aa0009aaaaa908eeeee801ccccc1003bbbb3037bbbbb337bbbbb337b77bb378777787787227877277772778777787787227876066606087e88880
0067600000a7aa0009aaaaa98eeeee801ccccc103b5b5b303bbbbbb33bb77bb33b7bb7b37888888778877887727117270722227078722787600600608e888e80
00d6d00000aaaa0009aaaaa958eee85051ccc1503bb5bb303bbbbbb33bb77bb33b7bb7b37878878776888867728778270727727077877877666066608888e780
000d0000009aa9009aaaaa90058e8500051c15003b5b5b303bbbbbb33bbbbbb33bb77bb3075775700768867078877887007887007078870706666600888e7e80
00000000000990009999990000585000005150005333335003bbbb3003bbbb3003bbbb30757007570767767007700770007887000078870006d6d6006ddddd50
00000000000000000000000000050000000500000555550000333300003333000033330007000070007007000700007000077000000770000000000055555550
00000000007007000000000000000000000000000000000000999900009999000099990000888800000880000888888088888888800880080666660000888000
0000000077000077000000000000000000000000000000000a7aaa900a7aaa900a7aaa90080000800880088080000008800000088880088866666660088e7e00
0008800075700757999999908eeeee801ccccc1003bbbb3097aaaaa997aaaaa997a77aa98088880880800808808888088088880880088008606660608888e780
008788007557755709aaaaa98eeeee801ccccc103b5b5b309aaaaaa99aa77aa99a7aa7a98000000880088008808008080800008080000008608680608e888e80
008888007571175709aaaaa958eee85051ccc1503bb5bb309aaaaaa99aa77aa99a7aa7a980800808800000088008800808088080880880886660666087e88880
002882007577775799999990058e8500051c15003b5b5b309aaaaaa99aaaaaa99aa77aa90808808008000080800880080080080080800808066666008e7e8880
00022000776666770000000000585000005150005333335009aaaa9009aaaa9009aaaa90808008080808808008800880008008000080080006d6d6006ddddd50
00000000077777700000000000050000000500000555550000999900009999000099990008000080008008000800008000088000000880000000000055555550
00000000000000000000000000000000000000000000000000222200002222000022220000050000000d00000000000000000000066666000666660000888000
00000000880000880000000000000000000000000000000008e8882008e8882008e88820000d00000006000000050000000d0000666666606666666008888800
000dd00080800808000000000000000000000000000000002e8888822e8888822e8ee8820006000000070000000d000000060000676667606866686088888880
00d7dd00800880080999999900000000000000000000000028888882288ee88228e88e825d666d50d67776d005d6d5000d676d00678687606886886088888880
00dddd00800880080999999908eee80001ccc1003bb5bb3028888882288ee88228e88e820006000000070000000d000000060000666766606660666088888880
005dd5008080080800000000058e8500051c15003b5b5b302888888228888882288ee882000d00000006000000050000000d0000066666000666660088888880
00055000800000080000000000585000005150005333335002888820028888200288882000050000000d0000000000000000000006d6d60006d6d6006ddddd50
00000000088888800000000000050000000500000555550000222200002222000022220000000000000000000000000000000000000000000000000055555550
00000000000000000000000000000000000000000000000000000000000000000099990000999900009099000090990000900900000000000000000000000000
000000000000000000000000000000000000000000000000000000000099990009aaaa900999aa900999aa900999aa9009090090000000000000000000000000
000cc00000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa99a999a999a999a0990990000909000000000000000000000000
00c7cc00000000000000000000000000000000000000000000999900099aa9909aaaaaa999aaaaa9999a99a99900900990000009000000000000000000000000
00cccc00000000000000000000000000000000000000000000999900099aa9909aaaaaa999a999a9099999000909900000000000000000000000000000000000
001cc10000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa9aa9900909999009009990000099000000000000000000000000
000110000000000000000000000800000001000003333300000000000099990009aaaa9009999a90099909900990009009000090000000000000000000000000
00000000000000000000000000050000000500000555550000000000000000000099990000999900000909000009090000090900000000000d6d6d0000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

