pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
t=0
function ball(c,r,x,y)
 local b={c=c,r=r,x=x,y=y,tr=r,tx=x,ty=y,vx=rnd(),vy=rnd(),vr=rnd()}
 b.ops={}
 b.loffs={}
 for i=1,5 do
  b.loffs[i]={{x=0,y=0},{x=0,y=0}}
 end
 b.draw=function(b)
  if t%1==0 then
   j=t\2%2+1
		 for i=1,5 do
		  b.loffs[i][j]={x=i*(2-4*rnd()),y=i*(2-4*rnd())}
		 end
		end
	 for l=1,2 do
	  lx=b.x;ly=b.y
   for i=1,5 do
    k=i*10+l*5-5
    if(#b.ops<k)break
	   ox=lx;oy=ly
	   lx=b.ops[k].x+b.loffs[i][l].x
	   ly=b.ops[k].y+b.loffs[i][l].y
	   for j=-3,(3-i) do
	    line(ox,oy+j,lx,ly+j,b.c)
	    line(ox,oy+j,lx-1,ly,7)
	   end
	  end
  end
  add(b.ops,{x=b.x,y=b.y},1)
  if(#b.ops>60)deli(b.ops)
  b.vx+=.1*(1-2*rnd()+b.tx-b.x)
  b.vy+=.1*(1-2*rnd()+b.ty-b.y)
  b.vr+=.1*(1-2*rnd()+b.tr-b.r)
  b.vx*=0.99
  b.vy*=0.99
  b.vr*=0.9
  circfill(b.x,b.y,b.r,b.c)
  b.x+=b.vx
  b.y+=b.vy
  b.r+=b.vr
  circfill(b.x,b.y,b.r,7)
 end
 return b
end
 
b=ball(12,5,0,0)
b2=ball(8,5,-20,0)
cx,cy=0,0
menu=false
function _draw()
 if (cx-40<b.tx) cx+=1
 if (cx+40>b.tx) cx-=1
 if (cy-40<b.ty) cy+=1
 if (cy+40>b.ty) cy-=1
 camera(cx-64,cy-64)
 cls()
 if menu then
	 for o in all(b.ops)do
   o.x+=1
	 end
	end
 local lx,ly,la=0,0,0
 for dt in all(track) do
  local olx,oly,ola=lx,ly,la
  la+=rotationspeed*dt-0.5
  lx+=balldistance*cos(la)
  ly+=balldistance*sin(la)
  line(olx,oly,lx,ly,5)
  for bn in all({b,b2}) do
   for d=10,30,10 do
    if close(lx-bn.x,ly-bn.y,d) then
     line(olx+1-2*rnd(),oly+1-2*rnd(),lx+1-2*rnd(),ly+1-2*rnd(),bn.c)
    end
   end
  end
 end
 b.tx=lx
 b.ty=ly
 b:draw()
 b2:draw()
end
function close(dx,dy,d)
 return abs(dx)<d and abs(dy)<d
end
creating=true
rotationspeed=0.02
balldistance=20
lastswap=0
prevgap=0
track={}
function _update60()
 t+=1
 if btnp(❎) then
  b,b2=b2,b
  local dt=t-lastswap
  if (creating) add(track,dt)
  if (t>14400) t-=14400
  lastswap=t
  print(dt<prevgap*0.7 and "\ai6c1" or dt>prevgap*1.3 and "\ai1c2" or "\ai1c1")
  prevgap=dt
 end
 a=atan2(b2.tx-b.tx,b2.ty-b.ty)
 a+=rotationspeed
 b2.tx=b.tx+balldistance*cos(a)
 b2.ty=b.ty+balldistance*sin(a)
 b2.x=b2.tx
 b2.y=b2.ty
end
--[[
tolerance=3
function fixtiming(track)
-- if (true) return track
 local counts={}
 for t in all(track) do
  counts[t]=(counts[t] or 0)+1
 end
 local corrected={}
 for t in all(track) do
  for i=1,tolerance do
   if (counts[t+1]or 0>counts[t]) t+=1
	  if (counts[t-1]or 0>counts[t]) t-=1
  end
  add(corrected,t)
 end
 return corrected
end]]
