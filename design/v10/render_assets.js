// Render new SVG clipping components; original raster pixels remain unchanged.
const fs=require('fs');
const path=require('path');
const sharp=require('sharp');
const base=__dirname;
const data=JSON.parse(fs.readFileSync(path.join(base,'geometry.json'),'utf8'));
const source=fs.readFileSync(path.resolve(base,'../..',data.source)).toString('base64');
async function render(spec,folder){
  const [x,y,w,h]=spec.bounds;
  const backing=spec.restore?`<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${spec.restore}"/>`:'';
  const raster=spec.backgroundOnly?'':`<image width="1024" height="1536" href="data:image/png;base64,${source}" clip-path="url(#cut)"/>`;
  const svg=`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="${x} ${y} ${w} ${h}"><defs><clipPath id="cut"><path d="${spec.d}"/></clipPath></defs>${backing}${raster}</svg>`;
  await sharp(Buffer.from(svg)).png().toFile(path.join(base,folder,spec.key+'.png'));
}
(async()=>{
  for(const folder of ['drinks','parts'])fs.mkdirSync(path.join(base,folder),{recursive:true});
  for(const item of data.drinks)await render(item,'drinks');
  for(const item of data.parts)await render(item,'parts');
  console.log(JSON.stringify({drinks:data.drinks.length,parts:data.parts.length,method:'SVG clipping, source pixels preserved'}));
})();
