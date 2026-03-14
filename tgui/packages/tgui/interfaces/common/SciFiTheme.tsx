import { type CSSProperties, type ReactNode, useState } from 'react';

import { Box, Button, Icon, Tooltip } from '../../components';
import { Window } from '../../layouts';

// ─── Color Palette ───────────────────────────────────────────────────────────

export const SciFi = {
  font: 'Consolas, "Courier New", monospace',

  // Primary accent
  accent: '#40e0d0',
  accentGlow: 'rgba(64, 224, 208, 0.8)',
  accentDim: 'rgba(64, 224, 208, 0.3)',
  accentSubtle: 'rgba(64, 224, 208, 0.15)',
  accentFaint: 'rgba(64, 224, 208, 0.05)',

  // Success / positive
  green: '#00ff00',
  greenGlow: 'rgba(0, 255, 0, 0.8)',
  greenDim: 'rgba(0, 255, 0, 0.4)',
  greenSubtle: 'rgba(0, 255, 0, 0.2)',
  greenFaint: 'rgba(0, 255, 0, 0.1)',

  // Warning / caution
  orange: '#ff9933',
  orangeGlow: 'rgba(255, 153, 51, 0.8)',
  orangeDim: 'rgba(255, 153, 51, 0.3)',
  orangeSubtle: 'rgba(255, 153, 51, 0.08)',

  amber: '#ffa500',
  amberGlow: 'rgba(255, 165, 0, 0.8)',
  amberDim: 'rgba(255, 165, 0, 0.6)',
  amberSubtle: 'rgba(255, 165, 0, 0.3)',

  yellow: '#ffff00',
  yellowGlow: 'rgba(255, 255, 0, 1)',

  // Danger / error
  red: '#ff6666',
  redGlow: 'rgba(255, 102, 102, 0.8)',
  redDim: 'rgba(255, 102, 102, 0.3)',
  redSubtle: 'rgba(255, 102, 102, 0.08)',

  redBright: '#ff4444',
  redBrightGlow: 'rgba(255, 68, 68, 0.8)',
  redBrightDim: 'rgba(255, 68, 68, 0.5)',
  redBrightSubtle: 'rgba(255, 68, 68, 0.2)',
  redBrightFaint: 'rgba(255, 68, 68, 0.05)',

  redDark: 'rgba(139, 0, 0, 0.9)',

  // Critical
  criticalRed: '#ff0000',
  criticalRedGlow: 'rgba(255, 0, 0, 0.8)',
  criticalRedDim: 'rgba(255, 0, 0, 0.6)',
  criticalRedSubtle: 'rgba(255, 0, 0, 0.2)',

  warningOrange: 'rgba(255, 140, 0, 0.85)',
  warningOrangeBorder: 'rgba(255, 200, 0, 0.9)',
  warningOrangeGlow: 'rgba(255, 200, 0, 0.6)',
  warningOrangeFaint: 'rgba(255, 140, 0, 0.2)',

  // Backgrounds
  bgDeep: '#0a0a0a',
  bgDark: '#1a1a1a',
  bgPanel: 'rgba(0, 20, 20, 0.6)',
  bgOverlay: 'rgba(0, 0, 0, 0.85)',
  bgInset: 'rgba(0, 0, 0, 0.8)',
  bgSurface: 'rgba(0, 0, 0, 0.4)',
  bgContainer: 'rgba(0, 10, 10, 0.85)',
  bgDarkest: 'rgba(0, 0, 0, 0.9)',

  white: '#ffffff',
} as const;

/** Map of semantic color names to their full color set for readouts / labels. */
export const readoutColors = {
  turquoise: {
    color: SciFi.accent,
    shadow: SciFi.accentGlow,
    bg: SciFi.accentFaint,
    border: SciFi.accentDim,
  },
  orange: {
    color: SciFi.orange,
    shadow: SciFi.orangeGlow,
    bg: SciFi.orangeSubtle,
    border: SciFi.orangeDim,
  },
  red: {
    color: SciFi.red,
    shadow: SciFi.redGlow,
    bg: SciFi.redSubtle,
    border: SciFi.redDim,
  },
} as const;

