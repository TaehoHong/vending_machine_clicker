const boards=storage.v3Boards,main=boards['02-main-play'];
// Static post-use state makes the resource/effect sequence reviewable.
const used=main.clone();used.name='11 · 콜라 사용 후';used.x=2260;used.y=3150;boards['11-after-use']=used;
const replace=(b,from,to)=>b.children.filter(s=>s.type==='text'&&s.characters===from).forEach(s=>{s.characters=to;s.name='Text / '+to;});
replace(used,'36','37');replace(used,'×3','×2');replace(used,'보유 3개  ·  클릭 횟수 감소','보유 2개  ·  클릭 횟수 감소');replace(used,'4회마다 동전 발견','3회마다 동전 발견');replace(used,'동전 찾기  3 / 4   [SPACE]','동전 찾기  0 / 3   [SPACE]');replace(used,'콜라 한 캔으로 더 빠르게','콜라 사용 완료!');replace(used,'음료를 사용하면 능력이 올라갑니다.','클릭 4회 → 3회  ·  빈캔 +1');replace(used,'보유 콜라 사용하기','콜라 한 개 더 사용하기');
const reward=used.children.find(s=>s.type==='text'&&s.characters==='+50 G');reward.characters='빈캔 +1';reward.name='Text / 빈캔 +1';reward.resize(220,60);reward.x=used.x+572;reward.fills=[{fillColor:'#9CDEBC',fillOpacity:1}];
const cells=used.children.filter(s=>s.name.includes('/ rect')&&Math.abs(s.parentY-695)<1&&Math.abs(s.height-14)<1).sort((a,b)=>a.x-b.x);
cells.forEach((s,i)=>{if(i===3)s.remove();else{s.x=used.x+477+i*54;s.fills=[{fillColor:'#111A30',fillOpacity:1}];}});
for(const key of ['04-item-result','04b-miss-result'])replace(boards[key],'12,480 G','12,130 G');
replace(boards['04-item-result'],'×3','×4');replace(boards['04-item-result'],'보유 3','보유 4');
const purchasedUse=used.clone();purchasedUse.name='12 · 획득 음료 사용 후';purchasedUse.x=4010;purchasedUse.y=3150;boards['12-purchased-use']=purchasedUse;
replace(purchasedUse,'12,480 G','12,130 G');purchasedUse.children.find(s=>s.type==='text'&&s.characters==='×2'&&s.parentX<270).characters='×3';replace(purchasedUse,'보유 2개  ·  클릭 횟수 감소','보유 3개  ·  클릭 횟수 감소');
const stored=main.clone();stored.name='13 · 획득 음료 보관 후';stored.x=0;stored.y=4200;boards['13-stored']=stored;
replace(stored,'12,480 G','12,130 G');replace(stored,'×3','×4');replace(stored,'보유 3개  ·  클릭 횟수 감소','보유 4개  ·  클릭 횟수 감소');replace(stored,'콜라 한 캔으로 더 빠르게','가방에 보관했어요');replace(stored,'음료를 사용하면 능력이 올라갑니다.','콜라 +1  ·  아직 빈캔으로 바뀌지 않았어요.');
const upgraded=used.clone();upgraded.name='14 · 클릭 능력 강화 후';upgraded.x=1750;upgraded.y=4200;boards['14-upgraded']=upgraded;
replace(upgraded,'37','12');upgraded.children.find(s=>s.type==='text'&&s.characters==='×2'&&s.parentX<270).characters='×3';replace(upgraded,'보유 2개  ·  클릭 횟수 감소','보유 3개  ·  클릭 횟수 감소');replace(upgraded,'콜라 사용 완료!','클릭 능력 강화 완료!');replace(upgraded,'클릭 4회 → 3회  ·  빈캔 +1','빈캔 24개 사용  ·  클릭 4회 → 3회');replace(upgraded,'빈캔 +1','강화 완료');replace(upgraded,'콜라 한 개 더 사용하기','보유 콜라 사용하기');
const links=[];
function link(b,label,dest){
 const texts=b.children.filter(s=>s.type==='text'&&s.characters===label);
 if(!texts.length)throw Error('Missing control: '+b.name+' / '+label);
 for(const t of texts){
  const action={type:'navigate-to',destination:dest,animation:{type:'dissolve',duration:200,easing:'ease-out'}};
  t.addInteraction('click',action);
  const cx=t.x+t.width/2,cy=t.y+t.height/2;
  b.children.filter(s=>s.type!=='text'&&s.name.includes('/ rect')&&s.height>=24&&s.height<=100&&s.width<=800&&cx>=s.x&&cx<=s.x+s.width&&cy>=s.y&&cy<=s.y+s.height).forEach(s=>s.addInteraction('click',action));
  links.push({from:b.name,label,to:dest.name});
 }
}
const core=['02-main-play','03-vending-purchase','05-collection','06-upgrades','07-automation','11-after-use'];
for(const key of core){const b=boards[key];
 for(const [label,dest] of [['구매','03-vending-purchase'],['강화','06-upgrades'],['자동화','07-automation'],['수집함','05-collection']])if(key!==dest)link(b,label,boards[dest]);
 link(b,'일시정지  II',boards['08-pause']);
 const hit=penpot.createRectangle();hit.name='Hit target / 음료 자판기';hit.resize(280,432);hit.x=b.x+418;hit.y=b.y+202;hit.fills=[{fillColor:'#FFFFFF',fillOpacity:.001}];b.appendChild(hit);hit.addInteraction('click',{type:'navigate-to',destination:boards['03-vending-purchase'],animation:{type:'dissolve',duration:200,easing:'ease-out'}});
}
link(main,'보유 콜라 사용하기',used);link(main,'자판기에서 뽑기 · 350 G',boards['03-vending-purchase']);
link(boards['03-vending-purchase'],'350 G 투입 · 콜라 뽑기',boards['04-item-result']);
link(boards['04-item-result'],'바로 사용',purchasedUse);link(boards['04-item-result'],'가방에 보관',stored);link(boards['04-item-result'],'다시 뽑기 · 350 G',boards['03-vending-purchase']);link(boards['04-item-result'],'골목으로  [ESC]',stored);
link(boards['04b-miss-result'],'350 G · 다시 뽑기',boards['03-vending-purchase']);link(boards['04b-miss-result'],'골목으로 돌아가기  [ESC]',main);
link(boards['05-collection'],'콜라 1개 사용하기',used);link(boards['06-upgrades'],'빈캔 24개 · 강화',upgraded);link(boards['07-automation'],'생산 능력 강화',boards['06-upgrades']);
link(boards['01-title'],'이어하기',main);link(boards['01-title'],'새 게임',main);link(boards['01-title'],'설정',boards['08-pause']);link(boards['08-pause'],'계속하기  [ESC]',main);link(boards['08-pause'],'타이틀로',boards['01-title']);
for(const b of [purchasedUse,stored,upgraded]){link(b,'일시정지  II',boards['08-pause']);link(b,'구매',boards['03-vending-purchase']);link(b,'강화',boards['06-upgrades']);link(b,'자동화',boards['07-automation']);link(b,'수집함',boards['05-collection']);}
penpot.currentPage.createFlow('골목 자판기 · PC 화면 흐름',boards['01-title']);penpot.currentPage.createFlow('모바일 · 메인 화면',boards['10-mobile-play']);penpot.currentPage.createFlow('꽝 결과 예시',boards['04b-miss-result']);
storage.v3Links=links;
penpot.selection=[main];penpot.viewport.zoomIntoView([main]);
return {boards:Object.entries(boards).map(([key,b])=>({key,id:b.id,name:b.name,width:b.width,height:b.height})),links:links.length};
