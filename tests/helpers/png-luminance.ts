import { inflateSync } from 'zlib';

/**
 * Giai ma PNG du de do do sang. Khong dung thu vien ngoai — du an chua co, va
 * viec can lam chi la "anh nay sang hay toi".
 *
 * Vi sao khong doc thang canvas trong trang: Flutter Web ve bang WebGL/CanvasKit
 * nen `getImageData` tra null (drawing buffer khong duoc giu lai). Anh chup cua
 * Playwright di qua compositor nen luon dung.
 */
export type LuminanceStats = {
  avg: number;
  min: number;
  max: number;
};

/** Bo loc tung dong quet cua PNG (muc 9.2 cua dac ta). */
function unfilter(
  raw: Buffer,
  width: number,
  height: number,
  bytesPerPixel: number,
): Buffer {
  const stride = width * bytesPerPixel;
  const out = Buffer.alloc(stride * height);

  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    const line = raw.subarray(y * (stride + 1) + 1, (y + 1) * (stride + 1));
    const prev = y > 0 ? out.subarray((y - 1) * stride, y * stride) : null;
    const cur = out.subarray(y * stride, (y + 1) * stride);

    for (let i = 0; i < stride; i++) {
      const a = i >= bytesPerPixel ? cur[i - bytesPerPixel] : 0; // trai
      const b = prev ? prev[i] : 0; // tren
      const c = prev && i >= bytesPerPixel ? prev[i - bytesPerPixel] : 0; // cheo
      const x = line[i];

      switch (filter) {
        case 0:
          cur[i] = x;
          break;
        case 1:
          cur[i] = (x + a) & 0xff;
          break;
        case 2:
          cur[i] = (x + b) & 0xff;
          break;
        case 3:
          cur[i] = (x + ((a + b) >> 1)) & 0xff;
          break;
        case 4: {
          // Paeth
          const p = a + b - c;
          const pa = Math.abs(p - a);
          const pb = Math.abs(p - b);
          const pc = Math.abs(p - c);
          const pred = pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
          cur[i] = (x + pred) & 0xff;
          break;
        }
        default:
          throw new Error(`Bo loc PNG khong ho tro: ${filter}`);
      }
    }
  }
  return out;
}

export function luminanceOf(png: Buffer): LuminanceStats {
  if (png.readUInt32BE(0) !== 0x89504e47) {
    throw new Error('Khong phai file PNG');
  }

  let width = 0;
  let height = 0;
  let colorType = 0;
  let bitDepth = 0;
  const idat: Buffer[] = [];

  let off = 8;
  while (off < png.length) {
    const len = png.readUInt32BE(off);
    const type = png.toString('ascii', off + 4, off + 8);
    const data = png.subarray(off + 8, off + 8 + len);

    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'IEND') {
      break;
    }
    off += 12 + len;
  }

  if (bitDepth !== 8) throw new Error(`Chi ho tro 8-bit, gap ${bitDepth}`);
  const channels = colorType === 6 ? 4 : colorType === 2 ? 3 : 0;
  if (channels === 0) throw new Error(`colorType ${colorType} khong ho tro`);

  const pixels = unfilter(
    inflateSync(Buffer.concat(idat)),
    width,
    height,
    channels,
  );

  let sum = 0;
  let min = 255;
  let max = 0;
  const n = width * height;
  for (let i = 0; i < pixels.length; i += channels) {
    const l =
      0.2126 * pixels[i] + 0.7152 * pixels[i + 1] + 0.0722 * pixels[i + 2];
    sum += l;
    if (l < min) min = l;
    if (l > max) max = l;
  }

  return { avg: sum / n, min, max };
}
