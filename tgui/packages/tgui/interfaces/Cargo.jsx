import { useBackend, useSharedState } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Collapsible,
  Flex,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const Cargo = (props) => {
  return (
    <Window width={1050} height={750}>
      <Window.Content>
        <CargoContent />
      </Window.Content>
    </Window>
  );
};

export const CargoContent = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useSharedState('tab', 'catalog');
  const { requestonly } = data;
  const cart = data.cart || [];
  const requests = data.requests || [];
  return (
    <Flex height="100%">
      {/* Left panel - main content */}
      <Flex.Item grow={1} basis={0} style={{ overflow: 'auto' }} mr={1}>
        <CargoStatus />
        <Section fitted>
          <Tabs>
            <Tabs.Tab
              icon="list"
              selected={tab === 'catalog'}
              onClick={() => setTab('catalog')}
            >
              Catalog
            </Tabs.Tab>
            <Tabs.Tab
              icon="envelope"
              textColor={tab !== 'requests' && requests.length > 0 && 'yellow'}
              selected={tab === 'requests'}
              onClick={() => setTab('requests')}
            >
              Requests ({requests.length})
            </Tabs.Tab>
            {!requestonly && (
              <Tabs.Tab
                icon="shopping-cart"
                textColor={tab !== 'cart' && cart.length > 0 && 'yellow'}
                selected={tab === 'cart'}
                onClick={() => setTab('cart')}
              >
                Orders ({cart.length})
              </Tabs.Tab>
            )}
          </Tabs>
        </Section>
        {tab === 'catalog' && <CargoCatalog />}
        {tab === 'requests' && <CargoRequests />}
        {tab === 'cart' && <CargoCart />}
      </Flex.Item>
      {/* Right panel - batch cart */}
      <Flex.Item
        basis="320px"
        shrink={0}
        style={{ overflow: 'auto' }}
      >
        <BatchPanel />
      </Flex.Item>
    </Flex>
  );
};

