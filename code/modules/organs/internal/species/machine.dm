/obj/item/organ/internal/heart/coolant_pump
    name = "liquid coolant pump"
    var/evaporating = FALSE

/obj/item/organ/internal/heart/coolant_pump/Initialize()
    . = ..()
    status |= ORGAN_ROBOT

/obj/item/organ/internal/heart/coolant_pump/process()
    if(owner)
        handle_coolant()
    ..()

/obj/item/organ/internal/heart/coolant_pump/proc/expend_coolant(var/amt, var/datum/gas_mixture/env)
    if(amt <= 0)
        return

    var/datum/reagents/coolant = owner.vessel
    if(env)
        var/temp_diff = owner.bodytemperature - owner.species.heat_level_1 // It's not realistic, but it helps make coolant not insanely strong.
        var/relative_density = env.total_moles / MOLES_CELLSTANDARD
        owner.bodytemperature -= Clamp(BODYTEMP_COOLING_MAX, (temp_diff / BODYTEMP_COLD_DIVISOR) * relative_density, BODYTEMP_HEATING_MAX)

    coolant.remove_reagent(/decl/reagent/blood/coolant, amt)
    var/CV = round(REAGENT_VOLUME(coolant, owner.species.blood))

    if(CV <= 0)
        warn_empty()

/obj/item/organ/internal/heart/coolant_pump/proc/warn_empty()
    status |= ORGAN_DEAD
    playsound(owner, 'sound/machines/click.ogg', 20, 1)
    to_chat(owner, SPAN_WARNING("You hear a sputter as your coolant pump stops dead. You're out of coolant!"))

/obj/item/organ/internal/heart/coolant_pump/proc/toggle_evaporating()
    evaporating = !evaporating
    playsound(owner, 'sound/machines/click.ogg', 20, 1)
    // to_chat(owner, evaporating ? SPAN_NOTICE("Your coolant pump whirrs, evaporating coolant to lower operating temperature.") : SPAN_NOTICE("Your coolant pump returns to idle, covering its evaporating fans once more."))
    return evaporating

/obj/item/organ/internal/heart/coolant_pump/proc/handle_coolant()
    var/mob/living/carbon/human/H = owner
    if (!istype(owner) || !H?.species)
        return

    var/datum/reagents/coolant = owner.vessel
    var/CV = round(REAGENT_VOLUME(coolant, owner.species.blood))
    var/coolant_fraction = (CV / owner.species.blood_volume)

    if(owner.species.passive_temp_gain)
        var/ideal_temp_gain = initial(owner.species.passive_temp_gain)
        if(ideal_temp_gain > 0)
            var/new_passive_temp_gain = ideal_temp_gain + (ideal_temp_gain ** (1.9 * (3 - coolant_fraction)))
            owner.species.passive_temp_gain = new_passive_temp_gain

    if ((!coolant || CV <= 0) && !(status & ORGAN_DEAD))
        warn_empty()
        return
    else if (CV > 0 && (status & ORGAN_DEAD))
        status &= ~ORGAN_DEAD
        playsound(H, 'sound/machines/click.ogg', 20, 1)
        to_chat(H, SPAN_WARNING("Your coolant pump starts up with a whirr and a series of clicks."))

    if(owner.bodytemperature >= owner.species.heat_level_1)
        var/turf/T = get_turf(H)
        var/datum/gas_mixture/env = T ? T.return_air() : null
        var/pressure = env ? env.return_pressure() : 0
        var/coolant_use = owner.bodytemperature / env.temperature
        if(pressure > 50 && coolant_use > 1)
            if(!evaporating)
                toggle_evaporating()
            expend_coolant(coolant_use, env)
        else if (evaporating)
            toggle_evaporating()
    else if(evaporating)
        toggle_evaporating()
