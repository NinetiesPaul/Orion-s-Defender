pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- general code

function _init()
	-- encounters variable
	encounters = {}
	-- 3 police
	-- 3 random civilian
	-- quests (ransom, kidnap, help raid, avoid raid)
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
	r_fuel = 0
	r_scraps = 0
	-- player variables
	cooldown_lvls = {3,2,1}
	scraps = 25
	ship_spr = 017
	ship_x = 64
	ship_y = 118
	fuel = 25
	fuel_comsumption = 0.02
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
	warned = true
	random_factor = 0.90
	collateral_type =
	{
		1, -- motor damage
		2, -- aiming damage
		3 -- firing damage
	}
	-- store variables
	shop_selector_spr = {002,018,034}
	shop_selector_y = 30
	shop_selector_pos = 1
	shop_selector_spr_pointer = 1
	shop_last_bought = ""
	next_armor_upgrade_cost = 75 * current_stat_armor_lvl
	next_health_upgrade_cost = 50 * current_stat_health_lvl
	next_gun_upgrade_cost = 100 * current_stat_gun_lvl
	next_cooldown_upgrade_cost = 100 * current_stat_cooldown_lvl
	last_encounter_store = true
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
			["knowledge_level"] = 0
		},
		{
			["spr_ok"] = 010,
			["spr_damage"] = 026,
			["b_health"] = 2,
			["b_damage"] = 2,
			["b_shot_speed"] = 2,
			["b_speed"] =  1,
			["b_cdr"] = 60,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0
		},
		{
			["spr_ok"] = 011,
			["spr_damage"] = 027,
			["b_health"] = 5,
			["b_damage"] = 1,
			["b_shot_speed"] = 1.5,
			["b_speed"] =  1.5,
			["b_cdr"] = 45,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0
		},
		{
			["spr_ok"] = 012,
			["spr_damage"] = 028,
			["b_health"] = 4,
			["b_damage"] = 2,
			["b_shot_speed"] = 2,
			["b_speed"] =  2,
			["b_cdr"] = 30,
			["n_destroyed"] = 0,
			["knowledge_level"] = 0
		}
	}
	enemies = {}
	enemy_bullets = {}
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
		if (clock % 5 == 0 and ship_spr == 033) ship_spr = 017
		create_enemy_bullet()

		spr(ship_spr,ship_x,ship_y)

		draw_cooldown()
		foreach(enemies, draw_enemy)
		foreach(enemy_bullets, draw_enemy_bullet)
		foreach(bullets, draw_bullet)
	end
 
	if current_view == 3 then -- rewards
		destroy()

		print("you've won!", 40,64)
		print("added "..r_fuel.." fuel", 40,72)
		print("added "..r_scraps.." scraps", 40,80)
		print("press z or x to continue", 18, 104)
	end
 
	if current_view == 4 then -- store
		draw_ui()
		destroy()

		print("buy fuel -- $4", 10, 32)
		print("repair hull -- $5", 10, 40)
		print("repair armor -- $6", 10, 48)
		print("upgrade hull -- $" .. next_health_upgrade_cost, 10, 56)
		print("upgrade armor -- $" .. next_armor_upgrade_cost, 10, 64)
		print("upgrade gun damage -- $" .. next_gun_upgrade_cost, 10, 72)
		print("upgrade gun cooldown -- $" .. next_cooldown_upgrade_cost, 10, 80)

		if (clock % 90 == 0) shop_last_bought = ""
		print(shop_last_bought, 10, 22)

		print("up or down - change", 2, 120)
		print("z - select", 2,104)
		print("x - exit", 2, 112)

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
		print("orion's defender",44,64)
		print("press z or x to start", 18, 104)
	end
 
	if current_view == 7 then -- help
		print("help screen", 40, 2)

		spr(017, 2, 12)
		print("this is your ship. \nyou can only move sideways", 11, 10)

		spr(001, 1, 26)
		print("when in battle, \npress 'z' to shoot", 10, 24)
		spr(049, 1, 39)
		print("a red shot means critical\ndamage", 10, 37)

		spr(000, 1, 53)
		print("this is an encounter pickup\nit can be anything", 10, 52)

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
	move()
	update_threat()

	if current_view == 1 then
		fuel -= fuel_comsumption
		if (clock % 30 == 0) create_encounter()
	end

	if current_view == 2 then
		if (count(enemies) == 0)	start_battle()
		if (bullet_cooldown == 0) fire()
		if clock % 30 == 0 and bullet_cooldown != 0 then
			bullet_cooldown -= 1
		end
		gun_ready()
	end

	if current_view == 3 then
		warned = true
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

	foreach(enemies, move_enemy)
	foreach(bullets, move_bullet)
	foreach(enemy_bullets, move_enemy_bullet)
	foreach(encounters, move_encounter)
