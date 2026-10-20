const fs=require('node:fs/promises');
const path=require('node:path');
const sharp=require('sharp');
const root=__dirname;
const config=require('./components.json');
const glyphs=require('./font-outlines.json');
const ink='#10171D',cream='#FFF2D9';
const uiFont="'Pretendard','Apple SD Gothic Neo',sans-serif";
const themes={
 default:{face:'#4699C8',top:'#9FDDFA',bottom:'#28648F',base:'#132433',text:cream},
 hover:{face:'#58AFDA',top:'#C0EBFF',bottom:'#317CA7',base:'#132433',text:cream},
 pressed:{face:'#3986B5',top:'#7AC4E7',bottom:'#245A80',base:'#132433',text:cream},
 disabled:{face:'#526773',top:'#8497A0',bottom:'#344751',base:'#182832',text:'#BDCCD1'},
 tab:{face:'#2B4B60',top:'#547B90',bottom:'#203747',base:'#132433',text:'#CBDDE2'}
};
const rect=(x,y,w,h,c)=>`<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${c}"/>`;
const pixelPath=(d,c,stroke=ink,sw=2)=>`<path d="${d}" fill="${c}" stroke="${stroke}" stroke-width="${sw}" stroke-linejoin="miter"/>`;
function icon(name){
 const map=pixelPath('M2 8H6V6H12V2H20V6H26V4H30V26H26V28H20V26H12V30H4V28H2Z','#F8E5AE')+rect(12,4,2,22,'#B1A16F')+rect(20,8,2,16,'#B1A16F')+rect(6,12,4,4,'#7C9B66')+rect(8,16,4,4,'#7C9B66')+rect(16,10,4,4,'#7C9B66')+rect(24,16,4,4,'#7C9B66')+pixelPath('M24 4H28V6H30V12H28V16H24V12H22V6H24Z','#F07A54')+rect(25,7,2,3,cream);
 const bottle=rect(12,1,10,5,ink)+rect(14,2,6,3,'#E0F3F3')+pixelPath('M12 6H22V10H24V14H26V29H24V31H10V29H8V14H10V10H12Z','#B9E3EA')+rect(11,15,12,12,'#3C92BB')+rect(11,15,3,12,'#68B8D8')+rect(16,18,5,3,cream)+rect(13,28,9,2,'#81BDC8')+rect(12,9,3,5,'#E7F9F8');
 const upgrade=pixelPath('M14 2H18V6H22V10H26V14H20V30H12V14H6V10H10V6H14Z','#F4C66D')+rect(14,11,3,16,'#FFF0B8')+rect(23,23,3,3,'#FFF0B8')+rect(26,20,3,3,'#FFF0B8')+rect(3,22,3,3,'#F4C66D');
 const machine=pixelPath('M6 1H26V3H28V29H26V31H6V29H4V3H6Z','#D9534D')+rect(7,4,16,15,ink)+rect(9,6,12,11,'#E9DDAE')+rect(10,8,3,5,'#6B9E68')+rect(16,8,3,5,'#66A9D0')+rect(9,15,12,2,'#A18B5E')+rect(24,9,2,5,'#F8E4A0')+rect(8,22,16,6,ink)+rect(10,23,12,2,'#56666B')+rect(7,2,17,2,'#FC9583');
 const pause=pixelPath('M6 5H12V27H6Z',cream)+pixelPath('M20 5H26V27H20Z',cream)+rect(8,7,2,16,'#FFFFFF')+rect(22,7,2,16,'#FFFFFF');
 const back=pixelPath('M14 4H18V10H28V24H24V16H18V22H14V18H10V14H6V12H10V8H14Z',cream);
 const close=pixelPath('M4 4H10V8H14V12H18V8H22V4H28V10H24V14H20V18H24V22H28V28H22V24H18V20H14V24H10V28H4V22H8V18H12V14H8V10H4Z',cream);
 const left=pixelPath('M18 4H24V10H20V14H16V18H20V22H24V28H18V24H14V20H10V16H8V14H10V12H14V8H18Z',cream);
 const right=`<g transform="translate(32 0) scale(-1 1)">${left}</g>`;
 const trash=rect(12,2,10,4,ink)+rect(14,3,6,2,'#F6D27D')+pixelPath('M4 6H28V10H26V28H24V30H8V28H6V10H4Z','#A3B2A8')+rect(7,7,18,2,'#E4E7CE')+rect(11,14,3,12,'#60796D')+rect(18,14,3,12,'#60796D')+rect(8,11,2,15,'#CBD4BE');
 const can=pixelPath('M9 2H23V4H25V28H23V30H9V28H7V4H9Z','#BBCDD2')+rect(10,3,12,3,'#EDF4E7')+rect(11,3,7,2,'#4E6571')+rect(10,10,12,12,'#7296A6')+rect(10,10,3,12,'#9EBFCB')+rect(15,13,5,6,'#E0ECE6')+rect(10,26,12,2,'#6B8590');
 const play=pixelPath('M8 3H12V5H16V9H20V11H24V15H26V17H22V21H18V23H14V27H8Z',cream)+rect(10,7,2,16,'#FFFFFF');
 const settings=pixelPath('M12 2H20V6H24V10H28V18H24V22H22V26H18V30H12V26H8V22H4V14H8V10H10V6H12Z','#C7DCE2')+pixelPath('M12 11H20V13H22V19H20V21H12V19H10V13H12Z','#3B6680')+rect(13,13,6,6,'#182F40');
 const door=pixelPath('M8 2H26V30H6V26H8Z','#C4D5D9')+rect(12,6,10,22,'#213E51')+rect(18,16,2,3,'#F4C66D')+pixelPath('M2 12H12V8H16V12H20V16H16V20H12V16H2Z',cream);
 return {map,bottle,upgrade,machine,pause,back,close,left,right,trash,can,play,settings,door}[name]||'';
}
function label(value,x,baseline,size=28,color=cream,center=false){
 if(!value)return '';
 const g=glyphs[value],s=size/28;
 if(!g)throw new Error('Missing original-font label: '+value);
 const left=center?x-g.width*s/2:x;
 return `<g transform="translate(${left} ${baseline}) scale(${s})" class="label"><path d="${g.path}" fill="none" stroke="#1A3547" stroke-width="2.2" stroke-linejoin="round"/><path d="${g.path}" fill="${color}"/></g>`;
}
function bodyPath(w,h){return `M8 2H${w-8}V8H${w-2}V${h-12}H${w-8}V${h-6}H8V${h-12}H2V8H8Z`;}
function button(c,state='default'){
 const w=c.width||176,h=c.height||64;
 if(c.disabled&&state==='default')state='disabled';
 const t=state==='default'&&c.kind==='tab'&&!c.selected?themes.tab:(themes[state]||themes.default);
 const d=bodyPath(w,h),pressed=state==='pressed'?4:0;
 let content='';
 if(c.icon&&!c.label)content=`<g class="icon" transform="translate(${(w-32)/2} ${(h-4-32)/2})">${icon(c.icon)}</g>`;
 else if(c.icon){
  const size=c.id.startsWith('tab-')?24:28;
  content=`<g class="icon" transform="translate(16 ${(h-4-32)/2})">${icon(c.icon)}</g>`+label(c.label,60,h/2+8,size,t.text);
 }else content=label(c.label,w/2,h/2+8,28,t.text,true);
 const tab=c.kind==='tab'?`<g class="selection-marker" opacity="${c.selected?1:0}">${rect(w/2-12,h-11,24,4,'#F8CF7B')}</g>`:'';
 const focus=state==='focus'?`<path d="M4 -5H${w-4}V0H${w+4}V${h-4}H${w-4}V${h+4}H4V${h-4}H-4V0H4Z" fill="none" stroke="#FFD883" stroke-width="2"/>`:'';
 return `<g class="game-art" data-state="${state}">${focus}<path class="base" d="${d}" transform="translate(0 4)" fill="${t.base}" stroke="${ink}" stroke-width="4"/>
 <g class="moving" transform="translate(0 ${pressed})"><path class="surface" d="${d}" fill="${t.face}" stroke="${ink}" stroke-width="4"/>
 <path class="highlight" d="M10 6H${w-10}V10H${w-6}V15H${w-10}V10H10V15H6V10H10Z" fill="${t.top}"/>
 <path class="bevel" d="M6 ${h-21}H10V${h-12}H${w-10}V${h-21}H${w-6}V${h-13}H${w-10}V${h-9}H10V${h-13}H6Z" fill="${t.bottom}"/>
 <g ${state==='disabled'?'opacity="0.65"':''}>${content}</g>${tab}</g></g>`;
}
function svgButton(c,state='default'){
 const w=c.width||176,h=c.height||64;
 return `<svg xmlns="http://www.w3.org/2000/svg" width="${w+12}" height="${h+12}" viewBox="-6 -6 ${w+12} ${h+12}" aria-hidden="true">${button(c,state)}</svg>`;
}
function boardStart(title,sub,height,index){
 return `<svg xmlns="http://www.w3.org/2000/svg" width="1440" height="${height}" viewBox="0 0 1440 ${height}">
 <rect width="1440" height="${height}" fill="#F3EFE5"/>
 <g font-family="${uiFont}" fill="#26353E"><text x="48" y="43" font-size="13" letter-spacing="2" fill="#687A7D">CLICKER / HUD COMPONENT REVIEW · ${index}</text>
 <text x="48" y="96" font-size="36" font-weight="800">${title}</text><text x="48" y="130" font-size="17" fill="#53646A">${sub}</text>
 <text x="1392" y="43" text-anchor="end" font-size="14" fill="#7B6750">시안 · 승인 전 미반영</text></g>`;
}
const txt=(x,y,value,size=17,color='#BECFD0',weight=400)=>`<text x="${x}" y="${y}" font-family="${uiFont}" font-size="${size}" font-weight="${weight}" fill="${color}">${value}</text>`;
const line=(y)=>`<path d="M48 ${y}H1392" stroke="#40535E"/>`;
function place(c,x,y,scale=1,state='default',active=false){
 const w=c.width||176,h=c.height||64;
 const disabled=c.disabled||state==='disabled';
 const markup=`<g transform="translate(${x} ${y}) scale(${scale})">${button(c,state)}</g>`;
 const meta={id:c.id,label:c.accessibleLabel||c.label,width:w,height:h,x,y,scale,state,disabled:!!disabled};
 if(active)hotspots.push(meta);
 return markup;
}
let hotspots=[];
function mainBoard(){
 hotspots=[];
 let s=boardStart('HUD 버튼 5종','기존 A의 파란 버튼 · 4px 외곽선 · 입체 밑면 · Cafe24 PRO UP',950,'01');
 s+=rect(48,164,1344,234,'#20313B')+txt(80,198,'플레이 중 필요한 메뉴로 들어가는 버튼',16);
 config.navigation.forEach((c,i)=>{s+=place(c,88+i*252,234,1.2,'default',true);});
 s+=txt(80,367,'아이콘 + 짧은 이름으로 구분합니다. 아래는 각 버튼이 여는 내용입니다.',16);
 config.navigation.forEach((c,i)=>{
  const y=430+i*84;
  s+=rect(48,y,1344,72,i%2?'#E5E4DA':'#EBE9E0');
  s+=`<g transform="translate(72 ${y+18}) scale(1)">${icon(c.icon)}</g>`;
  s+=txt(128,y+45,c.label,22,'#233740',700)+txt(280,y+44,c.use,18,'#4E6167');
  s+=txt(1228,y+44,'176 × 64',15,'#66797D');
 });
 s+=txt(48,914,'버튼 에셋만 검토합니다. 사이드 패널이나 새 게임 화면은 제작하지 않았습니다.',16,'#61747A');
 return {svg:s+'</svg>',hotspots:[...hotspots]};
}
function commonBoard(){
 hotspots=[];
 let s=boardStart('공통 조작과 메뉴 내부 버튼','뒤로 · 닫기 · 좌우 이동 · 탭 · 비용 · 일시정지 메뉴',1120,'02');
 s+=rect(48,164,1344,888,'#20313B');
 s+=txt(80,204,'01  뒤로 / 닫기 / 좌우 이동',20,cream,700);
 for(const [id,x] of [['back',86],['close',330],['previous',484],['next',620]]){
  const c=config.common.find(x=>x.id===id);s+=place(c,x,236,1.25,'default',true);
 }
 s+=txt(880,260,'상세에서 뒤로 · 열린 창 닫기',17)+txt(880,294,'같은 목록 안에서 이전 / 다음',17);
 s+=line(340)+txt(80,384,'02  관리 항목 탭',20,cream,700);
 s+=place(config.common.find(c=>c.id==='tab-machine'),86,416,1.1,'default',true);
 s+=place(config.common.find(c=>c.id==='tab-trash'),352,416,1.1,'default',true);
 s+=txt(880,440,'선택: 밝은 파랑 + 하단 금색 표시',17)+txt(880,474,'대기: 짙은 파랑',17);
 s+=line(524)+txt(80,568,'03  골드 / 재료 비용',20,cream,700);
 for(const [id,x] of [['price',86],['price-insufficient',300],['material-ready',520],['material-insufficient',792]]){
  const c=config.common.find(v=>v.id===id);s+=place(c,x,608,1,'default',true);
 }
 s+=txt(86,716,'골드 충분',16)+txt(300,716,'골드 부족',16)+txt(520,716,'재료 충족',16)+txt(792,716,'재료 부족',16);
 s+=txt(1072,629,'금액 · 수량만 표시',17)+txt(1072,663,'액션 문구 없음',17);
 s+=line(752)+txt(80,796,'04  메뉴 안에서 쓰는 버튼',20,cream,700);
 for(const [id,x] of [['continue',86],['settings',416],['title',746]]){
  const c=config.common.find(v=>v.id===id);s+=place(c,x,834,1.2,'default',true);
 }
 s+=txt(86,966,'계속하기: 플레이 복귀',16)+txt(416,966,'설정: 음량 · 화면 설정',16)+txt(746,966,'타이틀: 시작 화면 이동',16);
 s+=txt(48,1090,'금액과 보유 수량은 시안 예시입니다. 선택된 탭은 색상과 표시선으로 함께 구분합니다.',16,'#61747A');
 return {svg:s+'</svg>',hotspots:[...hotspots]};
}
function statesBoard(){
 hotspots=[];
 const states=[['default','기본'],['hover','호버'],['pressed','눌림'],['disabled','비활성'],['focus','키보드 포커스']];
 let s=boardStart('버튼 상태와 반응','입력 영역 고정 · 버튼 면만 이동 · 클릭 / Enter / Space 대응',1040,'03');
 s+=rect(48,164,1344,630,'#20313B');
 states.forEach(([id,name],i)=>{s+=txt(236+i*226,210,name,16,cream);});
 config.navigation.forEach((c,i)=>{
  const y=254+i*102;s+=txt(80,y+38,c.label,18,cream,700);
  states.forEach(([state],j)=>{s+=place(c,230+j*226,y,1,state,true);});
 });
 s+=rect(48,826,1344,142,'#E7E5DB')+txt(76,862,'호버 90ms',19,'#233740',700)+txt(396,862,'눌림 60ms · 면이 4px 아래로',19,'#233740',700)+txt(936,862,'복귀 100ms',19,'#233740',700);
 s+=txt(76,906,'밝기와 윗면 하이라이트 변화',17,'#4E6167')+txt(396,906,'밑면이 줄어드는 물리적인 누름감',17,'#4E6167')+txt(936,906,'원래 높이로 복귀',17,'#4E6167');
 s+=txt(48,1010,'모션 줄이기 설정에서는 전환을 끄고 상태만 즉시 바꿉니다. 비활성 버튼은 입력되지 않습니다.',16,'#61747A');
 return {svg:s+'</svg>',hotspots:[...hotspots]};
}
function interactiveSheet(board,key,hidden=false){
 const buttons=board.hotspots.map(h=>`<button class="game" type="button" data-id="${h.id}" data-forced="${h.state}" aria-label="${h.label}" ${h.disabled?'disabled':''} style="left:${h.x/14.4}%;top:${h.y/(key==='hud'?9.5:key==='common'?11.2:10.4)}%;width:${h.width*h.scale/14.4}%;height:${h.height*h.scale/(key==='hud'?9.5:key==='common'?11.2:10.4)}%" ${h.id.startsWith('tab-')?`data-tab="true" aria-pressed="${h.id==='tab-machine'}"`:''}></button>`).join('');
 return `<section id="${key}" class="sheet" ${hidden?'hidden':''} aria-label="${key==='hud'?'HUD 버튼 5종':key==='common'?'공통 버튼':'상태 비교'}"><div class="artboard">${board.svg}${buttons}</div></section>`;
}
function html(boards){
 return `<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>HUD 버튼 전체 시안 · A 픽셀</title>
 <style>:root{font-family:${uiFont};color:#233740;background:#F3EFE5;color-scheme:light}*{box-sizing:border-box}body{margin:0}header{position:sticky;top:0;background:#F3EFE5;z-index:5;border-bottom:1px solid #D4D6CE;padding:14px max(24px,calc((100vw - 1344px)/2));display:flex;align-items:center;gap:24px;flex-wrap:wrap}header p{font-size:14px;margin:0;color:#53646A}nav{display:flex;gap:6px}nav button{font:600 15px ${uiFont};border:1px solid #BBC6C5;color:#40565D;background:transparent;padding:9px 15px;cursor:pointer}nav button[aria-pressed=true]{color:#FFF2D9;background:#233B49;border-color:#233B49}nav button:focus-visible{outline:3px solid #947126;outline-offset:3px}main{width:min(100%,1440px);margin:auto}.artboard{position:relative}.artboard>svg{display:block;width:100%;height:auto}.game{position:absolute;padding:0;border:0;background:transparent;cursor:pointer;border-radius:0;outline-offset:5px;touch-action:manipulation}.game:disabled{cursor:not-allowed}.game:focus-visible{outline:3px solid #F4C66D}.moving{transition:transform 100ms steps(2,end)}.surface,.highlight{transition:fill 90ms linear}.feedback{padding:16px 3.33%;min-height:54px;margin:0;font-size:15px;color:#40565D;border-top:1px solid #D4D6CE}.hint{color:#7B6750;margin-left:auto}@media(max-width:650px){header{gap:10px;padding:12px 16px}nav button{font-size:13px;padding:9px 10px}.hint{display:none}}@media(prefers-reduced-motion:reduce){.moving,.surface,.highlight{transition:none!important}}
 </style><header><nav aria-label="시안 시트 선택"><button type="button" data-sheet="hud" aria-pressed="true">HUD 5종</button><button type="button" data-sheet="common" aria-pressed="false">공통 버튼</button><button type="button" data-sheet="states" aria-pressed="false">상태·반응</button></nav><p>버튼에 마우스를 올리거나 눌러보세요. Tab · Enter · Space로도 확인할 수 있습니다.</p><p class="hint">승인 전 · Penpot 미반영</p></header>
 <main>${interactiveSheet(boards[0],'hud')}${interactiveSheet(boards[1],'common',true)}${interactiveSheet(boards[2],'states',true)}<p class="feedback" aria-live="polite">외형과 반응 검토용 시안입니다. 실제 게임 기능은 실행하지 않습니다.</p></main>
 <script>
 const feedback=document.querySelector('.feedback');const base=new WeakMap();
 document.querySelectorAll('[data-sheet]').forEach(b=>b.addEventListener('click',()=>{document.querySelectorAll('.sheet').forEach(s=>s.hidden=s.id!==b.dataset.sheet);document.querySelectorAll('[data-sheet]').forEach(x=>x.setAttribute('aria-pressed',String(x===b)));feedback.textContent=b.textContent+' 시안입니다. 버튼에 마우스를 올리거나 눌러 반응을 확인하세요.';}));
 document.querySelectorAll('.sheet').forEach(sheet=>{const arts=[...sheet.querySelectorAll('.game-art')];sheet.querySelectorAll('.game').forEach((b,i)=>{const art=arts[i],moving=art.querySelector('.moving'),surface=art.querySelector('.surface'),highlight=art.querySelector('.highlight');const original={fill:surface.getAttribute('fill'),top:highlight.getAttribute('fill'),transform:moving.getAttribute('transform')};base.set(art,original);const restore=()=>{const v=base.get(art);moving.setAttribute('transform',v.transform);surface.setAttribute('fill',v.fill);highlight.setAttribute('fill',v.top);};b.addEventListener('pointerenter',()=>{if(b.disabled)return;surface.setAttribute('fill','#58AFDA');highlight.setAttribute('fill','#C0EBFF');});b.addEventListener('pointerleave',restore);const press=()=>{if(b.disabled)return;moving.style.transitionDuration='60ms';moving.setAttribute('transform','translate(0 4)');surface.setAttribute('fill','#3986B5');};const release=()=>{moving.style.transitionDuration='100ms';restore();};b.addEventListener('pointerdown',press);b.addEventListener('pointerup',release);b.addEventListener('pointercancel',release);b.addEventListener('blur',release);b.addEventListener('keydown',e=>{if(['Enter',' '].includes(e.key)){if(e.key===' ')e.preventDefault();press();}});b.addEventListener('keyup',e=>{if(['Enter',' '].includes(e.key)){release();if(e.key===' ')b.click();}});b.addEventListener('click',()=>{feedback.textContent=b.getAttribute('aria-label')+' 버튼의 반응을 확인했습니다. 실제 게임 동작은 실행하지 않습니다.';if(b.dataset.id.startsWith('tab-')){sheet.querySelectorAll('[data-tab]').forEach(t=>{const selected=t===b;t.setAttribute('aria-pressed',String(selected));const idx=[...sheet.querySelectorAll('.game')].indexOf(t);const a=arts[idx];const fill=selected?'#4699C8':'#2B4B60',top=selected?'#9FDDFA':'#547B90';a.querySelector('.surface').setAttribute('fill',fill);a.querySelector('.highlight').setAttribute('fill',top);a.querySelector('.bevel').setAttribute('fill',selected?'#28648F':'#203747');a.querySelector('.selection-marker').setAttribute('opacity',selected?'1':'0');base.set(a,{fill,top,transform:'translate(0 0)'});});}});});});
 </script></html>`;
}
(async()=>{
 await fs.mkdir(path.join(root,'exports'),{recursive:true});await fs.mkdir(path.join(root,'icons'),{recursive:true});
 const assets=[...config.navigation,...config.common];
 for(const c of assets)for(const state of config.states)await fs.writeFile(path.join(root,'exports',`${c.id}-${state}.svg`),svgButton(c,state));
 const iconNames=[...new Set(assets.map(c=>c.icon).filter(Boolean))];
 for(const name of iconNames)await fs.writeFile(path.join(root,'icons',name+'.svg'),`<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">${icon(name)}</svg>`);
 const boards=[mainBoard(),commonBoard(),statesBoard()];
 for(const [i,board] of boards.entries()){
  const name=['01-hud','02-common','03-states'][i];
  await fs.writeFile(path.join(root,name+'.svg'),board.svg);await sharp(Buffer.from(board.svg)).png().toFile(path.join(root,name+'.png'));
 }
 const page=html(boards);await fs.writeFile(path.join(root,'index.html'),page);
 const current=path.join(root,'../purchase-button/index.html'),backup=path.join(root,'../purchase-button/placement-v3.html');
 try{await fs.access(backup);}catch{await fs.copyFile(current,backup);}
 await fs.writeFile(current,page);
 await fs.writeFile(path.join(root,'manifest.json'),JSON.stringify({status:config.status,penpotWrites:0,fullGameScreensCreated:0,font:config.font,labelsOutlined:true,exportPaddingPx:6,navCount:config.navigation.length,commonCount:config.common.length,svgCount:assets.length*config.states.length,iconCount:iconNames.length,states:config.states,motion:config.motion,preview:'http://127.0.0.1:8878/',sheets:boards.map((b,i)=>({file:['01-hud','02-common','03-states'][i]+'.png',interactiveButtons:b.hotspots.length})),numbersIllustrative:true},null,2)+'\n');
 console.log(JSON.stringify({navigation:config.navigation.length,common:config.common.length,svgAssets:assets.length*config.states.length,icons:iconNames.length,penpotWrites:0}));
})().catch(e=>{console.error(e);process.exitCode=1;});
