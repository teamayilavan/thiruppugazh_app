import React from 'react';
import {
  AbsoluteFill,
  Audio,
  Easing,
  Freeze,
  Img,
  OffthreadVideo,
  Sequence,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {BookOpen, Check, Columns, ArrowsLeftRight} from '@phosphor-icons/react';
import {c, font, FPS, H, PAD, phone, tablet, W} from './theme';
import {PlacedBeat, timeline} from './timeline';

const SMOOTH = {damping: 200}; // critically damped: no bounce, just a soft landing
const easeOut = Easing.bezier(0.16, 1, 0.3, 1);
const easeIn = Easing.bezier(0.7, 0, 0.84, 0);
const CROSS = 10; // frames of cross-fade between screens

const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;

/* ---------- background ---------- */

const Background: React.FC = () => {
  const f = useCurrentFrame();
  const a = f / 240;
  const x1 = 28 + Math.sin(a) * 14;
  const y1 = 30 + Math.cos(a * 0.8) * 8;
  const x2 = 78 + Math.cos(a * 0.7) * 12;
  const y2 = 74 + Math.sin(a * 0.9) * 8;
  return (
    <AbsoluteFill
      style={{
        background: [
          `radial-gradient(1200px 1200px at ${x1}% ${y1}%, ${c.glow}55 0%, transparent 62%)`,
          `radial-gradient(1000px 1000px at ${x2}% ${y2}%, #1B5A34 0%, transparent 60%)`,
          `linear-gradient(180deg, ${c.bg}, ${c.bgDeep})`,
        ].join(','),
      }}
    />
  );
};

/* ---------- headline, sub line, chip ---------- */

type Word = {text: string; accent: boolean};
// `|` forces a line break; words inside *asterisks* take the accent colour.
const parseTitle = (t: string): Word[][] =>
  t.split('|').map((line) =>
    line
      .split('*')
      .flatMap((part, i) => part.split(/\s+/).filter(Boolean).map((text) => ({text, accent: i % 2 === 1}))),
  );

const Headline: React.FC<{beat: PlacedBeat}> = ({beat}) => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const lines = parseTitle(beat.title ?? '');
  const words = lines.flat();
  const exit = interpolate(f, [beat.frames - 11, beat.frames - 3], [0, 1], {...clamp, easing: easeIn});
  const subIn = spring({frame: f - (8 + words.length * 3), fps, config: SMOOTH});
  const chipIn = spring({frame: f - 2, fps, config: {damping: 14, stiffness: 160}});
  return (
    <div style={{position: 'absolute', left: PAD, right: PAD, top: 0, height: 440}}>
      {beat.chip ? (
        <div
          style={{
            position: 'absolute',
            top: 64,
            left: 0,
            padding: '8px 22px',
            borderRadius: 999,
            background: c.accent,
            color: c.accentInk,
            fontFamily: font.display,
            fontWeight: 700,
            fontSize: 30,
            letterSpacing: 0.4,
            transform: `scale(${chipIn - exit * 0.2})`,
            transformOrigin: 'left center',
            opacity: 1 - exit,
          }}
        >
          {beat.chip}
        </div>
      ) : null}
      <div
        style={{
          position: 'absolute',
          top: 124,
          left: 0,
          right: 0,
          fontFamily: font.display,
          fontWeight: 700,
          fontSize: 80,
          lineHeight: 1.04,
          letterSpacing: -2.4,
          color: c.text,
        }}
      >
        {(() => {
          let n = 0;
          return lines.map((line, li) => (
            <div key={li} style={{whiteSpace: 'nowrap'}}>
              {line.map((w) => {
                const i = n++;
                const s = spring({frame: f - (4 + i * 3), fps, config: SMOOTH});
                const y = (1 - s) * 112 - exit * 112;
                return (
                  <span
                    key={i}
                    style={{display: 'inline-block', overflow: 'hidden', verticalAlign: 'top', paddingBottom: 14, marginBottom: -14, marginRight: 20}}
                  >
                    <span
                      style={{
                        display: 'inline-block',
                        transform: `translateY(${y}%)`,
                        opacity: 1 - exit * 0.6,
                        color: w.accent ? c.accent : c.text,
                      }}
                    >
                      {w.text}
                    </span>
                  </span>
                );
              })}
            </div>
          ));
        })()}
      </div>
      {beat.sub ? (
        <div
          style={{
            position: 'absolute',
            top: 322,
            left: 0,
            right: 40,
            fontFamily: font.display,
            fontWeight: 400,
            fontSize: 36,
            lineHeight: 1.28,
            color: c.muted,
            opacity: subIn * (1 - exit),
            transform: `translateY(${(1 - subIn) * 22 - exit * 18}px)`,
          }}
        >
          {beat.sub}
        </div>
      ) : null}
    </div>
  );
};

