import type { BooleanLike } from 'tgui-core/react';

export type NaniteProgram = {
  name: string;
  desc: string;
  id: number;
  activated: BooleanLike;
  can_trigger: BooleanLike;
  use_rate: number;
  trigger_cost: number;
  trigger_cooldown: number;
  timer_trigger_delay: number;
  timer_trigger: number;
  timer_restart: number;
  timer_shutdown: number;
  activation_code: number;
  deactivation_code: number;
  kill_code: number;
  trigger_code: number;
  has_extra_settings: BooleanLike;
  extra_settings: ExtraSetting[];
  has_rules: BooleanLike;
  rules: ProgramRule[];
  can_rule: BooleanLike;
};

type ExtraSetting = {
  name: string;
  value: string;
};

type ProgramRule = {
  display: string;
  program_id: number;
  id: number;
};
