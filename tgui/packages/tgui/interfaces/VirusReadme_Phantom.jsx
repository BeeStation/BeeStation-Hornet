import '../styles/VirusReadme.scss';

import { NtosWindow } from '../layouts';
import { VirusHeader } from './VirusHeader';

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
Yo.

Ever had station management breathing down your neck?
Accounts visible on every console for any nosy head to snoop through?

We got you covered. Introducing the Phantm drive.

This little beauty scrambles the account routing data on any ID card
you feed it. Once scrambled, the linked bank account becomes invisible
to station management systems. Paydays still come in, money still works,
but nobody can see your balance or track your transactions from a console.

It's like you never existed. A phantom, if you will.

Usage:
 1. Insert the Phantm drive into your device.
 2. Make sure your ID card is in the device's card slot.
 3. Run the Phantm.exe file.
 4. Hit "Scramble Account".
 5. Done. Your account is now off the grid.

Remote usage:
 1. Install "NTmessager".
 2. Turn on "Send Executable" when prompted.
 3. Pick a target.
 4. Their ID's account routing data will be scrambled.

Notes:
 • The cartridge will self-destruct after use.
 • This does NOT delete the account. It just hides it.
 • A multitool on the ID card can reverse the process. So watch out.
 • Works on any ID with a linked bank account.

Stay invisible.
- Hellraisers  ⧉ 2536
`;

export const VirusReadme_Phantom = (props) => {
  return (
    <NtosWindow title="Phantm-README.txt" width={650} height={560}>
      <NtosWindow.Content>
        <VirusHeader
          header={header}
          preText={intro}
          text={body}
          lineDelay={0.1}
        />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const interfaces = { VirusReadme_Phantom };
