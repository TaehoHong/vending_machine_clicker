from pathlib import Path
from html import escape
HERE=Path(__file__).parent
def r(x,y,w,h,c,s='#497899',sw=3):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}" stroke="{s}" stroke-width="{sw}"/>'
def t(x,y,s,n=20,c='#f8efd0'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{n}" fill="{c}">{escape(s)}</text>'
names=['물','녹차','보리차','이온음료','사과주스','진저에일','레모네이드','라임소다','복숭아주스','오렌지주스','비타민','멜론소다','황금음료','콜라','에너지']
costs=[0,0,8,5,8,10,10,12,12,15,15,20,30,20,25]
colors=['#77cce5','#a3c56b','#d2a052','#72c8e8','#c59a81','#87ba79','#e0cc66','#5dad78','#e09fba','#d7a454','#cb9359','#91c77f','#edc866','#ce605d','#6b717b']
def can(x,y,w=9,h=15):
    return r(x,y,w,h,'#aec3d0','#304a5b',1)+r(x,y-2,w,3,'#e1ebf0','#304a5b',1)
s=r(0,0,1672,940,'#0b1b2b')+t(60,70,'음료와 능력',44)+t(60,108,'최신 수정 · 이름 오른쪽 캔 비용 · 하단 요약 / 다음 해금 제거',22,'#abc4d2')+t(1510,66,'ESC ×',24)
# Equal-size outer panels; identical top/bottom edges.
s+=r(60,150,750,750,'#bd343d','#152b3b',6)+r(860,150,750,750,'#f0e9cf','#497899',6)
for i,name in enumerate(names):
    x=90+i%5*129;y=190+i//5*185
    s+=r(x,y,124,175,'#e9e5cb')+r(x+39,y+22,42,94,colors[i],'#182c3d')+r(x+47,y+13,26,11,'#e2ecf1','#182c3d')
    s+=r(x,y+132,124,43,'#16364d')+t(x+5,y+158,name,12)
    s+=(t(x+87,y+158,'기본',12) if costs[i]==0 else can(x+91,y+143)+t(x+103,y+158,str(costs[i]),12))
s+=r(108,786,589,81,'#101e2e','#6c7a8c',7)+r(133,807,539,30,'#0c1423')
s+=r(882,172,706,64,'#15354b')+can(905,194,14,23)+t(932,215,'보유 빈캔 18',23)
s+=r(890,258,686,160,'#fff8e3','#e0d5b4',2)
s+=r(914,282,39,65,colors[0],'#19364a',2)+r(923,272,21,10,'#dcecf4','#19364a',2)
s+=t(981,291,'물',24,'#17364b')+t(1032,290,'획득 3개',18,'#17364b')+r(1133,270,90,25,'#168bc0')+t(1141,288,'해금 완료',14)
s+=r(980,313,140,65,'#fff7db','#dbd1b6',1)+r(1120,313,140,65,'#fff7db','#dbd1b6',1)
s+=t(991,336,'1개당 효과',14,'#17364b')+t(991,364,'+1 Gold',20,'#1686b4')+t(1131,336,'현재 누적',14,'#17364b')+t(1131,364,'+3 Gold',20,'#1686b4')
s+=t(1356,874,'비용·수치는 임시 예시',17,'#657478')
(HERE/'layout.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1672" height="940">{s}</svg>',encoding='utf-8')
print('Updated equal panels / one-line costs / compact contents')
