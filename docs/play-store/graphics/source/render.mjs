// Renders the Play Store feature graphic and an icon preview sheet with Playwright.
// Run from the repository root:
//   NODE_PATH=/path/to/node_modules node docs/play-store/graphics/source/render.mjs
// Outputs docs/play-store/graphics/feature-graphic.png (CZ), feature-graphic-en.png and
//         docs/play-store/graphics/icon-preview.png (review aid, not uploaded).
import { readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const root = process.cwd();
const res = path.join(root, 'android/app/src/main/res');
const out = path.join(root, 'docs/play-store/graphics');

// Convert the monochrome VectorDrawable to SVG so the preview shows the real XML.
// Supports what make_icons.py emits: nested <group> (transform, leading <clip-path>) and <path>.
let clipSeq = 0;
function vectorToSvg(xml, color) {
  const attr = (t, n) => (t.match(new RegExp(`android:${n}="([^"]+)"`)) || [])[1];
  const defs = [];
  let body = '';
  const stack = [];
  for (const [tag] of xml.matchAll(/<\/?(group|clip-path|path)\b[\s\S]*?>/g)) {
    if (tag.startsWith('</group')) { body += '</g>'; stack.pop(); continue; }
    if (tag.startsWith('<group')) {
      const tx = attr(tag, 'translateX'), sc = attr(tag, 'scaleX');
      const tf = tx ? ` transform="translate(${tx} ${attr(tag, 'translateY')}) scale(${sc})"` : '';
      body += `<g${tf}>`; stack.push(body.length - 1); continue;
    }
    if (tag.startsWith('<clip-path')) {
      const id = `c${clipSeq++}`;
      defs.push(`<clipPath id="${id}"><path d="${attr(tag, 'pathData')}" clip-rule="nonzero"/></clipPath>`);
      // Insert clip-path on the innermost open <g> (clip-path is always its first child here).
      const at = stack[stack.length - 1];
      body = body.slice(0, at) + ` clip-path="url(#${id})"` + body.slice(at);
      continue;
    }
    const d = attr(tag, 'pathData');
    if (attr(tag, 'strokeColor')) {
      body += `<path d="${d}" fill="none" stroke="${color}" stroke-width="${attr(tag, 'strokeWidth')}" stroke-linecap="round"/>`;
    } else {
      const rule = attr(tag, 'fillType') === 'evenOdd' ? 'evenodd' : 'nonzero';
      body += `<path d="${d}" fill="${color}" fill-rule="${rule}"/>`;
    }
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="100%" height="100%">` +
    `<defs>${defs.join('')}</defs>${body}</svg>`;
}

const b64 = (p) => `data:image/png;base64,${readFileSync(p).toString('base64')}`;
const fg = b64(path.join(res, 'mipmap-xxxhdpi/ic_launcher_foreground.png'));
const legacy = b64(path.join(res, 'mipmap-xxxhdpi/ic_launcher.png'));
const play = b64(path.join(out, 'icon-512.png'));
const monoXml = readFileSync(path.join(res, 'drawable/ic_launcher_monochrome.xml'), 'utf8');
const monoDark = vectorToSvg(monoXml, '#F2DFD1');
const monoLight = vectorToSvg(monoXml, '#5B4134');

// Visible area of an adaptive icon = central 72 of 108 dp.
const adaptive = (mask, size, layer = `<div class="bg"></div><img src="${fg}">`) =>
  `<div class="ai" style="width:${size}px;height:${size}px;${mask}"><div class="inner">${layer}</div></div>`;
const masks = {
  circle: 'border-radius:50%',
  squircle: 'border-radius:32%',
  'rounded square': 'border-radius:18%',
  teardrop: 'border-radius:50% 50% 50% 12%',
};
const cell = (label, html) => `<figure>${html}<figcaption>${label}</figcaption></figure>`;
const preview = `<!doctype html><html><head><style>
body{margin:0;padding:32px;background:#e9e4df;font:14px system-ui;color:#35241D}
h2{margin:24px 0 12px;font-size:16px}.row{display:flex;gap:28px;flex-wrap:wrap;align-items:flex-end}
figure{margin:0;text-align:center}figcaption{margin-top:8px}
.ai{overflow:hidden;position:relative;box-shadow:0 2px 6px rgba(0,0,0,.18)}
.ai .inner{position:absolute;inset:-25%;}
.ai .bg{position:absolute;inset:0;background:#F8EDDD}.ai img,.ai svg{position:absolute;inset:0;width:100%;height:100%}
.home{display:flex;gap:22px;padding:22px;border-radius:24px}
</style></head><body>
<h2>Adaptive icon (foreground + background) in launcher masks</h2>
<div class="row">${Object.entries(masks).map(([n, m]) => cell(n, adaptive(m, 180))).join('')}
${cell('full 108 dp canvas', `<div style="width:270px;height:270px;position:relative;background:#F8EDDD;outline:1px dashed #999"><img src="${fg}" style="width:100%;height:100%"><div style="position:absolute;left:50%;top:50%;width:${270*66/108}px;height:${270*66/108}px;margin:-${270*33/108}px;border:1px dashed #b42318;border-radius:50%"></div></div>`)}</div>
<h2>Themed icons (Android 13+, monochrome layer)</h2>
<div class="row">
${cell('dark theme', adaptive(masks.circle, 180, `<div class="bg" style="background:#3B2F2A"></div>${monoDark}`))}
${cell('light theme', adaptive(masks.circle, 180, `<div class="bg" style="background:#F6DDCF"></div>${monoLight}`))}
${cell('dark, squircle', adaptive(masks.squircle, 180, `<div class="bg" style="background:#2E3A33"></div>${vectorToSvg(monoXml, '#CFE8D6')}`))}
</div>
<h2>Actual size on a home screen (48 dp at ~3x)</h2>
<div class="row"><div class="home" style="background:#4b6b8a">${adaptive(masks.circle, 144)}${adaptive(masks.squircle, 144)}${adaptive(masks.circle, 144, `<div class="bg" style="background:#3B2F2A"></div>${monoDark}`)}</div>
<div class="home" style="background:#f3f3f3">${adaptive(masks.circle, 96)}${adaptive(masks.circle, 96, `<div class="bg" style="background:#F6DDCF"></div>${monoLight}`)}</div></div>
<h2>Play Store icon 512 (Play rounds corners itself) and legacy PNG (API 24–25)</h2>
<div class="row">${cell('icon-512.png', `<img src="${play}" style="width:256px;border-radius:20%">`)}${cell('icon-512 at 64 px', `<img src="${play}" style="width:64px;border-radius:20%">`)}${cell('legacy ic_launcher.png', `<img src="${legacy}" style="width:144px">`)}</div>
</body></html>`;

const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: 1 });
await page.setViewportSize({ width: 1200, height: 900 });
await page.setContent(preview);
await page.screenshot({ path: path.join(out, 'icon-preview.png'), fullPage: true });

if (!process.argv.includes('--icons-only')) {
  const fonts = path.join(root, 'assets/fonts');
  let html = readFileSync(path.join(out, 'source/feature-graphic.html'), 'utf8');
  html = html.replaceAll('{{FONTS}}', `file://${fonts}`).replaceAll('{{ICON}}', b64(path.join(out, 'icon-512.png')))
    .replaceAll('{{FG}}', fg);
  const tmp = path.join(out, 'source/.feature-graphic.rendered.html');
  writeFileSync(tmp, html);
  for (const [hash, file] of [['cs', 'feature-graphic.png'], ['en', 'feature-graphic-en.png']]) {
    const fp = await browser.newPage({ deviceScaleFactor: 1 });
    await fp.setViewportSize({ width: 1024, height: 500 });
    await fp.goto(`file://${tmp}#${hash}`);
    await fp.evaluate(() => document.fonts.ready);
    await fp.screenshot({ path: path.join(out, file), omitBackground: false });
  }
  (await import('node:fs')).unlinkSync(tmp);
}
await browser.close();
console.log('rendered');
