const page=penpot.createPage();page.name='v4 · 사이드 패널 없는 플레이';await penpot.openPage(page);storage.v4Page=page;
const b=penpot.createBoard();b.name='메인 · 자판기 아래에서 동전 줍기';b.resize(1600,900);b.x=0;b.y=0;b.clipContent=true;b.fills=[{fillColor:'#202A32',fillOpacity:1}];
const font=penpot.fonts.all.find(f=>f.name==='Do Hyeon');
for(let i=0;i<ROWS.length;i++){
 const a=ROWS[i];let s;
 if(a[0]==='r'){
  s=penpot.createRectangle();s.resize(a[3],a[4]);s.x=a[1];s.y=a[2];s.fills=[{fillColor:a[5],fillOpacity:1}];if(a[6])s.strokes=[{strokeColor:a[6],strokeWidth:a[7],strokeAlignment:'center'}];s.name='Field / rect '+i;
 }else if(a[0]==='p'){
  s=penpot.createPath();s.d=a[1];s.fills=[{fillColor:a[2],fillOpacity:1}];if(a[3])s.strokes=[{strokeColor:a[3],strokeWidth:a[4],strokeAlignment:'center'}];s.name='Pixel shape / '+i;
 }else if(a[0]==='i'){
  s=penpot.createRectangle();s.resize(a[3],a[4]);s.x=a[1];s.y=a[2];s.fills=[{fillOpacity:1,fillImage:a[5]==='alley'?storage.v4Alley:storage.v4Image}];s.name=a[5]==='alley'?'Background / 일본풍 골목길':a[3]>200?'Sprite / 수동 자판기':'Sprite / 자동 자판기';if(a[5]==='alley')s.strokes=[{strokeColor:'#12121D',strokeWidth:8,strokeAlignment:'center'}];
 }else{
  const size=a[3],str=a[4];s=penpot.createText(str);font.applyToText(s,font.variants[0]);s.fontSize=String(size);s.lineHeight='1.2';s.fills=[{fillColor:a[5],fillOpacity:1}];s.strokes=[{strokeColor:'#12121D',strokeWidth:a[7],strokeAlignment:'outer'}];
  const w=Math.ceil([...str].reduce((v,c)=>v+(c.charCodeAt(0)>255?1.05:.67)*size,0)+16);s.growType='fixed';s.resize(w,size*1.55);s.x=a[1]-(a[6]==='middle'?w/2:a[6]==='end'?w:0);s.y=a[2]-size*1.05;s.align=a[6]==='middle'?'center':a[6]==='end'?'right':'left';s.verticalAlign='top';s.name='Text / '+str;
 }
 b.appendChild(s);
}
storage.v4Main=b;penpot.selection=[b];penpot.viewport.zoomIntoView([b]);
return {page:page.id,board:b.id,shapes:b.children.length};
