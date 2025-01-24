import { useBackend } from '../backend';
import { Button, Section, Box, Flex, Input, BlockQuote } from '../components';
import { Window } from '../layouts';

export const XenoartifactLabeler = (props, context) => {
  return (
    <Window width={350} height={500}>
      <Window.Content scrollable={0}>
        <XenoartifactLabelerSticker />
        <Flex direction="row">
          <Flex.Item>
            <XenoartifactLabelerTraits />
          </Flex.Item>

          <Flex.Item>
            <XenoartifactLabelerInfo />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const XenoartifactLabelerTraits = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selected_activator_traits,
    activator_traits,
    selected_minor_traits,
    minor_traits,
    selected_major_traits,
    major_traits,
    malfunction_list,
    selected_malfunction_traits,
    info_list,
  } = data;

  let alphasort = function (a, b) {
    return a.localeCompare(b, 'en');
  };

  const sorted_activators = activator_traits.sort(alphasort);
  const sorted_minors = minor_traits.sort(alphasort);
  const sorted_majors = major_traits.sort(alphasort);
  const sorted_malfs = malfunction_list.sort(alphasort);

  return (
    <Box px={1} grow={1} overflowY="auto" height="425px" width="150px">
      <Section title="Material">
        <Box>
          {sorted_activators.map((trait) => (
            <XenoartifactLabelerGenerateList
              specific_trait={trait}
              check_against={selected_activator_traits}
              key={trait}
              trait_type="activator"
            />
          ))}
        </Box>
      </Section>
      <Section title="Notes">
        <Box>
          {sorted_minors.map((trait) => (
            <XenoartifactLabelerGenerateList
              specific_trait={trait}
              check_against={selected_minor_traits}
              key={trait}
              trait_type="minor"
            />
          ))}
        </Box>
      </Section>
      <Section title="Shape">
        <Box>
          {sorted_majors.map((trait) => (
            <XenoartifactLabelerGenerateList
              specific_trait={trait}
              check_against={selected_major_traits}
              key={trait}
              trait_type="major"
            />
          ))}
        </Box>
      </Section>
      <Section title="Malfunction">
        <Box>
          {sorted_malfs.map((trait) => (
            <XenoartifactLabelerGenerateList
              key={trait}
              specific_trait={trait}
              check_against={selected_malfunction_traits}
              trait_type="malfunction"
            />
          ))}
        </Box>
      </Section>
    </Box>
  );
};

const XenoartifactLabelerInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const { info_list } = data;
  return (
    <Box px={1} overflowY="auto" height="425px">
      {info_list.map((info) => (
        <XenoartifactLabelerGenerateInfo info={info} key={info} />
      ))}
    </Box>
  );
};

const XenoartifactLabelerGenerateList = (props, context) => {
  const { act } = useBackend(context);
  const { specific_trait, check_against, trait_type } = props;
  return (
    <Box>
      <Button.Checkbox
        content={specific_trait}
        checked={check_against.includes(specific_trait)}
        onClick={() => act(`assign_${trait_type}_${specific_trait}`)}
      />
    </Box>
  );
};

const XenoartifactLabelerGenerateInfo = (props, context) => {
  const { act } = useBackend(context);
  const { info } = props;
  return (
    <Section>
      <Box italic>
        <BlockQuote>{`${info}`}</BlockQuote>
      </Box>
    </Section>
  );
};

const XenoartifactLabelerSticker = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Box>
      <Input placeholder="Label Name..." onChange={(e, input) => act('change_print_name', { name: input })} />
      <Button content="Print" onClick={() => act('print_traits')} />
      <Button content="Clear" onClick={() => act('clear_traits')} />
    </Box>
  );
};
