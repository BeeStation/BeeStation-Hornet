import { exhaustiveCheck } from 'common/exhaustive';

import { useBackend, useLocalState } from '../../backend';
import { Button, Stack } from '../../components';
import { Window } from '../../layouts';
import { GamePreferencesSelectedPage, PreferencesMenuData } from './data';
import { GamePreferencesPage } from './GamePreferencesPage';
import { KeybindingsPage } from './KeybindingsPage';
import { PageButton } from './PageButton';
import { SaveStatus } from './SaveStatus';

export const GamePreferenceWindow = (props: {
  startingPage?: GamePreferencesSelectedPage;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [currentPage, setCurrentPage] = useLocalState(
    'currentPage_game',
    props.startingPage ?? GamePreferencesSelectedPage.Settings,
  );

  let pageContents;

  switch (currentPage) {
    case GamePreferencesSelectedPage.Keybindings:
      pageContents = <KeybindingsPage />;
      break;
    case GamePreferencesSelectedPage.Settings:
      pageContents = <GamePreferencesPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window
      title="Game Preferences"
      width={1200}
      height={770}
      theme="generic-yellow"
      buttons={
        <>
          <Button
            icon="user"
            tooltip="Open Character Preferences"
            tooltipPosition="bottom"
            style={{ borderRadius: '20px' }}
            onClick={() => act('open_character_preferences')}
          />
          <SaveStatus />
        </>
      }
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={GamePreferencesSelectedPage.Settings}
                  setPage={setCurrentPage}
                >
                  Settings
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={GamePreferencesSelectedPage.Keybindings}
                  setPage={setCurrentPage}
                >
                  Keybindings
                </PageButton>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Divider />

          <Stack.Item grow shrink basis="1px">
            {pageContents}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
