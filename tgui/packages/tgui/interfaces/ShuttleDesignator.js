import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, Slider, ProgressBar, Fragment, ScrollableBox, OrbitalMapComponent } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const ShuttleDesignator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    shuttleId = null,
    inFlight = false,
  } = data;

  return (
    <Window
      width={500}
      height={700}>
      <Window.Content />
      <Section title="Shuttle Designation" >
        {
          (inFlight ? (
            <NoticeBox color="Red">
              Shuttle in flight, designation unavailable.
            </NoticeBox>
          ) : (
            <>
              {!!shuttleId || (
                <NoticeBox color="yellow">
                  No linked shuttle.
                </NoticeBox>
              )}
              <Button
                content="Designate Area"
                textAlign="center"
                onClick={() => act('designate')} />
            </>
          ))
        }
      </Section>
    </Window>
  );
};
