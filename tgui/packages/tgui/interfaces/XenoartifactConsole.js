import { useBackend } from '../backend';
import { Box, Tabs, Section, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, ProgressBar, Flex, Divider } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const XenoartifactConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { } = data;
  const sellers = data.sellers || [];
  return (
    <Window width={800} height={500}>
      <Window.Content scrollable>
        <Flex>
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
      <Section title={`${value["name"]}`}>
        <BlockQuote>{`${value["dialogue"]}`}</BlockQuote>
        <Divider/>
        {stock.map((stock_item) => (
          <BlockQuote>{`${stock_item}`}</BlockQuote>
        ))}
      </Section>
    </Flex.Item>
  );
};
