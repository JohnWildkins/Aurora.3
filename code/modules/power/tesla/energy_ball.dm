#define TESLA_DEFAULT_POWER 1738260
#define TESLA_MINI_POWER 156250

// zap constants, speeds up targeting
#define COIL (ROD + 1)
#define ROD (EMITTER + 1)
#define EMITTER (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (STRUCTURE + 1)
#define STRUCTURE (1)

/obj/singularity/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	current_size = STAGE_TWO
	move_self = 1
	grav_pull = 0
	contained = 0
	density = TRUE
	energy = 0
	dissipate = TRUE
	dissipate_delay = 10
	dissipate_strength = 1
	layer = EFFECTS_ABOVE_LIGHTING_LAYER
	blend_mode = BLEND_ADD
	var/failed_direction = 0
	var/list/orbiting_balls = list()
	var/miniball = FALSE
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20
	var/list/shocked_things = list()
	var/list/immune_things = list(/obj/effect/projectile/muzzle/emitter, /obj/effect/ebeam, /obj/effect/decal/cleanable/ash, /obj/singularity)

/obj/singularity/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	miniball = is_miniball
	. = ..()
	if(!is_miniball)
		set_light(10, 7, "#5e5edd")

/obj/singularity/energy_ball/consume(atom/A)
	return

/obj/singularity/energy_ball/ex_act(severity, target)
	return

/obj/singularity/energy_ball/Destroy()
	walk(src, 0) // Stop walking
	if(orbiting && istype(orbiting.orbiting, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/EB = orbiting.orbiting
		EB.orbiting_balls -= src

	for(var/ball in orbiting_balls)
		var/obj/singularity/energy_ball/EB = ball
		QDEL_NULL(EB)

	. = ..()

/obj/singularity/energy_ball/process()
	if(!orbiting)
		handle_energy()

		move_the_basket_ball(4 + orbiting_balls.len * 1.5)

		playsound(src.loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)

		pixel_x = 0
		pixel_y = 0

		// Instead of miniballs shooting stuff, decided to make it just count the power produced.
		dir = tesla_zap(src, 10, TESLA_DEFAULT_POWER + orbiting_balls.len * TESLA_MINI_POWER)

		pixel_x = -32
		pixel_y = -32

	else
		energy = 0 // ensure we dont have miniballs of miniballs

/obj/singularity/energy_ball/admin_investigate_setup()
	if(miniball)
		return
	..()

/obj/singularity/energy_ball/examine(mob/user)
	. = ..()
	if(orbiting_balls.len)
		to_chat(user, "There are [orbiting_balls.len] energy balls orbiting it.")


/obj/singularity/energy_ball/proc/move_the_basket_ball(var/move_amount)

	var/list/valid_directions = alldirs.Copy()

	var/can_zmove = !(locate(/obj/machinery/containment_field) in view(12,src))
	if(can_zmove && prob(10))
		valid_directions.Add(UP)
		valid_directions.Add(DOWN)

	valid_directions.Remove(failed_direction)

	var/move_dir = 0
	if(target && prob(75))
		move_dir = get_dir(src, target)
	else
		valid_directions.Remove(dir)
		move_dir = (prob(50) && (dir != failed_direction)) ? dir : pick(valid_directions)

	if(move_dir & (UP | DOWN) )
		move_amount = 0

	var/move_tesla = !move_amount ? 0.1 : move_amount
	for(var/i in 0 to move_amount)
		do_single_move(move_dir)
		sleep(1 SECOND / move_tesla)

/obj/singularity/energy_ball/proc/do_single_move(var/move_dir)
	var/z_move = 0
	var/turf/T
	switch(move_dir)
		if(UP)
			T = GetAbove(src)
			z_move = 1
		if(DOWN)
			T = GetBelow(src)
			z_move = -1
		else
			T = get_step(src, move_dir)

	if(can_move(T) && can_dunk(get_turf(src),T,move_dir))
		switch(z_move)
			if(1)
				visible_message(SPAN_DANGER("\The [src] gravitates upwards!"))
				zMove(UP)
				visible_message(SPAN_DANGER("\The [src] gravitates from below!"))
			if(0)
				Move(T)
			if(-1)
				visible_message(SPAN_DANGER("\The [src] gravitates downwards!"))
				zMove(DOWN)
				visible_message(SPAN_DANGER("\The [src] gravitates from above!"))

		if(dir in alldirs)
			dir = move_dir
		else
			dir = pick(alldirs)

		for(var/mob/living/carbon/C in loc)
			dust_mobs(C)
		failed_direction = 0
	else
		failed_direction = move_dir

/obj/singularity/energy_ball/proc/can_dunk(var/turf/old_turf,var/turf/new_turf,var/move_direction)

	if(istype(new_turf,/turf/simulated/wall/r_wall))
		return FALSE

	if(istype(old_turf,/turf/simulated/floor/reinforced) && (move_direction & DOWN))
		return FALSE

	if(istype(new_turf,/turf/simulated/floor/reinforced) && (move_direction & UP))
		return FALSE

	return TRUE

/obj/singularity/energy_ball/proc/handle_energy()
	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 100)

	else if(energy < energy_to_lower && orbiting_balls.len)
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20
		energy = energy_to_raise - 5

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

	else if(orbiting_balls.len)

		// Basically the more balls we have the faster Tesla looses energy.
		if(orbiting_balls.len > 16)
			dissipate_delay = 1.5
			dissipate_strength = 5
		if(orbiting_balls.len > 12)
			dissipate_delay = 2.5
			dissipate_strength = 2
		if(orbiting_balls.len <= 12)
			dissipate_delay = 5
			dissipate_strength = 1

		dissipate() //sing code has a much better system.
	else // that is when we have no balls but our energy is less
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

/obj/singularity/energy_ball/proc/new_mini_ball()
	if(!loc)
		return
	var/obj/singularity/energy_ball/EB = new(loc, 0, FALSE, FALSE)

	EB.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
	var/icon/I = icon(icon,icon_state,dir)

	var/orbitsize = (I.Width() + I.Height()) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	EB.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))


