from pathlib import Path
from base64 import b64encode
from html import escape
import json

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'design'/'penpot-ui'
C={'bg':'#0B1118','panel':'#111C27','edge':'#31404D','text':'#F6F0E4','muted':'#A6B3BF','gold':'#F2BD62','blue':'#77CEE5','green':'#B4D581'}

def rect(x,y,w,h,fill,rx=0,stroke=None,opacity=1):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" opacity="{opacity}"'+(f' stroke="{stroke}"' if stroke else '')+'/>'
def txt(x,y,t,size=16,color=None,weight=400,anchor='start',spacing=0):
    return f'<text x="{x}" y="{y}" fill="{color or C["text"]}" font-family="Malgun Gothic, Arial, sans-serif" font-size="{size}" font-weight="{weight}" text-anchor="{anchor}" letter-spacing="{spacing}">{escape(t)}</text>'
def line(x,y,x2,y2,color=None):
    return f'<path d="M{x} {y}H{x2}" stroke="{color or C["edge"]}"/>' if y==y2 else f'<path d="M{x} {y}L{x2} {y2}" stroke="{color or C["edge"]}"/>'
def panel(x,y,w,h):return rect(x,y,w,h,C['panel'],16,C['edge'],.96)
def button(x,y,w,h,label,primary=False):
    return rect(x,y,w,h,C['gold'] if primary else '#182633',10,None if primary else C['edge'])+txt(x+w/2,y+h/2+6,label,18,C['bg'] if primary else C['text'],700,'middle')
def background(menu=False):
    f=ROOT/'images'/('ef7fdf44-d785-487d-be87-8d480ea063ca.png' if menu else '2847210d-a3b0-4e7a-964a-049414535f65.png')
    data=b64encode(f.read_bytes()).decode()
    return f'<image width="1152" height="648" href="data:image/png;base64,{data}" preserveAspectRatio="xMidYMid slice"/>'
def header():
    return txt(32,40,'BACKSTREET / CLICKER',13,C['gold'],700,spacing=2)+txt(1120,40,'ESC  메뉴',13,C['muted'],600,'end')
def droplet(x,y,color):
    return f'<path d="M{x} {y-9} C{x-4} {y-2} {x-8} {y+1} {x-8} {y+5} A8 8 0 0 0 {x+8} {y+5} C{x+8} {y+1} {x+4} {y-2} {x} {y-9}Z" fill="{color}"/>'
def gameplay():
    s=background()+rect(0,0,1152,648,'url(#shade)')+header()
    s+=panel(28,64,246,94)+txt(48,92,'보유 금액',13,C['muted'])+txt(48,132,'¥ 1,250',32,C['text'],700)+txt(252,130,'JPY',11,C['gold'],600,'end')
    s+=panel(28,172,246,158)+txt(48,202,'수집 현황',14,C['muted'],600)+droplet(58,227,C['blue'])+txt(78,236,'물',16)+txt(252,236,'03',18,C['blue'],700,'end')
    s+=line(48,250,254,250)+droplet(58,269,C['green'])+txt(78,278,'녹차',16)+txt(252,278,'02',18,C['green'],700,'end')+txt(48,310,'빈캔 5개  ·  발견 보너스 +¥3',12,C['muted'])
    s+=panel(862,64,262,154)+rect(862,83,3,32,C['gold'],1)+txt(882,94,'첫 수집 목표',17,C['text'],700)+txt(882,122,'동전 10번 발견하기',14,C['muted'])+rect(882,139,220,5,'#293744',2)+rect(882,139,132,5,C['gold'],2)+txt(882,174,'6 / 10',13,C['gold'],600)+txt(1104,174,'보상 ¥100',13,C['muted'],400,'end')
    s+=rect(640,289,36,74,'#F2BD62',8,C['gold'],.18)+f'<circle cx="658" cy="344" r="23" fill="none" stroke="{C["gold"]}" stroke-width="1.5"/>'
    s+=panel(699,302,190,62)+txt(715,328,'100엔 투입',16,C['gold'],700)+txt(715,349,'물 / 녹차 랜덤 획득',12,C['muted'])+line(681,333,699,333,C['gold'])
    s+=panel(351,536,450,88)+txt(576,563,'자판기 밑을 클릭해 동전 찾기',16,C['text'],700,'middle')+rect(379,578,394,5,'#2B3B48',3)+rect(379,578,175,5,C['gold'],3)+txt(379,607,'수색 중 4 / 9',12,C['gold'])+txt(773,607,'발견 보너스 +¥3',12,C['muted'],400,'end')
    return s

