import { map, toArray } from 'common/collections';
import { useBackend } from '../backend';
import { Box, Tabs, Section, Button, BlockQuote, Icon, Collapsible, AnimatedNumber } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { sanitizeText } from "../sanitize";

export const XenoartifactConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tab_index,
    current_tab,
    tab_info,
    points,
  } = data;
  const sellers=toArray(data.seller);
  return (
    <Window
      width={800}
      height={500}>
      <Window.Content scrollable>
        <Box>
          <Section title={`Research and Development`} fluid
            buttons={(
              <Box fontFamily="verdana" inline bold>
                <AnimatedNumber
                  value={points}
                  format={value => formatMoney(value)} />
                {' credits'}
              </Box>
            )}>
            <BlockQuote>
              {`${tab_info}`}
            </BlockQuote>
          </Section>
          <Tabs row>
            {tab_index.map(tab_name => (<XenoartifactConsoleTabs 
              tab_name={tab_name} key={tab_name} />))}
          </Tabs>
          {current_tab === "Listings" && (
            sellers.map(details => (<XenoartifactListingBuy 
              name={details.name} dialogue={details.dialogue} 
              price={details.price} key={details.name}
              id={details.id} />))
          )}
          {current_tab === "Linking" && (
            <XenoartifactLinking />
          )}
          {current_tab === "Export" && (
            <XenoartifactSell />
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};

const XenoartifactConsoleTabs = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    tab_index,
    current_tab,
  } = data;
  const {
    tab_name,
  } = props;
  return (
    <Box>
      <Tabs.Tab 
        selected={current_tab === tab_name}
        onClick={() => act(`set_tab_${tab_name}`
        )}>
        {`${tab_name}`}
      </Tabs.Tab>
    </Box>
  );
};

export const XenoartifactListingBuy = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    dialogue,
    price,
    id,
  } = props;
  return (
    <Box p={.5}>
      <Section>
        {`${name}:`}
        <BlockQuote>
          {`${dialogue}`}
        </BlockQuote>
        <Button onClick={() => act(id)}>
          {`Purchase: ${price} credits.`} <Icon name="shopping-cart" />
        </Button>
      </Section>
    </Box>
  );
};

export const XenoartifactListingSell = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    dialogue,
  } = props;
  return (
    <Box p={.5}>
      <Section>
        {`${name}:`}
        <BlockQuote>
          {`${dialogue}`}
        </BlockQuote>
      </Section>
    </Box>
  );
};

export const XenoartifactLinking = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    linked_machines,
  } = data;
  return (
    <Box p={.5}>
      <Button onClick={() => act(`link_nearby`)}>
        Link nearby machines. <Icon name="sync" />
      </Button>
      {linked_machines.map(machine => (
        <Section p={1} key={machine}>{`${machine} connection established.`}
        </Section>))}
    </Box>
  );
};

export const XenoartifactSell = (props, context) => {
  const { act, data } = useBackend(context);
  const entries = toArray(data.sold_artifacts);
  const buyers = toArray(data.buyer);
  return (
    <Box p={.5}>
      <Section>
        <Collapsible title="Portfolio">
          {entries.map(item => (
            <Section key={item}>
              <BlockQuote>
                <Box>{`${item.main}`}</Box>
                <Box>{`${item.gain}`}</Box>
                {item.traits.map(trait => (
                  <Box key={trait} color={trait.color}>{`${trait.name}`}</Box>
                ))}
              </BlockQuote>
            </Section>))}
        </Collapsible>
        <Button onClick={() => act(`sell`)} p={.5}>
          Export pad contents. <Icon name="shopping-cart" />
        </Button>
      </Section>
      {buyers.map(details => (<XenoartifactListingSell 
        key={details}
        name={details.name} dialogue={details.dialogue} price={details.price} 
        id={details.id} />))}
    </Box>
  );
};
