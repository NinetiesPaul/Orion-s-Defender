pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- general code

function _init()
	-- encounters variable
	encounters = {}
	types = {
		1, -- battle pirate
		2 -- store
	}
	encounter_spawn_x = {
		12,
		36,
		64,
		96,
		108
	}

	-- threat variables
	threat_level_sprs = {
		{006,007,008}, -- low
		{022,023,024}, -- normal
		{038,039,040}  -- high
	}
	threat_y = 1
	views = {
		1, -- 1 world
		2, -- 2 battle
		3, -- 3 rewards
		4, -- 4 store
		5, -- 5 game over
		6, -- 6 start screen
		7 -- 7 tutorial
	}

	-- general purpose variables
	score = 0
	difficulty = 1
	clock = 0
	current_view = views[6]
	rewards_given = false
	battle_rewards = 0
	r_scraps = 0
	show_stats = false
	scraps_accrued = 0

	-- player variables
	cooldown_lvls = {3,2,1}
	scraps = 25
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
	current_stat_cooldown_lvl = 1
	current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier 
	current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
	health = current_max_health
	armor = current_max_armor
	bullet_damage = current_stat_gun_lvl
	bullet_cooldown = 0
	bullet_cooldown_rate = cooldown_lvls[current_stat_cooldown_lvl]
	bullets = {}
	missile_mode = false
	current_enemy_locked_on = null
	missile_available = true
	missile_damage = 3
	missile_cooldown = 0
	missile_n = 2
	missile_max_capacity = 5
	warned = true
	random_factor = 0.95
	collateral_type =
	{
		1, -- motor damage
		2, -- aiming damage
		3 -- firing damage
	}
	enemy_by_difficulty ={
		{1,2},
		{3,4},
		{5,6}
	}

	-- store variables
	shop_selector_spr = {002,018,034}
	shop_selector_y = 16
	shop_selector = 1
	current_shop_item = null
	shop_selector_spr_pointer = 1
	shop_last_bought = ""
	next_armor_upgrade_cost = 75 * current_stat_armor_lvl
	next_health_upgrade_cost = 50 * current_stat_health_lvl
	next_gun_upgrade_cost = 100 * current_stat_gun_lvl
	next_cooldown_upgrade_cost = 100 * current_stat_cooldown_lvl
	shop_items = {
		{
			["name"] = "fuel",
			["formatted_name"] = "fuel",
			["price"] = 3,
			["available"] = true
		},
		{
			["name"] = "health",
			["price"] = 4,
			["formatted_name"] = "health",
			["available"] = true
		},
		{
			["name"] = "armor",
			["price"] = 4,
			["formatted_name"] = "armor",
			["available"] = true
		},
		{
			["name"] = "missile",
			["price"] = 7,
			["formatted_name"] = "missile",
			["available"] = true
		},
		{
			["name"] = "health_upgrade",
			["price"] = 50 * current_stat_health_lvl,
			["formatted_name"] = "health upgrade",
			["available"] = true
		},
		{
			["name"] = "armor_upgrade",
			["price"] = 75 * current_stat_armor_lvl,
			["formatted_name"] = "armor upgrade",
			["available"] = true
		},
		{
			["name"] = "gun_damage_upgrade",
			["price"] = 100 * current_stat_gun_lvl,
			["formatted_name"] = "gun damage upgrade",
			["available"] = true
		},
		{
			["name"] = "gun_cooldown_upgrade",
			["price"] = 100 * current_stat_gun_lvl,
			["formatted_name"] = "gun cooldown upgrade",
			["available"] = true
		},
	}

	-- enemy variables
	enemy_list = 
	{
		{
			["name"] = "ant",
			["spr_ok"] = 009,
			["spr_damage"] = 025,
			["b_health"] = 3,
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
			["b_health"] = 2,
			["b_damage"] = 2,
			["b_shot_speed"] = 1.0,
			["b_speed"] =  1,
			["b_cdr"] = 60,
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
			["b_damage"] = 1,
			["b_shot_speed"] = 1.5,
			["b_speed"] =  1.7,
			["b_cdr"] = 45,
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
			["b_damage"] = 2,
			["b_shot_speed"] = 1.3,
			["b_speed"] =  1.5,
			["b_cdr"] = 30,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 175,
			["reward"] = 16
		}
	}
	enemies = {}
	enemy_bullets = {}
	missiles = {}
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
	battle_started = false

	-- music variables
	can_leave_screen = false
	music_view_1_playing = false
	music_batttle_player = false
	music_battle_end_playing = false

	stars = {}
