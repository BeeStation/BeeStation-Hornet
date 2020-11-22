import { useBackend } from "../backend";
import {
  Box,
  Icon,
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
    selectedChoice,
    time_remaining,
    generated_actions,
  } = data;

  return (
    <Window
      resizable
      title={`Vote${
        mode
          ? mode !== "custom"
            ? `: ${mode.replace(/^\w/, (c) => c.toUpperCase())}`
            : `: ${question.replace(/^\w/, (c) => c.toUpperCase())}`
          : ""
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
                <Section title="Still Voting">
                  <Collapsible mb={1} title="View List">
                    {voting}
                  </Collapsible>
                </Section>
              </Collapsible>
            </Flex.Item>
          )}
          <Flex.Item mb={1} grow={1}>
            <Section fill title="Choices">
              {choices.length === 0 && "No choices available!"}
              {mode !== "gamemode" &&
                choices?.map((choice, i) => (
                  <Flex justify="space-between" key={i} mb={1}>
                    <Flex.Item mb={1}>
                      <Flex direction="row">
                        <Button
                          onClick={() => {
                            act("vote", {
                              index: i + 1,
                            });
                          }}
                          disabled={choice === choices[selectedChoice - 1]}
                        >
                          {choice.name?.replace(/^\w/, (c) => c.toUpperCase())}
                        </Button>
                        <Box ml={1} textColor="green">
                          {choice === choices[selectedChoice - 1] && (
                            <Icon color="green" name="vote-yea" />
                          )}
                        </Box>
                      </Flex>
                    </Flex.Item>
                    <Flex.Item> {` Votes: ${choice.votes}`}</Flex.Item>
                  </Flex>
                ))}
              {mode === "gamemode" && choices.length > 10 && (
                <Flex justify="space-between" direction="row" mb={1}>
                  <Flex.Item direction="column" mr={1}>
                    {choices?.map(
                      (choice, i) =>
                        i < choices.length / 2 && (
                          <Flex justify="space-between" key={i}>
                            <Flex.Item>
                              <Flex justify="space-between" direction="row">
                                <Button
                                  onClick={() => {
                                    act("vote", {
                                      index: i + 1,
                                    });
                                  }}
                                  disabled={
                                    choice === choices[selectedChoice - 1]
                                  }
                                >
                                  {choice.name?.replace(/^\w/, (c) =>
                                    c.toUpperCase()
                                  )}
                                </Button>
                                <Box ml={1} textColor="green">
                                  {choice === choices[selectedChoice - 1] && (
                                    <Icon color="green" name="vote-yea" />
                                  )}
                                </Box>
                              </Flex>
                            </Flex.Item>
                            <Flex.Item ml={1}> {`| ${choice.votes}`}</Flex.Item>
                          </Flex>
                        )
                    )}
                  </Flex.Item>
                  <Flex.Item direction="column" ml={1}>
                    {choices?.map(
                      (choice, i) =>
                        i > choices.length / 2 && (
                          <Flex justify="space-between" key={i}>
                            <Flex.Item>
                              <Flex justify="space-between" direction="row">
                                <Button
                                  onClick={() => {
                                    act("vote", {
                                      index: i + 1,
                                    });
                                  }}
                                  disabled={
                                    choice === choices[selectedChoice - 1]
                                  }
                                >
                                  {choice.name?.replace(/^\w/, (c) =>
                                    c.toUpperCase()
                                  )}
                                </Button>
                                <Box ml={1} textColor="green">
                                  {choice === choices[selectedChoice - 1] && (
                                    <Icon color="green" name="vote-yea" />
                                  )}
                                </Box>
                              </Flex>
                            </Flex.Item>
                            <Flex.Item ml={1}>{`| ${choice.votes}`}</Flex.Item>
                          </Flex>
                        )
                    )}
                  </Flex.Item>
                </Flex>
              )}
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
                  Time Remaining: {time_remaining}s
                </Box>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
