/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useLocalState } from 'tgui/backend';
import { Button, Section, Stack } from 'tgui/components';
import { Box, Divider, DraggableControl } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { logger } from 'tgui/logging';

import { NowPlayingWidget, useAudio } from './audio';
import { ChatPanel, ChatTabs } from './chat';
import { useGame } from './game';
import { Notifications } from './Notifications';
import { PingIndicator } from './ping';
import { ReconnectButtons } from './reconnect';
import { SettingsPanel, useSettings } from './settings';
import { updateSettings } from './settings/actions';
import { StatTabs } from './stat';

export const Panel = (props) => {
  const audio = useAudio();
  const settings = useSettings();
  const game = useGame();
  const dispatch = useDispatch();
  if (process.env.NODE_ENV !== 'production') {
    const { useDebug, KitchenSink } = require('tgui/debug');
    const debug = useDebug();
    if (debug.kitchenSink) {
      return <KitchenSink panel />;
    }
  }

  if (isNaN(settings.statSize)) {
    logger.warn('Settings.statSize is not a number!');
    dispatch(
      updateSettings({
        statSize: 40,
      }),
    );
    return;
  }

  const [number, setNumber] = useLocalState('number', settings.statSize);
  const resizeFunction = (value) => {
    dispatch(
      updateSettings({
        statSize: Math.max(Math.min(value, 90), 10),
      }),
    );
  };
  return (
    <Pane theme={settings.theme}>
      <Stack height={98 - number + '%'} vertical>
        <StatTabs direction="column" />
      </Stack>
      <DraggableControl
        value={number}
        height="1%"
        minValue={0}
        maxValue={100}
        dragMatrix={[0, -1]}
        step={1}
        stepPixelSize={9}
        onDrag={(e, value) => resizeFunction(value)}
        updateRate={5}
      >
        {(control) => (
          <Box onMouseDown={control.handleDragStart} height="10px">
            <Box
              position="relative"
              height="4px"
              backgroundColor="grey"
              top="3px"
            >
              <Divider />
              {control.inputElement}
            </Box>
          </Box>
        )}
      </DraggableControl>
      <Stack mt={1} vertical height={number - 1 + '%'}>
        <Stack.Item>
          <Section>
            <Stack my={-1.25} align="center">
              <Stack.Item grow overflowX="auto">
                <ChatTabs />
              </Stack.Item>
              <Stack.Item>
                <PingIndicator />
              </Stack.Item>
              <Stack.Item mx={0.5}>
                <Button
                  color="grey"
                  selected={audio.visible}
                  icon="music"
                  tooltip="Music player"
                  tooltipPosition="bottom-start"
                  onClick={() => audio.toggle()}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={settings.visible ? 'times' : 'cog'}
                  selected={settings.visible}
                  tooltip={
                    settings.visible ? 'Close settings' : 'Open settings'
                  }
                  tooltipPosition="bottom-start"
                  onClick={() => settings.toggle()}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        {audio.visible && (
          <Stack.Item>
            <Section>
              <NowPlayingWidget />
            </Section>
          </Stack.Item>
        )}
        {settings.visible && (
          <Stack.Item>
            <SettingsPanel />
          </Stack.Item>
        )}
        <Stack.Item mt={1} grow>
          <Section fill fitted position="relative">
            <Pane.Content scrollable>
              <ChatPanel lineHeight={settings.lineHeight} />
            </Pane.Content>
            <Notifications>
              {game.connectionLostAt && (
                <Notifications.Item rightSlot={<ReconnectButtons />}>
                  You are either AFK, experiencing lag or the connection has
                  closed.
                </Notifications.Item>
              )}
              {game.roundRestartedAt && (
                <Notifications.Item>
                  The connection has been closed because the server is
                  restarting. Please wait while you automatically reconnect.
                </Notifications.Item>
              )}
            </Notifications>
          </Section>
        </Stack.Item>
      </Stack>
    </Pane>
  );
};
