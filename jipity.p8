pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
objs={}
debug=""
function _draw()
 cls(5)
 palt(0,false)
 map()
 palt()
 sortobjs()
 foreach(objs,function(o)
  if (o.type.draw) o.type.draw(o)
 end)
 print(debug,10,10)
end

function sortkey(o)
 if fget(o.type.tile,1) then
  return o.y-8
 else
  return o.y
 end
end
function sortobjs()
 for i=1,#objs do
  local j=i
  while j>1 and sortkey(objs[j-1])>sortkey(objs[j]) do
   objs[j],objs[j-1] = objs[j-1],objs[j]
   j=j-1
  end
 end
end

t=0
function _update()
 t+=1
 foreach(objs,function(o)
  if (o.type.update) o.type.update(o)
 end)
end

function simpledraw(this)
 spr(this.type.tile,this.x,this.y)
end

function sildraw(this,s)
 sprborder(this.type.tile,this.x,this.y)
end

function sprborder(s,x,y,fx)
 for c=1,15 do pal(c,0) end
 spr(s,x+1,y,1,1,fx)
 spr(s,x-1,y,1,1,fx)
 spr(s,x,y+1,1,1,fx)
 spr(s,x,y-1,1,1,fx)
 pal()
 spr(s,x,y,1,1,fx)
end

function walkdraw(this)
 local s=this.type.tile
 if (this.walking) s+=t\5%2*16
 sprborder(s,this.x,this.y,t\10%2==0)
end

poke(0x5f2d,1) --enable keyboard

