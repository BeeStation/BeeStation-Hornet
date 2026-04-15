import { createSearch } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { NtosWindow } from '../layouts';
import { AccessList } from './common/AccessList';

type Account = {
  name: string;
  ref: string;
  job: string;
  is_operator: boolean;
};

type PaymentEntry = {
  dept_id: string;
  payment: number;
  bonus: number;
};

type LinkedCard = {
  name: string;
  assignment: string;
  icon_state: string;
  ref: string;
};

type SelectedAccount = {
  name: string;
  job: string;
  ref: string;
  access: number[];
  suspended: boolean;
  immutable: boolean;
  payment_data: PaymentEntry[];
  linked_cards: LinkedCard[];
};

type Region = {
  name: string;
  regid: number;
  accesses: { desc: string; ref: number }[];
};

type JobEntry = {
  title: string;
};

type JobGroup = {
  department: string;
  dept_bitflag: number;
  jobs: JobEntry[];
};

type SlotEntry = {
  title: string;
  current_positions: number;
  total_positions: number;
  is_prioritized: boolean;
};

type TrimStyle = {
  name: string;
  icon_state: string;
};

type TrimGroup = {
  department: string;
  dept_bitflag: number;
  trims: TrimStyle[];
};

type StationManagementData = {
  has_card: boolean;
  card_name: string | null;
  authenticated: boolean;
  has_change_ids: boolean;
  accessible_region_bitflag: number;
  accounts: Account[];
  selected_account: SelectedAccount | null;
  regions: Region[];
  job_groups: JobGroup[];
  slots: SlotEntry[];
  trim_styles: TrimGroup[];
  cooldown_remaining: number;
  cooldown_time: number;
};

