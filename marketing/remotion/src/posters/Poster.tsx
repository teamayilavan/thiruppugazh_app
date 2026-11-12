import React from 'react';
import {AbsoluteFill, Img, staticFile} from 'remotion';
import {Check} from '@phosphor-icons/react';
import {c, font} from '../v2/theme';

// Instagram feed posters, 4:5 portrait. Same visual language as the video (see src/v2).
export const PW = 1080;
export const PH = 1350;
const PAD = 72;

export type PosterSpec = {
  id: string;
  title: string; // `|` breaks a line, *asterisks* take the accent colour
  sub?: string;
  chip?: string;
  device?: 'phone' | 'tablet';
  shot?: string; // file in public/posters
  tilt?: number;
  kind?: 'feature' | 'brand' | 'promise';
};

const Background: React.FC = () => (
  <AbsoluteFill
    style={{
      background: [
        `radial-gradient(1000px 1000px at 22% 18%, ${c.glow}66 0%, transparent 62%)`,
        `radial-gradient(900px 900px at 85% 80%, #1B5A34 0%, transparent 60%)`,
        `linear-gradient(180deg, ${c.bg}, ${c.bgDeep})`,
      ].join(','),
    }}
  />
);

const Title: React.FC<{text: string; size?: number}> = ({text, size = 84}) => (
  <div style={{fontFamily: font.display, fontWeight: 700, fontSize: size, lineHeight: 1.04, letterSpacing: -2.4, color: c.text}}>
    {text.split('|').map((line, li) => (
      <div key={li} style={{whiteSpace: 'nowrap'}}>
        {line.split('*').map((part, i) => (
          <span key={i} style={{color: i % 2 ? c.accent : c.text}}>
            {part}
          </span>
        ))}
      </div>
    ))}
  </div>
);

const Chip: React.FC<{text: string}> = ({text}) => (
  <div
    style={{
      display: 'inline-block',
      padding: '8px 22px',
      borderRadius: 999,
      background: c.accent,
      color: c.accentInk,
      fontFamily: font.display,
      fontWeight: 700,
      fontSize: 30,
      letterSpacing: 0.4,
    }}
  >
    {text}
  </div>
);

const Mark: React.FC<{size?: number}> = ({size = 84}) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: size * 0.26,
      background: c.tile,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      boxShadow: '0 12px 30px rgba(2,12,6,0.45)',
    }}
  >
    <Img src={staticFile('img/app-icon.png')} style={{width: '82%', height: '82%'}} />
  </div>
);

const Device: React.FC<{spec: PosterSpec}> = ({spec}) => {
  const isTablet = spec.device === 'tablet';
  const sw = isTablet ? 960 : 620;
  const sh = isTablet ? 600 : Math.round((620 * 2400) / 1080);
  const bz = isTablet ? 20 : 12;
  const outerW = sw + bz * 2;
  return (
    <div
      style={{
        position: 'absolute',
        left: (PW - outerW) / 2,
        top: isTablet ? 520 : 500,
        width: outerW,
        height: sh + bz * 2,
        borderRadius: isTablet ? 40 : 62,
        background: c.bezel,
        boxShadow: `0 50px 110px rgba(2,12,6,0.65), 0 0 0 2px rgba(238,245,234,0.1), 0 0 150px ${c.glow}50`,
        transform: `rotate(${spec.tilt ?? 0}deg)`,
      }}
    >
      <div
        style={{
          position: 'absolute',
          inset: bz,
          borderRadius: isTablet ? 22 : 50,
          overflow: 'hidden',
          background: '#000',
        }}
      >
        <Img src={staticFile(`posters/${spec.shot}`)} style={{width: sw, height: sh, objectFit: 'cover'}} />
      </div>
    </div>
  );
};

const Feature: React.FC<{spec: PosterSpec}> = ({spec}) => (
  <AbsoluteFill>
    <Background />
    <div style={{position: 'absolute', right: PAD, top: 56}}>
      <Mark />
    </div>
    <div style={{position: 'absolute', left: PAD, top: 64}}>{spec.chip ? <Chip text={spec.chip} /> : null}</div>
    <div style={{position: 'absolute', left: PAD, top: 124}}>
      <Title text={spec.title} />
    </div>
    {spec.sub ? (
      <div
        style={{
          position: 'absolute',
          left: PAD,
          top: 322,
          width: 800,
          fontFamily: font.display,
          fontSize: 36,
          lineHeight: 1.28,
          color: c.muted,
        }}
      >
        {spec.sub}
      </div>
    ) : null}
    <Device spec={spec} />
    {spec.device === 'tablet' ? (
      <div style={{position: 'absolute', left: PAD, right: PAD, bottom: 70, display: 'flex', alignItems: 'center', gap: 22}}>
        <Mark size={72} />
        <div style={{fontFamily: font.display, fontWeight: 700, fontSize: 52, color: c.text, letterSpacing: -1.5}}>Thiruppugazh</div>
      </div>
    ) : null}
  </AbsoluteFill>
);

