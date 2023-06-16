import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { ButtonCheckbox } from 'tgui/components/Button';
import { Box, Section, Button, Flex, TextArea, Input } from '../components';

export const IssueReporter = (props, context) => {
  const { act } = useBackend(context);

  const [isRegression, setIsRegression] = useLocalState(context, 'isRegression', false);
  const [issueName, setIssueName] = useLocalState(context, 'issueName', '');
  const [replicationSteps, setReplicationSteps] = useLocalState(context, 'replicationSteps', '');
  const [expected, setExpected] = useLocalState(context, 'expected', '');
  const [actual, setActual] = useLocalState(context, 'actual', '');

  const [stage, setStage] = useLocalState(context, 'stage', 1);

  let content = 'The issue reporter is currently facing issues.';
  let windowHeight = 480;

  switch (stage) {
    case 1:
      content = (
        <Regression
          isRegression={isRegression}
          setIsRegression={setIsRegression}
          issueName={issueName}
          setIssueName={setIssueName}
        />
      );
      windowHeight = 294;
      break;
    case 2:
      content = <ExpectedBehaviours expected={expected} setExpected={setExpected} actual={actual} setActual={setActual} />;
      windowHeight = 494;
      break;
    case 3:
      content = <ReplicationSteps replicationSteps={replicationSteps} setReplicationSteps={setReplicationSteps} />;
      windowHeight = 362;
      break;
  }

  return (
    <Window width={340} height={windowHeight} overflow="auto" theme="generic" title={`Issue reporter (${stage}/3)`}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item grow={1}>{content}</Flex.Item>
          <Flex.Item alignSelf="flex-end">
            <Section>
              <Flex direction="row" width="100%">
                {stage !== 1 ? (
                  <Flex.Item grow={1}>
                    <Button
                      fontSize={1.5}
                      onClick={() => {
                        if (stage === 1) {
                          return;
                        }
                        setStage(stage - 1);
                      }}>
                      Previous
                    </Button>
                  </Flex.Item>
                ) : (
                  <Flex.Item grow={1} />
                )}
                <Flex.Item alignSelf="flex-end">
                  <Button
                    fontSize={1.5}
                    onClick={() => {
                      if (stage === 3) {
                        // Submit the report and close
                        act('submit', {
                          title: issueName,
                          expected: expected,
                          actual: actual,
                          replicationSteps: replicationSteps,
                          isRegression: isRegression,
                        });
                        return;
                      }
                      setStage(stage + 1);
                    }}>
                    {stage === 3 ? 'Submit in browser' : 'Continue'}
                  </Button>
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Regression = (props, context) => {
  const { isRegression, setIsRegression, issueName, setIssueName } = props;

  return (
    <>
      <Section title="Issue Title">
        Please enter a concise name for the issue
        <Input mt={1} width="100%" value={issueName} onInput={(e, text) => setIssueName(text)} />
      </Section>
      <Section title="Issue Type">
        Was the issue being reported previously functioning as intended?
        <i>(Please select &#39;No&#39; if unknown).</i>
        <Box mt={1} mb={1} width="100%">
          <ButtonCheckbox
            overflowX="wrap"
            ml={1}
            style={{ 'font-weight': 'normal', 'font-size': '12px' }}
            content={'Yes - This is a new issue'}
            checked={isRegression}
            onClick={() => {
              setIsRegression(!isRegression);
            }}
          />
        </Box>
      </Section>
    </>
  );
};

const ExpectedBehaviours = (props, context) => {
  const { expected, setExpected, actual, setActual } = props;

  return (
    <>
      <Section title="Expected Behaviour">
        Please describe the expected behaviour of the issue that you are reporting.
        <TextArea mt={1} height="120px" value={expected} onInput={(e, text) => setExpected(text)} />
      </Section>
      <Section title="Actual Behaviour">
        Please describe the actual behaviour exhibited.
        <TextArea mt={1} height="120px" value={actual} onInput={(e, text) => setActual(text)} />
      </Section>
    </>
  );
};

const ReplicationSteps = (props, context) => {
  const { replicationSteps, setReplicationSteps } = props;

  return (
    <Section title="Replication Steps">
      Please describe the steps that you performed in order to cause the bug to happen. Issues that have steps to replicate 100%
      of the time are more likely to be solved.
      <TextArea mt={1} height="150px" value={replicationSteps} onInput={(e, text) => setReplicationSteps(text)} />
    </Section>
  );
};