/obj/singularity/energy_ball/Collide(atom/A)
	if(check_for_immune(A))
		return
	if(isliving(A))
		dust_mobs(A)
	else if(isobj(A))
		if(istype(A, /obj/effect/accelerated_particle))
			consume(A)
			return
		var/obj/O = A
		O.zap_act(0, (ZAP_OBJ_DAMAGE|ZAP_OBJ_MELT))

/obj/singularity/energy_ball/CollidedWith(atom/A)
	if(check_for_immune(A))
		return
	if(isliving(A))
		dust_mobs(A)
	else if(isobj(A))
		if(istype(A, /obj/effect/accelerated_particle))
			consume(A)
			return
		var/obj/O = A
		O.zap_act(0, (ZAP_OBJ_DAMAGE|ZAP_OBJ_MELT))

/obj/singularity/energy_ball/proc/check_for_immune(var/O)
	if(!O)
		return FALSE
	for(var/v in immune_things)
		if(istype(O, v))
			return TRUE
	return FALSE

/obj/singularity/energy_ball/Move(NewLoc, Dir)
	. = ..()
	for(var/v in view(0, loc))
		if(istype(v, /obj/singularity))
			continue

		if(isliving(v))
			dust_mobs(v)
		else if(isobj(v))
			var/obj/O = v
			O.zap_act(0, TRUE)

/obj/singularity/energy_ball/orbit(obj/singularity/energy_ball/target)
	if (istype(target))
		target.orbiting_balls += src
		target.dissipate_strength = target.orbiting_balls.len

	. = ..()

