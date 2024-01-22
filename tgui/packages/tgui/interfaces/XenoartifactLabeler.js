import { useBackend } from '../backend';
import { Button, Section, Box, Flex, Input, BlockQuote, Icon, Divider } from '../components';
import { Window } from '../layouts';

export const XenoartifactLabeler = (props, context) => {
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable={0}>
        <XenoartifactlabelerSticker />
        <Divider/>
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

const XenoartifactlabelerTraits = (props, context) => {
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
      <Section title="Activator Traits">
        <Box>
          {sorted_activators.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              specific_trait={trait}
              check_against={selected_activator_traits}
              key={trait}
              trait_type="activator"
            />
          ))}
        </Box>
      </Section>
      <Divider/>
      <Section title="Minor Traits">
        <Box>
          {sorted_minors.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              specific_trait={trait}
              check_against={selected_minor_traits}
              key={trait}
              trait_type="minor"
            />
          ))}
        </Box>
      </Section>
      <Divider/>
      <Section title="Major Traits">
        <Box>
          {sorted_majors.map((trait) => (
            <XenoartifactlabelerGenerateEntry
              specific_trait={trait}
              check_against={selected_major_traits}
              key={trait}
              trait_type="major"
            />
          ))}
        </Box>
      </Section>
       <Divider/>
      <Section title="Malfunction Traits">
        <Box>
          {sorted_malfs.map((trait) => (
            <XenoartifactlabelerGenerateEntry
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

const XenoartifactlabelerInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const { info_list } = data;
  return (
    <Box px={1} overflowY="auto" height="425px">
      {info_list.map((info) => (
        <XenoartifactlabelerGenerateInfo info={info} key={info} />
      ))}
    </Box>
  );
};

const XenoartifactlabelerGenerateEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { specific_trait, check_against, trait_type } = props;
  const { tooltip_stats } = data;
  return (
    <Box>
      <Button.Checkbox
        content={specific_trait}
        checked={check_against.includes(specific_trait)}
        onClick={() => act(`assign_${trait_type}_${specific_trait}`)}
        tooltip={`Weight: ${tooltip_stats[specific_trait]["weight"]}, Conductivity: ${tooltip_stats[specific_trait]["conductivity"]}`}
      />
    </Box>
  );
};

const XenoartifactlabelerGenerateInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const { info } = props;
  const { tooltip_stats } = data;
  return (
    <Section title={info["name"]}>
      <Box italic>
        <BlockQuote>{`${info["desc"]}`}</BlockQuote>
        {info["hints"].map((hint) => (
          <Button icon={hint["icon"]} tooltip={hint["desc"]}/>
        ))}
        {tooltip_stats[info["name"]]["availability"].map((trait) => (
          <Icon name={trait["icon"]} color={trait["color"]}/>
        ))}
      </Box>
    </Section>
  );
};

const XenoartifactlabelerSticker = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Section>
      <Button content="Print" onClick={() => act('print_traits')} />
      <Button content="Clear" onClick={() => act('clear_traits')} />
    </Section>
  );
};