end

function start_battle()
	enemy_count = (flr(rnd(3)) + 1) * difficulty

	while(enemy_count > 0)
	do
		enemy_data = enemy_list[flr(rnd(count(enemy_list)))+1]
		local enemy = {}
		enemy.spr = enemy_data["spr_ok"]
		enemy.spr_damage = enemy_data["spr_damage"]
		enemy.health = enemy_data["b_health"] + (difficulty - 1)
		enemy.damage = enemy_data["b_damage"] + (difficulty - 1)
		enemy.shot_v = enemy_data["b_shot_speed"] + (difficulty - 1)
		enemy.v = enemy_data["b_speed"]
		enemy.x = flr(rnd(15))+15
		enemy.y = flr(rnd(15))+15
		enemy.sx = enemy.x
		enemy.sy = enemy.y
		enemy.lx = enemy.x+rnd(30)+30
		enemy.ly = enemy.y+rnd(30)+30
		enemy.move_forward = true
		enemy.fire = true
		enemy.cdr = enemy_data["b_cdr"]
		enemy.collateral = false
		add(enemies, enemy)
		enemy_count -= 1
	end

	ship_x = 64
	encounters = {}
end

function rewards()
	if rewards_given == false then
		x = difficulty * (flr(rnd(5)) + 1)
		fuel += x
		r_fuel = x
		scraps_reward = x * 10
		scraps += scraps_reward
		r_scraps = scraps_reward
		rewards_given = true
		bullet_cooldown = 0
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
end

function draw_ui()
	print("$" .. scraps,2,2)
	if (current_view != 4) print("★ " .. score,2,8, 7)
	spr(003,76,2)
	print(health,85,4)
	spr(004,93,2)
	print(armor,102,4)
	spr(005,110,2)
	print(fuel,119,4)
	
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
	if (score > 2000 and score < 4000) difficulty = 2
	if (score > 4000) difficulty = 3
	if (difficulty == 2) threat_level = 022
	if (difficulty == 3) threat_level = 038
end

function draw_threat()
	threat_x = difficulty
	update = 5
	if (threat_x == 2) update = 3
	if (threat_x == 3) update = 2
	
	if (clock % update == 0) then
		threat_y += 1
		if(threat_y > 3) threat_y = 1
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
	spr(000,e.x, e.y)
end

function move_encounter(e)
	e.y += 3

	if e.x >= ship_x-4 and
	e.x <= ship_x+6 and
	e.y >= ship_y-4 and
	e.y <= ship_y+6 then
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

	if (e.y >= 128) then
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

function gun_ready()
	if bullet_cooldown == 0 and warned == false then
		sfx(03)
		warned = true
	end
end
-->8
-- player

function fire()
	if btnp(4) then
		local bullet = {}
		bullet.x = ship_x
		bullet.y = ship_y - 8
		--bullet.critical = (rnd() > random_factor) and true or false
		bullet.critical = false
		bullet.spr = (bullet.critical == true) and 049 or 001

		bullet_cooldown = bullet_cooldown_rate
		warned = false
		sfx(07)
		add(bullets, bullet)
	end
end

function draw_bullet(b)
	spr(b.spr,b.x,b.y)
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
			if (b.critical == true) damage = damage + (flr(rnd(2)) + 1)
			e.health -= damage

			if e.collateral == false then
				for el in all(enemy_list) do
					if e.spr == el.spr_ok then
						local_random_factor = random_factor - el.knowledge_level
						if (rnd() > local_random_factor) e.collateral = rnd(collateral_type)
					end
				end
			end

			sfx(04)
			del(bullets,b)

			if (e.health <= 0) then
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

				del(enemies,e)
				score += 100
				sfx(05)
			end

			if (count(enemies) == 0) current_view = views[3]
		end
	end
end

