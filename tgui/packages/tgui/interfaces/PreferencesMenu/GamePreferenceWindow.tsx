import { Stack, Button } from '../../components';
import { Window } from '../../layouts';
import { KeybindingsPage } from './KeybindingsPage';
import { GamePreferencesPage } from './GamePreferencesPage';
import { PageButton } from './PageButton';
import { useBackend, useLocalState } from '../../backend';
import { GamePreferencesSelectedPage, PreferencesMenuData } from './data';
import { exhaustiveCheck } from 'common/exhaustive';
import { SaveStatus } from './SaveStatus';

export const GamePreferenceWindow = (
  props: {
    startingPage?: GamePreferencesSelectedPage;
  },
  context
) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const [currentPage, setCurrentPage] = useLocalState(
    context,
    'currentPage_game',
    props.startingPage ?? GamePreferencesSelectedPage.Settings
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
            style={{ 'border-radius': '20px' }}
            onClick={() => act('open_character_preferences')}
          />
          <SaveStatus />
        </>
      }>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <PageButton currentPage={currentPage} page={GamePreferencesSelectedPage.Settings} setPage={setCurrentPage}>
                  Settings
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton currentPage={currentPage} page={GamePreferencesSelectedPage.Keybindings} setPage={setCurrentPage}>
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
