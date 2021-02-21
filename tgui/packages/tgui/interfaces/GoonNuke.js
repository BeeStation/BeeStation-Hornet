import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Flex, Grid, Icon } from '../components';
import { Window } from '../layouts';

// This ui is so many manual overrides and !important tags
// and hand made width sets that changing pretty much anything
// is going to require a lot of tweaking it get it looking correct again
// I'm sorry, but it looks bangin

export const GoonNuke = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    anchored,
    disk_present,
    status1,
    status2,
  } = data;
  return (
    <Window
      theme="retro"
      width={421}
      height={260}>
      <Window.Content>
        <Box m={1}>
          <Box
            mb={1}
            className="NuclearBomb__displayBox">
            {status1}
          </Box>
          <Flex mb={1.5}>
            <Flex.Item grow={1}>
              <Box className="NuclearBomb__displayBox">
                {status2}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="eject"
                fontSize="24px"
                lineHeight="23px"
                textAlign="center"
                width="43px"
                ml={1}
                mr="3px"
                mt="3px"
                className="NuclearBomb__Button NuclearBomb__Button--keypad"
                onClick={() => act('eject_disk')} />
            </Flex.Item>
          </Flex>
          <Flex ml="3px">
            <Flex.Item ml={1} width="129px">
              <Box>
                <Button
                  fluid
                  bold
                  content="ARM"
                  textAlign="center"
                  fontSize="28px"
                  lineHeight="32px"
                  mb={1}
                  className="NuclearBomb__Button NuclearBomb__Button--C"
                  onClick={() => act('arm')} />
                <Button
                  fluid
                  bold
                  content="ANCHOR"
                  textAlign="center"
                  fontSize="28px"
                  lineHeight="32px"
                  className="NuclearBomb__Button NuclearBomb__Button--E"
                  onClick={() => act('anchor')} />
              </Box>
            </Flex.Item>

            <Flex.Item ml={1} width="140px">
              <Box>
                <Box
                  textAlign="center"
                  fontSize="18px"
                  className="NuclearBomb__namePlate"
                  height="104px">
                  <Box
                    height="32px">
                    HSNB FUSOR
                  </Box>
                  <Box
                    fontSize="15px">
                    DO NOT MOVE DEVICE WHILE IN OPERATION
                  </Box>
                </Box>
              </Box>
            </Flex.Item>
            <Flex.Item ml={1} width="100px">
              <Box>
                <Box
                  textAlign="center"
                  color="#9C9987"
                  fontSize="70px">
                  <Icon name="radiation" />
                </Box>
              </Box>
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
