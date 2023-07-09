import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product, productStock, custom } = props;
  const free =
    !data.onstation ||
    product.price === 0 ||
    (!product.premium && data.department_bitflag && data.user && data.department_bitflag & data.user.department_bitflag);
  return (
    <Table.Row>
      <Table.Cell collapsing>
        {product.img ? (
          <img
            src={`data:image/jpeg;base64,${product.img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        ) : (
          <span
            className={classes(['vending32x32', product.path])}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          />
        )}
      </Table.Cell>
      <Table.Cell bold>{product.name}</Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box color={custom ? 'good' : productStock <= 0 ? 'bad' : productStock <= product.max_amount / 2 ? 'average' : 'good'}>
          {productStock} in stock
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {(custom && (
          <Button
            fluid
            content={data.access ? 'FREE' : product.price + ' cr'}
            onClick={() =>
              act('dispense', {
                'item': product.name,
              })
            }
          />
        )) || (
          <Button
            fluid
            disabled={productStock === 0 || (!free && (!data.user || product.price > data.user.cash))}
            content={free ? 'FREE' : product.price + ' cr'}
            onClick={() =>
              act('vend', {
                'ref': product.ref,
              })
            }
          />
        )}
      </Table.Cell>
    </Table.Row>
  );
};

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);
  let inventory;
  let custom = false;
  if (data.vending_machine_input) {
    inventory = data.vending_machine_input;
    custom = true;
  } else if (data.extended_inventory) {
    inventory = [...data.product_records, ...data.coin_records, ...data.hidden_records];
  } else {
    inventory = [...data.product_records, ...data.coin_records];
  }
  return (
    <Window width={400} height={550}>
      <Window.Content scrollable>
        {!!data.onstation && (
          <Section title="User">
            {(data.user && (
              <Box>
                Welcome, <b>{data.user.name}</b>, <b>{data.user.job || 'Unemployed'}</b>!
                <br />
                You have <b>{data.user.cash} credits in possession</b>.
              </Box>
            )) || (
              <Box color="light-gray">
                No registered ID card!
                <br />
                Please contact your local HoP!
              </Box>
            )}
          </Section>
        )}
        <Section title="Products">
          <Table>
            {inventory.map((product) => (
              <VendingRow key={product.name} custom={custom} product={product} productStock={data.stock[product.path]} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
