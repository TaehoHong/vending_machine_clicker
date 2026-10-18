"""Convert the approved SVG geometry to native Penpot rectangles, paths and text."""
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT=Path(__file__).parent
NAMES={'01-title':'01 · 시작','02-main-play':'02 · 메인 플레이','03-vending-purchase':'03 · 자판기 구매','04-item-result':'04 · 물품 획득','04b-miss-result':'04b · 꽝 결과','05-collection':'05 · 수집함','06-upgrades':'06 · 능력 강화','07-automation':'07 · 자동화 설치','08-pause':'08 · 일시정지','09-motion-storyboard':'09 · 모션 순서'}

def walk(e,ox=0,oy=0,sc=1,context='UI'):
    transform=e.get('transform','')
    trans=re.search(r'translate\(([-.\d]+)[ ,]+([-.\d]+)\)',transform)
    if trans: ox+=float(trans[1])*sc;oy+=float(trans[2])*sc
    scale=re.search(r'scale\(([-.\d]+)\)',transform)
    if scale: sc*=float(scale[1])
    context=e.get('id',context)
    tag=e.tag.split('}')[-1]
    n=lambda key,default=0:float(e.get(key,default))
    style=[e.get('fill','#111A30'),e.get('stroke'),n('stroke-width',4)*sc,n('opacity',1)]
    if tag=='rect':yield ['r',ox+n('x')*sc,oy+n('y')*sc,n('width')*sc,n('height')*sc,*style,context]
    elif tag=='text':yield ['t',ox+n('x')*sc,oy+n('y')*sc,n('font-size',22)*sc,''.join(e.itertext()),e.get('text-anchor','start'),e.get('fill'),e.get('font-weight','700'),context]
    elif tag=='path':
        vals=re.findall(r'[MLHVZ]|-?\d+(?:\.\d+)?',e.get('d'));d=[];ix=0;xx=yy=0
        while ix<len(vals):
            cmd=vals[ix];ix+=1
            if cmd=='Z':d.append('Z');continue
            if cmd in ['M','L']:xx=float(vals[ix]);yy=float(vals[ix+1]);ix+=2
            elif cmd=='H':xx=float(vals[ix]);ix+=1
            elif cmd=='V':yy=float(vals[ix]);ix+=1
            else:raise ValueError(cmd)
            d.append(f'{"M" if cmd=="M" else "L"}{ox+xx*sc:.3f} {oy+yy*sc:.3f}')
        yield ['p',' '.join(d),*style,context]
    for child in e:yield from walk(child,ox,oy,sc,context)

base=list(walk(ET.parse(ROOT/'v3'/'02-main-play.svg').getroot()))
NAMES['10-mobile-play']='10 · 모바일 메인'
for i,(stem,name) in enumerate(NAMES.items()):
    svg=ET.parse(ROOT/'v3'/f'{stem}.svg').getroot()
    rows=list(walk(svg))
    prefix=0
    if stem not in ('02-main-play','01-title','09-motion-storyboard','10-mobile-play'):
        for a,b in zip(base,rows):
            if a!=b:break
            prefix+=1
    args=[stem,name,(i%3)*1750,(i//3)*1050,rows[prefix:],prefix,float(svg.get('width')),float(svg.get('height'))]
    (ROOT/'v3'/f'{stem}.penpot.js').write_text('return storage.drawV3('+','.join(json.dumps(x,ensure_ascii=False,separators=(',',':')) for x in args)+');')

setup=r'''
storage.v3Boards=storage.v3Boards||{};
storage.drawV3=function(key,name,x,y,rows,prefix=0,w=1600,h=900){
 const b=prefix?storage.v3Boards['02-main-play'].clone():penpot.createBoard();
 if(prefix)b.children.slice(prefix).forEach(s=>s.remove());
 b.name=name;b.resize(w,h);b.x=x;b.y=y;b.clipContent=true;b.fills=[{fillColor:'#111A30',fillOpacity:1}];
 const fonts=penpot.fonts.all;const body=fonts.find(f=>f.name==='Noto Sans KR');const display=fonts.find(f=>f.name==='Do Hyeon');
 rows.forEach((a,j)=>{
  const i=j+prefix;
  let s;
  if(a[0]==='r'){
   s=penpot.createRectangle();s.resize(a[3],a[4]);s.x=x+a[1];s.y=y+a[2];s.fills=[{fillColor:a[5],fillOpacity:1}];
   if(a[6])s.strokes=[{strokeColor:a[6],strokeWidth:a[7],strokeAlignment:'center'}];s.opacity=a[8];s.name=a[9]+' / rect '+i;
  }else if(a[0]==='p'){
   s=penpot.createPath();s.d=a[1];s.fills=[{fillColor:a[2],fillOpacity:1}];if(a[3])s.strokes=[{strokeColor:a[3],strokeWidth:a[4],strokeAlignment:'center'}];s.x+=x;s.y+=y;s.opacity=a[5];s.name=a[6]+' / pixel shape';
  }else{
   const size=a[3],str=a[4];s=penpot.createText(str);const f=size>=20?display:body;
   f.applyToText(s,f.variants.find(v=>v.fontWeight===(size>=20?'400':a[7]))||f.variants[0]);
   s.fontSize=String(size);s.lineHeight='1.2';s.fills=[{fillColor:a[6],fillOpacity:1}];s.growType='fixed';
   const w=Math.ceil([...str].reduce((v,c)=>v+(c.charCodeAt(0)>255?1.02:.65)*size,0)+12);
   s.resize(w,size*1.55);s.x=x+a[1]-(a[5]==='middle'?w/2:a[5]==='end'?w:0);s.y=y+a[2]-size*1.05;
   s.align=a[5]==='middle'?'center':a[5]==='end'?'right':'left';s.verticalAlign='top';s.name='Text / '+str;
  }
  b.appendChild(s);
 });
 storage.v3Boards[key]=b;penpot.selection=[b];penpot.viewport.zoomIntoView([b]);
 return {id:b.id,name:b.name,shapes:b.children.length};
};
return {ready:true,page:penpot.currentPage.id};
'''
(ROOT/'v3'/'setup.penpot.js').write_text(setup)
print('Prepared',len(NAMES),'native boards')
