import { BooleanLike } from 'common/react';

/** Units of material in one sheet, came from MINERAL_MATERIAL_AMOUNT. */
export const SHEET_MATERIAL_AMOUNT = 2000;

/** Renders a raw material amount as the number of sheets it is worth. */
export const formatSheets = (amount: number) =>
  (amount / SHEET_MATERIAL_AMOUNT).toLocaleString(undefined, {
    maximumFractionDigits: 2,
  });

export type MaterialMap = Record<string, number>;

/** A reagent loaded into a machine, poured in. */
export type Reagent = {
  name: string;
  volume: number;
  id: string;
};

export type Material = {
  name: string;
  ref: string;
  amount: number;
  sheets: number;
  removable: BooleanLike;
  color: string;
};

export type Design = {
  name: string;
  desc: string;
  cost: MaterialMap;
  /** Reagent name -> units. Empty for designs that need none. */
  reagentCost: MaterialMap;
  id: string;
  categories: string[];
  icon: string;
  constructionTime: number;
};

export type FabricatorData = {
  materials: Material[];
  reagents: Reagent[];
  reagentCapacity: number;
  fabName: string;
  onHold: BooleanLike;
  designs: Record<string, Design>;
  busy: BooleanLike;
};
