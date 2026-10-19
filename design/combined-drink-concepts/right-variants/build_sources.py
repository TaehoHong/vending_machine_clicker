from pathlib import Path
from html import escape
HERE=Path(__file__).parent
base=(HERE.parent/'a-machine-details.svg').read_text(encoding='utf-8')
body=base[base.index('>')+1:base.rindex('</svg>')]
def r(x,y,w,h,c,stroke='#548db0'):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}" stroke="{stroke}" stroke-width="3"/>'
def t(x,y,s,n=21,c='#f7efcf'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{n}" fill="{c}">{escape(s)}</text>'
gallery=''
for k,key in enumerate(['a-light-cards','b-electronic-panel','c-catalog-page']):
    dark=k==1; ink='#f7efcf' if dark else '#183449'; panel='#102b43' if dark else '#f0e8cc'
    right=r(627,155,527,480,panel)+r(642,170,497,55,'#17394f')+t(665,206,'보유 빈캔 18 · 수치 예시',23)
    if k==0:
        right+=t(657,267,'물 · 해금 완료 · 획득 3개',25,ink)
        right+=r(649,286,238,105,'#fff5d9')+t(663,316,'1개당 효과',20,ink)+t(663,364,'+1 Gold',29,'#1580aa')
        right+=r(899,286,238,105,'#fff5d9')+t(913,316,'현재 누적',20,ink)+t(913,364,'+3 Gold',29,'#1580aa')
    elif k==1:
        right+=t(655,268,'선택한 음료 · 물',27)+t(655,310,'해금 완료 / 획득 3개',22,'#70d8ef')
        right+=r(650,330,480,42,'#081d30','#54c9eb')+t(663,358,'1개당 효과                 +1 Gold',22)
        right+=r(650,381,480,42,'#081d30','#54c9eb')+t(663,409,'현재 누적 효과           +3 Gold',22)
    else:
        right+=t(655,266,'음료 기록 · 물',29,ink)+t(655,302,'해금 완료 · 획득 3개',21,ink)
        right+=r(650,318,480,69,'#fff5dc')+t(663,345,'1개당 효과             현재 누적',21,ink)+t(663,376,'+1 Gold                  +3 Gold',26,ink)
        right+=t(655,418,'획득 강화 3 / 10 · 예시',21,ink)
    y=445
    right+=r(642,y,497,175,'#19374d')+t(658,y+31,'다음 해금 · 이온음료 / 미해금',24)
    right+=t(658,y+65,'상위 골드 발견 확률 증가',21)+t(658,y+93,'해금 후 자판기에서 등장',19,'#a9c6d5')
    right+=r(656,y+108,468,50,'#e3af4b')+t(735,y+141,'빈캔 5개로 추가',25,'#183449')
    result=body+right
    (HERE/f'{key}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{result}</svg>',encoding='utf-8')
    gallery+=f'<g transform="translate({k*1260},0)">{result}</g>'
    gallery+=t(k*1260+30,805,['1 · 밝은 카드형','2 · 전자 패널형','3 · 도감 페이지형'][k],28)
(HERE/'editable-gallery.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="3720" height="830">{gallery}</svg>',encoding='utf-8')
print('Created right-panel editable structure variants')
