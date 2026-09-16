import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import { ReactNode } from 'react';

import { useSharedState } from '../../backend';
import { Dimmer, Icon, Section, Stack } from '../../components';
import { SearchBar } from './SearchBar';
import { Design, MaterialMap } from './Types';

/** A category that, when selected, renders every design to the output. */
const ALL_CATEGORY = 'All Designs';

/** A category that collects all designs without a category of their own. */
const UNCATEGORIZED = '/Uncategorized';

/** Categories in this set never appear in the browser. */
const BLACKLISTED_CATEGORIES: Record<string, boolean> = {
  initial: true,
  core: true,
  hacked: true,
  emagged: true,
};

export type Category<T extends Design = Design> = {
  title: string;
  /** The`id of the Section this category renders into, for tab anchors. */
  anchorKey: string;
  /** Every design in this category and its descendants, keyed by design id. */
  descendants: Record<string, T>;
  /** Designs belonging to this exact category. */
  children: T[];
  subcategories: Record<string, Category<T>>;
};

type Props<T extends Design> = {
  designs: T[];
  availableMaterials?: MaterialMap;
  busy?: boolean;
  categoryButtons?: (category: Category<T>) => ReactNode;
  buildRecipeElement: (design: T, availableMaterials: MaterialMap) => ReactNode;
};

const makeCategory = <T extends Design>(
  title: string,
  anchorKey: string,
): Category<T> => ({
  title,
  anchorKey,
  descendants: {},
  children: [],
  subcategories: {},
});

