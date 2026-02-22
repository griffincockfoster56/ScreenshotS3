import React from "react";
import { AbsoluteFill } from "remotion";

const MOCK_SCREENSHOTS = [
  { name: "screenshot-2024-02-22-at-14.32.png", date: "Feb 22, 2024 at 2:32 PM", color: "#1a3a5c" },
  { name: "screenshot-2024-02-21-at-09.15.png", date: "Feb 21, 2024 at 9:15 AM", color: "#2d1a4e" },
  { name: "screenshot-2024-02-20-at-16.48.png", date: "Feb 20, 2024 at 4:48 PM", color: "#1a4a3a" },
  { name: "screenshot-2024-02-19-at-11.02.png", date: "Feb 19, 2024 at 11:02 AM", color: "#3a2a1a" },
  { name: "screenshot-2024-02-18-at-22.37.png", date: "Feb 18, 2024 at 10:37 PM", color: "#1a2a4a" },
  { name: "screenshot-2024-02-17-at-08.55.png", date: "Feb 17, 2024 at 8:55 AM", color: "#3a1a3a" },
];

const MockThumbnailImage: React.FC<{ color: string; index: number }> = ({ color, index }) => {
  // Each thumbnail gets a unique "screenshot-like" appearance
  const patterns = [
    // Code editor look
    <>
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 24, background: "rgba(0,0,0,0.4)", display: "flex", alignItems: "center", gap: 5, padding: "0 8px" }}>
        <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#ff5f57" }} />
        <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#febc2e" }} />
        <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#28c840" }} />
      </div>
      <div style={{ padding: "32px 12px 8px", display: "flex", flexDirection: "column", gap: 4 }}>
        <div style={{ height: 4, width: "70%", borderRadius: 2, background: "rgba(102,126,234,0.4)" }} />
        <div style={{ height: 4, width: "50%", borderRadius: 2, background: "rgba(255,255,255,0.15)" }} />
        <div style={{ height: 4, width: "85%", borderRadius: 2, background: "rgba(118,75,162,0.4)" }} />
        <div style={{ height: 4, width: "40%", borderRadius: 2, background: "rgba(255,255,255,0.1)" }} />
        <div style={{ height: 4, width: "65%", borderRadius: 2, background: "rgba(102,126,234,0.3)" }} />
      </div>
    </>,
    // Dashboard look
    <>
      <div style={{ padding: 10, display: "flex", flexDirection: "column", gap: 6 }}>
        <div style={{ display: "flex", gap: 6 }}>
          <div style={{ flex: 1, height: 35, borderRadius: 4, background: "rgba(102,126,234,0.2)", border: "1px solid rgba(102,126,234,0.15)" }} />
          <div style={{ flex: 1, height: 35, borderRadius: 4, background: "rgba(118,75,162,0.2)", border: "1px solid rgba(118,75,162,0.15)" }} />
        </div>
        <div style={{ height: 40, borderRadius: 4, background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.06)" }} />
      </div>
    </>,
    // Chat/message look
    <>
      <div style={{ padding: "10px 10px", display: "flex", flexDirection: "column", gap: 6 }}>
        <div style={{ display: "flex", gap: 6, alignItems: "flex-start" }}>
          <div style={{ width: 20, height: 20, borderRadius: "50%", background: "rgba(102,126,234,0.4)", flexShrink: 0 }} />
          <div style={{ height: 22, borderRadius: 8, background: "rgba(255,255,255,0.08)", flex: 1 }} />
        </div>
        <div style={{ display: "flex", gap: 6, alignItems: "flex-start", justifyContent: "flex-end" }}>
          <div style={{ height: 28, borderRadius: 8, background: "rgba(102,126,234,0.25)", width: "70%" }} />
        </div>
        <div style={{ display: "flex", gap: 6, alignItems: "flex-start" }}>
          <div style={{ width: 20, height: 20, borderRadius: "50%", background: "rgba(118,75,162,0.4)", flexShrink: 0 }} />
          <div style={{ height: 18, borderRadius: 8, background: "rgba(255,255,255,0.06)", width: "55%" }} />
        </div>
      </div>
    </>,
    // Terminal look
    <>
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 22, background: "rgba(0,0,0,0.5)", display: "flex", alignItems: "center", padding: "0 8px" }}>
        <div style={{ fontSize: 7, color: "rgba(255,255,255,0.3)", fontFamily: "monospace" }}>Terminal</div>
      </div>
      <div style={{ padding: "28px 8px 8px", display: "flex", flexDirection: "column", gap: 3 }}>
        <div style={{ height: 3, width: "80%", borderRadius: 1, background: "rgba(74,222,128,0.4)" }} />
        <div style={{ height: 3, width: "60%", borderRadius: 1, background: "rgba(255,255,255,0.15)" }} />
        <div style={{ height: 3, width: "90%", borderRadius: 1, background: "rgba(255,255,255,0.1)" }} />
        <div style={{ height: 3, width: "45%", borderRadius: 1, background: "rgba(74,222,128,0.3)" }} />
        <div style={{ height: 3, width: "70%", borderRadius: 1, background: "rgba(255,255,255,0.1)" }} />
      </div>
    </>,
    // Browser look
    <>
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 24, background: "rgba(0,0,0,0.3)", display: "flex", alignItems: "center", gap: 5, padding: "0 8px" }}>
        <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#ff5f57" }} />
        <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#febc2e" }} />
        <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#28c840" }} />
        <div style={{ flex: 1, height: 12, borderRadius: 4, background: "rgba(255,255,255,0.08)", marginLeft: 8 }} />
      </div>
      <div style={{ padding: "32px 10px 8px", display: "flex", flexDirection: "column", gap: 5 }}>
        <div style={{ height: 8, width: "50%", borderRadius: 2, background: "rgba(255,255,255,0.15)" }} />
        <div style={{ height: 4, width: "90%", borderRadius: 2, background: "rgba(255,255,255,0.06)" }} />
        <div style={{ height: 4, width: "75%", borderRadius: 2, background: "rgba(255,255,255,0.06)" }} />
        <div style={{ height: 30, borderRadius: 4, background: "rgba(102,126,234,0.15)", marginTop: 2 }} />
      </div>
    </>,
    // Settings/form look
    <>
      <div style={{ padding: 10, display: "flex", flexDirection: "column", gap: 8 }}>
        <div style={{ height: 6, width: "40%", borderRadius: 2, background: "rgba(255,255,255,0.2)" }} />
        <div style={{ height: 20, borderRadius: 4, background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)" }} />
        <div style={{ height: 6, width: "35%", borderRadius: 2, background: "rgba(255,255,255,0.2)" }} />
        <div style={{ height: 20, borderRadius: 4, background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)" }} />
      </div>
    </>,
  ];

  return (
    <div
      style={{
        width: "100%",
        height: 120,
        background: `linear-gradient(135deg, ${color}, ${color}88)`,
        position: "relative",
        overflow: "hidden",
      }}
    >
      {patterns[index % patterns.length]}
    </div>
  );
};

