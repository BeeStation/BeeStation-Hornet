import { useLocalState } from '../../backend';

import { Box, Button, Flex, Stack } from '../../components';
import { DataEvidence } from './DataTypes';
import { Pin } from './Pin';

type EvidenceProps = {
  key: string;
  case_ref: string;
  evidence: DataEvidence;
  act: Function;
  onPinStartConnecting: Function;
  onPinConnected: Function;
  onPinMouseUp: Function;
  onEvidenceRemoved: Function;
  onStartMoving: Function;
  onStopMoving: Function;
  onMoving: Function;
};

type Position = {
  x: number;
  y: number;
};

export const Evidence = (props: EvidenceProps) => {
  const { evidence, case_ref, act } = props;

  const [dragging, setDragging] = useLocalState('startDraging', false);

  const [canDrag, setCanDrag] = useLocalState('canDrag', true);

  const [dragPosition, setDragPosition] = useLocalState<Position>('dragPosition', {
    x: evidence.x,
    y: evidence.y,
  });

  const [lastMousePosition, setLastMousePosition] = useLocalState<Position | null>('lastPosition', null);

  const handleMouseDown = (args: MouseEvent) => {
    if (canDrag) {
      setDragging(true);
      props.onStartMoving(evidence);
      setLastMousePosition({ x: args.screenX, y: args.screenY });
    }
  };

  const handleMouseUp = (args: MouseEvent) => {
    if (canDrag && lastMousePosition) {
      const newX = dragPosition.x - (lastMousePosition.x - args.screenX);
      const newY = dragPosition.y - (lastMousePosition.y - args.screenY);
      act('set_evidence_cords', { evidence_ref: evidence.ref, case_ref, rel_x: newX, rel_y: newY });
      props.onStopMoving({ ...evidence, x: newX, y: newY });
    }
    setDragging(false);
    setLastMousePosition(null);
  };

  const onMouseMove = (args: MouseEvent) => {
    if (canDrag && lastMousePosition) {
      const newX = dragPosition.x - (lastMousePosition.x - args.screenX);
      const newY = dragPosition.y - (lastMousePosition.y - args.screenY);
      setDragPosition({ x: newX, y: newY });
      props.onMoving(evidence, { x: newX, y: newY });
      setLastMousePosition({ x: args.screenX, y: args.screenY });
    }
  };

  if (dragging) {
    window.addEventListener('mouseup', handleMouseUp);
    window.addEventListener('mousemove', onMouseMove);
  } else {
    window.removeEventListener('mouseup', handleMouseUp);
    window.removeEventListener('mousemove', onMouseMove);
  }

  return (
    <Box position="absolute" left={`${dragPosition.x}px`} top={`${dragPosition.y}px`} onMouseDown={handleMouseDown}>
      <Stack vertical>
        <Stack.Item>
          <Box className="Evidence__Box">
            <Flex justify="space-between" mt={0.5} align="top">
              <Flex.Item align="left">
                <Pin
                  evidence={evidence}
                  onStartConnecting={(evidence, mousePos) => {
                    setCanDrag(false);
                    props.onPinStartConnecting(evidence, mousePos);
                  }}
                  onConnected={(evidence) => {
                    setCanDrag(true);
                    props.onPinConnected(evidence);
                  }}
                  onMouseUp={(evidence, args) => {
                    setCanDrag(true);
                    props.onPinMouseUp(evidence, args);
                  }}
                />
              </Flex.Item>
              <Flex.Item align="center">
                <Box className="Evidence__Box__TextBox title">
                  <b>{evidence.name}</b>
                </Box>
              </Flex.Item>
              <Flex.Item align="right">
                <Button
                  iconColor="red"
                  icon="trash"
                  color="white"
                  onClick={() => {
                    props.onEvidenceRemoved(evidence);
                    act('remove_evidence', { evidence_ref: evidence.ref });
                  }}
                  onMouseDown={() => setCanDrag(false)}
                />
              </Flex.Item>
            </Flex>
            <Box onClick={() => act('look_evidence', { case_ref, evidence_ref: evidence.ref })}>
              {evidence.type === 'photo' ? (
                <img className="Evidence__Icon" src={evidence.photo_url} />
              ) : (
                // eslint-disable-next-line react/no-danger
                <div dangerouslySetInnerHTML={{ __html: evidence.text }} />
              )}
            </Box>
            <Box className="Evidence__Box__TextBox">{evidence.description}</Box>
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
