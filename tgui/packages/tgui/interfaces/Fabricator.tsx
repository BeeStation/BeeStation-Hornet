import { classes } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Design, FabricatorData, MaterialMap } from './Fabrication/Types';

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>();
  const available: MaterialMap = {};
  for (const material of data.materials || []) {
    available[material.name] = material.amount;
  }
  return (
    <Window title={data.fabName} width={670} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow style={{ minHeight: '0' }}>
            <DesignBrowser
              busy={!!data.busy}
              designs={Object.values(data.designs || {})}
              availableMaterials={available}
              buildRecipeElement={(design, materials) => (
                <Recipe design={design} available={materials} />
              )}
            />
          </Stack.Item>
          {!!data.reagents?.length && (
            <Stack.Item>
              <ReagentBar />
            </Stack.Item>
          )}
          <Stack.Item>
            <Section>
              <MaterialAccessBar
                availableMaterials={data.materials || []}
                designs={Object.values(data.designs || {})}
                onEjectRequested={(material, amount) =>
                  act('remove_mat', { ref: material.ref, amount })
                }
              />
            </Section>
          </Stack.Item>
        </Stack>
        {!!data.onHold && (
          <Dimmer style={{ fontSize: '2em', textAlign: 'center' }}>
            Mineral access is on hold, please contact the quartermaster.
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};

/** Reagent name -> units currently loaded. */
const loadedReagents = (data: FabricatorData) => {
  const loaded: MaterialMap = {};
  for (const reagent of data.reagents || []) {
    loaded[reagent.name] = reagent.volume;
  }
  return loaded;
};

/** Reagents are poured in by hand, so they get their own bar above the materials. */
const ReagentBar = () => {
  const { act, data } = useBackend<FabricatorData>();
  const loaded = data.reagents.reduce(
    (total, reagent) => total + reagent.volume,
    0,
  );

  return (
    <Section
      title={`Reagents (${loaded}u / ${data.reagentCapacity}u)`}
      buttons={
        <Button.Confirm
          color="bad"
          icon="trash"
          content="Purge"
          onClick={() => act('disposeall')}
        />
      }
    >
      <Flex wrap>
        {data.reagents.map((reagent) => (
          <Flex.Item key={reagent.id} mr={1}>
            <Button
              icon="times"
              color="transparent"
              tooltip="Dispose of this reagent"
              onClick={() => act('dispose', { reagent_id: reagent.id })}
            >
              {reagent.name} &mdash; {reagent.volume}u
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const Recipe = (props: { design: Design; available: MaterialMap }, context) => {
  const { act, data } = useBackend<FabricatorData>();
  const availableReagents = loadedReagents(data);
  const canPrint = (amount: number) =>
    !Object.entries(props.design.cost).some(
      ([material, cost]) =>
        cost * amount > availableFor(material, props.available),
    ) &&
    !Object.entries(props.design.reagentCost).some(
      ([reagent, volume]) =>
        volume * amount > (availableReagents[reagent] || 0),
    );
  const print = (amount: number) =>
    act('build', { ref: props.design.id, amount });
  return (
    <div className="FabricatorRecipe">
      <Tooltip content={props.design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canPrint(1) && 'FabricatorRecipe__Button--disabled',
          ])}
        >
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        content={
          <MaterialCostSequence
            design={props.design}
            available={props.available}
            availableReagents={availableReagents}
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canPrint(1) && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => print(1)}
        >
          <div className="FabricatorRecipe__Icon">
            <Box
              width="32px"
              height="32px"
              className={classes(['design32x32', props.design.icon])}
            />
          </div>
          <div className="FabricatorRecipe__Label">{props.design.name}</div>
        </div>
      </Tooltip>
      {[5, 10].map((amount) => (
        <Tooltip
          key={amount}
          content={
            <MaterialCostSequence
              design={props.design}
              amount={amount}
              available={props.available}
              availableReagents={availableReagents}
            />
          }
        >
          <div
            className={classes([
              'FabricatorRecipe__Button',
              !canPrint(amount) && 'FabricatorRecipe__Button--disabled',
            ])}
            onClick={() => print(amount)}
          >
            &times;{amount}
          </div>
        </Tooltip>
      ))}
      <CustomPrint design={props.design} available={props.available} />
    </div>
  );
};

/** The most copies the machine will accept in one order. */
const MAX_PRINT_AMOUNT = 50;

/**
 * How much of a cost entry the machine can cover. A cost keyed by a material
 * category rather than a material name -- the toolbox is costed against any
 * rigid material -- is payable from whichever single material there is most
 * of, so that is what it gets measured against.
 */
export const availableFor = (material: string, available: MaterialMap) =>
  material in available
    ? available[material]
    : Math.max(0, ...Object.values(available));

/** How many of a design the loaded materials and reagents can afford, up to the cap. */
export const affordableAmount = (
  design: Design,
  available: MaterialMap,
  availableReagents: MaterialMap = {},
) => {
  let affordable = Object.entries(design.cost).reduce(
    (most, [material, cost]) =>
      Math.min(most, availableFor(material, available) / cost),
    Infinity,
  );
  affordable = Object.entries(design.reagentCost || {}).reduce(
    (most, [reagent, volume]) =>
      Math.min(most, (availableReagents[reagent] || 0) / volume),
    affordable,
  );
  return Math.min(Math.floor(affordable), MAX_PRINT_AMOUNT);
};

const CustomPrint = (props: { design: Design; available: MaterialMap }) => {
  const { act, data } = useBackend<FabricatorData>();
  const max = affordableAmount(
    props.design,
    props.available,
    loadedReagents(data),
  );

  return (
    <div
      className={classes([
        'FabricatorRecipe__Button',
        max < 1 && 'FabricatorRecipe__Button--disabled',
      ])}
    >
      <Button.Input
        color="transparent"
        content={`×${max}`}
        onCommit={(_event, value: string) =>
          act('build', { ref: props.design.id, amount: value })
        }
      />
    </div>
  );
};
