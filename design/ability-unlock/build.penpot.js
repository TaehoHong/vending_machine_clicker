// Run through an authorized Penpot MCP session. All values are design examples.
const page = penpot.currentFile.pages.find(p => p.id === '55aeaacb-aa46-80be-8008-cdca4fa29ef0');
await penpot.openPage(page);

const rough = page.getShapeById('e7808af8-2ea3-8077-8008-cedf2d2bb675');
rough.x = 1800;
rough.name = '능력 해금 · 사용자 원본 러프 · 보존';
const C = { ink:'#141D29', panel:'#263B4B', tile:'#324F62', muted:'#BED0D2', cream:'#FFF1D4', gold:'#FFCF65', mint:'#A7E2C4', red:'#B7463D', edge:'#71352F', light:'#E87A5F' };
const heading = penpot.fonts.all.find(f => f.name === 'Do Hyeon');
const body = penpot.fonts.all.find(f => f.name === 'Noto Sans KR');
function board(name,x,y,w,h,color,parent) {
 const s=penpot.createBoard();s.name=name;s.resize(w,h);s.x=x;s.y=y;s.fills=[{fillColor:color,fillOpacity:1}];s.clipContent=true;if(parent)parent.appendChild(s);return s;
}
function rect(parent,name,x,y,w,h,color,stroke,width=2) {
 const s=penpot.createRectangle();s.name=name;s.resize(w,h);s.x=x;s.y=y;s.fills=[{fillColor:color,fillOpacity:1}];if(stroke)s.strokes=[{strokeColor:stroke,strokeWidth:width,strokeAlignment:'inner'}];parent.appendChild(s);return s;
}
function text(parent,label,x,y,w,size=20,color=C.cream,display=false,align='left') {
 const s=penpot.createText(label);s.name='Text / '+label;const font=display?heading:body;font.applyToText(s,display?font.variants[0]:font.variants.find(v=>v.fontWeight==='500'));s.fontSize=String(size);s.lineHeight='1.35';s.growType='fixed';s.resize(w,size*1.6);s.x=x;s.y=y;s.align=align;s.fills=[{fillColor:color,fillOpacity:1}];parent.appendChild(s);return s;
}
function art(parent,key,x,y,w,h,opacity=1) {
 const s=rect(parent,'Artwork / '+key,x,y,w,h,C.panel);s.fills=[{fillImage:storage.unlockMedia[key],fillOpacity:1}];s.opacity=opacity;return s;
}
function lock(parent,x,y,color=C.muted) {
 rect(parent,'Lock / shackle',x+4,y,16,17,color);rect(parent,'Lock / opening',x+8,y+4,8,13,C.panel);rect(parent,'Lock / body',x,y+12,24,19,color);rect(parent,'Lock / keyhole',x+10,y+18,4,7,C.ink);
}
function check(parent,x,y,color=C.mint) {
 rect(parent,'Check / step 1',x,y+5,4,6,color);rect(parent,'Check / step 2',x+4,y+8,4,6,color);rect(parent,'Check / step 3',x+8,y+4,4,6,color);rect(parent,'Check / step 4',x+12,y,4,6,color);
}
const Y=1379;
const main=page.getShapeById('e7808af8-2ea3-8077-8008-cee0143cdedc');
for(const child of main.children)child.remove();
main.name='능력 해금 · 실제 자판기 형태 · 음료 15종';
const previous=page.getShapeById('55aeaacb-aa46-80be-8008-cdca500ac9c3');
const alley=previous.children.find(s=>s.fills?.some(f=>f.fillImage)&&s.width>1000);
if(alley){const bg=rect(main,'Background / 기존 일본풍 골목길',0,Y,1600,900,C.ink);bg.fills=alley.fills;}
const dim=rect(main,'Overlay / 메뉴 집중',0,Y,1600,900,C.ink);dim.opacity=.68;
// A standing vending cabinet: face, side depth, feet and a recessed glass display.
rect(main,'Cabinet / 접지 그림자',525,Y+842,580,16,C.ink).opacity=.6;
rect(main,'Cabinet / 오른쪽 측면',1059,Y+49,30,780,'#652B2F',C.ink,4);
rect(main,'Cabinet / 오른쪽 반사광',1066,Y+64,5,740,'#A84B45');
for(const x of [544,978]){
 rect(main,'Cabinet / 받침 다리',x,Y+822,62,29,C.ink);
 rect(main,'Cabinet / 다리 전면',x+7,Y+827,47,15,'#778B99');
 rect(main,'Cabinet / 다리 반사광',x+7,Y+827,47,4,'#B7C5CB');
}
rect(main,'Cabinet / 빨간 전면 외장',512,Y+34,554,794,'#CC4B42',C.ink,6);
rect(main,'Cabinet / 상단 하이라이트',522,Y+42,534,7,'#F59376');
rect(main,'Cabinet / 좌측 하이라이트',520,Y+50,7,766,'#EC715E');
rect(main,'Cabinet / 우측 접힘',1050,Y+50,8,766,'#913639');
rect(main,'Cabinet / 하단 접힘',528,Y+811,522,10,'#913639');
rect(main,'Cabinet / 상단 도어 이음새',528,Y+135,522,5,'#8B3335');
rect(main,'Marquee / 조명 외곽',534,Y+60,508,70,C.ink);
rect(main,'Marquee / 알루미늄 테두리',538,Y+64,500,62,'#94A4A7');
rect(main,'Marquee / 크림색 조명판',544,Y+70,488,50,C.cream);
rect(main,'Marquee / 상단 조명',548,Y+72,480,4,'#FFFFFF');
text(main,'능력 해금',551,Y+75,474,29,'#752F31',true,'center');
// Three continuous lit shelves, without per-item UI cards.
rect(main,'Display / 고무 패킹',534,Y+145,440,393,C.ink);
rect(main,'Display / 메탈 외곽',540,Y+151,428,381,'#9FAFAF');
rect(main,'Display / 메탈 상단 반사',540,Y+151,428,5,'#E1E7DE');
rect(main,'Display / 진열창 안쪽 그림자',546,Y+157,416,369,'#736F68');
rect(main,'Display / 조명 뒷판',550,Y+161,408,361,'#F5E7BC');
rect(main,'Display / 왼쪽 조명',550,Y+163,5,357,'#FFF9E5');
rect(main,'Display / 오른쪽 깊이',953,Y+163,5,357,'#C6AB77');
// Payment hardware remains part of the machine silhouette, not a purchase action.
rect(main,'Payment / 세로 금속 패널',986,Y+160,56,378,'#7D8E97',C.ink,3);
rect(main,'Payment / 좌측 메탈 광택',989,Y+164,3,370,'#C8D2D3');
rect(main,'Payment / 발견 수 표시창',994,Y+183,40,63,C.ink);
text(main,'해금',996,Y+186,36,11,'#B1CEAD',false,'center');
text(main,'8/15',996,Y+211,36,15,'#A8E281',true,'center');
rect(main,'Payment / 동전 투입구 베젤',997,Y+269,34,58,C.ink);
rect(main,'Payment / 투입구 금속',1001,Y+273,26,50,'#CAD4D3');
rect(main,'Payment / 동전 슬릿',1010,Y+280,8,36,'#1E2B34');
rect(main,'Payment / 슬릿 반사광',1017,Y+280,2,36,'#71828E');
rect(main,'Payment / 지폐 리더 베젤',995,Y+352,38,59,C.ink);
rect(main,'Payment / 지폐 리더 전면',999,Y+356,30,51,'#A8B7BC');
rect(main,'Payment / 지폐 투입구',1001,Y+365,26,8,'#202C36');
rect(main,'Payment / 리더 하단',1003,Y+386,22,13,'#596E80');
const dial=penpot.createEllipse();dial.name='Payment / 반환 레버';dial.resize(28,28);dial.x=1000;dial.y=Y+447;dial.fills=[{fillColor:'#BBC8CB',fillOpacity:1}];dial.strokes=[{strokeColor:C.ink,strokeWidth:5,strokeAlignment:'inner'}];main.appendChild(dial);
rect(main,'Payment / 반환 레버 홈',1012,Y+454,4,14,'#314552');
rect(main,'Payment / 반환구',998,Y+496,32,24,C.ink);
rect(main,'Payment / 반환구 안쪽',1003,Y+501,22,11,'#627684');
const items=[
 ['water','물',3,10],['green-tea','녹차',2,10],['barley-tea','보리차',1,10],['ion','이온음료',1,5],['apple','사과 주스',2,5],
 ['ginger-ale','진저에일',1,10],['lemonade','레모네이드',3,3],['lemon-lime-soda','레몬라임 소다',1,10],['peach-juice','복숭아 주스',0,10],['orange','오렌지 주스',0,10],
 ['vitamin','비타민 음료',0,1],['melon-soda','멜론 소다',0,1],['golden-drink','황금음료',0,null],['cola','콜라',0,1],['energy-drink','에너지 드링크',0,null]
];
const tiles=[];
for(let row=0;row<3;row++){
 const y=Y+166+row*122;
 rect(main,'Shelf / '+(row+1)+'단 상단 조명',555,y-2,394,4,'#FFF9E5');
 rect(main,'Shelf / '+(row+1)+'단 알루미늄 선반',550,y+88,408,31,'#8B9AA2');
 rect(main,'Shelf / '+(row+1)+'단 선반 반사광',550,y+88,408,5,'#D7E2DF');
 rect(main,'Shelf / '+(row+1)+'단 선반 아래 그림자',550,y+116,408,3,'#46545F');
}
for(let i=0;i<items.length;i++){
 const [key,name,level,cap]=items[i],x=550+(i%5)*81.6,y=Y+166+Math.floor(i/5)*122;
 const selected=i===0,locked=level===0,maxed=level===cap;
 // A transparent group of physical product/label/button parts, never a card.
 const parts=[];
 parts.push(art(main,key,x+16.8,y+1,48,72,locked?.22:1));
 if(locked){
  rect(main,'Lock / '+name+' / 고리',x+34,y+33,13,13,C.ink);
  rect(main,'Lock / '+name+' / 구멍',x+37,y+36,7,10,'#C7BD9E');
  rect(main,'Lock / '+name+' / 본체',x+30,y+43,21,16,C.ink);
  rect(main,'Lock / '+name+' / 열쇠',x+39,y+47,3,7,'#D7D1B9');
 }
 if(maxed)check(main,x+60,y+8,'#326854');
 parts.push(text(main,name,x+1,y+72,80,11.5,'#4A4742',false,'center'));
 const button=rect(main,'Select / '+name+' / '+(selected?'선택':locked?'잠김':maxed?'최대':'해금됨'),x+17,y+94,48,19,C.ink);
 rect(main,'Button / 메탈 림',x+20,y+96,42,14,selected?'#F1DB95':'#D0DADB');
 rect(main,'Button / 실제 누름면',x+24,y+99,34,8,selected?'#E5B957':locked?'#73818A':'#3C5362');
 rect(main,'Button / 상태 LED',x+23,y+88,36,3,selected?'#FFF0A1':locked?'#9E6560':maxed?'#8FE1BD':'#C4E4BD');
 if(locked)text(main,'잠김',x+24,y+98,34,8,'#263C4A',false,'center');
 tiles.push(button);
}
// Information is printed on a small screen built into the lower door.
rect(main,'Info / 본체 표시창 프레임',534,Y+555,508,88,'#92A6AD',C.ink,4);
rect(main,'Info / 표시창 안쪽',542,Y+563,492,72,'#172D35');
rect(main,'Info / 표시창 상단 그림자',542,Y+563,492,4,'#0E1B23');
text(main,'물',555,Y+567,120,25,'#D5EFCD',true);
text(main,'획득 3 / 10',744,Y+576,145,15,'#A9C8BC',false,'right');
text(main,'+3 G',911,Y+566,109,28,'#F5D078',true,'right');
text(main,'발견 골드 증가',555,Y+605,300,16,'#BBD3C5');
text(main,'음료 버튼으로 능력 확인 · 구매 성공 시 자동 적용',538,Y+654,498,12,C.cream,false,'center');
// Wide delivery hatch with a deep interior, closed flap and metal lip.
rect(main,'Hatch / 고무 실링',534,Y+684,448,105,C.ink);
rect(main,'Hatch / 메탈 베젤',540,Y+690,436,93,'#A3B1BB');
rect(main,'Hatch / 안쪽 사선 그림자',547,Y+697,422,77,'#3B4A59');
rect(main,'Hatch / 어두운 배출구',557,Y+706,402,56,'#101B29');
rect(main,'Hatch / 닫힌 플랩',562,Y+706,392,32,'#263849');
rect(main,'Hatch / 플랩 반사광',562,Y+706,392,4,'#445367');
rect(main,'Hatch / 바닥 턱',552,Y+760,412,7,'#657B8C');
rect(main,'Hatch / 하단 메탈 립',545,Y+775,426,6,'#C2CFD1');
for(let i=0;i<6;i++)rect(main,'Vent / 하단 통풍구 '+i,1007,Y+697+i*12,29,5,'#622C31');
rect(main,'Service / 열쇠구멍 외곽',1012,Y+651,17,19,'#C1CACA');
rect(main,'Service / 열쇠구멍',1019,Y+656,4,10,'#354B59');
// A few paint chips follow the existing B cabinet reference.
for(const [x,y,w,h] of [[521,174,4,15],[1047,163,7,5],[523,477,7,5],[1037,603,12,4],[527,792,9,5]])rect(main,'Cabinet / 도장 마모',x,Y+y,w,h,'#CBB7A5');
rect(main,'Cabinet / 작은 서비스 라벨',548,Y+800,115,7,'#D5C5AB');
const close=rect(main,'Action / 돌아가기 · ESC',1434,Y+28,126,42,C.panel,C.muted,1);
text(main,'ESC  돌아가기',1439,Y+36,116,16,C.cream,false,'center');
text(main,'효과·획득 횟수·진행도는 시안 예시입니다.',32,Y+863,900,15,C.muted);
storage.abilityUnlock={main:main.id,page:page.id,tiles:tiles.map(s=>s.id),close:close.id};
// Compact handoff strip: static state guidance outside the game screen.
const states=page.getShapeById('e7808af8-2ea3-8077-8008-cee017d5042e');
for(const child of states.children)child.remove();
text(states,'능력 상태',32,Y+1022,900,32,C.cream,true);
const examples=[
 {x:32,title:'해금됨 · 선택',key:'water',badge:'획득 3 / 10',color:C.gold,effect:'발견 골드 증가  +3 G',hint:'상품 아래 선택 버튼 점등 · 본체 표시창 갱신'},
 {x:552,title:'미해금 · 선택',key:'cola',badge:'미해금',color:C.muted,effect:'음료 구매 성공 시 해금',hint:'흐린 상품 + 잠금 표식 · 음료 선택 버튼 비활성'},
 {x:1072,title:'강화 한도 도달',key:'lemonade',badge:'MAX',color:C.mint,effect:'강화 한도에 도달한 능력',hint:'체크 표시 + MAX · 한도 이후 보상은 미정'}
];
for(const e of examples){
 rect(states,'State / '+e.title,e.x,Y+1080,496,214,C.panel);
 text(states,e.title,e.x+20,Y+1094,450,24,e.color,true);
 art(states,e.key,e.x+16,Y+1144,60,90,e.key==='cola'?.2:1);
 if(e.key==='cola')lock(states,e.x+34,Y+1168);
 text(states,e.badge,e.x+94,Y+1148,374,22,e.color);
 text(states,e.effect,e.x+94,Y+1190,374,18,C.cream);
 text(states,e.hint,e.x+20,Y+1253,456,14,C.muted);
}
text(states,'조작: 상품 아래 버튼 선택 → 본체 표시창 갱신 / ESC → 플레이 복귀. 키보드 이동·Enter 선택은 구현 제안.',32,Y+1325,1510,18,C.muted);
text(states,'음료 15종 외형은 확정 에셋 재사용. 황금음료 효과·피버 세부 규칙·한도 이후 보상은 확정하지 않음.',32,Y+1360,1510,17,C.muted);
const title=page.getShapeById('55aeaacb-aa46-80be-8008-ceaba4e1962d');title.characters='능력 해금 · 상세 시안';
penpot.selection=[main];penpot.viewport.zoomIntoView([main]);
return {page:page.id,main:main.id,states:states.id,rough:rough.id,items:tiles.length};
