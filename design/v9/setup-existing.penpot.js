if(penpot.currentFile.id!=='cd444aaf-0d8c-801b-8008-cda246e18650')throw new Error('대상 파일 불일치');
const page=penpot.currentFile.pages.find(p=>p.id==='af2aed71-3cfe-80ea-8008-ceaf7492d553');
if(!page)throw new Error('기존 에셋 페이지 없음');await penpot.openPage(page);
let board=page.root.children.find(s=>s.getPluginData('asset-board')==='approved-drinks-v9');
const fresh=!board;
if(!board){board=penpot.createBoard();board.name='음료 마스터 · 확정 15종';board.x=0;board.y=3200;board.resize(1900,1280);board.fills=[{fillColor:'#20313B',fillOpacity:1}];board.setPluginData('asset-board','approved-drinks-v9');}
storage.v9={page,board,components:{},media:{},font:penpot.fonts.all.find(f=>f.name==='Do Hyeon')};
for(const s of board.children){const data=s.getPluginData('asset');if(data){const a=JSON.parse(data);storage.v9.components[a.key]={...a,main:s.id,component:s.component()?.id};}}
storage.v9.text=function(x,y,w,h,value,size=24,color='#E8F1E8'){
 const t=penpot.createText(value);storage.v9.font.applyToText(t,storage.v9.font.variants[0]);t.fontSize=String(size);t.growType='fixed';t.resize(w,h);t.lineHeight='1.2';t.fills=[{fillColor:color,fillOpacity:1}];t.strokes=[];t.x=board.x+x;t.y=board.y+y;t.name='Label / '+value;board.appendChild(t);return t;
};
if(fresh){storage.v9.text(64,34,1750,60,'확정 음료 에셋 · 15종',40);storage.v9.text(64,94,1750,45,'14종 승인 디자인 + 황금음료 05 오로라 골드 · 192×288 개별 투명 PNG · 각 아이템을 독립 컴포넌트로 관리',22,'#B8CED2');}
storage.v9.draw=function(a,index){
 if(storage.v9.components[a.key])return storage.v9.components[a.key];
 const media=storage.v9.media[a.key];if(!media)throw new Error('개별 PNG 업로드 필요: '+a.key);
 const image=penpot.createRectangle();image.resize(192,288);image.x=0;image.y=0;image.fills=[{fillImage:media,fillOpacity:1}];image.strokes=[];image.name='Artwork / '+a.name;
 const c=penpot.library.local.createComponent([image]);c.name=a.name;c.path='Clicker/Approved/Drinks';const main=c.mainInstance();board.appendChild(main);main.name='Drink / '+String(index+1).padStart(2,'0')+' / '+a.name;main.x=board.x+128+(index%5)*360;main.y=board.y+168+Math.floor(index/5)*338;c.name=a.name;c.path='Clicker/Approved/Drinks';main.clipContent=false;main.exports=[{type:'png',scale:1,suffix:''}];
 const info={key:a.key,name:a.name,component:c.id,main:main.id,width:192,height:288,media:media.id,status:'approved'};main.setPluginData('asset',JSON.stringify(info));
 const label=storage.v9.text(64+(index%5)*360,468+Math.floor(index/5)*338,320,48,String(index+1).padStart(2,'0')+' · '+a.name,24);label.align='center';storage.v9.components[a.key]=info;return info;
};
return {page:page.id,board:board.id,existing:Object.keys(storage.v9.components)};
