import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Collapsible,
  Flex,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

// --- Constants ---

const MIN_SEARCH_LENGTH = 2;
const DEBUG_SEARCH_KEYWORD = '@everything';

/** Threshold ratios for crate fill efficiency labels. */
const CRATE_FILL_GOOD = 0.8;
const CRATE_FILL_FAIR = 0.4;

/** Shared inline styles extracted to avoid re-creation on every render. */
const STYLES = {
  leftPanel: {
    display: 'flex',
    flexDirection: 'column',
    overflow: 'hidden',
  },
  contentArea: {
    flexGrow: 1,
    overflow: 'hidden',
    height: '100%',
  },
  rightPanel: {
    overflow: 'auto',
  },
  scrollable: {
    overflow: 'auto',
  },
  confirmButton: {
    lineHeight: '28px',
    padding: '0 12px',
  },
  pricingSummary: {
    background: 'rgba(0,0,0,0.2)',
    padding: '6px 8px',
    borderRadius: '3px',
  },
  quantityDisplay: {
    minWidth: '24px',
    textAlign: 'center',
  },
  expandedRow: {
    paddingLeft: '1.5em',
  },
};

// --- Helpers ---

/** Returns a simple plural suffix: "1 crate" vs "2 crates". */
const pluralize = (count, singular, plural) =>
  `${count} ${count === 1 ? singular : plural || singular + 's'}`;

/**
 * Returns a crate fill efficiency label and color based on slot usage ratio.
 */
const getCrateFillInfo = (slotsUsed, maxSlots) => {
  const ratio = slotsUsed / maxSlots;
  if (ratio >= CRATE_FILL_GOOD) {
    return { label: 'Efficient', color: 'good' };
  }
  if (ratio >= CRATE_FILL_FAIR) {
    return { label: 'Fair', color: 'average' };
  }
  return { label: 'Wasteful', color: 'bad' };
};

/**
 * Renders a batch order summary (crate/item counts) used in both
 * RequestEntry and CartEntry.
 */
const BatchLabel = ({ object, crateCount, totalItems }) => (
  <Box>
    <Box bold color="good">
      {object}
    </Box>
    <Box color="label" fontSize="11px">
      {pluralize(crateCount, 'crate')} &bull; {pluralize(totalItems, 'item')}
    </Box>
  </Box>
);

/**
 * Renders the expandable content rows for batch order details, shared by
 * RequestEntry and CartEntry.
 */
const ExpandedContentsRows = ({ parentId, contents, colSpan }) =>
  contents.map((item, idx) => (
    <Table.Row key={`${parentId}_c_${idx}`}>
      <Table.Cell collapsing />
      <Table.Cell collapsing />
      <Table.Cell colSpan={colSpan} color="label" style={STYLES.expandedRow}>
        • {item}
      </Table.Cell>
    </Table.Row>
  ));

// --- Components ---

export const Cargo = () => {
  return (
    <Window width={1050} height={750}>
      <Window.Content>
        <CargoContent />
      </Window.Content>
    </Window>
  );
};

export const CargoContent = () => {
  const { data } = useBackend();
  const [tab, setTab] = useSharedState('tab', 'catalog');
  const { requestonly } = data;
  const cart = data.cart || [];
  const requests = data.requests || [];
  return (
    <Flex height="100%">
      {/* Left panel — main content */}
      <Flex.Item grow={1} basis={0} mr={1} style={STYLES.leftPanel}>
        <Box shrink={0}>
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
                textColor={
                  tab !== 'requests' && requests.length > 0 && 'yellow'
                }
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
        </Box>
        <Box style={STYLES.contentArea}>
          {tab === 'catalog' && <CargoCatalog />}
          {tab === 'requests' && <CargoRequests />}
          {tab === 'cart' && <CargoCart />}
        </Box>
      </Flex.Item>
      {/* Right panel — batch cart */}
      <Flex.Item basis="320px" shrink={0} style={STYLES.rightPanel}>
        <BatchPanel />
      </Flex.Item>
    </Flex>
  );
};