const Thumbnail: React.FC<{ name: string; date: string; color: string; index: number }> = ({
  name,
  date,
  color,
  index,
}) => {
  return (
    <div
      style={{
        borderRadius: 12,
        overflow: "hidden",
        background: "rgba(255,255,255,0.06)",
        border: "1px solid rgba(255,255,255,0.08)",
      }}
    >
      <MockThumbnailImage color={color} index={index} />
      <div style={{ padding: "10px 10px" }}>
        <div
          style={{
            fontSize: 11,
            fontWeight: 600,
            color: "rgba(255,255,255,0.7)",
            whiteSpace: "nowrap",
            overflow: "hidden",
            textOverflow: "ellipsis",
          }}
        >
          {name}
        </div>
        <div
          style={{
            fontSize: 10,
            color: "rgba(255,255,255,0.3)",
            marginTop: 4,
          }}
        >
          {date}
        </div>
      </div>
    </div>
  );
};

export const GalleryStill: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        background: "linear-gradient(180deg, #06060f 0%, #0d0d24 30%, #151535 50%, #0d0d24 70%, #06060f 100%)",
        fontFamily: "Inter, system-ui, sans-serif",
        color: "white",
        padding: 0,
      }}
    >
      {/* macOS window chrome */}
      <div
        style={{
          margin: "40px auto",
          width: 580,
          borderRadius: 12,
          overflow: "hidden",
          border: "1px solid rgba(255,255,255,0.1)",
          background: "rgba(10,10,30,0.95)",
          boxShadow: "0 25px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.05)",
        }}
      >
        {/* Title bar */}
        <div
          style={{
            height: 40,
            display: "flex",
            alignItems: "center",
            padding: "0 14px",
            background: "rgba(0,0,0,0.3)",
            borderBottom: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <div style={{ display: "flex", gap: 7 }}>
            <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#ff5f57" }} />
            <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#febc2e" }} />
            <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#28c840" }} />
          </div>
          <div
            style={{
              flex: 1,
              textAlign: "center",
              fontSize: 12,
              color: "rgba(255,255,255,0.4)",
              fontWeight: 500,
            }}
          >
            Screenshot S3
          </div>
          <div style={{ width: 52 }} />
        </div>

        {/* Gallery header */}
        <div
          style={{
            padding: "20px 24px 16px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <div>
            <div style={{ fontSize: 28, fontWeight: 700 }}>Gallery</div>
            <div style={{ fontSize: 13, color: "rgba(255,255,255,0.4)", marginTop: 4 }}>
              6 screenshots
            </div>
          </div>
          <div
            style={{
              width: 36,
              height: 36,
              borderRadius: 10,
              background: "rgba(255,255,255,0.06)",
              border: "1px solid rgba(255,255,255,0.08)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="rgba(255,255,255,0.5)"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <polyline points="23 4 23 10 17 10" />
              <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10" />
            </svg>
          </div>
        </div>

        {/* Divider */}
        <div
          style={{
            height: 1,
            background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent)",
          }}
        />

        {/* Grid */}
        <div
          style={{
            padding: "16px 24px 24px",
            display: "grid",
            gridTemplateColumns: "repeat(3, 1fr)",
            gap: 16,
          }}
        >
          {MOCK_SCREENSHOTS.map((s, i) => (
            <Thumbnail key={i} name={s.name} date={s.date} color={s.color} index={i} />
          ))}
        </div>
      </div>
    </AbsoluteFill>
  );
};
