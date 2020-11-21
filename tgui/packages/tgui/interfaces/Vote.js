import { useBackend } from "../backend";
import {
  Box,
  Flex,
  Button,
  Section,
  Collapsible,
  TimeDisplay,
} from "../components";
import { Window } from "../layouts";
import { logger } from "../logging";

export const Vote = (props, context) => {
  const { act, data, config } = useBackend(context);
  const {
    avm,
    avr,
    mode,
    avmap,
    voted,
    voting,
    choices,
    question,
    initiator,
    lower_admin,
    upper_admin,
    started_time,
    time_remaining,
    generated_actions,
  } = data;

  logger.log(data);

  let userVote = null;

  return (
    <Window
      resizable
      title={`Vote${
        mode ? ": " + mode.replace(/^\w/, (c) => c.toUpperCase()) : ""
      }`}
      width={400}
      height={500}
    >
      <Window.Content>
        <Flex direction="column" height="100%">
          {lower_admin && (
            <Flex.Item mb={1}>
              <Collapsible title="Admin Options">
                <Section mb={1} title="Start a vote">
                  <Flex justify="space-between">
                    <Flex.Item>
                      <Box mb={1}>
                        <Button
                          disabled={!upper_admin || !avmap}
                          onClick={() => act("map")}
                        >
                          Map
                        </Button>
                        {upper_admin && (
                          <Button.Checkbox
                            ml={1}
                            color="red"
                            checked={!avmap}
                            onClick={() => act("toggle_map")}
                          >
                            Disable{!avmap ? "d" : ""}
                          </Button.Checkbox>
                        )}
                      </Box>
                      <Box mb={1}>
                        <Button
                          disabled={!upper_admin || !avr}
                          onClick={() => act("restart")}
                        >
                          Restart
                        </Button>
                        {upper_admin && (
                          <Button.Checkbox
                            ml={1}
                            color="red"
                            checked={!avr}
                            onClick={() => act("toggle_restart")}
                          >
                            Disable{!avr ? "d" : ""}
                          </Button.Checkbox>
                        )}
                      </Box>
                      <Box mb={1}>
                        <Button
                          disabled={!upper_admin || !avm}
                          onClick={() => act("gamemode")}
                        >
                          Gamemode
                        </Button>
                        {upper_admin && (
                          <Button.Checkbox
                            ml={1}
                            color="red"
                            checked={!avm}
                            onClick={() => act("toggle_gamemode")}
                          >
                            Disable{!avm ? "d" : ""}
                          </Button.Checkbox>
                        )}
                      </Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        disabled={!upper_admin}
                        onClick={() => act("custom")}
                      >
                        Create Custom Vote
                      </Button>
                    </Flex.Item>
                  </Flex>
                </Section>
                <Section>
                  <Collapsible mb={1} title="LIST: Still Voting">
                    {voting}
                  </Collapsible>
                </Section>
              </Collapsible>
            </Flex.Item>
          )}
          <Flex.Item mb={1} grow={1}>
            <Section fill title="Choices">
              {choices.length === 0 && "No choices available!"}
              {choices?.map((choice, i) => (
                <Flex justify={"space-between"} key={i} mb={1}>
                  <Flex.Item mb={1}>
                    <Button
                      onClick={() => {
                        act("vote", {
                          index: i + 1,
                        });
                        userVote = choice;
                      }}
                      disabled={voted.includes(config.client.ckey)}
                    >
                      {choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                    </Button>
                    {userVote === choice ? "Voted!" : ""}
                  </Flex.Item>
                  <Flex.Item> {` Votes: ${choice.votes}`}</Flex.Item>
                </Flex>
              ))}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section>
              <Flex justify="space-between">
                {upper_admin && (
                  <Button
                    onClick={() => {
                      act("cancel");
                    }}
                    color="red"
                  >
                    Cancel Vote
                  </Button>
                )}
                <Box fontSize={1.5} textAlign="right">
                  Time Remaining: <TimeDisplay value={time_remaining} />
                </Box>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
