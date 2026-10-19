"""Build editable layout companions to the separate AI visual references."""
from pathlib import Path
import base64
import html

HERE = Path(__file__).parent
ROOT = HERE.parent.parent
DRINKS = [('water','물',3,'발견 골드 +1'),('green_tea','녹차',4,'발견 골드 +3'),('barley_tea','보리차',1,'발견 골드 +5'),('ion_drink','이온음료',2,'상위 골드 발견 확률 증가'),('apple_juice','사과 주스',1,'상위 골드 발견 확률 증가'),('ginger_ale','진저에일',1,'골드 2배 확률 증가')]
def rect(x,y,w,h,fill='#17354d',stroke='#527b9c'):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke}" stroke-width="3"/>'
def text(x,y,s,size=22,color='#fff2cf'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{size}" fill="{color}">{html.escape(s)}</text>'
def drink(i,x,y,w=52,h=76):
    raw=(ROOT/'images/drinks/approved'/f'{DRINKS[i][0]}.png').read_bytes()
    uri=base64.b64encode(raw).decode()
    return f'<image x="{x}" y="{y}" width="{w}" height="{h}" href="data:image/png;base64,{uri}"/>'
def panel(kind):
    out=rect(0,0,1120,700,'#0b1727','#080f19')
    out+=text(30,42,{'a':'A · 카드형 도감','b':'B · 목록 + 상세형','c':'C · 자판기 진열장형'}[kind],28)
    out+=text(30,74,'능력 목록 창 · 미채택 비교 시안 / 편집용 레이아웃',18,'#94afc5')
    out+=rect(30,100,1060,540)+text(58,140,'능력',30)+text(1036,140,'×',28)
    if kind=='a':
        for i,(_,name,count,rule) in enumerate(DRINKS):
            x=55+(i%3)*335;y=164+(i//3)*185
            out+=rect(x,y,315,165,'#e8e4d0','#5d91af')+drink(i,x+12,y+26)
            out+=text(x+79,y+39,name,23,'#23384b')+text(x+79,y+72,f'획득 {count}개',18,'#456477')
            out+=text(x+15,y+137,rule,18,'#23384b')
    elif kind=='b':
        for i,(_,name,count,rule) in enumerate(DRINKS):
            y=162+i*62
            out+=rect(55,y,420,56,'#316078' if i==3 else '#10283d')+drink(i,65,y+3,34,49)
            out+=text(114,y+34,name,21)+text(356,y+34,f'획득 {count}',18)
        out+=rect(500,162,560,364,'#10283d')+drink(3,525,190,120,184)
        out+=text(678,211,'이온음료',30)+text(678,251,'획득 2개 / 강화 예시',20)
        out+=text(528,414,'개당 효과 · 상위 골드 발견 확률 증가',21)
        out+=text(528,457,'현재 누적 효과 · 강화 2회 반영',21,'#ffe475')
        out+=text(528,495,'수치와 확률은 실제 게임 데이터 연동',17,'#94afc5')
    else:
        for row in range(2):
            y=163+row*184
            out+=rect(55,y,650,167,'#102333')+rect(55,y+145,650,16,'#54849b')
            for col in range(3):
                i=row*3+col; x=79+col*210
                out+=drink(i,x+52,y+6,56,82)+text(x+20,y+111,DRINKS[i][1],21)
                out+=text(x+31,y+137,f'획득 {DRINKS[i][2]}개',17,'#a9c6db')
        out+=rect(732,163,328,351,'#172f3b')+text(757,205,'현재 누적 능력',25,'#ffe475')
        for j,s in enumerate(['수색 9회','발견 보너스 +13 Gold','꽝 확률 15%','빈캔 12개']):
            out+=text(754,260+j*59,s,21)
    out+=rect(55,551,1005,58,'#10283d')+text(76,588,'현재 누적 능력   수색 9회  /  보너스 +13 Gold  /  꽝 15%',22)
    out+=text(30,678,'수치는 시안 예시 · 획득 개수는 누적 획득량 · 게임 미적용',19,'#94afc5')
    return out
gallery=''
for i,kind in enumerate('abc'):
    body=panel(kind)
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="700" viewBox="0 0 1120 700">{body}</svg>'
    (HERE/f'{kind}-layout.svg').write_text(svg,encoding='utf-8')
    gallery+=f'<g transform="translate({i*1180},0)">{body}</g>'
(HERE/'editable-gallery.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="3480" height="700" viewBox="0 0 3480 700">{gallery}</svg>',encoding='utf-8')
print('Created 3 editable layouts and gallery')
