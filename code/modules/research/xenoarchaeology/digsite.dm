/decl/digsite
	var/name = "Example Digsite"	// Name of the digsite. For internal (non-player-facing) use only
	var/min_size = list("x" = 1, "y" = 1)		// Minimum size digsite will roll
	var/max_size = list("x" = 255, "y" = 255)	// Maximum size digsite will roll
	var/density = 30				// % chance each turf has a relic of any grade
	var/digsite_type = DIGSITE_OPEN
	var/spawn_weight = 1
	var/relic_blacklist = list()
	var/relic_whitelist = list()
	// % chance a given relic will be of a certain grade
	// Grade is roughly correlated to how powerful / dangerous / unique a relic is
	var/list/grade_weight = list(
		RELIC_MUNDANE = 65,
		RELIC_UNCOMMON = 25,
		RELIC_RARE = 10,
		RELIC_ANTAG = 0,
		RELIC_SPECIAL = 0
	)
	// Nested dict determining % chance of a given relic in a selected strata will be of a certain type
	// format: STRATA = list(TYPE = CHANCE, TYPE = CHANCE), STRATA = list()...
	var/list/type_weight = list(
		RELIC_CURIO = 100
	)
	var/list/allowed_sectors = ALL_POSSIBLE_SECTORS		// Whitelist for making digsites only appear in certain space sectors

/decl/digsite/proc/pick_relic()
	var/rel_type = pickweight(type_weight)
	if(!ispath(rel_type))
		return

	var/rel_grade = pickweight(grade_weight)
	if(!ispath(rel_grade))
		return

	var/list/decl/avail_relics
	if(length(relic_whitelist))
		for(var/RT in relic_whitelist)
			var/decl/relic/R = decls_repository.get_decl(RT)
			if(istype(R) && R.grade == rel_grade && istype(R, rel_type))
				avail_relics += R
	else
		var/list/relictypes = decls_repository.get_decls_of_subtype(rel_type)
		for(var/RT in relictypes)
			if(RT in relic_blacklist)
				continue
			var/decl/relic/R = decls_repository.get_decl(RT)
			if(R.grade == rel_grade)
				avail_relics += R

	if(length(avail_relics))
		return pick(avail_relics)

/decl/digsite/debug
	name = "Debug Zone"
	min_size = list("x" = 10, "y" = 10)
	max_size = list("x" = 20, "y" = 20)
	type_weight = list(
		RELIC_TRAP = 10,
		RELIC_CURIO = 10,
		RELIC_MEDICAL = 10,
		RELIC_TOOL = 10,
		RELIC_POWER = 10,
		RELIC_WEAPON = 10,
		RELIC_DEVICE = 10,
		RELIC_VEHICLE = 10,
		RELIC_REMAINS = 10
	)

/decl/digsite/forest
	name = "Buried Forest"
	min_size = list("x" = 10, "y" = 10)
	max_size = list("x" = 20, "y" = 20)
	type_weight = list(
		RELIC_REMAINS = 80,
		RELIC_MEDICAL = 20,
		RELIC_CURIO = 30,
		RELIC_WEAPON = 10
	)
