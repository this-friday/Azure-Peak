import { useMemo } from 'react';
import { Box, Dropdown, Input, NumberInput, TextArea } from 'tgui-core/components';

import { sanitize } from './TreatyData';
import { FactionType, InfoBlock, InputFieldDescriptor } from './TreatyTypes';

const FieldWrapper = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <Box mt={1}>
    {label && <Box color="label" mb={0.5}>{label}</Box>}
    {children}
  </Box>
);

const TextInputWidget = ({
  field,
  state,
  onChange,
}: {
  field: InputFieldDescriptor;
  state: any;
  onChange: (val: string) => void;
}) => (
  <FieldWrapper label={field.label}>
    <Input
      fluid
      value={state[field.key] ?? ''}
      onChange={(val) => onChange(sanitize(val, 'name'))}
      placeholder={field.placeholder}
    />
  </FieldWrapper>
);

const TextAreaWidget = ({
  field,
  state,
  onChange,
}: {
  field: InputFieldDescriptor;
  state: any;
  onChange: (val: string) => void;
}) => (
  <FieldWrapper label={field.label}>
    <TextArea
      fluid
      height="100px"
      value={state[field.key] ?? ''}
      onChange={(val) => onChange(sanitize(val, 'text'))}
      placeholder={field.placeholder}
    />
  </FieldWrapper>
);

const NumberWidget = ({
  field,
  state,
  onChange,
}: {
  field: InputFieldDescriptor;
  state: any;
  onChange: (val: number) => void;
}) => (
  <FieldWrapper label={field.label}>
    <NumberInput
      fluid
      value={state[field.key] ?? field.min_value ?? 1}
      onChange={onChange}
      minValue={field.min_value ?? 1}
      maxValue={field.max_value ?? 999999}
      step={field.step ?? 1}
    />
  </FieldWrapper>
);

const FactionDropdownWidget = ({
  field,
  state,
  onChange,
  factions,
}: {
  field: InputFieldDescriptor;
  state: any;
  onChange: (val: string) => void;
  factions: FactionType[];
}) => {
  const excludeVal = field.exclude_key ? state[field.exclude_key] : null;

  const options = useMemo(
    () =>
      factions
        .filter((f) => !excludeVal || f.name !== excludeVal)
        .map((f) => ({ text: f.name, value: f.name, displayText: f.name, icon: f.icon })),
    [factions, excludeVal],
  );

  return (
    <FieldWrapper label={field.label}>
      <Dropdown
        fluid
        options={options}
        selected={state[field.key]}
        onSelected={onChange}
        placeholder={field.placeholder ?? 'Select Faction...'}
      />
    </FieldWrapper>
  );
};

const DisplayWidget = ({
  field,
  state,
}: {
  field: InputFieldDescriptor;
  state: any;
}) => {
  const watchedValue = field.display_key ? state[field.display_key] : undefined;
  const blocks: InfoBlock[] | undefined = watchedValue && field.content_map
    ? field.content_map[watchedValue]
    : undefined;

  if (!blocks?.length) {
    return field.placeholder ? (
      <Box mt={1} color="label" fontSize="0.85em">
        {field.placeholder}
      </Box>
    ) : null;
  }

  return (
    <Box mt={1} textAlign="left">
      {blocks.map((block, i) => (
        <Box
          key={i}
          mt={i > 0 ? 0.5 : 0}
          p={1}
          style={{
            backgroundColor: 'rgba(0,0,0,0.3)',
            border: '1px solid #3a3228',
            fontSize: '0.85em',
            color: '#b1a390',
            wordBreak: 'break-word',
          }}
        >
          {block.label && (
            <Box bold color="#e9ca9e" mb={0.5}>
              {block.label}
            </Box>
          )}
          {block.text && (
            <Box style={{ whiteSpace: 'pre-wrap' }}>
              {block.text}
            </Box>
          )}
        </Box>
      ))}
    </Box>
  );
};

// iterates term.inputs and renders the correct widget for each descriptor
export const DynamicInputs = ({
  inputs,
  state,
  updateState,
  factions,
}: {
  inputs: InputFieldDescriptor[];
  state: any;
  updateState: (key: string, val: any) => void;
  factions: FactionType[];
}) => {
  return (
    <>
      {inputs.map((field) => {
        const handleChange = (val: any) => {
          updateState(field.key, val);
          for (const clearKey of field.clears_keys ?? []) {
            updateState(clearKey, '');
          }
        };

        switch (field.widget) {
          case 'text_input':
            return (
              <TextInputWidget key={field.key} field={field} state={state} onChange={handleChange} />
            );
          case 'textarea':
            return (
              <TextAreaWidget key={field.key} field={field} state={state} onChange={handleChange} />
            );
          case 'number_input':
            return (
              <NumberWidget key={field.key} field={field} state={state} onChange={handleChange} />
            );
          case 'option_dropdown':
            return (
              <FieldWrapper key={field.key} label={field.label}>
                <Dropdown
                  fluid
                  options={(field.options ?? []).map((o) => ({
                    value: o,
                    displayText: o,
                  }))}
                  selected={state[field.key]}
                  onSelected={handleChange}
                  placeholder={field.placeholder ?? 'Select...'}
                />
              </FieldWrapper>
            );
          case 'faction_dropdown':
            return (
              <FactionDropdownWidget
                key={field.key}
                field={field}
                state={state}
                onChange={handleChange}
                factions={factions}
              />
            );
          case 'display':
            return (
              <DisplayWidget key={field.key} field={field} state={state} />
            );
          default:
            return null;
        }
      })}
    </>
  );
};