export type ReadoutColorName = keyof typeof readoutColors;

// ─── Style helpers ───────────────────────────────────────────────────────────

/** Shorthand for the monospace font family. */
export const monoFont: CSSProperties = {
  fontFamily: SciFi.font,
};

/** A glowing text shadow for the given color string. */
export const glow = (color: string, spread = 8): CSSProperties => ({
  textShadow: `0 0 ${spread}px ${color}`,
});

/** Uppercase tracking label style. */
export const labelStyle = (
  color = SciFi.accent,
  size = '11px',
): CSSProperties => ({
  fontFamily: SciFi.font,
  color,
  fontSize: size,
  fontWeight: 'bold',
  textTransform: 'uppercase',
  letterSpacing: '2px',
  textShadow: `0 0 8px ${color}`,
});

/** Standard glowing border + shadow for panels. */
export const panelBorder = (
  color = SciFi.accentDim,
  width = '2px',
): CSSProperties => ({
  border: `${width} solid ${color}`,
  borderRadius: '4px',
  boxShadow: `0 0 10px ${color}`,
});

// ─── Window wrapper ──────────────────────────────────────────────────────────

/**
 * A pre-themed Window + Window.Content wrapper.
 * Gives a dark gradient background with the monospace font.
 */
export const SciFiWindow = (props: {
  width: number;
  height: number;
  children: ReactNode;
}) => {
  const { width, height, children } = props;
  return (
    <Window width={width} height={height}>
      <Window.Content
        style={{
          fontFamily: SciFi.font,
          background: `linear-gradient(180deg, ${SciFi.bgDeep} 0%, ${SciFi.bgDark} 100%)`,
        }}
      >
        {children}
      </Window.Content>
    </Window>
  );
};

// ─── Scan-line overlay ───────────────────────────────────────────────────────

/** Full-screen CRT scan-line effect. Place at the top of your layout. */
export const ScanLineOverlay = () => (
  <Box
    style={{
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background:
        'repeating-linear-gradient(0deg, rgba(0, 0, 0, 0.15), rgba(0, 0, 0, 0.15) 1px, transparent 1px, transparent 2px)',
      pointerEvents: 'none',
      zIndex: 9999,
    }}
  />
);

// ─── ReadoutBox ──────────────────────────────────────────────────────────────

/**
 * A monospace readout with a label and value, styled with a colored glow.
 * General-purpose: works for any labelled metric.
 */
export const ReadoutBox = (props: {
  label: string;
  value: string;
  color: ReadoutColorName;
  tooltip: string;
  textAlign?: string;
}) => {
  const { label, value, color, tooltip, textAlign = 'left' } = props;
  const colors = readoutColors[color];

  return (
    <Tooltip content={tooltip}>
      <Box
        fontSize="1.1em"
        bold
        textAlign={textAlign}
        style={{
          fontFamily: SciFi.font,
          color: colors.color,
          textShadow: `0 0 5px ${colors.shadow}`,
          backgroundColor: colors.bg,
          padding: '4px 8px',
          borderRadius: '2px',
          border: `1px solid ${colors.border}`,
        }}
      >
        [{label}: {value}]
      </Box>
    </Tooltip>
  );
};

// ─── Warning banner ──────────────────────────────────────────────────────────

export type WarningLevel = 'none' | 'warning' | 'critical';

/**
 * A floating warning/critical banner that appears at the top of a container.
 * Returns null when level is 'none'.
 */