const Brand: React.FC = () => (
  <AbsoluteFill>
    <Background />
    <div style={{position: 'absolute', left: 0, top: 0, width: PW, height: 760, overflow: 'hidden'}}>
      <Img src={staticFile('posters/hero.jpg')} style={{width: PW, height: PW, objectFit: 'cover', objectPosition: 'center 8%'}} />
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `linear-gradient(180deg, rgba(8,32,15,0) 45%, ${c.bg}f2 92%, ${c.bg} 100%)`,
        }}
      />
    </div>
    <div style={{position: 'absolute', left: PAD, right: PAD, top: 700}}>
      <div style={{display: 'flex', alignItems: 'center', gap: 28}}>
        <Mark size={120} />
        <div>
          <div style={{fontFamily: font.display, fontWeight: 800, fontSize: 104, letterSpacing: -3.5, color: c.text, lineHeight: 1}}>
            Thiruppugazh
          </div>
          <div style={{fontFamily: font.tamil, fontWeight: 600, fontSize: 56, color: c.accent, marginTop: 6}}>திருப்புகழ்</div>
        </div>
      </div>
      <div style={{marginTop: 48}}>
        <Title text={'All 1,340 songs,|*in one quiet app.*'} size={68} />
      </div>
    </div>
    <Img src={staticFile('img/google-play-badge.png')} style={{position: 'absolute', left: PAD, bottom: 64, width: 380}} />
    <div style={{position: 'absolute', right: PAD, bottom: 84, fontFamily: font.display, fontSize: 32, color: c.muted}}>
      Offline. No ads.
    </div>
  </AbsoluteFill>
);

const rows = ['No ads', 'No tracking', 'No accounts', 'Works offline', 'Backed up through your own Google account'];

const Promise: React.FC = () => (
  <AbsoluteFill>
    <Background />
    <div style={{position: 'absolute', right: PAD, top: 56}}>
      <Mark />
    </div>
    <div style={{position: 'absolute', left: PAD, top: 124}}>
      <Title text={'Made to stay|*out of your way.*'} />
    </div>
    <div style={{position: 'absolute', left: PAD, right: PAD, top: 400, display: 'flex', flexDirection: 'column', gap: 44}}>
      {rows.map((row) => (
        <div
          key={row}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 32,
            fontFamily: font.display,
            fontWeight: 600,
            fontSize: row.length > 20 ? 50 : 66,
            lineHeight: 1.1,
            letterSpacing: -1,
            color: c.text,
          }}
        >
          <span
            style={{
              flex: '0 0 88px',
              height: 88,
              borderRadius: 26,
              background: c.accent,
              color: c.accentInk,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Check size={52} weight="bold" />
          </span>
          <span>{row}</span>
        </div>
      ))}
    </div>
    <Img src={staticFile('img/google-play-badge.png')} style={{position: 'absolute', left: PAD, bottom: 64, width: 380}} />
    <div style={{position: 'absolute', right: PAD, bottom: 84, fontFamily: font.display, fontSize: 30, color: c.muted}}>
      Open source under AGPL-3.0
    </div>
  </AbsoluteFill>
);

export const Poster: React.FC<{spec: PosterSpec}> = ({spec}) => {
  if (spec.kind === 'brand') return <Brand />;
  if (spec.kind === 'promise') return <Promise />;
  return <Feature spec={spec} />;
};

export const posters: PosterSpec[] = [
  {id: 'brand', title: '', kind: 'brand'},
  {id: 'search', title: 'Type it|*the way it sounds.*', sub: 'Spelling forgiven. Search shows the line that matched.', chip: 'New in 1.7', device: 'phone', shot: 'search_end.png', tilt: -2},
  {id: 'meaning', title: 'Understand|*every word.*', sub: 'Word-by-word meanings on many songs, with the full meaning below.', device: 'phone', shot: 'meaning.png', tilt: 2},
  {id: 'temples', title: 'Visit the|*six abodes.*', sub: 'Browse every song by temple, starting with Arupadai Veedu.', device: 'phone', shot: 'temples.png', tilt: -2},
  {id: 'chanting', title: 'Chant,|*one verse at a time.*', sub: 'Large text, a tune cue, and an auto pace you choose.', device: 'phone', shot: 'chanting.png', tilt: 2},
  {id: 'widget', title: 'Today’s song,|*on your home screen.*', sub: 'A widget that opens the song with one tap.', chip: 'New in 1.7', device: 'phone', shot: 'widget.png', tilt: -2},
  {id: 'language', title: 'Your language.|*Your light.*', sub: 'Tamil or English lyrics, larger text, a dark theme for night.', device: 'phone', shot: 'dark_home.png', tilt: 2},
  {id: 'tablet', title: 'Made for|*tablets, too.*', sub: 'Songs on the left, the open song on the right.', chip: 'New in 1.7', device: 'tablet', shot: 'tablet.png'},
  {id: 'promise', title: '', kind: 'promise'},
];
