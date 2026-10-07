/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const binarySearch = <T, U = unknown>(
  getKey: (value: T) => U,
  collection: readonly T[],
  inserting: T,
): number => {
  if (collection.length === 0) {
    return 0;
  }

  const insertingKey = getKey(inserting);

  let [low, high] = [0, collection.length];

  // Because we have checked if the collection is empty, it's impossible
  // for this to be used before assignment.
  let compare: U = undefined as unknown as U;
  let middle = 0;

  while (low < high) {
    middle = (low + high) >> 1;

    compare = getKey(collection[middle]);

    if (compare < insertingKey) {
      low = middle + 1;
    } else if (compare === insertingKey) {
      return middle;
    } else {
      high = middle;
    }
  }

  return compare > insertingKey ? middle : middle + 1;
};

export const binaryInsertWith = <T, U = unknown>(
  collection: readonly T[],
  value: T,
  getKey: (value: T) => U,
): T[] => {
  const copy = [...collection];
  copy.splice(binarySearch(getKey, collection, value), 0, value);
  return copy;
};

// Needed by Fabricator.tsx
const COMPARATOR = (objA, objB) => {
  const criteriaA = objA.criteria;
  const criteriaB = objB.criteria;
  const length = criteriaA.length;
  for (let i = 0; i < length; i++) {
    const a = criteriaA[i];
    const b = criteriaB[i];
    if (a < b) {
      return -1;
    }
    if (a > b) {
      return 1;
    }
  }
  return 0;
};

/**
 * Creates an array of elements, sorted in ascending order by the results
 * of running each element in a collection thru each iteratee.
 *
 * Iteratees are called with one argument (value).
 */
export const sortBy =
  <T>(...iterateeFns: ((input: T) => unknown)[]) =>
  (array: T[]): T[] => {
    if (!Array.isArray(array)) {
      return array;
    }
    let length = array.length;
    // Iterate over the array to collect criteria to sort it by
    let mappedArray: {
      criteria: unknown[];
      value: T;
    }[] = [];
    for (let i = 0; i < length; i++) {
      const value = array[i];
      mappedArray.push({
        criteria: iterateeFns.map((fn) => fn(value)),
        value,
      });
    }
    // Sort criteria using the base comparator
    mappedArray.sort(COMPARATOR);

    // Unwrap values
    const values: T[] = [];
    while (length--) {
      values[length] = mappedArray[length].value;
    }
    return values;
  };
