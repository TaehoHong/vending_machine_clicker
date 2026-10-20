// Analyze source silhouettes and author native SVG paths; source artwork is unchanged.
const fs=require('node:fs/promises');
const path=require('node:path');
const sharp=require('sharp');
const root=__dirname;
function simplify(points,tolerance){
 if(points.length<3)return points;
 const a=points[0],b=points.at(-1),dx=b[0]-a[0],dy=b[1]-a[1],length=dx*dx+dy*dy;
 let far=0,index=0;
 for(let i=1;i<points.length-1;i++){
  const p=points[i],t=length?Math.max(0,Math.min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dy)/length)):0;
  const distance=(p[0]-a[0]-t*dx)**2+(p[1]-a[1]-t*dy)**2;
  if(distance>far){far=distance;index=i;}
 }
 if(far<=tolerance*tolerance)return [a,b];
 return [...simplify(points.slice(0,index+1),tolerance).slice(0,-1),...simplify(points.slice(index),tolerance)];
}
(async()=>{
 const items=JSON.parse(await fs.readFile(path.join(root,'items.json'),'utf8'));
 const images={};
 for(const [key,file] of [['sheet','approved-drinks-sheet.png'],['gold','gold-aurora-approved.png']])images[key]=await sharp(path.join(root,'source',file)).removeAlpha().raw().toBuffer({resolveWithObject:true});
 for(const item of items){
  const {data,info}=images[item.source],bb=item.sourceBounds,pad=8;
  const x0=Math.max(0,Math.floor(bb[0]-pad)),y0=Math.max(0,Math.floor(bb[1]-pad));
  const w=Math.min(info.width-x0,Math.ceil(bb[2]+pad*2)),h=Math.min(info.height-y0,Math.ceil(bb[3]+pad*2));
  const pixel=(x,y)=>{const i=((y0+y)*info.width+x0+x)*3;return [data[i],data[i+1],data[i+2]];};
  const corners=[pixel(0,0),pixel(w-1,0),pixel(0,h-1),pixel(w-1,h-1)];
  const background=[0,1,2].map(c=>corners.reduce((sum,p)=>sum+p[c],0)/4);
  const near=(x,y)=>pixel(x,y).reduce((sum,v,c)=>sum+(v-background[c])**2,0)<64**2;
  const exterior=new Uint8Array(w*h),queue=[];
  function add(x,y){if(x<0||y<0||x>=w||y>=h)return;const i=y*w+x;if(!exterior[i]&&near(x,y)){exterior[i]=1;queue.push(i);}}
  for(let x=0;x<w;x++){add(x,0);add(x,h-1);}for(let y=0;y<h;y++){add(0,y);add(w-1,y);}
  for(let q=0;q<queue.length;q++){const i=queue[q],x=i%w,y=Math.floor(i/w);add(x-1,y);add(x+1,y);add(x,y-1);add(x,y+1);}
  const seen=new Uint8Array(w*h);let biggest=[];
  for(let start=0;start<seen.length;start++)if(!exterior[start]&&!seen[start]){
   const part=[start];seen[start]=1;
   for(let q=0;q<part.length;q++){const i=part[q],x=i%w,y=Math.floor(i/w);for(const [nx,ny] of [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]){if(nx<0||ny<0||nx>=w||ny>=h)continue;const ni=ny*w+nx;if(!exterior[ni]&&!seen[ni]){seen[ni]=1;part.push(ni);}}}
   if(part.length>biggest.length)biggest=part;
  }
  const originalInside=new Set(biggest);
  if(item.source==='gold'){
   biggest=biggest.filter(i=>{const x=i%w+x0,y=Math.floor(i/w)+y0;return y<985||y<=1028-24*((x-628)/200)**2;});
  }else{
   biggest=biggest.filter(i=>{const x=i%w,y=Math.floor(i/w);return x>0&&y>0&&x<w-1&&y<h-1&&[i-1,i+1,i-w,i+w].every(j=>originalInside.has(j));});
  }
  const inside=new Set(biggest),edges=new Map();
  const filled=(x,y)=>x>=0&&y>=0&&x<w&&y<h&&inside.has(y*w+x);
  const edge=(a,b)=>{const k=a.join(',');if(!edges.has(k))edges.set(k,[]);edges.get(k).push(b);};
  for(const i of biggest){const x=i%w,y=Math.floor(i/w);if(!filled(x,y-1))edge([x,y],[x+1,y]);if(!filled(x+1,y))edge([x+1,y],[x+1,y+1]);if(!filled(x,y+1))edge([x+1,y+1],[x,y+1]);if(!filled(x-1,y))edge([x,y+1],[x,y]);}
  const loops=[];
  while(edges.size){const key=edges.keys().next().value,start=key.split(',').map(Number),loop=[start];let current=start;
   for(let n=0;n<w*h*4;n++){const k=current.join(','),list=edges.get(k);if(!list?.length)break;const next=list.pop();if(!list.length)edges.delete(k);loop.push(next);current=next;if(current[0]===start[0]&&current[1]===start[1])break;}
   if(loop.length>3)loops.push(loop);
  }
  const area=p=>Math.abs(p.reduce((sum,a,i)=>{const b=p[(i+1)%p.length];return sum+a[0]*b[1]-b[0]*a[1];},0));
  loops.sort((a,b)=>area(b)-area(a));let polygon=loops[0];
  if(!polygon)throw new Error('Missing silhouette '+item.key);
  polygon=polygon.map(([x,y])=>[x+x0,y+y0]);
  const half=Math.floor(polygon.length/2),tolerance=item.source==='gold'?0.8:0.4;
  polygon=[...simplify(polygon.slice(0,half+1),tolerance).slice(0,-1),...simplify(polygon.slice(half),tolerance)];
  const xs=polygon.map(p=>p[0]),ys=polygon.map(p=>p[1]);const minX=Math.min(...xs),minY=Math.min(...ys),maxX=Math.max(...xs),maxY=Math.max(...ys);
  if(maxX-minX<bb[2]*0.75||maxY-minY<bb[3]*0.75)throw new Error('Incomplete silhouette '+item.key);
  item.d=polygon.map((p,i)=>(i?'L':'M')+p.join(' ')).join(' ')+' Z';item.sourceBounds=[minX,minY,maxX-minX,maxY-minY];
  item.maskMethod='native vector silhouette traced from source; source pixels unchanged';
  console.log(item.key,polygon.length+' vertices');
 }
 await fs.writeFile(path.join(root,'items.json'),JSON.stringify(items,null,2)+'\n');
 for(const item of items){
  const [x,y,w,h]=item.sourceBounds,s=item.scale,dx=(192-w*s)/2-x*s,dy=264-h*s-y*s;
  const file=item.source==='sheet'?'approved-drinks-sheet.png':'gold-aurora-approved.png',image=await fs.readFile(path.join(root,'source',file));
  const width=item.source==='sheet'?1666:1254,height=item.source==='sheet'?944:1254;
  const svg=`<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="192" height="288" viewBox="0 0 192 288"><title>${item.name}</title><defs><clipPath id="silhouette"><path d="${item.d}"/></clipPath></defs><g transform="translate(${dx} ${dy}) scale(${s})"><image width="${width}" height="${height}" xlink:href="data:image/png;base64,${image.toString('base64')}" clip-path="url(#silhouette)"/></g></svg>`;
  await fs.writeFile(path.join(root,'svg',item.key+'.svg'),svg);
 }
})().catch(error=>{console.error(error);process.exitCode=1;});
