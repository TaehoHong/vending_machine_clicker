const p=penpot.currentFile.pages.find(p=>p.id==='af2aed71-3cfe-80ea-8008-ceaf7492d553');
const b=p.getShapeById('8e4548c6-4cd1-8076-8008-ceef6ba14bff');
const m=p.getShapeById('8e4548c6-4cd1-8076-8008-ceef6c0920ba');
const a=p.getShapeById(JSON.parse(b.getPluginData('complete')).amount);
const c=penpot.library.local.components.find(c=>c.id==='8e4548c6-4cd1-8076-8008-ceef6c094af7');
const t=penpot.library.local.typographies.find(t=>t.id==='8e4548c6-4cd1-8076-8008-ceef6bade547');
const texts=[];
function scan(s){if(s.type==='text')texts.push({text:s.characters,fontId:s.fontId,size:s.fontSize,weight:s.fontWeight,fill:s.fills,strokes:s.strokes});for(const ch of s.children||[])scan(ch);}
scan(b);
return {page:p.id,board:b.name,size:{width:m.width,height:m.height},amount:{type:a.type,name:a.name,rendering:JSON.parse(b.getPluginData('complete')).amountRendering},component:{name:c.name,path:c.path},typography:{name:t.name,path:t.path,fontId:t.fontId,fontSize:t.fontSize},sameBoardCount:p.root.children.filter(s=>s.getPluginData('asset-board')==='price-button-a-100g-v1').length,originalBoardsRetained:['af2aed71-3cfe-80ea-8008-ceb0d537ce15','d7a10464-8e4d-803c-8008-ceb58be78642','e7808af8-2ea3-8077-8008-cedf2d6bd36f'].every(id=>!!p.getShapeById(id)),texts};
