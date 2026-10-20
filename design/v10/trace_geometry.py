"""Trace vector clipping outlines; never alter the source raster pixels."""
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'design/review/ability-unlock/asset-page-approved-15-vending.png'
image = Image.open(SOURCE).convert('RGB')
catalog = json.loads((ROOT / 'design/v9/penpot-manifest.json').read_text())['components']
regions = [
    (185,260,286,435), (307,260,406,435), (425,260,526,435),
    (542,260,647,435), (665,290,776,435), (185,500,286,682),
    (308,500,407,682), (428,500,526,682), (543,540,649,682),
    (667,510,776,682), (184,766,287,919), (300,760,413,919),
    (422,760,530,919), (543,760,648,919), (660,760,776,919),
]

def simplify(points):
    result = []
    for point in points:
        if result and result[-1] == point:
            continue
        while len(result) > 1:
            a,b = result[-2:]
            if (b[0]-a[0])*(point[1]-b[1]) != (b[1]-a[1])*(point[0]-b[0]):
                break
            result.pop()
        result.append(point)
    return result

def profile_polygon(region, predicate):
    x0,y0,x1,y1 = region
    rows = []
    for y in range(y0,y1):
        xs = [x for x in range(x0,x1) if predicate(image.getpixel((x,y)))]
        if xs:
            rows.append((y,min(xs),max(xs)+1))
    assert rows and len(rows) == rows[-1][0]-rows[0][0]+1, region
    points = []
    for y,left,right in rows:
        points.extend([(right,y),(right,y+1)])
    for y,left,right in reversed(rows):
        points.extend([(left,y+1),(left,y)])
    return simplify(points)

def polygon(points, reverse=False):
    if reverse:
        points = list(reversed(points))
    return 'M'+' L'.join(f'{x},{y}' for x,y in points)+' Z'

def rect(x,y,w,h):
    return [(x,y),(x+w,y),(x+w,y+h),(x,y+h)]

def bounds(points):
    xs,ys = zip(*points)
    return [min(xs),min(ys),max(xs)-min(xs),max(ys)-min(ys)]

def clip_rect(points,x0,y0,x1,y1):
    for axis,value,keep_greater in [(0,x0,True),(0,x1,False),(1,y0,True),(1,y1,False)]:
        result=[]
        for a,b in zip(points,points[1:]+points[:1]):
            inside_a=a[axis]>=value if keep_greater else a[axis]<=value
            inside_b=b[axis]>=value if keep_greater else b[axis]<=value
            if inside_a:
                result.append(a)
            if inside_a!=inside_b:
                t=(value-a[axis])/(b[axis]-a[axis])
                result.append(tuple(round(a[i]+t*(b[i]-a[i]),3) for i in range(2)))
        points=result
    return simplify(points)

drinks = []
for asset,region in zip(catalog,regions):
    points = profile_polygon(region, lambda rgb:max(rgb)<130)
    drinks.append({**asset,'bounds':bounds(points),'points':points,'d':polygon(points)})

background = image.getpixel((0,0))
not_background = lambda rgb:max(abs(a-b) for a,b in zip(rgb,background))>8
body = profile_polygon((90,100,930,1395),not_background)
feet = [profile_polygon(region,not_background) for region in [(95,1395,260,1460),(770,1395,930,1460)]]

parts = []
def part(key,name,outer,holes=(),restore=None):
    all_points = [p for points in outer for p in points]
    parts.append({'key':key,'name':name,'bounds':bounds(all_points),
                  'd':' '.join(polygon(p) for p in outer)+' '+
                      ' '.join(polygon(p,True) for p in holes),
                  'restore':restore})

header = clip_rect(body,108,115,916,203)
display = rect(149,207,660,773)
payment = [
    ('status-display','상태 표시창',rect(817,504,68,84)),
    ('coin-slot','동전 투입구',rect(824,605,61,96)),
    ('bill-reader','지폐 투입구',rect(811,711,80,121)),
    ('return-lever','반환 레버',rect(811,844,82,106)),
]
outlet = rect(206,1128,592,197)
vent = rect(811,1214,69,108)
part('cabinet','본체 외장',[body],[header,display,*[p[2] for p in payment],outlet,vent])
part('header','상단 간판',[header])
openings=[]
row_regions=[(221,40,261,174,435,54),(489,22,511,171,682,55),(737,26,763,156,919,48)]
button_groups=[]
centers=[239,359,478,597,719]
for row,(ly,lh,by,bh,sy,sh) in enumerate(row_regions):
    lights=rect(168,ly,619,lh)
    backing=rect(168,by,619,bh)
    shelf=rect(168,sy,619,sh)
    openings.extend([lights,backing,shelf])
    part(f'light-{row+1}',f'진열 조명 · {row+1}단',[lights])
    sample=image.getpixel((290,by+10))
    color='#'+''.join(f'{c:02x}' for c in sample)
    part(f'backing-{row+1}',f'진열 배경 · {row+1}단',[backing],
         [d['points'] for d in drinks[row*5:row*5+5]],color)
    # Hidden backing pixels do not exist in the flattened source. A clean
    # native color plane avoids retaining outlines of removed containers.
    parts[-1]['backgroundOnly']=True
    button_holes=[]
    led_y=[438,687,924][row]
    button_y=[454,703,940][row]
    for col,cx in enumerate(centers):
        face=[(cx-22,button_y),(cx+22,button_y),(cx+27,button_y+5),
              (cx+27,button_y+21),(cx+22,button_y+27),(cx-22,button_y+27),
              (cx-27,button_y+21),(cx-27,button_y+5)]
        led=rect(cx-29,led_y,58,15)
        button_holes.extend([led,face])
        button_groups.append((f'button-{row+1}-{col+1}',f'상품 버튼 · {row+1}단 {col+1}열',[led,face]))
    part(f'shelf-{row+1}',f'금속 선반 · {row+1}단',[shelf],button_holes,'#8b969f')
part('display-frame','진열창 프레임',[display],openings)
for key,name,points in button_groups:
    part(key,name,points)
for key,name,points in payment:
    part(key,name,[points])
part('outlet','상품 배출구',[outlet])
part('vent','통풍구',[vent])
part('left-foot','받침 다리 · 왼쪽',[feet[0]])
part('right-foot','받침 다리 · 오른쪽',[feet[1]])
part('bottom-brace','하부 가로 프레임',[rect(239,1408,543,18)])
data = {'source':str(SOURCE.relative_to(ROOT)),'sourceWidth':1024,'sourceHeight':1536,
        'drinks':drinks,'parts':parts,'body':body,'feet':feet}
(ROOT / 'design/v10/geometry.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'drinks':len(drinks),'parts':len(parts),'bounds':{d['key']:d['bounds'] for d in drinks}},ensure_ascii=False))
