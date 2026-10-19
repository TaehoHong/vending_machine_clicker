from pathlib import Path
from html import escape
HERE=Path(__file__).parent
def r(x,y,w,h,c='#17394f',stroke='#4c89ac'):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}" stroke="{stroke}" stroke-width="3"/>'
def t(x,y,s,size=20,c='#fff0c5'):
    return f'<text x="{x}" y="{y}" font-family="Cafe24 PRO UP,카페24 프로업,sans-serif" font-size="{size}" fill="{c}">{escape(s)}</text>'
names=['물','녹차','보리차','이온음료','사과 주스','진저에일','레모네이드','라임 소다','복숭아 주스','오렌지 주스','비타민 음료','멜론 소다','황금 음료수','콜라','에너지 드링크']
colors=['#7bcde8','#a8cc66','#d6a554','#67bbed','#e98589','#7ab956','#e0ca53','#64b177','#e8a8b4','#e6a855','#dba756','#70b78a','#edcf60','#d65353','#7c858a']
def bottle(i,x,y):
    return r(x+8,y,14,8,'#e7edf0')+r(x,y+10,30,48,colors[i],'#122130')+r(x+4,y+24,22,19,'#e9eadb')
def source(k):
    titles=['A · 자판기 선택 + 능력 상세','B · 능력 / 음료수 추가 탭','C · 전체 음료 카드 통합']
    s=r(0,0,1200,760,'#0b1a2b')+t(26,40,titles[k],29)+t(26,72,'미채택 비교 시안 · 편집용 구조 원본 · 수치는 예시',18,'#9fbacc')
    s+=r(26,94,1148,52)+t(48,129,'음료와 능력',25)+t(861,129,'보유 빈캔 18    ESC ×',21)
    if k==0:
        s+=r(46,165,565,460,'#bd343e')
        for i,name in enumerate(names):
            x=65+i%5*107;y=184+i//5*140
            s+=r(x,y,96,126,'#e9e5cb')+bottle(i,x+32,y+8)+t(x+5,y+92,name,15,'#1c3343')+t(x+5,y+115,'미해금' if i==3 or i>5 else '해금 완료',14,'#1c3343')
        s+=r(635,165,510,225,'#e9e5cb')+t(660,205,'물 · 해금 완료 · 획득 3개',26,'#1c3343')+bottle(0,672,231)+t(735,265,'1개당 발견 골드 +1',22,'#1c3343')+t(735,315,'현재 누적 +3 Gold',25,'#1c3343')
        s+=r(635,411,510,214)+t(660,450,'다음 해금 · 이온음료',25)+t(660,493,'상위 골드 발견 확률 증가',22)+r(660,530,459,60,'#dba94a')+t(693,568,'빈캔 5개로 추가',25,'#1c3343')
    elif k==1:
        s+=r(46,165,536,54,'#307e9c')+t(225,200,'능력 보기',24)+r(597,165,548,54)+t(770,200,'음료수 추가 · 1',24)
        for i in range(6):
            x=46+i%3*180;y=238+i//3*172
            s+=r(x,y,166,157,'#e9e5cb')+bottle(i,x+17,y+18)+t(x+59,y+47,names[i],19,'#1c3343')+t(x+16,y+106,'해금 완료',19,'#1c3343')+t(x+16,y+136,'획득 3개',19,'#1c3343')
        s+=r(610,238,535,329,'#e9e5cb')+t(637,282,'선택한 음료 · 물',28,'#1c3343')+t(637,347,'1개당 발견 골드 +1',25,'#1c3343')+t(637,402,'현재 누적 +3 Gold',26,'#1c3343')+t(637,480,'추가 탭에서 새 음료 해금',22,'#1c3343')
    else:
        s+=t(46,186,'전체 15     해금 완료     추가 가능',23)
        for i,name in enumerate(names):
            x=46+i%5*140;y=210+i//5*137
            s+=r(x,y,130,125,'#284358' if i==3 or i>5 else '#e9e5cb')+bottle(i,x+49,y+7)+t(x+8,y+88,name,16,'#ffffff' if i==3 or i>5 else '#1c3343')+t(x+8,y+112,'미해금' if i==3 or i>5 else '획득 3개',16,'#ffffff' if i==3 or i>5 else '#1c3343')
        s+=r(767,210,378,396,'#e9e5cb')+t(790,253,'이온음료 · 미해금',26,'#1c3343')+bottle(3,790,278)+t(790,385,'상위 골드 발견 확률 증가',20,'#1c3343')+t(790,428,'해금 후 자판기에서 등장',20,'#1c3343')+r(786,477,338,62,'#dba94a')+t(808,517,'빈캔 5개로 추가',24,'#1c3343')
    s+=r(46,650,1099,60)+t(65,688,'현재 적용된 능력  |  발견 골드 +3  |  음료 획득으로 능력 강화',23)
    s+=t(26,740,'빈캔 해금 = 뽑기 목록 추가 / 능력 강화 = 플레이 중 음료 획득 · 게임 미적용',19,'#9fbacc')
    return s
gallery=''
for k,key in enumerate(['a-machine-details','b-tabs','c-unified-catalog']):
    body=source(k)
    (HERE/f'{key}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="760">{body}</svg>',encoding='utf-8')
    gallery+=f'<g transform="translate({k*1260},0)">{body}</g>'
(HERE/'editable-gallery.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="3720" height="760">{gallery}</svg>',encoding='utf-8')
print('Created editable structure sources')
