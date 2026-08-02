# ============================================================================
# MAPPING GENERATOR - Drill ↔ Knowledge
# ============================================================================
# Tạo quan hệ nhiều-nhiều giữa Drill và Knowledge

import json
import os
from pathlib import Path
from typing import Dict, List, Set

# ============================================================================
# CONFIG
# ============================================================================

KNOWLEDGE_DIR = "./Normalized/knowledge"
DRILLS_DIR = "./Drills"  # Drills data từ V2
OUTPUT_DIR = "./Mapping"

# ============================================================================
# CATEGORIES VÀ MAPPING RULES
# ============================================================================

# Category → Related Knowledge Keywords
CATEGORY_KEYWORDS = {
    "shotmaking": ["shot", "stop", "follow", "draw", "massé", "jump", "bank"],
    "aiming": ["aim", "ghost ball", "contact point", "object ball"],
    "position": ["position", "cue ball", "control", "speed"],
    "safety": ["safety", "play safe", "foul"],
    "psychology": ["focus", "mental", "confidence", "tilt"],
    "equipment": ["cue", "tip", "chalk", "table"],
    "rules": ["rules", "foul", "scratch"],
}

# Drill Code → Related Knowledge Slugs
DRILL_KNOWLEDGE_MAP = {
    # Stop Shot Drills
    "STOP_LV1": ["stop-shot", "cue-ball-control", "bridge", "follow-through"],
    "STOP_LV2": ["stop-shot", "speed-control", "aiming", "common-mistakes"],
    "STOP_LV3": ["stop-shot", "advanced", "precision"],

    # Draw Shot Drills
    "DRAW_LV1": ["draw-shot", "backspin", "cue-ball-control"],
    "DRAW_LV2": ["draw-shot", "speed-control", "position-play"],
    "DRAW_LV3": ["draw-shot", "advanced", "curve"],

    # Follow Shot Drills
    "FOLLOW_LV1": ["follow-shot", "topspin", "cue-ball-control"],
    "FOLLOW_LV2": ["follow-shot", "speed-control", "position-play"],
    "FOLLOW_LV3": ["follow-shot", "advanced"],

    # Position Drills
    "POSITION_LV1": ["position-play", "cue-ball-control", "speed"],
    "POSITION_LV2": ["position-play", "restoration", "pattern"],
    "POSITION_LV3": ["position-play", "advanced", "multi-ball"],

    # Straight Drills
    "STRAIGHT_LV1": ["aiming", "straight-shot", "foundation"],
    "STRAIGHT_LV2": ["aiming", "straight-shot", "accuracy"],
    "STRAIGHT_LV3": ["aiming", "straight-shot", "precision"],

    # Bank Drills
    "BANK_LV1": ["bank-shot", "reflection", "angle"],
    "BANK_LV2": ["bank-shot", "spin", "control"],
    "BANK_LV3": ["bank-shot", "advanced", "kick"],

    # Safety Drills
    "SAFETY_LV1": ["safety-play", "foul", "legal-shot"],
    "SAFETY_LV2": ["safety-play", "strategy", "leave"],
    "SAFETY_LV3": ["safety-play", "advanced", "snooker"],
}

# Knowledge → Related Drills (ngược lại)
KNOWLEDGE_DRILL_MAP = {
    "stop-shot": ["STOP_LV1", "STOP_LV2", "STOP_LV3"],
    "draw-shot": ["DRAW_LV1", "DRAW_LV2", "DRAW_LV3"],
    "follow-shot": ["FOLLOW_LV1", "FOLLOW_LV2", "FOLLOW_LV3"],
    "position-play": ["POSITION_LV1", "POSITION_LV2", "POSITION_LV3"],
    "aiming": ["STRAIGHT_LV1", "STRAIGHT_LV2", "STRAIGHT_LV3"],
    "bank-shot": ["BANK_LV1", "BANK_LV2", "BANK_LV3"],
    "safety-play": ["SAFETY_LV1", "SAFETY_LV2", "SAFETY_LV3"],
    "cue-ball-control": ["STOP_LV1", "DRAW_LV1", "FOLLOW_LV1", "POSITION_LV1"],
    "speed-control": ["STOP_LV2", "DRAW_LV2", "FOLLOW_LV2", "POSITION_LV2"],
    "bridge": ["STOP_LV1", "STRAIGHT_LV1", "BASIC"],
    "follow-through": ["STOP_LV1", "FOLLOW_LV1", "BASIC"],
}

