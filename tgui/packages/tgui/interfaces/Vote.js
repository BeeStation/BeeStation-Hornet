import { useBackend } from "../backend";
import { Box, Icon, Flex, Button, Section, Collapsible } from "../components";
import { Window } from "../layouts";

export const Vote = (props, context) => {
  const { data } = useBackend(context);
  const { mode, question, lower_admin } = data;

  return (
    <Window
      resizable
      title={`Vote${
        mode
          ? `: ${
            question
              ? question.replace(/^\w/, (c) => c.toUpperCase())
              : mode.replace(/^\w/, (c) => c.toUpperCase())
            }`
          : ""
      }`}
      width={400}
      height={500}
    >
      <Window.Content>
        <Flex direction="column" height="100%">
          {lower_admin && <AdminPanel />}
          <ChoicesPanel />
          <TimePanel />
        </Flex>
      </Window.Content>
    </Window>
  );
};

// Collapsible panel for admin actions.
const AdminPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { avm, avr, avmap, voting, upper_admin } = data;
  return (
    <Flex.Item mb={1}>
      <Collapsible title="Admin Options">
        <Section mb={1} title="Start a vote">
          <Flex justify="space-between">
            <Flex.Item>
              <Box mb={1}>
                <Button
                  disabled={!upper_admin || !avmap}
                  onClick={() => act("map")}>
                  Map
                </Button>
                {upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={!avmap}
                    onClick={() => act("toggle_map")}>
                    Disable{!avmap ? "d" : ""}
                  </Button.Checkbox>
                )}
              </Box>
              <Box mb={1}>
                <Button
                  disabled={!upper_admin || !avr}
                  onClick={() => act("restart")}>
                  Restart
                </Button>
                {upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={!avr}
                    onClick={() => act("toggle_restart")}>
                    Disable{!avr ? "d" : ""}
                  </Button.Checkbox>
                )}
              </Box>
              <Box mb={1}>
                <Button
                  disabled={!upper_admin || !avm}
                  onClick={() => act("gamemode")}>
                  Gamemode
                </Button>
                {upper_admin && (
                  <Button.Checkbox
                    ml={1}
                    color="red"
                    checked={!avm}
                    onClick={() => act("toggle_gamemode")}>
                    Disable{!avm ? "d" : ""}
                  </Button.Checkbox>
                )}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button disabled={!upper_admin} onClick={() => act("custom")}>
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
  );
};

// Display choices as buttons
const ChoicesPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode, choices, selectedChoice } = data;

  let content;
  if (choices.length === 0) (content = "No choices available!");
  // Single box for most normal vote types
  else if ((choices.length < 10) | (mode === "custom"))
    content = choices?.map((choice, i) => (
      <Flex justify="space-between" key={i} mb={1}>
        <Flex.Item mb={1}>
          <Flex direction="row">
            <Button
              onClick={() => {
                act("vote", {
                  index: i + 1,
                });
              }}
              disabled={choice === choices[selectedChoice - 1]}>
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
    ));
  else {
    // If there's both too much content, most likely gamemode
    content = (
      <Flex justify="space-between" direction="row" mb={1}>
        <Flex.Item direction="column" mr={1}>
          {choices?.map(
            (choice, i) =>
              i < choices.length / 2 && (
                <Flex justify="space-between" key={i}>
                  <Flex.Item>
                    <Flex direction="row">
                      <Button
                        onClick={() => {
                          act("vote", {
                            index: i + 1,
                          });
                        }}
                        disabled={choice === choices[selectedChoice - 1]}>
                        {choice.name?.replace(/^\w/, (c) => c.toUpperCase())}
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
                        disabled={choice === choices[selectedChoice - 1]}>
                        {choice.name?.replace(/^\w/, (c) => c.toUpperCase())}
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
    );
  }

  return (
    <Flex.Item mb={1} grow={1}>
      <Section fill title="Choices">
        {content}
      </Section>
    </Flex.Item>
  );
};

// Countdown timer at the bottom. Includes a cancel vote option for admins
const TimePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { upper_admin, time_remaining } = data;

  return (
    <Flex.Item>
      <Section>
        <Flex justify="space-between">
          {upper_admin && (
            <Button
              onClick={() => {
                act("cancel");
              }}
              color="red">
              Cancel Vote
            </Button>
          )}
          <Box fontSize={1.5} textAlign="right">
            Time Remaining: {time_remaining}s
          </Box>
        </Flex>
      </Section>
    </Flex.Item>
  );
};
