# POOL OS v2 - DRILL LIBRARY V3
## Comprehensive Drill Database

---

## PHILOSOPHY

**"Không có bài tập nào phù hợp cho tất cả mọi người. Drill phải được chọn dựa trên skill level, weakness, và progression."**

---

## DRILL STRUCTURE

```dart
class Drill {
  String id;
  String name;
  String nameVi;
  String category;      // POTTING, CONTROL, POSITION, SAFETY, BANK, BREAK
  String subCategory;   // specific type
  int difficulty;       // 1-5 (1=beginner, 5=expert)
  int durationMinutes;   // recommended time
  String setup;          // how to set up
  String instructions;     // step by step
  String successCriteria; // when is it mastered?
  List<String> targetSkills;
  List<String> relatedMistakes;
  List<String> prerequisites; // drill IDs needed first
}
```

---

## CATEGORY 1: POTTING (Đánh bi vào lỗ)

### 1.1 STRAIGHT POTS

**DRILL-POT-001: Straight Pot Near**
```
Name: Straight Pot Near
Name VI: Đánh thẳng gần
Category: POTTING
SubCategory: Straight
Difficulty: 1
Duration: 10 min
Setup: Bi mục tiêu cách lỗ 20-30cm
Target: Bi cái thẳng đến lỗ
Success: 8/10 lần
Target Skills: [AIM_BASIC, STRAIGHT_SHOT]
Related Mistakes: [MISALIGNMENT, JUMPING]
```

**DRILL-POT-002: Straight Pot Mid**
```
Name: Straight Pot Mid  
Name VI: Đánh thẳng trung bình
Category: POTTING
SubCategory: Straight
Difficulty: 2
Duration: 15 min
Setup: Bi mục tiêu cách lỗ 60-80cm
Target: Bi cái thẳng đến lỗ
Success: 7/10 lần
Target Skills: [AIM_BASIC, POWER_CONTROL]
Prerequisites: [DRILL-POT-001]
```

**DRILL-POT-003: Straight Pot Far**
```
Name: Straight Pot Far
Name VI: Đánh thẳng xa
Category: POTTING
SubCategory: Straight
Difficulty: 3
Duration: 15 min
Setup: Bi mục tiêu cách lỗ 1-1.5m
Target: Bi cái thẳng đến lỗ
Success: 6/10 lần
Target Skills: [AIM_BASIC, POWER_CONTROL, LONG_POT]
Prerequisites: [DRILL-POT-002]
```

**DRILL-POT-004: Multiple Angles**
```
Name: Multiple Angles Straight
Name VI: Đánh thẳng nhiều góc
Category: POTTING
SubCategory: Straight
Difficulty: 3
Duration: 20 min
Setup: 1 bi ở 6 vị trí khác nhau, mỗi vị trí cách lỗ 50cm
Target: Đánh thẳng từ mọi góc
Success: 5/10 mỗi vị trí
Target Skills: [AIM_ADVANCED, STANCE]
Prerequisites: [DRILL-POT-002]
```

### 1.2 CUT SHOTS

**DRILL-POT-005: Half Ball Practice**
```
Name: Half Ball Practice
Name VI: Luyện nửa bi
Category: POTTING
SubCategory: Cut
Difficulty: 2
Duration: 15 min
Setup: Bi mục tiêu cách lỗ 40cm, góc 45°
Target: Chạm nửa bi mục tiêu
Success: 7/10 lần
Target Skills: [THIN_CUT, AIM_ANGLE]
```

**DRILL-POT-006: Thin Cut 30°**
```
Name: Thin Cut 30°
Name VI: Cắt mỏng 30°
Category: POTTING
SubCategory: Cut
Difficulty: 3
Duration: 15 min
Setup: Bi mục tiêu cách lỗ 50cm, góc 30°
Target: Cắt mỏng chính xác
Success: 5/10 lần
Target Skills: [THIN_CUT, AIM_ANGLE]
Prerequisites: [DRILL-POT-005]
```

**DRILL-POT-007: Thin Cut 20°**
```
Name: Thin Cut 20°
Name VI: Cắt mỏng 20°
Category: POTTING
SubCategory: Cut
Difficulty: 4
Duration: 20 min
Setup: Bi mục tiêu cách lỗ 50cm, góc 20°
Target: Cắt rất mỏng
Success: 4/10 lần
Target Skills: [THIN_CUT, PRECISION]
Prerequisites: [DRILL-POT-006]
```

