import { exhaustiveCheck } from 'common/exhaustive';
import { BooleanLike } from 'common/react';
import { useEffect, useRef } from 'react';

import { useBackend, useLocalState } from '../../backend';
import {
  Button,
  Divider,
  Flex,
  Modal,
  Section,
  Stack,
  TrackOutsideClicks,
} from '../../components';
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

  const [expandedViewState, setExpandedViewState] = useLocalState(
    'slotViewState',
    false,
  );
  const [isCharacterSelectorOpen, setCharacterSelectorOpen] = useLocalState(
    'isCharacterSelectorOpen',
    false,
  );

  const scrollBarRef = useRef(null);

  useEffect(() => {
    const el: HTMLElement | undefined | null = scrollBarRef.current;

    if (!el) {
      return;
    }

    const onWheel = (e: WheelEvent) => {
      if (e.deltaY > 0) {
        // Dont block scroll event
        if (expandedViewState) {
          return;
        }
        setExpandedViewState(true);
      } else if (e.deltaY < 0) {
        if (el.scrollTop !== 0) {
          return;
        }
        setExpandedViewState(false);
      }
      e.stopPropagation();
      e.preventDefault();
    };

    el.addEventListener('wheel', onWheel, { passive: false });

    return () => {
      el.removeEventListener('wheel', onWheel);
    };
  }, [expandedViewState]);

  const slotsLeft = profiles.filter(
    (profile, slot) => !profile && slot < props.maxSlot,
  ).length;

  const popupWindow = !!isCharacterSelectorOpen && (
    <Modal
      style={{
        margin: '0 auto',
        width: '40%',
        position: 'fixed',
        overflowY: 'auto',
        maxHeight: 'calc(100vh - 100px)',
      }}
    >
      <TrackOutsideClicks
        onOutsideClick={() => setCharacterSelectorOpen(false)}
        removeOnOutsideClick
      >
        <Section
          buttons={
            <Button color="red" onClick={() => setCharacterSelectorOpen(false)}>
              Close
            </Button>
          }
          title="Available Character Slots"
        >
          <Flex width="100%" wrap>
            {profiles.map(
              (profile, slot) =>
                !!profile && (
                  <Flex.Item key={slot} mr={1} mt={1}>
                    <Button
                      selected={slot === props.activeSlot}
                      disabled={slot >= props.maxSlot}
                      onClick={() => {
                        props.onClick(slot);
                      }}
                      tooltip={
                        !props.content_unlocked && slot >= props.maxSlot
                          ? 'This character is inaccessible due to it being created with a donator slot that is no longer accessible. Buy a BYOND Membership or donate to the server to unlock this slot.'
                          : null
                      }
                      fluid
                    >
                      {profile ?? 'New Character'}
                    </Button>
                  </Flex.Item>
                ),
            )}
            {slotsLeft > 0 ? (
              <Flex.Item mr={1} mt={1}>
                <Button
                  onClick={() => {
                    props.onClick(
                      profiles.findIndex(
                        (profile, slot) => !profile && slot < props.maxSlot,
                      ),
                    );
                  }}
                  fluid
                >
                  New Character ({slotsLeft} left)
                </Button>
              </Flex.Item>
            ) : (
              !props.content_unlocked && (
                <Flex.Item mr={1} mt={1}>
                  <Button
                    disabled
                    tooltip={
                      'Buy a BYOND Membership or donate to the server to unlock more slots!'
                    }
                    fluid
                  >
                    New Character
                  </Button>
                </Flex.Item>
              )
            )}
          </Flex>
        </Section>
      </TrackOutsideClicks>
    </Modal>
  );

  if (expandedViewState) {
    return (
      <>
        {popupWindow}
        <div
          style={{
            height: '2.2em',
          }}
        />
        <div
          ref={scrollBarRef}
          style={{
            position: 'absolute',
            top: '0',
            left: '0',
            right: '0',
            zIndex: '1000',
            overflowY: 'scroll',
            maxHeight: '120px',
          }}
        >
          <Section
            style={{
              backgroundColor: '#1B1920DD',
            }}
            title="Available Characters"
            buttons={
              <Button
                onClick={() => {
                  setExpandedViewState(false);
                }}
              >
                Hide
              </Button>
            }
          >
            <Flex width="100%" wrap>
              {profiles.map(
                (profile, slot) =>
                  !!profile && (
                    <Flex.Item key={slot} mr={1} mt={1}>
                      <Button
                        selected={slot === props.activeSlot}
                        disabled={slot >= props.maxSlot}
                        onClick={() => {
                          props.onClick(slot);
                        }}
                        tooltip={
                          !props.content_unlocked && slot >= props.maxSlot
                            ? 'This character is inaccessible due to it being created with a donator slot that is no longer accessible. Buy a BYOND Membership or donate to the server to unlock this slot.'
                            : null
                        }
                        fluid
                      >
                        {profile ?? 'New Character'}
                      </Button>
                    </Flex.Item>
                  ),
              )}
              {slotsLeft > 0 ? (
                <Flex.Item mr={1} mt={1}>
                  <Button
                    onClick={() => {
                      props.onClick(
                        profiles.findIndex(
                          (profile, slot) => !profile && slot < props.maxSlot,
                        ),
                      );
                    }}
                    fluid
                  >
                    New Character ({slotsLeft} left)
                  </Button>
                </Flex.Item>
              ) : (
                !props.content_unlocked && (
                  <Flex.Item mr={1} mt={1}>
                    <Button
                      disabled
                      tooltip={
                        'Buy a BYOND Membership or donate to the server to unlock more slots!'
                      }
                      fluid
                    >
                      New Character
                    </Button>
                  </Flex.Item>
                )
              )}
            </Flex>
          </Section>
        </div>
      </>
    );
  }

  return (
    <>
      {popupWindow}
      <div ref={scrollBarRef}>
        <Flex width="100%" style={{ gap: '5px' }}>
          <Flex.Item grow shrink minWidth="0">
            <Flex overflow="hidden" width="100%">
              {profiles.map(
                (profile, slot) =>
                  !!profile && (
                    <Flex.Item key={slot} mr={1} mt={1}>
                      <Button
                        selected={slot === props.activeSlot}
                        disabled={slot >= props.maxSlot}
                        onClick={() => {
                          props.onClick(slot);
                        }}
                        tooltip={
                          !props.content_unlocked && slot >= props.maxSlot
                            ? 'This character is inaccessible due to it being created with a donator slot that is no longer accessible. Buy a BYOND Membership or donate to the server to unlock this slot.'
                            : null
                        }
                        fluid
                      >
                        {profile ?? 'New Character'}
                      </Button>
                    </Flex.Item>
                  ),
              )}
              {slotsLeft > 0 ? (
                <Flex.Item mr={1} mt={1}>
                  <Button
                    onClick={() => {
                      props.onClick(
                        profiles.findIndex(
                          (profile, slot) => !profile && slot < props.maxSlot,
                        ),
                      );
                    }}
                    fluid
                  >
                    New Character ({slotsLeft} left)
                  </Button>
                </Flex.Item>
              ) : (
                !props.content_unlocked && (
                  <Flex.Item mr={1} mt={1}>
                    <Button
                      disabled
                      tooltip={
                        'Buy a BYOND Membership or donate to the server to unlock more slots!'
                      }
                      fluid
                    >
                      New Character
                    </Button>
                  </Flex.Item>
                )
              )}
            </Flex>
          </Flex.Item>
          <Flex.Item shrink={0} mr={1} mt={1}>
            <Button
              onClick={(e: MouseEvent) => {
                setCharacterSelectorOpen(true);
                e.stopPropagation();
              }}
              fluid
            >
              ...
            </Button>
          </Flex.Item>
        </Flex>
      </div>
    </>
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
