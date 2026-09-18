import { useRef } from 'react';

import { Icon, Input, Stack } from '../../components';

type Props = {
  /** The hint displayed in the search bar when it is empty. */
  hint?: string;
  searchText: string;
  onSearchTextChanged: (newSearchText: string) => void;
};

export const SearchBar = (props: Props) => {
  const timeout = useRef<ReturnType<typeof setTimeout>>();

  return (
    <Stack align="baseline">
      <Stack.Item>
        <Icon name="search" />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          fluid
          placeholder={props.hint ?? 'Search for...'}
          value={props.searchText}
          onInput={(_event, value: string) => {
            clearTimeout(timeout.current);
            timeout.current = setTimeout(
              () => props.onSearchTextChanged(value),
              200,
            );
          }}
        />
      </Stack.Item>
    </Stack>
  );
};