/* ---------- recorded screens ---------- */

const Clip: React.FC<{clip: string; rate: number; startFrom: number; w: number; h: number; frozenAt?: number}> = ({
  clip,
  rate,
  startFrom,
  w,
  h,
  frozenAt,
}) => {
  const video = (
    <OffthreadVideo
      src={staticFile(`clips/${clip}.mp4`)}
      playbackRate={rate}
      startFrom={startFrom}
      muted
      style={{width: w, height: h, objectFit: 'cover'}}
    />
  );
  return frozenAt === undefined ? video : <Freeze frame={frozenAt}>{video}</Freeze>;
};

/** One beat's recording. It fades in over the previous beat; the last frame is held if the clip is shorter than the beat. */
const Screen: React.FC<{beat: PlacedBeat; lead: number; w: number; h: number}> = ({beat, lead, w, h}) => {
  const f = useCurrentFrame();
  const last = beat.placed[beat.placed.length - 1];
  const lastEnd = last ? last.from + last.frames : 0;
  const total = beat.frames + lead;
  return (
    <AbsoluteFill style={{opacity: lead ? interpolate(f, [0, lead], [0, 1], clamp) : 1}}>
      {beat.placed.map((seg) => (
        <Sequence
          key={seg.clip}
          from={lead + seg.from}
          durationInFrames={Math.max(1, Math.min(seg.frames, beat.frames - seg.from))}
          layout="none"
        >
          <Clip clip={seg.clip} rate={seg.rate} startFrom={seg.startFrom} w={w} h={h} />
        </Sequence>
      ))}
      {last && lastEnd < beat.frames ? (
        <Sequence from={lead + lastEnd} durationInFrames={total - lead - lastEnd} layout="none">
          <Clip
            clip={last.clip}
            rate={last.rate}
            startFrom={last.startFrom}
            w={w}
            h={h}
            frozenAt={Math.max(0, last.frames - 1)}
          />
        </Sequence>
      ) : null}
    </AbsoluteFill>
  );
};

/* ---------- devices ---------- */

const group = (device: 'phone' | 'tablet') => {
  const beats = timeline.placed.filter((b) => b.device === device);
  const first = beats[0];
  const lastB = beats[beats.length - 1];
  return {beats, start: first.start, end: lastB.start + lastB.frames};
};

const DeviceShell: React.FC<{
  stage: {start: number; end: number};
  outerW: number;
  outerH: number;
  top: number;
  radius: number;
  bezel: number;
  screenRadius: number;
  children: React.ReactNode;
  tilt?: number;
}> = ({stage, outerW, outerH, top, radius, bezel, screenRadius, children, tilt = 0}) => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const local = f - stage.start;
  const dur = stage.end - stage.start;
  const enter = spring({frame: local, fps, config: {damping: 24, stiffness: 90}});
  const exit = interpolate(local, [dur - 14, dur], [0, 1], {...clamp, easing: easeIn});
  const float = Math.sin(f / 52) * 7;
  const y = (1 - enter) * 260 + exit * 340 + float;
  return (
    <div
      style={{
        position: 'absolute',
        left: (W - outerW) / 2,
        top,
        width: outerW,
        height: outerH,
        borderRadius: radius,
        background: c.bezel,
        boxShadow: `0 50px 120px rgba(2,12,6,0.65), 0 0 0 2px rgba(238,245,234,0.1), 0 0 160px ${c.glow}40`,
        opacity: enter * (1 - exit),
        transform: `translateY(${y}px) rotate(${tilt}deg)`,
      }}
    >
      <div
        style={{
          position: 'absolute',
          left: bezel,
          top: bezel,
          right: bezel,
          bottom: bezel,
          borderRadius: screenRadius,
          overflow: 'hidden',
          background: '#000',
        }}
      >
        {children}
      </div>
    </div>
  );
};

const PhoneStage: React.FC = () => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const g = group('phone');
  // A small lean that eases to the opposite side on every beat gives the phone life without distracting.
  let idx = 0;
  g.beats.forEach((b, i) => {
    if (f >= b.start) idx = i;
  });
  const b = g.beats[idx];
  const s = spring({frame: f - b.start, fps, config: SMOOTH});
  const prevTilt = idx === 0 ? 0 : (idx - 1) % 2 ? 1.1 : -1.1;
  const nextTilt = idx % 2 ? 1.1 : -1.1;
  const tilt = prevTilt + (nextTilt - prevTilt) * s;
  return (
    <DeviceShell
      stage={g}
      outerW={phone.screenW + phone.bezel * 2}
      outerH={phone.screenH + phone.bezel * 2}
      top={phone.top}
      radius={phone.radius}
      bezel={phone.bezel}
      screenRadius={phone.screenRadius}
      tilt={tilt}
    >
      {g.beats.map((beat, i) => {
        const lead = i === 0 ? 0 : CROSS;
        return (
          <Sequence key={beat.id} from={beat.start - lead} durationInFrames={beat.frames + lead} layout="none">
            <Screen beat={beat} lead={lead} w={phone.screenW} h={phone.screenH} />
          </Sequence>
        );
      })}
    </DeviceShell>
  );
};

