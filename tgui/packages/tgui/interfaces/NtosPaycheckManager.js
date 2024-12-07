import { useBackend, useLocalState } from '../backend';
import { NtosWindow } from '../layouts';
import { Button, Section, Table, NoticeBox, Box, Flex, Tabs } from '../components';

export const NtosPaycheckManager = (props, context) => {
  return (
    <NtosWindow width={400} height={620}>
      <NtosWindow.Content scrollable>
        <NtosPaycheckManagerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosPaycheckManagerContent = (props, context) => {
  const { act, data } = useBackend(context);

  const { authenticated, have_id_slot, target_id, target_id_owner } = data;

  if (!have_id_slot) {
    return <NoticeBox>This device does not have a secondary ID slot.</NoticeBox>;
  }

  return (
    <NtosWindow>
      <NtosWindow.Content>
        {target_id ? (
          <Button fluid icon="eject" content={target_id_owner} onClick={() => act('eject_target_id')} />
        ) : (
          <Button fluid icon="eject" content={'------'} onClick={() => act('eject_target_id')} />
        )}
        {!authenticated ? (
          <NoticeBox>Authorized access only, please insert an appropriate identification card.</NoticeBox>
        ) : target_id ? (
          <NtosPaycheckManagerPay />
        ) : null}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosPaycheckManagerPay = (props, context) => {
  const { act, data } = useBackend(context);

  const { authenticated, have_id_slot, target_id, target_id_owner, departments } = data;

  const [selectedBudgetCard, setSelectedBudgetCard] = useLocalState(context, 'budget_card', Object.keys(departments)[0]);

  const department = departments[selectedBudgetCard] || [];
  return (
    <Flex>
      <Flex.Item>
        <Section fill title="Department Budget">
          <Tabs vertical>
            {departments.map((department) => (
              <Tabs.Tab
                key={department}
                selected={department === selectedBudgetCard}
                onClick={() => setSelectedBudgetCard(department)}>
                {department}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Flex.Item>
      FIX THIS SHIT ALIGN IT TO THE RIGHT
      <Flex.Item align="right">
        <Section fill textAlign="right">
          <Tabs vertical>
            <Section />
          </Tabs>
        </Section>
      </Flex.Item>
    </Flex>
  );
};
