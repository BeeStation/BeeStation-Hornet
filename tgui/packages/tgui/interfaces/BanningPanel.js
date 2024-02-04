/* eslint-disable react/prefer-stateless-function */
import { useBackend } from '../backend';
import { Button, Input, TextArea, LabeledList, Section, Box, Dropdown, Stack, Collapsible, Flex } from '../components';
import { Window } from '../layouts';

const KEY_REGEX = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

export const BanningPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    key_enabled,
    ip_enabled,
    cid_enabled,
    applies_to_admins,
    can_supress,
    suppressed,
    duration_type,
    time_units,
    ban_type,
    force_cryo_after, // Rest in piss, forever miss
    use_last_connection,
  } = data;

  return (
    <Window theme="admin" title="Banning Panel" resizable>
      <Window.Content>
        <Section title="Player Information">
          <Stack wrap="wrap">
            <Stack.Item>
              <Button.Checkbox content="Key" checked={key_enabled} onClick={() => act('toggle_key')} />
              <ConditionalComponent bool={key_enabled} component=<Input /> />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox content="IP" checked={ip_enabled} onClick={() => act('toggle_ip')} />
              <ConditionalComponent bool={ip_enabled} component=<Input /> />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox content="CID" checked={cid_enabled} onClick={() => act('toggle_cid')} />
              <ConditionalComponent bool={cid_enabled} component=<Input /> />
            </Stack.Item>
            <Stack.Item>
              <ConditionalComponent
                bool={can_supress}
                component=<Button.Checkbox
                  content="Enable supression"
                  color="bad"
                  checked={suppressed}
                  onClick={() => act('toggle_suppressed')}
                />
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              <Button.Checkbox
                content="Use IP and CID from last connection of key"
                checked={use_last_connection}
                onClick={() => act('toggle_use_last_connection')}
              />
              <Button.Checkbox
                content="Applies to admins"
                checked={applies_to_admins}
                onClick={() => act('toggle_applies_to_admins')}
              />
              <LabeledList>
                <LabeledList.Item label="Duration Type" verticalAlign="middle">
                  <Stack>
                    <Dropdown
                      selected={duration_type}
                      options={['Permanent', 'Temporary']}
                      onSelected={(selected) => act('set_duration_type', { type: selected })}
                    />
                    <ConditionalComponent
                      bool={duration_type === 'Temporary'}
                      component={() => {
                        return (
                          <Box>
                            <Input />
                            <Dropdown
                              selected={time_units}
                              options={['Seconds', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Years']}
                              onSelected={(selected) => act('set_time_units', { units: selected })}
                            />{' '}
                          </Box>
                        );
                      }}
                    />
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Ban Type" verticalAlign="middle">
                  <Dropdown
                    selected={ban_type}
                    options={['Server', 'Role']}
                    onSelected={(selected) => act('set_ban_type', { type: selected })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Ban Reason" verticalAlign="top">
                  <TextArea height="100px" />
                </LabeledList.Item>
                <LabeledList.Item>
                  <Button.Confirm content="Submit" onClick={() => act('submit_ban')} />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <ConditionalComponent bool={ban_type === 'Role'} component=<Roles /> />
      </Window.Content>
    </Window>
  );
};

const Roles = () => {
  return (
    <Section title="Roles" scrollable>
      <Stack direction="column">
        <CheckboxCollapsible title="Command Roles" color="blue" />
        <CheckboxCollapsible title="Security Roles" color="red" />
        <CheckboxCollapsible title="Engineering Roles" color="orange" />
        <CheckboxCollapsible title="Medical Roles" color="teal" />
        <CheckboxCollapsible title="Science Roles" color="purple" />
        <CheckboxCollapsible title="Supply Roles" color="brown" />
        <CheckboxCollapsible title="Silicon Roles" color="green" />
        <CheckboxCollapsible title="Antagonist Positions" color="black" />
        <CheckboxCollapsible title="Forced Antagonist Positions" color="bad" />
        <CheckboxCollapsible title="Ghost Roles" color="grey" />
        <CheckboxCollapsible title="Civilian" color="light-grey">
          <RolesInCategory roles={['Bartender', 'Botanist', 'Janitor', 'Cook', 'Lawyer', 'Curator', 'Chaplain']} />
        </CheckboxCollapsible>
        <CheckboxCollapsible title="Gimmick" color="pink">
          <RolesInCategory roles={['Clown', 'Mime', 'Assistant', 'Other Gimmick Roles']} />
        </CheckboxCollapsible>
        <CheckboxCollapsible title="Other">
          <Button.Checkbox content="Imaginary Friend" />
          <Button.Checkbox content="Split Personality" />
          <Button.Checkbox content="Mind Transfer Potion" />
          <Button.Checkbox content="Emergency Response Team" />
        </CheckboxCollapsible>
        <CheckboxCollapsible title="Abstract">
          <RolesInCategory roles={['Appearance', 'Emote', 'OOC', 'Dsay']} />
        </CheckboxCollapsible>
      </Stack>
    </Section>
  );
};

const CheckboxCollapsible = ({ color, title, onClick, children }) => {
  return (
    <Flex>
      <Button.Checkbox
        onClick={onClick}
        color={color}
        tooltip="Select all for this category"
        maxHeight="20px"
        verticalAlignContent="middle"
      />
      <Collapsible title={title} color={color} inline>
        {children}
      </Collapsible>
    </Flex>
  );
};

const RolesInCategory = ({ roles, all_checked }) => {
  return (
    <Stack wrap>
      {roles.map((role) => {
        return <Button.Checkbox content={role} key={role} />;
      })}
    </Stack>
  );
};

const ConditionalComponent = ({ bool, component }) => {
  if (bool) {
    return component;
  }
};