def main():
    s=background(True)+rect(0,0,1152,648,'url(#menuShade)')+txt(64,66,'夜の路地 / BACKSTREET',12,C['gold'],700,spacing=2)
    s+=rect(64,113,46,4,C['gold'],2)+txt(64,182,'BACKSTREET',48,C['text'],700,spacing=1)+txt(64,236,'CLICKER',48,C['text'],700,spacing=1)
    s+=txt(66,280,'골목의 작은 동전으로, 나만의 자판기를.',17,C['muted'])
    s+=button(64,326,320,54,'New Game   →',True)+button(64,392,320,54,'Load Game')
    s+=txt(64,478,'마지막 저장  ·  ¥1,250  /  음료 5개',12,C['muted'])+line(64,507,384,507)
    s+=txt(64,542,'Settings',15,C['text'],600)+txt(384,542,'Exit',15,C['muted'],600,'end')
    s+=txt(64,606,'拾う。飲む。育てる。',12,C['muted'],400,spacing=2)+txt(1116,608,'PC UI  /  01',11,C['muted'],400,'end')
    return s

def reward(tea=False):
    name='녹차' if tea else '물'; accent=C['green'] if tea else C['blue']
    s=gameplay()+rect(0,0,1152,648,C['bg'],opacity=.84)+panel(336,40,480,568)
    s+=txt(576,78,'VENDING MACHINE / 100 JPY',11,C['gold'],700,'middle',2)+txt(576,119,f'{name} 획득!',30,C['text'],700,'middle')
    s+=f'<circle cx="576" cy="275" r="119" fill="{accent}" opacity=".07"/><circle cx="576" cy="275" r="103" fill="none" stroke="{accent}" opacity=".15"/>'
    art=(ROOT/'images'/'drinks'/('green_tea.svg' if tea else 'water.svg')).read_text()
    prefix='tea' if tea else 'water'
    art=art.replace('id="body"',f'id="{prefix}_body"').replace('id="metal"',f'id="{prefix}_metal"').replace('url(#body)',f'url(#{prefix}_body)').replace('url(#metal)',f'url(#{prefix}_metal)')
    art=art.replace('<svg xmlns="http://www.w3.org/2000/svg" width="320" height="400" viewBox="0 0 320 400">', '<g transform="translate(464,143) scale(0.7)">').replace('</svg>', '</g>')
    s+=art+line(368,432,784,432)
    s+=txt(576,464,'동전 발견 금액 +¥1' if tea else '수색 숙련도 +1',21,accent,700,'middle')
    s+=txt(576,493,'동전을 찾을 때마다 1엔을 더 얻습니다.' if tea else '물 3개마다 수색에 필요한 클릭이 1회 줄어듭니다.',13,C['muted'],400,'middle')
    s+=txt(576,517,'빈캔 +1  ·  획득 즉시 능력치에 적용',12,C['muted'],400,'middle')+button(368,540,416,46,'닫기',True)
    return s

def pause():
    s=gameplay()+rect(0,0,1152,648,C['bg'],opacity=.84)+panel(376,106,400,436)
    s+=txt(576,150,'PAUSED',11,C['gold'],700,'middle',3)+txt(576,192,'잠시 쉬어가세요',27,C['text'],700,'middle')+txt(576,220,'골목은 그대로 기다리고 있어요.',13,C['muted'],400,'middle')
    s+=button(408,250,336,54,'계속',True)+button(408,318,336,54,'저장')+button(408,386,336,54,'끝내기')
    s+=txt(576,477,'끝내기를 누르면 저장 후 종료합니다.',12,C['muted'],400,'middle')+txt(576,510,'ESC  게임으로 돌아가기',12,C['gold'],400,'middle')
    return s

DEFS='''<defs><linearGradient id="shade" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#070D14" stop-opacity=".2"/><stop offset=".7" stop-color="#070D14" stop-opacity="0"/><stop offset="1" stop-color="#070D14" stop-opacity=".65"/></linearGradient><linearGradient id="menuShade"><stop stop-color="#080F18" stop-opacity=".97"/><stop offset=".52" stop-color="#080F18" stop-opacity=".7"/><stop offset="1" stop-color="#080F18" stop-opacity=".12"/></linearGradient></defs>'''
for filename,contents in [('01-main-menu',main()),('02-gameplay',gameplay()),('03-water-result',reward()),('04-green-tea-result',reward(True)),('05-pause-menu',pause())]:
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1152" height="648" viewBox="0 0 1152 648"><title>Backstreet Clicker — {filename}</title>{DEFS}{contents}</svg>'
    (OUT/f'{filename}.svg').write_text(svg,encoding='utf-8')
(OUT/'tokens.json').write_text(json.dumps({'colors':C,'viewport':{'width':1152,'height':648},'spacing':[4,8,12,16,24,32,48,64],'radii':{'button':10,'panel':16},'font':'Malgun Gothic','type':{'display':48,'title':30,'heading':21,'body':16,'caption':12}},indent=2),encoding='utf-8')
print('Created five editable SVG screens and design tokens.')
