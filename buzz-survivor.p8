pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
wpnclasses={
 {name="net",
  phase=0,len=10,spd=0.05,dmg=1,
  draw=function(s)
   line(
    p.x,p.y,
    p.x+s.len*cos(s.spd*(s.phase-1)),
    p.y+s.len*sin(s.spd*(s.phase-1)),12)
   line(
    p.x,p.y,
    p.x+s.len*cos(s.spd*s.phase),
    p.y+s.len*sin(s.spd*s.phase),7)
  end,
  update=function(s)
   s.phase+=1
   local last=nil
   for i=1,s.len\5 do
    local hx=p.x+5*i*cos(s.spd*s.phase)
    local hy=p.y+5*i*sin(s.spd*s.phase)
    local k=collision_key({x=hx,y=hy},0)
    if k!=last then
     last=k
     foreach(collision_map[k],function(e)
      hit(e,s.dmg)
     end)
    end
   end
  end}
}

function _init()
 p={
  x=rnd(10000),y=rnd(10000),
  spr=1,spd=1.5,
  weapons={wpnclasses[1]},
 }
 cam={x=p.x,y=p.y}
 start_time=t()
 effects={}
 enemies={}
 for i=1,10 do
  add(enemies,newenemy())
 end
 ts=0
end

function _draw()
 camera()
 --terrain
 local sx=cam.x%8
 local fx=cam.x\8
 local sy=cam.y%8
 local fy=cam.y\8
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
     x*8-sx+r%11,y*8-sy+r%9,(z-1)%3,c)
   end
  end
 end
 camera(cam.x-60,cam.y-60)
 cam.x*=0.95
 cam.x+=0.05*(p.x+flr(p.vx*20))
 cam.y*=0.95
 cam.y+=0.05*(p.y+flr(p.vy*20))
 --player
 if p.wounded then
  for i=1,15 do
   pal(i,8)
  end
  spr(p.spr,p.x-4,p.y-4,1,1,p.flip)
  pal()
 else
  spr(p.spr,p.x-4,p.y-4,1,1,p.flip)
 end
 --enemies
 foreach(enemies,function(e)
  spr(e.spr,e.x-4,e.y-4,1,1,e.flip)
 end)
 --effects
 foreach(effects,function(e)
  e.ttl-=1
  if e.ttl<0 then del(effects,e) return end
  e.x+=e.vx
  e.y+=e.vy
  pset(e.x,e.y,e.c)
 end)
 --weapons
 foreach(p.weapons,function(w)
  w.draw(w)
 end)
 --gui
 camera()
 local tt=flr(t()-start_time)
 print(--clock
  (tt\600==0and"0"or"")
  ..tostr(tt\60)
  ..(tt%60\10==0and":0"or":")
  ..tostr(tt%60),1,1,15)
 print(p.d,80,1,7)
end

function _update()
 ts+=1
 --player
 p.wounded=false
 p.vx=0 p.vy=0
 if btn(⬅️) then
  p.vx=-p.spd
  p.flip=false
 end
 if btn(➡️) then
  p.vx=p.spd
  p.flip=true
 end
 if btn(⬆️) then p.vy=-p.spd end
 if btn(⬇️) then p.vy=p.spd end
 if abs(p.vx)+abs(p.vy)>p.spd then
  p.vx*=0.7
  p.vy*=0.7
 end
 p.x+=p.vx
 p.y+=p.vy
 --enemies
 collision_map={}
 local key=collision_key
 local collision=collision_map
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
 if #enemies<250 and rnd(100)<10 then
  add(enemies,newenemy())
 end
 --weapons
 p.d=""
 foreach(p.weapons,function(w)
  w.update(w)
 end)
end

function collision_key(e,o)
 return (e.x-p.x+o)\10+(e.y-p.y+o)\10*100
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
 local e={x=x,y=y,hp=1}
 e.spr=flr(rnd(4)+2)
 e.r=e.spr
 return e
end

function hit(e,dmg)
 e.hp-=dmg
 addeffect(e,dmg*2,9)
 if e.hp<=0 then
  del(enemies,e)
 end
end

function addeffect(p,n,c)
 if #effects>250 then return end
 for i=1,n do
  local ph=rnd()
  local s=rnd()+1
  add(effects,{
   c=c,x=p.x,y=p.y,ttl=rnd(5)+5,
   vx=s*cos(ph),vy=s*sin(ph)})
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000009a00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000097890000000000000000000000000000000000000000000000000
007007000004400000000000000000000006000000a9aa00000000000000000000000000765a9900000000000000000000000000000000000000000000000000
00077000000ff0000000000000060000000599000c94940000000000000000000000000069a5a000000000000000000000000000000000000000000000000000
00077000000cc0000005a0000959590000a599000094990000000000000000000000000005a55000000000000000000000000000000000000000000000000000
00700700000cc0000000000000000000000000000000000000000000000000000000000009540000000000000000000000000000000000000000000000000000
00000000000110000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044b00000ffa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
