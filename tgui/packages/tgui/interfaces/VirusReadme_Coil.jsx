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
Comrades!

Haha, just kidding.

NT kinda pissed us of this time they didn't really
enjoy the crack we did for their Antivirus so they decided to start
"legally" syphoning credits from members of our team.

It was okay when it was just us. But then they started doing
it to our families and it was when I had to explain to my grandma
why she had suddenly become destitute after decades of hard work that
I decided we could do more.

We are entrusting you with this Virus, the Coil.

You only get one shot so listen carefully:
This Virus has two injection methods.


Remote usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted. (Be alarmed)
 3. Pick a target (Hopefully an NT prick).
 4. Emp ensues.
 5. Profit?

You can also activate the file itself.

Manual Usage:
 1. Run the File that comes pre-installed.
 2. Let it play in its entirity...
 3. Emp ensues.
 4. But on your own face this time.

Notes:
 • BE CREATIVE! NT Security are brainwashed drones, they
   will not understand this concept!
 • Closing the program early will cause early detonation,
   but it will be not as strong.
 • The cartrige will self-destruct on use.

Stick it to the man!!
- Hellraisers  ⧉ 2536
`;

export const VirusReadme_Coil = (props) => {
  return (
    <NtosWindow title="Coilvrs-README.txt" width={650} height={560}>
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

export const interfaces = { VirusReadme_Coil };
