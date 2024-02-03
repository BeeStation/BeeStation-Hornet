/* eslint-disable react/prefer-stateless-function */
import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section, Dropdown, Flex } from '../components';
import { Window } from '../layouts';

const KEY_REGEX = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

export const BanningPanel = (props, context) => {
  // const { act, data } = useBackend(context);

  return (
    <Window theme="admin" title="Banning Panel" resizable>
      <Flex>
        <Flex.Item>
          <Button.Checkbox content="Key" />
        </Flex.Item>
        <Flex.Item>
          <Input />
        </Flex.Item>
      </Flex>
      <Flex>
        <Flex.Item>
          <Button.Checkbox content="IP" />
        </Flex.Item>
        <Flex.Item>
          <Input />
        </Flex.Item>
      </Flex>
      <Flex>
        <Flex.Item>
          <Button.Checkbox content="CID" />
        </Flex.Item>
        <Flex.Item>
          <Input />
        </Flex.Item>
      </Flex>
      <Button.Checkbox content="Enable supression" />
      <Button.Checkbox content="Use IP and CID from last connection of key" />
      <Button.Checkbox content="Applies to admins" />
      <Flex>
        <Flex.Item>
          <Dropdown selected={'Temporary'} options={['Permanent', 'Temporary']} />
        </Flex.Item>
        <Flex.Item>
          <Input />
        </Flex.Item>
        <Flex.Item>
          <Dropdown selected={'Minutes'} options={['Seconds', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Years']} />
        </Flex.Item>
      </Flex>
    </Window>
  );
};
