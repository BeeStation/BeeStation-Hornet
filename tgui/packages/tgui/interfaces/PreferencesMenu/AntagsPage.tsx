import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Flex, Section, Stack, Tooltip, Divider, Input, Icon } from '../../components';
import { PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';
import { AntagonistData } from './data';
import { createSearch } from 'common/string';

const AntagSelection = (
  props: {
    antagonists: AntagonistData[];
    name: string;
  },
  context
) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const className = 'PreferencesMenu__Antags__antagSelection';

  const enableAntags = (antags: string[]) => {
    act('set_antags', {
      antags,
      toggled: true,
    });
  };

  const disableAntags = (antags: string[]) => {
    act('set_antags', {
      antags,
      toggled: false,
    });
  };

  const isSelected = (antag: string) => {
    return data.enabled_antags?.includes(antag);
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
          const isBanned = antagonist.ban_key && data.antag_bans && data.antag_bans.indexOf(antagonist.ban_key) !== -1;

          return (
            <Flex.Item
              className={classes([
                `${className}__antagonist`,
                `${className}__antagonist--${isBanned ? 'banned' : isSelected(antagonist.path) ? 'on' : 'off'}`,
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
                    content={
                      isBanned
                        ? `You are banned from ${antagonist.name}.`
                        : (antagonist.description || 'No description found.').split('\n').map((text, index, values) => (
                          <div key={antagonist.path + '_desc_' + index}>
                            {text}
                            {index !== values.length - 1 && <Divider />}
                          </div>
                        ))
                    }
                    position="bottom">
                    <Box
                      className={'antagonist-icon-parent'}
                      onClick={() => {
                        if (isBanned) {
                          return;
                        }

                        if (isSelected(antagonist.path)) {
                          disableAntags([antagonist.path]);
                        } else {
                          enableAntags([antagonist.path]);
                        }
                      }}>
                      <Box className={classes(['antagonists96x96', antagonist.icon_path, 'antagonist-icon'])} />

                      {isBanned && <Box className="antagonist-banned-slash" />}
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

export const AntagsPage = (_, context) => {
  let [searchText, setSearchText] = useLocalState(context, 'antag_search', '');
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
            <SearchBar searchText={searchText} setSearchText={setSearchText} />
            {searchText !== '' ? (
              <AntagSelection name="Search Result" antagonists={antagonists.filter(search)} />
            ) : (
              categories.map((category) => (
                <AntagSelection
                  name={category}
                  key={category}
                  antagonists={antagonists.filter((a) => a.category === category)!}
                />
              ))
            )}
          </Box>
        );
      }}
    />
  );
};

const SearchBar = ({ searchText, setSearchText }) => {
  return (
    <Section fill>
      <Icon mr={1} name="search" />
      <Input width="350px" placeholder="Search roles" value={searchText} onInput={(_, value) => setSearchText(value)} />
    </Section>
  );
};
