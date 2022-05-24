/**********************Mineral deposits**************************/
/turf/unsimulated/mineral
	name = "impassable rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock-dark"
	blocks_air = TRUE
	density = TRUE
	gender = PLURAL
	opacity = TRUE

// This is a global list so we can share the same list with all mineral turfs; it's the same for all of them anyways.
var/list/mineral_can_smooth_with = list(
	/turf/simulated/mineral,
	/turf/simulated/wall,
	/turf/unsimulated/wall
)

// Some extra types for the surface to keep things pretty.
/turf/simulated/mineral/surface
	mined_turf = /turf/unsimulated/floor/asteroid/ash

/turf/simulated/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/map_placeholders.dmi'
	icon_state = "rock"
	desc = "It's a greyish rock. Exciting."
	gender = PLURAL
	var/icon/actual_icon = 'icons/turf/smooth/rock_wall.dmi'
	layer = 2.01

	// canSmoothWith is set in Initialize().
	smooth = SMOOTH_MORE | SMOOTH_BORDER | SMOOTH_NO_CLEAR_ICON
	smoothing_hints = SMOOTHHINT_CUT_F | SMOOTHHINT_ONLY_MATCH_TURF | SMOOTHHINT_TARGETS_NOT_UNIQUE

	oxygen = 0
	nitrogen = 0
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	temperature = T0C
	var/mined_turf = /turf/unsimulated/floor/asteroid/ash
	var/ore/mineral
	var/mined_ore = 0
	var/last_act = 0
	var/emitter_blasts_taken = 0 // EMITTER MINING! Muhehe.

	var/obj/effect/mineral/my_mineral

	var/rock_health = 20 //10 to 20, in initialize

	has_resources = TRUE

/turf/simulated/mineral/proc/kinetic_hit(var/damage)
	rock_health -= damage
	if(rock_health <= 0)
		GetDrilled()

// Copypaste parent call for performance.
/turf/simulated/mineral/Initialize(mapload)
	if(initialized)
		crash_with("Warning: [src]([type]) initialized multiple times!")

	if(icon != actual_icon)
		icon = actual_icon

	initialized = TRUE

	turfs += src

	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	has_opaque_atom = TRUE

	if(smooth)
		canSmoothWith = mineral_can_smooth_with
		pixel_x = -4
		pixel_y = -4
		queue_smooth(src)

	if(!mapload)
		queue_smooth_neighbors(src)

	rock_health = rand(10,20)

	return INITIALIZE_HINT_NORMAL

/turf/simulated/mineral/examine(mob/user)
	..()
	if(mineral)
		switch(mined_ore)
			if(0)
				to_chat(user, SPAN_INFO("It is ripe with [mineral.display_name]."))
			if(1)
				to_chat(user, SPAN_INFO("Its [mineral.display_name] looks a little depleted."))
			if(2)
				to_chat(user, SPAN_INFO("Its [mineral.display_name] looks very depleted!"))
	else
		to_chat(user, SPAN_INFO("It is devoid of any valuable minerals."))
	switch(emitter_blasts_taken)
		if(0)
			to_chat(user, SPAN_INFO("It is in pristine condition."))
		if(1)
			to_chat(user, SPAN_INFO("It appears a little damaged."))
		if(2)
			to_chat(user, SPAN_INFO("It is crumbling!"))
		if(3)
			to_chat(user, SPAN_INFO("It looks ready to collapse at any moment!"))

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(2.0)
			if (prob(70))
				mined_ore = 1 //some of the stuff gets blown up
				GetDrilled()
			else
				emitter_blasts_taken += 2
		if(1.0)
			mined_ore = 2 //some of the stuff gets blown up
			GetDrilled()

