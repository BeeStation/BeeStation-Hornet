import { useBackend, useSharedState } from '../backend';
import { Box, Tabs, Section, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, ProgressBar, Flex, Divider, Table } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const XenoartifactConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'listings');
  const { stability, money, purchase_radio, solved_radio, current_tab } = data;
  const sellers = data.sellers || [];
  return (
    <Window width={888} height={500}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <b>{`Research Budget: ${money} credits`}</b>
            </Flex.Item>
            <Flex.Item ml={'auto'}>
              <Button
                icon={'microphone'}
                color={purchase_radio ? 'green' : 'red'}
                tooltip={'Toggle Purchase Radio'}
                onClick={() => act('toggle_purchase_audio')}
              />
              <Button
                icon={'microphone'}
                color={solved_radio ? 'green' : 'red'}
                tooltip={'Toggle Solve Radio'}
                onClick={() => act('toggle_solved_audio')}
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Divider />
        <Tabs>
          <Tabs.Tab onClick={() => setTab('listings')} selected={tab === 'listings'}>
            <Icon name="shopping-cart" /> Listings
          </Tabs.Tab>
          <Tabs.Tab onClick={() => setTab('requests')} selected={tab === 'requests'}>
            <Icon name="list" /> Requests
          </Tabs.Tab>
          <Tabs.Tab onClick={() => setTab('history')} selected={tab === 'history'}>
            <Icon name="search" /> History
          </Tabs.Tab>
        </Tabs>
        <Divider />
        {tab === 'listings' && <XenoartifactConsoleSellerTab />}
        {tab === 'requests' && <XenoartifactConsoleRequestsTab />}
        {tab === 'history' && <XenoartifactConsoleHistoryTab />}
      </Window.Content>
    </Window>
  );
};

const XenoartifactConsoleSellerTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { stability, money, purchase_radio, solved_radio, current_tab } = data;
  const sellers = data.sellers || [];
  return (
    <Flex wrap={'wrap'}>
      {sellers.map((value) => (
        <XenoartifactConsoleSellerEntry value={value} key={value} />
      ))}
    </Flex>
  );
};

const XenoartifactConsoleSellerEntry = (props, context) => {
  const { act } = useBackend(context);
  const { value } = props;
  const stock = value['stock'] || [];
  return (
    <Flex.Item ml={1} my={0.5}>
      <Section title={`${value['name']}`} px={2} py={1} independant>
        <BlockQuote>{`${value['dialogue']}`}</BlockQuote>
        <Divider />
        {stock.map((stock_list) => (
          <Section
            title={`${stock_list['name']}`}
            mx={5}
            independant
            buttons={
              <Button
                icon={'shopping-cart'}
                onClick={() => act(`stock_purchase`, { item_id: stock_list['id'], seller_id: value['id'] })}>
                {`$${stock_list['cost']}`}
              </Button>
            }
            key={stock_list}>
            <BlockQuote>{`${stock_list['description']}`}</BlockQuote>
            <Divider />
          </Section>
        ))}
      </Section>
    </Flex.Item>
  );
};

const XenoartifactConsoleRequestsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const requests = data.active_request || [];
  return (
    <Table>
      {requests.map((request) => (
        <Table.Row key={request.id} className="candystripe">
          <Table.Cell collapsing color="label">
            #{request.id}
          </Table.Cell>
          <Table.Cell>{request.object}</Table.Cell>
          <Table.Cell>
            <b>{request.orderer}</b>
          </Table.Cell>
          <Table.Cell width="25%">
            <i>{request.reason}</i>
          </Table.Cell>
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            {formatMoney(request.cost)} cr
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const XenoartifactConsoleHistoryTab = (props, context) => {
  const { act, data } = useBackend(context);
  const history = data.history || [];
  return (
    <Flex wrap={'wrap'}>
      {history.map((value) => (
        <BlockQuote key={value} fontSize={1.2}>
          {value}
        </BlockQuote>
      ))}
    </Flex>
  );
};
