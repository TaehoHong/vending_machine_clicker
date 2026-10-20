const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');
const root = __dirname;
const textFont = "'Pretendard','Apple SD Gothic Neo',sans-serif";
const gameFont = "'배달의민족 주아','BM JUA ',sans-serif";
const pixelFont = "'Cafe24 PRO UP',sans-serif";
const concepts = [
  {key:'a',name:'픽셀 아케이드',description:'계단 모서리 · 굵은 먹선 · 선명한 파랑',motion:'6px 눌림 · 짧고 단단한 복귀',bg:'#25323D',accent:'#87CBEA'},
  {key:'b',name:'카툰 팝',description:'과장된 두께 · 둥근 글자 · 노란 버튼',motion:'8px 눌림 · 가벼운 탄성',bg:'#3C302C',accent:'#F6CB67'},
  {key:'c',name:'레트로 자판기',description:'크림색 외장 · 가격창 · 빨간 누름판',motion:'빨간 누름판만 6px 이동',bg:'#34373A',accent:'#F0B09A'},
];

function pixelCoin(x,y,size=1) {
  return `<g transform="translate(${x} ${y}) scale(${size})" shape-rendering="crispEdges"><path d="M-8-12H8V-8H12V8H8V12H-8V8H-12V-8H-8Z" fill="#EBAF3E" stroke="#352B28" stroke-width="3"/><path d="M-6-9H6V-6H9V3H6V-6H-6Z" fill="#FFE6A0"/><path d="M-2-5H3V-2H0V3H3V6H-3V3H-5V-2H-2Z" fill="#9F612B"/></g>`;
}

function arcade(pressed) {
  const d='M24 34H388V42H396V114H388V122H24V114H16V42H24Z';
  return `<path d="${d}" transform="translate(0 10)" fill="#122331" stroke="#10171D" stroke-width="6" stroke-linejoin="miter"/>
    <g class="press-face" transform="translate(0 ${pressed?6:0})">
    <path d="${d}" fill="#4699C8" stroke="#10171D" stroke-width="6" stroke-linejoin="miter"/>
    <path d="M28 39H384V45H390V54H384V46H28V54H22V45H28Z" fill="#9FDDFA"/>
    <path d="M22 99H28V112H384V99H390V111H384V117H28V111H22Z" fill="#28648F"/>
    <text x="116" y="96" font-family="${pixelFont}" font-size="44" text-anchor="middle" fill="#10171D" stroke="#10171D" stroke-width="5" paint-order="stroke">구매</text>
    <text x="116" y="92" font-family="${pixelFont}" font-size="44" text-anchor="middle" fill="#F7F3DF">구매</text>
    <path d="M222 51H374V57H380V100H374V106H222V100H216V57H222Z" fill="#DDEBEE" stroke="#142C3B" stroke-width="4"/>
    <path d="M224 56H372" stroke="#FAFCF4" stroke-width="4"/>
    ${pixelCoin(240,79,.8)}
    <text x="294" y="91" font-family="${pixelFont}" font-size="32" text-anchor="middle" fill="#203949">100</text><text x="351" y="89" font-family="${pixelFont}" font-size="22" text-anchor="middle" fill="#203949">G</text>
    </g>`;
}

function cartoon(pressed) {
  const d='M35 31L382 27Q401 27 398 46L390 109Q388 124 369 125L31 129Q11 129 15 109L22 47Q24 32 35 31Z';
  return `<path d="${d}" transform="translate(0 10)" fill="#8E4E2B" stroke="#2E211D" stroke-width="6"/>
    <g class="press-face" transform="translate(0 ${pressed?8:0})">
    <path d="${d}" fill="#FFC64D" stroke="#2E211D" stroke-width="6"/>
    <path d="M37 39L379 35Q391 34 390 44L389 48L40 49Z" fill="#FFE89A"/>
    <path d="M23 109L378 106L376 116L31 121Q23 121 23 115Z" fill="#E59B32"/>
    <path d="M43 60L51 54L50 67Z" fill="#FFECAA"/>
    <text x="113" y="95" font-family="${gameFont}" font-size="49" text-anchor="middle" fill="#36241E">구매</text>
    <g transform="rotate(-2 296 78)"><rect x="219" y="47" width="159" height="60" rx="13" fill="#FFF1D1" stroke="#4A3223" stroke-width="4"/>
    <circle cx="244" cy="77" r="13" fill="#EDAC3E" stroke="#5A3924" stroke-width="2.5"/><path d="M244 69L247 74L252 77L247 80L244 85L241 80L236 77L241 74Z" fill="#FFF0AA"/>
    <text x="302" y="92" font-family="${gameFont}" font-size="38" text-anchor="middle" fill="#3A2820">100</text><text x="355" y="88" font-family="${gameFont}" font-size="24" text-anchor="middle" fill="#6B482D">G</text></g>
    </g>`;
}

