import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Dimmer, Divider, Flex, Icon, Input, LabeledList, Popper, ProgressBar, Section, Stack, Table, TextArea, Tooltip } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';
import { require } from 'tgui-dev-server/require';
import { createLogger } from 'tgui/logging';
import { storage } from 'common/storage';

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
  reaction_tags: ReactionTags;
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
  default_filters: ReactionTags;
};

/**
 * Reaction tags defined by the backend
 */
enum ReactionTags {
  None = 0,
  BRUTE = 1 << 0,
  BURN = 1 << 1,
  TOXIN = 1 << 2,
  OXY = 1 << 3,
  CLONE = 1 << 4,
  HEALING = 1 << 5,
  DAMAGING = 1 << 6,
  EXPLOSIVE = 1 << 7,
  OTHER = 1 << 8,
  ORGAN = 1 << 9,
  DRINK = 1 << 10,
  FOOD = 1 << 11,
  SLIME = 1 << 12,
  DRUG = 1 << 13,
  CHEMICAL = 1 << 14,
  PLANT = 1 << 15,
}

/**
 * A cache of the negative scores for items, since a chem dispenser is
 * unlikely to unlock new recipes while the UI is open.
 */
const negative_score_cache: { [path: string]: number } = {};

/**
 * The previous list of satisfied recipes, cached to prevent
 * unnecessary recalculations.
 */
let recipe_list: SatisfiedRecipe[] = [];

/**
 * The previous contents of the beaker, used for triggering updates
 * to the UI when necessary.
 */
let last_contents: { path: string; volume: number }[] = [];

const logger = createLogger('ChemDispenser');

/**
 * Checks if we need an update, to prevent rebuildin the chemical array
 * unnecessarilly
 * @param after The new data
 * @returns Returns true if the after data is different to the previous data
 */
const needs_update = (after: { path: string; volume: number }[]) => {
  if (last_contents.length !== after.length) {
    return true;
  }
  for (let i = 0; i < last_contents.length; i++) {
    if (last_contents[i].path !== after[i].path || last_contents[i].volume !== after[i].volume) {
      return true;
    }
  }
  return false;
};

/**
 *
 * @param contents The current contents of the beaker
 * @param recipes All craftable recipes
 * @returns All recipes that can be made with any of the ingredients currently contained in the beaker.
 */
