# PoolOS v2 - Future Features Roadmap

## Vision Auto Recording System

**Priority:** P1 (Phase 2)
**Status:** Architecture Prepared

---

## Overview

Vision Auto Recording sử dụng AI để tự động phát hiện và ghi nhận cú đánh trong Training Center mà không cần người dùng tap thủ công.

---

## Business Context

### Current State (v2.0)
- **Manual Recording**: Người dùng tap để record shot
- Training Center hoạt động tốt với manual input
- Phù hợp cho người mới bắt đầu

### Future State (v3.0)
- **Auto Recording**: Camera tự động phát hiện shots
- Không cần người dùng tương tác
- AI phân tích real-time performance

---

## Architecture Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Vision Recording System                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐    ┌──────────────┐    ┌────────────────┐  │
│  │ Camera   │───▶│ Vision Engine │───▶│ Shot Detector  │  │
│  │ (Input)  │    │  (ML Model)   │    │ (On-Device)    │  │
│  └──────────┘    └──────────────┘    └────────────────┘  │
│                                              │               │
│                                              ▼               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Shot Event Processor                      │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐  │   │
│  │  │ Ball   │ │ Pot    │ │ Miss   │ │ Position   │  │   │
│  │  │ Detect │ │ Detect │ │ Detect │ │ Tracking   │  │   │
│  │  └────────┘ └────────┘ └────────┘ └────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                              │               │
│                                              ▼               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Training Session Recorder                 │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐  │   │
│  │  │ Drill  │ │ Shots  │ │ Stats  │ │ Coach      │  │   │
│  │  │ Manager│ │ Store  │ │ Update │ │ Input      │  │   │
│  │  └────────┘ └────────┘ └────────┘ └────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Technical Components

### 1. Vision Engine

**Technology Options:**
| Option | Pros | Cons | Recommendation |
|--------|------|------|----------------|
| TensorFlow Lite | On-device, fast | Custom model needed | ✅ Primary |
| MediaPipe | Pre-built, multi-platform | Less customizable | ✅ Alternative |
| ML Kit | Easy integration | Limited pool-specific | For MVP |
| Custom YOLO | Best accuracy | Training required | Phase 2 |

**Model Requirements:**
```
Input: Video frame (640x480 minimum)
Output:
├── Ball positions [x, y, color]
├── Table boundaries
├── Pockets positions
└── Cue ball trajectory

Performance: 30 FPS minimum
Size: < 50MB for mobile
Latency: < 100ms per frame
```

### 2. Shot Detection Logic

```
Frame Sequence Analysis:
1. Pre-shot state → Ball positions tracked
2. Impact detection → Cue strikes ball
3. Post-shot trajectory → Ball movement vectors
4. Pot detection → Ball enters pocket
5. Final state → New ball positions
```

**Detection Rules:**
```
SHOTS_DETECTED = [
  {
    type: 'pot',
    balls: ['solid_3', 'stripe_7'],
    pocket: 'corner_top_left',
    difficulty: 'medium'
  },
  {
    type: 'miss',
    cause: 'wrong_angle',
    expected_position: [x, y],
    actual_position: [x, y]
  },
  {
    type: 'scratch',
    cue_ball: 'pocketed'
  }
]
```

### 3. Position Tracking

```
Position Play Analysis:
├── Start position (cue ball)
├── Target position (after shot)
├── Actual position (AI measured)
└── Deviation score

Difficulty Assessment:
├── Angle to target
├── Distance to pocket
├── Obstacles (other balls)
└── Spin required
```

### 4. Table Calibration

```
Before Recording:
1. User positions phone
2. AI detects table corners
3. Auto-calibrate pockets
4. Store table geometry

Calibration Data:
{
  corners: [[x1,y1], [x2,y2], [x3,y3], [x4,y4]],
  pockets: [[x,y], [x,y], ...],
  scale: meters_per_pixel
}
```

---

## UI/UX Design

### Camera Setup Screen
```
┌─────────────────────────────┐
│                             │
│     [Camera Preview]        │
│                             │
│  ┌─────────────────────┐   │
│  │ Table Detected ✓    │   │
│  │ Tap to calibrate    │   │
│  └─────────────────────┘   │
│                             │
│  [Start Training]           │
│                             │
└─────────────────────────────┘
```

### Recording Overlay
```
┌─────────────────────────────┐
│ ● REC    🔴 00:05:32        │
│                             │
│  ┌─────────────────────┐    │
│  │                     │    │
│  │  [Camera Feed]     │    │
│  │                     │    │
│  │  ✓ Ball 3 potted   │    │
│  │  ✓ Ball 7 potted   │    │
│  │  ⚡ Position: 95%  │    │
│  │                     │    │
│  └─────────────────────┘    │
│                             │
│  Session: Draw Drill        │
│  Progress: 8/10 shots       │
│                             │
│  ┌────┐ ┌────┐ ┌────┐     │
│  │ ⏸  │ │ ⏹  │ │ 📷  │     │
│  └────┘ └────┘ └────┘     │
└─────────────────────────────┘
```