export const WarningBanner = (props: {
  level: WarningLevel;
  message: string;
  top?: string;
}) => {
  const { level, message, top = '90px' } = props;

  if (level === 'none') {
    return null;
  }

  const isCritical = level === 'critical';

  return (
    <Box
      style={{
        position: 'absolute',
        top,
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 10,
        backgroundColor: isCritical ? SciFi.redDark : SciFi.warningOrange,
        border: isCritical
          ? `2px solid ${SciFi.criticalRedGlow}`
          : `2px solid ${SciFi.warningOrangeBorder}`,
        borderRadius: '4px',
        boxShadow: isCritical
          ? `0 0 20px ${SciFi.criticalRedDim}, inset 0 0 15px ${SciFi.criticalRedSubtle}`
          : `0 0 15px ${SciFi.warningOrangeGlow}, inset 0 0 10px ${SciFi.warningOrangeFaint}`,
        padding: '6px 16px',
      }}
    >
      <Box
        style={{
          fontFamily: SciFi.font,
          color: isCritical ? SciFi.criticalRed : SciFi.yellow,
          fontSize: '12px',
          fontWeight: 'bold',
          textTransform: 'uppercase',
          letterSpacing: '2px',
          textShadow: isCritical
            ? `0 0 10px ${SciFi.criticalRed}, 0 0 20px ${SciFi.criticalRedDim}`
            : `0 0 10px ${SciFi.yellowGlow}, 0 0 5px rgba(0, 0, 0, 1)`,
          whiteSpace: 'nowrap',
          textAlign: 'center',
        }}
      >
        {message}
      </Box>
    </Box>
  );
};

// ─── Toggle button ───────────────────────────────────────────────────────────

/**
 * An ON/OFF toggle button with green/red glow states.
 */
export const ToggleButton = (props: {
  enabled: boolean;
  tooltip?: string;
  onClick: () => void;
}) => {
  const { enabled, tooltip, onClick } = props;

  const button = (
    <Button
      onClick={onClick}
      style={{
        fontFamily: SciFi.font,
        fontWeight: 'bold',
        fontSize: '0.85em',
        padding: '4px 12px',
        backgroundColor: enabled ? SciFi.greenSubtle : 'rgba(255, 0, 0, 0.15)',
        border: enabled
          ? `2px solid rgba(0, 255, 0, 0.6)`
          : `2px solid rgba(255, 0, 0, 0.4)`,
        color: enabled ? SciFi.green : SciFi.red,
        boxShadow: enabled
          ? `0 0 8px ${SciFi.greenDim}, inset 0 0 8px ${SciFi.greenFaint}`
          : `0 0 8px rgba(255, 0, 0, 0.3), inset 0 0 8px rgba(255, 0, 0, 0.1)`,
        textShadow: enabled
          ? `0 0 6px ${SciFi.greenGlow}`
          : `0 0 6px rgba(255, 0, 0, 0.8)`,
        textTransform: 'uppercase',
        letterSpacing: '1px',
        whiteSpace: 'nowrap',
      }}
    >
      {enabled ? '● ON' : '○ OFF'}
    </Button>
  );

  return tooltip ? <Tooltip content={tooltip}>{button}</Tooltip> : button;
};

// ─── StatusBar ───────────────────────────────────────────────────────────────

/**
 * A horizontal progress bar with a percentage label overlay.
 * Useful for fuel, health, charge, etc.
 */
export const StatusBar = (props: {
  percent: number;
  color: string;
  glowColor: string;
  borderColor?: string;
  tooltip?: string;
  width?: string;
  height?: string;
}) => {
  const {
    percent,
    color,
    glowColor,
    borderColor = SciFi.accentDim,
    tooltip,
    width = '120px',
    height = '12px',
  } = props;

  const bar = (
    <Box
      style={{
        position: 'relative',
        height,
        width,
        minWidth: width,
        backgroundColor: SciFi.bgInset,
        border: `1px solid ${borderColor}`,
        borderRadius: '2px',
        overflow: 'hidden',
      }}
    >
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          height: '100%',
          width: `${percent}%`,
          backgroundColor: color,
          boxShadow: `0 0 6px ${glowColor}`,
          transition: 'width 0.3s ease',
        }}
      />
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontFamily: SciFi.font,
          fontSize: '8px',
          fontWeight: 'bold',
          color: SciFi.white,
          textShadow: '0 0 3px rgba(0, 0, 0, 1)',
          letterSpacing: '0.5px',
        }}
      >
        {percent.toFixed(0)}%
      </Box>
    </Box>
  );

  return tooltip ? <Tooltip content={tooltip}>{bar}</Tooltip> : bar;
};

// ─── Expandable panel ────────────────────────────────────────────────────────

/**
 * A collapsible panel with a chevron, title, and optional alert badge.
 */
