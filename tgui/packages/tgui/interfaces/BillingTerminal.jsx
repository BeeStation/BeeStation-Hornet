import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Section,
  Tabs,
} from 'tgui/components';
import { Dropdown, Input, Slider } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
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
  } = data;

  const [tabIndex, setTabIndex] = useLocalState('tab-index', 1);

  return (
    <Window width={700} height={800} scrollable>
      <Window.Content>
        <Flex direction="column" height="100%">
          {/* Console info */}
          <Flex.Item>
            <Section>
              <LabeledList.Item label="Department ID">
                {'' + account_id + ' ($' + account_amount + ')' ||
                  'No budget card inserted...'}
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
                {'Incoming Invoices (' + incoming_bills.length + ')'}{' '}
                <Icon name="envelope" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                {'Outgoing invoices (' + sent_bills.length + ')'}{' '}
                <Icon name="paper-plane" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 3}
                onClick={() => setTabIndex(3)}
              >
                {'Paid Invoices (' + paid_bills.length + ')'}{' '}
                <Icon name="receipt" />
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 4}
                onClick={() => setTabIndex(4)}
              >
                {'Drafted Invoices (' + drafted_bills.length + ')'}{' '}
                <Icon name="pencil" />
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>
          {/* Content body */}
          <Flex.Item grow>
            {tabIndex === 1 && <IncomingBills />}
            {tabIndex === 2 && <OutgoingBills />}
            {tabIndex === 3 && <PayedBills />}
            {tabIndex === 4 && <DraftedBills />}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const DraftedBills = (_props) => {
  const { act, data } = useBackend();
  const { drafted_bills, billables } = data;

  return (
    <Section
      scrollable
      title={'Drafts (' + drafted_bills.length + ')'}
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
              <Flex.Item key={bill}>
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
                      maxValue={1000}
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
  const { sent_bills } = data;

  return (
    <Section scrollable title={'Outgoing (' + sent_bills.length + ')'} fill>
      <Flex direction="column">
        {sent_bills
          ? sent_bills.map((bill) => (
              <Flex.Item key={bill}>
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
                      onClick={() => act('delete_draft', { ref: bill['ref'] })}
                    >
                      Delete <Icon name="trash-can" />
                    </Button>
                    <Button color="yellow">
                      Print <Icon name="print" />
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

const PayedBills = (_props) => {
  const { act, data } = useBackend();
  const { paid_bills } = data;

  return (
    <Section scrollable title={'Paid (' + paid_bills.length + ')'} fill>
      <Flex direction="column">
        {paid_bills
          ? paid_bills.map((bill) => (
              <Flex.Item key={bill}>
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
            ))
          : null}
      </Flex>
    </Section>
  );
};

const IncomingBills = (_props) => {
  const { act, data } = useBackend();
  const { incoming_bills } = data;

  return (
    <Section scrollable title={'Incoming (' + incoming_bills.length + ')'} fill>
      <Flex direction="column">
        {incoming_bills
          ? incoming_bills.map((bill) => (
              <Flex.Item key={bill}>
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
                    <Button.Checkbox tooltip="Does nothing">
                      Ignore
                    </Button.Checkbox>
                  </Box>
                </Section>
              </Flex.Item>
            ))
          : null}
      </Flex>
    </Section>
  );
};