export const NtosStationManagement = () => {
  const { data } = useBackend<StationManagementData>();
  const { authenticated, has_card } = data;

  return (
    <NtosWindow width={900} height={600}>
      <NtosWindow.Content scrollable>
        {!has_card ? (
          <NoCardView />
        ) : !authenticated ? (
          <LoginView />
        ) : (
          <AuthenticatedView />
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const NoCardView = () => (
  <Section fill>
    <Stack fill vertical>
      <Stack.Item grow />
      <Stack.Item align="center">
        <Icon name="id-card" size={5} color="label" />
      </Stack.Item>
      <Stack.Item align="center">
        <Box color="label" fontSize="16px" mt={2}>
          Insert an ID card to begin.
        </Box>
      </Stack.Item>
      <Stack.Item grow />
    </Stack>
  </Section>
);

const LoginView = () => {
  const { act, data } = useBackend<StationManagementData>();
  const { card_name } = data;

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item grow />
        <Stack.Item align="center">
          <Icon name="lock" size={5} color="average" />
        </Stack.Item>
        <Stack.Item align="center">
          <Box fontSize="16px" mt={2}>
            Station Management Console
          </Box>
        </Stack.Item>
        <Stack.Item align="center">
          <Box color="label" mt={1}>
            Card detected: {card_name || 'Unknown'}
          </Box>
        </Stack.Item>
        <Stack.Item align="center" mt={2}>
          <Button icon="lock-open" onClick={() => act('PRG_login')}>
            Login
          </Button>
          <Button
            icon="eject"
            color="bad"
            onClick={() => act('PRG_eject_card')}
          >
            Eject ID
          </Button>
        </Stack.Item>
        <Stack.Item grow />
      </Stack>
    </Section>
  );
};

const AuthenticatedView = () => {
  const { act, data } = useBackend<StationManagementData>();
  const { card_name, has_change_ids } = data;
  const [activeTab, setActiveTab] = useLocalState('mainTab', 'management');

  return (
    <Stack fill>
      <Stack.Item basis="260px">
        <AccountList />
      </Stack.Item>

      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Flex justify="space-between" align="center">
                <Flex.Item>
                  <Icon name="user-shield" mr={1} />
                  {card_name}
                  {!!has_change_ids && (
                    <Box as="span" color="good" ml={1}>
                      [CAPTAIN]
                    </Box>
                  )}
                </Flex.Item>
                <Flex.Item>
                  <Button icon="sign-out-alt" onClick={() => act('PRG_logout')}>
                    Logout
                  </Button>
                  <Button
                    icon="eject"
                    color="bad"
                    onClick={() => act('PRG_eject_card')}
                  >
                    Eject ID
                  </Button>
                </Flex.Item>
              </Flex>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === 'management'}
                onClick={() => setActiveTab('management')}
              >
                Account Management
              </Tabs.Tab>
              {!!has_change_ids && (
                <Tabs.Tab
                  selected={activeTab === 'slots'}
                  onClick={() => setActiveTab('slots')}
                >
                  Job Slots
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {activeTab === 'management' ? (
              <AccountManagementTab />
            ) : (
              <JobSlotsTab />
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const AccountList = () => {
  const { act, data } = useBackend<StationManagementData>();
  const { accounts = [], selected_account, has_change_ids } = data;
  const [searchTerm, setSearchTerm] = useLocalState('accountSearch', '');

  const isMatch = createSearch(
    searchTerm,
    (account: Account) => account.name + ' ' + account.job,
  );
  const filteredAccounts = accounts.filter(isMatch);

  return (
    <Section
      fill
      scrollable
      title="Accounts"
      buttons={
        !!has_change_ids && (
          <Button
            icon="plus"
            tooltip="Create New Account"
            onClick={() => act('PRG_create_account')}
          >
            New
          </Button>
        )
      }
    >
      <Input
        fluid
        placeholder="Search accounts..."
        value={searchTerm}
        onInput={(_event, value) => setSearchTerm(value)}
        mb={1}
      />
      {filteredAccounts.map((account) => (
        <Button
          key={account.ref}
          fluid
          disabled={account.is_operator}
          tooltip={
            account.is_operator
              ? 'You cannot modify your own account.'
              : undefined
          }
          color={
            account.is_operator
              ? 'label'
              : selected_account?.ref === account.ref
                ? 'good'
                : 'transparent'
          }
          onClick={() => act('PRG_select_account', { ref: account.ref })}
        >
          <Box bold inline>
            {account.name}
          </Box>
          {!!account.is_operator && <Icon name="user" ml={1} color="label" />}
          <Box color="label" fontSize="11px">
            {account.job}
          </Box>
        </Button>
      ))}
      {filteredAccounts.length === 0 && (
        <Box color="label" textAlign="center" mt={2}>
          No accounts found.
        </Box>
      )}
    </Section>
  );
};

const AccountManagementTab = () => {
  const { data } = useBackend<StationManagementData>();
  const { selected_account } = data;
  const [subTab, setSubTab] = useLocalState('subTab', 'job');

  if (!selected_account) {
    return (
      <Section fill>
        <Box color="label" textAlign="center" mt={4}>
          <Icon name="arrow-left" mr={1} />
          Select an account from the list.
        </Box>
      </Section>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <AccountHeader />
      </Stack.Item>

      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            selected={subTab === 'job'}
            onClick={() => setSubTab('job')}
          >
            Assignment
          </Tabs.Tab>
          <Tabs.Tab
            selected={subTab === 'access'}
            onClick={() => setSubTab('access')}
          >
            Access
          </Tabs.Tab>
          <Tabs.Tab
            selected={subTab === 'salary'}
            onClick={() => setSubTab('salary')}
          >
            Salary
          </Tabs.Tab>
          <Tabs.Tab
            selected={subTab === 'cardtrim'}
            onClick={() => setSubTab('cardtrim')}
          >
            Cards
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>

      <Stack.Item grow>
        {subTab === 'access' && <AccessSubTab />}
        {subTab === 'salary' && <SalarySubTab />}
        {subTab === 'job' && <JobAssignmentSubTab />}
        {subTab === 'cardtrim' && <CardTrimSubTab />}
      </Stack.Item>
    </Stack>
  );
};

const AccountHeader = () => {
  const { act, data } = useBackend<StationManagementData>();
  const { selected_account, has_change_ids } = data;

  if (!selected_account) return null;

  return (
    <Section>
      <Flex justify="space-between" align="center">
        <Flex.Item>
          <Box bold fontSize="14px">
            {selected_account.name}
            {!!selected_account.immutable && (
              <Box as="span" color="average" ml={1}>
                [LOCKED]
              </Box>
            )}
            {!!selected_account.suspended && (
              <Box as="span" color="bad" ml={1}>
                [SUSPENDED]
              </Box>
            )}
          </Box>
          <Box color="label">{selected_account.job}</Box>
        </Flex.Item>
        <Flex.Item>
          <Button icon="sync" onClick={() => act('PRG_sync')}>
            Sync Cards
          </Button>
          {!!has_change_ids && (
            <Button
              icon="pen"
              disabled={selected_account.immutable}
              onClick={() => act('PRG_rename_account')}
            >
              Rename
            </Button>
          )}
          <Button
            icon="user-times"
            color="bad"
            disabled={selected_account.immutable}
            onClick={() => act('PRG_fire')}
          >
            Fire
          </Button>
          {!!has_change_ids && (
            <Button
              icon="trash"
              color="bad"
              disabled={selected_account.immutable}
              onClick={() => act('PRG_delete_account')}
            >
              Delete
            </Button>
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const AccessSubTab = () => {
  const { act, data } = useBackend<StationManagementData>();
  const {
    regions = [],
    selected_account,
    has_change_ids,
    accessible_region_bitflag,
  } = data;

  if (!selected_account) return null;

  // Only show regions the user has authority over
  const visibleRegions = has_change_ids
    ? regions
    : regions.filter(
        (region) => (region.regid & accessible_region_bitflag) !== 0,
      );

  return (
    <AccessList
      accesses={visibleRegions}
      selectedList={selected_account.access || []}
      accessMod={(ref) => act('PRG_toggle_access', { access_target: ref })}
      grantAll={has_change_ids ? () => act('PRG_grant_all') : undefined}
      denyAll={has_change_ids ? () => act('PRG_revoke_all') : undefined}
      grantDep={(regid) => act('PRG_grant_dept', { dept_bitflag: regid })}
      denyDep={(regid) => act('PRG_revoke_dept', { dept_bitflag: regid })}
    />
  );
};

const SalarySubTab = () => {
  const { act, data } = useBackend<StationManagementData>();
  const { selected_account } = data;

  if (!selected_account) return null;

  const paymentData = selected_account.payment_data || [];

  return (
    <Section scrollable fill>
      <NoticeBox info>
        <b>Salary</b> is the recurring pay per cycle from the department budget.{' '}
        <b>Bonus</b> is a one-time adjustment applied next payday, then cleared.
        Negative values dock pay.
      </NoticeBox>
      <Table>
        <Table.Row header>
          <Table.Cell>Department</Table.Cell>
          <Table.Cell>Salary</Table.Cell>
          <Table.Cell>Bonus</Table.Cell>
        </Table.Row>
        {paymentData.map((entry) => (
          <Table.Row key={entry.dept_id}>
            <Table.Cell bold>{entry.dept_id}</Table.Cell>
            <Table.Cell>
              <NumberInput
                value={entry.payment}
                minValue={0}
                maxValue={500}
                step={5}
                width="80px"
                onChange={(value) =>
                  act('PRG_set_salary', {
                    dept_id: entry.dept_id,
                    value: value,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell>
              <NumberInput
                value={entry.bonus}
                minValue={-200}
                maxValue={500}
                step={5}
                width="80px"
                onChange={(value) =>
                  act('PRG_set_bonus', {
                    dept_id: entry.dept_id,
                    value: value,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const JobAssignmentSubTab = () => {
  const { act, data } = useBackend<StationManagementData>();
  const {
    job_groups = [],
    has_change_ids,
    accessible_region_bitflag,
    selected_account,
  } = data;

  const [customAssignment, setCustomAssignment] = useLocalState(
    'customAssignment',
    '',
  );

  // Only show departments the user can assign
  const visibleGroups = has_change_ids
    ? job_groups
    : job_groups.filter(
        (group) => (group.dept_bitflag & accessible_region_bitflag) !== 0,
      );

  const [selectedDept, setSelectedDept] = useLocalState(
    'jobDept',
    visibleGroups[0]?.department || '',
  );

  const currentGroup = visibleGroups.find(
    (group) => group.department === selectedDept,
  );

  return (
    <Section title="Job Assignment" fill>
      <NoticeBox info mb={1}>
        Current assignment: <b>{selected_account?.job || 'Unknown'}</b>
      </NoticeBox>
      <Section title="Custom Assignment" level={2} mb={1}>
        <Flex align="center">
          <Flex.Item grow={1} mr={1}>
            <Input
              fluid
              placeholder="Enter custom assignment title..."
              value={customAssignment}
              maxLength={42}
              onInput={(_event, value) => setCustomAssignment(value)}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="pen"
              disabled={!customAssignment || selected_account?.immutable}
              onClick={() => {
                act('PRG_set_custom_assignment', {
                  custom_title: customAssignment,
                });
                setCustomAssignment('');
              }}
            >
              Apply
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
      <Flex>
        <Flex.Item>
          <Tabs vertical>
            {visibleGroups.map((group) => (
              <Tabs.Tab
                key={group.department}
                selected={group.department === selectedDept}
                onClick={() => setSelectedDept(group.department)}
              >
                {group.department}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} ml={2}>
          {currentGroup?.jobs.map((job) => (
            <Button
              key={job.title}
              fluid
              icon="id-badge"
              onClick={() => act('PRG_set_job', { job_title: job.title })}
            >
              {job.title}
            </Button>
          ))}
          {!currentGroup && <Box color="label">Select a department.</Box>}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const CardTrimSubTab = () => {
  const { act, data } = useBackend<StationManagementData>();
  const {
    selected_account,
    trim_styles = [],
    has_change_ids,
    accessible_region_bitflag,
  } = data;

  const [selectedCard, setSelectedCard] = useLocalState<string | null>(
    'selectedCardRef',
    null,
  );
  const [selectedTrimDept, setSelectedTrimDept] = useLocalState(
    'trimStyleDept',
    '',
  );

  if (!selected_account) return null;

  const linkedCards = selected_account.linked_cards || [];

  // Filter to departments the user has authority over (Misc/bitflag 0 always visible)
  const visibleTrimGroups = has_change_ids
    ? trim_styles
    : trim_styles.filter(
        (group) =>
          group.dept_bitflag === 0 ||
          (group.dept_bitflag & accessible_region_bitflag) !== 0,
      );

  const activeCard =
    linkedCards.find((card) => card.ref === selectedCard) ||
    linkedCards[0] ||
    null;
  const activeDept =
    selectedTrimDept ||
    (visibleTrimGroups.length > 0 ? visibleTrimGroups[0].department : '');
  const currentTrimGroup = visibleTrimGroups.find(
    (group) => group.department === activeDept,
  );

  if (linkedCards.length === 0) {
    return (
      <Section fill>
        <Box color="label" textAlign="center" mt={4}>
          <Icon name="id-card" mr={1} />
          No linked cards found for this account.
        </Box>
      </Section>
    );
  }

  return (
    <Section fill scrollable>
      <Section title="Linked Cards" level={2}>
        <Flex wrap="wrap">
          {linkedCards.map((card) => (
            <Flex.Item key={card.ref} mr={1} mb={1}>
              <Button
                icon="id-card"
                selected={activeCard?.ref === card.ref}
                onClick={() => setSelectedCard(card.ref)}
              >
                {card.name} ({card.assignment})
              </Button>
            </Flex.Item>
          ))}
        </Flex>
        {activeCard && (
          <Flex mt={1} align="center" justify="space-between">
            <Flex.Item>
              <Box color="label" fontSize="11px">
                Current trim:{' '}
                <Box as="span" bold color="white">
                  {activeCard.icon_state}
                </Box>
                {' · '}
                Assignment:{' '}
                <Box as="span" bold color="white">
                  {activeCard.assignment}
                </Box>
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="trash"
                color="bad"
                disabled={selected_account.immutable}
                onClick={() =>
                  act('PRG_decommission_card', {
                    card_ref: activeCard.ref,
                  })
                }
              >
                Decommission
              </Button>
            </Flex.Item>
          </Flex>
        )}
      </Section>

      {activeCard && (
        <Section
          title="Apply Trim"
          level={2}
          mt={1}
          buttons={
            !!selected_account.immutable && (
              <Box color="average" fontSize="11px">
                Account is locked
              </Box>
            )
          }
        >
          <Flex>
            <Flex.Item>
              <Tabs vertical>
                {visibleTrimGroups.map((group) => (
                  <Tabs.Tab
                    key={group.department}
                    selected={group.department === activeDept}
                    onClick={() => setSelectedTrimDept(group.department)}
                  >
                    {group.department}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
            <Flex.Item grow={1} ml={2}>
              {currentTrimGroup?.trims.map((trim) => (
                <Button
                  key={trim.name}
                  fluid
                  icon="paint-brush"
                  disabled={selected_account.immutable}
                  color={
                    activeCard.icon_state === trim.icon_state
                      ? 'good'
                      : undefined
                  }
                  onClick={() =>
                    act('PRG_set_card_trim', {
                      card_ref: activeCard.ref,
                      trim_name: trim.name,
                    })
                  }
                >
                  {trim.name}
                  <Box as="span" color="label" ml={1} fontSize="11px">
                    ({trim.icon_state})
                  </Box>
                </Button>
              ))}
              {!currentTrimGroup && (
                <Box color="label">Select a department.</Box>
              )}
            </Flex.Item>
          </Flex>
        </Section>
      )}
    </Section>
  );
};

const JobSlotsTab = () => {
  const { act, data } = useBackend<StationManagementData>();
  const { slots = [], cooldown_remaining, cooldown_time } = data;

  return (
    <Section
      title="Job Slot Management"
      fill
      scrollable
      buttons={
        cooldown_remaining > 0 && (
          <Box color="label">
            Cooldown: {Math.ceil(cooldown_remaining)}s / {cooldown_time}s
          </Box>
        )
      }
    >
      {cooldown_remaining > 0 && (
        <NoticeBox>
          Job slot changes are on cooldown ({Math.ceil(cooldown_remaining)}s
          remaining).
        </NoticeBox>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>Job</Table.Cell>
          <Table.Cell textAlign="center">Filled / Total</Table.Cell>
          <Table.Cell textAlign="center">Open</Table.Cell>
          <Table.Cell textAlign="center">Close</Table.Cell>
          <Table.Cell textAlign="center">Priority</Table.Cell>
        </Table.Row>
        {slots.map((slot) => (
          <Table.Row key={slot.title}>
            <Table.Cell bold>{slot.title}</Table.Cell>
            <Table.Cell textAlign="center">
              {slot.current_positions} /{' '}
              {slot.total_positions < 0 ? '\u221E' : slot.total_positions}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <Button
                icon="plus"
                disabled={cooldown_remaining > 0 || slot.total_positions < 0}
                onClick={() => act('PRG_open_job', { job_title: slot.title })}
              />
            </Table.Cell>
            <Table.Cell textAlign="center">
              <Button
                icon="minus"
                disabled={cooldown_remaining > 0 || slot.total_positions <= 0}
                onClick={() => act('PRG_close_job', { job_title: slot.title })}
              />
            </Table.Cell>
            <Table.Cell textAlign="center">
              <Button
                icon="star"
                color={slot.is_prioritized ? 'good' : undefined}
                onClick={() =>
                  act('PRG_prioritize_job', { job_title: slot.title })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
