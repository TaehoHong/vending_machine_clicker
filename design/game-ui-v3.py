"""Original editable SVG game screens. Balance values are layout examples."""
from pathlib import Path
from html import escape

OUT = Path(__file__).parent / 'v3'
OUT.mkdir(exist_ok=True)
C = dict(ink='#111A30', panel='#23334D', edge='#52657C', text='#F4F1D0', muted='#B7C9CC', mint='#9CDEBC', gold='#FFD46C', red='#D86760', blue='#7EB7D4', wall='#91A5A4', floor='#556975')

class Screen:
    def __init__(self, name):
        self.name, self.s = name, []
    def rect(self, x,y,w,h,fill,stroke=None,sw=4, name=''):
        self.s.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+(f' id="{name}"' if name else '')+'/>')
    def text(self,x,y,value,size=22,color=None,weight=700,anchor='start'):
        self.s.append(f'<text x="{x}" y="{y}" font-family="Noto Sans KR, Apple SD Gothic Neo, sans-serif" font-size="{size}" font-weight="{weight}" text-anchor="{anchor}" fill="{color or C["text"]}">{escape(str(value))}</text>')
    def path(self,d,fill,stroke=None,sw=4):
        self.s.append(f'<path d="{d}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
    def group(self,name,x=0,y=0,scale=1):
        self.s.append(f'<g id="{name}" transform="translate({x} {y}) scale({scale})">')
    def end(self): self.s.append('</g>')
    def frame(self,x,y,w,h,fill=None):
        self.rect(x+5,y+6,w,h,C['ink'])
        self.rect(x,y,w,h,fill or C['panel'],C['ink'])
        self.rect(x+4,y+4,w-8,3,C['edge'])
    def button(self,x,y,w,h,label,color=None,disabled=False,small=False):
        color = '#40536A' if disabled else (color or C['mint'])
        self.rect(x+3,y+5,w,h,C['ink'])
        self.rect(x,y,w,h,color,C['ink'])
        self.rect(x+4,y+4,w-8,3,'#718899' if disabled else '#E0F3CF')
        self.text(x+w/2,y+h/2+8,label,18 if small else 22,C['muted'] if disabled else C['ink'],800,'middle')
    def coin(self,x,y,scale=1):
        self.group('coin',x,y,scale)
        self.path('M8 0H24V4H28V8H32V24H28V28H24V32H8V28H4V24H0V8H4V4H8Z',C['ink'])
        self.path('M8 4H24V8H28V24H24V28H8V24H4V8H8Z',C['gold'])
        self.rect(10,9,5,14,'#FFF1AF');self.rect(21,10,4,14,'#C48B44');self.end()
    def can(self,x,y,color=None,scale=1,empty=False):
        self.group('empty-can' if empty else 'drink-can',x,y,scale)
        self.path('M6 0H26V4H30V44H26V48H6V44H2V4H6Z',C['ink'])
        self.rect(6,7,20,34,color or C['red']);self.rect(7,2,18,5,'#D2DCD2');self.rect(12,3,8,2,C['edge'])
        self.rect(9,17,14,13,'#D2DCD2' if empty else C['text']);self.rect(7,42,18,3,'#D2DCD2');self.rect(6,8,3,32,'#FFFFFF' if empty else '#EC9A81');self.end()
    def item(self,x,y,kind,scale=1):
        if kind in ('cola','water','soda','empty'):
            return self.can(x,y,{'cola':C['red'],'water':C['blue'],'soda':C['mint'],'empty':'#7F9299'}[kind],scale,kind=='empty')
        self.group('item-'+kind,x,y,scale)
        if kind=='ramen':
            self.path('M0 12H44L38 48H6Z',C['red'],C['ink']);self.rect(-2,6,48,9,C['text'],C['ink']);self.rect(9,23,26,10,C['gold'])
        elif kind=='book':
            self.rect(0,0,38,48,C['gold'],C['ink']);self.rect(4,0,5,48,C['red']);self.rect(14,8,18,14,C['blue']);self.rect(14,29,18,3,C['ink']);self.rect(14,35,14,3,C['ink'])
        elif kind=='pizza':
            self.path('M4 2L44 44H0Z',C['gold'],C['ink']);self.path('M4 2L44 44L35 44L4 11Z','#BB6554');self.rect(10,26,7,7,C['red']);self.rect(23,33,7,7,C['red'])
        elif kind=='figure':
            self.rect(12,0,20,20,C['mint'],C['ink']);self.rect(7,24,30,24,C['blue'],C['ink']);self.rect(0,29,7,14,C['text']);self.rect(37,29,7,14,C['text']);self.rect(12,8,5,5,C['ink']);self.rect(26,8,5,5,C['ink'])
        else:
            self.rect(1,1,42,46,'#40536A',C['edge']);self.text(22,34,'?',30,C['muted'],800,'middle')
        self.end()
    def machine(self,x,y,scale=1,auto=False):
        self.group('automatic-machine' if auto else 'red-vending-machine',x,y,scale)
        body=C['blue'] if auto else C['red']
        self.rect(8,238,144,12,C['ink']);self.rect(6,4,146,232,C['ink']);self.rect(14,0,130,240,body,C['ink'])
        self.rect(18,4,122,5,'#C1E0DC' if auto else '#F4A08B');self.rect(139,8,7,226,'#466E8B' if auto else '#9C494E')
        self.rect(24,16,106,21,C['text'],C['ink'],3);self.text(77,32,'AUTO' if auto else 'DRINKS',15,C['ink'],900,'middle')
        self.rect(24,44,106,117,C['ink']);self.rect(30,49,94,105,'#C5DDD0')
        for row in range(3):
            for col in range(4):
                xx,yy=33+col*23,53+row*34
                self.can(xx,yy,[C['red'],C['blue'],C['mint'],C['gold']][(col+row)%4],.42)
                self.rect(xx-1,yy+23,19,5,C['ink']);self.rect(xx+4,yy+24,9,2,C['gold'])
            self.rect(29,78+row*34,96,4,C['panel'])
        self.rect(24,168,53,8,C['text']);self.rect(85,168,44,16,C['ink']);self.rect(90,172,31,5,C['mint'])
        self.rect(93,191,30,5,C['ink']);self.rect(111,188,4,10,C['gold'])
        self.rect(24,187,57,34,C['ink']);self.rect(28,191,49,14,'#344457');self.rect(28,211,49,5,'#835D62')
        for ix in range(4): self.rect(94+ix*7,213,3,10,C['ink'])
        self.rect(23,227,57,4,'#F4A08B' if not auto else '#C1E0DC');self.end()
    def hud(self):
        self.rect(0,0,1600,900,C['ink'])
        self.frame(24,20,292,68);self.text(44,47,'골목 자판기',26);self.text(44,72,'주택가 01  /  Lv. 3',15,C['muted'])
        self.frame(336,20,306,68);self.coin(355,36,1.1);self.text(404,47,'골드',14,C['muted']);self.text(621,73,'12,480 G',30,C['gold'],800,'end')
        self.frame(662,20,202,68);self.can(681,33,'#82969B',.85,True);self.text(724,47,'빈캔',14,C['muted']);self.text(842,73,'36',29,C['text'],800,'end')
        self.frame(884,20,310,68);self.text(904,47,'자동 수익  ·  1대 가동',15,C['muted']);self.text(904,74,'+120 G / 30초',26,C['mint'])
        self.button(1416,20,160,64,'일시정지  II',C['blue']);self.text(1334,62,'ESC',17,C['muted'])
    def scene(self):
        self.group('playfield')
        self.rect(24,110,984,650,C['wall'],C['ink'])
        self.rect(28,114,976,30,'#B0BEB2');self.rect(28,148,976,8,'#718B90')
        for yy in range(188,592,56):
            self.rect(28,yy,976,3,'#7D9699')
            for xx in range(28+(28 if (yy//56)%2 else 0),996,112): self.rect(xx,yy-34,3,34,'#7D9699')
        self.rect(28,594,976,25,'#3C5664');self.rect(28,622,976,134,C['floor'])
        for yy in [650,706]: self.rect(28,yy,976,3,'#71828A')
        for xx in range(42,1000,116): self.rect(xx,624,3,130,'#465967')
        self.frame(48,134,260,56,C['panel']);self.text(68,170,'01  주택가 골목',23)
        self.rect(334,166,28,437,'#5F7782');self.rect(343,166,9,437,'#A4B8B4')
        self.frame(72,232,198,118,'#BFD0B8');self.text(171,267,'喫茶',29,C['ink'],800,'middle');self.text(171,296,'COFFEE',18,C['ink'],800,'middle');self.rect(96,315,150,4,'#7A968D')
        self.rect(428,601,302,17,'#3C4C59');self.machine(418,202,1.8)
        self.rect(147,619,168,13,'#3C4C59');self.machine(151,394,.95,True)
        self.frame(94,650,272,72,C['panel']);self.text(110,679,'자동 1호기  ·  가동 중',18,C['mint']);self.rect(110,694,236,8,C['ink']);self.rect(110,694,142,8,C['mint']);self.text(346,718,'다음 수익 00:12',14,C['muted'],700,'end')
        self.rect(850,518,74,119,C['ink']);self.rect(856,531,62,100,'#9FB5AC');self.rect(847,514,80,18,C['ink']);self.rect(855,516,64,8,'#D7DCCA');self.rect(869,546,36,10,C['ink']);self.text(887,595,'REC',16,C['ink'],800,'middle')
        self.frame(792,670,188,52,C['panel']);self.text(886,702,'쓰레기통  Lv. 1',17,C['text'],700,'middle')
        self.frame(746,410,232,75,C['panel']);self.text(762,440,'떨어진 물품!',18,C['gold']);self.text(762,466,'회수 가능  ·  00:18',17,C['text'])
        self.rect(757,555,72,80,'#425A67',C['gold'],3);self.can(776,575,C['blue'],1.05)
        self.path('M781 534H803L792 546Z',C['gold'])
        self.rect(386,650,342,81,'#425A67',C['gold'],3);self.text(556,678,'자판기 밑을 클릭',19,C['text'],800,'middle')
        for j in range(4): self.rect(447+j*54,695,42,14,C['gold'] if j<3 else C['ink'])
        self.text(556,747,'동전 찾기  3 / 4   [SPACE]',17,C['text'],700,'middle')
        for x,y,k in [(433,620,.65),(488,631,.8),(570,622,.7),(631,629,.6)]:self.coin(x,y,k)
        self.text(682,609,'+50 G',34,C['gold'],900,'middle');self.rect(696,571,7,7,C['gold']);self.rect(714,591,5,5,C['gold'])
        self.end()
    def quickbar(self):
        self.frame(24,784,984,92);self.text(44,813,'가방',18);self.text(44,843,'1–4 사용',14,C['muted'])
        for i,(kind,num) in enumerate([('cola',3),('water',2),('soda',1),('ramen',1)]):
            x=148+i*130;self.rect(x,798,112,62,'#354B60',C['edge'],2);self.item(x+13,806,kind,.86);self.text(x+87,837,'×'+str(num),22,C['text'],800,'end')
        self.text(728,815,'자동 2호기 해금',18,C['gold']);self.text(728,846,'수집 물품 8 / 12',18,C['muted']);self.rect(728,857,245,6,C['ink']);self.rect(728,857,163,6,C['gold'])
    def panel(self,active,title,subtitle):
        self.frame(1032,110,544,766)
        for i,name in enumerate(['구매','강화','자동화','수집함']):
            x=1048+i*128;self.rect(x,126,120,48,C['mint'] if i==active else '#354B60',C['ink'],3);self.text(x+60,157,name,21,C['ink'] if i==active else C['muted'],800,'middle')
        self.text(1060,222,title,32);self.text(1060,256,subtitle,17,C['muted'])
        self.rect(1056,277,496,3,C['edge'])
    def base(self,active=0,title='골목의 하루',subtitle='동전을 모으고, 자판기를 키워 보세요.'):
        self.hud();self.scene();self.quickbar();self.panel(active,title,subtitle)
    def note(self): self.text(1568,895,'수치·시간·해금 조건은 시안 예시',12,C['muted'],500,'end')
    def write(self,width=1600,height=900):
        if width==1600:self.note()
        p=OUT/(self.name+'.svg');p.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">'+''.join(self.s)+'</svg>');return p

def shop(s):
    s.base(0,'음료 자판기','상품 선택 → 골드 투입 → 결과 확인')
    for i,(kind,name,price,count,desc) in enumerate([('cola','골목 콜라','350 G','3','사용하면 클릭 횟수 감소'),('water','맑은 샘물','200 G','2','사용 효과는 상세에서 확인'),('soda','멜론 소다','500 G','0','아직 발견하지 않은 음료')]):
        y=302+i*130;s.rect(1056,y,496,116,'#3B4D5E' if i==0 else '#293E55',C['gold'] if i==0 else C['edge'],3);s.item(1078,y+19,kind,1.15);s.text(1142,y+34,name,23);s.text(1532,y+34,'보유 '+count,16,C['muted'],700,'end');s.text(1142,y+67,desc,16,C['muted']);s.text(1532,y+99,price,25,C['gold'],800,'end')
    s.text(1060,732,'꽝이 나올 수 있습니다.',18,C['gold']);s.button(1056,760,496,66,'350 G 투입 · 콜라 뽑기',C['gold']);s.text(1304,855,'구매 후 보유 골드 12,130 G',16,C['muted'],600,'middle')

screens=[]
s=Screen('02-main-play');s.base()
s.text(1060,319,'다음 할 일',18,C['mint']);s.text(1060,362,'콜라 한 캔으로 더 빠르게',25);s.text(1060,398,'음료를 사용하면 능력이 올라갑니다.',18,C['muted']);s.item(1080,432,'cola',1.9);s.text(1174,463,'골목 콜라',26);s.text(1174,498,'보유 3개  ·  클릭 횟수 감소',17,C['muted']);s.button(1170,520,354,60,'보유 콜라 사용하기')
s.rect(1056,612,496,3,C['edge']);s.text(1060,654,'클릭 능력',20);s.text(1528,654,'4회마다 동전 발견',20,C['gold'],800,'end');s.text(1060,702,'자동 수익',20);s.text(1528,702,'+120 G / 30초',20,C['mint'],800,'end');s.button(1056,760,496,66,'자판기에서 뽑기 · 350 G',C['gold']);s.text(1304,855,'골드가 부족하면 자판기 밑에서 동전을 찾으세요.',15,C['muted'],500,'middle');screens.append(s)
s=Screen('03-vending-purchase');shop(s);screens.append(s)
s=Screen('06-upgrades');s.base(1,'능력 강화','빈캔을 모아 더 빠른 골목을 만드세요.')
for i,(kind,name,lv,desc,nextv,cost,okay) in enumerate([('cola','동전 수색','Lv. 3','발견에 필요한 클릭','4회 → 3회','빈캔 24개',True),('empty','쓰레기통','Lv. 1','물품 자동 회수 확률','10% → 15%','빈캔 48개',False),('figure','자동 자판기','Lv. 2','주기당 생산 골드','120 G → 150 G','빈캔 60개',False)]):
    y=304+i*176;s.rect(1056,y,496,160,'#293E55',C['edge'],2);s.item(1078,y+22,kind,.85);s.text(1135,y+34,name,23);s.text(1530,y+34,lv,18,C['mint'],800,'end');s.text(1135,y+65,desc,16,C['muted']);s.text(1135,y+97,nextv,24,C['gold']);s.button(1072,y+111,464,38,cost+(' · 강화' if okay else ' · 빈캔 부족'),disabled=not okay,small=True)
screens.append(s)
s=Screen('07-automation');s.base(2,'자동 자판기 설치','수집 조건을 달성하면 설치할 수 있습니다.')
s.rect(1056,304,496,198,'#293E55',C['edge'],2);s.machine(1074,327,.56,True);s.text(1192,342,'자동 1호기',25);s.text(1532,342,'가동 중',17,C['mint'],800,'end');s.text(1192,382,'+120 G / 30초',23,C['gold']);s.text(1192,416,'다음 생산까지 00:12',17,C['muted']);s.rect(1192,437,330,10,C['ink']);s.rect(1192,437,198,10,C['mint']);s.button(1192,462,330,28,'생산 능력 강화',small=True)
s.rect(1056,522,496,170,'#293E55',C['edge'],2);s.text(1076,558,'빈 설치 자리 02',24);s.text(1076,594,'물품 수집 8 / 12개',19,C['gold']);s.rect(1076,613,450,10,C['ink']);s.rect(1076,613,300,10,C['gold']);s.button(1072,646,464,32,'해금 전 · 물품 4개 더 수집',disabled=True,small=True)
s.text(1060,737,'떨어진 물품은 직접 회수하세요.',20);s.text(1060,772,'쓰레기통은 확률적으로 회수를 도와줍니다.',17,C['muted']);s.text(1060,813,'물품은 시간이 지나면 사라집니다.',17,C['gold']);screens.append(s)
s=Screen('05-collection');s.base(3,'가방 · 수집함','발견 8 / 12  ·  보유한 음료를 사용할 수 있어요.')
for i,label in enumerate(['전체','음료','라면','잡지','피자','피규어']):
    x=1056+i*84;s.rect(x,301,76,40,C['mint'] if i==0 else '#354B60',C['ink'],2);s.text(x+38,328,label,16,C['ink'] if i==0 else C['muted'],800,'middle')
for i,(kind,label,num) in enumerate([('cola','콜라','3'),('water','물','2'),('soda','소다','1'),('ramen','라면','1'),('book','잡지','1'),('unknown','미발견','—')]):
    x=1056+(i%3)*170;y=360+(i//3)*144;s.rect(x,y,156,128,'#3B4D5E' if i==0 else '#293E55',C['gold'] if i==0 else C['edge'],3);s.item(x+23,y+16,kind,1.1);s.text(x+139,y+42,'×'+num,19,C['muted'],700,'end');s.text(x+78,y+108,label,20,C['text'],800,'middle')
s.text(1534,653,'1 / 2   다음 >',15,C['muted'],700,'end');s.rect(1056,666,496,78,'#293E55',C['edge'],2);s.text(1076,696,'골목 콜라  ×3',21);s.text(1076,727,'사용 효과  ·  클릭 횟수 감소 / 빈캔 +1',17,C['muted']);s.button(1056,764,496,62,'콜라 1개 사용하기');s.text(1304,856,'사용 후 수량과 능력이 함께 갱신됩니다.',16,C['muted'],500,'middle');screens.append(s)
for miss in (False,True):
    s=Screen('04b-miss-result' if miss else '04-item-result');shop(s)
    s.rect(0,0,1600,900,'#111A30');s.s[-1]=s.s[-1].replace('/>',' opacity="0.78"/>')
    s.frame(416,130,768,640);s.rect(432,146,736,53,C['red'] if miss else C['mint']);s.text(800,181,'TRY AGAIN' if miss else 'ITEM GET!',26,C['ink'],900,'middle')
    if miss:s.text(800,360,'텅…',74,C['muted'],900,'middle')
    else:
        for xx,yy in [(650,300),(970,340),(720,242),(913,468)]:s.rect(xx,yy,8,8,C['gold'])
        s.item(748,240,'cola',3.2)
    s.text(800,475,'이번에는 꽝이에요' if miss else '골목 콜라 획득!',36,C['text'],800,'middle');s.text(800,522,'골드는 사용됐고, 물품은 획득하지 못했습니다.' if miss else '보유 수량 3 → 4',22,C['muted'],600,'middle')
    s.text(800,563,'다시 뽑거나 골목으로 돌아갈 수 있습니다.' if miss else '사용하면 클릭 횟수가 줄고 빈캔 1개를 얻어요.',19,C['gold'],600,'middle')
    if miss:s.button(456,610,688,64,'350 G · 다시 뽑기',C['gold'])
    else:s.button(456,610,332,64,'바로 사용');s.button(812,610,332,64,'가방에 보관',C['gold'])
    if miss:s.button(456,697,688,44,'골목으로 돌아가기  [ESC]',C['blue'],small=True)
    else:s.button(456,697,332,44,'다시 뽑기 · 350 G',C['blue'],small=True);s.button(812,697,332,44,'골목으로  [ESC]',C['blue'],small=True)
    screens.append(s)
s=Screen('01-title');s.rect(0,0,1600,900,C['ink']);s.rect(24,24,1552,852,C['panel'],C['edge']);
for yy in range(36,876,24):s.rect(36,yy,1528,2,'#263A52')
s.text(112,178,'VENDING ALLEY',24,C['mint']);s.text(108,286,'골목 자판기',78);s.text(112,342,'동전 하나부터 시작하는 작은 골목.',25,C['muted']);s.machine(1020,208,2.35);s.coin(1008,791,1.4);s.can(1394,744,C['blue'],1.1)
s.frame(112,409,624,92);s.text(136,443,'저장된 골목  ·  Lv. 3',20,C['muted']);s.text(136,479,'12,480 G  /  자동 자판기 1대',27,C['gold']);s.button(112,540,624,78,'이어하기');s.button(112,644,300,64,'새 게임',C['gold']);s.button(436,644,300,64,'설정',C['blue']);s.text(112,811,'동전을 줍고, 음료를 마시고, 자동 자판기를 설치하세요.',20,C['muted']);screens.insert(0,s)
s=Screen('08-pause');s.base();s.rect(0,0,1600,900,C['ink']);s.s[-1]=s.s[-1].replace('/>',' opacity="0.82"/>');s.frame(520,148,560,604);s.text(800,220,'PAUSED',24,C['mint'],900,'middle');s.text(800,280,'잠깐 쉬어가기',38,C['text'],800,'middle');s.button(560,326,480,70,'계속하기  [ESC]');s.text(560,454,'음악',23);s.rect(722,437,230,12,C['ink']);s.rect(722,437,170,12,C['mint']);s.rect(880,426,24,34,C['text'],C['ink'],3);s.text(1028,455,'70%',20,C['muted'],700,'end');s.text(560,516,'효과음',23);s.rect(722,499,230,12,C['ink']);s.rect(722,499,207,12,C['gold']);s.rect(920,488,24,34,C['text'],C['ink'],3);s.text(1028,517,'90%',20,C['muted'],700,'end');s.text(560,580,'모션 줄이기',23);s.button(906,548,130,48,'꺼짐',C['blue'],small=True);s.button(560,639,480,64,'타이틀로',C['blue']);screens.append(s)
s=Screen('09-motion-storyboard');s.rect(0,0,1600,900,C['ink']);s.text(48,70,'모션 · 입력부터 보상까지',36);s.text(48,110,'Penpot 정적 전후 상태  /  시간·흔들림·파티클은 구현 명세',19,C['muted'])
for i,(title,time,desc) in enumerate([('01  클릭','0–80 ms','눌림과 진행 칸을 즉시 표시'),('02  발견','80–260 ms','동전 등장 · 금액 표시'),('03  회수','260–560 ms','획득 수치가 상단 HUD로 이동'),('04  투입','0–340 ms','상품 선택 → 점등 → 기계 반응'),('05  배출','340–500 ms','배출구가 열리고 물품 등장'),('06  결과','500–680 ms','결과 · 수량 · 사용 / 보관')]):
    x=48+(i%3)*508;y=158+(i//3)*310;s.frame(x,y,480,278);s.text(x+24,y+37,title,24,C['mint']);s.text(x+454,y+36,time,16,C['muted'],700,'end');s.rect(x+24,y+58,432,146,'#718993');s.machine(x+165,y+71,.5)
    if i in [1,2]:s.coin(x+267,y+142,.75);s.text(x+340,y+136,'+50 G',24,C['gold']);
    if i in [4,5]:s.item(x+282,y+126,'cola',1.05)
    if i==0:
        for j in range(4):s.rect(x+170+j*24,y+189,18,7,C['gold'] if j<3 else C['ink'])
    s.text(x+24,y+244,desc,18)
s.text(48,825,'패널 180–220 ms  ·  반복 뽑기 연출 건너뛰기  ·  모션 줄이기: 흔들림·입자 제거',21,C['gold']);s.text(48,864,'음료 사용 → 능력 적용 → 빈캔 획득. 꽝에는 물품·능력 보상을 표시하지 않습니다.',19,C['muted']);screens.append(s)

for screen in screens:print(screen.write())

s=Screen('10-mobile-play');s.rect(0,0,390,844,C['ink']);s.text(16,37,'골목 자판기',25);s.button(326,12,48,48,'II',C['blue'],small=True)
s.frame(12,74,222,56);s.coin(24,88,.8);s.text(215,112,'12,480 G',25,C['gold'],800,'end');s.frame(246,74,128,56);s.can(259,83,'#82969B',.7,True);s.text(357,112,'36',25,C['text'],800,'end')
s.rect(12,146,362,406,C['wall'],C['ink']);s.rect(16,450,354,98,C['floor']);s.text(30,176,'주택가 01',17,C['ink']);s.machine(148,180,1.05);s.machine(30,318,.53,True)
s.rect(126,474,224,58,'#425A67',C['gold'],3);s.text(238,498,'동전 줍기',21,C['text'],800,'middle');s.text(238,522,'3 / 4',17,C['gold'],800,'middle');s.coin(177,450,.6);s.coin(238,451,.6);s.text(305,448,'+50 G',24,C['gold'],800,'middle');s.text(33,510,'자동 1대',14,C['ink']);s.text(33,534,'00:12',16,C['text'])
for i,label in enumerate(['구매','강화','자동화','수집함']):
    x=12+i*92;s.rect(x,570,84,48,C['mint'] if i==0 else '#354B60',C['ink'],3);s.text(x+42,601,label,18,C['ink'] if i==0 else C['text'],800,'middle')
s.frame(12,636,362,168);s.item(30,655,'cola',1.05);s.text(82,675,'골목 콜라  ×3',21);s.text(82,704,'클릭 횟수 감소',16,C['muted']);s.button(244,654,112,56,'사용하기',small=True);s.button(28,734,330,52,'자판기에서 뽑기 · 350 G',C['gold'],small=True);s.rect(140,825,110,4,C['muted']);print(s.write(390,844))
