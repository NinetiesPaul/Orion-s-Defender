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
	fuel_comsumption = 0.01
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
		{3,4,5},
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
	last_encounter_store = false
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
			["spr_ok"] = 009,
			["spr_damage"] = 025,
			["b_health"] = 3,
			["b_damage"] = 1,
			["b_shot_speed"] = 1.5,
			["b_speed"] =  0.5,
			["b_cdr"] = 90,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 100,
			["reward"] = 8
		},
		{
			["spr_ok"] = 010,
			["spr_damage"] = 026,
			["b_health"] = 2,
			["b_damage"] = 2,
			["b_shot_speed"] = 1.7,
			["b_speed"] =  1,
			["b_cdr"] = 60,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 125,
			["reward"] = 12
		},
		{
			["spr_ok"] = 011,
			["spr_damage"] = 027,
			["b_health"] = 5,
			["b_damage"] = 1,
			["b_shot_speed"] = 1.5,
			["b_speed"] =  1.3,
			["b_cdr"] = 45,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0,
			["score"] = 150,
			["reward"] = 14
		},
		{
			["spr_ok"] = 012,
			["spr_damage"] = 028,
			["b_health"] = 4,
			["b_damage"] = 2,
			["b_shot_speed"] = 1.7,
			["b_speed"] =  1.7,
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
		{8,15},
		{31,45},
		{39,67},
		{79,55},
		{80,25},
		{99,61},
		{21,21},
		{94,11},
	}
	music_view_1_playing = false
	music_batttle_player = false
	music_battle_end_playing = false
end

function _draw()
	cls()
	rect(0,0,127,127,7)
 
	if current_view == 1 then -- world
		draw_ui()
		draw_threat()
		spr(ship_spr,ship_x,ship_y)
		foreach(encounters, draw_encounter)
	end
 
	if current_view == 2 then -- battle
		draw_ui()
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
		print("press z or x to continue", 18, 104)
	end
 
	if current_view == 4 then -- store
		draw_ui()
		destroy()

		current_shop_item = shop_items[shop_selector]

		i = 0
		for item in all (shop_items) do
			print(item.formatted_name, 14, 16 + i * 8)
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
		print("orion's defender",30,44)
		print("z to start", 40, 84)
		print("x to help", 41, 92)
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
end

function _update()
	clock+=1
	if (count(warnings) == 0) move()
	update_threat()
	update_icons()

	if current_view == 1 then
		fuel -= fuel_comsumption
		if (clock % 30 == 0) create_encounter()
		if (fuel <= 0) current_view = views[5]
		foreach(encounters, move_encounter)
	end

	if current_view == 2 then
		if (count(enemies) == 0)	start_battle()
		if count(warnings) == 0 then
			fire()
			foreach(enemies, move_enemy)
			foreach(bullets, move_bullet)
			foreach(enemy_bullets, move_enemy_bullet)
			foreach(explosions, animate_explosion)
		end
		foreach(warnings, move_warning)

		if (missile_mode) missile_ui()
		foreach(missiles, move_missile)
		if missile_available == false then
			missile_cooldown += 1
			if missile_cooldown % 90 == 0 then
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
end

function draw_missile(m)
	spr(016,m.x,m.y)
end

function move_missile(m)
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
	if (armor/current_max_armor <= 0) armor_spr = 049
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
		del(explosions, explosion)
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
		if btnp(4) or btnp(5) then
			current_view = views[1]
			rewards_given = false
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
end

function draw_ui()
	print("$" .. scraps,2,2)
	if (current_view != 4) print("★ " .. score,2,8, 7)
	spr(armor_spr,98,2)
	spr(health_spr,108,2)
	spr(fuel_spr,118,2)

	for i=1, missile_n do
		spr(016, 91, -2 + i * 2)
		i += 1
	end
	
	--[[
	linect = 0
	for e in all(enemy_list) do
		spr(e.spr_ok, 100,64+linect*8)
		print(e.n_destroyed .. " " .. e.knowledge_level, 110,64+linect*8)
		linect+=1
	end
	]]--
end

function update_threat()
	if (score > 2000 and score < 5000) difficulty = 2
	if (score > 5000) difficulty = 3
	if (difficulty == 2) threat_level = 022
	if (difficulty == 3) threat_level = 038
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
	
	spr(threat_level_sprs[threat_x][threat_y],2,118)
end

function restart_from_gameover()
	if btnp(4) or btnp(5) then
		_init()
	end
end
-->8
-- encounters

