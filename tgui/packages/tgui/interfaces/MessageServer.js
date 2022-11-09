import { useBackend } from "../backend";
import { Stack, Dimmer, Section } from "../components";
import { Window } from "../layouts";


export const MessageServer = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    server_on,
    authenticated,
    hacking,
    no_server,
    can_hack,
    pda_messages,
    request_messages,
  } = data;
  return (
    <Window
      width={400}
      height={600}>
      <Window.Content>
        <Section title="Server Control">
          Server Link
        </Section>
        {!authenticated ? (
          <Dimmer>
            <Stack align="baseline" vertical>
              <Stack.Item>Authentication Required</Stack.Item>
            </Stack>
          </Dimmer>
        ) : null}
      </Window.Content>
    </Window>
  );
};
