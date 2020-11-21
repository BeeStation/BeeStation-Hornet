import { useBackend } from "../backend";
import { Button } from "../components";

import { Window } from "../layouts";

export const Vote = (props, context) => {
  const { act, data } = useBackend(context);
  const { choices, votes } = data;

  return (
    <Window width={200} height={100}>
      <Window.Content>
        {choices.map((choice) => (
          <Button
            key={choice.id}
            icon="flask" // placeholder
            content={choice.name}
            disabled={!choice.chosen}
            width="140px"
            onClick={() =>
              act("vote", {
                choice: choice.id,
              })
            }
          />
        ))}
      </Window.Content>
    </Window>
  );
};
