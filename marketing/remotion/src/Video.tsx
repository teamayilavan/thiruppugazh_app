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
  staticFile,
  useCurrentFrame,
} from 'remotion';
import {colors, fonts, layout} from './theme';
import {PlacedBeat, timeline} from './timeline';

const {screenW, screenH, bezel} = layout;
const phoneW = screenW + bezel * 2;
const phoneH = screenH + bezel * 2;
const phoneLeft = (layout.width - phoneW) / 2;

const Background: React.FC = () => (
  <AbsoluteFill
    style={{
      background: `radial-gradient(900px 900px at 50% 38%, ${colors.glow}55 0%, transparent 70%), linear-gradient(180deg, ${colors.bgTop}, ${colors.bgBottom})`,
    }}
  />
);

const fade = (frame: number, frames: number, edge = 6) =>
  interpolate(frame, [0, edge, frames - edge, frames], [0, 1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

const Clip: React.FC<{clip: string; rate: number; frozenAt?: number}> = ({clip, rate, frozenAt}) => {
  const video = (
    <OffthreadVideo
      src={staticFile(`clips/${clip}.mp4`)}
      playbackRate={rate}
      muted
      style={{width: screenW, height: screenH, objectFit: 'cover'}}
    />
  );
  return frozenAt === undefined ? video : <Freeze frame={frozenAt}>{video}</Freeze>;
};

/** The recorded app screens for one beat, with a short fade at each end and the last frame held if the clip is short. */
const Screen: React.FC<{beat: PlacedBeat}> = ({beat}) => {
  const frame = useCurrentFrame();
  const last = beat.placed[beat.placed.length - 1];
  const lastEnd = last ? last.from + last.frames : 0;
  return (
    <AbsoluteFill style={{opacity: fade(frame, beat.frames)}}>
      {beat.placed.map((seg) => (
        <Sequence
          key={seg.clip}
          from={seg.from}
          durationInFrames={Math.max(1, Math.min(seg.frames, beat.frames - seg.from))}
          layout="none"
        >
          <Clip clip={seg.clip} rate={seg.rate} />
        </Sequence>
      ))}
      {last && lastEnd < beat.frames ? (
        <Sequence from={lastEnd} durationInFrames={beat.frames - lastEnd} layout="none">
          <Clip clip={last.clip} rate={last.rate} frozenAt={last.frames - 1} />
        </Sequence>
      ) : null}
    </AbsoluteFill>
  );
};

const Caption: React.FC<{text: string; frames: number}> = ({text, frames}) => {
  const frame = useCurrentFrame();
  const opacity = fade(frame, frames, 8);
  const lift = interpolate(frame, [0, 10], [14, 0], {extrapolateRight: 'clamp', easing: Easing.out(Easing.cubic)});
  return (
    <div
      style={{
        position: 'absolute',
        top: layout.captionTop,
        left: 0,
        width: layout.width,
        height: layout.captionHeight,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '0 72px',
        boxSizing: 'border-box',
        textAlign: 'center',
        color: colors.text,
        fontFamily: fonts.latin,
        fontWeight: 700,
        fontSize: 52,
        lineHeight: 1.18,
        letterSpacing: -0.3,
        textShadow: '0 2px 14px rgba(0,0,0,0.45)',
        textWrap: 'balance',
        opacity,
        transform: `translateY(${lift}px)`,
      }}
    >
      {text}
    </div>
  );
};

const promiseLines = ['No ads', 'No tracking', 'No account', 'Works offline', 'Backed up to your Google account'];

const Promise: React.FC<{frames: number}> = ({frames}) => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{opacity: fade(frame, frames, 10), alignItems: 'center'}}>
      <div
        style={{
          marginTop: 330,
          fontFamily: fonts.latin,
          fontWeight: 700,
          fontSize: 44,
          letterSpacing: 6,
          color: colors.accent,
          textTransform: 'uppercase',
        }}
      >
        Our promise
      </div>
      <div style={{marginTop: 56, display: 'flex', flexDirection: 'column', gap: 30}}>
        {promiseLines.map((line, i) => {
          const t = frame - (14 + i * 20);
          const o = interpolate(t, [0, 10], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
          const y = interpolate(t, [0, 12], [24, 0], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
            easing: Easing.out(Easing.cubic),
          });
          return (
            <div
              key={line}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 28,
                width: 900,
                padding: '26px 38px',
                boxSizing: 'border-box',
                borderRadius: 80,
                background: 'rgba(255,255,255,0.09)',
                border: '1.5px solid rgba(255,255,255,0.16)',
                color: colors.text,
                fontFamily: fonts.latin,
                fontWeight: 600,
                fontSize: 50,
                opacity: o,
                transform: `translateY(${y}px)`,
              }}
            >
              <span
                style={{
                  flex: '0 0 64px',
                  height: 64,
                  borderRadius: 32,
                  background: '#7FD38A',
                  color: colors.bgTop,
                  fontSize: 40,
                  lineHeight: '64px',
                  textAlign: 'center',
                  fontWeight: 800,
                }}
              >
                ✓
              </span>
              <span style={{lineHeight: 1.15}}>{line}</span>
            </div>
          );
        })}
      </div>
      <div
        style={{
          position: 'absolute',
          bottom: 250,
          fontFamily: fonts.latin,
          fontSize: 38,
          color: colors.accent,
          opacity: interpolate(frame, [14 + 5 * 20, 14 + 5 * 20 + 12], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          }),
        }}
      >
        Open source · AGPL-3.0
      </div>
    </AbsoluteFill>
  );
};

