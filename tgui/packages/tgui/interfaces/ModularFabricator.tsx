import { round } from 'common/math';
import { BooleanLike, classes } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Design, Material, MaterialMap } from './Fabrication/Types';
import { affordableAmount, availableFor } from './Fabricator';

type QueueEntry = {
  name: string;
  amount: number;
  repeat: BooleanLike;
  design_id: string;
};

type CurrentBuild = {
  design_id: string;
  name: string;
  progress: number;
};

type Data = {
  fabName: string;
  accepts_disk: BooleanLike;
  show_unlock_bar: BooleanLike;
  allow_add_category: BooleanLike;
  uses_queue: BooleanLike;
  designs: Record<string, Design>;

  disk_inserted: BooleanLike;
  can_upload_disk: BooleanLike;
  sec_interface_unlock: BooleanLike;
  hacked: BooleanLike;
  design_queue: QueueEntry[];
  materials: Material[];
  being_built: CurrentBuild | null;
};

export const ModularFabricator = () => {
  const { act, data } = useBackend<Data>();
  const available: MaterialMap = {};
  for (const material of data.materials || []) {
    available[material.name] = material.amount;
  }

  return (
    <Window
      title={data.fabName}
      width={data.uses_queue ? 900 : 670}
      height={600}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow style={{ minHeight: '0' }}>
            <Stack fill>
              <Stack.Item grow style={{ minHeight: '0' }}>
                <DesignBrowser
                  designs={Object.values(data.designs || {})}
                  availableMaterials={available}
                  // A queued machine keeps its progress in the side panel, so the browser stays usable while it works through the queue.
                  busy={!data.uses_queue && !!data.being_built}
                  categoryButtons={
                    data.allow_add_category
                      ? (category) => (
                          <Button
                            color="transparent"
                            onClick={() =>
                              act('build', {
                                designs: category.children.map(
                                  (design) => design.id,
                                ),
                              })
                            }
                          >
                            Queue All
                          </Button>
                        )
                      : undefined
                  }
                  buildRecipeElement={(design, materials) => (
                    <Recipe design={design} available={materials} />
                  )}
                />
              </Stack.Item>
              {!!data.uses_queue && (
                <Stack.Item width="260px">
                  <SidePanel availableMaterials={available} />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          {!data.uses_queue && !!data.accepts_disk && (
            <Stack.Item>
              <Section>
                <DiskControls />
              </Section>
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
      </Window.Content>
    </Window>
  );
};

const Recipe = (props: { design: Design; available: MaterialMap }) => {
  const { act, data } = useBackend<Data>();
  const canQueue = (amount: number) =>
    !Object.entries(props.design.cost).some(
      ([material, cost]) =>
        cost * amount > availableFor(material, props.available),
    );
  // Machines without a queue print as soon as a design is clicked, the way the protolathe does.
  const queue = (amount: number) =>
    data.uses_queue
      ? act('queue_item', { design_id: props.design.id, amount })
      : act('build', { design_id: props.design.id, amount });

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={props.design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canQueue(1) && 'FabricatorRecipe__Button--disabled',
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
          />
        }
      >
        <div
          className={classes([
            'FabricatorRecipe__Title',
            !canQueue(1) && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => queue(1)}
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
            />
          }
        >
          <div
            className={classes([
              'FabricatorRecipe__Button',
              !canQueue(amount) && 'FabricatorRecipe__Button--disabled',
            ])}
            onClick={() => queue(amount)}
          >
            &times;{amount}
          </div>
        </Tooltip>
      ))}
      <CustomQueue design={props.design} available={props.available} />
    </div>
  );
};

const CustomQueue = (props: { design: Design; available: MaterialMap }) => {
  const { act, data } = useBackend<Data>();
  const max = affordableAmount(props.design, props.available);

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
          act(data.uses_queue ? 'queue_item' : 'build', {
            design_id: props.design.id,
            amount: value,
          })
        }
      />
    </div>
  );
};

