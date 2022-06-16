/obj/vehicle/train/machinery
	name = "debug"
	desc = "Uh oh."

	var/power_status // POWER_USE_*

	var/idle_power_usage = 100 // W
	var/active_power_usage = 500 // W

/obj/vehicle/train/machinery/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/vehicle/train/machinery/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/vehicle/train/machinery/process()
	update_stats()

/obj/vehicle/train/machinery/update_stats()
	..()
	var/pwr_usage = get_usage()
	var/obj/vehicle/train/engine/engine = head
	if(!istype(engine) || !engine.check_power(pwr_usage))
		stat |= NOPOWER
		return
	stat &= ~NOPOWER
	if(!stat && pwr_usage)
		engine.use_power(pwr_usage)

/obj/vehicle/train/machinery/update_icon()
	switch(power_status)
		if(POWER_USE_OFF)
			icon_state = initial(icon_state)
		if(POWER_USE_IDLE)
			icon_state = "[initial(icon_state)]_standby"
		if(POWER_USE_ACTIVE)
			icon_state = "[initial(icon_state)]_working"

/obj/vehicle/train/machinery/proc/get_usage()
	switch(power_status)
		if(POWER_USE_OFF)
			return 0
		if(POWER_USE_IDLE)
			return idle_power_usage
		if(POWER_USE_ACTIVE)
			return active_power_usage

/obj/vehicle/train/machinery/proc/toggle_power(mob/user)
	update_stats()
	if(stat)
		return // shouldn't even be calling this proc in this case, but w/e

	if(!on)
		turn_on()
	else
		turn_off()

/obj/vehicle/train/machinery/turn_on()
	if(stat)
		return FALSE
	on = TRUE
	power_status = POWER_USE_IDLE
	set_light(initial(light_range))
	update_icon()
	return TRUE

/obj/vehicle/train/machinery/attack_hand(mob/user)
	if(!user || use_check_and_message(user))
		return

	ui_interact(user)

/obj/vehicle/train/machinery/ui_interact(mob/user)
	var/datum/vueui/ui = SSvueui.get_open_ui(user, src)

	if(!ui)
		ui = new(user, src, "vehicles-[vueui_template]", 600, 400, capitalize_first_letters(initial(name)))
		ui.auto_update_content = TRUE

	ui.open()

/obj/vehicle/train/machinery/vueui_data_change(list/data, mob/user, datum/vueui/ui)
	if(!length(data))
		data = list()

	update_stats()

	data["is_on"] = on
	data["can_power"] = !stat

	return data

/obj/vehicle/train/machinery/Topic(href, href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(href_list["toggle_pwr"])
		toggle_power(usr)
		return TOPIC_HANDLED

	SSvueui.check_uis_for_change(src)

/obj/vehicle/train/machinery/proc/find_linked_machine(var/searchtype)
	if(!ispath(searchtype))
		return

	var/obj/vehicle/train/T = head
	while(T)
		if(istype(T, searchtype))
			return T
		T = T.tow
