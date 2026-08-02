# ============================================================================
# MIGRATION SCRIPT - V1 to V2 Normalized
# ============================================================================
# Chạy: python migrate.py

import json
import os
import re
from pathlib import Path

# ============================================================================
# CONFIG
# ============================================================================

RAW_DIR = Path("./Raw")
OUTPUT_DIR = Path("./Normalized")
MAPPING_DIR = Path("./Mapping")
SEARCH_DIR = Path("./Search")

# ============================================================================
# CATEGORY MAPPING
# ============================================================================

CATEGORY_MAP = {
    "cueball": {
        "id": "cat_shotmaking",
        "slug": "shot-making",
        "name": "Shot Making",
        "nameVi": "Kỹ Thuật Đánh",
        "description": "Core shot techniques",
        "icon": "sports_cricket",
        "order": 2,
    },
    "aiming": {
        "id": "cat_aiming",
        "slug": "aiming",
        "name": "Aiming",
        "nameVi": "Ngắm Bắn",
        "description": "Aiming techniques and alignment",
        "icon": "gps_fixed",
        "order": 3,
    },
    "safety": {
        "id": "cat_strategy",
        "slug": "strategy",
        "name": "Strategy",
        "nameVi": "Chiến Lược",
        "description": "Game strategy and tactics",
        "icon": "psychology",
        "order": 5,
    },
    "bridge": {
        "id": "cat_fundamentals",
        "slug": "fundamentals",
        "name": "Fundamentals",
        "nameVi": "Nền Tảng",
        "description": "Basic techniques and posture",
        "icon": "school",
        "order": 1,
    },
    "strategy": {
        "id": "cat_strategy",
        "slug": "strategy",
        "name": "Strategy",
        "nameVi": "Chiến Lược",
        "description": "Game strategy and tactics",
        "icon": "psychology",
        "order": 5,
    },
}

# ============================================================================
# DIFFICULTY ESTIMATION
# ============================================================================

def estimate_difficulty(article_id, content):
    """Estimate difficulty based on content"""
    content_lower = content.lower()

    # Advanced keywords
    advanced_keywords = ['nâng cao', 'chuyên sâu', 'level 4', 'level 5', 'expert', 'advanced']
    if any(kw in content_lower for kw in advanced_keywords):
        return "advanced"

    # Intermediate keywords
    intermediate_keywords = ['trung bình', 'level 2', 'level 3', 'intermediate']
    if any(kw in content_lower for kw in intermediate_keywords):
        return "intermediate"

    return "beginner"

# ============================================================================
# TAG EXTRACTION
# ============================================================================

def extract_tags(article_id, content, category):
    """Extract tags from article"""
    tags = []

    # Category tag
    if category in CATEGORY_MAP:
        tags.append(f"tag_{category}")

    # Content-based tags
    content_lower = content.lower()

    if 'stop' in article_id or 'stop' in content_lower:
        tags.append("tag_shotmaking")
    if 'draw' in article_id or 'draw' in content_lower:
        tags.append("tag_shotmaking")
        tags.append("tag_backspin")
    if 'follow' in article_id or 'follow' in content_lower:
        tags.append("tag_shotmaking")
        tags.append("tag_topspin")
    if 'ghost' in article_id or 'ghost' in content_lower:
        tags.append("tag_aiming")
    if 'cut' in article_id or 'cut' in content_lower:
        tags.append("tag_aiming")
    if 'safety' in article_id or 'safety' in content_lower:
        tags.append("tag_strategy")
        tags.append("tag_defense")
    if 'bridge' in article_id or 'bridge' in content_lower:
        tags.append("tag_technique")
    if 'position' in article_id or 'position' in content_lower:
        tags.append("tag_positioning")
        tags.append("tag_strategy")

    return list(set(tags)) if tags else ["tag_basic"]

# ============================================================================
# DRILL MAPPING
# ============================================================================

DRILL_MAP = {
    "stop_shot": ["STOP_LV1", "STOP_LV2", "STOP_LV3"],
    "draw_shot": ["DRAW_LV1", "DRAW_LV2", "DRAW_LV3"],
    "follow_shot": ["FOLLOW_LV1", "FOLLOW_LV2", "FOLLOW_LV3"],
    "ghost_ball": ["STRAIGHT_LV1", "STRAIGHT_LV2"],
    "cut_shots": ["STRAIGHT_LV1", "STRAIGHT_LV2"],
    "basic_safety": ["SAFETY_LV1", "SAFETY_LV2"],
    "open_bridge": ["STRAIGHT_LV1"],
    "closed_bridge": ["STRAIGHT_LV1", "STRAIGHT_LV2"],
    "position_play": ["POSITION_LV1", "POSITION_LV2", "POSITION_LV3"],
}

