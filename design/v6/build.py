"""Build editable game assets only: native Penpot primitives and matching SVGs."""
from pathlib import Path
import json, html

ROOT=Path(__file__).parent
A=[]
INK='#17242B'; SILVER='#B9CDD1'; LIGHT='#EEF7F0'; GOLD='#FFD36A'
def rect(x,y,w,h,c): return ['r',x,y,w,h,c]
def path(d,c): return ['p',d,c]
def ellipse(x,y,w,h,c): return ['e',x,y,w,h,c]
def text(x,y,w,h,s,size=20,c=LIGHT): return ['t',x,y,w,h,s,size,c]
def add(key,name,category,w,h,shapes,note='',proposal=False):
    A.append(dict(key=key,name=name,category=category,width=w,height=h,shapes=shapes,note=note,proposal=proposal))
def pix(points,c,s=3,ox=0,oy=0):
    return [rect(ox+x*s,oy+y*s,w*s,h*s,c) for x,y,w,h in points]

def drink(key,name,color,shade,mark,kind='can'):
    s=[rect(18,3,60,3,INK),rect(12,6,72,6,INK),rect(9,12,78,120,INK),rect(12,132,72,6,INK),rect(18,138,60,3,INK),rect(15,12,66,6,SILVER),rect(15,18,66,108,color),rect(15,126,66,9,SILVER),rect(69,18,12,108,shade),rect(21,21,6,99,'#FFFFFF'),rect(27,21,3,99,color),rect(27,6,42,6,'#DDE6E2'),rect(45,6,15,3,INK)]
    # One small motif per can. No package lettering or detailed illustration.
    if mark=='water':s += [path('M 48 48 L 33 72 L 33 84 L 42 93 L 54 93 L 63 84 L 63 72 Z',LIGHT)]
    elif mark in ('leaf','barley'):
      s += [path('M 33 90 L 36 66 L 66 48 L 63 75 L 42 90 Z',LIGHT),rect(42,72,18,6,shade)]
      if mark=='barley': s += [rect(45,45,6,54,'#F6E7AB'),rect(36,54,9,6,'#F6E7AB'),rect(51,63,9,6,'#F6E7AB')]
    elif mark in ('ion','energy'):
      s += [path('M 51 42 L 33 75 L 48 75 L 42 102 L 66 66 L 51 66 Z',LIGHT if mark=='ion' else '#95F7EC')]
    elif mark in ('apple','peach'):
      s += [rect(33,66,30,24,LIGHT),rect(30,72,36,12,LIGHT),rect(45,57,6,9,INK),rect(51,54,12,6,'#4B815A')]
      if mark=='peach':s += [rect(48,69,3,18,shade)]
    elif mark in ('orange','lemon'):
      s += [rect(36,57,24,36,LIGHT),rect(30,63,36,24,LIGHT),rect(36,66,24,18,color),rect(45,60,6,30,LIGHT),rect(33,72,30,6,LIGHT)]
    elif mark=='ginger':s += [rect(33,63,30,18,'#F4D6A3'),rect(27,72,18,12,'#F4D6A3'),rect(54,54,12,18,'#F4D6A3'),rect(42,57,9,15,'#F4D6A3')]
    elif mark=='sprite':s += [path('M 30 78 L 48 54 L 66 78 L 48 96 Z',LIGHT),path('M 36 78 L 48 63 L 60 78 L 48 90 Z','#F7DE7F')]
    elif mark=='vitamin':s += [rect(42,54,12,42,LIGHT),rect(27,69,42,12,LIGHT)]
    elif mark=='melon':s += [path('M 27 63 L 69 63 L 63 87 L 48 96 L 33 87 Z',LIGHT),rect(33,66,30,9,'#A8D98D'),rect(39,78,3,6,shade),rect(54,78,3,6,shade)]
    elif mark=='grape':s += [rect(33,60,15,15,LIGHT),rect(51,60,15,15,LIGHT),rect(39,78,15,15,LIGHT),rect(51,78,12,12,LIGHT),rect(45,93,12,9,LIGHT),rect(48,51,12,6,'#78B282')]
    elif mark=='cola':s += [path('M 24 84 L 69 54 L 72 69 L 27 99 Z',LIGHT)]
    add(key,name,'Items/Drinks',96,144,s,'32×48 logical pixels at 3×. No baked name, effect, price or quantity.')

