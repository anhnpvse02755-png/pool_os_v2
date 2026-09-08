"""Shared helpers for building knowledge items from the billiard dictionary.

Source: Tu-Dien-Kien-Thuc-Billiard-Pool.md

Every dictionary-sourced article keeps the dictionary's five blocks so the
detail screen renders a predictable shape:

    ## Mô tả
    ## Hướng dẫn thực hiện
    ## Lưu ý
    ## Lỗi thường gặp
    ## Cách sửa
"""

SOURCE = "Từ Điển Kiến Thức Billiard Pool"

VI_HEADINGS = [
    "Mô tả",
    "Hướng dẫn thực hiện",
    "Lưu ý",
    "Lỗi thường gặp",
    "Cách sửa",
]

EN_HEADINGS = [
    "Overview",
    "How to do it",
    "Key points",
    "Common mistakes",
    "How to fix",
]


def _block(heading, body):
    """Render one '## heading' section followed by its body."""
    return "## {}\n\n{}".format(heading, body.strip())


def _compose(headings, parts):
    return "\n\n".join(_block(h, p) for h, p in zip(headings, parts))


def _reading_time(text):
    """Roughly 200 words per minute, floored at 2 minutes."""
    return max(2, round(len(text.split()) / 200))


def item(
    *,
    id,
    slug,
    title,
    title_vi,
    category,
    difficulty,
    tags,
    aliases,
    keywords,
    vi,
    en,
    related=(),
    drills=(),
):
    """Build one knowledge item in the schema knowledge.json uses.

    `vi` and `en` are 5-tuples matching the dictionary's block order:
    (mô tả, hướng dẫn, lưu ý, lỗi thường gặp, cách sửa).
    """
    if len(vi) != 5 or len(en) != 5:
        raise ValueError("{}: expected 5 content blocks".format(id))

    content_vi = _compose(VI_HEADINGS, vi)
    content_en = _compose(EN_HEADINGS, en)

    return {
        "id": id,
        "slug": slug,
        "title": title,
        "titleVi": title_vi,
        "content": content_en,
        "contentVi": content_vi,
        "categoryId": category,
        "tagIds": list(tags),
        "difficulty": difficulty,
        "aliases": list(aliases),
        "keywords": list(keywords),
        "relatedKnowledgeIds": list(related),
        "relatedDrillCodes": list(drills),
        "readingTimeMinutes": _reading_time(content_vi),
        "media": {},
        "sources": [SOURCE],
        "imageUrl": None,
    }