end

function _draw()
	cls()
	rectfill(0,0,127,12,7)
	rect(0,12,127,127)
	if (current_view == 1 or current_view == 2 or current_view == 4) draw_ui()

	if current_view == 1 then -- world
		draw_threat()
		spr(ship_spr,ship_x,ship_y)
		foreach(encounters, draw_encounter)

		if show_stats then
			rect(24,24,104,104, 1)
			rectfill(25,25,103,103, 0)

			linect = 0
			total = 0
			for e in all(enemy_list) do
				spr(e.spr_ok, 30, 32 + linect * 14)
				print(e.name, 40, 32 + linect * 14, 7)

				print(e.n_destroyed, 40, 38 + linect * 14, 7)
				print(e.knowledge_level .. "/3", 88, 32 + linect * 14, 7)

				total += e.n_destroyed
				linect+=1
			end
			print("total: " .. total, 38, 96, 7)
		end
	end

	if current_view == 2 then -- battle
		draw_cooldown()
		if (count(warnings) == 0) foreach(enemies, create_enemy_bullet)

		spr(ship_spr,ship_x,ship_y)
		foreach(enemies, draw_enemy)
		foreach(enemy_bullets, draw_enemy_bullet)
		foreach(bullets, draw_bullet)
		foreach(missiles, draw_missile)
		foreach(explosions, draw_explosion)
		foreach(warnings, print_warning)
	end

	if current_view == 3 then -- rewards
		destroy()

		print("you've won!", 40,64)
		print("added "..r_scraps.." scraps", 40,80)
		if (stat(54) == 0) print("press z or x to continue", 18, 104)
	end

	if current_view == 4 then -- store
		destroy()

		current_shop_item = shop_items[shop_selector]

		i = 0
		for item in all (shop_items) do
			print(item.formatted_name, 14, 16 + i * 8, 7)
			print("$", 100, 16 + i * 8, 3)
			print(item.price, 104, 16 + i * 8, 7)
			i += 1
		end

		if (clock % 90 == 0) shop_last_bought = ""
		print(shop_last_bought, 24, 84)

		print("up or down - select", 2, 104)
		print("z - buy", 2,112)
		print("x - leave", 2, 120)

		animate_shop_selector()
	end

	if current_view == 5 then -- gameover
		destroy()

		print("game over",44,64)
		if (health <= 0) print("you were destroyed",24,72)
		if (fuel <= 0) print("you ran out of fuel",23,72)
		print("press z or x to restart", 18, 104)
	end

	if current_view == 6 then -- start
		spr(128,24,44,9,3)
		print("z to start", 40, 84,7)
		print("x to help", 42, 92,7)
	end

	if current_view == 7 then -- help
		print("help screen", 40, 2)

		spr(017, 2, 12)
		print("this is your ship. \nyou can only move sideways", 11, 10)

		spr(001, 2, 26)
		print("when in battle, \npress 'z' to shoot", 11, 23)
		print("some shots may cause critical\nor collateral damage", 11, 36)

		spr(000, 1, 51)
		print("this is an encounter pickup\nit can be anything", 11, 49)

		spr(009, 2, 69)
		print("this is an enemy.\ndestroy it to get scraps", 11, 67)

		print("threat level indicators", 2, 81)
		spr(006, 2, 90)
		print("low", 11, 92)
		spr(022, 24, 90)
		print("medium", 33, 92)
		spr(038, 58, 90)
		print("high level", 67, 92)

		print("use scraps to fix your ship,\nbuy fuel and upgrades. survive", 2, 106)
		print("press anything to start", 20, 120)
	end

	if current_view == 1 or current_view == 2 or current_view == 6 then
		foreach(stars, draw_star)
	end
end

