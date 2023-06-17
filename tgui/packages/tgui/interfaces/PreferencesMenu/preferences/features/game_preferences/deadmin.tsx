import { BooleanLike } from 'common/react';
import { Button } from '../../../../../components';
import { Feature, FeatureValueProps } from '../base';

type FeatureToggleDeadminServerData = {
  forced: BooleanLike;
};

type FeatureToggleDeadmin = Feature<BooleanLike, boolean, FeatureToggleDeadminServerData>;

const DeadminCheckboxInput = (props: FeatureValueProps<BooleanLike, boolean, FeatureToggleDeadminServerData>) => {
  const forced = props.serverData?.forced;
  return (
    <Button
      color="transparent"
      style={forced ? { 'background-color': '#cc0000' } : null}
      tooltip={forced ? 'Forced by server config' : null}
      tooltipPosition="right"
      icon={forced ? 'minus-square-o' : props.value ? 'check-square-o' : 'square-o'}
      selected={!!forced || !!props.value}
      onClick={() => {
        if (!forced) {
          props.handleSetValue(!props.value);
        }
      }}
    />
  );
};

export const deadmin_always: FeatureToggleDeadmin = {
  name: 'Always Deadmin',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round.',
  component: DeadminCheckboxInput,
};

export const deadmin_antagonist: FeatureToggleDeadmin = {
  name: 'Deadmin As Antagonist',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as an antagonist.',
  component: DeadminCheckboxInput,
};

export const deadmin_position_head: FeatureToggleDeadmin = {
  name: 'Deadmin As Head of Staff',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as a head of staff.',
  component: DeadminCheckboxInput,
};

export const deadmin_position_security: FeatureToggleDeadmin = {
  name: 'Deadmin As Security',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as security.',
  component: DeadminCheckboxInput,
};

export const deadmin_position_silicon: FeatureToggleDeadmin = {
  name: 'Deadmin As Silicon',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as a silicon.',
  component: DeadminCheckboxInput,
};
