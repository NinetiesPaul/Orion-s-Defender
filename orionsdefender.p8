pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--general code
ship_image = 017
ship_x = 64
ship_y = 120
fuel = 51
health = 5
armor = 5
score = 0

clock = 0

battling = false
battle = false

enemies = {}
enemy_bullets = {}
enemy_count = 0

rewards = false
rewards_given = false

r_fuel = 0
r_armor = 0
r_health = 0 

function _draw()
 if battling == false then
  cls()
  print(score,0,0)
  
  spr(003,108,0)
  print(health,120,1)
  spr(004,108,10)
  print(armor,120,11)
  spr(005,108,20)
  print(flr(fuel),119,21)
    
  spr(ship_image,ship_x,ship_y)
  foreach(encounters, draw_encounter)
 end
 if battling == true then
  cls()
  print(score,0,0)

  spr(003,108,0)
  print(health,120,1)
  spr(004,108,10)
  print(armor,120,11)
  spr(005,108,20)
  print(flr(fuel),119,21)
  
  print(enemy_count,120,120)
  
  spr(ship_image,ship_x,ship_y)
  if (clock % 30 == 0) create_enemy_bullet()
  foreach(enemies, draw_enemy)
  foreach(enemy_bullets, draw_enemy_bullet)
  foreach(bullets, draw_bullet)
 end
 if health <= 0 or fuel <= 0 then
  cls()
  print("game over",44,64)
  
  battling = false
  battle = false
  destroy()
 end
 if rewards == true then
  cls()
  
  print("you've won!", 40,64)
  print("added "..r_fuel.." fuel.", 40,72)
  print("added "..r_armor.." armor.", 40,80)
  print("added "..r_health.." health.", 40,88)
  destroy()
 end
end

function _update()
 clock+=1
 move()
 fire()
 if (rewards != true) fuel-=0.05
 if (clock % 30 == 0 and battling == false and rewards == false) create_encounter()
 foreach(enemies, move_enemy)
 foreach(bullets, move_bullet)
 foreach(enemy_bullets, move_enemy_bullet)
 foreach(encounters, move_encounter)
 if (battle == true and battling == false) start_battle()
 if battle == true and
    battling == true and
    enemy_count == 0 then
  battling = false
  battle = false
  rewards = true
 end
 if (rewards == true and rewards_given == false) give_rewards()
 restart()
end

function start_battle()
 enemy_count = flr(rnd(6))
 if (enemy_count == 0) enemy_count = 1
 
 for enemy_count = enemy_count,0,-1 do
  local enemy = {}
  enemy.x = flr(rnd(30))+30
  enemy.y = flr(rnd(30))+30
  enemy.sx = enemy.x
  enemy.sy = enemy.y
  enemy.lx = enemy.x+rnd(20)+20
  enemy.ly = enemy.y+rnd(20)+20
  enemy.move_forward = true
  dy = flr(rnd(4))
	 if (dy == 0) dy = 1
  enemy.dy = dy
  add(enemies, enemy)
 end
 
 enemy_count += 1
 battling = true
 ship_x = 64
 ship_y = 104
 for e in all(encounters) do
  del(encounters,e)
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

function give_rewards()
 x = flr(rnd(10))
 if (x == 0) x = 1
 fuel += x
 r_fuel = x
 rewards_given= true
end

function restart()
 if btnp(4) or btnp(5) then
  rewards = false
  rewards_given = false
 end
end
-->8
--encounters
encounters = {}
encounter_spawn_x = {12,36,64,96,108}

function create_encounter()
 local encounter = {}
 number = flr(rnd(6))
 if (number == 0) number = 1
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
  battle = true
 end
end
-->8
--player
bullets = {}

function fire()
 if btnp(4) and 
    battling == true then
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
   score += 100
   enemy_count -= 1
  	del(bullets,b)	 
  	del(enemies,e)
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
  enemy_bullet.x = e.x
  enemy_bullet.y = e.y+8
  enemy_bullet.dy = e.dy
  add(enemy_bullets,enemy_bullet)
 end
end

