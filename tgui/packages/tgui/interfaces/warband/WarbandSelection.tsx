import { useEffect, useState } from 'react';

import { useBackend } from '../../backend';
import { AspectType, ClassType, Data, SubType, WarbandType } from './WarbandTypes';


// selections & the point reductions that follow
// also clears selected aspects & classes after a new selection, unless they're compatible with the new selection

export const useWarbandSelection = () => {
  const { data } = useBackend<Data>();
  const finalized_status = data?.finalized_status;
  const backend_warband = data?.backend_warband?.[0] || null;
  const backend_subtype = data?.backend_subtype?.[0] || null;
  const backend_aspects = data?.backend_aspects || [];

  const [selectedWarband, setSelectedWarband] = useState<WarbandType | null>(null);
  const [selectedSubtype, setSelectedSubtype] = useState<SubType | null>(null);
  const [selectedAspects, setSelectedAspects] = useState<AspectType[]>([]);
  const [selectedClass, setSelectedClass] = useState<ClassType | null>(null);
  const [selectedSubclass, setSelectedSubclass] = useState<ClassType | null>(null);
  const [pointCounter, setPointCounter] = useState(0);
  const [aspectIntensities, setAspectIntensities] = useState<Record<string, number>>({});
  const [selectionInputStates, setSelectionInputStates] = useState<Record<string, Record<string, any>>>({});

  const [lockedWarband, setLockedWarband] = useState<WarbandType | null>(null);
  const [lockedSubtype, setLockedSubtype] = useState<SubType | null>(null);
  const [lockedAspects, setLockedAspects] = useState<AspectType[]>([]);
 
  useEffect(() => {
    const creation_stage = data?.creation_stage || 1;
    const shouldLoadBackend = finalized_status || creation_stage >= 2;
    
    if (shouldLoadBackend) {
      if (backend_warband) {
        setSelectedWarband(backend_warband);
        if (finalized_status) {
          setLockedWarband(backend_warband);
        }
      }
      if (backend_subtype) {
        setSelectedSubtype(backend_subtype);
        if (finalized_status) {
          setLockedSubtype(backend_subtype);
        }
      }
      if (backend_aspects.length > 0) {
        setSelectedAspects(backend_aspects);
        const restoredIntensities: Record<string, number> = {};
        for (const aspect of backend_aspects) {
          restoredIntensities[aspect.type] = aspect.intensity ?? 1;
        }
        setAspectIntensities(restoredIntensities);
        const restoredInputs: Record<string, Record<string, any>> = {};
        if (backend_warband?.selection_inputs) restoredInputs[backend_warband.type] = backend_warband.selection_inputs;
        if (backend_subtype?.selection_inputs) restoredInputs[backend_subtype.type] = backend_subtype.selection_inputs;
        for (const aspect of backend_aspects) {
          if (aspect.selection_inputs) restoredInputs[aspect.type] = aspect.selection_inputs;
        }
        setSelectionInputStates(restoredInputs);
        if (finalized_status) {
          setLockedAspects(backend_aspects);
        }
      }
    }
  }, [finalized_status, backend_warband, backend_subtype, backend_aspects, data?.creation_stage]);

  // uses intensity_costs if available, falls back to flat points
  useEffect(() => {
    let totalPoints = 0;
    if (selectedWarband) { totalPoints += selectedWarband.points; }
    if (selectedSubtype) { totalPoints += selectedSubtype.points; }
    for (const aspect of selectedAspects) {
      const rank = aspectIntensities[aspect.type] ?? 1;
      const cost = aspect.intensity_costs?.[rank - 1] ?? aspect.points;
      totalPoints += cost;
    }
    setPointCounter(totalPoints);
  }, [selectedWarband, selectedSubtype, selectedAspects, aspectIntensities, selectedSubclass]);


  // selection
  const handleWarbandSelect = (warband: WarbandType) => {
    if (lockedWarband) { return; }
    if (selectedWarband?.type === warband.type) { return; }
    const isSubtypeCompatible = selectedSubtype && warband.subtypes?.[0]?.includes(selectedSubtype.type);
    // carry over aspects the new warband also offers, but clamp to its cap so switching from an uncapped warband to a capped one can't smuggle in extra aspects
    const aspectCap = warband.max_aspects ?? 5;
    const carriedAspects = selectedAspects.filter(aspect => warband.aspects.includes(aspect.type));
    const compatibleAspects = carriedAspects.slice(0, aspectCap);
    const keptTypes = new Set(compatibleAspects.map(a => a.type));
    const removedTypes = new Set(selectedAspects.filter(a => !keptTypes.has(a.type)).map(a => a.type));
    setSelectedWarband(warband);
    setSelectedSubtype(isSubtypeCompatible ? selectedSubtype : null);
    setSelectedAspects(compatibleAspects);
    setAspectIntensities(prev => {
      const next = { ...prev };
      removedTypes.forEach(t => delete next[t]);
      return next;
    });
    setSelectionInputStates(prev => {
      const next = { ...prev };
      if (!isSubtypeCompatible && selectedSubtype) delete next[selectedSubtype.type];
      removedTypes.forEach(t => delete next[t]);
      return next;
    });
    setSelectedClass(null);
    setSelectedSubclass(null);
  };

  const handleSubtypeSelect = (subtype: SubType) => {
    if (lockedSubtype) { return; }
    setSelectedSubtype(subtype);
    const compatibleAspects = selectedAspects.filter(aspect => subtype.aspects.includes(aspect.type));
    const removedTypes = new Set(selectedAspects.filter(a => !subtype.aspects.includes(a.type)).map(a => a.type));
    setSelectedAspects(compatibleAspects);
    setAspectIntensities(prev => {
      const next = { ...prev };
      removedTypes.forEach(t => delete next[t]);
      return next;
    });
    setSelectionInputStates(prev => {
      const next = { ...prev };
      if (selectedSubtype) delete next[selectedSubtype.type];
      removedTypes.forEach(t => delete next[t]);
      return next;
    });
    setSelectedClass(null);
    setSelectedSubclass(null);
  };

  const handleAspectSelect = (aspect: AspectType) => {
    const isLocked = lockedAspects.some(a => a.type === aspect.type);
    setSelectedAspects(prevAspects => {
      const isSelected = prevAspects.some(a => a.type === aspect.type);
      if (isLocked && isSelected) {
        return prevAspects;
      }
      if (isSelected) {
        // deselect: clear intensity and input state
        setAspectIntensities(prev => { const next = { ...prev }; delete next[aspect.type]; return next; });
        setSelectionInputStates(prev => { const next = { ...prev }; delete next[aspect.type]; return next; });
        return prevAspects.filter(a => a.type !== aspect.type);
      } else {
        const hasConflict = prevAspects.some(a => // we don't want two aspects of the same class being selected (I.E: two map aspects)
          a.class !== null &&
          aspect.class !== null &&
          a.class === aspect.class
        );

        if (hasConflict) {
          return prevAspects;
        }
        // enforce the warband's aspect cap
        const aspectCap = selectedWarband?.max_aspects ?? 5;
        if (prevAspects.length >= aspectCap) {
          return prevAspects;
        }
        // initialize intensity to 1 on select, only if it isn't already set by the expand panel
        setAspectIntensities(prev => ({ ...prev, [aspect.type]: prev[aspect.type] ?? 1 }));
        return [...prevAspects, aspect];
      }
    });
    setSelectedClass(null);
    setSelectedSubclass(null);
  };

  const handleIntensityChange = (aspectType: string, newRank: number) => {
    setAspectIntensities(prev => ({ ...prev, [aspectType]: newRank }));
  };

  const handleSelectionInputChange = (typeKey: string, key: string, val: any) => {
    setSelectionInputStates(prev => ({
      ...prev,
      [typeKey]: { ...(prev[typeKey] ?? {}), [key]: val },
    }));
  };

  const handleClassSelect = (classe: ClassType) => {
    setSelectedClass(prevClass => {
      if (prevClass?.type === classe.type) {
        return null;
      }
      return classe;
    });
    setSelectedSubclass(null);
  };

  const handleSubclassSelect = (subclass: ClassType) => {
    setSelectedSubclass(prevSubclass => {
      if (prevSubclass?.type === subclass.type) {
        return null;
      }
      return subclass;
    });
  };

  return {
    selectedWarband,
    selectedSubtype,
    selectedAspects,
    selectedClass,
    selectedSubclass,
    pointCounter,
    lockedWarband,
    lockedSubtype,
    lockedAspects,
    aspectIntensities,
    selectionInputStates,
    handleWarbandSelect,
    handleSubtypeSelect,
    handleAspectSelect,
    handleIntensityChange,
    handleSelectionInputChange,
    handleClassSelect,
    handleSubclassSelect,
  };
};
