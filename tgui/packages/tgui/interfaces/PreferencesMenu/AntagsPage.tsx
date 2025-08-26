import { round } from 'common/math';
import { classes } from 'common/react';
import { createSearch } from 'common/string';

import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Icon,
  Input,
  Section,
  Stack,
  Tooltip,
} from '../../components';
import { PreferencesMenuData } from './data';
import { AntagonistData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const AntagSelection = (props: {
  antagonists: AntagonistData[];
  name: string;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const className = 'PreferencesMenu__Antags__antagSelection';

  const enableAntagsGlobal = (antags: string[]) => {
    act('set_antags', {
      antags,
      toggled: true,
      character: false,
    });
  };

  const disableAntagsGlobal = (antags: string[]) => {
    act('set_antags', {
      antags,
      toggled: false,
      character: false,
    });
  };

  const enableAntagsCharacter = (antags: string[]) => {
    act('set_antags', {
      antags,
      toggled: true,
      character: true,
    });
  };

  const disableAntagsCharacter = (antags: string[]) => {
    act('set_antags', {
      antags,
      toggled: false,
      character: true,
    });
  };

  const isSelectedGlobal = (antag: string) => {
    return data.enabled_global?.includes(antag);
  };

  const isSelectedCharacter = (antag: string) => {
    return data.enabled_character?.includes(antag);
  };

  const antagonistKeys = props.antagonists.map((antagonist) => antagonist.path);

  return (
    <Section
      title={props.name}
      buttons={
        <>
          <Button
            tooltip="Global Enable Category"
            tooltipPosition="bottom"
            icon="globe"
            color="good"
            onClick={() => enableAntagsGlobal(antagonistKeys)}
          />
          <Button
            tooltip="Global Disable Category"
            tooltipPosition="bottom"
            icon="ban"
            color="bad"
            onClick={() => disableAntagsGlobal(antagonistKeys)}
            mr={1}
          />

          <Button
            tooltip="Per-Character Enable Category"
            tooltipPosition="bottom"
            icon="user"
            color="good"
            onClick={() => enableAntagsCharacter(antagonistKeys)}
          />
          <Button
            tooltip="Per-Character Disable Category"
            tooltipPosition="bottom"
            icon="user-slash"
            color="bad"
            onClick={() => disableAntagsCharacter(antagonistKeys)}
          />
        </>
      }
    >
      <Flex className={className} align="flex-end" wrap>
        {props.antagonists.map((antagonist) => {
          const isBanned =
            antagonist.ban_key &&
            data.antag_bans &&
            data.antag_bans.indexOf(antagonist.ban_key) !== -1;
          const hoursLeft =
            (antagonist.path &&
              data.antag_living_playtime_hours_left &&
              data.antag_living_playtime_hours_left[antagonist.path]) ||
            0;

          let displayHours = round(hoursLeft, 2);
          let full_description = `${
            isBanned
              ? `You are banned from ${antagonist.name}.${antagonist.description || hoursLeft > 0 ? '\n' : ''}`
              : ''
          }${
            hoursLeft > 0
              ? `You require ${displayHours} more hour${
                  displayHours !== 1 ? 's' : ''
                } of living playtime in order to play this role.${antagonist.description ? '\n' : ''}`
              : ''
          }${antagonist.description}`;
          if (!full_description.length) {
            full_description = 'No description found.';
          }

          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                isSelectedGlobal(antagonist.path) &&
                  antagonist.per_character &&
                  !isSelectedCharacter(antagonist.path) &&
                  `${className}__antagonist--grey`,
                `${className}__antagonist--${isSelectedGlobal(antagonist.path) ? 'on' : 'off'}${
                  isBanned || hoursLeft > 0 ? '--banned' : ''
                }`,
              ])}
              key={antagonist.path}
            >
              <Stack align="center" vertical>
                <Stack.Item
                  style={{
                    fontWeight: 'bold',
                    marginTop: 'auto',
                    maxWidth: '100px',
                    textAlign: 'center',
                  }}
                >
                  {antagonist.name}
                </Stack.Item>

                <Stack.Item align="center">
                  {antagonist.per_character ? (
                    <Box
                      className={classes([
                        `${className}__antagonist__per_character`,
                        `${className}__antagonist__per_character--${isSelectedCharacter(antagonist.path) ? 'on' : 'off'}`,
                      ])}
                    >
                      <Box
                        className="antagonist-icon-parent-per-character"
                        onClick={() => {
                          if (isSelectedCharacter(antagonist.path)) {
                            disableAntagsCharacter([antagonist.path]);
                          } else {
                            enableAntagsCharacter([antagonist.path]);
                          }
                        }}
                      >
                        <Tooltip
                          content={
                            <div>
                              Per-Character Toggle
                              <Divider />
                              This can only be disabled per-character. You
                              cannot force a globally disabled antagonist
                              &apos;on&apos; for a specific character.
                            </div>
                          }
                        >
                          <Box className="antagonist-icon">C</Box>
                        </Tooltip>
                      </Box>
                    </Box>
                  ) : null}
                  <Tooltip
                    content={(full_description || 'No description found.')
                      .split('\n')
                      .map((text, index, values) => (
                        <div key={antagonist.path + '_desc_' + index}>
                          {text}
                          {index !== values.length - 1 && <Divider />}
                        </div>
                      ))}
                    position="bottom"
                  >
                    <Box
                      className="antagonist-icon-parent"
                      onClick={() => {
                        if (isSelectedGlobal(antagonist.path)) {
                          disableAntagsGlobal([antagonist.path]);
                        } else {
                          enableAntagsGlobal([antagonist.path]);
                        }
                      }}
                    >
                      <Box
                        className={classes([
                          'antagonists96x96',
                          antagonist.icon_path,
                          'antagonist-icon',
                        ])}
                      />

                      {isBanned && (
                        <>
                          <Box className="antagonist-overlay-text">
                            <span className="antagonist-overlay-text-hours">
                              Banned
                            </span>
                          </Box>
                          <Box className="antagonist-banned-slash" />
                        </>
                      )}

                      {hoursLeft > 0 && (
                        <Box className="antagonist-overlay-text">
                          <span className="antagonist-overlay-text-hours">
                            {Math.ceil(hoursLeft)}
                          </span>
                          <br />
                          hours left
                        </Box>
                      )}
                    </Box>
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          );
        })}
      </Flex>
    </Section>
  );
};