function _update()
	clock+=1
	if (count(warnings) == 0) move()
	update_threat()
	update_icons()

	if current_view == 1 then
		if show_stats == false then
			fuel -= fuel_comsumption
			if (clock % 60 == 0) create_encounter()
			if (fuel <= 0) current_view = views[5]
			foreach(encounters, move_encounter)
		end

		if btnp(4) then
			if show_stats then
				show_stats = false
			else
				show_stats = true
			end
		end
	end

	if current_view == 2 then
		if (battle_started == false)	start_battle()
		if count(warnings) == 0 then
			fire()
			foreach(enemies, move_enemy)
			foreach(bullets, move_bullet)
			foreach(enemy_bullets, move_enemy_bullet)
			foreach(explosions, animate_explosion)
		end
		foreach(warnings, move_warning)

		missile_ui()
		foreach(missiles, move_missile)
		if missile_available == false then
			missile_cooldown += 1
			if missile_cooldown % 90 == 0 and count(enemies) > 0 then
				missile_available = true
				missile_cooldown = 0
			end
		end
	end

	if current_view == 3 then
		rewards()
	end

	if current_view == 4 then
		nav_store()
	end

	if current_view == 5 then
		restart_from_gameover()
	end

	if current_view == 6 or current_view == 7 then
		start()
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
			--music(-1)
		end
	else
		music_battle_end_playing = false
	end

	-- star effect

	if current_view == 1 or current_view == 2 or current_view == 6 then
		create_stars()
		foreach(stars, move_star)
	end
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

function draw_missile(m)
	spr(016,m.x,m.y)
end

function move_missile(m)
	if (current_enemy_locked_on == null) current_enemy_locked_on = 1
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
	if (health/current_max_health < 0.25) health_spr = 051
	if (health/current_max_health > 0.25 and health/current_max_health < 0.50) health_spr = 035
	if (health/current_max_health > 0.50 and health/current_max_health < 1) health_spr = 019
	if (health/current_max_health == 1) health_spr = 003

	if (fuel/max_fuel < 0.25) fuel_spr = 053
	if (fuel/max_fuel > 0.25 and fuel/max_fuel < 0.50) fuel_spr = 037
	if (fuel/max_fuel > 0.50 and fuel/max_fuel < 1) fuel_spr = 021
	if (fuel/max_fuel == 1) fuel_spr = 005

	if (armor/current_max_armor == 1) armor_spr = 004
	if (armor/current_max_armor > 0.50 and armor/current_max_armor < 1) armor_spr = 020
	if (armor/current_max_armor > 0.25 and armor/current_max_armor < 0.50) armor_spr = 036
	if (armor/current_max_armor < 0.25) armor_spr = 052
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
	enemy_count = rnd(enemy_by_difficulty[difficulty])

	while(enemy_count > 0)
	do
		enemy_data = rnd(enemy_list)
		local enemy = {}
		enemy.spr = enemy_data["spr_ok"]
		enemy.spr_damage = enemy_data["spr_damage"]
		enemy.health = enemy_data["b_health"] + (difficulty - 1)
		enemy.damage = enemy_data["b_damage"] + (difficulty - 1)
		enemy.shot_v = enemy_data["b_shot_speed"] + (difficulty - 1)
		enemy.v = enemy_data["b_speed"]
		enemy.score = enemy_data.score
		enemy.reward = enemy_data.reward
		enemy.cdr = enemy_data["b_cdr"]
		enemy.clock = 0

		enemy.x = flr(rnd(48))+48
		enemy.y = 18
		enemy.angle = 0
		enemy.from_x = 0
		enemy.to_x = 0
		enemy.to_y = 0
		enemy.moving = false
		enemy.locked_on = false

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

	if count(explosions) == 0 and count(enemies) == 0 then
		current_view = views[3]
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

function rewards()
	if rewards_given == false then
		x = difficulty * (flr(rnd(difficulty)) + 1)
		scraps += battle_rewards
		r_scraps = battle_rewards
		rewards_given = true
		bullet_cooldown = 0
		battle_rewards = 0
	else
		if stat(54) == 0 then
			if btnp(4) or btnp(5) then
				current_view = views[1]
				rewards_given = false
			end
		end
	end
end

function destroy()
	enemies = {}
	enemy_bullets = {}
	bullets = {}
	encounters = {}
	explosions = {}
	warnings = {}
	missiles = {}
	missile_available = true
	missile_cooldown = 0
	missile_mode = false
	warned = true
	current_enemy_locked_on = null
	battle_started = false
end

function draw_ui()
	if current_view == 2 then
		current_weapon = (missile_mode) and "missile" or "main gun"
		print("weapon: " .. current_weapon, 1, 1, 0)
	end

	if current_view != 2 then
		print("$" .. scraps,1,1, 0)
		if (current_view != 4) print("score: " .. score,1,7, 0)
	end

	if (armor > 0) spr(armor_spr,103,2)
	spr(health_spr,111,2)
	spr(fuel_spr,119,2)
	spr(016, 88, 2)
	print("x" .. missile_n, 95, 4)
