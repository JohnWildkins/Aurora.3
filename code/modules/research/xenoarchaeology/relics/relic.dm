/decl/relic
    var/name = "Debug Relic"
    var/desc = "What?"
    var/item_path = /obj/random/loot
    var/grade = RELIC_SPECIAL
    var/strata = RELIC_ANOMALY

/decl/relic/proc/spawn_relic(var/turf/T)
    // Override this for randomization when the relic is uncovered.
    if(!ispath(item_path))
        crash_with("[src] returned invalid item_path [item_path]")
        return

    if(!isturf(T))
        crash_with("[src] attempted to spawn in nullspace")
        return

    var/atom/A = new item_path(T)
    if(name)
        A.name = name
    if(desc)
        A.desc = desc

    return A
