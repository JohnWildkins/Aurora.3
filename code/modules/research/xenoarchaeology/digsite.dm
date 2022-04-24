/decl/digsite
    var/name = "Example Digsite"
    var/list/strata_weight = list(
        RELIC_CIVILIAN = 100
    )
    var/list/grade_weight = list(
        RELIC_MUNDANE = 65,
        RELIC_UNCOMMON = 25,
        RELIC_RARE = 10,
        RELIC_ANTAG = 0,
        RELIC_SPECIAL = 0
    )
    var/list/type_weight = list(
        RELIC_CIVILIAN = list(
            RELIC_CURIO = 100
        )
    )

/decl/digsite/forest
    name = "Buried Forest"
    strata_weight = list(
        RELIC_XENOLIFE = 85,
        RELIC_CIVILIAN = 15
    )
    type_weight = list(
        RELIC_XENOLIFE = list(
            RELIC_REMAINS = 80,
            RELIC_MEDICAL = 20
        ),
        RELIC_CIVILIAN = list(
            RELIC_REMAINS = 70,
            RELIC_CURIO = 30
        )
    )
