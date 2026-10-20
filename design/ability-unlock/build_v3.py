"""Editable SVG + Penpot geometry for the B-style ability collection screen."""
from pathlib import Path
from PIL import Image
import base64, html, json

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
R=[]
C={'ink':'#141D29','muted':'#BED0D2','cream':'#FFF1D4','gold':'#FFCF65','mint':'#A7E2C4'}
def rect(name,x,y,w,h,color,opacity=1):R.append(dict(kind='rect',name=name,x=x,y=y,w=w,h=h,color=color,opacity=opacity))
def ellipse(name,x,y,w,h,color,opacity=1):R.append(dict(kind='ellipse',name=name,x=x,y=y,w=w,h=h,color=color,opacity=opacity))
def text(label,x,y,w,size=18,color='#FFF1D4',display=False,align='left'):
 R.append(dict(kind='text',name='Text / '+label,text=label,x=x,y=y,w=w,h=size*1.6,size=size,color=color,display=display,align=align))
def image(key,path,x,y,w,h,opacity=1):R.append(dict(kind='image',name='Artwork / '+key,key=key,path=str(path.relative_to(ROOT)),x=x,y=y,w=w,h=h,opacity=opacity))
def status(kind,x,y):
 color='#41565C' if kind=='new' else '#256747'
 if kind=='new':
  rect('Status / 미획득 고리',x+2,y,8,7,color);rect('Status / 고리 안',x+4,y+2,4,5,'#F5E8C1');rect('Status / 미획득',x,y+5,12,9,color);rect('Status / 열쇠',x+5,y+8,2,4,'#F5E8C1')
 else:
  for a,b,w,h in [(0,5,3,4),(3,8,3,3),(6,5,3,3),(9,2,3,3)]:rect('Status / 최대',x+a,y+b,w,h,color)

image('alley',ROOT/'design/v4/japanese-alley-web.png',0,0,1600,900)
rect('Background / 어둡게',0,0,1600,900,'#101B29',.53)
# Tight contact shadows and softer surrounding ground shadow.
ellipse('Ground / 주변 그림자',501,817,614,40,'#111923',.26)
ellipse('Ground / 접지 그림자',523,826,570,18,'#0A111B',.62)
image('cabinet',OUT/'cabinet-b-empty-v3.png',448,-20,704,921.6)
text('능력 해금',551,31,482,24,'#FFF2D7',True,'center')
text('8/15',1024,283,43,14,'#A8E685',True,'center')
items=[('water','물',3,10),('green-tea','녹차',2,10),('barley-tea','보리차',1,10),('ion','이온음료',1,5),('apple','사과 주스',2,5),('ginger-ale','진저에일',1,10),('lemonade','레모네이드',3,3),('lemon-lime-soda','레몬라임 소다',1,10),('peach-juice','복숭아 주스',0,10),('orange','오렌지 주스',0,10),('vitamin','비타민 음료',0,1),('melon-soda','멜론 소다',0,1),('golden-drink','황금음료',0,None),('cola','콜라',0,1),('energy-drink','에너지 드링크',0,None)]
metrics=[]
for i,(key,name,level,cap) in enumerate(items):
 row,col=divmod(i,5);x=558+col*88.2;floor=228+row*145.2;center=x+44.1
 p=ROOT/'design/v9/exports'/f'{key}.png';im=Image.open(p).convert('RGBA');a=im.getchannel('A');bounds=a.point(lambda v:255 if v>12 else 0).getbbox();l,t,r,b=bounds
 target_height={'apple':92,'peach-juice':88,'vitamin':80,'melon-soda':84,'golden-drink':91,'cola':87,'energy-drink':91}.get(key,103)
 scale=min(target_height/(b-t),62/(r-l));w,h=im.width*scale,im.height*scale
 ellipse('Shelf / '+name+' 접지',center-19,floor-4,38,6,'#806A43',.30)
 if i==0:rect('Selection / 물 아래 점등',center-22,floor-1,44,3,'#F6CF55')
 image(key,p,center-(l+r)*scale/2,floor-b*scale,w,h,.96 if level==0 else 1)
 if level==0:status('new',x+72,floor-87)
 elif level==cap:status('max',x+72,floor-87)
 rect('Label / '+name+' 명판',x+4,floor,80.2,16,'#FFD36F' if i==0 else '#F0E8CD')
 text('물 · 선택' if i==0 else name,x,floor+1,88.2,11.5 if len(name)>6 else 12,'#30382F',False,'center')
 # Raised metal button: bright upper lip, visible face, lower offset shadow.
 if i==0:rect('Selection / 버튼 외곽',center-31,floor+15,62,20,'#FFD66D')
 rect('Select / '+name+' / 선택 가능',center-28,floor+17,56,16,'#1E2933')
 rect('Button / 메탈 윗면',center-26,floor+18,52,3,'#E3EBE4')
 rect('Button / 누름면',center-26,floor+21,52,9,'#263D48' if i==0 else '#B5C4C7')
 rect('Button / 아래 깊이',center-25,floor+30,50,2,'#5F7380')
 rect('Button / 점등',center-15,floor+24,30,3,'#FFF0A1' if i==0 else '#45616A')
 metrics.append(dict(key=key,visible_height=round((b-t)*scale,2),visible_width=round((r-l)*scale,2),contact_y=floor))
