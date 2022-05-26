// Relic Grades
#define RELIC_MUNDANE 		0
#define RELIC_UNCOMMON		1
#define RELIC_RARE			2
#define RELIC_ANTAG			3
#define RELIC_SPECIAL		4

// Relic Type
#define RELIC_TRAP      /decl/relic/trap 		// Trap 'relics' -- should only be included on more dangerous digsites
#define RELIC_CURIO     /decl/relic/curio 		// "Miscellaneous", tag for relics that aren't otherwise easily categorized. Mostly mundane.
#define RELIC_MEDICAL   /decl/relic/medical		// Medical implements, whether they be tools, devices, or otherwise.
#define RELIC_TOOL      /decl/relic/tool 		// Tools of various shapes and forms
#define RELIC_POWER     /decl/relic/power		// Anything related to power generation or consumption
#define RELIC_WEAPON    /decl/relic/weapon 		// Weapons and armor
#define RELIC_DEVICE    /decl/relic/device 		// 'Devices' are anything from simple to extremely complex mechanical / electrical machinery; may be man-portable or not
#define RELIC_VEHICLE   /decl/relic/vehicle 	// Vehicle relics are what they suggest on the tin - the remains of once-active alien transport.
#define RELIC_REMAINS   /decl/relic/remains		// Remains are fossils or decomposed remains of xenolife, be it flora, fauna, or intelligent life
#define RELIC_CLOTHING	/decl/relic/clothing	// Anything that can be worn that isn't armor

// Relic Activation Conditions
#define RELIC_INERT			0
#define RELIC_ACTIVE		1
#define RELIC_ALWAYSON		2

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
#define DIGSITE_OPEN		0	// Primarily involves cleaning already-surfaced relics; low-tier
#define DIGSITE_BURIED		1	// Requires digging through rock; low - mid tier
#define DIGSITE_RUIN		2	// Uses a pre-built ruin as a digsite; mid - high tier
#define DIGSITE_AWAY		3	// Uses a pre-built away site as a digsite; high tier
