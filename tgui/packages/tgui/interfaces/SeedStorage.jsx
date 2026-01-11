import { useBackend } from '../backend';
import { Box, Button, Divider, Flex, Section } from '../components';
import { Window } from '../layouts';

export const SeedStorage = (props) => {
  const { act, data } = useBackend();
  const { seeds, focused_seeds } = data;
  return (
    <Window width={600} height={700} theme="plant_menu">
      <Window.Content scrollable={1}>
        <Box height={'100%'} width={'100%'} m={'-3px'}>
          <Flex direction={'column'} height={'100%'} width={'100%'}>
            {/* Seed tuff */}
            <Flex.Item>
              <Flex direction={'row'} width={'100%'}>
                {/* Seed browser */}
                <Flex.Item width={'40%'}>
                  <Section>
                    <Box
                      className={'scrollbox'}
                      height={'300px'}
                      overflowY="scroll"
                    >
                      {Object.entries(seeds).map(
                        ([data_list_key, data_list]) => (
                          <Entry key={data_list_key} data_list={data_list} />
                        ),
                      )}
                    </Box>
                  </Section>
                </Flex.Item>
                {/* Inspection panel */}
                <Flex.Item width={'60%'}>
                  <Section>
                    <Box mb={'-10px'} />
                    {focused_seeds['key'] && seeds[focused_seeds['species_id']]
                      ? Object.entries(
                          seeds[focused_seeds['species_id']]['features'],
                        ).map(([feature_key, feature]) => (
                          <Box key={feature_key}>
                            <InspectionPanel
                              key={feature_key}
                              current_feature_data={feature['data']}
                              current_feature_traits={feature['traits']}
                            />
                          </Box>
                        ))
                      : ''}
                  </Section>
                </Flex.Item>
              </Flex>
            </Flex.Item>
            {/* World building fluff top banner */}
            <Flex.Item>
              <Box height={'20px'} />
            </Flex.Item>
            <Flex.Item height={'100%'}>
              <Box />
            </Flex.Item>
            <Flex.Item>
              <Section textAlign={'start'} mb={'-5px'}>
                <Box>Yamato-lite OS [Version 7.3.1.1]</Box>
                <Box>© 2554 Yamato. All Rights Reserved.</Box>
                <br />
                <Box>
                  {'C:\\Users\\admin>'}
                  {'e'}
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

const InspectionPanel = (props) => {
  const { act, data } = useBackend();
  const { current_feature_data, current_feature_traits } = props;
  return (
    <Flex direction="column">
      {/* base feature information, stats */}
      <Flex.Item>
        <Button className="plant__button--display" width={'100%'} mt={'10px'}>
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
          <Button className="plant__button--display">No Traits Found</Button>
        )}
      </Flex.Item>
    </Flex>
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
    <Flex direction={'row'}>
      <Flex.Item grow={1}>
        <Button className="plant__button--display" width={'100%'}>
          <i>{title}</i>
          <br />
          {body}
        </Button>
      </Flex.Item>
    </Flex>
  );
};

const Entry = (props) => {
  const { act, data } = useBackend();
  const { focused_seeds } = data;
  const { data_list } = props;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        width={'100%'}
        selected={data_list['ref'] === focused_seeds['key']}
        onClick={() => act('select_entry', { key: data_list['ref'] })}
      >
        {`${data_list['name']} (${data_list['count']})`}
      </Button>
      <Button
        className="plant__button"
        icon="eject"
        onClick={() => act('dispense', { key: data_list['species_id'] })}
      />
    </Flex>
  );
};
