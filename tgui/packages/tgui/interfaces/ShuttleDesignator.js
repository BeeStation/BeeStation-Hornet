import { Button, Section, Dropdown, NoticeBox, ProgressBar } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ShuttleDesignator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    shuttleId = null,
    inFlight = false,
    name = null,
    shuttle_mass = 0,
    buffered_mass = 0,
    current_capacity = 0,
    ideal_capacity = 0,
    max_size = 0,
    current_direction = null,
    preferred_direction = null,
  } = data;

  const directions = ['North', 'South', 'East', 'West'];

  return (
    <Window width={500} height={500}>
      <Window.Content />
      {shuttleId && (
        <Section title="Shuttle Information">
          Shuttle name: {name}
          <br />
          Shuttle mass: {shuttle_mass / 10} tons
          <br />
          Buffered mass: {buffered_mass / 10} tons
          <br />
          Current capacity: {current_capacity / 10} tons
          <br />
          Ideal capacity: {ideal_capacity / 10} tons
        </Section>
      )}
      <Section title="Shuttle Designation">
        {inFlight ? (
          <NoticeBox color="Red">Shuttle in flight, designation unavailable.</NoticeBox>
        ) : (
          <>
            {!!shuttleId || <NoticeBox color="yellow">No linked shuttle.</NoticeBox>}
            Buffer capacity:
            <ProgressBar
              value={buffered_mass / max_size}
              ranges={{
                good: [-Infinity, current_capacity / max_size],
                average: [current_capacity / max_size, ideal_capacity / max_size],
                bad: [ideal_capacity / max_size, Infinity],
              }}
            />
            <Button content="Designate Area" textAlign="center" onClick={() => act('designate')} />
          </>
        )}
      </Section>
      {shuttleId && !inFlight && (
        <Section title="Shuttle Configuration">
          Current Direction:
          <Dropdown
            selected={current_direction}
            options={directions}
            onSelected={(dir) => act('current_direction', { direction: dir })}
          />
          Travel Direction:
          <Dropdown
            selected={preferred_direction}
            options={directions}
            onSelected={(dir) => act('preferred_direction', { direction: dir })}
          />
        </Section>
      )}
    </Window>
  );
};
