"""
Maintenance Loot Probability Analyzer
Analyzes and visualizes the probability distribution of maintenance loot items
"""

import re
import os
import sys

def extract_weights_from_dm(filepath="code/_globalvars/lists/maintenance_loot.dm"):
    """Extract weight definitions from maintenance_loot.dm"""
    weights = {}

    # Pattern to match #define statements like: #define maint_trash_weight 4500
    weight_pattern = re.compile(r'#define\s+(maint_\w+_weight)\s+(\d+)')

    # Handle relative path from tools directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    full_path = os.path.join(repo_root, filepath)

    if not os.path.exists(full_path):
        print(f"Error: Could not find {filepath}")
        print(f"Looked in: {full_path}")
        sys.exit(1)

    with open(full_path, 'r', encoding='utf-8') as f:
        for line in f:
            match = weight_pattern.match(line.strip())
            if match:
                weight_name = match.group(1).upper()  # Convert to uppercase
                weight_value = int(match.group(2))
                weights[weight_name] = weight_value

    return weights

# Automatically extract weights from the DM file
weights = extract_weights_from_dm()
MAINT_TRASH_WEIGHT = weights.get('MAINT_TRASH_WEIGHT', 4500)
MAINT_COMMON_WEIGHT = weights.get('MAINT_COMMON_WEIGHT', 4500)
MAINT_UNCOMMON_WEIGHT = weights.get('MAINT_UNCOMMON_WEIGHT', 900)
MAINT_RARITY_WEIGHT = weights.get('MAINT_RARITY_WEIGHT', 99)
MAINT_ODDITY_WEIGHT = weights.get('MAINT_ODDITY_WEIGHT', 1)

# Total weight
TOTAL_WEIGHT = (MAINT_TRASH_WEIGHT + MAINT_COMMON_WEIGHT +
                MAINT_UNCOMMON_WEIGHT + MAINT_RARITY_WEIGHT + MAINT_ODDITY_WEIGHT)

# Category data
categories = {
    "Trash/Junk": {
        "weight": MAINT_TRASH_WEIGHT,
        "subcategories": {
            "Trash items": 8,
            "Tier 1 stock parts": 1
        }
    },
    "Common": {
        "weight": MAINT_COMMON_WEIGHT,
        "subcategories": {
            "Tools": 1,
            "Equipment": 1,
            "Construction/Crafting": 1,
            "Medical/Chemicals": 1,
            "Food": 1,
            "Misc": 1
        }
    },
    "Uncommon": {
        "weight": MAINT_UNCOMMON_WEIGHT,
        "subcategories": {
            "Tools": 8,
            "Equipment": 8,
            "Construction/Crafting": 8,
            "Medical/Chemicals": 8,
            "Food": 8,
            "Xenoartifacts": 6,
            "Modsuits": 4,
            "Music": 2,
            "Fakeout items": 1
        }
    },
    "Rare": {
        "weight": MAINT_RARITY_WEIGHT,
        "subcategories": {
            "Tools": 1,
            "Equipment": 1,
            "Paint": 1,
            "Medical/Chemicals": 1,
            "Misc": 1
        }
    },
    "Oddity": {
        "weight": MAINT_ODDITY_WEIGHT,
        "subcategories": {
            "Oddities": 1
        }
    }
}


def calculate_percentages():
    """Calculate percentage for each category"""
    results = {}

    for category, data in categories.items():
        percentage = (data["weight"] / TOTAL_WEIGHT) * 100
        results[category] = {
            "weight": data["weight"],
            "percentage": percentage,
            "subcategories": data["subcategories"]
        }

    return results


def print_basic_stats():
    """Print basic statistics"""
    print("=" * 70)
    print("MAINTENANCE LOOT PROBABILITY ANALYSIS")
    print("=" * 70)
    print()
    print(f"Total Weight: {TOTAL_WEIGHT:,}")
    print()

    results = calculate_percentages()

    print("CATEGORY PROBABILITIES:")
    print("-" * 70)
    print(f"{'Category':<20} {'Weight':<10} {'Percentage':<15} {'Visual'}")
    print("-" * 70)

    for category, data in results.items():
        bar_length = int(data["percentage"] / 2)  # Scale for display
        bar = "█" * bar_length
        print(f"{category:<20} {data['weight']:<10,} {data['percentage']:>6.2f}%        {bar}")

    print()
    print("=" * 70)
    print()

    # Odds formatting
    print("ODDS OF GETTING EACH CATEGORY:")
    print("-" * 70)
    for category, data in results.items():
        odds = TOTAL_WEIGHT / data["weight"]
        print(f"{category:<20} 1 in {odds:>7.2f} ({data['percentage']:.4f}%)")

    print()
    print("=" * 70)
    print()

    # Show subcategory breakdown
    print("DETAILED SUBCATEGORY BREAKDOWN:")
    print("-" * 70)

    for category, data in results.items():
        print(f"\n{category.upper()} ({data['percentage']:.2f}%):")

        # Calculate total subcategory weight
        total_subcat_weight = sum(data["subcategories"].values())

        for subcat, weight in data["subcategories"].items():
            # Probability within the category
            prob_in_category = (weight / total_subcat_weight) * 100
            # Overall probability
            overall_prob = (data["weight"] / TOTAL_WEIGHT) * (weight / total_subcat_weight) * 100

            print(f"  {subcat:<30} {prob_in_category:>6.2f}% of category | {overall_prob:>6.3f}% overall")

    print()
    print("=" * 70)
    print()


def print_chances_per_spawns():
    """Calculate probability of getting at least one item from each category"""
    print("PROBABILITY OF GETTING AT LEAST ONE ITEM (given X spawns):")
    print("-" * 70)

    results = calculate_percentages()
    spawn_counts = [1, 10, 50, 100, 150, 180]  # 180 is metastation average

    print(f"{'Category':<20}", end="")
    for count in spawn_counts:
        print(f"{count:>10} ", end="")
    print()
    print("-" * 70)

    for category, data in results.items():
        prob_single = data["percentage"] / 100
        print(f"{category:<20}", end="")

        for count in spawn_counts:
            # Probability of at least one: 1 - (probability of none)
            prob_at_least_one = (1 - (1 - prob_single) ** count) * 100
            print(f"{prob_at_least_one:>9.2f}%", end=" ")
        print()

    print()
    print("Note: Metastation has 129 base spawners + ~51 from random rooms = ~180 total per round")
    print()
    print("=" * 70)
    print()


def print_expected_counts():
    """Calculate expected number of items per category"""
    print("EXPECTED NUMBER OF ITEMS PER CATEGORY:")
    print("-" * 70)

    results = calculate_percentages()
    spawn_counts = [50, 100, 150, 180]

    print(f"{'Category':<20}", end="")
    for count in spawn_counts:
        print(f"{count:>10} ", end="")
    print()
    print("-" * 70)

    for category, data in results.items():
        prob_single = data["percentage"] / 100
        print(f"{category:<20}", end="")

        for count in spawn_counts:
            expected = prob_single * count
            print(f"{expected:>10.2f}", end=" ")
        print()

    print()
    print("=" * 70)


if __name__ == "__main__":
    print_basic_stats()
    print_chances_per_spawns()
    print_expected_counts()
