// Relic Grades
#define RELIC_MUNDANE "mundane"
#define RELIC_UNCOMMON "uncommon"
#define RELIC_RARE "rare"
#define RELIC_ANTAG "exotic"
#define RELIC_SPECIAL "special"

// Relic Strata
// Relics will only have one strata, though digsites can have multiple.
#define RELIC_MILITARY      "mil" // Previous military applications, though may not be strictly military in nature
#define RELIC_CIVILIAN      "civ" // Previously used in daily civilian life - 'catch all' category
#define RELIC_RELIGION      "rel" // Religious import to previous civilization, typically found in holy sites
#define RELIC_INDUSTRIAL    "ind" // Industrial sites, waste dumps, etc.
#define RELIC_XENOLIFE      "xen" // Related to xenoflora and xenofauna
#define RELIC_ANOMALY       "ano" // Artifacts of bluespace anomalies -- not necessarily historical or tied to this planet

// Relic Type
#define RELIC_TRAP      /decl/relic/trap // Trap 'relics' -- should only be included on more dangerous digsites
#define RELIC_CURIO     /decl/relic/curio // "Miscellaneous", tag for relics that aren't otherwise easily categorized. Mostly mundane.
#define RELIC_MEDICAL   /decl/relic/medical // Medical implements, whether they be tools, devices, or otherwise.
#define RELIC_TOOL      /decl/relic/tool // Tools of various shapes and forms
#define RELIC_POWER     /decl/relic/power // Anything related to power generation or consumption
#define RELIC_WEAPON    /decl/relic/weapon // Anything which seemingly had a prior primary function as a weapon, whether for self-defense or war
#define RELIC_DEVICE    /decl/relic/device // 'Devices' are anything from simple to extremely complex mechanical / electrical machinery; may be man-portable or not
#define RELIC_VEHICLE   /decl/relic/vehicle // Vehicle relics are what they suggest on the tin - the remains of once-active alien transport.
#define RELIC_REMAINS   /decl/relic/remains

// Relic Activation Conditions
#define ACTIVE_TOUCH        (1<<0)
#define ACTIVE_TEMP         (1<<1)
#define ACTIVE_CHEM         (1<<2)
#define ACTIVE_GAS          (1<<3)
#define ACTIVE_INJECT       (1<<4)
#define ACTIVE_ENERGIZE     (1<<5)
#define ACTIVE_EMP          (1<<6)
#define ACTIVE_BLUESPACE    (1<<7)
#define ALWAYS_ACTIVE       (1<<8)
