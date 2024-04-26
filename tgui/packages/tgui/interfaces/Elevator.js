import { useBackend } from '../backend';
import { Button, Flex, Box } from '../components';
import { Window } from '../layouts';

export const Elevator = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_z, available_levels, in_transit = false } = data;
  return (
    <Window width={280} height={500} theme="elevator">
      <Window.Content scrollable={1}>
        <Flex direction="row" wrap="wrap" grow={1}>
          {available_levels.map((level) => (
            <Flex.Item mr={1} mt={1} key={level}>
              <Box className="button-container">
                <Box inline className="button-label" bold>
                  {level}
                </Box>
                <Button selected={`${level}` === `${current_z}` && in_transit} onClick={() => act(`${level}`)} />
              </Box>
            </Flex.Item>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
