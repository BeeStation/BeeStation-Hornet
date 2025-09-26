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
Ok!

Gloves are off this time.

We have decided to use our knowledge of NTOS Virus Buster to
deliver it's reckoning. (or is it reconing? Rekoning?
I mean like, it will cease to be.)

While they hide behind their walls NT keeps reeping in the rewards of
exploiting the common person, that has nowhere better to be...

Well, their walls are no more. Cus we bring in the SLEDGEHAMMER!
(This ones mine!)

One shot.
Dual injection.


Remote usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted.
 3. Pick a target.
 4. If they have Virus Buster installed it will knock them down a sub.

You can also activate the file itself.

Manual Usage:
 1. Run the File that comes pre-installed.
 2. Let it play (or not).
 3. Completely removes Virus Buster from your device.

Notes:
 • Careful. The virus doesn't stack. So if they have level 3
   package they can only go down to 2.
 • This is ideal for manual uninstalls of VB (To set up other viruses)
 • The cartrige will self-destroy on use.

Let them fear us!
- Hellraisers  ⧉ 2536
`;

export const VirusReadme_Sledge = () => (
  <NtosWindow title="Sleghamr-README.txt" width={650} height={560}>
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

export const interfaces = { VirusReadme_Sledge };