function move()
	if (btn(1) and ship_x < 120) ship_x+=2
	if (btn(0) and ship_x > 0) ship_x-=2
	--if (btn(2) and ship_y > 0) ship_y-=2
	--if (btn(3) and ship_y < 120) ship_y+=2
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
	for e in all(enemies) do
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
end

function move_enemy_bullet(eb)
	eb.x += (eb.aimless == false) and cos(eb.angle) * eb.v or 0
	eb.y += (eb.aimless == false) and sin(eb.angle) * eb.v or eb.v

	if eb.x >= ship_x-4 and
	eb.x <= ship_x+6 and
	eb.y >= ship_y-4 and
	eb.y <= ship_y+6 then
		del(enemy_bullets,eb)
		ship_spr = 033
		sfx(06)

		if (armor == 0) health-=eb.damage
		if (armor > 0) then 
			armor-=eb.damage
			if (armor < 0) armor = 0
		end
		if (health <= 0) current_view = views[5]
	end
end

function move_enemy(e)
	if e.collateral != 1 then
		if e.move_forward == true then
			if (e.x<e.lx) e.x+=e.v
			if (e.y<e.ly) e.y+=e.v
			if e.y>=e.ly and
			e.x>=e.lx then
				e.move_forward = false
			end
		end

		if e.move_forward == false then
			if (e.x>e.sx) e.x-=e.v
			if (e.y>e.sy) e.y-=e.v
			if e.y<=e.sy and
			e.x<=e.sx then
				e.move_forward = true
			end
		end
	end
end

function draw_enemy(e)
	spr(e.spr,e.x,e.y)
	print(e.health,e.x + 9,e.y, 10)
	-- if (clock % 5 == 0 and e.spr == 025) e.spr = 009  
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
		if shop_selector_pos == 1 then
			if scraps >= 4 then
				sfx(01)
				fuel += 1
				scraps -= 4
				shop_last_bought = "bought 1 fuel"
			else 
				sfx(00)
				shop_last_bought = "not enough scrap"
			end
		end
		
		if shop_selector_pos == 2 then
			if health < current_max_health then
				if scraps >= 5 then
					sfx(01)
					health += 1
					scraps -= 5
					shop_last_bought = "repaired 1 hull point"
				else
					sfx(00)
					shop_last_bought = "not enough scrap"
				end
			else
				sfx(00)
				shop_last_bought = "current at max health"
			end
		end
		
		if shop_selector_pos == 3 then
			if armor < current_max_armor then
				if scraps >= 6 then
					sfx(01)
					armor += 1
					scraps -= 6
					shop_last_bought = "repaired 1 armor point"
				else
					sfx(00)
					shop_last_bought = "not enough scrap"
				end
			else
				sfx(00)
				shop_last_bought = "current at max armor"
			end
		end
		
		if shop_selector_pos == 4 then
			if current_stat_health_lvl < 3 then
				if scraps >= next_health_upgrade_cost then
					sfx(01)
					scraps -= next_health_upgrade_cost
					current_stat_health_lvl += 1
					next_health_upgrade_cost = 50 * current_stat_health_lvl
					current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier
					shop_last_bought = "hull upgraded"
				else 
					sfx(00)
					shop_last_bought = "not enough scrap"
				end
			else
				sfx(00)
				shop_last_bought = "hull maxed out"
			end
		end

		if shop_selector_pos == 5 then
			if current_stat_armor_lvl < 3 then
				if scraps >= next_armor_upgrade_cost then
					sfx(01)
					scraps -= next_armor_upgrade_cost
					current_stat_armor_lvl += 1
					next_armor_upgrade_cost = 75 * current_stat_armor_lvl
					current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
					shop_last_bought = "armor upgraded"
				else 
					sfx(00)
					shop_last_bought = "not enough scrap"
				end
			else
				sfx(00)
				shop_last_bought = "armor maxed out"
			end
		end

		if shop_selector_pos == 6 then
			if current_stat_gun_lvl < 3 then
				if scraps >= next_gun_upgrade_cost then
					sfx(01)
					scraps -= next_gun_upgrade_cost
					current_stat_gun_lvl += 1
					bullet_damage = current_stat_gun_lvl 
					next_gun_upgrade_cost = 100 * current_stat_gun_lvl
					shop_last_bought = "gun damage upgraded"
				else
					sfx(00)
					shop_last_bought = "not enough scrap"
				end
			else
				sfx(00)
				shop_last_bought = "gun damage maxed out"
			end
		end

		if shop_selector_pos == 7 then
			if current_stat_cooldown_lvl < 3 then
				if scraps >= next_cooldown_upgrade_cost then
					sfx(01)
					scraps -= next_cooldown_upgrade_cost
					current_stat_cooldown_lvl += 1
					bullet_cooldown_rate = cooldown_lvls[current_stat_cooldown_lvl] 
					next_cooldown_upgrade_cost = 100 * current_stat_cooldown_lvl
					shop_last_bought = "gun cooldown upgraded"
				else
					sfx(00)
					shop_last_bought = "not enough scrap"
				end
			else
				sfx(00)
				shop_last_bought = "gun cooldown maxed out"
			end
		end
		
	end
 
	if btnp(3) and shop_selector_pos < 7 then
		sfx(02)
		shop_selector_y += 8
		shop_selector_pos += 1
	end
	
	if btnp(2) and shop_selector_pos > 1 then
		sfx(02)
		shop_selector_y -= 8
  	shop_selector_pos -= 1
	end
