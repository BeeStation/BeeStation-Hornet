import { Section } from '../components';
import { NtosWindow } from '../layouts';
import { AtmosGasRigTemplate } from './AtmosGasRig';
export const NtosAtmosGasRig = (props) => {
  return (
    <NtosWindow width={480} height={530}>
      <NtosWindow.Content scrollable>
        <Section title="Advanced Gas Rig:">
          <AtmosGasRigTemplate props />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