function create_encounter()
	local encounter = {}
	encounter.x = rnd(encounter_spawn_x)
	encounter.y = 0
	encounter.type = rnd(types)
	if (last_encounter_store == true) encounter.type = 1
	add(encounters, encounter)
end

function draw_encounter(e)
	sprite = (e.type == 1) and 064 or 070
	spr(sprite,e.x, e.y, 2, 2)
end

function move_encounter(e)
	e.y += 3

	if e.x >= ship_x-8 and
	e.x <= ship_x+10 and
	e.y >= ship_y-8 and
	e.y <= ship_y+10 then
		del(encounters,e)
		if e.type == 1 then
			current_view = views[2]
			last_encounter_store = false
		end
		if e.type == 2 then
			current_view = views[4]
			last_encounter_store = true
		end
	end

	if e.y >= 128 then
		del(encounters,e)
	end
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
		if missile_mode == false and bullet_cooldown == 0 then
			local bullet = {}
			bullet.x = ship_x
			bullet.y = ship_y - 8
			bullet.spr = 001

			bullet_cooldown = bullet_cooldown_rate
			warned = false
			sfx(07)
			add(bullets, bullet)
		else
			if missile_available == true and missile_n > 0 then
				local missile = {}
				missile.x = ship_x
				missile.y =ship_y - 8
				missile.v = 4
				missile.damage = missile_damage
				add(missiles, missile)
				missile_available = false
				missile_n -= 1
			end
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
						local_random_factor = random_factor - el.knowledge_level
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

			if el.n_destroyed % 5 == 0 then
				if (el.knowledge_level == 0) el.knowledge_level = 0.100
				if (el.knowledge_level == 0.100) el.knowledge_level = 0.200
				if (el.knowledge_level == 0.200) el.knowledge_level = 0.300
			end
		end
	end

	score += e.score
	battle_rewards += flr(10 + (e.reward * (difficulty/2)))
	del(enemies,e)
	create_explosion(e.x,e.y)
	sfx(05)
	if (count(enemies) == 0) current_view = views[3]
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
	if (btn(1) and ship_x < 120) ship_x+=2
	if (btn(0) and ship_x > 0) ship_x-=2
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
		if (clock % e.cdr == 0) e.fire = true
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
0000000000000000000000000e800880011111d000b3333000333300003333000033330000777700000770000777777077777777000000000000000000000000
008888000000000099999900efe88ee81ccccc6d0b7bbbb30b7bbb300b7bbb300b7bbb3007000070077007707000000770000007000000000000000000000000
087fee80000fa0009aaaaa908eeeeee81cccccc1b7bbbbb337bbbbb337bbbbb337b77bb370777707707007077077770770777707000000000000000000000000
08feee8000f7aa0009aaaaa98eeeeee81cccccc13b5bb5b33bbbbbb33bb77bb33b7bb7b370000007700770077070070707000070000000000000000000000000
08eeee8000aaaa0009aaaaa98eeeeee801cccc103bb55bb33bbbbbb33bb77bb33b7bb7b370700707700000077007700707077070000000000000000000000000
08eeee80000aa0009aaaaa9008eeee8001cccc103b5bb5b33bbbbbb33bbbbbb33bb77bb307077070070000707007700700700700000000000000000000000000
008888000000000099999900008ee800001cc1003bbbbbb303bbbb3003bbbb3003bbbb3070700707070770700770077000700700000000000000000000000000
00000000000000000000000000088000000110000333333000333300003333000033330007000070007007000700007000077000000000000000000000000000
00000000000000000000000000000000000000000000000000999900009999000099990000888800000880000888888088888888000000000000000000000000
0000000077000077000000000000000000000000000000000a7aaa900a7aaa900a7aaa9008000080088008808000000880000008000000000000000000000000
000e800070700707999999908eeeeee81cccccc1b7bbbbb397aaaaa997aaaaa997a77aa980888808808008088088880880888808000000000000000000000000
00e788007007700709aaaaa98eeeeee81cccccc13b5bb5b39aaaaaa99aa77aa99a7aa7a980000008800880088080080808000080000000000000000000000000
008888007007700709aaaaa98eeeeee801cccc103bb55bb39aaaaaa99aa77aa99a7aa7a980800808800000088008800808088080000000000000000000000000
00088000707007079999999008eeee8001cccc103b5bb5b39aaaaaa99aaaaaa99aa77aa908088080080000808008800800800800000000000000000000000000
000000007000000700000000008ee800001cc1003bbbbbb309aaaa9009aaaa9009aaaa9080800808080880800880088000800800000000000000000000000000
00000000077777700000000000088000000110000333333000999900009999000099990008000080008008000800008000088000000000000000000000000000
00000000000000000000000000000000000000000000000000222200002222000022220000000000000000000000000000000000000000000000000000000000
00000000880000880000000000000000000000000000000008e8882008e8882008e8882000000000000000000000000000000000000000000000000000000000
000d500080800808000000000000000000000000000000002e8888822e8888822e8ee88200000000000000000000000000000000000000000000000000000000
00d75500800880080999999900000000000000000000000028888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
0055550080088008099999998eeeeee801cccc103bb55bb328888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
00055000808008080000000008eeee8001cccc103b5bb5b32888888228888882288ee88200000000000000000000000000000000000000000000000000000000
000000008000000800000000008ee800001cc1003bbbbbb302888820028888200288882000000000000000000000000000000000000000000000000000000000
00000000088888800000000000088000000110000333333000222200002222000022220000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000099990000999900009099000090990000900900000000000000000000000000
000000000000000000000000000000000000000000000000000000000099990009aaaa900999aa900999aa900999aa9009090090000000000000000000000000
000c100000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa99a999a999a999a0990990000909000000000000000000000000
00c71100000000000000000000000000000000000000000000999900099aa9909aaaaaa999aaaaa9999a99a99900900990000009000000000000000000000000
00111100000000000000000000000000000000000000000000999900099aa9909aaaaaa999a999a9099999000909900000000000000000000000000000000000
0001100000000000000000000000000000000000000000000009900009a99a909aaaaaa999aa9aa9900909999009009990000099000000000000000000000000
000000000000000000000000008ee800001cc1003bbbbbb3000000000099990009aaaa9009999a90099909900990009009000090000000000000000000000000
00000000000000000000000000088000000110000333333000000000000000000099990000999900000909000009090000090900000000000000000000000000
00000000000000000000077777700000000000000000000000000033b00000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000077dd666d77000000999999999000000000033300000000000009999900000000000000000000000000000000000000000000000000000
00f000000000f000007d66666666d7000090000000009000000b3333333300000000990000099000000000000000000000000000000000000000000000000000
00a900000009a0000766666666666670009000000000900000b77bbbbbb730000009000000000900000000000000000000000000000000000000000000000000
000a900000090000076666666666667000900099999990000037bbbbbbbb30000090009999900900000000000000000000000000000000000000000000000000
0000a900009a000007d6066666606d700090090000000000003bb3333333b0000090099000099000000000000000000000000000000000000000000000000000
00000a9009a0000007d6006666006d700090009999000000003bbb33330000000090000990000000000000000000000000000000000000000000000000000000
0000009099000000007d08066080d7000090000000990000003bbbbbbb3300000009900009990000000000000000000000000000000000000000000000000000
00000009900000000007d666666d7000000990000000900000033bbbbbbb30000000099000009000000000000000000000000000000000000000000000000000
000000999000000000076660066670000000099990009000000003333bbb30000000000999000900000000000000000000000000000000000000000000000000
000e0990099000000007766666677000000000000900900000b3333333bb30000009900000900900000000000000000000000000000000000000000000000000
00002900009e0e0000076066660670000099999990009000003bbbbbbbb730000090099999000900000000000000000000000000000000000000000000000000
000e20000002200000066707070660000090000000009000003bbbbbbb77b0000090000000009000000000000000000000000000000000000000000000000000
00e2020000202e000007667070667000009000000000900000033333333b00000009900000990000000000000000000000000000000000000000000000000000
00200000000002200000766666670000000999999999000000000033300000000000099999000000000000000000000000000000000000000000000000000000
000000000000000000000777777000000000000000000000000000b3300000000000000000000000000000000000000000000000000000000000000000000000
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
011000000207500075020750007502075000750207500075020750c075020750c075020750c075020750c0750207500075020750007502075000750207500075020750c075020750c075020750c075020750c075
010f00202b054290542b054270542b05427054220541f0541d0511d0521b0511b0521b0511b0521f05122052220541f0541d0541b0541b0541d0542205424054240542705424054220541f0541f0542205422054
1d1000000605204052060520405206052040520605204052080520505208052050520805205052080520505206052040520605204052060520405206052040520805205052080520505208052050520805205052
011000003501235012350123501235022350223502235022350323503235032350323505235052350523505237012370123701237012370223702237022370223703237032370323703237042370423704237042
1910000013152131521315213152131521315217152181521a1521a1521a1521a1521a1521a15217152181521a1521a1521a1521a152131521315213152131521f1521f1521f1521f1521f1521f1521f1521f152
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
03 090a4344
03 0b0c4344
00 0d424344

