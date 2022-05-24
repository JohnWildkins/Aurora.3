/datum/society
	var/name = "Unknown Ecocluster"
	var/primary_stratum
	var/list/secondary_strata = list()
	var/list/banned_strata = list()
	var/age = 10 // in millions of years
	var/decl/society_background/government

	var/list/obj/effect/overmap/visitable/sector/exoplanet/planets		// All planets on the current map tied to this society
	var/obj/effect/overmap/visitable/sector/exoplanet/homeworld			// Homeworld doesn't necessarily mean the species' homeworld, but rather the planet that created this society on this map
	var/list/technology_levels = list()									// List of technologies -> levels (for relic generation primarily)
	var/list/digsites_by_tier = list(
		DIGSITE_OPEN = list(),
		DIGSITE_BURIED = list(),
		DIGSITE_RUIN = list(),
		DIGSITE_AWAY = list()
	)

/datum/society/New(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!planet)
		log_debug("Attempted to generate xenosociety without valid planet: [planet].")
		return FALSE
	LAZYINITLIST(planets)
	homeworld = planet
	planets += homeworld
	generate_strata()
	generate_info() // What strata we roll will define the reasonable parameters for generation
	log_debug("Society generated: [name] ([government])")
	log_debug("\tStrata selected: [primary_stratum] [secondary_strata[1]] [secondary_strata[2]]")

/datum/society/proc/generate_info()
	name = "Ecocluster [homeworld.planet_name]-[rand(1,100)]"
	var/list/govt_types = decls_repository.get_decls_of_subtype(/decl/society_background)
	var/list/decl/society_background/choices = list()
	for(var/gtype in govt_types)
		var/decl/society_background/GT = govt_types[gtype]
		var/valid = TRUE
		for(var/t in GT.req_tech_levels)
			if(get_tech_level(t) < GT.req_tech_levels[t])
				valid = FALSE
				break
		if(!valid)
			continue

		var/list/must_have = GT.stratum_whitelist + list(GT.primary_stratum)

		for(var/b in banned_strata)
			if(b in must_have)
				valid = FALSE
		if(!valid)
			continue

		if(primary_stratum == GT.primary_stratum)
			choices[GT] = 50
			must_have -= primary_stratum
		else if(primary_stratum in GT.stratum_whitelist)
			choices[GT] = 25
			must_have -= primary_stratum
		else if(!(primary_stratum in GT.stratum_blacklist))
			choices[GT] = 10

		for(var/ss in secondary_strata)
			if(ss in GT.stratum_blacklist)
				choices -= GT
				break
			if(ss in must_have)
				choices[GT] += 25
				must_have -= ss

		if(length(must_have))
			choices -= GT
			continue

	if(!length(choices))
		log_debug("Could not assign government to society [src]!")
		return

	government = pickweight(choices)

/datum/society/proc/generate_strata()
	var/list/avail_strata = decls_repository.get_decls_of_subtype(/decl/relic_category)
	if(!length(avail_strata))
		return // what how

	var/list/strata_choices = list()
	for(var/strata_type in avail_strata)
		var/decl/relic_category/RC = avail_strata[strata_type]
		if(!RC.normal_weight)
			banned_strata += strata_type
			continue
		strata_choices[strata_type] = RC.normal_weight

	primary_stratum = pickweight(strata_choices)
	strata_choices -= primary_stratum
	var/decl/relic_category/chosen_stratum = avail_strata[primary_stratum]

	for(var/strata_type in strata_choices)
		var/decl/relic_category/RC = avail_strata[strata_type]
		strata_choices[strata_type] = RC.sec_weight

	while(length(strata_choices) && length(secondary_strata) < 2)
		for(var/strata_type in strata_choices)
			strata_choices[strata_type] *= chosen_stratum.secondary_effects[strata_type]

		var/ch = pickweight(strata_choices)
		secondary_strata += ch
		strata_choices -= ch
		chosen_stratum = avail_strata[ch]

		CHECK_TICK

	for(var/S in strata_choices)
		banned_strata += S

	var/decl/relic_category/PS = avail_strata[primary_stratum]
	var/list/tech = PS.tech_bias

	for(var/T in tech)
		technology_levels[T] = tech[T]

	for(var/sec in secondary_strata)
		var/decl/relic_category/RC = avail_strata[sec]
		var/list/sec_tech = RC.tech_bias
		for(var/T in sec_tech)
			technology_levels[T] += Clamp(sec_tech[T], -1, 1) // Hurts tech gains more than losses, which is intentional

	// sanity check
	for(var/T in technology_levels)
		technology_levels[T] = Clamp(technology_levels[T], TL_NONE, TL_MASTER)

/datum/society/proc/get_tech_level(var/tech)
	return (tech in technology_levels) ? technology_levels[tech] : null
