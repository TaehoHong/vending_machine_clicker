"""Prepare editable SVG clipping compositions from source pixels."""
import base64
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'design/v10'
data=json.loads((OUT/'geometry.json').read_text())
encoded=base64.b64encode((ROOT/data['source']).read_bytes()).decode()
defs=f'<image id="source" width="1024" height="1536" href="data:image/png;base64,{encoded}"/>'
clips=[]
layers=[]
for part in data['parts']+data['drinks']:
    key=part['key']
    clips.append(f'<clipPath id="{key}"><path d="{part["d"]}"/></clipPath>')
    if part.get('restore'):
        x,y,w,h=part['bounds']
        layers.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{part["restore"]}"/>')
    if not part.get('backgroundOnly'):
        layers.append(f'<g id="{key}" clip-path="url(#{key})"><use href="#source"/></g>')
    if part is data['parts'][-1]:
        (OUT/'empty-assembly.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1536"><defs>'+defs+''.join(clips)+'</defs>'+''.join(layers)+'</svg>')
(OUT/'assembly.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1536" viewBox="0 0 1024 1536"><defs>'+defs+''.join(clips)+'</defs>'+''.join(layers)+'</svg>')

cells=[]
for i,drink in enumerate(data['drinks']):
    bx,by,bw,bh=drink['bounds'];cell_x=(i%5)*240;cell_y=(i//5)*340
    dx=cell_x+(240-bw*1.5)/2-bx*1.5
    dy=cell_y+284-(by+bh)*1.5
    cells.append(f'<g transform="translate({dx} {dy}) scale(1.5)" clip-path="url(#{drink["key"]})"><use href="#source"/></g>')
    cells.append(f'<text x="{cell_x+120}" y="{cell_y+322}" text-anchor="middle" fill="#fff1d5" font-family="Cafe24 PRO UP" font-size="21">{drink["name"]}</text>')
(OUT/'drinks-preview.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1020"><defs>'+defs+''.join(clips)+'</defs><rect width="1200" height="1020" fill="#20313b"/>'+''.join(cells)+'</svg>')

print(json.dumps({'parts':len(data['parts']),'drinks':len(data['drinks']),'prepared':['assembly.svg','empty-assembly.svg','drinks-preview.svg']}))
