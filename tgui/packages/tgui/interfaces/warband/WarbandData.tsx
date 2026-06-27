import { useBackend } from '../../backend';
import { Data } from './WarbandTypes';

export const useWarbandData = () => {
  const { data, act } = useBackend<Data>();
  const user_role = data?.user_role;
  const finalized_status = data?.finalized_status;
  const backend_warband = data?.backend_warband || [];
  const backend_subtype = data?.backend_subtype || [];
  const backend_aspects = data?.backend_aspects || [];

  const creation_stage = data?.creation_stage || 1;
  const warlord_spawned = data?.warlord_spawned || false;
  const is_warlord = data?.is_warlord || false;
  const user_ready = data?.user_ready || false;
  const user_race = data?.user_race || '';
  const user_patron = data?.user_patron || '';
  const user_race_name = data?.user_race_name || '';
  const user_patron_name = data?.user_patron_name || '';
  const manager_faithlocks = data?.manager_faithlocks || [];
  const manager_faithlock_names = data?.manager_faithlock_names || [];
  const manager_racelocks = data?.manager_racelocks || [];
  const manager_racelock_names = data?.manager_racelock_names || [];
  const bypass_rarity = data?.bypass_rarity || false;
  const class_slot_counts = data?.class_slot_counts || {};
  
  const time_remaining = data?.time_remaining || 0;
  const timer_active = data?.timer_active || false;
  const lobby_chat_muted = data?.lobby_chat_muted || false;
  const lobby_mute_remaining = data?.lobby_mute_remaining || 0;

  const warbandList = finalized_status ? backend_warband : (data?.warbands || []);
  const subtypeList = finalized_status ? backend_subtype : (data?.subtypes || []);
  const aspectList = finalized_status ? backend_aspects : (data?.aspects || []);
  const classList = data?.classes || [];
  const patronsList = data?.backendpatrons || [];

  const nobleList = data?.nobles || [];
  const alliesList = data?.allies || [];

  // casus belli
  const allTerms = data?.all_terms || [];
  const casusBelliProposals = data?.casus_belli_proposals || [];
  const userProposal = data?.user_proposal ?? null;
  const userVote = data?.user_vote ?? null;
  const userVoteConfirmed = data?.user_vote_confirmed || false;
  const warlordSelectedProposal = data?.warlord_selected_proposal ?? null;
  const warlordCasusBelli = data?.warlord_casus_belli ?? null;
  const factions = data?.backend_factions || [];

  return {
    user_role,
    act,
    warbandList,
    subtypeList,
    aspectList,
    classList,
    patronsList,
    alliesList,
    nobleList,
    backend_warband,
    creation_stage,
    warlord_spawned,
    is_warlord,
    user_ready,
    user_race,
    user_patron,
    user_race_name,
    user_patron_name,
    manager_faithlocks,
    manager_faithlock_names,
    manager_racelocks,
    manager_racelock_names,
    bypass_rarity,
    class_slot_counts,
    time_remaining,
    timer_active,
    lobby_chat_muted,
    lobby_mute_remaining,
    allTerms,
    casusBelliProposals,
    userProposal,
    userVote,
    userVoteConfirmed,
    warlordSelectedProposal,
    warlordCasusBelli,
    factions,
  };
};
