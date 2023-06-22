import { binaryInsertWith, sortBy } from 'common/collections';
import { useLocalState } from '../../backend';
import type { Inferno, InfernoNode } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Flex, Tooltip, Input, Icon } from '../../components';
import { PreferencesMenuData } from './data';
import features from './preferences/features';
import { FeatureValueInput } from './preferences/features/base';
import { TabbedMenu } from './TabbedMenu';
import { createSearch } from 'common/string';

type PreferenceChild = {
  name: string;
  children: InfernoNode;
};

const binaryInsertPreference = binaryInsertWith<PreferenceChild>((child) => child.name);

export const GamePreferencesPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  let [searchText, setSearchText] = useLocalState(context, 'game_prefs_searchText', '');

  const gamePreferences: Record<string, Record<string, PreferenceChild[]>> = {};

  for (const [featureId, value] of Object.entries(data.character_preferences.game_preferences)) {
    const feature = features[featureId];

    let nameInner: InfernoNode = feature?.name || featureId;

    if (feature?.description) {
      nameInner = (
        <Box
          as="span"
          style={{
            'border-bottom': '2px dotted rgba(255, 255, 255, 0.8)',
          }}>
          {nameInner}
        </Box>
      );
    }

    let name: InfernoNode = (
      <Flex.Item grow={1} pr={2} basis={0} ml={2}>
        {nameInner}
      </Flex.Item>
    );

    if (feature?.description) {
      name = (
        <Tooltip content={feature.description} position="bottom-start">
          {name}
        </Tooltip>
      );
    }

    const child = (
      <Flex key={featureId} pb={2} style={{ 'flex-wrap': 'wrap', 'flex-direction': 'row' }}>
        <Flex.Item grow={1} basis={0}>
          {name}
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          {(feature && <FeatureValueInput feature={feature} featureId={featureId} value={value} act={act} />) || (
            <Box as="b" color="red">
              ...is not filled out properly!!!
            </Box>
          )}
        </Flex.Item>
      </Flex>
    );

    const entry = {
      name: feature?.name || featureId,
      children: child,
    };

    const category = feature?.category || 'ERROR';
    const subcategory = feature?.subcategory || '';
    const curCategory = gamePreferences[category] || [];
    gamePreferences[category] = curCategory;

    gamePreferences[category][subcategory] = binaryInsertPreference(curCategory[subcategory] || [], entry);
  }

  const sortByName = sortBy(([name]) => name);

  const gamePreferenceEntries: [string, InfernoNode][] = sortByName(Object.entries(gamePreferences)).map(
    ([category, subcategory]) => {
      let subcategories = sortByName(Object.entries(subcategory));
      return [
        category,
        <>
          {subcategories.map(([subcategory, preferences], index) => (
            <Box key={category + '_' + subcategory + '_' + index}>
              {subcategory?.length ? (
                <Flex pb={2} style={{ 'flex-wrap': 'wrap', 'flex-direction': 'row' }}>
                  <Flex.Item grow={1} basis={0}>
                    <Flex.Item grow={1} pr={2} basis={0} ml={2}>
                      <Box inline fontSize={1.5} textColor="label" style={{ 'font-weight': 'bold' }}>
                        {subcategory}
                      </Box>
                    </Flex.Item>
                  </Flex.Item>
                  <Flex.Item grow={1} basis={0} />
                </Flex>
              ) : null}
              {preferences.map((preference) => preference.children)}
            </Box>
          ))}
        </>,
      ];
    }
  );

  const sortByNameTyped = sortBy<[string, Record<string, PreferenceChild[]>]>(([name]) => name);

  const search = createSearch(searchText, (preference: PreferenceChild) => preference.name);
  const searchResult: null | [string, InfernoNode][] =
    searchText?.length > 0
      ? [
        [
          'Search Result',
          sortByNameTyped(Object.entries(gamePreferences))
            .flatMap(([category, categoryObj]) =>
              Object.entries(categoryObj).map<[string, PreferenceChild[]]>(([k, v]) => [category + (k ? ' > ' + k : ''), v])
            )
            .filter(([_, preferences]) => preferences.some(search))
            .map(([subcategory, preferences], index) => (
              <Box key={'search_result_' + subcategory + '_' + index}>
                {subcategory?.length ? (
                  <Flex pb={2} style={{ 'flex-wrap': 'wrap', 'flex-direction': 'row' }}>
                    <Flex.Item grow={1} basis={0}>
                      <Flex.Item grow={1} pr={2} basis={0} ml={2}>
                        <Box inline fontSize={1.5} textColor="label" style={{ 'font-weight': 'bold' }}>
                          {subcategory}
                        </Box>
                      </Flex.Item>
                    </Flex.Item>
                    <Flex.Item grow={1} basis={0} />
                  </Flex>
                ) : null}
                {preferences.filter(search).map((preference) => preference.children)}
              </Box>
            )),
        ],
      ]
      : null;

  const result: [string, InfernoNode][] = searchResult || gamePreferenceEntries;

  return (
    <TabbedMenu
      categoryEntries={result}
      contentProps={{
        fontSize: 1.5,
      }}>
      <Flex pl="15px" pr="25px" fontSize={1.5} mb="-5px" mt="5px" style={{ 'align-items': 'center' }}>
        <Flex.Item mr={1}>
          <Icon name="search" />
        </Flex.Item>
        <Flex.Item grow>
          <Input autoFocus fluid placeholder="Search options" value={searchText} onInput={(_, value) => setSearchText(value)} />
        </Flex.Item>
      </Flex>
    </TabbedMenu>
  );
};