function vending(pressed) {
  return `<rect x="16" y="38" width="384" height="98" rx="20" fill="#8E8980" stroke="#22272B" stroke-width="5"/>
    <rect x="16" y="25" width="384" height="99" rx="20" fill="#EFE7D5" stroke="#22272B" stroke-width="5"/>
    <path d="M37 33H379" stroke="#FFF9E8" stroke-width="5" stroke-linecap="round"/>
    <path d="M29 104Q31 116 42 116H374" fill="none" stroke="#C4BAA8" stroke-width="4"/>
    <rect x="29" y="45" width="152" height="58" rx="7" fill="#202F35" stroke="#8B897F" stroke-width="3"/>
    <path d="M37 51H173" stroke="#0E1C22" stroke-width="3"/>
    ${pixelCoin(49,75,.7)}
    <text x="108" y="88" font-family="${pixelFont}" font-size="32" text-anchor="middle" fill="#F8D179">100</text><text x="158" y="86" font-family="${pixelFont}" font-size="20" text-anchor="middle" fill="#F8D179">G</text>
    <rect x="197" y="44" width="188" height="72" rx="14" fill="#803528" stroke="#3A2827" stroke-width="4"/>
    <g class="press-face" transform="translate(0 ${pressed?6:0})"><rect x="197" y="34" width="188" height="72" rx="14" fill="#D95D46" stroke="#3A2827" stroke-width="4"/>
    <path d="M213 41H367" stroke="#F59A78" stroke-width="5" stroke-linecap="round"/>
    <path d="M211 95H370" stroke="#BA4236" stroke-width="4" stroke-linecap="round"/>
    <text x="291" y="88" font-family="${gameFont}" font-size="46" text-anchor="middle" fill="#86352A">구매</text><text x="291" y="85" font-family="${gameFont}" font-size="46" text-anchor="middle" fill="#FFF2D8">구매</text>
    </g>`;
}

function art(key,pressed=false) {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 416 148" width="416" height="148" aria-hidden="true">${key==='a'?arcade(pressed):key==='b'?cartoon(pressed):vending(pressed)}</svg>`;
}

