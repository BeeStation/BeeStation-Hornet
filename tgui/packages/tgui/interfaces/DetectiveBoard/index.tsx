import { useBackend, useLocalState } from '../../backend';

import { Box, Button, Icon, Stack } from '../../components';
import { Window } from '../../layouts';
import { Connection, Connections, Position } from '../common/Connections';
import { BoardTabs } from './BoardTabs';
import { DataCase, DataEvidence } from './DataTypes';
import { Evidence } from './Evidence';

type Data = {
  cases: DataCase[];
  current_case: number;
};

type TypedConnection = {
  type: string;
  connection: Connection;
};

const PIN_Y_OFFSET = 15;

const PIN_CONNECTING_Y_OFFSET = -60;

export const DetectiveBoard = function (props, context) {
  const { act, data } = useBackend<Data>(context);

  const { cases, current_case } = data;

  const [connectingEvidence, setConnectingEvidence] = useLocalState<DataEvidence | null>(context, 'connectingRope', null);

  const [movingEvidenceConnections, setMovingEvidenceConnections] = useLocalState<TypedConnection[] | null>(context, 'movingRope', null);

  const [connection, setConnection] = useLocalState<Connection | null>(context, 'setRope', null);

  const [connections, setConnections] = useLocalState<Connection[]>(context,
    'setRopes',
    current_case - 1 < cases.length ? cases[current_case - 1].connections : []
  );

  const handlePinStartConnecting = function (evidence: DataEvidence, mousePos: Position) {
    setConnectingEvidence(evidence);
    setConnection({
      color: 'red',
      from: getPinPosition(evidence),
      to: { x: mousePos.x, y: mousePos.y + PIN_CONNECTING_Y_OFFSET },
    });
  };

  const getPinPositionByPosition = function (evidence: Position) {
    return { x: evidence.x + 15, y: evidence.y + PIN_Y_OFFSET };
  };

  const getPinPosition = function (evidence: DataEvidence) {
    return getPinPositionByPosition({ x: evidence.x, y: evidence.y });
  };

  const handlePinConnected = function (evidence: DataEvidence) {
    setConnection(null);
    setConnectingEvidence(null);
  };

  const handleEvidenceRemoved = function (evidence: DataEvidence) {
    let pinPosition = getPinPosition(evidence);
    let new_connections: Connection[] = [];
    for (let old_connection of connections) {
      if (
        (old_connection.to.x === pinPosition.x && old_connection.to.y === pinPosition.y) ||
        (old_connection.from.x === pinPosition.x && old_connection.from.y === pinPosition.y)
      ) {
        continue;
      }
      new_connections.push(old_connection);
    }
    setConnections(new_connections);
    if (movingEvidenceConnections) {
      let new_mov_connections: TypedConnection[] = [];
      for (let old_connection of movingEvidenceConnections) {
        if (
          (old_connection.connection.to.x === pinPosition.x && old_connection.connection.to.y === pinPosition.y) ||
          (old_connection.connection.from.x === pinPosition.x && old_connection.connection.from.y === pinPosition.y)
        ) {
          continue;
        }
        new_mov_connections.push(old_connection);
      }
      setMovingEvidenceConnections(new_mov_connections);
    }
  };

  useEffect(() => {
    if (!connectingEvidence) {
      return () => {
        window.removeEventListener('mousemove', handleMouseMove);
        window.removeEventListener('mouseup', handleMouseUp);
      };
    }

    const handleMouseMove = function (args: MouseEvent) {
      if (connectingEvidence) {
        setConnection({
          color: 'red',
          from: getPinPosition(connectingEvidence),
          to: { x: args.clientX, y: args.clientY - 60 },
        });
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [connectingEvidence]);

  useEffect(() => {
    setConnections(current_case - 1 < cases.length ? cases[current_case - 1].connections : []);
  }, [current_case]);

  const handleMouseUp = function (args: MouseEvent) {
    if (movingEvidenceConnections && connectingEvidence) {
      let new_connections: Connection[] = [];
      for (let con of movingEvidenceConnections) {
        if (con.type === 'from') {
          new_connections.push({
            color: con.connection.color,
            from: getPinPosition(connectingEvidence),
            to: con.connection.to,
          });
        } else {
          new_connections.push({
            color: con.connection.color,
            from: con.connection.from,
            to: getPinPosition(connectingEvidence),
          });
        }
      }
      setConnections([...connections, ...new_connections]);
      setMovingEvidenceConnections(null);
    }
  };

  const handleMouseUpOnPin = function (evidence: DataEvidence, args) {
    if (
      connectingEvidence &&
      connectingEvidence.ref !== evidence.ref &&
      !connectingEvidence.connections.includes(evidence.ref) &&
      !evidence.connections.includes(connectingEvidence.ref)
    ) {
      let new_connections: Connection[] = [];
      if (movingEvidenceConnections) {
        for (let con of movingEvidenceConnections) {
          if (con.type === 'from') {
            new_connections.push({
              color: con.connection.color,
              from: getPinPosition(connectingEvidence),
              to: con.connection.to,
            });
          } else {
            new_connections.push({
              color: con.connection.color,
              from: con.connection.from,
              to: getPinPosition(connectingEvidence),
            });
          }
        }
      }
      setConnections([
        ...connections,
        ...new_connections,
        {
          color: 'red',
          from: getPinPosition(connectingEvidence),
          to: getPinPosition(evidence),
        },
      ]);
      act('add_connection', {
        from_ref: connectingEvidence.ref,
        to_ref: evidence.ref,
      });
      setConnection(null);
      setConnectingEvidence(null);
      setMovingEvidenceConnections(null);
    }
  };

  const handleEvidenceStartMoving = function (evidence: DataEvidence) {
    let moving_connections: TypedConnection[] = [];
    let pinPosition = getPinPosition(evidence);
    let new_connections: Connection[] = [];
    for (let con of connections) {
      if (con.from.x === pinPosition.x && con.from.y === pinPosition.y) {
        moving_connections.push({ type: 'from', connection: con });
      } else if (con.to.x === pinPosition.x && con.to.y === pinPosition.y) {
        moving_connections.push({ type: 'to', connection: con });
      } else {
        new_connections.push(con);
      }
    }
    setMovingEvidenceConnections(moving_connections);
    setConnections(new_connections);
  };

  const handleEvidenceMoving = function (evidence: DataEvidence, position: Position) {
    if (movingEvidenceConnections) {
      let new_connections: TypedConnection[] = [];
      for (let con of movingEvidenceConnections) {
        if (con.type === 'from') {
          new_connections.push({
            type: con.type,
            connection: {
              color: con.connection.color,
              from: getPinPositionByPosition({ x: position.x, y: position.y }),
              to: con.connection.to,
            },
          });
        } else {
          new_connections.push({
            type: con.type,
            connection: {
              color: con.connection.color,
              from: con.connection.from,
              to: getPinPositionByPosition({ x: position.x, y: position.y }),
            },
          });
        }
      }
      setMovingEvidenceConnections(new_connections);
    }
  };

  const handleEvidenceStopMoving = function (evidence: DataEvidence) {
    if (movingEvidenceConnections) {
      let new_connections: Connection[] = [];
      for (let con of movingEvidenceConnections) {
        if (con.type === 'from') {
          new_connections.push({
            color: con.connection.color,
            from: getPinPosition(evidence),
            to: con.connection.to,
          });
        } else {
          new_connections.push({
            color: con.connection.color,
            from: con.connection.from,
            to: getPinPosition(evidence),
          });
        }
      }
      setConnections([...connections, ...new_connections]);
      setMovingEvidenceConnections(null);
    }
  };

  const retrieveConnections = function (typedConnections: TypedConnection[]) {
    let result: Connection[] = [];
    for (let con of typedConnections) {
      result.push(con.connection);
    }
    return result;
  };

  return (
    <Window width={1200} height={800}>
      <Window.Content>
        {cases.length > 0 ? (
          <>
            <BoardTabs />

            {cases?.map(
              (item, i) =>
                current_case - 1 === i && (
                  <Box key={cases[i].ref} className="Board__Content">
                    {movingEvidenceConnections && (
                      <Connections lineWidth={5} connections={retrieveConnections(movingEvidenceConnections)} zLayer={99} />
                    )}
                    {connection && <Connections lineWidth={5} connections={[connection]} zLayer={99} />}
                    <Connections lineWidth={5} connections={connections} zLayer={99} />
                    {item?.evidences?.map((evidence, index) => (
                      <Evidence
                        key={evidence.ref}
                        evidence={evidence}
                        case_ref={item.ref}
                        act={act}
                        onPinStartConnecting={handlePinStartConnecting}
                        onPinConnected={handlePinConnected}
                        onPinMouseUp={handleMouseUpOnPin}
                        onEvidenceRemoved={handleEvidenceRemoved}
                        onStartMoving={handleEvidenceStartMoving}
                        onMoving={handleEvidenceMoving}
                        onStopMoving={handleEvidenceStopMoving}
                      />
                    ))}
                  </Box>
                )
            )}
          </>
        ) : (
          <Stack fill>
            <Stack.Item grow>
              <Stack fill vertical>
                <Stack.Item grow />
                <Stack.Item align="center" grow={2}>
                  <Icon color="average" name="search" size={15} />
                </Stack.Item>
                <Stack.Item align="center">
                  <Box color="red" fontSize="18px" bold mt={5}>
                    You have no cases! Create the first one
                  </Box>
                </Stack.Item>
                <Stack.Item align="center" grow={3}>
                  <Button icon="plus" content="Create case" onClick={() => act('add_case')} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
