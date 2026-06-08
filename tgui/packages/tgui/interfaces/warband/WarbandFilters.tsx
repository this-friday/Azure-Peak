  // the backend should be providing every possible warband, aspect and class
  // then it gets put through this Filter

  // for a storyteller-locked warband to pass the filter and appear as a possible choice, its required storyteller needs to be present in the manager's "storyinfluences" variable
  // it will need to be present an amount of times equal to the warband's "rarity"

  // grant: a source's warlord/lieu/grunt class lists are unioned into the available pool
  // suppress: a source's "suppressed_classes" removes those class types from every panel
  // exclusive: a source with "replaces_primaries" restricts the PRIMARY panel to its own grants (blocks all other primaries) for the tiers it grants into
  // subclass override: a selected primary with classes shows exactly those as its subclasses (hiding the shared multiclass pool)


import { useMemo } from 'react';

import { AspectType, ClassType, StorytellerType, SubType, WarbandType } from './WarbandTypes';

const rarityFilter = (band: any, storytellersList: StorytellerType[], bypass: boolean): boolean => {
  if (bypass) return true;
  if (band.storyinfluence) {
    const matchCount = storytellersList.filter(storyteller => storyteller.type === band.storyinfluence).length;
    return matchCount >= band.rarity;
  }
  return true;
};

type ClassSource = WarbandType | SubType | AspectType;
type Tier = 'warlord' | 'lieutenant' | 'grunt';

const tierList = (source: ClassSource | null | undefined, tier: Tier): string[] => {
  if (!source) return [];
  if (tier === 'warlord') return source.warlordclasses || [];
  if (tier === 'lieutenant') return source.lieuclasses || [];
  return source.gruntclasses || [];
};

const tierForRole = (user_role: string | undefined): Tier | null => {
  if (user_role === 'Warlord') return 'warlord';
  if (user_role === 'Lieutenant' || user_role === 'Aspirant Lieutenant') return 'lieutenant';
  if (user_role === 'Grunt') return 'grunt';
  return null;
};

export const useWarbandFilters = (
  user_role: string | undefined,
  selectedWarband: WarbandType | null,
  selectedSubtype: SubType | null,
  selectedAspects: AspectType[],
  selectedClass: ClassType | null,
  warbandList: WarbandType[],
  subtypeList: SubType[],
  aspectList: AspectType[],
  classList: ClassType[],
  storytellersList: StorytellerType[],
  bypassRarity: boolean = false,
) => {

  const filteredWarbands = useMemo(() => {
    return warbandList.map(warband => ({
      ...warband,
      rarity_locked: !rarityFilter(warband, storytellersList, bypassRarity),
    }));
  }, [warbandList, storytellersList, bypassRarity]);

  const filteredSubtypes = useMemo(() => {
    if (!selectedWarband) {
      return [];
    }

    return subtypeList
      .filter(subtype => selectedWarband.subtypes?.[0]?.includes(subtype.type))
      .map(subtype => ({
        ...subtype,
        rarity_locked: !rarityFilter(subtype, storytellersList, bypassRarity),
      }));
  }, [selectedWarband, subtypeList, storytellersList, bypassRarity]);

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

    return aspectList
      .filter(aspect => allowedAspectTypes.has(aspect.type))
      .map(aspect => ({
        ...aspect,
        rarity_locked: !rarityFilter(aspect, storytellersList, bypassRarity),
      }))
      .sort((a, b) => b.points - a.points);
  }, [selectedWarband, selectedSubtype, aspectList, storytellersList, bypassRarity]);

  // every selection that can manipulate the class pool, in priority order
  const classSources: ClassSource[] = useMemo(
    () => [selectedWarband, selectedSubtype, ...selectedAspects].filter(Boolean) as ClassSource[],
    [selectedWarband, selectedSubtype, selectedAspects],
  );

  // class types hidden by any active source
  const suppressedTypes = useMemo(
    () => new Set(classSources.flatMap(s => s.suppressed_classes ?? [])),
    [classSources],
  );

  const filteredClasses = useMemo(() => {
    if (!selectedWarband) {
      return { warlord: [], lieutenant: [], grunt: [] };
    }

    const filteredRarity = classList.filter(
      classe => rarityFilter(classe, storytellersList, bypassRarity) && !suppressedTypes.has(classe.type),
    );

    const combine = (tier: Tier) => new Set(classSources.flatMap(s => tierList(s, tier)));
    const combinedWarlordClasses = combine('warlord');
    const combinedLieuClasses = combine('lieutenant');
    const combinedGruntClasses = combine('grunt');

    const warlordClasses = filteredRarity.filter(classe => combinedWarlordClasses.has(classe.type));
    const lieuClasses = filteredRarity.filter(classe => combinedLieuClasses.has(classe.type));
    const gruntClasses = filteredRarity.filter(classe => combinedGruntClasses.has(classe.type));

    return { warlord: warlordClasses, lieutenant: lieuClasses, grunt: gruntClasses };
  }, [selectedWarband, classSources, suppressedTypes, classList, storytellersList, bypassRarity]);

  const availableClasses = useMemo(() => {
    const tier = tierForRole(user_role);
    if (!tier) return [];

    let roleClasses: ClassType[] = filteredClasses[tier];

    // primaries only, for multiclass-enabled warbands
    if (selectedWarband?.multiclass_enabled) {
      roleClasses = roleClasses.filter(c => !c.multiclass_capable);
    }

    // if any active source replaces primaries, restrict this tier's primaries to those grants
    const exclusiveGrants = new Set(
      classSources.filter(s => s.replaces_primaries).flatMap(s => tierList(s, tier)),
    );
    if (exclusiveGrants.size > 0) {
      roleClasses = roleClasses.filter(c => exclusiveGrants.has(c.type));
    }

    return roleClasses;
  }, [user_role, filteredClasses, selectedWarband, classSources]);

  const filteredSubclasses = useMemo(() => {
    if (!selectedWarband?.multiclass_enabled) return [];

    const pool = classList.filter(
      c => rarityFilter(c, storytellersList, bypassRarity) && !suppressedTypes.has(c.type),
    );

    if (selectedClass?.classes?.length) {
      const whitelist = new Set(selectedClass.classes);
      return pool.filter(c => whitelist.has(c.type));
    }

    const getMulticlasses = (classTypes: string[]) =>
      pool.filter(c => classTypes.includes(c.type) && c.multiclass_capable);

    const warlordTypes = [...tierList(selectedWarband, 'warlord'), ...tierList(selectedSubtype, 'warlord')];
    const lieutenantTypes = [...tierList(selectedWarband, 'lieutenant'), ...tierList(selectedSubtype, 'lieutenant')];
    const gruntTypes = [...tierList(selectedWarband, 'grunt'), ...tierList(selectedSubtype, 'grunt')];

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
  }, [selectedWarband, selectedSubtype, selectedClass, user_role, classList, suppressedTypes, storytellersList, bypassRarity]);

  return {
    filteredWarbands,
    filteredSubtypes,
    filteredAspects,
    availableClasses,
    filteredGruntClasses: filteredClasses.grunt,
    filteredSubclasses,
  };
};
