import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Dimmer, Flex, Icon, LabeledList, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

const RecipeOptions = (_props, context) => {
  const { act, data } = useBackend(context);
  const [deletingRecipes, setDeletingRecipes] = useLocalState(context, 'deletingRecipes', false);
  const [_clearingRecipes, setClearingRecipes] = useLocalState(context, 'clearingRecipes', false);
  const recording = !!data.recordingRecipe;
  return (
    <>
      {!recording && (
        <Box inline mx={1}>
          <Button color="transparent" content="Clear recipes" onClick={() => setClearingRecipes(true)} />
        </Box>
      )}
      {!recording && (
        <Button
          icon="trash"
          color={deletingRecipes ? 'red' : 'transparent'}
          content={deletingRecipes ? 'Deleting' : 'Delete'}
          onClick={() => setDeletingRecipes(!deletingRecipes)}
        />
      )}
      {!recording && (
        <Button icon="circle" disabled={!data.isBeakerLoaded} content="Record" onClick={() => act('record_recipe')} />
      )}
      {recording && <Button icon="ban" color="transparent" content="Discard" onClick={() => act('cancel_recording')} />}
      {recording && <Button icon="save" color="green" content="Save" onClick={() => act('save_recording')} />}
    </>
  );
};

const RecipeClearAllDimmer = (_props, context) => {
  const { act } = useBackend(context);
  const [_clearingRecipes, setClearingRecipes] = useLocalState(context, 'clearingRecipes', false);
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon color="red" name="trash" size={10} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px">
          <Stack vertical textAlign="center">
            <Stack.Item>
              Are you sure you want to delete <b>all of your recipes</b>?
            </Stack.Item>
            <Stack.Item>
              This is <b>irreversible</b>!
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                color="good"
                content="Keep"
                onClick={() => {
                  setClearingRecipes(null);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="bad"
                content="Delete"
                onClick={() => {
                  act('clear_all_recipes');
                  setClearingRecipes(null);
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const RecipeButton = (props, context) => {
  const { act } = useBackend(context);
  const { recipe } = props;
  const [deletingRecipes] = useLocalState(context, 'deletingRecipes', false);
  return (
    <Button
      icon={deletingRecipes ? 'trash' : 'tint'}
      width="129.5px"
      lineHeight="21px"
      content={recipe.name}
      color={!!deletingRecipes && 'red'}
      onClick={() => {
        act(deletingRecipes ? 'delete_recipe' : 'dispense_recipe', {
          recipe: recipe.name,
        });
      }}
    />
  );
};

export const ChemDispenser = (_props, context) => {
  const { act, data } = useBackend(context);
  const recording = !!data.recordingRecipe;
  const [clearingRecipes] = useLocalState(context, 'clearingRecipes', false);
  // TODO: Change how this piece of shit is built on server side
  // It has to be a list, not a fucking OBJECT!
  const recipes = Object.keys(data.recipes).map((name) => ({
    name,
    contents: data.recipes[name],
  }));
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents =
    (recording &&
      Object.keys(data.recordingRecipe).map((id) => ({
        id,
        name: toTitleCase(id.replace(/_/, ' ')),
        volume: data.recordingRecipe[id],
      }))) ||
    data.beakerContents ||
    [];
  return (
    <Window width={565} height={620}>
      {!!clearingRecipes && <RecipeClearAllDimmer />}
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={
            recording && (
              <Box inline mx={1} color="red">
                <Icon name="circle" mr={1} />
                Recording
              </Box>
            )
          }>
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar value={data.energy / data.maxEnergy}>{toFixed(data.energy) + ' units'}</ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Recipes" buttons={<RecipeOptions />}>
          <Box mr={-1}>
            {recipes.map((recipe) => (
              <RecipeButton recipe={recipe} key={recipe.name} />
            ))}
            {recipes.length === 0 && <Box color="light-gray">No recipes.</Box>}
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
            <Button key={amount} icon="minus" disabled={recording} content={amount} onClick={() => act('remove', { amount })} />
          ))}>
          <LabeledList>
            <LabeledList.Item
              label="Beaker"
              buttons={
                !!data.isBeakerLoaded && (
                  <Button icon="eject" content="Eject" disabled={!data.isBeakerLoaded} onClick={() => act('eject')} />
                )
              }>
              {(recording && 'Virtual beaker') ||
                (data.isBeakerLoaded && (
                  <>
                    <AnimatedNumber initial={0} value={data.beakerCurrentVolume} />/{data.beakerMaxVolume} units
                  </>
                )) ||
                'No beaker'}
            </LabeledList.Item>
            <LabeledList.Item label="Contents">
              <Box color="label">
                {(!data.isBeakerLoaded && !recording && 'N/A') || (beakerContents.length === 0 && 'Nothing')}
              </Box>
              {beakerContents.map((chemical) => (
                <Box key={chemical.name} color="label">
                  <AnimatedNumber initial={0} value={chemical.volume} /> units of {chemical.name}
                </Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
