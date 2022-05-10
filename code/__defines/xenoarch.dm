// Relic Grades
#define RELIC_MUNDANE "mundane"
#define RELIC_UNCOMMON "uncommon"
#define RELIC_RARE "rare"
#define RELIC_ANTAG "exotic"
#define RELIC_SPECIAL "special"

// Relic Strata
// Relics will only have one stratum, though digsites can have multiple.
#define RELIC_MILITARY      /decl/relic_category/mil // Previous military applications, though may not be strictly military in nature
#define RELIC_CIVILIAN      /decl/relic_category/civ // Previously used in daily civilian life - 'catch all' category
#define RELIC_RELIGION      /decl/relic_category/rel // Religious import to previous civilization, typically found in holy sites
#define RELIC_INDUSTRIAL    /decl/relic_category/ind // Industrial sites, waste dumps, etc.
#define RELIC_XENOLIFE      /decl/relic_category/xen // Related to xenoflora and xenofauna
#define RELIC_ANOMALY       /decl/relic_category/ano // Artifacts of bluespace anomalies -- not necessarily historical or tied to this planet

#define ALL_RELIC_TYPES		list(RELIC_MILITARY, RELIC_CIVILIAN, RELIC_RELIGION, RELIC_INDUSTRIAL, RELIC_XENOLIFE, RELIC_ANOMALY)
// Relic Type
#define RELIC_TRAP      /decl/relic/trap 	// Trap 'relics' -- should only be included on more dangerous digsites
#define RELIC_CURIO     /decl/relic/curio 	// "Miscellaneous", tag for relics that aren't otherwise easily categorized. Mostly mundane.
#define RELIC_MEDICAL   /decl/relic/medical // Medical implements, whether they be tools, devices, or otherwise.
#define RELIC_TOOL      /decl/relic/tool 	// Tools of various shapes and forms
#define RELIC_POWER     /decl/relic/power	// Anything related to power generation or consumption
#define RELIC_WEAPON    /decl/relic/weapon 	// Anything which seemingly had a prior primary function as a weapon, whether for self-defense or war
#define RELIC_DEVICE    /decl/relic/device 	// 'Devices' are anything from simple to extremely complex mechanical / electrical machinery; may be man-portable or not
#define RELIC_VEHICLE   /decl/relic/vehicle // Vehicle relics are what they suggest on the tin - the remains of once-active alien transport.
#define RELIC_REMAINS   /decl/relic/remains	// Remains are fossils or decomposed remains of xenolife, be it flora, fauna, or intelligent life

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

// Digsite Defines
#define DIGSITE_OPEN    "open air"      // Primarily involves cleaning already-surfaced relics; low-tier
#define DIGSITE_BURIED  "excavation"    // Requires digging through rock; low - mid tier
#define DIGSITE_RUIN    "ruin"          // Uses a pre-built ruin as a digsite; mid - high tier
#define DIGSITE_AWAY    "away site"     // Uses a pre-built away site as a digsite; high tier

// Society Tech Levels
/* 	Rough sort of tech tree definition of varying degrees
	Essentially defines how 'advanced' a civilization was in each field, to determine relics
	For reference, the current peak technology (i.e. what is theoretically available on Horizon) is somewhere between
	EXPERT and MASTER for all of the technologies. For more info see:
	http://www.projectrho.com/public_html/rocket/techlevel.php#travtech

	For a rough idea of scale -- basic transportation would be the car,
	advanced transportation being chemical rockets. Expert and master would
	bring the refinement of interplanetary and interstellar travel respectively,
	and the anomalous tier... is for everything that's difficult to explain.
*/
#define XENOTECH_NONE	0
#define XENOTECH_BASIC	1
#define XENOTECH_ADV	2
#define XENOTECH_EXPERT	3
#define XENOTECH_MASTER	4
#define XENOTECH_ANOM	5

#define XENOTECH_ENV	"environmental"
#define XENOTECH_TRAVEL	"transportation"
#define XENOTECH_ELEC	"electrical"
#define XENOTECH_MED	"medical"
#define XENOTECH_AI		"robotics"
#define XENOTECH_MIL	"military"
