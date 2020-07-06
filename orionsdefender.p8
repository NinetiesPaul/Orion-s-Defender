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

ship_spr = 017
ship_x = 64
ship_y = 120
fuel = 101
fuel_comsumption = 0.02
health = 5
armor = 5
score = 0
bullet_damage = 1
bullet_cooldown = 3
difficulty = 1
scraps = 20

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

enemies = {}
enemy_bullets = {}
enemy_count = 0

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
 
 if current_view == 5 then
  cls()
  print("game over",44,64)
  if (health <= 0) print("you were destroyed",54,72)
  if (fuel <= 0) print("you ran out of fuel",34,72)
  
  destroy()
 end
 
 if current_view == 3 and rewards_given == true then
  cls()
  print("you've won!", 40,64)
  print("added "..r_fuel.." fuel", 40,72)
  print("added "..r_scraps.." scraps", 40,80)
  
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
 for e in all(enemies) do
  del(enemies,e)
 end
 for eb in all(enemy_bullets) do
  del(enemy_bullets,eb)
 end
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
encounters = {}
encounter_spawn_x = {12,36,64,96,108}

function create_encounter()
 local encounter = {}
 number = flr(rnd(5)) + 1
 encounter.x = encounter_spawn_x[number]
 encounter.y = 0
 add(encounters, encounter)
end

function draw_encounter(e)
 spr(002,e.x, e.y)
end

function move_encounter(e)
 e.y += 3
 
 if e.x >= ship_x-4 and
    e.x <= ship_x+6 and
    e.y >= ship_y-4 and
    e.y <= ship_y+6 then
  del(encounters,e)
  current_view = views[2]
 end
