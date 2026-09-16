import { classes } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';
import { DesignBrowser } from './Fabrication/DesignBrowser';
import { MaterialAccessBar } from './Fabrication/MaterialAccessBar';
import { MaterialCostSequence } from './Fabrication/MaterialCostSequence';
import { Design, Material, MaterialMap } from './Fabrication/Types';

type QueueJob = {
  jobId: string;
  designId: string;
  processing: boolean;
  timeLeft: number;
};

type Data = {
  materials: Material[];
  designs: Record<string, Design>;
  queue: QueueJob[];
  processing: boolean;
};

export const ExosuitFabricator = () => {
  const { act, data } = useBackend<Data>();
  const availableMaterials: MaterialMap = {};
  for (const material of data.materials || []) {
    availableMaterials[material.name] = material.amount;
  }

  return (
    <Window title="Exosuit Fabricator" width={1100} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item grow style={{ minHeight: '0' }}>
                <DesignBrowser
                  designs={Object.values(data.designs || {})}
                  availableMaterials={availableMaterials}
                  categoryButtons={(category) => (
                    <Button
                      color="transparent"
                      onClick={() =>
                        act('build', {
                          designs: category.children.map((design) => design.id),
                        })
                      }
                    >
                      Queue All
                    </Button>
                  )}
                  buildRecipeElement={(design, available) => (
                    <Recipe design={design} available={available} />
                  )}
                />
              </Stack.Item>
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
          </Stack.Item>
          <Stack.Item width="420px">
            <Queue availableMaterials={availableMaterials} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Recipe = (props: { design: Design; available: MaterialMap }) => {
  const { act } = useBackend<Data>();
  const canBuild = !Object.entries(props.design.cost).some(
    ([material, cost]) => cost > (props.available[material] || 0),
  );
  const queue = (now = false) =>
    act('build', { designs: [props.design.id], ...(now && { now: true }) });

  return (
    <div className="FabricatorRecipe">
      <Tooltip content={props.design.desc} position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canBuild && 'FabricatorRecipe__Button--disabled',
          ])}
        >
          <Icon name="question-circle" />
        </div>
      </Tooltip>
      <Tooltip
        position="bottom"
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
            !canBuild && 'FabricatorRecipe__Title--disabled',
          ])}
          onClick={() => queue(true)}
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
      <Tooltip content="Add to Queue" position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canBuild && 'FabricatorRecipe__Button--disabled',
          ])}
          onClick={() => queue()}
        >
          <Icon name="plus-circle" />
        </div>
      </Tooltip>
      <Tooltip content="Build Now" position="right">
        <div
          className={classes([
            'FabricatorRecipe__Button',
            'FabricatorRecipe__Button--icon',
            !canBuild && 'FabricatorRecipe__Button--disabled',
          ])}
          onClick={() => queue(true)}
        >
          <Icon name="play" />
        </div>
      </Tooltip>
    </div>
  );
};

const Queue = (props: { availableMaterials: MaterialMap }) => {
  const { act, data } = useBackend<Data>();
  const materialCosts: MaterialMap = {};
  for (const job of data.queue || []) {
    const design = data.designs[job.designId];
    for (const [material, amount] of Object.entries(design?.cost || {})) {
      materialCosts[material] = (materialCosts[material] || 0) + amount;
    }
  }

  const queued = !!data.queue?.length;

  return (
    <Section
      fill
      className="Fabricator__QueuePanel"
      title="Queue"
      buttons={
        <>
          <Button.Confirm
            disabled={!queued}
            color="bad"
            icon="minus-circle"
            content="Clear"
            onClick={() => act('clear_queue')}
          />
          {data.processing ? (
            <Button
              disabled={!queued}
              content="Stop"
              icon="stop"
              onClick={() => act('stop_queue')}
            />
          ) : (
            <Button
              disabled={!queued}
              content="Build"
              icon="play"
              onClick={() => act('build_queue')}
            />
          )}
        </>
      }
    >
      <Stack fill vertical>
        {queued && (
          <Stack.Item mb={0.5}>
            <MaterialCostSequence
              available={props.availableMaterials}
              costMap={materialCosts}
            />
          </Stack.Item>
        )}
        <Stack.Item grow>
          <div className="Fabricator__Queue">
            <QueueList availableMaterials={props.availableMaterials} />
          </div>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const QueueList = (props: { availableMaterials: MaterialMap }) => {
  const { act, data } = useBackend<Data>();
  const accumulated: MaterialMap = {};

  return (data.queue || []).map((job, index) => {
    const design = data.designs[job.designId];
    const canBuild = !Object.entries(design?.cost || {}).some(
      ([material, amount]) =>
        (accumulated[material] = (accumulated[material] || 0) + amount) >
        (props.availableMaterials[material] || 0),
    );
    return (
      <div key={job.jobId} className="FabricatorRecipe">
        {!!job.processing && !!design && (
          <div
            className="FabricatorRecipe__Progress"
            style={{
              width: `${(job.timeLeft / design.constructionTime) * 100}%`,
            }}
          />
        )}
        <Tooltip
          content={
            <MaterialCostSequence
              design={design}
              available={props.availableMaterials}
            />
          }
          position="bottom"
        >
          <div
            className={classes([
              'FabricatorRecipe__Title',
              !canBuild && 'FabricatorRecipe__Title--disabled',
            ])}
          >
            <div className="FabricatorRecipe__Icon">
              <Box
                width="32px"
                height="32px"
                className={classes(['design32x32', design?.icon])}
              />
            </div>
            <div className="FabricatorRecipe__Label">{design?.name}</div>
          </div>
        </Tooltip>
        {!job.processing && (
          <Tooltip content="Remove from Queue">
            <div
              className="FabricatorRecipe__Button FabricatorRecipe__Button--icon"
              onClick={() =>
                act('del_queue_part', {
                  index: index + (data.queue[0].processing ? 0 : 1),
                })
              }
            >
              <Icon name="minus-circle" />
            </div>
          </Tooltip>
        )}
      </div>
    );
  });
};
