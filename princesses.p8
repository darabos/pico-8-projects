pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
poke(0x5f5c,255)--no repeat for btnp
poke(0x5f2e,1)--keep palette
function pl()
 pal()
-- pal(13,13+128,1)
end
t=0
mode="select"
objs={}
function _init()
 p1.ox=p1.x
 p2.ox=p2.x
	chars={
	 catra=catra,
	 adora=adora,
	 double=double,
	 glimmer=glimmer,
	 entrapta=entrapta,
	 none={extra={}},
	}
end
function _update60()
t+=1
if mode=="fight" then
 updateplayer(p1)
 updateplayer(p2)
	foreach(objs,function(o)
	 if (o.update) o.update(o)
	end)
elseif mode=="select" then
 updateselect(p1)
 updateselect(p2)
 if p1.ready and p2.ready then
  mode="fight"
  music(0)
 end
end
p1.flip=p1.x<p2.x
p2.flip=p1.x>p2.x
local dx=p1.x-p2.x
local dy=p1.y-p2.y
if abs(dx)<10 and abs(dy)<10 then
 p1.x+=sgn(dx)*(10-abs(dx))/2
 p2.x-=sgn(dx)*(10-abs(dx))/2
end
end
function updateplayer(p)
 p.ox=p.x
 p.oy=p.y
 local h=chars[p.head].head
 local b=chars[p.body].body
 local a=chars[p.arms].arms
 local x=chars[p.extra].extra
 if (h.update) h.update(p)
 if (b.update) b.update(p)
 if (a.update) a.update(p)
 if (x.update) x.update(p)
end
partnames={"head","body","arms","extra"}
function updateselect(p)
 local part=p.selectedpart
 if (part==nil) part=0
 if btnp(⬇️,p.btn) then
  sfx(0,-1,2,1)
  part+=1
 end
 if btnp(⬆️,p.btn) then
  sfx(0,-1,3,1)
  part+=#partnames-1
 end
 part%=#partnames
 p.selectedpart=part
 local pname=partnames[part+1]
 if btnp(⬅️,p.btn) then
  sfx(0,-1,2,1)
  local last=nil
  local new=nil
  for k,v in pairs(chars) do
   if k==p[pname] then
    new=last
   end
   if (v[pname]) last=k
  end
  if (new==nil) new=last
  p[pname]=new
 end
 if btnp(➡️,p.btn) then
  sfx(0,-1,3,1)
  local last=nil
  local new=nil
  local first=nil
  for k,v in pairs(chars) do
   if (first==nil and v[pname]) first=k
   if last==p[pname] then
    new=k
   end
   if (v[pname]) last=k
  end
  if (new==nil) new=first
  p[pname]=new
 end
 if btnp(❎,p.btn) then
  p.ready=not p.ready
  sfx(0,-1,6,2)
 end
end

p1={btn=0,x=40,y=-8,flip=true,
head="entrapta",arms="entrapta",body="entrapta",extra="none"}
p2={btn=1,x=-40,y=-8,flip=false,
head="entrapta",arms="entrapta",body="entrapta",extra="none"}
--head="glimmer",arms="glimmer",body="glimmer",extra="none"}
--head="double",arms="double",body="double",extra="double"}
--head="catra",arms="catra",body="catra",extra="catra"}
--head="adora",arms="adora",body="adora",extra="none"}

camerax=0
function _draw()
local cx=(p1.x+p2.x)/2
camerax=camerax*0.8+cx*0.2
camera(camerax-64,-90)
levels[level].draw(camerax)
foreach(objs,function(o)
 if (o.drawunder) o.drawunder(o)
end)
drawplayer(p1)
drawplayer(p2)
foreach(objs,function(o)
 if (o.draw) o.draw(o)
end)
if mode=="select" then
 drawselect(p1)
 drawselect(p2)
end
end

