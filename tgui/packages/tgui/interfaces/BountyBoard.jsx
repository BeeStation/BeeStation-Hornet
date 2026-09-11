import { useState } from 'react';

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
  Tabs,
  TextArea,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { UserDetails } from './Newscaster';

// Status + Color of an active request.
const STATUS_META = {
  open: { color: 'green', label: 'Open' },
  claimed: { color: 'yellow', label: 'Claimed' },
};

// All non-active bounties are marked complete, with a tag indicating how it was completed.
const OUTCOME_META = {
  Paid: { color: 'good', label: 'Paid' },
  Failed: { color: 'bad', label: 'Failed' },
  Expired: { color: 'average', label: 'Expired' },
};

const getOutcomeMeta = (tags = '') => {
  for (const outcome of Object.keys(OUTCOME_META)) {
    if (tags.includes(outcome)) {
      return OUTCOME_META[outcome];
    }
  }
  return { color: 'grey', label: 'Completed' };
};

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
  const [tab, setTab] = useState('open');

  const openRequests = requests.filter((request) => request.status === 'open');
  const claimedRequests = requests.filter(
    (request) => request.status === 'claimed',
  );

  const tabs = [
    { key: 'open', label: 'Open', list: openRequests },
    { key: 'claimed', label: 'Claimed', list: claimedRequests },
    { key: 'completed', label: 'Completed Log', list: completedRequests },
  ];
  const activeTab = tabs.find((entry) => entry.key === tab) || tabs[0];

  return (
    <>
      <UserDetails />

      {!user.silicon && <NewBountyMenu />}

      <Section title="Bounty Log">
        <Tabs fluid textAlign="center">
          {tabs.map((entry) => (
            <Tabs.Tab
              key={entry.key}
              selected={tab === entry.key}
              onClick={() => setTab(entry.key)}
            >
              {entry.label} ({entry.list.length})
            </Tabs.Tab>
          ))}
        </Tabs>
        <Box mt={1}>
          {!activeTab.list.length && (
            <Box italic color="label" textAlign="center" py={2}>
              No {activeTab.label.toLowerCase()} bounties.
            </Box>
          )}
          {activeTab.list.map((request) => (
            <BountyCard
              key={`${request.acc_number}-${request.status}-${request.tags}`}
              request={request}
              user={user}
              completed={tab === 'completed'}
            />
          ))}
        </Box>
      </Section>
    </>
  );
};