function draw_enemy(e)
 spr(016,e.x,e.y)
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
  if (armor == 0) health-=1
  if (armor > 0) armor-=1
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
0000000000000000000000000e800880011115500003300000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000888800e7e88ee81cccc6650003300000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa000087fee808eeeeee81ccccc650033330000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a7aa0008feee808eeeeee81cccccc103b3333000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0008eeee808eeeeee801cccc103bb3333300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa00008eeee8008eeee8001cccc103b7b333300000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000888800008ee800001cc10003bbbb3000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000088000000110000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700707707007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70077007700770070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70077007700770070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700707707007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000077700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888777777888eeeeee888eeeeee888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888778887788ee88eee88ee888ee88888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888777878778eeee8eee8eeeee8ee88888e88888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
888777878778eeee8eee8eee888ee8888eee8888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
888777878778eeee8eee8eee8eeee88888e88888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
888777888778eee888ee8eee888ee888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888777777778eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555e5555ee55ee5eee5e555555566656655666566656565555555555555577577555555555555555555555555555555555555555555555555555555555
555555555e555e5e5e555e5e5e555555565556565655566656565555577755555575557555555555555555555555555555555555555555555555555555555555
555555555e555e5e5e555eee5e555555566556565665565656665555555555555775557755555555555555555555555555555555555555555555555555555555
555555555e555e5e5e555e5e5e555555565556565655565655565555577755555575557555555555555555555555555555555555555555555555555555555555
555555555eee5ee555ee5e5e5eee5555566656565666565656665555555555555577577555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555556665665566656665656555556565555555555555bbb5b555bbb55755bbb5bb55bb555755ccc5ccc5575557555555ccc5ccc55555555555555555555
5555555556555656565556665656555556565555577755555b555b555b5b57555b5b5b5b5b5b5755555c5c5c555755575575555c5c5c55555555555555555555
5555555556655656566556565666555555655555555555555bb55b555bb557555bb55b5b5b5b575555cc5c5c55575557577755cc5c5c55555555555555555555
5555555556555656565556565556555556565555577755555b555b555b5b57555b5b5b5b5b5b5755555c5c5c555755575575555c5c5c55555555555555555555
5555555556665656566656565666557556565555555555555b555bbb5b5b55755b5b5b5b5bbb55755ccc5ccc5575557555555ccc5ccc55555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555556665665566656665656555556565555555555555bbb5b555bbb55755bbb5bb55bb555755ccc5ccc5575557555555ccc5ccc55555555555555555555
5555555556555656565556665656555556565555577755555b555b555b5b57555b5b5b5b5b5b5755555c5c5c555755575575555c5c5c55555555555555555555
5555555556655656566556565666555556665555555555555bb55b555bb557555bb55b5b5b5b575555cc5c5c55575557577755cc5c5c55555555555555555555
5555555556555656565556565556555555565555577755555b555b555b5b57555b5b5b5b5b5b5755555c5c5c555755575575555c5c5c55555555555555555555
5555555556665656566656565666557556665555555555555b555bbb5b5b55755b5b5b5b5bbb55755ccc5ccc5575557555555ccc5ccc55555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555566656655666566656565555556656565555555555555666566556665666565655555656555555555555555555555555555555555555555555555555
55555555565556565655566656565555565556565555577755555655565656555666565655555656555555555555555555555555555555555555555555555555
55555555566556565665565656665555566655655555555555555665565656655656566655555565555555555555555555555555555555555555555555555555
55555555565556565655565655565555555656565555577755555655565656555656555655555656555555555555555555555555555555555555555555555555
55555555566656565666565656665575566556565555555555555666565656665656566655755656555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555566656655666566656565555556656565555555555555666566556665666565655555656555555555555555555555555555555555555555555555555
55555555565556565655566656565555565556565555577755555655565656555666565655555656555555555555555555555555555555555555555555555555
55555555566556565665565656665555566656665555555555555665565656655656566655555666555555555555555555555555555555555555555555555555
55555555565556565655565655565555555655565555577755555655565656555656555655555556555555555555555555555555555555555555555555555555
55555555566656565666565656665575566556665555555555555666565656665656566655755666555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555556665665566656665656555556555656555555555555566656655666566656565555565655555bbb5bb55bb555755ccc5ccc557555555ccc5ccc5555
5555555556555656565556665656555556555656555557775555565556565655566656565555565655755b5b5b5b5b5b5755555c5c5c55575575555c5c5c5555
5555555556655656566556565666555556555565555555555555566556565665565656665555556557775bb55b5b5b5b57555ccc5c5c555757775ccc5c5c5555
5555555556555656565556565556555556555656555557775555565556565655565655565555565655755b5b5b5b5b5b57555c555c5c555755755c555c5c5555
5555555556665656566656565666557556665656555555555555566656565666565656665575565655555b5b5b5b5bbb55755ccc5ccc557555555ccc5ccc5555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555556665665566656665656555556555656555555555555566656655666566656565555565655555bbb5bb55bb555755ccc5ccc557555555ccc5ccc5555
5555555556555656565556665656555556555656555557775555565556565655566656565555565655755b5b5b5b5b5b5755555c5c5c55575575555c5c5c5555
5555555556655656566556565666555556555666555555555555566556565665565656665555566657775bb55b5b5b5b57555ccc5c5c555757775ccc5c5c5555
5555555556555656565556565556555556555556555557775555565556565655565655565555555655755b5b5b5b5b5b57555c555c5c555755755c555c5c5555
5555555556665656566656565666557556665666555555555555566656565666565656665575566655555b5b5b5b5bbb55755ccc5ccc557555555ccc5ccc5555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555666566556665666565655555666556656565666555556665166566656565666566656655555555555555ccc5ccc5c5c5ccc55555555555555555555
5555555556555656565556665656555556665656565656555555565517165656565656565656565655555777555555c55c5c5c5c5c5555555555555555555555
5555555556655656566556565666555556565656565656655555566517715665565656665665565655555555555555c55cc55c5c5cc555555555555555555555
5555555556555656565556565556555556565656566656555555565517771656566656565656565655555777555555c55c5c5c5c5c5555555555555555555555
5555555556665656566656565666557556565665556556665666565517777156566656565656566655555555555555c55c5c55cc5ccc55555555555555555555
55555555555555555555555555555555555555555555555555555555177115555555555555555555555555555555555555555555555555555555555555555555
555555555656556656665555555555555bbb5b555bbb55755bbb5bb5511715755c5c557555755555555555555555555555555555555555555555555555555555
555555555656565656555555577755555b555b555b5b57555b5b5b5b5b5b57555c5c555755575555555555555555555555555555555555555555555555555555
555555555666565656655555555555555bb55b555bb557555bb55b5b5b5b57555ccc555755575555555555555555555555555555555555555555555555555555
555555555656565656555555577755555b555b555b5b57555b5b5b5b5b5b5755555c555755575555555555555555555555555555555555555555555555555555
555555555656566556555555555555555b555bbb5b5b55755b5b5b5b5bbb5575555c557555755555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555eee5eee5555557556565566566655555555555555555ccc557555555656556656665555555555555cc5555555555555555555555555555555555555
5555555555e55e555555575556565656565555555777577755555c5c5557555556565656565555555777555555c5555555555555555555555555555555555555
5555555555e55ee55555575556665656566555555555555555555c5c5557555556665656566555555555555555c5555555555555555555555555555555555555
5555555555e55e555555575556565656565555555777577755555c5c5557555556565656565555555777555555c5555555555555555555555555555555555555
555555555eee5e555555557556565665565555555555555555555ccc557555555656566556555555555555555ccc555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555888885555555555555555555555555555555555555555555555555555555
55555555566656655666566656565555565655665666555555555555565655665666888885555555555555555555555555555555555555555555555555555555
55555555565556565655566656565555565656565655555557775555565656565655888885555555555555555555555555555555555555555555555555555555
55555555566556565665565656665555566656565665555555555555566656565665888885555555555555555555555555555555555555555555555555555555
55555555565556565655565655565555565656565655555557775555565656565655888885555555555555555555555555555555555555555555555555555555
55555555566656565666565656665575565656655655555555555555565656655655888885555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555bbb5bb55bb5557556665665566656665666566655665555555556665665566656665656557555555555555555555555555555555555555555555555
555555555b5b5b5b5b5b575556555656565556665565565556555555555556555656565556665656555755555555555555555555555555555555555555555555
555555555bbb5b5b5b5b575556655656566556565565566556665555555556655656566556565666555755555555555555555555555555555555555555555555
555555555b5b5b5b5b5b575556555656565556565565565555565575555556555656565556565556555755555555555555555555555555555555555555555555
555555555b5b5bbb5bbb557556665656566656565666566656655755555556665656566656565666557555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5ee55ee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ee55e5e5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5e5e5eee5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555566656665666566656555666566555665555555555555ccc5ccc5c5c5ccc5555555555555555555555555555555555555555555555555555555555555555
55555656565655655565565555655656565555555777555555c55c5c5c5c5c555555555555555555555555555555555555555555555555555555555555555555
55555665566655655565565555655656565555555555555555c55cc55c5c5cc55555555555555555555555555555555555555555555555555555555555555555
55555656565655655565565555655656565655555777555555c55c5c5c5c5c555555555555555555555555555555555555555555555555555555555555555555
55555666565655655565566656665656566655555555555555c55c5c55cc5ccc5555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5ee55ee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ee55e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5e5e5eee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5e5e5ee555ee5eee5eee55ee5ee5555555665666566555555666566556665666566656665566557556665575555555555555555555555555555555555555
5e555e5e5e5e5e5555e555e55e5e5e5e555556555655565655555655565656555666556556555655575556555557555555555555555555555555555555555555
5ee55e5e5e5e5e5555e555e55e5e5e5e555556555665565655555665565656655656556556655666575556655557555555555555555555555555555555555555
5e555e5e5e5e5e5555e555e55e5e5e5e555556565655565655555655565656555656556556555556575556555557555555555555555555555555555555555555
5e5555ee5e5e55ee55e55eee5ee55e5e555556665666565656665666565656665656566656665665557556665575555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555bb5bbb5bbb55755ccc5cc55c55555556665555565655555666555556565575555555555555555555555555555555555555555555555555555555555555
55555b555b5b5b5b57555c5c55c55c55555556555555565655555655555556565557555555555555555555555555555555555555555555555555555555555555
55555bbb5bbb5bb557555c5c55c55ccc555556655555556555555665555556665557555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888828882288882822282228888888888888888888888888888888888888888888888888222822282228882822282288222822288866688
82888828828282888888828888288828828282828888888888888888888888888888888888888888888888888288828882828828828288288282888288888888
82888828828282288888822288288828822282828888888888888888888888888888888888888888888888888222822282228828822288288222822288822288
82888828828282888888828288288828888282828888888888888888888888888888888888888888888888888882888288828828828288288882828888888888
82228222828282228888822282228288888282228888888888888888888888888888888888888888888888888222822288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000e050000000000000000160501605016050160501605017050190501a0501c0501d0501f0502005021050000000000000000000000000000000000000000000000000000000000000