### Post-Session Analysis
```
┌─────────────────────────────┐
│       Session Complete!      │
│                             │
│  ┌─────────────────────┐    │
│  │ Success Rate: 85%  │    │
│  │ ████████████░░░   │    │
│  └─────────────────────┘    │
│                             │
│  Detected Shots: 17        │
│  Pots: 14                  │
│  Misses: 3                 │
│                             │
│  [View Details]            │
│  [Save to History]         │
│                             │
└─────────────────────────────┘
```

---

## Data Model Extension

```dart
// New entity for Vision Sessions
class VisionTrainingSession {
  String id;
  String drillCode;
  DateTime startTime;
  DateTime endTime;

  // Vision-generated data
  List<DetectedShot> shots;
  SessionStats computedStats;

  // Calibration data
  TableCalibration calibration;
  PhonePosition phonePosition;
}

class DetectedShot {
  DateTime timestamp;
  ShotType type;
  List<Ball> ballsPotted;
  PocketPosition pocket;
  PositionAccuracy positionScore;
  Difficulty difficulty;
  bool isFoul;
  String? foulType;
}

class TableCalibration {
  List<Point2D> corners;
  List<Point2D> pockets;
  double scaleFactor;
  DateTime calibratedAt;
}
```

---

## Implementation Phases

### Phase 1: Architecture (v2.1)
- [ ] Design database schema for vision data
- [ ] Create placeholder interfaces
- [ ] Document integration points
- [ ] Set up ML model placeholder

### Phase 2: Core Vision (v3.0)
- [ ] Implement TensorFlow Lite integration
- [ ] Train ball detection model
- [ ] Implement shot detection algorithm
- [ ] Table calibration flow

### Phase 3: Advanced Features (v3.1)
- [ ] Position tracking accuracy
- [ ] Difficulty estimation
- [ ] Multi-table support
- [ ] Offline mode optimization

---

## API Integration Points

```dart
// Vision Service Interface
abstract class VisionRecordingService {
  // Initialize camera and ML model
  Future<void> initialize();

  // Calibrate table from camera
  Future<TableCalibration> calibrateTable();

  // Start real-time recording
  Stream<VisionEvent> startRecording({
    required String drillCode,
    required TableCalibration calibration,
  });

  // Stop and finalize
  Future<VisionTrainingSession> stopRecording();

  // Cleanup resources
  void dispose();
}

// Events from Vision Engine
sealed class VisionEvent {
  ShotDetected(List<DetectedBall> balls, PocketPosition pocket);
  MissDetected(MissType type, Position deviation);
  FoulDetected(FoulType type);
  PositionMeasured(PositionAccuracy score);
  SessionStatsUpdated(SessionStats stats);
}
```

---

## Performance Requirements

| Metric | Target | Notes |
|--------|--------|-------|
| Frame Rate | 30 FPS | Minimum for smooth tracking |
| Latency | < 100ms | Shot detection to UI feedback |
| Battery | < 15%/hour | Recording with ML |
| Storage | ~50MB | ML model size |
| RAM | < 200MB | Peak during recording |
| Accuracy | > 90% | Shot detection accuracy |

---

## Fallback Strategy

```
Vision Recording Flow:

┌─────────────┐
│ Start Vision │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Calibration │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│ Success?    │────▶│ Auto Mode   │
└──────┬──────┘ NO  └──────┬──────┘
       │ YES                │
       ▼                    ▼
┌─────────────┐     ┌─────────────┐
│ Continue    │     │ Fallback    │
│ Recording   │     │ Manual Mode │
└─────────────┘     └──────┬──────┘
                            │
                            ▼
                    ┌─────────────┐
                    │ User can     │
                    │ switch back  │
                    └─────────────┘
```

---

## Testing Strategy

### Unit Tests
- Shot detection algorithm
- Position calculation
- Table calibration logic

### Integration Tests
- Camera feed processing
- ML model inference
- Session recording flow

### E2E Tests
- Full recording session
- Table calibration flow
- Session save and retrieve

---

## Dependencies (Future)

```yaml
dependencies:
  # Vision/ML
  tflite_flutter: ^2.1.0      # TensorFlow Lite
  camera: ^0.10.0              # Camera access
  image: ^4.0.0                # Image processing

  # Optional alternatives
  google_mlkit_pose: ^0.5.0    # ML Kit (simpler)
  mediapipe_flutter: ^0.3.0   # MediaPipe

dev_dependencies:
  mockito: ^5.4.0
  integration_test: ^3.0.0
```

---

## Related Documents

- [RFC-014 Training Drill Library](../Pool OS/RFC-014 - Training Drill Library.md)
- [FIX-004 Training Library & Drill Experience](../Pool OS/FIX-004 - Training Library & Drill Experience.md)
- [Architecture Constitution - BR-001 Separation of Training and Play](../Pool OS/ARCHITECTURE_CONSTITUTION.md)

---

## Status

- [x] Architecture Designed
- [ ] Database Schema Updated
- [ ] ML Model Trained
- [ ] Integration Implemented
- [ ] Testing Complete
- [ ] Production Deployed

**Last Updated:** 2026-08-02
