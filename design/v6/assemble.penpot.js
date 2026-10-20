const v=storage.v6,page=v.page;await penpot.openPage(page);
function instance(key,x=0,y=0,w=null,h=null){
 const meta=v.components[key],comp=penpot.library.local.components.find(c=>c.id===meta.component),s=comp.instance();
 if(w!==null)s.resize(w,h);s.x=x;s.y=y;s.name='Part / '+key;return s;
}
for(const variant of ['closed','open','auto']){
 const bounds=penpot.createRectangle();bounds.resize(350,525);bounds.x=0;bounds.y=0;bounds.fills=[{fillColor:'#FFFFFF',fillOpacity:0}];bounds.name='Registration / 350×525';
 const shapes=[bounds,instance('b-shadow'),instance('b-body'),instance('b-display')];
 const drinks=['water','green-tea','barley-tea','ion','apple','ginger-ale','lemonade','sprite','peach-juice','orange','vitamin','melon-soda','fanta-grape','cola','energy-drink'];
 for(let i=0;i<drinks.length;i++){
  const row=Math.floor(i/5),col=i%5;
  shapes.push(instance(drinks[i],58+42*col,100+90*row,27,40.5));
  shapes.push(instance('select-button-idle',57+42*col,155+90*row,27,10.8));
 }
 shapes.push(instance('b-payment'),instance(variant==='open'?'b-hatch-open':'b-hatch-closed'));
 if(variant==='auto')shapes.push(instance('auto-marker',278,119,32,20));
 const key='b-assembly-'+variant,name='B 조립 · '+({closed:'기본 15종',open:'배출구 열림',auto:'자동 생산'}[variant]);
 v.register({key,name,category:'World/Vending/Parts',width:350,height:525,note:'Asset assembly only, not a gameplay screen. Nested instances retain editable independent items and parts.',proposal:false},shapes);
}
for(const [key,b] of Object.entries(v.boards)){
 const count=Object.values(v.components).filter(c=>b.children.some(s=>s.id===c.main)).length;
 v.text(b,b.x+64,b.y+b.height-55,b.width-128,40,'개별 컴포넌트 '+count+'개 · PNG / SVG · 기획 수치는 아트에 고정하지 않음',20,'#A9C1C8');
}
v.boards.drinks.setPluginData('asset-manifest',JSON.stringify(Object.values(v.components)));
penpot.selection=[v.boards.drinks];penpot.viewport.zoomIntoView([v.boards.drinks]);
return {page:v.page.id,components:Object.keys(v.components).length,totalLibrary:penpot.library.local.components.length,boards:Object.fromEntries(Object.entries(v.boards).map(([k,b])=>[k,{id:b.id,width:b.width,height:b.height}])),pages:penpot.currentFile.pages.map(p=>({id:p.id,name:p.name}))};