export const AntagsPage = (_) => {
  let [searchText, setSearchText] = useLocalState('antag_search', '');
  let search = createSearch(searchText, (antagonist: AntagonistData) => {
    return antagonist.name;
  });
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <Box>Loading loadout data...</Box>;
        }
        const { antagonists = [], categories = [] } = serverData.antags;
        return (
          <Box className="PreferencesMenu__Antags">
            <SearchBar
              searchText={searchText}
              setSearchText={setSearchText}
              allAntags={antagonists.map((antag) => antag.path)}
            />
            {searchText !== '' ? (
              <AntagSelection
                name="Search Result"
                antagonists={antagonists.filter(search)}
              />
            ) : (
              categories.map((category) => (
                <AntagSelection
                  name={category}
                  key={category}
                  antagonists={
                    antagonists.filter((a) => a.category === category)!
                  }
                />
              ))
            )}
          </Box>
        );
      }}
    />
  );
};

const SearchBar = ({ searchText, setSearchText, allAntags }) => {
  const { act } = useBackend<PreferencesMenuData>();
  const enableAntags = (character: boolean) => {
    act('set_antags', {
      antags: allAntags,
      toggled: true,
      character,
    });
  };

  const disableAntags = (character: boolean) => {
    act('set_antags', {
      antags: allAntags,
      toggled: false,
      character,
    });
  };
  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Icon mr={1} name="search" />
          <Input
            width="500px"
            placeholder="Search roles"
            value={searchText}
            onInput={(_, value) => setSearchText(value)}
          />
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item>
          <Button
            tooltip="Global Enable Everything"
            tooltipPosition="bottom"
            icon="globe"
            color="good"
            onClick={() => enableAntags(false)}
          >
            Enable
          </Button>
          <Button
            tooltip="Global Disable Everything"
            tooltipPosition="bottom"
            icon="ban"
            color="bad"
            onClick={() => disableAntags(false)}
          >
            Disable
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            tooltip="Per-Character Enable Everything"
            tooltipPosition="bottom"
            icon="user"
            color="good"
            onClick={() => enableAntags(true)}
          >
            Enable
          </Button>
          <Button
            tooltip="Per-Character Disable Everything"
            tooltipPosition="bottom"
            icon="user-slash"
            color="bad"
            onClick={() => disableAntags(true)}
          >
            Disable
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