**DRILL-POT-008: Thick Cut Practice**
```
Name: Thick Cut Practice
Name VI: Luyện cắt dày
Category: POTTING
SubCategory: Cut
Difficulty: 2
Duration: 15 min
Setup: Bi mục tiêu cách lỗ 50cm, góc 60-70°
Target: Cắt dày ổn định
Success: 7/10 lần
Target Skills: [THICK_CUT, AIM_ANGLE]
```

**DRILL-POT-009: Cut Progression**
```
Name: Cut Angle Progression
Name VI: Luyện góc cắt tăng dần
Category: POTTING
SubCategory: Cut
Difficulty: 4
Duration: 25 min
Setup: Bắt đầu 60°, giảm 5° mỗi lần đến 15°
Target: Cắt mỏng đến 15° ổn định
Success: 4/10 ở mỗi góc
Target Skills: [CUT_CONTROL, THIN_CUT, THICK_CUT]
Prerequisites: [DRILL-POT-005, DRILL-POT-008]
```

### 1.3 LONG POTS

**DRILL-POT-010: Long Pot 1.5m**
```
Name: Long Pot 1.5m
Name VI: Đánh xa 1.5m
Category: POTTING
SubCategory: Long
Difficulty: 3
Duration: 15 min
Setup: Bi mục tiêu cách lỗ 1.5m
Target: Đánh bi vào lỗ
Success: 5/10 lần
Target Skills: [LONG_POT, POWER_CONTROL]
Prerequisites: [DRILL-POT-003]
```

**DRILL-POT-011: Long Pot 2m**
```
Name: Long Pot 2m
Name VI: Đánh xa 2m
Category: POTTING
SubCategory: Long
Difficulty: 4
Duration: 20 min
Setup: Bi mục tiêu cách lỗ 2m
Target: Đánh bi xa ổn định
Success: 4/10 lần
Target Skills: [LONG_POT, POWER_CONTROL, AIM_BASIC]
Prerequisites: [DRILL-POT-010]
```

**DRILL-POT-012: Long Pot with Position**
```
Name: Long Pot with Position
Name VI: Đánh xa có vị trí
Category: POTTING
SubCategory: Long
Difficulty: 5
Duration: 25 min
Setup: Bi mục tiêu cách lỗ 1.5m, cần position cho bi tiếp theo
Target: Đánh xa + position tốt
Success: 3/10 lần
Target Skills: [LONG_POT, POSITION, POWER_CONTROL]
Prerequisites: [DRILL-POT-010, DRILL-CUE-001]
```

---

## CATEGORY 2: CUE BALL CONTROL

### 2.1 STOP SHOT

**DRILL-CUE-001: Stop Shot Basic**
```
Name: Stop Shot Basic
Name VI: Đánh dừng bi cái cơ bản
Category: CONTROL
SubCategory: Stop
Difficulty: 1
Duration: 10 min
Setup: Bi cái cách bi mục tiêu 40cm
Target: Bi cái dừng ngay sau khi chạm
Success: 8/10 lần
Target Skills: [STOP_SHOT, POWER_STOP]
Related Mistakes: [OVER_HIT, UNDER_HIT, STEERING]
```

**DRILL-CUE-002: Stop Shot Mid Distance**
```
Name: Stop Shot Mid Distance
Name VI: Đánh dừng trung bình
Category: CONTROL
SubCategory: Stop
Difficulty: 2
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 80cm
Target: Bi cái dừng chính xác
Success: 7/10 lần
Target Skills: [STOP_SHOT, POWER_CONTROL]
Prerequisites: [DRILL-CUE-001]
```

**DRILL-CUE-003: Stop Shot Far**
```
Name: Stop Shot Far
Name VI: Đánh dừng xa
Category: CONTROL
SubCategory: Stop
Difficulty: 3
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 1.2m
Target: Bi cái dừng với lực vừa đủ
Success: 6/10 lần
Target Skills: [STOP_SHOT, POWER_CONTROL, ACCELERATION]
Prerequisites: [DRILL-CUE-002]
```

