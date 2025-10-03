import { NtosWindow } from '../layouts';
import { SignalerContent } from './Signaler';

export const NtosSignaller = (props) => {
  return (
    <NtosWindow width={400} height={300}>
      <NtosWindow.Content>
        <SignalerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
