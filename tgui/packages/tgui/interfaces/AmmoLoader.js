import { useBackend } from 'tgui/backend';
import { Button, Flex } from '../components';
import { Window } from '../layouts';

export const AmmoLoader = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    loaded = [],
  } = data;
  return (
    <Window
      width={380}
      height={240}>
      <Window.Content>
        <Flex direction="column" overflowY="scroll">
          {loaded.map(element => (
            <Flex.Item key={element.id}>
              <Flex direction="row">
                <Flex.Item grow={1}>{element.name}</Flex.Item>
                <Flex.Item mr="20px">{element.count}</Flex.Item>
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