end

function update_threat()
	if (score > 2000 and score < 5000) difficulty = 2
	if (score > 5000) difficulty = 3
end

function draw_threat()
	threat_x = difficulty
	update = 5
	if (threat_x == 2) update = 3
	if (threat_x == 3) update = 2
	
	if clock % update == 0 then
		threat_y += 1
		if (threat_y > 3) threat_y = 1
	end
	
	spr(threat_level_sprs[threat_x][threat_y],60,3)
end

function restart_from_gameover()
	if btnp(4) or btnp(5) then
		_init()
	end
end
-->8
-- encounters

function create_encounter()
	type = rnd(types)

	local encounter = {}
	encounter.x = rnd(encounter_spawn_x)
	encounter.y = 12
	encounter.type = type
	encounter.animate = false
	encounter.sprite = (type == 1) and 064 or 072
	encounter.clock = 0
	add(encounters, encounter)
end

function draw_encounter(e)
	spr(e.sprite,e.x, e.y, 2, 2)
end

function move_encounter(e)
	e.clock += 1
	e.y += 1

	if e.x >= ship_x-8 and
	e.x <= ship_x+10 and
	e.y >= ship_y-8 and
	e.y <= ship_y+10 then
		del(encounters,e)
		if e.type == 1 then
			current_view = views[2]
		end
		if e.type == 2 then
			current_view = views[4]
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

function draw_cooldown()
	pos = bullet_cooldown_rate - bullet_cooldown
	bar_color = (bullet_cooldown > 0) and 10 or 11

	for i = pos, 0, -1 do
		line(
		ship_x+9,
		ship_y+7,
		ship_x+9,
		ship_y+(7-i),
		bar_color)
	end
end
-->8
-- player

function fire()
	if warned == false then
		sfx(03)
		warned = true
	end
	if btnp(4) then
		if missile_mode == false then
			if bullet_cooldown == 0 then
				local bullet = {}
				bullet.x = ship_x
				bullet.y = ship_y - 8
				bullet.spr = 001
				bullet_cooldown = bullet_cooldown_rate
				warned = false
				sfx(07)
				add(bullets, bullet)
			end
		elseif missile_available == true and missile_n > 0 then
			local missile = {}
			missile.x = ship_x
			missile.y =ship_y - 8
			missile.v = 3
			missile.damage = missile_damage
			add(missiles, missile)
			missile_available = false
			missile_n -= 1
		end
	end
	if btnp(5) then
		if missile_mode == false then
			missile_mode = true
		else
			for e in all (enemies) do
				e.locked_on = false
			end
			missile_mode = false
		end
	end
	if clock % 30 == 0 and bullet_cooldown != 0 then
		bullet_cooldown -= 1
	end
end

function draw_bullet(b)
	spr(b.spr,b.x,b.y)
end

function missile_ui()
	if missile_mode and missile_available then
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
	end
end

function move_bullet(b)
	b.y -= 4

	for e in all(enemies) do
		if e.x >= b.x-4 and
		e.x <= b.x+6 and
		e.y >= b.y-4 and
		e.y <= b.y+6
		then
			damage = bullet_damage
			if rnd() > random_factor then
				damage = damage + (flr(rnd(2)) + 1)
				create_warning("critical\ndamage!", e)
			end
			e.health -= damage

			if e.collateral == false then
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

			sfx(04)
			del(bullets,b)

			if (e.health <= 0) destroy_enemy(e)
		end
	end
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

	score += e.score
	battle_rewards += flr(10 + (e.reward * (difficulty/2)))
	create_explosion(e.x,e.y)
	sfx(05)
	del(enemies,e)
	if (current_enemy_locked_on != null) current_enemy_locked_on = null

	if count(enemies) == 0 then
		missile_available = false
		missile_mode = false
	end
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
		current_view = views[1]
	end

	if btnp(5) then
		sfx(01)
		current_view = views[7]
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
		if (health <= 0) current_view = views[5]
	end
end

function move_enemy(e)
	e.clock += 1
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
	print(e.health,e.x + 9,e.y, 10)
	if (e.locked_on) rect(e.x-2,e.y-2,e.x+9,e.y+9,8)
end

function draw_enemy_bullet(eb)
	spr(001,eb.x,eb.y)
end
-->8
-- store

