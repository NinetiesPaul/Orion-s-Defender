pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--general code
threat_level_sprs = {
{006,007,008},
{022,023,024},
{038,039,040}
}
threat_y = 1

score = 0
difficulty = 1
scraps = 10

clock = 0

views = {
1, -- 1 world
2, -- 2 battle
3, -- 3 rewards
4, -- 4 store
5} -- 5 game over
current_view = views[1]

rewards = false
rewards_given = false
last_encounter_store = false

function _draw()
 cls()
 
 if current_view == 1 then
  draw_ui()
  draw_threat()
  
		spr(ship_spr,ship_x,ship_y)
		
  foreach(encounters, draw_encounter)
 end
 
 if current_view == 2 then
  draw_ui()
  if (clock % 5 == 0 and ship_spr == 033) ship_spr = 017
  if (clock % 30 == 0) create_enemy_bullet()
  
  spr(ship_spr,ship_x,ship_y)
  
  foreach(enemies, draw_enemy)
  foreach(enemy_bullets, draw_enemy_bullet)
  foreach(bullets, draw_bullet)
 end
 
 if current_view == 3 and rewards_given == true then
  cls()
  print("you've won!", 40,64)
  print("added "..r_fuel.." fuel", 40,72)
  print("added "..r_scraps.." scraps", 40,80)
  
  destroy()
 end
 
 if current_view == 4 then
 	print ("store", 0, 0, 7)
 	print("$ " .. scraps,0,10)
 	
	 spr(003,83,0)
	 print(health,92,2)
	 spr(004,97,0)
	 print(armor,106,2)
	 spr(005,111,0)
	 print(fuel,120,2)
 	
 	print("buy fuel -- $4", 10, 32)
 	print("repair hull -- $5", 10, 40)
 	print("repair armor -- $6", 10, 48)
 	print("upgrade hull -- $" .. next_health_upgrade_cost, 10, 56)
 	print("upgrade armor -- $" .. next_armor_upgrade_cost, 10, 64)
 	print("upgrade gun -- $" .. next_gun_upgrade_cost, 10, 72)
 	
 	if (clock % 90 == 0) shop_last_bought = ""
 	print(shop_last_bought, 10, 22)
 	
 	print("up or down - change", 0, 120)
 	print("z - select", 0,104)
 	print("x - exit", 0, 112)
 	
 	animate_shop_selector()
 end
 
 if current_view == 5 then
  cls()
  print("game over",44,64)
  if (health <= 0) print("you were destroyed",54,72)
  if (fuel <= 0) print("you ran out of fuel",34,72)
  
  destroy()
 end
end

function _update()
 clock+=1
 move()
 fire()
 update_threat()
 
 if (current_view == 1) fuel-=fuel_comsumption
 if (clock % 30 == 0 and current_view == 1) create_encounter()
 foreach(enemies, move_enemy)
 foreach(bullets, move_bullet)
 foreach(enemy_bullets, move_enemy_bullet)
 foreach(encounters, move_encounter)
 if (current_view == 2 and enemy_count == 0) start_battle()
 if current_view == 3 then
 	if (rewards_given == false) give_rewards() 
		if (rewards_given == true) restart()
	end
	if current_view == 4 then
		nav_store()
	end
	if current_view != 1 then
		encounters = {}
	end
end

function start_battle()
 enemy_count = flr(rnd(6)) + 1
 enemy_count = enemy_count * difficulty
 
 for enemy_count = enemy_count,0,-1 do
  local enemy = {}
  enemy.spr = 016
  enemy.x = flr(rnd(15))+15
  enemy.y = flr(rnd(15))+15
  enemy.sx = enemy.x
  enemy.sy = enemy.y
  enemy.lx = enemy.x+rnd(30)+30
  enemy.ly = enemy.y+rnd(30)+30
  enemy.move_forward = true
  enemy.health = 3 * difficulty
  dy = flr(rnd(4))  +1
  enemy.dy = dy
  add(enemies, enemy)
 end
 
 enemy_count += 1
 ship_x = 64
 ship_y = 104
 for e in all(encounters) do
  del(encounters,e)
 end
end

function give_rewards()
 x = difficulty * flr(rnd(5)) + 1
 fuel += x
 r_fuel = x
 scraps_reward = x * 10
 scraps += scraps_reward
 r_scraps = scraps_reward
 rewards_given = true
end

function restart()
 if btnp(4) or btnp(5) and current_view == 3 then
  current_view = views[1]
  rewards_given = false
 end
end

function destroy()
 enemies = {}
 enemy_bullets = {}
 bullets = {}
end

