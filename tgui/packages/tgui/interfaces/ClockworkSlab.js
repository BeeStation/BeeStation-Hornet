import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

export const ClockworkSlab = (props, context) => {
  const { data } = useBackend(context);
  const { power } = data;
  const { recollection } = data;
  return (
    <Window
      theme="clockwork"
      resizable>
      <Window.Content scrollable>
        <ClockworkClassSelection />
      </Window.Content>
    </Window>
  );
};

export const ClockworkClassSelection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    servant_classes = [],
  } = data;
  return (
    <Section>
      <Tabs vertical>
        {servant_classes.map(category => (
          <Tabs.Tab
            key={category.class_name}
            selected={false}
            onClick={() => act('setClass', {
              class: category,
            })}>
            {category.class_name} - {category.class_description}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};