# ============================================================================
# PARSE V1 KNOWLEDGE
# ============================================================================

def parse_v1_knowledge():
    """Parse V1 knowledge Dart file"""
    v1_file = RAW_DIR / "knowledge_v1.dart"

    if not v1_file.exists():
        print(f"❌ V1 file not found: {v1_file}")
        return [], []

    content = v1_file.read_text()

    # Extract articles
    articles = []

    # Find KnowledgeArticle constructors
    pattern = r'KnowledgeArticle\s*\(\s*id:\s*[\'"]([^\'"]+)[\'"]\s*,\s*title:\s*[\'"]([^\'"]+)[\'"]\s*,\s*titleVi:\s*[\'"]([^\'"]+)[\'"]\s*,\s*category:\s*[\'"]([^\'"]+)[\'"]\s*,\s*content:\s*\'\'\'(.*?)\'\'\''
    matches = re.findall(pattern, content, re.DOTALL)

    for match in matches:
        article_id, title, title_vi, category, article_content = match

        # Skip duplicates in category definitions
        if 'categories' in article_id:
            continue

        articles.append({
            "id": article_id,
            "title": title,
            "titleVi": title_vi,
            "category": category,
            "content": article_content.strip(),
        })

    print(f"✅ Found {len(articles)} articles from V1")

    # Extract categories
    categories = []
    for cat_id, cat_data in CATEGORY_MAP.items():
        categories.append(cat_data)

    return articles, categories

# ============================================================================
# CONVERT TO V2 FORMAT
# ============================================================================

def slugify(text):
    """Convert text to URL-friendly slug"""
    text = text.lower()
    text = re.sub(r'[àáạảãâầấậẩẫăằắặẳẵ]', 'a', text)
    text = re.sub(r'[èéẹẻẽêềếệểễ]', 'e', text)
    text = re.sub(r'[ìíịỉĩ]', 'i', text)
    text = re.sub(r'[òóọỏõôồốộổỗơờớợởỡ]', 'o', text)
    text = re.sub(r'[ùúụủũưừứựửữ]', 'u', text)
    text = re.sub(r'[ỳýỵỷỹ]', 'y', text)
    text = re.sub(r'[đ]', 'd', text)
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s+]', '-', text)
    text = re.sub(r'-+', '-', text)
    return text.strip('-')

def convert_article(article):
    """Convert V1 article to V2 format"""
    v2_article = {
        "id": f"kn_{slugify(article['id'])}",
        "slug": slugify(article['id']),
        "title": article['title'],
        "titleVi": article['titleVi'],
        "content": article['content'],
        "contentVi": article['content'],
        "categoryId": CATEGORY_MAP.get(article['category'], {}).get('id', 'cat_fundamentals'),
        "tagIds": extract_tags(article['id'], article['content'], article['category']),
        "aliases": extract_aliases(article),
        "keywords": extract_keywords(article),
        "difficulty": estimate_difficulty(article['id'], article['content']),
        "relatedKnowledgeIds": [],
        "relatedDrillCodes": DRILL_MAP.get(article['id'], []),
    }
    return v2_article

def extract_aliases(article):
    """Extract aliases from article"""
    aliases = []
    title = article['title'].lower()
    title_vi = article['titleVi'].lower()

    aliases.append(title)
    aliases.append(title_vi)

    # Add common variations
    if 'stop' in title:
        aliases.extend(['stop ball', 'dung', 'dung bi'])
    if 'draw' in title:
        aliases.extend(['draw', 'backspin', 'lui', 'quay lui'])
    if 'follow' in title:
        aliases.extend(['follow', 'topspin', 'theo', 'quay tới'])
    if 'bridge' in title:
        aliases.extend(['bridge', 'gac co', 'tay gac'])
    if 'safety' in title:
        aliases.extend(['safety', 'an toan', 'choi an toan'])
    if 'ghost' in title:
        aliases.extend(['ghost ball', 'bi ao', 'phuong phap bi ao'])
    if 'position' in title:
        aliases.extend(['position', 'vi tri', 'kiem soat vi tri'])

    return list(set(aliases))

