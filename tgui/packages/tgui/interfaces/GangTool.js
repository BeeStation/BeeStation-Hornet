import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox } from '../components';
import { Window } from '../layouts';
import { GenericUplink } from './Uplink';



export const GangTool = (props, context) => {
  const { data } = useBackend(context);
  const { influence } = data;
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  return (
    <Window theme="neutral" width={600} height={532}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab icon="list" lineHeight="23px" selected={tab === 1} onClick={() => setTab(1)}>
            Market
          </Tabs.Tab>
          <Tabs.Tab icon="list" lineHeight="23px" selected={tab === 2} onClick={() => setTab(2)}>
            Tracker
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <GenericUplink currencyAmount={influence} currencySymbol="Influence" />}
        {tab === 2 && <GenericUplink currencyAmount={influence} currencySymbol="Influence" />}
      </Window.Content>
    </Window>
  );
};
