import React from 'react';
import {Composition} from 'remotion';
import {Video} from './Video';
import {Poster, posters, PW, PH} from './posters/Poster';
import {VideoV2, durationInFrames as v2Frames} from './v2/Video';
import {FPS, timeline} from './timeline';
import {layout} from './theme';

export const RemotionRoot: React.FC = () => (
  <>
    {/* Music-only cut. Voiceover cuts (Cut-ta, Cut-en) will reuse Video with their own audio and timing. */}
    <Composition
      id="Cut-music"
      component={Video}
      durationInFrames={timeline.total}
      fps={FPS}
      width={layout.width}
      height={layout.height}
    />
    {/* v2: cleaner, modern cut with the 1.7.0 features (see marketing/STATUS.md). */}
    <Composition id="Cut-v2" component={VideoV2} durationInFrames={v2Frames} fps={30} width={1080} height={1920} />
    {/* Instagram posters (4:5): npm run posters */}
    {posters.map((p) => (
      <Composition key={p.id} id={`Poster-${p.id}`} component={() => <Poster spec={p} />} durationInFrames={1} fps={30} width={PW} height={PH} />
    ))}
  </>
);
