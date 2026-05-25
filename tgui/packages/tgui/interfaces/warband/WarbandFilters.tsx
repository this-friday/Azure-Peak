  // the backend should be providing every possible warband, aspect and class
  // then it gets put through this Filter

  // for a storyteller-locked warband to pass the filter and appear as a possible choice, its required storyteller needs to be present in the manager's "storyinfluences" variable
  // it will need to be present an amount of times equal to the warband's "rarity"

  // available subtypes and aspects are determined by:
  // the rarity filter, if applicable
  // the currently selected warband

  // available classes are determined by all of the above + the user's role


import { useMemo } from 'react';

import { AspectType, ClassType, StorytellerType, SubType, WarbandType } from './WarbandTypes';

const rarityFilter = (band: any, storytellersList: StorytellerType[]): boolean => {
  if (band.storyinfluence) {
    const matchCount = storytellersList.filter(storyteller => storyteller.type === band.storyinfluence).length;
    return matchCount >= band.rarity;
  }
  return true;
};

export const useWarbandFilters = (
  user_role: string | undefined,
  selectedWarband: WarbandType | null,
  selectedSubtype: SubType | null,
  warbandList: WarbandType[],
  subtypeList: SubType[],
  aspectList: AspectType[],
  classList: ClassType[],
  storytellersList: StorytellerType[]
) => {

  const filteredWarbands = useMemo(() => {
    return warbandList.filter(warband => rarityFilter(warband, storytellersList));
  }, [warbandList, storytellersList]);

  const filteredSubtypes = useMemo(() => {
    if (!selectedWarband) {
      return [];
    }
    return subtypeList.filter(subtype => {
      const isWarbandCompatible = selectedWarband.subtypes?.[0]?.includes(subtype.type);
      return isWarbandCompatible && rarityFilter(subtype, storytellersList);
    });
  }, [selectedWarband, subtypeList, storytellersList]);

  const filteredAspects = useMemo(() => {
    if (!selectedWarband) {
      return [];
    }
    const allowedAspectTypes = new Set(selectedWarband.aspects);
    if (selectedSubtype) {
      if (Array.isArray(selectedSubtype.aspects)) {
        selectedSubtype.aspects.forEach(aspectType => allowedAspectTypes.add(aspectType));
      }
    }
    return aspectList.filter(aspect => {
      const isTypeAllowed = allowedAspectTypes.has(aspect.type);
      return isTypeAllowed && rarityFilter(aspect, storytellersList);
    }).sort((a, b) => b.points - a.points);
  }, [selectedWarband, selectedSubtype, aspectList, storytellersList]);

  const filteredClasses = useMemo(() => {
    if (!selectedWarband) {
      return { warlord: [], lieutenant: [], grunt: [] };
    }

    const filteredRarity = classList.filter(classe => rarityFilter(classe, storytellersList));

    const warbandWarlordClasses = selectedWarband.warlordclasses || [];
    const warbandLieuClasses = selectedWarband.lieuclasses || [];
    const warbandGruntClasses = selectedWarband.gruntclasses || [];

    const subtypeWarlordClasses = selectedSubtype?.warlordclasses || [];
    const subtypeLieuClasses = selectedSubtype?.lieuclasses || [];
    const subtypeGruntClasses = selectedSubtype?.gruntclasses || [];

    const combinedWarlordClasses = new Set([...warbandWarlordClasses, ...subtypeWarlordClasses]);
    const combinedLieuClasses = new Set([...warbandLieuClasses, ...subtypeLieuClasses]);
    const combinedGruntClasses = new Set([...warbandGruntClasses, ...subtypeGruntClasses]);

    const warlordClasses = filteredRarity.filter(classe => combinedWarlordClasses.has(classe.type));
    const lieuClasses = filteredRarity.filter(classe => combinedLieuClasses.has(classe.type));
    const gruntClasses = filteredRarity.filter(classe => combinedGruntClasses.has(classe.type));

    return { warlord: warlordClasses, lieutenant: lieuClasses, grunt: gruntClasses };
  }, [selectedWarband, selectedSubtype, classList, storytellersList]);

  const availableClasses = useMemo(() => {
    if (!user_role) return [];

    let roleClasses: ClassType[] = [];
    if (user_role === 'Warlord') roleClasses = filteredClasses.warlord;
    else if (user_role === 'Lieutenant' || user_role === 'Aspirant Lieutenant') roleClasses = filteredClasses.lieutenant;
    else if (user_role === 'Grunt') roleClasses = filteredClasses.grunt;
    if (selectedWarband?.multiclass_enabled) {
      return roleClasses.filter(c => !c.multiclass_capable);
    }
    return roleClasses;
  }, [user_role, filteredClasses, selectedWarband]);

  const filteredSubclasses = useMemo(() => {
    if (!selectedWarband?.multiclass_enabled) return [];

    const filteredRarity = classList.filter(c => rarityFilter(c, storytellersList));

    const getMulticlasses = (classTypes: string[]) =>
      filteredRarity.filter(c => classTypes.includes(c.type) && c.multiclass_capable);

    const warlordTypes = [
      ...(selectedWarband.warlordclasses || []),
      ...(selectedSubtype?.warlordclasses || []),
    ];
    const lieutenantTypes = [
      ...(selectedWarband.lieuclasses || []),
      ...(selectedSubtype?.lieuclasses || []),
    ];
    const gruntTypes = [
      ...(selectedWarband.gruntclasses || []),
      ...(selectedSubtype?.gruntclasses || []),
    ];

    // if higher-tier multiclass_capable classes exist for the role, they replace grunt-tier ones
    // grunts, however, will only ever see grunt-tier classes
    if (user_role === 'Warlord') {
      const higher = getMulticlasses(warlordTypes);
      return higher.length > 0 ? higher : getMulticlasses(gruntTypes);
    }

    if (user_role === 'Lieutenant' || user_role === 'Aspirant Lieutenant') {
      const higher = getMulticlasses(lieutenantTypes);
      return higher.length > 0 ? higher : getMulticlasses(gruntTypes);
    }

    if (user_role === 'Grunt') {
      return getMulticlasses(gruntTypes);
    }

    return [];
  }, [selectedWarband, selectedSubtype, user_role, classList, storytellersList]);

  return {
    filteredWarbands,
    filteredSubtypes,
    filteredAspects,
    availableClasses,
    filteredGruntClasses: filteredClasses.grunt,
    filteredSubclasses,
  };
};
