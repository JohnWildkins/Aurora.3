/obj/machinery/telescope
	name = "high-power space telescope"
	desc = "A highly specialized piece of astrometric equipment - despite packing state of the art technological advancements, its shape and function is largely reminiscent of the Ritchey-Chretien telescopes of the 20th century."
	icon_state = "telescope_ctr"

	var/range = 1000 // Close-in scanning range in KM

/obj/machinery/telescope/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/telescope/ui_interact(mob/user, var/datum/topic_state/state = default_state)
	user.set_machine(src)

	var/datum/vueui/ui = SSvueui.get_open_ui(user, src)
	if(!ui)
		ui = new(user, src, "machinery-astrometry-telescope", 425, 500, "High-Power Space Telescope", state=state)

	ui.open()

/obj/machinery/telescope/vueui_data_change(list/data, mob/user, datum/vueui/ui)
	LAZYINITLIST(data)
	LAZYINITLIST(data["inner"])

	for(var/datum/inner_system_object/I in SSastrometry.inner_objs)
		data["inner"][I.id] = list(
			"id" = I.id,
			"dist" = I.distance,
			"vel" = I.velocity,
			"traj" = I.trajectory,
			"class" = I.class,
			"scan_det" = I.scan_details,
			"scan_stat" = I.scan_status
		)

	return data
/obj/machinery/telescope/nw
	icon_state = "telescope_nw"

/obj/machinery/telescope/n
	icon_state = "telescope_n"

/obj/machinery/telescope/ne
	icon_state = "telescope_ne"

/obj/machinery/telescope/w
	icon_state = "telescope_w"

/obj/machinery/telescope/e
	icon_state = "telescope_e"

/obj/machinery/telescope/sw
	icon_state = "telescope_sw"

/obj/machinery/telescope/s
	icon_state = "telescope_s"

/obj/machinery/telescope/se
	icon_state = "telescope_se"
