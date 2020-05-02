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
  if (recollection)
  {
    return (
      <Window
        resizable>
        <Window.Content scrollable>
          <ClockworkRecollection />
        </Window.Content>
      </Window>
    );
  }
  else
  {
    return (
      <Window
        resizable>
        <Window.Content scrollable>
          <ClockworkGeneric />
        </Window.Content>
      </Window>
    );
  }
};

export const ClockworkRecollection = (props, context) => {
  const { data } = useBackend(context);
  const { rec_text } = data;
  const { rec_section } = data;
  const { rec_binds } = data;
  const { rec_category } = data;
  const { recollection_categories } = data;
  return (
    <Section>
      {rec_text}
      {recollection_categories.map(category => (
        <Tabs.Tab
          key={category.name}
          onClick={() => rec_category(category.name)}>
          {category.name} - {category.desc}
        </Tabs.Tab>
      ))}
      {rec_section}
      {rec_binds}
    </Section>
  );
};

export const ClockworkGeneric = (props, context) => {
  const { act, data } = useBackend(context);
  const { power } = data;
  const { tier_info } = data;
  const { scripturecolors } = data;
  const { scripture } = data;
  const { selected } = data;
  return (
    <Section>
      <Section>
        {power}
      </Section>
      <Section>
        <Fragment>
          <Button
            selected={selected === "Driver"}
            onClick={() => act('select', {
              'category': 'Driver',
            })}
            content="Driver" />
          <Button
            selected={selected === "Script"}
            onClick={() => act('select', {
              'category': 'Script',
            })}
            content="Scripts" />
          <Button
            selected={selected === "Application"}
            onClick={() => act('select', {
              'category': 'Application',
            })}
            content="Applications" />
          {tier_info}
        </Fragment>
      </Section>
      <Section>
        {scripturecolors}
      </Section>
      <Section>
        {scripture.map(category => {
          <ClockworkScripture
            scripture={category} />;
        })}
      </Section>
    </Section>
  );
};

export const ClockworkScripture = (props, context) => {
  const {
    scripture,
  } = props;
  const { act } = useBackend(context);

  return (
    <Tabs.Tab
      tooltip={scripture.tip}
      key={scripture.type}
      onClick={() => act('recite', {
        'category': scripture.type,
      })}>
      Recite {scripture.required}
      <ClockworkScriptureBindButton
        scripture={scripture} />
    </Tabs.Tab>
  );
};

export const ClockworkScriptureBindButton = (props, context) => {
  const {
    scripture,
  } = props;
  const { act } = useBackend(context);
  if (scripture.quickbind)
  {
    if (scripture.bound)
    {
      return (
        <Button
          onClick={() => act('bind', {
            'category': scripture.type,
          })}
          content={'Unbind' + scripture.bound} />
      );
    }
    else
    {
      return (
        <Button
          onClick={() => act('bind', {
            'category': scripture.type,
          })}
          content={'Quickbind'} />
      );
    }
  }
};
