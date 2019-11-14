var/global/list/teleportbeacons = list()

/obj/item/device/beacon
	name = "tracking beacon"
	desc = "A radio-frequency beacon used by bluespace teleporters."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = list(TECH_BLUESPACE = 1)

	var/freq = 1451
	var/filter = RADIO_TELEBEACONS
	var/code = "electronic"
	var/locked = TRUE

	req_access = list(access_engine)

/obj/item/device/beacon/New()
	..()
	teleportbeacons += src

	if(SSradio)
		SSradio.add_object(src, freq, filter)

/obj/item/device/beacon/Destroy()
	teleportbeacons.Remove(src)

	if(SSradio)
		SSradio.remove_object(src, freq)

	return ..()

/obj/item/device/beacon/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		updateDialog()
	return

/obj/item/device/beacon/attack_ai(mob/user)
	interact(user, TRUE)

/obj/item/device/beacon/attack_hand(mob/user)
	if(!user.IsAdvancedToolUser())
			return 0

	interact(user)
	src.add_fingerprint(user)

/obj/item/device/beacon/proc/interact(mob/user, ai = FALSE)
	var/menu = ""

	menu += "<TT><B>Tracking Beacon</B><HR><BR>"
	menu += "<i>Swipe card to [locked ? "un" : ""]lock controls.</i><BR>"

	if(locked && !ai)
		menu += "Frequency: [format_frequency(freq)]<BR>"
		menu += "Transponder: [code ? code : "N/A"]</TT>"
	else
		menu += "<A href='byond://?src=\ref[src];freq=-10'>-</A>"
		menu += "<A href='byond://?src=\ref[src];freq=-2'>-</A>"
		menu += "[format_frequency(freq)]"
		menu += "<A href='byond://?src=\ref[src];freq=2'>+</A>"
		menu += "<A href='byond://?src=\ref[src];freq=10'>+</A><BR>"
		menu += "Transponder: [code ? code : "N/A"] <small>(<A href='byond://?src=\ref[src];edit=1'>edit</A>)</small>"

	user << browse(menu, "window=beacon")
	onclose(user, "beacon")
	return

/obj/item/device/beacon/Topic(href, href_list)
	..()

	if(href_list["freq"])
		freq = sanitize_frequency(freq + text2num(href_list["freq"]))
		updateDialog()
	if(href_list["edit"])
		var/new_code = sanitize(input("Enter New Transponder", "Tracking Beacon", code))
		if(!new_code)
			return
		code = new_code
		updateDialog()

/obj/item/device/beacon/receive_signal(datum/signal/signal)
	if(signal.data["ping_all_beacons"])
		addtimer(CALLBACK(src, .proc/post_signal), 1)
	if(signal.data["ping_beacon"])
		var/challenge = signal.data["ping_beacon"]
		if(!challenge || !code || challenge != code)
			return
		addtimer(CALLBACK(src, .proc/post_signal), 1)

/obj/item/device/beacon/proc/post_signal()
	var/datum/radio_frequency/RF = SSradio.return_frequency(freq)

	if(!RF)
		return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	signal.data["beacon"] = code

	RF.post_signal(src, signal, filter)

/obj/item/device/beacon/bacon //Probably a better way of doing this, I'm lazy.
	proc/digest_delay()
		QDEL_IN(src, 600)


// SINGULO BEACON SPAWNER

/obj/item/device/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = list(TECH_BLUESPACE = 1, TECH_ILLEGAL = 7)

/obj/item/device/beacon/syndicate/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/power/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return