D=[
('water','01 · 물','#69CDE8','#3A95C6','water'),('green-tea','02 · 녹차','#99C779','#629B5B','leaf'),('barley-tea','03 · 보리차','#D3AF6F','#9F7953','barley'),('ion','04 · 이온음료','#94BFE4','#6286C3','ion'),('apple','05 · 사과 주스','#E58B78','#BD5C5A','apple'),('ginger-ale','06 · 진저에일','#D9AD64','#9D7D40','ginger'),('lemonade','07 · 레모네이드','#F2D873','#C4A452','lemon'),('sprite','08 · 스프라이트','#73C7A3','#3F937B','sprite'),('peach-juice','09 · 복숭아 주스','#EFAEAE','#CC7C91','peach'),('orange','10 · 오렌지 주스','#F2AE61','#D27D42','orange'),('vitamin','11 · 비타민 음료','#F1CF6B','#C99A44','vitamin'),('melon-soda','12 · 멜론 소다','#B7D58C','#82AB62','melon'),('fanta-grape','13 · 환타 포도','#B599CD','#8366AC','grape'),('cola','14 · 콜라','#D97776','#A24C55','cola'),('energy-drink','15 · 에너지 드링크','#465360','#B86DAB','energy')]
for row in D:drink(*row)

# Goods and recyclable materials use the same compact, editable pixel vocabulary.
add('ramen','라멘','Items/Goods',96,96,[rect(15,39,66,12,INK),rect(21,51,54,24,INK),rect(30,75,36,9,INK),rect(21,42,54,9,'#F1D17A'),rect(27,54,42,18,'#D36D5C'),rect(33,72,30,6,'#F2E4BF'),rect(33,27,6,15,'#F2E4BF'),rect(54,24,6,18,'#F2E4BF')])
add('magazine','잡지','Items/Goods',96,96,[rect(18,12,60,72,INK),rect(24,18,48,60,'#90B9CC'),rect(24,18,6,60,'#597E9C'),rect(36,27,27,6,'#F5DE8B'),rect(36,39,24,24,'#D7786C'),rect(36,69,27,3,LIGHT)],'Cover artwork is decorative; product title remains external text.')
add('figure','피규어','Items/Goods',96,96,[rect(30,12,36,30,INK),rect(36,18,24,18,'#D8B9DA'),rect(24,42,48,27,INK),rect(33,45,30,21,'#A39AD3'),rect(18,48,12,21,INK),rect(66,48,12,21,INK),rect(30,69,12,12,INK),rect(54,69,12,12,INK),rect(21,81,54,6,'#839AB0')],'Generic collectible silhouette. Final character/IP is undecided.')
add('pizza','피자','Items/Goods',96,96,[path('M 15 21 L 81 21 L 48 81 Z',INK),path('M 24 30 L 72 30 L 48 69 Z','#EED47A'),rect(21,21,54,9,'#BE8757'),rect(36,36,9,9,'#C3675D'),rect(51,45,9,9,'#C3675D')])
add('empty-can','빈캔','Items/Materials',96,96,[rect(27,15,42,9,INK),path('M 24 24 L 72 24 L 66 45 L 75 69 L 63 81 L 27 78 L 21 60 L 30 42 Z',INK),path('M 30 27 L 66 27 L 60 45 L 69 66 L 60 75 L 33 72 L 27 60 L 36 42 Z',SILVER),rect(39,18,18,3,LIGHT),rect(33,54,24,6,'#7D9CA7')])
add('empty-container','빈 용기','Items/Materials',96,96,[rect(15,33,66,9,INK),path('M 21 42 L 75 42 L 63 78 L 33 78 Z',INK),path('M 27 42 L 69 42 L 60 72 L 36 72 Z','#D6E3DB'),rect(24,33,48,6,'#819EAA')],'Ramen/container material mapping is a proposal.',True)
add('wastepaper','폐지','Items/Materials',96,96,[rect(18,27,60,54,INK),rect(24,33,48,42,'#E4DEBE'),rect(12,15,60,54,INK),rect(18,21,48,42,'#F0E9CD'),rect(27,30,30,3,'#98A69B'),rect(27,39,24,3,'#98A69B'),rect(27,48,30,3,'#98A69B')],'Material-to-region mapping is unconfirmed.',True)
add('empty-capsule','빈 캡슐','Items/Materials',96,96,[path('M 27 24 L 69 24 L 78 39 L 78 57 L 69 72 L 27 72 L 18 57 L 18 39 Z',INK),path('M 30 30 L 66 30 L 72 42 L 24 42 Z','#BDCCD8'),path('M 24 48 L 72 48 L 72 54 L 63 66 L 33 66 L 24 54 Z','#D2ACCD'),rect(27,42,42,6,'#7E8EAC')],'Capsule payout mapping is a proposal.',True)
add('pizza-box','빈 피자 상자','Items/Materials',96,96,[path('M 12 33 L 57 18 L 84 33 L 84 66 L 39 81 L 12 66 Z',INK),path('M 18 36 L 57 24 L 78 36 L 39 51 Z','#D0A977'),path('M 18 42 L 36 54 L 36 72 L 18 63 Z','#AA805C'),path('M 42 54 L 78 42 L 78 63 L 42 75 Z','#C49669')],'Material-to-region mapping is unconfirmed.',True)