end

function animate_shop_selector()
	shop_selector_spr_pointer += 1
	if (shop_selector_spr_pointer > 3) shop_selector_spr_pointer = 1
	spr(shop_selector_spr[shop_selector_spr_pointer], 0, shop_selector_y)
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
0000000070700707999999908eeeeee81cccccc1b7bbbbb397aaaaa997aaaaa997a77aa980888808808008088088880880888808000000000000000000000000
000000007007700709aaaaa98eeeeee81cccccc13b5bb5b39aaaaaa99aa77aa99a7aa7a980000008800880088080080808000080000000000000000000000000
000000007007700709aaaaa98eeeeee801cccc103bb55bb39aaaaaa99aa77aa99a7aa7a980800808800000088008800808088080000000000000000000000000
00000000707007079999999008eeee8001cccc103b5bb5b39aaaaaa99aaaaaa99aa77aa908088080080000808008800800800800000000000000000000000000
000000007000000700000000008ee800001cc1003bbbbbb309aaaa9009aaaa9009aaaa9080800808080880800880088000800800000000000000000000000000
00000000077777700000000000088000000110000333333000999900009999000099990008000080008008000800008000088000000000000000000000000000
00000000000000000000000000000000000000000000000000222200002222000022220000000000000000000000000000000000000000000000000000000000
00000000880000880000000000000000000000000000000008e8882008e8882008e8882000000000000000000000000000000000000000000000000000000000
0000000080800808000000000000000000000000000000002e8888822e8888822e8ee88200000000000000000000000000000000000000000000000000000000
00000000800880080999999900000000000000000000000028888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
0000000080088008099999998eeeeee801cccc103bb55bb328888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
00000000808008080000000008eeee8001cccc103b5bb5b32888888228888882288ee88200000000000000000000000000000000000000000000000000000000
000000008000000800000000008ee800001cc1003bbbbbb302888820028888200288882000000000000000000000000000000000000000000000000000000000
00000000088888800000000000088000000110000333333000222200002222000022220000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000e788000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000008ee800001cc1003bbbbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000088000000110000333333000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000000000000040000100000000230000000016000160003000029000060003007008000050002b070090000a0001100015000000001b0001e0002200031000280002a0002d00032000370003d00017000
000100000000000000000000000000000000000000000000000000000000000000002a070000002e0003007000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003f07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000350003a000120501405016050190501b0501e050200502305026070280702b0702f0502c0002f00000000320003700037000000000000000000000000000000000000000000000000000000000000000
0001000000000000000000000000300502f050323502c3502c0502a050321502e1702b15022050292502525022250202502415022150211501805016050150500000000000000000000000000000000000000000
00020000000000000004500045002e6002e6002e6002c6702b670296702e60025670246702e6002e600206702e6001d6701a670196701667014670116700e6700d67005500006000060000600000000160001600
00030000086701d6701d6701d6701d6701d670146701d6701d6700f6701d6700c6701d6701d6701d67027500285002a5002c5002d5002e500315003150033500355003e6003e6003e6003e6003e6003e6003e600
0001000000000000000000000000000701a1701b1701c1701e17020170201702217024170261702717027170281702b1702d1702f100311003310036100361000000000000000000000000000000000000000000
00010000000000000000000000002f1502c150291502715026150251501b1501a1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
