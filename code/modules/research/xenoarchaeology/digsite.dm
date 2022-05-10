/decl/digsite
	var/name = "Example Digsite"	// Name of the digsite. For internal (non-player-facing) use only
	var/min_size = list("x" = 1, "y" = 1)		// Minimum size digsite will roll
	var/max_size = list("x" = 255, "y" = 255)	// Maximum size digsite will roll
	var/density = 30				// % chance each turf has a relic of any grade
	var/digsite_type = DIGSITE_OPEN
	// % chance of each strata appearing (see __defines/xenoarch.dm)
	// Strata are the main dividing categories of relics, associated with the facet of society / history they represent
	var/list/strata_weight = list(
		RELIC_CIVILIAN = 100
	)
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
		RELIC_CIVILIAN = list(
			RELIC_CURIO = 100
		)
	)
	var/list/allowed_sectors = ALL_POSSIBLE_SECTORS		// Whitelist for making digsites only appear in certain space sectors

/decl/digsite/proc/pick_relic()
	var/rel_stratum = pickweight(strata_weight)
	if(!ispath(rel_stratum))
		return
	var/rel_type = pickweight(type_weight[rel_stratum])
	if(!ispath(rel_type))
		return

	var/decl/relic_category/RC = decls_repository.get_decl(rel_stratum)
	if(!length(RC.relics))
		return

	var/rel_grade = pickweight(grade_weight)
	var/list/decl/relictypes = RC.relics[rel_grade]
	while(!length(relictypes))
		relictypes = pick(RC.relics)

	return pick(relictypes)

/decl/digsite/forest
	name = "Buried Forest"
	min_size = list("x" = 10, "y" = 10)
	max_size = list("x" = 20, "y" = 20)
	strata_weight = list(
		RELIC_XENOLIFE = 85,
		RELIC_CIVILIAN = 15
	)
	type_weight = list(
		RELIC_XENOLIFE = list(
			RELIC_REMAINS = 80,
			RELIC_MEDICAL = 20
		),
		RELIC_CIVILIAN = list(
			RELIC_REMAINS = 60,
			RELIC_CURIO = 30,
			RELIC_WEAPON = 10
		)
	)