export const DesignBrowser = <T extends Design = Design>(props: Props<T>) => {
  const [selectedCategory, setSelectedCategory] = useSharedState(
    'selected_category',
    ALL_CATEGORY,
  );
  const [searchText, setSearchText] = useSharedState('search_text', '');

  const onCategorySelected = (newCategory: string) => {
    if (newCategory === selectedCategory) {
      return;
    }
    setSelectedCategory(newCategory);
    setSearchText('');
  };

  const root = makeCategory<T>(ALL_CATEGORY, ALL_CATEGORY);

  for (const design of props.designs) {
    const categories = design.categories.length
      ? design.categories
      : [UNCATEGORIZED];

    for (const category of categories) {
      if (BLACKLISTED_CATEGORIES[category]) {
        continue;
      }

      // Categories are slash-delimited and always lead with a slash, so the first group of the split is empty.
      const nodes = category.split('/').filter((node) => node.length > 0);

      let parent = root;
      let path = '';

      for (const node of nodes) {
        parent.descendants[design.id] = design;
        path += `/${node}`;
        parent.subcategories[node] ||= makeCategory<T>(node, path);
        parent = parent.subcategories[node];
      }

      parent.descendants[design.id] = design;
      parent.children.push(design);
    }
  }

  const allDesigns = sortBy((design: T) => design.name)(
    Object.values(root.descendants),
  );

  return (
    <Stack fill className="Fabricator__Browser">
      <Stack.Item width="200px">
        <Section fill title="Categories">
          <div className="FabricatorTabs Fabricator__Categories">
            <div
              className={classes([
                'FabricatorTabs__Tab',
                selectedCategory === ALL_CATEGORY &&
                  'FabricatorTabs__Tab--active',
              ])}
              onClick={() => onCategorySelected(ALL_CATEGORY)}
            >
              <div className="FabricatorTabs__Label">
                <div className="FabricatorTabs__CategoryName">
                  {ALL_CATEGORY}
                </div>
                <div className="FabricatorTabs__CategoryCount">
                  ({Object.keys(root.descendants).length})
                </div>
              </div>
            </div>
            {sortBy((category: Category<T>) => category.title)(
              Object.values(root.subcategories),
            ).map((category) => (
              <DesignBrowserTab
                key={category.title}
                category={category}
                selectedCategory={selectedCategory}
                setSelectedCategory={onCategorySelected}
              />
            ))}
          </div>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section
          fill
          title={
            searchText.length > 0
              ? `Results for "${searchText}"`
              : selectedCategory === ALL_CATEGORY
                ? ALL_CATEGORY
                : selectedCategory
          }
        >
          <Stack vertical fill>
            <Stack.Item mb={0.5}>
              <SearchBar
                searchText={searchText}
                onSearchTextChanged={setSearchText}
                hint="Search all designs..."
              />
            </Stack.Item>
            <Stack.Item grow>
              <div className="Fabricator__Designs">
                {searchText.length > 0
                  ? allDesigns
                      .filter((design) =>
                        design.name
                          .toLowerCase()
                          .includes(searchText.toLowerCase()),
                      )
                      .map((design) =>
                        props.buildRecipeElement(
                          design,
                          props.availableMaterials || {},
                        ),
                      )
                  : (selectedCategory === ALL_CATEGORY
                      ? root
                      : root.subcategories[selectedCategory]) && (
                      <CategoryView
                        category={
                          selectedCategory === ALL_CATEGORY
                            ? root
                            : root.subcategories[selectedCategory]
                        }
                        availableMaterials={props.availableMaterials}
                        categoryButtons={props.categoryButtons}
                        buildRecipeElement={props.buildRecipeElement}
                      />
                    )}
              </div>
            </Stack.Item>
            {!!props.busy && (
              <Dimmer style={{ fontSize: '2em', textAlign: 'center' }}>
                <Icon name="cog" spin /> Building items...
              </Dimmer>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type DesignBrowserTabProps<T extends Design> = {
  category: Category<T>;
  depth?: number;
  maxDepth?: number;
  selectedCategory: string;
  setSelectedCategory: (newCategory: string) => void;
};

const DesignBrowserTab = <T extends Design>(
  props: DesignBrowserTabProps<T>,
) => {
  const { category, selectedCategory, setSelectedCategory } = props;
  const depth = props.depth ?? 0;
  const maxDepth = props.maxDepth ?? 3;
  const topLevel = depth === 0;

  return (
    <div
      className={classes([
        'FabricatorTabs__Tab',
        topLevel &&
          selectedCategory === category.title &&
          'FabricatorTabs__Tab--active',
      ])}
      onClick={() =>
        topLevel
          ? setSelectedCategory(category.title)
          : document.getElementById(category.anchorKey)?.scrollIntoView(true)
      }
    >
      <div className="FabricatorTabs__Label">
        <div className="FabricatorTabs__CategoryName">{category.title}</div>
        {topLevel && (
          <div className="FabricatorTabs__CategoryCount">
            ({Object.keys(category.descendants).length})
          </div>
        )}
      </div>
      {depth < maxDepth &&
        Object.keys(category.subcategories).length > 0 &&
        selectedCategory === category.title && (
          <div className="FabricatorTabs">
            {sortBy((subcategory: Category<T>) => subcategory.title)(
              Object.values(category.subcategories),
            ).map((subcategory) => (
              <DesignBrowserTab
                key={subcategory.title}
                category={subcategory}
                depth={depth + 1}
                maxDepth={maxDepth}
                selectedCategory={selectedCategory}
                setSelectedCategory={setSelectedCategory}
              />
            ))}
          </div>
        )}
    </div>
  );
};

type CategoryViewProps<T extends Design> = {
  category: Category<T>;
  availableMaterials?: MaterialMap;
  depth?: number;
  categoryButtons?: (category: Category<T>) => ReactNode;
  buildRecipeElement: (design: T, availableMaterials: MaterialMap) => ReactNode;
};

const CategoryView = <T extends Design>(props: CategoryViewProps<T>) => {
  const { category, availableMaterials, buildRecipeElement, categoryButtons } =
    props;
  const depth = props.depth ?? 0;

  const body = (
    <>
      {sortBy((design: T) => design.name)(category.children).map((design) =>
        buildRecipeElement(design, availableMaterials || {}),
      )}
      {sortBy((subcategory: Category<T>) => subcategory.title)(
        Object.values(category.subcategories),
      ).map((subcategory) => (
        <CategoryView
          {...props}
          key={subcategory.anchorKey}
          category={subcategory}
          depth={depth + 1}
        />
      ))}
    </>
  );

  if (depth === 0 || category.children.length === 0) {
    return body;
  }

  return (
    // independent opts out of the nested-Section rules, which outdent a section past its container by half an em on each side.
    <Section
      independent
      title={category.title}
      id={category.anchorKey}
      buttons={
        category.children.length ? categoryButtons?.(category) : undefined
      }
    >
      {body}
    </Section>
  );
};
