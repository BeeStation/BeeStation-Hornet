import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Modal, Stack, LabeledList, NoticeBox, Box, Tooltip } from '../components';
import { Window } from '../layouts';

export const PlantDNAManipulator = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    confirmationPrompt,
    setConfirmationPrompt,
  ] = useLocalState(context, 'confirmationPrompt', null);

  return (
    <Window
      width={450}
      height={600}>
      {
        !!confirmationPrompt && <PlantDNAManipulatorConfirmationPrompt />
      }
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <PlantDNAManipulatorHeader />
          </Stack.Item>
          <Stack.Item>
            <PlantDNAManipulatorContent />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const makePopupData = (act_name, act_data, content) => { return {
  act_name: act_name,
  act_data: act_data,
  content: content,
}; };

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

const PlantDNAManipulatorConfirmationPrompt = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    skip_confirmation,
  } = data;
  const [
    confirmationPrompt,
    setConfirmationPrompt,
  ] = useLocalState(context, 'confirmationPrompt', null);

  const {
    act_name,
    act_data,
    content,
  } = confirmationPrompt;

  if (skip_confirmation)
  {
    act(act_name, act_data);
    setConfirmationPrompt();
    return;
  }

  return (
    <Modal p={0.5} minWidth={20} maxWidth="400px">
      <Section title="Confirm operation">
        <Stack vertical>
          <Stack.Item>
            {content}
          </Stack.Item>
          <Stack.Item>
            <Stack justify="space-around">
              <Stack.Item>
                <Button content="Confirm" onClick={() => {
                  act(act_name, act_data);
                  setConfirmationPrompt();
                }} />
              </Stack.Item>
              <Stack.Item>
                <Button content="Abort" color="red" onClick={() => setConfirmationPrompt()} />
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
    disk,
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
        <LabeledList.Item label="Data disk">
          <Button
            content={disk ?? "None"}
            onClick={() => act("eject_insert_disk")}
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
    disk,
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
      <PlantDNAManipulatorCoreGenes />
      <PlantDNAManipulatorGenes label="Reagent genes"
        type="reagent" list={reagent_genes} />
      <PlantDNAManipulatorGenes label="Trait genes"
        type="trait" list={trait_genes} />
    </>
  );
};

const PlantDNAManipulatorGene = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    seed,
    disk,
    disk_readonly,
    disk_gene,
    machine_stats,
    stat_tooltips,
    disk_canadd,
  } = data;
  const {
    gene,
  } = props;

  const [
    confirmationPrompt,
    setConfirmationPrompt,
  ] = useLocalState(context, 'confirmationPrompt', null);

  const act_data = { gene_id: gene?.id };

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsing width="50%" position="relative">
        {
          gene.type === "core" && stat_tooltips[gene.stat.toLowerCase()]
          && <Tooltip
            content={stat_tooltips[gene.stat.toLowerCase()]}
            position="bottom-right" />
        }
        {gene.name}
      </Table.Cell>
      <Table.Cell />
      <Table.Cell collapsing py={0.1}>
        <Button
          content="Extract"
          disabled={!disk || disk_readonly || !gene.extractable}
          onClick={() => {
            let statname, stat_limit_type, stat_limit, stat_result;
            if (gene.type === "core")
            {
              statname = gene.stat.toLowerCase();
              [
                stat_limit_type,
                stat_limit,
              ] = machine_stats[statname];
              stat_result = (stat_limit_type === "min")
                ? Math.max(gene.value, stat_limit)
                : Math.min(gene.value, stat_limit);
            }

            setConfirmationPrompt(makePopupData("extract", act_data, (
              <Stack vertical>
                <Stack.Item>
                  Are you sure you want to
                  extract <Accent>{gene.name}</Accent> from
                  the <Accent>{seed}</Accent>?
                </Stack.Item>
                <Stack.Item>
                  {
                    gene.type === "core" && stat_result !== gene.value
                    && (
                      <NoticeBox info>
                        <Box>
                          Target gene will be
                          degraded to{" "}
                          <Accent>
                            {stat_result} {statname}
                          </Accent> on extraction. Upgrade the machine to
                          increase efficiency.
                        </Box>
                      </NoticeBox>
                    )
                  }
                  <NoticeBox danger>
                    The sample will be destroyed in the process
                  </NoticeBox>
                </Stack.Item>
              </Stack>
            )));
          }}
        />
      </Table.Cell>
      <Table.Cell collapsing>
        {
          (gene.type === "core") ? (
            <Button
              content="Replace"
              disabled={!disk_gene
                || disk_gene?.id !== gene.id
                || !gene.removable
                || !disk_canadd}
              onClick={() => setConfirmationPrompt(makePopupData("replace", act_data, (
                <>
                  Are you sure you want to replace{" "}
                  <Accent>{gene.name}</Accent> with{" "}
                  <Accent>{disk_gene.name}</Accent>?
                </>
              )))}
            />
          ) : (
            <Button
              content="Remove"
              disabled={!gene.removable}
              onClick={() => setConfirmationPrompt(makePopupData("remove", act_data, (
                <>
                  Are you sure you want to remove{" "}
                  <Accent>{gene.name} </Accent> from the{" "}
                  <Accent>{seed}</Accent>?
                </>
              )))}
            />
          )
        }
      </Table.Cell>
      <Table.Cell />
    </Table.Row>
  );
};

const PlantDNAManipulatorCoreGenes = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    core_genes,
    disk_gene,
  } = data;

  return (
    <Section title="Core Genes">
      <Table>
        {
          core_genes.map(gene => (
            <PlantDNAManipulatorGene gene={gene} key={gene.id} />
          ))
        }
      </Table>
    </Section>
  );
};

const PlantDNAManipulatorGenes = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    reagent_genes,
    disk_gene,
    seed,
    disk_canadd,
  } = data;
  const {
    label,
    type,
    list,
  } = props;
  const [
    confirmationPrompt,
    setConfirmationPrompt,
  ] = useLocalState(context, 'confirmationPrompt', null);

  return (
    <Section title={label}>
      <Table>
        {
          list.map(gene => (
            <PlantDNAManipulatorGene gene={gene} key={gene.id} />
          ))
        }
      </Table>
      {
        disk_gene?.type === type && type !== "core"
          && <Button content={"Insert: " + disk_gene.name}
            disabled={!disk_canadd
              || list.some(gene => gene.id === disk_gene.id)}
            onClick={() => setConfirmationPrompt(makePopupData("insert", undefined, (
              <>
                Are you sure you want to insert{" "}
                <Accent>{disk_gene.name}</Accent> into the{" "}
                <Accent>{seed}</Accent>?
              </>
            )))} />
      }
    </Section>
  );
};