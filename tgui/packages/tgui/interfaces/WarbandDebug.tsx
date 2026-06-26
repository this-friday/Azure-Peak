import { useState } from 'react';
import { Box, Button, Dropdown, Input, NumberInput, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const ROLES = ['Grunt', 'Lieutenant', 'Warlord'];

export const WarbandDebug = () => {
  const { act, data } = useBackend();
  const {
    members = [],
    active_ckeys = [],
    bypass_rarity = false,
    poll_active = false,
    poll_seconds_left: pollSecondsLeft = 0,
  } = data as any;

  const bypassRarity = !!bypass_rarity;
  const pollActive = !!poll_active;

  const [selectedCkey, setSelectedCkey] = useState('');
  const [ckeyFilter, setCkeyFilter] = useState('');
  const [role, setRole] = useState('Grunt');
  const [pollSize, setPollSize] = useState(5);

  const addedCkeys = new Set(members.map((m) => m.ckey));
  const availableCkeys = active_ckeys.filter((ck) => !addedCkeys.has(ck));
  const filteredCkeys = ckeyFilter
    ? availableCkeys.filter((ck) => ck.includes(ckeyFilter.toLowerCase()))
    : availableCkeys;

  const hasWarlord = members.some((m) => m.role === 'Warlord');
  const canCreate = hasWarlord && !pollActive;

  const handleAdd = () => {
    if (!selectedCkey) return;
    act('add_member', { ckey: selectedCkey, role });
    const remaining = availableCkeys.filter((ck) => ck !== selectedCkey);
    setSelectedCkey(remaining[0] ?? '');
    setCkeyFilter('');
  };

  return (
    <Window title="Create Warband" width={380} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <Input
                    fluid
                    placeholder="Filter players..."
                    value={ckeyFilter}
                    onChange={(v) => {
                      setCkeyFilter(v);
                      if (selectedCkey && !filteredCkeys.includes(selectedCkey)) {
                        setSelectedCkey('');
                      }
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item grow>
                      <Dropdown
                        width="100%"
                        selected={selectedCkey || null}
                        options={filteredCkeys}
                        onSelected={(v) => setSelectedCkey(v)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Dropdown
                        width="110px"
                        selected={role}
                        options={ROLES}
                        onSelected={(v) => setRole(v)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button icon="plus" disabled={!selectedCkey} onClick={handleAdd} />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Box nowrap>Poll size:</Box>
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        value={pollSize}
                        minValue={1}
                        maxValue={50}
                        step={1}
                        width="48px"
                        onChange={(v: number) => setPollSize(v)}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="bullhorn"
                        disabled={pollActive}
                        onClick={() => act('poll_candidates', { poll_size: pollSize })}
                        tooltip="Polls ghosts who have Warband enabled in their antag prefs. You'll be told how many qualify before the poll's sent."
                      >
                        {pollActive ? `POLLING... ${pollSecondsLeft}s` : 'POLL FOR CANDIDATES'}
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow style={{ minHeight: 0 }}>
            <Section fill scrollable title="Members">
              {availableCkeys.length === 0 && members.length === 0 && (
                <Box color="label" italic>
                  No active players found.
                </Box>
              )}

              {members.length === 0 && availableCkeys.length > 0 && (
                <Box color="label" italic>
                  No members added yet.
                </Box>
              )}

              {members.map((m, i) => (
                <Stack key={i} align="center" mb={0.5}>
                  <Stack.Item grow>
                    <Box inline bold>
                      {m.ckey}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Dropdown
                      width="105px"
                      selected={m.role}
                      options={ROLES}
                      onSelected={(v) => act('set_member_role', { index: i + 1, role: v })}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="times"
                      color="transparent"
                      onClick={() => act('remove_member', { index: i + 1 })}
                    />
                  </Stack.Item>
                </Stack>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <Button
                    fluid
                    icon={bypassRarity ? 'unlock' : 'lock'}
                    color={bypassRarity ? 'average' : 'transparent'}
                    onClick={() => act('toggle_bypass_rarity')}
                    tooltip="When enabled, the created warband ignores rarity requirements."
                  >
                    {bypassRarity ? 'RARITY BYPASS: ON' : 'RARITY BYPASS: OFF'}
                  </Button>
                </Stack.Item>
                {!hasWarlord && members.length > 0 && (
                  <Stack.Item>
                    <Box color="bad">A Warlord is required.</Box>
                  </Stack.Item>
                )}
                {pollActive && (
                  <Stack.Item>
                    <Box color="label" italic>
                      A poll is running. Creation is locked.
                    </Box>
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Button
                    fluid
                    icon="flag"
                    color={canCreate ? 'good' : 'grey'}
                    disabled={!canCreate}
                    onClick={() => act('create_warband')}
                  >
                    Create Warband
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
