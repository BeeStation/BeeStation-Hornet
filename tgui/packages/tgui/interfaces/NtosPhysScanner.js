import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Section, Dropdown, Box } from '../components';
import { sanitizeText } from '../sanitize';

export const NtosPhysScanner = (props, context) => {
  const { act, data } = useBackend(context);
  const { set_mode, available_modes = [], last_record } = data;
  const textHtml = {
    __html: sanitizeText(last_record),
  };
  return (
    <NtosWindow width={600} height={350}>
      <NtosWindow.Content scrollable>
        <Section title="Scanner Mode">
          <Dropdown
            options={available_modes}
            selected={set_mode || 'Select Mode'}
            onSelected={(value) =>
              act('selectMode', {
                newMode: value,
              })
            }
          />
        </Section>
        {textHtml.__html.length ? (
          <Section title="Results">
            <Box style={{ 'white-space': 'pre-line' }} dangerouslySetInnerHTML={textHtml} />
          </Section>
        ) : null}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
