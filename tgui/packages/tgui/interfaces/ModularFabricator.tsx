import { round } from 'common/math';
import { BooleanLike } from 'common/react';
import { capitalize, createSearch } from 'common/string';
import { Fragment, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Flex,
  Input,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  accepts_disk: BooleanLike;
  show_unlock_bar: BooleanLike;
  allow_add_category: BooleanLike;
  available_categories: DesignCategory[];

  disk_inserted: BooleanLike;
  can_upload_disk: BooleanLike;
  sec_interface_unlock: BooleanLike;
  hacked: BooleanLike;
  output_direction: number;
  design_queue: QueueEntry[];
  contained_materials: MaterialData[];
  being_built: CurrentBuild | null;
};

type DesignCategory = {
  category_name: string;
  category_items: DesignItem[];
};

type DesignItem = {
  name: string;
  desc: string;
  design_id: string;
  material_cost: MaterialData;
};

type MaterialData = {
  name: string;
  amount: number;
  typepath: string;
};

type CurrentBuild = {
  design_id: string;
  name: string;
  progress: number;
};

type QueueEntry = {
  name: string;
  amount: number;
  repeat: BooleanLike;
  design_id: string;
};

const MAX_SEARCH_RESULTS = 25;

export const ModularFabricator = (props) => {
  return (
    <Window width={1000} height={714}>
      <Window.Content>
        <div className="ModularFabricator">
          <div className="vertical fill_height">
            <ModFabSecurityMessage />
            <div className="horizontal grow no_overflow">
              <div className="vertical grow fill_height">
                <div className="data">
                  <ModFabData />
                </div>
                <div className="browser">
                  <ModFabMain />
                </div>
              </div>
              <div className="side_panel">
                <SidePanel />
              </div>
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

export const ModFabMain = () => {
  const { act, data } = useBackend<Data>();
  const [category, setCategory] = useLocalState('category', '');
  const { available_categories } = data;

  const [search, setSearch] = useLocalState('search', '');
  const testSearch = createSearch(search, (item: DesignItem) => {
    return item.name;
  });
  let selected_category_items;
  if (search) {
    let repeats = new Set();
    selected_category_items = available_categories
      .flatMap((category) => category.category_items || [])
      .filter(testSearch)
      .filter((item, i) => i < MAX_SEARCH_RESULTS)
      .filter((item) => {
        // check whether we have design_id repeats in our search
        return repeats.has(item.design_id)
          ? false
          : repeats.add(item.design_id);
      });
  } else {
    for (let i = 0; i < available_categories.length; i++) {
      if (available_categories[i].category_name === category) {
        // don't need to check for repeats as this (shouldn't) have repeats
        selected_category_items = available_categories[i].category_items;
      }
    }
  }

  return (
    <>
      <ModFabCategoryList categories={available_categories} />
      <Divider />
      {selected_category_items ? (
        <ModFabCategoryItems available_categories={selected_category_items} />
      ) : (
        ''
      )}
    </>
  );
};

export const ModFabCategoryList = (props) => {
  const { categories } = props;
  const [category, setCategory] = useLocalState('category', '');
  const [search, setSearch] = useLocalState('search', '');

  return (
    <>
      <Box bold>
        <Table>
          <Table.Cell bold>Categories</Table.Cell>
          <Table.Cell textAlign="right">
            {'Search: '}
            <Input
              align="right"
              value={search}
              onInput={(e, value) => {
                setSearch(value);
              }}
            />
          </Table.Cell>
        </Table>
      </Box>
      <Divider />
      {categories.map((category) => (
        <Fragment key={category.category_name}>
          <Button
            width="200px"
            icon="angle-right"
            onClick={() => {
              setCategory(category.category_name);
              setSearch('');
            }}
          >
            {category.category_name}
          </Button>
        </Fragment>
      ))}
    </>
  );
};

export const ModFabCategoryItems = (props) => {
  const { act, data } = useBackend<Data>();
  const { allow_add_category } = data;
  const { available_categories } = props;
  const [category, setCategory] = useLocalState('category', '');
  const [search, setSearch] = useLocalState('search', '');

  return (
    <>
      <Button
        icon="backspace"
        onClick={() => {
          setCategory('');
        }}
      >
        Return
      </Button>
      {!!(allow_add_category && !search) && (
        <Button
          icon="backspace"
          onClick={() =>
            act('queue_category', {
              category_name: category,
            })
          }
        >
          Add Category
        </Button>
      )}
      <Stack className="item_table" vertical>
        {available_categories.map((item) => {
          /* CSS can't handle height of divs inside table cells for some reason */
          const [amount, setAmount] = useLocalState(
            `amount${item.design_id}`,
            1,
          );
          return (
            <Stack.Item key={item.design_id} className="item_row">
              <Box className="item_description" height="inherit" pr={0}>
                <div className="item_property_container">
                  <div className="item_name">{item.name}</div>
                  {!!item.desc && <div className="item_desc">{item.desc}</div>}
                </div>
              </Box>
              <Box pl={0} className="item_costs">
                <div className="item_property_container">
                  {item.material_cost.map((mat) => (
                    <Box key={mat.name}>
                      {mat.name} ({mat.amount})
                    </Box>
                  ))}
                </div>
              </Box>
              <Box className="item_small_button">
                <Button
                  icon="minus"
                  onClick={() => {
                    amount !== 0 && setAmount(amount - 1);
                  }}
                />
              </Box>
              <Box className="item_small_button">
                <NumberInput
                  value={amount}
                  minValue={0}
                  maxValue={50}
                  step={1}
                  onChange={(value) => setAmount(value)}
                />
              </Box>
              <Box className="item_small_button">
                <Button
                  icon="plus"
                  onClick={() => {
                    amount !== 50 && setAmount(amount + 1);
                  }}
                />
              </Box>
              <Box p={1} className="item_large_button">
                <Button
                  icon="plus-circle"
                  onClick={() =>
                    act('queue_item', {
                      design_id: item.design_id,
                      amount: amount,
                      item_name: item.name,
                    })
                  }
                >
                  Queue
                </Button>
              </Box>
            </Stack.Item>
          );
        })}
      </Stack>
    </>
  );
};

export const ModFabSecurityMessage = () => {
  const { act, data } = useBackend<Data>();
  const { hacked, sec_interface_unlock, show_unlock_bar } = data;

  return show_unlock_bar ? (
    <NoticeBox
      className="ModularFabricator__security_header"
      color={sec_interface_unlock ? 'green' : 'red'}
    >
      <Flex align="center">
        <Flex.Item grow={1}>
          Security protocol {hacked ? 'disengaged' : 'engaged'}. Swipe a valid
          ID to unlock safety controls.
        </Flex.Item>
        <Flex.Item>
          <Button
            m={0}
            color={sec_interface_unlock ? 'green' : 'red'}
            icon={sec_interface_unlock ? 'unlock' : 'lock'}
            onClick={() => act('toggle_safety')}
          >
            {hacked ? 'Reactivate' : 'Deactivate'}
          </Button>
        </Flex.Item>
        <Flex.Item mx={1}>
          <Button
            m={0}
            color={sec_interface_unlock ? 'green' : 'red'}
            icon={sec_interface_unlock ? 'unlock' : 'lock'}
            onClick={() => act('toggle_lock')}
          >
            {sec_interface_unlock ? 'Unlocked' : 'Locked'}
          </Button>
        </Flex.Item>
      </Flex>
    </NoticeBox>
  ) : (
    <NoticeBox textAlign="center" color="orange">
      Nanotrasen Fabrication Unit V1.0.4
    </NoticeBox>
  );
};

export const ModFabData = () => {
  return (
    <Section height="100px">
      <ModFabDataDisk />
      <Box width="150px" inline>
        <Box bold align="center" height={1.5}>
          Output Direction
        </Box>
        <OutputDir />
      </Box>
    </Section>
  );
};

export const OutputDir = () => {
  const { act, data } = useBackend<Data>();
  const { output_direction = 0 } = data;
  return (
    <Table width="80px" align="center">
      <Table.Row>
        <Table.Cell />
        <Table.Cell>
          <Button
            icon="arrow-up"
            color={output_direction === 1 ? 'green' : 'red'}
            onClick={() =>
              act('output_dir', {
                direction: 1,
              })
            }
          />
        </Table.Cell>
        <Table.Cell />
      </Table.Row>
      <Table.Row>
        <Table.Cell>
          <Button
            icon="arrow-left"
            color={output_direction === 8 ? 'green' : 'red'}
            onClick={() =>
              act('output_dir', {
                direction: 8,
              })
            }
          />
        </Table.Cell>
        <Table.Cell>
          <Button
            icon="circle"
            color={output_direction === 0 ? 'green' : 'red'}
            onClick={() =>
              act('output_dir', {
                direction: 0,
              })
            }
          />
        </Table.Cell>
        <Table.Cell>
          <Button
            icon="arrow-right"
            color={output_direction === 4 ? 'green' : 'red'}
            onClick={() =>
              act('output_dir', {
                direction: 4,
              })
            }
          />
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell />
        <Table.Cell>
          <Button
            icon="arrow-down"
            color={output_direction === 2 ? 'green' : 'red'}
            onClick={() =>
              act('output_dir', {
                direction: 2,
              })
            }
          />
        </Table.Cell>
        <Table.Cell />
      </Table.Row>
    </Table>
  );
};

export const ContainedMaterials = () => {
  const { act, data } = useBackend<Data>();
  const { contained_materials } = data;
  return contained_materials.filter((material) => material.amount > 0)
    .length === 0 ? (
    <div className="material_warning">No materials inserted</div>
  ) : (
    <>
      <Box bold width="100%" textAlign="center" mb={1}>
        Materials
      </Box>
      <Flex direction="column">
        {contained_materials
          .filter((material) => material.amount > 0)
          .map((material) => (
            <Flex.Item key={material.typepath}>
              <Flex direction="row">
                <Flex.Item>
                  <Box>{capitalize(material.name)}</Box>
                </Flex.Item>
                <Flex.Item grow={1} />
                <Flex.Item mr={1}>
                  <Box>{material.amount} sheets</Box>
                </Flex.Item>

                <Flex.Item>
                  <Button
                    color="green"
                    disabled={material.amount < 1}
                    onClick={() =>
                      act('eject_material', {
                        material_datum: material.typepath,
                        amount: 1,
                      })
                    }
                  >
                    x1
                  </Button>
                </Flex.Item>
                <Flex.Item>
                  <Button
                    color="green"
                    disabled={material.amount < 10}
                    onClick={() =>
                      act('eject_material', {
                        material_datum: material.typepath,
                        amount: 10,
                      })
                    }
                  >
                    x10
                  </Button>
                </Flex.Item>
                <Flex.Item>
                  <Button
                    color="green"
                    disabled={material.amount < 50}
                    onClick={() =>
                      act('eject_material', {
                        material_datum: material.typepath,
                        amount: 50,
                      })
                    }
                  >
                    x50
                  </Button>
                </Flex.Item>
              </Flex>
            </Flex.Item>
          ))}
      </Flex>
    </>
  );
};

export const SidePanel = () => {
  const { act } = useBackend();
  const [queueRepeat, setQueueRepeat] = useState(0);

  return (
    <Section fill className="no_overflow">
      <Flex direction="column" height="100%">
        <Flex.Item minHeight="30%" shrink={1} className="scroll_vertically">
          <ContainedMaterials />
        </Flex.Item>
        <Flex.Item>
          <Divider />
        </Flex.Item>
        <Flex.Item>
          <Flex align="center">
            <Flex.Item bold grow={1}>
              Queue
            </Flex.Item>
            <Flex.Item>
              <Button
                m={0}
                color={queueRepeat ? 'green' : 'red'}
                icon="redo-alt"
                content={queueRepeat ? 'Continuous' : 'Linear'}
                onClick={() => {
                  act('queue_repeat', {
                    repeating: 1 - queueRepeat,
                  });
                  setQueueRepeat(1 - queueRepeat);
                }}
              />
            </Flex.Item>
            <Flex.Item mx={1}>
              <Button
                m={0}
                color="red"
                icon="times"
                content="Clear"
                onClick={() => act('clear_queue')}
              />
            </Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item>
          <Divider />
        </Flex.Item>
        <Flex.Item shrink={1} className="scroll_vertically">
          <FabricationQueue />
        </Flex.Item>
        <Flex.Item grow={1} />
        <Flex.Item>
          <ProcessingBar />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const ProcessingBar = (props) => {
  const { act, data } = useBackend<Data>();
  const { being_built } = data;
  return (
    <div className="processing_bar">
      <Button
        content="Process"
        color="green"
        icon="caret-right"
        onClick={() => act('begin_process')}
      />
      {being_built ? (
        <ProgressBar
          value={being_built.progress}
          minValue={0}
          maxValue={100}
          color="green"
          width="100%"
        >
          {being_built.name} - {Math.min(round(being_built.progress, 1), 100)}%
        </ProgressBar>
      ) : (
        <NoticeBox bold width="100%" inline>
          Not Processing.
        </NoticeBox>
      )}
    </div>
  );
};

export const FabricationQueue = (props) => {
  const { act, data } = useBackend<Data>();
  const { design_queue } = data;
  return (
    <Flex direction="column">
      {design_queue.map((item) => (
        <Flex.Item key={item}>
          <Flex direction="row" key={item}>
            <Flex.Item bold>{item.name}</Flex.Item>
            <Flex.Item grow={1} />
            <Flex.Item mr={1}>x{item.amount}</Flex.Item>
            <Flex.Item collapsing mr={1}>
              <Button
                icon="redo-alt"
                color={item.repeat ? 'green' : 'red'}
                onClick={() =>
                  act('item_repeat', {
                    design_id: item.design_id,
                    repeating: !item.repeat,
                  })
                }
              />
            </Flex.Item>
            <Flex.Item collapsing mr={1}>
              <Button
                icon="times"
                color="red"
                onClick={() =>
                  act('clear_item', {
                    design_id: item.design_id,
                  })
                }
              />
            </Flex.Item>
          </Flex>
        </Flex.Item>
      ))}
    </Flex>
  );
};

export const ModFabDataDisk = () => {
  const { act, data } = useBackend<Data>();
  const { accepts_disk, disk_inserted, can_upload_disk } = data;

  return (
    <Box inline>
      <Box bold textAlign="center">
        Data Disk Drive
      </Box>
      <Table>
        <Table.Row>
          <Table.Cell>Status:</Table.Cell>
          <Table.Cell
            bold
            color={accepts_disk ? (disk_inserted ? 'green' : 'yellow') : 'red'}
          >
            {accepts_disk ? (disk_inserted ? 'Ready' : 'Empty') : 'Inactive'}
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colSpan={2} textAlign="center" bold>
            Actions
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colSpan={2} textAlign="center" bold>
            <Button
              color={
                accepts_disk && disk_inserted && can_upload_disk
                  ? 'green'
                  : 'grey'
              }
              icon="upload"
              onClick={() => act('upload_disk')}
            >
              Upload
            </Button>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colSpan={2} textAlign="center" bold>
            <Button
              color={accepts_disk && disk_inserted ? 'green' : 'grey'}
              icon="folder-open"
              onClick={() => act('eject_disk')}
            >
              Eject
            </Button>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Box>
  );
};