const EndCard: React.FC<{frames: number}> = ({frames}) => {
  const frame = useCurrentFrame();
  const o = interpolate(frame, [0, 12], [0, 1], {extrapolateRight: 'clamp'});
  const rise = interpolate(frame, [0, 18], [30, 0], {extrapolateRight: 'clamp', easing: Easing.out(Easing.cubic)});
  const out = interpolate(frame, [frames - 10, frames], [1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  return (
    <AbsoluteFill
      style={{alignItems: 'center', justifyContent: 'center', opacity: o * out, transform: `translateY(${rise}px)`}}
    >
      <Img
        src={staticFile('img/app-icon.png')}
        style={{width: 300, height: 300, borderRadius: 68, boxShadow: '0 24px 60px rgba(0,0,0,0.4)'}}
      />
      <div style={{marginTop: 54, fontFamily: fonts.latin, fontWeight: 800, fontSize: 104, color: colors.text, letterSpacing: -1}}>
        Thiruppugazh
      </div>
      <div style={{marginTop: 8, fontFamily: fonts.tamil, fontWeight: 600, fontSize: 84, color: colors.accent}}>
        திருப்புகழ்
      </div>
      <Img src={staticFile('img/google-play-badge.png')} style={{marginTop: 70, width: 480}} />
      <div style={{marginTop: 54, fontFamily: fonts.latin, fontSize: 40, color: colors.accent, letterSpacing: 1}}>
        Team Ayilavan
      </div>
    </AbsoluteFill>
  );
};

export const Video: React.FC<{music?: string}> = ({music = 'music-placeholder.m4a'}) => {
  const frame = useCurrentFrame();
  const promise = timeline.placed.find((b) => b.id === 'promise')!;
  // The phone fades away when the closing graphics begin.
  const phoneOpacity = interpolate(frame, [promise.start - 4, promise.start + 8], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{backgroundColor: colors.bgTop}}>
      <Background />

      <div
        style={{
          position: 'absolute',
          left: phoneLeft,
          top: layout.phoneTop,
          width: phoneW,
          height: phoneH,
          borderRadius: 66,
          background: colors.bezel,
          boxShadow: '0 40px 90px rgba(0,0,0,0.5), inset 0 0 0 2px rgba(255,255,255,0.08)',
          opacity: phoneOpacity,
        }}
      >
        <div
          style={{
            position: 'absolute',
            left: bezel,
            top: bezel,
            width: screenW,
            height: screenH,
            borderRadius: 52,
            overflow: 'hidden',
            background: '#000',
          }}
        >
          {timeline.placed
            .filter((b) => (b.kind ?? 'clips') === 'clips')
            .map((b) => (
              <Sequence key={b.id} from={b.start} durationInFrames={b.frames} layout="none">
                <Screen beat={b} />
              </Sequence>
            ))}
        </div>
      </div>

      {timeline.placed
        .filter((b) => b.caption)
        .map((b) => (
          <Sequence key={`c-${b.id}`} from={b.start} durationInFrames={b.frames} layout="none">
            <Caption text={b.caption as string} frames={b.frames} />
          </Sequence>
        ))}

      <Sequence from={promise.start} durationInFrames={promise.frames} layout="none">
        <Promise frames={promise.frames} />
      </Sequence>
      {(() => {
        const end = timeline.placed.find((b) => b.id === 'end')!;
        return (
          <Sequence from={end.start} durationInFrames={end.frames} layout="none">
            <EndCard frames={end.frames} />
          </Sequence>
        );
      })()}

      <Audio
        src={staticFile(music)}
        volume={(f) => interpolate(f, [0, 60, timeline.total - 120, timeline.total], [0, 0.85, 0.85, 0], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        })}
      />
    </AbsoluteFill>
  );
};
