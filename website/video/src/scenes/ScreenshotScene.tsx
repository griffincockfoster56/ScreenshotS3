import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Background } from "../components/Background";

export const ScreenshotScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Step badge springs in
  const badgeScale = spring({ frame, fps, config: { damping: 15 } });

  // Keyboard shortcut fades in
  const keysProgress = spring({
    frame: Math.max(0, frame - 15),
    fps,
    config: { damping: 200 },
  });

  // Selection rectangle grows
  const selectionProgress = spring({
    frame: Math.max(0, frame - 40),
    fps,
    config: { damping: 200 },
  });
  const selectionWidth = interpolate(selectionProgress, [0, 1], [0, 480]);
  const selectionHeight = interpolate(selectionProgress, [0, 1], [0, 280]);

  // Dashed border animation
  const dashOffset = interpolate(frame, [0, 120], [0, 100]);

  return (
    <Background>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 40,
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
            1
          </div>
          <div
            style={{
              fontSize: 36,
              fontWeight: 700,
              opacity: keysProgress,
            }}
          >
            Take a screenshot
          </div>
        </div>

        {/* Keyboard shortcut keys */}
        <div
          style={{
            display: "flex",
            gap: 8,
            opacity: keysProgress,
            transform: `translateY(${interpolate(keysProgress, [0, 1], [20, 0])}px)`,
          }}
        >
          {["Cmd", "Shift", "4"].map((key, i) => (
            <React.Fragment key={key}>
              <div
                style={{
                  padding: "12px 20px",
                  fontSize: 24,
                  fontWeight: 600,
                  background: "rgba(102, 126, 234, 0.15)",
                  border: "1px solid rgba(102, 126, 234, 0.3)",
                  borderRadius: 10,
                  color: "#667eea",
                }}
              >
                {key}
              </div>
              {i < 2 && (
                <div
                  style={{
                    fontSize: 24,
                    color: "rgba(255,255,255,0.3)",
                    display: "flex",
                    alignItems: "center",
                  }}
                >
                  +
                </div>
              )}
            </React.Fragment>
          ))}
        </div>

        {/* Screenshot selection rectangle */}
        <div
          style={{
            position: "relative",
            width: selectionWidth,
            height: selectionHeight,
            overflow: "visible",
          }}
        >
          <svg
            width={selectionWidth}
            height={selectionHeight}
            style={{ position: "absolute", top: 0, left: 0 }}
          >
            <rect
              x="2"
              y="2"
              width={Math.max(0, selectionWidth - 4)}
              height={Math.max(0, selectionHeight - 4)}
              fill="rgba(102, 126, 234, 0.08)"
              stroke="#667eea"
              strokeWidth="2"
              strokeDasharray="8 4"
              strokeDashoffset={dashOffset}
              rx="4"
            />
          </svg>
        </div>
      </div>
    </Background>
  );
};
