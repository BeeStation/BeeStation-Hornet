import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Input, NoticeBox, ProgressBar, Section, Divider, Flex, Table, Grid, NumberInput, Tabs } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { capitalize, createSearch } from 'common/string';
import { round } from 'common/math';

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
export const ModularFabricator = (props, context) => {
  return (
    <Window width={1000} height={714}>
      <Window.Content>
        <div className="ModularFabricator__top">
          <ModFabData />
        </div>
        <div className="ModularFabricator__bottom">
          <div className="ModularFabricator__main">
            <ModFabMain />
          </div>
          <div className="ModularFabricator__sidebar">
            <SidePanel />
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

export const ModFabMain = (props, context) => {
  const { act, data } = useBackend(context);
  const [category, setCategory] = useLocalState(context, 'category', '');
  const { items = [] } = data;
  const [search, setSearch] = useLocalState(context, 'search', '');
  const testSearch = createSearch(search, (item) => {
    return item.name;
  });
  let selected_category_items;
  if (search) {
    selected_category_items = items
      .flatMap((category) => category.category_items || [])
      .filter(testSearch)
      .filter((item, i) => i < MAX_SEARCH_RESULTS);
  } else {
    for (let i = 0; i < items.length; i++) {
      if (items[i].category_name === category) {
        selected_category_items = items[i].category_items;
      }
    }
  }
  return (
    <Section overflowY="scroll" height="100%" width="100%">
      <ModFabCategoryList categories={items} />
      <Divider />
      {selected_category_items ? <ModFabCategoryItems items={selected_category_items} /> : ''}
    </Section>
  );
};

export const ModFabCategoryList = (props, context) => {
  const { categories } = props;
  const [category, setCategory] = useLocalState(context, 'category', '');
  const [search, setSearch] = useLocalState(context, 'search', '');
  return (
    <Fragment>
      <Box bold>
        <Grid>
          <Grid.Column>Categories</Grid.Column>
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
    </Fragment>
  );
};

export const ModFabCategoryItems = (props, context) => {
  const { act, data } = useBackend(context);
  const { allow_add_category = true } = data;
  const { items } = props;
  const [category, setCategory] = useLocalState(context, 'category', '');
  const [amount, setAmount] = useLocalState(context, 'amount', 1);
  const [search, setSearch] = useLocalState(context, 'search', '');
  return (
    <Fragment>
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
      <Table height="100%">
        {items.map((item) => (
          <Table.Row height="100%" key={item.design_id}>
            <Table.Cell>{item.name}</Table.Cell>
            <Table.Cell>
              {item.material_cost.map((mat) => (
                <Box key={mat.name}>
                  {mat.name} ({mat.amount})
                </Box>
              ))}
              <Divider />
            </Table.Cell>
            <Table.Cell collapsing verticalAlign="middle">
              <Button
                icon="minus"
                onClick={() => {
                  amount !== 0 && setAmount(amount - 1);
                }}
              />
            </Table.Cell>
            <Table.Cell collapsing verticalAlign="middle">
              <NumberInput value={amount} minValue={0} maxValue={50} onChange={(e, value) => setAmount(value)} />
            </Table.Cell>
            <Table.Cell collapsing verticalAlign="middle">
              <Button
                icon="plus"
                onClick={() => {
                  amount !== 50 && setAmount(amount + 1);
                }}
              />
            </Table.Cell>
            <Table.Cell collapsing verticalAlign="middle">
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
    </Fragment>
  );
};

export const ModFabData = (props, context) => {
  const { act, data } = useBackend(context);
  const { hacked, sec_interface_unlock, show_unlock_bar, can_sync = true } = data;
  return (
    <Fragment>
      {show_unlock_bar ? (
        <NoticeBox color={sec_interface_unlock ? 'green' : 'red'}>
          <Flex align="center">
            <Flex.Item grow={1}>
              Security protocol {hacked ? 'disengaged' : 'engaged'}. Swipe a valid ID to unlock safety controls.
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
      )}
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
    </Fragment>
  );
};

export const SyncWithServers = (props, context) => {
  const { act } = useBackend(context);
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
            <Button color={'green'} content="Resync" icon="upload" onClick={() => act('resync_rd')} />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Box>
  );
};

export const OutputDir = (props, context) => {
  const { act, data } = useBackend(context);
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

export const MaterialData = (props, context) => {
  const { act, data } = useBackend(context);
  const { materials = [] } = data;
  return (
    <Table>
      {materials.map((material) => (
        <Fragment key={material.name}>
          <Table.Row>
            <Table.Cell>{capitalize(material.name)}</Table.Cell>
            <Table.Cell>{material.amount} sheets</Table.Cell>
            <Table.Cell>
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
            </Table.Cell>
            <Table.Cell>
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
            </Table.Cell>
            <Table.Cell>
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
            </Table.Cell>
          </Table.Row>
        </Fragment>
      ))}
    </Table>
  );
};

export const SidePanel = (props, context) => {
  const { act } = useBackend(context);
  const [queueRepeat, setQueueRepeat] = useLocalState(context, 'queueRepeat', 0);
  return (
    <Section width="100%" height="100%">
      <MaterialData />
      <Divider />
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
          <Button m={0} color="red" icon="times" content="Clear" onClick={() => act('clear_queue')} />
        </Flex.Item>
      </Flex>
      <Divider />
      <FabricationQueue />
      <ProcessingBar />
    </Section>
  );
};

export const ProcessingBar = (props, context) => {
  const { act, data } = useBackend(context);
  const { being_build } = data;
  return (
    <div className="ModularFabricator__sidebar_bottom">
      <Button content="Process" color="green" icon="caret-right" onClick={() => act('begin_process')} />
      {being_build ? (
        <ProgressBar value={being_build.progress} minValue={0} maxValue={100} color="green" width="75%">
          {being_build.name} - {Math.min(round(being_build.progress), 100)}%
        </ProgressBar>
      ) : (
        <NoticeBox bold width="75%" inline>
          Not Processing.
        </NoticeBox>
      )}
    </div>
  );
};

export const FabricationQueue = (props, context) => {
  const { act, data } = useBackend(context);
  const { queue = [] } = data;
  return (
    <Table>
      {queue.map((item) => (
        <Table.Row key={item}>
          <Table.Cell bold>{item.name}</Table.Cell>
          <Table.Cell>x{item.amount}</Table.Cell>
          <Table.Cell collapsing>
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
          </Table.Cell>
          <Table.Cell collapsing>
            <Button
              icon="times"
              color="red"
              onClick={() =>
                act('clear_item', {
                  design_id: item.design_id,
                })
              }
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

export const ModFabDataDisk = (props, context) => {
  const { act, data } = useBackend(context);
  const { acceptsDisk, diskInserted } = data;
  return (
    <Box inline>
      <Box bold textAlign="center">
        Data Disk Drive
      </Box>
      <Table>
        <Table.Row>
          <Table.Cell>Status:</Table.Cell>
          <Table.Cell bold color={acceptsDisk ? (diskInserted ? 'green' : 'yellow') : 'red'}>
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
