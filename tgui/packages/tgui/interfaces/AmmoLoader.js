import { Button, Flex } from '../components';
import { Window } from '../layouts';

export const AmmoLoader = (props, context) => {
  const { act, data } = context;
  const {
    loaded = [],
  } = data;
  return (
    <Window
      width={380}
      height={240}>
      <Window.Content>
        <Flex direction="row" overflowY="scroll">
          {loaded.map(element => (
            <Flex.Item key={element.id}>
              <Flex direction="width">
                <Flex.Item grow={1}>element.name</Flex.Item>
                <Flex.Item>element.count</Flex.Item>
                <Flex.Item>
                  <Button
                    content="Eject"
                    onClick={() => act('eject', {
                      id: element.id,
                    })} />
                </Flex.Item>
              </Flex>
            </Flex.Item>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
