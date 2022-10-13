import { Window } from '../layouts';
import { EmagConsoleText } from "./NtosEmagConsole";
import { useBackend } from '../backend';

export const EmagConsole = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Window title="Crypto-breaker 2400 Edition" width={400} height={500} theme="syndicate">
      <Window.Content>
        <EmagConsoleText
          log_text={data.log_text}
          frame_skip={5}
          end_pause={100} />
      </Window.Content>
    </Window>
  );
};
