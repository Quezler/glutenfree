-- in the control stage we check every x ticks for new items, so this constant must be equal or higher to that:
assert(data.raw["utility-constants"]["default"].ejected_item_lifetime >= 60 * 5)