const CargoStatus = () => {
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
          {docked && !requestonly && can_send ? (
            <Button content={location} onClick={() => act('send')} />
          ) : (
            location
          )}
        </LabeledList.Item>
        <LabeledList.Item label="CentCom Message">{message}</LabeledList.Item>
        {!!loan && !requestonly && (
          <LabeledList.Item label="Loan">
            {loan_dispatched ? (
              <Box color="bad">Loaned to Centcom</Box>
            ) : (
              <Button
                content="Loan Shuttle"
                disabled={!(away && docked)}
                onClick={() => act('loan')}
              />
            )}
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
  const bc = data.batch_constants || {};
  const selfPaidMult = 1 + (bc.self_paid_pct || 10) / 100;

  const allPacks = data.supplies || [];
  const [searchText, setSearchText] = useLocalState('catalogSearch', '');

  // DEBUG: typing the debug keyword in the search bar shows every item
  const isDebugShowAll =
    searchText.trim().toLowerCase() === DEBUG_SEARCH_KEYWORD;

  const isSearching = isDebugShowAll || searchText.length >= MIN_SEARCH_LENGTH;
  const searchLower = searchText.toLowerCase();
  const searchResults = isSearching
    ? allPacks.filter(
        (pack) =>
          isDebugShowAll ||
          pack.name.toLowerCase().includes(searchLower) ||
          (pack.desc && pack.desc.toLowerCase().includes(searchLower)),
      )
    : [];

  return (
    <Section
      title="Catalog"
      fill
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
      <Flex direction="column" height="100%">
        <Flex.Item shrink={0} mb={1}>
          <Input
            fluid
            placeholder="Search supplies..."
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
          />
        </Flex.Item>
        <Flex.Item grow={1} style={{ overflow: 'hidden' }}>
          {isSearching ? (
            <Box height="100%" style={{ overflow: 'auto' }}>
              <Box color={isDebugShowAll ? 'orange' : 'label'} mb={1}>
                {isDebugShowAll && (
                  <><Icon name="bug" mr={1} />DEBUG: </>
                )}
                {searchResults.length} result
                {searchResults.length !== 1 && 's'}
                {isDebugShowAll
                  ? ' (showing all entries)'
                  : <> for &quot;{searchText}&quot;</>}
              </Box>
              {searchResults.length === 0 && (
                <Box color="label" textAlign="center" mt={4}>
                  <Icon name="search" size={2} mb={2} />
                  <br />
                  No matching entries found. Try a different query.
                </Box>
              )}
              <Table>
                {searchResults.map((pack) => {
                  const tags = [];
                  if (pack.small_item) {
                    tags.push('Small');
                  }
                  if (pack.access) {
                    tags.push('Restricted');
                  }
                  return (
                    <Table.Row key={pack.id} className="candystripe">
                      <Table.Cell>
                        {pack.name}
                        {pack.desc && (
                          <Box fontSize="10px" color="label">
                            {pack.desc}
                          </Box>
                        )}
                      </Table.Cell>
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
                            pack.supply <= 0 ||
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
                              ? Math.round(pack.cost * selfPaidMult)
                              : pack.cost,
                          )}
                          {' cr'}
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            </Box>
          ) : (
            <Flex
              height="100%"
              direction="column"
              align="center"
              justify="center"
            >
              <Icon name="database" size={4} color="label" mb={3} />
              <Box color="label" fontSize="16px" bold mb={2}>
                Query database for entry listings
              </Box>
              <Box color="label" fontSize="12px">
                Use the search bar above to find supplies by name or
                description.
              </Box>
            </Flex>
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const CargoRequests = () => {
  const { act, data } = useBackend();
  const { requestonly, can_send, can_approve_requests } = data;
  const requests = data.requests || [];
  // Labeled list reimplementation to squeeze extra columns out of it
  return (
    <Section
      title="Active Requests"
      fill
      scrollable
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
  const isBatch = request.is_batch;
  return (
    <>
      <Table.Row className="candystripe">
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
        <Table.Cell>
          {isBatch ? (
            <BatchLabel
              object={request.object}
              crateCount={request.crate_count}
              totalItems={request.total_items}
            />
          ) : (
            request.object
          )}
        </Table.Cell>
        <Table.Cell>
          <b>{request.orderer}</b>
        </Table.Cell>
        <Table.Cell width="25%">
          <i>{request.reason}</i>
        </Table.Cell>
        <Table.Cell fontFamily="verdana" collapsing textAlign="right">
          {formatMoney(request.cost)} cr
        </Table.Cell>
        {isBatch ? (
          <Table.Cell collapsing />
        ) : (
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            Stock: {request.supply}
          </Table.Cell>
        )}
        {(!requestonly || can_send) && can_approve_requests && (
          <Table.Cell collapsing>
            <Button
              icon="check"
              color="good"
              onClick={() => act('approve', { id: request.id })}
            />
            <Button
              icon="times"
              color="bad"
              onClick={() => act('deny', { id: request.id })}
            />
          </Table.Cell>
        )}
      </Table.Row>
      {expanded && (
        <ExpandedContentsRows
          parentId={request.id}
          contents={contents}
          colSpan={6}
        />
      )}
    </>
  );
};

const CargoCartButtons = () => {
  const { act, data } = useBackend();
  const { requestonly, can_send, can_approve_requests } = data;
  const cart = data.cart || [];
  const total = cart.reduce((sum, entry) => sum + entry.cost, 0);
  if (requestonly || !can_send || !can_approve_requests) {
    return null;
  }
  return (
    <>
      <Box inline mx={1}>
        {cart.length === 0 && 'Cart is empty'}
        {cart.length >= 1 && pluralize(cart.length, 'item')}{' '}
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

const CargoCart = () => {
  const { act, data } = useBackend();
  const { requestonly, away, docked, location, can_send } = data;
  const cart = data.cart || [];
  return (
    <Section
      title="Current Orders"
      fill
      scrollable
      buttons={<CargoCartButtons />}
    >
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
          {away === 1 && docked === 1 ? (
            <Button
              color="green"
              style={STYLES.confirmButton}
              content="Confirm the order"
              onClick={() => act('send')}
            />
          ) : (
            <Box opacity={0.5}>Shuttle in {location}.</Box>
          )}
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
  const isBatch = entry.is_batch;
  return (
    <>
      <Table.Row className="candystripe">
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
        <Table.Cell>
          {isBatch ? (
            <BatchLabel
              object={entry.object}
              crateCount={entry.crate_count}
              totalItems={entry.total_items}
            />
          ) : (
            entry.object
          )}
        </Table.Cell>
        <Table.Cell collapsing>
          {!!entry.paid && <b>[Paid Privately]</b>}
        </Table.Cell>
        <Table.Cell fontFamily="verdana" collapsing textAlign="right">
          {formatMoney(entry.cost)} cr
        </Table.Cell>
        {isBatch ? (
          <Table.Cell collapsing />
        ) : (
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            Stock: {entry.supply}
          </Table.Cell>
        )}
        <Table.Cell collapsing>
          {can_send && (
            <Button
              icon="minus"
              onClick={() => act('remove', { id: entry.id })}
            />
          )}
        </Table.Cell>
      </Table.Row>
      {expanded && (
        <ExpandedContentsRows
          parentId={entry.id}
          contents={contents}
          colSpan={5}
        />
      )}
    </>
  );
};

const BatchPanel = () => {
  const { act, data } = useBackend();
  const [batchTab, setBatchTab] = useSharedState('batchTab', 'items');
  const batch = data.batch || {};
  const batchItems = batch.items || [];
  const totalCost = batch.total_cost || 0;
  const baseCost = batch.base_cost || 0;
  const itemCount = batch.item_count || 0;
  const crates = batch.crates || [];
  const surcharge = batch.surcharge || 0;
  const bulkDiscountPct = batch.bulk_discount_pct || 0;
  const crateCost = batch.crate_cost || 0;
  const selfPaidPct = batch.self_paid_pct || 0;
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
        <Tabs.Tab
          icon="calculator"
          selected={batchTab === 'pricing'}
          onClick={() => setBatchTab('pricing')}
        >
          Pricing
        </Tabs.Tab>
      </Tabs>
      {batchTab === 'items' && <BatchItemsList />}
      {batchTab === 'crates' && <BatchCrateReadout />}
      {batchTab === 'pricing' && <BatchPricingBreakdown />}
      {batchItems.length > 0 && (
        <Box mt={2}>
          {/* Compact pricing summary — always visible */}
          <Box
            fontSize="11px"
            color="label"
            mb={1}
            style={STYLES.pricingSummary}
          >
            <Box>
              Base: {formatMoney(baseCost)} cr
              {surcharge > 0 && (
                <Box as="span" color="bad" ml={1}>
                  +{formatMoney(surcharge)} surcharge
                </Box>
              )}
            </Box>
            {bulkDiscountPct > 0 && (
              <Box color="good">
                Bulk discount: -{bulkDiscountPct.toFixed(1)}%
              </Box>
            )}
            {crateCost > 0 && (
              <Box>
                Crates: +{formatMoney(crateCost)} cr
                <Box as="span" color="label" ml={1}>
                  (refunded on return)
                </Box>
              </Box>
            )}
            {selfPaidPct > 0 && (
              <Box color="average">
                Personal purchase: +{selfPaidPct}%
              </Box>
            )}
          </Box>
          <Box
            fontFamily="verdana"
            bold
            textAlign="center"
            mb={1}
            fontSize="14px"
          >
            Total: {formatMoney(totalCost)} cr ({pluralize(itemCount, 'item')},{' '}
            {pluralize(crates.length, 'crate')})
          </Box>
          <Button
            fluid
            color="green"
            icon="check"
            textAlign="center"
            style={STYLES.confirmButton}
            content={requestonly ? 'Submit Request' : 'Confirm Batch Order'}
            onClick={() => act('batch_confirm')}
          />
        </Box>
      )}
    </Section>
  );
};

const BatchItemsList = () => {
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
          <Table.Cell>
            {item.name}
            <Box fontSize="10px" color="label">
              {item.crate_type}
              {' · Stock: '}
              <Box
                as="span"
                color={
                  item.supply <= 0
                    ? 'bad'
                    : item.quantity >= item.supply
                      ? 'average'
                      : 'good'
                }
              >
                {item.supply}
              </Box>
            </Box>
          </Table.Cell>
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
                color={item.quantity > item.supply ? 'bad' : undefined}
                style={STYLES.quantityDisplay}
              >
                {item.quantity}
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="plus"
                  compact
                  disabled={item.quantity >= item.supply}
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

const BatchCrateReadout = () => {
  const { data } = useBackend();
  const batch = data.batch || {};
  const crates = batch.crates || [];
  const bc = data.batch_constants || {};
  const maxSlots = bc.crate_max_items || 10;

  if (crates.length === 0) {
    return (
      <Box color="label" textAlign="center" mt={2}>
        No crates to display. Add items to the batch first.
      </Box>
    );
  }

  return (
    <Box>
      {crates.map((crate, idx) => {
        const slotsUsed = crate.slots_used || crate.count;
        const fill = getCrateFillInfo(slotsUsed, maxSlots);
        const isFull = slotsUsed >= maxSlots;
        return (
          <Collapsible
            key={idx}
            title={
              `Crate ${idx + 1}: (${slotsUsed}/${maxSlots} slots` +
              `${isFull ? ' ✓' : ''}) - ` +
              `${formatMoney(crate.crate_cost)} cr deposit`
            }
            color={fill.color}
          >
            <Box ml={2}>
              {crate.contents.map((item, cidx) => (
                <Box key={cidx} color="label">
                  - {item}
                </Box>
              ))}
              <Box mt={1} fontSize="10px" color="label" italic>
                Fill: {slotsUsed}/{maxSlots} slots - {fill.label}
                {' '}| Crate deposit: {formatMoney(crate.crate_cost)} cr
              </Box>
            </Box>
          </Collapsible>
        );
      })}
    </Box>
  );
};

const BatchPricingBreakdown = () => {
  const { data } = useBackend();
  const batch = data.batch || {};
  const baseCost = batch.base_cost || 0;
  const totalCost = batch.total_cost || 0;
  const itemCount = batch.item_count || 0;
  const surcharge = batch.surcharge || 0;
  const bulkDiscountPct = batch.bulk_discount_pct || 0;
  const crateCost = batch.crate_cost || 0;
  const selfPaidPct = batch.self_paid_pct || 0;
  const bc = data.batch_constants || {};

  if (itemCount === 0) {
    return (
      <Box color="label" textAlign="center" mt={2}>
        Add items to see pricing breakdown.
      </Box>
    );
  }

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Base Item Cost">
          {formatMoney(baseCost)} cr
        </LabeledList.Item>
        <LabeledList.Item
          label="Batch Surcharge"
          color={surcharge > 0 ? 'bad' : 'good'}
        >
          {surcharge > 0
            ? '+' + formatMoney(surcharge) + ' cr'
            : `None (${bc.surcharge_items_zero}+ items)`}
          <Box fontSize="10px" color="label">
            Starts at {bc.surcharge_max} cr, drops to 0 at{' '}
            {bc.surcharge_items_zero}+ items
          </Box>
        </LabeledList.Item>
        <LabeledList.Item
          label="Bulk Discount"
          color={bulkDiscountPct > 0 ? 'good' : 'label'}
        >
          {bulkDiscountPct > 0
            ? '-' + bulkDiscountPct.toFixed(1) + '%'
            : `None (need ${bc.bulk_discount_start}+ items)`}
          <Box fontSize="10px" color="label">
            Up to {bc.bulk_discount_max_pct}% off at{' '}
            {bc.bulk_discount_cap}+ items
          </Box>
        </LabeledList.Item>
        <LabeledList.Item
          label="Crate Deposits"
          color={crateCost > 0 ? 'label' : 'good'}
        >
          {crateCost > 0 ? '+' + formatMoney(crateCost) + ' cr' : 'None'}
          <Box fontSize="10px" color="good">
            Fully refunded when crates are sent back
          </Box>
        </LabeledList.Item>
        {selfPaidPct > 0 && (
          <LabeledList.Item label="Personal Purchase" color="average">
            +{selfPaidPct}%
          </LabeledList.Item>
        )}
        <LabeledList.Divider />
        <LabeledList.Item label="Final Total" bold>
          <Box fontSize="14px" bold>
            {formatMoney(totalCost)} cr
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