def extract_keywords(article):
    """Extract keywords from article"""
    keywords = []
    content = article['content'].lower()
    title = article['title'].lower()

    keywords.append(title)

    # Technical terms
    tech_terms = [
        'stop shot', 'draw shot', 'follow shot', 'backspin', 'topspin',
        'ghost ball', 'aiming', 'bridge', 'safety', 'position',
        'cue ball', 'object ball', 'follow through', 'speed control',
        'cut shot', 'bank shot', 'spin'
    ]

    for term in tech_terms:
        if term in content or term in title:
            keywords.append(term)

    return list(set(keywords))

# ============================================================================
# GENERATE MAPPINGS
# ============================================================================

def generate_mappings(articles):
    """Generate drill <-> knowledge mappings"""
    drill_to_knowledge = {}
    knowledge_to_drill = {}

    for article in articles:
        v2_id = f"kn_{slugify(article['id'])}"
        drills = DRILL_MAP.get(article['id'], [])

        if drills:
            for drill in drills:
                if drill not in drill_to_knowledge:
                    drill_to_knowledge[drill] = []
                drill_to_knowledge[drill].append(v2_id)

            knowledge_to_drill[v2_id] = drills

    return drill_to_knowledge, knowledge_to_drill

# ============================================================================
# GENERATE SEARCH INDEX
# ============================================================================

def generate_search_index(articles):
    """Generate search index"""
    index = {
        "knowledge": [],
        "aliases": {},
        "keywords": {}
    }

    for article in articles:
        v2_id = f"kn_{slugify(article['id'])}"
        aliases = extract_aliases(article)
        keywords = extract_keywords(article)

        # Add to index
        index["knowledge"].append({
            "id": v2_id,
            "slug": slugify(article['id']),
            "title": article['title'],
            "titleVi": article['titleVi'],
        })

        # Alias index
        for alias in aliases:
            index["aliases"][alias.lower()] = v2_id

        # Keyword index
        for keyword in keywords:
            if keyword not in index["keywords"]:
                index["keywords"][keyword] = []
            index["keywords"][keyword].append(v2_id)

    return index

# ============================================================================
# MAIN
# ============================================================================

def main():
    print("=" * 60)
    print("MIGRATING V1 KNOWLEDGE TO V2")
    print("=" * 60)

    # Create directories
    OUTPUT_DIR.mkdir(exist_ok=True)
    MAPPING_DIR.mkdir(exist_ok=True)
    SEARCH_DIR.mkdir(exist_ok=True)

    # Parse V1
    articles, categories = parse_v1_knowledge()

    if not articles:
        print("❌ No articles found. Check V1 file.")
        return

    # Convert articles
    v2_articles = []
    for article in articles:
        v2_article = convert_article(article)
        v2_articles.append(v2_article)

        # Save individual file
        output_file = OUTPUT_DIR / f"{v2_article['id']}.json"
        output_file.write_text(
            json.dumps(v2_article, ensure_ascii=False, indent=2)
        )

    print(f"✅ Converted {len(v2_articles)} articles")

    # Save categories
    categories_file = OUTPUT_DIR / "categories.json"
    categories_file.write_text(
        json.dumps(categories, ensure_ascii=False, indent=2)
    )
    print(f"✅ Saved {len(categories)} categories")

    # Save all articles as single file
    all_knowledge_file = OUTPUT_DIR / "all_knowledge.json"
    all_knowledge_file.write_text(
        json.dumps(v2_articles, ensure_ascii=False, indent=2)
    )

    # Generate mappings
    drill_to_knowledge, knowledge_to_drill = generate_mappings(articles)

    mapping_file = MAPPING_DIR / "drill_knowledge.json"
    mapping_file.write_text(
        json.dumps(drill_to_knowledge, ensure_ascii=False, indent=2)
    )

    knowledge_drill_file = MAPPING_DIR / "knowledge_drill.json"
    knowledge_drill_file.write_text(
        json.dumps(knowledge_to_drill, ensure_ascii=False, indent=2)
    )

    print(f"✅ Generated mappings: {len(drill_to_knowledge)} drills")

    # Generate search index
    search_index = generate_search_index(articles)
    search_file = SEARCH_DIR / "index.json"
    search_file.write_text(
        json.dumps(search_index, ensure_ascii=False, indent=2)
    )

    print(f"✅ Generated search index: {len(search_index['knowledge'])} items")

    # Summary
    print("\n" + "=" * 60)
    print("MIGRATION COMPLETE")
    print("=" * 60)
    print(f"📁 Normalized: {len(v2_articles)} articles")
    print(f"📁 Categories: {len(categories)} categories")
    print(f"📁 Mappings: {len(drill_to_knowledge)} drill mappings")
    print(f"📁 Search: {len(search_index['knowledge'])} indexed items")
    print("=" * 60)

if __name__ == "__main__":
    main()
