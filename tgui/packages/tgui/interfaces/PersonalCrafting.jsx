import { useBackend, useLocalState } from '../backend';
import { classes } from 'common/react';
import { Button, Dimmer, Flex, Icon, LabeledList, Section, Tabs, Box } from '../components';
import { Window } from '../layouts';

export const PersonalCrafting = (props) => {
  const { act, data } = useBackend();
  const { busy, display_craftable_only, display_compact } = data;
  const crafting_recipes = data.crafting_recipes || {};
  // Sort everything into flat categories
  const categories = [];
  const recipes = [];
  for (let category of Object.keys(crafting_recipes)) {
    const subcategories = crafting_recipes[category];
    if ('has_subcats' in subcategories) {
      for (let subcategory of Object.keys(subcategories)) {
        if (subcategory === 'has_subcats') {
          continue;
        }
        // Push category
        categories.push({
          name: subcategory,
          category,
          subcategory,
        });
        // Push recipes
        const _recipes = subcategories[subcategory];
        for (let recipe of _recipes) {
          recipes.push({
            ...recipe,
            category: subcategory,
          });
        }
      }
      continue;
    }
    // Push category
    categories.push({
      name: category,
      category,
    });
    // Push recipes
    const _recipes = crafting_recipes[category];
    for (let recipe of _recipes) {
      recipes.push({
        ...recipe,
        category,
      });
    }
  }
  // Sort out the tab state
  const [tab, setTab] = useLocalState('tab', categories[0]?.name);
  const shownRecipes = recipes.filter((recipe) => recipe.category === tab);
  return (
    <Window theme="generic" title="Crafting Menu" width={700} height={800}>
      <style>
        {`table, th, td {
            vertical-align: middle;
          }
        `}
      </style>
      <Window.Content scrollable>
        {!!busy && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Crafting...'}
          </Dimmer>
        )}
        <Section
          title="Personal Crafting"
          buttons={
            <>
              <Button.Checkbox content="Compact" checked={display_compact} onClick={() => act('toggle_compact')} />
              <Button.Checkbox
                content="Craftable Only"
                checked={display_craftable_only}
                onClick={() => act('toggle_recipes')}
              />
            </>
          }>
          <Flex>
            <Flex.Item>
              <Tabs vertical>
                {categories.map((category) => (
                  <Tabs.Tab
                    key={category.name}
                    selected={category.name === tab}
                    onClick={() => {
                      setTab(category.name);
                      act('set_category', {
                        category: category.category,
                        subcategory: category.subcategory,
                      });
                    }}>
                    {category.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
              <CraftingList craftables={shownRecipes} />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

const CraftingList = (props) => {
  const { craftables = [] } = props;
  const { act, data } = useBackend();
  const { craftability = {}, display_compact, display_craftable_only } = data;
  return craftables.map((craftable) => {
    if (display_craftable_only && !craftability[craftable.ref]) {
      return null;
    }
    // Compact display
    if (display_compact) {
      return (
        <LabeledList.Item
          key={craftable.name}
          label={
            <table>
              <tr>
                <td className={classes(['crafting42x42', craftable.path])} />
                <td>{craftable.name}</td>
              </tr>
            </table>
          }
          verticalAlign="middle"
          className="candystripe"
          buttons={
            <Button
              icon="cog"
              content="Craft"
              style={{ marginTop: '14px' }}
              disabled={!craftability[craftable.ref]}
              tooltip={craftable.tool_text && 'Tools needed: ' + craftable.tool_text}
              tooltipPosition="left"
              onClick={() =>
                act('make', {
                  recipe: craftable.ref,
                })
              }
            />
          }>
          {craftable.req_text}
        </LabeledList.Item>
      );
    }
    // Full display
    return (
      <Section
        key={craftable.name}
        title={
          <>
            <span style={{ marginRight: '2px' }} className={classes(['crafting42x42', craftable.path])} />
            {craftable.name}
          </>
        }
        level={2}
        buttons={
          <Button
            icon="cog"
            content="Craft"
            style={{ marginTop: '14px' }}
            disabled={!craftability[craftable.ref]}
            onClick={() =>
              act('make', {
                recipe: craftable.ref,
              })
            }
          />
        }>
        <LabeledList>
          {!!craftable.req_text && <LabeledList.Item label="Required">{craftable.req_text}</LabeledList.Item>}
          {!!craftable.catalyst_text && <LabeledList.Item label="Catalyst">{craftable.catalyst_text}</LabeledList.Item>}
          {!!craftable.tool_text && <LabeledList.Item label="Tools">{craftable.tool_text}</LabeledList.Item>}
        </LabeledList>
      </Section>
    );
  });
};
