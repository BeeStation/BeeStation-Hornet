import { createSearch } from 'common/string';
import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import {
  Button,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type typePath = string;

type Reagent = {
  id: typePath;
  text: string;
};

type ContainerType = {
  id: typePath;
  text: string;
  volume: number;
};

type Data = {
  reagents: Reagent[];
  containers: ContainerType[];
};

type Container = {
  type: typePath;
  reagents: Record<typePath, number>;
};

function makeContainerState(default_type: ContainerType) {
  return useState<Container>({
    type: default_type.id,
    reagents: {},
  });
}

function removeContainerReagent(
  container: Container,
  setContainer: (container: Container) => void,
  reagent: typePath,
) {
  const newReagents = { ...container.reagents };
  delete newReagents[reagent];
  setContainer({ ...container, reagents: newReagents });
}

function setContainerReagentVolume(
  container: Container,
  setContainer: (container: Container) => void,
  reagent: typePath,
  volume: number = 10,
) {
  const newReagents = { ...container.reagents };
  newReagents[reagent] = volume;
  setContainer({ ...container, reagents: newReagents });
}

function containerToSpawnInfo(container: Container) {
  return {
    container: container.type,
    reagents: container.reagents,
  };
}

function readableContainerType(container_type: ContainerType) {
  return capitalizeFirst(`${container_type.text} (${container_type.volume}u)`);
}

function readableReagentType(reagent: Reagent) {
  return capitalizeFirst(reagent.text);
}

function grenadeCheck(containers: Container[]) {
  return containers.every((container) => container.type.includes('beaker'));
}

type ReagentEntryProps = {
  container: Container;
  reagent: Reagent;
  reagentAmount?: number | undefined | null;
  updateContainer: (container: Container) => void;
};

function ReagentEntry(props: ReagentEntryProps) {
  const { container, reagent, reagentAmount, updateContainer } = props;

  const [addingReagentVolume, setAddingReagentVolume] = useState<number>(50);

  return (
    <Stack.Item>
      <Stack>
        <Stack.Item grow>{readableReagentType(reagent)}</Stack.Item>
        <Stack.Item>
          <NumberInput
            fluid
            step={1}
            minValue={0}
            maxValue={1000}
            unit="u"
            value={reagentAmount ?? addingReagentVolume}
            onChange={(value) => {
              if (reagentAmount !== undefined) {
                setContainerReagentVolume(
                  container,
                  updateContainer,
                  reagent.id,
                  value,
                );
              } else {
                setAddingReagentVolume(value);
              }
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color={reagentAmount !== undefined ? 'red' : 'green'}
            icon={reagentAmount !== undefined ? 'minus' : 'plus'}
            onClick={() => {
              if (reagentAmount !== undefined) {
                removeContainerReagent(container, updateContainer, reagent.id);
              } else {
                setContainerReagentVolume(
                  container,
                  updateContainer,
                  reagent.id,
                  addingReagentVolume,
                );
              }
            }}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
}

type ContainerProps = {
  container: Container;
  number: number;
  updateContainer: (container: Container) => void;
  reagents: Reagent[];
  containers: ContainerType[];
};

function ContainerSection(props: ContainerProps) {
  const { container, number, updateContainer, reagents, containers } = props;
  const { act } = useBackend<Data>();

  const [showContainerDropdown, setShowContainerDropdown] =
    useState<boolean>(true);
  const [showReagentsDropdown, setShowReagentsDropdown] =
    useState<boolean>(true);

  const [containerSearchText, setContainerSearchText] = useState<string>('');
  const containerSearch = createSearch(
    containerSearchText,
    (container: ContainerType) => container.text,
  );
  const containersToShow =
    containerSearchText.length > 0
      ? filter(containers, containerSearch)
      : containers;

  const [reagentSearchText, setReagentSearchText] = useState<string>('');
  const reagentSearch = createSearch(
    reagentSearchText,
    (reagent: Reagent) => reagent.text,
  );
  const reagentsToShow =
    reagentSearchText.length > 0 ? filter(reagents, reagentSearch) : reagents;

  const [showSelectedReagentsOnly, setShowSelectedReagentsOnly] =
    useState<boolean>(false);

  return (
    <Stack vertical fill>
      <Stack.Item grow={showContainerDropdown}>
        <Section
          title={`Container ${number}`}
          fill
          scrollable
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  icon="cog"
                  onClick={() =>
                    act('spawn', {
                      spawn_info: containerToSpawnInfo(container),
                    })
                  }
                >
                  Spawn
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Input
                  autoFocus
                  placeholder="Search"
                  value={containerSearchText}
                  onInput={(_, value) => setContainerSearchText(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={showContainerDropdown ? 'chevron-down' : 'chevron-up'}
                  onClick={() =>
                    setShowContainerDropdown(!showContainerDropdown)
                  }
                />
              </Stack.Item>
            </Stack>
          }
        >
          {showContainerDropdown && (
            <Stack vertical>
              {containersToShow.map((otherContainer) => (
                <Stack.Item key={otherContainer.id} grow>
                  <Stack>
                    <Stack.Item grow>
                      {readableContainerType(otherContainer)}
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        disabled={container.type === otherContainer.id}
                        onClick={() =>
                          updateContainer({
                            ...container,
                            type: otherContainer.id,
                          })
                        }
                      >
                        Select
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              ))}
            </Stack>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item grow={showReagentsDropdown}>
        <Section
          title={`Reagents ${number}`}
          fill
          scrollable
          buttons={
            <Stack>
              <Stack.Item>
                <Input
                  autoFocus
                  placeholder="Search"
                  value={reagentSearchText}
                  onInput={(_, value) => setReagentSearchText(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={showSelectedReagentsOnly}
                  onClick={() =>
                    setShowSelectedReagentsOnly(!showSelectedReagentsOnly)
                  }
                >
                  Selected Only
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={showReagentsDropdown ? 'chevron-down' : 'chevron-up'}
                  onClick={() => setShowReagentsDropdown(!showReagentsDropdown)}
                />
              </Stack.Item>
            </Stack>
          }
        >
          {showReagentsDropdown && (
            <Stack vertical fill>
              {reagentsToShow.map((reagent) => {
                const reagentAmount = container.reagents[reagent.id];
                if (showSelectedReagentsOnly && reagentAmount === undefined) {
                  return;
                }

                return (
                  <ReagentEntry
                    key={reagent.id}
                    container={container}
                    reagent={reagent}
                    reagentAmount={reagentAmount}
                    updateContainer={updateContainer}
                  />
                );
              })}
            </Stack>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

export function BeakerPanel() {
  const { act, data } = useBackend<Data>();
  const { reagents, containers } = data;

  const [container_one, setContainerOne] = makeContainerState(containers[0]);
  const [container_two, setContainerTwo] = makeContainerState(containers[0]);
  const [grenadeTimer, setGrenadeTimer] = useState<number>(5.0);

  const reagentsSorted = reagents.sort((a, b) => (a.text < b.text ? -1 : 1));
  const containersSorted = containers.sort((a, b) =>
    readableContainerType(a) < readableContainerType(b) ? -1 : 1,
  );

  return (
    <Window
      title="Spawn a Reagent Container"
      width={800}
      height={500}
      theme="admin"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <Button
                    tooltip={
                      grenadeCheck([container_one, container_two])
                        ? ''
                        : 'Both containers must be beakers!'
                    }
                    disabled={!grenadeCheck([container_one, container_two])}
                    onClick={() =>
                      act('spawngrenade', {
                        spawn_info: [
                          containerToSpawnInfo(container_one),
                          containerToSpawnInfo(container_two),
                        ],
                        grenade_info: {
                          detonation_type: 'normal', // to be implemented
                          detonation_timer: grenadeTimer,
                        },
                      })
                    }
                  >
                    Spawn Grenade
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  Timer:&nbsp;
                  <NumberInput
                    step={0.1}
                    minValue={1.0}
                    maxValue={10.0}
                    unit="seconds"
                    value={grenadeTimer}
                    onChange={(value) => {
                      setGrenadeTimer(value);
                    }}
                  />
                </Stack.Item>
                <Stack.Item fontSize={0.9} align="center">
                  <i>
                    Spawned containers will grow to fit all listed reagents!
                  </i>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <ContainerSection
                  container={container_one}
                  number={1}
                  updateContainer={setContainerOne}
                  reagents={reagentsSorted}
                  containers={containersSorted}
                />
              </Stack.Item>
              <Stack.Item grow>
                <ContainerSection
                  container={container_two}
                  number={2}
                  updateContainer={setContainerTwo}
                  reagents={reagentsSorted}
                  containers={containersSorted}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