/obj/singularity/energy_ball/stop_orbit()
	if (orbiting && istype(orbiting.orbiting, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/orbitingball = orbiting.orbiting
		orbitingball.orbiting_balls -= src
		orbitingball.dissipate_strength = orbitingball.orbiting_balls.len
	. = ..()
	if (!loc && !QDELETED(src))
		qdel(src)

/obj/singularity/energy_ball/proc/dust_mobs(atom/A)
	if(!iscarbon(A))
		return
	for(var/obj/machinery/power/grounding_rod/GR in orange(src, 2))
		if(GR.anchored)
			return
	var/mob/living/carbon/C = A
	C.dust()

/obj/singularity/energy_ball/zap_act()
	return

/proc/tesla_zap(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list())
	. = source.dir
	if(power < 1000)
		return

	var/atom/closest_atom
	var/closest_type = 0
	var/static/list/blacklisted_types = typecacheof(list(
		/obj/machinery/atmospherics,
		/obj/machinery/field_generator,
		/mob/living/simple_animal,
		/obj/machinery/particle_accelerator/control_box,
		/obj/structure/particle_accelerator/fuel_chamber,
		/obj/structure/particle_accelerator/particle_emitter/center,
		/obj/structure/particle_accelerator/particle_emitter/left,
		/obj/structure/particle_accelerator/particle_emitter/right,
		/obj/structure/particle_accelerator/power_box,
		/obj/structure/particle_accelerator/end_cap,
		/obj/machinery/containment_field,
		/obj/structure/disposalpipe,
		/obj/structure/sign,
		/obj/machinery/gateway,
		/obj/structure/lattice,
		/obj/structure/grille,
		/obj/machinery/the_singularitygen/tesla,
		/obj/machinery/atmospherics/pipe
	))
	var/static/list/things_to_shock = typecacheof(list(
		/obj/machinery,
		/mob/living,
		/obj/structure
	))

	var/rods_count = 0
	/*
		We make an assumption here, that view() calculates from the center out --
		This means if we find an object, we can assume it's the closest of its type.
		This also means we don't need to track distance, as oview() will do it for us.
	*/
	for(var/a in typecache_filter_multi_list_exclusion(oview(zap_range + 2, source), things_to_shock, blacklisted_types))
		var/atom/A = a
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue
		if (closest_type >= COIL)
			break

		if(istype(source, /obj/singularity/energy_ball) && istype(A, /obj/machinery/power/tesla_beacon))
			var/obj/machinery/power/tesla_beacon/E = A
			var/obj/singularity/energy_ball/B = source
			if(!E.active)
				return
			B.visible_message("\The [B] discharges entirely at [A] until it dissapears and [A] melts down")
			B.Beam(E, icon_state="lightning[rand(1,12)]", icon = 'icons/effects/effects.dmi', time=2, maxdistance=beam_range)
			E.zap_act(0)
			qdel(B)
			return

		else if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/machinery/power/tesla_coil/C = A
			if(!HAS_TRAIT(C, TRAIT_SHOCKED))
				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_type = COIL
				closest_atom = C

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(closest_type >= EMITTER)
			continue

		else if(istype(A, /obj/machinery/power/emitter))
			closest_type = EMITTER
			closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !L.tesla_ignore && !HAS_TRAIT(L, TRAIT_SHOCKED))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(istype(A, /obj/machinery))
			if(!HAS_TRAIT(A, TRAIT_SHOCKED))
				closest_atom = A
				closest_type = MACHINERY

		else if(closest_type >= STRUCTURE)
			continue

		else if(istype(A, /obj/structure))
			if(!HAS_TRAIT(A, TRAIT_SHOCKED))
				closest_atom = A
				closest_type = STRUCTURE

	var/zap_flags_modified = zap_flags
	if(istype(source, /obj/singularity/energy_ball))
		var/obj/singularity/energy_ball/E = source
		if(E.energy && (E.orbiting_balls.len > rods_count * 4)) // so that miniballs don't fry stuff.
			zap_flags_modified |= ZAP_OBJ_MELT
			E.visible_message(SPAN_DANGER("All [E.orbiting_balls.len] energize for a second, sending their energy to the main ball, which redirects it at the nearest object! Sacrificing one of its miniballs!"))
			for(var/obj/singularity/energy_ball/mini in E.orbiting_balls)
				mini.Beam(source, icon_state="lightning[rand(1,12)]", icon = 'icons/effects/effects.dmi', time=2)
			playsound(source.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
			E.energy_to_raise = E.energy_to_raise / 1.25
			E.energy_to_lower = (E.energy_to_raise / 1.25) - 20
			E.energy = E.energy_to_raise - 5

			var/Orchiectomy_target = pick(E.orbiting_balls)
			qdel(Orchiectomy_target)
		E.dissipate()

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return

	//common stuff
	source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", icon = 'icons/effects/effects.dmi', time= 5)
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, closest_atom, TRUE)
	var/zapdir = get_dir(source, closest_atom)
	if(zapdir)
		. = zapdir

	var/next_range = 3
	//per type stuff:
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		ADD_TRAIT(closest_mob, TRAIT_SHOCKED, TRAIT_GENERIC)
		addtimer(TRAIT_CALLBACK_REMOVE(closest_mob, TRAIT_SHOCKED, TRAIT_GENERIC), 1 SECOND)

		var/shock_damage = (zap_flags_modified & ZAP_MOB_DAMAGE) ? (min(round(power/600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, tesla_shock = TRUE, stun = (zap_flags_modified & ZAP_MOB_STUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/S = closest_mob
			if((zap_flags_modified & ZAP_MOB_STUN) || (zap_flags_modified & ZAP_MOB_DAMAGE))
				S.emp_act(2)
			next_range = 7 // metallic folks bounce it further
		else
			next_range = 5

		power /= 1.5
	else
		power = closest_atom.zap_act(power, zap_flags_modified, shocked_targets)

	if(prob(20))
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags_modified, shocked_targets)
		tesla_zap(closest_atom, next_range, power * 0.5, zap_flags_modified, shocked_targets)
	else
		tesla_zap(closest_atom, next_range, power, zap_flags_modified, shocked_targets)

#undef TESLA_DEFAULT_POWER
#undef TESLA_MINI_POWER
#undef COIL
#undef ROD
#undef EMITTER
#undef LIVING
#undef MACHINERY
#undef STRUCTURE
