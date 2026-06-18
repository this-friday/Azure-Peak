import { useEffect, useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { AspectType, ClassType, NobleType, SubType, WarbandType } from './WarbandTypes';

type FinalizeTabProps = {
  selectedWarband: WarbandType | null;
  selectedSubtype: SubType | null;
  selectedAspects: AspectType[];
  selectedClass: ClassType | null;
  selectedSubclass: ClassType | null;
  finalize_disabled: boolean;
  pointCounter: number;
  act: (action: string, payload?: object) => void;
  canFinalize?: boolean;
  canInteract?: boolean;
  isWarlord?: boolean;
  alliesList: NobleType[];
  userReady: boolean;
  warlordSpawned?: boolean;
  userRace?: string;
  userPatron?: string;
  userRaceName?: string;
  userPatronName?: string;
  selectedWarbandType?: string;
  selectedSubtypeType?: string;
  selectedAspectTypes?: string[];
  selectedClassType?: string;
  selectedSubclassType?: string;
  managerFaithlocks?: string[];
  managerFaithNames?: string[];
  managerRacelocks?: string[];
  managerRaceNames?: string[];
};

export const FinalizeTab = ({
  selectedWarband,
  selectedSubtype,
  selectedAspects,
  selectedClass,
  selectedSubclass,
  finalize_disabled,
  pointCounter,
  act,
  canFinalize = true,
  canInteract = true,
  isWarlord = false,
  alliesList,
  userReady,
  warlordSpawned = false,
  userRace = '',
  userPatron = '',
  userRaceName = '',
  userPatronName = '',
  selectedWarbandType,
  selectedSubtypeType,
  selectedAspectTypes = [],
  selectedClassType,
  selectedSubclassType,
  managerFaithlocks = [],
  managerFaithNames = [],
  managerRacelocks = [],
  managerRaceNames = [],
}: FinalizeTabProps) => {

  const [lockWarnings, setLockWarnings] = useState<string[]>([]);
  const [hasLockIssue, setHasLockIssue] = useState(false);
  const [hasReadyIssue, setHasReadyIssue] = useState(false);
  const [confirmEnabled, setConfirmEnabled] = useState(false);

  useEffect(() => {
    act('refresh');
  }, []);

  useEffect(() => {
    if (lockWarnings.length === 0) { setConfirmEnabled(false); return; }
    setConfirmEnabled(false);
    const t = setTimeout(() => setConfirmEnabled(true), 1500);
    return () => clearTimeout(t);
  }, [lockWarnings.length]);

  const buildLockWarnings = (): string[] => {
    if (selectedClass?.ignore_locks) return [];
    const warnings: string[] = [];

    if (managerFaithlocks.length > 0 && userPatron && !managerFaithlocks.some(f => f === userPatron)) {
      warnings.push(
        `Your patron (${userPatronName}) does not meet the warband's faith requirement. Required: ${managerFaithNames.join(', ') || 'unknown'}.`
      );
    }

    if (managerRacelocks.length > 0 && userRace && !managerRacelocks.some(r => r === userRace)) {
      warnings.push(
        `Your race (${userRaceName}) does not meet the warband's race requirement. Required: ${managerRaceNames.join(', ') || 'unknown'}.`
      );
    }
    return warnings;
  };

  const confirmReady = () => {
    if (isWarlord) {
      act('create_warband', all_selections);
    } else if (warlordSpawned) {
      act('create_character', all_selections);
    } else {
      act('toggle_ready', all_selections);
    }
    act('interaction_sound');
    setLockWarnings([]);
    setHasLockIssue(false);
    setHasReadyIssue(false);
  };

  const checkAndJoin = () => {
    const warnings = buildLockWarnings();
    if (warnings.length > 0) {
      setLockWarnings(warnings);
      setHasLockIssue(true);
      setHasReadyIssue(false);
    } else {
      confirmReady();
    }
  };

  const dismissWarning = () => {
    setLockWarnings([]);
    setHasLockIssue(false);
    setHasReadyIssue(false);
  };

  const checkLocksAndReady = () => {
    if (userReady) { act('toggle_ready', {}); act('interaction_sound'); return; }
    const warnings = buildLockWarnings();
    if (warnings.length > 0) {
      setLockWarnings(warnings);
      setHasLockIssue(true);
      setHasReadyIssue(false);
    } else {
      confirmReady();
    }
  };

  const checkAndFinalize = () => {
    const warnings = buildLockWarnings();
    const lockIssue = warnings.length > 0;
    const unreadyMembers = lobbyMembers.filter(m => !m.is_ready && m.job !== 'Warlord' && m.special_role !== 'Warlord');
    const readyIssue = unreadyMembers.length > 0;
    if (readyIssue) {
      const names = unreadyMembers.map(m => m.name || (m.job === 'Aspirant Lieutenant' ? 'Lieutenant' : m.job)).join(', ');
      warnings.push(`${unreadyMembers.length} lobby member${unreadyMembers.length !== 1 ? 's are' : ' is'} not yet ready (${names}). They won't spawn automatically. Continue?`);
    }
    if (warnings.length > 0) {
      setLockWarnings(warnings);
      setHasLockIssue(lockIssue);
      setHasReadyIssue(readyIssue);
    } else {
      confirmReady();
    }
  };

  const disableReason = () => {
    if (!canInteract) return "RETURN TO CLASSES TAB";
    if (!canFinalize && !isWarlord) return "AWAITING WARLORD TO FINALIZE WARBAND";
    if (!finalize_disabled) return null;
    if (pointCounter < 0) return "MUST HAVE 0 OR MORE ASPECT POINTS REMAINING";
    if (!selectedWarband) return "NO WARBAND SELECTED";
    if (selectedWarband?.subtyperequired && !selectedSubtype) return "WARBAND REQUIRES A SELECTED SUBTYPE";
    if (!selectedClass) return "NO CLASS SELECTED";
    if (selectedWarband?.universal_subclasses_enabled && selectedWarband?.subclass_required && !selectedClass?.ignores_uni_class_requirement && !selectedSubclass) {
      return `${(selectedWarband.subclass_label || 'SUBCLASS').toUpperCase()} REQUIRED`;
    }
    return null;
  };

  const warlordActuallyDisabled = !canInteract || finalize_disabled || !canFinalize;
  const readyDisabled = !canInteract || (!userReady && finalize_disabled);

  const lobbyMembers = alliesList.filter(a => a.in_lobby);
  const fieldMembers = alliesList.filter(a => !a.in_lobby);

  const all_selections = {
    warband: selectedWarbandType,
    subtype: selectedSubtypeType,
    aspects: selectedAspectTypes,
    class: selectedClassType,
    subclass: selectedSubclassType,
  };

  return (
    <Stack style={{ flex: 1, flexDirection: 'column', height: '100%', position: 'relative' }}>

      {lockWarnings.length > 0 && (
        <Box style={{
          position: 'absolute', inset: 0, zIndex: 100,
          backgroundColor: 'rgba(0,0,0,0.82)',
          display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
          padding: '32px',
        }}>
          <Box style={{
            backgroundColor: '#1a0505',
            border: '2px solid #7a2525',
            padding: '24px 32px',
            maxWidth: '520px',
            width: '100%',
          }}>
            <Box bold style={{ color: '#d46060', fontSize: '16px', letterSpacing: '0.1em', marginBottom: '16px' }}>
              ⚠ WARBAND RESTRICTION WARNING
            </Box>
            {lockWarnings.map((w, i) => (
              <Box key={i} mb={1} p={1} style={{
                backgroundColor: 'rgba(122,37,37,0.25)',
                border: '1px solid #5a2020',
                color: '#c8bfb0',
                fontSize: '13px',
                lineHeight: '1.5',
              }}>
                {w}
              </Box>
            ))}
            {hasLockIssue && (
              <Box mt={1} style={{ color: '#8a8070', fontSize: '12px', fontStyle: 'italic' }}>
                You may still ready up, in which case the game will auto-correct your character as you join.
              </Box>
            )}
            {hasReadyIssue && (
              <Box mt={1} style={{ color: '#8a8070', fontSize: '12px', fontStyle: 'italic' }}>
                Members who have not readied up will not spawn automatically when you finalize. You can still proceed without them.
              </Box>
            )}
            <Stack mt={2} direction="row" justify="center">
              <Button
                onClick={confirmReady}
                disabled={!confirmEnabled}
                style={{ flex: 1, backgroundColor: confirmEnabled ? '#5a1010' : undefined, borderColor: '#7a2525', padding: '10px' }}
              >
                {confirmEnabled ? 'PROCEED ANYWAY' : '...'}
              </Button>
              <Button
                onClick={dismissWarning}
                style={{ flex: 1, padding: '10px' }}
              >
                GO BACK
              </Button>
            </Stack>
          </Box>
        </Box>
      )}
      <Stack direction="row" style={{ flex: 1, minHeight: 0 }}>

        <Section
          title={<span style={{ color: '#7a2525ff' }}>FINAL SUMMARY</span>}
          scrollable fill
          style={{ flex: 3 }}
        >
          {selectedWarband && (
            <Box mb={1}>
              <Box bold style={{ color: '#ae3636', fontSize: '13px', letterSpacing: '0.08em' }}>WARBAND</Box>
              <Box ml={2} mt={0.5}>
                <Box bold style={{ color: '#ae3636' }}>{selectedWarband.title}</Box>
                <Box>{selectedWarband.summary}</Box>
              </Box>
            </Box>
          )}
          {selectedSubtype && (
            <Box mb={1}>
              <Box bold style={{ color: '#ae3636', fontSize: '13px', letterSpacing: '0.08em' }}>SUBTYPE</Box>
              <Box ml={2} mt={0.5}>
                <Box bold style={{ color: '#ae3636' }}>{selectedSubtype.title}</Box>
                <Box>{selectedSubtype.summary}</Box>
              </Box>
            </Box>
          )}
          {selectedAspects.length > 0 && (
            <Box mb={1}>
              <Box bold style={{ color: '#ae3636', fontSize: '13px', letterSpacing: '0.08em' }}>ASPECTS</Box>
              <Box ml={2} mt={0.5}>
                {selectedAspects.map((aspect) => (
                  <Box key={aspect.title} mb={1}>
                    <Box bold style={{ color: '#ae3636' }}>{aspect.title}</Box>
                    <Box>{aspect.summary}</Box>
                  </Box>
                ))}
              </Box>
            </Box>
          )}
          {selectedClass && (
            <Box mb={1}>
              <Box bold style={{ color: '#ae3636', fontSize: '13px', letterSpacing: '0.08em' }}>SELECTED CLASS</Box>
              <Box ml={2} mt={0.5}>
                <Box bold style={{ color: '#ae3636' }}>{selectedClass.name}</Box>
                <Box>{selectedClass.desc}</Box>
              </Box>
            </Box>
          )}
        </Section>

        <Section
          title={<span style={{ color: '#7a2525ff' }}>LOBBY</span>}
          scrollable fill
          style={{ flex: 2 }}
        >
          {(lobbyMembers.length > 0 || fieldMembers.length > 0) ? (
            <Stack vertical>
              {lobbyMembers.map((ally, index) => {
                const isReady = ally.is_ready;
                const displayRole = ally.job === 'Aspirant Lieutenant' ? 'Lieutenant' : ally.job;
                return (
                  <Box
                    key={`${ally.name}-${index}`}
                    p={1}
                    onClick={() => {
                      if (!ally.ref) return;
                      act('view_member', { ref: ally.ref });
                      act('interaction_sound');
                    }}
                    style={{
                      backgroundColor: isReady ? 'rgba(20,60,20,0.4)' : 'rgba(60,10,10,0.3)',
                      border: `1px solid ${isReady ? '#3a6a3a' : '#5a2020'}`,
                      marginBottom: '4px',
                      cursor: ally.ref ? 'pointer' : undefined,
                    }}
                  >
                    <Stack align="center" justify="space-between">
                      <Stack.Item grow={1}>
                        <Box bold style={{ color: isReady ? '#7fc97f' : '#d46060' }}>
                          {ally.name}
                        </Box>
                        <Box style={{ fontSize: '12px', color: '#9a8878' }}>
                          {ally.special_role && ally.special_role !== ally.job
                            ? `${ally.special_role} — ${displayRole}`
                            : displayRole}
                        </Box>
                        {!!ally.ready_class && (
                          <Box style={{ fontSize: '12px', color: '#c9a347' }}>
                            {ally.ready_class}
                            {!!ally.ready_subclass && ` / ${ally.ready_subclass}`}
                          </Box>
                        )}
                      </Stack.Item>
                      <Stack.Item>
                        <Box
                          bold
                          style={{
                            fontSize: '12px',
                            letterSpacing: '0.1em',
                            color: isReady ? '#4db84d' : '#7a2525',
                          }}
                        >
                          {isReady ? '✓ READY' : '— WAITING'}
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })}
              {fieldMembers.map((ally, index) => {
                const displayRole = ally.special_role === 'Aspirant Lieutenant' ? 'Lieutenant' : (ally.special_role || ally.job);
                return (
                  <Box
                    key={`field-${ally.name}-${index}`}
                    p={1}
                    onClick={() => {
                      if (!ally.ref) return;
                      act('view_member', { ref: ally.ref });
                      act('interaction_sound');
                    }}
                    style={{
                      backgroundColor: 'rgba(30,30,40,0.35)',
                      border: '1px solid #3a3a50',
                      marginBottom: '4px',
                      cursor: ally.ref ? 'pointer' : undefined,
                    }}
                  >
                    <Stack align="center" justify="space-between">
                      <Stack.Item grow={1}>
                        <Box bold style={{ color: '#9aa6c0' }}>
                          {ally.name}
                        </Box>
                        <Box style={{ fontSize: '12px', color: '#9a8878' }}>
                          {displayRole !== ally.job ? `${displayRole} — ${ally.job}` : ally.job}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box
                          bold
                          style={{
                            fontSize: '12px',
                            letterSpacing: '0.1em',
                            color: '#7a8aa5',
                          }}
                        >
                          ⚔ IN THE FIELD
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })}
            </Stack>
          ) : (
            <Box style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
              <Box style={{ color: '#7a2525ff' }}>NO OTHER MEMBERS IN LOBBY</Box>
            </Box>
          )}
        </Section>

      </Stack>

      <Section style={{ flex: 0, flexBasis: 'auto' }}>
        <Stack direction="row" justify="center">
          {isWarlord ? (
            <>
              {warlordActuallyDisabled && (
                <span style={{
                  flex: 1, color: '#ae3636', fontSize: '15px', padding: '25px',
                  display: 'flex', marginBottom: '110px', justifyContent: 'center', alignItems: 'center',
                }}>
                  {disableReason()}
                </span>
              )}
              <Button
                onClick={checkAndFinalize}
                disabled={warlordActuallyDisabled}
                style={{
                  flex: 1, fontSize: '25px', padding: '25px', display: 'flex',
                  marginBottom: '110px', justifyContent: 'center', alignItems: 'center',
                }}
              >
                FINALIZE WARBAND & SPAWN
              </Button>
            </>
          ) : warlordSpawned ? (
            <Button
              onClick={checkAndJoin}
              disabled={!canInteract || finalize_disabled}
              style={{
                flex: 1, fontSize: '25px', padding: '25px', display: 'flex',
                marginBottom: '110px', justifyContent: 'center', alignItems: 'center',
              }}
            >
              JOIN GAME
            </Button>
          ) : (
            <>
              {readyDisabled && !userReady && (
                <span style={{
                  flex: 1, color: '#ae3636', fontSize: '15px', padding: '25px',
                  display: 'flex', marginBottom: '110px', justifyContent: 'center', alignItems: 'center',
                }}>
                  {disableReason()}
                </span>
              )}
              <Button
                onClick={() => {
                  checkLocksAndReady();
                }}
                disabled={readyDisabled}
                style={{
                  flex: 1, fontSize: '25px', padding: '25px', display: 'flex',
                  marginBottom: '110px', justifyContent: 'center', alignItems: 'center',
                  backgroundColor: userReady ? '#1a4a1a' : undefined,
                  borderColor: userReady ? '#3a6a3a' : undefined,
                }}
              >
                {userReady ? '✓ READY — CLICK TO UNREADY' : 'MARK READY'}
              </Button>
            </>
          )}
        </Stack>
      </Section>
    </Stack>
  );
};
