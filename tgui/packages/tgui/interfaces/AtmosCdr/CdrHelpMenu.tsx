
import { Box, Section } from 'tgui-core/components';

export const CdrHelpMenu = () => {
  return (
    // I do not think this help menu text is great but I am not knowledgeable enough in the CDR to write a better one.
    <Box>
      <Section >
        <Box fontSize={1.1} mb={2} textAlign="center">
          This panel will guide you through how to operate the <b>Condensate Decay Reactor (CDR)</b>
        </Box>
        The CDR has four components: the core, stability, the toroid, and graviton targets.
      </Section>
      <Section title="The Core">
        <Box mb={1}>
          Gases will either deposit on the core, or diffuse off of it, to hit the set ratio of core-to-environment gases (called the metallization ratio) There, once they hit their decay threshold, will decay into other gases slowly. There is a decay chain, IE, one gases decays into another which decays into another.
        </Box>
        <Box mb={1}>As gases decay, they release flux and cool the core, with each gas releasing a different amount of flux. Generally, more stable gases generate more flux, but also contribute to stability more.</Box>
      </Section>
      <Section title="Stability">
        <Box mb={1}>
          As gases collect on the core, they will cause the Reactor to become more stable. Stability is not optimal, and high stability can lead to core collapse.
        </Box>
        <Box mb={1}>
          You can decrease stability by increasing the core temperature, or by adding BZ gas. Stability is massively increased by low temperatures, though this effect can be mitigated by incorporating N2O into the core.
        </Box>
      </Section>
      <Section title="Toroid">
        <Box mb={1}>
          The toroid is quite simple, it will increase the amount of flux produced based on a parabolic function. As gases are input they increase toroid spin (with higher specific heats generating more spin).
        </Box>
        <Box mb={1}>
          Toroid spin is represented as the horizontal value on the parabolic multiplier graph (or its X-value, to the more mathematically inclined), so you need to hit the sweet spot to get the most flux output. The upper limit is increased by core mass. Reducing the parabolic setting will reduce the required spin to reach the ideal flux value, but will also reduce the maximum flux increase from it.
        </Box>
      </Section>
      <Section title="Graviton Targets">
        The CDR releases its power output in the form of dangerous gravitons which must be captured using <b>Graviton Targets</b>, which in turn convert these gravitons into easily used electrical energy. Gravitons can be redirected using reflectors, allowing a smaller number of targets to be used to capture all released gravitons.
      </Section>
    </Box>
  );
};
