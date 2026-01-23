import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  objectives: Objective[];
};

const StructureAltar = (_props) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-altar.gif')}
        width="48px"
        style={{
          msInterpolationMode: 'nearest-neighbor',
          imageRendering: 'pixelated',
          float: 'left',
        }}
      />
      The{' '}
      <Box inline textColor="red">
        altar
      </Box>{' '}
      is a bloodstained altar dedicated to{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      , capable of producing 4 different items:
      <br />
      <Box inline textColor="red">
        <b>Eldritch Whetstone</b>
      </Box>
      : A bloody whetstone, used for sharpening your blades.
      <br />
      <Box inline textColor="red">
        <b>Construct Shell</b>
      </Box>
      : An empty shell, which can turn into a construct whenever a soul stone is
      placed within.
      <br />
      <Box inline textColor="red">
        <b>Flask of Unholy Water</b>
      </Box>
      : A dark flask containing unholy water, which will heal believers, and
      burn the veins of heretics.
      <br />
      <Box inline textColor="red">
        <b>Runic Golem Shell</b>
      </Box>
      : A consecrated shell capable of binding a soul stone into a runic golem
      construct.
    </Box>
  );
};

const StructureArchives = (_props) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-archives.gif')}
        width="48px"
        style={{
          msInterpolationMode: 'nearest-neighbor',
          imageRendering: 'pixelated',
          float: 'left',
        }}
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
      : A blindfold which will, when worn by a believer, paradoxically allow
      them to see in the dark.
      <br />
      <Box inline textColor="red">
        <b>Shuttle Curse</b>
      </Box>
      : A mysterious orb, that will delay the emergency shuttle whenever it is
      smashed. <i>This can only be used once.</i>
      <br />
      <Box inline textColor="red">
        <b>Veil Walker Set</b>
      </Box>
      : A set of two items - the <b>veil shifter</b>, which will allow you to
      teleport quite a distance ahead up to 4 times, and the <b>void torch</b>,
      which can instantly transport items to fellow believers.
    </Box>
  );
};

const StructureForge = (_props) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-forge.gif')}
        width="48px"
        style={{
          msInterpolationMode: 'nearest-neighbor',
          imageRendering: 'pixelated',
          float: 'left',
        }}
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
      : Empowered robes, which will fully block a limited number of incoming
      attacks for the user.
      <br />
      <Box inline textColor="red">
        <b>Flagellant&apos;s Robe</b>
      </Box>
      : Robes blessed with bloody speed, which increase your vulnerability to
      damage in exchange for allowing to you move at inhuman speeds.
      <br />
      <Box inline textColor="red">
        <b>Mirror Shield</b>
      </Box>
      : An unholy shield capable of summoning illusions to defend you, and it
      can be thrown to knock people down.
    </Box>
  );
};

const StructurePylon = (_props) => {
  return (
    <Box>
      <Box
        inline
        as="img"
        src={resolveAsset('cult-pylon.gif')}
        width="48px"
        style={{
          msInterpolationMode: 'nearest-neighbor',
          imageRendering: 'pixelated',
          float: 'left',
        }}
      />
      The{' '}
      <Box inline textColor="red">
        pylon
      </Box>{' '}
      is a floating crystal blessed by{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      , which will slowly convert nearly floors into runed floor tiles, and
      heals nearby cultists.
      <br />
      Runed flooring is resistant to, albeit not immune to, atmospheric changes,
      and allows runes to be drawn faster on top of it.
    </Box>
  );
};

const StructureSection = (_props) => {
  const [tab, setTab] = useLocalState('structureTab', 1);
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
      <i>
        All cult structures can be unanchored and reanchored by hitting them
        with your ritual dagger.
      </i>
    </Section>
  );
};