# Modular machine B. Shared transparent registration canvas guarantees layer alignment.
W,H=350,525
body=[rect(28,24,294,468,INK),rect(33,29,284,458,'#D45550'),rect(38,34,274,448,'#F16E5D'),rect(38,60,274,8,'#A93640'),rect(48,72,224,282,INK),rect(54,78,212,270,'#50474C'),rect(55,399,216,57,INK),rect(60,404,206,47,'#303947'),rect(48,490,50,18,INK),rect(256,490,50,18,INK),rect(55,493,36,10,'#8899A5'),rect(263,493,36,10,'#8899A5')]
for x,y,w,h in [(45,364,24,12),(78,370,18,8),(140,371,40,16),(277,372,20,12),(299,92,8,18),(42,461,16,8)]:body.append(rect(x,y,w,h,'#CBB9A8'))
add('b-body','B · 본체 프레임','World/Vending/Parts',W,H,body,'Fixed registration canvas 350×525; display, payment, hatch and shadow are independent.')
window=[]
for row in range(3):
 y=78+90*row;window += [rect(54,y,212,80,'#FFF0CC'),rect(58,y+2,204,6,'#F6D47A'),rect(64,y+7,188,4,'#FFFBE9'),rect(54,y+80,212,9,'#8DA0AC'),rect(60,y+80,200,3,'#DDE4E1')]
add('b-display','B · 빈 진열창 5×3','World/Vending/Parts',W,H,window,'Fifteen item instances are separate from this background.')
payment=[rect(280,176,27,45,INK),rect(285,183,17,17,'#273F48'),rect(287,193,13,5,'#A7D16E'),rect(280,232,27,42,INK),rect(285,237,17,32,SILVER),rect(291,241,6,22,INK),rect(279,288,30,40,INK),rect(284,293,20,11,'#9DADBA'),rect(285,308,18,12,'#51667C'),rect(283,339,22,24,INK),rect(289,345,10,12,'#8996A1')]
add('b-payment','B · 결제부','World/Vending/Parts',W,H,payment)
add('b-hatch-closed','B · 배출구 닫힘','World/Vending/Parts',W,H,[rect(62,407,202,34,'#202A37'),rect(67,410,192,23,'#5D6A7A'),rect(67,410,192,5,'#A5B2BF'),rect(62,441,202,8,'#B6C5CC')])
add('b-hatch-open','B · 배출구 열림','World/Vending/Parts',W,H,[rect(62,407,202,34,'#111D2C'),rect(72,412,182,14,'#253346'),path('M 62 435 L 264 435 L 254 448 L 72 448 Z','#8B9DAF'),rect(72,435,182,4,'#D6E0DF')])
add('b-shadow','B · 고정 바닥 그림자','World/Vending/Parts',W,H,[ellipse(35,491,284,26,'#27373F')],'Keep fixed during body recoil.')
add('b-hit-flash','B · 타격 플래시','World/Vending/Parts',W,H,[rect(33,29,284,8,'#FFF2B7'),rect(33,37,8,440,'#FFF2B7'),rect(309,37,8,440,'#FFF2B7'),rect(33,477,284,10,'#FFF2B7')],'Short alpha flash. Recoil transform belongs to the engine.')
for key,n,c in [('button-idle','대기','#57768A'),('button-lit','점등','#F2D679'),('button-disabled','비활성','#626E74')]:
 add('select-'+key,'선택 버튼 · '+n,'World/Vending/Parts',30,12,[rect(0,0,30,12,INK),rect(3,3,24,6,c),rect(6,3,18,3,'#B3C6CE' if key!='button-lit' else '#FFF1C0')])
