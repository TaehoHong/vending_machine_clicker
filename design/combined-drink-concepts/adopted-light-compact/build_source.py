from pathlib import Path
from html import escape
HERE=Path(__file__).parent
def r(x,y,w,h,c,s='#5284a3'):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}" stroke="{s}" stroke-width="3"/>'
def t(x,y,s,n=20,c='#f8efd0'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{n}" fill="{c}">{escape(s)}</text>'
names=['물','녹차','보리차','이온음료','사과 주스','진저에일','레모네이드','라임 소다','복숭아 주스','오렌지 주스','비타민','멜론 소다','황금 음료수','콜라','에너지']
costs=[0,0,8,5,8,10,10,12,12,15,15,20,30,20,25]
colors=['#77cce5','#a3c56b','#d2a052','#72c8e8','#c59a81','#87ba79','#e0cc66','#5dad78','#e09fba','#d7a454','#cb9359','#91c77f','#edc866','#ce605d','#6b717b']
def can(x,y):
    return r(x,y,8,13,'#afc4cf','#334d5c')+r(x,y-2,8,3,'#dbe5e9','#334d5c')
s=r(0,0,1200,760,'#0c1c2c')+t(30,40,'음료와 능력 · 밝은 카드형 · 축소 수정',29)+t(30,73,'선택된 디자인 방향 / 게임 미적용 / 비용·수치는 임시 예시',18,'#a0bdce')
s+=r(46,110,565,515,'#b9323c')
for i,name in enumerate(names):
    x=65+i%5*107;y=130+i//5*150
    s+=r(x,y,96,142,'#e9e5cb')+r(x+33,y+15,30,62,colors[i],'#1b2a39')+r(x+39,y+8,18,9,'#e9edf1','#1b2a39')
    s+=r(x,y+87,96,55,'#153147')+t(x+5,y+107,name,14)
    s+=(t(x+28,y+132,'기본',16) if costs[i]==0 else can(x+28,y+117)+t(x+44,y+131,str(costs[i]),17))
s+=r(65,590,525,24,'#142838')
# Earlier right panel footprint: 510 x 460 = 234600. Current: 350 x 220 = 77000 (~33%).
s+=r(755,291,350,220,'#f0e9d1')+r(765,301,330,34,'#17394f')+can(782,312)+t(800,324,'보유 빈캔 18',19)
s+=t(770,362,'물 · 획득 3개 · 해금 완료',20,'#1b3549')
s+=r(768,376,155,59,'#fff6dd')+t(777,397,'1개당 효과',15,'#1b3549')+t(777,422,'+1 Gold',23,'#1883ab')
s+=r(936,376,155,59,'#fff6dd')+t(946,397,'현재 누적',15,'#1b3549')+t(946,422,'+3 Gold',23,'#1883ab')
s+=r(765,447,330,52,'#17394f')+t(774,468,'다음 해금 · 이온음료',16)+r(947,456,139,32,'#dfae4c')+t(956,478,'빈캔 5개로 추가',16,'#1b3549')
s+=r(30,650,1140,67,'#17394f')+t(50,691,'현재 누적 능력  |  발견 골드 +3  |  실제 적용 시 게임 데이터 연결',22)
s+=t(30,745,'도형·문구 편집용 구조 원본 / 음료 자리표시 도형 / 완성 아트는 preview.png 참고',17,'#a0bdce')
(HERE/'layout.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{s}</svg>',encoding='utf-8')
print('Updated compact layout: right panel 33% area')
