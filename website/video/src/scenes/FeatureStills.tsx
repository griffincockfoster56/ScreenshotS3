import React from "react";
import { AbsoluteFill } from "remotion";

const FeatureLayout: React.FC<{
  title: string;
  subtitle: string;
  children: React.ReactNode;
}> = ({ title, subtitle, children }) => {
  return (
    <AbsoluteFill
      style={{
        background: "linear-gradient(135deg, #0a0a1a 0%, #1a1a3e 100%)",
        fontFamily: "Inter, system-ui, sans-serif",
        color: "white",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: 80,
      }}
    >
      <div
        style={{
          fontSize: 64,
          fontWeight: 800,
          letterSpacing: -2,
          textAlign: "center",
          background:
            "linear-gradient(135deg, #fff 0%, rgba(255,255,255,0.7) 100%)",
          WebkitBackgroundClip: "text",
          WebkitTextFillColor: "transparent",
          backgroundClip: "text",
          lineHeight: 1.1,
          maxWidth: 900,
        }}
      >
        {title}
      </div>
      <div
        style={{
          fontSize: 24,
          color: "rgba(255,255,255,0.5)",
          marginTop: 20,
          textAlign: "center",
          maxWidth: 700,
          lineHeight: 1.5,
        }}
      >
        {subtitle}
      </div>
      <div style={{ marginTop: 60 }}>{children}</div>
    </AbsoluteFill>
  );
};

// ─── Feature 1: Automatic Upload ───

export const Feature1_AutoUpload: React.FC = () => {
  return (
    <FeatureLayout
      title="Automatic Upload"
      subtitle="Screenshots are detected and uploaded to your S3 bucket the moment they're saved. Zero manual steps."
    >
      <div style={{ display: "flex", alignItems: "center", gap: 40 }}>
        {/* Screenshot file */}
        <div
          style={{
            width: 120,
            height: 150,
            borderRadius: 12,
            background: "rgba(255,255,255,0.06)",
            border: "1px solid rgba(255,255,255,0.12)",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            gap: 8,
          }}
        >
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="1.5">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <circle cx="8.5" cy="8.5" r="1.5" />
            <polyline points="21 15 16 10 5 21" />
          </svg>
          <div style={{ fontSize: 11, color: "rgba(255,255,255,0.4)" }}>screenshot.png</div>
        </div>

        {/* Arrow */}
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
          <svg width="64" height="24" viewBox="0 0 64 24" fill="none">
            <path d="M0 12h56m0 0l-8-8m8 8l-8 8" stroke="#667eea" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
          <div style={{ fontSize: 13, color: "#667eea", fontWeight: 600 }}>Instant</div>
        </div>

        {/* S3 Bucket */}
        <div
          style={{
            width: 120,
            height: 150,
            borderRadius: 12,
            background: "linear-gradient(135deg, rgba(102,126,234,0.15), rgba(118,75,162,0.15))",
            border: "1px solid rgba(102,126,234,0.25)",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            gap: 8,
          }}
        >
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#667eea" strokeWidth="1.5">
            <ellipse cx="12" cy="5" rx="9" ry="3" />
            <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3" />
            <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5" />
          </svg>
          <div style={{ fontSize: 11, color: "#667eea" }}>S3 Bucket</div>
        </div>
      </div>
    </FeatureLayout>
  );
};

// ─── Feature 2: Clipboard URL ───

export const Feature2_Clipboard: React.FC = () => {
  return (
    <FeatureLayout
      title="Link Copied Instantly"
      subtitle="The public URL is automatically copied to your clipboard. Just paste it wherever you need it."
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 24,
        }}
      >
        {/* URL bar */}
        <div
          style={{
            padding: "18px 32px",
            background: "rgba(255,255,255,0.06)",
            border: "1px solid rgba(255,255,255,0.12)",
            borderRadius: 12,
            fontSize: 18,
            fontFamily: "monospace",
            color: "#667eea",
            display: "flex",
            alignItems: "center",
            gap: 16,
          }}
        >
          <span>https://your-bucket.s3.amazonaws.com/screenshot.png</span>
        </div>

        {/* Copied badge */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "12px 24px",
            borderRadius: 10,
            background: "rgba(74, 222, 128, 0.1)",
            border: "1px solid rgba(74, 222, 128, 0.25)",
          }}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#4ade80" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="20 6 9 17 4 12" />
          </svg>
          <span style={{ fontSize: 16, fontWeight: 600, color: "#4ade80" }}>
            Copied to clipboard
          </span>
        </div>
      </div>
    </FeatureLayout>
  );
};

// ─── Feature 3: Built-in Gallery ───

