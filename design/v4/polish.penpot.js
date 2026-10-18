const b=storage.v4Main;
for(const s of [...b.children].filter(s=>s.name.startsWith('Shadow /')))s.remove();
for(const s of [...b.children]){
 if(s.type==='path'&&((Math.abs(s.y-646)<1&&Math.abs(s.width-310)<1)||(Math.abs(s.y-642)<1&&Math.abs(s.width-190)<1)))s.remove();
}
for(const t of b.children.filter(s=>s.type==='text'&&!s.name.startsWith('Shadow /'))){
 t.strokes=[];
 for(const [dx,dy] of [[-1.5,-1.5],[0,-1.5],[1.5,-1.5],[-1.5,0],[1.5,0],[-1.5,1.5],[0,1.5],[1.5,1.5]]){
  const s=t.clone();s.name='Shadow / '+t.characters;s.x+=dx;s.y+=dy;s.fills=[{fillColor:'#12121D',fillOpacity:1}];s.bringToFront();
 }
 t.bringToFront();
}
penpot.selection=[b];penpot.viewport.zoomIntoView([b]);
return {page:storage.v4Page.id,board:b.id,texts:b.children.filter(s=>s.type==='text'&&!s.name.startsWith('Shadow /')).map(s=>s.characters)};
