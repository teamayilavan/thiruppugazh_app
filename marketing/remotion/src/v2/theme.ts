import {loadFont} from '@remotion/google-fonts/Outfit';

// Outfit for display type, loaded once at module scope (Remotion waits for it before rendering).
export const outfit = loadFont('normal', {weights: ['400', '500', '600', '700', '800'], subsets: ['latin']});

// One palette, taken from the app's own greens. Single accent: mint.
export const c = {
  bg: '#08200F',
  bgDeep: '#051509',
  glow: '#2F7A4A',
  text: '#EEF5EA',
  muted: '#A9C7A9',
  accent: '#A8D5A2',
  accentInk: '#0B2E1A',
  tile: '#D8EDD3', // the app's light surface, used behind the logo
  bezel: '#0A0F0C',
  line: 'rgba(238,245,234,0.14)',
};

export const font = {
  display: `${outfit.fontFamily}, 'Segoe UI', sans-serif`,
  tamil: "'Nirmala UI', 'Noto Sans Tamil', 'Segoe UI', sans-serif",
};

export const W = 1080;
export const H = 1920;
export const FPS = 30;
export const PAD = 72;

// Phone: the emulator's 1080:2400 shape, flush with the bottom of the canvas.
export const phone = {
  screenW: 660,
  screenH: 1467,
  bezel: 12,
  top: 442,
  radius: 64,
  screenRadius: 52,
};
phone.screenH = Math.round((phone.screenW * 2400) / 1080);

// Tablet: 2560x1600 landscape, 16:10.
export const tablet = {
  screenW: 960,
  screenH: 600,
  bezel: 20,
  top: 560,
  radius: 40,
  screenRadius: 22,
};
