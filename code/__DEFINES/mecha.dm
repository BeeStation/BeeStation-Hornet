#define MECHA_INT_FIRE (1<<0)
#define MECHA_INT_TEMP_CONTROL (1<<1)
#define MECHA_INT_SHORT_CIRCUIT (1<<2)
#define MECHA_CABIN_AIR_BREACH (1<<3)
#define MECHA_INT_CONTROL_LOST (1<<4)

//Mech flags
#define PANEL_OPEN (1<<0)
#define ID_LOCK_ON (1<<1)
#define CAN_STRAFE (1<<2)
#define LIGHTS_ON (1<<3)
#define SILICON_PILOT (1<<4)
#define IS_ENCLOSED (1<<5)
#define HAS_LIGHTS (1<<6)
#define QUIET_STEPS (1<<7)
#define QUIET_TURNS (1<<8)
#define CANNOT_INTERACT (1<<9)
/// posibrains can drive this mecha (savanna ivanov for later)
#define MMI_COMPATIBLE (1<<10)
/// Can click from any direction and perform stuff
#define OMNIDIRECTIONAL_ATTACKS (1<<11)

#define MECHA_MELEE (1 << 0)
#define MECHA_RANGED (1 << 1)

#define MECHA_FRONT_ARMOUR "mechafront"
#define MECHA_SIDE_ARMOUR "mechaside"
#define MECHA_BACK_ARMOUR "mechaback"

#define MECHA_WEAPON "mecha_weapon" //l and r arm weapon type
#define MECHA_L_ARM "mecha_l_arm"
#define MECHA_R_ARM "mecha_r_arm"
#define MECHA_UTILITY "mecha_utility"
#define MECHA_POWER "mecha_power"
#define MECHA_ARMOR "mecha_armor"

// Some mechs must (at least for now) use snowflake handling of their UI elements, these defines are for that
// when changing MUST update the same-named tsx file constants
#define MECHA_SNOWFLAKE_ID_SLEEPER "sleeper_snowflake"
#define MECHA_SNOWFLAKE_ID_SYRINGE "syringe_snowflake"
#define MECHA_SNOWFLAKE_ID_MODE "mode_snowflake"
#define MECHA_SNOWFLAKE_ID_EXTINGUISHER "extinguisher_snowflake"
#define MECHA_SNOWFLAKE_ID_EJECTOR "ejector_snowflake"
#define MECHA_SNOWFLAKE_ID_OREBOX_MANAGER "orebox_manager_snowflake"
#define MECHA_SNOWFLAKE_ID_RADIO "radio_snowflake"
#define MECHA_SNOWFLAKE_ID_AIR_TANK "air_tank_snowflake"
#define MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC "ballistic_weapon_snowflake"
#define MECHA_SNOWFLAKE_ID_GENERATOR "generator_snowflake"

#define MECHA_AMMO_INCENDIARY "Incendiary bullet"
#define MECHA_AMMO_BUCKSHOT "Buckshot shell"
#define MECHA_AMMO_LMG "LMG bullet"
#define MECHA_AMMO_MISSILE_SRM "SRM missile"
#define MECHA_AMMO_MISSILE_PEP "PEP missile"
#define MECHA_AMMO_FLASHBANG "Flashbang"
#define MECHA_AMMO_CLUSTERBANG "Clusterbang"
#define MECHA_AMMO_PUNCHING_GLOVE "Punching glove"
#define MECHA_AMMO_BANANA_PEEL "Banana peel"
#define MECHA_AMMO_MOUSETRAP "Mousetrap"