add('auto-marker','자동 생산 표식','World/Automation',64,40,[rect(2,2,60,36,INK),rect(6,6,52,28,'#658A85'),path('M 21 11 L 21 29 L 36 20 Z',LIGHT),rect(40,12,5,17,'#B5D6AD')])

# World machine families, each with a distinct front structure.
def family(key,name,c,kind):
 s=[rect(28,24,294,468,INK),rect(33,29,284,458,c),rect(43,38,264,28,'#F1D5A3'),rect(49,72,252,260,INK),rect(55,78,240,248,'#D8DCD0'),rect(48,491,50,17,INK),rect(254,491,50,17,INK)]
 if kind=='ramen':
  for yy in [93,169]:
   for xx in [69,145,221]:s += [rect(xx,yy,58,64,'#977E67'),rect(xx+5,yy+5,48,40,'#F0D48D'),rect(xx+10,yy+24,38,12,'#B96254'),rect(xx+12,yy+50,34,6,'#E9D8BD')]
  s += [rect(66,345,221,82,INK),rect(74,353,205,62,'#7E6B60'),rect(95,365,163,12,'#E5D1AE'),rect(128,383,96,18,'#D98763'),rect(64,445,225,15,'#F0D4A3')]
 elif kind=='magazine':
  for yy in [91,205]:
   for xx,col in [(69,'#CD7E6D'),(145,'#88AFC8'),(221,'#B6A7CF')]:s += [rect(xx,yy,58,97,'#526D80'),rect(xx+5,yy+5,48,84,col),rect(xx+12,yy+13,34,7,'#F3E2BD'),rect(xx+12,yy+28,34,38,'#E6D5B5')]
  s += [rect(59,365,232,58,INK),rect(66,372,218,26,'#6A7A86'),rect(66,399,218,13,'#AAB8BC'),rect(260,438,28,18,'#F0D5A0')]
 elif kind=='figure':
  for xx,cc in [(71,'#D994A8'),(148,'#A8BDCE'),(225,'#B8CE9A')]:s += [rect(xx,102,50,54,cc),rect(xx+10,95,30,7,LIGHT),rect(xx-5,156,60,12,'#5A6B7B')]
  s += [rect(76,205,82,75,'#6C6A87'),rect(91,220,52,45,'#D1B1CF'),rect(200,218,63,16,INK),rect(218,204,24,48,'#92AEC1'),rect(185,276,100,17,'#F0D5A0'),rect(97,358,156,73,INK),rect(110,369,130,39,'#40465E'),rect(110,409,130,11,'#A9B7C4')]
 else:
  for yy in [92,195]:
   for xx in [75,187]:s += [rect(xx,yy,88,84,'#9A7962'),rect(xx+8,yy+7,72,64,'#F0D7A2'),path(f'M {xx+15} {yy+20} L {xx+73} {yy+20} L {xx+44} {yy+61} Z','#D77E5B'),rect(xx+18,yy+72,52,6,INK)]
  s += [rect(59,353,232,78,INK),rect(66,360,218,20,'#774D42'),rect(75,366,200,5,'#F0B369'),rect(66,392,218,27,'#667180'),rect(74,397,202,6,'#CAD0CE')]
 s += [rect(282,82,14,34,'#A9C4BF'),rect(286,90,6,15,INK),rect(286,448,12,14,'#C3C1AB')]
 add(key,name,'World/Vending/Families',W,H,s,'Editable base appearance. Regional skins, exact product counts and balance are not fixed.')
