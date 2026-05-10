import { useMemo } from 'react';
import { Box } from 'tgui-core/components';

import { FactionType, TermType } from './TreatyTypes';

// resolves authority display names and signature status
// sometimes the backend is gonna be sending up something like 'faction owner' or 'target' and we'll wanna translate that to the actual owner/target
export const useAuthorityResolver = (
  term: TermType,
  signedSet: Set<string>,
  factions: FactionType[],
) => {
  return useMemo(() => {
    const getDisplay = (f: FactionType) =>
      f.owner ? `${f.owner} (${f.job_owner || 'Leader'})` : f.job_owner || f.name;

    return (auth: string) => {
      const authLower = auth.toLowerCase();

      if (authLower === 'target' && term.target) {
        const faction = factions.find((f) => f.name === term.target);
        if (faction) {
          return {
            display: getDisplay(faction),
            signed: !!faction.owner && signedSet.has(faction.owner.toLowerCase()),
            visible: true,
          };
        }
        return {
          display: term.target,
          signed: signedSet.has(term.target.toLowerCase()),
          visible: true,
        };
      }

      if (authLower === 'receiver' && term.receiver) {
        const faction = factions.find((f) => f.name === term.receiver);
        if (faction) {
          return {
            display: getDisplay(faction),
            signed: !!faction.owner && signedSet.has(faction.owner.toLowerCase()),
            visible: true,
          };
        }
        return {
          display: term.receiver,
          signed: signedSet.has(term.receiver.toLowerCase()),
          visible: true,
        };
      }

      return {
        display: auth,
        signed: signedSet.has(authLower),
        visible: true,
      };
    };
  }, [term, signedSet, factions]);
};

export const SignatureDisplay = ({
  term,
  signatures,
  minSigs,
  isUnsigned,
  signedSet,
  factions,
}: {
  term: TermType;
  signatures: string[];
  minSigs: number;
  isUnsigned: boolean;
  signedSet: Set<string>;
  factions: FactionType[];
}) => {
  const resolveAuth = useAuthorityResolver(term, signedSet, factions);
  const weightDisplay = term.signature_weight_total ?? signatures.length;

  return (
    <Box
      mt={1}
      p={1}
      style={{
        backgroundColor:
          isUnsigned && !term.open_signatures ? 'rgba(255, 0, 0, 0.1)' : 'rgba(0, 255, 0, 0.1)',
        border: `1px solid ${isUnsigned && !term.open_signatures ? '#731313' : 'green'}`,
        width: '100%',
      }}
    >
      {!term.open_signatures ? (
        <Box bold color={isUnsigned ? 'red' : 'green'}>
          Signatures: {weightDisplay} / {minSigs}
        </Box>
      ) : (
        <Box bold color="green">
          Open Signatures
        </Box>
      )}

      {!term.open_signatures && (term.authorities?.length || 0) > 0 && (
        <Box mt={0.5} fontSize="0.9em">
          <Box bold color="label" mb={0.5}>
            Required Signatures:
          </Box>
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
            {term.authorities?.map((auth) => {
              const { display, signed, visible } = resolveAuth(auth);
              if (!visible) return null;
              return (
                <Box
                  key={auth}
                  color={signed ? 'good' : 'light-gray'}
                  style={{
                    border: `1px solid ${signed ? 'green' : 'gray'}`,
                    padding: '2px 6px',
                    borderRadius: '4px',
                    overflowWrap: 'break-word',
                    whiteSpace: 'normal',
                  }}
                >
                  {display}
                </Box>
              );
            })}
          </Box>
        </Box>
      )}

      {signatures.length > 0 && (
        <Box mt={1} fontSize="0.9em">
          <Box bold color="label" mb={0.5}>
            Signatures:
          </Box>
          <Box style={{ display: 'flex', flexDirection: 'row', gap: '4px', overflowX: 'auto', paddingBottom: '2px' }}>
            {signatures.map((s) => (
              <Box
                key={s}
                color="good"
                style={{
                  border: '1px solid green',
                  padding: '2px 6px',
                  borderRadius: '4px',
                  whiteSpace: 'nowrap',
                  flexShrink: 0,
                }}
              >
                {s}
              </Box>
            ))}
          </Box>
        </Box>
      )}
    </Box>
  );
};
