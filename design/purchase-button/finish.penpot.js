// Repair only the new price-button board after checking its exported image.
const page=penpot.currentFile.pages.find(p=>p.id==='af2aed71-3cfe-80ea-8008-ceaf7492d553');
await penpot.openPage(page);
const board=page.getShapeById('8e4548c6-4cd1-8076-8008-ceef6ba14bff');
const font=penpot.fonts.findByName('Cafe24 PRO UP');
const variant=font.variants.find(v=>v.fontWeight==='400');
const bodyFont=penpot.fonts.findByName('Noto Sans KR');
const bodyVariant=bodyFont.variants.find(v=>v.fontWeight==='400');
const typography=penpot.library.local.typographies.find(t=>t.id==='8e4548c6-4cd1-8076-8008-ceef6bade547');
typography.setFont(font,variant);
const frame=board.children.find(s=>s.name==='Preview / 외곽 3배');
frame.resize(432,168);frame.x=board.x+568;frame.y=board.y+157;
const applied=[];
function apply(shape){
 if(shape.type==='text'){
  const pixel=shape.characters==='100 G'||shape.characters==='Cafe24 PRO UP'||shape.characters.startsWith('가나다');
  (pixel?font:bodyFont).applyToText(shape,pixel?variant:bodyVariant);
  applied.push({id:shape.id,text:shape.characters,fontId:shape.fontId});
 }
 for(const child of shape.children||[])apply(child);
}
apply(board);
return {board:board.id,frame:{width:frame.width,height:frame.height},font:font.fontId,applied};