**DRILL-CUE-004: Stop Shot Variable Distance**
```
Name: Stop Shot Variable Distance
Name VI: Đánh dừng nhiều khoảng cách
Category: CONTROL
SubCategory: Stop
Difficulty: 3
Duration: 20 min
Setup: 5 vị trí khác nhau (30cm, 50cm, 70cm, 100cm, 130cm)
Target: Dừng chính xác ở mọi khoảng cách
Success: 6/10 mỗi khoảng cách
Target Skills: [STOP_SHOT, POWER_CONTROL, DISTANCE_FEEL]
Prerequisites: [DRILL-CUE-003]
```

### 2.2 FOLLOW SHOT

**DRILL-CUE-005: Follow Shot Soft**
```
Name: Soft Follow Shot
Name VI: Cu lê nhẹ
Category: CONTROL
SubCategory: Follow
Difficulty: 1
Duration: 10 min
Setup: Bi cái cách bi mục tiêu 40cm
Target: Bi cái đi theo 20-30cm
Success: 8/10 lần
Target Skills: [FOLLOW_SHOT, SOFT_FOLLOW]
Related Mistakes: [TOO_MUCH_FOLLOW, OVER_HIT]
```

**DRILL-CUE-006: Follow Shot Medium**
```
Name: Medium Follow Shot
Name VI: Cu lê trung bình
Category: CONTROL
SubCategory: Follow
Difficulty: 2
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 60cm
Target: Bi cái đi theo 50-70cm
Success: 7/10 lần
Target Skills: [FOLLOW_SHOT, POWER_FOLLOW]
Prerequisites: [DRILL-CUE-005]
```

**DRILL-CUE-007: Follow Shot Power**
```
Name: Power Follow Shot
Name VI: Cu lê mạnh
Category: CONTROL
SubCategory: Follow
Difficulty: 3
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 80cm, bi tiếp theo 1m phía sau
Target: Đánh mạnh + position cho bi tiếp
Success: 5/10 lần
Target Skills: [FOLLOW_SHOT, POWER_CONTROL, POSITION]
Prerequisites: [DRILL-CUE-006]
```

**DRILL-CUE-008: Follow Progression**
```
Name: Stop-Follow Progression
Name VI: Luyện dừng đến cu lê
Category: CONTROL
SubCategory: Follow
Difficulty: 3
Duration: 20 min
Setup: 10 bi mục tiêu, mỗi cách 50cm
         Bắt đầu: Stop, xen kẽ: Stop, Follow, Stop, Follow...
Target: Kiểm soát stop vs follow
Success: 7/10 correct type each
Target Skills: [STOP_SHOT, FOLLOW_SHOT, POWER_CONTROL]
Prerequisites: [DRILL-CUE-001, DRILL-CUE-005]
```

### 2.3 DRAW SHOT

**DRILL-CUE-009: Draw Shot Basic**
```
Name: Draw Shot Basic
Name VI: Kéo băng cơ bản
Category: CONTROL
SubCategory: Draw
Difficulty: 2
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 40cm, bi tiếp theo 30cm phía sau
Target: Bi cái quay về 20-30cm
Success: 7/10 lần
Target Skills: [DRAW_SHOT, TIP_POSITION]
Related Mistakes: [WRONG_TIP, OVER_DRAW, STEERING]
```

**DRILL-CUE-010: Draw Shot Mid**
```
Name: Draw Shot Mid Distance
Name VI: Kéo băng trung bình
Category: CONTROL
SubCategory: Draw
Difficulty: 3
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 80cm
Target: Bi cái quay về 40-60cm
Success: 6/10 lần
Target Skills: [DRAW_SHOT, POWER_CONTROL]
Prerequisites: [DRILL-CUE-009]
```

**DRILL-CUE-011: Draw Shot Far**
```
Name: Draw Shot Far Distance
Name VI: Kéo băng xa
Category: CONTROL
SubCategory: Draw
Difficulty: 4
Duration: 20 min
Setup: Bi cái cách bi mục tiêu 1.2m
Target: Bi cái quay về 50-70cm
Success: 4/10 lần
Target Skills: [DRAW_SHOT, POWER_CONTROL, ACCELERATION]
Prerequisites: [DRILL-CUE-010]
```