family('machine-ramen','라멘 자판기','#C47B65','ramen')
family('machine-magazine','잡지 자판기','#6F93AD','magazine')
family('machine-figure','피규어 자판기','#9B8AB8','figure')
family('machine-pizza','피자 자판기','#C97460','pizza')

for opened in [False,True]:
 s=[rect(12,36,72,78,INK),rect(18,42,60,66,'#638982'),rect(24,48,9,54,'#8EAEA1'),rect(24,114,48,6,INK),rect(39,66,18,6,'#C9E1BB'),rect(45,60,6,30,'#C9E1BB')]
 s+=([path('M 9 30 L 72 12 L 87 24 L 18 42 Z',INK),path('M 18 28 L 69 18 L 78 24 L 24 36 Z','#98B4A5')] if opened else [rect(6,27,84,15,INK),rect(12,30,72,6,'#A1BAB1'),rect(36,18,24,9,INK)])
 add('trash-open' if opened else 'trash-closed','쓰레기통 · '+('열림' if opened else '닫힘'),'World/Automation',96,128,s)
for key,name,c in [('waiting','대기','#9AA7AF'),('working','가동','#98C9A6'),('ready','회수 가능','#F1D179')]:
 add('auto-'+key,'자동 생산 · '+name,'World/Automation',96,64,[rect(3,3,90,58,INK),rect(9,9,78,46,'#45616E'),rect(15,18,18,28,c),path('M 48 18 L 48 45 L 72 32 Z',c)])

