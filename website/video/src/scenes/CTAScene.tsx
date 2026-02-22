import React from "react";
import { useCurrentFrame, useVideoConfig, spring, interpolate } from "remotion";
import { Background } from "../components/Background";

export const CTAScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const scale = spring({ frame, fps, config: { damping: 200 } });
  const opacity = interpolate(frame, [0, 0.5 * fps], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <Background>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 20,
          opacity,
          transform: `scale(${scale})`,
        }}
      >
        <div
          style={{
            fontSize: 48,
            fontWeight: 800,
            background:
              "linear-gradient(135deg, #fff 0%, rgba(255,255,255,0.7) 100%)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            backgroundClip: "text",
          }}
        >
          Free & Open Source
        </div>
        <div
          style={{
            fontSize: 24,
            color: "rgba(255,255,255,0.5)",
          }}
        >
          github.com/griffincockfoster/s3-screenshot-app
        </div>
      </div>
    </Background>
  );
};
