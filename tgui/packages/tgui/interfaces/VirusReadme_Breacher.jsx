import '../styles/VirusReadme.scss';

import { NtosWindow } from '../layouts';
import { VirusHeader } from './VirusHeader';

// Static header always visible
const header = String.raw`
  $$\   $$\         $$\$$\                 $$\
  $$ |  $$ |        $$ $$ |                \__|
  $$ |  $$ |$$$$$$\ $$ $$ |$$$$$$\ $$$$$$\ $$\ $$$$$$$\ $$$$$$\  $$$$$$\  $$$$$$$\
  $$$$$$$$ $$  __$$\$$ $$ $$  __$$\\____$$\$$ $$  _____$$  __$$\$$  __$$\$$  _____|
  $$  __$$ $$$$$$$$ $$ $$ $$ |  \__$$$$$$$ $$ \$$$$$$\ $$$$$$$$ $$ |  \__\$$$$$$\
  $$ |  $$ $$   ____$$ $$ $$ |    $$  __$$ $$ |\____$$\$$   ____$$ |      \____$$\
  $$ |  $$ \$$$$$$$\$$ $$ $$ |    \$$$$$$$ $$ $$$$$$$  \$$$$$$$\$$ |     $$$$$$$  |
  \__|  \__|\_______\__\__\__|     \_______\__\_______/ \_______\__|     \_______/

                        -==[ HELLRAISERS CRACK TEAM ]==-
`;

const intro = `
Auth bypass successful.
Opening README.txt …
`;

const body = `
Hey.

Whats shakin, bakin. (!?!!?!?)

We read some comments on the forums regarding NT policy enforcers abusing
the ability to disable NT messager altogether.

It's an act of cowardice we cannot abide by. (I think that means tolerate)
So, we've developed a special little something for you, child of mankind.

We are entrusting you with this Virus, the Breacher.
(Daxter spells it like Brexer, and since he kinda coded the whole thing...
I let him have this win. Also, idk why the heck you'd need a virus that
explodes your fingers off but... again... his code...)

As usual you only get one shot so listen carefully:
Dual injection method Virus.


Remote usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted.
 3. Pick a target.
 4. Their Device's receiving will be locked ON.
 5. Harrass them freely.

You can also activate the file itself.

Manual Usage:
 1. Run the File that comes pre-installed.
 2. Let it play (or don't).
 4. Press Detonate
 3. Your computer battery will EXPLODE.

Notes:
 • Be warned! It is possible a fresh install of an anti-virus can
   do away with this trojan.
 • Starting the virus is non-reversable, it will either detonate
   or brick your computer.
 • The cartrige will self-destroy on use.

Have fun raising hell!
- Hellraisers  ⧉ 2536
`;

export const VirusReadme_Breacher = (props) => {
  return (
    <NtosWindow title="BrexerTrojn-README.txt" width={650} height={560}>
      <NtosWindow.Content>
        <VirusHeader
          header={header}
          preText={intro}
          text={body}
          lineDelay={0.1} // ← tweak this to speed up / slow down */
        />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const interfaces = { VirusReadme_Breacher };