function sheet() {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1520" height="748" viewBox="0 0 1520 748"><rect width="1520" height="748" fill="#F2EEE5"/><g font-family="${textFont}">
    <text x="64" y="55" font-size="13" fill="#6B6864" letter-spacing="2">PURCHASE BUTTON / DIRECTION 02</text><text x="64" y="108" font-size="34" font-weight="800" fill="#252B2E">구매 버튼 · 세 가지 새 방향</text><text x="1456" y="55" font-size="15" text-anchor="end" fill="#6B6864">외형 비교 · 승인 전</text>
    ${concepts.map((c,i)=>`<g transform="translate(${64+i*488} 0)"><text x="0" y="181" font-size="22" font-weight="800" fill="#252B2E">${c.key.toUpperCase()} · ${c.name}</text><text x="0" y="214" font-size="16" fill="#676A69">${c.description}</text><rect x="0" y="239" width="416" height="338" rx="4" fill="${c.bg}"/>
      <text x="24" y="274" font-size="13" fill="#C0C3BE">기본</text><g transform="translate(0 275)">${art(c.key)}</g><text x="24" y="443" font-size="13" fill="#C0C3BE">눌림</text><g transform="translate(0 433)">${art(c.key,true)}</g>
      <text x="0" y="620" font-size="17" font-weight="600" fill="#414847">${c.motion}</text></g>`).join('')}
    <path d="M64 658H1456" stroke="#D4D1C9"/><text x="64" y="701" font-size="16" fill="#676A69">가격 100 G는 비교용 예시입니다. 외형을 선택한 뒤 호버·골드 부족·구매 중 상태를 전개합니다.</text></g></svg>`;
}

function html() {
  return `<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>게임 구매 버튼 · 새 방향 3종</title><style>
    :root{color-scheme:light;font-family:"Pretendard","Apple SD Gothic Neo",sans-serif;background:#f2eee5;color:#252b2e}*{box-sizing:border-box}body{margin:0}main{max-width:1520px;margin:auto;padding:38px 46px 28px}.eyebrow{font:12px Arial,sans-serif;letter-spacing:2px;color:#6b6864}header{display:flex;align-items:start;justify-content:space-between;gap:20px}h1{font-size:32px;font-weight:800;letter-spacing:-.7px;margin:17px 0 0}header>span{font-size:14px;color:#6b6864;white-space:nowrap}.concepts{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:36px;margin-top:38px}h2{font-size:22px;font-weight:800;margin:0 0 12px}article>p{font-size:15px;line-height:1.5;color:#676a69;margin:0 0 20px}.stage{padding:18px 0 4px;background:var(--stage);border-radius:4px}.state-label{color:#c0c3be;font-size:12px;margin-left:22px}.game-button{display:block;width:100%;aspect-ratio:416/148;background:none;border:0;padding:0;cursor:pointer;outline-offset:-10px;border-radius:12px;-webkit-tap-highlight-color:transparent}.game-button:focus-visible{outline:3px solid #fff3af}.game-button svg,.pressed-preview svg{display:block;width:100%;height:auto}.press-face{transition:transform 120ms cubic-bezier(.2,.8,.2,1),filter 100ms}.game-button:hover .press-face{filter:brightness(1.09)}.game-button:active .press-face{transform:translateY(var(--travel));transition-duration:60ms}.concept-a .press-face{transition-timing-function:steps(2,end)}.concept-b .press-face{transition-timing-function:cubic-bezier(.34,1.56,.64,1)}.pressed-preview{margin-top:8px}.pressed-preview svg{opacity:.98}.motion{margin-top:18px!important;margin-bottom:0!important;color:#414847!important;font-weight:600}.click-status{min-height:24px;margin:12px 0 0;font-size:14px;color:#636965}footer{border-top:1px solid #d4d1c9;padding-top:20px;margin-top:20px;font-size:13px;color:#676a69;line-height:1.7}footer a{color:#3c6177;text-underline-offset:3px}footer .refs{margin-top:8px}@media(max-width:1050px){main{padding:30px}.concepts{gap:20px}h2{font-size:19px}article>p{font-size:13px}h1{font-size:29px}}@media(max-width:760px){main{padding:26px 20px}.concepts{grid-template-columns:1fr;gap:32px;max-width:450px;margin:32px auto 0}header{display:block}header>span{display:block;margin-top:16px}h1{font-size:27px}h2{font-size:22px}article>p{font-size:15px}}@media(prefers-reduced-motion:reduce){.press-face{transition:none!important}}
  </style><main><header><div><div class="eyebrow">PURCHASE BUTTON / DIRECTION 02</div><h1>구매 버튼 · 세 가지 새 방향</h1></div><span>외형 비교 · 승인 전</span></header><section class="concepts" aria-label="게임 구매 버튼 외형 세 가지">
    ${concepts.map(c=>`<article class="concept-${c.key}" style="--stage:${c.bg};--travel:${c.key==='b'?8:6}px"><h2>${c.key.toUpperCase()} · ${c.name}</h2><p>${c.description}</p><div class="stage"><div class="state-label">직접 눌러보기</div><button class="game-button" type="button" aria-label="${c.name} 버튼 눌러보기" data-concept="${c.key}">${art(c.key)}</button><div class="pressed-preview"><div class="state-label">눌림</div>${art(c.key,true)}</div></div><p class="motion">${c.motion}</p><p class="click-status" aria-live="polite"></p></article>`).join('')}
    </section><footer>가격 100 G는 비교용 예시입니다. 외형을 선택한 뒤 호버·골드 부족·구매 중 상태를 전개합니다. 버튼은 마우스와 Enter·Space로 눌러볼 수 있습니다.<div class="refs">확인한 실제 게임 UI: <a href="https://store.steampowered.com/app/3946950/Click_the_Button/" target="_blank" rel="noreferrer">Click the Button</a> · <a href="https://store.steampowered.com/app/2379780/Balatro/" target="_blank" rel="noreferrer">Balatro</a></div></footer></main><script>document.querySelectorAll('.game-button').forEach(button=>{button.addEventListener('click',()=>{const status=button.closest('article').querySelector('.click-status');status.textContent=button.dataset.concept.toUpperCase()+' 버튼을 눌렀습니다.';});});</script></html>`;
}

(async()=>{
  await fs.mkdir(path.join(root,'concepts-v2'),{recursive:true});
  for(const c of concepts)for(const state of ['idle','pressed'])await fs.writeFile(path.join(root,'concepts-v2',c.key+'-'+state+'.svg'),art(c.key,state==='pressed'));
  const svg=sheet();await fs.writeFile(path.join(root,'directions-v2.svg'),svg);await sharp(Buffer.from(svg)).png().toFile(path.join(root,'directions-v2.png'));
  await fs.writeFile(path.join(root,'index.html'),html());
  console.log(JSON.stringify({concepts:3,statesPerConcept:2,approval:'pending',penpotWrites:0}));
})().catch(e=>{console.error(e);process.exitCode=1;});