/turf/simulated/mineral/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam/plasmacutter))
		var/obj/item/projectile/beam/plasmacutter/PC_beam = Proj
		var/list/cutter_results = PC_beam.pass_check(src)
		. = cutter_results[1]
		if(cutter_results[2]) // the cutter mined the turf, just pass on
			return

	// Emitter blasts
	if(istype(Proj, /obj/item/projectile/beam/emitter))
		emitter_blasts_taken++

	if(emitter_blasts_taken >= 3)
		GetDrilled()

/turf/simulated/mineral/CollidedWith(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/pickaxe)) && (!H.hand))
			var/obj/item/pickaxe/P = H.l_hand
			if(P.autodrill)
				attackby(H.l_hand,H)

		else if((istype(H.r_hand,/obj/item/pickaxe)) && H.hand)
			var/obj/item/pickaxe/P = H.r_hand
			if(P.autodrill)
				attackby(H.r_hand,H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)

//For use in non-station z-levels as decoration.
/turf/unsimulated/mineral/asteroid
	name = "rock"
	icon = 'icons/turf/map_placeholders.dmi'
	icon_state = "rock"
	desc = "It's a greyish rock. Exciting."
	opacity = TRUE
	var/icon/actual_icon = 'icons/turf/smooth/rock_wall.dmi'
	layer = 2.01
	var/list/asteroid_can_smooth_with = list(
		/turf/unsimulated/mineral,
		/turf/unsimulated/mineral/asteroid
	)
	smooth = SMOOTH_MORE | SMOOTH_BORDER | SMOOTH_NO_CLEAR_ICON
	smoothing_hints = SMOOTHHINT_CUT_F | SMOOTHHINT_ONLY_MATCH_TURF | SMOOTHHINT_TARGETS_NOT_UNIQUE

/turf/unsimulated/mineral/asteroid/Initialize(mapload)
	if(initialized)
		crash_with("Warning: [src]([type]) initialized multiple times!")

	if(icon != actual_icon)
		icon = actual_icon

	initialized = TRUE

	turfs += src

	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	has_opaque_atom = TRUE

	if(smooth)
		canSmoothWith = asteroid_can_smooth_with
		pixel_x = -4
		pixel_y = -4
		queue_smooth(src)

	if(!mapload)
		queue_smooth_neighbors(src)

	return INITIALIZE_HINT_NORMAL

#define SPREAD(the_dir) \
	if (prob(mineral.spread_chance)) {                              \
		var/turf/simulated/mineral/target = get_step(src, the_dir); \
		if (istype(target) && !target.mineral) {                    \
			target.mineral = mineral;                               \
			target.UpdateMineral();                                 \
			target.MineralSpread();                                 \
		}                                                           \
	}

/turf/simulated/mineral/proc/MineralSpread()
	if(mineral && mineral.spread)
		SPREAD(NORTH)
		SPREAD(SOUTH)
		SPREAD(EAST)
		SPREAD(WEST)

#undef SPREAD

/turf/simulated/mineral/proc/UpdateMineral()
	clear_ore_effects()
	if(!mineral)
		name = "\improper Rock"
		icon_state = "rock"
		return
	name = "\improper [mineral.display_name] deposit"
	new /obj/effect/mineral(src, mineral)

