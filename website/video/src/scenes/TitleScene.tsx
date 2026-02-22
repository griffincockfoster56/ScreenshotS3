import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Background } from "../components/Background";

export const TitleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Logo bucket icon scales in with spring
  const logoScale = spring({ frame, fps, config: { damping: 200 } });

  // Title slides up and fades in
  const titleProgress = spring({
    frame: Math.max(0, frame - 10),
    fps,
    config: { damping: 200 },
  });
  const titleY = interpolate(titleProgress, [0, 1], [40, 0]);
  const titleOpacity = titleProgress;

  // Tagline fades in after title
  const taglineProgress = spring({
    frame: Math.max(0, frame - 25),
    fps,
    config: { damping: 200 },
  });
  const taglineOpacity = taglineProgress;
  const taglineY = interpolate(taglineProgress, [0, 1], [20, 0]);

  return (
    <Background>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 24,
        }}
      >
        {/* S3 bucket icon */}
        <div
          style={{
            transform: `scale(${logoScale})`,
            width: 100,
            height: 100,
            borderRadius: 24,
            background: "linear-gradient(135deg, #667eea, #764ba2)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 48,
          }}
        >
          <svg
            width="56"
            height="56"
            viewBox="0 0 24 24"
            fill="none"
            stroke="white"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="17 8 12 3 7 8" />
            <line x1="12" y1="3" x2="12" y2="15" />
          </svg>
        </div>

        {/* Title */}
        <div
          style={{
            fontSize: 72,
            fontWeight: 800,
            letterSpacing: -2,
            opacity: titleOpacity,
            transform: `translateY(${titleY}px)`,
            background: "linear-gradient(135deg, #fff 0%, rgba(255,255,255,0.7) 100%)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            backgroundClip: "text",
          }}
        >
          Screenshot S3
        </div>

        {/* Tagline */}
        <div
          style={{
            fontSize: 28,
            fontWeight: 400,
            color: "rgba(255,255,255,0.6)",
            opacity: taglineOpacity,
            transform: `translateY(${taglineY}px)`,
            maxWidth: 700,
            textAlign: "center",
            lineHeight: 1.4,
          }}
        >
          Instantly upload screenshots to S3.
          <br />
          Link copied to your clipboard.
        </div>
      </div>
    </Background>
  );
};
