const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');
const root = __dirname;
const font = "'Apple SD Gothic Neo','Noto Sans KR',sans-serif";
const states = [
  { key:'idle', title:'기본', caption:'가격과 구매 동작을 또렷하게', detail:'구매 가능한 상태', top:'#304237', bottom:'#1D2D25', edge:'#738373', ink:'#F1F1DF', lamp:'#B4D986' },
  { key:'hover', title:'호버', caption:'테두리와 표시등만 밝아짐', detail:'마우스를 올렸을 때', top:'#3A503E', bottom:'#263B2D', edge:'#B7D98F', ink:'#FFFFEE', lamp:'#D3F2AC' },
  { key:'pressed', title:'눌림', caption:'버튼 면이 2px 안쪽으로', detail:'입력 영역의 크기는 유지', top:'#203225', bottom:'#16251C', edge:'#7C9A6A', ink:'#E3EBD8', lamp:'#A4C77F' },
  { key:'insufficient', title:'골드 부족', caption:'이유를 글자로 함께 표시', detail:'보유 60 G · 40 G 부족', top:'#2D3531', bottom:'#222B27', edge:'#56645B', ink:'#B9C3B9', lamp:'#5D6A60' },
  { key:'processing', title:'구매 중', caption:'투입 표시가 차례로 점등', detail:'가격은 같은 위치에 유지', top:'#293C30', bottom:'#1C2E23', edge:'#779568', ink:'#CEDBC8', lamp:'#C9E79C' },
];

function button(s, prefix) {
  const down = s.key === 'pressed' ? 2 : 0;
  const disabled = s.key === 'insufficient';
  const busy = s.key === 'processing';
  const action = disabled ? '골드 부족' : busy ? '투입 중' : '구매';
  const coin = disabled ? '#9CA991' : '#DFC47C';
  return `<svg xmlns="http://www.w3.org/2000/svg" width="312" height="88" viewBox="0 0 312 88" class="state-art state-${s.key}" aria-hidden="true">
    <defs><linearGradient id="${prefix}-face" x1="0" y1="0" x2="0" y2="1"><stop stop-color="${s.top}"/><stop offset="1" stop-color="${s.bottom}"/></linearGradient></defs>
    <g id="housing"><rect x="0" y="4" width="312" height="84" rx="7" fill="#080F0B"/><rect x=".75" y=".75" width="310.5" height="82.5" rx="6.25" fill="#101B14" stroke="${s.edge}" stroke-width="1.5"/>
    <path d="M8 3H304" stroke="${s.key==='hover'?'#CEE6B0':'#8F9F86'}" stroke-opacity=".45"/><path d="M8 82H304" stroke="#050C08"/>
    </g>
    <g id="face" transform="translate(0 ${down})"><rect x="4" y="4" width="304" height="74" rx="3" fill="url(#${prefix}-face)"/><path d="M8 5H304" stroke="#CFDCC2" stroke-opacity="${s.key==='pressed'?'.05':'.17'}"/><path d="M8 77H304" stroke="#060F09" stroke-opacity=".7"/>
    <path d="M158 18V64" stroke="#0B180F"/><path d="M159 18V64" stroke="#B6C9A9" stroke-opacity=".12"/>
    <g id="price" fill="${s.ink}" font-family="${font}"><circle cx="27" cy="41" r="10" fill="none" stroke="${coin}" stroke-width="1.5"/><path d="M30 38A4 4 0 1 0 30 44V41H27" fill="none" stroke="${coin}" stroke-width="1.3" stroke-linecap="round"/><text x="48" y="54" font-family="'DIN Alternate','Arial',sans-serif" font-weight="700" font-size="34">100</text><text x="114" y="52" font-size="16" font-weight="700" fill="${coin}">G</text></g>
    <g id="action" font-family="${font}" fill="${s.ink}">
      ${busy ? '' : `<circle cx="${disabled?189:211}" cy="41" r="3.5" fill="${s.lamp}"/>${disabled?'':`<circle cx="211" cy="40" r="1.5" fill="#F2FFD8" fill-opacity=".5"/>`}`}
      <text x="${disabled?244:busy?234:251}" y="${busy?45:50}" font-size="${disabled?18:busy?19:21}" font-weight="700" text-anchor="middle">${action}</text>
      ${busy ? [0,1,2].map(i=>`<rect class="chase chase-${i}" x="${216+i*14}" y="56" width="9" height="3" rx="1" fill="${s.lamp}" fill-opacity="${i===0?1:i===1?.5:.2}"/>`).join('') : ''}
    </g></g>
  </svg>`;
}

