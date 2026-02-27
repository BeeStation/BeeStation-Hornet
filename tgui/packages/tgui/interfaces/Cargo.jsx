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

/**
 * Parses the new nested supplies data from the backend into a flat list
 * of { categoryName, subcategoryName, packs[] } entries, plus a grouped
 * structure for the sidebar.
 */
const parseSupplies = (rawSupplies) => {
  const categories = [];
  for (const catData of Object.values(rawSupplies)) {
    const subcategories = Object.values(catData.subcategories || {}).sort(
      (a, b) => a.name.localeCompare(b.name),
    );
    const totalPacks = subcategories.reduce(
      (sum, sub) => sum + (sub.packs?.length || 0),
      0,
    );
    categories.push({
      name: catData.name,
      subcategories,
      totalPacks,
    });
  }
  categories.sort((a, b) => a.name.localeCompare(b.name));
  return categories;
};

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
      <Flex.Item
        grow={1}
        basis={0}
        mr={1}
        style={{
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
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
        <Box style={{ flexGrow: 1, overflow: 'hidden', height: '100%' }}>
          {tab === 'catalog' && <CargoCatalog />}
          {tab === 'requests' && <CargoRequests />}
          {tab === 'cart' && <CargoCart />}
        </Box>
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
  const bc = data.batch_constants || {};
  const selfPaidMult = 1 + (bc.self_paid_pct || 10) / 100;

  const categories = parseSupplies(data.supplies || {});

  // Track which category is expanded in the sidebar
  const [expandedCategory, setExpandedCategory] = useSharedState(
    'expandedCat',
    categories[0]?.name,
  );
  // Track the active subcategory (what's shown in the main panel)
  const [activeSubcatKey, setActiveSubcatKey] = useSharedState(
    'activeSubcat',
    categories[0]?.subcategories[0]?.name,
  );
  // Track the parent category of the active subcategory (for display)
  const [activeCatKey, setActiveCatKey] = useSharedState(
    'activeCat',
    categories[0]?.name,
  );

  const [searchText, setSearchText] = useLocalState('catalogSearch', '');

  // Find the active subcategory's packs
  const activeCategory = categories.find((c) => c.name === activeCatKey);
  const activeSubcategory = activeCategory?.subcategories.find(
    (s) => s.name === activeSubcatKey,
  );
  const activePacks = activeSubcategory?.packs || [];

  // Helper to select a subcategory
  const selectSubcategory = (catName, subName) => {
    setActiveCatKey(catName);
    setActiveSubcatKey(subName);
    setExpandedCategory(catName);
  };

  // When searching, collect matching packs across all categories/subcategories
  const isSearching = searchText.length >= 2;
  const searchLower = searchText.toLowerCase();
  const searchResults = isSearching
    ? categories.flatMap((cat) =>
        cat.subcategories.flatMap((sub) =>
          (sub.packs || [])
            .filter(
              (pack) =>
                pack.name.toLowerCase().includes(searchLower) ||
                (pack.desc && pack.desc.toLowerCase().includes(searchLower)),
            )
            .map((pack) => ({
              ...pack,
              category: cat.name,
              subcategory: sub.name,
            })),
        ),
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
            placeholder="Search all items..."
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
          />
        </Flex.Item>
        <Flex.Item grow={1} style={{ overflow: 'hidden' }}>
          {isSearching ? (
            <Box height="100%" style={{ overflow: 'auto' }}>
              <Box color="label" mb={1}>
                {searchResults.length} result
                {searchResults.length !== 1 && 's'} for &quot;{searchText}
                &quot;
              </Box>
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
                        <Box fontSize="10px" color="label">
                          {pack.category}
                          {pack.subcategory && ' › ' + pack.subcategory}
                        </Box>
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
            <Flex height="100%" style={{ overflow: 'hidden' }}>
              {/* Sidebar with category/subcategory hierarchy */}
              <Flex.Item
                mr={1}
                shrink={0}
                style={{
                  overflowY: 'auto',
                  overflowX: 'hidden',
                  minWidth: '200px',
                  maxWidth: '220px',
                }}
              >
                {categories.map((cat) => {
                  const isExpanded = expandedCategory === cat.name;
                  return (
                    <Box key={cat.name} mb={0.5}>
                      <Button
                        fluid
                        color={
                          activeCatKey === cat.name
                            ? 'transparent'
                            : 'transparent'
                        }
                        bold
                        style={{
                          padding: '4px 6px',
                          background:
                            activeCatKey === cat.name
                              ? 'rgba(255,255,255,0.07)'
                              : 'none',
                        }}
                        onClick={() =>
                          setExpandedCategory(
                            isExpanded ? null : cat.name,
                          )
                        }
                      >
                        <Icon
                          name={isExpanded ? 'chevron-down' : 'chevron-right'}
                          mr={1}
                        />
                        {cat.name}
                        <Box
                          as="span"
                          color="label"
                          ml={1}
                          fontSize="10px"
                        >
                          ({cat.totalPacks})
                        </Box>
                      </Button>
                      {isExpanded &&
                        cat.subcategories.map((sub) => {
                          const isActive =
                            activeCatKey === cat.name &&
                            activeSubcatKey === sub.name;
                          return (
                            <Button
                              key={sub.name}
                              fluid
                              color={isActive ? 'good' : 'transparent'}
                              style={{
                                padding: '2px 6px 2px 22px',
                                fontSize: '12px',
                              }}
                              onClick={() =>
                                selectSubcategory(cat.name, sub.name)
                              }
                            >
                              {sub.name}
                              <Box
                                as="span"
                                color="label"
                                ml={1}
                                fontSize="10px"
                              >
                                ({sub.packs?.length || 0})
                              </Box>
                            </Button>
                          );
                        })}
                    </Box>
                  );
                })}
              </Flex.Item>
              {/* Main pack list */}
              <Flex.Item grow={1} basis={0} style={{ overflow: 'auto' }}>
                {activeSubcategory && (
                  <Box color="label" mb={1} fontSize="11px">
                    {activeCatKey} › {activeSubcatKey} (
                    {activePacks.length}{' '}
                    {activePacks.length === 1 ? 'item' : 'items'})
                  </Box>
                )}
                <Table>
                  {activePacks.map((pack) => {
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
                        <Table.Cell
                          collapsing
                          color="label"
                          textAlign="right"
                        >
                          {tags.join(', ')}
                        </Table.Cell>
                        <Table.Cell
                          collapsing
                          color="label"
                          textAlign="right"
                        >
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
              </Flex.Item>
            </Flex>
          )}
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
        <Table.Cell>
          {isBatch ? (
            <Box>
              <Box bold color="good">
                {request.object}
              </Box>
              <Box color="label" fontSize="11px">
                {request.crate_count}{' '}
                {request.crate_count === 1 ? 'crate' : 'crates'} &bull;{' '}
                {request.total_items}{' '}
                {request.total_items === 1 ? 'item' : 'items'}
              </Box>
            </Box>
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
        {!isBatch && (
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            Stock: {request.supply}
          </Table.Cell>
        )}
        {isBatch && <Table.Cell collapsing />}
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
    <Section title="Current Orders" fill scrollable buttons={<CargoCartButtons />}>
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
  const isBatch = entry.is_batch;
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
        <Table.Cell>
          {isBatch ? (
            <Box>
              <Box bold color="good">
                {entry.object}
              </Box>
              <Box color="label" fontSize="11px">
                {entry.crate_count}{' '}
                {entry.crate_count === 1 ? 'crate' : 'crates'} &bull;{' '}
                {entry.total_items}{' '}
                {entry.total_items === 1 ? 'item' : 'items'}
              </Box>
            </Box>
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
        {!isBatch && (
          <Table.Cell fontFamily="verdana" collapsing textAlign="right">
            Stock: {entry.supply}
          </Table.Cell>
        )}
        {isBatch && <Table.Cell collapsing />}
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
  const baseCost = batch.base_cost || 0;
  const itemCount = batch.item_count || 0;
  const crates = batch.crates || [];
  const surcharge = batch.surcharge || 0;
  const bulkDiscountPct = batch.bulk_discount_pct || 0;
  const crateCost = batch.crate_cost || 0;
  const selfPaidPct = batch.self_paid_pct || 0;
  const avgCrateFill = batch.avg_crate_fill || 0;
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
          {/* Compact pricing summary always visible */}
          <Box
            fontSize="11px"
            color="label"
            mb={1}
            style={{
              background: 'rgba(0,0,0,0.2)',
              padding: '6px 8px',
              borderRadius: '3px',
            }}
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
            Total: {formatMoney(totalCost)} cr ({itemCount}{' '}
            {itemCount === 1 ? 'item' : 'items'}, {crates.length}{' '}
            {crates.length === 1 ? 'crate' : 'crates'})
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
          <Table.Cell>
            {item.name}
            <Box fontSize="10px" color="label">
              {item.crate_type}
              {' · Stock: '}
              <Box
                as="span"
                color={item.supply <= 0 ? 'bad' : item.quantity >= item.supply ? 'average' : 'good'}
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

const BatchCrateReadout = (props) => {
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
        return (
          <Collapsible
            key={idx}
            title={
              'Crate ' +
              (idx + 1) +
              ': (' +
              slotsUsed +
              '/' +
              maxSlots +
              ' slots' +
              (slotsUsed >= maxSlots ? ' ✓' : '') +
              ') - ' +
              formatMoney(crate.crate_cost) +
              ' cr deposit'
            }
            color={
              slotsUsed >= maxSlots * 0.8
                ? 'good'
                : slotsUsed >= maxSlots * 0.4
                  ? 'average'
                  : 'bad'
            }
          >
            <Box ml={2}>
              {crate.contents.map((item, cidx) => (
                <Box key={cidx} color="label">
                  - {item}
                </Box>
              ))}
              <Box mt={1} fontSize="10px" color="label" italic>
                Fill: {slotsUsed}/{maxSlots} slots -{' '}
                {slotsUsed >= maxSlots * 0.8
                  ? 'Efficient'
                  : slotsUsed >= maxSlots * 0.4
                    ? 'Fair'
                    : 'Wasteful'}
                {' '}| Crate deposit: {formatMoney(crate.crate_cost)} cr
              </Box>
            </Box>
          </Collapsible>
        );
      })}
    </Box>
  );
};

const BatchPricingBreakdown = (props) => {
  const { data } = useBackend();
  const batch = data.batch || {};
  const baseCost = batch.base_cost || 0;
  const totalCost = batch.total_cost || 0;
  const itemCount = batch.item_count || 0;
  const surcharge = batch.surcharge || 0;
  const bulkDiscountPct = batch.bulk_discount_pct || 0;
  const crateCost = batch.crate_cost || 0;
  const selfPaidPct = batch.self_paid_pct || 0;
  const avgCrateFill = batch.avg_crate_fill || 0;
  const crates = batch.crates || [];
  const bc = data.batch_constants || {};
  const crateCosts = bc.crate_costs || {};

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
