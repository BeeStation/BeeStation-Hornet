import { round } from 'common/math';
import { capitalize, createSearch } from 'common/string';
import { Fragment } from 'react';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Grid,
  Input,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

/*
 * Modular Fabricator Interface By PowerfulBacon
 * ---------------------------------------------
 * Examples of use: Autolathe, Exosuit fabricator
 * =============================================
 * Modular Fabricator Changelog:
 *  - Instead of using datums as IDs for ui_act,
====the /datum/design ID is used instead
 *  - Made the comment look ugly because of TGUI max
====line limit :(
====I promise this was readable before
 * =============================================
 * Instructions on use:
 * Under ui_interact open the interface (pretty
 simple)
 * [R] - required.
 * [*] - recommended
 *
 * ui_data / ui_static_data things:
 *  - [R] can_sync - If TRUE the Sync R&D button will be displayed
 *  - [R] allow_add_category - If TRUE a button will be added that lets the
====user queue all items in the category.
 *  - [R] show_unlock_bar - TRUE if the interface can be hacked / unlocked.
 *  - [*] sec_interface_unlock - TRUE if the security
====interface is unlocked. You probably want to set it to
====true when a sec ID is scanned, or the thing is hacked.
 *  - [*] hacked - TRUE if the interface is hacked
 *  - [R] outputDir ("center", "left", "right", "up", "down")
====- Direction of output
 *  - [R] acceptsDisk - Does this interface accept data disks?
====If false the data disk drive on the UI will display is 'inactive'
 *  - [*] diskInserted - Required if you accept disks. Will unlock
====the install and eject buttons when set to TRUE.
 *  - [R] materials - List of all inserted materials (or linked
====silo materials if you want that)
 *        list(list(
 *          name = "Iron",
====Name of the material in the UI
 *          amount = 50000,
====Amount of the material in the UI
====(Divided by 2000 to calculate sheet amount)
 *          design_id = "iron",
====The design ID required for ui_act
 *        ))
 *  - [R] queue - List of all items in the processing queue
 *        list(list(
 *          name = "Battery",           //The name of the thing to display
 *          amount = 8,                 //The amount left to display
 *          repeat = FALSE,             //Will the repeat icon on the
====interface be green?
====You will have to handle the repeating yourself.
 *          design_id = "a",            //The design ID of the object in queue
====regular queue?
 *        ))
 *  - [R] items - List of all possible printable items
 *        list(list(
 *          category_name = "batteries",        //Category Name
 *          category_items = list(
 *            list(
 *              name = "Battery"                //Display name of the item
 *              design_id = "battery"           //Design ID of the object
 *              material_cost = list(
 *               list("name" = "iron", "amount" = "2000"),
 *               list("name" = "copper", "amount" = "5000"),
 *              )
 *            ),
 *            list(
 *              name = "Battery2"               //Display name of the item
 *              design_id = "battery2"          //Design ID of the object
 *              material_cost = list(
 *               list("name" = "iron", "amount" = "2000"),
 *               list("name" = "copper", "amount" = "5000"),
 *              )
 *            ),
 *          ),
 *        ))
 *  - [R] being_built - What is being built (can be null)
 *      list(list(
 *        design_id,
 *        name,
 *        progress,
 *      ))
 *
 * ui_act things:
 *  - [R] toggle_lock -
 *  - [R] toggle_safety - Toggles the safeties.
    Button is only green when sec_interface_unlock = FALSE
 *  - [R] output_dir - Set the output direction when this is called.
    Parameters: direction (string)
 *  - [*] upload_disk - When the install button is pressed on disk.
    You should upload all tech in the inserted disk into the internal tech tree.
 *  - [*] eject_disk - Eject the inserted disk.
 *  - [R] eject_material - Ejects a material.
    parameters: material_datum, amount (int)
 *  - [R] queue_repeat - When repeating mode on the queue is changed.
    Parameters: repeating (bool)
 *  - [R] clear_queue - Clear the queue.
 *  - [R] item_repeat - When repeating mode an a specific item is toggled.
    Parameters: repeating (bool), item_datum
 *  - [R] clear_item - Clear an item from the queue
    Parameters: design_id
 *  - [R] queue_item - Add an item to the queue
    Parameters: design_id, amount, item_name
 *  - [R] begin_process - Beings processing the queue
    (Nothing to stop this being automatic)
 *  - [*] queue_category - Queues an entier category
    Parameters: category_name (string)
 *  - [*] resync_rd - Resync with nearby R&D Servers
 *
*/
export const ModularFabricator = (props) => {
  return (
    <Window width={1000} height={714}>
      <Window.Content>
        <div className="ModularFabricator">
          <div className="vertical fill_height">
            <ModFabSecurityMessage />
            <div className="horizontal">
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

export const ModFabMain = (props) => {
  const { act, data } = useBackend();
  const [category, setCategory] = useLocalState('category', '');
  const { items = [] } = data;
  const [search, setSearch] = useLocalState('search', '');
  const testSearch = createSearch(search, (item) => {
    return item.name;
  });
  let selected_category_items;
  if (search) {
    let repeats = new Set();
    selected_category_items = items
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
    for (let i = 0; i < items.length; i++) {
      if (items[i].category_name === category) {
        // don't need to check for repeats as this (shouldn't) have repeats
        selected_category_items = items[i].category_items;
      }
    }
  }
  return (
    <>
      <ModFabCategoryList categories={items} />
      <Divider />
      {selected_category_items ? (
        <ModFabCategoryItems items={selected_category_items} />
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
        <Grid>
          <Grid.Column bold>Categories</Grid.Column>
          <Grid.Column textAlign="right">
            {'Search: '}
            <Input
              align="right"
              value={search}
              onInput={(e, value) => {
                setSearch(value);
              }}
            />
          </Grid.Column>
        </Grid>
      </Box>
      <Divider />
      {categories.map((category) => (
        <Fragment key={category.category_name}>
          <Button
            width="200px"
            content={category.category_name}
            icon="angle-right"
            onClick={() => {
              setCategory(category.category_name);
              setSearch('');
            }}
          />
        </Fragment>
      ))}
    </>
  );
};

export const ModFabCategoryItems = (props) => {
  const { act, data } = useBackend();
  const { allow_add_category = true } = data;
  const { items } = props;
  const [category, setCategory] = useLocalState('category', '');
  const [amount, setAmount] = useLocalState('amount', 1);
  const [search, setSearch] = useLocalState('search', '');

  return (
    <>
      <Button
        content="Return"
        icon="backspace"
        onClick={() => {
          setCategory('');
        }}
      />
      {!!(allow_add_category && !search) && (
        <Button
          content="Add Category"
          icon="backspace"
          onClick={() =>
            act('queue_category', {
              category_name: category,
            })
          }
        />
      )}
      <Table className="item_table">
        {items.map((item) => (
          /* CSS can't handle height of divs inside table cells for some reason */
          <Table.Row key={item.design_id} height="1px" className="item_row">
            <Table.Cell height="inherit" pr={0}>
              <div className="item_property_container">
                <div className="item_name">{item.name}</div>
                {!!item.desc && <div className="item_desc">{item.desc}</div>}
              </div>
            </Table.Cell>
            <Table.Cell pl={0} className="item_costs">
              <div className="item_property_container">
                {item.material_cost.map((mat) => (
                  <Box key={mat.name}>
                    {mat.name} ({mat.amount})
                  </Box>
                ))}
              </div>
            </Table.Cell>
            <Table.Cell
              collapsing
              verticalAlign="middle"
              className="item_small_button"
            >
              <Button
                icon="minus"
                onClick={() => {
                  amount !== 0 && setAmount(amount - 1);
                }}
              />
            </Table.Cell>
            <Table.Cell
              collapsing
              verticalAlign="middle"
              className="item_small_button"
            >
              <NumberInput
                value={amount}
                minValue={0}
                maxValue={50}
                step={1}
                onChange={(value) => setAmount(value)}
              />
            </Table.Cell>
            <Table.Cell
              collapsing
              verticalAlign="middle"
              className="item_small_button"
            >
              <Button
                icon="plus"
                onClick={() => {
                  amount !== 50 && setAmount(amount + 1);
                }}
              />
            </Table.Cell>
            <Table.Cell
              collapsing
              verticalAlign="middle"
              className="item_large_button"
            >
              <Button
                icon="plus-circle"
                content="Queue"
                onClick={() =>
                  act('queue_item', {
                    design_id: item.design_id,
                    amount: amount,
                    item_name: item.name,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </>
  );
};

export const ModFabSecurityMessage = (props) => {
  const { act, data } = useBackend();
  const {
    hacked,
    sec_interface_unlock,
    show_unlock_bar,
    can_sync = true,
  } = data;
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
            content={hacked ? 'Reactivate' : 'Deactivate'}
            onClick={() => act('toggle_safety')}
          />
        </Flex.Item>
        <Flex.Item mx={1}>
          <Button
            m={0}
            color={sec_interface_unlock ? 'green' : 'red'}
            icon={sec_interface_unlock ? 'unlock' : 'lock'}
            content={sec_interface_unlock ? 'Unlocked' : 'Locked'}
            onClick={() => act('toggle_lock')}
          />
        </Flex.Item>
      </Flex>
    </NoticeBox>
  ) : (
    <NoticeBox textAlign="center" color="orange">
      Nanotrasen Fabrication Unit V1.0.4
    </NoticeBox>
  );
};

export const ModFabData = (props) => {
  const { data } = useBackend();
  const { can_sync = true } = data;
  return (
    <Section height="100px">
      <ModFabDataDisk />
      <Box width="150px" inline>
        <Box bold align="center" height={1.5}>
          Output Direction
        </Box>
        <OutputDir />
      </Box>
      {!!can_sync && <SyncWithServers />}
    </Section>
  );
};

export const SyncWithServers = (props) => {
  const { act } = useBackend();
  return (
    <Box inline>
      <Box bold textAlign="center">
        Research Database
      </Box>
      <Table>
        <Table.Row>
          <Table.Cell colspan={2} textAlign="center" bold>
            Actions:
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colspan={2} textAlign="center" bold>
            <Button
              color={'green'}
              content="Resync"
              icon="upload"
              onClick={() => act('resync_rd')}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Box>
  );
};

export const OutputDir = (props) => {
  const { act, data } = useBackend();
  const { outputDir = 0 } = data;
  return (
    <Table width="80px" align="center">
      <Table.Row>
        <Table.Cell />
        <Table.Cell>
          <Button
            icon="arrow-up"
            color={outputDir === 1 ? 'green' : 'red'}
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
            color={outputDir === 8 ? 'green' : 'red'}
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
            color={outputDir === 0 ? 'green' : 'red'}
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
            color={outputDir === 4 ? 'green' : 'red'}
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
            color={outputDir === 2 ? 'green' : 'red'}
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

export const MaterialData = (props) => {
  const { act, data } = useBackend();
  const { materials = [] } = data;
  return materials.filter((material) => material.amount > 0).length === 0 ? (
    <div className="material_warning">No materials inserted</div>
  ) : (
    <>
      <Box bold width="100%" textAlign="center" mb={1}>
        Materials
      </Box>
      <Flex direction="column">
        {materials
          .filter((material) => material.amount > 0)
          .map((material) => (
            <Flex.Item key={material.datum}>
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
                    content="x1"
                    onClick={() =>
                      act('eject_material', {
                        material_datum: material.datum,
                        amount: 1,
                      })
                    }
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    color="green"
                    disabled={material.amount < 10}
                    content="x10"
                    onClick={() =>
                      act('eject_material', {
                        material_datum: material.datum,
                        amount: 10,
                      })
                    }
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    color="green"
                    disabled={material.amount < 50}
                    content="x50"
                    onClick={() =>
                      act('eject_material', {
                        material_datum: material.datum,
                        amount: 50,
                      })
                    }
                  />
                </Flex.Item>
              </Flex>
            </Flex.Item>
          ))}
      </Flex>
    </>
  );
};

export const SidePanel = (props) => {
  const { act } = useBackend();
  const [queueRepeat, setQueueRepeat] = useLocalState('queueRepeat', 0);
  return (
    <Section fill>
      <Flex direction="column" height="100%">
        <Flex.Item minHeight="30%">
          <MaterialData />
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
        <Flex.Item>
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
  const { act, data } = useBackend();
  const { being_build } = data;
  return (
    <div className="processing_bar">
      <Button
        content="Process"
        color="green"
        icon="caret-right"
        onClick={() => act('begin_process')}
      />
      {being_build ? (
        <ProgressBar
          value={being_build.progress}
          minValue={0}
          maxValue={100}
          color="green"
          width="100%"
        >
          {being_build.name} - {Math.min(round(being_build.progress), 100)}%
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
  const { act, data } = useBackend();
  const { queue = [] } = data;
  return (
    <Flex direction="column">
      {queue.map((item) => (
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
                    repeating: 1 - item.repeat,
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

export const ModFabDataDisk = (props) => {
  const { act, data } = useBackend();
  const { acceptsDisk, diskInserted } = data;
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
            color={acceptsDisk ? (diskInserted ? 'green' : 'yellow') : 'red'}
          >
            {acceptsDisk ? (diskInserted ? 'Ready' : 'Empty') : 'Inactive'}
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colspan={2} textAlign="center" bold>
            Actions
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colspan={2} textAlign="center" bold>
            <Button
              color={acceptsDisk && diskInserted ? 'green' : 'grey'}
              content="Install"
              icon="upload"
              onClick={() => act('upload_disk')}
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell colspan={2} textAlign="center" bold>
            <Button
              color={acceptsDisk && diskInserted ? 'green' : 'grey'}
              content="Eject"
              icon="folder-open"
              onClick={() => act('eject_disk')}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Box>
  );
};