function drawselect(p)
 local part=partnames[p.selectedpart+1]
 print(part,p.x-#part*2,p.y-44,15)
 spr(35,p.x-4,p.y-50)
 pal(9,10)
 pal(10,9)
 spr(35,p.x-4,p.y-41,1,1,false,true)
 pl()
 local option=p[part]
 spr(34,p.x-#option*2-7,p.y-30)
 spr(34,p.x+#option*2-2,p.y-30,1,1,true)
 print(option,p.x-#option*2,p.y-28)
 if p.ready then
  print("ready",p.x-#"ready"*2,p.y-20,10)
 end
end

function drawplayer(p)
if (p.invisible) return
local h=chars[p.head].head
local b=chars[p.body].body
local a=chars[p.arms].arms
local x=chars[p.extra].extra
if (h.drawunder) h.drawunder(p)
if (b.drawunder) b.drawunder(p)
if (a.drawunder) a.drawunder(p)
if (x.drawunder) x.drawunder(p)
if (h.draw) h.draw(p)
if (b.draw) b.draw(p)
if (a.draw) a.draw(p)
if (x.draw) x.draw(p)
--circ(p.x,p.y,3,7)circ(p.x,p.y,10,7)
end

levels={
{draw=function(x)
cls()
circfill(x,0,80,1)
for i=0,20 do
 local rx=(i*80%17*10+t/200)%170-85
 local ry=i*18%29*-3
 local rz=i*19%13
 ovalfill(x+rx-rz*cos(rx/400),ry-rz*cos(ry/400),x+rx+rz*cos(rx/400),ry+rz*cos(ry/400),0)
end
for i=0,20 do
 local rx=i*10%17*20-170
 local rz=i*19%13+2
 local ry=i*15%29*-1-rz
 local d=i%3+2
 circfill(x/d+rx,ry,rz,0)
 rectfill(x/d+rx-rz/3,ry,x/d+rx+rz/3,0,0)
end
for i=0,3 do
 local rx=i*10%17*20-170
 local rz=i*19%13+30
 local d=i%3+2
	for i=0,5 do
	 circ(x/d+rx,0,rz-i,0)
	end
end
for i=0,3 do
 local rx=i*10%17*20-170
 local rz=i*19%13+50
	for i=0,5 do
	 circ(rx,0,rz-i,1)
	end
end

rectfill(x-64,0,x+64,64,2)
line(x-64,0,x+64,0,3)
local cs={3,11,1}
for i=0,127 do
 local z=flr(x+i-64)
 if (z%11+z%17)%3==0 then
  pset(z,-1,cs[z%#cs+1])
 end
end
end},
}
level=1
-->8
catra={}
catra.head={draw=function(p)
 local f=tonum(p.flip)
 local ph=sin(t*0.01)+0.5
 local height=chars[p.body].body.height
 if (p.flip) pal(10,12)
 spr(1,p.x-2-2*f+ph,p.y-height-1,1,1,p.flip)
 pal()
end}

catra.body={height=7,draw=function(p)
local s=6
local w=2
local h=1
local f=tonum(p.flip)
if not p.jumping and
  (btn(⬅️,p.btn) or
   btn(➡️,p.btn)) then
 local ph=sin(t*0.02)+0.3
 f=tonum(ph>0)
 if abs(ph)<0.5 then
  s=8
  w=1
 end
end
if p.jumping then
 if p.y<-12 and p.jumping==1 then
  s=9;w=1;h=2
 else
  s=8;w=1;h=1
 end
end
spr(s,p.x-w*4+2*f,p.y,w,h,f>0)
end,update=function(p)
if (btn(⬅️,p.btn)) p.x-=1
if (btn(➡️,p.btn)) p.x+=1
if (p.y==-8 and btnp(⬆️,p.btn)) then
 p.jumping=1
 sfx(0,-1,2,2)
end
if p.jumping==1 then
 p.y-=1
 if p.y<-28 then
  p.jumping=2
 end
elseif p.jumping==2 then
 p.y+=1
 if p.y>=-8 then
  p.y=-8
  p.jumping=nil
 end
end
end}

catra.arms={draw=function(p)
 local f=tonum(p.flip)
 local ph=sin(t*0.01-0.1)+0.5
 local th=(2*f-1)*cos(t*0.01-0.1)+0.5
 local height=chars[p.body].body.height
 local s=2
 if btn(❎,p.btn) then ph=6*f-3;s=18 end
 spr(s,p.x-5+4*f+ph,p.y-height+5+th/2,1,1,p.flip)
end,update=function(p)
 if btnp(❎,p.btn) then
  sfx(0,-1,0,2)
 end
end}

catra.extra={draw=function(p)
 local height=chars[p.body].body.height
 local f=tonum(p.flip)
 local ph=sin(t*0.01)+4.5
 spr(ph,p.x+1-8*f,p.y-height\2,1,1,p.flip)
end}
-->8
adora={}
adora.head={draw=function(p)
 local f=tonum(p.flip)
 local ph=sin(t*0.008)+0.5
 local height=chars[p.body].body.height
 if (p.jumping==1) ph=-1
 if (p.jumping==2) ph=1
 spr(ph+20,p.x-3-1*f,p.y-height,1,1,p.flip)
end}

adora.body={height=9,draw=function(p)
 local f=tonum(p.flip)
 spr(22,p.x-4+1*f,p.y-6,1,1,f>0)
 local s=38+(t\30%4)
 if (s==41) s=39
	local steps={38,41,42,43}
	local dirs={⬅️,➡️}
	if btn(⬅️,p.btn) or btn(➡️,p.btn) then
	 if btn(dirs[f+1],p.btn) then
 	 s=steps[t\10%4+1]
	 else
	  s=steps[-t\10%4+1]
	 end
	elseif p.jumping then
	 s=41
	end
 spr(s,p.x-4+1*f,p.y,1,1,f>0)
end,update=function(p)
 catra.body.update(p)
end}

adora.arms={draw=function(p)
 local f=tonum(p.flip)
 local height=chars[p.body].body.height
 if btn(❎,p.btn) then
  spr(24,p.x-6+5*f,p.y-height+3,1,1,p.flip)
 else
  spr(23,p.x-4+1*f,p.y-height+3,1,1,p.flip)
 end
end,update=function(p)
 catra.arms.update(p)
end}
-->8
double={}
double.head={drawunder=function(p)
 local height=chars[p.body].body.height
 rectfill(p.x-2,p.y-height+3,p.x+2,p.y-height+6,15)
 rectfill(p.ox-2,p.y-height+7,p.ox+2,p.y-height+8,15)
 rectfill(p.ox*2-p.x-1,p.y-height+9,p.ox*2-p.x+1,p.y-height+9,15)
end,draw=function(p)
 local f=tonum(p.flip)
 local height=chars[p.body].body.height
 local ph=0
 if (p.jumping==1) ph=1
 if (p.jumping==2) ph=-1
 spr(28,p.x-4+1*f,p.y-height+1,1,1,p.flip)
 --ears
 pset(p.x-4,p.y-height+4+ph,11)
 pset(p.x+4,p.y-height+4+ph,11)
end}

double.body={height=11,draw=function(p)
 local f=tonum(p.flip)
 if btn(⬅️,p.btn) or btn(➡️,p.btn) or p.jumping then
  local ph=t\15%4
  if (p.jumping) ph=f*2+1
  local th=ph%4\2
  spr(10,p.x-4+1*f,p.y-8,1,1,f>0)
  if ph%2==1 then
   spr(14,p.x-4+th,p.y,1,1,th>0)
  else
   spr(26,p.x-4+th,p.y,1,1,th>0)
  end
 else
  spr(10,p.x-4+1*f,p.y-8,1,2,f>0)
 end
end,update=function(p)
 catra.body.update(p)
end}

double.arms={draw=function(p)
 local f=tonum(p.flip)
 local height=chars[p.body].body.height
 spr(27,p.x+1-9*f,p.y-height+8,1,0.5,p.flip)
 sspr(88,12,8,4,p.x-9+11*f,p.y-height+8,8,4,p.flip)
end,update=function(p)
 catra.arms.update(p)
end}

double.extra={drawunder=function(p)
 local height=chars[p.body].body.height
 local f=tonum(p.flip)
 local ph=sin(t*0.01)+1.1
 spr(11+ph,p.x-7*f,p.y-max(-1,height\2-5),1,1,p.flip)
end}
-->8
glimmer={}
glimmer.head={draw=function(p)
 local f=tonum(p.flip)*2-1
 local height=chars[p.body].body.height
 spr(50,p.x-3+0.5*f,p.y-height,1,1,p.flip)
 if btn(⬇️,p.btn) then
  circ(p.x,p.y,10,7)
 end
end}

glimmer.body={height=7,drawunder=function(p)
 local f=tonum(p.flip)*2-1
 if p.jumping==2 then
  spr(36,p.x-3-3.5*f,p.y-5,1,1,f>0,true)
 else
  spr(36,p.x-3-3.5*f,p.y,1,1,f>0)
 end
end,draw=function(p)
 local f=tonum(p.flip)
 local s=53
 local bs={⬅️,➡️}
 if (btn(bs[f+1],p.btn) or p.jumping) s=54
 if (btn(bs[2-f],p.btn)) s=55
 f=f*2-1
 spr(s,p.x-3-0.5*f,p.y,1,1,f>0)
end,poof=function(p)
 for i=1,20 do
	 add(objs,{
	  t0=t-rnd()*20,
	  rate=rnd()*10+10,
	  x=p.x+rnd()*15-7,
	  y=p.y-rnd()*15+4,
	  update=function(s)
	   if t-s.t0>40 then
	    del(objs,s)
	   end
	  end,
	  draw=glimmerspark})
 end
end,update=function(p)
 if p.teleporting then
  if t>=p.teleportstart+30 then
   p.teleporting=false
   p.x=camerax+flr(rnd()*100)-50
   p.y=-flr(rnd()*30)-8
   p.jumping=2
   p.invisible=false
 		glimmer.body.poof(p)
  end
  return
 end
 catra.body.update(p)
 if btnp(🅾️,p.btn) then
		glimmer.body.poof(p)
		p.teleporting=true
		p.invisible=true
		p.teleportstart=t
  sfx(0,-1,13,5)
 end
end}

glimmer.arms={drawunder=function(p)
 local f=tonum(p.flip)*2-1
 local height=chars[p.body].body.height
 local d=sin(t/100)*1.4+2.5
 if (btn(❎,p.btn)) d=4
 spr(52,p.x-3+d*f,p.y-height+5,1,1,p.flip)
end,draw=function(p)
 local f=tonum(p.flip)*2-1
 local height=chars[p.body].body.height
 if p.jumping then
  spr(51,p.x-3-0.5*f,p.y-height+7,1,1,p.flip,true)
 else
  spr(51,p.x-3-0.5*f,p.y-height+2,1,1,p.flip)
 end
end,update=function(p)
 if (not btnp(❎,p.btn)) return
 sfx(0,-1,18+flr(rnd()*3),1)
 local height=chars[p.body].body.height
 local f=tonum(p.flip)*2-1
 add(objs,{
  dir=f,t0=t,x=p.x+f*(5+rnd()*3),y=p.y+2-height+rnd()*3,rate=20,
  update=function(s)
   s.x+=s.dir
   if t-s.t0>40 then
    del(objs,s)
   end
  end,
  draw=glimmerspark})
end}

function glimmerspark(s)
 local cs={0,2,14,7,14,2,0}
 local ph=(t-s.t0)/s.rate
 function h(x)
  return cs[mid(1,flr(x*4+1),#cs)]
 end
 local p={
  [2]=h(ph-0.2),
  [14]=h(ph),
  [7]=h(ph*0.5+0.7)}
 for k,v in pairs(p) do
  if (v==0) palt(k,true)
 end
 pal(p)
 local hf=t\4%2
 local vf=t\8%2
 spr(37,s.x-4+hf,s.y-vf,1,1,hf!=0,vf!=0)
 pal() palt()
end
-->8
entrapta={}
entrapta.head={draw=function(p)
 local f=tonum(p.flip)*2-1
 local height=chars[p.body].body.height
 spr(44,p.x-7+0.5*f,p.y-height,2,2,p.flip)
end}

entrapta.body={height=7,draw=function(p)
 local f=tonum(p.flip)*2-1
 spr(56,p.x-3+0.5*f,p.y,1,1,f>0)
end}

entrapta.arms={draw=function(p)
 local f=tonum(p.flip)*2-1
 local height=chars[p.body].body.height
 sspr(
  57%16*8+4,57\16*8,4,8,
  p.x-1-1.5*f,p.y-height\2+3,4,8,p.flip)
end,drawunder=function(p)
 local f=tonum(p.flip)*2-1
 local height=chars[p.body].body.height
 sspr(
  57%16*8,57\16*8,4,8,
  p.x-1+2.5*f,p.y-height\2+3,4,8,p.flip)
end,update=function(p)
 if (not btnp(❎,p.btn)) return
 sfx(0,-1,18+flr(rnd()*3),1)
end}
__gfx__
00000000000000000700000000000000000000000000000000000000220000000000220000002200000000000000000000000000000000000005553000000000
0000000000600000009000000000000000000000000000000000000022000000000222000002220000000000000000000000000000003b000003333000000000
00700700855556000799000000004490000004900044400000000000220000000022200000022000000000000b0000000b000bb00b00b0b00005335000000000
000770008555555000099220000040000000440000404490000002922400000002222490000220000000000000b000b000bb000b00bb00b00000555000000000
0007700098556500000000000000400000044000004000000000220002200000022222200002200000555550000b000b0000b00b0000bb000000030000000000
00700700a89555600000000000044000004400000440000000022000009200000011119000012000005353500000b00b00000bb0000000000000333000000000
000000009995555500000000444400004440000044000000000220000002200000022200000120000005550000000bb000000000000000000000555000000000
00000000009400000000000000000000000000000000000000929000000929000009290000012000000b5b000000000000000000000000000000555000000000
000000000000000007000000000000000000000000000000000000000000000000000000000122110005553000b000b0000fff00000000000000000000000000
000ee00ee0dee0007000000099099000990990009909900000000000000000000000000000001214003353300050550000bbfbb0000000000000000000000000
000dddddddddd0007000000099999900999999009999900000000000000000000000000000000220005303500005500000bbbbb0000000000000000000000000
00eddd9999ddde0070999222ff990900ff990990ff9999090006700000000000000000000000022200550550000000000b3a3a3b000000000000000000000000
00dddd94942ddd0070900000cff90990cff90099cff909990007800000008800f77888800000092900300300000005b000bbbbb0000000000000000000000000
00ddd29999d2dd0007900000ffff0099ffff0009ffff000000088000f00888000000888000000000033003000000550000003000000000000000000000000000
000d2d0770dd22000077000000440000004400000044000000088000778880000000000000000000555005500005500000000000000000000000000000000000
0002dd92299ddd00000000000000000000000000000000000002200000f0000000000000000000005500055000b0000000000000000000000000000000000000
000dd992922ddd0000000000000100000ccccc000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd2277720dde000001000001a10000c55ccc002002000000000000000000000000000000000000000000000000000000eed0ee00ee0000000000000000000
000d2228772eedd00001a10001a9a10000555ccc0002e200000888000008800000888000000880000008800000088000000dddddddddd0000000000000000000
00e22288722222d0001a91001a919a10000055cc002e7e2000066000000668000066600000066800000660000006680000eddd9999ddde000000000000000000
00dd2222d8220d2001a91100011111000000050c0002e20000d6660000d660000dd660000066600000666d0000d6600000ddd24949dddd000000000000000000
00dd022288800dd00019a10000000000000000000000202000dd678000d677000ddd7800006780000078dd2000d7800000dd2d99992ddd000000000000000000
0edd002828000ddd00019100000000000000000002000000002207800022d7800022d7800008820000780220000782000022dd0770d2d0000000000000000000
ddd00000000000dd0000100000000000000000000000000002220880022208800222088000022200088802200008820000ddd00000dd20000000000000000000
00000000000000000000000000000000f000000000eee00000eee00000eee0000002200009900900000000000000000000ddd00000ddd0000000000000000000
00000000000000000eeee000000000000700000000eee00000eee00000eeee00002920000220099000000000000000000edd0000002dd0000000000000000000
0000000000000000eeeeeee0000000f0f777fcc000eeee0000eeee00002eee00007770000200022000000000000000000dd2000000d2d0000000000000000000
00000000000000002fffee200000000f0007fff0002eeee000eeee000022eee0007770000200822200000000000000000d2d0000000d2e000000000000000000
00000000000000000f2fff2000000070000000000222eee0022eee000222eee02207702288008800000000000000000002d00000000ddd000000000000000000
00000000000000000ffff22000000770000000000ff0ff000ff0ff000ff0ff00228d22220900000000000000000000000dd000000000dd000000000000000000
000000000000000000044000000ff7700000000000f2cf0000f20fc00f00cf0008882220000000000000000000000000ddd0000000002de00000000000000000
0000000000000000000000000000f70000000000000cc000000200c0220cc00000828200000000000000000000000000dd000000000002dd0000000000000000
__sfx__
031000003e630316500c55011551301623416230566355602f250302502f3502d3502f35039156305563753015556305513755535555305550000000000000000000000000000000000000000000000000000000
351b00001873018735187351a7351b7301b7301f7301f73020730207301f7301d7301f7301f7301f7321f7351873018735187351a7351b7301b7301f7301f730247302473022730227301f7301f7301f7321f735
351b00001873018735187351a7351b7301b7301f7301f73020730207301f7301d7301f7301f7301f7301f73520730207301f7302173022730227301f7301d7301f7301f7301f7301f7301f7321f7321f7321f732
c51b00000013200135001320013500132001350013200135081320813508132081350313203135031320313500132001350013200135001320013500132001350813208135081320813503132031350313203135
c51b00000013200135001320013500132001350013200135081320813508132081350313203135031320313508132081350813208135051320513505132051350713207135071320713507132071350713207135
351b00001503015035150351703518030180301c0301c0301d0301d0301c0301a0301c0301c0301c0301c0351d0301d0301c0301d0301f0301f03021030230302403024030240302403024022240222401224012
c51b00001013210135101321013510132101351013210135181321813518132181351313213135131321313515132151321513215132171321713217132171321813218132181321813218122181221811218112
__music__
00 01034344
00 02044344
04 05064344

