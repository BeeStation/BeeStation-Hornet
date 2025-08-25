import {
  Component,
  createRef,
  PropsWithChildren,
  ReactNode,
  RefObject,
} from 'react';
import { CollapsibleSection } from 'tgui/components/CollapsibleSection';

import { Box, Button, Flex, Stack } from '../../components';
import { FlexProps } from '../../components/Flex';

type TabbedMenuProps = {
  categoryEntries: [string, ReactNode][];
  categoryScales: Record<string, string>;
  contentProps?: FlexProps;
};

export class TabbedMenu extends Component<TabbedMenuProps & PropsWithChildren> {
  categoryRefs: Record<string, RefObject<HTMLDivElement>> = {};
  sectionRef: RefObject<HTMLDivElement> = createRef();

  getCategoryRef(category: string): RefObject<HTMLDivElement> {
    if (!this.categoryRefs[category]) {
      this.categoryRefs[category] = createRef();
    }

    return this.categoryRefs[category];
  }

  render() {
    return (
      <Stack vertical fill>
        {this.props.children && (
          <Stack.Item position="relative">{this.props.children}</Stack.Item>
        )}
        {this.props.categoryEntries?.length > 1 && (
          <Stack.Item>
            <Stack fill px={5}>
              {this.props.categoryEntries.map(([category]) => {
                return (
                  <Stack.Item key={category} grow basis="content">
                    <Button
                      align="center"
                      fontSize="1.2em"
                      fluid
                      onClick={() => {
                        const offsetTop =
                          this.categoryRefs[category].current?.offsetTop;

                        if (offsetTop === undefined) {
                          return;
                        }

                        const currentSection = this.sectionRef.current;

                        if (!currentSection) {
                          return;
                        }

                        currentSection.scrollTop = offsetTop;
                      }}
                    >
                      {category}
                    </Button>
                  </Stack.Item>
                );
              })}
            </Stack>
          </Stack.Item>
        )}

        <Stack.Item
          grow
          innerRef={this.sectionRef}
          position="relative"
          overflowY="scroll"
          {...{
            ...this.props.contentProps,

            // Otherwise, TypeScript complains about invalid prop
            className: undefined,
          }}
        >
          <Flex direction="row" px={2} wrap="wrap">
            {this.props.categoryEntries.map(([category, children]) => {
              return (
                <Flex.Item
                  grow
                  basis={this.props.categoryScales[category] || '45%'}
                  minWidth={'500px'}
                  px={1}
                  py={2}
                  key={category}
                  innerRef={this.getCategoryRef(category)}
                >
                  <CollapsibleSection
                    minWidth="200px"
                    fill
                    title={
                      <Box inline fontSize={1.3}>
                        {category}
                      </Box>
                    }
                    sectionKey={category}
                  >
                    {children}
                  </CollapsibleSection>
                </Flex.Item>
              );
            })}
          </Flex>
        </Stack.Item>
      </Stack>
    );
  }
}
