import { useState } from 'react';
import { logger } from 'tgui/logging';

import { useBackend } from '../../backend';
import { Box, Icon, Stack, Tooltip } from '../../components';
import { PreferencesMenuData, Quirk } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

function getValueClass(value: number) {
  if (value > 0) {
    return 'positive';
  } else if (value < 0) {
    return 'negative';
  } else {
    return 'neutral';
  }
}

type QuirkEntry = [string, Quirk & { failTooltip?: string }];

type QuirkListProps = {
  quirks: QuirkEntry[];
};

type QuirkProps = {
  onClick: (quirkName: string, quirk: Quirk) => void;
  selected?: boolean;
};

function QuirkList(props: QuirkProps & QuirkListProps) {
  const { quirks = [], selected, onClick } = props;

  return (
    // Stack is not used here for a variety of IE flex bugs
    <Box className="PreferencesMenu__Quirks__QuirkList">
      {quirks.map(([quirkKey, quirk]) => (
        <QuirkDisplay
          key={quirkKey}
          onClick={onClick}
          quirk={quirk}
          quirkKey={quirkKey}
          selected={selected}
        />
      ))}
    </Box>
  );
}

type QuirkDisplayProps = {
  quirk: Quirk & { failTooltip?: string };
  // bugged
  // eslint-disable-next-line react/no-unused-prop-types
  quirkKey: string;
} & QuirkProps;

function QuirkDisplay(props: QuirkDisplayProps) {
  const { quirk, quirkKey, onClick, selected } = props;
  const { icon, value, name, description, failTooltip } = quirk;

  const className = 'PreferencesMenu__Quirks__QuirkList__quirk';

  if (!icon) {
    logger.info(name);
  }

  const child = (
    <Box
      className={className}
      role="button"
      tabIndex="1"
      onClick={(event) => {
        event.stopPropagation();
        if (selected) {
        }

        onClick(quirkKey, quirk);
      }}
    >
      <Stack fill>
        <Stack.Item
          align="center"
          style={{
            minWidth: '15%',
            maxWidth: '15%',
            textAlign: 'center',
          }}
        >
          {icon && <Icon color="#333" fontSize={3} name={icon} />}
        </Stack.Item>

        <Stack.Item
          align="stretch"
          ml={0}
          style={{
            borderRight: '1px solid black',
          }}
        />

        <Stack.Item
          grow
          ml={0}
          style={{
            // Fixes an IE bug for text overflowing in Flex boxes
            minWidth: '0%',
          }}
        >
          <Stack vertical fill>
            <Stack.Item
              className={`${className}--${getValueClass(value)}`}
              style={{
                borderBottom: '1px solid black',
                padding: '2px',
              }}
            >
              <Stack
                fill
                style={{
                  fontSize: '1.2em',
                }}
              >
                <Stack.Item grow basis="content">
                  <b>{name}</b>
                </Stack.Item>

                <Stack.Item>
                  <b>{value}</b>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item
              grow
              basis="content"
              mt={0}
              style={{
                padding: '3px',
              }}
            >
              {description}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );

  if (failTooltip) {
    return <Tooltip content={failTooltip}>{child}</Tooltip>;
  } else {
    return child;
  }
}

function StatDisplay(props) {
  const { children } = props;

  return (
    <Box
      backgroundColor="#eee"
      bold
      color="black"
      fontSize="1.2em"
      px={3}
      py={0.5}
    >
      {children}
    </Box>
  );
}

export function QuirksPage(props) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [selectedQuirks, setSelectedQuirks] = useState(data.selected_quirks);

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return <Box>Loading quirks...</Box>;
        }

        const {
          max_positive_quirks: maxPositiveQuirks,
          quirk_blacklist: quirkBlacklist,
          quirk_info: quirkInfo,
        } = data.quirks;

        const quirks = Object.entries(quirkInfo);
        quirks.sort(([_, quirkA], [__, quirkB]) => {
          if (quirkA.value === quirkB.value) {
            return quirkA.name > quirkB.name ? 1 : -1;
          } else {
            return quirkB.value - quirkA.value;
          }
        });

        let positiveQuirks = 0;

        for (const selectedQuirkName of selectedQuirks) {
          const selectedQuirk = quirkInfo[selectedQuirkName];
          if (!selectedQuirk) {
            continue;
          }

          if (selectedQuirk.value > 0) {
            positiveQuirks += 1;
          }
        }

        const getReasonToNotAdd = (quirkName: string) => {
          const quirk = quirkInfo[quirkName];

          if (quirk.value > 0) {
            if (positiveQuirks >= maxPositiveQuirks) {
              return "You can't have any more positive quirks!";
            }
          }

          const selectedQuirkNames = selectedQuirks.map((quirkKey) => {
            return quirkInfo[quirkKey].name;
          });

          for (const blacklist of quirkBlacklist) {
            if (blacklist.indexOf(quirk.name) === -1) {
              continue;
            }

            for (const incompatibleQuirk of blacklist) {
              if (
                incompatibleQuirk !== quirk.name &&
                selectedQuirkNames.indexOf(incompatibleQuirk) !== -1
              ) {
                return `This is incompatible with ${incompatibleQuirk}!`;
              }
            }
          }

          return undefined;
        };

        return (
          <Stack align="center" fill>
            <Stack.Item basis="50%">
              <Stack vertical fill align="center">
                <Stack.Item>
                  <Box as="b" fontSize="1.6em">
                    Available Quirks
                  </Box>
                </Stack.Item>

                <Stack.Item grow width="100%">
                  <QuirkList
                    onClick={(quirkName, quirk) => {
                      if (getReasonToNotAdd(quirkName) !== undefined) {
                        return;
                      }

                      setSelectedQuirks(selectedQuirks.concat(quirkName));

                      act('give_quirk', { quirk: quirk.name });
                    }}
                    quirks={quirks
                      .filter(([quirkName, _]) => {
                        return selectedQuirks.indexOf(quirkName) === -1;
                      })
                      .map(([quirkName, quirk]) => {
                        return [
                          quirkName,
                          {
                            ...quirk,
                            failTooltip: getReasonToNotAdd(quirkName),
                          },
                        ];
                      })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack vertical fill align="center">
              <Stack.Item>
                <Box fontSize="1.3em">Positive Quirks</Box>
              </Stack.Item>

              <Stack.Item>
                <StatDisplay>
                  {positiveQuirks} / {maxPositiveQuirks}
                </StatDisplay>
              </Stack.Item>

              <Stack.Item>
                <Icon name="exchange-alt" size={1.5} ml={2} mr={2} />
              </Stack.Item>
            </Stack>

            <Stack.Item basis="50%">
              <Stack vertical fill align="center">
                <Stack.Item>
                  <Box as="b" fontSize="1.6em">
                    Current Quirks
                  </Box>
                </Stack.Item>

                <Stack.Item grow width="100%">
                  <QuirkList
                    onClick={(quirkName, quirk) => {
                      setSelectedQuirks(
                        selectedQuirks.filter(
                          (otherQuirk) => quirkName !== otherQuirk,
                        ),
                      );

                      act('remove_quirk', { quirk: quirk.name });
                    }}
                    quirks={quirks
                      .filter(([quirkName, _]) => {
                        return selectedQuirks.indexOf(quirkName) !== -1;
                      })
                      .map(([quirkName, quirk]) => {
                        return [
                          quirkName,
                          {
                            ...quirk,
                            failTooltip: getReasonToNotAdd(quirkName),
                          },
                        ];
                      })}
                    selected
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
}
