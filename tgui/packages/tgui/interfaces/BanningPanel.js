/* eslint-disable react/prefer-stateless-function */
import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section, Box, Dropdown, Stack, Collapsible } from '../components';
import { Window } from '../layouts';

const KEY_REGEX = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

export const BanningPanel = (props, context) => {
  // const { act, data } = useBackend(context);

  return (
    <Window theme="admin" title="Banning Panel" resizable>
      <Stack wrap="wrap">
        <Stack.Item>
          <Button.Checkbox content="Key" />
          <Input />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox content="IP" />
          <Input />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox content="CID" />
          <Input />
        </Stack.Item>
      </Stack>
      <Button.Checkbox content="Use IP and CID from last connection of key" />
      <Button.Checkbox content="Applies to admins" />
      <Button.Checkbox content="Enable supression" />
      <Stack>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Duration Type">
              <Stack>
                <Dropdown selected={'Temporary'} options={['Permanent', 'Temporary']} />
                <Input />
                <Dropdown selected={'Minutes'} options={['Seconds', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Years']} />
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Ban Type">
              <Dropdown selected={'Server'} options={['Server', 'Role']} />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Ban Reason">
              <Input fluid />
            </LabeledList.Item>
            <LabeledList.Item>
              <Button content="Submit" />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
      <Roles />
    </Window>
  );
};

const Roles = () => {
  return (
    <Section title="Roles">
      <Stack wrap="wrap">
        <Button.Checkbox content="Command Roles" />
        <Button.Checkbox content="Security Roles" />
        <Button.Checkbox content="Engineering Roles" />
        <Button.Checkbox content="Medical Roles" />
        <Button.Checkbox content="Science Roles" />
        <Button.Checkbox content="Supply Roles" />
        <Button.Checkbox content="Silicon Roles" />
        <Button.Checkbox content="Gimmick Roles" />
        <Button.Checkbox content="Antagonist Positions" />
        <Button.Checkbox content="Forced Antagonist Positions" />
        <Button.Checkbox content="Ghost Roles" />
        <Collapsible title="Civilian">
          <Button.Checkbox content="Bartender" />
          <Button.Checkbox content="Botanist" />
          <Button.Checkbox content="Janitor" />
          <Button.Checkbox content="Cook" />
          <Button.Checkbox content="Lawyer" />
          <Button.Checkbox content="Curator" />
          <Button.Checkbox content="Chaplain" />
        </Collapsible>
        <Collapsible title="Gimmick">
          <Button.Checkbox content="Clown" />
          <Button.Checkbox content="Mime" />
          <Button.Checkbox content="Assistant" />
          <Button.Checkbox content="Other Gimmick Roles" />
        </Collapsible>
        <Collapsible title="Other">
          <Button.Checkbox content="Imaginary Friend" />
          <Button.Checkbox content="Split Personality" />
          <Button.Checkbox content="Mind Transfer Potion" />
          <Button.Checkbox content="Emergency Response Team" />
        </Collapsible>
        <Collapsible title="Abstract">
          <Button.Checkbox content="Appearance" />
          <Button.Checkbox content="Emote" />
          <Button.Checkbox content="OOC" />
          <Button.Checkbox content="Dsay" />
        </Collapsible>
      </Stack>
    </Section>
  );
};
