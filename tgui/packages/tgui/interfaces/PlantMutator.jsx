import { ButtonCheckbox } from 'tgui/components/Button';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Flex,
  Icon,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const PlantMutator = (props) => {
  const { act, data } = useBackend();
  const {
    inserted_plant,
    last_command,
    plant_feature_data,
    catalyst,
    catalyst_desc,
    catalyst_strength,
    current_feature,
    confirm_radiation,
    working,
    port_traits,
  } = data;
  return (
    <Window width={600} height={500} theme="plant_menu">
      <Window.Content scrollable={1}>
        {working ? (
          <Dimmer className={'Dimmer--super'}>
            <Section>
              <Icon size={3} name={'radiation'} className={'spinner'} />
            </Section>
          </Dimmer>
        ) : (
          ''
        )}
        {confirm_radiation ? <Dimmer /> : ''}
        <Box m={'-3px'} height={'100%'}>
          <Flex direction={'column'} height={'100%'}>
            {/* World building fluff top banner */}
            <Flex.Item>
              <Section textAlign={'center'}>
                Irradiator Kiln [Version 1.0.0.3]
              </Section>
            </Flex.Item>
            {/* Plant stuff column */}
            <Flex.Item>
              <Flex direction={'row'}>
                {/* Feature row */}
                <Flex.Item width={'100%'}>
                  <Flex direction={'column'}>
                    {/* Plant title */}
                    <Flex.Item width={'100%'}>
                      <Section>
                        <h1>{inserted_plant || 'No Plant Inserted'}</h1>
                      </Section>
                    </Flex.Item>
                    {/* Feature panel  */}
                    <Flex.Item>
                      <Section>
                        {plant_feature_data.length
                          ? plant_feature_data.map((feature_data) => (
                              <PlantFeaturePanel
                                feature={feature_data}
                                key={feature_data}
                              />
                            ))
                          : '...'}
                      </Section>
                    </Flex.Item>
                    {/* Info */}
                    <Flex.Item width={'100%'}>
                      {/* Title */}
                      <Section>
                        <h1>{catalyst || 'No Catalyst Inserted'}</h1>
                        <Divider />
                        {catalyst_desc || '...'}
                      </Section>
                      {/* Body */}
                      <Section>
                        <Box textAlign={'center'}>Irradiator Coil Charge</Box>
                        <ProgressBar
                          color={'#ffff77'}
                          textColor={
                            catalyst_strength
                              ? catalyst_strength > 90
                                ? '#252517ff'
                                : '#ffff77'
                              : '#ffff77'
                          }
                          value={Math.min(catalyst_strength * 0.01, 1)}
                        >
                          {catalyst_strength || '0'}
                        </ProgressBar>
                      </Section>
                    </Flex.Item>
                  </Flex>
                </Flex.Item>
                {/* Inspection row */}
                <Flex.Item width={'100%'}>
                  <Section textAlign={'center'}>
                    <ButtonCheckbox
                      width={'100%'}
                      className={'plant__button'}
                      checked={port_traits}
                      tooltip="Port traits from the original feature to the mutated result, when possible"
                      onClick={() =>
                        act('toggle_port', { port_state: !port_traits })
                      }
                    >
                      Preserve Traits
                    </ButtonCheckbox>
                  </Section>
                  <Section>
                    {current_feature ? <InspectionPanel /> : ' ... '}
                  </Section>
                </Flex.Item>
              </Flex>
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
      <Button className="plant__button--display--beacon" width={'100%'}>
        <i>{title}</i>
        <br />
        {body}
      </Button>
    </Flex>
  );
};

const InspectionPanel = (props) => {
  const { act, data } = useBackend();
  const { current_feature_data, current_feature_traits } = data;
  return (
    <Flex direction="column">
      {/* base feature information, stats */}
      <Flex.Item>
        <Button className="plant__button--display--beacon" width={'100%'}>
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
          <Button className="plant__button--display--beacon">
            No Traits Found
          </Button>
        )}
      </Flex.Item>
    </Flex>
  );
};

const PlantFeaturePanel = (props) => {
  const { act, data } = useBackend();
  const { feature } = props;
  const { current_feature, confirm_radiation } = data;
  return (
    <Flex>
      <Button
        className="plant__button"
        width={'100%'}
        onClick={() =>
          confirm_radiation
            ? act('cancel')
            : act('select_feature', { key: feature['key'] })
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
        icon={confirm_radiation ? 'check' : 'radiation'}
        tooltip="Mutate Feature"
        onClick={() => act('mutate', { key: feature['key'] })}
      />
    </Flex>
  );
};
