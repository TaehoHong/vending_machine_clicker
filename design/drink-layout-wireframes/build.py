from pathlib import Path
from html import escape
from PIL import Image, ImageDraw, ImageFont

HERE=Path(__file__).parent
FONT=Path('C:/Windows/Fonts/malgun.ttf')
names=['물','녹차','보리차','이온음료','사과 주스','진저에일','레모네이드','라임 소다','복숭아 주스','오렌지 주스','비타민','멜론 소다','황금 음료수','콜라','에너지']
costs=[0,0,8,5,8,10,10,12,12,15,15,20,30,20,25]
class Canvas:
    def __init__(self):
        self.svg=[]; self.im=Image.new('RGB',(1200,760),'#ffffff');self.d=ImageDraw.Draw(self.im)
    def box(self,x,y,w,h,fill='#ffffff',stroke='#686868',lw=2):
        self.svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke}" stroke-width="{lw}"/>')
        self.d.rectangle((x,y,x+w,y+h),fill=fill,outline=stroke,width=lw)
    def txt(self,x,y,s,size=20,color='#252525'):
        self.svg.append(f'<text x="{x}" y="{y+size}" font-family="Malgun Gothic,sans-serif" font-size="{size}" fill="{color}">{escape(s)}</text>')
        self.d.text((x,y),s,font=ImageFont.truetype(str(FONT),size),fill=color)
    def line(self,x,y,x2,y2,color='#777777',lw=2):
        self.svg.append(f'<line x1="{x}" y1="{y}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="{lw}"/>')
        self.d.line((x,y,x2,y2),fill=color,width=lw)
    def save(self,key):
        body=''.join(self.svg)
        (HERE/f'{key}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{body}</svg>',encoding='utf-8')
        self.im.save(HERE/f'{key}.png')
        return body

def info(c,x,y,w,h,locked=False):
    c.box(x,y,w,h,'#fafafa','#333333',2)
    c.txt(x+15,y+12,'이온음료' if locked else '물',22)
    c.txt(x+w-30,y+12,'×',20)
    c.txt(x+15,y+47,'미해금' if locked else '획득 3개 · 강화 3 / 10',15,'#666666')
    c.line(x+15,y+78,x+w-15,y+78,'#cccccc',1)
    if locked:
        c.txt(x+15,y+90,'상위 골드 발견 확률 증가',16)
        c.txt(x+15,y+117,'해금하면 뽑기 목록에 추가',14,'#666666')
        c.box(x+15,y+151,w-30,36,'#e4e4e4','#555555',1)
        c.txt(x+35,y+157,'빈캔 5개로 음료 추가',16)
    else:
        c.txt(x+15,y+90,'개당 효과       골드 +1',16)
        c.txt(x+15,y+121,'누적 효과       골드 +3',16)

