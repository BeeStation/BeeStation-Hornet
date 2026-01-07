import { useState } from 'react';
import {
  Button,
  Icon,
  ImageButton,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeAll, createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { getLayoutState, LAYOUT, LayoutToggle } from './common/LayoutToggle';

type GearRequisitionData = {
  product_records: ProductRecord[];
  categories: Record<string, Category>;
  user: UserData;
};

type Category = {
  icon: string;
};

type ProductRecord = {
  path: string;
  name: string;
  price: number;
  ref: string;
  category: string;
  icon?: string;
  icon_state?: string;
};

type UserData = {
  name?: string;
  job?: string;
  points?: number;
  currency_type?: string;
  access_valid?: boolean;
  card_found?: boolean;
  observer?: boolean;
};

interface ProductDisplayProps {
  inventory: ProductRecord[];
  stockSearch: string;
  setStockSearch: (search: string) => void;
  selectedCategory: string;
}

interface ProductProps {
  product: ProductRecord;
  fluid: boolean;
}

interface ProductPriceProps {
  product: ProductRecord;
}

interface CategorySelectorProps {
  categories: Record<string, Category>;
  selectedCategory: string;
  onSelect: (category: string) => void;
}

export const GearRequisition = () => {
  const { data } = useBackend<GearRequisitionData>();

  const { product_records = [], categories } = data;

  const [selectedCategory, setSelectedCategory] = useState<string>(
    Object.keys(categories)[0],
  );
  const [stockSearch, setStockSearch] = useState<string>('');
  const stockSearchFn = createSearch(
    stockSearch,
    (item: ProductRecord) => item.name,
  );

  let inventory: ProductRecord[] = [...product_records];

  // Filter by search if search term is long enough
  if (stockSearch.length >= 2) {
    inventory = inventory.filter(stockSearchFn);
  }

  // Filter categories to only show ones that have products
  const filteredCategories = Object.fromEntries(
    Object.entries(categories).filter(([categoryName]) => {
      return product_records.find(
        (product) => product.category === categoryName,
      );
    }),
  );

  return (
    <Window width={431} height={635}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <UserDetails />
          </Stack.Item>
          <Stack.Item grow>
            <ProductDisplay
              inventory={inventory}
              stockSearch={stockSearch}
              setStockSearch={setStockSearch}
              selectedCategory={selectedCategory}
            />
          </Stack.Item>
          {stockSearch.length < 2 &&
            Object.keys(filteredCategories).length > 1 && (
              <Stack.Item>
                <CategorySelector
                  categories={filteredCategories}
                  selectedCategory={selectedCategory}
                  onSelect={setSelectedCategory}
                />
              </Stack.Item>
            )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details with mining points balance */
export const UserDetails = () => {
  const { data } = useBackend<GearRequisitionData>();
  const { user } = data;

  const hasAccess = user?.access_valid || user?.observer;
  const hasCard = user?.card_found;

  return (
    <NoticeBox m={0} color={hasAccess ? 'blue' : hasCard ? 'yellow' : 'red'}>
      <Stack align="center">
        <Stack.Item>
          <Icon name="id-card" size={1.5} />
        </Stack.Item>
        <Stack.Item grow>
          {hasAccess ? (
            <>
              Welcome, <b>{user.name || 'Unknown'}</b>,{' '}
              <b>{user.job || 'Unemployed'}</b>!
              <br />
              Your balance is{' '}
              <b>
                {user.points || 0} {user.currency_type || 'points'}
              </b>
              .
            </>
          ) : hasCard ? (
            <>
              No bank account in the card!
              <br />
              Please contact your local HoP!
            </>
          ) : (
            <>
              No registered ID card!
              <br />
              Please contact your local HoP!
            </>
          )}
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};

/** Displays products in a section, with user balance at top */
const ProductDisplay = (props: ProductDisplayProps) => {
  const { data } = useBackend<GearRequisitionData>();
  const { inventory, stockSearch, setStockSearch, selectedCategory } = props;
  const { user } = data;
  const [toggleLayout, setToggleLayout] = useState(getLayoutState(LAYOUT.Grid));

  const hasAccess = user?.access_valid || user?.observer;

  return (
    <Section
      fill
      scrollable
      title="Mining Equipment"
      buttons={
        <Stack>
          {hasAccess && (
            <Stack.Item fontSize="16px" color="green">
              {user?.points || 0} points
              <Icon name="coins" color="gold" />
            </Stack.Item>
          )}
          <Stack.Item>
            <Input
              onInput={(_, value: string) => setStockSearch(value)}
              placeholder="Search equipment..."
              value={stockSearch}
            />
          </Stack.Item>
          <LayoutToggle state={toggleLayout} setState={setToggleLayout} />
        </Stack>
      }
    >
      {inventory
        .filter((product) => {
          if (!stockSearch && product.category) {
            return product.category === selectedCategory;
          } else {
            return true;
          }
        })
        .map((product) => (
          <Product
            key={product.path}
            fluid={toggleLayout === LAYOUT.List}
            product={product}
          />
        ))}
    </Section>
  );
};

/**
 * An individual listing for a mining equipment item.
 */
const Product = (props: ProductProps) => {
  const { act, data } = useBackend<GearRequisitionData>();
  const { product, fluid } = props;
  const { user } = data;

  const hasAccess = user?.access_valid && !user?.observer;
  const canAfford = hasAccess && product.price <= (user?.points || 0);
  const disabled = !canAfford;

  const baseProps = {
    asset: product.icon
      ? undefined
      : (['vending32x32', product.path] as [string, string]),
    dmIcon: product.icon,
    dmIconState: product.icon_state,
    disabled: disabled,
    tooltipPosition: 'bottom' as const,
    product: product,
    onClick: () => {
      act('vend', {
        ref: product.ref,
      });
    },
  };

  return fluid ? (
    <ProductList {...baseProps} />
  ) : (
    <ProductGrid {...baseProps} />
  );
};

const ProductGrid = (props: any) => {
  const { product, ...baseProps } = props;

  return (
    <ImageButton
      {...baseProps}
      tooltip={capitalizeAll(product.name)}
      buttonsAlt={
        <Stack fontSize={0.8}>
          <Stack.Item grow textAlign={'left'}>
            <ProductPrice product={product} />
          </Stack.Item>
          <Stack.Item color={'lightgray'}>∞</Stack.Item>
        </Stack>
      }
    >
      {capitalizeAll(product.name)}
    </ImageButton>
  );
};

const ProductList = (props: any) => {
  const { product, ...baseProps } = props;

  return (
    <ImageButton {...baseProps} fluid imageSize={32}>
      <Stack textAlign={'right'} align="center">
        <Stack.Item grow textAlign={'left'}>
          {capitalizeAll(product.name)}
        </Stack.Item>
        <Stack.Item
          width={3.5}
          fontSize={0.8}
          color={'rgba(255, 255, 255, 0.5)'}
        >
          unlimited
        </Stack.Item>
        <Stack.Item width={3.5}>
          <ProductPrice product={product} />
        </Stack.Item>
      </Stack>
    </ImageButton>
  );
};

/** The price display for mining equipment */
const ProductPrice = (props: ProductPriceProps) => {
  const { product } = props;

  return (
    <Stack.Item fontSize={0.85} color={'gold'}>
      {product.price} points
    </Stack.Item>
  );
};

const CATEGORY_COLORS: Record<string, string> = {
  'Mining Tools': 'green',
  Equipment: 'blue',
  Consumables: 'orange',
  Shelters: 'purple',
  Upgrades: 'yellow',
  'Mining Bot': 'teal',
  Novelty: 'pink',
  'Weapons & Tools': 'red',
};

const CategorySelector = (props: CategorySelectorProps) => {
  const { categories, selectedCategory, onSelect } = props;

  return (
    <Section>
      {Object.entries(categories).map(([name, category]) => (
        <Button
          key={name}
          selected={name === selectedCategory}
          color={CATEGORY_COLORS[name]}
          icon={category.icon}
          onClick={() => onSelect(name)}
        >
          {name}
        </Button>
      ))}
    </Section>
  );
};
