import { BooleanLike } from 'common/react';
import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
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
  const [focusRequest, setFocusRequest] = useState<FocusRequest | null>(null);

  const selectArea = (areaRef: string | null) => {
    if (!areaRef) {
      return;
    }
    // The nonce(NUMBER USED ONCE) lets the same entry be clicked twice
    setFocusRequest({ ref: areaRef, nonce: Date.now() });
  };

  return { hovered, setHovered, focusRequest, selectArea };
};

type AlertSidebarProps = Pick<
  AlertLinkage,
  'hovered' | 'setHovered' | 'selectArea'
> & {
  showDetail?: boolean;
};

/** The alarm column */
export const AlertSidebar = (props: AlertSidebarProps) => {
  const { hovered, setHovered, selectArea, showDetail = true } = props;
  const { data } = useBackend<Data>();
  const { workOrders } = data;
  const [tab, setTab] = useState('alarms');
  const showWork = workOrders !== null;
  const orders = workOrders || [];
  const unclaimed = orders.filter((order) => !order.claimant).length;

  return (
    <Stack fill vertical>
      <Stack.Item shrink={0}>
        {/* Never unmount schematic when switching tabs */}
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
            onSelect={selectArea}
          />
        ) : (
          <StationAlertConsoleContent
            hovered={hovered}
            setHovered={setHovered}
            onSelect={selectArea}
          />
        )}
      </Stack.Item>
      {showDetail && (
        <Stack.Item shrink={0}>
          <AreaReadout areaRef={hovered} />
        </Stack.Item>
      )}
    </Stack>
  );
};

type WorkOrderListProps = {
  orders: WorkOrder[];
  hovered: string | null;
  setHovered: (ref: string | null) => void;
  onSelect: (ref: string | null) => void;
};

/** Only rendered for whoever can assign, see canAssign() */
const AssignMenu = (props: { orderKey: string; crew: CrewMember[] }) => {
  const { act } = useBackend<Data>();
  const { orderKey, crew } = props;

  if (!crew.length) {
    return null;
  }
  return (
    <Dropdown
      width="16em"
      selected=""
      placeholder="Assign"
      options={crew.map((member) => ({
        // Current load first, then their record, so you can see who is already busy.
        displayText: `${member.name} - ${member.openJobs} open, ${member.completed} done${
          member.dropped ? `, ${member.dropped} dropped` : ''
        }`,
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
  const { orders, hovered, setHovered, onSelect } = props;

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
                background:
                  hovered === order.areaRef
                    ? 'rgba(255, 255, 255, 0.12)'
                    : undefined,
              }}
            >
              <Stack align="baseline">
                <Stack.Item grow>
                  <Box
                    className={
                      order.claimant
                        ? 'color-label'
                        : PRIORITY_CLASS[order.priority]
                    }
                  >
                    {order.task}
                  </Box>
                  {(order.claimant || order.assignedBy) && (
                    <Box className="color-label" fontSize="0.9em">
                      {order.claimant}
                      {order.assignedBy ? ` (by ${order.assignedBy})` : ''}
                    </Box>
                  )}
                </Stack.Item>
                {!!canAssign && (
                  <Stack.Item onClick={(event) => event.stopPropagation()}>
                    <AssignMenu orderKey={order.key} crew={crew || []} />
                  </Stack.Item>
                )}
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
  onSelect?: (ref: string | null) => void;
};

export const StationAlertConsoleContent = (props: AlarmListProps = {}) => {
  const { act, data } = useBackend<Data>();
  const { cameraView } = data;
  const { hovered, setHovered, onSelect } = props;
  const linked = !!onSelect;

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

  return (
    <>
      {sortedAlarms.map((category) => (
        <Section key={category.name} title={`${category.name} Alarms`}>
          <ul>
            {category.alerts.length === 0 && (
              <li className="color-good">Systems nominal</li>
            )}
            {category.alerts.map((alert) => (
              <Box
                key={alert.name}
                onMouseOver={() => setHovered?.(alert.areaRef)}
                onMouseLeave={() => {
                  if (hovered === alert.areaRef) {
                    setHovered?.(null);
                  }
                }}
                onClick={() => onSelect?.(alert.areaRef)}
                style={
                  linked
                    ? {
                        cursor: 'pointer',
                        background:
                          hovered === alert.areaRef
                            ? 'rgba(255, 255, 255, 0.12)'
                            : undefined,
                      }
                    : undefined
                }
              >
                <Stack height="30px" align="baseline">
                  <Stack.Item grow>
                    <li className="color-average">
                      {alert.name}{' '}
                      {cameraView && (alert.sources ?? 0) > 1
                        ? ` (${alert.sources} sources)`
                        : ''}
                    </li>
                  </Stack.Item>
                  {!!cameraView && (
                    <Stack.Item>
                      <Button
                        textAlign="center"
                        width="100px"
                        icon={alert.cameras ? 'video' : ''}
                        disabled={!alert.cameras}
                        content={
                          alert.cameras === 1
                            ? `${alert.cameras} Camera`
                            : (alert.cameras ?? 0) > 1
                              ? `${alert.cameras} Cameras`
                              : 'No Camera'
                        }
                        onClick={() =>
                          act('select_camera', {
                            alert: alert.ref,
                          })
                        }
                      />
                    </Stack.Item>
                  )}
                </Stack>
              </Box>
            ))}
          </ul>
        </Section>
      ))}
    </>
  );
};
