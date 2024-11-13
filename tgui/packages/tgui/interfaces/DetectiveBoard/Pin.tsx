import { useBackend, useLocalState } from '../../backend';

import { Box, Stack } from '../../components';
import { DataEvidence } from './DataTypes';

type PinProps = {
  evidence: DataEvidence;
  onStartConnecting: Function;
  onConnected: Function;
  onMouseUp: Function;
};

export const Pin = function (props, context: PinProps) {
  const { evidence, onStartConnecting, onConnected, onMouseUp } = props;
  const [creatingRope, setCreatingRope] = useLocalState(context, 'creatingRope', false);

  const handleMouseDown = function (args) {
    setCreatingRope(true);
    onStartConnecting(evidence, {
      x: args.clientX,
      y: args.clientY,
    });
  };

  useEffect(() => {
    if (!creatingRope) {
      return;
    }
    const handleMouseUp = (args: MouseEvent) => {
      if (creatingRope) {
        setCreatingRope(false);
        onConnected(evidence, {
          evidence_ref: 'not used',
          position: {
            x: args.clientX,
            y: args.clientY,
          },
        });
      }
    };
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [creatingRope]);

  return (
    <Stack>
      <Stack.Item>
        <Box
          className="Evidence__Pin"
          textAlign="center"
          onMouseDown={handleMouseDown}
          onMouseUp={(args) => onMouseUp(evidence, args)}
        />
      </Stack.Item>
    </Stack>
  );
};
