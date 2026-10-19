from pathlib import Path
from html import escape
import base64
HERE=Path(__file__).parent
ROOT=HERE.parent.parent
def png(path):
    return 'data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode()
bg=png(ROOT/'images/alley_arcade_penpot.png')
machine=png(ROOT/'images/vending_approved_15.png')
def r(x,y,w,h,c,stroke='none',opacity=1):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}" stroke="{stroke}" fill-opacity="{opacity}"/>'
def t(x,y,s,size=20,color='#f6efd6'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{size}" fill="{color}">{escape(s)}</text>'
gallery=''
for i,(key,tint,op,card,border) in enumerate([
    ('a-daylight','#101b29',0.35,'#112235','#8d9da7'),
    ('b-dusk','#574537',0.32,'#202b3d','#a8a8a0'),
    ('c-night','#08182d',0.63,'#071c2a','#66cede')]):
    body=f'<image width="1200" height="760" preserveAspectRatio="xMidYMid slice" href="{bg}"/>'
    body+=r(0,0,1200,760,tint,opacity=op)
    body+=f'<image x="408" y="135" width="384" height="576" preserveAspectRatio="xMidYMid meet" href="{machine}"/>'
    body+=t(35,58,'음료와 능력',28)+t(818,52,'빈캔 18',18)
    body+=r(920,24,133,40,card,border)+t(935,51,'능력 요약',18)+r(1072,24,98,40,card,border)+t(1084,51,'ESC 닫기',16)
    body+=r(621,232,30,62,'none','#61dce9')
    if i != 0:  # Historical alternatives; adopted daylight has no connection.
        body+='<path d="M 651 273 L 831 286 L 862 267" fill="none" stroke="#61dce9" stroke-width="1.5"/>'
    body+=r(862,241,286,218,card,border)+t(879,273,'이온음료',22)+t(879,301,'미해금',14,'#97a8b7')
    body+='<path d="M879 318 H1131" stroke="#596b7c"/>'
    body+=t(879,345,'상위 골드 발견 확률 증가',16)+t(879,371,'해금 후 자판기에서 등장',14,'#97a8b7')
    body+=r(879,402,252,38,'#d6a147','#edc66c')+t(931,427,'빈캔 5개로 추가',18,'#202736')
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{body}</svg>'
    (HERE/f'{key}.svg').write_text(svg,encoding='utf-8')
    gallery+=f'<g transform="translate({i*1260},0)">{body}</g>'
(HERE/'editable-gallery.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="3720" height="760">{gallery}</svg>',encoding='utf-8')
print('Created original-asset layout and palette sources')
