import { BooleanLike } from 'common/react';

export type SecurityRecordsData = {
  character_preview_view: string;
  authenticated: BooleanLike;
  is_silicon: BooleanLike;
  amount: number;
  available_statuses: string[];
  current_user: string;
  higher_access: BooleanLike;
  records: SecurityRecord[];
  min_age: number;
  max_age: number;
};

export type SecurityRecord = {
  age: number;
  citations: Crime[];
  record_ref: string;
  crimes: Crime[];
  fingerprint: string;
  gender: string;
  name: string;
  security_note: string;
  rank: string;
  species: string;
  wanted_status: string;
};

export type Crime = {
  author: string;
  crime_ref: string;
  details: string;
  fine: number;
  name: string;
  paid: number;
  time: number;
  valid: BooleanLike;
  voider: string;
};

export enum SECURETAB {
  Crimes,
  Citations,
  Add,
}

export enum PRINTOUT {
  Missing = 'missing',
  Rapsheet = 'rapsheet',
  Wanted = 'wanted',
}
