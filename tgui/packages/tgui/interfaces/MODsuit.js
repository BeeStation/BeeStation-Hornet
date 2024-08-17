import { useBackend, useLocalState } from '../backend';
import { Button, ColorBox, LabeledList, ProgressBar, Section, Collapsible, Box, Icon, Stack, Table, Dimmer, NumberInput, Flex, AnimatedNumber, Dropdown } from '../components';
import { Window } from '../layouts';

const ConfigureNumberEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      stepPixelSize={5}
      width="39px"
      onChange={(e, value) => act('configure', {
        "key": name,
        "value": value,
        "ref": module_ref,
      })} />
  );
};

const ConfigureBoolEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <Button.Checkbox
      checked={value}
      onClick={() => act('configure', {
        "key": name,
        "value": !value,
        "ref": module_ref,
      })}
    />
  );
};

const ConfigureColorEntry = (props, context) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <>
      <Button
        icon="paint-brush"
        onClick={() => act('configure', {
          "key": name,
          "ref": module_ref,
        })} />
      <ColorBox
        color={value}
        mr={0.5} />
    </>
  );
};

const ConfigureListEntry = (props, context) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend(context);
  return (
    <Dropdown
      displayText={value}
      options={values}
      onSelected={value => act('configure', {
        "key": name,
        "value": value,
        "ref": module_ref,
      })}
    />
  );
};

const ConfigureDataEntry = (props, context) => {
  const { name, display_name, type, value, values, module_ref } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
  };
  return (
    <Box>
      {display_name}: {configureEntryTypes[type]}
    </Box>
  );
};