function nav_store()
	if btnp(5) then
		sfx(00)
		current_view = views[1]
		shop_last_bought = ""
	end

	if btnp(4) then
		if current_shop_item.available then
			if scraps >= current_shop_item.price then
				if current_shop_item.name == "fuel" then
					if fuel < max_fuel then
						fuel = flr(fuel)
						fuel += 1
						shop_last_bought = "bought 1 fuel"
						scraps -= current_shop_item.price
						if (fuel > max_fuel) fuel = max_fuel
					else
						shop_last_bought = "fuel at max capacity"
					end
				end
				if current_shop_item.name == "health" then
					if health < current_max_health then
						health += 1
						shop_last_bought = "bought 1 health"
						scraps -= current_shop_item.price
					else
						shop_last_bought = "current at max health"
					end
				end
				if current_shop_item.name == "armor" then
					if armor < current_max_armor then
						armor += 1
						shop_last_bought = "bought 1 armor"
						scraps -= current_shop_item.price
					else
						shop_last_bought = "current at max armor"
					end
				end
				if current_shop_item.name == "missile" then
					if missile_n < missile_max_capacity then
						missile_n += 1
						shop_last_bought = "bought 1 missile"
						scraps -= current_shop_item.price
					else
						shop_last_bought = "missiles at max capacity"
					end
				end
				if current_shop_item.name == "health_upgrade" then
					if current_stat_health_lvl < 3 then
						scraps -= current_shop_item.price
						current_stat_health_lvl += 1
						current_shop_item.price = current_shop_item.price * current_stat_health_lvl
						current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier
						health = current_max_health
						shop_last_bought = "hull upgraded"
					else
						shop_last_bought = "hull upgrade maxed out"
					end
				end
				if current_shop_item.name == "armor_upgrade" then
					if current_stat_armor_lvl < 3 then
						scraps -= current_shop_item.price
						current_stat_armor_lvl += 1
						current_shop_item.price = current_shop_item.price * current_stat_armor_lvl
						current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
						armor = current_max_armor
						shop_last_bought = "armor upgraded"
					else
						shop_last_bought = "armor upgrade maxed out"
					end
				end
				if current_shop_item.name == "gun_damage_upgrade" then
					if current_stat_gun_lvl < 3 then
						scraps -= current_shop_item.price
						current_stat_gun_lvl += 1
						bullet_damage = current_stat_gun_lvl
						current_shop_item.price = current_shop_item.price * current_stat_gun_lvl
						shop_last_bought = "gun damage upgraded"
					else
						shop_last_bought = "gun damage upgrade maxed out"
					end
				end
				if current_shop_item.name == "gun_cooldown_upgrade" then
					if current_stat_cooldown_lvl < 3 then
						scraps -= current_shop_item.price
						current_stat_cooldown_lvl += 1
						bullet_cooldown_rate = current_stat_cooldown_lvl
						current_shop_item.price = current_shop_item.price * current_stat_cooldown_lvl
						shop_last_bought = "gun damage upgraded"
					else
						shop_last_bought = "gun cooldown upgrade maxed out"
					end
				end
			else
				shop_last_bought = "too expensive"
			end
		else
			shop_last_bought = "unavailable"
		end
	end
 
	if btnp(3) then
		sfx(02)
		shop_selector += 1
		if (shop_selector > count(shop_items)) shop_selector = 1
	end
	
	if btnp(2) then
		sfx(02)
		shop_selector -= 1
		if (shop_selector == 0) shop_selector = count(shop_items)
	end
end

function animate_shop_selector()
	if (clock % 5 == 0) shop_selector_spr_pointer += 1
	if (shop_selector_spr_pointer > 3) shop_selector_spr_pointer = 1
	spr(shop_selector_spr[shop_selector_spr_pointer], 4, (shop_selector_y - 9) + shop_selector * 8)
