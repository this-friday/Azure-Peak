// returns a warband source's class list for a given role tier
/datum/warband_manager/proc/tier_classes_for(datum/warbands/source, role)
	if(!source)
		return list()
	if(role == ROLE_WARLORD)
		return source.warlordclasses || list()
	if(role == ROLE_WARLORD_LIEUTENANT || role == ROLE_WARLORD_ASPIRANT)
		return source.lieutenantclasses || list()
	return source.gruntclasses || list()

// returns a warband source's universal-class list for a given role tier
/datum/warband_manager/proc/universal_subclasses_for(datum/warbands/source, role)
	if(!source)
		return list()
	if(role == ROLE_WARLORD)
		return source.universal_warlordclasses || list()
	if(role == ROLE_WARLORD_LIEUTENANT || role == ROLE_WARLORD_ASPIRANT)
		return source.universal_lieutenantclasses || list()
	return source.universal_gruntclasses || list()

// every warband datum contributing class grants: the warband, its subtype, and each aspect
/datum/warband_manager/proc/class_grant_sources()
	var/list/sources = list()
	if(selected_warband)
		sources += selected_warband
	if(selected_subtype)
		sources += selected_subtype
	for(var/datum/warbands/aspects/aspect in selected_aspects)
		sources += aspect
	return sources

// collects every class path suppressed by the current selections
/datum/warband_manager/proc/suppressed_class_paths()
	var/list/suppressed = list()
	for(var/datum/warbands/source in class_grant_sources())
		if(source.suppressed_classes)
			suppressed |= source.suppressed_classes
	return suppressed

// the primary class paths this warband may field for the given role
/datum/warband_manager/proc/allowed_primaries(role)
	var/list/granted = list()
	var/list/exclusive = list()
	var/list/suppressed = suppressed_class_paths()
	for(var/datum/warbands/source in class_grant_sources())
		var/list/tier_list = tier_classes_for(source, role)
		if(tier_list.len)
			granted |= tier_list
			if(source.suppress_all_other_classes)
				exclusive |= tier_list

	var/list/primaries = list()
	for(var/class_type in granted)
		if(class_type in suppressed)
			continue
		primaries += class_type
	if(exclusive.len)
		var/list/restricted = list()
		for(var/class_type in primaries)
			if(class_type in exclusive)
				restricted += class_type
		primaries = restricted
	return primaries

// the subclass paths available beneath the given primary for the given role
/datum/warband_manager/proc/allowed_subclasses(role, class_path)
	var/list/suppressed = suppressed_class_paths()
	var/list/subclass_pool = list()
	var/registered = SSwarbands.all_warband_class_types[class_path]
	if(registered && initial(class_path:use_subclasses))
		for(var/sub_type in subtypesof(class_path))
			if(SSwarbands.all_warband_class_types[sub_type] && !(sub_type in suppressed))
				subclass_pool += sub_type
	else if(registered && length(initial(class_path:classes)))
		for(var/sub_type in initial(class_path:classes))
			if(!(sub_type in suppressed))
				subclass_pool += sub_type
	else if(selected_warband?.universal_subclasses_enabled) // when we're using the Universal Subclass list:
		var/list/tier_types = universal_subclasses_for(selected_warband, role) + universal_subclasses_for(selected_subtype, role)
		for(var/class_type in tier_types)
			if(class_type in suppressed)
				continue
			subclass_pool += class_type
		if(!subclass_pool.len) // roles without their own universal options share the grunt-tier pool
			var/list/grunt_types = universal_subclasses_for(selected_warband, ROLE_WARLORD_GRUNT) + universal_subclasses_for(selected_subtype, ROLE_WARLORD_GRUNT)
			for(var/class_type in grunt_types)
				if(class_type in suppressed)
					continue
				subclass_pool += class_type
	return subclass_pool

// counts this warband's members holding the given class: spawned characters plus current ready-up picks
// exclude_user keeps a member's own ready entry from blocking them when they re-validate
/datum/warband_manager/proc/class_slot_count(class_path, mob/exclude_user)
	var/count = taken_class_counts[class_path] || 0
	for(var/ckey in ready_members)
		if(exclude_user && ckey == exclude_user.ckey)
			continue
		var/list/stored = ready_members[ckey]
		if(!islist(stored))
			continue
		if(text2path(stored["class"]) == class_path)
			count++
		else if(stored["subclass"] && text2path(stored["subclass"]) == class_path)
			count++
	return count

// TRUE if the class still has an open slot in this warband
/datum/warband_manager/proc/class_slots_available(class_path, mob/user)
	var/max_slots = initial(class_path:maximum_possible_slots)
	if(max_slots < 0)
		return TRUE
	return class_slot_count(class_path, user) < max_slots

// strips classes whose maximum_possible_slots are already occupied
/datum/warband_manager/proc/filter_full_classes(list/class_pool, mob/user)
	var/list/open = list()
	for(var/class_path in class_pool)
		if(class_slots_available(class_path, user))
			open += class_path
	return open

/datum/warband_manager/proc/validate_class_selection(mob/user, class_path, subclass_path)
	if(!ispath(class_path, /datum/advclass))
		return FALSE
	if(!(class_path in allowed_primaries(user.mind?.special_role)))
		return FALSE
	if(!class_slots_available(class_path, user))
		return FALSE
	if(subclass_path)
		if(!ispath(subclass_path, /datum/advclass))
			return FALSE
		if(!(subclass_path in allowed_subclasses(user.mind?.special_role, class_path)))
			return FALSE
		if(!class_slots_available(subclass_path, user))
			return FALSE
	return TRUE
