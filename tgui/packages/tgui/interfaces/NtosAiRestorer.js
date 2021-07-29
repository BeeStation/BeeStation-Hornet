import { NtosWindow } from '../layouts';
import { AiRestorerContent } from './AiRestorer';

export const NtosAiRestorer = () => {
  return (
    <NtosWindow
      width={360}
      height={400}>
      <NtosWindow.Content scrollable>
        <AiRestorerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
