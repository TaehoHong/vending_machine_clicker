from pathlib import Path
import base64
from html import escape
HERE=Path(__file__).parent
ROOT=HERE.parents[2]
def uri(name):
    return 'data:image/png;base64,'+base64.b64encode((ROOT/name).read_bytes()).decode()
def r(x,y,w,h,c,stroke='none',opacity=1):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}" stroke="{stroke}" fill-opacity="{opacity}"/>'
def t(x,y,s,n=18,c='#f4eedf'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{n}" fill="{c}">{escape(s)}</text>'
base=f'<image width="1200" height="760" preserveAspectRatio="xMidYMid slice" href="{uri("images/alley_arcade_penpot.png")}"/>'
base+=r(0,0,1200,760,'#101b29',opacity=.35)
base+=f'<image x="408" y="135" width="384" height="576" href="{uri("images/vending_approved_15.png")}"/>'
base+=t(30,60,'음료와 능력',30)+t(823,53,'빈캔 18',20)
base+=r(938,24,126,42,'#112235','#8295a5')+t(949,51,'능력 요약')+r(1076,24,100,42,'#112235','#8295a5')+t(1087,51,'ESC 닫기')
detail=r(610.875,235.875,41.625,74.625,'none','#67ddea')
detail+=r(862,241,306,278,'#112235','#8295a5')+t(880,276,'이온음료',24)+t(1140,271,'×',18)+t(880,312,'미해금',16,'#9baebe')
detail+=t(880,351,'마실 때마다 발견 금액 +2 Gold',18)+t(880,433,'해금 후 자판기에서 등장',15,'#9baebe')
detail+=r(880,466,270,38,'#d6a147','#edc66c')+t(949,492,'5개로 추가',18,'#182234')
gallery=''
for i,(key,body) in enumerate([('initial',base),('locked-selected',base+detail)]):
    (HERE/f'{key}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{body}</svg>',encoding='utf-8')
    gallery+=f'<g transform="translate({i*1260},0)">{body}</g>'
(HERE/'editable-states.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="2460" height="760">{gallery}</svg>',encoding='utf-8')
print('Initial and click-selected native sources, without connecting lines')