function sheet() {
  const columns=states.map((s,i)=>`<g transform="translate(${64+i*330} 0)">
    <text x="0" y="248" fill="#8D9E91" font-size="13" letter-spacing="2">0${i+1}</text>
    <text x="28" y="249" fill="#EAF0E3" font-size="21" font-weight="700">${s.title}</text>
    <g transform="translate(0 282)">${button(s,`sheet-${s.key}`)}</g>
    <text x="0" y="411" fill="${s.key==='insufficient'?'#D3B5A5':'#C4D0C0'}" font-size="17" font-weight="500">${s.caption}</text>
    <text x="0" y="443" fill="#98AA9B" font-size="15">${s.detail}</text>
  </g>`).join('');
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1760" height="708" viewBox="0 0 1760 708">
    <rect width="1760" height="708" fill="#17211C"/>
    <g font-family="${font}">
    <text x="64" y="51" font-family="'Arial',sans-serif" fill="#A7C589" font-size="12" font-weight="700" letter-spacing="2.5">VENDING MACHINE / UI 01</text>
    <text x="64" y="112" fill="#F1F2E6" font-size="38" font-weight="700">구매 버튼 · 가격표</text>
    <text x="64" y="153" fill="#A4B39F" font-size="18">얇은 금속 프레임 · 눌리는 버튼 면 · 고정된 가격 · 작은 상태등</text>
    <text x="1696" y="51" text-anchor="end" fill="#A4B39F" font-size="15">시안 01 · 승인 전</text>
    <path d="M64 190H1696" stroke="#344539"/>
    ${columns}
    <path d="M64 505H1696" stroke="#344539"/>
    <text x="64" y="559" fill="#DCE5D3" font-size="18" font-weight="700">모션</text>
    <text x="64" y="598" fill="#A4B39F" font-size="17">호버 120ms</text><text x="260" y="598" fill="#A4B39F" font-size="17">눌림 70ms · 복귀 110ms</text><text x="618" y="598" fill="#A4B39F" font-size="17">투입 표시 600ms 반복</text>
    <text x="1696" y="598" text-anchor="end" fill="#A4B39F" font-size="16">버튼 312 × 88 · 가격은 예시</text>
    <text x="64" y="661" fill="#8FA18F" font-size="15">5개는 동일한 버튼의 상태입니다. 색상과 함께 문구·깊이·표시등으로 구분합니다.</text>
    </g></svg>`;
}

function html() {
  const stateGrid=states.map((s,i)=>`<article class="sample"><h2><small>0${i+1}</small>${s.title}</h2>${button(s,`card-${s.key}`)}<p>${s.caption}</p><span>${s.detail}</span></article>`).join('');
  return `<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>구매 버튼 · 시안 01</title>
  <style>
    :root{color-scheme:dark;--bg:#17211c;--ink:#f1f2e6;--muted:#a4b39f;--line:#344539;font-family:"Apple SD Gothic Neo","Noto Sans KR",sans-serif}
    *{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink)}main{max-width:1800px;margin:auto;padding:48px 48px 38px}.eyebrow{color:#a7c589;font:700 12px Arial,sans-serif;letter-spacing:2.5px}.heading{display:flex;justify-content:space-between;gap:24px;align-items:start}h1{margin:22px 0 16px;font-size:38px;letter-spacing:-.7px}.subtitle{margin:0;color:var(--muted);font-size:18px;line-height:1.6}.draft{color:var(--muted);white-space:nowrap;font-size:14px;margin-top:1px}.states{display:grid;grid-template-columns:repeat(5,312px);justify-content:space-between;gap:40px 20px;border-block:1px solid var(--line);padding:46px 0 44px;margin-top:32px}.sample h2{font-size:20px;margin:0 0 24px;font-weight:700}.sample h2 small{color:#8d9e91;font-size:12px;letter-spacing:1px;margin-right:12px}.sample p{font-size:16px;color:#c4d0c0;margin:24px 0 10px}.sample span{color:#98aa9b;font-size:14px}.sample svg{display:block}.sample:has(.state-insufficient) p{color:#d3b5a5}.demo{padding-top:34px;display:grid;grid-template-columns:minmax(240px,1fr) minmax(320px,1fr);gap:40px}.demo h2{font-size:22px;margin:0 0 12px}.demo p{color:var(--muted);line-height:1.7;margin:0}.controls{display:flex;gap:24px;margin-top:24px;flex-wrap:wrap}.controls label{display:flex;align-items:center;gap:8px;font-size:15px;color:#d3dfc9;cursor:pointer}.controls input{accent-color:#a7c589;width:16px;height:16px}.live{padding-top:4px}#purchase{padding:0;border:0;width:312px;height:88px;display:block;position:relative;background:none;cursor:pointer;border-radius:7px;outline-offset:5px}#purchase:focus-visible{outline:2px solid #d2e6b0}#purchase[disabled]{cursor:not-allowed}#purchase[data-state=processing]{cursor:progress}.live .state-art{position:absolute;inset:0;opacity:0;transition:opacity 110ms ease-out;pointer-events:none}#purchase .state-idle{opacity:1}#purchase:not([disabled]):hover .state-idle{opacity:0}#purchase:not([disabled]):hover .state-hover{opacity:1;transition-duration:120ms}#purchase:not([disabled]):active .state-idle,#purchase:not([disabled]):active .state-hover{opacity:0;transition-duration:70ms}#purchase:not([disabled]):active .state-pressed{opacity:1;transition-duration:70ms}#purchase[data-state=insufficient] .state-idle,#purchase[data-state=processing] .state-idle{opacity:0}#purchase[data-state=insufficient] .state-insufficient,#purchase[data-state=processing] .state-processing{opacity:1}.feedback{min-height:48px;margin-top:14px!important;font-size:15px}#purchase[data-state=processing] .chase{animation:chase 600ms infinite steps(1,end)}#purchase[data-state=processing] .chase-1{animation-delay:200ms}#purchase[data-state=processing] .chase-2{animation-delay:400ms}@keyframes chase{0%,32%{fill-opacity:1}33%,100%{fill-opacity:.2}}footer{margin-top:34px;padding-top:22px;border-top:1px solid var(--line);color:#8fa18f;font-size:13px;line-height:1.8}.timing{display:flex;gap:30px;flex-wrap:wrap;font-size:14px;margin-bottom:10px}
    @media(max-width:1720px){.states{grid-template-columns:repeat(3,312px);justify-content:start;gap:40px 28px}}
    @media(max-width:1080px){main{padding:32px}.states{grid-template-columns:repeat(2,312px);justify-content:space-between}.demo{gap:28px}}
    @media(max-width:730px){main{padding:26px 20px}.heading{display:block}.draft{margin-top:18px}h1{font-size:30px}.states{grid-template-columns:312px;justify-content:center}.demo{grid-template-columns:1fr}.live{justify-self:center}.subtitle{font-size:16px}}
    @media(prefers-reduced-motion:reduce){.live .state-art{transition:none}#purchase[data-state=processing] .chase{animation:none}}
  </style>
  <main><div class="heading"><header><div class="eyebrow">VENDING MACHINE / UI 01</div><h1>구매 버튼 · 가격표</h1><p class="subtitle">얇은 금속 프레임 · 눌리는 버튼 면 · 고정된 가격 · 작은 상태등</p></header><span class="draft">시안 01 · 승인 전</span></div>
    <section class="states" aria-label="구매 버튼의 다섯 가지 상태">${stateGrid}</section>
    <section class="demo" aria-labelledby="demo-heading"><div><h2 id="demo-heading">직접 눌러보기</h2><p>마우스를 올리거나 버튼을 눌러 상태 전환을 확인하세요.<br>Tab 키로 이동하고 Enter 또는 Space로도 누를 수 있습니다.</p><div class="controls" role="group" aria-label="보유 골드 예시"><label><input type="radio" name="wallet" value="ready" checked>보유 160 G</label><label><input type="radio" name="wallet" value="insufficient">보유 60 G</label></div></div><div class="live"><button id="purchase" type="button" data-state="idle" aria-label="100 골드로 구매">${states.map(s=>button(s,`live-${s.key}`)).join('')}</button><p class="feedback" id="feedback" aria-live="polite">100 G로 구매할 수 있습니다.</p></div></section>
    <footer><div class="timing"><span>호버 120ms</span><span>눌림 70ms · 복귀 110ms</span><span>투입 표시 600ms 반복</span></div>가격·보유량과 720ms의 구매 중 연출은 시안 확인용입니다. 실제 골드·능력·구매 결과와 연결되지 않습니다.</footer>
  </main><script>
    const purchase=document.querySelector('#purchase'),feedback=document.querySelector('#feedback'),wallet=[...document.querySelectorAll('[name=wallet]')];let busy=false;
    function refresh(){const low=wallet.some(x=>x.checked&&x.value==='insufficient');purchase.dataset.state=busy?'processing':low?'insufficient':'idle';purchase.disabled=busy||low;purchase.setAttribute('aria-busy',String(busy));purchase.setAttribute('aria-label',busy?'100 골드 투입 중':low?'골드 부족. 100 골드 필요, 보유 60 골드':'100 골드로 구매');feedback.textContent=busy?'동전을 투입하고 있습니다.':low?'보유 60 G · 40 G 부족':'100 G로 구매할 수 있습니다.';}
    wallet.forEach(x=>x.addEventListener('change',refresh));purchase.addEventListener('click',()=>{if(busy)return;const restoreFocus=document.activeElement===purchase;busy=true;wallet.forEach(x=>x.disabled=true);refresh();setTimeout(()=>{busy=false;wallet.forEach(x=>x.disabled=false);refresh();if(restoreFocus&&document.activeElement===document.body)purchase.focus({preventScroll:true});},720);});
  </script></html>`;
}

(async()=>{
  await fs.mkdir(path.join(root,'states'),{recursive:true});
  for(const s of states){const svg=button(s,`export-${s.key}`);await fs.writeFile(path.join(root,'states',s.key+'.svg'),svg);}
  const svg=sheet();await fs.writeFile(path.join(root,'states.svg'),svg);
  await sharp(Buffer.from(svg)).png().toFile(path.join(root,'states.png'));
  await fs.writeFile(path.join(root,'index.html'),html());
  console.log(JSON.stringify({states:states.length,button:[312,88],sheet:[1760,708],status:'draft-awaiting-approval'}));
})().catch(e=>{console.error(e);process.exitCode=1;});
