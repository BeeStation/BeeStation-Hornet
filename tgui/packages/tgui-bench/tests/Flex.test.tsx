import { Flex } from 'tgui/components';
import { render } from 'tgui/renderer';

export const Default = () => {
  const node = (
    <Flex align="baseline">
      <Flex.Item mr={1}>Text {Math.random()}</Flex.Item>
      <Flex.Item grow={1} basis={0}>
        Text {Math.random()}
      </Flex.Item>
    </Flex>
  );
  render(node);
};
