import { useLocalState } from '../../backend';

export const useRandomToggleState = (context) => useLocalState('randomToggle', false);
