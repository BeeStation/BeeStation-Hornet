import { capitalize, createSearch } from 'common/string';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

// Handles protolathes, circuit fabricators, and techfabs

export const TechFab = (props) => {
  return (
    <Window width={590} height={700}>
      <Window.Content>
        <Stack vertical fill>
          <TechFabTopBar />
          <TechFabHeader />
          <TechFabContent />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TechFabTopBar = (props) => {
  const { act, data } = useBackend();
  const { busy, efficiency, search } = data;

  return (
    <Stack.Item>
      <Section>
        <Flex align="baseline" wrap="wrap">
          <Flex.Item mx={0.5}>
            {'Search: '}
            <Input
              align="right"
              value={search}
              // Uncomment to make the search update as you type.
              // Likely to cause issues with topic per minute limits.
              // onInput={(e, value) => {
              //   value.trim().length>2 && act("search", { "value": value });
              // }}
              onChange={(e, value) => act('search', { value: value })}
            />
          </Flex.Item>
          <Flex.Item mx={0.5}>
            <Button
              content="Synchronize research"
              onClick={() => act('sync_research')}
            />
          </Flex.Item>
          <Flex.Item mx={0.5} grow>
            Efficiency: {Math.floor(efficiency * 100)}%
          </Flex.Item>
          <Flex.Item px={1.5} color={busy ? 'red' : 'green'}>
            {busy ? 'Busy ' : 'Ready '}
            <Icon name={busy ? 'spinner' : 'check-circle-o'} spin={busy} />
          </Flex.Item>
        </Flex>
      </Section>
    </Stack.Item>
  );
};

const formatBigNumber = (number, digits) => {
  const unsafeDigitCount = Math.floor(Math.log10(number));
  const digitCount = isFinite(unsafeDigitCount) ? unsafeDigitCount : 0;
  const exponent =
    digitCount > digits
      ? Math.pow(10, digitCount - digits)
      : Math.pow(10, Math.max(0, digits - digitCount));

  if (digitCount > digits) {
    number = Math.floor(number / exponent);
    return number + 'e+' + (digitCount - digits);
  } else {
    return Math.round(number * exponent) / exponent;
  }
};

const Material = (props) => {
  const { act, data } = useBackend();
  const { material } = props;

  const material_dispense_amounts = [1, 10, 50];

  return (
    <Flex.Item width="50%" my="1px">
      <Flex justify="space-between" px={1} align="baseline">
        <Flex.Item width="100%">{capitalize(material.name)}</Flex.Item>
        <Flex.Item grow basis="content">
          <Flex align="baseline">
            <Flex.Item shrink px={1}>
              {formatBigNumber(material.amount, 4)}
            </Flex.Item>
            <Flex.Item>
              <Flex className="TechFab__ButtonsContainer">
                {material_dispense_amounts.map((amount) => (
                  <Flex.Item key={material.name + amount}>
                    <Button
                      className="TechFab__NumberButton"
                      content={amount}
                      disabled={material.amount < amount}
                      onClick={() =>
                        act('ejectsheet', {
                          material_id: material.name,
                          amount: amount,
                        })
                      }
                    />
                  </Flex.Item>
                ))}
              </Flex>
            </Flex.Item>
          </Flex>
        </Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

const Reagent = (props) => {
  const { act, data } = useBackend();
  const { reagent } = props;

  return (
    <Flex.Item width="50%" className="TechFab__Reagent">
      <Flex justify="space-between" align="baseline">
        <Flex.Item grow px={1}>
          {reagent.name}
        </Flex.Item>
        <Flex.Item shrink px={1}>
          {formatBigNumber(reagent.volume, 4)}
        </Flex.Item>
        <Flex.Item>
          <Button
            content="Purge"
            onClick={() =>
              act('dispose', {
                reagent_id: reagent.id,
              })
            }
          />
        </Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

const TechFabHeader = (props) => {
  const { act, data } = useBackend();
  const {
    materials = {},
    materials_label = '0/unlimited', // Placeholder
    reagents = {},
    reagents_label = '',
  } = data;

  return (
    <Stack.Item>
      <Section>
        <Collapsible
          title={'Materials (' + materials_label + ')'}
          disabled={materials === null}
        >
          <Flex wrap="wrap" align="baseline">
            {materials &&
              Object.keys(materials).map((id) => {
                const material = materials[id];

                return <Material key={id} material={material} />;
              })}
          </Flex>
        </Collapsible>
        <Collapsible
          title={'Reagents (' + reagents_label + ')'}
          disabled={materials === null}
          buttons={
            <Button content="Purge all" onClick={() => act('disposeall')} />
          }
        >
          <Flex wrap="wrap" align="baseline">
            {reagents && Object.keys(reagents).length > 0 ? (
              Object.keys(reagents).map((id) => {
                const reagent = reagents[id];

                return <Reagent key={id} reagent={reagent} />;
              })
            ) : (
              <Flex.Item width="100%">
                <NoticeBox info>Reagent storage empty</NoticeBox>
              </Flex.Item>
            )}
          </Flex>
        </Collapsible>
      </Section>
    </Stack.Item>
  );
};

const ConditionalTooltip = (props) => {
  const { condition, children, ...rest } = props;

  if (!condition) {
    return children;
  }

  return <Tooltip {...rest}>{children}</Tooltip>;
};

const Recipe = (props) => {
  const { act, data } = useBackend();
  const { materials, reagents, efficiency, stack_to_mineral } = data;
  const { recipe } = props;

  const craft_amounts = [1, 5, 10];
  const substitutions = { 'bluespace crystal': 'bluespace_crystal' };

  let max = 50;

  const material_objects = Object.keys(recipe.materials).map((id) => {
    const material = materials[id] || materials[substitutions[id]];
    const total = material.amount;
    const amountNeeded =
      Math.floor(
        recipe.materials[id] / (recipe.efficiency_affects ? efficiency : 1),
      ) / stack_to_mineral;

    const mat_max = Math.floor(total / amountNeeded);
    max = Math.min(max, mat_max);
    return (
      <Box inline key={recipe.id + id} color={mat_max < 1 ? '#cb4848' : null}>
        {amountNeeded} {material.name}
      </Box>
    );
  });

  const reagent_objects = Object.keys(recipe.reagents).map((id) => {
    const reagent = reagents[id];
    const total = reagent?.volume || 0;
    const recipeReagent = recipe.reagents[id];
    const amountNeeded = Math.floor(recipeReagent.volume);
    const mat_max = Math.floor(total / amountNeeded);
    max = Math.min(max, mat_max);
    return (
      <Box inline key={recipe.id + id} color={mat_max < 1 ? '#cb4848' : null}>
        {amountNeeded} {recipeReagent.name}
      </Box>
    );
  });

  const reducefn = (list, cur) => {
    list.push(' | ');
    list.push(cur);
    return list;
  };

  return (
    <Flex.Item className="candystripe">
      <Flex align="center" py={0.6} className="TechFab__Recipe">
        <ConditionalTooltip
          condition={recipe.description && recipe.description !== 'Desc'}
          content={recipe.description}
          position="bottom-end"
        >
          <Flex.Item position="relative" width="100%">
            <Box className="TechFab__RecipeName">{recipe.name}</Box>
            <Box color="lightgray" pl={1}>
              {reagent_objects
                .reduce(reducefn, material_objects.reduce(reducefn, []))
                .slice(1)}
            </Box>
          </Flex.Item>
        </ConditionalTooltip>
        <Flex.Item grow basis="content">
          <Flex className="TechFab__ButtonsContainer">
            {craft_amounts.map((amount) => {
              return (
                <Flex.Item key={recipe.id + amount}>
                  <Button
                    className="TechFab__NumberButton"
                    content={'x' + amount}
                    disabled={amount > max}
                    onClick={() =>
                      act('build', { design_id: recipe.id, amount: amount })
                    }
                  />
                </Flex.Item>
              );
            })}
          </Flex>
        </Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

const TechFabContent = (props) => {
  const { act, data } = useBackend();
  const { categories = [], recipes = [], search, category } = data;

  const testSearch = createSearch(search || '', (recipe) => {
    return recipe.name;
  });

  const recipesDisplayed =
    search !== null
      ? recipes.filter(testSearch)
      : category
        ? recipes.filter((recipe) => recipe.category.includes(category))
        : null;

  if (recipesDisplayed) {
    return (
      <Stack.Item grow>
        <Section
          grow
          fill
          scrollable
          title={search !== null ? 'Search' : category}
          buttons={
            <Button
              icon="backspace"
              content="Back"
              onClick={() => act('mainmenu')}
            />
          }
        >
          <Flex direction="column">
            {recipesDisplayed.map((recipe) => {
              return <Recipe key={recipe.id} recipe={recipe} />;
            })}
          </Flex>
        </Section>
      </Stack.Item>
    );
  } else {
    return (
      <Stack.Item grow>
        <Section title="Categories" grow fill scrollable>
          <Flex wrap="wrap" justify="space-between" align="center">
            {categories.map((category) => {
              return (
                <Flex.Item key={category} minWidth="50%" p={0.2}>
                  <Button
                    content={category}
                    fluid
                    onClick={() => act('category', { category: category })}
                  />
                </Flex.Item>
              );
            })}
          </Flex>
        </Section>
      </Stack.Item>
    );
  }
};