def machine(c,x,y,w,h,selected,show_costs=True):
    c.box(x,y,w,h,'#eeeeee','#454545',3)
    c.box(x+20,y+18,w-40,30,'#fafafa','#999999',1)
    c.txt(x+35,y+21,'음료 선택',18)
    top=y+65; rows_h=(h-160)/3; cell_w=(w-50)/5
    points=[]
    for i,name in enumerate(names):
        xx=x+15+(i%5)*cell_w; yy=top+(i//5)*rows_h
        c.box(xx,yy,cell_w-3,rows_h-8,'#ffffff','#bbbbbb',1)
        # Simple bottle placeholder, intentionally no finished art.
        bx=xx+cell_w/2-11;by=yy+12
        c.box(bx+5,by,12,7,'#ffffff','#888888',1)
        c.box(bx,by+7,22,37,'#eeeeee','#888888',1)
        c.txt(xx+5,yy+57,name,12)
        locked=i>=2
        if locked and show_costs:
            c.box(xx+cell_w-41,yy+79,35,20,'#e7e7e7','#999999',1)
            c.txt(xx+cell_w-37,yy+80,f'캔{costs[i]}',11)
        if i==selected:
            c.box(xx-2,yy-2,cell_w+1,rows_h-4,'#ffffff','#202020',3)
            c.box(bx+5,by,12,7,'#ffffff','#444444',1)
            c.box(bx,by+7,22,37,'#dddddd','#444444',1)
            c.txt(xx+5,yy+57,name,12)
            if locked and show_costs:
                c.box(xx+cell_w-41,yy+79,35,20,'#dddddd','#555555',1)
                c.txt(xx+cell_w-37,yy+80,f'캔{costs[i]}',11)
        points.append((xx+cell_w/2,yy+rows_h/2))
    c.box(x+40,y+h-74,w-80,44,'#d4d4d4','#777777',2)
    c.txt(x+w/2-24,y+h-65,'배출구',14,'#666666')
    return points

gallery=''
for k,key in enumerate(['a-right-card','b-left-card','c-below-card']):
    c=Canvas()
    title=['A · 선택 음료 오른쪽 카드','B · 선택 음료 왼쪽 카드','C · 자판기 아래 선택 카드'][k]
    c.txt(25,18,title,27)
    c.txt(25,59,'배치 검토용 · 흑백 도형만 사용 · 수치와 비용은 예시',15,'#777777')
    c.box(20,96,1160,615,'#f8f8f8','#c5c5c5',1)
    c.txt(42,111,'음료와 능력',22)
    c.txt(815,115,'빈캔 18',17)
    c.box(923,107,139,36,'#ffffff','#888888',1);c.txt(939,112,'능력 요약 ▾',17)
    c.txt(1104,114,'닫기 ×',16)
    if k==0:
        pts=machine(c,365,160,470,520,3,show_costs=False)
        info(c,862,241,286,218,True)
        c.line(pts[3][0],pts[3][1],848,pts[3][1],'#333333',2)
        c.line(848,pts[3][1],862,270,'#333333',2)
        c.txt(46,222,'음료를 누르면',18);c.txt(46,251,'가까이에 정보 카드',18)
        c.txt(46,294,'음료 아래에는 이름만',16,'#666666');c.txt(46,320,'캔 비용은 선택 카드에서',16,'#666666')
        c.txt(25,729,'오른쪽 공간을 활용 · 자판기를 가리지 않음 · 추천',17)
    elif k==1:
        pts=machine(c,365,160,470,520,0)
        info(c,48,240,286,182,False)
        c.line(334,270,pts[0][0]-25,pts[0][1],'#333333',2)
        c.txt(876,248,'선택한 음료가',18);c.txt(876,277,'왼쪽이면 카드도 왼쪽',18)
        c.txt(876,320,'해금한 음료는',16,'#666666');c.txt(876,346,'획득량과 효과만 표시',16,'#666666')
        c.txt(25,729,'선택 위치에 따라 좌우 전환 · 화면 가장자리에서는 안쪽으로 이동',17)
    else:
        pts=machine(c,390,153,420,352,0)
        c.line(pts[0][0],pts[0][1],350,pts[0][1],'#333333',2)
        c.line(350,pts[0][1],350,541,'#333333',2);c.line(350,541,390,541,'#333333',2)
        c.box(390,522,420,164,'#fafafa','#333333',2)
        c.txt(407,535,'물 · 획득 3개',20);c.txt(771,534,'×',19)
        c.txt(407,572,'개당 골드 +1     누적 골드 +3',17)
        c.txt(407,611,'미해금 선택 시 → 효과·캔 비용·추가 버튼',15,'#666666')
        c.txt(45,252,'선택 전에는',18);c.txt(45,281,'아래 카드가 숨겨짐',18)
        c.txt(874,265,'전체 누적 능력은',18);c.txt(874,294,'상단 버튼으로 펼침',18)
        c.txt(25,729,'카드 위치가 일정해 읽기 편함 · 카드 공간만큼 자판기는 작아짐',17)
    body=c.save(key)
    gallery+=f'<g transform="translate({k*1260},0)">{body}</g>'
(HERE/'editable-gallery.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="3720" height="760">{gallery}</svg>',encoding='utf-8')
print('Created 3 editable wireframes + PNG previews')
