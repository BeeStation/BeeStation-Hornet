import { AtmosGasRig, AtmosGasRigTemplate } from './AtmosGasRig';
import { Box } from '../components';
import { NtosWindow } from '../layouts';

export const NtosAtmosGasRig = (props) => {
  return (
    <NtosWindow width={500} height={425}>
      <Box mt="25px">{AtmosGasRigTemplate(props)}</Box>
    </NtosWindow>
  );
};
