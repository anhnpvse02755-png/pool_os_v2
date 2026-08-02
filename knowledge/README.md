# Knowledge Architecture - V2

## Mục tiêu
Tận dụng tri thức từ V1, xây dựng V2 với kiến trúc sạch.

## Cấu trúc thư mục

```
Knowledge/
├── Raw/                    ← Import toàn bộ từ V1
│   ├── articles/          ← Knowledge items gốc
│   ├── categories/        ← Categories gốc
│   ├── tags/             ← Tags gốc
│   ├── glossary/         ← Thuật ngữ
│   └── learning_paths/   ← Learning paths gốc
│
├── Normalized/            ← Dữ liệu đã chuẩn hóa
│   ├── knowledge/         ← Knowledge items chuẩn hóa
│   ├── categories/       ← Categories chuẩn hóa
│   ├── tags/             ← Tags chuẩn hóa
│   └── glossary/         ← Glossary chuẩn hóa
│
├── Mapping/              ← Knowledge ↔ Drill relationships
│   ├── drill_knowledge/  ← Drill → Knowledge
│   └── knowledge_drill/  ← Knowledge → Drill
│
├── Search/               ← Index cho tìm kiếm
│   ├── index.json       ← Full-text index
│   └── aliases/          ← Alias index
│
├── Assets/               ← Media files
│   ├── images/
│   ├── videos/
│   └── gifs/
│
└── Version/             ← Version tracking
    ├── v1_export.json
    └── migrations/
```

## Nguyên tắc

1. **Raw không sửa** - Giữ nguyên V1
2. **Normalized đọc từ Raw** - Không đọc trực tiếp Raw
3. **Mapping tự động** - Sinh từ drill-knowledge relationships
4. **Assets tách riêng** - Dễ quản lý

## Migration Flow

```
V1 Repository
    ↓ (export)
Raw/
    ↓ (migration script)
Normalized/
    ↓ (mapping script)
Mapping/
    ↓ (index script)
Search/
```
