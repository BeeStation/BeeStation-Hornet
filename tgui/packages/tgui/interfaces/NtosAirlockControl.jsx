import { useBackend } from '../backend';
import { Button, Icon, LabeledList, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosAirlockControl = (_) => {
  const { act, data } = useBackend();
  const { airlocks = [] } = data;
  return (
    <NtosWindow width={400} height={500}>
      <NtosWindow.Content>
        <Section fill scrollable title="Airlocks">
          <LabeledList>
            {airlocks.map((airlock) => (
              <LabeledList.Item
                label={
                  <>
                    <Icon name={airlock.open ? 'lock-open' : 'lock'} />{' '}
                    {` ${airlock.name} (${airlock.locx}, ${airlock.locy})`}
                  </>
                }
                key={airlock.id}
                buttons={
                  <Button
                    content="Cycle"
                    color={airlock.open ? 'red' : 'green'}
                    onClick={() => act('airlock_control', { id: airlock.id })}
                  />
                }
              />
            ))}
          </LabeledList>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
