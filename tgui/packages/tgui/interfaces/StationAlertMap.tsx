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
};

type AreaStatus = {
  alarms?: string[];
  power?: string;
  blind?: Record<string, string>;
  integrity?: number;
  pressure?: number;
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
};

/** `id` matches the alarm types in code/__DEFINES/alarm.dm. Ordered by severity. */
const ALARM_LAYERS: Layer[] = [
  { id: 'Fire', label: 'Fire', icon: 'fire', color: '#e8703a' },
  { id: 'Atmosphere', label: 'Atmos', icon: 'wind', color: '#4ab8e0' },
  { id: 'Power', label: 'Power', icon: 'bolt', color: '#e0c040' },
];

const APC_LAYER: Layer = {
  id: 'apc',
  label: 'Grid',
  icon: 'plug',
  color: '#c86a30',
};

const INTEGRITY_LAYER: Layer = {
  id: 'integrity',
  label: 'Damage',
  icon: 'house-crack',
  color: '#b0553f',
};

const LAYERS: Layer[] = [...ALARM_LAYERS, APC_LAYER, INTEGRITY_LAYER];

const INTEGRITY_DAMAGED_AT = 90;

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

const TOGGLES: Layer[] = [...LAYERS, COVERAGE_LAYER, WORK_LAYER];

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

