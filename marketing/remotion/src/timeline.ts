import clipMeta from '../public/clips/clips.json';

export const FPS = 30;

type ClipName = keyof typeof clipMeta;

export type Seg = {clip: ClipName; rate?: number};

export type Beat = {
  id: string;
  seconds: number;
  caption?: string;
  segs: Seg[];
  kind?: 'clips' | 'promise' | 'end';
};

// Beat order and lengths follow script/en.md (120 s). Captions are shortened for the music-only cut,
// where the text carries the story. Every claim matches the approved script and feature-inventory.md.
export const beats: Beat[] = [
  {id: 'hook', seconds: 8, caption: 'Thiruppugazh: all 1,340 songs, in one app.', segs: [{clip: 'b00_hook'}]},
  {
    id: 'library',
    seconds: 9,
    caption: 'Lyrics, meaning, tune and temple, together on one page.',
    segs: [{clip: 'b01_library'}, {clip: 'b01b_meaning'}],
  },
  {id: 'padham', seconds: 7, caption: 'Word-by-word meanings on many songs.', segs: [{clip: 'b02_padham'}]},
  {id: 'search', seconds: 8, caption: "Type it the way it sounds. We'll still find it.", segs: [{clip: 'b03_search'}]},
  {id: 'temples', seconds: 5, caption: 'Browse by temple. Start with the six Arupadai Veedu.', segs: [{clip: 'b04_temples'}]},
  {
    id: 'language',
    seconds: 10,
    caption: 'Tamil or English. Bigger text. A dark screen at night.',
    segs: [{clip: 'b05_language_theme'}],
  },
  {id: 'notes', seconds: 7, caption: 'Highlight a verse. Add your own note.', segs: [{clip: 'b06_notes'}]},
  {id: 'lists', seconds: 7, caption: 'Keep favorites. Make your own lists.', segs: [{clip: 'b07_lists'}]},
  {
    id: 'links',
    seconds: 12,
    caption: 'Found a kirtan online? Share it to the app and pick its song.',
    segs: [{clip: 'b08_share_in'}, {clip: 'b08b_links', rate: 1}],
  },
  {id: 'today', seconds: 7, caption: 'A song for today, or a surprise.', segs: [{clip: 'b09_today'}]},
  {id: 'chanting', seconds: 12, caption: 'Chanting mode: one verse at a time, large and clear.', segs: [{clip: 'b10_chanting'}]},
  {id: 'continue', seconds: 5, caption: 'Stop halfway? It remembers the verse.', segs: [{clip: 'b11_continue'}]},
  {id: 'reminder', seconds: 7, caption: 'An optional daily reminder. Works offline.', segs: [{clip: 'b12_reminder'}]},
  {id: 'share', seconds: 5, caption: 'Moved by a song? Share it as text or a link.', segs: [{clip: 'b13_share'}]},
  {id: 'promise', seconds: 6, kind: 'promise', segs: []},
  {id: 'end', seconds: 5, kind: 'end', segs: []},
];

const MIN_RATE = 0.6;
const MAX_RATE = 3.5;

export type PlacedSeg = {clip: string; from: number; frames: number; rate: number};
export type PlacedBeat = Beat & {start: number; frames: number; placed: PlacedSeg[]};

export function layoutBeats(): {placed: PlacedBeat[]; total: number} {
  let cursor = 0;
  const placed = beats.map((beat): PlacedBeat => {
    const frames = Math.round(beat.seconds * FPS);
    const active = (c: string) => (clipMeta as Record<string, {active_seconds: number}>)[c].active_seconds;
    const fixed = beat.segs.filter((s) => s.rate);
    const free = beat.segs.filter((s) => !s.rate);
    const fixedFrames = fixed.reduce((a, s) => a + Math.round((active(s.clip) / (s.rate as number)) * FPS), 0);
    const freeActive = free.reduce((a, s) => a + active(s.clip), 0);
    const freeSeconds = Math.max(0.5, frames / FPS - fixedFrames / FPS);
    const freeRate = freeActive ? Math.min(MAX_RATE, Math.max(MIN_RATE, freeActive / freeSeconds)) : 1;

    let inBeat = 0;
    const segs = beat.segs.map((s) => {
      const rate = s.rate ?? freeRate;
      const f = Math.round((active(s.clip) / rate) * FPS);
      const out = {clip: s.clip as string, from: inBeat, frames: f, rate};
      inBeat += f;
      return out;
    });
    const result = {...beat, start: cursor, frames, placed: segs};
    cursor += frames;
    return result;
  });
  return {placed, total: cursor};
}

export const timeline = layoutBeats();
