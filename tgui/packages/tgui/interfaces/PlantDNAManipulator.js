import { sortBy, map } from 'common/collections';
import { flow } from 'common/fp';
import { toTitleCase } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Dimmer, Table, Modal, Stack, LabeledList, NumberInput, NoticeBox, Box, Tooltip, Flex } from '../components';
import { Window } from '../layouts';

const WINDOW_SELECT_BASIC = 'basic';
const WINDOW_SELECT_CHEMICALS = 'chemicals';
const WINDOW_SELECT_TRAITS = 'traits';


export const PlantDNAManipulator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    research_valid,
  } = data;

  return (
    <Window
      width={900}
      height={600}>
      {!data.research_valid && (
        <Dimmer fontSize="32px">
          {'This seed needs research...'}<br />
          <Button
            content={"Eject the seed"}
            onClick={() => act("eject_insert_seed")}
          />
        </Dimmer>
      )}
      <PlantDNAManipulatorConfirmationPrompt />
      <Window.Content>
        <Flex>
          <Flex.Item width="450px" mr="10px">
            <Stack vertical fill>
              <Stack.Item>
                <PlantDNAManipulatorHeader />
              </Stack.Item>
              <Stack.Item>
                <PlantDNAManipulatorContent />
              </Stack.Item>
            </Stack>
          </Flex.Item>
          <Flex.Item width="450px">
            <Stack vertical fill>
              <Stack.Item>
                <PlantDNAManipulatorHeaderRight />
              </Stack.Item>
            </Stack>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Accent = (props, context) => {
  const {
    children,
    ...rest
  } = props;
  return (
    <Box as="span" inline color="lightblue" {...rest}>
      {children}
    </Box>);
};

const PlantDNAManipulatorConfirmMutate = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    operation_target,
    seed,
  } = data;

  return (
    <>
      Are you sure you want to mutate{" "}
      <Accent>{seed}</Accent>?
    </>
  );
};
const PlantDNAManipulatorConfirmInsert = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    operation_target,
    seed,
  } = data;

  return (
    <>
      Are you sure you want to insert{" "}
      <Accent>{seed}</Accent>?
    </>
  );
};

const PlantDNAManipulatorConfirmRemove = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    operation_target,
    seed,
  } = data;

  return (
    <>
      Are you sure you want to remove{" "}
      <Accent>{operation_target.name} </Accent> from the{" "}
      <Accent>{seed}</Accent>?
    </>
  );
};

const PlantDNAManipulatorConfirmAdjust = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    operation_target,
    seed,
  } = data;

  return (
    <>
      Are you sure you want to adjust{" "}
      reagent unit(<Accent>{operation_target.reag_unit}u</Accent>) lower than{" "}
      its maximum <Accent>{operation_target.reag_unit_max}u</Accent> of <Accent>{operation_target.name}</Accent> in the{" "}
      <Accent>{seed}</Accent>?
    </>
  );
};

const PlantDNAManipulatorConfirmationPrompt = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    operation,
  } = data;

  if (!operation)
  {
    return;
  }

  return (
    <Modal p={0.5} minWidth={20} maxWidth="400px">
      <Section title="Confirm operation">
        <Stack vertical>
          <Stack.Item>
            {operation === "mutate" && <PlantDNAManipulatorConfirmMutate />}
            {operation === "insert" && <PlantDNAManipulatorConfirmInsert />}
            {operation === "remove" && <PlantDNAManipulatorConfirmRemove />}
            {operation === "adjust" && <PlantDNAManipulatorConfirmAdjust />}
          </Stack.Item>
          <Stack.Item>
            <Stack justify="space-around">
              <Stack.Item>
                <Button content="Confirm" onClick={() => act("confirm")} />
              </Stack.Item>
              <Stack.Item>
                <Button content="Abort" color="red" onClick={() => act("abort")} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};

const PlantDNAManipulatorHeader = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seed,
    skip_confirmation,
  } = data;

  return (
    <Section
      title="Status"
      buttons={<Button.Checkbox
        content="Skip confirmation"
        checked={skip_confirmation}
        onClick={() => act("toggle_skip_confirmation")} />}>
      <LabeledList>
        <LabeledList.Item label="Plant sample">
          <Button
            content={seed ?? "None"}
            onClick={() => act("eject_insert_seed")}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};


const PlantDNAManipulatorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seed,
    core_genes,
    reagent_genes,
    trait_genes,
  } = data;

  if (!seed)
  { return (
    <>
      <NoticeBox>
        No sample found
      </NoticeBox>
      <NoticeBox info>
        Please insert a plant sample to use this device.
      </NoticeBox>
    </>
  ); }

  return (
    <>
      <PlantDNAManipulatorGenes label="Core genes"
        type="core" list={core_genes} />
      <PlantDNAManipulatorGenes label="Reagent genes"
        type="reagent" list={reagent_genes} />
      <PlantDNAManipulatorGenes label="Trait genes"
        type="trait" list={trait_genes} />
    </>
  );
};

const ConditionalTooltip = (props, context) => {
  const {
    condition,
    children,
    ...rest
  } = props;

  if (!condition)
  {
    return children;
  }

  return (
    <Tooltip {...rest}>
      {children}
    </Tooltip>
  );
};


const PlantDNAManipulatorGene = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    stat_tooltips,
  } = data;
  const {
    gene,
  } = props;

  const act_data = { gene_id: gene?.id };

  const tooltip_text = gene.type === "core" && stat_tooltips[gene.stat.toLowerCase()];

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsing width="50%" position="relative">
        <ConditionalTooltip
          condition={!!tooltip_text}
          content={tooltip_text}
          position="bottom-end">
          <Box m={0.5}>
            {gene.name}
          </Box>
        </ConditionalTooltip>
      </Table.Cell>
      <Table.Cell />
      <Table.Cell collapsing>
        {
          gene.type === "reagent" && (
            <box>
              [max: {gene.reag_unit_max}u]
            </box>
          )
        }
      </Table.Cell>
      <Table.Cell collapsing py={0.1}>
        {
          gene.type === "reagent" && (
            <NumberInput
              value={gene.reag_unit}
              unit="u"
              width="65px"
              minValue={0.01}
              maxValue={gene.reag_unit_max}
              step={0.01}
              stepPixelSize={2}
              onChange={(e, value) => { act_data.value = value; act("adjust", act_data); }} />
          )
        }
      </Table.Cell>
      <Table.Cell collapsing py={0.1}>
        {
          (gene.type === "core") ? "" : (
            <Button
              content="Remove"
              disabled={!gene.removable}
              onClick={() => act("remove", act_data)}
            />
          )
        }
      </Table.Cell>
      <Table.Cell />
    </Table.Row>
  );
};

const PlantDNAManipulatorGenes = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    label,
    type,
    list,
  } = props;

  return (
    <Section title={label}>
      <Table>
        {
          list.map(gene => (
            <PlantDNAManipulatorGene gene={gene} key={gene.id} />
          ))
        }
      </Table>
    </Section>
  );
};


const PlantDNAManipulatorButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedWindow } = data;
  return (
    <Fragment>
      <Button
        selected={selectedWindow === WINDOW_SELECT_BASIC}
        content="Basic Data"
        onClick={() => act('set_view', {
          selectedWindow: WINDOW_SELECT_BASIC,
        })} />
      <Button
        selected={selectedWindow === WINDOW_SELECT_CHEMICALS}
        content="Chemical Data"
        onClick={() => act('set_view', {
          selectedWindow: WINDOW_SELECT_CHEMICALS,
        })} />
      <Button
        selected={selectedWindow === WINDOW_SELECT_TRAITS}
        content="Trait Data"
        onClick={() => act('set_view', {
          selectedWindow: WINDOW_SELECT_TRAITS,
        })} />
    </Fragment>
  );
};


const PlantDNAManipulatorHeaderRight = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seed,
    selectedWindow,
  } = data;

  return (
    <Section
      title="Data Storage"
      buttons={(
        <PlantDNAManipulatorButtons />
      )}>
      {selectedWindow === WINDOW_SELECT_BASIC && (
        <PlantDNAManipulatorWindowBasic />
      )}
      {selectedWindow === WINDOW_SELECT_CHEMICALS && (
        <PlantDNAManipulatorWindowChemicals />
      )}
      {selectedWindow === WINDOW_SELECT_TRAITS && (
        <PlantDNAManipulatorWindowTraits />
      )}
    </Section>
  );
};

