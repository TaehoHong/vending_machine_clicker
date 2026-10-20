// Run only through the user-authorized Penpot MCP connection.
// Idempotent: existing asset page and a stable plugin key; never create a page.
const fileId='cd444aaf-0d8c-801b-8008-cda246e18650';
const pageId='af2aed71-3cfe-80ea-8008-ceaf7492d553';
const key='price-button-a-100g-v1';
if(penpot.currentFile?.id!==fileId)throw new Error('대상 파일 불일치');
const page=penpot.currentFile.pages.find(p=>p.id===pageId);
if(!page)throw new Error('기존 02 에셋 페이지를 찾을 수 없습니다');
await penpot.openPage(page);
const font=penpot.fonts.all.find(f=>/Cafe24\s*PRO\s*UP/i.test(f.name));
if(!font)return {status:'font-required',page:page.id,font:'Cafe24 PRO UP',created:false};
const labelFont=penpot.fonts.all.find(f=>f.name==='Noto Sans KR')||font;
let board=page.root.children.find(s=>s.getPluginData('asset-board')===key);
if(board?.getPluginData('complete'))return JSON.parse(board.getPluginData('complete'));
if(board)throw new Error('이 가격 버튼 보드의 미완료 작업을 먼저 확인해야 합니다');
board=penpot.createBoard();board.name='UI 마스터 · 가격 버튼 A';board.resize(1120,500);board.x=0;
board.y=Math.max(0,...page.root.children.filter(s=>s.id!==board.id).map(s=>s.y+s.height))+160;
board.fills=[{fillColor:'#20313B',fillOpacity:1}];board.setPluginData('asset-board',key);
const variant=font.variants.find(v=>String(v.fontWeight)==='400')||font.variants[0];
let typography=penpot.library.local.typographies.find(t=>t.getPluginData('asset-key')==='price-cafe24-28');
if(!typography){typography=penpot.library.local.createTypography();typography.name='Price · Cafe24 PRO UP · 28';typography.path='Clicker/UI/Pixel';typography.setFont(font,variant);typography.fontSize='28';typography.fontWeight='400';typography.lineHeight='1';typography.letterSpacing='0';typography.setPluginData('asset-key','price-cafe24-28');}
function text(value,x,y,w,h,size=20,color='#E8F1E8',display=false){
 const t=penpot.createText(value);(display?font:labelFont).applyToText(t,display?variant:labelFont.variants[0]);t.fontSize=String(size);t.growType='fixed';t.resize(w,h);t.lineHeight='1.2';t.fills=[{fillColor:color,fillOpacity:1}];t.strokes=[];t.x=board.x+x;t.y=board.y+y;t.name='Label / '+value;board.appendChild(t);return t;
}
text('가격 버튼 · 1번 픽셀 스타일',48,32,1000,48,30);
text('금액만 표시 · 원본 144 × 56 · Cafe24 PRO UP',48,86,1000,36,18,'#B8CED2');
const d='M8 2H136V8H142V44H136V50H8V44H2V8H8Z';
function price(scale,x,y){
 const frame=penpot.createShapeFromSvg(`<svg xmlns="http://www.w3.org/2000/svg" width="${144*scale}" height="${56*scale}" viewBox="0 0 144 56"><path d="${d}" transform="translate(0 4)" fill="#132433" stroke="#10171D" stroke-width="4"/><path d="${d}" fill="#4699C8" stroke="#10171D" stroke-width="4"/><path d="M10 6H134V10H138V15H134V10H10V15H6V10H10Z" fill="#9FDDFA"/><path d="M6 35H10V44H134V35H138V43H134V47H10V43H6Z" fill="#28648F"/></svg>`);
 if(!frame)throw new Error('가격 버튼 외형 생성 실패');frame.name='Frame / 파란 픽셀 외곽';frame.x=board.x+x;frame.y=board.y+y;board.appendChild(frame);
 const amount=text('100 G',x,y+6*scale,144*scale,40*scale,28*scale,'#FFF2D9',true);amount.name='Amount / 100 G';amount.align='center';amount.verticalAlign='center';amount.lineHeight='1';amount.strokes=[{strokeColor:'#1A3547',strokeWidth:2.2*scale,strokeAlignment:'center'}];
 if(scale===1)amount.setPluginData('typography-reference',typography.id);
 return {frame,amount};
}
const original=price(1,64,176);
const component=penpot.library.local.createComponent([original.frame,original.amount]);
component.name='가격 버튼 · A · 100 G';component.path='Clicker/UI/Price';
const main=component.mainInstance();board.appendChild(main);main.x=board.x+64;main.y=board.y+176;
main.exports=[{type:'svg',scale:1,suffix:''},{type:'png',scale:1,suffix:''}];
main.setPluginData('asset-key',key);main.setPluginData('value','100 G');
text('원본 · 재사용 컴포넌트',48,258,340,32,18,'#B8CED2');
const large=price(3,568,157);large.frame.resize(432,168);large.frame.x=board.x+568;large.frame.y=board.y+157;large.frame.name='Preview / 외곽 3배';large.amount.name='Preview / 100 G 3배';
text('3배 미리보기',568,340,490,34,18,'#B8CED2');
text('Cafe24 PRO UP',48,330,450,44,28,'#E8F1E8',true);
text('가나다  ABC  0123456789',48,384,470,42,22,'#E8F1E8',true);
text('텍스트 스타일: Clicker / UI / Pixel',48,448,1000,30,17,'#B8CED2');
// Apply fonts after geometry and text styling: Penpot's imported text can retain
// an earlier font run when these operations are interleaved during creation.
typography.setFont(font,variant);
const labelVariant=labelFont.variants.find(v=>String(v.fontWeight)==='400')||labelFont.variants[0];
function applyFonts(s){if(s.type==='text'){const pixel=s.characters==='100 G'||s.characters==='Cafe24 PRO UP'||s.characters.startsWith('가나다');(pixel?font:labelFont).applyToText(s,pixel?variant:labelVariant);}for(const ch of s.children||[])applyFonts(ch);}
applyFonts(board);
const result={status:'complete',file:fileId,page:page.id,board:board.id,component:component.id,main:main.id,amount:original.amount.id,typography:typography.id,font:{name:font.name,id:font.fontId||font.id},visibleText:'100 G',originalSize:{width:main.width,height:main.height}};
board.setPluginData('complete',JSON.stringify(result));penpot.selection=[board];penpot.viewport.zoomIntoView([board]);return result;