const tabletRows = [
  {Icon: Columns, text: 'Lyrics and meanings, side by side'},
  {Icon: ArrowsLeftRight, text: 'Previous and next with the arrow keys'},
  {Icon: BookOpen, text: 'Opens where you left off'},
];

const TabletStage: React.FC = () => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const g = group('tablet');
  const beat = g.beats[0];
  const local = f - beat.start;
  const exit = interpolate(local, [beat.frames - 12, beat.frames - 3], [0, 1], {...clamp, easing: easeIn});
  return (
    <>
      <DeviceShell
        stage={g}
        outerW={tablet.screenW + tablet.bezel * 2}
        outerH={tablet.screenH + tablet.bezel * 2}
        top={tablet.top}
        radius={tablet.radius}
        bezel={tablet.bezel}
        screenRadius={tablet.screenRadius}
      >
        <Sequence from={beat.start} durationInFrames={beat.frames} layout="none">
          <Screen beat={beat} lead={0} w={tablet.screenW} h={tablet.screenH} />
        </Sequence>
      </DeviceShell>
      <div style={{position: 'absolute', left: PAD + 20, top: 1340, display: 'flex', flexDirection: 'column', gap: 40}}>
        {tabletRows.map(({Icon, text}, i) => {
          const s = spring({frame: local - (34 + i * 12), fps, config: SMOOTH});
          return (
            <div
              key={text}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 28,
                fontFamily: font.display,
                fontWeight: 500,
                fontSize: 46,
                color: c.text,
                opacity: s * (1 - exit),
                transform: `translateX(${(1 - s) * 60}px)`,
              }}
            >
              <span
                style={{
                  width: 84,
                  height: 84,
                  borderRadius: 24,
                  background: 'rgba(168,213,162,0.14)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: c.accent,
                }}
              >
                <Icon size={46} weight="regular" />
              </span>
              {text}
            </div>
          );
        })}
      </div>
    </>
  );
};

/* ---------- logo lockup (intro and end card) ---------- */

const Lockup: React.FC<{frames: number; tagline?: string; badge?: boolean}> = ({frames, tagline, badge}) => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const tile = spring({frame: f - 4, fps, config: {damping: 16, stiffness: 110}});
  const ring = interpolate(f, [8, 70], [0.6, 1.9], {...clamp, easing: easeOut});
  const ringO = interpolate(f, [8, 20, 70], [0, 0.35, 0], clamp);
  const word = spring({frame: f - 26, fps, config: SMOOTH});
  const tamil = spring({frame: f - 38, fps, config: SMOOTH});
  const tag = spring({frame: f - 52, fps, config: SMOOTH});
  const bd = spring({frame: f - 62, fps, config: SMOOTH});
  const out = interpolate(f, [frames - 12, frames], [1, 0], {...clamp, easing: easeIn});
  const tileSize = badge ? 280 : 360;
  return (
    <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', opacity: out}}>
      <div style={{position: 'relative', marginTop: badge ? -120 : -60, display: 'flex', flexDirection: 'column', alignItems: 'center'}}>
        <div
          style={{
            position: 'absolute',
            top: tileSize / 2,
            left: '50%',
            width: tileSize,
            height: tileSize,
            borderRadius: '50%',
            border: `3px solid ${c.accent}`,
            transform: `translate(-50%,-50%) scale(${ring})`,
            opacity: ringO,
          }}
        />
        <div
          style={{
            width: tileSize,
            height: tileSize,
            borderRadius: tileSize * 0.26,
            background: c.tile,
            boxShadow: `0 40px 100px rgba(2,12,6,0.55), 0 0 140px ${c.glow}55`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            transform: `scale(${tile}) rotate(${(1 - tile) * -14}deg)`,
          }}
        >
          <Img src={staticFile('img/app-icon.png')} style={{width: '82%', height: '82%'}} />
        </div>
        <div style={{height: badge ? 54 : 70}} />
        <div style={{overflow: 'hidden', paddingBottom: 14, marginBottom: -14}}>
          <div
            style={{
              fontFamily: font.display,
              fontWeight: 800,
              fontSize: badge ? 120 : 132,
              letterSpacing: -4,
              color: c.text,
              transform: `translateY(${(1 - word) * 115}%)`,
            }}
          >
            Thiruppugazh
          </div>
        </div>
        <div
          style={{
            marginTop: 6,
            fontFamily: font.tamil,
            fontWeight: 600,
            fontSize: 76,
            color: c.accent,
            opacity: tamil,
            transform: `translateY(${(1 - tamil) * 24}px)`,
          }}
        >
          திருப்புகழ்
        </div>
        {tagline ? (
          <div
            style={{
              marginTop: 44,
              fontFamily: font.display,
              fontWeight: 400,
              fontSize: 44,
              color: c.muted,
              opacity: tag,
              transform: `translateY(${(1 - tag) * 20}px)`,
            }}
          >
            {tagline}
          </div>
        ) : null}
        {badge ? (
          <>
            <Img
              src={staticFile('img/google-play-badge.png')}
              style={{marginTop: 70, width: 500, opacity: bd, transform: `translateY(${(1 - bd) * 24}px)`}}
            />
            <div
              style={{
                marginTop: 44,
                fontFamily: font.display,
                fontSize: 36,
                color: c.muted,
                letterSpacing: 1,
                opacity: bd,
              }}
            >
              Team Ayilavan
            </div>
          </>
        ) : null}
      </div>
    </AbsoluteFill>
  );
};