/turf/simulated/mineral/attackby(obj/item/W, mob/user)
	if(use_check_and_message(user))
		return FALSE

	if(istype(W, /obj/item/pickaxe) && W.simulated)	// Pickaxe offhand is not simulated.
		var/turf/T = get_turf(user)
		if(!istype(T))
			return TRUE
		var/obj/item/pickaxe/P = W
		if(P.drilling)
			return TRUE

		P.drilling = TRUE

		to_chat(user, SPAN_WARNING("You start [P.drill_verb] \the [src]."))

		if(P.use_tool(src, user, P.digspeed, volume = 20))
			if(!istype(src, /turf/simulated/mineral))
				return TRUE

			P.drilling = FALSE

			if(prob(50))
				var/obj/item/ore/O
				if(prob(25) && (mineral) && (P.excavation_amount >= 30))
					O = new mineral.ore(src)
				else
					O = new /obj/item/ore(src)
				addtimer(CALLBACK(O, /atom/movable/.proc/forceMove, user.loc), 1)

			GetDrilled(P.relic_chance)
			return TRUE

		else
			to_chat(user, SPAN_NOTICE("You stop [P.drill_verb] \the [src]."))
			P.drilling = FALSE
		// TODO UPDATE XENOARCH

	if(istype(W, /obj/item/autochisel))
		to_chat(user, SPAN_NOTICE("You start chiselling \the [src] into a sculptable block."))

		if(!W.use_tool(src, user, 8 SECONDS, volume = 50))
			return TRUE

		if(!istype(src, /turf/simulated/mineral))
			return TRUE

		to_chat(user, SPAN_NOTICE("You finish chiselling \the [src] into a sculptable block."))
		new /obj/structure/sculpting_block(src)
		GetDrilled()

// /turf/simulated/mineral/proc/get_geodata()
// 	if(!geologic_data)
// 		geologic_data = new /datum/geosample(src)
// 	geologic_data.UpdateNearbyArtifactInfo(src)
// 	return geologic_data
// TODO UPDATE XENOARCH

/turf/simulated/mineral/proc/clear_ore_effects()
	if(my_mineral)
		qdel(my_mineral)

/turf/simulated/mineral/proc/DropMineral()
	if(!mineral)
		return

	clear_ore_effects()
	var/obj/item/ore/O = new mineral.ore(src)
	// if(istype(O))
	// 	O.geologic_data = get_geodata()
	// TODO UPDATE XENOARCH
	return O

/turf/simulated/mineral/proc/GetDrilled(var/relic_prob = 0)
	// GetDrilled now takes a probability of getting an intact relic
	// turf/simulated/mineral/attackby will pass the tool's probability
	// Otherwise, defaults to destroying the relic 100% of the time
	if(mineral?.result_amount)
		//if the turf has already been excavated, some of it's ore has been removed
		for(var/i = 1 to mineral.result_amount - mined_ore)
			DropMineral()

	if(relictype)
		var/decl/relic/R = decls_repository.get_decl(relictype)
		excavate_find(R, relic_prob)

	//Add some rubble, you did just clear out a big chunk of rock.

	if(prob(25))
		var/datum/reagents/R = new/datum/reagents(20)
		R.my_atom = src
		R.add_reagent(/decl/reagent/stone_dust,20)
		var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem(/decl/reagent/stone_dust) // have to explicitly say the type to avoid issues with warnings
		S.show_log = 0
		S.set_up(R, 10, 0, src, 40)
		S.start()
		qdel(R)

	ChangeTurf(mined_turf)

	if(rand(1,500) == 1)
		visible_message(SPAN_NOTICE("An old dusty crate was buried within!"))
		new /obj/structure/closet/crate/secure/loot(src)

/turf/simulated/mineral/proc/excavate_find(var/decl/relic/R, var/relic_prob)
	if(!istype(R))
		return

	if(!relic_prob || !prob(relic_prob))
		visible_message(SPAN_WARNING("Something crumbles to dust inside the rock!"))
		return

	R.spawn_relic(src)

/turf/simulated/mineral/random
	name = "mineral deposit"
	var/mineralSpawnChanceList = list(
		ORE_URANIUM = 2,
		ORE_PLATINUM = 2,
		ORE_IRON = 8,
		ORE_COAL = 8,
		ORE_DIAMOND = 1,
		ORE_GOLD = 2,
		ORE_SILVER = 2
	)
	var/mineralChance = 55

/turf/simulated/mineral/random/phoron
	mineralSpawnChanceList = list(
		ORE_URANIUM = 2,
		ORE_PLATINUM = 2,
		ORE_IRON = 8,
		ORE_COAL = 8,
		ORE_DIAMOND = 1,
		ORE_GOLD = 2,
		ORE_SILVER = 2,
		ORE_PHORON = 5
	)

