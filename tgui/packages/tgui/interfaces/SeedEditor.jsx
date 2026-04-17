import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const SeedEditor = (props) => {
  const { act, data } = useBackend();
  const {
    seeds_feature_data,
    current_feature,
    inserted_plant,
    disk_feature_data,
    disk_trait_data,
    disk_inserted,
    last_command,
    current_feature_genetic_budget,
    current_feature_remaining_genetic_budget,
  } = data;
  return (
    <Window width={750} height={750} theme="plant_menu">
      <Window.Content>
        <Box m={'-3px'} height={'100%'}>
          <Flex direction={'column'} height={'100%'}>
            {/* World building fluff top banner */}
            <Flex.Item>
              <Section textAlign={'center'}>
                Seed Sequencer [Version 4.1.1.9]
              </Section>
            </Flex.Item>
            {/* Top banner, contains plant name & genetic stability */}
            <Flex.Item>
              <Flex direction={'row'}>
                <Section textAlign={'center'} width={'100%'}>
                  <Flex direction={'row'} justify="center">
                    <h1>{inserted_plant || 'No Seeds Inserted'}</h1>
                    <Button
                      className="plant__button"
                      icon={'eject'}
                      tooltip={'Eject Seeds'}
                      onClick={() => act('remove_seeds')}
                      mx={"5px"}
                      my={"8px"}
                      height={"50%"}
                    />
                  </Flex>
                </Section>
                <Section textAlign={'center'} width={'100%'}>
                  Genetic Stability
                  <ProgressBar
                    color={'#ffff77'}
                    textColor={
                      current_feature_genetic_budget
                        ? current_feature_genetic_budget -
                            current_feature_remaining_genetic_budget <=
                          0
                          ? '#252517ff'
                          : '#ffff77'
                        : '#ffff77'
                    }
                    maxValue={current_feature_genetic_budget || 1}
                    value={current_feature_remaining_genetic_budget || 0}
                  >
                    {current_feature_remaining_genetic_budget || 0}
                  </ProgressBar>
                </Section>
              </Flex>
            </Flex.Item>
            {/* Bottom section for plant feature select panel, and inspection panel */}
            <Flex.Item>
              <Flex direction={'row'}>
                {/* Feature panel */}
                <Flex.Item grow={1} width={'100%'}>
                  <Section>
                    <Flex direction={'column'} grow={1}>
                      {/* Features */}
                      <Flex.Item>
                        {seeds_feature_data.length
                          ? seeds_feature_data.map((feature_data) => (
                              <PlantFeaturePanel
                                feature={feature_data}
                                key={feature_data}
                              />
                            ))
                          : '...'}
                      </Flex.Item>
                      <Divider />
                      {/* Disk */}
                      <Flex.Item>
                        {disk_feature_data ? (
                          <DiskFeatureTab feature={disk_feature_data} />
                        ) : disk_trait_data ? (
                          <DiskTraitTab data_set={disk_trait_data} />
                        ) : disk_inserted ? (
                          <Flex.Item>
                            <DiskEmptyTab />
                          </Flex.Item>
                        ) : (
                          <Flex.Item>
                            <Button
                              width={'100%'}
                              className="plant__dialogue"
                            >
                              {'No Disk Inserted'}
                            </Button>
                          </Flex.Item>
                        )}
                      </Flex.Item>
                    </Flex>
                  </Section>
                </Flex.Item>
                {/* Inspection panel */}
                <Flex.Item width={'100%'}>
                  <Section>
                    {current_feature ? <InspectionPanel /> : ' ... '}
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
              <Section textAlign={'start'} mb={'-3px'}>
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

const DiskEmptyTab = (props) => {
  const { act, data } = useBackend();
  const { data_set } = props;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        icon={'eject'}
        tooltip={'Eject Disk'}
        onClick={() => act('remove_disk')}
      />
      <Button className="plant__dialogue" width={'100%'}>
        Empty Disk
      </Button>
    </Flex>
  );
};

const DiskTraitTab = (props) => {
  const { act, data } = useBackend();
  const { data_set } = props;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'eject'}
        tooltip={'Eject Disk'}
        onClick={() => act('remove_disk')}
      />
      <PlantTraitInstance
        title={data_set['trait_name']}
        body={data_set['trait_desc']}
        trait_key={data_set['trait_ref']}
        key={data_set}
      />
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        onClick={() => act('add_trait', { key: data_set['trait_ref'] })}
      >
        +
      </Button>
    </Flex>
  );
};

const DiskFeatureTab = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature } = data;
  return (
    <Flex direction={'row'}>
      <Button
        className="plant__button"
        icon={'trash'}
        tooltip="Remove Feature"
        onClick={() => act('remove_feature', { key: feature['key'] })}
      />
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'eject'}
        tooltip={'Eject Disk'}
        onClick={() => act('remove_disk')}
      />
      <Button
        className="plant__button"
        width={'100%'}
        onClick={() => act('select_feature', { key: feature['key'] })}
        selected={feature['key'] === current_feature}
      >
        {`${feature['name']}`}
      </Button>
      <Button
        className="plant__button"
        icon={'plus'}
        tooltip="Add Feature"
        onClick={() => act('add_feature', { key: feature['key'] })}
      />
    </Flex>
  );
};

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body, trait_key, remove_disabled } = props;
  return (
    <Flex direction={'row'}>
      <Flex.Item grow={1}>
        <Button className="plant__dialogue" width={'100%'}>
          <i>{title}</i>
          <br />
          {body}
        </Button>
      </Flex.Item>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'trash'}
        tooltip="Remove Trait"
        disabled={!remove_disabled}
        onClick={() => act('remove_trait', { key: trait_key })}
      />
    </Flex>
  );
};

const InspectionPanel = (props) => {
  const { act, data } = useBackend();
  const { current_feature_data, current_feature_traits } = data;
  return (
    <Flex direction="column">
      <Box className={'scrollbox'} height={'520px'} overflowY="scroll">
        {/* base feature information, stats */}
        <Flex.Item>
          <Button className="plant__dialogue" width={'100%'}>
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
                remove_disabled={data_set['can_remove']}
              />
            ))
          ) : (
            <Button className="plant__dialogue">No Traits Found</Button>
          )}
        </Flex.Item>
      </Box>
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

const PlantFeaturePanel = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature } = data;
  return (
    <Flex>
      <Button
        className="plant__button"
        width={'100%'}
        onClick={() => act('select_feature', { key: feature['key'] })}
        selected={feature['key'] === current_feature}
      >
        {`${feature['name']}`}
      </Button>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'trash'}
        tooltip="Remove Feature"
        disabled={!feature['can_remove']}
        onClick={() => act('remove_feature', { key: feature['key'] })}
      />
    </Flex>
  );
};