const compile_recipes = (
  contents: { path: string; volume: number }[],
  recipes: Recipe[],
  favourites: { [id: string]: boolean }
): SatisfiedRecipe[] => {
  if (recipe_list.length && !needs_update(contents)) {
    return recipe_list;
  }
  const { act, data } = useBackend<ChemDispenserData>();
  let result: SatisfiedRecipe[] = [];
  const [unlocked_recipes, set_unlocked_recipes] = useSharedState('unlocked_recipes', {});
  const [search_term] = useSharedState('search_term', '');
  const [selected_recipe] = useSharedState<Recipe | null>('selected_recipe', null);
  const [filters] = useSharedState('filters', 0);
  let initial_length = Object.keys(unlocked_recipes).length;
  if (selected_recipe !== null) {
    // Build a recipe lookup list
    const recipe_lookup: { [path: string]: Recipe[] } = {};
    for (const recipe of recipes) {
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
      if (head!.required_container || head!.required_other) {
        continue;
      }
      if (used_recipes[head!.name]) {
        continue;
      }
      used_recipes[head!.name] = true;
      // If our result is a base reagent, don't show it
      if (head?.results.length === 1 && data.chemicals.some((x) => x.title === head?.results[0].name)) {
        continue;
      }
      for (const requirement of head!.required_reagents) {
        const recipes = recipe_lookup[requirement.path];
        if (!recipes) {
          continue;
        }
        recipes.forEach((x) => search_list.push(x));
      }
      // Always show dependants, regardless of unlock status
      // If we view something with hidden recipes, we actually
      // unlock them permanently
      unlocked_recipes[head!.name] = 1;
      result.push({ rating: depth++, ...head! });
    }
  } else if (search_term.length > 0) {
    for (const recipe of recipes) {
      if (recipe.required_container || recipe.required_other) {
        continue;
      }
      if (recipe.name?.toLowerCase().includes(search_term.toLowerCase())) {
        result.push({ rating: 1, ...recipe });
      }
    }
  } else {
    for (const recipe of recipes) {
      if (recipe.required_container || recipe.required_other) {
        continue;
      }
      let matches = 100;
      let unlocked = false;
      // Skip filtered recipes
      if (filters === 0) {
        if ((recipe.reaction_tags & data.default_filters) === 0) {
          continue;
        }
      } else {
        // Must match all the filters to be shown
        if ((recipe.reaction_tags & filters) !== filters) {
          continue;
        }
      }
      // Always show favourited recipes, regardless of unlock status
      if (favourites[recipe.id]) {
        matches += 100;
      }
      // Gain points if we have the reagent already
      if (contents.length > 0) {
        for (const required of recipe.required_reagents) {
          if (contents.some((x) => x.path === required.path && x.volume >= required.volume)) {
            matches += 2;
            unlocked = true;
            continue;
          }
        }
      }
      // Lose points if we can't add the reagent
      if (negative_score_cache[recipe.id]) {
        // -1 point for every reagent that we can't add
        matches -= negative_score_cache[recipe.id];
      } else {
        let negativePoints = 0;
        for (const required of recipe.required_reagents) {
          if (!data.chemicals.some((x) => required.name === x.title)) {
            negativePoints++;
          }
        }
        negative_score_cache[recipe.id] = negativePoints;
        matches -= negativePoints;
      }
      if (!unlocked && !unlocked_recipes[recipe.name] && filters === 0 && !favourites[recipe.id]) {
        continue;
      }
      result.push({ rating: matches, ...recipe });
      if (filters === 0 && unlocked && !favourites[recipe.id]) {
        unlocked_recipes[recipe.name] = 1;
      }
    }
  }
  if (initial_length !== Object.keys(unlocked_recipes).length) {
    set_unlocked_recipes(unlocked_recipes);
  }
  recipe_list = result;
  last_contents = contents;
  return result;
};

