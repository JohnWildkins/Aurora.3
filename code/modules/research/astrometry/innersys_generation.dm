#define SYS_ASTEROID "Asteroid"
#define SYS_DEBRIS "Debris"
#define SYS_SATELLITE "Satellite"
#define SYS_BIOMASS "Biomass"
#define SYS_LIFEPOD "Lifepod"
#define SYS_SPECIAL "Special"

/datum/inner_system_object
    var/id
    var/distance
    var/velocity
    var/trajectory = FALSE // if set to TRUE, will impact the station
    var/class = SYS_ASTEROID
    var/scan_details
    var/scan_status = FALSE
    var/obj_type = /datum/astrometrics/asteroid

/datum/inner_system_object/New(var/obj/machinery/telescope/T)
    id = uppertext(generateRandomAlphanumericString(7))

    generate_sysobj()

    var/range = T?.range ? T.range : 1000

    distance = rand(round(range * 0.8), range) // in KM
    var/min_time = 5 * 60
    var/max_time = 15 * 60
    velocity = rand(distance / min_time, distance / max_time) // in KM/S
    trajectory = prob(10) ? TRUE : FALSE // 10% chance the object starts off on a collision course

/datum/inner_system_object/proc/generate_sysobj()
    switch(rand(1, 100))
        if(1 to 66)
            // Asteroid
            class = SYS_ASTEROID
            scan_details = "Readings indicate a rocky body, possibly containing rare metals."
            obj_type = /datum/astrometrics/asteroid
        if(67 to 76)
            // Ship Debris
            class = SYS_DEBRIS
            scan_details = "Readings indicate the presence of electronics and plasteel hull segments."
            obj_type = /datum/astrometrics/debris
        if(77 to 86)
            // Satellite
            class = SYS_SATELLITE
            scan_details = "Readings indicate the presence of electronics and plasteel hull segments."
            obj_type = /datum/astrometrics/satellite
        if(86 to 91)
            // Biomass
            class = SYS_BIOMASS
            scan_details = "Readings indicate an unidentified biomass."
            obj_type = /datum/astrometrics/biomass
        if(92 to 97)
            // Lifepod
            class = SYS_LIFEPOD
            scan_details = "Readings match that of a standard-issue escape pod. Life-signs unknown."
            obj_type = /datum/astrometrics/lifepod
        if(98 to 100)
            // Special
            class = SYS_SPECIAL
            scan_details = "No accurate readings can be made. Natural or synthetic jamming may be in effect."
            obj_type = /datum/astrometrics/special

/datum/astrometrics/asteroid
    // here be the mapgen for a random asteroid

/datum/astrometrics/debris

/datum/astrometrics/satellite

/datum/astrometrics/biomass

/datum/astrometrics/lifepod

/datum/astrometrics/special

#undef SYS_ASTEROID
#undef SYS_DEBRIS
#undef SYS_SATELLITE
#undef SYS_BIOMASS
#undef SYS_LIFEPOD
#undef SYS_SPECIAL