rect('LCD / 표시창 확장',560,551,441,67,'#0D242C')
rect('LCD / 상단 반사',564,553,433,2,'#31575B')
rect('LCD / 하단 음영',564,615,433,2,'#071A22')
text('물 · 현재 누적 효과',571,555,295,19,'#DEF1DA',True)
text('+3 G',871,553,120,24,'#FFDE8A',True,'right')
text('발견 골드 증가',571,587,280,16,'#D3E4D9')
text('획득 3 / 10',867,588,124,15,'#BED4C8',False,'right')
# Small contextual help; collection state never disables selecting an item.
text('음료를 눌러 능력을 확인하세요.',48,53,398,19,'#FFF0D6')
text('미획득 음료도 설명을 볼 수 있어요.',48,87,398,16,'#C8D9D8')
rect('Action / 돌아가기',1434,28,126,42,'#263B4B')
text('ESC  돌아가기',1439,36,116,16,'#FFF1D4',False,'center')
text('효과·획득 횟수는 시안 예시입니다.',32,865,850,14,'#C1D1D2')

main=list(R)
R=[]
text('능력 상태 · 획득 여부와 선택은 별개',32,22,1480,30,'#FFF1D4',True)
examples=[(32,'해금됨 · 선택','water','현재 누적 효과 +3 G','획득 3 / 10','상품 버튼 점등 + 본체 표시창에 현재 효과 표시'),(552,'미획득 · 선택 가능','cola','아직 획득하지 않은 능력','음료 구매 성공 시 해금','음료 외형 유지 + 작은 잠금 · 설명 선택 가능'),(1072,'최대 강화 · 선택 가능','lemonade','강화 한도에 도달한 능력','MAX','같은 위치의 작은 체크 · 이후 보상은 미정')]
for x,title,key,effect,badge,hint in examples:
 rect('State / '+title,x,82,496,210,'#263B4B');text(title,x+20,98,450,23,'#FFCF65' if key=='water' else '#A7E2C4' if key=='lemonade' else '#D2DFDC',True)
 image(key,ROOT/'design/v9/exports'/f'{key}.png',x+8,142,80,120,1)
 if key!='water':status('new' if key=='cola' else 'max',x+74,156)
 text(effect,x+105,151,370,18,'#FFF1D4');text(badge,x+105,191,370,18,'#BED6CE');text(hint,x+20,259,460,13,'#BED0D2')
text('상품 버튼은 획득 여부와 관계없이 상세 설명을 선택합니다. 이 화면에서 직접 구매하거나 음료를 사용하지 않습니다.',32,326,1510,18,'#BED0D2')
text('현재 누적 효과와 획득 횟수를 구분합니다. 효과·한도·진행도는 예시이며 황금음료 효과와 한도 이후 보상은 미정입니다.',32,364,1510,16,'#BED0D2')
states=list(R)

def svg(rows,width,height):
 out=[f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',f'<rect width="{width}" height="{height}" fill="#141D29"/>']
 for s in rows:
  x,y,w,h=s['x'],s['y'],s['w'],s['h'];kind=s['kind'];name=html.escape(s['name'],quote=True)
  if kind=='image':
   data=base64.b64encode((ROOT/s['path']).read_bytes()).decode();out.append(f'<image x="{x}" y="{y}" width="{w}" height="{h}" opacity="{s["opacity"]}" preserveAspectRatio="none" xlink:href="data:image/png;base64,{data}"/>')
  elif kind=='text':
   align=s['align'];anchor='start' if align=='left' else 'end' if align=='right' else 'middle';xx=x if align=='left' else x+w if align=='right' else x+w/2;font='Cafe24 PRO UP'
   out.append(f'<text x="{xx}" y="{y+s["size"]*1.08}" font-family="{font}" font-size="{s["size"]}" font-weight="400" fill="{s["color"]}" text-anchor="{anchor}">{html.escape(s["text"])}</text>')
  elif kind=='ellipse':out.append(f'<ellipse cx="{x+w/2}" cy="{y+h/2}" rx="{w/2}" ry="{h/2}" fill="{s["color"]}" opacity="{s["opacity"]}"/>')
  else:out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{s["color"]}" opacity="{s["opacity"]}"/>')
 out.append('</svg>');return '\n'.join(out)
(OUT/'main-v3.svg').write_text(svg(main,1600,900));(OUT/'states-v3.svg').write_text(svg(states,1600,410))
(OUT/'geometry-v3.json').write_text(json.dumps(dict(main=main,states=states,metrics=metrics),ensure_ascii=False,indent=2))
print('Prepared v3: 15 products, visible height',min(a['visible_height'] for a in metrics),'to',max(a['visible_height'] for a in metrics))