**DRILL-CUE-012: Draw Stop Follow Control**
```
Name: Draw-Stop-Follow Control
Name VI: Kiểm soát kéo-dừng-đẩy
Category: CONTROL
SubCategory: Draw
Difficulty: 4
Duration: 25 min
Setup: 15 bi, mỗi cách 50cm
         Bắt đầu: Draw, xen kẽ: Draw, Stop, Follow, Draw, Stop, Follow...
Target: Chính xác 5/10 mỗi type
Target Skills: [DRAW_SHOT, STOP_SHOT, FOLLOW_SHOT, POWER_CONTROL]
Prerequisites: [DRILL-CUE-004, DRILL-CUE-008]
```

### 2.4 SPIN / ENGLISH

**DRILL-CUE-013: Left English Basic**
```
Name: Left English Basic
Name VI: Áp phê trái cơ bản
Category: CONTROL
SubCategory: Spin
Difficulty: 2
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 50cm, góc 30°
Target: Bi cái đi trái sau khi chạm
Success: 6/10 lần
Target Skills: [LEFT_ENGLISH, SPIN_CONTROL]
Related Mistakes: [TOO_MUCH_SPIN, JUMPING]
```

**DRILL-CUE-014: Right English Basic**
```
Name: Right English Basic
Name VI: Áp phê phải cơ bản
Category: CONTROL
SubCategory: Spin
Difficulty: 2
Duration: 15 min
Setup: Bi cái cách bi mục tiêu 50cm, góc 30°
Target: Bi cái đi phải sau khi chạm
Success: 6/10 lần
Target Skills: [RIGHT_ENGLISH, SPIN_CONTROL]
Prerequisites: [DRILL-CUE-013]
```

**DRILL-CUE-015: Inside English**
```
Name: Inside English
Name VI: Áp phê trong
Category: CONTROL
SubCategory: Spin
Difficulty: 4
Duration: 20 min
Setup: Bi mục tiêu dính băng, cách lỗ 50cm
Target: Sử dụng inside để điều khiển bi cái
Success: 4/10 lần
Target Skills: [INSIDE_ENGLISH, SPIN_CONTROL, RAIL_CONTROL]
Prerequisites: [DRILL-CUE-013, DRILL-CUE-014]
```

**DRILL-CUE-016: Spin Combination**
```
Name: Spin with Cut Angle
Name VI: Áp phê kết hợp cắt bi
Category: CONTROL
SubCategory: Spin
Difficulty: 5
Duration: 25 min
Setup: Bi mục tiêu cách lỗ 60cm, góc 30°, cần spin để position
Target: Cắt + spin đúng position
Success: 3/10 lần
Target Skills: [SPIN_CONTROL, CUT_ANGLE, POSITION]
Prerequisites: [DRILL-CUE-015, DRILL-POT-006]
```

---

## CATEGORY 3: POSITION PLAY

### 3.1 ONE-RAIL POSITION

**DRILL-POS-001: One Rail Position Easy**
```
Name: One Rail Position Easy
Name VI: Vị trí 1 băng dễ
Category: POSITION
SubCategory: One Rail
Difficulty: 2
Duration: 15 min
Setup: Bi mục tiêu góc 1 băng, position target đơn giản
Target: Đánh vào vùng position
Success: 7/10 lần
Target Skills: [ONE_RAIL, POSITION]
```

**DRILL-POS-002: One Rail Position Medium**
```
Name: One Rail Position Medium
Name VI: Vị trí 1 băng trung bình
Category: POSITION
SubCategory: One Rail
Difficulty: 3
Duration: 20 min
Setup: Bi mục tiêu góc 1 băng, position target nhỏ hơn
Target: Position chính xác hơn
Success: 5/10 lần
Target Skills: [ONE_RAIL, POSITION, POWER_CONTROL]
Prerequisites: [DRILL-POS-001]
```

**DRILL-POS-003: One Rail Position Hard**
```
Name: One Rail Position Hard
Name VI: Vị trí 1 băng khó
Category: POSITION
SubCategory: One Rail
Difficulty: 4
Duration: 20 min
Setup: Bi mục tiêu góc 1 băng xa, position target nhỏ
Target: Position với độ chính xác cao
Success: 4/10 lần
Target Skills: [ONE_RAIL, POSITION, AIM]
Prerequisites: [DRILL-POS-002]
```

### 3.2 TWO-RAIL POSITION

