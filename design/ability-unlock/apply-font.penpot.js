// Font-only update: preserve artwork, geometry, colors and content.
const page=penpot.currentFile.pages.find(p=>p.id==='55aeaacb-aa46-80be-8008-cdca4fa29ef0');
if(penpot.currentPage.id!==page.id)return {applied:false,reason:'target-page-not-active',targetPage:page.id};
const font=penpot.fonts.findByName('Cafe24 PRO UP') || penpot.fonts.all.find(f=>/cafe24.*pro.*up/i.test(f.name));
if(!font) return {applied:false,reason:'font-not-available',matchingFonts:penpot.fonts.all.filter(f=>/cafe|pro.?up/i.test(f.name)).map(f=>({id:f.id,name:f.name}))};
const variant=font.variants.find(v=>v.fontWeight==='400') || font.variants[0];
const changed=[];
function visit(shape){
 if(shape.type==='text'){font.applyToText(shape,variant);changed.push({id:shape.id,text:shape.characters});}
 for(const child of shape.children||[])visit(child);
}
for(const id of ['e7808af8-2ea3-8077-8008-cee0143cdedc','e7808af8-2ea3-8077-8008-cee017d5042e'])visit(page.getShapeById(id));
return {applied:true,font:font.name,variant:variant.name,textNodes:changed.length,changed};
