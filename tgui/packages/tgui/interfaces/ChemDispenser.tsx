import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Dimmer, Flex, Icon, Input, LabeledList, ProgressBar, Section, Stack, Table, TextArea, Tooltip } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';
import { require } from 'tgui-dev-server/require';

type Reagent = {
  name: string;
  volume: number;
  path: string;
};

interface ExtendedReagentInfo extends Reagent {
  description: string;
  addiction: number;
  overdose: number;
}

type RecipeHintTypes = 'explosion' | 'explosion_radius' | 'safety';

type Recipe = {
  name: string;
  results: ExtendedReagentInfo[];
  required_reagents: Reagent[];
  required_catalysts: { [path: string]: number };
  required_container: string;
  required_other: boolean;
  is_cold_recipe: boolean;
  required_temp: number;
  id: string;
  hints: Record<RecipeHintTypes, string | number[]>;
};

interface SatisfiedRecipe extends Recipe {
  rating: number;
}

type ChemDispenserData = {
  amount: number;
  energy: number;
  maxEnergy: number;
  isBeakerLoaded: boolean;
  beakerContents: Reagent[];
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerTransferAmounts: number[];
  containerType: string;
  chemicals: {
    title: string;
    id: string;
  }[];
  reactions_list: Recipe[];
};

/**
 *
 * @param contents The current contents of the beaker
 * @param recipes All craftable recipes
 * @returns All recipes that can be made with any of the ingredients currently contained in the beaker.
 */
const compile_recipes = (contents: { path: string; volume: number }[], recipes: Recipe[]): SatisfiedRecipe[] => {
  let result: SatisfiedRecipe[] = [];
  const [unlocked_recipes, set_unlocked_recipes] = useSharedState('unlocked_recipes', {});
  const [search_term] = useSharedState('search_term', '');
  const [selected_recipe] = useSharedState<Recipe | null>('selected_recipe', null);
  let initial_length = Object.keys(unlocked_recipes).length;
  if (selected_recipe !== null) {
    // Build a recipe lookup list
    const recipe_lookup: { [path: string]: Recipe[] } = {};
    for (const recipe of recipes) {
      if (!unlocked_recipes[recipe.name]) {
        continue;
      }
      for (const result of recipe.results) {
        if (recipe_lookup[result.path]) {
          recipe_lookup[result.path].push(recipe);
        } else {
          recipe_lookup[result.path] = [recipe];
        }
      }
    }
    // Find all the relevant recipes
    let used_recipes: { [recipe_name: string]: boolean } = {};
    let search_list: Recipe[] = [selected_recipe];
    let depth = 100;
    while (search_list.length > 0) {
      const head = search_list.pop();
      if (used_recipes[head!.name]) {
        continue;
      }
      used_recipes[head!.name] = true;
      for (const requirement of head!.required_reagents) {
        const recipes = recipe_lookup[requirement.path];
        if (!recipes) {
          continue;
        }
        recipes.forEach((x) => search_list.push(x));
      }
      result.push({ rating: depth--, ...head! });
    }
  } else if (search_term.length > 0) {
    for (const recipe of recipes) {
      if (!unlocked_recipes[recipe.name]) {
        continue;
      }
      if (recipe.name?.toLowerCase().includes(search_term.toLowerCase())) {
        result.push({ rating: 1, ...recipe });
      }
    }
  } else if (contents.length === 0) {
    for (const recipe of recipes) {
      if (!unlocked_recipes[recipe.name]) {
        continue;
      }
      let matches = 0;
      for (const required of recipe.required_reagents) {
        if (contents.some((x) => x.path === required.path && x.volume >= required.volume)) {
          matches++;
        }
      }
      result.push({ rating: matches, ...recipe });
    }
  } else {
    for (const recipe of recipes) {
      if (recipe.required_container || recipe.required_other) {
        continue;
      }
      let matches = 0;
      for (const required of recipe.required_reagents) {
        if (contents.some((x) => x.path === required.path && x.volume >= required.volume)) {
          matches++;
        }
      }
      if (matches > 0) {
        result.push({ rating: matches, ...recipe });
        unlocked_recipes[recipe.name] = 1;
      }
    }
    if (initial_length !== Object.keys(unlocked_recipes).length) {
      set_unlocked_recipes(unlocked_recipes);
    }
  }
  return result;
};

