// Colours taken from the app's own green palette (see the app screenshots / app_theme.dart).
export const colors = {
  bgTop: '#0B2E1A',
  bgBottom: '#1A4D2E',
  glow: '#2F7A4A',
  surface: '#D8EDD3', // the app's light surface
  accent: '#9ACB9B',
  text: '#F3F8EF',
  bezel: '#0A0F0C',
};

export const fonts = {
  latin: "'Segoe UI', 'Helvetica Neue', Arial, sans-serif",
  tamil: "'Nirmala UI', 'Noto Sans Tamil', 'Segoe UI', sans-serif",
};

// Canvas 1080x1920 (9:16). The phone screen keeps the emulator's 1080:2400 shape.
export const layout = {
  width: 1080,
  height: 1920,
  screenW: 700,
  screenH: 1556, // 700 * 2400 / 1080
  bezel: 14,
  phoneTop: 262,
  captionTop: 64,
  captionHeight: 176,
};
