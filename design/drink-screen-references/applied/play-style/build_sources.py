from pathlib import Path
from html import escape
HERE=Path(__file__).parent
source=(HERE.parent/'initial.svg').read_text(encoding='utf-8')
base=source[source.index('>')+1:source.index('<text x="30"')]
def rect(x,y,w,h,color,stroke='none',sw=0):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{color}" stroke="{stroke}" stroke-width="{sw}"/>'
def frame(x,y,w,h):
    return rect(x+5,y+7,w-5,h-7,'#12121d')+rect(x,y,w-5,h-7,'#4b98d0','#12121d',6)+rect(x+5,y+5,w-15,6,'#a8dbec')+rect(x+5,y+h-17,w-15,5,'#28567f')
def text(x,y,s,n=18,c='#ffffff'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{n}" fill="{c}" stroke="#12121d" stroke-width="0.7" paint-order="stroke">{escape(s)}</text>'
header=text(30,60,'음료와 능력',30)+frame(30,86,210,64)+text(85,123,'빈캔 18',22)
header+=rect(50,103,20,28,'#aac1cc','#405d70',2)+rect(50,101,20,4,'#dce7eb')
header+=frame(900,24,150,60)+text(925,58,'능력 요약')+frame(1062,24,114,60)+text(1078,58,'ESC 닫기')
detail=rect(610.875,235.875,41.625,74.625,'none','#67ddea',2)
detail+=frame(862,241,306,278)+text(880,276,'이온음료',24)+frame(1106,249,54,44)+text(1125,278,'×')
detail+=text(880,312,'미해금',16,'#e4eff4')+text(880,351,'마실 때마다 발견 금액 +2 Gold',18)
detail+=text(880,433,'해금 후 자판기에서 등장',15,'#dcebf2')
detail+=rect(882,468,270,38,'#12121d')+rect(880,466,270,38,'#559e9a','#12121d',3)+text(965,492,'5개로 추가')
gallery=''
for i,(key,body) in enumerate([('initial',base+header),('locked-selected',base+header+detail)]):
    (HERE/f'{key}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{body}</svg>',encoding='utf-8')
    gallery+=f'<g transform="translate({i*1260},0)">{body}</g>'
(HERE/'editable-states.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="2460" height="760">{gallery}</svg>',encoding='utf-8')
print('Play-style native initial/selected sources created')