const RadCounter = (props, context) => {
  const {
    active,
    userradiated,
    usertoxins,
    threatlevel,
  } = props;
  return (
    <Stack fill textAlign="center">
      <Stack.Item grow>
        <Section title="Radiation Level" color={active && userradiated ? "bad" : "good"}>
          {active && userradiated ? "IRRADIATED" : "RADIATION-FREE"}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Toxins Level">
          <ProgressBar
            value={active ? usertoxins / 100 : 0}
            ranges={{
              good: [-Infinity, 0.2],
              average: [0.2, 0.5],
              bad: [0.5, Infinity],
            }} >
            <AnimatedNumber value={usertoxins} />
          </ProgressBar>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Hazard Level" color={active && threatlevel ? "bad" : "good"} bold>
          {active && threatlevel ? threatlevel : 0}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ID2MODULE = {
  rad_counter: RadCounter,
};

const LockedInterface = () => (
  <Section align="center" fill>
    <Icon
      color="red"
      name="exclamation-triangle"
      size={15}
    />
    <Box fontSize="30px" color="red">
      ERROR: INTERFACE UNRESPONSIVE
    </Box>
  </Section>
);

const LockedModule = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Dimmer>
      <Stack>
        <Stack.Item fontSize="16px" color="blue">
          SUIT UNPOWERED
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const ConfigureScreen = (props, context) => {
  const { configuration_data, module_ref } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Dimmer backgroundColor="rgba(0, 0, 0, 0.8)">
      <Stack vertical>
        {configuration_keys.map(key => {
          const data = configuration_data[key];
          return (
            <Stack.Item key={data.key}>
              <ConfigureDataEntry
                name={key}
                display_name={data.display_name}
                type={data.type}
                value={data.value}
                values={data.values}
                module_ref={module_ref} />
            </Stack.Item>
          );
        })}
        <Stack.Item>
          <Box>
            <Button
              fluid
              onClick={props.onExit}
              icon="times"
              textAlign="center" >
              Exit
            </Button>
          </Box>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const displayText = param => {
  switch (param) {
    case 1:
      return "Use";
    case 2:
      return "Toggle";
    case 3:
      return "Select";
  }
};

const ParametersSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    malfunctioning,
    locked,
    open,
    selected_module,
    complexity,
    complexity_max,
    wearer_name,
    wearer_job,
    AI,
  } = data;
  const status = malfunctioning
    ? 'Malfunctioning' : active
      ? 'Active' : 'Inactive';
  return (
    <Section title="Parameters">
      <LabeledList>
        <LabeledList.Item
          label="Status"
          buttons={
            <Button
              icon="power-off"
              content={active ? 'Deactivate' : 'Activate'}
              onClick={() => act('activate')} />
          } >
          {status}
        </LabeledList.Item>
        <LabeledList.Item
          label="Lock"
          buttons={
            <Button
              icon={locked ? "lock-open" : "lock"}
              content={locked ? 'Unlock' : 'Lock'}
              onClick={() => act('lock')} />
          } >
          {locked ? 'Locked' : 'Unlocked'}
        </LabeledList.Item>
        <LabeledList.Item label="Cover">
          {open ? 'Open' : 'Closed'}
        </LabeledList.Item>
        <LabeledList.Item label="Selected Module">
          {selected_module || "None"}
        </LabeledList.Item>
        <LabeledList.Item label="Complexity">
          {complexity} ({complexity_max})
        </LabeledList.Item>
        <LabeledList.Item label="Occupant">
          {wearer_name}, {wearer_job}
        </LabeledList.Item>
        <LabeledList.Item label="Onboard AI">
          {AI || 'None'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const HardwareSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    control,
    helmet,
    chestplate,
    gauntlets,
    boots,
    cell,
    charge,
  } = data;
  return (
    <Section title="Hardware">
      <Collapsible title="Parts">
        <LabeledList>
          <LabeledList.Item label="Control Unit">
            {control}
          </LabeledList.Item>
          <LabeledList.Item label="Helmet">
            {helmet || "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Chestplate">
            {chestplate || "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Gauntlets">
            {gauntlets || "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Boots">
            {boots || "None"}
          </LabeledList.Item>
        </LabeledList>
      </Collapsible>
      <Collapsible title="Cell">
        {cell && (
          <LabeledList>
            <LabeledList.Item label="Cell Type">
              {cell}
            </LabeledList.Item>
            <LabeledList.Item label="Cell Charge">
              <ProgressBar
                value={charge / 100}
                content={charge + '%'}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }} />
            </LabeledList.Item>
          </LabeledList>
        ) || (
          <Box color="bad" textAlign="center">No Cell Detected</Box>
        )}
      </Collapsible>
    </Section>
  );
};

const InfoSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active,
    modules,
  } = data;
  const info_modules = modules.filter(module => !!module.id);

  return (
    <Section title="Info">
      <Stack vertical>
        {info_modules.length !== 0 && info_modules.map(module => {
          const Module = ID2MODULE[module.id];
          return (
            <Stack.Item key={module.ref}>
              {!active && <LockedModule />}
              <Module {...module} active={active} />
            </Stack.Item>
          );
        }) || (
          <Box textAlign="center">No Info Modules Detected</Box>
        )}
      </Stack>
    </Section>
  );
};

const ModuleSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    complexity_max,
    modules,
  } = data;
  const [configureState, setConfigureState]
    = useLocalState(context, "module_configuration", null);
  return (
    <Section title="Modules" fill>
      <Flex direction="column">
        {modules.length !== 0 && modules.map(module => {
          return (
            <Flex.Item key={module.ref} >
              <Collapsible
                title={module.name} >
                <Section>
                  {configureState === module.ref && (
                    <ConfigureScreen
                      configuration_data={module.configuration_data}
                      module_ref={module.ref}
                      onExit={() => setConfigureState(null)} />)}
                  <Table>
                    <Table.Row
                      header>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          color="transparent"
                          icon="save"
                          tooltip="Complexity"
                          tooltipPosition="top" />
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          color="transparent"
                          icon="plug"
                          tooltip="Idle Power Cost"
                          tooltipPosition="top" />
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          color="transparent"
                          icon="lightbulb"
                          tooltip="Active Power Cost"
                          tooltipPosition="top" />
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          color="transparent"
                          icon="bolt"
                          tooltip="Use Power Cost"
                          tooltipPosition="top" />
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          color="transparent"
                          icon="hourglass-half"
                          tooltip="Cooldown"
                          tooltipPosition="top" />
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          color="transparent"
                          icon="tasks"
                          tooltip="Actions"
                          tooltipPosition="top" />
                      </Table.Cell>
                    </Table.Row>
                    <Table.Row>
                      <Table.Cell textAlign="center">
                        {module.complexity}/{complexity_max}
                      </Table.Cell>
                      <Table.Cell textAlign="center">
                        {module.idle_power}
                      </Table.Cell>
                      <Table.Cell textAlign="center">
                        {module.active_power}
                      </Table.Cell>
                      <Table.Cell textAlign="center">
                        {module.use_power}
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        {(module.cooldown > 0) && (
                          module.cooldown / 10
                        ) || ("0")}/{module.cooldown_time / 10}s
                      </Table.Cell>
                      <Table.Cell
                        textAlign="center">
                        <Button
                          onClick={() => act('select', { "ref": module.ref })}
                          icon="bullseye"
                          selected={module.active}
                          tooltip={displayText(module.module_type)}
                          tooltipPosition="left"
                          disabled={!module.module_type} />
                        <Button
                          onClick={() => setConfigureState(module.ref)}
                          selected={configureState === module.ref}
                          icon="cog"
                          tooltip="Configure"
                          tooltipPosition="left"
                          disabled={module.configuration_data.length === 0} />
                      </Table.Cell>
                    </Table.Row>
                  </Table>
                  <Box>
                    {module.description}
                  </Box>
                </Section>
              </Collapsible>
            </Flex.Item>
          );
        }) || (
          <Flex.Item>
            <Box textAlign="center">No Modules Detected</Box>
          </Flex.Item>
        )}
      </Flex>
    </Section>
  );
};

export const MODsuit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ui_theme,
    interface_break,
  } = data;
  return (
    <Window
      width={400}
      height={525}
      theme={ui_theme}
      title="MOD Interface Panel"
      resizable>
      <Window.Content scrollable={!interface_break}>
        {!!interface_break && (
          <LockedInterface />
        ) || (
          <Stack vertical fill>
            <Stack.Item>
              <ParametersSection />
            </Stack.Item>
            <Stack.Item>
              <HardwareSection />
            </Stack.Item>
            <Stack.Item>
              <InfoSection />
            </Stack.Item>
            <Stack.Item grow>
              <ModuleSection />
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
