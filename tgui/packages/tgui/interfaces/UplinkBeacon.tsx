import { Button, Flex, NoticeBox } from 'tgui/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type UplinkBeaconData = {
  frequency: number;
};

export const UplinkBeacon = () => {
  const { act, data } = useBackend<UplinkBeaconData>();
  const { frequency } = data;
  let channel = 'green';
  switch (frequency) {
    case 0:
      channel = 'green';
      break;
    case 1:
      channel = 'purple';
      break;
    case 2:
      channel = 'yellow';
      break;
    case 3:
      channel = 'orange';
      break;
    case 4:
      channel = 'red';
      break;
    case 5:
      channel = 'black';
      break;
    case 6:
      channel = 'white';
      break;
    case 7:
      channel = 'blue';
      break;
    case 8:
      channel = 'brown';
      break;
  }
  return (
    <Window width={300} height={270} theme="syndicate">
      <Window.Content>
        <NoticeBox
          height="9%"
          backgroundColor={channel}
          verticalAlign="middle"
          textAlign="center"
        >
          Beacon broadcasting on {channel} channel
        </NoticeBox>
        <Flex height="90%" direction="column">
          <Flex.Item grow>
            <Flex height="100%">
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="green"
                  onClick={() =>
                    act('set_freq', {
                      freq: 0,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="purple"
                  onClick={() =>
                    act('set_freq', {
                      freq: 1,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="yellow"
                  onClick={() =>
                    act('set_freq', {
                      freq: 2,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item grow>
            <Flex height="100%">
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="orange"
                  onClick={() =>
                    act('set_freq', {
                      freq: 3,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="red"
                  onClick={() =>
                    act('set_freq', {
                      freq: 4,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="black"
                  onClick={() =>
                    act('set_freq', {
                      freq: 5,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item grow>
            <Flex height="100%">
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="white"
                  onClick={() =>
                    act('set_freq', {
                      freq: 6,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="blue"
                  onClick={() =>
                    act('set_freq', {
                      freq: 7,
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item grow>
                <Button
                  width="100%"
                  height="100%"
                  color="brown"
                  onClick={() =>
                    act('set_freq', {
                      freq: 8,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
