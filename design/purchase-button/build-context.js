const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');
const root = __dirname;
const uiFont = "'Pretendard','Apple SD Gothic Neo',sans-serif";
const gameFont = "'Cafe24 PRO UP',sans-serif";
const layout = {width:1440,height:900,scene:{x:48,y:213,width:570,height:600},price:{x:354,y:230,width:144,height:56},zoom:{x:666,y:213,width:708,height:498,source:[278,198,236,166]}};

function priceButton() {
  const outline='M8 2H136V8H142V44H136V50H8V44H2V8H8Z';
  return `<g id="price-button"><path d="${outline}" transform="translate(0 4)" fill="#132433" stroke="#10171D" stroke-width="4"/>
    <g class="price-face"><path d="${outline}" fill="#4699C8" stroke="#10171D" stroke-width="4"/>
    <path d="M10 6H134V10H138V15H134V10H10V15H6V10H10Z" fill="#9FDDFA"/>
    <path d="M6 35H10V44H134V35H138V43H134V47H10V43H6Z" fill="#28648F"/>
    <text id="price-label" x="72" y="36" text-anchor="middle" font-family="${gameFont}" font-size="28" fill="#FFF2D9" stroke="#1A3547" stroke-width="2.2" paint-order="stroke" stroke-linejoin="round">100 G</text></g></g>`;
}

function board(machineData) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1440" height="900" viewBox="0 0 1440 900" role="img" aria-label="자판기 투입구 오른쪽에 가격만 표시하는 파란 픽셀 버튼을 배치한 시안">
    <defs><g id="machine-and-price"><image id="existing-machine-b" x="28" y="34" width="350" height="525" href="data:image/png;base64,${machineData}" style="image-rendering:pixelated"/><g transform="translate(354 230)">${priceButton()}</g></g></defs>
    <rect width="1440" height="900" fill="#F2EEE5"/>
    <g font-family="${uiFont}" fill="#252B2E"><text x="48" y="54" fill="#6B6864" font-size="13" letter-spacing="2">PRICE BUTTON / PLACEMENT 03</text><text x="48" y="108" font-size="34" font-weight="800">투입구 옆, 가격만 표시</text><text x="1392" y="54" text-anchor="end" fill="#6B6864" font-size="15">1번 픽셀 스타일 · 배치 시안</text>
    <text x="48" y="143" fill="#676A69" font-size="17">기존 자판기 B · 투입구와 같은 높이 · 100 G</text>
    <text x="48" y="189" font-size="21" font-weight="700">자판기 기준 배치</text><text x="666" y="189" font-size="21" font-weight="700">결제부 확대</text>
    <rect x="48" y="213" width="570" height="600" rx="4" fill="#25323D"/>
    <g transform="translate(48 213)"><use href="#machine-and-price"/></g>
    <svg x="666" y="213" width="708" height="498" viewBox="278 198 236 166"><rect x="278" y="198" width="236" height="166" fill="#25323D"/><use href="#machine-and-price"/></svg>
    <g fill="#676A69" font-size="17"><text x="666" y="756">금속 슬릿이 동전 투입구입니다.</text><text x="666" y="788">그 오른쪽의 파란 가격 버튼을 눌러 조작합니다.</text></g>
    <path d="M48 841H1392" stroke="#D4D1C9"/><text x="48" y="875" fill="#676A69" font-size="15">금액 100 G는 예시입니다. 위치·크기 검토용 시안이며 기존 자판기 에셋은 수정하지 않았습니다.</text>
    </g></svg>`;
}

function html(svg) {
  const main={x:layout.scene.x+layout.price.x,y:layout.scene.y+layout.price.y,width:144,height:56};
  const zoom={x:894,y:309,width:432,height:168};
  const hit=(b,name)=>`<button class="price-hit" type="button" aria-label="${name}" style="left:${b.x/14.4}%;top:${b.y/9}%;width:${b.width/14.4}%;height:${b.height/9}%"></button>`;
  return `<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>투입구와 가격 버튼 · 1번 스타일</title><style>
    :root{color-scheme:light;background:#f2eee5;font-family:"Pretendard","Apple SD Gothic Neo",sans-serif;color:#252b2e}*{box-sizing:border-box}body{margin:0}main{width:min(100%,1440px);margin:auto}.artboard{position:relative;width:100%}.artboard>svg{display:block;width:100%;height:auto}.price-hit{position:absolute;border:0;background:transparent;padding:0;cursor:pointer;outline-offset:3px}.price-hit:focus-visible{outline:3px solid #f6d583}.price-face{transition:transform 90ms steps(2,end),filter 90ms ease-out}.artboard:has(.price-hit:hover) .price-face{filter:brightness(1.12)}.artboard:has(.price-hit:active) .price-face{transform:translateY(3px);transition-duration:60ms}.feedback{color:#676a69;min-height:26px;margin:0;padding:4px 3.333% 20px;font-size:14px}.artboard>svg image{image-rendering:pixelated}@media(prefers-reduced-motion:reduce){.price-face{transition:none!important}}
    </style><main><div class="artboard">${svg}${hit(main,'100 골드')}${hit(zoom,'100 골드 확대 보기')}</div><p class="feedback" aria-live="polite">파란 금액 버튼에 마우스를 올리거나 눌러 반응을 확인할 수 있습니다.</p></main><script>document.querySelectorAll('.price-hit').forEach(b=>b.addEventListener('click',()=>{document.querySelector('.feedback').textContent='버튼 반응을 확인했습니다. 표시는 100 G로 유지됩니다.';}));</script></html>`;
}

(async()=>{
  const source=path.resolve(root,'../v5/vending-machine-b-5x3-web.png');
  const image=(await fs.readFile(source)).toString('base64');
  const svg=board(image);
  await fs.writeFile(path.join(root,'placement-v3.svg'),svg);
  await sharp(Buffer.from(svg)).png().toFile(path.join(root,'placement-v3.png'));
  await fs.writeFile(path.join(root,'price-only-v3.svg'),`<svg xmlns="http://www.w3.org/2000/svg" width="144" height="56" viewBox="0 0 144 56">${priceButton()}</svg>`);
  await fs.writeFile(path.join(root,'index.html'),html(svg));
  await fs.writeFile(path.join(root,'placement-v3.json'),JSON.stringify({status:'preview-awaiting-placement-approval',style:'A / 1번 픽셀 아케이드',visibleButtonText:'100 G',actionLabel:false,sourceAsset:'design/v5/vending-machine-b-5x3-web.png',sourceAssetModified:false,layout,penpotWrites:0,penpotAccess:'MCP only'},null,2)+'\n');
  console.log(JSON.stringify({priceOnly:true,style:'A',sourceModified:false,button:[144,56],preview:[1440,900]}));
})().catch(e=>{console.error(e);process.exitCode=1;});
