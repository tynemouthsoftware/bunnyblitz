

;Rabbit Blitz (C. Simun).prg ==1001==
    0 z=10:m1=254:poke36878,15:poke36879,8
    2 rem*open forum aug.
    3 rem"{inst}{inst}{inst}{inst}{inst}{inst}**************
    4 rem instrinstrinstrinstrinstrinstr*            *
    5 rem instrinstrinstrinstrinstrinstr*   rabbit   *
    6 rem instrinstrinstrinstrinstrinstr*    blitz   *
    7 rem instrinstrinstrinstrinstrinstr*            *
    8 rem instrinstrinstrinstrinstrinstr**************
    9 print"{clr}{wht}{down}{down}{down}{down}   rabbit blitz!!":print"{down}{down}{rght}(c)  by       {rvon}c.simun"
   10 print"{rght}{rght}{rght}{down}{down}{down}please wait"
   20 fori=0to501:poke7186+i,peek(32768):next
   30 fort=0to47:readd:poke7168+t,d:next
   40 data255,255,219,219,255,255,219,219
   50 data16,24,156,255,255,156,24,16
   60 data60,60,24,60,60,60,60,24
   70 data255,255,255,255,255,255,255,255
   80 data0,0,0,0,0,0,0,0
   90 data0,0,0,0,24,60,126,255
  100 print"{clr}":z=z-1:poke36869,255:b=0:poke650,127:poke36879,25:ifsc=10then5000
  110 fort=8120to8185:poket,3:poke30720+t,5:next
  120 a$(1)="{blk}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}e{left}{down}@{left}{down}@{left}{down}@{left}{down}@{left}{down}@{left}{down}@"
  125 a$(2)="{blk}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}e{left}{down}@{left}{down}@{left}{down}@{left}{down}@{left}{down}@{left}{down}@{left}{down}@{left}{down}@"
  130 a$(3)="{blk}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}e{left}{down}@{left}{down}@{left}{down}@{left}{down}@"
  135 a$(4)="{blk}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}e{left}{down}@{left}{down}@"
  200 fort=0to21
  210 print"{home}"tab(t);a$(int(rnd(1)*6)+1)
  220 nextt
 1000 poke7680+q,1:poke7680+30720+q,6
 1111 forh=1toz:nexth:print"{rvon}{blk}{home}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{rght}{rght}{rght}"tb,b
 1112 geta$:ifa$=" "thengosub3000
 1113 ifpeek(7680+q+1)=5orpeek(7680+q+1)=0then1998
 1114 ifpeek(7680+q+22)=3thensc=sc+1:q=0:goto100
 1115 ifa$="^"thengosub7000
 1117 poke7680+q,4:q=q+1
 1120 poke36877,245
 1121 goto1000
 1998 poke36877,150:fort=1to10:poke36865,50:forx=1to50:nextx:poke36865,30
 1999 forx=1to50:nextx:nextt:poke36865,40
 2000 fort=1to2000:nextt:poke36877,0:print"{clr}{home}{down}{down}{down}{down}sorry youre dead"
 2150 poke36869,240:goto5030
 3000 ifb=30thenreturn
 3005 fort=7680+qto8119step22
 3010 poket,2:poket+30720,2:poke36874,m1
 3030 forp=1to10:nextp
 3040 poket,4:m1=m1-2
 3050 ifpeek(t+22)=0andpeek(t+44)=3thentb=tb+1
 3051 ifpeek(t+22)=5thenpoke36877,130
 3060 nextt:q=q+int(rnd(1)*3):b=b+1:m1=254:poke36874,0:poke36877,0:poke36876,0:return
 5000 print"{clr}":poke36869,240:poke36877,0
 5010 print"{down}{down}{rght}{rvon}well done you ve"
 5020 print"{down}{down}{rght}{rvon}landed perfectly"
 5030 print"{down}{down}{down}{down}{rght}you landed "sc"times"
 5032 print"{down}{down}you destroyed"tb:print"buildings{down}{down}"
 5035 gosub10000
 5040 print"another go?
 5050 geta$:ifa$="y"thenrun
 5060 ifa$="n"thenprint"{clr}":end
 5070 goto5050
 7000 poke36877,0:poke36874,0:poke198,0:wait198,1:poke198,0
 7010 poke36877,245
 7011 return
 10000 fort=0to255step22:poke36879,t:forb=1to100:next:next:poke36879,25:return

