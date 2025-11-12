import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  Icon,
  Section,
} from '../components';
import { Window } from '../layouts';

export const XenoartifactLabeler = (props) => {
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable={0}>
        <Section>
          <Flex>
            <Flex.Item>
              <XenoartifactlabelerSticker />
            </Flex.Item>
            <Flex.Item ml={'auto'}>
              <Button
                icon="question"
                tooltip="Left-Click to check traits, and Right-Click to exclude traits."
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Divider />
        <Section>
          <Collapsible title="Filters">
            <XenoartifactlabelerGenerateFilterEntry />
          </Collapsible>
        </Section>
        <Divider />
        <Flex direction="row">
          <Flex.Item>
            <XenoartifactlabelerTraits />
          </Flex.Item>
          <Flex.Item>
            <XenoartifactlabelerInfo />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const XenoartifactlabelerTraits = (props) => {
  const { act, data } = useBackend();
  const {
    activator_traits,
    minor_traits,
    major_traits,
    malfunction_list,
    enabled_trait_filters,
    filtered_traits,
  } = data;

  let alphasort = function (a, b) {
    return a.localeCompare(b, 'en');
  };

  const sorted_activators = activator_traits.sort(alphasort);
  const sorted_minors = minor_traits.sort(alphasort);
  const sorted_majors = major_traits.sort(alphasort);
  const sorted_malfs = malfunction_list.sort(alphasort);

  let filtered_activators = sorted_activators.filter(
    (n) => !filtered_traits.includes(n),
  );
  let filtered_minors = sorted_minors.filter(
    (n) => !filtered_traits.includes(n),
  );
  let filtered_majors = sorted_majors.filter(
    (n) => !filtered_traits.includes(n),
  );
  let filtered_malfs = sorted_malfs.filter((n) => !filtered_traits.includes(n));

  return (
    <Box px={1} overflowY="scroll" height="72vh" width="150px">
      <Section title="Activator Traits">
        <Box>
          {filtered_activators.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              specific_trait={trait}
              key={trait}
              trait_type="activator"
            />
          ))}
        </Box>
      </Section>
      <Divider />
      <Section title="Minor Traits">
        <Box>
          {filtered_minors.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              specific_trait={trait}
              key={trait}
              trait_type="minor"
            />
          ))}
        </Box>
      </Section>
      <Divider />
      <Section title="Major Traits">
        <Box>
          {filtered_majors.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              specific_trait={trait}
              key={trait}
              trait_type="major"
            />
          ))}
        </Box>
      </Section>
      <Divider />
      <Section title="Malfunction Traits">
        <Box>
          {filtered_malfs.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              key={trait}
              specific_trait={trait}
              trait_type="malfunction"
            />
          ))}
        </Box>
      </Section>
    </Box>
  );
};

const XenoartifactlabelerInfo = (props) => {
  const { act, data } = useBackend();
  const { selected_traits, labeler_traits_filter } = data;
  return (
    <Box px={1} overflowY="auto" height="72vh">
      {selected_traits.map((info) => (
        <XenoartifactlabelerGenerateInfo info={info} key={info} />
      ))}
    </Box>
  );
};

const XenoartifactlabelerGenerateEntry = (props) => {
  const { act, data } = useBackend();
  const { specific_trait, trait_type } = props;
  const { tooltip_stats, selected_traits, deselected_traits } = data;
  return (
    <Box>
      <Button.Checkbox
        content={specific_trait}
        checked={selected_traits.includes(specific_trait)}
        color={
          deselected_traits.includes(specific_trait) ? 'bad' : 'transparent'
        }
        onClick={() =>
          act(`toggle_trait`, { trait_name: specific_trait, select: true })
        }
        tooltip={`${tooltip_stats[specific_trait]['alt_name'] ? `${tooltip_stats[specific_trait]['alt_name']},` : ``}
          Weight: ${tooltip_stats[specific_trait]['weight']},
          Conductivity: ${tooltip_stats[specific_trait]['conductivity']}`}
        onContextMenu={(e) => {
          e.preventDefault();
          act(`toggle_trait`, { trait_name: specific_trait, select: false });
        }}
      />
    </Box>
  );
};

const XenoartifactlabelerGenerateInfo = (props) => {
  const { act, data } = useBackend();
  const { info } = props;
  const { tooltip_stats } = data;
  return (
    <Section title={info}>
      <Box italic>
        <BlockQuote>{`${tooltip_stats[info]['desc']}`}</BlockQuote>
        {tooltip_stats[info]['hints'].map((hint) => (
          <Button icon={hint['icon']} tooltip={hint['desc']} key={info} />
        ))}
        {tooltip_stats[info]['availability'].map((trait) => (
          <Icon name={trait['icon']} color={trait['color']} key={trait} />
        ))}
      </Box>
    </Section>
  );
};

const XenoartifactlabelerSticker = (props) => {
  const { act } = useBackend();
  return (
    <Box>
      <Button content="Print" onClick={() => act('print_traits')} />
      <Button content="Clear" onClick={() => act('clear_traits')} />
    </Box>
  );
};

const XenoartifactlabelerGenerateFilterEntry = (props) => {
  const { act, data } = useBackend();
  //  const { specific_trait, trait_type } = props;
  const { trait_filters, enabled_trait_filters } = data;
  return (
    <Box>
      {trait_filters.map((filter) => (
        <Button
          key={filter['desc']}
          tooltip={filter['desc']}
          icon={filter['icon']}
          onClick={() => act(`toggle_filter`, { filter: filter['icon'] })}
          selected={enabled_trait_filters.includes(filter['icon'])}
        />
      ))}
    </Box>
  );
};