**DRILL-POS-004: Two Rail Position Basic**
```
Name: Two Rail Position Basic
Name VI: Vị trí 2 băng cơ bản
Category: POSITION
SubCategory: Two Rail
Difficulty: 3
Duration: 20 min
Setup: Bi mục tiêu góc 2 băng, position target đơn giản
Target: Đánh qua 2 băng đến position
Success: 4/10 lần
Target Skills: [TWO_RAIL, POSITION, RAIL_CONTROL]
Prerequisites: [DRILL-POS-002]
```

**DRILL-POS-005: Two Rail Position Advanced**
```
Name: Two Rail Position Advanced
Name VI: Vị trí 2 băng nâng cao
Category: POSITION
SubCategory: Two Rail
Difficulty: 5
Duration: 25 min
Setup: Complex 2-rail position với position target nhỏ
Target: Kiểm soát qua 2 băng + position
Success: 2/10 lần
Target Skills: [TWO_RAIL, POSITION, POWER_CONTROL]
Prerequisites: [DRILL-POS-004]
```

### 3.3 NATURAL ANGLE

**DRILL-POS-006: Natural Angle Recognition**
```
Name: Natural Angle Recognition
Name VI: Nhận diện góc tự nhiên
Category: POSITION
SubCategory: Natural
Difficulty: 2
Duration: 15 min
Setup: 10 vị trí khác nhau, mỗi cách lỗ 50cm
Target: Đánh tự nhiên, không cần tính toán
Success: 7/10 lần (nhiều người đánh đúng hơn khi không nghĩ)
Target Skills: [NATURAL_ANGLE, AIM]
```

**DRILL-POS-007: Natural vs Spin Decision**
```
Name: Natural vs Spin Decision
Name VI: Quyết định tự nhiên hay spin
Category: POSITION
SubCategory: Natural
Difficulty: 4
Duration: 20 min
Setup: 10 thế bi, một số tự nhiên tốt, một số cần spin
Target: Nhận biết khi nào dùng spin
Success: 6/10 đúng quyết định
Target Skills: [NATURAL_ANGLE, SPIN_CONTROL, DECISION]
Prerequisites: [DRILL-POS-006, DRILL-CUE-012]
```

### 3.4 KEY BALL

**DRILL-POS-008: Key Ball Position**
```
Name: Key Ball Position Practice
Name VI: Vị trí bi then chốt
Category: POSITION
SubCategory: Key Ball
Difficulty: 4
Duration: 25 min
Setup: Bi then chốt trong position quan trọng
Target: Position tốt cho bi then chốt
Success: 4/10 lần
Target Skills: [KEY_BALL, POSITION, PATTERN]
Prerequisites: [DRILL-POS-002, DRILL-POS-003]
```

---

## CATEGORY 4: BANK & KICK

### 4.1 BANK SHOTS

**DRILL-BANK-001: Short Bank Basic**
```
Name: Short Bank Basic
Name VI: Đánh dội gần
Category: BANK
SubCategory: Short
Difficulty: 2
Duration: 15 min
Setup: Bi mục tiêu cách băng 30cm, góc 30-40°
Target: Đánh dội vào lỗ
Success: 6/10 lần
Target Skills: [SHORT_BANK, AIM_ANGLE]
Related Mistakes: [WRONG_ANGLE, TOO_MUCH_POWER]
```

**DRILL-BANK-002: Short Bank Advanced**
```
Name: Short Bank with Position
Name VI: Đánh dội gần có vị trí
Category: BANK
SubCategory: Short
Difficulty: 4
Duration: 20 min
Setup: Short bank + position cho bi tiếp theo
Target: Bank + position
Success: 3/10 lần
Target Skills: [SHORT_BANK, POSITION, POWER_CONTROL]
Prerequisites: [DRILL-BANK-001]
```

**DRILL-BANK-003: Long Bank Basic**
```
Name: Long Bank Basic
Name VI: Đánh dội xa
Category: BANK
SubCategory: Long
Difficulty: 3
Duration: 20 min
Setup: Bi mục tiêu cách băng 1m, góc 30-40°
Target: Bank dài ổn định
Success: 4/10 lần
Target Skills: [LONG_BANK, AIM_ANGLE, POWER_CONTROL]
Prerequisites: [DRILL-BANK-001]
```

