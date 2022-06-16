/obj/vehicle/train
	name = "train"
	dir = 4
	animate_movement = SLIDE_STEPS

	move_delay = 1
	locked = FALSE

	health = 100
	maxhealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/passenger_allowed = 1

	var/active_engines = 0
	var/train_length = 0

	var/obj/vehicle/train/lead
	var/obj/vehicle/train/tow

	var/obj/vehicle/train/head
	var/obj/vehicle/train/tail

	var/engine_lock = FALSE // prevents train from moving during rebuild / reversal

	var/vueui_template = "trainengine"
	can_hold_mob = TRUE

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/setup_vehicle()
	..()
	rebuild_train()
	for(var/obj/vehicle/train/T in orange(1, src))
		latch(T)

/obj/vehicle/train/ui_interact(mob/user)
	if(!vueui_template)
		SSvueui.close_uis(src)
		return

	var/datum/vueui/ui = SSvueui.get_open_ui(user, src)

	if(!ui)
		ui = new(user, src, "vehicles-[vueui_template]", 600, 400, capitalize_first_letters(initial(name)))
		ui.auto_update_content = TRUE

	ui.open()

/obj/vehicle/train/examine(mob/user)
	. = ..()
	if(lead)
		to_chat(user, SPAN_NOTICE("It is being towed by \the [lead] in the [dir2text(get_dir(src, lead))]."))
	if(tow)
		to_chat(user, SPAN_NOTICE("It is towing \the [tow] in the [dir2text(get_dir(src, tow))]."))

/obj/vehicle/train/Move()
	var/old_loc = get_turf(src)
	. = ..()
	if(. && tow)
		tow.Move(old_loc)
	else if(!. && lead)
		unattach()

/obj/vehicle/train/Collide(atom/Obstacle)
	if(!lead)
		return

	. = ..()

	if(!istype(Obstacle, /atom/movable))
		return
	var/atom/movable/AM = Obstacle

	if(!AM.anchored)
		var/turf/T = get_step(AM, dir)
		if(istype(T))
			AM.Move(T)	//bump things away when hit

	if(emagged && isliving(AM))
		var/mob/living/M = AM
		visible_message(SPAN_WARNING("[src] knocks over [M]!"))
		var/def_zone = ran_zone()
		M.apply_effects(5, 5)				//knock people down if you hit them
		M.apply_damage(22 / move_delay, BRUTE, def_zone)	// and do damage according to how fast the train is going
		if(isliving(load))
			var/mob/living/D = load
			to_chat(D, SPAN_WARNING("You hit [M]!"))
			msg_admin_attack("[D.name] ([D.ckey]) hit [M.name] ([M.ckey]) with [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)",ckey=key_name(D),ckey_target=key_name(M))

// Cargo trains are open topped, so you can shoot at the driver.
// Or you can shoot at the tug itself, if you're good.
/obj/vehicle/train/bullet_act(var/obj/item/projectile/Proj)
	if (buckled && Proj.original == buckled)
		buckled.bullet_act(Proj)
	else
		..()

/obj/vehicle/train/update_icon()
	if(open)
		icon_state = initial(icon_state) + "_open"
	else
		icon_state = initial(icon_state)

/obj/vehicle/train/proc/update_offset(var/dir)
	return // Overwrite this for trains that change offsets depending on dir state (e.g. janitruck)

//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/train/explode()
	if(tow)
		tow.unattach()
	unattach()
	..()

/obj/vehicle/train/turn_on()
	. = ..()
	update_stats()

/obj/vehicle/train/turn_off()
	. = ..()
	update_stats()

