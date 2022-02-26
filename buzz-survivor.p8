pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
function _init()
 p={
  x=rnd(10000),y=rnd(10000),
  spd=1,
 }
 start_time=t()
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
   if c==3 then c=5 end
   local d=flr(
    sin(0.015*(fx+x))*2^2+
    cos(0.02*(fy+y))*2^2)%5
   for z=1,d do
    local r=(fx+x)^2+(fy+y)^2+(z+c)^2
    circfill(
     x*8-sx+r%9,y*8-sy+r%15,(z-1)%3,c)
   end
  end
 end
 camera(lx or p.x,ly or p.y)
 lx,ly=p.x-60,p.y-60
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
 --gui
 camera()
 local tt=flr(t()-start_time)
 print(
  (tt\600==0and"0"or"")
  ..tostr(tt\60)
  ..(tt%60\10==0and":0"or":")
  ..tostr(tt%60),1,1,15)
 print(tostr(#enemies),80,1,15)
end

function _update()
 ts+=1
 p.wounded=false
 if btn(⬅️) then p.x-=p.spd end
 if btn(➡️) then p.x+=p.spd end
 if btn(⬆️) then p.y-=p.spd end
 if btn(⬇️) then p.y+=p.spd end
 function key(e,o)
  return (e.x-p.x+o)\10+(e.y-p.y+o)\10*100
 end
 local collision={}
 for i,e in pairs(enemies) do
  local k=key(e,0)
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
  local l=sqrt((dx/10)^2+(dy/10)^2)*10
  local max_dist=120
  if abs(dx)>max_dist
  or abs(dy)>max_dist then
   del(enemies,e)
  end
  if l<e.r then
   p.wounded=e.x
  end
  if abs(dx)>2 then
   e.x+=dx*spd/l
  end
  if abs(dy)>2 then
   e.y+=dy*spd/l
  end
  e.flip=dx<0
  local k=key(e,-5)
  for dk1=0,1 do for dk2=0,1 do
   for j,e2 in pairs(collision[k+dk1+100*dk2]) do
    if e2!=e then
     local dx=e.x-e2.x
     local dy=e.y-e2.y
     local l=abs(dx)+abs(dy)
     if l<e.r+e2.r+5 then
      e.x+=sgn(dx)*spd
      e.y+=sgn(dy)*spd
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
 local x,y=0,0
 local excl,incl=60,90
 while abs(x)<excl and abs(y)<excl do
  x=rnd(incl*2)-incl
  y=rnd(incl*2)-incl
 end
 return p.x+x,p.y+y
end

function newenemy()
 local x,y=spawnpos()
 local e={x=x,y=y}
 e.spr=flr(rnd(4)+2)
 e.r=e.spr
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
