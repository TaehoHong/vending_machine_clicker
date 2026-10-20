const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');
const root = __dirname;
(async () => {
  const items = JSON.parse(await fs.readFile(path.join(root,'items.json'),'utf8'));
  await fs.mkdir(path.join(root,'exports'),{recursive:true});
  for (const item of items) {
    await sharp(path.join(root,'svg',item.key+'.svg')).png().toFile(path.join(root,'exports',item.key+'.png'));
  }
  let body='';
  for (let i=0;i<items.length;i++) {
    const item=items[i],x=128+(i%5)*360,y=168+Math.floor(i/5)*338;
    const png=await fs.readFile(path.join(root,'exports',item.key+'.png'));
    body+=`<image x="${x}" y="${y}" width="192" height="288" href="data:image/png;base64,${png.toString('base64')}"/><text x="${x+96}" y="${y+326}" text-anchor="middle" font-size="24" fill="#E8F1E8">${String(i+1).padStart(2,'0')} · ${item.name}</text>`;
  }
  const sheet=`<svg xmlns="http://www.w3.org/2000/svg" width="1900" height="1280"><rect width="1900" height="1280" fill="#20313B"/><g font-family="sans-serif"><text x="64" y="80" font-size="40" fill="#E8F1E8">확정 음료 에셋 · 15종</text><text x="64" y="130" font-size="22" fill="#B8CED2">승인 원본 아트 · 황금음료 05 오로라 골드 · 192×288 개별 투명 배경</text>${body}</g></svg>`;
  await fs.writeFile(path.join(root,'approved-items.svg'),sheet);
  await sharp(Buffer.from(sheet)).png().toFile(path.join(root,'approved-items.png'));
  const checks=[];
  for (const item of items) {
    const metadata=await sharp(path.join(root,'exports',item.key+'.png')).metadata();
    if(metadata.width!==192||metadata.height!==288||!metadata.hasAlpha)throw new Error(item.key+' canvas/alpha mismatch');
    checks.push(item.key);
  }
  console.log(JSON.stringify({verified:checks.length,canvas:[192,288],alpha:true}));
})().catch(error=>{console.error(error);process.exitCode=1;});
