import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, NoticeBox, Section, Collapsible, Table } from '../components';
import { Window } from '../layouts';

export const Stack = (props, context) => {
  const { act, data } = useBackend(context);

  const { amount, recipes = [] } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const testSearch = createSearch(searchText, (item) => {
    return item.title;
  });

  const filterRecipes = (recipes, searchText) => {
    return recipes
      .filter((recipe) => recipe.title !== undefined)
      .map((recipe) =>
        recipe.sub_recipes
          ? {
            'title': recipe.title,
            'sub_recipes': filterRecipes(recipe.sub_recipes, searchText),
          }
          : recipe
      )
      .filter((recipe) => (recipe.sub_recipes ? recipe.sub_recipes.length > 0 : testSearch(recipe)));
  };

  const doSearch = searchText.length > 0;

  const items = (doSearch && filterRecipes(recipes, searchText)) || recipes;

  const height = Math.max(94 + recipes.length * 26, 250);

  return (
    <Window width={400} height={Math.min(height, 500)}>
      <Window.Content scrollable>
        <Section
          title={'Amount: ' + amount}
          buttons={
            <Fragment>
              Search
              <Input autoFocus value={searchText} onInput={(e, value) => setSearchText(value)} mx={1} />
            </Fragment>
          }>
          {(items.length === 0 && <NoticeBox>No recipes found.</NoticeBox>) || (
            <RecipeList recipes={items} do_sort={doSearch} expand={doSearch} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RecipeList = (props, context) => {
  const { act, data } = useBackend(context);

  const { recipes, do_sort, expand } = props;

  const display_recipes = do_sort
    ? sortBy((recipe) => recipe.title.toLowerCase())(recipes.filter((recipe) => recipe.title !== undefined))
    : recipes;

  return display_recipes.map((recipe) => {
    if (recipe.spacer) {
      return <hr key="spacer" />;
    } else if (recipe.sub_recipes) {
      return (
        <Collapsible color="label" title={recipe.title} key={recipe.title} open={expand}>
          <Box ml={1}>
            <RecipeList recipes={recipe.sub_recipes} do_sort={do_sort} expand={expand} />
          </Box>
        </Collapsible>
      );
    } else {
      return <Recipe title={recipe.title} key={recipe.ref} recipe={recipe} />;
    }
  });
};

const buildMultiplier = (recipe, amount) => {
  if (recipe.req_amount > amount) {
    return 0;
  }

  return Math.floor(amount / recipe.req_amount);
};

const Multipliers = (props, context) => {
  const { act, data } = useBackend(context);

  const { recipe, maxMultiplier } = props;

  const maxM = Math.min(maxMultiplier, Math.floor(recipe.max_res_amount / recipe.res_amount));

  const multipliers = [5, 10, 25];

  let finalResult = [];

  for (const multiplier of multipliers) {
    if (maxM >= multiplier) {
      finalResult.push(
        <Button
          content={multiplier * recipe.res_amount + 'x'}
          onClick={() =>
            act('make', {
              ref: recipe.ref,
              multiplier: multiplier,
            })
          }
        />
      );
    }
  }

  if (multipliers.indexOf(maxM) === -1) {
    finalResult.push(
      <Button
        content={maxM * recipe.res_amount + 'x'}
        onClick={() =>
          act('make', {
            ref: recipe.ref,
            multiplier: maxM,
          })
        }
      />
    );
  }

  return finalResult;
};

const Recipe = (props, context) => {
  const { act, data } = useBackend(context);

  const { amount } = data;

  const { recipe, title } = props;

  const { res_amount, max_res_amount, req_amount, ref } = recipe;

  let buttonName = title;
  buttonName += ' (';
  buttonName += req_amount + ' ';
  buttonName += 'sheet' + (req_amount > 1 ? 's' : '');
  buttonName += ')';

  if (res_amount > 1) {
    buttonName = res_amount + 'x ' + buttonName;
  }

  const maxMultiplier = buildMultiplier(recipe, amount);

  return (
    <Box mb={1}>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Button
              fluid
              disabled={!maxMultiplier}
              icon="wrench"
              content={buttonName}
              onClick={() =>
                act('make', {
                  ref: recipe.ref,
                  multiplier: 1,
                })
              }
            />
          </Table.Cell>
          {max_res_amount > 1 && maxMultiplier > 1 && (
            <Table.Cell collapsing>
              <Multipliers recipe={recipe} maxMultiplier={maxMultiplier} />
            </Table.Cell>
          )}
        </Table.Row>
      </Table>
    </Box>
  );
};
