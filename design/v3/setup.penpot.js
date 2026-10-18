
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
