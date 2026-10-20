const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

// Native SVG composition: omit the original product regions, then render a
// single body bitmap. No intact product-bearing image remains in the output.
const base = __dirname;
const sourcePath = path.join(base, '../v5/exports/vending-b.png');
const source = fs.readFileSync(sourcePath).toString('base64');
const windows = [[61,95,207,56],[61,170,207,56],[61,246,207,56]];
const holes = windows.map(([x,y,w,h]) => `M${x} ${y}h${w}v${h}h-${w}Z`).join('');
const backs = windows.map(([x,y,w,h]) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="#fcfce5"/>`).join('');
const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="350" height="525"><defs><clipPath id="body"><path clip-rule="evenodd" d="M0 0H350V525H0Z${holes}"/></clipPath></defs>${backs}<image width="350" height="525" href="data:image/png;base64,${source}" clip-path="url(#body)"/></svg>`;
fs.writeFileSync(path.join(base, 'body-b-empty-source.svg'), svg);
sharp(Buffer.from(svg)).png().toFile(path.join(base, 'body-b-empty.png')).then(() => console.log('Wrote one empty B body, 350x525.'));
