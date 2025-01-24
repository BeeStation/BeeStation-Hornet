import { useBackend } from '../backend';
import { UserDetails } from './Newscaster';
import { Icon, Box, Button, Collapsible, Flex, NumberInput, Section, TextArea, BlockQuote } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const BountyBoard = () => {
  return (
    <Window width={550} height={600}>
      <Window.Content scrollable>
        <BountyBoardContent />
      </Window.Content>
    </Window>
  );
};

export const BountyBoardContent = (_, context) => {
  const { act, data } = useBackend(context);
  const { requests = [], applicants = [], user } = data;
  const color = '#2c4461';
  const backColor = 'black';
  return (
    <>
      <Section title="User Details">
        <UserDetails />
      </Section>
      {user.silicon ? null : <NewBountyMenu />}
      {requests?.map((request) => (
        <Collapsible key={request.name} title={`${request.owner}: ${formatMoney(request.value)}cr Bounty`}>
          <Section
            title={`${request.owner}`}
            key={request.name}
            buttons={
              <>
                <Icon name="coins" />
                <Box as="span" ml={1} mr={1}>
                  {formatMoney(request.value)}cr
                </Box>
                <Button
                  icon="pen-fancy"
                  content="Apply"
                  disabled={user.silicon || !user.authenticated || request.owner === user.name}
                  onClick={() =>
                    act('apply', {
                      request: request.acc_number,
                    })
                  }
                />
                <Button
                  icon="trash-alt"
                  content="Delete"
                  color="red"
                  onClick={() =>
                    act('deleteRequest', {
                      request: request.acc_number,
                    })
                  }
                />
              </>
            }>
            <BlockQuote style={{ 'white-space': 'pre-wrap', overflow: 'auto' }}>
              <i>{request.description}</i>
            </BlockQuote>
            {!!applicants.length && (
              <Section title="Request Applicants">
                {applicants?.map(
                  (applicant) =>
                    applicant.request_id === request.acc_number && (
                      <Flex key={applicant.request_id}>
                        <Flex.Item
                          grow={1}
                          p={0.5}
                          backgroundColor={backColor}
                          width="500px"
                          textAlign="center"
                          mt={1}
                          style={{
                            border: `1px solid ${color}`,
                            borderRadius: '5px',
                          }}>
                          {applicant.name}
                        </Flex.Item>
                        <Flex.Item mt={1} align="end">
                          <Button
                            icon="cash-register"
                            tooltip="Pay out to this applicant."
                            onClick={() =>
                              act('payApplicant', {
                                applicant: applicant.requestee_id,
                                request: request.acc_number,
                              })
                            }
                            disabled={request.owner !== user.name}
                          />
                        </Flex.Item>
                      </Flex>
                    )
                )}
              </Section>
            )}
          </Section>
        </Collapsible>
      ))}
    </>
  );
};

const NewBountyMenu = (_, context) => {
  const { act, data } = useBackend(context);
  const { bountyValue, user } = data;
  return (
    <Section
      title="Create Bounty"
      buttons={
        <>
          <NumberInput
            animate
            unit="cr"
            minValue={1}
            maxValue={1000}
            value={bountyValue}
            width="80px"
            onChange={(e, value) =>
              act('bountyVal', {
                bountyval: value,
              })
            }
          />
          <Button icon="print" content="Submit Bounty" disabled={!user.authenticated} onClick={() => act('createBounty')} />
        </>
      }>
      <TextArea
        height="60px"
        backgroundColor="black"
        textColor="white"
        onChange={(e, value) =>
          act('bountyText', {
            bountytext: value,
          })
        }
      />
    </Section>
  );
};
