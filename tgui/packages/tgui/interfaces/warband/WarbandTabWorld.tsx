import { useRef, useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { CasusBelliPanel } from './WarbandCasusBelli';
import { CasusBelliProposal, CasusBelliTerm, NobleType } from './WarbandTypes';

type WorldTabProps = {
  nobleList: NobleType[];
  act: (action: string, payload?: object) => void;
  proposals: CasusBelliProposal[];
  availableTerms: CasusBelliTerm[];
  userProposal: string | null;
  userVote: string | null;
  userVoteConfirmed: boolean;
  warlordSelectedProposal: string | null;
  warlordCasusBelli: CasusBelliTerm | null;
  isWarlord: boolean;
  locked?: boolean;
  factions: any[];
  lockedWarbandType: string | null;
};

const SPLIT_MIN = 80;
const SPLIT_DEFAULT = 220;
const DIVIDER_H = 8;
const THIN_MIN = 12;

export const WorldTab = ({
  nobleList, act,
  proposals, availableTerms,
  userProposal, userVote, userVoteConfirmed,
  warlordSelectedProposal, warlordCasusBelli,
  isWarlord, locked = false, factions,
  lockedWarbandType,
}: WorldTabProps) => {
  const [casusBelliHeight, setCasusBelliHeight] = useState(SPLIT_DEFAULT);
  const containerRef = useRef<HTMLDivElement>(null);

  const handleDragStart = (e: React.MouseEvent) => {
    e.preventDefault();
    const startY = e.clientY;
    const startHeight = casusBelliHeight;

    const onMove = (ev: MouseEvent) => {
      const delta = ev.clientY - startY;
      const containerH = containerRef.current?.clientHeight ?? 600;
      const maxH = containerH - THIN_MIN - DIVIDER_H;
      setCasusBelliHeight(Math.max(SPLIT_MIN, Math.min(maxH, startHeight + delta)));
    };

    const onUp = () => {
      window.removeEventListener('mousemove', onMove);
      window.removeEventListener('mouseup', onUp);
    };

    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseup', onUp);
  };

  const measuredH = containerRef.current?.clientHeight;
  const topHeight = measuredH
    ? Math.min(casusBelliHeight, Math.max(SPLIT_MIN, measuredH - THIN_MIN - DIVIDER_H))
    : casusBelliHeight;

  const confirmed = locked && !!warlordCasusBelli;

  // after the casus belli stage is passed, the entire tab is dedicated to displaying the chosen term
  if (confirmed) {
    return (
      <Stack style={{ flex: 1, flexDirection: 'column', height: '100%' }}>
        <Stack.Item grow={1} style={{ minHeight: 0, display: 'flex', flexDirection: 'column' }}>
          <CasusBelliPanel
            proposals={proposals} availableTerms={availableTerms}
            userProposal={userProposal} userVote={userVote} userVoteConfirmed={userVoteConfirmed}
            warlordSelectedProposal={warlordSelectedProposal}
            warlordCasusBelli={warlordCasusBelli}
            isWarlord={isWarlord} act={act}
            factions={factions ?? []}
            locked={locked}
            lockedWarbandType={lockedWarbandType}
          />
        </Stack.Item>
        <Section style={{ flex: 0, flexBasis: 'auto' }}>
          <Stack direction="row" justify="center">
            <Button
              onClick={() => act('view_laws')}
              style={{ flex: 1, fontSize: '25px', padding: '25px', display: 'flex', marginBottom: '110px', justifyContent: 'center', alignItems: 'center' }}
            >
              VIEW LAWS
            </Button>
          </Stack>
        </Section>
      </Stack>
    );
  }

  return (
    <Stack style={{ flex: 1, flexDirection: 'column', height: '100%' }}>
      <Stack.Item grow={1} style={{ minHeight: 0, display: 'flex', flexDirection: 'column' }}>
        <div ref={containerRef} style={{ display: 'flex', flexDirection: 'column', flex: 1, minHeight: 0 }}>
          <div style={{ height: topHeight, flexShrink: 0, overflow: 'hidden' }}>
            <CasusBelliPanel
              proposals={proposals} availableTerms={availableTerms}
              userProposal={userProposal} userVote={userVote} userVoteConfirmed={userVoteConfirmed}
              warlordSelectedProposal={warlordSelectedProposal}
              warlordCasusBelli={warlordCasusBelli}
              isWarlord={isWarlord} act={act}
              factions={factions ?? []}
              locked={locked}
              lockedWarbandType={lockedWarbandType}
            />
          </div>

          <div
            onMouseDown={handleDragStart}
            style={{
              height: `${DIVIDER_H}px`,
              flexShrink: 0,
              cursor: 'ns-resize',
              backgroundColor: '#1a0a0a',
              borderTop: '1px solid #5a2020',
              borderBottom: '1px solid #5a2020',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              userSelect: 'none',
            }}
          >
            <div style={{ display: 'flex', gap: '3px', pointerEvents: 'none' }}>
              {[0, 1, 2, 3, 4].map((i) => (
                <div key={i} style={{
                  width: '3px', height: '3px',
                  borderRadius: '50%',
                  backgroundColor: '#7a3030',
                }} />
              ))}
            </div>
          </div>

          <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
            <Section
              title={<span style={{ color: '#7a2525ff' }}>KNOW THY ENEMIES</span>}
              scrollable fill style={{ flex: 1, minHeight: 0 }}
            >
              {nobleList.length > 0 ? (
                <Stack vertical>
                  {nobleList.map((noble) => (
                    <Button
                      key={noble.name} tooltip={noble.name}
                      onClick={() => { act('view_vip', { enemy: noble.name }); act('interaction_sound'); }}
                      style={{ textAlign: 'center' }}
                    >
                      The {noble.job}
                    </Button>
                  ))}
                </Stack>
              ) : (
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
                  <p style={{ color: '#7a2525ff' }}>THERE ARE NO ENEMIES OF NOTE</p>
                </div>
              )}
            </Section>

            <Section style={{ flexShrink: 0 }}>
              <Stack direction="row" justify="center">
                <Button
                  onClick={() => act('view_laws')}
                  style={{ flex: 1, fontSize: '25px', padding: '25px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}
                >
                  VIEW LAWS
                </Button>
              </Stack>
            </Section>
          </div>

        </div>
      </Stack.Item>
    </Stack>
  );
};
