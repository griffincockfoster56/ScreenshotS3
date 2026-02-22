import React from "react";
import { Composition, Still } from "remotion";
import { Video } from "./Video";
import { GalleryStill } from "./scenes/GalleryStill";
import {
  Feature1_AutoUpload,
  Feature2_Clipboard,
  Feature3_Gallery,
  Feature4_MenuBar,
  Feature5_OpenSource,
} from "./scenes/FeatureStills";

// Total: 120 + 120 + 105 + 105 + 45 - (4 * 15) = 435 frames
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="Video"
        component={Video}
        durationInFrames={435}
        fps={30}
        width={1920}
        height={1080}
      />
      <Still
        id="GalleryScreenshot"
        component={GalleryStill}
        width={1200}
        height={800}
      />
      <Still id="Feature-AutoUpload" component={Feature1_AutoUpload} width={1920} height={1080} />
      <Still id="Feature-Clipboard" component={Feature2_Clipboard} width={1920} height={1080} />
      <Still id="Feature-Gallery" component={Feature3_Gallery} width={1920} height={1080} />
      <Still id="Feature-MenuBar" component={Feature4_MenuBar} width={1920} height={1080} />
      <Still id="Feature-OpenSource" component={Feature5_OpenSource} width={1920} height={1080} />
    </>
  );
};