/* ---------- promise ---------- */

const promiseRows = ['No ads', 'No tracking', 'No accounts', 'Works offline', 'Backed up through your own Google account'];

const Promise: React.FC<{beat: PlacedBeat}> = ({beat}) => {
  const f = useCurrentFrame();
  const {fps} = useVideoConfig();
  const fake: PlacedBeat = {...beat, title: 'Made to stay|*out of your way.*', sub: undefined, chip: undefined};
  const exit = interpolate(f, [beat.frames - 12, beat.frames - 3], [0, 1], {...clamp, easing: easeIn});
  const note = spring({frame: f - (30 + promiseRows.length * 14), fps, config: SMOOTH});
  return (
    <AbsoluteFill>
      <Headline beat={fake} />
      <div style={{position: 'absolute', left: PAD, right: PAD, top: 520, display: 'flex', flexDirection: 'column', gap: 54}}>
        {promiseRows.map((row, i) => {
          const s = spring({frame: f - (24 + i * 14), fps, config: SMOOTH});
          return (
            <div
              key={row}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 34,
                fontFamily: font.display,
                fontWeight: 600,
                fontSize: row.length > 20 ? 54 : 70,
                lineHeight: 1.1,
                letterSpacing: -1,
                color: c.text,
                opacity: s * (1 - exit),
                transform: `translateX(${(1 - s) * 70}px)`,
              }}
            >
              <span
                style={{
                  flex: '0 0 92px',
                  height: 92,
                  borderRadius: 28,
                  background: c.accent,
                  color: c.accentInk,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  transform: `scale(${s})`,
                }}
              >
                <Check size={54} weight="bold" />
              </span>
              <span>{row}</span>
            </div>
          );
        })}
      </div>
      <div
        style={{
          position: 'absolute',
          left: PAD,
          bottom: 130,
          fontFamily: font.display,
          fontSize: 38,
          color: c.muted,
          opacity: note * (1 - exit),
        }}
      >
        Open source under AGPL-3.0
      </div>
    </AbsoluteFill>
  );
};

/* ---------- root ---------- */

export const VideoV2: React.FC<{music?: string}> = ({music = 'music-v2.m4a'}) => {
  const byId = (id: string) => timeline.placed.find((b) => b.id === id)!;
  return (
    <AbsoluteFill style={{backgroundColor: c.bgDeep}}>
      <Background />

      <Sequence from={byId('intro').start} durationInFrames={byId('intro').frames} layout="none">
        <Lockup frames={byId('intro').frames} tagline="1,340 songs. One quiet app." />
      </Sequence>

      {timeline.placed
        .filter((b) => b.title && b.kind !== 'promise')
        .map((b) => (
          <Sequence key={`h-${b.id}`} from={b.start} durationInFrames={b.frames} layout="none">
            <Headline beat={b} />
          </Sequence>
        ))}

      <PhoneStage />

      <TabletStage />

      <Sequence from={byId('promise').start} durationInFrames={byId('promise').frames} layout="none">
        <Promise beat={byId('promise')} />
      </Sequence>

      <Sequence from={byId('end').start} durationInFrames={byId('end').frames} layout="none">
        <Lockup frames={byId('end').frames} badge />
      </Sequence>

      <Audio
        src={staticFile(music)}
        volume={(f) =>
          interpolate(f, [0, 45, timeline.total - 90, timeline.total], [0, 0.9, 0.9, 0], clamp)
        }
      />
    </AbsoluteFill>
  );
};

export const durationInFrames = timeline.total;
export {FPS, H, W};
