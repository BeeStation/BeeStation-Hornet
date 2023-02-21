import { useBackend } from '../backend';
import { Button, Stack } from '../components';
import { Window } from '../layouts';

export const Elevator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_z,
    available_levels
  } = data;
  return (
    <Window        
    width={240}
    height={500}
    theme="retro">
      <Window.Content scrollable={1}>
        <Stack direction="row" wrap="wrap" grow = {1} 
        align = "center" 
        spacing = {`0%`}>
          {
            available_levels.map(level => (
            <Stack.Item basis = {`100px`}>
              <Button disabled = {level == current_z}
              onClick={() => act(`${level}`)}
              fontSize = {`50px`}
              bold = {1}
              m = {`5%`}>
                {level}
              </Button>
            </Stack.Item>))
          }
        </Stack>
      </Window.Content>
    </Window>
  );
};
