"""Asset master import source; preserve v4 sources."""
from pathlib import Path
from copy import deepcopy
import base64
import xml.etree.ElementTree as ET

ROOT = Path(__file__).parent
SVG = 'http://www.w3.org/2000/svg'
XLINK = 'http://www.w3.org/1999/xlink'
ET.register_namespace('', SVG)
ET.register_namespace('xlink', XLINK)
source = list(ET.parse(ROOT.parent / 'v4/main-play.svg').getroot())
def el(tag, **attrs):
    return ET.Element('{'+SVG+'}'+tag, {k.replace('_','-'):str(v) for k,v in attrs.items()})
def canvas(w,h):
    return el('svg',width=w,height=h,viewBox=f'0 0 {w} {h}')
def label(parent,x,y,value,size=24,color='#F2F5F0'):
    text=el('text',x=x,y=y,font_family='Do Hyeon, Noto Sans KR, sans-serif',font_size=size,fill=color)
    text.text=value;parent.append(text)
def image(parent,x,y,w,h,path):
    item=el('image',x=x,y=y,width=w,height=h)
    item.set('{'+XLINK+'}href','data:image/png;base64,'+base64.b64encode(path.read_bytes()).decode())
    parent.append(item)
def group(parent,name,items,transform=None):
    g=el('g',id=name)
    if transform:g.set('transform',transform)
    for item in items:g.append(deepcopy(item))
    parent.append(g);return g
def save(root,name):
    ET.ElementTree(root).write(ROOT/name,encoding='unicode',xml_declaration=False)

assets=canvas(1920,1580)
assets.append(el('rect',width=1920,height=1580,fill='#202E38'))
label(assets,64,62,'에셋 마스터 · 화면과 별도로 관리',34)
label(assets,64,100,'A/B는 동일한 350×525 캔버스. 배경·UI·오브젝트는 각각 독립 레이어.',21,'#B9CED7')
for version,x,path in [('A',80,ROOT.parent/'v4/vending-machine-front-web.png'),('B',540,ROOT/'vending-machine-b-5x3-web.png')]:
    label(assets,x,150,f'자판기 {version} · '+('기존안' if version=='A' else '디테일 반영'))
    g=el('g',id=f'World--Vending--{version}')
    image(g,x,180,350,525,path);assets.append(g)
label(assets,1000,150,'배경 · 일본풍 골목길')
g=el('g',id='World--Japanese-alley')
image(g,1000,180,800,450,ROOT.parent/'v4/japanese-alley-web.png');assets.append(g)
label(assets,64,805,'UI · 네이티브 도형 / 글자',30)
ui=[('UI--Currency-HUD',16,25,80,880,30,28),('UI--Ability-purchase',30,37,450,880,967,410),
    ('UI--Unlock',37,42,800,880,1100,790),('UI--Upgrade',42,47,1150,880,1340,790),
    ('UI--Pause',25,30,1500,880,1496,28)]
for name,start,end,x,y,ox,oy in ui:
    label(assets,x,y-25,name.split('--')[-1],21)
    group(assets,name,source[start:end],f'translate({x-ox} {y-oy})')
label(assets,64,1155,'월드 오브젝트 / 클릭 피드백',30)
for name,index,x,y,scale in [('World--Coin',21,80,1240,3),('World--Empty-can',14,450,1240,2),
                              ('FX--Cursor',53,1150,1240,2),('FX--Spark',15,1500,1240,3)]:
    label(assets,x,y-25,name.split('--')[-1],21)
    item=deepcopy(source[index]);tr=item.get('transform','')
    if name=='World--Coin':item.attrib.pop('transform',None);ox=oy=0
    elif name=='World--Empty-can':item.attrib.pop('transform',None);ox=oy=0
    elif name=='FX--Cursor':ox,oy=790,682
    else:ox,oy=1135,613
    group(assets,name,[item],f'translate({x} {y}) scale({scale}) translate({-ox} {-oy})')
label(assets,800,1215,'Trash-bin',21)
group(assets,'World--Trash-bin',source[5:14],'translate(800 1240) scale(1.5) translate(-1227 -546)')
save(assets,'assets-library.svg')
print('Prepared 13 independent asset groups.')
