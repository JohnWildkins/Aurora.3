/datum/map_template/ruin/exoplanet/xenoarch
	prefix = "maps/random_ruins/exoplanets/xenoarch/"
	ruin_tags = RUIN_ALIEN
	sectors = ALL_POSSIBLE_SECTORS

	var/type_weight = list(
		RELIC_TRAP = 10,
		RELIC_CURIO = 10,
		RELIC_MEDICAL = 10,
		RELIC_TOOL = 10,
		RELIC_POWER = 10,
		RELIC_WEAPON = 10,
		RELIC_DEVICE = 10,
		RELIC_VEHICLE = 10,
		RELIC_REMAINS = 10
	)

	var/relic_blacklist = list()
	var/relic_whitelist = list()

/datum/map_template/ruin/exoplanet/xenoarch/temple
	name = "Alien Temple"
	id = "xenoarch_temple"
	description = "A long-buried alien temple, built in service to a forgotten deity."

	spawn_cost = 3
	spawn_weight = 1
	suffix = "temple.dmm"

	type_weight = list(
		RELIC_CURIO = 40,
		RELIC_CLOTHING = 20,
		RELIC_REMAINS = 20,
		RELIC_TRAP = 10,
		RELIC_DEVICE = 10
	)
