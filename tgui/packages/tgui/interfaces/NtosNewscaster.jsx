import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Newscaster } from './Newscaster';

export const NtosNewscaster = (_) => {
  const { data } = useBackend();
  const { PC_device_theme, PC_classic_color } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Newscaster
          override_bg={
            PC_classic_color && PC_device_theme === 'thinktronic-classic'
              ? PC_classic_color
              : null
          }
        />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
