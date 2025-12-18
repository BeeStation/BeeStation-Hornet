import { ReactElement, useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  Section,
  Stack,
} from 'tgui/components';
import { Window } from 'tgui/layouts';

const methodToComponent = (method: string, login: () => void): ReactElement => {
  switch (method) {
    case 'discord':
      return (
        <Button color="blurple" fontSize="16px" p={2} onClick={login}>
          <Box inline style={{ transform: 'translateY(1.5px)' }}>
            <Icon name="tg-discord" />
          </Box>{' '}
          Discord
        </Button>
      );
  }
  return <div>Unknown method: {method}</div>;
};

export const GameLogin = (props) => {
  const { act, data } = useBackend<{
    byond_enabled: boolean;
    methods: Record<string, string>;
    authenticated_key: string;
  }>();
  const [showInput, setShowInput] = useState(false);
  const inputToken = useRef<string>('');
  const sendToken = (token: string) => {
    Byond.topic({
      session_token: token,
      from_ui: 1,
    });
  };
  return (
    <Window title="LOGIN" width={400} height={450} theme="login">
      <Window.Content style={{ padding: '10px' }}>
        <Section title="Welcome!" fill style={{ textAlign: 'center' }}>
          <Stack vertical height="100%">
            <Stack.Item>
              <Box mt={2}>
                <Box>
                  You have connected as{' '}
                  {data.authenticated_key ? (
                    <span>
                      BYOND account <strong>{data.authenticated_key}</strong>
                    </span>
                  ) : (
                    <span>a guest</span>
                  )}
                  .
                </Box>
                {data.authenticated_key ? (
                  <Box my={1}>
                    Server policy requires that you link a second account to
                    your CKEY due to ongoing sign-on issues with BYOND.
                  </Box>
                ) : null}
                <Box mt={2.5}>
                  {`${
                    data.byond_enabled && !data.authenticated_key
                      ? ' Reconnect after signing into your BYOND account or '
                      : ' Please '
                  }log in with one of the following methods.`}
                </Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Flex
                direction="row"
                align="center"
                justify="center"
                height="100%"
              >
                <Flex.Item>
                  <Section fill fitted title="Methods">
                    <Flex
                      direction="row"
                      align="center"
                      justify="center"
                      height="100%"
                      p={2}
                    >
                      {Object.keys(data.methods).map((key) => (
                        <Flex.Item key={key}>
                          {methodToComponent(key, () =>
                            act('login', { method: key }),
                          )}
                        </Flex.Item>
                      ))}
                    </Flex>
                  </Section>
                </Flex.Item>
              </Flex>
            </Stack.Item>
            <Stack.Item>
              {showInput ? (
                <Box height="50px" textAlign="left">
                  <Box mb={1}>Enter Token</Box>
                  <Stack verticalAlign="center">
                    <Stack.Item grow>
                      <Input
                        autoFocus
                        placeholder="333f5d0fd91785947efa..."
                        fluid
                        onInput={(_, value) => {
                          inputToken.current = value;
                        }}
                        onEnter={(_, value) => sendToken(value)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        py={0.8}
                        onClick={() => sendToken(inputToken.current)}
                      >
                        Submit
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Box>
              ) : (
                <Box height="50px">
                  <Button
                    icon="sign-in"
                    color="default"
                    p={2}
                    onClick={() => setShowInput(true)}
                  >
                    Enter Token Manually
                  </Button>
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
