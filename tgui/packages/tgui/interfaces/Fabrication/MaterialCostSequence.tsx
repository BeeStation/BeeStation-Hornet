import { Flex, Icon } from '../../components';
import { MaterialIcon } from './MaterialIcon';
import { Design, formatSheets, MaterialMap } from './Types';

type Props = {
  available?: MaterialMap;
  /** Reagent name -> units loaded, for colouring the reagent costs. */
  availableReagents?: MaterialMap;
  /** The materials to be consumed. Merged with the cost of `design`. */
  costMap?: MaterialMap;
  design?: Design;
  /** How many times the design will be printed. Defaults to one. */
  amount?: number;
  align?: string;
  justify?: string;
};

/**
 * A horizontal list of material costs. Costs that can only be afforded once
 * are labelled orange, costs that can't be afforded at all are labelled red.
 */
export const MaterialCostSequence = (props: Props) => {
  if (!props.costMap && !props.design) {
    return null;
  }

  const multiplier = props.amount || 1;
  const costMap: MaterialMap = { ...props.costMap };

  if (props.design) {
    for (const [name, value] of Object.entries(props.design.cost)) {
      costMap[name] = (costMap[name] || 0) + value;
    }
  }

  return (
    <Flex
      wrap
      justify={props.justify ?? 'space-around'}
      align={props.align ?? 'center'}
    >
      {Object.entries(costMap).map(([material, cost]) => {
        const quantity = cost * multiplier;
        const available = props.available?.[material];

        return (
          <Flex.Item key={material} style={{ padding: '0.25em' }}>
            <Flex direction="column" align="center">
              <Flex.Item>
                <MaterialIcon materialName={material} amount={quantity} />
              </Flex.Item>
              <Flex.Item
                style={
                  available !== undefined
                    ? {
                        color:
                          quantity * 2 <= available
                            ? '#fff'
                            : quantity <= available
                              ? '#f08f11'
                              : '#db2828',
                      }
                    : undefined
                }
              >
                {formatSheets(quantity)}
              </Flex.Item>
            </Flex>
          </Flex.Item>
        );
      })}
      {Object.entries(props.design?.reagentCost || {}).map(
        ([reagent, volume]) => (
          <Flex.Item key={reagent} style={{ padding: '0.25em' }}>
            <Flex direction="column" align="center">
              <Flex.Item>
                <Icon name="flask" size={1.5} />
              </Flex.Item>
              <Flex.Item
                style={{
                  color:
                    (props.availableReagents?.[reagent] || 0) >=
                    volume * multiplier
                      ? '#fff'
                      : '#db2828',
                }}
              >
                {volume * multiplier}u {reagent}
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ),
      )}
    </Flex>
  );
};
