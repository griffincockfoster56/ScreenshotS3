import React from "react";
import {
  TransitionSeries,
  linearTiming,
} from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { TitleScene } from "./scenes/TitleScene";
import { ScreenshotScene } from "./scenes/ScreenshotScene";
import { UploadScene } from "./scenes/UploadScene";
import { ClipboardScene } from "./scenes/ClipboardScene";
import { CTAScene } from "./scenes/CTAScene";

export const Video: React.FC = () => {
  const transitionDuration = 15; // frames

  return (
    <TransitionSeries>
      {/* Scene 1: Title (0-4s = 120 frames) */}
      <TransitionSeries.Sequence durationInFrames={120}>
        <TitleScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      {/* Scene 2: Take Screenshot (4-8s = 120 frames) */}
      <TransitionSeries.Sequence durationInFrames={120}>
        <ScreenshotScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      {/* Scene 3: Auto Upload (8-11s = 90 frames) */}
      <TransitionSeries.Sequence durationInFrames={105}>
        <UploadScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      {/* Scene 4: Link Copied (11-14s = 90 frames) */}
      <TransitionSeries.Sequence durationInFrames={105}>
        <ClipboardScene />
      </TransitionSeries.Sequence>

      <TransitionSeries.Transition
        presentation={fade()}
        timing={linearTiming({ durationInFrames: transitionDuration })}
      />

      {/* Scene 5: CTA (14-15s = 45 frames) */}
      <TransitionSeries.Sequence durationInFrames={45}>
        <CTAScene />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  );
};