const PlantDNAManipulatorWindowBasic = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seed,
    plant_name,
    plant_desc,
    seed_desc,
    family_gene,
  } = data;
  const str_plant_name = JSON.stringify(plant_name);
  const str_plant_desc = JSON.stringify(plant_desc);
  const str_seed_desc = JSON.stringify(seed_desc);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Plant name">
            <Button
              content={(plant_name === null ? "None":(str_plant_name.length<38 ? str_plant_name.slice(1, str_plant_name.length-1): str_plant_name.slice(1, 36)+"..."))}
              disabled={!seed}
              onClick={() => act("modify_plant_name")}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Plant description">
            <Button
              content={(str_plant_desc === "null" ? "None":(str_plant_desc.length<38 ? str_plant_desc.slice(1, str_plant_desc.length-1): str_plant_desc.slice(1, 36)+"..."))}
              disabled={!seed}
              onClick={() => act("modify_plant_desc")}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Seed description">
            <Button
              content={(str_seed_desc === "null" ? "None":(str_seed_desc.length<38 ? str_seed_desc.slice(1, str_seed_desc.length-1): str_seed_desc.slice(1, 36)+"..."))}
              disabled={!seed}
              onClick={() => act("modify_seed_desc")}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Plant Family">
            {seed === null ? "None" : family_gene.family_name}
          </LabeledList.Item>
          <LabeledList.Item label="Possible families">
            {"-"}
          </LabeledList.Item>
          <LabeledList.Item label="Possible mutations">
            <PlantDNAManipulatorButtonsMutatelist />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

const PlantDNAManipulatorWindowChemicals = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <PlantDNAManipulatorWindowChemicalsContents />
      </Stack.Item>
    </Stack>
  );
};

const PlantDNAManipulatorWindowChemicalsContents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    research_datas,
    research_faction_type,
  } = data;
  const act_data = { data_id: null };
  const r_datas = data.research_datas || [];

  return (
    <Table>
      <Table.Row header>
        <Table.Cell>
          Chemical datas
        </Table.Cell>
        <Table.Cell>
          Volume
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          Insert
        </Table.Cell>
      </Table.Row>
      {r_datas.map(r_data => (
        (r_data.type === "reagent") && (r_data.faction & research_faction_type)) ? (
          <Table.Row key={r_data.id}>
            <Table.Cell m={0.2}>
              {r_data.name}
            </Table.Cell>
            <Table.Cell>
              {r_data.max_reagent}u
            </Table.Cell>
            <Table.Cell collapsing py={0.1}>
              <Button
                content="Insert"
                onClick={() => { act_data.data_id = r_data.id; act("insert", act_data); }}
              />
            </Table.Cell>
          </Table.Row>
        ):"")}
    </Table>
  );
};

const PlantDNAManipulatorWindowTraits = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seed,
  } = data;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <PlantDNAManipulatorWindowTraitsContents />
      </Stack.Item>
    </Stack>
  );
};

const PlantDNAManipulatorWindowTraitsContents = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    research_datas,
    research_faction_type,
  } = data;
  const act_data = { data_id: null };
  const r_datas = data.research_datas || [];

  return (
    <Table>
      <Table.Row header>
        <Table.Cell>
          Trait datas
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          Insert
        </Table.Cell>
      </Table.Row>
      {r_datas.map(r_data => (
        (r_data.type === "trait") && (r_data.faction & research_faction_type)) ? (
          <Table.Row key={r_data.id}>
            <Table.Cell m={0.2}>
              {r_data.name}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Insert"
                onClick={() => {
                  act_data.data_id = r_data.id;
                  act("insert", act_data); }}
              />
            </Table.Cell>
          </Table.Row>
        ):"")}
    </Table>
  );
};

const PlantDNAManipulatorButtonsMutatelist = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mutate_list,
  } = data;

  const act_data = { mutation_path: null };
  const mutatables = data.mutate_list || [];
  return (
    <Table>
      {mutatables.map(mutatable => (
        <Button
          key={mutatable.plantname}
          content={mutatable.plantname}
          onClick={() => { act_data.mutation_path = mutatable.plantpath; act("mutate", act_data); }}
        />
      ))}

    </Table>
  );
};
