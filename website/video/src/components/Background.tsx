import React from "react";
import { AbsoluteFill } from "remotion";

export const Background: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  return (
    <AbsoluteFill
      style={{
        background: "linear-gradient(135deg, #0a0a1a 0%, #1a1a3e 100%)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "Inter, sans-serif",
        color: "white",
      }}
    >
      {children}
    </AbsoluteFill>
  );
};
