/datum/map_template/ruin/exoplanet/xenoarch
	prefix = "maps/random_ruins/exoplanets/xenoarch/"
	var/primary_stratum = RELIC_CIVILIAN
	var/secondary_stratum
	ruin_tags = RUIN_ALIEN
	sectors = ALL_POSSIBLE_SECTORS

/datum/map_template/ruin/exoplanet/xenoarch/temple
	name = "Alien Temple"
	id = "xenoarch_temple"
	description = "A long-buried alien temple, built in service to a forgotten deity."

	spawn_cost = 3
	spawn_weight = 1
	suffix = "temple.dmm"

	primary_stratum = RELIC_RELIGION
	secondary_stratum = RELIC_CIVILIAN
