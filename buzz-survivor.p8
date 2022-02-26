pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
p={
 x=0,y=0,
 spd=2,
}
enemies={}
for i=1,10 do
 add(enemies,
  {spr=2,x=rnd(10),y=rnd(10),flip=false})
end
add(enemies,
 {spr=3,x=rnd(10),y=rnd(10),flip=false})
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
    cos(0.04*(fy+y))*2^2)%3+4
   local d=flr(
    sin(0.015*(fx+x))*2^2+
    cos(0.02*(fy+y))*2^2)%3+4
   for z=1,d-4 do
    local r=(fx+x+fy+y+z+c)^2
    pset(
     x*8-sx+r%3,y*8-sy+r%5,c)
   end
  end
 end
 camera(p.x-60,p.y-60)
 spr(1,p.x,p.y)
 foreach(enemies,function(e)
  spr(e.spr,e.x,e.y,1,1,e.flip)
 end)
end
function _update()
 if btn(⬅️) then p.x-=p.spd end
 if btn(➡️) then p.x+=p.spd end
 if btn(⬆️) then p.y-=p.spd end
 if btn(⬇️) then p.y+=p.spd end
 foreach(enemies,function(e)
  local spd=1
  local dx=p.x-e.x
  local dy=p.y-e.y
  if abs(dx)+abs(dy)>200 then
   del(enemies,e)
  end
  if abs(dx)>2 then
   e.x+=sgn(dx)*spd
  end
  if abs(dy)>2 then
   e.y+=sgn(dy)*spd
  end
  e.flip=dx<0
  foreach(enemies,function(e2)
   if e2==e then return end
	  local dx=e.x-e2.x
	  local dy=e.y-e2.y
	  if abs(dx)+abs(dy)<10 then
	   e.x+=sgn(dx)*spd/2
	   e.y+=sgn(dy)*spd/2
	  end
  end)
 end)
end

__gfx__
00000000000000000000000000009a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000097890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000004400000000000765a9900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000ff0000000000069a5a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000cc0000005a00005a55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000cc0000000000009540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000110000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
