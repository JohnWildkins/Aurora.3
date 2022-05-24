var/datum/controller/subsystem/xenoarch/SSxenoarch

/datum/controller/subsystem/xenoarch
	name = "Xenoarcheology"
	flags = SS_NO_FIRE
	init_order = SS_INIT_MISC
	var/list/planet_societies = list()			// Societies and their associated planets/objs

/datum/controller/subsystem/xenoarch/New()
	NEW_SS_GLOBAL(SSxenoarch)

/datum/controller/subsystem/xenoarch/Initialize(timeofday)
	// current_map.build_digsites()
	return ..(timeofday)

/datum/controller/subsystem/xenoarch/proc/get_society(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(planet in planet_societies)
		return planet_societies[planet]

	if(!length(planet_societies))
		planet_societies[planet] = new /datum/society(planet)
		return planet_societies[planet]

	for(var/obj/effect/overmap/visitable/sector/exoplanet/existing in planet_societies)
		if(existing.habitability_class <= planet.habitability_class && prob(25))
			// New planet is similarly habitable or moreso
			planet_societies[planet] = planet_societies[existing]
			break
		var/datum/society/S = planet_societies[existing]
		if(S.get_tech_level(XENOTECH_TRAVEL) >= TL_ADV && prob(50))
			// They had space travel capabilities, so at least some trace of them is expected
			planet_societies[planet] = planet_societies[existing]
			break
		if(S.get_tech_level(XENOTECH_ENV) >= TL_EXPERT && prob(75))
			// They had the capabilities terraform or otherwise habitate the planet
			planet_societies[planet] = planet_societies[existing]
			break

	if(!(planet in planet_societies)) // Check if we still don't have a society (uh oh)
		planet_societies[planet] = new /datum/society(planet)

	return planet_societies[planet]

/datum/controller/subsystem/xenoarch/proc/should_generate_ruins(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!istype(planet))
		log_debug("Invalid exoplanet [planet] attempted to queue SSxenoarch ruin generation pre-check")
		return

	var/datum/society/S = get_society(planet)
	return !(Clamp(length(S.digsites_by_tier[DIGSITE_RUIN]), 0, 1))

/datum/controller/subsystem/xenoarch/proc/generate_ruin(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!istype(planet))
		log_debug("Invalid exoplanet [planet] attempted to queue SSxenoarch ruin generation")
		return

	if(!should_generate_ruins(planet))
		return

	var/datum/society/S = get_society(planet)
	var/list/possible_ruins = list()

	for(var/datum/map_template/ruin/exoplanet/xenoarch/R in subtypesof(/datum/map_template/ruin/exoplanet/xenoarch))
		if(R.primary_stratum in S.banned_strata || R.secondary_stratum in S.banned_strata)
			continue

		if(!(SSatlas.current_sector.name in R.sectors))
			continue

		possible_ruins[R.primary_stratum] = R

	for(var/strata in S.primary_stratum) // should only ever be one
		if(!length(possible_ruins[strata]))
			break
		if(!length(S.secondary_strata) || prob(75)) // if there's no secondary strata we have to grab from here
			return pick(possible_ruins[strata])

	var/list/possible_strata = S.secondary_strata.Copy()
	while(length(possible_strata))
		var/strata = popleft(possible_strata)
		if(!length(possible_ruins[strata]))
			continue
		if(!length(possible_strata) || prob(25))
			return pick(possible_ruins[strata])
		else
			continue

/datum/controller/subsystem/xenoarch/proc/generate_digsites(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!istype(planet))
		log_debug("Invalid exoplanet [planet] attempted to queue SSxenoarch digsite generation")
		return

	var/datum/society/S = get_society(planet)

	var/list/digs = decls_repository.get_decls_of_subtype(/decl/digsite)
	var/list/decl/digsite/available_open = list()
	var/list/decl/digsite/available_mine = list()

	for(var/digtype in digs)
		var/valid = TRUE
		var/decl/digsite/D = decls_repository.get_decl(digtype)
		if(!(SSatlas.current_sector.name in D.allowed_sectors))
			continue
		for(var/B in S.banned_strata)
			if(B in D.strata_weight)
				valid = FALSE
				break

		if(!valid)
			continue

		var/weight = 1

		if(S.primary_stratum in D.strata_weight)
			weight = 3

		if(D.digsite_type == DIGSITE_OPEN)
			available_open[D] = weight
		else
			available_mine[D] = weight

	var/list/decl/digsite/to_generate = list()
	for(var/i in 1 to rand(1, 3))
		to_generate += pickweight(available_open)

	var/remaining_digs = min(rand(2, 4) - length(to_generate), 1)

	for(var/i in 1 to remaining_digs)
		to_generate += pickweight(available_mine)

	for(var/decl/digsite/D in to_generate)
		var/gen_x = rand(D.min_size[1], D.max_size[1])
		var/gen_y = rand(D.min_size[2], D.max_size[2])
		var/max_x = planet.maxx
		var/max_y = planet.maxy

		var/width = TRANSITIONEDGE + RUIN_MAP_EDGE_PAD + round(gen_x / 2)
		var/height = TRANSITIONEDGE + RUIN_MAP_EDGE_PAD + round(gen_y / 2)
		if (width > max_x - width || height > max_y - height)
			log_debug("Digsite [D] failed to be placed: available area too small")
			continue

		var/list/turf/digsite_turfs = list()

		for (var/attempts = 20, attempts > 0, --attempts)
			var/z = pick(planet.map_z)
			var/turf/choice = locate(rand(width, max_x - width), rand(height, max_y - height), z)
			digsite_turfs = block(choice, locate(choice.x + width-1, choice.y + height-1, choice.z))
			var/valid = TRUE
			for(var/turf/check in digsite_turfs)
				var/area/check_area = get_area(check)
				if(!istype(check_area, /area/exoplanet) || check.flags & TURF_NORUINS)
					valid = FALSE
					break

			if(valid)
				log_debug("Digsite \"[D.name]\" placed at ([choice.x], [choice.y], [choice.z])!")
				for(var/turf/T in digsite_turfs)
					// TODO UPDATE XENOARCH: make this not demolish ruins (aka set TURF_NORUINS on existing ruins)
					if(D.digsite_type == DIGSITE_OPEN)
						if(T.density)
							T.ChangeTurf(get_base_turf_by_area(T))

						if(!prob(D.density))
							continue

						var/decl/relic/R = D.pick_relic()
						if(!istype(R))
							continue

						T.relictype = R
					else if(D.digsite_type == DIGSITE_BURIED)
						if(!istype(T, /turf/simulated/mineral))
							T.ChangeTurf(/turf/simulated/mineral)

						if(!prob(D.density))
							continue

						var/decl/relic/R = D.pick_relic()
						if(!istype(R))
							continue

						T.relictype = R
				break
