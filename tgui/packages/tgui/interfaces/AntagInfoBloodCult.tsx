import { useBackend, useLocalState } from '../backend';
import { Box, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { resolveAsset } from '../assets';

type Info = {
  objectives: Objective[];
};

const IntroSection = (_props, _context) => {
  return (
    <Stack>
      <Stack.Item>
        <Box
          inline
          as="img"
          src={resolveAsset('bloodcult.png')}
          width="64px"
          style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
        />
      </Stack.Item>
      <Stack.Item grow>
        <h1 style={{ 'position': 'relative', 'top': '25%', 'left': '20%' }}>
          You are the{' '}
          <Box inline textColor="red">
            Blood Cultist
          </Box>
          !
        </h1>
      </Stack.Item>
    </Stack>
  );
};

const StructureAltar = (_props, _context) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-altar.gif')}
        width="48px"
        style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
      />
      The{' '}
      <Box inline textColor="red">
        altar
      </Box>{' '}
      is a bloodstained alter dedicated to{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      , capable of producing 3 different items:
      <br />
      <Box inline textColor="red">
        <b>Eldritch Whetstone</b>
      </Box>
      : A bloody whetstone, used for sharpening your blades.
      <br />
      <Box inline textColor="red">
        <b>Construct Shell</b>
      </Box>
      : An empty shell, which can turn into a construct whenever a soul stone is placed within.
      <br />
      <Box inline textColor="red">
        <b>Flask of Unholy Water</b>
      </Box>
      : A dark flask containing unholy water, which will heal believers, and burn the veins of heretics.
    </Box>
  );
};

const StructureArchives = (_props, _context) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-archives.gif')}
        width="48px"
        style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
      />
      The{' '}
      <Box inline textColor="red">
        archives
      </Box>{' '}
      are a desk covered in the ancient manuscripts of the great{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      , capable of producing 3 different items:
      <br />
      <Box inline textColor="red">
        <b>Zealot&apos;s Blindfold</b>
      </Box>
      : A blindfold which will, when worn by a believer, paradoxically allow them to see in the dark.
      <br />
      <Box inline textColor="red">
        <b>Shuttle Curse</b>
      </Box>
      : A mysterious orb, that will delay the emergency shuttle whenever it is smashed. <i>This can only be used once.</i>
      <br />
      <Box inline textColor="red">
        <b>Veil Walker Set</b>
      </Box>
      : A set of two items - the <b>veil shifter</b>, which will allow you to teleport quite a distance ahead up to 4 times, and
      the <b>void torch</b>, which can instantly transport items to fellow believers.
    </Box>
  );
};

const StructureForge = (_props, _context) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-forge.gif')}
        width="48px"
        style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
      />
      The{' '}
      <Box inline textColor="red">
        forge
      </Box>{' '}
      is used to craft the unholy weapons for the armies of the great{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      , capable of producing 3 different items:
      <br />
      <Box inline textColor="red">
        <b>Shielded Robe</b>
      </Box>
      : Empowered robes, which will fully block a limited number of incoming attacks for the user.
      <br />
      <Box inline textColor="red">
        <b>Flagellant&apos;s Robe</b>
      </Box>
      : Robes blessed with bloody speed, which increase your vulnerability to damage in exchange for allowing to you move at
      inhuman speeds.
      <br />
      <Box inline textColor="red">
        <b>Mirror Shield</b>
      </Box>
      : An unholy shield capable of summoning illusions to defend you, and it can be thrown to knock people down.
    </Box>
  );
};

const StructurePylon = (_props, _context) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-pylon.gif')}
        width="48px"
        style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
      />
      The{' '}
      <Box inline textColor="red">
        pylon
      </Box>{' '}
      is a floating crystal blessed by{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      , which will slowly convert nearly floors into runed floor tiles, and heals nearby cultists.
      <br />
      Runed flooring is resistant to, albeit not immune to, atmospheric changes, and allows runes to be drawn faster on top of
      it.
    </Box>
  );
};

const StructureSection = (_props, context) => {
  const [tab, setTab] = useLocalState(context, 'structureTab', 1);
  return (
    <Section title="Structures">
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          Altar
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          Archives
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
          Forge
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
          Pylon
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && <StructureAltar />}
      {tab === 2 && <StructureArchives />}
      {tab === 3 && <StructureForge />}
      {tab === 4 && <StructurePylon />}
      <br />
      <i>All cult structures can be unanchored and reanchored by hitting them with your ritual dagger.</i>
    </Section>
  );
};

