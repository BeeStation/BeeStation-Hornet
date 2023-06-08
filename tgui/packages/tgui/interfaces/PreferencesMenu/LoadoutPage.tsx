import { Box, Tabs, Button } from '../../components';
import { PreferencesMenuData } from './data';
import { useBackend } from '../../backend';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

export const LoadoutPage = (props, context) => {
  const { act } = useBackend<PreferencesMenuData>(context);
  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return <Box>Loading loadout data...</Box>;
        }
        const { categories = [], purchased_gear = [], equipped_gear = [] } = data.loadout;

        return (
          <Tabs>
            {categories.map((category) => (
              <Tabs.Tab key={category.name}>{category.name}</Tabs.Tab>
            ))}
          </Tabs>
        );
      }}
    />
  );
};
