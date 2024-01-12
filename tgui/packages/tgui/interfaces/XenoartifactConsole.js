import { useBackend } from '../backend';
import { Box, Tabs, Section, Button, BlockQuote, Icon, Collapsible, AnimatedNumber, ProgressBar } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const XenoartifactConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { tab_index, current_tab, tab_info, points, stability } = data;
  const sellers = Object.values(data.seller);
  return (
    <Window width={800} height={500}>
      <Window.Content scrollable>
        <Box>
            test
        </Box>
      </Window.Content>
    </Window>
  );
};
