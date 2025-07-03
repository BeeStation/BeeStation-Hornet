
#define ARMOUR_DROPOFF_START 50
#define ARMOUR_MAXIMUM 75

#define STANDARDISE_ARMOUR(val) round(CALCULATE_ARMOUR(val, ARMOUR_DROPOFF_START, (ARMOUR_MAXIMUM - ARMOUR_DROPOFF_START)), 1)

/// Calculate an armour value
/// val: The original armour value
/// armour_dropoff_start: The point at which to start diminishing returns on armour
/// armour_diff: The difference between the maximum armour value that can be returned and armour_dropoff_start
#define CALCULATE_ARMOUR(val, armour_dropoff_start, armour_diff) (val > armour_dropoff_start ? ((arctan((val - armour_dropoff_start) / (0.6 * armour_diff)) / 90) * armour_diff + armour_dropoff_start) : val)
