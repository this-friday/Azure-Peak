import { useMemo, useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';
import { MASK, useTreatyData } from './warband/TreatyData';
import { PartyDisplay } from './warband/TreatyDisplays';
import { PartySelector } from './warband/TreatyPartySelector';
import { ActiveTerm, DraftTerm } from './warband/TreatyTerms';
import { TermType } from './warband/TreatyTypes';

export const TreatyMenu = () => {
  const { data, act, party1, party2, activeTerms, availableTerms, factions } =
    useTreatyData();
  const isExpert = !!data?.is_expert;

  const [draft, setDraft] = useState({
    term: null as TermType | null,
    text: '',
    number: 1,
    custom_name: '',
    target: '',
    receiver: '',
    index: null as number | null,
  });

  const updateDraft = (key: string, val: any) => setDraft((prev) => ({ ...prev, [key]: val }));

  const resetDraft = () =>
    setDraft({
      term: null,
      text: '',
      number: 1,
      custom_name: '',
      target: '',
      receiver: '',
      index: null,
    });

  // only used by the party selector dropdowns
  // the 'factions' on treaties currently just exist as flavor
  const factionOptions = useMemo(
    () =>
      factions.map((f) => ({
        text: f.name,
        value: f.name,
        displayText: f.name,
        icon: f.icon,
      })),
    [factions],
  );

  const isDraftValid = useMemo(() => {
    const { term } = draft;
    if (!term) return true;
    for (const field of term.inputs ?? []) {
      // client_only fields are never submitted
      if (!field.required || field.client_only) continue;
      const val = draft[field.key as keyof typeof draft];
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
  }, [draft]);

  const actions = {
    select: (term: TermType, isEdit = false) =>
      setDraft({
        term,
        index: isEdit ? (term.index ?? null) : null,
        text: term.text || '',
        number: term.number || 1,
        custom_name: term.custom_name || term.name,
        target: term.target || '',
        receiver: term.receiver || '',
      }),

    inscribe: (term: TermType) => {
      const payload: any = {
        index: draft.index,
        name: term.original_name || term.name,
      };
      for (const field of term.inputs ?? []) {
        if (field.client_only) continue;
        payload[field.key] = draft[field.key as keyof typeof draft];
      }
      act(draft.index !== null ? 'edit_term' : 'add_term', payload);
      resetDraft();
    },

    remove: () => {
      if (draft.index !== null) {
        act('remove_term', { index: draft.index });
      }
      resetDraft();
    },

    cancel: resetDraft,

    sign: (term: TermType) => {
      if (term.index !== null) {
        act('sign_term', { index: term.index });
      }
    },
  };

  return (
    <Window theme="treaty" width={950} height={62}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={1} basis={0} order={0}>
            <Stack vertical fill>
              <Stack.Item>
                <Section title="FIRST PARTY">
                  {isExpert ? (
                    <PartySelector
                      act={act}
                      party={party1}
                      partyId={1}
                      factions={factions}
                      options={factionOptions}
                      align="left"
                      isExpert={isExpert}
                    />
                  ) : (
                    <PartyDisplay party={party1} align="left" isExpert={isExpert} />
                  )}
                </Section>
              </Stack.Item>

              <Stack.Item grow={1}>
                <Section title="AVAILABLE TERMS" fill scrollable>
                  {isExpert ? (
                    availableTerms.map((term) => {
                      const handleSelectTerm = () => actions.select(term);
                      return (
                        <Button
                          key={term.name}
                          fluid
                          textAlign="left"
                          mb={0.5}
                          onClick={handleSelectTerm}
                          disabled={!!draft.term}
                          style={{ backgroundColor: '#1a1510', color: '#b1a390' }}
                        >
                          {term.name}
                        </Button>
                      );
                    })
                  ) : (
                    <Box color="label" p={1} textAlign="center">
                      You lack the wisdom to draft new terms.
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow={1} basis={0} order={1}>
            <Stack vertical fill>
              <Stack.Item grow={1}>
                <Section title="ACTIVE TERMS" textAlign="center" fill scrollable>
                  <Box mb={1} textAlign="center" color="label" fontSize="0.8em">
                    Limit: {activeTerms.length}/10
                  </Box>
                  <Stack vertical>
                    {activeTerms.length === 0 && (
                      <Box color="label" textAlign="Center">
                        [NO ACTIVE TERMS]
                      </Box>
                    )}
                    {activeTerms.map((term, index) => {
                      const handleDraftTerm = () => actions.select(term, true);
                      const handleSignTerm = () => actions.sign(term);
                      return (
                        <Box key={term.index || index}>
                          <Box textAlign="center" color="label" fontSize="0.9em" my={0.5}>
                            {index + 1}
                          </Box>
                          <ActiveTerm
                            term={term}
                            onDraft={handleDraftTerm}
                            onSign={handleSignTerm}
                            disabled={!!draft.term}
                            isExpert={isExpert}
                            factions={factions}
                          />
                        </Box>
                      );
                    })}
                  </Stack>
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section title="DRAFT" textAlign="center" style={{ overflow: 'visible' }}>
                  {!isExpert && (
                    <Box color="label" textAlign="center" p={1}>
                      {MASK}
                    </Box>
                  )}
                  {isExpert && !draft.term && (
                    <Box color="label">Click an available or active term to draft it.</Box>
                  )}
                  {isExpert && draft.term && (
                    <DraftTerm
                      term={draft.term}
                      state={draft}
                      updateState={updateDraft}
                      actions={actions}
                      isValid={isDraftValid}
                      isEditing={draft.index !== null}
                      factions={factions}
                    />
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow={1} basis={0} order={2}>
            <Section title="SECOND PARTY" textAlign="right">
              {isExpert ? (
                <PartySelector
                  act={act}
                  party={party2}
                  partyId={2}
                  factions={factions}
                  options={factionOptions}
                  align="right"
                  isExpert={isExpert}
                />
              ) : (
                <PartyDisplay party={party2} align="right" isExpert={isExpert} />
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
