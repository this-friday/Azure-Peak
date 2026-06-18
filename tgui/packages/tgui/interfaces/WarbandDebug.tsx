import { useState } from 'react';
import { Box, Button, Dropdown, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const ROLES = ['Grunt', 'Lieutenant', "Warlord"];

const ROLE_COLOR = {
  Warlord: 'red',
  Lieutenant: 'average',
  Grunt: 'label',
};

export const WarbandDebug = (props) => {
  const { act, data } = useBackend();
  const { members = [], active_ckeys = [], bypass_rarity: bypassRarity = false } = data as any;

  const [selectedCkey, setSelectedCkey] = useState('');
  const [ckeyFilter, setCkeyFilter] = useState('');
  const [role, setRole] = useState('Grunt');

  const addedCkeys = new Set(members.map((m) => m.ckey));
  const availableCkeys = active_ckeys.filter((ck) => !addedCkeys.has(ck));
  const filteredCkeys = ckeyFilter
    ? availableCkeys.filter((ck) => ck.includes(ckeyFilter.toLowerCase()))
    : availableCkeys;

  const hasWarlord = members.some((m) => m.role === 'Warlord');
  const canCreate = hasWarlord;

  const handleAdd = () => {
    if (!selectedCkey) return;
    act('add_member', { ckey: selectedCkey, role });
    const remaining = availableCkeys.filter((ck) => ck !== selectedCkey);
    setSelectedCkey(remaining[0] ?? '');
    setCkeyFilter('');
  };

  return (
    <Window title="Create Warband" width={360} height={Math.min(280 + members.length * 26, 560)}>
      <Window.Content>
        <Section>
          <Stack vertical fill>
            <Stack align="center">
              <Stack.Item grow>
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
            </Stack>
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
                <Button
                  icon="plus"
                  disabled={!selectedCkey}
                  onClick={handleAdd}
                />
              </Stack.Item>
            </Stack>

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

            <Box style={{ maxHeight: '260px', overflowY: 'auto' }}>
              {members.map((m, i) => (
                <Stack key={i} align="center">
                  <Stack.Item grow>
                    <Box inline bold>
                      {m.ckey}
                    </Box>
                    <Box inline color={ROLE_COLOR[m.role]} ml={1}>
                      {m.role}
                    </Box>
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
            </Box>

            <Stack.Divider />

            <Button
              fluid
              icon={bypassRarity ? 'unlock' : 'lock'}
              color={bypassRarity ? 'average' : 'transparent'}
              onClick={() => act('toggle_bypass_rarity')}
              tooltip="When enabled, the created warband ignores storyteller rarity requirements."
            >
              {bypassRarity ? 'RARITY BYPASS: ON' : 'RARITY BYPASS: OFF'}
            </Button>

            {!hasWarlord && members.length > 0 && (
              <Box color="bad">A Warlord is required.</Box>
            )}
            <Button
              fluid
              icon="flag"
              color={canCreate ? 'good' : 'grey'}
              disabled={!canCreate}
              onClick={() => act('create_warband')}
            >
              Create Warband
            </Button>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
