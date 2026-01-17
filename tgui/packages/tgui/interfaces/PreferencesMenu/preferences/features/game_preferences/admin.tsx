import { useLocalState } from 'tgui/backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  Popper,
  Section,
  Stack,
} from 'tgui/components';

import {
  CheckboxInput,
  Feature,
  FeatureChoicedServerData,
  FeatureColorInput,
  FeatureToggle,
  FeatureValueProps,
} from '../base';

export const asaycolor: Feature<string> = {
  name: 'Admin chat color',
  category: 'ADMIN',
  subcategory: 'Chat',
  description: 'The color of your messages in Adminsay.',
  component: FeatureColorInput,
  important: true,
};

export const brief_outfit: Feature<string> = {
  name: 'Brief outfit',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'The outfit to gain when spawning as the briefing officer.',
  important: true,
  component: (
    props: FeatureValueProps<
      string,
      string,
      FeatureChoicedServerData & { outfit_names: Record<string, string> }
    > & {
      disabled?: boolean;
      buttons?: boolean;
    },
  ) => {
    const serverData = props.serverData;
    if (!serverData) {
      return null;
    }

    let [isOpen, setOpen] = useLocalState('brief_outfit_pref_open', false);
    let [searchText, setSearchText] = useLocalState(
      'brief_outfit_pref_search_text',
      '',
    );
    const handleCloseInternal = () => {
      setOpen(false);
      setSearchText('');
    };

    const sortedChoices = serverData.choices.sort((aS, bS) => {
      const length = aS.length;
      for (let i = 0; i < length; i++) {
        const a = aS[i];
        const b = bS[i];
        if (a < b) {
          return -1;
        }
        if (a > b) {
          return 1;
        }
      }
      return 0;
    });

    return (
      <Popper
        placement="bottom-start"
        isOpen={isOpen}
        onClickOutside={handleCloseInternal}
        content={
          <Box
            className="theme-generic-yellow"
            style={{
              height: `250px`,
              width: `400px`,
            }}
          >
            <Box
              className="PopupWindow"
              style={{ padding: '5px' }}
              width="100%"
              height="100%"
            >
              <Section>
                <Box>
                  <Icon mr={1} name="search" />
                  <Input
                    autoFocus
                    width="350px"
                    placeholder="Search outfits"
                    value={searchText}
                    onInput={(_, value) => setSearchText(value)}
                  />
                </Box>
              </Section>
              <Section fill fitted scrollable maxHeight="190px">
                <Stack fill vertical>
                  {sortedChoices
                    .filter(
                      (choice) =>
                        searchText.length <= 1 ||
                        choice.includes(searchText) ||
                        serverData.outfit_names[choice]?.includes(searchText),
                    )
                    .map((choice) => {
                      const shortChoice = choice.replace('/datum/outfit/', '');
                      return (
                        <Stack.Item
                          key={shortChoice}
                          className="candystripe"
                          p={1}
                        >
                          <Flex fill>
                            <Flex.Item grow>
                              <Box>{`${serverData.outfit_names[choice] ? `${serverData.outfit_names[choice]}` : 'N/A'}`}</Box>
                              <Box textColor="label">{shortChoice}</Box>
                            </Flex.Item>
                            <Flex.Item>
                              <Button
                                selected={props.value === choice}
                                onClick={() => {
                                  props.handleSetValue(choice);
                                  handleCloseInternal();
                                }}
                              >
                                Select
                              </Button>
                            </Flex.Item>
                          </Flex>
                        </Stack.Item>
                      );
                    })}
                </Stack>
              </Section>
            </Box>
          </Box>
        }
      >
        <Flex pr={2}>
          <Flex.Item grow>
            {props.value ? (
              <>
                <Box>{serverData.outfit_names[props.value]}</Box>
                <Box inline textColor="label" mr={1}>
                  {props.value?.replace('/datum/outfit/', '')}
                </Box>{' '}
              </>
            ) : (
              <Box>No outfit selected</Box>
            )}
          </Flex.Item>
          <Flex.Item>
            <Button
              style={{ 'word-break': 'break-all' }}
              mt={1}
              onClick={(event) => {
                event.stopPropagation();
                if (isOpen) {
                  handleCloseInternal();
                } else {
                  setOpen(true);
                }
              }}
            >
              Change
            </Button>
          </Flex.Item>
        </Flex>
      </Popper>
    );
  },
};

export const combohud_lighting: FeatureToggle = {
  name: 'Combo HUD Lighting',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Whether you see combo HUD lighting as fullbright or not.',
  component: CheckboxInput,
  important: true,
};
