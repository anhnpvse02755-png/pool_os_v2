# ============================================================================
# MIGRATION SCRIPT - V1 to V2
# ============================================================================
# Chuyển đổi data từ V1 sang định dạng chuẩn hóa V2

import json
import os
from pathlib import Path
from typing import Dict, List, Any

# ============================================================================
# CONFIG
# ============================================================================

V1_SOURCE = "./v1_export"  # Thư mục export từ V1
V2_OUTPUT = "./Normalized"   # Thư mục output V2

# ============================================================================
# MIGRATION HELPERS
# ============================================================================

def slugify(text: str) -> str:
    """Convert text to URL-friendly slug"""
    return text.lower().replace(' ', '-').replace('_', '-')

def generate_id(prefix: str, text: str) -> str:
    """Generate consistent ID from prefix and text"""
    slug = slugify(text)
    return f"{prefix}_{slug}"

def migrate_knowledge_item(v1_item: Dict) -> Dict:
    """Migrate single knowledge item from V1 to V2 format"""
    return {
        "id": v1_item.get("id", generate_id("kn", v1_item.get("title", ""))),
        "slug": slugify(v1_item.get("title", "")),
        "title": v1_item.get("title", ""),
        "titleVi": v1_item.get("title_vi") or v1_item.get("titleVi"),
        "content": v1_item.get("content", ""),
        "contentVi": v1_item.get("content_vi") or v1_item.get("contentVi"),
        "categoryId": v1_item.get("category_id", ""),
        "tagIds": v1_item.get("tags", []),
        "aliases": v1_item.get("aliases", []),
        "keywords": v1_item.get("keywords", []),
        "difficulty": v1_item.get("difficulty", "beginner"),
        "imageUrl": v1_item.get("image"),
        "relatedKnowledgeIds": v1_item.get("related", []),
        "relatedDrillCodes": v1_item.get("related_drills", []),
        "sourceUrl": v1_item.get("source"),
        "createdAt": v1_item.get("created_at"),
        "updatedAt": v1_item.get("updated_at"),
    }

def migrate_category(v1_cat: Dict) -> Dict:
    """Migrate category from V1 to V2 format"""
    return {
        "id": v1_cat.get("id", generate_id("cat", v1_cat.get("name", ""))),
        "slug": slugify(v1_cat.get("name", "")),
        "name": v1_cat.get("name", ""),
        "nameVi": v1_cat.get("name_vi") or v1_cat.get("nameVi"),
        "description": v1_cat.get("description", ""),
        "icon": v1_cat.get("icon", "book"),
        "order": v1_cat.get("order", 0),
        "knowledgeIds": v1_cat.get("items", []),
    }

def migrate_tag(v1_tag: Dict) -> Dict:
    """Migrate tag from V1 to V2 format"""
    return {
        "id": v1_tag.get("id", generate_id("tag", v1_tag.get("name", ""))),
        "name": v1_tag.get("name", ""),
        "nameVi": v1_tag.get("name_vi") or v1_tag.get("nameVi"),
        "color": v1_tag.get("color"),
    }

# ============================================================================
# MAIN MIGRATION
# ============================================================================

def migrate_all():
    """Main migration function"""
    print("Starting V1 to V2 migration...")

    # Create output directories
    os.makedirs(f"{V2_OUTPUT}/knowledge", exist_ok=True)
    os.makedirs(f"{V2_OUTPUT}/categories", exist_ok=True)
    os.makedirs(f"{V2_OUTPUT}/tags", exist_ok=True)
    os.makedirs(f"{V2_OUTPUT}/glossary", exist_ok=True)

    # Migrate Knowledge Items
    knowledge_source = f"{V1_SOURCE}/articles/"
    if os.path.exists(knowledge_source):
        for filename in os.listdir(knowledge_source):
            if filename.endswith('.json'):
                with open(f"{knowledge_source}/{filename}", 'r', encoding='utf-8') as f:
                    v1_item = json.load(f)
                    v2_item = migrate_knowledge_item(v1_item)

                    output_file = f"{V2_OUTPUT}/knowledge/{v2_item['id']}.json"
                    with open(output_file, 'w', encoding='utf-8') as out:
                        json.dump(v2_item, out, ensure_ascii=False, indent=2)
        print(f"✓ Migrated knowledge items")

    # Migrate Categories
    categories_source = f"{V1_SOURCE}/categories/"
    if os.path.exists(categories_source):
        for filename in os.listdir(categories_source):
            if filename.endswith('.json'):
                with open(f"{categories_source}/{filename}", 'r', encoding='utf-8') as f:
                    v1_cat = json.load(f)
                    v2_cat = migrate_category(v1_cat)

                    output_file = f"{V2_OUTPUT}/categories/{v2_cat['id']}.json"
                    with open(output_file, 'w', encoding='utf-8') as out:
                        json.dump(v2_cat, out, ensure_ascii=False, indent=2)
        print(f"✓ Migrated categories")

    # Migrate Tags
    tags_source = f"{V1_SOURCE}/tags/"
    if os.path.exists(tags_source):
        all_tags = []
        for filename in os.listdir(tags_source):
            if filename.endswith('.json'):
                with open(f"{tags_source}/{filename}", 'r', encoding='utf-8') as f:
                    v1_tag = json.load(f)
                    v2_tag = migrate_tag(v1_tag)
                    all_tags.append(v2_tag)

        with open(f"{V2_OUTPUT}/tags/all.json", 'w', encoding='utf-8') as out:
            json.dump(all_tags, out, ensure_ascii=False, indent=2)
        print(f"✓ Migrated {len(all_tags)} tags")

    # Generate index
    generate_search_index()

    print("Migration complete!")

def generate_search_index():
    """Generate search index from migrated data"""
    index = {
        "knowledge": [],
        "categories": [],
        "tags": [],
    }

    # Index knowledge
    knowledge_dir = f"{V2_OUTPUT}/knowledge"
    for filename in os.listdir(knowledge_dir):
        if filename.endswith('.json'):
            with open(f"{knowledge_dir}/{filename}", 'r', encoding='utf-8') as f:
                item = json.load(f)
                index["knowledge"].append({
                    "id": item["id"],
                    "slug": item["slug"],
                    "title": item["title"],
                    "titleVi": item.get("titleVi"),
                    "aliases": item.get("aliases", []),
                    "keywords": item.get("keywords", []),
                })

    print(f"✓ Generated search index with {len(index['knowledge'])} items")

# ============================================================================
# RUN
# ============================================================================

if __name__ == "__main__":
    migrate_all()
