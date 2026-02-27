import { NtosWindow } from '../layouts';
import { CargoContent } from './Cargo';

export const NtosCargo = (props) => {
  return (
    <NtosWindow width={1050} height={600}>
      <NtosWindow.Content>
        <CargoContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
