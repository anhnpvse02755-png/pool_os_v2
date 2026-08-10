# TOURNAMENT CREATION SCREEN

## MÀN HÌNH: Tạo Giải Đấu Mới

```
┌────────────────────────────────────────────┐
│ ← Tạo giải đấu                          │
├────────────────────────────────────────────┤
│                                            │
│ Tên giải *                                │
│ ┌────────────────────────────────────────┐│
│ │ Giải PoolOS Mùa 1                    ││
│ └────────────────────────────────────────┘│
│                                            │
│ Loại giải *                                │
│ ┌────────────┐ ┌────────────┐           │
│ │ ○ Vòng tròn│ │ ● Knockout │           │
│ └────────────┘ └────────────┘           │
│ ┌────────────┐ ┌────────────┐           │
│ │ ○ Chia bảng│ │ ○ Hệ kết  │           │
│ └────────────┘ └────────────┘           │
│                                            │
│ Số người chơi                             │
│ [4] [8] [16] [32]                        │
│                                            │
│ Thời gian                                 │
│ Ngày bắt đầu: [08/08/2026]              │
│ Ngày kết thúc: [15/08/2026]             │
│                                            │
│ Địa điểm (tùy chọn)                     │
│ ┌────────────────────────────────────────┐│
│ │ VD: CLB Pool Hà Nội                   ││
│ └────────────────────────────────────────┘│
│                                            │
│ Race to (số bi thắng mỗi trận)          │
│ [1] [3] [5] [7]                          │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│    [Huỷ]          [Tạo giải]             │
│                                            │
└────────────────────────────────────────────┘
```

---

## LOẠI GIẢI

### 1. Vòng tròn (Round Robin)
```
Mỗi người đấu với tất cả người khác
→ Tính điểm: Win = 3đ, Draw = 1đ, Lose = 0đ
→ Xếp hạng theo tổng điểm
→ Có thể chọn top N vào vòng tiếp theo
```

### 2. Knockout (Đấu loại)
```
Đấu 1 lần → Thua = Out
VD: 8 người → Tứ kết (4 trận) → Bán kết (2 trận) → Chung kết (1 trận)
→ Không có trận tranh hạng 3
```

### 3. Chia bảng (Group Stage)
```
 Chia thành N bảng (VD: 16 người → 4 bảng × 4 người)
→ Đấu vòng tròn trong bảng
→ Top 2/4 mỗi bảng vào vòng loại trực tiếp
```

### 4. Hệ kết hợp (Combined)
```
Vòng bảng → Vòng loại trực tiếp
VD: 16 người → 2 bảng 8 → Top 4 mỗi bảng → Tứ kết
```

---

## FLOW: Tạo Giải

```
1. User nhập thông tin giải
2. Chọn loại giải
3. Tạo giải → Vào màn hình quản lý giải
```

---

## MÀN HÌNH: Quản lý Giải Đấu

```
┌────────────────────────────────────────────┐
│ ← Giải PoolOS Mùa 1           [⚙️]       │
├────────────────────────────────────────────┤
│                                            │
│ 🔵 ĐANG DIỄN RA • Vòng 2/5               │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ 👥 8/16 người đăng ký                    │
│ [+ Mời người chơi]                       │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ 📊 Bảng xếp hạng (Vòng tròn)            │
│ ┌────┬─────────────┬────┬────┬────┐     │
│ │ #  │ Tên        │ W  │ D  │ L  │     │
│ ├────┼─────────────┼────┼────┼────┤     │
│ │ 1  │ Nguyễn A   │ 3  │ 0  │ 0  │     │
│ │ 2  │ Trần B     │ 2  │ 1  │ 0  │     │
│ │ 3  │ Lê C       │ 2  │ 0  │ 1  │     │
│ │ 4  │ Phạm D     │ 1  │ 1  │ 1  │     │
│ └────┴─────────────┴────┴────┴────┘     │
│                                            │
├────────────────────────────────────────────┤
│                                            │
│ 📋 Lịch đấu                              │
│ ┌────────────────────────────────────────┐│
│ │ Vòng 3                               ││
│ │ ─────────────────────────────────────││
│ │ ● Trần B vs Lê C     [Ghi kết quả] ││
│ │ ○ Nguyễn A vs Phạm D [Ghi kết quả] ││
│ └────────────────────────────────────────┘│
│                                            │
└────────────────────────────────────────────┘
```

