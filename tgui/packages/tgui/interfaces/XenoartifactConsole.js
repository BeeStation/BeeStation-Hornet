import { useBackend } from '../backend';
import { Box, Tabs, Section, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, ProgressBar, Flex, Divider } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const XenoartifactConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { stability, money, purchase_radio, solved_radio } = data;
  const sellers = data.sellers || [];
  return (
    <Window width={900} height={500}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item align='start'>
              <BlockQuote align='start'>{`Research Budget: ${money}`}</BlockQuote>
            </Flex.Item>
            <Flex.Item align='end'>
              <Button icon={'microphone'} color={purchase_radio ? "green" : "red"} tooltip={"Toggle Purchase Radio"} onClick={() => act('toggle_purchase_audio')} />
              <Button icon={'microphone'} color={solved_radio ? "green" : "red"} tooltip={"Toggle Solve Radio"} onClick={() => act('toggle_solved_audio')} />
            </Flex.Item>
          </Flex>
        </Section>
        <Divider />
        <Flex wrap={"wrap"}>
          {sellers.map((value) => (
            <XenoartifactConsoleSellerEntry value={value} key={value} />
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
      <Section title={`${value["name"]}`} px={2} py={1} independant>
        <BlockQuote>{`${value["dialogue"]}`}</BlockQuote>
        <Divider />
        {stock.map((stock_list) => (
          <Section title={`${stock_list["name"]}`} mx={5} independant buttons={<Button icon={'shopping-cart'} onClick={() => act(`stock_purchase`, { item_id: stock_list["id"], seller_id: value["id"] })}>{`$${stock_list["cost"]}`}</Button>} key={stock_list}>
            <BlockQuote>{`${stock_list["description"]}`}</BlockQuote>
            <Divider />
          </Section>
        ))}
      </Section>
    </Flex.Item>
  );
};
