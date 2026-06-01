import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { DynamicInputs } from './TreatyInputs';
import { AspectType, SubType, WarbandType } from './WarbandTypes';

type CreationTabProps = {
  filteredWarbands: WarbandType[];
  filteredSubtypes: SubType[];
  filteredAspects: AspectType[];
  selectedWarband: WarbandType | null;
  selectedSubtype: SubType | null;
  selectedAspects: AspectType[];
  aspectIntensities: Record<string, number>;
  selectionInputStates: Record<string, Record<string, any>>;
  handleWarbandSelect: (warband: WarbandType) => void;
  handleSubtypeSelect: (subtype: SubType) => void;
  handleAspectSelect: (aspect: AspectType) => void;
  handleIntensityChange: (aspectType: string, newRank: number) => void;
  handleSelectionInputChange: (typeKey: string, key: string, val: any) => void;
  act: (action: string, payload?: object) => void;
  locked?: boolean;
  stage1Complete?: boolean;
  isStage1?: boolean;
  isWarlord?: boolean;
  pointCounter?: number;
};

// renders rank pips for intensity (filled up to the current rank)
const IntensityStepper = ({
  maxIntensity,
  currentRank,
  costs,
  onChange,
}: {
  maxIntensity: number;
  currentRank: number;
  costs: number[];
  onChange: (rank: number) => void;
}) => {
  const currentCost = costs[currentRank - 1] ?? 0;
  const costColor = currentCost < 0 ? '#ae3636' : currentCost > 0 ? '#7a2585' : '#888';

  return (
    <Box mt={1}>
      <Box color="label" mb={0.5} fontSize="0.85em">
        INTENSITY
      </Box>
      <Stack align="center">
        {Array.from({ length: maxIntensity }, (_, i) => i + 1).map((rank) => (
          <Stack.Item key={rank}>
            <Button
              onClick={() => onChange(rank)}
              style={{
                width: '28px',
                height: '28px',
                padding: 0,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: rank <= currentRank ? '#7a2525' : '#2a1a1a',
                border: '1px solid #5a3030',
                fontSize: '12px',
              }}
            >
              {rank}
            </Button>
          </Stack.Item>
        ))}
        <Stack.Item ml={1}>
          <Box color={costColor} fontSize="0.85em" bold>
            {currentCost > 0 ? `+${currentCost}` : currentCost} pts
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const ExpandedPanel = ({
  desc,
  inputs,
  inputState,
  onInputChange,
  isSelected,
  onConfirm,
  onCancel,
  observerMode = false,
}: {
  desc?: string;
  inputs?: import('./TreatyTypes').InputFieldDescriptor[];
  inputState: Record<string, any>;
  onInputChange: (key: string, val: any) => void;
  isSelected: boolean;
  onConfirm: () => void;
  onCancel: () => void;
  observerMode?: boolean;
}) => (
  <Box
    p={1.5}
    style={{
      backgroundColor: 'rgba(0,0,0,0.5)',
      border: '1px solid #5a3030',
      borderTop: 'none',
      marginTop: '-1px',
    }}
  >
    {desc && (
      <Box
        fontSize="0.85em"
        color="#b1a390"
        p={1}
        mb={1}
        style={{ backgroundColor: 'rgba(0,0,0,0.3)', border: '1px solid #3a3228' }}
      >
        {desc}
      </Box>
    )}
    {!!(inputs?.length) && (
      <DynamicInputs
        inputs={inputs}
        state={inputState}
        updateState={(key, val) => {
          onInputChange(key, val);
        }}
        factions={[]}
      />
    )}
    {observerMode ? (
      <Box mt={1}>
        <Stack>
          <Stack.Item grow={1}>
            <Button
              fluid
              onClick={onConfirm}
              style={{
                color: '#8ab4cc',
                backgroundColor: 'rgba(40, 60, 80, 0.4)',
                borderColor: '#4a6a80',
              }}
            >
              {isSelected ? 'BROWSING FROM HERE' : 'BROWSE FROM HERE'}
            </Button>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Button fluid color="transparent" onClick={onCancel}>
              CANCEL
            </Button>
          </Stack.Item>
        </Stack>
        <Box mt={0.5} fontSize="0.8em" color="#7a5525" italic>
          Your selection is for browsing only — the Warlord makes the final choice.
        </Box>
      </Box>
    ) : (
      <Stack mt={1}>
        <Stack.Item grow={1}>
          <Button fluid color={isSelected ? 'bad' : 'good'} icon={isSelected ? 'times' : 'check'} onClick={onConfirm}>
            {isSelected ? 'DESELECT' : 'SELECT'}
          </Button>
        </Stack.Item>
        <Stack.Item grow={1}>
          <Button fluid color="transparent" onClick={onCancel}>
            CANCEL
          </Button>
        </Stack.Item>
      </Stack>
    )}
  </Box>
);

// renders the filled-in input values for a warband, subtype, or aspect
// uses the field descriptors from .inputs and the saved values from .selection_inputs
const SelectionInputDisplay = ({
  inputs,
  selectionInputs,
  dividerStyle,
  valueStyle,
}: {
  inputs?: import('./TreatyTypes').InputFieldDescriptor[];
  selectionInputs?: Record<string, any>;
  dividerStyle: React.CSSProperties;
  valueStyle: React.CSSProperties;
}) => {
  if (!inputs?.length || !selectionInputs) return null;
  const filled = inputs.filter(field => {
    const val = selectionInputs[field.key];
    return val !== undefined && val !== null && val !== '';
  });
  if (!filled.length) return null;
  return (
    <>
      <div style={dividerStyle} />
      <Stack vertical style={{ gap: '4px' }}>
        {filled.map(field => (
          <div key={field.key}>
            <span style={{ fontSize: '11px', letterSpacing: '0.1em', color: '#7a5525', fontWeight: 'bold' }}>
              {field.label.toUpperCase()}
            </span>
            <div style={valueStyle}>{String(selectionInputs[field.key])}</div>
          </div>
        ))}
      </Stack>
    </>
  );
};

// read-only summary shown to latejoining players after the warband is confirmed
const LockedSummaryView = ({
  selectedWarband,
  selectedSubtype,
  selectedAspects,
  aspectIntensities,
}: {
  selectedWarband: WarbandType | null;
  selectedSubtype: SubType | null;
  selectedAspects: AspectType[];
  aspectIntensities: Record<string, number>;
}) => {
  const dividerStyle: React.CSSProperties = {
    borderBottom: '1px solid #5a2020',
    margin: '8px 0',
  };

  const labelStyle: React.CSSProperties = {
    fontSize: '11px',
    letterSpacing: '0.12em',
    color: '#7a2525',
    fontWeight: 'bold',
    marginBottom: '4px',
  };

  const titleStyle: React.CSSProperties = {
    fontSize: '16px',
    fontWeight: 'bold',
    color: '#d46060',
    marginBottom: '4px',
  };

  const summaryStyle: React.CSSProperties = {
    fontSize: '13px',
    color: '#b1a390',
    lineHeight: '1.5',
  };

  const inputValueStyle: React.CSSProperties = {
    fontSize: '13px',
    color: '#c9a060',
    marginTop: '1px',
  };

  const cardStyle: React.CSSProperties = {
    backgroundColor: 'rgba(60, 10, 10, 0.45)',
    border: '1px solid #5a2020',
    padding: '12px 16px',
    marginBottom: '8px',
  };

  return (
    <Stack direction="row" style={{ flex: 1, minHeight: 0 }}>
      <Section
        title={<span style={{ color: '#7a2525ff' }}>WARBAND</span>}
        scrollable fill
        style={{ flex: 1, minWidth: '280px' }}
      >
        {selectedWarband ? (
          <Box style={cardStyle}>
            <div style={labelStyle}>SELECTED</div>
            <div style={titleStyle}>{selectedWarband.title}</div>
            <div style={dividerStyle} />
            <div style={summaryStyle}>{selectedWarband.summary}</div>
            {selectedWarband.desc && (
              <>
                <div style={dividerStyle} />
                <div style={{ ...summaryStyle, color: '#8a8070' }}>{selectedWarband.desc}</div>
              </>
            )}
            <SelectionInputDisplay
              inputs={selectedWarband.inputs}
              selectionInputs={selectedWarband.selection_inputs}
              dividerStyle={dividerStyle}
              valueStyle={inputValueStyle}
            />
          </Box>
        ) : (
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <p style={{ color: '#7a2525ff' }}>NO WARBAND SELECTED</p>
          </div>
        )}
      </Section>

      <Section
        title={<span style={{ color: '#7a2525ff' }}>SUBTYPE</span>}
        scrollable fill
        style={{ flex: 1, minWidth: '280px' }}
      >
        {selectedSubtype ? (
          <Box style={cardStyle}>
            <div style={labelStyle}>SELECTED</div>
            <div style={titleStyle}>{selectedSubtype.title}</div>
            {selectedSubtype.quote && (
              <div style={{ ...summaryStyle, color: '#8a7060', fontStyle: 'italic', marginBottom: '6px' }}>
                &ldquo;{selectedSubtype.quote}&rdquo;
                {selectedSubtype.quote_followup && (
                  <span style={{ display: 'block', fontSize: '11px', marginTop: '2px' }}>
                    — {selectedSubtype.quote_followup}
                  </span>
                )}
              </div>
            )}
            <div style={dividerStyle} />
            <div style={summaryStyle}>{selectedSubtype.summary}</div>
            {selectedSubtype.desc && (
              <>
                <div style={dividerStyle} />
                <div style={{ ...summaryStyle, color: '#8a8070' }}>{selectedSubtype.desc}</div>
              </>
            )}
            <SelectionInputDisplay
              inputs={selectedSubtype.inputs}
              selectionInputs={selectedSubtype.selection_inputs}
              dividerStyle={dividerStyle}
              valueStyle={inputValueStyle}
            />
          </Box>
        ) : (
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <p style={{ color: '#7a2525ff' }}>NO SUBTYPE SELECTED</p>
          </div>
        )}
      </Section>

      <Section
        title={<span style={{ color: '#7a2525ff' }}>ASPECTS</span>}
        scrollable fill
        style={{ flex: 1, minWidth: '280px' }}
      >
        {selectedAspects.length > 0 ? (
          <Stack vertical>
            {selectedAspects.map((aspect) => {
              const rank = aspectIntensities[aspect.type] ?? aspect.intensity ?? 1;
              const hasIntensity = (aspect.max_intensity ?? 1) > 1;
              const currentCost = aspect.intensity_costs?.[rank - 1] ?? aspect.points;
              const costColor = currentCost < 0 ? '#ae3636' : currentCost > 0 ? '#9a40a0' : '#888';
              const bgColor = currentCost < 0 ? 'rgba(60,13,13,0.6)' : currentCost > 0 ? 'rgba(60,20,60,0.45)' : 'rgba(30,20,20,0.45)';

              return (
                <Box key={aspect.type} style={{ ...cardStyle, backgroundColor: bgColor, marginBottom: '6px' }}>
                  <Stack align="center" justify="space-between">
                    <Stack.Item grow={1}>
                      <div style={{ fontWeight: 'bold', color: '#d46060', fontSize: '14px' }}>
                        {aspect.title}
                        {hasIntensity && (
                          <span style={{ color: '#c9a347', fontWeight: 'normal', marginLeft: '8px', fontSize: '12px' }}>
                            [RANK {rank}]
                          </span>
                        )}
                      </div>
                    </Stack.Item>
                    <Stack.Item>
                      <span style={{ color: costColor, fontSize: '12px', fontWeight: 'bold' }}>
                        {currentCost > 0 ? `+${currentCost}` : currentCost} pts
                      </span>
                    </Stack.Item>
                  </Stack>
                  <div style={{ ...summaryStyle, marginTop: '4px' }}>{aspect.summary}</div>
                  {aspect.desc && (
                    <>
                      <div style={dividerStyle} />
                      <div style={{ ...summaryStyle, color: '#8a8070', fontSize: '12px' }}>{aspect.desc}</div>
                    </>
                  )}
                  <SelectionInputDisplay
                    inputs={aspect.inputs}
                    selectionInputs={aspect.selection_inputs}
                    dividerStyle={dividerStyle}
                    valueStyle={inputValueStyle}
                  />
                </Box>
              );
            })}
          </Stack>
        ) : (
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <p style={{ color: '#7a2525ff' }}>NO ASPECTS SELECTED</p>
          </div>
        )}
      </Section>
    </Stack>
  );
};

export const CreationTab = ({
  filteredWarbands,
  filteredSubtypes,
  filteredAspects,
  selectedWarband,
  selectedSubtype,
  selectedAspects,
  aspectIntensities,
  selectionInputStates,
  handleWarbandSelect,
  handleSubtypeSelect,
  handleAspectSelect,
  handleIntensityChange,
  handleSelectionInputChange,
  act,
  locked = false,
  stage1Complete = false,
  isStage1 = true,
  isWarlord = false,
  pointCounter = 0,
}: CreationTabProps) => {
  const [expandedSelection, setExpandedSelection] = useState<string | null>(null);
  const [gateDismissed, setGateDismissed] = useState(false);

  const observerMode = !isWarlord && isStage1 && !locked;

  const getAspectColor = (points: number) => {
    if (points < 0) return '#3c0d0d';
    if (points > 0) return '#722b5d';
    return undefined;
  };

  const disableReason = () => {
    if (stage1Complete) return null;
    if (pointCounter < 0) return "MUST HAVE 0 OR MORE ASPECT POINTS";
    if (!selectedWarband) return "SELECT A WARBAND";
    if (selectedWarband?.subtyperequired && !selectedSubtype) return "THIS WARBAND REQUIRES A SUBTYPE";
    return null;
  };

  const canAdvance = stage1Complete;

  const handleAspectClick = (aspect: AspectType) => {
    if (locked) return;
    act('interaction_sound');
    setExpandedSelection(prev => prev === aspect.type ? null : aspect.type);
  };

  const handleConfirmSelect = (aspect: AspectType) => {
    handleAspectSelect(aspect);
    setExpandedSelection(null);
  };

  const handleCancelExpand = () => {
    setExpandedSelection(null);
  };

  if (locked) {
    return (
      <Stack style={{ flex: 1, flexDirection: 'column', height: '100%' }}>
        <LockedSummaryView
          selectedWarband={selectedWarband}
          selectedSubtype={selectedSubtype}
          selectedAspects={selectedAspects}
          aspectIntensities={aspectIntensities}
        />
        <div style={{ height: '110px' }} />
      </Stack>
    );
  }

  return (
    <Stack style={{ flex: 1, flexDirection: 'column', height: '100%', position: 'relative' }}>

      {observerMode && !gateDismissed && (
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
            maxWidth: '480px',
            width: '100%',
          }}>
            <Box bold style={{ color: '#d46060', fontSize: '16px', letterSpacing: '0.1em', marginBottom: '12px' }}>
              BROWSING AS OBSERVER
            </Box>
            <Box style={{ color: '#b1a390', fontSize: '13px', lineHeight: '1.6', marginBottom: '16px' }}>
              The Warlord is currently selecting the Warband. You may browse the available options and read their descriptions, but your selections are not binding.
            </Box>
            <Button
              fluid
              onClick={() => setGateDismissed(true)}
              style={{ padding: '10px', fontSize: '14px', letterSpacing: '0.08em' }}
            >
              UNDERSTOOD
            </Button>
          </Box>
        </Box>
      )}

      <Stack direction="row" style={{ flex: 1, minHeight: 0 }}>
        <Section
          title={<span style={{ color: '#7a2525ff' }}>AVAILABLE WARBANDS</span>}
          scrollable fill
          style={{ flex: 1, minWidth: '280px' }}
        >
          {filteredWarbands.length > 0 ? (
            <Stack vertical>
              {filteredWarbands.map((warband) => {
                const isSelected = selectedWarband?.type === warband.type;
                const isExpanded = expandedSelection === warband.type;
                const needsExpand = true;
                return (
                  <Box key={warband.title}>
                    <Button
                      fluid
                      onClick={() => {
                        if (locked) return;
                        act('interaction_sound');
                        if (needsExpand) {
                          setExpandedSelection(prev => prev === warband.type ? null : warband.type);
                        } else {
                          handleWarbandSelect(warband);
                        }
                      }}
                      disabled={locked || (isSelected && !needsExpand)}
                      style={{ backgroundColor: isSelected ? '#7a2525ff' : isExpanded ? '#4a1515' : undefined }}
                    >
                      {warband.title}
                    </Button>
                    {isExpanded && !locked && (
                      <ExpandedPanel
                        desc={warband.summary}
                        inputs={warband.inputs}
                        inputState={selectionInputStates[warband.type] ?? {}}
                        onInputChange={(key, val) => handleSelectionInputChange(warband.type, key, val)}
                        isSelected={isSelected}
                        onConfirm={() => { handleWarbandSelect(warband); setExpandedSelection(null); }}
                        onCancel={() => setExpandedSelection(null)}
                        observerMode={observerMode}
                      />
                    )}
                  </Box>
                );
              })}
            </Stack>
          ) : (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
              <p>NO WARBANDS AVAILABLE.</p>
            </div>
          )}
        </Section>

        <Section
          title={<span style={{ color: '#7a2525ff' }}>SUBTYPE</span>}
          scrollable fill
          style={{ flex: 1, minWidth: '280px' }}
        >
          {selectedWarband && filteredSubtypes.length > 0 ? (
            <Stack vertical>
              {filteredSubtypes.map((subtype) => {
                const isSelected = selectedSubtype?.type === subtype.type;
                const isExpanded = expandedSelection === subtype.type;
                const needsExpand = true;
                return (
                  <Box key={subtype.title}>
                    <Button
                      fluid
                      onClick={() => {
                        if (locked) return;
                        act('interaction_sound');
                        if (needsExpand) {
                          setExpandedSelection(prev => prev === subtype.type ? null : subtype.type);
                        } else {
                          handleSubtypeSelect(subtype);
                        }
                      }}
                      disabled={locked}
                      style={{ backgroundColor: isSelected ? '#7a2525ff' : isExpanded ? '#4a1515' : undefined }}
                    >
                      {subtype.title}
                    </Button>
                    {isExpanded && !locked && (
                      <ExpandedPanel
                        desc={subtype.summary}
                        inputs={subtype.inputs}
                        inputState={selectionInputStates[subtype.type] ?? {}}
                        onInputChange={(key, val) => handleSelectionInputChange(subtype.type, key, val)}
                        isSelected={isSelected}
                        onConfirm={() => { handleSubtypeSelect(subtype); setExpandedSelection(null); }}
                        onCancel={() => setExpandedSelection(null)}
                        observerMode={observerMode}
                      />
                    )}
                  </Box>
                );
              })}
            </Stack>
          ) : (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
              <p style={{ color: '#7a2525ff' }}>{selectedWarband ? 'NO SUBTYPES AVAILABLE' : 'SELECT A WARBAND'}</p>
            </div>
          )}
        </Section>

        <Section
          title={<span style={{ color: '#7a2525ff' }}>ASPECTS</span>}
          scrollable fill
          style={{ flex: 1, minWidth: '280px' }}
        >
          {selectedWarband && filteredAspects.length > 0 ? (
            <Stack vertical>
              {filteredAspects.map((aspect) => {
                const isSelected = selectedAspects.some((s) => s.type === aspect.type);
                const isExpanded = expandedSelection === aspect.type;
                const rank = aspectIntensities[aspect.type] ?? 1;
                const currentCost = aspect.intensity_costs?.[rank - 1] ?? aspect.points;
                const hasIntensity = (aspect.max_intensity ?? 1) > 1;
                const needsExpand = true;

                return (
                  <Box key={aspect.title}>
                    <Button
                      fluid
                      onClick={() => needsExpand ? handleAspectClick(aspect) : handleConfirmSelect(aspect)}
                      disabled={locked}
                      style={{
                        backgroundColor: isSelected ? '#7a2525ff' : isExpanded ? '#4a1515' : getAspectColor(currentCost),
                        height: 'auto',
                        padding: '12px 16px',
                        whiteSpace: 'normal',
                        textAlign: 'left',
                      }}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', fontWeight: 'bold' }}>
                        <span>
                          {aspect.title}
                          {hasIntensity && isSelected && (
                            <span style={{ color: '#c9a347', fontWeight: 'normal', marginLeft: '6px', fontSize: '0.85em' }}>
                              [RANK {rank}]
                            </span>
                          )}
                        </span>
                        <span style={{
                          fontSize: '0.85em',
                          fontWeight: 'normal',
                          color: currentCost < 0 ? '#e05555' : currentCost > 0 ? '#c080c8' : '#888',
                          marginLeft: '8px',
                          flexShrink: 0,
                        }}>
                          {currentCost > 0 ? `+${currentCost}` : currentCost} pts
                        </span>
                      </div>
                      <p style={{ margin: 0, fontSize: '15px' }}>{aspect.summary}</p>
                    </Button>

                    {isExpanded && !locked && (
                      <Box>
                        {hasIntensity && (
                          <Box
                            px={1.5}
                            pt={1.5}
                            style={{
                              backgroundColor: 'rgba(0,0,0,0.5)',
                              border: '1px solid #5a3030',
                              borderTop: 'none',
                              borderBottom: 'none',
                            }}
                          >
                            <IntensityStepper
                              maxIntensity={aspect.max_intensity!}
                              currentRank={rank}
                              costs={aspect.intensity_costs!}
                              onChange={(newRank) => handleIntensityChange(aspect.type, newRank)}
                            />
                          </Box>
                        )}
                        <ExpandedPanel
                          desc={aspect.desc}
                          inputs={
                            aspect.inputs?.length === (aspect.max_intensity ?? 1) // when an aspect has as many Inputs as it has Intensity Stages, we progressively reveal the inputs with each stage
                              ? aspect.inputs.slice(0, rank)
                              : aspect.inputs
                          }
                          inputState={selectionInputStates[aspect.type] ?? {}}
                          onInputChange={(key, val) => handleSelectionInputChange(aspect.type, key, val)}
                          isSelected={isSelected}
                          onConfirm={() => handleConfirmSelect(aspect)}
                          onCancel={handleCancelExpand}
                          observerMode={observerMode}
                        />
                      </Box>
                    )}
                  </Box>
                );
              })}
            </Stack>
          ) : (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
              <p style={{ color: '#7a2525ff' }}>{selectedWarband ? 'NO ASPECTS AVAILABLE' : 'SELECT A WARBAND'}</p>
            </div>
          )}
        </Section>
      </Stack>

      {isStage1 && isWarlord ? (
        <Section style={{ flex: 0, flexBasis: 'auto' }}>
          <Stack direction="row" justify="center">
            <span
              style={{
                flex: 1,
                color: '#ae3636',
                fontSize: '15px',
                padding: '25px',
                display: 'flex',
                marginBottom: '110px',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              {disableReason()}
            </span>
            <Button
              onClick={() => {
                const stage1_selections = {
                  warband: selectedWarband?.type,
                  subtype: selectedSubtype?.type,
                  aspects: selectedAspects?.map((aspect) => aspect.type),
                  aspect_intensities: aspectIntensities,
                  selection_inputs: selectionInputStates,
                };
                act('advance_stage', stage1_selections);
                act('interaction_sound');
              }}
              disabled={!canAdvance}
              style={{
                flex: 1,
                fontSize: '25px',
                padding: '25px',
                marginBottom: '110px',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              CONFIRM WARBAND
            </Button>
          </Stack>
        </Section>
      ) : (
        <div style={{ height: '110px' }} />
      )}
    </Stack>
  );
};