export const ExpandablePanel = (props: {
  title: string;
  count?: number;
  alert?: boolean;
  alertText?: string;
  defaultExpanded?: boolean;
  children: ReactNode;
}) => {
  const {
    title,
    count,
    alert = false,
    alertText,
    defaultExpanded = false,
    children,
  } = props;
  const [expanded, setExpanded] = useState(defaultExpanded);

  return (
    <Box
      style={{
        backgroundColor: SciFi.bgContainer,
        border: alert
          ? `1px solid ${SciFi.redBrightDim}`
          : `1px solid ${SciFi.accentDim}`,
        borderRadius: '3px',
        boxShadow: alert
          ? `0 0 8px ${SciFi.redBrightSubtle}, inset 0 0 10px ${SciFi.redBrightFaint}`
          : `0 0 8px ${SciFi.accentSubtle}, inset 0 0 10px rgba(64, 224, 208, 0.03)`,
        padding: '6px 10px',
      }}
    >
      <Box
        style={{
          fontFamily: SciFi.font,
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          cursor: 'pointer',
        }}
        onClick={() => setExpanded(!expanded)}
      >
        <Icon
          name={expanded ? 'chevron-down' : 'chevron-right'}
          style={{ color: SciFi.accent, fontSize: '10px' }}
        />
        <Box
          as="span"
          style={{
            ...labelStyle(SciFi.accent, '11px'),
            letterSpacing: '1.5px',
          }}
        >
          {title}
          {count !== undefined ? ` [${count}]` : ''}
        </Box>
        {alert && alertText && (
          <Box
            as="span"
            style={{
              color: SciFi.redBright,
              fontSize: '10px',
              fontWeight: 'bold',
              textShadow: `0 0 8px ${SciFi.redBrightGlow}`,
              letterSpacing: '1px',
            }}
          >
            {alertText}
          </Box>
        )}
      </Box>
      {expanded && <Box style={{ marginTop: '6px' }}>{children}</Box>}
    </Box>
  );
};

// ─── Big numeric display ─────────────────────────────────────────────────────

/**
 * A large numeric display with a label beneath, suitable for thrust levels,
 * temperatures, power readings, etc.
 */
export const BigNumericDisplay = (props: {
  value: string | number;
  label: string;
  color?: string;
  glowColor?: string;
  borderColor?: string;
}) => {
  const {
    value,
    label,
    color = SciFi.green,
    glowColor = SciFi.greenGlow,
    borderColor = 'rgba(0, 255, 0, 0.6)',
  } = props;

  return (
    <Box
      style={{
        backgroundColor: SciFi.bgInset,
        border: `2px solid ${borderColor}`,
        borderRadius: '4px',
        padding: '20px 10px',
        textAlign: 'center',
        boxShadow: `0 0 15px ${borderColor.replace('0.6', '0.3')}, inset 0 0 10px ${borderColor.replace('0.6', '0.1')}`,
      }}
    >
      <Box
        style={{
          fontFamily: SciFi.font,
          color,
          fontSize: '3em',
          fontWeight: 'bold',
          textShadow: `0 0 10px ${glowColor}, 0 0 20px ${glowColor.replace('0.8', '0.4')}`,
          lineHeight: '1',
        }}
      >
        {value}
      </Box>
      <Box
        style={{
          fontFamily: SciFi.font,
          color,
          fontSize: '0.7em',
          marginTop: '8px',
          textTransform: 'uppercase',
          letterSpacing: '2px',
          textShadow: `0 0 5px ${glowColor}`,
        }}
      >
        {label}
      </Box>
    </Box>
  );
};

// ─── Compact numeric display ─────────────────────────────────────────────────

/**
 * A smaller numeric readout with a label beneath. Good for secondary metrics.
 */