**DRILL-BANK-004: Long Bank Advanced**
```
Name: Long Bank with Position
Name VI: Đánh dội xa có vị trí
Category: BANK
SubCategory: Long
Difficulty: 5
Duration: 25 min
Setup: Long bank + position cho bi tiếp theo
Target: Bank xa + position chính xác
Success: 2/10 lần
Target Skills: [LONG_BANK, POSITION, POWER_CONTROL]
Prerequisites: [DRILL-BANK-003]
```

### 4.2 KICK SHOTS

**DRILL-KICK-001: Basic One-Rail Kick**
```
Name: One-Rail Kick Basic
Name VI: Đá 1 băng cơ bản
Category: KICK
SubCategory: One Rail
Difficulty: 3
Duration: 20 min
Setup: Bi cách băng, cần đá qua băng đến bi mục tiêu
Target: Đá trúng bi mục tiêu
Success: 4/10 lần
Target Skills: [ONE_RAIL_KICK, AIM_ANGLE]
```

**DRILL-KICK-002: One-Rail Kick with Position**
```
Name: One-Rail Kick with Position
Name VI: Đá 1 băng có vị trí
Category: KICK
SubCategory: One Rail
Difficulty: 4
Duration: 20 min
Setup: One-rail kick + position cho bi tiếp theo
Target: Đá + position
Success: 3/10 lần
Target Skills: [ONE_RAIL_KICK, POSITION]
Prerequisites: [DRILL-KICK-001]
```

**DRILL-KICK-003: Two-Rail Kick Basic**
```
Name: Two-Rail Kick Basic
Name VI: Đá 2 băng cơ bản
Category: KICK
SubCategory: Two Rail
Difficulty: 4
Duration: 25 min
Setup: Bi cần đá qua 2 băng đến mục tiêu
Target: Đá trúng qua 2 băng
Success: 2/10 lần
Target Skills: [TWO_RAIL_KICK, AIM_ANGLE, RAIL_CONTROL]
Prerequisites: [DRILL-KICK-002]
```

---

## CATEGORY 5: SAFETY PLAY

### 5.1 DISTANCE SAFETY

**DRILL-SAFETY-001: Distance Safety Basic**
```
Name: Distance Safety Basic
Name VI: Đánh an toàn khoảng cách
Category: SAFETY
SubCategory: Distance
Difficulty: 2
Duration: 15 min
Setup: Đối thủ ở giữa bàn, đánh bi cái đến vị trí an toàn
Target: Đối thủ không ăn được
Success: 7/10 lần (đối thủ miss)
Target Skills: [DISTANCE_SAFETY, POSITION]
```

**DRILL-SAFETY-002: Distance Safety Advanced**
```
Name: Distance Safety with Leave
Name VI: Đánh an toàn với leave cụ thể
Category: SAFETY
SubCategory: Distance
Difficulty: 3
Duration: 20 min
Setup: Safety đến vị trí leave cụ thể
Target: Leave khó cho đối thủ
Success: 5/10 lần
Target Skills: [DISTANCE_SAFETY, POSITION, STRATEGY]
Prerequisites: [DRILL-SAFETY-001]
```

### 5.2 HOOK SAFETY

**DRILL-SAFETY-003: Hook Safety**
```
Name: Hook Safety
Name VI: Đánh móc
Category: SAFETY
SubCategory: Hook
Difficulty: 3
Duration: 15 min
Setup: Đối thủ gần băng, đánh bi cái móc về phía đối thủ
Target: Đối thủ bị hook, khó ăn
Success: 5/10 lần
Target Skills: [HOOK_SAFETY, SPIN_CONTROL]
Prerequisites: [DRILL-SAFETY-001]
```

---

## CATEGORY 6: BREAK

### 6.1 BREAK CONTROL

**DRILL-BREAK-001: Soft Break Control**
```
Name: Soft Break Control
Name VI: Phá nhẹ
Category: BREAK
SubCategory: Control
Difficulty: 1
Duration: 10 min
Setup: Rack bình thường, đánh nhẹ
Target: 2-3 bi vào, bi cái không đi ra
Success: 8/10 lần
Target Skills: [SOFT_BREAK, BREAK_CONTROL]
```

