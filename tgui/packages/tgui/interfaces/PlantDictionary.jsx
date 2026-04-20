import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Flex, Input, Section } from '../components';
import { Window } from '../layouts';

export const PlantDictionary = (props) => {
  const { act, data } = useBackend();
  const {
    chapters,
    selected_chapter,
    selected_entry,
    selected_type_shortcut,
    last_command,
  } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  return (
    <Window width={750} height={750} theme="plant_menu">
      <Window.Content scrollable={1}>
        <Box m={'-3px'} height={'100%'}>
          <Flex direction={'column'} height={'100%'}>
            <Flex.Item>
              <Section textAlign={'center'}>
                Botanical Index [Version 1.12.8.0]
              </Section>
            </Flex.Item>
            <Flex.Item>
              <Flex direction={'row'}>
                {/* Side Bar */}
                <Flex.Item width={'30%'}>
                  <Flex direction={'column'}>
                    {/* Chapter Section */}
                    <Flex.Item>
                      <Section>
                        {Object.entries(chapters).map(
                          ([chapter_key, chapter]) => (
                            <ChapterEntry
                              key={chapter_key}
                              title={chapter_key}
                            />
                          ),
                        )}
                      </Section>
                    </Flex.Item>
                    {/* Filter Section */}
                    <Flex.Item>
                      <Section>Filters</Section>
                    </Flex.Item>
                    {/* Search Section */}
                    <Flex.Item>
                      <Section>
                        <Input
                          width={'100%'}
                          placeholder={'Search...'}
                          onInput={(e, value) => setSearchText(value)}
                        />
                      </Section>
                    </Flex.Item>
                    {/* Entry Section */}
                    <Flex.Item>
                      <Section>
                        <Box
                          className={'scrollbox'}
                          height={'427px'}
                          overflowY="scroll"
                        >
                          {selected_chapter === 'features' ? (
                            <Box className={'discrete'}>
                              {/* Fruits */}
                              {Object.entries(
                                chapters[selected_chapter][
                                  '/datum/plant_feature/fruit'
                                ],
                              ).map(([entry_key, entry]) =>
                                entry['stats']['name']
                                  .toLowerCase()
                                  .includes(searchText.toLowerCase()) ? (
                                  <Entry
                                    key={entry_key}
                                    title={entry['stats']['name']}
                                    selected_key={entry_key}
                                  />
                                ) : (
                                  ''
                                ),
                              )}
                              <Divider />
                              {/* Bodies */}
                              {Object.entries(
                                chapters[selected_chapter][
                                  '/datum/plant_feature/body'
                                ],
                              ).map(([entry_key, entry]) =>
                                entry['stats']['name']
                                  .toLowerCase()
                                  .includes(searchText.toLowerCase()) ? (
                                  <Entry
                                    key={entry_key}
                                    title={entry['stats']['name']}
                                    selected_key={entry_key}
                                  />
                                ) : (
                                  ''
                                ),
                              )}
                              <Divider />
                              {/* Roots */}
                              {Object.entries(
                                chapters[selected_chapter][
                                  '/datum/plant_feature/roots'
                                ],
                              ).map(([entry_key, entry]) =>
                                entry['stats']['name']
                                  .toLowerCase()
                                  .includes(searchText.toLowerCase()) ? (
                                  <Entry
                                    key={entry_key}
                                    title={entry['stats']['name']}
                                    selected_key={entry_key}
                                  />
                                ) : (
                                  ''
                                ),
                              )}
                            </Box>
                          ) : selected_chapter === 'traits' ? (
                            <Box>
                              {Object.entries(
                                chapters[selected_chapter]['other'],
                              ).map(([entry_key, entry]) =>
                                entry[0]['dictionary_name']
                                  .toLowerCase()
                                  .includes(searchText.toLowerCase()) ? (
                                  <Entry
                                    key={entry_key}
                                    title={entry[0]['dictionary_name']}
                                    selected_key={entry_key}
                                  />
                                ) : (
                                  ''
                                ),
                              )}
                              <Divider />
                              {Object.entries(
                                chapters[selected_chapter]['reagents'],
                              ).map(([entry_key, entry]) =>
                                entry[0]['dictionary_name']
                                  .toLowerCase()
                                  .includes(searchText.toLowerCase()) ? (
                                  <Entry
                                    key={entry_key}
                                    title={entry[0]['dictionary_name']}
                                    selected_key={entry_key}
                                  />
                                ) : (
                                  ''
                                ),
                              )}
                            </Box>
                          ) : selected_chapter === 'plants' ? (
                            Object.entries(chapters[selected_chapter]).map(
                              ([entry_key, entry]) =>
                                entry['name']
                                  ?.toLowerCase()
                                  .includes(searchText?.toLowerCase()) ? (
                                  <Entry
                                    key={entry_key}
                                    title={entry['name']}
                                    selected_key={entry_key}
                                  />
                                ) : (
                                  ''
                                ),
                            )
                          ) : (
                            ''
                          )}
                        </Box>
                      </Section>
                    </Flex.Item>
                  </Flex>
                </Flex.Item>
                {/* Inspection Panel */}
                <Flex.Item width={'70%'}>
                  <Section>
                    <Box
                      className={'scrollbox'}
                      height={'570px'}
                      overflowY="scroll"
                    >
                      <Box mb={'-10px'} />
                      {selected_chapter === 'features' ? (
                        selected_entry && selected_type_shortcut ? (
                          <InspectionPanelFeature
                            current_feature_data={
                              chapters[selected_chapter][
                                selected_type_shortcut
                              ][selected_entry]['data']
                            }
                            current_feature_traits={
                              chapters[selected_chapter][
                                selected_type_shortcut
                              ][selected_entry]['traits']
                            }
                            feature_key={selected_entry}
                          />
                        ) : (
                          ''
                        )
                      ) : selected_chapter === 'traits' ? (
                        selected_entry ? (
                          <Box>
                            <Box mb={'10px'} />
                            {chapters[selected_chapter]['other'][
                              selected_entry
                            ] ? (
                              <InspectionPanelTrait
                                data_set={
                                  chapters[selected_chapter]['other'][
                                    selected_entry
                                  ][0]
                                }
                              />
                            ) : (
                              <InspectionPanelTrait
                                data_set={
                                  chapters[selected_chapter]['reagents'][
                                    selected_entry
                                  ][0]
                                }
                              />
                            )}
                          </Box>
                        ) : (
                          ''
                        )
                      ) : selected_chapter === 'plants' &&
                        chapters[selected_chapter][selected_entry] ? (
                        <Box>
                          {Object.entries(
                            chapters[selected_chapter][selected_entry][
                              'features'
                            ],
                          ).map(([feature_key, feature]) => (
                            <InspectionPanelPlantFeature
                              key={feature_key}
                              current_feature_data={feature['data']}
                              current_feature_traits={feature['traits']}
                            />
                          ))}
                        </Box>
                      ) : (
                        ''
                      )}
                    </Box>
                  </Section>
                </Flex.Item>
              </Flex>
              <Flex.Item>
                <Box height={'20px'} />
              </Flex.Item>
            </Flex.Item>
            {/* World building fluff top banner */}
            <Flex.Item height={'100%'}>
              <Box />
            </Flex.Item>
            <Flex.Item>
              <Section textAlign={'start'} mb={'-5px'}>
                <Box>Yamato OS [Version 19.89.3.5]</Box>
                <Box>© 2554 Yamato. All Rights Reserved.</Box>
                <br />
                <Box>
                  {'C:\\Users\\admin>'}
                  {last_command}
                  <span className={'terminal'}>|</span>
                </Box>
              </Section>
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};

const InspectionPanelTrait = (props) => {
  const { act, data } = useBackend();
  const { links, chapters } = data;
  const { data_set } = props;
  return (
    <Flex direction="column">
      {/* traits */}
      <Flex.Item>
        <PlantTraitInstance
          title={data_set['trait_name']}
          body={data_set['trait_desc']}
          trait_key={data_set['trait_ref']}
          key={data_set}
        />
      </Flex.Item>
      <Divider />
      {/* Links */}
      <Flex.Item width={'50%'}>
        <Flex direction="column">
          {links[data_set['trait_id']] ? (
            links[data_set['trait_id']].map((id) => (
              <Button
                key={id}
                className="plant__button"
                onClick={() =>
                  act('select_link', { key: id, chapter: 'features' })
                }
              >
                {`${
                  chapters['features']['/datum/plant_feature/fruit'][id]
                    ? chapters['features']['/datum/plant_feature/fruit'][id][
                        'stats'
                      ]['name']
                    : chapters['features']['/datum/plant_feature/body'][id]
                      ? chapters['features']['/datum/plant_feature/body'][id][
                          'stats'
                        ]['name']
                      : chapters['features']['/datum/plant_feature/roots'][id]
                        ? chapters['features']['/datum/plant_feature/roots'][
                            id
                          ]['stats']['name']
                        : 'No Records'
                }
              `}
              </Button>
            ))
          ) : (
            <Button className="plant__dialogue">No Records</Button>
          )}
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const InspectionPanelFeature = (props) => {
  const { act, data } = useBackend();
  const { links, chapters } = data;
  const { current_feature_data, current_feature_traits, feature_key } = props;
  return (
    <Flex direction="column">
      {/* base feature information, stats */}
      <Flex.Item>
        <Button className="plant__dialogue" width={'100%'} mt={'10px'}>
          {current_feature_data.map((data_set) =>
            data_set['data_title'] ? (
              <PlantDataInstance
                title={data_set['data_title']}
                body={data_set['data_field']}
                key={data_set}
              />
            ) : (
              <Divider key={data_set} />
            ),
          )}
        </Button>
      </Flex.Item>
      <Divider />
      {/* traits */}
      <Flex.Item>
        {current_feature_traits ? (
          current_feature_traits.map((data_set) => (
            <PlantTraitInstance
              title={data_set['trait_name']}
              body={data_set['trait_desc']}
              trait_key={data_set['trait_ref']}
              key={data_set}
            />
          ))
        ) : (
          <Button className="plant__dialogue">No Traits Found</Button>
        )}
      </Flex.Item>
      <Divider />
      {/* Links */}
      <Flex.Item>
        <Flex direction={'row'}>
          <Flex direction={'column'}>
            {links[feature_key] ? (
              links[feature_key].map((plant_key) => (
                <Button
                  key={plant_key}
                  className="plant__button"
                  onClick={() =>
                    act('select_link', {
                      key: plant_key,
                      chapter:
                        chapters['features']['/datum/plant_feature/fruit'][
                          plant_key
                        ] ||
                        chapters['features']['/datum/plant_feature/body'][
                          plant_key
                        ] ||
                        chapters['features']['/datum/plant_feature/roots'][
                          plant_key
                        ]
                          ? 'features'
                          : 'plants',
                    })
                  }
                >
                  {chapters['plants'][plant_key]
                    ? `${chapters['plants'][plant_key]['name']} (found in)`
                    : `${
                        (chapters['features']['/datum/plant_feature/fruit'][
                          plant_key
                        ]
                          ? chapters['features']['/datum/plant_feature/fruit'][
                              plant_key
                            ]['stats']['name']
                          : 0) ||
                        (chapters['features']['/datum/plant_feature/body'][
                          plant_key
                        ]
                          ? chapters['features']['/datum/plant_feature/body'][
                              plant_key
                            ]['stats']['name']
                          : 0) ||
                        (chapters['features']['/datum/plant_feature/roots'][
                          plant_key
                        ]
                          ? chapters['features']['/datum/plant_feature/roots'][
                              plant_key
                            ]['stats']['name']
                          : 0)
                      } (mutates from)`}
                </Button>
              ))
            ) : (
              <Button className="plant__dialogue">No Records</Button>
            )}
          </Flex>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const InspectionPanelPlantFeature = (props) => {
  const { act, data } = useBackend();
  const { current_feature_data, current_feature_traits } = props;
  return (
    <Flex direction="column">
      {/* base feature information, stats */}
      <Flex.Item>
        <Button className="plant__dialogue" width={'100%'} mt={'10px'}>
          {current_feature_data.map((data_set) =>
            data_set['data_title'] ? (
              <PlantDataInstance
                title={data_set['data_title']}
                body={data_set['data_field']}
                key={data_set}
              />
            ) : (
              <Divider key={data_set} />
            ),
          )}
        </Button>
      </Flex.Item>
      <Divider />
      {/* traits */}
      <Flex.Item>
        {current_feature_traits ? (
          current_feature_traits.map((data_set) => (
            <PlantTraitInstance
              title={data_set['trait_name']}
              body={data_set['trait_desc']}
              trait_key={data_set['trait_ref']}
              key={data_set}
            />
          ))
        ) : (
          <Button className="plant__dialogue">No Traits Found</Button>
        )}
      </Flex.Item>
    </Flex>
  );
};

const ChapterEntry = (props) => {
  const { act, data } = useBackend();
  const { selected_chapter } = data;
  const { title } = props;
  return (
    <Button
      className="plant__button"
      width={'100%'}
      selected={title === selected_chapter}
      onClick={() => act('select_chapter', { key: title })}
    >
      {title}
    </Button>
  );
};

const Entry = (props) => {
  const { act, data } = useBackend();
  const { selected_entry } = data;
  const { title, selected_key } = props;
  return (
    <Button
      className="plant__button"
      width={'100%'}
      selected={selected_key === selected_entry}
      onClick={() => act('select_entry', { key: selected_key })}
    >
      {title}
    </Button>
  );
};

const PlantDataInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body } = props;
  return (
    <Flex.Item>
      <b>{title}</b>: {body}
    </Flex.Item>
  );
};

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body } = props;
  return (
    <Button className="plant__dialogue" width={'100%'}>
      <i>{title}</i>
      <br />
      {body}
    </Button>
  );
};
