import { BooleanLike } from 'common/react';
import { sortBy } from 'es-toolkit';
import { useEffect, useRef, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  AreaReadout,
  type CrewMember,
  getMapWindowSize,
  type MapData,
  StationAlertMap,
  type WorkOrder,
} from './StationAlertMap';

/** Keep Camera fields null unless cameraView is set. */
type AlarmEntry = {
  name: string;
  areaRef: string;
  cameras: number | null;
  sources: number | null;
  ref: string | null;
};

type AlarmCategory = {
  name: string;
  alerts: AlarmEntry[];
};

type Data = {
  cameraView: BooleanLike;
  map: MapData | null;
  workOrders: WorkOrder[] | null;
  alarms: AlarmCategory[];
  /** designator if you can assign others. see can_assign_work() in work_order.dm. */
  canAssign: BooleanLike;
  crew: CrewMember[] | null;
};

/** Asks the map to frame an area. The nonce(NUMBER USED ONCE) lets the same one fire again. */
type FocusRequest = { ref: string; nonce: number };

export type AlertLinkage = {
  hovered: string | null;
  setHovered: (ref: string | null) => void;
  /** Sticky, meant for clicks */
  selected: string | null;
  focusRequest: FocusRequest | null;
  selectArea: (areaRef: string | null) => void;
};

const PRIORITY_CLASS: Record<number, string> = {
  0: 'color-bad',
  1: 'color-average',
  2: 'color-label',
  3: 'color-label',
};

/** docked alarm column, in px */
export const SIDEBAR_WIDTH = 260;

/** Links hover and framing state between the schematic and the alarm list. */
export const useAlertLinkage = (): AlertLinkage => {
  const [hovered, setHovered] = useState<string | null>(null);
  const [selected, setSelected] = useState<string | null>(null);
  const [focusRequest, setFocusRequest] = useState<FocusRequest | null>(null);

  const selectArea = (areaRef: string | null) => {
    setSelected(areaRef);
    if (!areaRef) {
      return;
    }
    setFocusRequest({ ref: areaRef, nonce: Date.now() });
  };

  return { hovered, setHovered, selected, focusRequest, selectArea };
};

const useSelectedRow = (selected: string | null) => {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    ref.current?.scrollIntoView({ block: 'nearest' });
  }, [selected]);
  return ref;
};

const getRowBackground = (isSelected: boolean, isHovered: boolean) => {
  if (isSelected) {
    return 'rgba(122, 200, 255, 0.18)';
  }
  return isHovered ? 'rgba(255, 255, 255, 0.12)' : undefined;
};

type AlertSidebarProps = Pick<
  AlertLinkage,
  'hovered' | 'setHovered' | 'selected' | 'selectArea'
> & {
  showDetail?: boolean;
};

/** The alarm column */
export const AlertSidebar = (props: AlertSidebarProps) => {
  const {
    hovered,
    setHovered,
    selected,
    selectArea,
    showDetail = true,
  } = props;
  const { data } = useBackend<Data>();
  const { workOrders } = data;
  const [tab, setTab] = useState('alarms');
  const showWork = workOrders !== null;
  const orders = workOrders || [];
  const unclaimed = orders.filter((order) => !order.claimant).length;

  useEffect(() => {
    if (!selected || !showWork) {
      return;
    }
    const inAlarms = (data.alarms || []).some((category) =>
      category.alerts.some((alert) => alert.areaRef === selected),
    );
    const inWork = orders.some((order) => order.areaRef === selected);
    if (tab === 'alarms' && !inAlarms && inWork) {
      setTab('work');
    } else if (tab === 'work' && !inWork && inAlarms) {
      setTab('alarms');
    }
  }, [selected]);

  return (
    <Stack fill vertical>
      <Stack.Item shrink={0}>
        <Tabs fluid>
          <Tabs.Tab
            selected={tab === 'alarms'}
            onClick={() => setTab('alarms')}
          >
            Alarms
          </Tabs.Tab>
          {showWork && (
            <Tabs.Tab selected={tab === 'work'} onClick={() => setTab('work')}>
              Work {orders.length > 0 && `(${unclaimed}/${orders.length})`}
            </Tabs.Tab>
          )}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow basis={0} style={{ overflowY: 'auto' }}>
        {showWork && tab === 'work' ? (
          <WorkOrderList
            orders={orders}
            hovered={hovered}
            setHovered={setHovered}
            selected={selected}
            onSelect={selectArea}
          />
        ) : (
          <StationAlertConsoleContent
            hovered={hovered}
            setHovered={setHovered}
            selected={selected}
            onSelect={selectArea}
          />
        )}
      </Stack.Item>
      {showDetail && (
        <Stack.Item shrink={0}>
          <AreaReadout areaRef={hovered ?? selected} />
        </Stack.Item>
      )}
    </Stack>
  );
};

