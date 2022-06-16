/obj/vehicle/train/engine
	name = "tug"
	desc = "A ridable electric tug designed to pull trolleys."
	desc_info = "Click-drag yourself onto the tug to climb onto it.<br>\
		- CTRL-click the tug to open the ignition and controls menu.<br>\
		- ALT-click the tug to remove the key from the ignition.<br>\
		- Click the tug to open a UI menu.<br>\
		- Click the resist button or type \"resist\" in the command bar at the bottom of your screen to get off the tug."
	icon_state = "cargo_engine"

	powered = TRUE
	cell = /obj/item/cell/high

	mob_offset_y = 7
	active_engines = 1

	var/car_limit = 3		//how many cars an engine can pull before performance degrades

	var/obj/item/key/key
	var/keytype = /obj/item/key

//-------------------------------------------
// Standard procs
//-------------------------------------------

/obj/vehicle/train/engine/setup_vehicle()
	..()
	setup_engine()

/obj/vehicle/train/engine/proc/setup_engine()
	if(ispath(keytype))
		key = new keytype(src)
	if(ispath(cell))
		cell = new cell(src)

	var/image/I = new(icon = icon, icon_state = "[icon_state]_overlay", layer = src.layer + 0.2) //over mobs
	add_overlay(I)
	turn_off()

/obj/vehicle/train/engine/examine(mob/user)
	if(!..(user, 1))
		return

	if(!ishuman(user))
		return

	to_chat(user, "The power light is [on ? "on" : "off"].\nThere are[key ? "" : " no"] keys in the ignition.")
	to_chat(user, "The charge meter reads [cell? round(cell.percent(), 0.01) : 0]%")

/obj/vehicle/train/engine/Move(var/turf/destination)
	if(on && cell.charge < charge_use)
		turn_off()
		update_stats()
		if(load && !lead)
			to_chat(load, "The drive motor briefly whines, then drones to a stop.")

	//space check ~no flying space trains sorry
	if(on && istype(destination, /turf/space))
		return FALSE

	update_icon()

	return ..()

/obj/vehicle/train/engine/insert_cell(var/obj/item/cell/C, var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/engine/remove_cell(var/mob/living/carbon/human/H)
	..()
	update_stats()

//-------------------------------------------
// Vehicle procs
//-------------------------------------------

/obj/vehicle/train/engine/turn_on()
	if(!key)
		audible_message(SPAN_WARNING("\The [src] whirrs, but without a key in the ignition, it shuts down!"))
		return
	return ..()

//-------------------------------------------
// Interaction procs
//-------------------------------------------

/obj/vehicle/train/engine/attack_hand(mob/user)
	if(use_check_and_message(user))
		return
	if(!load || user == load) // no driver, or the user is the driver
		ui_interact(user)
		return
	..()

/obj/vehicle/train/engine/attackby(obj/item/W, mob/user)
	if(istype(W, keytype))
		if(!key)
			user.drop_from_inventory(W, src)
			key = W
			to_chat(user, SPAN_NOTICE("You slide the key into the ignition."))
		else
			to_chat(user, SPAN_WARNING("\The [src] already has a key inserted."))
		return TRUE
	. = ..()

/obj/vehicle/train/engine/CtrlClick(mob/user)
	if(Adjacent(user))
		if(on)
			stop_engine(usr)
		else
			start_engine(usr)
	else
		return ..()

/obj/vehicle/train/engine/AltClick(mob/user)
	if(Adjacent(user))
		remove_key(user)
	else
		return ..()

/obj/vehicle/train/engine/proc/start_engine(mob/user)
	if(on)
		to_chat(user, SPAN_WARNING("The engine is already running."))
		return

	turn_on()
	if(on)
		to_chat(user, SPAN_NOTICE("You start \the [src]'s engine."))
	else if(cell.charge < charge_use)
		to_chat(user, SPAN_WARNING("\The [src] is out of power."))

/obj/vehicle/train/engine/proc/stop_engine(mob/user)
	if(!on)
		to_chat(user, SPAN_WARNING("The engine is already stopped."))
		return

	turn_off()
	if(!on)
		to_chat(user, SPAN_NOTICE("You stop \the [src]'s engine."))

/obj/vehicle/train/engine/proc/remove_key(mob/user)
	if(!key)
		to_chat(usr, SPAN_WARNING("\The [src] doesn't have a key inserted!"))
		return
	if(load && load != usr)
		return

	if(on)
		turn_off()

	user.put_in_hands(key)
	key = null

/obj/vehicle/train/engine/emag_act(var/remaining_charges, mob/user)
	. = ..()
	if(.)
		update_car(train_length, active_engines)

/obj/vehicle/train/engine/proc/check_power(var/power = 0)
	return (!cell || cell.charge < power)

/obj/vehicle/train/engine/proc/use_power(var/power = 0)
	return check_power(power) && cell.use(power)

/obj/vehicle/train/engine/vueui_data_change(list/data, mob/user, datum/vueui/ui)
	if(!length(data))
		data = list()

	data["is_on"] = on
	data["has_key"] = !!key
	data["has_cell"] = !!cell
	if(cell)
		data["cell_charge"] = cell.charge
		data["cell_max_charge"] = cell.maxcharge
	data["tow"] = tow?.name
	data["lead"] = lead?.name

	data["can_switch"] = !tow && lead

	return data

/obj/vehicle/train/engine/Topic(href, href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(load && load != usr)
		to_chat(usr, SPAN_WARNING("You can't interact with \the [src] while its in use."))
		return TOPIC_HANDLED

	if(href_list["take_control"])
		switch_engine(usr)
		. = TOPIC_HANDLED

	if(href_list["toggle_engine"])
		if(!on)
			start_engine(usr)
		else
			stop_engine(usr)
		. = TOPIC_HANDLED

	if(href_list["key"])
		remove_key(usr)
		. = TOPIC_HANDLED

	if(href_list["untow"])
		if(tow)
			tow.unattach(usr)
		. = TOPIC_HANDLED

	if(href_list["unlead"])
		unattach(usr)
		. = TOPIC_HANDLED

	SSvueui.check_uis_for_change(src)

//-------------------------------------------
// Latching/unlatching procs
// Loading/unloading procs
//-------------------------------------------
/obj/vehicle/train/engine/set_dir(var/ndir)
	if(ndir && lead && !tow)
		ndir = reverse_direction(ndir) // Caboose engine should face the other way.

	update_offset(ndir)
	. = ..()

/obj/vehicle/train/engine/is_engine()
	return TRUE

/obj/vehicle/train/engine/is_active_engine()
	return powered && on

/obj/vehicle/train/engine/proc/switch_engine(mob/user)
	if(src != tail)
		return FALSE

	reverse_train()

/obj/vehicle/train/engine/load(var/atom/movable/C)
	if(!ishuman(C))
		return FALSE

	return ..()

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

/obj/vehicle/train/engine/update_car(var/train_length, var/active_engines)
	src.train_length = train_length
	src.active_engines = active_engines

	//Update move delay
	if(!is_active_engine())
		move_delay = initial(move_delay)		//so that engines that have been turned off don't lag behind
	else
		move_delay = max(0, (-car_limit * active_engines) + train_length - active_engines)	//limits base overweight so you cant overspeed trains
		move_delay *= (1 / max(1, active_engines)) * 2 										//overweight penalty (scaled by the number of engines)
		move_delay += config.walk_speed 													//base reference speed
		move_delay *= config.vehicle_delay_multiplier												//makes cargo trains 10% slower than running when not overweight
		if(emagged)
			move_delay -= 2