const BountyCard = ({ request, user, completed }) => {
  const { act } = useBackend();
  const meta = completed
    ? getOutcomeMeta(request.tags)
    : STATUS_META[request.status] || { color: 'grey', label: request.status };

  return (
    <Collapsible
      color={meta.color}
      title={
        <Stack fill>
          <Stack.Item grow>
            <Box bold as="span">
              {request.title || 'Untitled'}
            </Box>
            <Box as="span" color="label" ml={1}>
              x{request.quantity || 1}
            </Box>
            {!!request.prepaid && (
              <Box as="span" color="good" bold ml={1}>
                <Icon name="vault" mr={0.5} />
                Pre-Paid
              </Box>
            )}
          </Stack.Item>
          <Stack.Item>
            <Box bold as="span">
              <Icon name="coins" mr={0.5} />
              {formatMoney(request.value)}cr total
            </Box>
          </Stack.Item>
        </Stack>
      }
      buttons={
        <>
          <Box inline bold mr={1} px={1} color={meta.color}>
            {meta.label}
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
            request.status === 'claimed' &&
            request.owner !== user.name &&
            request.claimant === user.name && (
              <Button
                icon="undo"
                content="Cancel Claim"
                color="average"
                onClick={() =>
                  act('unclaim', {
                    request: request.request_id || request.acc_number,
                  })
                }
              />
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
      <Box mt={1}>
        <b>Issuer Name:</b> {request.owner}
      </Box>
      <Box mt={1}>
        <b>Requested Quantity:</b> {request.quantity || 1}
      </Box>
      {!!request.rewardPerItem && (
        <Box mt={1}>
          <b>Reward Per Item:</b> {formatMoney(request.rewardPerItem)}cr
        </Box>
      )}
      <Box mt={1}>
        <b>Payment Status:</b>{' '}
        {request.prepaid ? (
          <Box as="span" color="good">
            Pre-Paid - Funds have secured and deposited, they will be released electronically pending the Issuer marking the bounty as completed.
          </Box>
        ) : (
          <Box as="span" color="label">
            Deferred - Issuer is taking responsibility for payment and is due to pay personally upon completion of the bounty.
          </Box>
        )}
      </Box>
      <Box mt={1}>
        <b>Bounty Request:</b> {request.title || 'Untitled'}
      </Box>
      <Box mt={1}>
        <b>Bounty Description:</b>{' '}
        {!request.description && <Box as="span" italic color="label">None provided.</Box>}
      </Box>
      {!!request.description && (
        <BlockQuote style={{ whiteSpace: 'pre-wrap', overflow: 'auto' }}>
          <i>{request.description}</i>
        </BlockQuote>
      )}
      {!!request.claimant && <Box mt={1}>Claimed by: {request.claimant}</Box>}
      {!!request.tags && <Box mt={1}>Tags: {request.tags}</Box>}
    </Collapsible>
  );
};

const NewBountyMenu = (_) => {
  const { act, data } = useBackend();
  const { bountyValue, bountyQuantity, bountyTitle, bountyText, user } = data;
  const [itemMode, setItemMode] = useState('single');
  const [rewardPerItem, setRewardPerItem] = useState(bountyValue);

  const setSingleItemMode = () => {
    setItemMode('single');
    act('bountyQty', { bountyqty: 1 });
  };

  const setMultipleItemsMode = () => {
    setItemMode('multiple');
    setRewardPerItem(bountyValue);
  };

  const setMultipleQuantity = (quantity) => {
    act('bountyQty', { bountyqty: quantity });
    act('bountyVal', { bountyval: quantity * rewardPerItem });
  };

  const setMultipleReward = (reward) => {
    setRewardPerItem(reward);
    act('bountyVal', { bountyval: bountyQuantity * reward });
  };

  const submitBounty = (prepay) => {
    act('createBounty', {
      multipleItems: itemMode === 'multiple',
      rewardPerItem: itemMode === 'multiple' ? rewardPerItem : null,
      prepay,
    });
    setItemMode('single');
    setRewardPerItem(1);
  };

  return (
    <Section title="Create Bounty">
      <Stack mb={1} align="end">
        <Stack.Item>
          <Stack vertical g={0.25}>
            <Stack.Item>
              <Button
                fluid
                selected={itemMode === 'single'}
                content="Single Item"
                onClick={setSingleItemMode}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                selected={itemMode === 'multiple'}
                content="Multiple Items"
                onClick={setMultipleItemsMode}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {itemMode === 'single' ? (
          <Stack.Item>
            <Box bold mb={0.25}>Reward</Box>
            <NumberInput
              animated
              unit="cr"
              minValue={1}
              maxValue={1000}
              value={bountyValue}
              width="100px"
              step={1}
              onChange={(value) => act('bountyVal', { bountyval: value })}
            />
          </Stack.Item>
        ) : (
          <>
            <Stack.Item>
              <Box bold mb={0.25}>Quantity Requested</Box>
              <NumberInput
                animated
                minValue={1}
                maxValue={1000}
                value={bountyQuantity}
                width="100px"
                step={1}
                onChange={setMultipleQuantity}
              />
            </Stack.Item>
            <Stack.Item mb={0.5}>x</Stack.Item>
            <Stack.Item>
              <Box bold mb={0.25}>Reward Per Item</Box>
              <NumberInput
                animated
                unit="cr"
                minValue={1}
                maxValue={1000}
                value={rewardPerItem}
                width="100px"
                step={1}
                onChange={setMultipleReward}
              />
            </Stack.Item>
            <Stack.Item mb={0.5}>=</Stack.Item>
            <Stack.Item>
              <Box bold mb={0.25}>Total Reward</Box>
              <Box
                p={0.5}
                textAlign="right"
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  minWidth: '100px',
                }}
              >
                {formatMoney(bountyQuantity * rewardPerItem)}cr
              </Box>
            </Stack.Item>
          </>
        )}
        <Stack.Item grow />
        <Stack.Item>
          <Stack vertical g={0.25}>
            <Stack.Item>
              <Button
                fluid
                icon="print"
                content="Submit Bounty"
                disabled={!user.authenticated}
                onClick={() => submitBounty(false)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                icon="piggy-bank"
                content="Pre-Pay & Submit"
                color="good"
                tooltip="Withdraws the reward from your account and puts it on hold. Funds will then be automatically transferred upon bounty being marked complete, or returned due to cancellation."
                disabled={!user.authenticated}
                onClick={() => submitBounty(true)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Box mb={1}>Bounty Request</Box>
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