const CargoStatus = (props) => {
  const { act, data } = useBackend();
  const {
    away,
    docked,
    loan,
    loan_dispatched,
    location,
    message,
    points,
    requestonly,
    can_send,
  } = data;
  return (
    <Section
      title="Cargo"
      buttons={
        <Box fontFamily="verdana" inline bold>
          <AnimatedNumber
            value={points}
            format={(value) => formatMoney(value)}
          />
          {' credits'}
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Shuttle">
          {(docked && !requestonly && can_send && (
            <Button content={location} onClick={() => act('send')} />
          )) ||
            location}
        </LabeledList.Item>
        <LabeledList.Item label="CentCom Message">{message}</LabeledList.Item>
        {!!loan && !requestonly && (
          <LabeledList.Item label="Loan">
            {(!loan_dispatched && (
              <Button
                content="Loan Shuttle"
                disabled={!(away && docked)}
                onClick={() => act('loan')}
              />
            )) || <Box color="bad">Loaned to Centcom</Box>}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const CargoCatalog = (props) => {
  const { express, canOrder = true } = props;
  const { act, data } = useBackend();
  const { self_paid, app_cost, points } = data;
  const supplies = Object.values(data.supplies);
  const [activeSupplyName, setActiveSupplyName] = useSharedState(
    'supply',
    supplies[0]?.name,
  );
  const activeSupply = supplies.find((supply) => {
    return supply.name === activeSupplyName;
  });
  return (
    <Section
      title="Catalog"
      buttons={
        !express && (
          <>
            <CargoCartButtons />
            <Button.Checkbox
              ml={2}
              content="Buy Privately"
              checked={self_paid}
              onClick={() => act('toggleprivate')}
            />
          </>
        )
      }
    >
      <Flex>
        <Flex.Item ml={-1} mr={1}>
          <Tabs vertical>
            {supplies.map((supply) => (
              <Tabs.Tab
                key={supply.name}
                selected={supply.name === activeSupplyName}
                onClick={() => setActiveSupplyName(supply.name)}
              >
                {supply.name} ({supply.packs.length})
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <Table>
            {activeSupply?.packs.map((pack) => {
              const tags = [];
              if (pack.small_item) {
                tags.push('Small');
              }
              if (pack.access) {
                tags.push('Restricted');
              }
              return (
                <Table.Row key={pack.name} className="candystripe">
                  <Table.Cell>{pack.name}</Table.Cell>
                  <Table.Cell collapsing color="label" textAlign="right">
                    {tags.join(', ')}
                  </Table.Cell>
                  <Table.Cell collapsing color="label" textAlign="right">
                    Stock: {pack.supply}
                  </Table.Cell>
                  <Table.Cell collapsing textAlign="right">
                    <Button
                      fontFamily="verdana"
                      fluid
                      icon={express ? 'add' : 'cart-plus'}
                      tooltip={pack.desc}
                      tooltipPosition="left"
                      disabled={
                        !canOrder ||
                        (express &&
                          points &&
                          points < pack.cost &&
                          pack.supply > 0)
                      }
                      onClick={() =>
                        act(express ? 'add' : 'batch_add', {
                          id: pack.id,
                        })
                      }
                    >
                      {formatMoney(
                        self_paid || app_cost
                          ? Math.round(pack.cost * 1.1)
                          : pack.cost,
                      )}
                      {' cr'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const CargoRequests = (props) => {
  const { act, data } = useBackend();
  const { requestonly, can_send, can_approve_requests } = data;
  const requests = data.requests || [];
  // Labeled list reimplementation to squeeze extra columns out of it
  return (
    <Section
      title="Active Requests"
      buttons={
        !requestonly && (
          <Button
            icon="times"
            content="Clear"
            color="transparent"
            onClick={() => act('denyall')}
          />
        )
      }
    >
      {requests.length === 0 && <Box color="good">No Requests</Box>}
      {requests.length > 0 && (
        <Table>
          {requests.map((request) => (
            <RequestEntry
              key={request.id}
              request={request}
              requestonly={requestonly}
              can_send={can_send}
              can_approve_requests={can_approve_requests}
            />
          ))}
        </Table>
      )}
    </Section>
  );
};

const RequestEntry = (props) => {
  const { act } = useBackend();
  const { request, requestonly, can_send, can_approve_requests } = props;
  const [expanded, setExpanded] = useSharedState(
    'req_expand_' + request.id,
    false,
  );
  const contents = request.contents || [];
  return (
    <>
      <Table.Row key={request.id} className="candystripe">
        <Table.Cell collapsing>
          {contents.length > 0 && (
            <Button
              icon={expanded ? 'chevron-down' : 'chevron-right'}
              color="transparent"
              compact
              onClick={() => setExpanded(!expanded)}
            />
          )}
        </Table.Cell>
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
        <Table.Cell fontFamily="verdana" collapsing textAlign="right">
          Stock: {request.supply}
        </Table.Cell>
        {(!requestonly || can_send) && can_approve_requests && (
          <Table.Cell collapsing>
            <Button
              icon="check"
              color="good"
              onClick={() =>
                act('approve', {
                  id: request.id,
                })
              }
            />
            <Button
              icon="times"
              color="bad"
              onClick={() =>
                act('deny', {
                  id: request.id,
                })
              }
            />
          </Table.Cell>
        )}
      </Table.Row>
      {expanded &&
        contents.map((item, idx) => (
          <Table.Row key={request.id + '_c_' + idx}>
            <Table.Cell collapsing />
            <Table.Cell collapsing />
            <Table.Cell
              colSpan={6}
              color="label"
              style={{ paddingLeft: '1.5em' }}
            >
              • {item}
            </Table.Cell>
          </Table.Row>
        ))}
    </>
  );
};

const CargoCartButtons = (props) => {
  const { act, data } = useBackend();
  const { requestonly, can_send, can_approve_requests } = data;
  const cart = data.cart || [];
  const total = cart.reduce((total, entry) => total + entry.cost, 0);
  if (requestonly || !can_send || !can_approve_requests) {
    return null;
  }
  return (
    <>
      <Box inline mx={1}>
        {cart.length === 0 && 'Cart is empty'}
        {cart.length === 1 && '1 item'}
        {cart.length >= 2 && cart.length + ' items'}{' '}
        {total > 0 && `(${formatMoney(total)} cr)`}
      </Box>
      <Button
        icon="times"
        color="transparent"
        content="Clear"
        onClick={() => act('clear')}
      />
    </>
  );
};

const CargoCart = (props) => {
  const { act, data } = useBackend();
  const { requestonly, away, docked, location, can_send } = data;
  const cart = data.cart || [];
  return (
    <Section title="Current Orders" buttons={<CargoCartButtons />}>
      {cart.length === 0 && <Box color="label">No orders placed</Box>}
      {cart.length > 0 && (
        <Table>
          {cart.map((entry) => (
            <CartEntry key={entry.id} entry={entry} can_send={can_send} />
          ))}
        </Table>
      )}
      {cart.length > 0 && !requestonly && (
        <Box mt={2}>
          {(away === 1 && docked === 1 && (
            <Button
              color="green"
              style={{
                lineHeight: '28px',
                padding: '0 12px',
              }}
              content="Confirm the order"
              onClick={() => act('send')}
            />
          )) || <Box opacity={0.5}>Shuttle in {location}.</Box>}
        </Box>
      )}
    </Section>
  );
};

const CartEntry = (props) => {
  const { act } = useBackend();
  const { entry, can_send } = props;
  const [expanded, setExpanded] = useSharedState(
    'cart_expand_' + entry.id,
    false,
  );
  const contents = entry.contents || [];
  return (
    <>
      <Table.Row key={entry.id} className="candystripe">
        <Table.Cell collapsing>
          {contents.length > 0 && (
            <Button
              icon={expanded ? 'chevron-down' : 'chevron-right'}
              color="transparent"
              compact
              onClick={() => setExpanded(!expanded)}
            />
          )}
        </Table.Cell>
        <Table.Cell collapsing color="label">
          #{entry.id}
        </Table.Cell>
        <Table.Cell>{entry.object}</Table.Cell>
        <Table.Cell collapsing>
          {!!entry.paid && <b>[Paid Privately]</b>}
        </Table.Cell>
        <Table.Cell fontFamily="verdana" collapsing textAlign="right">
          {formatMoney(entry.cost)} cr
        </Table.Cell>
        <Table.Cell fontFamily="verdana" collapsing textAlign="right">
          Stock: {entry.supply}
        </Table.Cell>
        <Table.Cell collapsing>
          {can_send && (
            <Button
              icon="minus"
              onClick={() =>
                act('remove', {
                  id: entry.id,
                })
              }
            />
          )}
        </Table.Cell>
      </Table.Row>
      {expanded &&
        contents.map((item, idx) => (
          <Table.Row key={entry.id + '_c_' + idx}>
            <Table.Cell collapsing />
            <Table.Cell collapsing />
            <Table.Cell
              colSpan={5}
              color="label"
              style={{ paddingLeft: '1.5em' }}
            >
              • {item}
            </Table.Cell>
          </Table.Row>
        ))}
    </>
  );
};

const BatchPanel = (props) => {
  const { act, data } = useBackend();
  const [batchTab, setBatchTab] = useSharedState('batchTab', 'items');
  const batch = data.batch || {};
  const batchItems = batch.items || [];
  const totalCost = batch.total_cost || 0;
  const itemCount = batch.item_count || 0;
  const crates = batch.crates || [];
  const { requestonly } = data;

  return (
    <Section
      title="Batch Order"
      fill
      buttons={
        <Button
          icon="trash"
          color="transparent"
          disabled={batchItems.length === 0}
          tooltip="Clear batch"
          onClick={() => act('batch_clear')}
        />
      }
    >
      <Tabs>
        <Tabs.Tab
          icon="boxes-stacked"
          selected={batchTab === 'items'}
          onClick={() => setBatchTab('items')}
        >
          Items ({itemCount})
        </Tabs.Tab>
        <Tabs.Tab
          icon="box"
          selected={batchTab === 'crates'}
          onClick={() => setBatchTab('crates')}
        >
          Crates ({crates.length})
        </Tabs.Tab>
      </Tabs>
      {batchTab === 'items' && <BatchItemsList />}
      {batchTab === 'crates' && <BatchCrateReadout />}
      {batchItems.length > 0 && (
        <Box mt={2}>
          <Box
            fontFamily="verdana"
            bold
            textAlign="center"
            mb={1}
            fontSize="14px"
          >
            Total: {formatMoney(totalCost)} cr ({itemCount}{' '}
            {itemCount === 1 ? 'item' : 'items'})
          </Box>
          <Button
            fluid
            color="green"
            icon="check"
            textAlign="center"
            style={{
              lineHeight: '28px',
              padding: '0 12px',
            }}
            content={requestonly ? 'Submit Request' : 'Confirm Batch Order'}
            onClick={() => act('batch_confirm')}
          />
        </Box>
      )}
    </Section>
  );
};

const BatchItemsList = (props) => {
  const { act, data } = useBackend();
  const batch = data.batch || {};
  const batchItems = batch.items || [];

  if (batchItems.length === 0) {
    return (
      <Box color="label" textAlign="center" mt={2}>
        Add items from the catalog to build a batch order.
      </Box>
    );
  }

  return (
    <Table>
      {batchItems.map((item) => (
        <Table.Row key={item.pack_id} className="candystripe">
          <Table.Cell>{item.name}</Table.Cell>
          <Table.Cell collapsing textAlign="center">
            <Stack align="center" inline>
              <Stack.Item>
                <Button
                  icon="minus"
                  compact
                  onClick={() =>
                    act('batch_remove', {
                      id: item.pack_id,
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item
                fontFamily="verdana"
                bold
                style={{
                  minWidth: '24px',
                  textAlign: 'center',
                }}
              >
                {item.quantity}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="plus"
                  compact
                  onClick={() =>
                    act('batch_add', {
                      id: item.pack_id,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          </Table.Cell>
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            {formatMoney(item.entry_cost)} cr
          </Table.Cell>
          <Table.Cell collapsing>
            <Button
              icon="times"
              color="bad"
              compact
              onClick={() =>
                act('batch_remove_all', {
                  id: item.pack_id,
                })
              }
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

const BatchCrateReadout = (props) => {
  const { data } = useBackend();
  const batch = data.batch || {};
  const crates = batch.crates || [];

  if (crates.length === 0) {
    return (
      <Box color="label" textAlign="center" mt={2}>
        No crates to display. Add items to the batch first.
      </Box>
    );
  }

  return (
    <Box>
      {crates.map((crate, idx) => (
        <Collapsible
          key={idx}
          title={crate.crate_name + ' (' + crate.count + ')'}
          color="transparent"
        >
          <Box ml={2}>
            {crate.contents.map((item, cidx) => (
              <Box key={cidx} color="label">
                • {item}
              </Box>
            ))}
          </Box>
        </Collapsible>
      ))}
    </Box>
  );
};
