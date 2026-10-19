from pathlib import Path
from html import escape
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).parent
ROOT = HERE.parents[1]
FONT = ROOT / 'ui/fonts/DoHyeon-Regular.ttf'
W, H = 1200, 860
BLUE, INK = '#4b98d0', '#243444'
gallery = []

for i, (name, scale, note) in enumerate([
    ('A', 1.05, '현재 느낌 유지'),
    ('B', 1.10, '추천 / 가독성과 여백 균형'),
    ('C', 1.15, '음료 선택 영역 최대화'),
]):
    im = Image.new('RGB', (W, H), '#f5f6f8')
    d = ImageDraw.Draw(im)
    svg = []
    def rect(x, y, w, h, fill, stroke=None, sw=1):
        d.rectangle((round(x), round(y), round(x+w), round(y+h)), fill=fill, outline=stroke, width=sw)
        svg.append(f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" fill="{fill or "none"}" stroke="{stroke or "none"}" stroke-width="{sw}"/>')
    def text(x,y,s,size=20,color=INK):
        d.text((round(x),round(y)),s,font=ImageFont.truetype(str(FONT),size),fill=color)
        svg.append(f'<text x="{x:g}" y="{y+size:g}" font-family="Do Hyeon, sans-serif" font-size="{size}" fill="{color}">{escape(s)}</text>')
    def line(x1,y1,x2,y2,color=INK,sw=1):
        d.line((x1,y1,x2,y2),fill=color,width=sw)
        svg.append(f'<line x1="{x1:g}" y1="{y1:g}" x2="{x2:g}" y2="{y2:g}" stroke="{color}" stroke-width="{sw}"/>')
    def box(x,y,w,h,label,fs=20):
        rect(x,y,w,h,'#d8eaf6',BLUE,2)
        text(x+14,y+(h-fs)/2-2,label,fs)
    mw,mh=384*scale,576*scale
    mx,my=600-mw/2,100+711-mh
    gap=862-(mx+mw)
    text(28,14,f'{name}   +{round((scale-1)*100)}%',32)
    text(240,22,f'{mw:.1f} × {mh:.1f}  /  {note}',24)
    text(28,62,'배치 검토용 / 2:3 비율 유지 / 바닥선 고정 / HUD / 정보창 위치 동일',18,'#617181')
    rect(0,100,1200,760,'#e9edf1','#b8c4ce')
    text(30,128,'음료와 능력',30)
    box(30,186,210,64,'빈캔 18',22)
    box(900,124,150,60,'능력 요약')
    box(1062,124,114,60,'ESC 닫기',18)
    # Current footprint is dashed; candidate grows upward around the same center and floor.
    for xx in range(408,792,14):
        line(xx,235,min(xx+7,792),235,'#9aa7b3',2)
        line(xx,811,min(xx+7,792),811,'#9aa7b3',2)
    for yy in range(235,811,14):
        line(408,yy,408,min(yy+7,811),'#9aa7b3',2)
        line(792,yy,792,min(yy+7,811),'#9aa7b3',2)
    rect(mx,my,mw,mh,'#eadcdd','#ae555c',3)
    rect(mx+mw*.07,my+mh*.035,mw*.86,mh*.075,'#fbf8f1','#ae555c',2)
    text(mx+mw*.29,my+mh*.047,'자판기',22)
    gx,gy,gw,gh=mx+mw*.09,my+mh*.135,mw*.72,mh*.53
    rect(gx,gy,gw,gh,'#f9fbfc','#8ba3b4',2)
    for row in range(3):
        for col in range(5):
            cw,ch=gw*.105,gh*.21
            cx,cy=gx+gw*(.06+col*.19),gy+gh*(.07+row*.31)
            rect(cx,cy,cw,ch,'#c9dce8','#607c91',1)
            line(cx+2,cy+ch*.22,cx+cw-2,cy+ch*.22,'#607c91')
    rect(mx+mw*.84,my+mh*.43,mw*.07,mh*.13,'#c9d0d6','#607c91',2)
    rect(mx+mw*.10,my+mh*.78,mw*.75,mh*.13,'#667888','#425669',2)
    text(mx+mw*.25,my+mh*.82,'배출구',20,'#ffffff')
    line(mx,811,mx+mw,811,'#ae555c',4)
    box(862,341,306,278,'',18)
    text(882,361,'선택 음료 정보',24)
    text(882,411,'능력 / 획득량 / 해금 조건',18)
    text(882,454,'음료 클릭 시에만 표시',18,'#617181')
    box(882,554,266,44,'추가 / 강화 정보',18)
    # Horizontal gap dimension, where the cabinet is beside the card.
    yy=664
    line(mx+mw,yy,862,yy,'#436b88',2)
    line(mx+mw,yy-6,mx+mw,yy+6,'#436b88',2)
    line(862,yy-6,862,yy+6,'#436b88',2)
    text(862,683,f'자판기 ↔ 정보창  {gap:.1f}px',18,'#436b88')
    text(28,792,'기준 화면 1200 × 760',18,'#617181')
    text(28,820,'게임 미적용 / 크기 비교 시안',18,'#617181')
    body=''.join(svg)
    (HERE/f'{name.lower()}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="860">{body}</svg>',encoding='utf-8')
    im.save(HERE/f'{name.lower()}.png')
    gallery.append(f'<g transform="translate({i*1260},0)">{body}</g>')
(HERE/'editable-gallery.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="3720" height="860">{"".join(gallery)}</svg>',encoding='utf-8')
sheet=Image.new('RGB',(1200,3*860+40),'#cbd3dc')
for i in range(3):
    sheet.paste(Image.open(HERE/f'{"abc"[i]}.png'),(0,i*880))
sheet.save(HERE/'comparison.png')
print('3 editable layout variants and PNG previews created')

