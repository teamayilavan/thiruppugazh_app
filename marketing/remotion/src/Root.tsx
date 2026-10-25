import React from 'react';
import {Composition} from 'remotion';
import {Video} from './Video';
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
  </>
);
