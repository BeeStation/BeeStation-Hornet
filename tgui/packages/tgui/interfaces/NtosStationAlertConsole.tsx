import { BooleanLike } from 'common/react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import {
  AlertSidebar,
  SIDEBAR_WIDTH,
  useAlertLinkage,
} from './StationAlertConsole';
import {
  getMapWindowSize,
  type MapData,
  StationAlertMap,
} from './StationAlertMap';

type Data = {
  /** PDA snowflake */
  full_capability: BooleanLike;
  map: MapData | null;
};

// Put the header above the plain console body
const NTOS_HEADER_HEIGHT = 28;

export const NtosStationAlertConsole = () => {
  const { data } = useBackend<Data>();
  const { full_capability, map } = data;
  const linkage = useAlertLinkage();
  const showMap = !!full_capability && !!map;
  const [width, height] = getMapWindowSize(
    map,
    NTOS_HEADER_HEIGHT,
    SIDEBAR_WIDTH,
  );

  // No map for you
  if (!showMap) {
    return (
      <NtosWindow width={335} height={587}>
        <NtosWindow.Content>
          <AlertSidebar {...linkage} showDetail={false} />
        </NtosWindow.Content>
      </NtosWindow>
    );
  }

  return (
    <NtosWindow width={width} height={height}>
      <NtosWindow.Content>
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
      </NtosWindow.Content>
    </NtosWindow>
  );
};
