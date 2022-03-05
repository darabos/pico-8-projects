pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
wpnclasses={
 {name="net",
  pickup=50,
  phase=0,len=10,spd=0.02,dmg=1,
  draw=function(s)
   line(
    flr(p.x)+1.5*cos(s.spd*(s.phase-1)),
    flr(p.y)+3*sin(s.spd*(s.phase-1)),
    p.x+s.len*cos(s.spd*(s.phase-1)),
    p.y+s.len*sin(s.spd*(s.phase-1)),12)
   line(
    flr(p.x)+1.5*cos(s.spd*s.phase),
    flr(p.y)+3*sin(s.spd*s.phase),
    p.x+s.len*cos(s.spd*s.phase),
    p.y+s.len*sin(s.spd*s.phase),7)
  end,
  update=function(s)
   s.phase+=1
   s.len=min(90,p.level*5)
   local last=nil
   for i=1,s.len\5 do
    local hx=p.x+5*i*cos(s.spd*s.phase)
    local hy=p.y+5*i*sin(s.spd*s.phase)
    local k=collisionkey({x=hx,y=hy},0)
    if k!=last then
     last=k
     foreach(collisionmap[k],function(e)
      hit(e,s.dmg)
     end)
     foreach(xps[k],function(e)
      if rnd(100)<s.pickup then
       del(xps[k],e)
       p.xp+=e.value
      end
     end)
    end
   end
  end},
}

function _init()
 p={
  x=rnd(10000)-5000,y=rnd(10000)-5000,
  spr=1,spd=1,level=1,xp=0,
  weapons={wpnclasses[1]},
 }
 cam={x=p.x,y=p.y}
 start_time=t()
 effects={}
 enemies={}
 xps={}
 for i=1,10 do
  add(enemies,newenemy())
 end
 ts=0
 biome=2
end

function setpal(c)
 for i=1,15 do
  pal(i,c or i)
 end
 if biome==1 then
  pal(0,3+128,1)
  pal(1,1+128,1)
  pal(2,1,1)
  pal(3,3,1)
 elseif biome==2 then
  pal(0,2+128,1)
  pal(1,0+128,1)
  pal(2,4+128,1)
  pal(3,5+128,1)
 end
 poke(24366,1)--apply to editor
end
setpal()

function _draw()
 camera()
 --terrain
 local sx=cam.x%8
 local fx=cam.x\8
 local sy=cam.y%8
 local fy=cam.y\8
 cls(0)
 for x=-1,16 do
  for y=-1,16 do
   local c=flr(
    sin(0.03*(fx+x))*2^2+
    cos(0.04*(fy+y))*2^2)%3+1
   local d=flr(
    sin(0.015*(fx+x))*2^2+
    cos(0.02*(fy+y))*2^2)%5
   for z=1,d do
    local r=(fx+x)^2+(fy+y)^2+(z+c)^2
    if biome==1 then
     circfill(
      x*8-sx+r%11,y*8-sy+r%9,(z-1)%3,c)
    elseif biome==2 then
     circ(
      x*8-sx+r%11,y*8-sy+r%9,(z-1)%3,c)
    end
   end
  end
 end
 camera(cam.x-64,cam.y-64)
 cam.x*=0.95
 cam.x+=0.05*(p.x+flr(p.vx*20))
 cam.y*=0.95
 cam.y+=0.05*(p.y+flr(p.vy*20))
 --xp
 local ck=collisionkey(cam,0)
 for i=-6,7 do for j=-6,7 do
  local v=xps[ck+i+100*j]
  if v then for i=1,#v do
   pset(v[i].x,v[i].y,12)
  end end
 end end
 --player
 if p.wounded then
  setpal(8)
  spr(p.spr,p.x-4,p.y-4,1,1,p.flip)
  setpal()
 else
  spr(p.spr,p.x-4,p.y-4,1,1,p.flip)
 end
 --enemies
 foreach(enemies,function(e)
  if e.hp>0 then
   spr(e.spr,e.x-4,e.y-4,1,1,e.flip)
  end
 end)
 pal(9,1)
 pal(10,12)
 foreach(enemies,function(e)
  if e.hp<=0 then
   spr(e.spr,e.x-4,e.y-4,1,1,e.flip)
  end
 end)
 setpal()
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
 rectfill(
  24,1,
  24+87*min(1,p.xp/p.nextlevelxp),5,12)
 rprint(p.level,124,1,15)
end

