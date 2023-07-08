/**
 * Stores a list of items that had their leftmost and rightmost pixels found before, for the sake of optimization
 *
 * Format :
 * * cached_image_borders[type] = list("left" = x, "right" = y)
 */
GLOBAL_LIST_EMPTY(cached_image_borders)
