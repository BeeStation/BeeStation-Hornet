import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Section,
  Tabs,
} from 'tgui/components';
import { Collapsible, Dropdown, Input, Slider } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const BillingTerminal = (props) => {
  const { act, data } = useBackend();
  const {
    incoming_bills,
    account_id,
    server_id,
    drafted_bills,
    sent_bills,
    paid_bills,
    account_amount,
    bill_filters,
    bill_filter,
    show_ignored,
    autopay_filter,
    agents,
    settings,
  } = data;

  const [tabIndex, setTabIndex] = useState(1);
  const [autoMenu, setAutoMenu] = useState('', 0);

  return (
    <Window width={950} height={800} scrollable>
      <Window.Content>
        <Flex direction="column" height="100%">
          {/* Console info */}
          <Flex.Item>
            <Section>
              <LabeledList.Item label="Department ID">
                {account_id
                  ? '' + account_id + ' ($' + account_amount + ')'
                  : 'No budget card inserted...'}
              </LabeledList.Item>
              <LabeledList.Item label="Linked Server">
                {server_id || 'No server linked...'}
              </LabeledList.Item>
            </Section>
          </Flex.Item>
          {/* Menu tabs */}
          <Flex.Item>
            <Tabs>
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                {'Incoming Invoices (' + incoming_bills?.length + ')'}{' '}
                <Icon name="envelope" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                {'Outgoing invoices (' + sent_bills?.length + ')'}{' '}
                <Icon name="paper-plane" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 3}
                onClick={() => setTabIndex(3)}
              >
                {'Paid Invoices (' + paid_bills?.length + ')'}{' '}
                <Icon name="receipt" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 4}
                onClick={() => setTabIndex(4)}
              >
                {'Drafted Invoices (' + drafted_bills?.length + ')'}{' '}
                <Icon name="pencil" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 5}
                onClick={() => setTabIndex(5)}
              >
                {'Agents (' + agents?.length + ')'} <Icon name="robot" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 6}
                onClick={() => setTabIndex(6)}
              >
                {'Settings (' + settings?.length + ')'} <Icon name="gear" />
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          {/* Filters */}
          <Flex.Item>
            <Section my={0.3}>
              <Flex>
                <Flex.Item grow>
                  {Object.entries(bill_filters).map(([key, value]) => (
                    <Button.Checkbox
                      key={key}
                      checked={
                        autoMenu ? autopay_filter & value : bill_filter & value
                      }
                      onClick={() =>
                        !autoMenu
                          ? act('toggle_filter', { filter: value })
                          : act('toggle_autopay', { filter: value })
                      }
                    >
                      {key}
                    </Button.Checkbox>
                  ))}
                </Flex.Item>
                <Flex.Item>
                  <Button.Checkbox
                    checked={show_ignored}
                    onClick={() => act('toggle_ignore_filter')}
                  >
                    Ignored
                  </Button.Checkbox>
                  <Button
                    icon={autoMenu ? 'robot' : 'filter'}
                    tooltip={
                      !autoMenu ? 'Invoice Filters' : 'Automated Payments'
                    }
                    color={!autoMenu ? '' : 'red'}
                    onClick={() => setAutoMenu(!autoMenu)}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          {/* Search */}
          <Flex.Item>
            <Input
              m={0.2}
              fluid
              placeholder={'This search doesnt work lol. Use ctrl+f for now.'}
            />
          </Flex.Item>
          {/* Content body */}
          <Flex.Item grow>
            {tabIndex === 1 && <IncomingBills />}
            {tabIndex === 2 && <OutgoingBills />}
            {tabIndex === 3 && <PayedBills />}
            {tabIndex === 4 && <DraftedBills />}
            {tabIndex === 5 && <ManageAgents />}
            {tabIndex === 6 && <Settings />}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Settings = (_props) => {
  const { act, data } = useBackend();
  const { settings } = data;

  return (
    <Section scrollable title={'Settings (' + settings?.length + ')'} fill>
      {settings
        ? settings.map((setting) => (
            <Section key={setting['ui_type']} title={setting['name']} m={0.1}>
              {setting['desc'] ? (
                <LabeledList.Item label="Description">
                  {setting['desc']}
                </LabeledList.Item>
              ) : null}
              {setting['ui_type'] === 'BILLING_SETTING_TYPE_NUMBERS' ? (
                <SettingDataNumber
                  key={setting['ui_type']}
                  number={setting['number']}
                  low={setting['lower']}
                  high={setting['upper']}
                  step={setting['step']}
                  set_ref={setting['ref']}
                />
              ) : (
                'No data structure for ' + setting['ui_type']
              )}
            </Section>
          ))
        : null}
    </Section>
  );
};

const SettingDataNumber = (_props) => {
  const { act, data } = useBackend();
  const { number, low, high, step, set_ref } = _props;

  return (
    <Box fill>
      <LabeledList.Item label="Upper">{high}</LabeledList.Item>
      <LabeledList.Item label="Lower">{low}</LabeledList.Item>
      <Slider
        value={number}
        minValue={low}
        maxValue={high}
        step={step || 1}
        onDrag={(e, value) => {
          act('set_setting_number', {
            ref: set_ref,
            amount: value,
          });
        }}
      />
    </Box>
  );
};