const render_hint = (hint_type: RecipeHintTypes, message: string | number[]) => {
  let hint_icon: string;
  let colour: string;
  let tooltip: any = message;
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

/**
 * Indicates whether we are waiting to save data in the storage,
 * so we don't queue loads of updates at once.
 */
let waitingForSave = false;

export const ChemDispenser = (_props) => {
  const { act, data } = useBackend<ChemDispenserData>();
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = data.beakerContents || [];
  const [unlocked_recipes] = useSharedState('unlocked_recipes', {});
  const [search_term, set_search_term] = useSharedState('search_term', '');
  const [selected_recipe, set_selected_recipe] = useSharedState<Recipe | null>('selected_recipe', null);
  const [favourites, setFavourites] = useLocalState<{ [id: string]: boolean } | undefined>('favourites', undefined);
  const [filters, setFilters] = useSharedState('filters', 0);
  const [showFilters, setShowFilters] = useLocalState('show_filters', false);

  let usedFavourites: { [id: string]: boolean } = favourites!;

  if (favourites === undefined) {
    logger.log('Fetching store...');
    storage.get('chem_dispenser_favourites').then((result) => {
      logger.log('Store found', result);
      // Nothing stored
      if (result === undefined) {
        return;
      }
      if (typeof result === 'object' && !Array.isArray(result) && result !== null) {
        // Good enough
        recipe_list = [];
        setFavourites(result);
      } else {
        // Invalid storage
        storage.set('chem_dispenser_favourites', {});
      }
    });
    usedFavourites = {};
  }

  const shown_recipes = compile_recipes(data.beakerContents, data.reactions_list, usedFavourites).sort(
    (a, b) => b.rating - a.rating
  );

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
            autofocus
            fill
            title="Recipes"
            className="grow"
            buttons={
              selected_recipe ? (
                <Button
                  content="Return"
                  onClick={() => {
                    recipe_list = [];
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
                        recipe_list = [];
                        set_search_term(val);
                      }
                    }}
                  />
                  <Popper
                    options={{
                      placement: 'left-start',
                    }}
                    popperContent={
                      (showFilters && (
                        <div className="chem_dispenser_filter_modal">
                          <Stack vertical>
                            <Button
                              content={'Clear Filters'}
                              onClick={() => {
                                recipe_list = [];
                                setFilters(ReactionTags.None);
                                setShowFilters(false);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.BRUTE ? 'orange' : 'transparent'}
                              icon="hand-fist"
                              content="Brute"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.BRUTE);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.BURN ? 'orange' : 'transparent'}
                              icon="fire"
                              content="Burn"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.BURN);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.TOXIN ? 'orange' : 'transparent'}
                              icon="radiation"
                              content="Toxin"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.TOXIN);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.OXY ? 'orange' : 'transparent'}
                              icon="wind"
                              content="Suffocation"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.OXY);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.CLONE ? 'orange' : 'transparent'}
                              icon="person"
                              content="Clone"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.CLONE);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.ORGAN ? 'orange' : 'transparent'}
                              icon="lungs"
                              content="Organ"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.ORGAN);
                              }}
                            />
                            <Divider />
                            <Button
                              color={filters & ReactionTags.HEALING ? 'green' : 'transparent'}
                              icon="kit-medical"
                              content="Healing"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.HEALING);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.DAMAGING ? 'green' : 'transparent'}
                              icon="book-skull"
                              content="Damaging"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.DAMAGING);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.EXPLOSIVE ? 'green' : 'transparent'}
                              icon="explosion"
                              content="Explosive"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.EXPLOSIVE);
                              }}
                            />
                            <Divider />
                            <Button
                              color={filters & ReactionTags.DRINK ? 'blue' : 'transparent'}
                              icon="mug-saucer"
                              content="Drink"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.DRINK);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.FOOD ? 'blue' : 'transparent'}
                              icon="bacon"
                              content="Food"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.FOOD);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.SLIME ? 'blue' : 'transparent'}
                              icon="droplet"
                              content="Slime"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.SLIME);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.DRUG ? 'blue' : 'transparent'}
                              icon="joint"
                              content="Drug"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.DRUG);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.CHEMICAL ? 'blue' : 'transparent'}
                              icon="flask"
                              content="Chemical"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.CHEMICAL);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.PLANT ? 'blue' : 'transparent'}
                              icon="seedling"
                              content="Plant"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.PLANT);
                              }}
                            />
                            <Button
                              color={filters & ReactionTags.OTHER ? 'blue' : 'transparent'}
                              icon="ellipsis"
                              content="Other"
                              onClick={() => {
                                recipe_list = [];
                                setFilters(filters ^ ReactionTags.OTHER);
                              }}
                            />
                          </Stack>
                        </div>
                      )) as any
                    }>
                    <Button
                      icon="arrow-down-short-wide"
                      color={filters !== 0 && 'green'}
                      ml={0.5}
                      onClick={() => {
                        setShowFilters(!showFilters);
                      }}
                    />
                  </Popper>
                </>
              )
            }>
            <Box className="recipe_container" mr={-1}>
              {shown_recipes.map((recipe) => (
                <div
                  className={classes([
                    'recipe_box',
                    recipe.required_reagents.every(
                      (x) => beakerContents.some((y) => y.path === x.path) || data.chemicals.some((y) => x.name === y.title)
                    ) && 'craftable',
                  ])}
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
                    recipe_list = [];
                    set_selected_recipe(recipe);
                  }}>
                  <div
                    className={classes(['favourite', !usedFavourites[recipe.id] && 'unfavourited'])}
                    onClick={(e) => {
                      e.stopPropagation();
                      if (usedFavourites[recipe.id]) {
                        delete usedFavourites[recipe.id];
                      } else {
                        usedFavourites[recipe.id] = true;
                      }
                      recipe_list = [];
                      setFavourites(usedFavourites);
                      if (!waitingForSave) {
                        waitingForSave = true;
                        window.setTimeout(() => {
                          waitingForSave = false;
                          storage.set('chem_dispenser_favourites', usedFavourites);
                        }, 5000);
                      }
                    }}>
                    <Icon name={usedFavourites[recipe.id] ? 'star' : 'star-o'} />
                  </div>
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
                  <div>
                    Only recipes that can be made from components in the beaker will be shown. Use the search function to find
                    more, or empty the beaker to start again.
                  </div>
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
