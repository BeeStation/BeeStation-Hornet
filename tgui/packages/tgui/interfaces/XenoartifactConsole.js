import { useBackend } from '../backend';
import { Box, Tabs, Section, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, ProgressBar, Flex, Divider } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const XenoartifactConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { stability, money } = data;
  const sellers = data.sellers || [];
  return (
    <Window width={800} height={500}>
      <Window.Content scrollable>
        <BlockQuote>{`Research Budget: ${money}`}</BlockQuote>
        <Divider/>
        <ProgressBar value = {stability/100} ranges={{good: [0.5, Infinity], average: [0.25, 0.5], bad: [-Infinity, 0.25],}}/>
        <Divider/>
        <Section>
          <BlockQuote>
            {"Purchase research materials from independant sellers, using the science budget. Purchased items will be routed through cargo."}
          </BlockQuote>
        </Section>
        <Divider/>
        <Flex wrap = {"wrap"}>
          {sellers.map((value) => (
            <XenoartifactConsoleSellerEntry value = {value} key={value}/>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const XenoartifactConsoleSellerEntry = (props, context) => {
  const { act } = useBackend(context);
  const { value } = props;
  const stock = value["stock"] || [];
  return (
    <Flex.Item>
      <Section title={`${value["name"]}`} px={2} py={1} independant={true}>
        <BlockQuote>{`${value["dialogue"]}`}</BlockQuote>
        <Divider/>
        {stock.map((stock_list) => (
          <Section title={`${stock_list["name"]}`} mx={5} independant={true} buttons={<Button icon={'shopping-cart'} onClick={() => act(`stock_purchase`, {item_id: stock_list["id"], seller_id: value["id"],})}>{`$${stock_list["cost"]}`}</Button>} key={stock_list}>
            <BlockQuote>{`${stock_list["description"]}`}</BlockQuote>
            <Divider/>
          </Section>
        ))}
      </Section>
    </Flex.Item>
  );
};
