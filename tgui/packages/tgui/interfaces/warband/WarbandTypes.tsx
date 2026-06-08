export type WarbandDatumBase = {
  title: string;
  summary: string;
  desc?: string;
  storyinfluence?: string;
  rarity: number;
  points: number;
  type: string;
  warlordclasses: string[];
  lieuclasses: string[];
  gruntclasses: string[];
  faithlock?: string[];
  faithlock_names?: string[];
  racelock?: string[];
  racelock_names?: string[];
  inputs?: import('./TreatyTypes').InputFieldDescriptor[];
  selection_inputs?: Record<string, any>;
  suppressed_classes?: string[];
  replaces_primaries?: boolean;
  rarity_locked?: boolean;
};

export type WarbandType = WarbandDatumBase & {
  subtyperequired: boolean;
  subtypes: string[][];
  aspects: string[];
  multiclass_enabled: boolean;
  subclass_required: boolean;
  subclass_label?: string;
};

export type SubType = WarbandDatumBase & {
  aspects: string[];
  quote?: string;
  quote_followup?: string;
};

export type AspectType = WarbandDatumBase & {
  class: string | null;
  max_intensity?: number;
  intensity_costs?: number[];
  intensity?: number;
};

export type ClassType = {
  name: string;
  desc: string;
  alt_name: string;
  storyinfluence?: string;
  rarity: number;
  slots: number;
  type: string;
  multiclass_capable: boolean;
  ignore_locks?: boolean;
  ignores_multiclass_requirement?: boolean;
  classes?: string[];
};

export type StorytellerType = {
  title: string;
  summary: string;
  type: string;
};

export type NobleType = {
  name: string;
  job: string;
  special_role?: string;
  in_lobby?: boolean;
  is_ready?: boolean;
};

export type CasusBelliTerm = {
  name: string;
  desc: string;
  hint?: string;
  open_signatures: boolean;
  inputs?: import('./TreatyTypes').InputFieldDescriptor[];
  display_fields?: import('./TreatyTypes').DisplayField[];
  type: string;
  warbandlock?: string;
  custom_name?: string;
  text?: string;
  number?: number;
  target?: string;
  receiver?: string;
  obj_target?: string;
};

export type CasusBelliProposal = {
  proposal_id: string;
  term_type: string;
  term_name: string;
  term_desc: string;
  vote_count: number;
  pending_count: number;
  is_user_proposal: boolean;
  is_user_vote: boolean;
  is_user_vote_confirmed: boolean;
  is_warlord_selected: boolean;
  term_custom_name?: string;
  term_text?: string;
  term_number?: number;
  term_target?: string;
  term_receiver?: string;
  term_obj_target?: string;
};

export type Data = {
  user_role?: string;
  finalized_status?: boolean;
  creation_stage: number;
  warlord_spawned: boolean;
  is_warlord: boolean;
  time_remaining: number;
  timer_active: boolean;
  lobby_chat_muted: boolean;
  lobby_mute_remaining: number;
  warbands?: WarbandType[];
  subtypes?: SubType[];
  aspects?: AspectType[];
  classes?: ClassType[];
  backendstorytellers?: StorytellerType[];
  backend_warband?: WarbandType[];
  backend_subtype?: SubType[];
  backend_aspects?: AspectType[];
  nobles?: NobleType[];
  allies?: NobleType[];
  all_terms?: CasusBelliTerm[];
  casus_belli_proposals?: CasusBelliProposal[];
  user_proposal?: string | null;
  user_vote?: string | null;
  user_vote_confirmed?: boolean;
  warlord_selected_proposal?: string | null;
  warlord_casus_belli?: CasusBelliTerm | null;
  backend_factions?: any[];
  user_ready?: boolean;
  user_race?: string;
  user_patron?: string;
  user_race_name?: string;
  user_patron_name?: string;
  manager_faithlocks?: string[];
  manager_faithlock_names?: string[];
  manager_racelocks?: string[];
  manager_racelock_names?: string[];
  bypass_rarity?: boolean;
};
