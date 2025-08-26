import { AtmosGasRigTemplate } from './AtmosGasRig';
import { Box } from '../components';
import { NtosWindow } from '../layouts';

export const NtosAtmosGasRig = (props) => {
  return (
    <NtosWindow width={480} height={450}>
      <Box mt="25px">{AtmosGasRigTemplate(props)}</Box>
    </NtosWindow>
  );
};
