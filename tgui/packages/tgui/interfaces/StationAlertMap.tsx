import { BooleanLike } from 'common/react';
import { useCallback, useEffect, useRef, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';

type View = { x: number; y: number; w: number; h: number };

const MAX_ZOOM = 12;
const ZOOM_STEP = 1.3;
const CLICK_SLOP = 3;

const clamp = (value: number, min: number, max: number) =>
  Math.min(Math.max(value, min), max);

/** [x, y, w, h] in cropped map space */
type Rect = [number, number, number, number];

type MapArea = {
  ref: string;
  name: string;
  department: string | null;
  anchor: BooleanLike;
  rects: Rect[];
};

export type MapData = {
  url: string;
  width: number;
  height: number;
  areas: MapArea[];
  /** [x, y] of the console on the schematic */
  viewer: [number, number] | null;
};

type AreaStatus = {
  alarms?: string[];
  power?: string;
  blind?: Record<string, string>;
  /** See update_area_integrity() */
  structure?: 'breached' | 'damaged';
  integrity?: number;
  pressure?: number;
  /** Set by get_area_status() */
  faults?: Record<string, number>;
};

export type WorkOrder = {
  key: string;
  areaRef: string;
  area: string;
  task: string;
  /** Lowest is most urgent. */
  priority: number;
  claimant: string | null;
  assignedBy: string | null;
  claimedAt: number | null;
};

export type CrewMember = {
  ckey: string;
  name: string;
  job: string;
  openJobs: number;
  completed: number;
  dropped: number;
};

type Data = {
  map: MapData | null;
  areaStatus: Record<string, AreaStatus> | null;
  workOrders: WorkOrder[] | null;
  areaNotApplicable: Record<string, string[]> | null;
};

const MAP_CHROME_WIDTH = 16;
const MAP_CHROME_HEIGHT = 128;
const MAP_MAX_WIDTH = 1100;
const MAP_MAX_HEIGHT = 800;

export const getMapWindowSize = (
  map: MapData | null | undefined,
  extraChromeHeight = 0,
  extraChromeWidth = 0,
): [number, number] => {
  const chromeHeight = MAP_CHROME_HEIGHT + extraChromeHeight;
  const chromeWidth = MAP_CHROME_WIDTH + extraChromeWidth;
  if (!map?.width || !map?.height) {
    return [880 + extraChromeWidth, 620 + extraChromeHeight];
  }
  const aspect = map.width / map.height;
  let height = MAP_MAX_HEIGHT - chromeHeight;
  let width = height * aspect;
  if (width > MAP_MAX_WIDTH - chromeWidth) {
    width = MAP_MAX_WIDTH - chromeWidth;
    height = width / aspect;
  }
  return [Math.round(width + chromeWidth), Math.round(height + chromeHeight)];
};

type Layer = {
  id: string;
  label: string;
  icon: string;
  color: string;
  tooltip?: string;
};

type GlyphShape =
  | 'circle'
  | 'square'
  | 'triangle'
  | 'triangleDown'
  | 'diamond'
  | 'cross';

type FaultLayer = Layer & { shape: GlyphShape };

/** `id` matches the alarm types in code/__DEFINES/alarm.dm */
const ALARM_LAYERS: FaultLayer[] = [
  {
    id: 'Fire',
    label: 'Fire',
    icon: 'fire',
    color: '#e8703a',
    shape: 'triangle',
  },
  {
    id: 'Atmosphere',
    label: 'Atmos',
    icon: 'wind',
    color: '#4ab8e0',
    shape: 'circle',
  },
  {
    id: 'Power',
    label: 'Power',
    icon: 'bolt',
    color: '#e0c040',
    shape: 'square',
  },
];

const APC_LAYER: FaultLayer = {
  id: 'apc',
  label: 'Grid',
  icon: 'plug',
  color: '#c86a30',
  shape: 'diamond',
};

const INTEGRITY_LAYER: FaultLayer = {
  id: 'integrity',
  label: 'Damage',
  icon: 'house-crack',
  color: '#b0553f',
  shape: 'triangleDown',
};

const BREACH_LAYER: FaultLayer = {
  id: INTEGRITY_LAYER.id,
  label: 'Breach',
  icon: 'house-crack',
  color: '#ff3b3b',
  shape: 'cross',
};

const LAYERS: FaultLayer[] = [...ALARM_LAYERS, APC_LAYER, INTEGRITY_LAYER];

const UNRANKED = 99;

const faultPriority = (status: AreaStatus, layer: FaultLayer) =>
  status.faults?.[layer.id] ?? UNRANKED;

const COVERAGE_LAYER: Layer = {
  id: 'coverage',
  label: 'Coverage',
  icon: 'eye-slash',
  color: '#8a8f96',
};

const WORK_LAYER: Layer = {
  id: 'work',
  label: 'Work',
  icon: 'screwdriver-wrench',
  color: '#5fb85f',
};

/** Snowflake view option that isnt a fault layer :P */
const TINT_LAYER: Layer = {
  id: 'tint',
  label: 'Tint',
  icon: 'palette',
  tooltip: 'Department tinting on the schematic',
  color: '#8a8f96',
};

const VIEWER_COLOR = '#9adcff';

const TOGGLES: Layer[] = [...LAYERS, COVERAGE_LAYER, WORK_LAYER, TINT_LAYER];

const ALL_LAYERS_ON: Record<string, boolean> = Object.fromEntries(
  TOGGLES.map((layer) => [layer.id, true]),
);

const LAYER_DEFAULTS: Record<string, boolean> = Object.fromEntries(
  TOGGLES.map((layer) => [layer.id, layer.id !== TINT_LAYER.id]),
);

const BACKDROP_FILTER = 'saturate(0.3) brightness(0.9)';

const FAULT_FILL_OPACITY = 0.3;
const UNSELECTED_FILL_SCALE = 0.45;
const HOVER_WASH = 0.14;
const SELECT_WASH = 0.26;

const POWER_LABELS: Record<string, string> = {
  nocell: 'No cell installed',
  dead: 'Cell depleted',
  critical: 'Cell critical',
  low: 'Cell low',
};

const BLIND_LABELS: Record<string, string> = {
  asbuilt: 'No sensor fitted',
  missing: 'Sensor removed',
  offline: 'Sensor offline',
  unpowered: 'Sensor unpowered',
};

const BLIND_GRID_LABELS: Record<string, string> = {
  asbuilt: 'No APC fitted',
  missing: 'APC removed',
  offline: 'APC broken',
  nocell: 'No power cell',
};

/** Blind now, as opposed to never having had the sensor. */
const isLiveGap = (reason?: string) => !!reason && reason !== 'asbuilt';

const getAreaFaults = (
  status: AreaStatus | undefined,
  enabled: Record<string, boolean>,
): FaultLayer[] => {
  if (!status) {
    return [];
  }
  const faults: FaultLayer[] = [];
  for (const layer of ALARM_LAYERS) {
    if (!enabled[layer.id]) {
      continue;
    }
    if (
      status.alarms?.includes(layer.id) ||
      (layer.id === 'Atmosphere' && status.pressure !== undefined)
    ) {
      faults.push(layer);
    }
  }
  if (enabled[APC_LAYER.id] && status.power) {
    faults.push(APC_LAYER);
  }
  if (enabled[INTEGRITY_LAYER.id] && status.structure) {
    faults.push(
      status.structure === 'breached' ? BREACH_LAYER : INTEGRITY_LAYER,
    );
  }
  // Worst first
  return faults.sort(
    (a, b) => faultPriority(status, a) - faultPriority(status, b),
  );
};

const FaultGlyph = (props: {
  shape: GlyphShape;
  color: string;
  cx: number;
  cy: number;
  size: number;
}) => {
  const { shape, color, cx, cy, size } = props;
  const r = size / 2;
  // paintOrder puts the stroke behind the fill, haloing it like the labels
  const halo = {
    fill: color,
    stroke: '#0b0e12',
    strokeWidth: size * 0.26,
    paintOrder: 'stroke' as const,
    style: { pointerEvents: 'none' as const },
  };
  switch (shape) {
    case 'circle':
      return <circle cx={cx} cy={cy} r={r} {...halo} />;
    case 'square':
      return (
        <rect x={cx - r} y={cy - r} width={size} height={size} {...halo} />
      );
    case 'diamond':
      return (
        <polygon
          points={`${cx},${cy - r} ${cx + r},${cy} ${cx},${cy + r} ${cx - r},${cy}`}
          {...halo}
        />
      );
    case 'cross': {
      const arm = r * 0.32;
      return (
        <polygon
          points={`${cx - arm},${cy - r} ${cx + arm},${cy - r} ${cx + arm},${cy - arm} ${cx + r},${cy - arm} ${cx + r},${cy + arm} ${cx + arm},${cy + arm} ${cx + arm},${cy + r} ${cx - arm},${cy + r} ${cx - arm},${cy + arm} ${cx - r},${cy + arm} ${cx - r},${cy - arm} ${cx - arm},${cy - arm}`}
          transform={`rotate(45 ${cx} ${cy})`}
          {...halo}
        />
      );
    }
    case 'triangleDown':
      return (
        <polygon
          points={`${cx - r},${cy - r} ${cx + r},${cy - r} ${cx},${cy + r}`}
          {...halo}
        />
      );
    default:
      return (
        <polygon
          points={`${cx},${cy - r} ${cx + r},${cy + r} ${cx - r},${cy + r}`}
          {...halo}
        />
      );
  }
};

const isAreaBlind = (
  status: AreaStatus | undefined,
  enabled: Record<string, boolean>,
): boolean => {
  if (!status?.blind || !enabled[COVERAGE_LAYER.id]) {
    return false;
  }
  return LAYERS.some(
    (layer) => enabled[layer.id] && isLiveGap(status.blind?.[layer.id]),
  );
};

const clampView = (view: View, map: MapData): View => {
  const w = clamp(view.w, map.width / MAX_ZOOM, map.width);
  const h = w * (map.height / map.width);
  return {
    w,
    h,
    x: clamp(view.x, 0, Math.max(0, map.width - w)),
    y: clamp(view.y, 0, Math.max(0, map.height - h)),
  };
};

const fullView = (map: MapData): View => ({
  x: 0,
  y: 0,
  w: map.width,
  h: map.height,
});

const getLabelRect = (rects: Rect[]): Rect | undefined =>
  rects.reduce(
    (best, rect) => (rect[2] * rect[3] > best[2] * best[3] ? rect : best),
    rects[0],
  );

const DEPARTMENT_LABEL_BELOW_ZOOM = 2.5;

const getDepartmentLabels = (areas: MapArea[]) => {
  const byDepartment: Record<string, { anchor: Rect[]; all: Rect[] }> = {};
  for (const area of areas) {
    if (!area.department) {
      continue;
    }
    const entry = (byDepartment[area.department] ||= { anchor: [], all: [] });
    entry.all.push(...area.rects);
    if (area.anchor) {
      entry.anchor.push(...area.rects);
    }
  }
  return Object.entries(byDepartment).map(([name, { anchor, all }]) => ({
    name,
    rect: getLabelRect(anchor.length ? anchor : all),
  }));
};

const getAreaBounds = (area: MapArea) => {
  const xs = area.rects.map(([x]) => x);
  const ys = area.rects.map(([, y]) => y);
  const x2s = area.rects.map(([x, , w]) => x + w);
  const y2s = area.rects.map(([, y, , h]) => y + h);
  const x = Math.min(...xs);
  const y = Math.min(...ys);
  return { x, y, w: Math.max(...x2s) - x, h: Math.max(...y2s) - y };
};

const ReadoutRow = (props: {
  layer: Layer;
  status?: AreaStatus;
  na?: string[];
}) => {
  const { layer, status, na } = props;
  const isGrid = layer.id === APC_LAYER.id;

  let text: string;
  let color: string;

  if (na?.includes(layer.id)) {
    text = 'Not applicable';
    color = 'label';
  } else if (status?.blind?.[layer.id]) {
    const reason = status.blind[layer.id];
    const labels = isGrid ? BLIND_GRID_LABELS : BLIND_LABELS;
    text = `No data - ${labels[reason] || reason}`;
    color = isLiveGap(reason) ? 'average' : 'label';
  } else if (layer.id === INTEGRITY_LAYER.id) {
    const integrity = status?.integrity;
    const reading = integrity === undefined ? null : `${integrity}%`;
    if (status?.structure === 'breached') {
      text = reading ? `Breached, ${reading} of as-built` : 'Breached';
      color = 'bad';
    } else if (reading) {
      text = `${reading} of as-built`;
      color = status?.structure ? 'bad' : 'average';
    } else {
      text = 'Intact';
      color = 'good';
    }
  } else if (isGrid) {
    text = status?.power
      ? POWER_LABELS[status.power] || status.power
      : 'Nominal';
    color = status?.power ? 'average' : 'good';
  } else {
    const alarming = status?.alarms?.includes(layer.id);
    // "Alarm" doesn't distinguish a vacuum from a leak.
    if (layer.id === 'Atmosphere' && status?.pressure !== undefined) {
      text = `${status.pressure} kPa`;
      color = 'bad';
    } else {
      text = alarming ? 'Alarm' : 'Nominal';
      color = alarming ? 'bad' : 'good';
    }
  }

  return (
    <Box color={color} style={{ whiteSpace: 'nowrap' }}>
      <Icon name={layer.icon} mr={1} />
      {layer.label}: {text}
    </Box>
  );
};

export const AreaReadout = (props: { areaRef: string | null }) => {
  const { areaRef } = props;
  const { data } = useBackend<Data>();
  const { map, areaStatus, areaNotApplicable } = data;
  const area = areaRef
    ? map?.areas.find((entry) => entry.ref === areaRef)
    : undefined;

  // One row per layer, always
  return (
    <Section
      title={
        <Box
          style={{
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {area ? area.name : 'Area detail'}
        </Box>
      }
    >
      {LAYERS.map((layer) =>
        area ? (
          <ReadoutRow
            key={layer.id}
            layer={layer}
            status={areaRef ? areaStatus?.[areaRef] : undefined}
            na={areaRef ? areaNotApplicable?.[areaRef] : undefined}
          />
        ) : (
          <Box key={layer.id} color="label" style={{ whiteSpace: 'nowrap' }}>
            <Icon name={layer.icon} mr={1} />
            {layer.label}: &mdash;
          </Box>
        ),
      )}
    </Section>
  );
};

type StationAlertMapProps = {
  hovered: string | null;
  setHovered: (ref: string | null) => void;
  /** Sticky, unlike hover */
  selected: string | null;
  selectArea: (areaRef: string | null) => void;
  /** Bumped by the alarm list to frame an area */
  focusRequest: { ref: string; nonce: number } | null;
};

export const StationAlertMap = (props: StationAlertMapProps) => {
  const { hovered, setHovered, selected, selectArea, focusRequest } = props;
  const { data } = useBackend<Data>();
  const { map, areaStatus, workOrders } = data;

  const [enabled, setEnabled] =
    useState<Record<string, boolean>>(LAYER_DEFAULTS);
  const [viewState, setViewState] = useState<View | null>(null);
  const [dragging, setDragging] = useState(false);

  const svgRef = useRef<SVGSVGElement>(null);
  // Refs so the natively-attached wheel handler never reads a stale view or map.
  const viewRef = useRef<View | null>(null);
  const mapRef = useRef<MapData | null>(null);
  const dragRef = useRef<{
    px: number;
    py: number;
    view: View;
    moved: number;
  } | null>(null);
  const lastMovedRef = useRef(0);

  const view = viewState ?? (map ? fullView(map) : null);

  useEffect(() => {
    viewRef.current = view;
    mapRef.current = map;
  });

  useEffect(() => {
    setViewState(null);
  }, [map?.url]);

  const zoomAt = useCallback(
    (clientX: number, clientY: number, factor: number) => {
      const node = svgRef.current;
      const current = viewRef.current;
      const bounds = mapRef.current;
      if (!node || !current || !bounds) {
        return;
      }
      const rect = node.getBoundingClientRect();
      if (!rect.width || !rect.height) {
        return;
      }
      // Zoom about the pointer, not the centre.
      const fx = clamp((clientX - rect.left) / rect.width, 0, 1);
      const fy = clamp((clientY - rect.top) / rect.height, 0, 1);
      const ux = current.x + fx * current.w;
      const uy = current.y + fy * current.h;
      const next = clampView({ ...current, w: current.w / factor }, bounds);
      setViewState(
        clampView(
          { ...next, x: ux - fx * next.w, y: uy - fy * next.h },
          bounds,
        ),
      );
    },
    [],
  );

  // React attaches wheel at the root as a passive listener, so preventDefault() there is a
  // no-op. Attaching natively is the only way to stop the scroll while zooming.
  useEffect(() => {
    const node = svgRef.current;
    if (!node) {
      return;
    }
    const onWheel = (event: WheelEvent) => {
      event.preventDefault();
      zoomAt(
        event.clientX,
        event.clientY,
        event.deltaY < 0 ? ZOOM_STEP : 1 / ZOOM_STEP,
      );
    };
    node.addEventListener('wheel', onWheel, { passive: false });
    return () => node.removeEventListener('wheel', onWheel);
  }, [zoomAt, map?.url]);

  const zoomByButton = (factor: number) => {
    const node = svgRef.current;
    if (!node) {
      return;
    }
    const rect = node.getBoundingClientRect();
    zoomAt(rect.left + rect.width / 2, rect.top + rect.height / 2, factor);
  };

  const focusArea = useCallback((area: MapArea) => {
    const bounds = mapRef.current;
    if (!bounds) {
      return;
    }
    const box = getAreaBounds(area);
    const aspect = bounds.width / bounds.height;
    const w = Math.max(box.w, box.h * aspect) * 1.8;
    const next = clampView({ x: 0, y: 0, w, h: 0 }, bounds);
    setViewState(
      clampView(
        {
          ...next,
          x: box.x + box.w / 2 - next.w / 2,
          y: box.y + box.h / 2 - next.h / 2,
        },
        bounds,
      ),
    );
  }, []);

  useEffect(() => {
    if (!focusRequest) {
      return;
    }
    const area = mapRef.current?.areas.find(
      (entry) => entry.ref === focusRequest.ref,
    );
    if (area) {
      focusArea(area);
    }
  }, [focusRequest, focusArea]);

  const onPointerDown = (event: React.PointerEvent<SVGSVGElement>) => {
    if (event.button !== 0 || !view) {
      return;
    }
    dragRef.current = {
      px: event.clientX,
      py: event.clientY,
      view,
      moved: 0,
    };
  };

  const onPointerMove = (event: React.PointerEvent<SVGSVGElement>) => {
    const drag = dragRef.current;
    const node = svgRef.current;
    const bounds = mapRef.current;
    if (!drag || !node || !bounds) {
      return;
    }
    const dx = event.clientX - drag.px;
    const dy = event.clientY - drag.py;
    drag.moved = Math.max(drag.moved, Math.abs(dx) + Math.abs(dy));
    if (drag.moved <= CLICK_SLOP) {
      return;
    }
    if (!node.hasPointerCapture(event.pointerId)) {
      node.setPointerCapture(event.pointerId);
    }
    setDragging(true);
    const rect = node.getBoundingClientRect();
    setViewState(
      clampView(
        {
          ...drag.view,
          x: drag.view.x - (dx / rect.width) * drag.view.w,
          y: drag.view.y - (dy / rect.height) * drag.view.h,
        },
        bounds,
      ),
    );
  };

  const onPointerUp = (event: React.PointerEvent<SVGSVGElement>) => {
    if (svgRef.current?.hasPointerCapture(event.pointerId)) {
      svgRef.current.releasePointerCapture(event.pointerId);
    }
    lastMovedRef.current = dragRef.current?.moved ?? 0;
    dragRef.current = null;
    setDragging(false);
  };

  if (!map || !view) {
    return (
      <NoticeBox danger>
        Schematic unavailable - no mapping data for this location.
      </NoticeBox>
    );
  }

  const status = areaStatus || {};
  const workAreas = new Set((workOrders || []).map((order) => order.areaRef));
  const zoom = map.width / view.w;
  // Font size in turfs, scaled by the view. If this gets too ugly we can fuck around with fonts or sizing or just trash it
  const fontSize = view.w * 0.022;
  const hatch = view.w * 0.012;
  const labelDepartments = zoom < DEPARTMENT_LABEL_BELOW_ZOOM;
  const departmentFontSize = fontSize * 1.6;
  const departmentTracking = departmentFontSize * 0.18;
  const departmentLabels = labelDepartments
    ? getDepartmentLabels(map.areas)
    : [];

  return (
    <Stack fill vertical>
      <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
        <Box position="relative" width="100%" style={{ overflow: 'auto' }}>
          <svg
            ref={svgRef}
            viewBox={`${view.x} ${view.y} ${view.w} ${view.h}`}
            preserveAspectRatio="xMidYMid meet"
            onPointerDown={onPointerDown}
            onPointerMove={onPointerMove}
            onPointerUp={onPointerUp}
            onPointerCancel={onPointerUp}
            onContextMenu={(event) => {
              event.preventDefault();
              selectArea(null);
            }}
            style={{
              display: 'block',
              width: '100%',
              height: 'auto',
              cursor: dragging ? 'grabbing' : 'grab',
              touchAction: 'none',
            }}
          >
            <defs>
              <pattern
                id="stationAlertBlind"
                patternUnits="userSpaceOnUse"
                width={hatch}
                height={hatch}
                patternTransform="rotate(45)"
              >
                <rect
                  width={hatch}
                  height={hatch}
                  fill={COVERAGE_LAYER.color}
                  opacity={0.12}
                />
                <line
                  x1={0}
                  y1={0}
                  x2={0}
                  y2={hatch}
                  stroke={COVERAGE_LAYER.color}
                  strokeWidth={hatch * 0.35}
                  opacity={0.75}
                />
              </pattern>
            </defs>
            <image
              href={map.url}
              x={0}
              y={0}
              width={map.width}
              height={map.height}
              style={{
                imageRendering: 'pixelated',
                filter: enabled[TINT_LAYER.id] ? undefined : BACKDROP_FILTER,
              }}
            />
            {map.areas.map((area) => {
              const isSelected = area.ref === selected;
              const filters = isSelected ? ALL_LAYERS_ON : enabled;
              const faults = getAreaFaults(status[area.ref], filters);
              const color = faults[0]?.color ?? null;
              // An active alarm outranks a coverage gap
              const blind = !color && isAreaBlind(status[area.ref], filters);
              const isHovered = !dragging && area.ref === hovered;
              const dim = selected && !isSelected ? UNSELECTED_FILL_SCALE : 1;
              const fillOpacity = (color ? FAULT_FILL_OPACITY : 1) * dim;
              const wash = isSelected ? SELECT_WASH : HOVER_WASH;
              const labelRect = getLabelRect(area.rects);
              // does the text fit the room
              const textWidth = area.name.length * fontSize * 0.55;
              const showLabel =
                !labelDepartments &&
                !!labelRect &&
                (isSelected ||
                  (labelRect[2] > textWidth && labelRect[3] > fontSize * 1.6));
              const cx = labelRect ? labelRect[0] + labelRect[2] / 2 : 0;
              const cy = labelRect ? labelRect[1] + labelRect[3] / 2 : 0;
              const glyphSize = fontSize * 0.62;
              const glyphStep = glyphSize * 1.5;
              // Drop the ones the room has no width for rather than overflowing it
              const glyphs =
                labelRect && labelRect[3] > glyphSize * 1.5
                  ? faults.slice(0, Math.floor(labelRect[2] / glyphStep))
                  : [];
              const hasWork =
                enabled[WORK_LAYER.id] &&
                workAreas.has(area.ref) &&
                !!labelRect;
              // to stack instead of overlaying
              const tiers =
                (hasWork ? 1 : 0) +
                (showLabel ? 1 : 0) +
                (glyphs.length ? 1 : 0);
              const tierGap = fontSize * 1.05;
              const tierTop = cy - ((tiers - 1) * tierGap) / 2;
              const labelY = tierTop + (hasWork ? tierGap : 0);
              const glyphY =
                tierTop + ((hasWork ? 1 : 0) + (showLabel ? 1 : 0)) * tierGap;
              return (
                <g
                  key={area.ref}
                  onMouseEnter={() => setHovered(area.ref)}
                  onMouseLeave={() => {
                    if (hovered === area.ref) {
                      setHovered(null);
                    }
                  }}
                  onClick={() => {
                    if (lastMovedRef.current <= CLICK_SLOP) {
                      selectArea(area.ref);
                    }
                  }}
                  style={{ pointerEvents: 'all', cursor: 'pointer' }}
                >
                  {area.rects.map(([x, y, w, h], index) => (
                    <rect
                      key={index}
                      x={x}
                      y={y}
                      width={w}
                      height={h}
                      fill={
                        blind
                          ? 'url(#stationAlertBlind)'
                          : color || 'transparent'
                      }
                      fillOpacity={fillOpacity}
                    />
                  ))}
                  {(isSelected || isHovered) &&
                    area.rects.map(([x, y, w, h], index) => (
                      <rect
                        key={`wash-${index}`}
                        x={x}
                        y={y}
                        width={w}
                        height={h}
                        fill="#ffffff"
                        fillOpacity={wash}
                      />
                    ))}
                  {hasWork && (
                    <circle
                      cx={cx}
                      cy={tierTop}
                      r={fontSize * 0.35}
                      fill={WORK_LAYER.color}
                      stroke="#0b0e12"
                      strokeWidth={fontSize * 0.1}
                      style={{ pointerEvents: 'none' }}
                    />
                  )}
                  {glyphs.map((layer, index) => (
                    <FaultGlyph
                      key={layer.id}
                      shape={layer.shape}
                      color={layer.color}
                      size={glyphSize}
                      cx={cx + (index - (glyphs.length - 1) / 2) * glyphStep}
                      cy={glyphY}
                    />
                  ))}
                  {showLabel && (
                    <text
                      x={cx}
                      y={labelY}
                      textAnchor="middle"
                      dominantBaseline="middle"
                      fontSize={fontSize}
                      fill="#e6ebf2"
                      stroke="#0b0e12"
                      strokeWidth={fontSize * 0.2}
                      paintOrder="stroke"
                      style={{ pointerEvents: 'none', userSelect: 'none' }}
                    >
                      {area.name}
                    </text>
                  )}
                </g>
              );
            })}
            {departmentLabels.map(({ name, rect }) =>
              !rect ? null : (
                <text
                  key={name}
                  x={rect[0] + rect[2] / 2}
                  y={rect[1] + rect[3] / 2}
                  dx={-departmentTracking / 2}
                  textAnchor="middle"
                  dominantBaseline="middle"
                  fontSize={departmentFontSize}
                  letterSpacing={departmentTracking}
                  fill="#f2f5f8"
                  fillOpacity={0.6}
                  stroke="#0b0e12"
                  strokeWidth={departmentFontSize * 0.22}
                  paintOrder="stroke"
                  style={{ pointerEvents: 'none', userSelect: 'none' }}
                >
                  {name.toUpperCase()}
                </text>
              ),
            )}
            {!!map.viewer && (
              <g style={{ pointerEvents: 'none' }}>
                <circle
                  cx={map.viewer[0]}
                  cy={map.viewer[1]}
                  r={fontSize * 0.45}
                  fill="none"
                  stroke={VIEWER_COLOR}
                  strokeWidth={fontSize * 0.12}
                  opacity={0.55}
                >
                  <animate
                    attributeName="r"
                    values={`${fontSize * 0.45};${fontSize * 1.4}`}
                    dur="2.4s"
                    repeatCount="indefinite"
                  />
                  <animate
                    attributeName="opacity"
                    values="0.55;0"
                    dur="2.4s"
                    repeatCount="indefinite"
                  />
                </circle>
                <circle
                  cx={map.viewer[0]}
                  cy={map.viewer[1]}
                  r={fontSize * 0.45}
                  fill="none"
                  stroke="#0b0e12"
                  strokeWidth={fontSize * 0.26}
                />
                <circle
                  cx={map.viewer[0]}
                  cy={map.viewer[1]}
                  r={fontSize * 0.45}
                  fill="none"
                  stroke={VIEWER_COLOR}
                  strokeWidth={fontSize * 0.13}
                />
                <circle
                  cx={map.viewer[0]}
                  cy={map.viewer[1]}
                  r={fontSize * 0.13}
                  fill={VIEWER_COLOR}
                  stroke="#0b0e12"
                  strokeWidth={fontSize * 0.06}
                />
              </g>
            )}
          </svg>
        </Box>
      </Stack.Item>
      <Stack.Item shrink={0}>
        <Section>
          <Stack wrap>
            {TOGGLES.map((layer) => (
              <Stack.Item key={layer.id}>
                <Button
                  icon={layer.icon}
                  selected={enabled[layer.id]}
                  tooltip={layer.tooltip ?? `Toggle ${layer.label} layer`}
                  onClick={() =>
                    setEnabled((current) => ({
                      ...current,
                      [layer.id]: !current[layer.id],
                    }))
                  }
                >
                  {layer.label}
                </Button>
              </Stack.Item>
            ))}
            <Stack.Item grow />
            <Stack.Item>
              <Button
                icon="magnifying-glass-minus"
                tooltip="Zoom out"
                disabled={zoom <= 1.01}
                onClick={() => zoomByButton(1 / ZOOM_STEP)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="magnifying-glass-plus"
                tooltip="Zoom in"
                disabled={zoom >= MAX_ZOOM - 0.01}
                onClick={() => zoomByButton(ZOOM_STEP)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="expand"
                tooltip="Fit whole station"
                disabled={zoom <= 1.01}
                onClick={() => setViewState(null)}
              >
                {zoom.toFixed(1)}x
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
