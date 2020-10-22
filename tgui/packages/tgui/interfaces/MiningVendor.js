import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

export const MiningVendor = (props, context) => {
  const { act, data } = useBackend(context);
  let inventory = [
    ...data.product_records,
  ];
  return (
   <Window
  width={425}
  height={600}>