**DRILL-BREAK-002: Power Break Control**
```
Name: Power Break Control
Name VI: Phá mạnh có kiểm soát
Category: BREAK
SubCategory: Power
Difficulty: 3
Duration: 15 min
Setup: Rack bình thường, đánh mạnh
Target: 4-5 bi vào, bi cái kiểm soát được
Success: 5/10 lần
Target Skills: [POWER_BREAK, BREAK_CONTROL, SCRATCH_PREVENTION]
Prerequisites: [DRILL-BREAK-001]
```

**DRILL-BREAK-003: Break with Position**
```
Name: Break with Position
Name VI: Phá có vị trí
Category: BREAK
SubCategory: Power
Difficulty: 4
Duration: 20 min
Setup: Phá xong cần position cho bi tiếp theo
Target: Break + position cho lượt tiếp theo
Success: 3/10 lần
Target Skills: [POWER_BREAK, POSITION, BREAK_CONTROL]
Prerequisites: [DRILL-BREAK-002]
```

---

## CATEGORY 7: MENTAL GAME

### 7.1 PRE-SHOT ROUTINE

**DRILL-MENTAL-001: Pre-Shot Routine**
```
Name: Pre-Shot Routine Practice
Name VI: Luyện quy trình trước cú đánh
Category: MENTAL
SubCategory: Routine
Difficulty: 2
Duration: 20 min
Setup: Bất kỳ cú nào cũng thực hiện đủ routine
Target: Thực hiện routine đầy đủ mỗi cú
Success: 10/10 lần (routine hoàn chỉnh)
Target Skills: [ROUTINE, FOCUS, DISCIPLINE]
```

### 7.2 PRESSURE PRACTICE

**DRILL-MENTAL-002: Pressure Shot Practice**
```
Name: Pressure Shot Practice
Name VI: Luyện cú áp lực
Category: MENTAL
SubCategory: Pressure
Difficulty: 3
Duration: 25 min
Setup: Đặt cược gì đó (thua uống nước, thắng được điểm)
Target: Thực hiện tốt dưới áp lực
Success: 5/10 lần
Target Skills: [PRESSURE, MENTAL, FOCUS]
Prerequisites: [DRILL-MENTAL-001]
```

---

## DRILL PROGRESSION PATHS

### Beginner Path (0-6 months)
```
Month 1-2:
├── DRILL-POT-001: Straight Near
├── DRILL-CUE-001: Stop Basic
├── DRILL-CUE-005: Follow Soft
└── DRILL-SAFETY-001: Distance Safety

Month 3-4:
├── DRILL-POT-005: Half Ball
├── DRILL-CUE-002: Stop Mid
├── DRILL-CUE-009: Draw Basic
└── DRILL-POT-010: Long Pot 1.5m

Month 5-6:
├── DRILL-POT-006: Thin Cut
├── DRILL-CUE-004: Stop Variable
├── DRILL-POS-001: One Rail Easy
└── DRILL-BREAK-001: Soft Break
```

### Intermediate Path (6-18 months)
```
├── DRILL-CUE-012: Draw-Stop-Follow Control
├── DRILL-CUE-013/014: Left/Right English
├── DRILL-POS-003: One Rail Hard
├── DRILL-BANK-001: Short Bank
├── DRILL-KICK-001: One-Rail Kick
├── DRILL-SAFETY-003: Hook Safety
└── DRILL-BREAK-002: Power Break
```

### Advanced Path (18+ months)
```
├── DRILL-POT-012: Long Pot with Position
├── DRILL-CUE-016: Spin Combination
├── DRILL-POS-005: Two Rail Position
├── DRILL-BANK-004: Long Bank with Position
├── DRILL-KICK-003: Two-Rail Kick
├── DRILL-BREAK-003: Break with Position
└── DRILL-MENTAL-002: Pressure Practice
```

---

## DRILL DIFFICULTY MAPPING

| Difficulty | Level | Example Time to Master |
|------------|-------|---------------------|
| 1 | 🥉 Beginner | 2-4 weeks |
| 2 | 🥈 Lower-Int | 1-2 months |
| 3 | 🥈 Upper-Int | 2-4 months |
| 4 | 🥇 Advanced | 4-6 months |
| 5 | 🏆 Expert | 6+ months |

---

## END OF DRILL LIBRARY V3
