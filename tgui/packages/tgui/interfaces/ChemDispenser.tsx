import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Dimmer, Flex, Icon, Input, LabeledList, ProgressBar, Section, Stack, TextArea, Tooltip } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';

type Reagent = {
  name: string;
  volume: number;
  path: string;
};

type Recipe = {
  name: string;
  results: { [path: string]: number };
  required_reagents: Reagent[];
  required_catalysts: { [path: string]: number };
  required_container: string;
  required_other: boolean;
  is_cold_recipe: boolean;
  required_temp: number;
  id: string;
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
  const [search_term] = useLocalState('search_term', '');
  let initial_length = Object.keys(unlocked_recipes).length;
  if (search_term.length > 0) {
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

export const ChemDispenser = (_props) => {
  const { act, data } = useBackend<ChemDispenserData>();
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = data.beakerContents || [];
  const [unlocked_recipes] = useSharedState('unlocked_recipes', {});
  const [search_term, set_search_term] = useLocalState('search_term', '');
  const shown_recipes = compile_recipes(data.beakerContents, data.reactions_list).sort((a, b) => b.rating - a.rating);
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
            }>
            <Box className="recipe_container" mr={-1}>
              {shown_recipes.map((recipe) => (
                <div className="recipe_box" key={recipe.name}>
                  <div className="recipe_title">{recipe.name}</div>
                  <div className="recipe_required">
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
                    {recipe.required_reagents.map((x) => (
                      <div
                        className={classes([
                          'recipe_ingredient',
                          !!beakerContents.some((y) => y.name === x.name) && 'satisfied',
                        ])}
                        key={x.path}>
                        {x.name}
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