const PowersSection = (_props, _context) => {
  return (
    <Section title="Powers">
      <Stack>
        <Stack.Item>
          <Box
            inline
            as="img"
            src={resolveAsset('dagger.png')}
            width="32px"
            style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
          />
          Your{' '}
          <Box inline textColor="red">
            ritual dagger
          </Box>{' '}
          is an essential tool for your worship of Nar&apos;Sie!
          <br />
          It allows you to quickly draw{' '}
          <Box inline textColor="red">
            blood runes
          </Box>{' '}
          on the floor, which have a variety of abilities!
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Box
            inline
            as="img"
            src={resolveAsset('cult-comms.png')}
            width="32px"
            style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
          />
          Use{' '}
          <Box inline textColor="red">
            Communion
          </Box>{' '}
          to communicate with your fellow cultists. Messages communicated this way can be heard by all cultists.
          <br />
          Be warned though, those standing close to you will also hear you!
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BloodMagicSection = (_props, context) => {
  const [tab, setTab] = useLocalState(context, 'magicTab', 1);
  return (
    <Section name="Blood Magic">
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          Blood Magic
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          Stun
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
          Teleport
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
          Electromagnetic Pulse
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
          Shadow Shackles
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 6} onClick={() => setTab(6)}>
          Twisted Construction
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 7} onClick={() => setTab(7)}>
          Summon Combat Equipment
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 8} onClick={() => setTab(8)}>
          Summon Ritual Dagger
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 9} onClick={() => setTab(9)}>
          Hallucinations
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 10} onClick={() => setTab(10)}>
          Conceal Presence
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 11} onClick={() => setTab(11)}>
          Blood Rites
        </Tabs.Tab>
        {tab === 1 && (
          <Box>
            <Box
              inline
              as="img"
              src={resolveAsset('cult-carve.png')}
              width="32px"
              style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
            />
            <Box inline textColor="red">
              Prepare Blood Magic
            </Box>{' '}
            allows you to carve runes into yourself in order to cast blood magic. These are undetectable until they are used,
            and can help in various situations.
            <br />
            This only allows a maximum of 1 piece of magic to be carved into you, however, with an <b>Empower</b> rune, you can
            carve up to 4 pieces of blood magic into you!
            <br />
            <b>Note</b>: Most blood magic is completely ineffective on holy people (the chaplain) or someone with antimagic (i.e
            someone holding an holymelon).
          </Box>
        )}
        {tab === 2 && (
          <Box>
            <h2>
              <Box inline textColor="#FF0000">
                <i>Fuu ma&apos;jin!</i>
              </Box>
            </h2>
            <br />
            <b>Name</b>: Stun
            <br />
            <b>Charges</b>: 1
            <br />
            <b>Effect</b>: When used on someone at melee range, flood their mind with the forbidden whispers of Nar&apos;sie,
            causing them to collapse to the floor as a gibbering mess. People with mindshields are <b>completely immune</b> to
            this magic! Pairs well with Shadow Shackles.
          </Box>
        )}
        {tab === 3 && (
          <Box>
            <h2>
              <Box inline textColor="#551A8B">
                <i>Sas&apos;so c&apos;arta forbici!</i>
              </Box>
            </h2>
            <br />
            <b>Name</b>: Teleport
            <br />
            <b>Charges</b>: 1
            <br />
            <b>Effect</b>: Instantly teleports yourself, someone, or something to a scribed teleport rune.
          </Box>
        )}
        {tab === 4 && (
          <Box>
            <h2>
              <Box inline textColor="#551A8B">
                <i>Ta&apos;gh fara&apos;qha fel d&apos;amar det!!</i>
              </Box>
            </h2>
            <br />
            <b>Name</b>: Teleport
            <br />
            <b>Charges</b>: 1
            <br />
            <b>Effect</b>: Instantly teleports yourself, someone, or something to a scribed teleport rune.
          </Box>
        )}
        {tab === 5 && (
          <Box>
            <h2>
              <Box inline textColor="#2a2a2a">
                <i>In&apos;otum Lig&apos;abis!</i>
              </Box>
            </h2>
            <br />
            <b>Name</b>: Shadow Shackles
            <br />
            <b>Charges</b>: 4
            <br />
            <b>Effect</b>: Cuffs someone with unholy shadow shackles when used on someone at melee range. Pairs well with Stun.
          </Box>
        )}
      </Tabs>
    </Section>
  );
};

export const AntagInfoBloodCult = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Window width={620} height={650} theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item>
            <PowersSection />
          </Stack.Item>
          <Stack.Item>
            <BloodMagicSection />
          </Stack.Item>
          <Stack.Item>
            <StructureSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
