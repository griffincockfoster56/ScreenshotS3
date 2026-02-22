import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Background } from "../components/Background";

export const UploadScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Step badge
  const badgeScale = spring({ frame, fps, config: { damping: 15 } });

  // Title fade
  const titleProgress = spring({
    frame: Math.max(0, frame - 10),
    fps,
    config: { damping: 200 },
  });

  // File icon rises up
  const fileProgress = spring({
    frame: Math.max(0, frame - 20),
    fps,
    config: { damping: 200 },
  });
  const fileY = interpolate(fileProgress, [0, 1], [80, 0]);

  // Arrow animates upward continuously
  const arrowY = interpolate(frame, [30, 90], [0, -60], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const arrowOpacity = interpolate(frame, [30, 50, 70, 90], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // S3 bucket icon fades in
  const bucketProgress = spring({
    frame: Math.max(0, frame - 15),
    fps,
    config: { damping: 200 },
  });

  // Progress bar
  const progressWidth = interpolate(frame, [25, 75], [0, 100], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Checkmark appears
  const checkProgress = spring({
    frame: Math.max(0, frame - 75),
    fps,
    config: { damping: 12 },
  });

  return (
    <Background>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 36,
        }}
      >
        {/* Step indicator */}
        <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
          <div
            style={{
              width: 48,
              height: 48,
              borderRadius: "50%",
              background: "linear-gradient(135deg, #667eea, #764ba2)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 22,
              fontWeight: 700,
              transform: `scale(${badgeScale})`,
            }}
          >
            2
          </div>
          <div
            style={{
              fontSize: 36,
              fontWeight: 700,
              opacity: titleProgress,
            }}
          >
            Auto upload to S3
          </div>
        </div>

        {/* Upload visualization */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 24,
            position: "relative",
            height: 240,
            justifyContent: "center",
          }}
        >
          {/* S3 Bucket icon at top */}
          <div
            style={{
              opacity: bucketProgress,
              transform: `scale(${bucketProgress})`,
              width: 80,
              height: 80,
              borderRadius: 20,
              background: "linear-gradient(135deg, #667eea, #764ba2)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg
              width="40"
              height="40"
              viewBox="0 0 24 24"
              fill="none"
              stroke="white"
              strokeWidth="2"
            >
              <ellipse cx="12" cy="5" rx="9" ry="3" />
              <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3" />
              <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5" />
            </svg>
          </div>

          {/* Upload arrow */}
          <div
            style={{
              opacity: arrowOpacity,
              transform: `translateY(${arrowY}px)`,
            }}
          >
            <svg
              width="32"
              height="32"
              viewBox="0 0 24 24"
              fill="none"
              stroke="#667eea"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="17 8 12 3 7 8" />
              <line x1="12" y1="3" x2="12" y2="21" />
            </svg>
          </div>

          {/* File icon at bottom */}
          <div
            style={{
              opacity: fileProgress,
              transform: `translateY(${fileY}px)`,
              width: 64,
              height: 80,
              background: "rgba(255,255,255,0.1)",
              border: "1px solid rgba(255,255,255,0.2)",
              borderRadius: 8,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg
              width="32"
              height="32"
              viewBox="0 0 24 24"
              fill="none"
              stroke="rgba(255,255,255,0.6)"
              strokeWidth="1.5"
            >
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <circle cx="8.5" cy="8.5" r="1.5" />
              <polyline points="21 15 16 10 5 21" />
            </svg>
          </div>
        </div>

        {/* Progress bar */}
        <div
          style={{
            width: 300,
            height: 6,
            borderRadius: 3,
            background: "rgba(255,255,255,0.1)",
            overflow: "hidden",
          }}
        >
          <div
            style={{
              width: `${progressWidth}%`,
              height: "100%",
              borderRadius: 3,
              background: "linear-gradient(90deg, #667eea, #764ba2)",
            }}
          />
        </div>

        {/* Checkmark */}
        {checkProgress > 0 && (
          <div
            style={{
              fontSize: 24,
              fontWeight: 600,
              color: "#4ade80",
              opacity: checkProgress,
              transform: `scale(${checkProgress})`,
              display: "flex",
              alignItems: "center",
              gap: 8,
            }}
          >
            <svg
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              stroke="#4ade80"
              strokeWidth="3"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="20 6 9 17 4 12" />
            </svg>
            Uploaded
          </div>
        )}
      </div>
    </Background>
  );
};
