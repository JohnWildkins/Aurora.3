/decl/relic
    var/name = "Debug Relic"
    var/desc = "What?"
    var/item_path = /obj/random/loot
    var/grade = RELIC_SPECIAL

/decl/relic/proc/spawn_relic(var/turf/T)
    // Override this for randomization when the relic is uncovered.
    var/atom/A = new item_path(T)
    if(name)
        A.name = name
    if(desc)
        A.desc = desc

    return A
