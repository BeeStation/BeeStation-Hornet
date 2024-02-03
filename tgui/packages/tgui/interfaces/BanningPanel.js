/* eslint-disable react/prefer-stateless-function */
import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section, Dropdown, Flex } from '../components';
import { Window } from '../layouts';

const KEY_REGEX = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

export const BanningPanel = (props, context) => {
  // const { act, data } = useBackend(context);

  return (
    <Window theme="admin" title="Banning Panel" width={1200} height={500} resizable>
      <Flex>
        <Flex.Item>
          <Button.Checkbox content="Key" />
          <Input />
        </Flex.Item>
        <Flex.Item>
          <Button.Checkbox content="IP" />
          <Input />
        </Flex.Item>
        <Flex.Item>
          <Button.Checkbox content="CID" />
          <Input />
        </Flex.Item>
        <Button.Checkbox content="Enable supression" />
      </Flex>
      <Button.Checkbox content="Use IP and CID from last connection of key" />
      <Button.Checkbox content="Applies to admins" />
      <Dropdown options={['Permanent', 'Temporary']} />
      <Input />
      <Dropdown options={['Seconds', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Years']} />

      <Window.Content scrollable />
    </Window>
  );
};