function draw_ui()
 print("★ " .. score,0,0, 7)
 print("$ " .. scraps,0,10)
 
 spr(003,0,110)
 print(health,10,112)
 spr(004,0,120)
 print(armor,10,122)
 
 if current_view == 1 then
 	spr(005,106,120)
 	print(flr(fuel),115,122)
 end
 
 if current_view == 2 then
 	spr(016,106,112)
 	print(enemy_count,115,114)
 end
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
	
	spr(threat_level_sprs[threat_x][threat_y],120,0)
end
-->8
--encounters
types = {
1, -- battle
2 -- store
}
encounters = {}
encounter_spawn_x = {12,36,64,96,108}

function create_encounter()
 local encounter = {}
 number = flr(rnd(5)) + 1
 encounter.x = encounter_spawn_x[number]
 encounter.y = 0
 encounter.type = types[flr(rnd(2)) + 1]
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
-->8
--player
ship_spr = 017
ship_x = 64
ship_y = 120
fuel = 25
fuel_comsumption = 0.02
stat_multiplier = 5
stat_lvl = {1,2,3}
current_stat_armor_lvl = 1
current_stat_health_lvl = 1
current_stat_gun_lvl = 1
current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier 
current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
health = current_max_health
armor = current_max_armor
bullet_damage = current_stat_gun_lvl
bullet_cooldown = 3
bullets = {}

function fire()
 if btnp(4) and 
    current_view == 2 then
  local bullet = {}
  bullet.x = ship_x
  bullet.y = ship_y - 8
  add(bullets, bullet)
 end
end

function draw_bullet(b)
 spr(001,b.x,b.y)
end

function move_bullet(b)
 b.y -= 4
 
 for e in all(enemies) do
  if e.x >= b.x-4 and
     e.x <= b.x+6 and
     e.y >= b.y-4 and
     e.y <= b.y+6 then 
   e.health -= bullet_damage
   e.spr = 032
  	del(bullets,b)
   
   if (e.health <= 0) then
  	 del(enemies,e)
   	enemy_count -= 1
   	score += 100
  	end
  	
  	if (enemy_count == 0) current_view = views[3]
  end
 end
end

function move()
 if (btn(1) and ship_x < 120) ship_x+=2
 if (btn(0) and ship_x > 0) ship_x-=2
 --if (btn(2) and ship_y > 0) ship_y-=2
 --if (btn(3) and ship_y < 120) ship_y+=2
end
-->8
--enemies
enemies = {}
enemy_bullets = {}
enemy_count = 0

function create_enemy_bullet(e)
 for e in all(enemies) do
  local enemy_bullet = {}
  enemy_bullet.damage = difficulty * 1
  enemy_bullet.x = e.x
  enemy_bullet.y = e.y+8
  enemy_bullet.angle=atan2(ship_x - e.x, ship_y - e.y)
  enemy_bullet.v = flr(rnd(3)) + 1
  enemy_bullet.dy = e.dy
  add(enemy_bullets,enemy_bullet)
 end
end

function draw_enemy(e)
 spr(e.spr,e.x,e.y)
 print(e.health,e.x+9,e.y)

 if (clock % 5 == 0 and e.spr == 032) e.spr = 016  
 --endpoint = e.x+16
 --line(e.x+8,e.y,endpoint,e.y, 11)
end

function draw_enemy_bullet(eb)
 spr(001,eb.x,eb.y)
end

function move_enemy_bullet(eb)
	eb.x+=cos(eb.angle) * eb.v
	eb.y+=sin(eb.angle) * eb.v
	
 if eb.x >= ship_x-4 and
    eb.x <= ship_x+6 and
    eb.y >= ship_y-4 and
    eb.y <= ship_y+6 then
  del(enemy_bullets,eb)
  ship_spr = 033
  
  if (armor == 0) health-=eb.damage
  if (armor > 0) then 
  	armor-=eb.damage
  	if (armor < 0) armor = 0
  end
  if (health <= 0) current_view = views[5]
 end	
end

function move_enemy(e)
 if e.move_forward == true then
  if (e.x<e.lx) e.x+=0.5
  if (e.y<e.ly) e.y+=0.5
  if e.y>=e.ly and
     e.x>=e.lx then
   e.move_forward = false
  end
 end
 
 if e.move_forward == false then
  if (e.x>e.sx) e.x-=0.5
  if (e.y>e.sy) e.y-=0.5
  if e.y<=e.sy and
     e.x<=e.sx then
   e.move_forward = true
  end
 end
end
-->8
-- store
shop_selector_spr = {002,018,034}
shop_selector_y = 30
shop_selector_pos = 1
shop_selector_spr_pointer = 1
shop_last_bought = ""
next_armor_upgrade_cost = 75 * current_stat_armor_lvl
next_health_upgrade_cost = 50 * current_stat_health_lvl
next_gun_upgrade_cost = 100 * current_stat_gun_lvl