end
__gfx__
0000000000000000000000000e80880011111dd03303330000333300003333000033330000777700000770000777777077777777700770070776660000888000
008888000000000099999900efe8ee801cccc6d0003bbb300b7bbb300b7bbb300b7bbb3007222270077227707222222778888887777cc777786668600e7e8800
087fee80000aa0009aaaaa908eeeee801ccccc1003bbbb3037bbbbb337bbbbb337b77bb378777787787227877277772778777787711771177886886087e88880
08feee8000a7aa0009aaaaa98eeeee801ccccc103b5b5b303bbbbbb33bb77bb33b7bb7b37888888778877887727117270722227071111117666666608e888880
08eeee8000aaaa0009aaaaa958eee85051ccc1503bb5bb303bbbbbb33bb77bb33b7bb7b378788787768888677287782707277270771551776660665088888880
08eeee80009aa9009aaaaa90058e8500051c15003b5b5b303bbbbbb33bbbbbb33bb77bb307577570076886707887788700788700707cc7070666650088888880
00888800000990009999990000585000005150005333335003bbbb3003bbbb3003bbbb3075700757076776700770077000788700007cc70006d6d6006ddddd50
00000000000000000000000000050000000500000555550000333300003333000033330007000070007007000700007000077000000770000d6d6d00dd555550
00000000007007000000000000000000000000000000000000999900009999000099990000888800000880000888888088888888800880080000000000000000
0000000077000077000000000000000000000000000000000a7aaa900a7aaa900a7aaa9008000080088008808000000880000008888008880000000000000000
0008800075700757999999908eeeee801ccccc1003bbbb3097aaaaa997aaaaa997a77aa980888808808008088088880880888808800880080000000000000000
008788007557755709aaaaa98eeeee801ccccc103b5b5b309aaaaaa99aa77aa99a7aa7a980000008800880088080080808000080800000080000000000000000
008888007571175709aaaaa958eee85051ccc1503bb5bb309aaaaaa99aa77aa99a7aa7a980800808800000088008800808088080880880880000000000000000
002882007577775799999990058e8500051c15003b5b5b309aaaaaa99aaaaaa99aa77aa908088080080000808008800800800800808008080000000000000000
00022000776666770000000000585000005150005333335009aaaa9009aaaa9009aaaa9080800808080880800880088000800800008008000000000000000000
00000000077777700000000000050000000500000555550000999900009999000099990008000080008008000800008000088000000880000000000000000000
00000000000000000000000000000000000000000000000000222200002222000022220000050000000d00000000000000000000000000000000000000000000
00000000880000880000000000000000000000000000000008e8882008e8882008e88820000d00000006000000050000000d0000000000000000000000000000
000dd00080800808000000000000000000000000000000002e8888822e8888822e8ee8820006000000070000000d000000060000000000000000000000000000
00d7dd00800880080999999900000000000000000000000028888882288ee88228e88e825d666d50d67776d005d6d5000d676d00000000000000000000000000
00dddd00800880080999999908eee80001ccc1003bb5bb3028888882288ee88228e88e820006000000070000000d000000060000000000000000000000000000
005dd5008080080800000000058e8500051c15003b5b5b302888888228888882288ee882000d00000006000000050000000d0000000000000000000000000000
00055000800000080000000000585000005150005333335002888820028888200288882000050000000d00000000000000000000000000000000000000000000
00000000088888800000000000050000000500000555550000222200002222000022220000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000099990000999900009099000090990000900900000000000000000000000000
000000000000000000000000000000000000000000000000000000000099990009aaaa900999aa900999aa900999aa9009090090000000000000000000000000
000cc00000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa99a999a999a999a0990990000909000000000000000000000000
00c7cc00000000000000000000000000000000000000000000999900099aa9909aaaaaa999aaaaa9999a99a99900900990000009000000000000000000000000
00cccc00000000000000000000000000000000000000000000999900099aa9909aaaaaa999a999a9099999000909900000000000000000000000000000000000
001cc10000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa9aa9900909999009009990000099000000000000000000000000
000110000000000000000000000800000001000003333300000000000099990009aaaa9009999a90099909900990009009000090000000000000000000000000
00000000000000000000000000050000000500000555550000000000000000000099990000999900000909000009090000090900000000000000000000000000
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
00000000000000000000077777700000000000337000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000077dd666d77000000000333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f000000000f000007d66666666d700000b33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a900000009a000076666666666667000b77bbbbbb7300000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a90000009000007666666666666700037bbbbbbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a900009a000007d6066666606d70003bb3333333b00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000a9009a0000007d6006666006d70003bbb333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000009099000000007d08066080d700003bbbbbbb33000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000009900000000007d666666d700000033bbbbbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000099900000000007666006667000000003333bbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e099009900000000776666667700000b3333333bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002900009e0e000007606666067000003bbbbbbbb7300000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e2000000220000006670707066000003bbbbbbb77b00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e2020000202e00000766707066700000033333333b000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00200000000002200000766666670000000000b33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000777777000000000007b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606660600066006660660060600600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606000600060606060606000660606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66006600600060606660606060606606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60606660666006606060660060600600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

__gff__
0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