# Effects are aligned, discrete frames; final timing stays editable in motion.json.
add('punch-cursor','주먹 커서','FX/Punch',96,96,[path('M 18 39 L 18 24 L 30 18 L 42 18 L 48 12 L 60 12 L 66 18 L 78 18 L 84 27 L 84 57 L 72 75 L 39 75 L 21 60 Z',INK),path('M 24 39 L 24 27 L 33 24 L 45 24 L 51 18 L 57 18 L 66 24 L 75 24 L 78 30 L 78 54 L 69 69 L 42 69 L 27 57 Z','#F1E7C8'),rect(36,30,6,21,'#C9B38E'),rect(51,27,6,21,'#C9B38E'),rect(66,30,6,18,'#C9B38E')],'Distinct from floor-search hand. Cursor hot spot: 46,48.')
for kind,col in [('search','#A8E3C4'),('punch','#F3D18B'),('reward','#F7D46E')]:
 for frame in range(3):
  spread=frame*6;cen=48
  points=[rect(cen-3,12-spread//2,6,15,col),rect(cen-3,69+spread//2,6,15,col),rect(12-spread//2,45,15,6,col),rect(69+spread//2,45,15,6,col)]
  points += [path(f'M {cen} {30+frame*3} L {66-frame*3} 48 L 48 {66-frame*3} L {30+frame*3} 48 Z',col)] if kind!='punch' else [path(f'M 48 {18+frame*3} L 57 36 L {81-frame*3} 39 L 63 54 L 66 75 L 48 63 L 27 78 L 30 57 L 12 42 L 36 36 Z',col),path('M 48 33 L 60 48 L 48 60 L 36 48 Z',LIGHT)]
  add(f'{kind}-fx-{frame:02}',f'{kind} · frame {frame+1}','FX/'+kind.title(),96,96,points,'Frame canvas 96×96, origin 48,48; timing and alpha are in motion.json.')
for frame in range(3):
 s=[rect(18,48-frame*9,15,9,'#A5E2CB'),rect(42,30-frame*6,12,9,'#D8F2D8'),rect(63,51-frame*12,12,9,'#A5E2CB')]
 add(f'pickup-fx-{frame:02}',f'자동 회수 · frame {frame+1}','FX/Pickup',96,96,s)
for frame in range(3):
 s=[rect(21+frame*6,15,6,12,'#EFD78B'),rect(69-frame*6,15,6,12,'#EFD78B'),rect(18+frame*6,69,6,12,'#EFD78B'),rect(72-frame*6,69,6,12,'#EFD78B')]
 add(f'expiry-fx-{frame:02}',f'소멸 임박 · frame {frame+1}','FX/Expiry',96,96,s,'Use with the actual item icon. No fixed expiration time in the image.')

# Semantic icons use a common 64px canvas, separate from editable values.
def icon(kind,c=GOLD):
 s=[]
 if kind in ['gold-flat','gold-percent','gold-double']:
  s=[rect(12,9,34,6,INK),rect(6,15,46,34,INK),rect(12,49,34,6,INK),rect(12,15,34,34,c),rect(17,20,6,24,'#FFF1B5')]
  s += [text(31,24,30,30,'+' if kind=='gold-flat' else '%' if kind=='gold-percent' else '×2',21,INK)]
 elif kind=='miss-down':s=[rect(12,12,36,36,INK),rect(18,18,24,24,'#B6CCE0'),rect(21,24,6,6,INK),rect(33,24,6,6,INK),path('M 37 36 L 43 42 L 49 36 L 49 48 L 43 55 L 37 48 Z',c)]
 elif kind in ['click-double','click-down']:
  s=[path('M 18 9 L 43 34 L 31 37 L 37 49 L 28 55 L 22 42 L 12 51 Z',INK),path('M 21 18 L 34 32 L 25 34 L 31 47 L 28 49 L 22 36 L 18 40 Z',LIGHT),text(37,10,30,30,'×2' if kind=='click-double' else '−',19,c)]
 elif kind in ['search-time','punch-time']:
  s=[rect(18,6,24,6,INK),rect(12,18,36,36,INK),rect(18,24,24,24,'#B4D8D1' if kind=='search-time' else '#D8B7A0'),rect(27,27,6,15,INK),rect(30,36,9,6,INK),text(43,36,21,25,'+',19,c)]
 elif kind=='fever-unlock':s=[rect(15,12,30,12,INK),rect(9,24,42,30,INK),rect(15,30,30,18,'#A7D8BB'),path('M 33 18 L 24 36 L 33 36 L 27 48 L 42 30 L 33 30 Z',LIGHT)]
 elif kind=='punch-activate':s=[path('M 12 24 L 18 12 L 45 12 L 54 21 L 54 39 L 42 51 L 24 51 L 12 39 Z',INK),rect(18,21,30,18,'#EBDDC1'),rect(24,39,18,6,'#EBDDC1')]
 return s
for key,name in [('gold-flat','고정 골드 증가'),('gold-percent','골드 비율 증가'),('gold-double','골드 2배 확률'),('miss-down','꽝 확률 감소'),('click-double','수색 클릭 2회 인정'),('search-time','일반 피버 시간'),('punch-time','펀치 피버 시간'),('click-down','필요 클릭 감소'),('fever-unlock','일반 피버 해금'),('punch-activate','펀치 피버 발동')]:add('effect-'+key,name,'UI/EffectIcons',64,64,icon(key),'Editable semantic mark. Effect value remains separate text.')
for state,name,c in [('locked','미해금','#788A94'),('available','사용 가능','#B5D5BC'),('active','활성','#F3D17E'),('ending','종료 임박','#DCA279')]:
 add('fever-'+state,'피버 · '+name,'UI/Fever',240,72,[rect(0,0,240,72,INK),rect(4,4,232,64,'#39545F'),rect(12,12,48,48,c),path('M 42 17 L 27 37 L 39 37 L 30 54 L 51 31 L 39 31 Z',INK),text(73,14,150,33,name,24,LIGHT),rect(75,51,145,8,'#213843'),rect(75,51,{'locked':0,'available':145,'active':105,'ending':25}[state],8,c)],'Illustrative bar fill only. Duration, activation and cap are not baked into art.')
for state,name,c in [('locked','잠김','#80909B'),('available','해금 가능','#C6DFB6'),('unlocked','해금됨','#8EC3AA'),('selected','선택됨','#F0D381'),('insufficient','재료 부족','#D9988B')]:
 s=[rect(6,6,52,52,INK),rect(12,12,40,40,c)]
 if state=='locked':s += [rect(22,18,20,8,INK),rect(18,28,28,20,INK),rect(28,34,8,8,c)]
 elif state in ('unlocked','selected'):s += [path('M 18 31 L 27 40 L 45 22 L 49 27 L 27 49 L 14 36 Z',INK)]
 elif state=='insufficient':s += [rect(28,18,8,21,INK),rect(28,43,8,6,INK)]
 else:s += [rect(28,18,8,28,INK),rect(18,28,28,8,INK)]
 add('unlock-'+state,'해금 · '+name,'UI/Unlock',64,64,s,'Region and machine use the same mark but different target label and material data.')
for state,name,c in [('idle','기본','#6C96AE'),('focus','포커스','#92C3C2'),('pressed','누름','#4C748B'),('disabled','비활성','#72818B')]:
 add('button-'+state,'공통 버튼 · '+name,'UI/Button',240,64,[rect(0,0,240,64,INK),rect(4,4,232,56,c),rect(8,8,224,4,'#C7D7D5' if state!='disabled' else '#909C9F'),rect(8,52,224,8,'#35566D'),text(35,17,170,31,'버튼',23,LIGHT)],'Text and size are editable; no game screen or permanent side panel.')
add('cap-badge','강화 한도 배지','UI/Proposals',96,40,[rect(0,0,96,40,INK),rect(4,4,88,32,'#576F75'),text(13,7,75,29,'MAX',22,'#D9D5AD')],'Post-cap payout is a source proposal. Badge is a reusable candidate, not a confirmed rule.',True)

# General progression icons remain separate from the excluded drink options.
add('skill-high-gold','상위 골드 확률','UI/ProgressionIcons',64,64,[rect(9,27,31,27,INK),rect(14,32,21,17,GOLD),path('M 39 24 L 48 12 L 60 24 L 53 24 L 53 45 L 43 45 L 43 24 Z','#B4DBBC')],'General progression icon; not an ability in the new 15-drink allocation.')
add('skill-quantity','생산·회수 수량','UI/ProgressionIcons',64,64,[rect(9,12,25,39,INK),rect(14,17,15,29,'#B3D0D1'),rect(30,21,25,39,INK),rect(35,26,15,29,'#D8CB9C')],'Editable quantity value remains external text.')
add('skill-pickup-chance','자동 회수 확률','UI/ProgressionIcons',64,64,[path('M 9 15 L 21 15 L 21 36 L 27 42 L 36 42 L 42 36 L 42 15 L 54 15 L 54 42 L 42 54 L 21 54 L 9 42 Z',INK),path('M 15 15 L 21 15 L 21 36 L 27 42 L 36 42 L 42 36 L 42 15 L 48 15 L 48 39 L 39 48 L 24 48 L 15 39 Z','#A9D4BC'),rect(12,12,12,9,'#E2CC8A'),rect(39,12,12,9,'#E2CC8A')],'Automatic material pickup does not grant purchase ability.')

# SVG mirrors for handoff; native Penpot shapes remain the editable source.
def svg(asset):
 out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{asset["width"]}" height="{asset["height"]}" viewBox="0 0 {asset["width"]} {asset["height"]}">']
 for s in asset['shapes']:
  if s[0]=='r':
   _,x,y,w,h,c=s
   if w>0 and h>0:out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}"/>')
  elif s[0]=='e':
   _,x,y,w,h,c=s;out.append(f'<ellipse cx="{x+w/2}" cy="{y+h/2}" rx="{w/2}" ry="{h/2}" fill="{c}"/>')
  elif s[0]=='p':out.append(f'<path d="{s[1]}" fill="{s[2]}"/>')
  else:
   _,x,y,w,h,t,size,c=s;out.append(f'<text x="{x}" y="{y+size}" font-family="Do Hyeon, sans-serif" font-size="{size}" fill="{c}">{html.escape(t)}</text>')
 out.append('</svg>');return ''.join(out)
assert len({a['key'] for a in A})==len(A)
for old in (ROOT/'svg').glob('*.svg'):old.unlink()
for a in A:(ROOT/'svg'/f'{a["key"]}.svg').write_text(svg(a))
(ROOT/'assets.json').write_text(json.dumps(A,ensure_ascii=False,indent=2)+'\n')
motion={'status':'asset animation specification; runtime implementation not included','values':'Suggested timings only. Source probabilities, fever duration and activation rules remain editable.','clips':{
 'search-fever-click':{'frames':['search-fx-00','search-fx-01','search-fx-02'],'suggested_ms_per_frame':[35,45,55],'anchor':[48,48],'trigger':'floor search during fever','engine':'scale and alpha fade'},
 'punch-hit':{'frames':['punch-fx-00','punch-fx-01','punch-fx-02'],'suggested_ms_per_frame':[30,40,60],'anchor':[48,48],'trigger':'machine body hit during punch fever','engine':'body recoil 3–5 px and return; keep shadow fixed; flash alpha'},
 'reward':{'frames':['reward-fx-00','reward-fx-01','reward-fx-02'],'suggested_ms_per_frame':[40,50,70],'engine':'editable gold popup; gold×2 and click×2 are different events'},
 'auto-pickup':{'frames':['pickup-fx-00','pickup-fx-01','pickup-fx-02'],'suggested_ms_per_frame':[45,50,65],'engine':'item travels toward bin or counter; no ability gain'},
 'expiry':{'frames':['expiry-fx-00','expiry-fx-01','expiry-fx-02'],'suggested_ms_per_frame':[100,100,100],'engine':'pulse and fade at runtime-configured expiry; no fixed lifetime in art'},
 'dispense':{'parts':['b-body','b-display','b-payment','b-hatch-closed','b-hatch-open'],'engine':'toggle hatch only; animate item downward; keep frame registration'},
 'fever-status':{'states':['fever-locked','fever-available','fever-active','fever-ending'],'engine':'timer and bar derive from runtime. Orange target and normal/special caps are unresolved.'}
}}
(ROOT/'motion.json').write_text(json.dumps(motion,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'assets':len(A),'drink_items':15,'svg_files':len(list((ROOT/'svg').glob('*.svg')))},ensure_ascii=False))
# Portable SVG assemblies mirror the nested Penpot components.
by={a['key']:a for a in A}
assemblies=[]
for variant in ['closed','open','auto']:
    layers=[('b-shadow',0,0,350,525),('b-body',0,0,350,525),('b-display',0,0,350,525)]
    drinks=[a['key'] for a in A if a['category']=='Items/Drinks']
    for i,key in enumerate(drinks):
        row,col=divmod(i,5)
        layers += [(key,58+42*col,100+90*row,27,40.5),('select-button-idle',57+42*col,155+90*row,27,10.8)]
    layers += [('b-payment',0,0,350,525),('b-hatch-open' if variant=='open' else 'b-hatch-closed',0,0,350,525)]
    if variant=='auto': layers += [('auto-marker',278,119,32,20)]
    out=['<svg xmlns="http://www.w3.org/2000/svg" width="350" height="525" viewBox="0 0 350 525">']
    for key,x,y,w,h in layers:
        content=(ROOT/'svg'/f'{key}.svg').read_text()
        body=content[content.index('>')+1:content.rindex('</svg>')]
        a=by[key]
        out.append(f'<g transform="translate({x} {y}) scale({w/a["width"]} {h/a["height"]})">{body}</g>')
    out.append('</svg>')
    (ROOT/'svg'/f'b-assembly-{variant}.svg').write_text(''.join(out))
    assemblies.append({'key':'b-assembly-'+variant,'width':350,'height':525,'layers':[{'asset':k,'x':x,'y':y,'width':w,'height':h} for k,x,y,w,h in layers]})
(ROOT/'assemblies.json').write_text(json.dumps(assemblies,ensure_ascii=False,indent=2)+'\n')
print('SVG total including assemblies:',len(list((ROOT/'svg').glob('*.svg'))))
