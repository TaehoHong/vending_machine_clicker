"""One playfield composition based on the user-selected game reference."""
import base64
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from html import escape

ROOT=Path(__file__).parent
ink='#12121D'
parts=[]
def rect(x,y,w,h,c,stroke=None,sw=4):
    parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
def text(x,y,value,size=28,color='#FFFFFF',anchor='start',outline=3):
    parts.append(f'<text x="{x}" y="{y}" font-family="Do Hyeon, Noto Sans KR, sans-serif" font-size="{size}" font-weight="800" fill="{color}" text-anchor="{anchor}" stroke="{ink}" stroke-width="{outline}" stroke-linejoin="round" paint-order="stroke fill">{escape(value)}</text>')
def path(d,color,stroke=None,sw=4):
    parts.append(f'<path d="{d}" fill="{color}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
def frame(x,y,w,h,c='#4B98D0'):
    rect(x+5,y+7,w,h,ink);rect(x,y,w,h,c,ink,6);rect(x+5,y+5,w-10,6,'#A8DBEC');rect(x+5,y+h-10,w-10,5,'#28567F')
def star(x,y,s=12):
    path(f'M{x} {y-s}L{x+4} {y-4}L{x+s} {y}L{x+4} {y+4}L{x} {y+s}L{x-4} {y+4}L{x-s} {y}L{x-4} {y-4}Z','#FFF7C6')
def coin(x,y,s=1):
    parts.append(f'<g id="coin" transform="translate({x} {y}) scale({s})">')
    path('M8 0H28V4H32V8H36V28H32V32H28V36H8V32H4V28H0V8H4V4H8Z',ink)
    path('M8 4H28V8H32V28H28V32H8V28H4V8H8Z','#F7B747');rect(9,9,18,19,'#D8872E');rect(10,10,7,15,'#FFE48C');rect(25,9,4,16,'#B7672C');parts.append('</g>')
def can(x,y,s=1):
    parts.append(f'<g id="material-can" transform="translate({x} {y}) scale({s})">')
    path('M6 0H27V4H31V45H27V49H6V45H2V4H6Z',ink)
    rect(6,6,21,37,'#97ADB3');rect(6,7,5,32,'#DBE6D5');rect(22,8,5,33,'#627C8A');rect(7,2,19,5,'#E5E8DC');rect(12,3,9,2,'#4C5F70');rect(10,18,15,12,'#E0E3CB');rect(7,43,18,3,'#4C5F70');parts.append('</g>')
def image(x,y,w,h,filename,kind):
    encoded=base64.b64encode((ROOT/filename).read_bytes()).decode()
    parts.append(f'<image x="{x}" y="{y}" width="{w}" height="{h}" data-art="{kind}" href="data:image/png;base64,{encoded}"/>')
def machine(x,y,w):
    image(x,y,w,w*1.5,'vending-machine-front-web.png','machine')

rect(0,0,1600,900,'#202A32')
image(20,18,1560,862,'japanese-alley-web.png','alley')
# Peripheral objects leave the center and the coin-search area unobstructed.
machine(290,390,190);text(385,694,'00:12',24,anchor='middle')
machine(630,160,350)
rect(1232,553,66,100,ink);rect(1238,560,54,87,'#507C75');rect(1280,560,12,87,'#31545A');rect(1227,546,77,15,ink);rect(1233,548,63,7,'#B4D2BB');rect(1249,571,32,10,ink);rect(1247,606,35,8,'#C0D2B6');rect(1257,595,10,29,'#C0D2B6');rect(1237,648,56,6,'#2A4853')
can(1132,642,.95);star(1145,623,10)
# Tight HUD at the edge. No title block, sidebar, inventory bar or tutorial card.
frame(30,28,238,118)
rect(37,86,224,3,'#28567F');coin(48,42,1.0);text(98,76,'1,250 G',32)
can(50,97,.65);text(98,124,'빈캔 8',26)
frame(1496,28,70,58,'#637D94');text(1531,68,'ESC',23,anchor='middle')
# Buy on the object. The world remains visible and the cursor can return nearby.
frame(996,410,190,94,'#528DC5');text(1091,445,'능력 뽑기',23,anchor='middle');text(1091,483,'100 G',34,'#FFE282','middle')
path('M982 440L967 452L982 465Z','#FFE282',ink,3)
frame(1100,790,218,72,'#559E9A');text(1209,837,'자판기 해금',27,anchor='middle')
frame(1340,790,226,72);text(1453,837,'능력 강화',29,anchor='middle')
# Coins and local feedback are game objects, not an extra action button.
coin(716,675,.65);coin(785,688,.8);coin(859,674,.62)
star(745,658,8);star(894,695,7)
text(906,637,'+50 G',36,'#FFE282','middle',4)
path('M797 707L797 682L803 682L803 696L810 694L814 698L821 698L826 704L826 720L820 730L804 730L790 716L790 710Z','#FFFFFF',ink,4)
text(810,765,'3 / 4',30,anchor='middle',outline=4)
text(810,818,'자판기 밑을 클릭',21,'#F2EED4','middle',2)
svg='<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="900" viewBox="0 0 1600 900">'+''.join(parts)+'</svg>'
(ROOT/'main-play.svg').write_text(svg)

# Keep native geometry separate from the raster sprite for the Penpot authoring path.
root=ET.fromstring(svg)
rows=[]
def walk(e,ox=0,oy=0,sc=1):
    import re
    tr=e.get('transform','');m=re.search(r'translate\(([-.\d]+) ([-.\d]+)\)',tr)
    if m:ox+=float(m[1])*sc;oy+=float(m[2])*sc
    m=re.search(r'scale\(([-.\d]+)\)',tr)
    if m:sc*=float(m[1])
    n=lambda k,d=0:float(e.get(k,d));tag=e.tag.split('}')[-1]
    if tag=='rect':rows.append(['r',ox+n('x')*sc,oy+n('y')*sc,n('width')*sc,n('height')*sc,e.get('fill'),e.get('stroke'),n('stroke-width',4)*sc])
    elif tag=='image':rows.append(['i',n('x'),n('y'),n('width'),n('height'),e.get('data-art')])
    elif tag=='text':rows.append(['t',ox+n('x')*sc,oy+n('y')*sc,n('font-size')*sc,e.text,e.get('fill'),e.get('text-anchor','start'),n('stroke-width',3)])
    elif tag=='path':
        vals=re.findall(r'[MLHVZ]|-?\d+(?:\.\d+)?',e.get('d'));i=0;xx=yy=0;d=[]
        while i<len(vals):
            cmd=vals[i];i+=1
            if cmd=='Z':d.append('Z');continue
            if cmd in ('M','L'):xx=float(vals[i]);yy=float(vals[i+1]);i+=2
            elif cmd=='H':xx=float(vals[i]);i+=1
            elif cmd=='V':yy=float(vals[i]);i+=1
            d.append(f'{"M" if cmd=="M" else "L"}{ox+xx*sc:.3f} {oy+yy*sc:.3f}')
        rows.append(['p',' '.join(d),e.get('fill'),e.get('stroke'),n('stroke-width',4)*sc])
    for child in e:walk(child,ox,oy,sc)
walk(root)
(ROOT/'geometry.json').write_text(json.dumps(rows,ensure_ascii=False,separators=(',',':')))
print('Prepared one main playfield:',len(rows),'elements')