/obj/vehicle/train/RunOver(var/mob/living/carbon/human/H)
	var/list/parts = list(BP_HEAD, BP_CHEST, BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

	H.apply_effects(5, 5)
	for(var/i = 0, i < rand(1,5), i++)
		var/def_zone = pick(parts)
		H.apply_damage(rand(5,10), BRUTE, def_zone)

	if(!lead && istype(load, /mob/living/carbon/human))
		var/mob/living/carbon/human/D = load
		to_chat(D, SPAN_DANGER("You ran over [H]!"))
		visible_message(SPAN_DANGER("\The [src] ran over [H]!"))
		attack_log += text("\[[time_stamp()]\] [SPAN_WARNING("ran over [H.name] ([H.ckey]), driven by [D.name] ([D.ckey])")]")
		msg_admin_attack("[D.name] ([D.ckey]) ran over [H.name] ([H.ckey]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)",ckey=key_name(D),ckey_target=key_name(H))
	else
		attack_log += text("\[[time_stamp()]\] [SPAN_WARNING("ran over [H.name] ([H.ckey])")]")

//-------------------------------------------
// Interaction procs
//-------------------------------------------
/obj/vehicle/train/relaymove(mob/user, direction)
	var/turf/T = get_step(src, direction)
	if(!istype(T))
		return FALSE

	if(user != load)
		if(user in src)
			user.forceMove(T)
			return TRUE
		return FALSE

	if(!lead && is_active_engine())
		if(tow && direction == get_dir(src, tow))
			return FALSE
		if(engine_lock)
			return FALSE
		return Move(T)

	unload(user, direction)

	to_chat(user, SPAN_NOTICE("You climb down from \the [src]."))

	return TRUE

/obj/vehicle/train/MouseDrop_T(atom/movable/C, mob/user)
	if(user.buckled_to || user.stat || user.restrained() || !Adjacent(user) || !user.Adjacent(C) || !istype(C) || (user == C && !user.canmove))
		return
	if(istype(C, /obj/vehicle/train))
		latch(C, user)
	else if(!load(C))
		to_chat(user, SPAN_WARNING("You were unable to load \the [C] on \the [src]."))

/obj/vehicle/train/attack_hand(mob/user)
	if(user.stat || user.restrained() || !Adjacent(user))
		return FALSE

	if(user != load && (user in src))
		user.forceMove(loc)			//for handling players stuck in src
	else if(load)
		unload(user)			//unload if loaded

/obj/vehicle/train/attackby(obj/item/W, mob/user)
	if(W.iswrench())
		playsound(loc, W.usesound, 70, FALSE)
		unattach(user)
		return TRUE
	. = ..()

//-------------------------------------------
// Latching/unlatching procs
//-------------------------------------------
// attaches src as the towed object of T
/obj/vehicle/train/proc/attach_to(obj/vehicle/train/T, mob/user)
	if(!Adjacent(T))
		to_chat(user, SPAN_WARNING("\The [src] is too far away from \the [T] to hitch them together."))
		return

	if(lead)
		to_chat(user, SPAN_WARNING("\The [src] is already hitched to \the [lead]."))
		return

	if(T.tow)
		to_chat(user, SPAN_WARNING("\The [T] is already towing \the [T.tow]."))
		return

	//check for cycles.
	var/obj/vehicle/train/next_car = T
	while(next_car)
		if(next_car == src)
			to_chat(user, SPAN_WARNING("You probably shouldn't hitch both ends of a train together."))
			return
		next_car = next_car.lead

	//latch with src as the follower
	lead = T
	T.tow = src
	rebuild_train()
	set_dir(lead.dir)

	if(user)
		to_chat(user, SPAN_NOTICE("You hitch \the [src] to \the [T]."))

//detaches the train from whatever is towing it
/obj/vehicle/train/proc/unattach(mob/user)
	if(!lead)
		if(user)
			to_chat(user, SPAN_WARNING("\The [src] is not hitched to anything."))
		return

	if(user)
		to_chat(user, SPAN_NOTICE("You unhitch \the [src] from \the [lead]."))

	lead.tow = null
	lead = null

	head.rebuild_train()
	rebuild_train()

/obj/vehicle/train/proc/latch(obj/vehicle/train/T, mob/user)
	if(!istype(T) || !Adjacent(T) || T == src)
		return FALSE

	if(lead || (is_engine() && !T.head.is_engine()))
		// We have a train: attach T to us; alternatively, we're an engine, and T has no (viable) engine leading it
		if(T.lead)
			to_chat(user, SPAN_WARNING("\The [T] is already hitched to \the [T.lead]!"))
			return FALSE
		if(tow)
			to_chat(user, SPAN_WARNING("\The [src] is already towing \the [tow]!"))
			return FALSE
		return T.attach_to(src, user)

	if(T.tow)
		// We don't have a train, so check if they can tow us
		to_chat(user, SPAN_WARNING("\The [T] is already towing \the [T.tow]!"))
		return FALSE

	return attach_to(T, user)

/obj/vehicle/train/proc/is_engine()
	return FALSE

/obj/vehicle/train/proc/is_active_engine()
	return FALSE

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

/obj/vehicle/train/proc/reverse_train()
	var/obj/vehicle/train/temp = head
	if(!istype(temp))
		return FALSE

	head.engine_lock = TRUE
	tail.engine_lock = TRUE

	head = tail
	tail = temp
	var/obj/vehicle/train/C = head

	// because trains are just doubly linked lists...
	// we're just reversing a doubly linked list. Crazy, huh?

	while(C)
		temp = C.tow
		C.tow = C.lead
		C.lead = temp
		C = C.tow

	rebuild_train()

	head.engine_lock = FALSE
	tail.engine_lock = FALSE

/obj/vehicle/train/proc/rebuild_train()
	// Should only be called if a car is added or disconnected to the train
	var/obj/vehicle/train/car = src
	while(car.tow)
		if(src == car.tow)
			unattach()
			return
		car = car.tow

	var/engines = 0
	var/train_length = 0
	var/obj/vehicle/train/new_head
	var/obj/vehicle/train/new_tail = car // We're already at the end of the train

	while(car)
		train_length++
		new_head = car
		car.tail = new_tail
		if(car.is_active_engine())
			engines++
		car = car.lead

	car = new_head

	while(car)
		car.head = new_head
		car.update_car(train_length, engines)
		car = car.tow

/obj/vehicle/train/update_stats()
	// Should be called whenever you need to check the power status of engines (basically every move)
	// Does NOT check the length of the train or validity of cars, for that see rebuild_train() above
	var/engines = 0
	var/obj/vehicle/train/T = head
	while(T)
		if(T.is_active_engine())
			engines++
		T = T.tow

	active_engines = engines
	T = head

	while(T)
		T.update_car(train_length, engines)
		T = T.tow

/obj/vehicle/train/proc/update_car(var/train_length, var/active_engines)
	return