function nav_store()
	if btnp(5) then
	 current_view = views[1]
		shop_last_bought = ""
	end
	
	if btnp(4) then
		if shop_selector_pos == 1 then
			if scraps >= 4 then
				fuel += 1
				scraps -= 4
				shop_last_bought = "bought 1 fuel"
			else 
				shop_last_bought = "not enough scrap"
			end
		end
		
		if shop_selector_pos == 2 then
			if health < current_max_health then
				if scraps >= 5 then
					health += 1
					scraps -= 5
					shop_last_bought = "repaired 1 hull point"
				else 
					shop_last_bought = "not enough scrap"
				end
			else
			 shop_last_bought = "current at max health"
			end
		end
		
		if shop_selector_pos == 3 then
			if armor < current_max_armor then
				if scraps >= 6 then
					armor += 1
					scraps -= 6
					shop_last_bought = "repaired 1 armor point"
				else 
					shop_last_bought = "not enough scrap"
				end
			else
			 shop_last_bought = "current at max armor"
			end
		end
		
		if shop_selector_pos == 4 then
			if current_stat_health_lvl < 3 then
				if scraps >= next_health_upgrade_cost then
					scraps -= next_health_upgrade_cost
					current_stat_health_lvl += 1
					next_health_upgrade_cost = 50 * current_stat_health_lvl
					current_max_health = stat_lvl[current_stat_health_lvl] * stat_multiplier
					shop_last_bought = "hull upgraded"
				else 
					shop_last_bought = "not enough scrap"
				end
			else
				shop_last_bought = "hull maxed out"
			end
		end

		if shop_selector_pos == 5 then
			if current_stat_armor_lvl < 3 then
				if scraps >= next_armor_upgrade_cost then
					scraps -= next_armor_upgrade_cost
					current_stat_armor_lvl += 1
					next_armor_upgrade_cost = 75 * current_stat_armor_lvl
					current_max_armor = stat_lvl[current_stat_armor_lvl] * stat_multiplier
					shop_last_bought = "armor upgraded"
				else 
					shop_last_bought = "not enough scrap"
				end
			else
				shop_last_bought = "armor maxed out"
			end
		end

		if shop_selector_pos == 6 then
			if current_stat_gun_lvl < 3 then
				if scraps >= next_gun_upgrade_cost then
					scraps -= next_gun_upgrade_cost
					current_stat_gun_lvl += 1
					bullet_damage = current_stat_gun_lvl 
					next_gun_upgrade_cost = 100 * current_stat_gun_lvl
					shop_last_bought = "gun upgraded"
				else 
					shop_last_bought = "not enough scrap"
				end
			else
				shop_last_bought = "gun maxed out"
			end
		end
	end
 
 if btnp(3) and shop_selector_pos < 6 then
  shop_selector_y += 8
  shop_selector_pos += 1
 end
	
	if btnp(2) and shop_selector_pos > 1 then
		shop_selector_y -= 8
  shop_selector_pos -= 1
	end

end

function animate_shop_selector()
	if (clock % 1.5 == 0) then
		shop_selector_spr_pointer += 1
	 if (shop_selector_spr_pointer > 3) shop_selector_spr_pointer = 1
	end
	
	spr(shop_selector_spr[shop_selector_spr_pointer], 0, shop_selector_y)
