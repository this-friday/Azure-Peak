import React, { useEffect, useMemo, useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { DynamicInputs } from './TreatyInputs';
import { CasusBelliProposal, CasusBelliTerm } from './WarbandTypes';

type CasusBelliPanelProps = {
  proposals: CasusBelliProposal[];
  availableTerms: CasusBelliTerm[];
  userProposal: string | null;
  userVote: string | null;
  userVoteConfirmed: boolean;
  warlordSelectedProposal: string | null;
  warlordCasusBelli: CasusBelliTerm | null;
  isWarlord: boolean;
  act: (action: string, payload?: object) => void;
  factions: any[];
  locked?: boolean;
  lockedWarbandType: string | null; // the warlord's locked warband type string | used to filter out warband-specific terms/proposals
};

type ViewState = 'list' | 'browse' | 'draft';

const detailStyle: React.CSSProperties = { fontSize: '11px', color: '#b1a390', marginTop: '2px' };

type BadgeType = 'warlord' | 'proposal+confirmed' | 'confirmed' | 'proposal+vote' | 'vote' | 'proposal';
const BADGE_CONFIG: Record<BadgeType, { label: string; color: string; bold?: true }> = {
  'warlord':            { label: '🔒 WARLORD\'S CHOICE', color: '#4db84d', bold: true },
  'proposal+confirmed': { label: '★ YOUR PROPOSAL + VOTE ✓', color: '#5a9a5a' },
  'confirmed':          { label: '★ YOUR VOTE ✓', color: '#7aaaff', bold: true },
  'proposal+vote':      { label: '★ YOUR PROPOSAL + VOTE', color: '#a08030' },
  'vote':               { label: '★ YOUR VOTE', color: '#7aaaff' },
  'proposal':           { label: 'YOUR PROPOSAL', color: '#8b6914' },
};

export const CasusBelliPanel = ({
  proposals,
  availableTerms,
  userProposal,
  userVote,
  userVoteConfirmed,
  warlordSelectedProposal,
  warlordCasusBelli,
  isWarlord,
  act,
  factions,
  locked = false,
  lockedWarbandType,
}: CasusBelliPanelProps) => {
  const [view, setView] = useState<ViewState>('list');
  const [draftingTerm, setDraftingTerm] = useState<CasusBelliTerm | null>(null);
  const [draftState, setDraftState] = useState<Record<string, any>>({
    custom_name: '', text: '', number: 1,
    target: '', receiver: '', obj_target: '', intermediateTarget: '',
  });
  const [showVoteResetWarning, setShowVoteResetWarning] = useState(false);

  const updateDraftState = (key: string, val: any) =>
    setDraftState((prev) => ({ ...prev, [key]: val }));

  const sortedProposals = useMemo(() => {
    return [...proposals].sort((a, b) => b.vote_count - a.vote_count);
  }, [proposals]);

  // whether or not the warlord has locked in the proposal this player authored
  const userProposalIsWarlordLocked = !!(userProposal && warlordSelectedProposal === userProposal);
  
  const userProposalConfirmedVotes = useMemo(
    () => proposals.find((p) => !!p.is_user_proposal)?.vote_count ?? 0,
    [proposals],
  );

  useEffect(() => {
    if (userProposalIsWarlordLocked) setShowVoteResetWarning(false);
  }, [userProposalIsWarlordLocked]);

  // draft validity checks
  const isDraftValid = useMemo(() => {
    if (!draftingTerm) return false;
    for (const field of draftingTerm.inputs ?? []) {
      if (!field.required || field.client_only) continue;
      const val = draftState[field.key];
      switch (field.widget) {
        case 'number_input': {
          const n = Number(val);
          if (!val && val !== 0) return false;
          if (n < (field.min_value ?? 1)) return false;
          break;
        }
        case 'textarea': {
          const s = String(val ?? '');
          if (s.length < (field.min_length ?? 1)) return false;
          if (s.length > (field.max_length ?? Infinity)) return false;
          break;
        }
        case 'text_input': {
          const s = String(val ?? '');
          if (s.trim().length < (field.min_length ?? 1)) return false;
          break;
        }
        default:
          if (!val || String(val).trim().length === 0) return false;
      }
    }
    return true;
  }, [draftingTerm, draftState]);

  const handleDraftSubmit = () => {
    if (!draftingTerm || !isDraftValid) return;
    const payload: Record<string, any> = {
      term_type: draftingTerm.type,
      term_name: draftState.custom_name || draftingTerm.name,
    };
    for (const field of draftingTerm.inputs ?? []) {
      if (field.client_only) continue;
      const val = draftState[field.key];
      if (val !== undefined && val !== '' && val !== null) {
        payload[field.key] = val;
      }
    }
    act('propose_casus_belli', payload);
    setShowVoteResetWarning(false);
    setView('list');
  };

  const openDraft = (term: CasusBelliTerm) => {
    setDraftingTerm(term);
    setDraftState({
      custom_name: '', text: '', number: 1,
      target: '', receiver: '', obj_target: '', intermediateTarget: '',
    });
    setView('draft');
  };

  const handleOpenBrowse = () => {
    if (locked || userProposalIsWarlordLocked) return;
    if (userProposal && userProposalConfirmedVotes > 0) {
      setShowVoteResetWarning(true);
      return;
    }
    setShowVoteResetWarning(false);
    setView('browse');
  };

  // browse view
  if (view === 'browse') {
    // filter out warband-specific terms unless the locked warband matches
    const visibleTerms = availableTerms.filter((term) => {
      if (!term.warbandlock) return true;
      return term.warbandlock === lockedWarbandType;
    });

    // term types the player has already proposed
    const userProposedTermTypes = new Set(
      proposals.filter((p) => !!p.is_user_proposal).map((p) => p.term_type)
    );

    return (
      <Section
        title={<span style={{ color: '#7a2525ff' }}>SELECT A TERM</span>}
        fill scrollable
        style={{ display: 'flex', flexDirection: 'column', height: '100%', overflowY: 'auto' }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', width: '100%' }}>
          {visibleTerms.map((term) => (
            <Button
              key={term.type} fluid textAlign="left"
              onClick={() => { if (!locked) openDraft(term); }}
              disabled={locked}
              style={{
                whiteSpace: 'normal', height: 'auto', padding: '8px 12px', width: '100%',
                backgroundColor: userProposedTermTypes.has(term.type) ? '#7a2525ff' : undefined,
              }}
            >
              <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
                <span style={{ fontWeight: 'bold', color: '#e9ca9e' }}>{term.name}</span>
                <span style={{ fontSize: '12px', color: '#b1a390' }}>{term.desc}</span>
              </div>
            </Button>
          ))}
        </div>
        <Box mt={1}>
          <Button fluid icon="arrow-left" onClick={() => setView('list')}>BACK</Button>
        </Box>
      </Section>
    );
  }

  // draft view
  if (view === 'draft' && draftingTerm) {
    return (
      <Section
        title={<span style={{ color: '#7a2525ff' }}>{isWarlord ? 'DRAFT CASUS BELLI' : 'PROPOSE A TERM'}</span>}
        fill scrollable
        style={{ display: 'flex', flexDirection: 'column', height: '100%', overflowY: 'auto' }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', width: '100%' }}>

          <Box bold color="#e9ca9e">{draftingTerm.name}</Box>

          <Box fontSize="0.9em" color="#b1a390">{draftingTerm.desc}</Box>

          <DynamicInputs
            inputs={draftingTerm.inputs ?? []}
            state={draftState}
            updateState={updateDraftState}
            factions={factions}
          />

          <Stack mt={1}>
            <Stack.Item grow={1}>
              <Button fluid color="good" icon="pen" onClick={handleDraftSubmit} disabled={!isDraftValid}>
                {isWarlord ? 'CONFIRM CASUS BELLI' : 'SUBMIT PROPOSAL'}
              </Button>
            </Stack.Item>
            <Stack.Item grow={1}>
              <Button fluid color="bad" icon="times" onClick={() => setView('browse')}>BACK</Button>
            </Stack.Item>
          </Stack>

        </div>
      </Section>
    );
  }

  // list view
  return (
    <Section
      title={<span style={{ color: '#7a2525ff' }}>CASUS BELLI</span>}
      fill
    >
      <Stack fill vertical>
        <Stack.Item grow={1} style={{ overflowY: 'auto', minHeight: 0 }}>
          {sortedProposals.length > 0 ? (
            <Stack vertical>
              {sortedProposals.map((proposal) => {
                const isWarlordSelected = !!proposal.is_warlord_selected;
                const isUserProposal = !!proposal.is_user_proposal;
                const isUserVote = userVote === proposal.proposal_id;
                const isUserVoteConfirmed = !!proposal.is_user_vote_confirmed;

                type BadgeKey = BadgeType | null;
                const badge: BadgeKey =
                  isWarlordSelected ? 'warlord'
                  : (isUserProposal && isUserVoteConfirmed) ? 'proposal+confirmed'
                  : isUserVoteConfirmed ? 'confirmed'
                  : (isUserProposal && isUserVote) ? 'proposal+vote'
                  : isUserVote ? 'vote'
                  : isUserProposal ? 'proposal'
                  : null;

                // votes are frozen once confirmed
                const voteDisabled = locked || (!isWarlord && !!userVoteConfirmed);
                const pendingCount = proposal.pending_count ?? 0;

                return (
                  <Button
                    key={proposal.proposal_id}
                    fluid textAlign="left"
                    onClick={() => {
                      if (isWarlord) {
                        if (locked) return;
                        act('select_casus_belli', { proposal_id: proposal.proposal_id });
                        act('interaction_sound');
                      } else {
                        if (voteDisabled) return;
                        act('vote_casus_belli', { proposal_id: proposal.proposal_id });
                        act('interaction_sound');
                      }
                    }}
                    disabled={isWarlord ? locked : voteDisabled}
                    style={{
                      whiteSpace: 'normal', height: 'auto', padding: '8px 12px',
                      backgroundColor: isWarlordSelected
                        ? 'rgba(30, 100, 30, 0.55)'
                        : isUserVoteConfirmed
                          ? 'rgba(50, 80, 130, 0.55)'
                          : isUserVote
                            ? 'rgba(50, 80, 130, 0.35)'
                            : undefined,
                      border: isWarlordSelected
                        ? '1px solid #3a8a3a'
                        : isUserVote
                          ? '1px solid #5a8adf'
                          : isUserProposal
                            ? '1px solid #8b6914'
                            : undefined,
                    }}
                  >
                    <Stack vertical>
                      <Stack align="center">
                        <Stack.Item grow={1}>
                          <span style={{ fontWeight: 'bold', color: '#e9ca9e' }}>
                            {proposal.term_name}
                          </span>
                        </Stack.Item>
                        {badge && (
                          <Stack.Item>
                            <span style={{ fontSize: '11px', color: BADGE_CONFIG[badge].color, fontWeight: BADGE_CONFIG[badge].bold ? 'bold' : undefined }}>
                              {BADGE_CONFIG[badge].label}
                            </span>
                          </Stack.Item>
                        )}
                      </Stack>

                      <span style={{ fontSize: '12px', color: '#b1a390' }}>{proposal.term_desc}</span>

                      {!!proposal.term_text && (
                        <Box mt={0.5} p={0.5} style={{
                          backgroundColor: 'rgba(0,0,0,0.3)', whiteSpace: 'pre-wrap',
                          wordBreak: 'break-word', fontSize: '0.85em', color: '#c8bfb0',
                        }}>
                          {proposal.term_text}
                        </Box>
                      )}
                      {(() => {
                        const displayFields = (proposal as any).display_fields as { key: string; label: string }[] | undefined;
                        if (displayFields?.length) {
                          return displayFields.map((field) => {
                            const val = (proposal as any)[`term_${field.key}`];
                            if (!val) return null;
                            return (
                              <span key={field.key} style={detailStyle}>
                                {field.label}: {val}
                              </span>
                            );
                          });
                        }
                        // a fallback for proposals missing display_fields (e.g. older data)
                        return (
                          <>
                            {!!proposal.term_number && proposal.term_number > 0 && (
                              <span style={detailStyle}>Number: {proposal.term_number}</span>
                            )}
                            {!!proposal.term_target && (
                              <span style={detailStyle}>Target: {proposal.term_target}</span>
                            )}
                            {!!proposal.term_receiver && (
                              <span style={detailStyle}>Recipient: {proposal.term_receiver}</span>
                            )}
                            {!!proposal.term_obj_target && (
                              <span style={detailStyle}>Territory: {proposal.term_obj_target}</span>
                            )}
                          </>
                        );
                      })()}

                      <span style={{ fontSize: '11px', color: '#888', marginTop: '2px' }}>
                        {proposal.vote_count} vote{proposal.vote_count !== 1 ? 's' : ''}
                        {pendingCount > 0 && (
                          <span style={{ color: '#6b5a20' }}> (+{pendingCount} pending)</span>
                        )}
                      </span>
                    </Stack>
                  </Button>
                );
              })}
            </Stack>
          ) : (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80px' }}>
              <p style={{ color: '#7a2525ff' }}>NO PROPOSITIONS YET</p>
            </div>
          )}
        </Stack.Item>

        <Stack.Item style={{ flexShrink: 0 }}>
          <Stack vertical>

            {showVoteResetWarning && (
              <Box p={1} mb={1} style={{
                backgroundColor: 'rgba(100, 60, 0, 0.35)',
                border: '1px solid #8b6914', borderRadius: '2px',
              }}>
                <Box bold color="#e9ca9e" fontSize="0.85em" mb={0.5}>YOUR PROPOSAL HAS VOTES</Box>
                <Box fontSize="0.82em" color="#b1a390" mb={1}>
                  Changing your proposal will remove your current term from the list
                  and reset any votes it has received. Are you sure?
                </Box>
                <Stack>
                  <Stack.Item grow={1}>
                    <Button fluid color="average" icon="exclamation-triangle"
                      onClick={() => {
                        if (userProposalIsWarlordLocked) return;
                        setShowVoteResetWarning(false);
                        setView('browse');
                      }}
                    >
                      CHANGE ANYWAY
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow={1}>
                    <Button fluid icon="times" onClick={() => setShowVoteResetWarning(false)}>CANCEL</Button>
                  </Stack.Item>
                </Stack>
              </Box>
            )}

            {!isWarlord && userProposalIsWarlordLocked ? (
              <Box p={1} style={{
                backgroundColor: 'rgba(30, 100, 30, 0.15)', border: '1px solid #3a8a3a',
                borderRadius: '2px', fontSize: '0.82em', color: '#4db84d', textAlign: 'center',
              }}>
                The warlord has chosen your proposal. It cannot be changed.
              </Box>
            ) : (
              <Button fluid onClick={handleOpenBrowse} disabled={locked} icon="scroll">
                {userProposal ? 'CHANGE PROPOSITION' : 'PROPOSE A TERM'}
              </Button>
            )}

            {!isWarlord && (
              <Button
                fluid
                color={userVoteConfirmed ? 'good' : 'average'}
                icon={userVoteConfirmed ? 'check' : 'lock'}
                onClick={() => {
                  if (!userVote || userVoteConfirmed || locked) return;
                  act('confirm_casus_belli', { proposal_id: userVote });
                }}
                disabled={!userVote || !!userVoteConfirmed || locked}
              >
                {userVoteConfirmed ? 'VOTE CONFIRMED' : 'CONFIRM VOTE'}
              </Button>
            )}

            {isWarlord && (
              <Button
                  fluid
                  color="good"
                  icon="flag"
                  onClick={() => { if (!locked) act('advance_stage'); }}
                  disabled={locked || !warlordCasusBelli}
                >
                  ADVANCE STAGE
              </Button>
            )}

          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
