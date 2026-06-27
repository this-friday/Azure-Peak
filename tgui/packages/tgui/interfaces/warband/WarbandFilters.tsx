  // the backend should be providing every possible warband, aspect and class
  // then it gets put through this Filter

  // for a rarity-locked warband to pass the filter and appear as a possible choice, its required patron needs to be present in the manager's "storyinfluence" variable
  // it will need to be present an amount of times equal to the warband's "rarity" (contributed by the princes' patrons)

  // grant: a source's warlord/lieu/grunt class lists are unioned into the available pool
  // suppress: a source's "suppressed_classes" removes those class types from every panel
  // exclusive: a source with "suppress_all_other_classes" restricts the PRIMARY panel to its own grants (blocks all other primaries) for the tiers it grants into
  // subclass override: a selected primary with classes shows exactly those as its subclasses (hiding the shared universal-class pool)
  // universal classes: the warband's & subtype's universal_*classes lists (one per role tier) fill the subclass panel. roles without their own entry will share the grunt-tier's pool


import { useMemo } from 'react';

import { AspectType, ClassType, PatronType, SubType, WarbandType } from './WarbandTypes';

const rarityFilter = (band: any, patronsList: PatronType[], bypass: boolean): boolean => {
  if (bypass) return true;
  if (band.storytellerlimit) {
    const matchCount = patronsList.filter(patron => patron.type === band.storytellerlimit).length;
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

const uniList = (source: ClassSource | null | undefined, tier: Tier): string[] => {
  if (!source) return [];
  if (tier === 'warlord') return source.universal_warlordclasses || [];
  if (tier === 'lieutenant') return source.universal_lieuclasses || [];
  return source.universal_gruntclasses || [];
};

const ROLE_LIEUTENANT = "Lieutenant";
const ROLE_ASPIRANT = 'Aspirant Lieutenant';

const tierForRole = (user_role: string | undefined): Tier | null => {
  if (user_role === 'Warlord') return 'warlord';
  if (user_role === ROLE_LIEUTENANT || user_role === ROLE_ASPIRANT) return 'lieutenant';
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
  patronsList: PatronType[],
  bypassRarity: boolean = false,
) => {

  const filteredWarbands = useMemo(() => {
    return warbandList.map(warband => ({
      ...warband,
      rarity_locked: !rarityFilter(warband, patronsList, bypassRarity),
    }));
  }, [warbandList, patronsList, bypassRarity]);

  const filteredSubtypes = useMemo(() => {
    if (!selectedWarband) {
      return [];
    }

    return subtypeList
      .filter(subtype => selectedWarband.subtypes?.[0]?.includes(subtype.type))
      .map(subtype => ({
        ...subtype,
        rarity_locked: !rarityFilter(subtype, patronsList, bypassRarity),
      }));
  }, [selectedWarband, subtypeList, patronsList, bypassRarity]);

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
        rarity_locked: !rarityFilter(aspect, patronsList, bypassRarity),
      }))
      .sort((a, b) => b.points - a.points);
  }, [selectedWarband, selectedSubtype, aspectList, patronsList, bypassRarity]);

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
      classe => rarityFilter(classe, patronsList, bypassRarity) && !suppressedTypes.has(classe.type),
    );

    const combine = (tier: Tier) => new Set(classSources.flatMap(s => tierList(s, tier)));
    const combinedWarlordClasses = combine('warlord');
    const combinedLieuClasses = combine('lieutenant');
    const combinedGruntClasses = combine('grunt');

    const warlordClasses = filteredRarity.filter(classe => combinedWarlordClasses.has(classe.type));
    const lieuClasses = filteredRarity.filter(classe => combinedLieuClasses.has(classe.type));
    const gruntClasses = filteredRarity.filter(classe => combinedGruntClasses.has(classe.type));

    return { warlord: warlordClasses, lieutenant: lieuClasses, grunt: gruntClasses };
  }, [selectedWarband, classSources, suppressedTypes, classList, patronsList, bypassRarity]);

  const availableClasses = useMemo(() => {
    const tier = tierForRole(user_role);
    if (!tier) return [];

    let roleClasses: ClassType[] = filteredClasses[tier];

    // if any active source replaces primaries, restrict this tier's primaries to those grants
    const exclusiveGrants = new Set(
      classSources.filter(s => s.suppress_all_other_classes).flatMap(s => tierList(s, tier)),
    );
    if (exclusiveGrants.size > 0) {
      roleClasses = roleClasses.filter(c => exclusiveGrants.has(c.type));
    }

    return roleClasses;
  }, [user_role, filteredClasses, selectedWarband, classSources]);

  const filteredSubclasses = useMemo(() => {
    if (!selectedWarband?.universal_subclasses_enabled) return [];

    const pool = classList.filter(
      c => rarityFilter(c, patronsList, bypassRarity) && !suppressedTypes.has(c.type),
    );

    if (selectedClass?.classes?.length) {
      const whitelist = new Set(selectedClass.classes);
      return pool.filter(c => whitelist.has(c.type));
    }

    const getUniversals = (classTypes: string[]) =>
      pool.filter(c => classTypes.includes(c.type));

    const warlordTypes = [...uniList(selectedWarband, 'warlord'), ...uniList(selectedSubtype, 'warlord')];
    const lieutenantTypes = [...uniList(selectedWarband, 'lieutenant'), ...uniList(selectedSubtype, 'lieutenant')];
    const gruntTypes = [...uniList(selectedWarband, 'grunt'), ...uniList(selectedSubtype, 'grunt')];

    if (user_role === 'Warlord') {
      const higher = getUniversals(warlordTypes);
      return higher.length > 0 ? higher : getUniversals(gruntTypes);
    }

    if (user_role === ROLE_LIEUTENANT || user_role === ROLE_ASPIRANT) {
      const higher = getUniversals(lieutenantTypes);
      return higher.length > 0 ? higher : getUniversals(gruntTypes);
    }

    if (user_role === 'Grunt') {
      return getUniversals(gruntTypes);
    }

    return [];
  }, [selectedWarband, selectedSubtype, selectedClass, user_role, classList, suppressedTypes, patronsList, bypassRarity]);

  return {
    filteredWarbands,
    filteredSubtypes,
    filteredAspects,
    availableClasses,
    filteredGruntClasses: filteredClasses.grunt,
    filteredSubclasses,
  };
};
