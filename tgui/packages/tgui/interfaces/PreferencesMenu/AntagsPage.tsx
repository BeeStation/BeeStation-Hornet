import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Flex, Section, Stack, Tooltip } from '../../components';
import { PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';
import { AntagonistData } from './data';

const AntagSelection = (
  props: {
    antagonists: AntagonistData[];
    name: string;
  },
  context
) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const className = 'PreferencesMenu__Antags__antagSelection';

  const [predictedState, setPredictedState] = useLocalState(
    context,
    'AntagSelection_predictedState',
    new Set(data.selected_antags)
  );

  const enableAntags = (antags: string[]) => {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.add(antag);
    }

    setPredictedState(newState);

    act('set_antags', {
      antags,
      toggled: true,
    });
  };

  const disableAntags = (antags: string[]) => {
    const newState = new Set(predictedState);

    for (const antag of antags) {
      newState.delete(antag);
    }

    setPredictedState(newState);

    act('set_antags', {
      antags,
      toggled: false,
    });
  };

  const antagonistKeys = props.antagonists.map((antagonist) => antagonist.path);

  return (
    <Section
      title={props.name}
      buttons={
        <>
          <Button color="good" onClick={() => enableAntags(antagonistKeys)}>
            Enable All
          </Button>

          <Button color="bad" onClick={() => disableAntags(antagonistKeys)}>
            Disable All
          </Button>
        </>
      }>
      <Flex className={className} align="flex-end" wrap>
        {props.antagonists.map((antagonist) => {
          const isBanned = data.antag_bans && data.antag_bans.indexOf(antagonist.path) !== -1;

          const daysLeft = (data.antag_days_left && data.antag_days_left[antagonist.path]) || 0;

          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--${
                  isBanned || daysLeft > 0 ? 'banned' : predictedState.has(antagonist.path) ? 'on' : 'off'
                }`,
              ])}
              key={antagonist.path}>
              <Stack align="center" vertical>
                <Stack.Item
                  style={{
                    'font-weight': 'bold',
                    'margin-top': 'auto',
                    'max-width': '100px',
                    'text-align': 'center',
                  }}>
                  {antagonist.name}
                </Stack.Item>

                <Stack.Item align="center">
                  <Tooltip
                    content={isBanned ? `You are banned from ${antagonist.name}.` : antagonist.description}
                    position="bottom">
                    <Box
                      className={'antagonist-icon-parent'}
                      onClick={() => {
                        if (isBanned) {
                          return;
                        }

                        if (predictedState.has(antagonist.path)) {
                          disableAntags([antagonist.path]);
                        } else {
                          enableAntags([antagonist.path]);
                        }
                      }}>
                      <Box className={classes(['antagonists96x96', antagonist.icon_path, 'antagonist-icon'])} />

                      {isBanned && <Box className="antagonist-banned-slash" />}

                      {daysLeft > 0 && (
                        <Box className="antagonist-days-left">
                          <b>{daysLeft}</b> days left
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

export const AntagsPage = () => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <Box>Loading loadout data...</Box>;
        }
        const { antagonists = [], categories = [] } = serverData.antags;

        return (
          <Box className="PreferencesMenu__Antags">
            {categories.map((category) => (
              <AntagSelection
                name={category}
                key={category}
                antagonists={antagonists.filter((a) => a.category === category)!}
              />
            ))}
          </Box>
        );
      }}
    />
  );
};