const SidePanel = (props: { availableMaterials: MaterialMap }) => {
  const { act, data } = useBackend<Data>();
  const queue = data.design_queue || [];

  const materialCosts: MaterialMap = {};
  for (const entry of queue) {
    const design = data.designs[entry.design_id];
    for (const [material, cost] of Object.entries(design?.cost || {})) {
      materialCosts[material] =
        (materialCosts[material] || 0) + cost * entry.amount;
    }
  }

  return (
    <Stack vertical fill>
      {!!data.show_unlock_bar && (
        <Stack.Item>
          <SecurityControls />
        </Stack.Item>
      )}
      <Stack.Item grow style={{ minHeight: '0' }}>
        <Section
          fill
          className="Fabricator__QueuePanel"
          title="Queue"
          buttons={
            <Button
              disabled={!queue.length}
              color="bad"
              icon="times"
              content="Clear"
              onClick={() => act('clear_queue')}
            />
          }
        >
          <Stack fill vertical>
            {!!queue.length && (
              <Stack.Item mb={0.5}>
                <MaterialCostSequence
                  available={props.availableMaterials}
                  costMap={materialCosts}
                />
              </Stack.Item>
            )}
            <Stack.Item grow>
              <div className="Fabricator__Queue">
                {queue.map((entry) => (
                  <div key={entry.design_id} className="FabricatorRecipe">
                    <Tooltip
                      content={
                        <MaterialCostSequence
                          design={data.designs[entry.design_id]}
                          amount={entry.amount}
                          available={props.availableMaterials}
                        />
                      }
                    >
                      <div className="FabricatorRecipe__Title">
                        <div className="FabricatorRecipe__Label">
                          {entry.name}
                        </div>
                      </div>
                    </Tooltip>
                    <div className="FabricatorRecipe__Button">
                      &times;{entry.amount}
                    </div>
                    <Tooltip content="Repeat this item">
                      <div
                        className={classes([
                          'FabricatorRecipe__Button',
                          'FabricatorRecipe__Button--icon',
                          !entry.repeat && 'FabricatorRecipe__Button--disabled',
                        ])}
                        onClick={() =>
                          act('item_repeat', {
                            design_id: entry.design_id,
                            repeating: !entry.repeat,
                          })
                        }
                      >
                        <Icon name="redo-alt" />
                      </div>
                    </Tooltip>
                    <Tooltip content="Remove from queue">
                      <div
                        className="FabricatorRecipe__Button FabricatorRecipe__Button--icon"
                        onClick={() =>
                          act('clear_item', { design_id: entry.design_id })
                        }
                      >
                        <Icon name="minus-circle" />
                      </div>
                    </Tooltip>
                  </div>
                ))}
              </div>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      {!!data.being_built && (
        <Stack.Item>
          <Section>
            <ProcessingBar />
          </Section>
        </Stack.Item>
      )}
      {!!data.accepts_disk && (
        <Stack.Item>
          <Section>
            <DiskControls />
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const SecurityControls = () => {
  const { act, data } = useBackend<Data>();

  return (
    <NoticeBox color={data.sec_interface_unlock ? 'green' : 'red'} m={0}>
      <Stack align="center">
        <Stack.Item grow>
          Security protocol {data.hacked ? 'disengaged' : 'engaged'}.
        </Stack.Item>
        <Stack.Item>
          <Button
            color={data.sec_interface_unlock ? 'green' : 'red'}
            icon={data.sec_interface_unlock ? 'unlock' : 'lock'}
            tooltip="Swipe a valid ID to unlock safety controls"
            content={data.hacked ? 'Reactivate' : 'Deactivate'}
            onClick={() => act('toggle_safety')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color={data.sec_interface_unlock ? 'green' : 'red'}
            icon={data.sec_interface_unlock ? 'unlock' : 'lock'}
            content={data.sec_interface_unlock ? 'Unlocked' : 'Locked'}
            onClick={() => act('toggle_lock')}
          />
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};

/** Nothing to report while the machine is idle, so this renders only mid-build. */
const ProcessingBar = () => {
  const { data } = useBackend<Data>();

  if (!data.being_built) {
    return null;
  }

  return (
    <ProgressBar
      value={data.being_built.progress}
      minValue={0}
      maxValue={100}
      color="good"
    >
      {data.being_built.name} &mdash;{' '}
      {Math.min(round(data.being_built.progress, 1), 100)}%
    </ProgressBar>
  );
};

const DiskControls = () => {
  const { act, data } = useBackend<Data>();

  return (
    <Stack align="center">
      <Stack.Item bold>Data disk</Stack.Item>
      <Stack.Item grow>
        <Button
          disabled={!data.disk_inserted || !data.can_upload_disk}
          icon="upload"
          content="Upload"
          onClick={() => act('upload_disk')}
        />
        <Button
          disabled={!data.disk_inserted}
          icon="folder-open"
          content="Eject"
          onClick={() => act('eject_disk')}
        />
      </Stack.Item>
    </Stack>
  );
};