end
-->8
--player
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
function create_enemy_bullet(e)
 for e in all(enemies) do
  local enemy_bullet = {}
  enemy_bullet.damage = difficulty * 1
  enemy_bullet.x = e.x
  enemy_bullet.y = e.y+8
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
	eb.y+=eb.dy
	
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
__gfx__
0000000000000000000000000e800880011111d000b3333000333300003333000033330000000000000000000000000000000000000000000000000000000000
000000000000000000888800efe88ee81ccccc6d0b7bbbb30b7bbb300b7bbb300b7bbb3000000000000000000000000000000000000000000000000000000000
00000000000aa000087fee808eeeeee81cccccc1b7bbbbb337bbbbb337bbbbb337b77bb300000000000000000000000000000000000000000000000000000000
0000000000a7aa0008feee808eeeeee81cccccc13b5bb5b33bbbbbb33bb77bb33b7bb7b300000000000000000000000000000000000000000000000000000000
0000000000aaaa0008eeee808eeeeee801cccc103bb55bb33bbbbbb33bb77bb33b7bb7b300000000000000000000000000000000000000000000000000000000
00000000000aa00008eeee8008eeee8001cccc103b5bb5b33bbbbbb33bbbbbb33bb77bb300000000000000000000000000000000000000000000000000000000
000000000000000000888800008ee800001cc1003bbbbbb303bbbb3003bbbb3003bbbb3000000000000000000000000000000000000000000000000000000000
00000000000000000000000000088000000110000333333000333300003333000033330000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000999900009999000099990000000000000000000000000000000000000000000000000000000000
7000000777000077000000000000000000000000000000000a7aaa900a7aaa900a7aaa9000000000000000000000000000000000000000000000000000000000
7070070770700707000000008eeeeee81cccccc1b7bbbbb397aaaaa997aaaaa997a77aa900000000000000000000000000000000000000000000000000000000
7007700770077007000000008eeeeee81cccccc13b5bb5b39aaaaaa99aa77aa99a7aa7a900000000000000000000000000000000000000000000000000000000
7007700770077007000000008eeeeee801cccc103bb55bb39aaaaaa99aa77aa99a7aa7a900000000000000000000000000000000000000000000000000000000
70700707707007070000000008eeee8001cccc103b5bb5b39aaaaaa99aaaaaa99aa77aa900000000000000000000000000000000000000000000000000000000
770000777000000700000000008ee800001cc1003bbbbbb309aaaa9009aaaa9009aaaa9000000000000000000000000000000000000000000000000000000000
00000000077777700000000000088000000110000333333000999900009999000099990000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000222200002222000022220000000000000000000000000000000000000000000000000000000000
80000008880000880000000000000000000000000000000008e8882008e8882008e8882000000000000000000000000000000000000000000000000000000000
8080080880800808000000000000000000000000000000002e8888822e8888822e8ee88200000000000000000000000000000000000000000000000000000000
80088008800880080000000000000000000000000000000028888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
8008800880088008000000008eeeeee801cccc103bb55bb328888882288ee88228e88e8200000000000000000000000000000000000000000000000000000000
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
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888ffffff882222228888888888888888888888888888888888888888888888888888888888888888228228888ff88ff888222822888888822888888228888
88888f8888f882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888222822888882282888888222888
88888ffffff882888828888888888888888888888888888888888888888888888888888888888888882288822888f8ff8f888222888888228882888888288888
88888888888882888828888888888888888888888888888888888888888888888888888888888888882288822888ffffff888888222888228882888822288888
88888f8f8f88828888288888888888888888888888888888888888888888888888888888888888888822888228888ffff8888228222888882282888222288888
888888f8f8f8822222288888888888888888888888888888888888888888888888888888888888888882282288888f88f8888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557777777777770000000000000000000000000000005555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557000000000071111111112222222222333333333305555555
55555550000000000000000000000000000000000000000000000000000000000000000005555557777777777775555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550444444444455555555556666666666777777777705555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555088888888889999999999aaaaaaaaaabbbbbbbbbb05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550ccccccccccddddddddddeeeeeeeeeeffffffffff05555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550000000000000000000000000000000000000000005555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555556667655555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555666555555555555555555555555555555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555666666655555556dddddddddddddddddddddddd5555555555
555555500000000000000000000000000000000000000000000000000000000000000000055555566606665555555655555555555555555555555d5555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555576666666d6666666d666666655555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556666666555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556665666555556667655555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556555556555555666555555555555555555555555555555555
5555555000000000000000000000000000000000000000000000000000000000000000000555555555555555555556dddddddddddddddddddddddd5555555555
555555500000000000000000000000000000000000000000000000000000000000000000055555565555565555555655555555555555555555555d5555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555556665666555555576666666d6666666d666666655555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555550005550005550005550005550005550005550005550005555
555555500000000000000000000000000000000000000000000000000000000000000000055555011d05011d05011d05011d05011d05011d05011d05011d0555
55555550000000000000000000000000000000000000000000000000000000000000000005555501110501110501110501110501110501110501110501110555
55555550000000000000000000000000000000000000000000000000000000000000000005555501110501110501110501110501110501110501110501110555
55555550000000000000000000000000000000000000000000000000000000000000000005555550005550005550005550005550005550005550005550005555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555550000000000000000000000000000000000000000000000000000000000000000005555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555575555555ddd55555d5d5d5d55555d5d555555555d5555555ddd5555550000000055555555555555555555555555555555555555555555555555
555555555555777555555ddd55555555555555555d5d5d55555555d55555d555d555550000000056666666666666555557777755555555555555555555555555
555555555557777755555ddd55555d55555d55555d5d5d555555555d555d55555d55550000000056ddd6ddd6d666555577ddd775566666555666665556666655
555555555577777555555ddd55555555555555555ddddd5555ddddddd55d55555d55550000000056d6d666d6d666555577d7d77566dd666566ddd66566ddd665
5555555557577755555ddddddd555d55555d555d5ddddd555d5ddddd555d55555d55550000000056d6d6ddd6ddd6555577d7d775666d66656666d665666dd665
5555555557557555555d55555d55555555555555dddddd555d55ddd55555d555d555550000000056d6d6d666d6d6555577ddd775666d666566d666656666d665
5555555557775555555ddddddd555d5d5d5d555555ddd5555d555d5555555ddd5555550000000056ddd6ddd6ddd655557777777566ddd66566ddd66566ddd665
55555555555555555555555555555555555555555555555555555555555555555555550000000056666666666666555577777775666666656666666566666665
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566666665ddddddd5ddddddd5ddddddd5
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000e800880011111d000b3333000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000888800efe88ee81ccccc6d0b7bbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa000087fee808eeeeee81cccccc1b7bbbbb3b7bbbbb3000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a7aa0008feee808eeeeee81cccccc13b5bb5b33b5bb5b3000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0008eeee808eeeeee801cccc103bb55bb33bb55bb33bb55bb30000000000000000000000000000000000000000000000000000000000000000
00000000000aa00008eeee8008eeee8001cccc103b5bb5b33b5bb5b33b5bb5b30000000000000000000000000000000000000000000000000000000000000000
000000000000000000888800008ee800001cc1003bbbbbb33bbbbbb33bbbbbb33bbbbbb300000000000000000000000000000000000000000000000000000000
00000000000000000000000000088000000110000333333003333330033333300333333000000007777777777000000000000000000000000000000000000000
07777770000000000000000000000000000000000e80088000000000000000000000000000000007000000007000000000000000000000000000000000000000
7000000777000077000000000000000000000000efe88ee800000000000000000000000000000007000000007000000000000000000000000000000000000000
70700707707007070000000000000000000000008eeeeee88eeeeee8000000000000000000000007000000007000000000000000000000000000000000000000
70077007700770070000000000000000000000008eeeeee88eeeeee8000000000000000000000007000000007000000000000000000000000000000000000000
70077007700770070000000000000000000000008eeeeee88eeeeee88eeeeee80000000000000007000000007000000000000000000000000000000000000000
707007077070070700000000000000000000000008eeee8008eeee8008eeee800000000000000007000000007000000000000000000000000000000000000000
7700007770000007000000000000000000000000008ee800008ee800008ee800008ee80000000007000000007000000000000000000000000000000000000000
00000000077777700000000000000000000000000008800000088000000880000008800000000007000000007000000000000000000000000000000000000000
0000000000000000000000000000000000000000011111d000000000000000000000000000000007777777777000000000000000000000000000000000000000
00000000000000000000000000000000000000001ccccc6d00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001cccccc11cccccc1000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001cccccc11cccccc1000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000001cccc1001cccc1001cccc100000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000001cccc1001cccc1001cccc100000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000001cc100001cc100001cc100001cc10000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001100000011000000110000001100000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000017100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000017710000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000017771000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000017777100000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000017711000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888881171888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000e050000000000000000160501605016050160501605017050190501a0501c0501d0501f0502005021050000000000000000000000000000000000000000000000000000000000000
