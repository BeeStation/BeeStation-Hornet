import { useState } from 'react';
import { Dropdown } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Icon,
  Input,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { UserDetails } from './Newscaster';

export const BountyBoard = () => {
  return (
    <Window width={550} height={600}>
      <Window.Content scrollable>
        <BountyBoardContent />
      </Window.Content>
    </Window>
  );
};

export const BountyBoardContent = (_) => {
  const { data } = useBackend();
  const { requests = [], completedRequests = [], user } = data;
  const [viewMode, setViewMode] = useState('All');

  const openRequests = requests.filter((request) => request.status === 'open');
  const claimedRequests = requests.filter(
    (request) => request.status === 'claimed',
  );

  return (
    <>
      <UserDetails />

      {!user.silicon && <NewBountyMenu />}

      <Section title="Board View">
        <Dropdown
          width="100%"
          selected={viewMode}
          options={['All', 'Open', 'Claimed', 'Completed']}
          onSelected={(value) => setViewMode(value)}
        />
      </Section>

      {(viewMode === 'All' || viewMode === 'Open') && (
        <BountySection
          title="Open Bounties"
          emptyMessage="No open bounties."
          requests={openRequests}
          user={user}
        />
      )}

      {(viewMode === 'All' || viewMode === 'Claimed') && (
        <BountySection
          title="Claimed Bounties"
          emptyMessage="No claimed bounties."
          requests={claimedRequests}
          user={user}
        />
      )}

      {(viewMode === 'All' || viewMode === 'Completed') && (
        <BountySection
          title="Completed Log"
          emptyMessage="No completed bounties."
          requests={completedRequests}
          user={user}
          completed
        />
      )}
    </>
  );
};

const BountySection = ({
  title,
  emptyMessage,
  requests,
  user,
  completed,
}) => {
  const { act } = useBackend();

  return (
    <Section title={title}>
      {!requests.length && <Box italic>{emptyMessage}</Box>}
      {requests.map((request) => (
        <Collapsible
          key={`${request.acc_number}-${request.status}`}
          title={`${request.title || 'Untitled'} x${request.quantity || 1} - ${formatMoney(
            request.value,
          )}cr`}
        >
          <Section
            title={request.title || 'Untitled'}
            buttons={
              <>
                <Icon name="coins" />
                <Box as="span" ml={1} mr={1}>
                  {formatMoney(request.value)}cr x{request.quantity || 1}
                </Box>
                {!completed && request.status === 'open' && (
                  <Button
                    icon="hand-paper"
                    content="Claim"
                    disabled={
                      user.silicon ||
                      !user.authenticated ||
                      request.owner === user.name
                    }
                    onClick={() =>
                      act('claim', {
                        request: request.request_id || request.acc_number,
                      })
                    }
                  />
                )}
                {!completed &&
                  request.status === 'claimed' &&
                  request.owner === user.name && (
                    <>
                      <Button
                        icon="check-circle"
                        content="Paid"
                        color="green"
                        onClick={() =>
                          act('payApplicant', {
                            request: request.request_id || request.acc_number,
                          })
                        }
                      />
                      <Button
                        icon="clock"
                        content="Expired"
                        color="average"
                        onClick={() =>
                          act('expireBounty', {
                            request: request.request_id || request.acc_number,
                          })
                        }
                      />
                      <Button
                        icon="times-circle"
                        content="Failed"
                        color="red"
                        onClick={() =>
                          act('failBounty', {
                            request: request.request_id || request.acc_number,
                          })
                        }
                      />
                      <Button
                        icon="undo"
                        content="Reopen"
                        onClick={() =>
                          act('unclaim', {
                            request: request.request_id || request.acc_number,
                          })
                        }
                      />
                    </>
                  )}
                {!completed &&
                  request.status === 'open' &&
                  request.owner === user.name && (
                    <Button
                      icon="trash-alt"
                      content="Delete"
                      color="red"
                      onClick={() =>
                        act('deleteRequest', {
                          request: request.request_id || request.acc_number,
                        })
                      }
                    />
                  )}
              </>
            }
          >
            {!!request.description && (
              <BlockQuote style={{ whiteSpace: 'pre-wrap', overflow: 'auto' }}>
                <i>{request.description}</i>
              </BlockQuote>
            )}
            <Box mt={1}>Issuer: {request.owner}</Box>
            {!!request.claimant && <Box mt={1}>Claimed by: {request.claimant}</Box>}
            {!!request.tags && <Box mt={1}>Tags: {request.tags}</Box>}
          </Section>
        </Collapsible>
      ))}
    </Section>
  );
};

const NewBountyMenu = (_) => {
  const { act, data } = useBackend();
  const { bountyValue, bountyQuantity, bountyTitle, bountyText, user } = data;

  return (
    <Section title="Create Bounty">
      <Stack mb={1} align="end">
        <Stack.Item>
          <Box
            bold
            textAlign="center"
            mb={0.25}
            px={0.5}
            py={0.2}
            style={{
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(255, 255, 255, 0.2)',
              borderRadius: '3px',
            }}
          >
            Reward
          </Box>
          <NumberInput
            animated
            unit="cr"
            minValue={1}
            maxValue={1000}
            value={bountyValue}
            width="90px"
            step={1}
            onChange={(value) =>
              act('bountyVal', {
                bountyval: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Box
            bold
            textAlign="center"
            mb={0.25}
            px={0.5}
            py={0.2}
            style={{
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(255, 255, 255, 0.2)',
              borderRadius: '3px',
            }}
          >
            Quantity
          </Box>
          <NumberInput
            animated
            unit="x"
            minValue={1}
            maxValue={1000}
            value={bountyQuantity}
            width="90px"
            step={1}
            onChange={(value) =>
              act('bountyQty', {
                bountyqty: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item>
          <Button
            icon="print"
            content="Submit Bounty"
            disabled={!user.authenticated}
            onClick={() => act('createBounty')}
          />
        </Stack.Item>
      </Stack>
      <Box mb={1}>Bounty Name</Box>
      <Input
        fluid
        maxLength={64}
        value={bountyTitle}
        onChange={(e, value) =>
          act('bountyTitle', {
            bountytitle: value,
          })
        }
      />

      <Box mt={1} mb={1}>
        Description (optional)
      </Box>
      <TextArea
        height="80px"
        backgroundColor="black"
        textColor="white"
        value={bountyText}
        onChange={(e, value) =>
          act('bountyText', {
            bountytext: value,
          })
        }
      />
    </Section>
  );
};