const render_hint = (hint_type: RecipeHintTypes, message: string | number[]) => {
  let hint_icon: string;
  let colour: string;
  let tooltip = message;
  switch (hint_type) {
    case 'explosion':
      hint_icon = 'explosion';
      colour = 'yellow';
      break;
    case 'explosion_radius':
      hint_icon = 'circle-notch';
      colour = 'yellow';
      tooltip = (
        <Table>
          <Table.Row>
            <Table.Cell mr={1} bold>
              Amt.
            </Table.Cell>
            <Table.Cell mr={1}>10</Table.Cell>
            <Table.Cell mr={1}>50</Table.Cell>
            <Table.Cell mr={1}>100</Table.Cell>
            <Table.Cell mr={1}>200</Table.Cell>
            <Table.Cell mr={1}>500</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell bold>Radius</Table.Cell>
            <Table.Cell>{(message as number[])[0]}</Table.Cell>
            <Table.Cell>{(message as number[])[1]}</Table.Cell>
            <Table.Cell>{(message as number[])[2]}</Table.Cell>
            <Table.Cell>{(message as number[])[3]}</Table.Cell>
            <Table.Cell>{(message as number[])[4]}</Table.Cell>
          </Table.Row>
        </Table>
      );
      break;
    case 'safety':
      hint_icon = 'radiation';
      colour = 'yellow';
      break;
  }
  return (
    <Tooltip content={tooltip}>
      <Icon name={hint_icon} color={colour} pt={0.8} pl={1} pr={2} />
    </Tooltip>
  );
};

