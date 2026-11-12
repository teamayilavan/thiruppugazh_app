import clipMeta from '../../public/clips/clips.json';
import {FPS} from './theme';

type ClipName = keyof typeof clipMeta;

/** `from`/`to` trim the (already idle-free) clip, in clip seconds. `rate` fixes the playback speed. */
export type Seg = {clip: ClipName; rate?: number; from?: number; to?: number};

export type Device = 'phone' | 'tablet' | 'none';

export type Beat = {
  id: string;
  seconds: number;
  device: Device;
  /** Headline. Words wrapped in *asterisks* get the accent colour. */
  title?: string;
  sub?: string;
  /** Small label above the headline, used only for what is new in this release. */
  chip?: string;
  segs: Seg[];
  kind?: 'intro' | 'promise' | 'end' | 'tablet';
};

// About 130 seconds. Every claim matches feature-inventory.md and the 1.7.0 changelog. No em dashes anywhere.
export const beats: Beat[] = [
  {id: 'intro', seconds: 6.5, device: 'none', kind: 'intro', segs: []},
  {
    id: 'library',
    seconds: 8,
    device: 'phone',
    title: 'Every song,|*fully laid out.*',
    sub: 'Lyrics, meaning, tune and temple on one page.',
    segs: [{clip: 'b01_library'}, {clip: 'b01b_meaning'}],
  },
  {
    id: 'padham',
    seconds: 7,
    device: 'phone',
    title: 'Understand|*every word.*',
    sub: 'Word-by-word meanings on many songs.',
    segs: [{clip: 'b02_padham'}],
  },
  {
    id: 'search',
    seconds: 8.5,
    device: 'phone',
    chip: 'New in 1.7',
    title: 'Type it|*the way it sounds.*',
    sub: 'Search finds the song and shows the line that matched.',
    segs: [{clip: 'n01_search_match'}],
  },
  {
    id: 'temples',
    seconds: 5,
    device: 'phone',
    title: 'Visit the|*six abodes.*',
    sub: 'Browse every song by temple.',
    segs: [{clip: 'b04_temples'}],
  },
  {
    id: 'language',
    seconds: 9,
    device: 'phone',
    title: 'Your language.|*Your light.*',
    sub: 'Tamil or English, larger text, a dark theme for night.',
    segs: [{clip: 'b05_language_theme'}],
  },
  {
    id: 'notes',
    seconds: 7,
    device: 'phone',
    title: 'Mark|*what moves you.*',
    sub: 'Highlight a verse. Add a note of your own.',
    segs: [{clip: 'b06_notes'}],
  },
  {
    id: 'lists',
    seconds: 6,
    device: 'phone',
    title: 'Your own|*collections.*',
    sub: 'Favorites, and lists you name yourself.',
    segs: [{clip: 'b07_lists'}],
  },
  {
    id: 'links',
    seconds: 11,
    device: 'phone',
    chip: 'New in 1.7',
    title: 'Found a kirtan online?|*Keep it.*',
    sub: 'Share it into the app and pick its song. Recent songs are one tap away.',
    segs: [{clip: 'n02_share_in', from: 0.8, to: 14.6}, {clip: 'b08b_links', rate: 1}],
  },
  {
    id: 'today',
    seconds: 5,
    device: 'phone',
    title: 'A song|*for today.*',
    sub: 'Or let the app surprise you.',
    segs: [{clip: 'b09_today'}],
  },
  {
    id: 'widget',
    seconds: 6,
    device: 'phone',
    chip: 'New in 1.7',
    title: 'Today’s song,|*on your home screen.*',
    sub: 'A widget that opens the song with one tap.',
    segs: [{clip: 'n03_widget'}],
  },
  {
    id: 'chanting',
    seconds: 11,
    device: 'phone',
    title: 'Chant,|*one verse at a time.*',
    sub: 'Large text, a tune cue, and an auto pace you choose.',
    segs: [{clip: 'b10_chanting'}],
  },
  {
    id: 'continue',
    seconds: 5,
    device: 'phone',
    title: 'Stop halfway?|*Pick up there.*',
    sub: 'It remembers the verse you were on.',
    segs: [{clip: 'b11_continue'}],
  },
  {
    id: 'share',
    seconds: 4.5,
    device: 'phone',
    title: 'Moved by a song?|*Share it.*',
    sub: 'As text, or as a link that opens in the app.',
    segs: [{clip: 'b13_share'}],
  },
  {
    id: 'settings',
    seconds: 8.5,
    device: 'phone',
    chip: 'New in 1.7',
    title: 'Quiet|*by design.*',
    sub: 'An optional daily reminder, and the screen stays awake as you read.',
    segs: [{clip: 'n04_settings'}],
  },
  {
    id: 'tablet',
    seconds: 8.5,
    device: 'tablet',
    kind: 'tablet',
    chip: 'New in 1.7',
    title: 'Made for|*tablets, too.*',
    sub: 'Songs on the left, the open song on the right.',
    segs: [{clip: 'n05_tablet'}],
  },
  {id: 'promise', seconds: 7, device: 'none', kind: 'promise', segs: []},
  {id: 'end', seconds: 7, device: 'none', kind: 'end', segs: []},
];

const MIN_RATE = 0.6;
const MAX_RATE = 3.5;

export type PlacedSeg = {clip: string; from: number; frames: number; rate: number; startFrom: number};
export type PlacedBeat = Beat & {start: number; frames: number; placed: PlacedSeg[]};

const meta = clipMeta as Record<string, {active_seconds: number}>;
const activeOf = (s: Seg) => (s.to ?? meta[s.clip].active_seconds) - (s.from ?? 0);

export function layoutBeats(): {placed: PlacedBeat[]; total: number} {
  let cursor = 0;
  const placed = beats.map((beat): PlacedBeat => {
    const frames = Math.round(beat.seconds * FPS);
    const fixed = beat.segs.filter((s) => s.rate);
    const free = beat.segs.filter((s) => !s.rate);
    const fixedFrames = fixed.reduce((a, s) => a + Math.round((activeOf(s) / (s.rate as number)) * FPS), 0);
    const freeActive = free.reduce((a, s) => a + activeOf(s), 0);
    const freeSeconds = Math.max(0.5, (frames - fixedFrames) / FPS);
    const freeRate = freeActive ? Math.min(MAX_RATE, Math.max(MIN_RATE, freeActive / freeSeconds)) : 1;

    let inBeat = 0;
    const segs = beat.segs.map((s) => {
      const rate = s.rate ?? freeRate;
      const f = Math.round((activeOf(s) / rate) * FPS);
      const out = {clip: s.clip as string, from: inBeat, frames: f, rate, startFrom: Math.round((s.from ?? 0) * FPS)};
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
