pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
function _init()
 p={
  x=rnd(10000),y=rnd(10000),
  spd=1,
 }
 enemies={}
 for i=1,10 do
  add(enemies,newenemy())
 end
 ts=0
end

function _draw()
 camera()
 local sx=p.x%8
 local fx=p.x\8
 local sy=p.y%8
 local fy=p.y\8
 cls(3)
 for x=-1,16 do
  for y=-1,16 do
   local c=flr(
    sin(0.03*(fx+x))*2^2+
    cos(0.04*(fy+y))*2^2)%3+1
   if c==3 then c=4 end
   local d=flr(
    sin(0.015*(fx+x))*2^2+
    cos(0.02*(fy+y))*2^2)%3
   for z=1,d do
    local r=(fx+x+fy+y+z+c)^2
    pset(
     x*8-sx+r%3,y*8-sy+r%5,c)
   end
  end
 end
 camera(p.x-60,p.y-60)
 if p.wounded then
  for i=1,15 do
   pal(i,8)
  end
  spr(1,p.x,p.y)
  pal()
 else
  spr(1,p.x,p.y)
 end
 foreach(enemies,function(e)
  spr(e.spr,e.x,e.y,1,1,e.flip)
 end)
 camera()
 print(tostr(#enemies),10,10,15)
end

function _update()
 ts+=1
 p.wounded=false
 if btn(⬅️) then p.x-=p.spd end
 if btn(➡️) then p.x+=p.spd end
 if btn(⬆️) then p.y-=p.spd end
 if btn(⬇️) then p.y+=p.spd end
 local collision={}
 for i,e in pairs(enemies) do
  local k=(e.x-p.x)\10+(e.y-p.y)\10*100
  if collision[k] then
   add(collision[k],e)
  else
   collision[k]={e}
  end
 end
 for i,e in pairs(enemies) do
  local spd=1/2
  local dx=p.x-e.x
  local dy=p.y-e.y
  if abs(dx)+abs(dy)>200 then
   del(enemies,e)
  end
  if abs(dx)+abs(dy)<(e.r or 5) then
   p.wounded=true
  end
  if abs(dx)>2 then
   e.x+=sgn(dx)*spd
  end
  if abs(dy)>2 then
   e.y+=sgn(dy)*spd
  end
  e.flip=dx<0
  local k=(e.x-p.x)\10+(e.y-p.y)\10*100
  for dk1=0,1 do for dk2=0,1 do
   for j,e2 in pairs(collision[k+dk1+100*dk2]) do
    if e2!=e then
     local dx=e.x-e2.x
     local dy=e.y-e2.y
     if abs(dx)+abs(dy)<10 then
      e.x+=sgn(dx)*spd/2
      e.y+=sgn(dy)*spd/2
     end
    end
   end
  end end
 end
 if #enemies<250 and rnd(100)<20 then
  add(enemies,newenemy())
 end
end

function spawnpos()
 local x=0
 local y=0
 while abs(x)<80 and abs(y)<80 do
  x=rnd(200)-100
  y=rnd(200)-100
 end
 return p.x+x,p.y+y
end

function newenemy()
 local x,y=spawnpos()
 local e={x=x,y=y}
 e.spr=rnd(4)+2
 return e
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000009a00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000097890000000000000000000000000000000000000000000000000
007007000004400000000000000000000006000000a9aa00000000000000000000000000765a9900000000000000000000000000000000000000000000000000
00077000000ff0000000000000060000000599000c94940000000000000000000000000069a5a000000000000000000000000000000000000000000000000000
00077000000cc0000005a0000959590000a599000094990000000000000000000000000005a55000000000000000000000000000000000000000000000000000
00700700000cc0000000000000000000000000000000000000000000000000000000000009540000000000000000000000000000000000000000000000000000
00000000000110000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000