type WorkOrderListProps = {
  orders: WorkOrder[];
  hovered: string | null;
  setHovered: (ref: string | null) => void;
  selected: string | null;
  onSelect: (ref: string | null) => void;
};

/** Only rendered for whoever can assign, see canAssign() */
const AssignMenu = (props: { orderKey: string; crew: CrewMember[] }) => {
  const { act } = useBackend<Data>();
  const { orderKey, crew } = props;

  if (!crew.length) {
    return (
      <Button compact fluid disabled icon="user-slash">
        No one to assign
      </Button>
    );
  }
  return (
    <Dropdown
      width="100%"
      selected=""
      placeholder="Assign"
      options={crew.map((member) => ({
        // Current load first, then their record, so you can see who is already busy.
        displayText: `${member.name} — ${member.openJobs} open, ${member.completed} done`,
        value: member.ckey,
      }))}
      onSelected={(value) =>
        act('assign_order', { key: orderKey, ckey: value })
      }
    />
  );
};

/** Jobs derived from station state. Made to last as long as the fault does */
const WorkOrderList = (props: WorkOrderListProps) => {
  const { act, data } = useBackend<Data>();
  const { canAssign, crew } = data;
  const { orders, hovered, setHovered, selected, onSelect } = props;
  const selectedRef = useSelectedRow(selected);

  if (!orders.length) {
    return (
      <Section title="Work Orders">
        <Box className="color-good">
          No outstanding work. Every area reports in.
        </Box>
      </Section>
    );
  }

  // Grouped by place, then urgency. i.e. broken room shows that theres a breach before the air alarm detecting no air
  const byArea: Record<string, WorkOrder[]> = {};
  for (const order of orders) {
    (byArea[order.area] ||= []).push(order);
  }
  const groups = sortBy(
    Object.entries(byArea).map(([area, areaOrders]) => ({
      area,
      orders: sortBy(areaOrders, [
        (order) => order.priority,
        (order) => (order.claimant ? 1 : 0),
        (order) => order.task,
      ]),
      // A group is as urgent as the worst thing in it.
      worst: Math.min(...areaOrders.map((order) => order.priority)),
      unclaimed: areaOrders.filter((order) => !order.claimant).length,
    })),
    [
      (group) => group.worst,
      (group) => -group.unclaimed,
      (group) => group.area,
    ],
  );

  return (
    <Section title="Work Orders">
      {groups.map((group) => (
        <Box key={group.area} mb={1}>
          {group.orders[0]?.areaRef === selected && <div ref={selectedRef} />}
          <Box
            className="color-label"
            fontSize="0.9em"
            style={{ borderBottom: '1px solid rgba(255, 255, 255, 0.15)' }}
          >
            {group.area}
            {group.unclaimed > 0 ? ` — ${group.unclaimed} unclaimed` : ''}
          </Box>
          {group.orders.map((order) => (
            <Box
              key={order.key}
              onMouseOver={() => setHovered(order.areaRef)}
              onMouseLeave={() => {
                if (hovered === order.areaRef) {
                  setHovered(null);
                }
              }}
              onClick={() => onSelect(order.areaRef)}
              style={{
                cursor: 'pointer',
                paddingLeft: '4px',
                borderLeft: order.claimant
                  ? '2px solid rgba(139, 195, 74, 0.65)'
                  : '2px solid transparent',
                background: getRowBackground(
                  order.areaRef === selected,
                  hovered === order.areaRef,
                ),
              }}
            >
              <Stack align="baseline">
                <Stack.Item grow>
                  <Box
                    className={PRIORITY_CLASS[order.priority]}
                    style={{ opacity: order.claimant ? 0.45 : 1 }}
                  >
                    {order.task}
                  </Box>
                  {!!order.claimant && (
                    <Box className="color-good" fontSize="0.9em">
                      <Icon name="user-check" mr={0.5} />
                      {order.claimant}
                      {order.assignedBy ? ` (by ${order.assignedBy})` : ''}
                    </Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    compact
                    icon={order.claimant ? 'user-minus' : 'user-plus'}
                    color={order.claimant ? 'transparent' : 'good'}
                    tooltip={
                      order.claimant
                        ? 'Release, or take over from them'
                        : 'Put your name on this'
                    }
                    onClick={(event) => {
                      event.stopPropagation();
                      act('toggle_claim', { key: order.key });
                    }}
                  />
                </Stack.Item>
              </Stack>
              {!!canAssign && (
                <Box mb={0.5} onClick={(event) => event.stopPropagation()}>
                  <AssignMenu orderKey={order.key} crew={crew || []} />
                </Box>
              )}
            </Box>
          ))}
        </Box>
      ))}
    </Section>
  );
};

export const StationAlertConsole = () => {
  const { data } = useBackend<Data>();
  const { cameraView, map } = data;
  const linkage = useAlertLinkage();
  const [width, height] = getMapWindowSize(map, 0, SIDEBAR_WIDTH);

  // No map for you
  if (!map) {
    return (
      <Window width={cameraView ? 390 : 345} height={587}>
        <Window.Content scrollable>
          <StationAlertConsoleContent />
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={width} height={height}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis={0}>
            <StationAlertMap
              hovered={linkage.hovered}
              setHovered={linkage.setHovered}
              selected={linkage.selected}
              selectArea={linkage.selectArea}
              focusRequest={linkage.focusRequest}
            />
          </Stack.Item>
          <Stack.Item shrink={0} width={`${SIDEBAR_WIDTH}px`}>
            <AlertSidebar {...linkage} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type AlarmListProps = {
  hovered?: string | null;
  setHovered?: (ref: string | null) => void;
  selected?: string | null;
  onSelect?: (ref: string | null) => void;
};

export const StationAlertConsoleContent = (props: AlarmListProps = {}) => {
  const { act, data } = useBackend<Data>();
  const { cameraView } = data;
  const { hovered, setHovered, selected, onSelect } = props;
  const linked = !!onSelect;
  const selectedRef = useSelectedRow(selected ?? null);

  const sortingKey: Record<string, number> = {
    Fire: 0,
    Atmosphere: 1,
    Power: 2,
    Burglar: 3,
    Motion: 4,
    Camera: 5,
  };

  const sortedAlarms = sortBy(data.alarms || [], [
    (alarm) => sortingKey[alarm.name],
  ]);
  const raised = sortedAlarms.filter((category) => category.alerts.length > 0);
  const clear = sortedAlarms.filter((category) => !category.alerts.length);

  // An area can be listed under several categories; anchor on the first so the scroll
  // lands on the highest mention of it rather than the last.
  const anchorCategory = selected
    ? raised.find((category) =>
        category.alerts.some((alert) => alert.areaRef === selected),
      )?.name
    : undefined;

  const cameraTooltip = (cameras: number | null) => {
    if (!cameras) {
      return 'No cameras cover this area';
    }
    return cameras > 1 ? `Jump to camera (${cameras})` : 'Jump to camera';
  };
  const jumpToCamera = (alert: AlarmEntry) =>
    act('select_camera', { alert: alert.ref });

  return (
    <Section title="Alarms">
      {raised.map((category) => (
        <Box key={category.name} mb={1}>
          <Box
            className="color-label"
            fontSize="0.9em"
            style={{ borderBottom: '1px solid rgba(255, 255, 255, 0.15)' }}
          >
            {category.name}
          </Box>
          {category.alerts.map((alert) => (
            <Box
              key={alert.areaRef}
              onMouseOver={() => setHovered?.(alert.areaRef)}
              onMouseLeave={() => {
                if (hovered === alert.areaRef) {
                  setHovered?.(null);
                }
              }}
              onClick={() => onSelect?.(alert.areaRef)}
              style={{
                paddingLeft: '4px',
                cursor: linked ? 'pointer' : undefined,
                background: linked
                  ? getRowBackground(
                      alert.areaRef === selected,
                      hovered === alert.areaRef,
                    )
                  : undefined,
              }}
            >
              {alert.areaRef === selected &&
                category.name === anchorCategory && <div ref={selectedRef} />}
              <Stack align="baseline">
                <Stack.Item grow>
                  <Box className="color-average">
                    {alert.name}
                    {cameraView && (alert.sources ?? 0) > 1
                      ? ` (${alert.sources} sources)`
                      : ''}
                  </Box>
                </Stack.Item>
                {!!cameraView && (
                  <Stack.Item>
                    <Button
                      compact
                      icon="video"
                      disabled={!alert.cameras}
                      tooltip={cameraTooltip(alert.cameras)}
                      onClick={() => jumpToCamera(alert)}
                    >
                      {(alert.cameras ?? 0) > 1 ? alert.cameras : null}
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            </Box>
          ))}
        </Box>
      ))}
      {!raised.length && <Box className="color-good">All systems nominal.</Box>}
      {!!raised.length && !!clear.length && (
        <Box className="color-good" fontSize="0.9em" mt={1}>
          Nominal: {clear.map((category) => category.name).join(', ')}
        </Box>
      )}
    </Section>
  );
};