export const ChemDispenser = (_props) => {
  const { act, data } = useBackend<ChemDispenserData>();
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = data.beakerContents || [];
  const [unlocked_recipes] = useSharedState('unlocked_recipes', {});
  const [search_term, set_search_term] = useSharedState('search_term', '');
  const shown_recipes = compile_recipes(data.beakerContents, data.reactions_list).sort((a, b) => b.rating - a.rating);
  const [selected_recipe, set_selected_recipe] = useSharedState<Recipe | null>('selected_recipe', null);
  return (
    <Window width={695} height={720}>
      <Window.Content className="chem_dispenser">
        <div className="root">
          <Section
            title="Status"
            buttons={
              <div className="discover_count">
                Discovered <AnimatedNumber initial={0} value={Object.keys(unlocked_recipes).length} /> recipe
                {Object.keys(unlocked_recipes).length !== 1 && 's'}
              </div>
            }>
            <LabeledList>
              <LabeledList.Item label="Energy">
                <ProgressBar value={data.energy / data.maxEnergy}>{toFixed(data.energy) + ' units'}</ProgressBar>
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Section
            scrollable
            fill
            title="Recipes"
            className="grow"
            buttons={
              selected_recipe ? (
                <Button
                  content="Return"
                  onClick={() => {
                    set_selected_recipe(null);
                    set_search_term('');
                  }}
                  icon="arrow-left"
                />
              ) : (
                <>
                  Search discovered:
                  <Input
                    value={search_term}
                    minWidth="240px"
                    ml={1}
                    onInput={(_, val) => {
                      if (val !== search_term) {
                        set_search_term(val);
                      }
                    }}
                  />
                </>
              )
            }>
            <Box className="recipe_container" mr={-1}>
              {shown_recipes.map((recipe) => (
                <div
                  className={classes(['recipe_box'])}
                  key={recipe.id}
                  onClick={() => {
                    if (
                      recipe.required_reagents.every(
                        (x) => beakerContents.some((y) => y.path === x.path) || data.chemicals.some((y) => x.name === y.title)
                      )
                    ) {
                      let has_all = true;
                      for (const chem of recipe.required_reagents) {
                        // we already have this component
                        if (beakerContents.some((y) => y.path === chem.path && y.volume >= chem.volume)) {
                          continue;
                        }
                        has_all = false;
                        const printable_chem = data.chemicals.filter((x) => x.title === chem.name)[0];
                        if (!printable_chem) {
                          continue;
                        }
                        act('dispense', {
                          reagent: printable_chem.id,
                          multiplier: chem.volume,
                        });
                      }
                      // If we have all the reagents already, make it again anyway
                      if (has_all) {
                        for (const chem of recipe.required_reagents) {
                          const printable_chem = data.chemicals.filter((x) => x.title === chem.name)[0];
                          if (!printable_chem) {
                            continue;
                          }
                          act('dispense', {
                            reagent: printable_chem.id,
                            multiplier: chem.volume,
                          });
                        }
                      }
                      return;
                    }
                    if (selected_recipe) {
                      return;
                    }
                    set_selected_recipe(recipe);
                  }}>
                  <div
                    className={classes([
                      'recipe_title',
                      !!recipe.required_reagents.every(
                        (x) => beakerContents.some((y) => y.path === x.path) || data.chemicals.some((y) => x.name === y.title)
                      ) && 'create',
                    ])}>
                    {Object.entries(recipe.hints).map((x) => {
                      return render_hint(x[0] as RecipeHintTypes, x[1]);
                    })}
                    {recipe.results.map((x) => (
                      <>
                        {!!x.description && (
                          <Tooltip content={x.description}>
                            <Icon name="info" color="white" pt={0.8} pl={1} pr={2} />
                          </Tooltip>
                        )}
                        {!!x.addiction && (
                          <Tooltip content={'Causes addictions when more than ' + x.addiction + 'u is ingested.'}>
                            <Icon name="pills" color="red" pt={0.8} pl={1} pr={2} />
                          </Tooltip>
                        )}
                        {!!x.overdose && (
                          <Tooltip content={'Causes an overdose when more than ' + x.overdose + 'u is ingested.'}>
                            <Icon name="syringe" color="red" pt={0.8} pl={1} pr={2} />
                          </Tooltip>
                        )}
                      </>
                    ))}
                    {recipe.required_temp > 0 &&
                      (recipe.is_cold_recipe ? (
                        <Tooltip content={'Maximum temp: ' + recipe.required_temp + 'K'}>
                          <Icon name="snowflake" color="blue" pt={0.8} pl={1} pr={2} />
                        </Tooltip>
                      ) : (
                        <Tooltip content={'Minimum temp: ' + recipe.required_temp + 'K'}>
                          <Icon name="fire-flame-curved" color="orange" pt={0.8} pl={1} pr={2} />
                        </Tooltip>
                      ))}
                    {recipe.name}
                  </div>
                  <div className="recipe_required">
                    {recipe.required_reagents.map((x) => (
                      <div
                        className={classes([
                          'recipe_ingredient',
                          !!beakerContents.some((y) => y.name === x.name && y.volume >= x.volume) && 'satisfied',
                          !!data.chemicals.some((y) => y.title === x.name) && 'insertable',
                        ])}
                        key={x.path}>
                        {x.volume} {x.name}
                      </div>
                    ))}
                    {Object.entries(recipe.required_catalysts).map((x) => (
                      <Tooltip key={x[0]} content={'Catalyst: Not consumed by the reaction'}>
                        <div className="recipe_ingredient catalyst" key={x[0]}>
                          {x[0].substring(x[0].lastIndexOf('/') + 1)}
                        </div>
                      </Tooltip>
                    ))}
                  </div>
                </div>
              ))}
              {shown_recipes.length === 0 && !!search_term && (
                <div className="no_recipes">
                  <div>No discovered recipes matching the search term &apos;{search_term}&apos;.</div>
                  <br />
                  <div>Add or create new reagents to unlock more.</div>
                </div>
              )}
              {shown_recipes.length === 0 && Object.keys(unlocked_recipes).length === 0 && !search_term && (
                <div className="no_recipes">
                  <div>No recipes discovered.</div>
                  <br />
                  <div>Add some reagents to the beaker to start unlocking recipes.</div>
                </div>
              )}
              {shown_recipes.length === 0 && Object.keys(unlocked_recipes).length > 0 && !search_term && (
                <div className="no_recipes">
                  <div>No recipes to show.</div>
                  <br />
                  <div>Only recipes that can be made from components in the beaker will be shown. Use the search function to find more, or empty the beaker to start again.</div>
                </div>
              )}
            </Box>
          </Section>
          <Section
            title="Dispense"
            buttons={beakerTransferAmounts.map((amount) => (
              <Button
                key={amount}
                icon="plus"
                selected={amount === data.amount}
                content={amount}
                onClick={() =>
                  act('amount', {
                    target: amount,
                  })
                }
              />
            ))}>
            <Box mr={-1}>
              {data.chemicals.map((chemical) => (
                <Button
                  key={chemical.id}
                  icon="tint"
                  width="129.5px"
                  lineHeight="21px"
                  content={chemical.title}
                  onClick={() =>
                    act('dispense', {
                      reagent: chemical.id,
                    })
                  }
                />
              ))}
            </Box>
          </Section>
          <Section
            title="Beaker"
            buttons={beakerTransferAmounts.map((amount) => (
              <Button key={amount} icon="minus" content={amount} onClick={() => act('remove', { amount })} />
            ))}
            className="beaker_section">
            <div className="beaker_labelled_part">
              <div className="beaker_label beaker_label_part">Beaker</div>
              <div className="beaker_content_part">
                {(data.isBeakerLoaded && (
                  <>
                    <AnimatedNumber initial={0} value={data.beakerCurrentVolume} />/{data.beakerMaxVolume} units
                  </>
                )) ||
                  'No beaker'}
              </div>
              {!!data.isBeakerLoaded && (
                <Button icon="eject" content="Eject" disabled={!data.isBeakerLoaded} onClick={() => act('eject')} />
              )}
            </div>
            <div className="beaker_labelled_part">
              <div className="beaker_label beaker_label_part">Contents</div>
              <div className="beaker_contents beaker_content_part">
                <Box color="label">{(!data.isBeakerLoaded && 'N/A') || (beakerContents.length === 0 && 'Nothing')}</Box>

                {beakerContents.map((chemical) => (
                  <div className="beaker_chemical beaker_label" key={chemical.path}>
                    <AnimatedNumber initial={0} value={chemical.volume} /> units of {chemical.name}
                  </div>
                ))}
              </div>
            </div>
          </Section>
        </div>
      </Window.Content>
    </Window>
  );
};
