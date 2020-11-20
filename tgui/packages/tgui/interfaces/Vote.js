import { useBackend } from "../backend";
import { Button } from "../components";

import { Window } from "../layouts";

export const Vote = (props, context) => {
  const { act, data } = useBackend(context);
  const { choices, votes } = data;

  return (
    <Window width={200} height={100}>
      <Window.Content>
        {choices.map((choices) => (
          <Button
            key={choices.id}
            icon="flask"
            content={choices.name}
            disabled={!choices.chosen}
            width="140px"
            onClick={() =>
              act("vote", {
                choice: choices.id,
              })
            }
          />
        ))}
      </Window.Content>
    </Window>
  );
};
