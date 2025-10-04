import { binaryInsertWith, sortBy } from 'common/collections';
import { createSearch } from 'common/string';
import { ReactNode } from 'react';
import { ButtonCheckbox } from 'tgui/components/Button';

import { useBackend, useLocalState } from '../../backend';
import { Box, Flex, Icon, Input, Section, Tooltip } from '../../components';
import { PreferencesMenuData } from './data';
import features from './preferences/features';
import { FeatureValueInput } from './preferences/features/base';
import { TabbedMenu } from './TabbedMenu';

const CATEGORY_SCALES = {};

const CATEGORIES_ORDER = [
  'ADMIN',
  'CHAT',
  'GRAPHICS',
  'SOUND',
  'GHOST',
  'UI',
  'BYOND MEMBER',
  'GAMEPLAY',
];

// Specific scales used to make the layout better
const SUBCATEGORY_SCALES = {
  ADMIN: {
    Misc: '100%',
  },
  CHAT: {
    IC: '100%',
    Runechat: '100%',
  },
  GHOST: {
    Appearance: '100%',
    Behavior: '100%',
    Chat: '100%',
  },
  GRAPHICS: {
    Quality: '100%',
    Scaling: '100%',
  },
  UI: {
    HUD: '100%',
  },
};

type PreferenceChild = {
  name: string;
  children: ReactNode;
};

const binaryInsertPreference = (
  collection: PreferenceChild[],
  value: PreferenceChild,
) => binaryInsertWith(collection, value, (child) => child.name);

const sortByName = (array: [string, PreferenceChild[]][]) =>
  sortBy(array, ([name]) => name);

