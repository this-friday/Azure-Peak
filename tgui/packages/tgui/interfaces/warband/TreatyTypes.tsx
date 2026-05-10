export type FactionType = {
  name: string;
  desc: string;
  type: string;
  icon: string;
  vault: number;
  owner?: string;
  job_owner?: string;
}

export type InputFieldDescriptor = {
  key: string;
  widget: 'text_input' | 'textarea' | 'number_input' | 'faction_dropdown' | 'option_dropdown' | 'display';
  label: string;
  placeholder?: string;
  required?: boolean;
  client_only?: boolean;
  clears_keys?: string[];
  min_length?: number;
  max_length?: number;
  min_value?: number;
  max_value?: number;
  step?: number;
  options?: string[];
  exclude_key?: string;
  display_key?: string;
  content_map?: Record<string, InfoBlock[]>;
}

export type DisplayField = {
  label: string;
  key: string;
}

export type InfoBlock = {
  label: string;
  text: string;
}

export type TermType = {
  name: string;
  custom_name?: string;
  desc: string;
  hint: string;
  text?: string;
  original_name?: string;
  signed?: boolean;
  number?: number;
  index?: number;
  target?: string;
  receiver?: string;
  obj_target?: string;
  authorities?: string[];
  signatures?: string[];
  minimum_signatures?: number;
  signature_weight_total?: number;
  open_signatures?: boolean;
  inputs?: InputFieldDescriptor[];
  display_fields?: DisplayField[];
  info_blocks?: InfoBlock[];
}

export type Data = {
  user_role?: string;
  is_expert?: boolean;
  firstparty?: FactionType;
  secondparty?: FactionType;
  terms?: TermType[];
  all_terms?: TermType[];
  backend_factions?: FactionType[];
};
