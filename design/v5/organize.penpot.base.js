const assetPage=penpot.currentFile.pages.find(p=>p.id==='af2aed71-3cfe-80ea-8008-ceaf7492d553');
await penpot.openPage(assetPage);
const assetBoard=assetPage.getShapeById('af2aed71-3cfe-80ea-8008-ceb0d537ce15');
storage.v5Images={
 A:assetPage.getShapeById('af2aed71-3cfe-80ea-8008-ceb0bac8902b').fills[0].fillImage,
 B:assetPage.getShapeById('af2aed71-3cfe-80ea-8008-ceb0bac8902e').fills[0].fillImage,
 alley:assetPage.getShapeById('af2aed71-3cfe-80ea-8008-ceb0bac8ee43').fills[0].fillImage
};
for(const s of [...assetBoard.children])s.remove();
assetBoard.x=0;assetBoard.y=900;assetBoard.resize(1920,1580);
assetBoard.name='에셋 마스터 · 13개 컴포넌트';assetBoard.fills=[{fillColor:'#202E38',fillOpacity:1}];
const font=penpot.fonts.all.find(f=>f.name==='Do Hyeon');
storage.v5Parts=function(rows,parent){
 const result=[];
 for(const a of rows){
  let s;
  if(a[0]==='r'){
   s=penpot.createRectangle();s.resize(a[3],a[4]);s.x=a[1];s.y=a[2];s.fills=[{fillColor:a[5],fillOpacity:1}];
   if(a[6])s.strokes=[{strokeColor:a[6],strokeWidth:a[7],strokeAlignment:'center'}];s.name='Pixel / rectangle';
  }else if(a[0]==='p'){
   s=penpot.createPath();s.d=a[1];s.fills=[{fillColor:a[2],fillOpacity:1}];
   if(a[3])s.strokes=[{strokeColor:a[3],strokeWidth:a[4],strokeAlignment:'center'}];s.name='Pixel / path';
  }else if(a[0]==='t'){
   const size=a[3],str=a[4],w=Math.ceil([...str].reduce((v,c)=>v+(c.charCodeAt(0)>255?1.05:.67)*size,0)+16);
   s=penpot.createText(str);font.applyToText(s,font.variants[0]);s.fontSize=String(size);s.lineHeight='1.2';s.growType='fixed';s.resize(w,size*1.55);
   s.x=a[1]-(a[6]==='middle'?w/2:a[6]==='end'?w:0);s.y=a[2]-size*1.05;s.align=a[6]==='middle'?'center':a[6]==='end'?'right':'left';s.verticalAlign='top';s.strokes=[];s.fills=[{fillColor:a[5],fillOpacity:1}];s.name='Text / '+str;
   for(const [dx,dy] of [[-1.5,-1.5],[0,-1.5],[1.5,-1.5],[-1.5,0],[1.5,0],[-1.5,1.5],[0,1.5],[1.5,1.5]]){
    const shadow=s.clone();shadow.x=s.x+dx;shadow.y=s.y+dy;shadow.fills=[{fillColor:'#12121D',fillOpacity:1}];shadow.name='Outline / '+str;
    if(parent)parent.appendChild(shadow);result.push(shadow);
   }
  }
  if(s){if(parent)parent.appendChild(s);result.push(s);}
 }
 return result;
};
storage.v5Comps={};
function register(key,name,path,shapes,x,y,previewScale=1){
 const component=penpot.library.local.createComponent(shapes);component.name=name;component.path='Clicker/'+path;
 const main=component.mainInstance();const original={x:main.x,y:main.y,w:main.width,h:main.height};
 for(const t of [...main.children].filter(s=>s.type==='text'&&s.name.startsWith('Text /')))t.setParentIndex(main.children.length-1);
 assetBoard.appendChild(main);main.name='Clicker / '+path+' / '+name;main.x=x;main.y=assetBoard.y+y;
 if(previewScale!==1)main.resize(original.w*previewScale,original.h*previewScale);
 main.clipContent=false;storage.v5Comps[key]={component,original};return main;
}
function raster(key,name,path,image,x,y,w,h){
 const shape=penpot.createRectangle();shape.resize(w,h);shape.x=0;shape.y=0;shape.fills=[{fillImage:image,fillOpacity:1}];shape.name=name+' / image';
 return register(key,name,path,[shape],x,y);
}
function caption(x,y,text,size=24,color='#F2F5F0'){
 const s=penpot.createText(text);font.applyToText(s,font.variants[0]);s.fontSize=String(size);s.fills=[{fillColor:color,fillOpacity:1}];s.x=x;s.y=assetBoard.y+y;s.name='Label / '+text;assetBoard.appendChild(s);return s;
}
caption(64,28,'에셋 마스터 · 화면과 별도로 관리',34);
caption(64,78,'자판기 A/B는 같은 350×525 크기 · 모든 에셋은 Clicker 컴포넌트로 등록',21,'#B9CED7');
caption(80,125,'자판기 A · 기존안');caption(540,125,'자판기 B · 5×3 진열');caption(1000,125,'배경 · 일본풍 골목길');
raster('A','A · 기존 정면','World/Vending',storage.v5Images.A,80,180,350,525);
raster('B','B · 원본 디테일 · 5×3','World/Vending',storage.v5Images.B,540,180,350,525);
raster('alley','일본풍 골목길','World/Background',storage.v5Images.alley,1000,180,800,450);
caption(64,755,'UI · 편집 가능한 도형과 텍스트',30);
const definitions=[
 ['hud','재화 HUD','UI',23,43,80,880],['buy','능력 구매','UI',48,55,450,880],
 ['unlock','자판기 해금','UI',55,60,800,880],['upgrade','능력 강화','UI',60,65,1150,880],
 ['pause','일시정지','UI',43,48,1500,880],['coin','동전','World/Objects',28,33,80,1240,3],
 ['can','빈캔','World/Objects',14,22,450,1240,2],['bin','쓰레기통','World/Objects',5,14,800,1240,1.5],
 ['cursor','클릭 커서','FX',83,84,1150,1240,2],['spark','획득 반짝임','FX',22,23,1500,1240,3]
];
for(const [key,name,path,start,end,x,y,scale] of definitions){
 caption(x,y-48,name,22);register(key,name,path,storage.v5Parts(ROWS.slice(start,end)),x,y,scale||1);
}
caption(64,1100,'월드 오브젝트 / 클릭 피드백',30);
storage.v5AssetBoard=assetBoard;storage.v5AssetPage=assetPage;storage.v5Rows=ROWS;
penpot.selection=[assetBoard];penpot.viewport.zoomIntoView([assetBoard]);
return {page:assetPage.id,board:assetBoard.id,components:Object.entries(storage.v5Comps).map(([key,v])=>({key,id:v.component.id,main:v.component.mainInstance().id,original:v.original})),preservedNotes:assetPage.root.children.filter(s=>s.id==='bb86c7d2-8437-8019-8008-ceaff04ee08c').length};
