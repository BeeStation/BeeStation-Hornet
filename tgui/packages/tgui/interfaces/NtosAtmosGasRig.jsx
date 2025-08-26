import { Box } from '../components';
import { NtosWindow } from '../layouts';
import { AtmosGasRigTemplate } from './AtmosGasRig';

export const NtosAtmosGasRig = (props) => {
  return (
    <NtosWindow width={480} height={450}>
      <Box mt="25px">{AtmosGasRigTemplate(props)}</Box>
    </NtosWindow>
  );
};
