if(penpot.currentFile.id!=='cd444aaf-0d8c-801b-8008-cda246e18650')throw new Error('대상 파일 불일치');
const page=penpot.createPage();page.name='03 · 개별 에셋 · 심플 아이템·피버';await penpot.openPage(page);
storage.v6={page,boards:{},components:{},font:penpot.fonts.all.find(f=>f.name==='Do Hyeon')};
storage.v6.text=function(parent,x,y,w,h,value,size=24,color='#E8F1E8'){
 const t=penpot.createText(value);storage.v6.font.applyToText(t,storage.v6.font.variants[0]);t.fontSize=String(size);t.growType='fixed';t.resize(w,h);t.lineHeight='1.25';t.fills=[{fillColor:color,fillOpacity:1}];t.strokes=[];t.x=x;t.y=y;t.name='Label / '+value.split('\n')[0];if(parent)parent.appendChild(t);return t;
};
const specs=[
 ['drinks','01 · 심플 음료 15종',0,0,1900,1100,'32×48 논리 픽셀 · 대표색 + 작은 표식 1개 · 진열·획득·목록에 재사용'],
 ['goods','02 · 상품·해금 재료',2200,0,1900,860,'상품 4계열 / 재료 5종 · 재료별 지역 매핑은 제안 · 별도 사용 버튼 없음'],
 ['parts','03 · 자판기 B 부품·조립',0,1450,2300,2250,'350×525 공통 캔버스 · 본체·진열·결제·배출·그림자 분리 · 기존 A/B 보존'],
 ['world','04 · 자판기 계열·자동 생산·회수',2600,1250,1900,1470,'라멘·잡지·피규어·피자 기본 외형 / 쓰레기통·생산 상태 · 지역별 스킨은 미정'],
 ['fx','05 · 수색·펀치·획득·회수 FX',0,4000,1900,1100,'프레임별 개별 컴포넌트 · 동일 캔버스·중심점 · 프레임 순서와 제안 시간은 motion.json'],
 ['ui','06 · 능력·피버·해금·버튼 상태',2200,3200,1900,1450,'금액 ×2와 클릭 ×2 구분 · 효과·시간·가격은 별도 편집 텍스트 · 화면 조립 없음']
];
for(const [key,name,x,y,w,h,note] of specs){const b=penpot.createBoard();b.name=name;b.x=x;b.y=y;b.resize(w,h);b.fills=[{fillColor:'#20313B',fillOpacity:1}];storage.v6.boards[key]=b;storage.v6.text(b,x+64,y+35,w-128,55,name,36);storage.v6.text(b,x+64,y+96,w-128,55,note,22,'#B7CED2');}
storage.v6.place=function(a){
 const k=a.category.startsWith('Items/Drinks')?'drinks':a.category.startsWith('Items/')?'goods':a.category==='World/Vending/Parts'?'parts':a.category.startsWith('World/')?'world':a.category.startsWith('FX/')?'fx':'ui';
 const b=storage.v6.boards[k];let i=b.getPluginData('count');i=i?Number(i):0;b.setPluginData('count',String(i+1));
 let cols=5,pitch=360,row=220,start=170;
 if(k==='drinks'){row=285;}
 if(k==='goods'){row=285;}
 if(k==='parts'){pitch=440;row=660;start=180;}
 if(k==='world'){
  if(a.category==='World/Vending/Families'){const j=Number(b.getPluginData('machine-count')||0);b.setPluginData('machine-count',String(j+1));return {board:b,x:b.x+70+j*450,y:b.y+180,labelX:b.x+70+j*450,labelY:b.y+725,labelW:350};}
  const j=Number(b.getPluginData('state-count')||0);b.setPluginData('state-count',String(j+1));return {board:b,x:b.x+95+j*295,y:b.y+970,labelX:b.x+64+j*295,labelY:b.y+1120,labelW:265};
 }
 const col=i%cols,r=Math.floor(i/cols),left=64+col*pitch;
 return {board:b,x:b.x+left+(pitch-40-a.width)/2,y:b.y+start+r*row,labelX:b.x+left,labelY:b.y+start+r*row+(k==='parts'?545:k==='drinks'?165:k==='goods'?130:110),labelW:pitch-40};
};
storage.v6.register=function(a,shapes){
 const slot=storage.v6.place(a),component=penpot.library.local.createComponent(shapes),main=component.mainInstance();
 slot.board.appendChild(main);main.name='Clicker / V6 / '+a.category.replaceAll('/',' / ')+' / '+a.name;main.x=slot.x;main.y=slot.y;main.clipContent=false;
 main.setPluginData('asset',JSON.stringify({key:a.key,category:a.category,canvas:[a.width,a.height],note:a.note,proposal:a.proposal}));
 const label=storage.v6.text(slot.board,slot.labelX,slot.labelY,slot.labelW,70,a.name,23);label.align='center';
 storage.v6.components[a.key]={key:a.key,name:a.name,category:a.category,component:component.id,main:main.id,width:a.width,height:a.height,note:a.note,proposal:a.proposal,export:'exports/'+a.key+'.png',svg:'svg/'+a.key+'.svg'};
 return storage.v6.components[a.key];
};
storage.v6.draw=function(a){
 const bounds=penpot.createRectangle();bounds.resize(a.width,a.height);bounds.x=0;bounds.y=0;bounds.fills=[{fillColor:'#FFFFFF',fillOpacity:0}];bounds.strokes=[];bounds.name='Registration / '+a.width+'×'+a.height;const shapes=[bounds];
 for(let j=0;j<a.shapes.length;j++){
  const p=a.shapes[j];let s;
  if(p[0]==='r'||p[0]==='e'){
   if(p[3]<=0||p[4]<=0)continue;s=p[0]==='r'?penpot.createRectangle():penpot.createEllipse();s.resize(p[3],p[4]);s.x=p[1];s.y=p[2];s.fills=[{fillColor:p[5],fillOpacity:1}];
  }else if(p[0]==='p'){s=penpot.createPath();s.d=p[1];s.fills=[{fillColor:p[2],fillOpacity:1}];}
  else {s=storage.v6.text(null,p[1],p[2],p[3],p[4],p[5],p[6],p[7]);}
  s.strokes=[];s.name=(p[0]==='t'?'Editable label':'Pixel part')+' / '+j;shapes.push(s);
 }
 return storage.v6.register(a,shapes);
};
return {page:page.id,boards:Object.fromEntries(Object.entries(storage.v6.boards).map(([k,b])=>[k,b.id])),preservedPages:penpot.currentFile.pages.filter(p=>p.id!==page.id).map(p=>({id:p.id,name:p.name}))};