end
__gfx__
0000000000000000000000000e800880011111d000b3333000333300003333000033330000000000000000000000000000000000000000000000000000000000
008888000000000099999900efe88ee81ccccc6d0b7bbbb30b7bbb300b7bbb300b7bbb3000000000000000000000000000000000000000000000000000000000
087fee80000aa0009aaaaa908eeeeee81cccccc1b7bbbbb337bbbbb337bbbbb337b77bb300000000000000000000000000000000000000000000000000000000
08feee8000a7aa0009aaaaa98eeeeee81cccccc13b5bb5b33bbbbbb33bb77bb33b7bb7b300000000000000000000000000000000000000000000000000000000
08eeee8000aaaa0009aaaaa98eeeeee801cccc103bb55bb33bbbbbb33bb77bb33b7bb7b300000000000000000000000000000000000000000000000000000000
08eeee80000aa0009aaaaa9008eeee8001cccc103b5bb5b33bbbbbb33bbbbbb33bb77bb300000000000000000000000000000000000000000000000000000000
008888000000000099999900008ee800001cc1003bbbbbb303bbbb3003bbbb3003bbbb3000000000000000000000000000000000000000000000000000000000
00000000000000000000000000088000000110000333333000333300003333000033330000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000999900009999000099990000000000000000000000000000000000000000000000000000000000
7000000777000077000000000000000000000000000000000a7aaa900a7aaa900a7aaa9000000000000000000000000000000000000000000000000000000000
7070070770700707999999908eeeeee81cccccc1b7bbbbb397aaaaa997aaaaa997a77aa900000000000000000000000000000000000000000000000000000000
700770077007700709aaaaa98eeeeee81cccccc13b5bb5b39aaaaaa99aa77aa99a7aa7a900000000000000000000000000000000000000000000000000000000
700770077007700709aaaaa98eeeeee801cccc103bb55bb39aaaaaa99aa77aa99a7aa7a900000000000000000000000000000000000000000000000000000000
70700707707007079999999008eeee8001cccc103b5bb5b39aaaaaa99aaaaaa99aa77aa900000000000000000000000000000000000000000000000000000000
770000777000000700000000008ee800001cc1003bbbbbb309aaaa9009aaaa9009aaaa9000000000000000000000000000000000000000000000000000000000
00000000077777700000000000088000000110000333333000999900009999000099990000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000222200002222000022220000000000000000000000000000000000000000000000000000000000
80000008880000880000000000000000000000000000000008e8882008e8882008e8882000000000000000000000000000000000000000000000000000000000
8080080880800808000000000000000000000000000000002e8888822e8888822e8ee88200000000000000000000000000000000000000000000000000000000
80088008800880080999999900000000000000000000000028888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
8008800880088008099999998eeeeee801cccc103bb55bb328888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
80800808808008080000000008eeee8001cccc103b5bb5b32888888228888882288ee88200000000000000000000000000000000000000000000000000000000
880000888000000800000000008ee800001cc1003bbbbbb302888820028888200288882000000000000000000000000000000000000000000000000000000000
00000000088888800000000000088000000110000333333000222200002222000022220000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000008ee800001cc1003bbbbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000088000000110000333333000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00070000000077007770777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000000007007070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770000007007070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777700000007007070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000700000077707770777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77700000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000777777007770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000007000000700070000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007777770077700000007070070700770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070000007000700000077777700777070000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070700707007700000707007770707770000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070077007000700000707077070777000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070077007077700000707770077707000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000070700707000000000700770070777000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000077000077000000000707007070000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000770000770000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077777700777000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000700000070007000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000707007070077000000000000000000000000000077777700777000000000000000000000000000000000000
00000000000000000000000000000000000000000700770070007000000000000000000000000000700000070007000000000000000000000000000000000000
00000000000000000000000000000000000000000700770070777000000000000000000000000000707007070777000000000000000000000000000000000000
00000000000000000000000000000000000000000707007070000000000000000000000000000000700770070700000000000000000000000000000000000000
00000000000000000000000000000000000000000770000770000000000000000000000000000000700770070777000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000707007070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000770000770000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000a7aa00000000000000000aa00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000aaaa0000000000000000a7aa0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000aa00000000000000000aaaa0000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000aa000000000000000aa00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000a7aa000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000aaaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000770000770000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000707007070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000700770070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000700770070000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000707007070000000000000000000000000000000000000000
0e80088000000000000000000000000000000000000000000000000aa00000000000000000000000700000070000000000000000000000000000000000000000
efe88ee80000000000000000000000000000000000000000000000a7aa0000000000000000000000077777700000000000000000000000000000000000000000
8eeeeee80070000000000000000000000000000000000000aa0000aaaa0000000000000000000000000000000000000000000000000777777000000000000000
8eeeeee8007000000000000000000000000000000000000a7aa0000aa00000000000000000000000000000000000000000000000007000000700000000000000
8eeeeee80077700000000000000000000000000000000aaaaaa00000000000000000000000000000000000000000000000000000007070070707770000000000
08eeee80007070000000000000000000000000000000a7aaaa000000000000000000000000000000000000000000000000000000007007700707000000000000
008ee800007770000000000000000000000000000000aaaa00000000000000000000000000000000000000000000000000000000007007700707770000000000
000880000000000000000000000000000000000000000aa000000000000000000000000000000000000000000000000000000000007070070700070000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007700007707770000000000
00000000000000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000
011111d000000000000000000000000000000000000000000000000000000000000a7aa000000000000000000000000000000000000000000000000000000000
1ccccc6d000000000000000000000000000000000000000000000000000000000aaaaaa000000000000000000000000000000000000000000000000000000000
1cccccc100700000000000000000000000000000000000000000000000000000a7aaaa0000000000000000000000000000000000000000000000000000000000
1cccccc100700000000000000000000000000000000000000000000000000000aaaa000000000000000000000000000000000000000000000000000000000000
01cccc10007770000000000000000000000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000
01cccc1000707000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001cc1000077700000000000000000000000000a7aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000110000000000000000000000000000aa0000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000000000000000000001000000000000000000160001600016000160001600017000190001a0001c0001d0001f0002000021000000000000000000000000000000000000000000000000000000000000000
