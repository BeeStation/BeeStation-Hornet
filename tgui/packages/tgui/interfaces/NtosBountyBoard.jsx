import { BountyBoardContent } from './BountyBoard';
import { NtosWindow } from '../layouts';

export const NtosBountyBoard = (props) => {
  return (
    <NtosWindow width={550} height={600}>
      <NtosWindow.Content scrollable>
        <BountyBoardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
