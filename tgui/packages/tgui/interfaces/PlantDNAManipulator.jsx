import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

export const PlantDNAManipulator = (props) => {
  const { act, data } = useBackend();

  return (
    <Window width={450} height={600}>
      <PlantDNAManipulatorConfirmationPrompt />
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

const Accent = (props) => {
  const { children, ...rest } = props;
  return (
    <Box as="span" inline color="lightblue" {...rest}>
      {children}
    </Box>
  );
};

const PlantDNAManipulatorConfirmReplace = (props) => {
  const { act, data } = useBackend();
  const { operation_target, disk_gene } = data;

  return (
    <>
      Are you sure you want to replace <Accent>{operation_target.name}</Accent>{' '}
      with <Accent>{disk_gene.name}</Accent>?
    </>
  );
};

const PlantDNAManipulatorConfirmRemove = (props) => {
  const { act, data } = useBackend();
  const { operation_target, seed } = data;

  return (
    <>
      Are you sure you want to remove <Accent>{operation_target.name} </Accent>{' '}
      from the <Accent>{seed}</Accent>?
    </>
  );
};

const PlantDNAManipulatorConfirmExtract = (props) => {
  const { act, data } = useBackend();
  const { operation_target, machine_stats, seed } = data;

  let statname, stat_limit_type, stat_limit, stat_result;
  if (operation_target.type === 'core') {
    statname = operation_target.stat.toLowerCase();
    [stat_limit_type, stat_limit] = machine_stats[statname];
    stat_result =
      stat_limit_type === 'min'
        ? Math.max(operation_target.value, stat_limit)
        : Math.min(operation_target.value, stat_limit);
  }

  return (
    <Stack vertical>
      <Stack.Item>
        Are you sure you want to extract{' '}
        <Accent>{operation_target.name}</Accent> from the{' '}
        <Accent>{seed}</Accent>?
      </Stack.Item>
      <Stack.Item>
        {operation_target.type === 'core' &&
          stat_result !== operation_target.value && (
            <NoticeBox info>
              <Box>
                Target gene will be degraded to{' '}
                <Accent>
                  {stat_result} {statname}
                </Accent>{' '}
                on extraction. Upgrade the machine to increase efficiency.
              </Box>
            </NoticeBox>
          )}
        <NoticeBox danger>
          The sample will be destroyed in the process
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

const PlantDNAManipulatorConfirmInsert = (props) => {
  const { act, data } = useBackend();
  const { disk_gene, seed } = data;

  return (
    <>
      Are you sure you want to insert <Accent>{disk_gene.name}</Accent> into the{' '}
      <Accent>{seed}</Accent>?
    </>
  );
};

const PlantDNAManipulatorConfirmationPrompt = (props) => {
  const { act, data } = useBackend();
  const { operation } = data;

  if (!operation) {
    return;
  }

  return (
    <Modal p={0.5} minWidth={20} maxWidth="400px">
      <Section title="Confirm operation">
        <Stack vertical>
          <Stack.Item>
            {operation === 'replace' && <PlantDNAManipulatorConfirmReplace />}
            {operation === 'extract' && <PlantDNAManipulatorConfirmExtract />}
            {operation === 'insert' && <PlantDNAManipulatorConfirmInsert />}
            {operation === 'remove' && <PlantDNAManipulatorConfirmRemove />}
          </Stack.Item>
          <Stack.Item>
            <Stack justify="space-around">
              <Stack.Item>
                <Button content="Confirm" onClick={() => act('confirm')} />
              </Stack.Item>
              <Stack.Item>
                <Button
                  content="Abort"
                  color="red"
                  onClick={() => act('abort')}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};

const PlantDNAManipulatorHeader = (props) => {
  const { act, data } = useBackend();
  const { seed, disk, skip_confirmation } = data;

  return (
    <Section
      title="Status"
      buttons={
        <Button.Checkbox
          content="Skip confirmation"
          checked={skip_confirmation}
          onClick={() => act('toggle_skip_confirmation')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Plant sample">
          <Button
            content={seed ?? 'None'}
            onClick={() => act('eject_insert_seed')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Data disk">
          <Button
            content={disk ?? 'None'}
            onClick={() => act('eject_insert_disk')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const PlantDNAManipulatorContent = (props) => {
  const { act, data } = useBackend();
  const { seed, core_genes, reagent_genes, trait_genes } = data;

  if (!seed) {
    return (
      <>
        <NoticeBox>No sample found</NoticeBox>
        <NoticeBox info>
          Please insert a plant sample to use this device.
        </NoticeBox>
      </>
    );
  }

  return (
    <>
      <PlantDNAManipulatorGenes
        label="Core genes"
        type="core"
        list={core_genes}
      />
      <PlantDNAManipulatorGenes
        label="Reagent genes"
        type="reagent"
        list={reagent_genes}
      />
      <PlantDNAManipulatorGenes
        label="Trait genes"
        type="trait"
        list={trait_genes}
      />
    </>
  );
};

const ConditionalTooltip = (props) => {
  const { condition, children, ...rest } = props;

  if (!condition) {
    return children;
  }

  return <Tooltip {...rest}>{children}</Tooltip>;
};

const PlantDNAManipulatorGene = (props) => {
  const { act, data } = useBackend();
  const { disk, disk_readonly, disk_gene, stat_tooltips, disk_canadd } = data;
  const { gene } = props;

  const act_data = { gene_id: gene?.id };

  const tooltip_text =
    gene.type === 'core' && stat_tooltips[gene.stat.toLowerCase()];

  return (
    <Table.Row className="candystripe">
      <Table.Cell collapsing width="50%" position="relative">
        <ConditionalTooltip
          condition={!!tooltip_text}
          content={tooltip_text}
          position="bottom-end"
        >
          <Box>{gene.name}</Box>
        </ConditionalTooltip>
      </Table.Cell>
      <Table.Cell />
      <Table.Cell collapsing py={0.1}>
        <Button
          content="Extract"
          disabled={!disk || disk_readonly || !gene.extractable}
          onClick={() => act('extract', act_data)}
        />
      </Table.Cell>
      <Table.Cell collapsing>
        {gene.type === 'core' ? (
          <Button
            content="Replace"
            disabled={
              !disk_gene ||
              disk_gene?.id !== gene.id ||
              !gene.removable ||
              !disk_canadd
            }
            onClick={() => act('replace', act_data)}
          />
        ) : (
          <Button
            content="Remove"
            disabled={!gene.removable}
            onClick={() => act('remove', act_data)}
          />
        )}
      </Table.Cell>
      <Table.Cell />
    </Table.Row>
  );
};

const PlantDNAManipulatorGenes = (props) => {
  const { act, data } = useBackend();
  const { disk_gene, disk_canadd } = data;
  const { label, type, list } = props;

  return (
    <Section title={label}>
      <Table>
        {list.map((gene) => (
          <PlantDNAManipulatorGene gene={gene} key={gene.id} />
        ))}
      </Table>
      {disk_gene?.type === type && type !== 'core' && (
        <Button
          content={'Insert: ' + disk_gene.name}
          disabled={!disk_canadd}
          onClick={() => act('insert')}
        />
      )}
    </Section>
  );
};