export const Feature3_Gallery: React.FC = () => {
  const thumbColors = ["#1a3a5c", "#2d1a4e", "#1a4a3a", "#3a2a1a"];

  return (
    <FeatureLayout
      title="Built-in Gallery"
      subtitle="Browse all your past uploads in a beautiful gallery. Re-copy links or open them anytime."
    >
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(4, 1fr)",
          gap: 16,
          width: 640,
        }}
      >
        {thumbColors.map((color, i) => (
          <div
            key={i}
            style={{
              borderRadius: 12,
              overflow: "hidden",
              background: "rgba(255,255,255,0.06)",
              border: "1px solid rgba(255,255,255,0.08)",
            }}
          >
            <div
              style={{
                height: 90,
                background: `linear-gradient(135deg, ${color}, ${color}88)`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.25)" strokeWidth="1.5">
                <rect x="3" y="3" width="18" height="18" rx="2" />
                <circle cx="8.5" cy="8.5" r="1.5" />
                <polyline points="21 15 16 10 5 21" />
              </svg>
            </div>
            <div style={{ padding: "8px 10px" }}>
              <div style={{ fontSize: 10, color: "rgba(255,255,255,0.5)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                screenshot-{i + 1}.png
              </div>
              <div style={{ fontSize: 9, color: "rgba(255,255,255,0.25)", marginTop: 3 }}>
                Feb {20 - i}, 2024
              </div>
            </div>
          </div>
        ))}
      </div>
    </FeatureLayout>
  );
};

// ─── Feature 4: Menu Bar Native ───

export const Feature4_MenuBar: React.FC = () => {
  return (
    <FeatureLayout
      title="Lives in Your Menu Bar"
      subtitle="No Dock icon, no windows cluttering your workspace. Just a clean, native macOS experience."
    >
      {/* macOS menu bar mockup */}
      <div
        style={{
          width: 700,
          borderRadius: 10,
          overflow: "hidden",
          background: "rgba(30,30,40,0.9)",
          border: "1px solid rgba(255,255,255,0.1)",
          boxShadow: "0 20px 50px rgba(0,0,0,0.4)",
        }}
      >
        {/* Menu bar strip */}
        <div
          style={{
            height: 28,
            background: "rgba(0,0,0,0.5)",
            display: "flex",
            alignItems: "center",
            justifyContent: "flex-end",
            padding: "0 16px",
            gap: 16,
          }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2">
            <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2" />
          </svg>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2">
            <rect x="2" y="2" width="20" height="20" rx="2" />
          </svg>
          {/* Active app icon - highlighted */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 5,
              padding: "2px 8px",
              borderRadius: 4,
              background: "rgba(102,126,234,0.2)",
            }}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#667eea" strokeWidth="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="17 8 12 3 7 8" />
              <line x1="12" y1="3" x2="12" y2="15" />
            </svg>
            <span style={{ fontSize: 11, color: "#667eea", fontWeight: 600 }}>Screenshot S3</span>
          </div>
          <div style={{ fontSize: 12, color: "rgba(255,255,255,0.4)" }}>
            Sat 2:34 PM
          </div>
        </div>

        {/* Dropdown */}
        <div style={{ padding: 12 }}>
          <div style={{ display: "flex", flexDirection: "column", gap: 2 }}>
            {[
              { label: "Open Gallery", icon: "⊞", shortcut: "⌘G" },
              { label: "Settings...", icon: "⚙", shortcut: "⌘," },
              { label: "Quit", icon: "⏻", shortcut: "⌘Q" },
            ].map((item) => (
              <div
                key={item.label}
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "6px 12px",
                  borderRadius: 6,
                  fontSize: 13,
                  color: "rgba(255,255,255,0.7)",
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <span style={{ fontSize: 14, width: 20, textAlign: "center" }}>{item.icon}</span>
                  {item.label}
                </div>
                <span style={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>{item.shortcut}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </FeatureLayout>
  );
};

// ─── Feature 5: Open Source ───

export const Feature5_OpenSource: React.FC = () => {
  return (
    <FeatureLayout
      title="100% Open Source"
      subtitle="No tracking. No telemetry. No hidden anything. Inspect the code, contribute, or fork it."
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 24,
        }}
      >
        {/* GitHub icon */}
        <div
          style={{
            width: 88,
            height: 88,
            borderRadius: 22,
            background: "rgba(255,255,255,0.06)",
            border: "1px solid rgba(255,255,255,0.12)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <svg width="48" height="48" viewBox="0 0 24 24" fill="rgba(255,255,255,0.7)">
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z" />
          </svg>
        </div>

        {/* Badges */}
        <div style={{ display: "flex", gap: 12 }}>
          {["MIT License", "No Telemetry", "Community Driven"].map((badge) => (
            <div
              key={badge}
              style={{
                padding: "10px 20px",
                borderRadius: 10,
                background: "rgba(102,126,234,0.1)",
                border: "1px solid rgba(102,126,234,0.2)",
                fontSize: 14,
                fontWeight: 600,
                color: "#667eea",
              }}
            >
              {badge}
            </div>
          ))}
        </div>

        <div style={{ fontSize: 16, color: "rgba(255,255,255,0.35)" }}>
          github.com/griffincockfoster/s3-screenshot-app
        </div>
      </div>
    </FeatureLayout>
  );
};