function rprint(txt,x,y,c)
 txt=tostr(txt)
 print(txt,x-#txt*4+4,y,c)
end

function colliders(
 list,center,radius,fn)
 local pk=collisionkey(center,-5)
 for i=0,1 do for j=0,1 do
  local cell=list[pk+i+100*j]
  foreach(cell,function(o)
   local dx=o.x-center.x
   local dy=o.y-center.y
   if abs(dx)+abs(dy)<radius then
    fn(o,cell)
   end
  end)
 end end
end

function _update()
 ts+=1
 --player
 p.nextlevelxp=10*p.level^2
 if p.xp>=p.nextlevelxp then
  p.xp-=p.nextlevelxp
  p.level+=1
  p.nextlevelxp=10*p.level^2
 end
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
 --xp
 colliders(xps,p,5,function(xp,cell)
  del(cell,xp)
  p.xp+=xp.value
 end)
 --enemies
 collisionmap={}
 local key=collisionkey
 local collision=collisionmap
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
  if e.hp<1 then
   dx*=-2
   dy*=-2
  end
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
  if e.hp>0 then for dk1=0,1 do for dk2=0,1 do
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
  end end end
 end
 if #enemies<250 and rnd(100)<10 then
  add(enemies,newenemy())
 end
 --weapons
 foreach(p.weapons,function(w)
  w.update(w)
 end)
end

function collisionkey(e,o)
 return (e.x+o)\10+(e.y+o)\10*100
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
 local e={x=x,y=y,hp=1,xp=1}
 r=rnd()^2
 e.spr=flr(r*9+2)
 e.hp=e.spr^2
 e.xp=e.hp
 e.r=e.spr
 return e
end

function hit(e,dmg)
 e.hp-=dmg
 addeffect(e,dmg*2,9)
 if e.hp<=0 then
  addxp(e,e.xp)
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

function addxp(p,n)
 for i=0,n-1 do
  local xp={
   value=1,
   x=p.x+rnd(i*2)-i,
   y=p.y+rnd(i*2)-i}
  local k=collisionkey(xp,0)
  if xps[k] then
   if #xps[k]<20 then
    add(xps[k],xp)
   else
    xps[k][flr(rnd(20)+1)].value+=1
   end
  else
   xps[k]={xp}
  end
 end
end
__gfx__
000000000000000000000000000000000000000000000000660000660660066000999000000000000000000000000000000000000000000000009a0000000000
00000000000000000000000000000000000000000000000066600666066006609939399077000000770000000000000000000000000000000009789000000000
007007000004400000000000000000000006000000a9aa000660066008aaaa80999a99909900000077007000000000000000000000000000765a990000000000
00077000000ff00000000000000600000005990001949400008aa8000aaaaaa099999990999999907777777000000000000000000000000069a5a00000000000
00077000000cc0000005a0000959590000a599000094990000999900011111109999999099999b9177777b7100000000000000000000000005a5500000000000
00700700000cc00000000000000000000000000000000000005005000aaaaaa00100010099999990777777700000000000000000000000000954000000000000
00000000000110000000000000000000000000000000000000000000011111101010101000909000007070000000000000000000000000005000000000000000
00000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044b00000ffa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008aaaaaa800000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006611116600000000000000000111110000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000066aaaa66000000000000000001bbb110bbbbbbbbbbbbbbbb0000000000000000
00000000000000000000000000000000000000000000000000000000000000006611116600000000000000000111110000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000066aaaa6600000000000000000001000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006611116600000000000000000001000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000
0000000000000000000000000333330000000000000000000000000000000000000000000000000000000000000000000000000000000000449ff94400000000
00000000000000000000000003333300000000000000000000000000000000000000000000000000000000000000000000000000000000004999999400000000
00000000000000000000000003353300000000000000000000000000000000000000000000000000000000000000000000000000000000009119911900444400
000000000000000000000000033533000000000000000000000000000000000000000000000000000000000000000000000000000000000091c99c1900344300
00000000000000000000000000050000000000000a00000000000000000000000000000000000000000000000000000000000000000000009ff99ff940444400
000000000000000000000000000500000000000008000000000000000000000000000000000000000000000000000000000000000000000049f11f9404444440
00000000000000000000000000050000000000000b00000000000000000000000000000000000000000000000000000000000000000000004f1111f400000004
00000000000000000000000000050000000000000c00000000000000000000000000000000000000000000000000000000000000000000009f1ee1f900000000
