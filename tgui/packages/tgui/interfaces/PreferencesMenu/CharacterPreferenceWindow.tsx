import { exhaustiveCheck } from 'common/exhaustive';
import { BooleanLike } from 'common/react';

import { useBackend, useLocalState } from '../../backend';
import { Button, Divider, Flex, Stack } from '../../components';
import { Window } from '../../layouts';
import { AntagsPage } from './AntagsPage';
import { PreferencesMenuData } from './data';
import { JobsPage } from './JobsPage';
import { LoadoutPage } from './LoadoutPage';
import { MainPage } from './MainPage';
import { PageButton } from './PageButton';
import { QuirksPage } from './QuirksPage';
import { SaveStatus } from './SaveStatus';
import { SpeciesPage } from './SpeciesPage';

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
  Loadout,
}

const CharacterProfiles = (props: {
  activeSlot: number;
  maxSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
  content_unlocked: BooleanLike;
}) => {
  const { profiles = [] } = props;

  return (
    <Flex justify="center" wrap>
      {profiles?.map((profile, slot) => (
        <Flex.Item key={slot} mr={1} mt={1}>
          <Button
            selected={slot === props.activeSlot}
            disabled={slot >= props.maxSlot}
            onClick={() => {
              props.onClick(slot);
            }}
            tooltip={
              !props.content_unlocked && slot >= props.maxSlot
                ? 'Buy a BYOND Membership to unlock more slots!'
                : null
            }
            fluid
          >
            {profile ?? 'New Character'}
          </Button>
        </Flex.Item>
      ))}
    </Flex>
  );
};

export const CharacterPreferenceWindow = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const [currentPage, setCurrentPage] = useLocalState(
    'currentPage_character',
    Page.Main,
  );

  let pageContents;

  switch (currentPage) {
    case Page.Antags:
      pageContents = <AntagsPage />;
      break;
    case Page.Jobs:
      pageContents = <JobsPage />;
      break;
    case Page.Main:
      pageContents = (
        <MainPage openSpecies={() => setCurrentPage(Page.Species)} />
      );

      break;
    case Page.Species:
      pageContents = (
        <SpeciesPage closeSpecies={() => setCurrentPage(Page.Main)} />
      );

      break;
    case Page.Quirks:
      pageContents = <QuirksPage />;
      break;
    case Page.Loadout:
      pageContents = <LoadoutPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window
      title="Character Preferences"
      width={1200}
      height={770}
      theme="generic-yellow"
      buttons={
        <>
          <Button
            icon="cog"
            tooltip="Open Game Preferences"
            tooltipPosition="bottom"
            style={{ borderRadius: '20px' }}
            onClick={() => act('open_game_preferences')}
          />
          <SaveStatus />
        </>
      }
    >
      <Window.Content scrollable>
        <Flex direction="column" width="100%">
          <Flex.Item mt={-1}>
            <CharacterProfiles
              activeSlot={data.active_slot - 1}
              maxSlot={data.max_slot}
              content_unlocked={data.content_unlocked}
              onClick={(slot) => {
                act('change_slot', {
                  slot: slot + 1,
                });
              }}
              profiles={data.character_profiles}
            />
          </Flex.Item>

          <Flex.Item>
            <Divider />
          </Flex.Item>

          <Flex.Item>
            <Stack fill>
              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Main}
                  setPage={setCurrentPage}
                  otherActivePages={[Page.Species]}
                >
                  Character
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Jobs}
                  setPage={setCurrentPage}
                >
                  {/*
                    Fun fact: This isn't "Jobs" so that it intentionally
                    catches your eyes, because it's really important!
                  */}
                  Occupations
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Loadout}
                  setPage={setCurrentPage}
                >
                  Loadout
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Antags}
                  setPage={setCurrentPage}
                >
                  Antagonists
                </PageButton>
              </Stack.Item>

              <Stack.Item grow>
                <PageButton
                  currentPage={currentPage}
                  page={Page.Quirks}
                  setPage={setCurrentPage}
                >
                  Quirks
                </PageButton>
              </Stack.Item>
            </Stack>
          </Flex.Item>

          <Flex.Item>
            <Divider />
          </Flex.Item>

          <Flex.Item>{pageContents}</Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
