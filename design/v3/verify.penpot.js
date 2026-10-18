const b=storage.v3Boards;
for(const key of ['12-purchased-use','14-upgraded']){
 const water=b[key].children.find(s=>s.type==='text'&&s.parentX>270&&s.parentX<400&&s.characters==='×3');
 if(water){water.characters='×2';water.name='Text / ×2';}
}
const reward=b['13-stored'].children.find(s=>s.type==='text'&&s.characters==='+50 G');
if(reward){reward.characters='콜라 +1';reward.name='Text / 콜라 +1';reward.resize(220,60);reward.x=b['13-stored'].x+572;reward.fills=[{fillColor:'#9CDEBC',fillOpacity:1}];}
const checks=Object.entries(b).map(([key,board])=>({key,id:board.id,name:board.name,shapes:board.children.length,texts:board.children.filter(s=>s.type==='text').length,links:board.children.reduce((n,s)=>n+s.interactions.length,0),width:board.width,height:board.height}));
const counts=['02-main-play','11-after-use','12-purchased-use','13-stored','14-upgraded'].map(key=>({key,values:b[key].children.filter(s=>s.type==='text'&&['36','37','12','12,480 G','12,130 G','×2','×3','×4','3회마다 동전 발견','4회마다 동전 발견'].includes(s.characters)).map(s=>({text:s.characters,x:Math.round(s.parentX),y:Math.round(s.parentY)}))}));
penpot.selection=[b['02-main-play']];penpot.viewport.zoomIntoView([b['02-main-play']]);
return {page:penpot.currentPage.id,pages:penpot.currentFile.pages.map(p=>({id:p.id,name:p.name})),boards:checks,stateChecks:counts};
