import { classes } from 'common/react';
import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, Icon, LabeledList, NoticeBox, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

type VendingData = {
  onstation: boolean;
  department: string;
  product_records: ProductRecord[];
  coin_records: CoinRecord[];
  hidden_records: HiddenRecord[];
  user: UserData;
  stock: StockItem[];
  extended_inventory: boolean;
  access: boolean;
  vending_machine_input: CustomInput[];
  categories: Record<string, Category>;
};

type Category = {
  icon: string;
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  max_amount: number;
  ref: string;
  category: string;
};

type CoinRecord = ProductRecord & {
  premium: boolean;
};

type HiddenRecord = ProductRecord & {
  premium: boolean;
};

type UserData = {
  name: string;
  cash: number;
  job: string;
  department: string;
};

type StockItem = {
  name: string;
  amount: number;
  colorable: boolean;
};

type CustomInput = {
  name: string;
  price: number;
  img: string;
};


export const Vending = (props, context) => {
  const { data } = useBackend<VendingData>(context);
  const {
    onstation,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    stock,
  } = data;

  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    context,
    'selectedCategory',
    Object.keys(data.categories)[0]
  );

  let inventory: (ProductRecord | CustomInput)[];
  let custom = false;
  if (data.vending_machine_input) {
    inventory = data.vending_machine_input;
    custom = true;
  } else {
    inventory = [...product_records, ...coin_records];
    if (data.extended_inventory) {
      inventory = [...inventory, ...hidden_records];
    }
  }

  inventory = inventory
    // Just in case we still have undefined values in the list
    .filter((item) => !!item);

  const filteredCategories = Object.fromEntries(
    Object.entries(data.categories).filter(([categoryName]) => {
      return inventory.find((product) => {
        if ('category' in product) {
          return product.category === categoryName;
        } else {
          return false;
        }
      });
    })
  );
  return (
    <Window width={450} height={600}>
      <Window.Content>
        <Stack fill vertical>
          {!!onstation && (
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <ProductDisplay
              custom={custom}
              inventory={inventory}
              selectedCategory={selectedCategory}
            />
          </Stack.Item>

          {Object.keys(filteredCategories).length > 1 && (
            <Stack.Item>
              <CategorySelector
                categories={filteredCategories}
                selectedCategory={selectedCategory!}
                onSelect={setSelectedCategory}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details if an ID is present and the user is on the station */
const UserDetails = (props, context) => {
  const { data } = useBackend<VendingData>(context);
  const { user } = data;

  if (!user) {
    return (
      <NoticeBox>No ID detected! Contact the Head of Personnel.</NoticeBox>
    );
  } else {
    return (
      <Section>
        <Stack>
          <Stack.Item>
            <Icon name="id-card" size={3} mr={1} />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="User">{user.name}</LabeledList.Item>
              <LabeledList.Item label="Occupation">
                {user.job || 'Unemployed'}
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};

/** Displays  products in a section, with user balance at top */
const ProductDisplay = (
  props: {
    custom: boolean;
    selectedCategory: string | null;
    inventory: (ProductRecord | CustomInput)[];
  },
  context
) => {
  const { data } = useBackend<VendingData>(context);
  const { custom, inventory, selectedCategory } = props;
  const { stock, onstation, user } = data;
  return (
    <Section
      fill
      scrollable
      title="Products"
      buttons={
        !!onstation
        && user && (
          <Box fontSize="16px" color="green">
            {(user && user.cash) || 0} cr <Icon name="coins" color="gold" />
          </Box>)
      }>
      <Table>
        {inventory
          .filter((product) => {
            if ('category' in product) {
              return product.category === selectedCategory;
            } else {
              return true;
            }
          })
          .map((product) => (
            <VendingRow
              key={product.name}
              custom={custom}
              product={product}
              productStock={stock[product.name]}
            />
          ))}
      </Table>
    </Section>
  );
};

/** An individual listing for an item.
* Uses a table layout - Labeledlist might be better,
* but you cannot use item icons as labels currently.
*/
const VendingRow = (props, context) => {
  const { data } = useBackend<VendingData>(context);
  const { custom, product, productStock } = props;
  const { department, onstation, user } = data;
  const free
  = !onstation
  || product.price === 0
  || (!product.premium && department && user);

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <ProductImage product={product} />
      </Table.Cell>
      <Table.Cell bold>
        {product.name.replace(/^\w/, (c) => c.toUpperCase())}
      </Table.Cell>
      <Table.Cell>
        {!!productStock?.colorable && (
          <ProductColorSelect free={free} product={product} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <ProductStock
          custom={custom}
          product={product}
          productStock={productStock}
        />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <ProductButton
          free={free}
          product={product}
          productStock={productStock}
        />
      </Table.Cell>
    </Table.Row>
  );
};

/** Displays the product image. Displays a default if there is none. */
const ProductImage = (props) => {
  const { product } = props;

  return product.img ? (
    <img
      src={`data:image/jpeg;base64,${product.img}`}
      style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
      }}
    />
  ) : (
    <span
      className={classes(['vending32x32', product.path])}
      style={{
        'vertical-align': 'middle',
        'horizontal-align': 'middle',
      }}
    />
  );
};

/** Displays a colored indicator for remaining stock */
const ProductStock = (props) => {
  const { custom, product, productStock } = props;

  return (
    <Box
      color={
        (custom && 'good')
      || (productStock.amount <= 0 && 'bad')
      || (productStock.amount <= product.max_amount / 2 && 'average')
      || 'good'
      }>
      {custom ? product.amount : productStock.amount} left
    </Box>
  );
};

/** In the case of customizable items, ie: shoes,
* this displays a color wheel button that opens another window.
*/
const ProductColorSelect = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { user, onstation, department } = data;
  const { product, productStock } = props;
  const free
  = !onstation
  || product.price === 0
  || (!product.premium && department && user);

  return (
    <Button
      icon="palette"
      tooltip="Change color"
      disabled={
        productStock?.amount === 0
      || (!user || (product.price > user.cash && !free))
      }
      onClick={() => act('select_colors', { ref: product.ref })}
    />
  );
};

/** The main button to purchase an item. */
const ProductButton = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { access, department, user, onstation } = data;
  const { custom, free, product, productStock } = props;
  const discount
  = department === user?.department && !product.premium || !data.onstation;
  const redPrice = Math.round(product.price * 0);

  return custom ? (
    <Button
      fluid
      disabled={
        productStock.amount === 0
      || ((!user || (product.price > user.cash && !free)) && onstation)
      }
      content={access ? 'FREE' : product.price + ' cr'}
      onClick={() =>
        act('dispense', {
          'item': product.name,
        })}
    />
  ) : (
    <Button
      fluid
      disabled={
        productStock.amount === 0
      || ((!user || (product.price > user.cash && !free)) && onstation)
      }
      content={discount ? 'FREE' : product.price + ' cr'}
      onClick={() =>
        act('vend', {
          'ref': product.ref,
        })}
    />
  );
};

const CATEGORY_COLORS = {
  'Contraband': 'red',
  'Premium': 'yellow',
};

const CategorySelector = (props: {
  categories: Record<string, Category>;
  selectedCategory: string;
  onSelect: (category: string) => void;
}) => {
  const { categories, selectedCategory, onSelect } = props;

  return (
    <Section>
      <Stack grow>
        <Stack.Item>
          {Object.entries(categories).map(([name, category]) => (
            <Button
              key={name}
              selected={name === selectedCategory}
              color={CATEGORY_COLORS[name]}
              icon={category.icon}
              onClick={() => onSelect(name)}>
              {name}
            </Button>
          ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
