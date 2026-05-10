import { Box } from 'tgui-core/components';

import { MASK } from './TreatyData';
import { FactionType } from './TreatyTypes';

// displays a faction's info card in the party section
export const PartyDisplay = ({
  party,
  align = 'left',
  isExpert,
}: {
  party: FactionType | null | undefined;
  align?: 'left' | 'right';
  isExpert?: boolean;
}) => {
  if (!party) {
    return (
      <Box
        color="label"
        textAlign="center"
        py={2}
        style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '150px' }}
      >
        {isExpert ? '[CLICK TO SELECT PARTY]' : MASK}
      </Box>
    );
  }

  return (
    <Box position="relative" style={{ overflow: 'visible', height: '150px' }}>
      <Box
        position="relative"
        textAlign={align}
        style={{ zIndex: 1, height: '100%', display: 'flex', flexDirection: 'column' }}
      >
        <Box bold>{party.name}</Box>
        <Box bold color="gold" fontSize="0.9em" mb={0.5}>
          Wealth: {party.vault}
        </Box>
        <Box
          fontSize="0.9em"
          color="#b1a390"
          backgroundColor="#181612"
          p={1.5}
          style={{
            overflowWrap: 'break-word',
            whiteSpace: 'normal',
            flexGrow: 1,
            overflowY: 'auto',
            border: '1px solid #333',
          }}
        >
          {party.desc}
        </Box>
      </Box>
    </Box>
  );
};

export const WrapBox = ({ label, value }: { label: string; value: string | undefined }) => (
  <Box>
    {label}:{' '}
    <span style={{ color: '#fff', overflowWrap: 'break-word', wordBreak: 'break-word', whiteSpace: 'normal' }}>
      {value ?? ''}
    </span>
  </Box>
);
