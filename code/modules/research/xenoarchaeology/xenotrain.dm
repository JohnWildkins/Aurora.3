#define X_STORAGE_L /obj/vehicle/train/trolley/xenoarch/storage
#define X_STORAGE_S /obj/vehicle/train/trolley/xenoarch/storage/three
#define X_SPECTRO /obj/vehicle/train/machinery/xenoarch/spectrometer
#define X_ANALYZER /obj/vehicle/train/machinery/xenoarch/analyzer
#define X_DETECTOR /obj/vehicle/train/machinery/xenoarch/detector
#define X_CHEMS /obj/vehicle/train/machinery/xenoarch/chems
#define X_ANCHOR /obj/vehicle/train/machinery/xenoarch/anchor

/obj/vehicle/train/engine/xenoarch
	name = "\improper HPX-196 exploratory rover"
	desc = "An electrically-powered exploratory vehicle designed to haul a variety of scientific equipment."
	icon = 'icons/obj/xenoarch/xenotug.dmi'
	icon_state = "science_engine"

	locked = TRUE

	vueui_template = "scienceengine"

	car_limit = 6 // These trains be long.

/obj/item/key/xenoarch
	name = "HPX-196 rover key"
	desc = "A keyring holding a small steel key, with a fob emblazoned with the Hephaestus Exploration logo."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "train_keys"

/obj/vehicle/train/engine/xenoarch/setup_engine()
	cell = new /obj/item/cell/hyper(src)
	key = new /obj/item/key/xenoarch(src)
	var/image/I = new(icon = icon, icon_state = "[icon_state]_overlay", layer = src.layer + 0.2) //over mobs
	add_overlay(I)
	turn_off()

/obj/vehicle/train/engine/xenoarch/vueui_data_change(list/data, mob/user, datum/vueui/ui)
	if(!length(data))
		data = list()

	data["is_on"] = on
	data["has_key"] = !!key
	data["has_cell"] = !!cell
	if(cell)
		data["cell_charge"] = cell.charge
		data["cell_max_charge"] = cell.maxcharge
	data["is_towing"] = !!tow
	if(tow)
		data["tow"] = tow.name

	return data

/obj/vehicle/train/trolley/xenoarch
	icon = 'icons/obj/xenoarch/xenotug.dmi'
	load_item_visible = FALSE

/obj/vehicle/train/trolley/xenoarch/setup_vehicle()
	// doesn't call parent - no you cannot ride the scientific equipment, literally 1984
	for(var/obj/vehicle/train/T in orange(1, src))
		latch(T)

/obj/vehicle/train/trolley/xenoarch/load(var/atom/movable/C)
	return FALSE

/obj/vehicle/train/trolley/xenoarch/unload(var/mob/user, var/direction)
	return FALSE

/obj/vehicle/train/trolley/xenoarch/storage
	name = "\improper HPX-C anomalous materials bin"
	desc = "A hardened storage container designed to be transported by HPX-series rovers."
	icon_state = "artifact_storage_large"

	var/max_size = ITEMSIZE_LARGE

/obj/vehicle/train/trolley/xenoarch/storage/three
	name = "\improper HPX-C3 anomalous materials bin"
	desc = "A hardened storage container designed to be transported by HPX-series rovers. \
	This one contains several smaller compartments, shielded from each other."
	icon_state = "artifact_storage_small"

	max_size = ITEMSIZE_NORMAL

/obj/vehicle/train/machinery/xenoarch/ui_interact(mob/user)
	var/datum/vueui/ui = SSvueui.get_open_ui(user, src)

	if(!ui)
		ui = new(user, src, "vehicles-xeno-[vueui_template]", 600, 400, capitalize_first_letters(initial(name)))
		ui.auto_update_content = TRUE

	ui.open()

/obj/vehicle/train/machinery/xenoarch/vueui_data_change(list/data, mob/user, datum/vueui/ui)
	data = ..()

	return data

/obj/vehicle/train/machinery/xenoarch/Topic(href, href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(href_list["toggle_pwr"])
		toggle_power(usr)
		return TOPIC_HANDLED

	SSvueui.check_uis_for_change(src)

/obj/vehicle/train/machinery/xenoarch/spectrometer
	name = "\improper HPX-S spectrometry suite"
	desc = "An advanced sensor system designed to be transported by HPX-series rovers, \
	capable of analyzing geological data to a high level of precision. \
	Requires an attached analysis compartment to function."
	icon_state = "spectrometer"

	vueui_template = "spectrometer"

	var/amplitude = 1
	var/frequency = 0.01

	var/obj/vehicle/train/machinery/xenoarch/analyzer/linked_analyzer

/obj/vehicle/train/machinery/xenoarch/spectrometer/update_stats()
	. = ..()
	linked_analyzer = find_linked_machine(X_ANALYZER)

/obj/vehicle/train/machinery/xenoarch/spectrometer/vueui_data_change(list/data, mob/user, datum/vueui/ui)
	. = data = ..()

	data["amplitude"] = amplitude
	data["frequency"] = frequency

	if(istype(linked_analyzer))
		data["target"] = linked_analyzer.get_artifact_data()

	return data

/obj/vehicle/train/machinery/xenoarch/spectrometer/Topic(href, href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(href_list["amp"])
		var/amp_change = href_list["amp"]
		if(amp_change > 0)
			amplitude = min(amplitude + 0.1, 1)
		else
			amplitude = max(amplitude - 0.1, 0)
		return TOPIC_HANDLED

	if(href_list["frq"])
		var/frq_change = href_list["frq"]
		if(frq_change > 0)
			frequency = min(frequency + 0.01, 0.1)
		else
			frequency = max(frequency - 0.01, 0.01)
		return TOPIC_HANDLED

	if(href_list["tgt"])
		if(istype(linked_analyzer))
			linked_analyzer.lock_in()
		return TOPIC_HANDLED

/obj/vehicle/train/machinery/xenoarch/analyzer
	name = "\improper HPX-A archaeological analysis compartment"
	desc = "A doubly-reinforced observation chamber for use with HPX-series analysis and spectrometry suites. \
	Protects archaeological finds and anomalous materials equally."
	icon_state = "analyzer"

	vueui_template = "analyzer"

	var/art_data = list("frq" = 0.1, "amp" = 0.6)

/obj/vehicle/train/machinery/xenoarch/analyzer/proc/get_artifact_data()
	// DEBUG PURPOSES ONLY
	return art_data

/obj/vehicle/train/machinery/xenoarch/analyzer/proc/lock_in()
	// DEBUG PURPOSES ONLY
	. = art_data = null

/obj/vehicle/train/machinery/xenoarch/detector
	name = "\improper HPX-NAV pathfinding system"
	desc = "A high-performance suite of various long and short-range sensors. Used on archaeological excursions \
	to find sites of interest."
	icon_state = "BAD+pinpointer"

	vueui_template = "pathfinder"

/obj/vehicle/train/machinery/xenoarch/chems
	name = "\improper HPX-CHM mobile chemical lab"
	desc = "An adapted, compact version of chemical dispenser suites designed for rugged field work. \
	Notably, this model boasts considerable chemical recycling capability to improve mission endurance."
	icon_state = "chemcart"

	vueui_template = "chemcart"

/obj/vehicle/train/machinery/xenoarch/anchor
	name = "\improper NTX-BX prototype bluespace anchor"
	desc = "A revolutionary prototype device, the NTX-BX is a miniaturized bluespace interdiction net, \
	the smallest ever developed. Designed for nullifying the effects of anomalous bluespace activity."
	icon_state = "bluespace_anchor"

	vueui_template = "bluespace"
