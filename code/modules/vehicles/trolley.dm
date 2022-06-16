/obj/vehicle/train/trolley
	name = "trolley"
	desc = "A trolley designed to haul crates and other large materials."
	desc_info = "You can use a wrench to unlatch this."
	icon_state = "cargo_trailer"

	anchored = FALSE
	passenger_allowed = FALSE

	load_offset_y = 4
	mob_offset_y = 8

	var/list/permitted_cargo = list(
		/obj/machinery,
		/obj/structure/closet,
		/obj/structure/largecrate,
		/obj/structure/reagent_dispensers,
		/obj/structure/ore_box,
		/mob/living/carbon/human
	)

	var/list/dummy_cargo = list( // Cargo that should be replaced with a dummy object on load, to not be interacted with
		/obj/machinery
	)

//-------------------------------------------
// Standard procs
//-------------------------------------------

/obj/vehicle/train/trolley/insert_cell(var/obj/item/cell/C, var/mob/living/carbon/human/H)
	return

//-------------------------------------------
// Interaction procs
//-------------------------------------------

/obj/vehicle/train/trolley/attackby(obj/item/W, mob/user)
	if(open && W.iswirecutter())
		passenger_allowed = !passenger_allowed
		user.visible_message(SPAN_NOTICE("[user] [passenger_allowed ? "cuts" : "mends"] a cable in [src]."), \
			SPAN_NOTICE("You [passenger_allowed ? "cut" : "mend"] the load limiter cable."))
		return TRUE
	. = ..()

//-------------------------------------------
// Loading/unloading procs
//-------------------------------------------
/obj/vehicle/train/trolley/load(var/atom/movable/C)
	if(!is_type_in_list(C, permitted_cargo))
		return FALSE
	if(ismob(C) && !passenger_allowed)
		return FALSE

	//if there are any items you don't want to be able to interact with, add them to this check
	// ~no more shielded, emitter armed death trains
	if(is_type_in_list(C, dummy_cargo))
		load_object(C)
	else
		..()

	return load

/obj/vehicle/train/trolley/proc/load_object(var/atom/movable/C)
	/* Load the object "inside" the trolley and add an overlay of it.
	This prevents the object from being interacted with until it has
	been unloaded. A dummy object is loaded instead so the loading
	code knows to handle it correctly. */
	if(load || C.anchored || !isturf(C.loc)) //To prevent loading things from someone's inventory, which wouldn't get handled properly.
		return FALSE

	var/datum/vehicle_dummy_load/dummy_load = new()
	load = dummy_load

	if(!load)
		return FALSE

	dummy_load.actual_load = C
	C.forceMove(src)

	if(load_item_visible)
		var/mutable_appearance/MA = new(C)
		MA.pixel_x += load_offset_x
		MA.pixel_y += load_offset_y
		MA.layer = FLOAT_LAYER

		add_overlay(MA)

/obj/vehicle/train/trolley/unload(var/mob/user, var/direction)
	if(istype(load, /datum/vehicle_dummy_load))
		var/datum/vehicle_dummy_load/dummy_load = load
		load = dummy_load.actual_load
		dummy_load.actual_load = null
		qdel(dummy_load)
		cut_overlays()
	..()

//-------------------------------------------------------
// Stat update procs
//
// Update the trains stats for speed calculations.
// The longer the train, the slower it will go. car_limit
// sets the max number of cars one engine can pull at
// full speed. Adding more cars beyond this will slow the
// train proportionate to the length of the train. Adding
// more engines increases this limit by car_limit per
// engine.
//-------------------------------------------------------

/obj/vehicle/train/trolley/update_car(var/train_length, var/active_engines)
	src.train_length = train_length
	src.active_engines = active_engines

	if(!lead && !tow)
		anchored = FALSE
	else
		anchored = TRUE
