export const formatTime = (deciseconds: number): string => {
  const totalSeconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};
 
export const stageLabel = (stage: number): string => {
  if (stage === 1) return 'Warband Selection';
  if (stage === 2) return 'Casus Belli';
  if (stage === 3) return 'Class Selection';
  return 'Go Forth';
};

export const missingRequiredInput = (
  selectedWarband: import('./WarbandTypes').WarbandType | null,
  selectedSubtype: import('./WarbandTypes').SubType | null,
  selectedAspects: import('./WarbandTypes').AspectType[],
  selectionInputStates: Record<string, Record<string, any>>,
  aspectIntensities: Record<string, number>,
): string | null => {
  const checkFields = (
    title: string,
    typeKey: string,
    inputs?: import('./TreatyTypes').InputFieldDescriptor[],
  ): string | null => {
    if (!inputs?.length) return null;
    const state = selectionInputStates[typeKey] ?? {};
    for (const field of inputs) {
      if (field.client_only || !field.required) continue;
      const val = state[field.key];
      if (val === undefined || val === null || val === '') {
        return `FILL IN: ${title.toUpperCase()} — ${field.label.toUpperCase()}`;
      }
    }
    return null;
  };

  if (selectedWarband) {
    const miss = checkFields(selectedWarband.title, selectedWarband.type, selectedWarband.inputs);
    if (miss) return miss;
  }
  if (selectedSubtype) {
    const miss = checkFields(selectedSubtype.title, selectedSubtype.type, selectedSubtype.inputs);
    if (miss) return miss;
  }
  for (const aspect of selectedAspects) {
    const rank = aspectIntensities[aspect.type] ?? 1;
    const visibleInputs = aspect.inputs?.length === (aspect.max_intensity ?? 1)
      ? aspect.inputs.slice(0, rank)
      : aspect.inputs;
    const miss = checkFields(aspect.title, aspect.type, visibleInputs);
    if (miss) return miss;
  }
  return null;
};