export const CompactNumericDisplay = (props: {
  value: string | number;
  label: string;
  color?: string;
  glowColor?: string;
  borderColor?: string;
  tooltip?: string;
}) => {
  const {
    value,
    label,
    color = SciFi.accent,
    glowColor = SciFi.accentGlow,
    borderColor = `rgba(64, 224, 208, 0.4)`,
    tooltip,
  } = props;

  const content = (
    <Box
      style={{
        backgroundColor: SciFi.bgDarkest,
        border: `2px solid ${borderColor}`,
        borderRadius: '4px',
        padding: '8px 6px',
        textAlign: 'center',
        boxShadow: `0 0 8px ${borderColor.replace('0.4', '0.2')}, inset 0 0 5px ${borderColor.replace('0.4', '0.05')}`,
      }}
    >
      <Box
        style={{
          fontFamily: SciFi.font,
          color,
          fontSize: '1.8em',
          fontWeight: 'bold',
          textShadow: `0 0 8px ${glowColor}`,
          lineHeight: '1',
        }}
      >
        {value}
      </Box>
      <Box
        style={{
          fontFamily: SciFi.font,
          color,
          fontSize: '0.6em',
          marginTop: '4px',
          textTransform: 'uppercase',
          letterSpacing: '1.5px',
          textShadow: `0 0 5px ${glowColor}`,
        }}
      >
        {label}
      </Box>
    </Box>
  );

  return tooltip ? <Tooltip content={tooltip}>{content}</Tooltip> : content;
};

// ─── Status icon ─────────────────────────────────────────────────────────────

/**
 * A small icon with optional tooltip, for status indicators in rows.
 */
export const StatusIcon = (props: {
  ok: boolean;
  okIcon?: string;
  alertIcon?: string;
  okTooltip?: string;
  alertTooltip?: string;
}) => {
  const {
    ok,
    okIcon = 'check-circle',
    alertIcon = 'exclamation-triangle',
    okTooltip = 'Nominal',
    alertTooltip = 'Alert',
  } = props;

  return (
    <Tooltip content={ok ? okTooltip : alertTooltip}>
      <Icon
        name={ok ? okIcon : alertIcon}
        style={{
          color: ok ? SciFi.green : SciFi.redBright,
          fontSize: '12px',
          textShadow: ok
            ? `0 0 6px ${SciFi.greenDim}`
            : `0 0 6px ${SciFi.redBrightGlow}`,
          marginRight: '6px',
        }}
      />
    </Tooltip>
  );
};

// ─── Sci-Fi Section ──────────────────────────────────────────────────────────

/**
 * A styled Section-like wrapper with glowing border and dark background.
 */
export const SciFiPanel = (props: {
  title?: string;
  children: ReactNode;
  style?: CSSProperties;
}) => {
  const { title, children, style } = props;

  return (
    <Box
      style={{
        fontFamily: SciFi.font,
        backgroundColor: SciFi.bgPanel,
        border: `2px solid ${SciFi.accent}`,
        borderRadius: '4px',
        boxShadow: `0 0 15px ${SciFi.accentDim}, inset 0 0 20px ${SciFi.accentFaint}`,
        padding: '8px',
        ...style,
      }}
    >
      {title && (
        <Box
          style={{
            ...labelStyle(SciFi.accent, '12px'),
            textAlign: 'center',
            marginBottom: '8px',
            borderBottom: `1px solid ${SciFi.accentDim}`,
            paddingBottom: '6px',
          }}
        >
          {title}
        </Box>
      )}
      {children}
    </Box>
  );
};

// ─── Sci-Fi action button ────────────────────────────────────────────────────

/**
 * A large styled action button (e.g. thrust up / down arrows).
 */
export const SciFiActionButton = (props: {
  children: ReactNode;
  onClick: () => void;
  fluid?: boolean;
  style?: CSSProperties;
}) => {
  const { children, onClick, fluid = true, style } = props;

  return (
    <Button
      fluid={fluid}
      onClick={onClick}
      style={{
        fontFamily: SciFi.font,
        fontWeight: 'bold',
        fontSize: '1.5em',
        padding: '10px 20',
        textAlign: 'center' as const,
        backgroundColor: SciFi.accentSubtle,
        border: `2px solid ${SciFi.accent}`,
        boxShadow: `0 0 10px ${SciFi.accentDim}, inset 0 0 10px ${SciFi.accentFaint}`,
        ...style,
      }}
    >
      {children}
    </Button>
  );
};
