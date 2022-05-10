/decl/society_background
	var/name = "Default Society Background"
	var/desc = "Lorem ipsum..."
	var/primary_stratum = RELIC_CIVILIAN
	var/list/stratum_whitelist = list()
	var/list/stratum_blacklist = list()
	var/list/req_tech_levels = list()

/decl/society_background/mil
	name = "Military State"
	primary_stratum = RELIC_MILITARY
	desc = "This alien civilization valued the might of military arms above all else."
	req_tech_levels = list(XENOTECH_MIL = XENOTECH_BASIC)

/decl/society_background/civ
	name = "Social Democracy"
	primary_stratum = RELIC_CIVILIAN
	desc = "This alien civilization valued the individual and the collective citizen in an uneasy balance."

/decl/society_background/rel
	name = "Theocracy"
	primary_stratum = RELIC_RELIGION
	desc = "This alien civilization valued subservience and servitude to an almighty deity or pantheon."

/decl/society_background/ind
	name = "Oligarchy"
	primary_stratum = RELIC_INDUSTRIAL
	desc = "This alien civilization sought material wealth and economic prosperity, awarding much to very few."
	req_tech_levels = list(XENOTECH_ELEC = XENOTECH_ADV, XENOTECH_TRAVEL = XENOTECH_BASIC)

/decl/society_background/xen
	name = "Untamed Wilds"
	primary_stratum = RELIC_XENOLIFE
	desc = "What civilization could be said to exist largely clung to a type of semi-nomadism, as great beasts roamed the landscape."

/decl/society_background/mil/civ
	name = "Hegemony"
	stratum_whitelist = list(RELIC_CIVILIAN)
	desc = "A disparate group of ethnicities and species made up this alien civilization, bound together in servitude to a military hegemony."

/decl/society_background/mil/rel
	name = "Crusaders"
	stratum_whitelist = list(RELIC_RELIGION)
	desc = "Proclaiming a new Holy Kingdom in the name of their pantheon, these aliens seemed to conflate military might with piety."

/decl/society_background/mil/ind
	name = "Military-Industrial Complex"
	stratum_whitelist = list(RELIC_INDUSTRIAL)
	desc = "Seemingly a capable military power in its own right, this civilization seemed to use its penchant for high-quality arms as its primary source of revenue."
	req_tech_levels = list(XENOTECH_MIL = XENOTECH_BASIC, XENOTECH_ELEC = XENOTECH_ADV)

/decl/society_background/mil/xen
	name = "Tamed Wilds"
	stratum_whitelist = list(RELIC_XENOLIFE)
	desc = "Throughout the remains of this civilization lies the evidence of a great culling, as though these aliens rose from nothing to tame the wilderness around them... \
	only to find themselves reclaimed by nature when they inevitably fell."
	req_tech_levels = list(XENOTECH_MIL = XENOTECH_ADV, XENOTECH_ENV = XENOTECH_BASIC)
