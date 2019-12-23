import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section } from '../components';

export const TurboLift = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  let currentdeck;
  Object.values(data.decks).forEach(value => {
    if (value.z === data.current) {
      currentdeck = value.deck;
    }
  });

  return (
    <Fragment>
      <NoticeBox>{
        data.online 
          ? (currentdeck 
            ? `Currently at deck ${currentdeck}` 
            : `Unable to determine current deck.`) 
          : "This lift is currently offline. Please contact a Nanotrasen lift repair technician."
      }
      </NoticeBox>
      <Section
        title="Lift panel"
      >
        {Object.keys(data.decks).map(key => {
          let value = data.decks[key];
          return (
            <Button
              key={key}
              fluid
              color={
                (data.current === value.z) 
                  ? "blue" 
                  : (value.queued 
                    ? "good" 
                    : "normal")
              }
              content={`Deck ${value.deck}: ${value.name}`}
              bold={data.current === value.z}
              disabled={!data.online}
              onClick={() => {
                if (data.current === value.z) {
                  return;
                }

                if (value.queued) {
                  return;
                }

                act(ref, "goto", {deck: key});
              }}
            />);
        })}
      </Section>
    </Fragment>
  );
};
