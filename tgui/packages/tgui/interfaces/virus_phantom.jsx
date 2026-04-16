import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { NtosWindow } from '../layouts';

const rawLogo = String.raw`
  ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗███╗   ███╗
  ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝████╗ ████║
  ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██╔████╔██║
  ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║╚██╔╝██║
  ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ██║ ╚═╝ ██║
  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝     ╚═╝
                      v1.0
        -==[ HELLRAISERS CRACK TEAM ]==-`;

export const virus_phantom = () => {
  const { act } = useBackend();

  const lines = rawLogo.trimEnd().split('\n');

  return (
    <NtosWindow title="Phantm.exe" width={550} height={350}>
      <NtosWindow.Content>
        <Section
          fill
          scrollable
          backgroundColor="black"
          style={{ whiteSpace: 'pre-wrap' }}
        >
          {lines.map((line, i) => (
            <Box key={i} fontFamily="monospace">
              {line}
            </Box>
          ))}

          <Box mt={2} color="#aaa" fontFamily="monospace">
            Insert your ID card into the device, then hit the button below.
          </Box>
          <Box mt={0.5} color="#aaa" fontFamily="monospace">
            The account routing data on the card will be scrambled, hiding it
            from station management systems.
          </Box>

          <Box mt={2} style={{ display: 'flex', gap: '0.5rem' }}>
            <Button
              style={{
                backgroundColor: 'black',
                border: '1px solid #ff004d',
                color: '#ff004d',
                fontFamily: 'monospace',
                padding: '0.4rem 1rem',
                textTransform: 'uppercase',
                cursor: 'pointer',
                textShadow: '0 0 5px #ff004d',
              }}
              onClick={() => act('PC_exit')}
            >
              Cancel
            </Button>

            <Button
              style={{
                backgroundColor: 'black',
                border: '1px solid #ff6600',
                color: '#ff6600',
                fontFamily: 'monospace',
                padding: '0.4rem 1rem',
                textTransform: 'uppercase',
                cursor: 'pointer',
                textShadow: '0 0 5px #ff6600',
              }}
              onClick={() => act('Detonate')}
            >
              Scramble Account
            </Button>
          </Box>

          <Box mt={1} color="#ffea00" fontFamily="monospace">
            Tip: The cartridge will self-destruct after use.
          </Box>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const interfaces = {
  virus_phantom,
};