# Common Mistakes per Category
COMMON_MISTAKES = {
    "stop-shot": [
        "Pulling the cue back too far",
        "Jerky follow through",
        "Not hitting center ball",
        "Looking up too early",
    ],
    "draw-shot": [
        "Hitting too high on cue ball",
        "Not following through",
        "Lifting the cue",
    ],
    "follow-shot": [
        "Not following through",
        "Stopping the cue",
        "Hitting too low",
    ],
    "position-play": [
        "Overcutting",
        "Undercutting",
        "Wrong speed",
    ],
}

# ============================================================================
# MAPPING GENERATORS
# ============================================================================

def generate_drill_knowledge_mapping() -> Dict:
    """Generate drill → knowledge mapping"""
    mapping = {}

    for drill_code, knowledge_slugs in DRILL_KNOWLEDGE_MAP.items():
        # Extract drill family and level
        parts = drill_code.split('_')
        drill_family = parts[0]
        level = int(parts[1].replace('LV', ''))

        # Find matching knowledge items
        knowledge_ids = []
        for slug in knowledge_slugs:
            knowledge_ids.append(f"kn_{slug}")

        # Add common mistakes
        mistakes = COMMON_MISTAKES.get(drill_family.lower(), [])

        mapping[drill_code] = {
            "drillCode": drill_family,
            "drillLevel": level,
            "knowledgeIds": knowledge_ids,
            "commonMistakes": mistakes,
            "tips": f"Practice {drill_family} with focus on smooth stroke.",
        }

    return mapping

def generate_knowledge_drill_mapping() -> Dict:
    """Generate knowledge → drill mapping"""
    mapping = {}

    for knowledge_slug, drill_codes in KNOWLEDGE_DRILL_MAP.items():
        knowledge_id = f"kn_{knowledge_slug}"

        mapping[knowledge_id] = {
            "knowledgeId": knowledge_id,
            "slug": knowledge_slug,
            "relatedDrills": drill_codes,
            "drillCount": len(drill_codes),
        }

    return mapping

def generate_category_mapping() -> Dict:
    """Generate category → knowledge mapping"""
    mapping = {}

    for category, keywords in CATEGORY_KEYWORDS.items():
        category_id = f"cat_{category}"
        knowledge_ids = []

        # Find all knowledge items matching keywords
        if os.path.exists(KNOWLEDGE_DIR):
            for filename in os.listdir(KNOWLEDGE_DIR):
                if filename.endswith('.json'):
                    with open(f"{KNOWLEDGE_DIR}/{filename}", 'r', encoding='utf-8') as f:
                        item = json.load(f)
                        item_text = f"{item.get('title', '')} {item.get('content', '')}".lower()
                        item_slug = item.get('slug', '').lower()

                        # Match by slug or keywords
                        for kw in keywords:
                            if kw in item_slug or kw in item_text:
                                knowledge_ids.append(item['id'])
                                break

        mapping[category_id] = {
            "categoryId": category_id,
            "knowledgeIds": list(set(knowledge_ids)),  # Remove duplicates
            "count": len(set(knowledge_ids)),
        }

    return mapping

# ============================================================================
# MAIN
# ============================================================================

def generate_all_mappings():
    """Generate all mapping files"""
    print("Generating mappings...")

    # Create output directories
    os.makedirs(f"{OUTPUT_DIR}/drill_knowledge", exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/knowledge_drill", exist_ok=True)
    os.makedirs(f"{OUTPUT_DIR}/category", exist_ok=True)

    # Drill → Knowledge
    drill_kn_mapping = generate_drill_knowledge_mapping()
    for drill_code, data in drill_kn_mapping.items():
        output_file = f"{OUTPUT_DIR}/drill_knowledge/{drill_code}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✓ Generated {len(drill_kn_mapping)} drill → knowledge mappings")

    # Knowledge → Drill
    kn_dr_mapping = generate_knowledge_drill_mapping()
    for kn_id, data in kn_dr_mapping.items():
        slug = data.pop('slug')
        output_file = f"{OUTPUT_DIR}/knowledge_drill/{kn_id}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✓ Generated {len(kn_dr_mapping)} knowledge → drill mappings")

    # Category → Knowledge
    cat_mapping = generate_category_mapping()
    with open(f"{OUTPUT_DIR}/category/all.json", 'w', encoding='utf-8') as f:
        json.dump(cat_mapping, f, ensure_ascii=False, indent=2)
    print(f"✓ Generated category mappings")

    # Generate summary
    summary = {
        "drillKnowledgeCount": len(drill_kn_mapping),
        "knowledgeDrillCount": len(kn_dr_mapping),
        "categoryCount": len(cat_mapping),
    }
    with open(f"{OUTPUT_DIR}/summary.json", 'w', encoding='utf-8') as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)

    print("Mapping generation complete!")

if __name__ == "__main__":
    generate_all_mappings()
