var/datum/controller/subsystem/xenoarch/SSxenoarch

/datum/controller/subsystem/xenoarch
	name = "Xenoarcheology"
	flags = SS_NO_FIRE
	init_order = SS_INIT_MISC

/datum/controller/subsystem/xenoarch/New()
	NEW_SS_GLOBAL(SSxenoarch)

/datum/controller/subsystem/xenoarch/Initialize(timeofday)
	//create digsites
	log_debug("Initialize() in xenoarch.dm called")
