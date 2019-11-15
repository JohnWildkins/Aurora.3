/datum/teleporter
	var/source
	var/freq = 1451
	var/filter = RADIO_TELEBEACONS

	var/list/availablebeacons = list()

/datum/teleporter/New(chosen_source, frequency)
	source = chosen_source
	freq = frequency

	if(SSradio)
		SSradio.add_object(src, freq, filter)

/datum/teleporter/Destroy()
	if(SSradio)
		SSradio.remove_object(src, freq)

/datum/teleporter/proc/receive_signal(datum/signal/signal)
	if(signal.data["beacon"])
		availablebeacons += signal.source

/datum/teleporter/proc/post_signal(code = null)
	var/datum/radio_frequency/RF = SSradio.return_frequency(freq)

	if(!RF)
		return

	var/datum/signal/signal = new()
	signal.source = source
	signal.transmission_method = 1

	if(code)
		signal.data["ping_beacon"] = code
	else
		signal.data["ping_all_beacons"] = TRUE
		availablebeacons.Cut()

	RF.post_signal(src, signal, filter)