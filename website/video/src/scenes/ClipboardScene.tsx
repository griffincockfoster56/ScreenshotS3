import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Background } from "../components/Background";

export const ClipboardScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Step badge
  const badgeScale = spring({ frame, fps, config: { damping: 15 } });

  // Title
  const titleProgress = spring({
    frame: Math.max(0, frame - 10),
    fps,
    config: { damping: 200 },
  });

  // URL typing effect
  const url = "https://your-bucket.s3.amazonaws.com/screenshot-2024.png";
  const charsVisible = Math.min(
    url.length,
    Math.max(0, Math.floor((frame - 25) * 1.5))
  );
  const displayUrl = url.slice(0, charsVisible);

  // Cursor blink
  const cursorVisible =
    charsVisible < url.length ? Math.floor(frame / 8) % 2 === 0 : false;

  // "Copied!" popup
  const copiedProgress = spring({
    frame: Math.max(0, frame - 65),
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
            3
          </div>
          <div
            style={{
              fontSize: 36,
              fontWeight: 700,
              opacity: titleProgress,
            }}
          >
            Link copied to clipboard
          </div>
        </div>

        {/* URL display */}
        <div
          style={{
            padding: "20px 32px",
            background: "rgba(255,255,255,0.06)",
            border: "1px solid rgba(255,255,255,0.12)",
            borderRadius: 12,
            fontSize: 20,
            fontFamily: "monospace",
            color: "#667eea",
            minWidth: 600,
            textAlign: "center",
            position: "relative",
          }}
        >
          {displayUrl}
          {cursorVisible && (
            <span style={{ color: "white", marginLeft: 1 }}>|</span>
          )}
        </div>

        {/* Copied popup */}
        {copiedProgress > 0 && (
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 12,
              opacity: copiedProgress,
              transform: `scale(${copiedProgress}) translateY(${interpolate(copiedProgress, [0, 1], [20, 0])}px)`,
            }}
          >
            {/* Clipboard icon */}
            <div
              style={{
                width: 56,
                height: 56,
                borderRadius: 14,
                background: "rgba(74, 222, 128, 0.15)",
                border: "1px solid rgba(74, 222, 128, 0.3)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <svg
                width="28"
                height="28"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#4ade80"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <rect x="8" y="2" width="8" height="4" rx="1" ry="1" />
                <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2" />
                <path d="m9 14 2 2 4-4" />
              </svg>
            </div>
            <div
              style={{
                fontSize: 28,
                fontWeight: 700,
                color: "#4ade80",
              }}
            >
              Copied to clipboard!
            </div>
          </div>
        )}
      </div>
    </Background>
  );
};
