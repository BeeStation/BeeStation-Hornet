/datum/damage_source/sharp

/// Small and light but sharp weapons like knives
/datum/damage_source/sharp/light

/// Heavy and sharp weapons like large swords
/// Either by slicing or stabbing, without armour this will be likely to
/// penetrate the skin and cause internal damage and bleeding.
/datum/damage_source/sharp/heavy

/datum/damage_source/blunt

/// Light and blunt weaker weapons like toolboxes
/datum/damage_source/blunt/light

/// Heavy but blunt weapons like battle hammers
/datum/damage_source/blunt/heavy

/// A constant source of damage drilling into the skin.
/// Pretty bad but respects melee armour.
/datum/damage_source/drill

/// Something pricked directly in the skin, bypasses armour
/// Ignored if the mob has TRAIT_PIERCEIMMUNE
/datum/damage_source/skin_prick

/// For when you rip a bodypart (un)cleanly off with sheer force.
/// Will force screaming
/datum/damage_source/forceful_laceration

/// Caused by impact of objects colliding with each other
/// May cause head trauma if hit on the head
/// Affected by armour
/datum/damage_source/impact

/// Caused by an object inside of a mob bursting out through their skin
/// Causes intense bleeding and internal damage
/datum/damage_source/internal_rupture

/// Caused by an explosion, obviously
/datum/damage_source/explosion

/// Electrical damage to a mechanical source
/datum/damage_source/electrical_damage

/// Caused by fatigue from doing an action over and over.
/// Bypasses all armour.
/datum/damage_source/fatigue

/// Damage caused by consuming something you shouldn't have. Highly likely to cause
/// internal damage and bypasses armour.
/datum/damage_source/consumption

/// Caused by accidentally burning yourself on something.
/// Will account for armour or gloves if you are wearing any and the target is a precise hand
/datum/damage_source/accidental_burn

/// Damage caused by exposure to high temperatures, reduced by wearing temperature resistant
/// clothing.
/datum/damage_source/temperature

/// Electrical damage.
/// Applies the stutter effect.
/datum/damage_source/shock

/// Damage caused by a religious source. Damage is reduced by a null rod
/// or magic protection.
/datum/damage_source/magic

/// Abstract magic damage not blocked by a null rod
/datum/damage_source/magic/abstract

/// Damaged caused by stun shock weapons.
/// Blocked by the stamina damage flag.
/// Applies the stutter effect.
/datum/damage_source/stun

/// Caused by chemicals injested inside the body. Bypasses armour and causes
/// internal damage.
/datum/damage_source/chemical

/// Damage caused by external acid burns. Respects acid armour
/datum/damage_source/acid_burns

/// Damage caused by mental trauma
/// TODO: Rename to mental_trauma
/datum/damage_source/mental_health

/// Damage caused by a bullet. If not blocked by armour, will be penetrating
/// and may cause internal damage.
/datum/damage_source/bullet
