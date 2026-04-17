import { useBackend } from '../backend';
import { Box, Button, Dimmer, Divider, Flex, Section } from '../components';
import { Window } from '../layouts';

export const PlantEditor = (props) => {
  const { act, data } = useBackend();
  const {
    inserted_plant,
    plant_feature_data,
    current_feature,
    disk_feature_data,
    disk_trait_data,
    disk_inserted,
    saving_feature,
    last_command,
  } = data;
  return (
    <Window width={750} height={750} theme="plant_menu">
      <Window.Content>
        {saving_feature ? <Dimmer /> : ''}
        <Box m={'-3px'} height={'100%'}>
          <Flex direction={'column'} height={'100%'}>
            {/* World building fluff top banner */}
            <Flex.Item>
              <Section textAlign={'center'}>
                Plant Analyzer [Version 7.20.4.5]
              </Section>
            </Flex.Item>
            <Flex direction={'row'}>
              {/* Feature tab*/}
              <Flex.Item width={'100%'}>
                <Flex direction={'column'}>
                  <Flex.Item>
                    <Section textAlign={'center'}>
                      <h1>{inserted_plant || 'No Plant Inserted'}</h1>
                    </Section>
                  </Flex.Item>
                  <Flex.Item>
                    <Section>
                      <Flex direction={'column'} grow={1}>
                        {/* Features */}
                        <Flex.Item>
                          {plant_feature_data.length
                            ? plant_feature_data.map((feature_data) => (
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
                </Flex>
              </Flex.Item>
              {/* Inspection panel*/}
              <Flex.Item width={'100%'}>
                <Section>
                  {current_feature ? <InspectionPanel /> : ' ... '}
                </Section>
              </Flex.Item>
            </Flex>
            {/* World building fluff top banner */}
            <Flex.Item>
              <Box height={'20px'} />
            </Flex.Item>
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

const DiskEmptyTab = (props) => {
  const { act, data } = useBackend();
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue" width={'100%'}>
        Empty Disk
      </Button>
      <Button
        className="plant__button"
        icon={'eject'}
        tooltip={'Eject Disk'}
        onClick={() => act('remove_disk')}
      />
    </Flex>
  );
};

const DiskTraitTab = (props) => {
  const { act, data } = useBackend();
  const { data_set } = props;
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue" width={'100%'}>
        <i>{data_set['trait_name']}</i>
        <br />
        {data_set['trait_desc']}
      </Button>
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'trash'}
        tooltip="Remove Trait"
        onClick={() => act('remove_trait', { key: data_set['trait_ref'] })}
      />
      <Button
        className="plant__button"
        verticalAlignContent={'middle'}
        icon={'eject'}
        tooltip={'Eject Disk'}
        onClick={() => act('remove_disk')}
      />
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
    </Flex>
  );
};

const InspectionPanel = (props) => {
  const { act, data } = useBackend();
  const { current_feature_data, current_feature_traits } = data;
  return (
    <Flex direction="column">
      <Box className={'scrollbox'} height={'575px'} overflowY="scroll">
        {/* base feature information, stats */}
        <Flex.Item>
          <Button className="plant__dialogue--beacon" width={'100%'}>
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
                save_disabled={data_set['can_copy']}
              />
            ))
          ) : (
            <Button className="plant__dialogue--beacon">
              No Traits Found
            </Button>
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

const PlantTraitInstance = (props) => {
  const { act, data } = useBackend();
  const { title, body, trait_key, save_disabled } = props;
  const { saving_feature, save_excluded_traits } = data;
  return (
    <Flex direction={'row'}>
      <Button className="plant__dialogue--beacon" width={'100%'}>
        <i>{title}</i>
        <br />
        {body}
      </Button>
      {!saving_feature ? (
        <Button
          className="plant__button"
          verticalAlignContent={'middle'}
          icon={'save'}
          onClick={() => act('save_trait', { key: trait_key })}
          disabled={!save_disabled}
        />
      ) : (
        <Button.Checkbox
          className="plant__button--beacon"
          verticalAlignContent={'middle'}
          checked={!save_excluded_traits.includes(trait_key)}
          onClick={() => act('toggle_trait', { key: trait_key })}
          disabled={!save_disabled}
        />
      )}
    </Flex>
  );
};

const PlantFeaturePanel = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature, saving_feature } = data;
  return (
    <Flex>
      <Button
        className="plant__button"
        width={'100%'}
        onClick={
          saving_feature
            ? null
            : () => act('select_feature', { key: feature['key'] })
        }
        selected={feature['key'] === current_feature}
      >
        {`${feature['name']}`}
      </Button>
      <Button
        className={
          feature['key'] === current_feature
            ? 'plant__button--beacon'
            : 'plant__button'
        }
        verticalAlignContent={'middle'}
        icon={saving_feature ? 'save' : 'search'}
        tooltip="Save Feature"
        disabled={!feature['can_copy']}
        onClick={() =>
          act('save_feature', {
            key: feature['key'],
            force: saving_feature ? 1 : 0,
          })
        }
      />
    </Flex>
  );
};