const ManageAgents = (_props) => {
  const { act, data } = useBackend();
  const { sent_bills, bill_filter, show_ignored, ignored_bills, agents } = data;

  return (
    <Section scrollable title={'Agents (' + agents?.length + ')'} fill>
      <Flex direction="column">
        {agents
          ? agents.map((agent) =>
              agent['tags'] & bill_filter || !bill_filter ? (
                <Section
                  m={0.1}
                  title={'' + agent['agent_name'] + ' (' + agent['name'] + ')'}
                  key={agent['ref']}
                  buttons={
                    <Button
                      color={agent['disabled'] ? 'green' : 'red'}
                      onClick={() => act('toggle_agent', { ref: agent['ref'] })}
                    >
                      {agent['disabled'] ? 'Enable' : ' Disable'}
                    </Button>
                  }
                >
                  {agent['desc'] ? (
                    <LabeledList.Item label="Description">
                      {agent['desc']}
                    </LabeledList.Item>
                  ) : null}
                  <LabeledList.Item label="Status">
                    {agent['disabled'] ? 'Disabled' : 'Enabled'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Generated Bills">
                    {agent['total_bills']}
                  </LabeledList.Item>
                  <LabeledList.Item label="Collected Credits">
                    {'$' + agent['income']}
                  </LabeledList.Item>
                  <Collapsible title="Generated Bills">
                    <ManualEntries bill_list={agent['bills']} />
                  </Collapsible>
                </Section>
              ) : null,
            )
          : null}
      </Flex>
    </Section>
  );
};

const ManualEntries = (_props) => {
  const { act, data } = useBackend();
  const { bill_list } = _props;

  return (
    <Flex direction="column">
      {bill_list
        ? bill_list.map((bill) => (
            <Section m={0.2} key={bill['ref']}>
              {/* Data */}
              <LabeledList.Item label="To">{bill['to_whom']}</LabeledList.Item>
              <LabeledList.Item label="Title">{bill['title']}</LabeledList.Item>
              <LabeledList.Item label="Body">{bill['body']}</LabeledList.Item>
              <LabeledList.Item label="Amount">
                ${bill['amount']}
              </LabeledList.Item>
              <LabeledList.Item label="Status">
                {bill['paid'] ? 'Paid' : 'Unpaid'}
              </LabeledList.Item>
              <LabeledList.Item label="Recieved">
                {bill['sent_when']}
              </LabeledList.Item>
              {/* Buttons */}
              <Box mx={1}>
                <Button color="yellow">
                  Print <Icon name="print" />
                </Button>
              </Box>
            </Section>
          ))
        : null}
    </Flex>
  );
};

const DraftedBills = (_props) => {
  const { act, data } = useBackend();
  const { drafted_bills, billables } = data;

  return (
    <Section
      scrollable
      title={'Drafts (' + drafted_bills?.length + ')'}
      fill
      buttons={
        <Button color="green" onClick={() => act('new_draft')}>
          New Draft <Icon name="pencil" />
        </Button>
      }
    >
      <Flex direction="column">
        {drafted_bills
          ? drafted_bills.map((bill) => (
              <Flex.Item key={bill['ref']}>
                <Section mx={0.2} my={0.5}>
                  {/* Data */}
                  <LabeledList.Item label="To">
                    <Dropdown
                      selected={bill['to_whom']}
                      options={billables}
                      onSelected={(value) =>
                        act('set_draft_whom', {
                          ref: bill['ref'],
                          target: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Title">
                    <Input
                      fluid
                      value={bill['title']}
                      onInput={(e, value) => {
                        act('set_draft_title', {
                          ref: bill['ref'],
                          title: value,
                        });
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Body">
                    <Input
                      fluid
                      value={bill['body']}
                      onInput={(e, value) => {
                        act('set_draft_body', {
                          ref: bill['ref'],
                          body: value,
                        });
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Amount" inline>
                    <Slider
                      value={bill['amount'] || 1}
                      minValue={1}
                      maxValue={10000}
                      step={1}
                      format={(value) => '$' + value}
                      onDrag={(e, value) => {
                        act('set_draft_amount', {
                          ref: bill['ref'],
                          amount: value,
                        });
                      }}
                    >
                      ${bill['amount'] || '0'}
                    </Slider>
                  </LabeledList.Item>
                  {/* Buttons */}
                  <Box mx={1}>
                    <Button
                      color="green"
                      onClick={() => act('send_draft', { ref: bill['ref'] })}
                    >
                      Send <Icon name="paper-plane" />
                    </Button>
                    <Button
                      color="red"
                      onClick={() => act('delete_draft', { ref: bill['ref'] })}
                    >
                      Delete <Icon name="trash-can" />
                    </Button>
                  </Box>
                </Section>
              </Flex.Item>
            ))
          : null}
      </Flex>
    </Section>
  );
};

const OutgoingBills = (_props) => {
  const { act, data } = useBackend();
  const { sent_bills, bill_filter, show_ignored, ignored_bills } = data;

  return (
    <Section scrollable title={'Outgoing (' + sent_bills?.length + ')'} fill>
      <Flex direction="column">
        {sent_bills
          ? sent_bills.map((bill) =>
              bill['tags'] & bill_filter || !bill_filter ? (
                !!show_ignored ===
                  Object.values(ignored_bills).includes(bill['ref']) ||
                !Object.values(ignored_bills).includes(bill['ref']) ? (
                  <Flex.Item key={bill['ref']}>
                    <Section mx={0.2} my={0.5}>
                      {/* Data */}
                      <LabeledList.Item label="To">
                        {bill['to_whom']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Title">
                        {bill['title']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Body">
                        {bill['body']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Amount">
                        ${bill['amount']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Status">
                        {bill['paid'] ? 'Paid' : 'Unpaid'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Sent">
                        {bill['sent_when']}
                      </LabeledList.Item>
                      {/* Buttons */}
                      <Box mx={1}>
                        <Button
                          color="red"
                          disabled={bill['paid'] || !bill['can_delete']}
                          tooltip={
                            bill['can_delete']
                              ? null
                              : 'This bill cannot be deleted.'
                          }
                          onClick={() =>
                            act('delete_draft', { ref: bill['ref'] })
                          }
                        >
                          Delete <Icon name="trash-can" />
                        </Button>
                        <Button color="yellow">
                          Print <Icon name="print" />
                        </Button>
                      </Box>
                    </Section>
                  </Flex.Item>
                ) : null
              ) : null,
            )
          : null}
      </Flex>
    </Section>
  );
};

const PayedBills = (_props) => {
  const { act, data } = useBackend();
  const { paid_bills, bill_filter, ignored_bills, show_ignored } = data;

  return (
    <Section scrollable title={'Paid (' + paid_bills?.length + ')'} fill>
      <Flex direction="column">
        {paid_bills
          ? paid_bills.map((bill) =>
              bill['tags'] & bill_filter || !bill_filter ? (
                !!show_ignored ===
                  Object.values(ignored_bills).includes(bill['ref']) ||
                !Object.values(ignored_bills).includes(bill['ref']) ? (
                  <Flex.Item key={bill['ref']}>
                    <Section mx={0.2} my={0.5}>
                      {/* Data */}
                      <LabeledList.Item label="From">
                        {bill['from']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Title">
                        {bill['title']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Body">
                        {bill['body']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Amount">
                        ${bill['amount']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Status">
                        {bill['paid'] ? 'Paid' : 'Unpaid'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Recieved">
                        {bill['sent_when']}
                      </LabeledList.Item>
                      {/* Buttons */}
                      <Box mx={1}>
                        <Button color="yellow">
                          Print <Icon name="print" />
                        </Button>
                      </Box>
                    </Section>
                  </Flex.Item>
                ) : null
              ) : null,
            )
          : null}
      </Flex>
    </Section>
  );
};

const IncomingBills = (_props) => {
  const { act, data } = useBackend();
  const { incoming_bills, bill_filter, ignored_bills, show_ignored } = data;

  return (
    <Section
      scrollable
      title={'Incoming (' + incoming_bills?.length + ')'}
      fill
    >
      <Flex direction="column">
        {incoming_bills
          ? incoming_bills.map((bill) =>
              bill['tags'] & bill_filter || !bill_filter ? (
                !!show_ignored ===
                  Object.values(ignored_bills).includes(bill['ref']) ||
                !Object.values(ignored_bills).includes(bill['ref']) ? (
                  <Flex.Item key={bill['ref']}>
                    <Section mx={0.2} my={0.5} key={bill['ref']}>
                      {/* Data */}
                      <LabeledList.Item label="From">
                        {bill['from']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Title">
                        {bill['title']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Body">
                        {bill['body']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Amount">
                        ${bill['amount']}
                      </LabeledList.Item>
                      <LabeledList.Item label="Status">
                        {bill['paid'] ? 'Paid' : 'Unpaid'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Recieved">
                        {bill['sent_when']}
                      </LabeledList.Item>
                      {/* Buttons */}
                      <Box mx={1}>
                        <Button.Confirm
                          color="green"
                          content="Pay "
                          confirmContent="Confirm "
                          onClick={() => act('pay_bill', { ref: bill['ref'] })}
                        >
                          <Icon name="dollar" />
                        </Button.Confirm>
                        <Button color="yellow">
                          Print <Icon name="print" />
                        </Button>
                        <Button.Checkbox
                          checked={Object.values(ignored_bills).includes(
                            bill['ref'],
                          )}
                          onClick={() =>
                            act('toggle_ignore', { ref: bill['ref'] })
                          }
                        >
                          Ignore
                        </Button.Checkbox>
                      </Box>
                    </Section>
                  </Flex.Item>
                ) : null
              ) : null,
            )
          : null}
      </Flex>
    </Section>
  );
};
