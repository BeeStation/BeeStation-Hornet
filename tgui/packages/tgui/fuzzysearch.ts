import createFuzzySearch from '@nozbe/microfuzz';
import { useCallback, useState } from 'react';

interface UseFuzzySearchProps<T> {
  /** An input array to match */
  searchArray: T[];
  /**
   * The matching strategy to use. `off` - don't use fuzzy search.
   * `smart` - ignore low density matches. `agressive` - accept
   * any match avaliable. Defaults to 'smart' if not set.
   */
  matchStrategy?: 'off' | 'smart' | 'aggressive';
  /** The input string to match */
  getSearchString: (item: T) => string;
}

/**
 * ## useFuzzySearch
 *
 * A simple hook providing fuzzy searching - uses approximate rather
 * than exact pattern matching.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/hooks-usefuzzysearch--docs)
 */
export function useFuzzySearch<T>(options: UseFuzzySearchProps<T>) {
  const { getSearchString, matchStrategy = 'smart', searchArray } = options;

  const [query, setQuery] = useState('');
  const [results, setResults] = useState<T[]>([]);

  const fuzzySearch = useCallback(
    createFuzzySearch(searchArray, {
      getText: (item: T) => [getSearchString(item)],
      strategy: matchStrategy,
    }),
    [searchArray, getSearchString],
  );

  function handleSearch(value: string) {
    setQuery(value);

    if (value.trim() === '') {
      setResults([]);
      return;
    }

    const searchResults = fuzzySearch(value);
    setResults(searchResults.map((result) => result.item));
  }

  return {
    query,
    setQuery: handleSearch,
    results,
  };
}
