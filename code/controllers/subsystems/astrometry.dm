/var/datum/controller/subsystem/astrometry/SSastrometry

/datum/controller/subsystem/astrometry
    name = "Astrometry"
    flags = SS_NO_FIRE
    init_order = SS_INIT_MISC_FIRST

    var/list/datum/inner_system_object/inner_objs = list()
    var/list/datum/outer_system/outer_sys = list()

    var/min_inner = 3
    var/max_inner = 5
    var/min_outer = 8
    var/max_outer = 10

/datum/controller/subsystem/astrometry/New()
    NEW_SS_GLOBAL(SSastrometry)

/datum/controller/subsystem/astrometry/Initialize()
    . = ..()

    for (var/i in 1 to rand(min_inner, max_inner))
        inner_objs += new /datum/inner_system_object

    for (var/i in 1 to rand(min_outer, max_outer))
        outer_sys += new /datum/outer_system
