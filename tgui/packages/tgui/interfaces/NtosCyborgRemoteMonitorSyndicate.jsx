import { NtosWindow } from '../layouts';
import { NtosCyborgRemoteMonitorContent } from './NtosCyborgRemoteMonitor';

export const NtosCyborgRemoteMonitorSyndicate = (props) => {
  return (
    <NtosWindow theme="syndicate">
      <NtosWindow.Content scrollable>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
