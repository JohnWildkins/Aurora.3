/decl/relic
    var/name = "Debug Relic"
    var/desc = "What?"
    var/item_path = /obj/random/loot
    var/grade = RELIC_SPECIAL
    var/strata = RELIC_ANOMALY

/decl/relic/proc/new_relic(var/datum/society/S, var/turf/T)
    // Randomize stuff here, if necessary.
    if(!S)
        return
    if(!ispath(item_path))
        crash_with("[src] returned invalid item_path [item_path]")
        return
    if(!isturf(T))
        crash_with("[src] attempted to spawn in nullspace")
        return

    return new item_path(T)

/decl/relic/proc/spawn_relic(var/turf/T)
    // Override this for randomization when the relic is uncovered.
    var/atom/A = new item_path(T)
    if(name)
        A.name = name
    if(desc)
        A.desc = desc

    return A

/decl/relic_category
    var/name = "default"
    var/normal_weight = 0
    var/sec_weight = 50
    var/list/secondary_effects = list()     // Every secondary strata has a 50% of being selected by default
                                            // Each selected strata will affect that chance, sometimes significantly

    var/list/tech_bias = list()
    var/list/relics = list(
        RELIC_MUNDANE = list(),
        RELIC_UNCOMMON = list(),
        RELIC_RARE = list(),
        RELIC_ANTAG = list(),
        RELIC_SPECIAL = list()
    )

/decl/relic_category/Initialize()
    ..()
    var/list/all_relictypes = decls_repository.get_decls_of_subtype()
    for(var/relictype in all_relictypes)
        var/decl/relic/R = decls_repository.get_decl(relictype)
        if(R.strata == type)
            relics[R.grade] = relictype

/decl/relic_category/mil
    name = "Military"
    normal_weight = 15
    secondary_effects = list(
        RELIC_CIVILIAN = 1.1,
        RELIC_RELIGION = 1,
        RELIC_INDUSTRIAL = 1.25,
        RELIC_XENOLIFE = 1
    )
    tech_bias = list(
        XENOTECH_ENV = 0,
        XENOTECH_TRAVEL = 1,
        XENOTECH_ELEC = 1,
        XENOTECH_MED = 1,
        XENOTECH_AI = 2,
        XENOTECH_MIL = 2
    )

/decl/relic_category/civ
    name = "Civilian"
    normal_weight = 30
    secondary_effects = list(
        RELIC_MILITARY = 1,
        RELIC_RELIGION = 1,
        RELIC_INDUSTRIAL = 1,
        RELIC_XENOLIFE = 0.5
    )
    tech_bias = list(
        XENOTECH_ENV = 2,
        XENOTECH_TRAVEL = 1,
        XENOTECH_ELEC = 2,
        XENOTECH_MED = 1,
        XENOTECH_AI = 1,
        XENOTECH_MIL = 1
    )

/decl/relic_category/rel
    name = "Religion"
    normal_weight = 20
    secondary_effects = list(
        RELIC_MILITARY = 1.2,
        RELIC_CIVILIAN = 1,
        RELIC_INDUSTRIAL = 0.75,
        RELIC_XENOLIFE = 0.75
    )
    tech_bias = list(
        XENOTECH_ENV = 0,
        XENOTECH_TRAVEL = 0,
        XENOTECH_ELEC = 0,
        XENOTECH_MED = -1,
        XENOTECH_AI = -2,
        XENOTECH_MIL = 0
    )

/decl/relic_category/ind
    name = "Industrial"
    normal_weight = 20
    secondary_effects = list(
        RELIC_MILITARY = 1,
        RELIC_CIVILIAN = 2,
        RELIC_RELIGION = 0.5,
        RELIC_XENOLIFE = 0.25
    )
    tech_bias = list(
        XENOTECH_ENV = -1,
        XENOTECH_TRAVEL = 2,
        XENOTECH_ELEC = 2,
        XENOTECH_MED = 0,
        XENOTECH_AI = 2,
        XENOTECH_MIL = 1
    )

/decl/relic_category/xen
    name = "Xenolife"
    normal_weight = 15
    secondary_effects = list(
        RELIC_MILITARY = 1,
        RELIC_CIVILIAN = 0.5,
        RELIC_RELIGION = 1,
        RELIC_INDUSTRIAL = 0.5
    )
    tech_bias = list(
        XENOTECH_ENV = -1,
        XENOTECH_TRAVEL = -1,
        XENOTECH_ELEC = -1,
        XENOTECH_MED = -1,
        XENOTECH_AI = -1,
        XENOTECH_MIL = 1
    )

/decl/relic_category/ano
    name = "Anomalous"
    normal_weight = 0
    secondary_effects = list()
