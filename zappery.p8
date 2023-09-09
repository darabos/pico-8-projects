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
 
b=ball(12,5,10,80)
b2=ball(8,5,10,60)
function _draw()
 t+=1
 cls()
 b:draw()
 b2:draw()
 for o in all(b2.ops)do
  o.x+=1
 end
end
function _update60()
 if(btn(⬅️))b.tx-=1
 if(btn(➡️))b.tx+=1
 if(btn(⬆️))b.ty-=1
 if(btn(⬇️))b.ty+=1
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