types={}
player={
 tile=1,
 draw=function(this)
  walkdraw(this)
  if this.typing!=nil then
   local s=this.typing
   if (#s==0) s="..."
   circfill(this.x-3,this.y,1,7)
   circfill(this.x-5,this.y-4,2,7)
   for i=1,#s do
    circfill(this.x-#s*2+i*4+2,this.y-8,4,7)
   end
   print(s,this.x-#s*2+5,this.y-10,0)
  end
 end,
 update=function(this)
  local dx=0
  local dy=0
  if (btn(⬅️)) dx-=1
  if (btn(➡️)) dx+=1
  if (btn(⬆️)) dy-=1
  if (btn(⬇️)) dy+=1
  if this.typing==nil then
   --test
	  if (btnp(❎)) dx+=10
	 end
  this.move(dx,dy)
  this.walking=dx!=0 or dy!=0
  while stat(30) do --key pressed
   local k=stat(31) --get code
   if k=="p" then
    poke(0x5f30,1) --suppress pause menu
   elseif k=="\r" then --enter
    poke(0x5f30,1) --suppress pause menu
    if this.typing==nil then
     this.typing=""
    else
     this.typing=nil
    end
    goto continue
   elseif k=="\8" then --backspace
    this.typing=sub(this.typing,1,#this.typing-2)
    goto continue
   end
   if this.typing!=nil then
    this.typing=this.typing..k
   end
   ::continue::
  end
  if btnp(❎) and peek(0x5f2d)==0 then
   poke(0x5f2d,1) --enable keyboard
   this.typing=""
   --empty keyboard buffer
   while stat(30) do stat(31) end
  end
 end,
}
add(types,player)

guard={
 tile=2,
 draw=walkdraw,
}
add(types,guard)

miss={
 tile=3,
 draw=walkdraw,
}
add(types,miss)

coin={
 tile=6,
 draw=sildraw,
}
add(types,coin)

flower={
 tile=7,
 draw=sildraw,
}
add(types,flower)

function _init()
 for x=0,16 do
  for y=0,16 do
   local t=mget(x,y)
   foreach(types,function(ty)
    if ty.tile==t then
     local o={type=ty,x=x*8,y=y*8}
     if (ty.init!=nil) ty.init(o)
     initobj(o)
     add(objs,o)
     mset(x,y,0)
    end
   end)
  end
 end
end

function initobj(o)
 o.rx=0
 o.ry=0
 o.w=8
 o.h=8
 o.is_solid=function(x,y)
  local ox=o.x+x
  local oy=o.y+y
  local ex,ey=0,0
  if (ox%8!=0) ex+=1
  if (oy%8!=0) ey+=1
  for i=0,ex do for j=0,ey do
   local t=mget(ox\8+i,oy\8+j)
   if (fget(t,0)) return true
  end end
  for i=1,#objs do
   local e=objs[i]
   if not (
    o==e or
    not fget(e.type.tile,0) or
    ox+o.w<=e.x or
    ox>=e.x+e.w or
    oy+o.h<=e.y or
    oy>=e.y+e.h) then
    return true
   end
  end
  return false
 end
 o.move=function(x,y)
  poke(0x5f80+o.type.tile*2,o.x,o.y)
	 if (x==0 and y==0) return
  o.rx+=x
  o.ry+=y
  x=flr(o.rx)
  y=flr(o.ry)
  o.rx-=x
  o.ry-=y
  local sx=sign(x)
  for i=1,abs(x) do
   if o.is_solid(sx,0) then
    break
   else
    o.x+=sx
   end
  end
  local sy=sign(y)
  for i=1,abs(y) do
   if o.is_solid(0,sy) then
    break
   else
    o.y+=sy
   end
  end
 end
 o.move(0,0) --to set gpio
end

function sign(x)
 if (x>0) return 1
 if (x<0) return -1
 return 0
end
__gfx__
000000000044440000cccc0009999990555555555111111500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00dddddd09aaaaaa9155515551fff12f100000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000a4aa4a00d0dd0d09acaaca95555555511122ff1000aa000000000000000000000000000000000000000000000000000000000000000000000000000
000770009aaaaaa96dddddd60aaaaaa0555155551f2ff21100a9aa00000700000000000000000000000000000000000000000000000000000000000000000000
00077000099999900666666000eeee00555155551f2ff2f1009a7a00007970000000000000000000000000000000000000000000000000000000000000000000
007007000999999006666660aeeeeeea555155551121211100a7a900000700000000000000000000000000000000000000000000000000000000000000000000
000000000044440000cccc000eeeeee0555555511ff2fff1004a9400000b30000000000000000000000000000000000000000000000000000000000000000000
00000000009009000060060000c00c00551555515111111500044000000b00000000000000000000000000000000000000000000000000000000000000000000
000000000044440000cccc0000000000000000002ff2ff1251111115000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00dddddd000000000000000002222222212424241000000000000000000000000000000000000000000000000000000000000000000000000
000000000a4aa4a00d0dd0d00000000000000000f2ff2ff211111111000000000000000000000000000000000000000000000000000000000000000000000000
000000009aaaaaa06dddddd000000000000000002221122212242421000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999999066666660000000000000000ff2ff2ff12494921000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999900666666000000000000000002212221212494921000000000000000000000000000000000000000000000000000000000000000000000000
000000000044440000cccc0000000000000000002ff2ff2f11242411000000000000000000000000000000000000000000000000000000000000000000000000
00000000009000000060000000000000000000002222222251111115000000000000000000000000000000000000000000000000000000000000000000000000
__label__
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555551111115511111155111111551111115511111155555555555555555555555555555555555555555
5555555555555555555555555555555515551555555555551fff12f11fff12f11fff12f11fff12f11fff12f15555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555511122ff111122ff111122ff111122ff111122ff15555555555555555555555555555555555555555
5555555555555555555555555555555555515555555555551f2ff2111f2ff2111f2ff2111f2ff2111f2ff2115555555555555555555555555555555555555555
5555555555555555555555555555555555515555555555551f2ff2f11f2ff2f11f2ff2f11f2ff2f11f2ff2f15555555555555555555555555555555555555555
55555555555555555555555555555555555155555555555511212111112121111121211111212111112121115555555555555555555555555555555555555555
5555555555555555555555555555555555555551555555551ff2fff11ff2fff11ff2fff11ff2fff11ff2fff15555555555555555555555555555555555555555
55555555555555555555555555555555551555515555555551111115511111155111111551111115511111155555555555555555555555555555555555555555
55555555555555555111111555555555511111155555555555555555555555555555555551111115511111155555555555555555555555555555555555555555
555555555555555512424241555555551242424115551555555555555555555555555555124242411fff12f15555555555555555555555555555555555555555
5555555555555555111111115555555511111111555555555555555555555555555555551111111111122ff15555555555555555555555555555555555555555
555555555555555512242421555555551224242155515555555555555555555555555555122424211f2ff2115555555555555555555555555555555555555555
555555555555555512494921555555551249492155515555555555555555555555555555124949211f2ff2f15555555555555555555555555555555555555555
55555555555555551249492155555555124949215551555555555555555555555555555512494921112121115555555555555555555555555555555555555555
555555555555555511242411555555551124241155555551555555555555555555555555112424111ff2fff15555555555555555555555555555555555555555
55555555555555555111111555555555511111155515555155555555550000555555555551111115511111155555555555555555555555555555555555555555
5555555555555555555555555555555555555555555555555555555550cccc055555555555555555511111155555555555555555555555555555555555555555
555555555555555555555555555555555555555555555555555555550dddddd055555555555555551fff12f15555555555555555555555555555555555555555
555555555555555555555555555555555555555555555555555555550d0dd0d0555555555555555511122ff15555555555555555555555555555555555555555
555555555555555555555555555555555555555555555555555555506dddddd605555555555555551f2ff2115555555555555555555555555555555555555555
555555555555555555555555555555555555555555555555555555550666666055555555555555551f2ff2f15555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555066666605555555555555555112121115555555555555555555555555555555555555555
5555555555555555555555555555555555555555555555555555555550cccc0555555555555555551ff2fff15555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555506006055555555555555555511111155555555555555555555555555555555555555555
55555555555555555111111555555555555555555555555555555555550550555555555555555555511111155555555555555555555555555555555555555555
555555555555555512424241555555551555155555555555555555555555555555555555555555551fff12f15555555555555555555555555555555555555555
5555555555555555111111115555555555555555555555555555555555555555555555555555555511122ff15555555555555555555555555555555555555555
555555555555555512242421555555555551555555555555555555555555555555555555555555551f2ff2115555555555555555555555555555555555555555
555555555555555512494921555555555551555555555555555555555555555555555555555555551f2ff2f15555555555555555555555555555555555555555
55555555555555551249492155555555555155555555555555555555555555555555555555555555112121115555555555555555555555555555555555555555
555555555555555511242411555555555555555155555555555555555555555555555555555555551ff2fff15555555555555555555555555555555555555555
55555555555555555100001555555555551555515555555555555555555555555555555555555555511111155555555555555555555555555555555555555555
55555555555555555044440555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555550aaaaaa055555555555555551555155555555555555555555555555555555555555555555555555555555555555005555555555555555555
55555555555555550a4aa4a055555555555555555555555555555555555555555555555555555555555555555555555555555555550aa0555555555555555555
55555555555555509aaaaaa90555555555555555555155555555555555555555555555555555555555555555555555555555555550a9aa055555555555555555
55555555555555550999999055555555555555555551555555555555555555555555555555555555555555555555555555555555509a7a055555555555555555
5555555555555555099999905555555555555555555155555555555555555555555555555555555555555555555555555555555550a7a9055555555555555555
55555555555555555044440555555555555555555555555155555555555555555555555555555555555555555555555555555555504a94055555555555555555
55555555555555555090090555555555555555555515555155555555555555555555555555555555500000055555555555555555550440555555555555555555
55555555555555555505505555555555555555555555555555555555555555555555555555555555099999905555555555555555555005555555555555555555
555555555555555555555555555555551555155515551555155515555555555555555555555555509aaaaaa90555555555500555555555555550055555555555
555555555555555555505555555555555555555555555555555555555555555555555555555555509acaaca905555555550aa05555555555550aa05555555555
555555555555555555070555555555555551555555515555555155555555555555555555555555550aaaaaa05555555550a9aa055555555550a9aa0555555555
5555555555555555507970555555555555515555555155555551555555555555555555555555555500eeee0055555555509a7a0555555555509a7a0555555555
55555555555555555507055555555555555155555551555555515555555555555555555555555550aeeeeeea0555555550a7a9055555555550a7a90555555555
5555555555555555550b3055555555555555555155555551555555515555555555555555555555550eeeeee055555555504a940555555555504a940555555555
5555555555555555550b05555555555555155551551555515515555155555555555555555555555550c00c055555555555044055555555555504405555555555
55555555555555555550555555555555555555555555555555555555555555555555555555555555550550555555555555500555555555555550055555555555
55555555555555555555555555555555555555551555155555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555551555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555551555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555551555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555155555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555515555155555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__gff__
0001010100010200000000000000000000010100000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004000505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000160016040000001605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000002000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000160004000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010000040000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070004040400000003000600060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
a10f00000c5400c540105401054013540135401554015540135401354011540135401554015540005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0004000024550245502455023550235502455021550205501f5501f5501f5501f5501f5501f5501f5501f5501f5401f5401f5301f5301f5201f5100d5100d5000d5000d500005000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01f000000c840118400c840118401384011840108400c840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