export const GamePreferencesPage = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  let [searchText, setSearchText] = useLocalState('game_prefs_searchText', '');
  const [advancedSettings, setAdvancedSettings] = useLocalState(
    'game_prefs_advanced_settings',
    false,
  );

  const gamePreferences: Record<string, Record<string, PreferenceChild[]>> = {};

  for (const [featureId, value] of Object.entries(
    data.character_preferences.game_preferences,
  )) {
    const feature = features[featureId];

    if (!advancedSettings && !feature?.important) {
      continue;
    }

    let nameInner: ReactNode = feature?.name || featureId;

    if (feature?.description) {
      nameInner = (
        <Box
          as="span"
          style={{
            borderBottom: '2px dotted rgba(180, 180, 180, 0.8)',
          }}
        >
          {nameInner}
        </Box>
      );
    }

    let name: ReactNode = (
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
      <Flex
        className="candystripe"
        key={featureId}
        pt={1}
        pb={1}
        style={{ flexFlow: 'row nowrap', alignItems: 'center' }}
      >
        <Flex.Item grow={1} basis={0} textColor="#e8e8e8">
          <Flex direction="row">
            {!feature.important && (
              <Flex.Item ml={1}>
                <Icon name="gears" />
              </Flex.Item>
            )}
            <Flex.Item grow={1}>{name}</Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          {(feature && (
            <FeatureValueInput
              feature={feature}
              featureId={featureId}
              value={value}
              act={act}
            />
          )) || (
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

    gamePreferences[category][subcategory] = binaryInsertPreference(
      curCategory[subcategory] || [],
      entry,
    );
  }

  const sortByName = (array: [string, PreferenceChild[]][]) =>
    sortBy(array, ([name]) => name);

  const sortByManual = (entries) => {
    let result: any[] = [];
    for (let category of CATEGORIES_ORDER) {
      for (let [name, val] of entries) {
        if (name === category) {
          result.push([name, val]);
        }
      }
    }
    return result;
  };

  const gamePreferenceEntries: [string, ReactNode][] = sortByManual(
    Object.entries(gamePreferences),
  ).map(([category, subcategory]) => {
    let subcategories = sortByName(Object.entries(subcategory));
    return [
      category,
      <Flex style={{ flexFlow: 'row wrap' }} key={category}>
        {subcategories.length > 1
          ? subcategories.map(([subcategory, preferences], index) => (
              <Flex.Item
                grow
                basis={0}
                px={2}
                py={1}
                minWidth={
                  (SUBCATEGORY_SCALES[category]
                    ? SUBCATEGORY_SCALES[category][subcategory]
                    : '50%') || '50%'
                }
                key={category + '_' + subcategory + '_' + index}
              >
                <Section
                  fill
                  fitted
                  pb={1}
                  backgroundColor="rgba(40, 40, 45, 0.25)"
                  style={{ boxShadow: '1px 1px 5px rgba(0, 0, 0, 0.4)' }}
                  title={<Box fontSize={1.1}>{subcategory}</Box>}
                >
                  <Box backgroundColor="rgba(40, 40, 45, 0.75)">
                    {preferences.map((preference) => preference.children)}
                  </Box>
                </Section>
              </Flex.Item>
            ))
          : subcategories.map(([subcategory, preferences], index) => (
              <Box
                key={category + '_' + subcategory + '_' + index}
                backgroundColor="rgba(40, 40, 45, 0.75)"
                width="100%"
              >
                {preferences.map((preference) => preference.children)}
              </Box>
            ))}
      </Flex>,
    ];
  });

  const sortByNameTyped = (
    array: [string, Record<string, PreferenceChild[]>][],
  ) => sortBy(array, ([name]) => name);

  const search = createSearch(
    searchText,
    (preference: PreferenceChild) => preference.name,
  );
  const searchResult: null | [string, ReactNode][] =
    searchText?.length > 0
      ? [
          [
            'Search Result',
            sortByNameTyped(Object.entries(gamePreferences))
              .flatMap(([category, categoryObj]) =>
                Object.entries(categoryObj).map<[string, PreferenceChild[]]>(
                  ([k, v]) => [category + (k ? ' > ' + k : ''), v],
                ),
              )
              .filter(([_, preferences]) => preferences.some(search))
              .map(([subcategory, preferences], index) => (
                <Box
                  key={'search_result_' + subcategory + '_' + index}
                  px={2}
                  py={1}
                >
                  {subcategory?.length ? (
                    <Section
                      fill
                      fitted
                      pb={1}
                      mb={2}
                      backgroundColor="rgba(40, 40, 45, 0.25)"
                      style={{ boxShadow: '1px 1px 5px rgba(0, 0, 0, 0.4)' }}
                      title={<Box fontSize={1.1}>{subcategory}</Box>}
                    >
                      <Box backgroundColor="rgba(40, 40, 45, 0.75)">
                        {preferences
                          .filter(search)
                          .map((preference) => preference.children)}
                      </Box>
                    </Section>
                  ) : (
                    <Box
                      key={'search_result_' + subcategory + '_' + index}
                      backgroundColor="rgba(40, 40, 45, 0.75)"
                      width="100%"
                    >
                      {preferences
                        .filter(search)
                        .map((preference) => preference.children)}
                    </Box>
                  )}
                </Box>
              )),
          ],
        ]
      : null;

  const result: [string, ReactNode][] = searchResult || gamePreferenceEntries;

  return (
    <TabbedMenu categoryEntries={result} categoryScales={CATEGORY_SCALES}>
      <Flex
        fontSize={1.2}
        pl="15px"
        pr="25px"
        mb="-5px"
        mt="5px"
        style={{ alignItems: 'center' }}
      >
        <Flex.Item mr={1}>
          <Icon name="search" />
        </Flex.Item>
        <Flex.Item grow>
          <Input
            autoFocus
            fluid
            placeholder="Search options"
            value={searchText}
            onInput={(_, value) => setSearchText(value)}
          />
        </Flex.Item>
        <Flex.Item>
          <ButtonCheckbox
            checked={advancedSettings}
            onClick={() => {
              setAdvancedSettings(!advancedSettings);
            }}
          >
            Show Advanced Settings
          </ButtonCheckbox>
        </Flex.Item>
      </Flex>
    </TabbedMenu>
  );
};
