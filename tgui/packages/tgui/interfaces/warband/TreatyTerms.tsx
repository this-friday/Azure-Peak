import { useState } from 'react';
import { Box, Button, Stack } from 'tgui-core/components';

import { MASK } from './TreatyData';
import { WrapBox } from './TreatyDisplays';
import { DynamicInputs } from './TreatyInputs';
import { SignatureDisplay } from './TreatySignatures';
import { DisplayField, FactionType, InfoBlock, TermType } from './TreatyTypes';

// active terms
export const ActiveTerm = ({
  term,
  onDraft,
  onSign,
  disabled,
  isExpert,
  factions,
}: {
  term: TermType;
  onDraft: () => void;
  onSign: () => void;
  disabled: boolean;
  isExpert: boolean;
  factions: FactionType[];
}) => {
  const [showOpts, setShowOpts] = useState(false);

  const signatures = term.signatures || [];
  const minSigs = term.minimum_signatures || 0;
  const weightTotal = term.signature_weight_total ?? signatures.length;
  const isUnsigned = !term.open_signatures && weightTotal < minSigs;
  const signedSet = new Set(signatures.map((n) => n.toLowerCase()));

  const handleToggleOptions = () => setShowOpts(!showOpts);

  const handleDraftClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    onDraft();
    setShowOpts(false);
  };

  const handleSignClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    onSign();
    setShowOpts(false);
  };

  return (
    <Button
      fluid
      textAlign="left"
      className="Section"
      p={1}
      onClick={handleToggleOptions}
      disabled={disabled}
      style={{
        backgroundColor: 'rgba(14, 10, 10, 0.5)',
        flexDirection: 'column',
        height: 'auto',
        minWidth: 0,
        position: 'relative',
        marginLeft: '8px',
      }}
    >
      <Box width="100%">
        <Box
          bold
          color="#e9ca9e"
          style={{ overflowWrap: 'break-word', whiteSpace: 'normal' }}
        >
          {term.name}
        </Box>
        <Box
          mt={0.5}
          fontSize="0.9em"
          color="#b1a390"
          style={{ overflowWrap: 'break-word', whiteSpace: 'normal' }}
        >
          {term.desc}
        </Box>

        {term.text && (
          <Box
            mt={0.5}
            p={1}
            style={{
              backgroundColor: 'rgba(0,0,0,0.3)',
              whiteSpace: 'pre-wrap',
              maxHeight: '150px',
              overflowY: 'auto',
              wordBreak: 'break-word',
            }}
          >
            {isExpert ? term.text : MASK}
          </Box>
        )}

        {!!(term.display_fields?.length) && (
          <Box mt={0.5} color="average" style={{ width: '100%' }}>
            {term.display_fields.map((field: DisplayField) => (
              <WrapBox
                key={field.key}
                label={field.label}
                value={isExpert ? String((term as any)[field.key] ?? '') : MASK}
              />
            ))}
          </Box>
        )}

        {!!(term.info_blocks?.length) && (
          <Box mt={0.5}>
            {term.info_blocks.map((block: InfoBlock, i: number) => (
              <Box
                key={i}
                mt={i > 0 ? 0.5 : 0}
                p={1}
                style={{
                  backgroundColor: 'rgba(0,0,0,0.3)',
                  border: '1px solid #3a3228',
                  whiteSpace: 'pre-wrap',
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
                {block.text}
              </Box>
            ))}
          </Box>
        )}

        <SignatureDisplay
          term={term}
          signatures={signatures}
          minSigs={minSigs}
          isUnsigned={isUnsigned}
          signedSet={signedSet}
          factions={factions}
        />

        <Box mt={1} bold color={term.signed ? 'good' : 'bad'}>
          {term.signed
            ? 'SIGNED'
            : term.open_signatures && signatures.length > 0
              ? 'PARTIALLY SIGNED'
              : 'NOT SIGNED'}
        </Box>
      </Box>

      {showOpts && (
        <Stack mt={0.5} width="100%">
          <Stack.Item>
            <Button
              fluid
              icon="pen"
              color="average"
              disabled={!isExpert}
              onClick={handleDraftClick}
            >
              DRAFT
            </Button>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Button
              fluid
              icon="check"
              color="good"
              onClick={handleSignClick}
              disabled={term.signed}
            >
              {term.signed ? 'SIGNED' : 'SIGN'}
            </Button>
          </Stack.Item>
        </Stack>
      )}
    </Button>
  );
};

// draft terms
export const DraftTerm = ({
  term,
  state,
  updateState,
  actions,
  isValid,
  isEditing,
  factions,
}: {
  term: TermType;
  state: any;
  updateState: (key: string, val: any) => void;
  actions: any;
  isValid: boolean;
  isEditing: boolean;
  factions: FactionType[];
}) => {
  const handleInscribe = () => actions.inscribe(term);
  const handleCancel = () => actions.cancel();
  const handleRemove = () => actions.remove();

  return (
    <Box>
      <Box bold color="#e9ca9e">
        {term.name}
      </Box>
      <Box mt={0.5} fontSize="0.9em">
        {term.desc}
      </Box>

      <DynamicInputs
        inputs={term.inputs ?? []}
        state={state}
        updateState={updateState}
        factions={factions}
      />

      <Stack mt={1}>
        <Stack.Item grow={1}>
          <Button
            fluid
            color={isEditing ? 'average' : 'good'}
            icon="pen"
            onClick={handleInscribe}
            disabled={!isValid}
          >
            {isEditing ? 'UPDATE' : 'INSCRIBE'}
          </Button>
        </Stack.Item>
        <Stack.Item grow={1}>
          <Button fluid color="bad" icon="times" onClick={handleCancel}>
            CANCEL
          </Button>
        </Stack.Item>
      </Stack>

      {isEditing && (
        <Button fluid color="danger" icon="trash" mt={1} onClick={handleRemove}>
          REMOVE TERM
        </Button>
      )}
    </Box>
  );
};
