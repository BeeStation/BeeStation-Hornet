import { useBackend } from '../../backend';
import { Box, Button, Chart, Flex, Icon, LabeledList, Tooltip } from '../../components';

export const RecipeLookup = (props, context) => {
  const { recipe, bookmarkedReactions } = props;
  const { act, data } = useBackend(context);
  if (!recipe) {
    return (
      <Box>
        No reaction selected!
      </Box>
    );
  }

  const getReaction = id => {
    return data.master_reaction_list.filter(reaction => (
      reaction.id === id
    ));
  };

  const addBookmark = bookmark => {
    bookmarkedReactions.add(bookmark);
  };

  return (
    <LabeledList>
      <LabeledList.Item bold label="Recipe">
        <Icon name="circle" mr={1} color={recipe.reagentCol} />
        {recipe.name}
      </LabeledList.Item>
      {recipe.products && (
        <LabeledList.Item bold label="Products">
          {recipe.products.map(product => (
            <Button
              key={product.name}
              icon="vial"
              disabled={product.hasProduct}
              content={product.ratio + "u " + product.name}
              onClick={() => act('reagent_click', {
                id: product.id,
              })} />
          ))}
        </LabeledList.Item>
      )}
      <LabeledList.Item bold label="Reactants">
        {recipe.reactants.map(reactant => (
          <Box key={reactant.id}>
            <Button
              icon="vial"
              color={reactant.color}
              content={reactant.ratio + "u " + reactant.name}
              onClick={() => act('reagent_click', {
                id: reactant.id,
              })} />
            {!!reactant.tooltipBool && (
              <Button
                icon="flask"
                color="purple"
                tooltip={reactant.tooltip}
                tooltipPosition="right"
                onClick={() => act('find_reagent_reaction', {
                  id: reactant.id,
                })} />
            )}
          </Box>
        ))}
      </LabeledList.Item>
      {recipe.catalysts && (
        <LabeledList.Item bold label="Catalysts">
          {recipe.catalysts.map(catalyst => (
            <Box key={catalyst.id}>
              {catalyst.tooltipBool && (
                <Button
                  icon="vial"
                  color={catalyst.color}
                  content={catalyst.ratio + "u " + catalyst.name}
                  tooltip={catalyst.tooltip}
                  tooltipPosition={"right"}
                  onClick={() => act('reagent_click', {
                    id: catalyst.id,
                  })} />
              ) || (
                <Button
                  icon="vial"
                  color={catalyst.color}
                  content={catalyst.ratio + "u " + catalyst.name}
                  onClick={() => act('reagent_click', {
                    id: catalyst.id,
                  })} />
              )}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {recipe.reqContainer && (
        <LabeledList.Item bold label="Container">
          <Button
            color="transparent"
            textColor="white"
            tooltipPosition="right"
            content={recipe.reqContainer}
            tooltip="The required container for this reaction to occur in." />
        </LabeledList.Item>
      )}
      <LabeledList.Item bold label="Required Minimum Heat" width="10px">
        <Flex
          justify="space-between">
          <Flex.Item
            position="relative"
            textColor={recipe.isColdRecipe && "red"}>
            <Tooltip
              content={recipe.isColdRecipe
                + "The minimum temperature needed for this reaction to start."} />
            {recipe.isColdRecipe
              + recipe.tempMin + "K"}
          </Flex.Item>
        </Flex>
      </LabeledList.Item>
    </LabeledList>
  );
};