/turf/simulated/mineral/random/Initialize()
	if(prob(mineralChance) && !mineral)
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name
		if(mineral_name && (mineral_name in ore_data))
			mineral = ore_data[mineral_name]
			UpdateMineral()
		MineralSpread()
	. = ..()

/turf/simulated/mineral/random/high_chance
	mineralSpawnChanceList = list(
		ORE_URANIUM = 2,
		ORE_PLATINUM = 2,
		ORE_IRON = 2,
		ORE_COAL = 2,
		ORE_DIAMOND = 1,
		ORE_GOLD = 2,
		ORE_SILVER = 2
	)
	mineralChance = 55

/turf/simulated/mineral/random/high_chance/phoron
	mineralSpawnChanceList = list(
		ORE_URANIUM = 2,
		ORE_PLATINUM = 2,
		ORE_IRON = 2,
		ORE_COAL = 2,
		ORE_DIAMOND = 1,
		ORE_GOLD = 2,
		ORE_SILVER = 2
	)

/turf/simulated/mineral/random/higher_chance
	mineralSpawnChanceList = list(
		ORE_URANIUM = 3,
		ORE_PLATINUM = 3,
		ORE_IRON = 1,
		ORE_COAL = 1,
		ORE_DIAMOND = 1,
		ORE_GOLD = 3,
		ORE_SILVER = 3
	)
	mineralChance = 75

/turf/simulated/mineral/random/higher_chance/phoron
	mineralSpawnChanceList = list(
		ORE_URANIUM = 3,
		ORE_PLATINUM = 3,
		ORE_IRON = 1,
		ORE_COAL = 1,
		ORE_DIAMOND = 1,
		ORE_GOLD = 3,
		ORE_SILVER = 3,
		ORE_PHORON = 2
	)