const getAreaColor = (
  status: AreaStatus | undefined,
  enabled: Record<string, boolean>,
): string | null => {
  if (!status) {
    return null;
  }
  for (const layer of ALARM_LAYERS) {
    if (enabled[layer.id] && status.alarms?.includes(layer.id)) {
      return layer.color;
    }
    if (
      layer.id === 'Atmosphere' &&
      enabled[layer.id] &&
      status.pressure !== undefined
    ) {
      return layer.color;
    }
  }
  if (enabled[APC_LAYER.id] && status.power) {
    return APC_LAYER.color;
  }
  if (
    enabled[INTEGRITY_LAYER.id] &&
    status.integrity !== undefined &&
    status.integrity <= INTEGRITY_DAMAGED_AT
  ) {
    return INTEGRITY_LAYER.color;
  }
  return null;
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
    if (integrity === undefined) {
      text = 'Intact';
      color = 'good';
    } else {
      text = `${integrity}% of as-built`;
      color = integrity <= INTEGRITY_DAMAGED_AT ? 'bad' : 'average';
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

  // Always four rows: a shorter placeholder would resize the panel on every hover.
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
  /** Bumped by the alarm list to frame an area. The nonce lets the same one re-fire. */
  focusRequest: { ref: string; nonce: number } | null;
};

export const StationAlertMap = (props: StationAlertMapProps) => {
  const { hovered, setHovered, focusRequest } = props;
  const { data } = useBackend<Data>();
  const { map, areaStatus, workOrders } = data;

  const [enabled, setEnabled] = useState<Record<string, boolean>>(
    Object.fromEntries(TOGGLES.map((layer) => [layer.id, true])),
  );
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
    // Capturing here would retarget the pointer and swallow click-to-focus on areas, so we
    // capture once a drag starts.
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
    // pointerup lands before click, so stash the travel for the click handler to check.
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
  // Font size in turfs, scaled by the view, so labels hold a constant on-screen size.
  const fontSize = view.w * 0.022;
  const labelDepartments = zoom < DEPARTMENT_LABEL_BELOW_ZOOM;
  const departmentFontSize = fontSize * 1.6;
  const departmentLabels = labelDepartments
    ? getDepartmentLabels(map.areas)
    : [];

  return (
    <Stack fill vertical>
      {/* basis={0} so a tall schematic scrolls rather than pushing the toolbar off-window. */}
      <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
        {/*
          The schematic fills the width it is given and derives height from the viewBox
          aspect. Sizing off `height: 100%` collapses when an ancestor resolves to auto.
        */}
        <Box position="relative" width="100%" style={{ overflow: 'auto' }}>
          <svg
            ref={svgRef}
            viewBox={`${view.x} ${view.y} ${view.w} ${view.h}`}
            preserveAspectRatio="xMidYMid meet"
            onPointerDown={onPointerDown}
            onPointerMove={onPointerMove}
            onPointerUp={onPointerUp}
            onPointerCancel={onPointerUp}
            style={{
              display: 'block',
              width: '100%',
              height: 'auto',
              cursor: dragging ? 'grabbing' : 'grab',
              touchAction: 'none',
            }}
          >
            <defs>
              {/* Hatched, not tinted: colour is already carrying alarm state. */}
              <pattern
                id="stationAlertBlind"
                patternUnits="userSpaceOnUse"
                width={4}
                height={4}
                patternTransform="rotate(45)"
              >
                <rect
                  width={4}
                  height={4}
                  fill={COVERAGE_LAYER.color}
                  opacity={0.12}
                />
                <line
                  x1={0}
                  y1={0}
                  x2={0}
                  y2={4}
                  stroke={COVERAGE_LAYER.color}
                  strokeWidth={1.4}
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
              style={{ imageRendering: 'pixelated' }}
            />
            {map.areas.map((area) => {
              const color = getAreaColor(status[area.ref], enabled);
              // An active alarm outranks a coverage gap.
              const blind = !color && isAreaBlind(status[area.ref], enabled);
              const isHovered = !dragging && area.ref === hovered;
              const labelRect = getLabelRect(area.rects);
              // Rough advance width - enough to decide whether a name fits its room.
              const textWidth = area.name.length * fontSize * 0.55;
              const showLabel =
                !labelDepartments &&
                !!labelRect &&
                labelRect[2] > textWidth &&
                labelRect[3] > fontSize * 1.6;
              return (
                <g
                  key={area.ref}
                  onMouseEnter={() => setHovered(area.ref)}
                  onMouseLeave={() => {
                    // enter fires before leave between areas, so only clear if still ours.
                    if (hovered === area.ref) {
                      setHovered(null);
                    }
                  }}
                  onClick={() => {
                    if (lastMovedRef.current <= CLICK_SLOP) {
                      focusArea(area);
                    }
                  }}
                  style={{ pointerEvents: 'all', cursor: 'pointer' }}
                >
                  {/* Fills only - stroking each rect would draw the area's internal seams. */}
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
                      fillOpacity={color ? 0.45 : 1}
                    />
                  ))}
                  {isHovered &&
                    area.rects.map(([x, y, w, h], index) => (
                      <rect
                        key={`hover-${index}`}
                        x={x}
                        y={y}
                        width={w}
                        height={h}
                        fill="#ffffff"
                        fillOpacity={0.22}
                      />
                    ))}
                  {enabled[WORK_LAYER.id] &&
                    workAreas.has(area.ref) &&
                    !!labelRect && (
                      <circle
                        cx={labelRect[0] + labelRect[2] / 2}
                        cy={
                          labelRect[1] +
                          labelRect[3] / 2 -
                          (showLabel ? fontSize * 1.1 : 0)
                        }
                        r={fontSize * 0.35}
                        fill={WORK_LAYER.color}
                        stroke="#0b0e12"
                        strokeWidth={fontSize * 0.1}
                        style={{ pointerEvents: 'none' }}
                      />
                    )}
                  {showLabel && (
                    <text
                      x={labelRect[0] + labelRect[2] / 2}
                      y={labelRect[1] + labelRect[3] / 2}
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
            {/* After the areas so department names sit above the fills. */}
            {departmentLabels.map(({ name, rect }) =>
              !rect ? null : (
                <text
                  key={name}
                  x={rect[0] + rect[2] / 2}
                  y={rect[1] + rect[3] / 2}
                  textAnchor="middle"
                  dominantBaseline="middle"
                  fontSize={departmentFontSize}
                  fill="#f2f5f8"
                  fillOpacity={0.85}
                  stroke="#0b0e12"
                  strokeWidth={departmentFontSize * 0.22}
                  paintOrder="stroke"
                  style={{ pointerEvents: 'none', userSelect: 'none' }}
                >
                  {name}
                </text>
              ),
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
                  tooltip={`Toggle ${layer.label} layer`}
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