---

## MÀN HÌNH: Nhập Kết Quả Trận Đấu

```
┌────────────────────────────────────────────┐
│ Kết quả trận đấu                         │
├────────────────────────────────────────────┤
│                                            │
│        Trần B    vs    Lê C               │
│         (1)              (3)               │
│                                            │
│  ┌──────────┐  ┌──────────┐              │
│  │    -     │  │    -     │              │
│  └──────────┘  └──────────┘              │
│   [−]  [+]      [−]  [+]                 │
│                                            │
│  ──────────────────────────────────────── │
│                                            │
│  Winner:  (○) Trần B    (●) Lê C        │
│                                            │
│  ──────────────────────────────────────── │
│                                            │
│           [Lưu kết quả]                   │
│                                            │
└────────────────────────────────────────────┘
```

---

## MÀN HÌNH: Knockout Bracket

```
┌────────────────────────────────────────────┐
│ 🏆 Hệ Knockout - 8 người                 │
├────────────────────────────────────────────┤
│                                            │
│    Tứ kết        Bán kết      Chung kết   │
│                                            │
│   ┌───┐                                   │
│   │ A │──┐                               │
│   └───┘  │    ┌───┐                      │
│           ├────│   │──┐                  │
│   ┌───┐  │    └───┘  │                   │
│   │ B │──┘           │                   │
│   └───┘              │                   │
│                      │   ┌───┐           │
│   ┌───┐              ├───│   │──┐        │
│   │ C │──┐           │   └───┘  │        │
│   └───┘  │    ┌───┐  │          │        │
│           ├────│ ? │──┘          │        │
│   ┌───┐  │    └───┘             │        │
│   │ D │──┘                      │        │
│   └───┘                         │        │
│                                │   🏆   │
│   ┌───┐                        │        │
│   │ E │──┐                     │        │
│   └───┘  │    ┌───┐            │        │
│           ├────│ ? │────────────┘        │
│   ┌───┐  │    └───┘                     │
│   │ F │──┘                              │
│   └───┘                                 │
│                                          │
│   ┌───┐                                 │
│   │ G │──┐                              │
│   └───┘  │    ┌───┐                     │
│           ├────│ ? │                    │
│   ┌───┐  │    └───┘                     │
│   │ H │──┘                              │
│   └───┘                                 │
│                                          │
└──────────────────────────────────────────┘
```

---

## IMPLEMENTATION

### Tournament Creation Screen
```dart
class TournamentCreateScreen extends StatefulWidget {
  const TournamentCreateScreen({super.key});

  @override
  State<TournamentCreateScreen> createState() => _TournamentCreateScreenState();
}

class _TournamentCreateScreenState extends State<TournamentCreateScreen> {
  String _name = '';
  TournamentType _type = TournamentType.knockout;
  int _participantCount = 8;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _venue;
  int _raceTo = 3;

  void _createTournament() {
    // Validate
    if (_name.isEmpty) return;

    // Create tournament
    final tournament = Tournament(
      id: 'tournament_${DateTime.now().millisecondsSinceEpoch}',
      name: _name,
      type: _type.name,
      status: 'upcoming',
      startDate: _startDate,
      endDate: _endDate,
      venue: _venue,
      maxParticipants: _participantCount,
      participants: [],
      createdAt: DateTime.now(),
    );

    // Navigate to tournament management
    context.push('/play/tournament/${tournament.id}');
  }
}
```

### Tournament Types
```dart
enum TournamentType {
  roundRobin,   // Vòng tròn
  knockout,     // Loại trực tiếp
  groupStage,   // Chia bảng
  combined,     // Kết hợp
}
```

---

## TODO

- [ ] Create Tournament Creation Screen
- [ ] Tournament Management Screen  
- [ ] Match Result Entry
- [ ] Round Robin Ranking Logic
- [ ] Knockout Bracket Display
- [ ] Tournament Repository