/turf/simulated/mineral/attack_hand(var/mob/user)
	add_fingerprint(user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(ishuman(user) && user.a_intent == I_GRAB)
		var/mob/living/carbon/human/H = user
		var/turf/destination = GetAbove(H)
		if(destination)
			var/turf/start = get_turf(H)
			if(start.CanZPass(H, UP))
				if(destination.CanZPass(H, UP))
					H.climb(UP, src, 20)

/**********************Asteroid**************************/

// Setting icon/icon_state initially will use these values when the turf is built on/replaced.
// This means you can put grass on the asteroid etc.
/turf/unsimulated/floor/asteroid
	name = "coder's blight"
	icon = 'icons/turf/map_placeholders.dmi'
	icon_state = ""
	desc = "An exposed developer texture. Someone wasn't paying attention."
	smooth = SMOOTH_FALSE
	smoothing_hints = SMOOTHHINT_CUT_F | SMOOTHHINT_ONLY_MATCH_TURF | SMOOTHHINT_TARGETS_NOT_UNIQUE
	gender = PLURAL
	base_icon = 'icons/turf/map_placeholders.dmi'
	base_icon_state = "ash"

	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	var/dug = 0 //Increments by 1 everytime it's dug. 11 is the last integer that should ever be here.
	var/digging
	has_resources = 1
	footstep_sound = /decl/sound_category/asteroid_footstep

	roof_type = null

// Same as the other, this is a global so we don't have a lot of pointless lists floating around.
// Basalt is explicitly omitted so ash will spill onto basalt turfs.
var/list/asteroid_floor_smooth = list(
	/turf/unsimulated/floor/asteroid/ash,
	/turf/simulated/mineral,
	/turf/simulated/wall
)

// Copypaste parent for performance.
/turf/unsimulated/floor/asteroid/Initialize(mapload)
	if(initialized)
		crash_with("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(icon != base_icon)	// Setting icon is an appearance change, so avoid it if we can.
		icon = base_icon

	base_desc = desc
	base_name = name

	turfs += src

	if(dynamic_lighting)
		luminosity = 0
	else
		luminosity = 1

	if(mapload && permit_ao)
		queue_ao()

	if(smooth)
		canSmoothWith = asteroid_floor_smooth
		pixel_x = -4
		pixel_y = -4
		queue_smooth(src)

	if(!mapload)
		queue_smooth_neighbors(src)

	if(light_range && light_power)
		update_light()

	return INITIALIZE_HINT_NORMAL

/turf/unsimulated/floor/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if(prob(70))
				dug += rand(4, 10)
				gets_dug() // who's dug
			else
				dug += rand(1, 3)
				gets_dug()
		if(1.0)
			if(prob(30))
				dug = 11
				gets_dug()
			else
				dug += rand(4,11)
				gets_dug()
	return

/turf/unsimulated/floor/asteroid/is_plating()
	return FALSE

/turf/unsimulated/floor/asteroid/attackby(obj/item/W, mob/user)
	if(!W || !user)
		return FALSE

	if(istype(W, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			return
		var/obj/item/stack/rods/R = W
		if(R.use(1))
			to_chat(user, SPAN_NOTICE("Constructing support lattice..."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			ReplaceWithLattice()
		return

	if(istype(W, /obj/item/stack/tile/floor))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/floor/S = W
			if(S.get_amount() < 1)
				return
			qdel(L)
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			S.use(1)
			ChangeTurf(/turf/simulated/floor/airless)
			return
		else
			to_chat(user, SPAN_WARNING("The plating is going to need some support.")) //turf psychiatrist lmaooo
			return

	var/static/list/usable_tools = typecacheof(list(
		/obj/item/shovel,
		/obj/item/pickaxe/diamonddrill,
		/obj/item/pickaxe/drill,
		/obj/item/pickaxe/borgdrill
	))

	if(is_type_in_typecache(W, usable_tools))
		var/turf/T = get_turf(user)
		if(!istype(T))
			return
		if(digging)
			return
		if(dug)
			if(!GetBelow(src))
				return
			to_chat(user, SPAN_NOTICE("You start digging deeper."))
			playsound(get_turf(user), 'sound/effects/stonedoor_openclose.ogg', 50, TRUE)
			digging = TRUE
			if(!W.use_tool(src, user, 60, volume = 50))
				if(istype(src, /turf/unsimulated/floor/asteroid))
					digging = FALSE
				return

			// Turfs are special. They don't delete. So we need to check if it's
			// still the same turf as before the sleep.
			if(!istype(src, /turf/unsimulated/floor/asteroid))
				return

			playsound(get_turf(user), 'sound/effects/stonedoor_openclose.ogg', 50, TRUE)
			if(prob(33))
				switch(dug)
					if(1)
						to_chat(user, SPAN_NOTICE("You've made a little progress."))
					if(2)
						to_chat(user, SPAN_NOTICE("You notice the hole is a little deeper."))
					if(3)
						to_chat(user, SPAN_NOTICE("You think you're about halfway there."))
					if(4)
						to_chat(user, SPAN_NOTICE("You finish up lifting another pile of dirt."))
					if(5)
						to_chat(user, SPAN_NOTICE("You dig a bit deeper. You're definitely halfway there now."))
					if(6)
						to_chat(user, SPAN_NOTICE("You still have a ways to go."))
					if(7)
						to_chat(user, SPAN_NOTICE("The hole looks pretty deep now."))
					if(8)
						to_chat(user, SPAN_NOTICE("The ground is starting to feel a lot looser."))
					if(9)
						to_chat(user, SPAN_NOTICE("You can almost see the other side."))
					if(10)
						to_chat(user, SPAN_NOTICE("Just a little deeper..."))
					else
						to_chat(user, SPAN_NOTICE("You penetrate the virgin earth!"))
			else
				if(dug <= 10)
					to_chat(user, SPAN_NOTICE("You dig a little deeper."))
				else
					to_chat(user, SPAN_NOTICE("You dug a big hole.")) // how ceremonious

			gets_dug(user)
			digging = 0
			return

		to_chat(user, SPAN_WARNING("You start digging."))
		playsound(get_turf(user), 'sound/effects/stonedoor_openclose.ogg', 50, TRUE)

		digging = TRUE
		if(!do_after(user, 40))
			if(istype(src, /turf/unsimulated/floor/asteroid))
				digging = FALSE
			return

		// Turfs are special. They don't delete. So we need to check if it's
		// still the same turf as before the sleep.
		if(!istype(src, /turf/unsimulated/floor/asteroid))
			return

		to_chat(user, SPAN_NOTICE("You dug a hole."))
		digging = FALSE

		gets_dug(user)

	else if(istype(W,/obj/item/storage/bag/ore))
		var/obj/item/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/ore/O in contents)
				O.attackby(W, user)
				return
	// else if(istype(W,/obj/item/storage/bag/fossils))
	// 	var/obj/item/storage/bag/fossils/S = W
	// 	if(S.collection_mode)
	// 		for(var/obj/item/fossil/F in contents)
	// 			F.attackby(W, user)
	// 			return
	// TODO UPDATE XENOARCH
	else
		..(W, user)
	return

/turf/unsimulated/floor/asteroid/proc/gets_dug(mob/user)
	add_overlay("asteroid_dug", TRUE)

	if(prob(75))
		new /obj/item/ore/glass(src)
	if(prob(25) && has_resources)
		var/list/ore = list()
		for(var/metal in resources)
			switch(metal)
				if("silicates")
					ore += /obj/item/ore/glass
				if("carbonaceous rock")
					ore += /obj/item/ore/coal
				if("iron")
					ore += /obj/item/ore/iron
				if("gold")
					ore += /obj/item/ore/gold
				if("silver")
					ore += /obj/item/ore/silver
				if("diamond")
					ore += /obj/item/ore/diamond
				if("uranium")
					ore += /obj/item/ore/uranium
				if("phoron")
					ore += /obj/item/ore/phoron
				if("osmium")
					ore += /obj/item/ore/osmium
				if("hydrogen")
					ore += /obj/item/ore/hydrogen
				else
					if(prob(25))
						switch(rand(1,5))
							if(1)
								ore += /obj/random/junk
							if(2)
								ore += /obj/random/powercell
							if(3)
								ore += /obj/random/coin
							if(4)
								ore += /obj/random/loot
							if(5)
								ore += /obj/item/ore/glass
					else
						ore += /obj/item/ore/glass
		if(length(ore))
			var/ore_path = pick(ore)
			if(ore)
				new ore_path(src)

	if(dug <= 10)
		dug += 1
		add_overlay("asteroid_dug", TRUE)
	else
		var/turf/below = GetBelow(src)
		if(below)
			var/area/below_area = get_area(below)	// Let's just assume that the turf is not in nullspace.
			if(below_area.station_area)
				if(user)
					to_chat(user, SPAN_ALERT("You strike metal!"))
				below.spawn_roof(ROOF_FORCE_SPAWN)
			else
				ChangeTurf(/turf/space)

/turf/unsimulated/floor/asteroid/Entered(atom/movable/M as mob|obj)
	..()
	if(istype(M,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		if(R.module) // bro wtf this is criminal
			if(istype(R.module_state_1, /obj/item/storage/bag/ore))
				attackby(R.module_state_1, R)
			else if(istype(R.module_state_2, /obj/item/storage/bag/ore))
				attackby(R.module_state_2, R)
			else if(istype(R.module_state_3, /obj/item/storage/bag/ore))
				attackby(R.module_state_3, R)
			else
				return

/turf/simulated/mineral/Destroy()
	clear_ore_effects()
	. = ..()