const BloodMagicSection = (_props) => {
  const [tab, setTab] = useLocalState('magicTab', 1);
  return (
    <Stack>
      <Stack.Item>
        <Tabs vertical>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Prepare Blood Magic
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
        </Tabs>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        {tab === 1 && (
          <Box>
            <Box
              inline
              as="img"
              src={resolveAsset('cult-carve.png')}
              width="32px"
              style={{
                msInterpolationMode: 'nearest-neighbor',
                imageRendering: 'pixelated',
                float: 'left',
              }}
            />
            <Box inline textColor="red">
              Prepare Blood Magic
            </Box>{' '}
            allows you to carve runes into yourself in order to cast blood
            magic. These are undetectable until they are used, and can help in
            various situations.
            <br />
            This only allows a maximum of 1 piece of magic to be carved into
            you, however, with an <b>Empower</b> rune, you can carve up to 4
            pieces of blood magic into you!
            <br />
            <b>Note</b>: Most blood magic is completely ineffective on holy
            people (the chaplain) or someone with antimagic (i.e someone holding
            an holymelon).
          </Box>
        )}
        {tab === 2 && (
          <Box>
            <h2>
              <Box inline textColor="#FF0000">
                <i>Fuu ma&apos;jin!</i>
              </Box>
            </h2>
            <b>Name</b>: Stun
            <br />
            <b>Charges</b>: 1
            <br />
            <p>
              A potent spell that will stun and mute victims upon contact.
              Simple, clean, and quite effective for a plethora of situations.
            </p>
            <p>
              Paralyzes for for 16 seconds, mutes for 12 seconds and cult-slurs
              speech for 30 seconds (from the stun moment). If used on a cyborg
              it stuns it as if hit by a heavy EMP.
            </p>
            <p>
              <b>Does not work on mindshielded personnel!</b>
            </p>
            <p>
              While slurring cult-speak, victims will speak in a disturbing,
              incomprehensible way. This is usually a dead giveaway that a Cult
              is onboard when shouted over the radio (unless the Bartender has
              been handing out way too many Nar&apos;Sours).
            </p>
          </Box>
        )}
        {tab === 3 && (
          <Box>
            <h2>
              <Box inline textColor="#551A8B">
                <i>Sas&apos;so c&apos;arta forbici!</i>
              </Box>
            </h2>
            <b>Name</b>: Teleport
            <b>Charges</b>: 1
            <p>
              Instantly teleports yourself, someone, or something to a scribed
              teleport rune.
            </p>
          </Box>
        )}
        {tab === 4 && (
          <Box>
            <h2>
              <Box inline textColor="#4D94FF">
                <i>Ta&apos;gh fara&apos;qha fel d&apos;amar det!!</i>
              </Box>
            </h2>
            <b>Name</b>: Electromagnetic Pulse
            <br />
            <b>Charges</b>: 1
            <p>
              A large spell that allows a user to channel dark energy into an
              EMP, causing all electronics in the area to malfunction or be
              disabled.
            </p>
          </Box>
        )}
        {tab === 5 && (
          <Box>
            <h2>
              <Box inline textColor="#2a2a2a">
                <i>In&apos;otum Lig&apos;abis!</i>
              </Box>
            </h2>
            <b>Name</b>: Shadow Shackles
            <br />
            <b>Charges</b>: 4
            <p>
              A stealthy spell that will summon shadowy handcuffs on a person,
              and temporarily silence your victim for 10 seconds. Used for
              keeping crew restrained until they can be converted. The
              restraints will diseappear if the victim is converted.
            </p>
          </Box>
        )}
        {tab === 6 && (
          <Box>
            <h2>
              <Box inline textColor="#2a2a2a">
                <i>Ethra p&apos;ni dedol!</i>
              </Box>
            </h2>
            <b>Name</b>: Twisted Construction
            <br />
            <b>Charges</b>: 1
            <p>
              Converts plasteel into runed metal, 50 iron into a construct
              shell, living cyborgs and AIs into constructs (after a delay),
              cyborg shells into construct shells, and airlocks into brittle
              runed airlocks (after a delay, on harm intent)
            </p>
          </Box>
        )}
        {tab === 7 && (
          <Box>
            <b>Name</b>: Summon Combat Equipment
            <b>Charges</b>: 1
            <p>
              When used on a cultist (including yourself), otherworldly armor,
              including a cult blade and bola, will appear on them.
            </p>
          </Box>
        )}
        {tab === 8 && (
          <Box>
            <h2>
              <Box inline textColor="red">
                <i>Wur d&apos;dai leev&apos;mai k&apos;sagan!!</i>
              </Box>
            </h2>
            <b>Name</b>: Summon Ritual Dagger
            <br />
            <b>Charges</b>: 1
            <p>
              Enables you to summon a ritual dagger used to draw runes, in case
              you lost yours or forgot to pick it up from the floor when you got
              converted. Activate the spell and then click yourself.
            </p>
          </Box>
        )}
        {tab === 9 && (
          <Box>
            <b>Name</b>: Hallucinations
            <br />
            <b>Charges</b>: 4
            <p>
              Silently curses someone&apos;s mind with living nightmares,
              causing them to hallucinate. Can be used at a range, and is
              completely silent.
            </p>
          </Box>
        )}
        {tab === 10 && (
          <Box>
            <h2>
              <Box inline textColor="red">
                <i>Kla&apos;atu barada nikt&apos;o!</i>
              </Box>
            </h2>
            <b>Name</b>: Conceal Presence
            <br />
            <b>Charges</b>: 10
            <p>
              A multi-function spell that alternates between hiding and
              revealing nearby runes and cult structures within a range of{' '}
              <b>5 tiles</b>. You can still teleport to concealed teleport runes
              and prepare blood magic on concealed empower runes.
            </p>
            <p>
              Will make runed airlocks look like basic maintenance airlocks, but
              only cultists will have access.
            </p>
          </Box>
        )}
        {tab === 11 && (
          <Box>
            <h2>
              <Box inline textColor="red">
                <i>Fel&apos;th Dol Ab&apos;orod!</i>
              </Box>
            </h2>
            <b>Name</b>: Blood Rites
            <br />
            <b>Charges</b>: 5
            <p>
              A complex type of blood magic, capable of healing cultists,
              summoning a spear, firing powerful bolts of blood, or manifesting
              a huge beam to convert walls and floors into those of
              Nar&apos;sie.
            </p>
            <p>
              Blood Rites is fueled by blood - use the hand on the floor (or
              living victims) in order to absorb blood off the floor to fuel the
              rites.
            </p>
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
};

const RunesSection = (_props) => {
  const [tab, setTab] = useLocalState('runeTab', 1);
  return (
    <Stack>
      <Stack.Item>
        <Tabs vertical>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Offer
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Empower
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Teleport
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
            Revive
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
            Barrier
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 6} onClick={() => setTab(6)}>
            Summon Cultist
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 7} onClick={() => setTab(7)}>
            Boil Blood
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 8} onClick={() => setTab(8)}>
            Spirit Realm
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 9} onClick={() => setTab(9)}>
            Apocalypse
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 10} onClick={() => setTab(10)}>
            Nar&apos;Sie
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        {tab === 1 && (
          <Box>
            <h2>
              <Box inline textColor="#FFFFFF">
                <i>Mah&apos;weyh pleggh at e&apos;ntrath!</i>
              </Box>
            </h2>
            <b>Name</b>: Offer
            <br />
            <b>Cultists Required</b>: 1 (sacrificing dead non-target), 2
            (conversion), 3 (sacrificing target or non-dead person)
            <p>
              Instantly converts a normal crewmember on top of it to the cult,
              healing them for 75% of their brute and burn damage, and spawning
              a ritual dagger.
            </p>
            <p>
              Mindshield-implanted crew cannot be converted, only sacrificed,
              (but constructs are no less dangerous than humans) -{' '}
              <b>
                therefore it is recommended that you quickly finish off security
                victims before their radio or suit sensors can give you away!
              </b>
            </p>
            <p>
              Sacrifice victims will be gibbed and have their soul placed into a
              Soul Stone, which can then be placed into a construct shell or a
              golem shell.
            </p>
          </Box>
        )}
        {tab === 2 && (
          <Box>
            <h2>
              <Box inline textColor="#0000FF">
                <i>H&apos;drak v&apos;loso, mir&apos;kanas verbot!</i>
              </Box>
            </h2>
            <b>Name</b>: Empower
            <br />
            <b>Cultists Required</b>: 1
            <p>
              Allows cultists to prepare greater amounts of blood magic at far
              less of a cost. While standing on an empowering rune, the spell
              count is capped at 4 instead of 1.
            </p>
            <p>
              Additionally, preparing blood magic takes far less time, and you
              don&apos;t lose as much blood while doing it.
            </p>
          </Box>
        )}
        {tab === 3 && (
          <Box>
            <h2>
              <Box inline textColor="#551A8B">
                <i>Sas&apos;so c&apos;arta forbici!</i>
              </Box>
            </h2>
            <b>Name</b>: Teleport
            <br />
            <b>Cultists Required</b>: 1
            <p>
              This rune warps everything above it to another teleport rune when
              used. Creating a teleport rune will allow you to set a tag for it.
            </p>
            <p>
              <b>Warning:</b>{' '}
              <i>
                Teleporting from Lavaland or Space will make the destination
                rune glow brightly and open a rift in reality that may not only
                reveal the rune, but the location of your main base as well,
                choose your rune locations wisely!
              </i>
            </p>
          </Box>
        )}
        {tab === 4 && (
          <Box>
            <h2>
              <Box inline textColor="#C80000">
                <i>
                  Pasnar val&apos;keriam usinar. Savrae ines amutan.
                  Yam&apos;toth remium il&apos;tarat!
                </i>
              </Box>
            </h2>
            <b>Name</b>: Revive
            <br />
            <b>Cultists Required</b>: 1
            <p>
              Whenever someone is sacrificed on a Convert rune, they add one
              (global) charge to this rune. Placing a cultist corpse on the rune
              and activating it will bring them back to life, expending a hefty
              three charges in the process. It starts with one freebie revival,
              so use it sparingly.
            </p>
            <p>
              Catatonic(disconnected/ghosted) cultists can be reawakened with a
              new soul by putting them on the Revive rune and activating it.
              This method of revival does not consume any charges.
            </p>
          </Box>
        )}
        {tab === 5 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>Khari&apos;d! Eske&apos;te tannin!</i>
              </Box>
            </h2>
            <b>Name</b>: Barrier
            <br />
            <b>Cultists Required</b>: 1
            <p>
              When invoked, makes a 5-minute invisible wall to block passage.
              Can be invoked again to reverse this.
            </p>
            <p>
              Invoking one barrier rune will chain activate other barrier runes
              that are within 2 tiles from one another. Reversing a barrier rune
              will not chain deactivate other barrier runes.
            </p>
            <p>
              Costs 2 brute both to invoke and to deactivate (regardless how
              many are chained). Active barrier runes have a subtle wriggling
              animation, and are usually brighter.
            </p>
          </Box>
        )}
        {tab === 6 && (
          <Box>
            <h2>
              <Box inline textColor="#00FF00">
                <i>N&apos;ath reth sh&apos;yro eth d&apos;rekkathnor!</i>
              </Box>
            </h2>
            <b>Name</b>: Summon Cultist
            <br />
            <b>Cultists Required</b>: 2
            <p>
              This rune allows you to instantly summon any living cultist to the
              rune, consuming it afterward.
            </p>
            <p>
              <b>This rune will only work on the main space station</b>, but can
              grab cultists from almost any location!
            </p>
            <p>
              Does not work on restrained cultists who are buckled or being
              pulled.
            </p>
          </Box>
        )}
        {tab === 7 && (
          <Box>
            <h2>
              <Box inline textColor="#CC5500">
                <i>Dedo ol&apos;btoh!</i>
              </Box>
            </h2>
            <b>Name</b>: Boil Blood
            <br />
            <b>Cultists Required</b>: 3
            <p>
              When invoked, it saps some health from the invokers to send three
              damaging pulses to anyone who can see the rune, causing 25/50/75
              damage split evenly between brute and burn. When the effect is
              over the rune will briefly set fire to anything over it.
            </p>
            <p>
              Some species, such as golems, do not have blood, and thus are
              immune to this rune. Will also deal extra stamina damage to clock
              cultists.
            </p>
          </Box>
        )}
        {tab === 8 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>Gal&apos;h&apos;rfikk harfrandid mud&apos;gib!</i>
              </Box>
            </h2>
            <b>Name</b>: Spirit Realm
            <br />
            <b>Cultists Required</b>: 1
            <p>This rune gives you two powerful options:</p>
            <p>
              <b>1)</b> To manifest ghosts as semitransparent homunculi, which
              are effectively weak, humanoid cultists with no self preservation
              instinct. To sustain these homunculi, you must remain on the rune,
              and each homunculi you have summoned will deal brute damage over
              time. If you get stuck on the rune after summoning a ghost, use
              your ritual dagger to remove the rune before you get hurt too
              badly.
              <br />
              This option is only available on the space station itself, as the
              veil is not weak enough in space or Lavaland to give spirits a
              physical form.
            </p>
            <p>
              <b>2)</b> To ascend as a dark spirit. This option costs no health
              to use and will give you virtually unlimited knowledge! You can
              use information given to you by ghosts in this form, commune with
              the cult with your booming voice, and even mark a target that will
              be &quot;pinpointed&quot; for the rest of the cult. You can even
              use this function after manifesting ghosts to help guide them in
              combat - manifested ghosts can also see regular ghosts and
              therefore can see your dark spirit as you lead them in battle!
            </p>
          </Box>
        )}
        {tab === 9 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>Ta&apos;gh fara&apos;qha fel d&apos;amar det!</i>
              </Box>
            </h2>
            <b>Name</b>: Apocalypse
            <br />
            <b>Cultists Required</b>: 3
            <p>
              A harbinger of the end times. It scales depending on the
              crew&apos;s strength relative to the cult. Effects include a
              massive EMP, unique hallucination for non-cultists, and if the
              cult is doing poorly, certain events. The rune can only occur in
              the Nar-Sie ritual sites and will prevent Nar-Sie from being
              summoned there in the future.
            </p>
            <p>
              Similarly to the Ritual of Dimensional Rending, the Apocalypse
              rune can only be scribed in one of the 3 ritual areas. After the
              Apocalypse rune has been scribed, that particular ritual area can
              no longer be used to summon Nar-Sie.
            </p>
          </Box>
        )}
        {tab === 10 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>TOK-LYR RQA-NAP G&apos;OLT-ULOFT!!</i>
              </Box>
            </h2>
            <b>Name</b>: Nar&apos;Sie
            <br />
            <b>Cultists Required</b>: 9
            <p>
              This rune tears apart dimensional barriers, calling forth the
              Geometer. It needs a free 3x3 space, and can only be summoned in 3
              areas around the station. To start drawing it the requested target
              must have already been sacrificed. Starting to draw this rune
              creates a weak forcefield around the caster and alarms the entire
              station of its location. The caster must be defended for 45
              seconds before it&apos;s complete.
            </p>
            <p>
              After it&apos;s drawn, 9 cultists, constructs, or summoned ghosts
              must stand on the rune, which can then be invoked to manifest
              Nar&apos;Sie herself.
            </p>
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
};

const PowersSection = (_props) => {
  const [tab, setTab] = useLocalState('powersTab', 1);
  return (
    <Section title="Powers">
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Box
                inline
                as="img"
                src={resolveAsset('dagger.png')}
                width="32px"
                style={{
                  msInterpolationMode: 'nearest-neighbor',
                  imageRendering: 'pixelated',
                  float: 'left',
                }}
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
                style={{
                  msInterpolationMode: 'nearest-neighbor',
                  imageRendering: 'pixelated',
                  float: 'left',
                }}
              />
              Use{' '}
              <Box inline textColor="red">
                Communion
              </Box>{' '}
              to communicate with your fellow cultists. Messages communicated
              this way can be heard by all cultists.
              <br />
              Be warned though, those standing close to you will also hear you!
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Tabs>
            <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
              Blood Magic
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
              Runes
            </Tabs.Tab>
          </Tabs>
          {tab === 1 && <BloodMagicSection />}
          {tab === 2 && <RunesSection />}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoBloodCult = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={750} height={900} theme="narsie">
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name="Blood Cultist" asset="bloodcult.png" />
          </Stack.Item>
          <Stack.Item>
            <PowersSection />
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
