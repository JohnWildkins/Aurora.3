/obj/item/ore/sample
    name = "rock sample"
    desc = "An archaeological sample, excavated from a dig site."
    icon = 'icons/obj/xenoarchaeology.dmi'
    icon_state = "strange"
    origin_tech = list(TECH_MATERIAL = 2)
    var/decl/relic/contained
    var/exposed_relic = FALSE

/obj/item/ore/sample/Initialize(mapload, var/decl/relic)
    if(istype(relic))
        contained = relic
    return ..()

/obj/item/ore/sample/attackby(obj/item/W, mob/user)
    if(exposed_relic)
        if(W.ishammer())
            to_chat(user, SPAN_NOTICE("You begin to chisel away the rock surrounding \the [contained.name]."))
            if(do_after(user, (5 SECONDS)/W.toolspeed))
                break_sample(user)
                return TRUE
    else if(!exposed_relic)
        if(istype(W, /obj/item/brush))
            to_chat(user, SPAN_NOTICE("You begin to carefully brush away fragments of rock and soil, attempting to reveal what lies within."))
            if(do_after(user, (3 SECONDS)/W.toolspeed))
                reveal_sample(user)
            return TRUE
        else if(W.ishammer() && user.a_intent == I_HURT)
            to_chat(user, SPAN_WARNING("You begin to carelessly hammer away at the sample, attempting to reveal what's inside..."))
            if(do_after(user, (5 SECONDS)/W.toolspeed))
                if(prob(66))
                    break_sample(user)
                else
                    break_sample(user, FALSE)
            return TRUE
    return ..()

/obj/item/ore/sample/proc/break_sample(var/mob/user, var/spawn_relic=TRUE)
    if(!spawn_relic)
        user.visible_message(
            SPAN_WARNING("[user] carelessly smashes \the [src] into pieces!"), \
            SPAN_WARNING("You carelessly smash \the [src] into pieces, destroying whatever lay within.")
        )
        qdel(src)
        return
    var/atom/A = contained.spawn_relic(get_turf(src))
    if(!istype(A))
        crash_with("Failed to spawn relic of type [contained]: returned [A]!")
        return
    user.visible_message(
        SPAN_WARNING("[user] breaks open the [src] to reveal \a [contained.name]!"),
        SPAN_WARNING("You break open the [src] and reveal \the [contained.name]")
    )
    if(user.get_type_in_hands(src.type))
        user.drop_from_inventory(src)
        user.put_in_hands(A)
    qdel(src)

/obj/item/ore/sample/proc/reveal_sample(var/mob/user)
    if(istype(contained))
        to_chat(user, SPAN_NOTICE("You brush away enough of the sample to reveal \a [contained.name] hidden within."))
        desc += " This particular sample appears to have \a [contained.name] buried within."
        exposed_relic = TRUE
    else
        to_chat(user, SPAN_NOTICE("The sample appears to be empty."))
        desc += " This particular sample contains nothing of archaeological value."
