var/datum/controller/subsystem/xenoarch/SSxenoarch

/datum/controller/subsystem/xenoarch
	name = "Xenoarcheology"
	flags = SS_NO_FIRE
	init_order = SS_INIT_MISC
	var/list/digsites_by_tier = list(
		DIGSITE_OPEN = list(),
		DIGSITE_BURIED = list(),
		DIGSITE_RUIN = list(),
		DIGSITE_AWAY = list()
	)

/datum/controller/subsystem/xenoarch/New()
	NEW_SS_GLOBAL(SSxenoarch)

/datum/controller/subsystem/xenoarch/Initialize(timeofday)
	// current_map.build_digsites()
	return ..(timeofday)

/datum/controller/subsystem/xenoarch/proc/should_generate_ruins(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!istype(planet))
		log_debug("Invalid exoplanet [planet] attempted to queue SSxenoarch ruin generation pre-check")
		return

	return !(Clamp(length(digsites_by_tier[DIGSITE_RUIN]), 0, 1))

/datum/controller/subsystem/xenoarch/proc/generate_ruin(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!istype(planet))
		log_debug("Invalid exoplanet [planet] attempted to queue SSxenoarch ruin generation")
		return

	if(!should_generate_ruins(planet))
		return

	var/list/possible_ruins = list()

	for(var/datum/map_template/ruin/exoplanet/xenoarch/R in subtypesof(/datum/map_template/ruin/exoplanet/xenoarch))
		if(!(SSatlas.current_sector.name in R.sectors))
			continue

		possible_ruins[R] = R.spawn_weight

	if(length(possible_ruins))
		return pickweight(possible_ruins)

/datum/controller/subsystem/xenoarch/proc/generate_digsites(var/obj/effect/overmap/visitable/sector/exoplanet/planet)
	if(!istype(planet))
		log_debug("Invalid exoplanet [planet] attempted to queue SSxenoarch digsite generation")
		return

	var/list/digs = decls_repository.get_decls_of_subtype(/decl/digsite)
	var/list/decl/digsite/available_open = list()
	var/list/decl/digsite/available_mine = list()

	for(var/digtype in digs)
		var/valid = TRUE
		var/decl/digsite/D = decls_repository.get_decl(digtype)
		if(!(SSatlas.current_sector.name in D.allowed_sectors))
			continue

		if(!valid)
			continue

		if(D.digsite_type == DIGSITE_OPEN)
			available_open[D] = D.spawn_weight
		else
			available_mine[D] = D.spawn_weight

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
