import { BooleanLike } from 'common/react';

export type MedicalRecordData = {
  character_preview_view: string;
  authenticated: BooleanLike;
  is_silicon: BooleanLike;
  physical_statuses: string[];
  mental_statuses: string[];
  records: MedicalRecord[];
  min_age: number;
  max_age: number;
};

export type MedicalRecord = {
  age: number;
  blood_type: string;
  record_ref: string;
  dna: string;
  gender: string;
  major_disabilities: string;
  minor_disabilities: string;
  physical_status: string;
  mental_status: string;
  name: string;
  medical_notes: MedicalNote[];
  quirk_notes: string;
  rank: string;
  species: string;
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
