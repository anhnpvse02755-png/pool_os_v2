"""Dictionary §1–§6 — fundamentals, ghost-ball aiming, and the break."""

from .common import item

ITEMS = [
    # =========================================================================
    # §1 Cách cầm cơ (Grip)
    # =========================================================================
    item(
        id="kn_grip",
        slug="grip",
        title="Grip",
        title_vi="Cách cầm cơ",
        category="cat_fundamentals",
        difficulty="beginner",
        tags=["tag_basic", "tag_technique"],
        aliases=["grip", "cầm cơ", "cach cam co", "tay cầm cơ"],
        keywords=["grip", "cầm cơ", "tay thuận", "cổ tay", "đuôi cơ"],
        related=["kn_stance", "kn_bridge", "kn_stroke"],
        drills=["STROKE_STRAIGHT", "STRAIGHT_NEAR"],
        vi=(
            "Cách tay thuận (tay cầm cơ) nắm vào đuôi cơ để tạo ra cú đẩy "
            "thẳng, mượt và có lực kiểm soát tốt.",

            "1. Nắm cơ bằng các ngón tay, không nắm chặt trong lòng bàn tay "
            "như nắm đấm.\n"
            "2. Vị trí nắm cách đuôi cơ khoảng 5-7cm (tùy chiều cao và sải tay).\n"
            "3. Cổ tay thả lỏng, tạo góc vuông (90 độ) với cẳng tay khi cơ ở "
            "vị trí sẵn sàng đánh.\n"
            "4. Lực nắm chỉ vừa đủ để giữ cơ không rơi — như đang cầm một con "
            "chim nhỏ.",

            "- Lực nắm nên tăng nhẹ đúng lúc tiếp xúc bi (điểm chạm), không "
            "nắm chặt suốt cả cú đánh.\n"
            "- Khuỷu tay đóng vai trò như bản lề, không di chuyển ngang.",

            "- Nắm cơ quá chặt gây cứng tay, mất độ mượt của cú đẩy.\n"
            "- Nắm quá xa hoặc quá gần đuôi cơ làm mất cân bằng lực.\n"
            "- Cổ tay bẻ cong (không thẳng hàng) khi đẩy cơ.",

            "- Tập đẩy cơ chậm, tập trung cảm nhận độ lỏng của bàn tay trước "
            "khi tăng tốc.\n"
            "- Đánh dấu vị trí cầm cơ chuẩn bằng băng dính để tạo thói quen.\n"
            "- Luyện tập trước gương để quan sát góc cổ tay.",
        ),
        en=(
            "How the dominant hand holds the butt of the cue to produce a "
            "straight, smooth, well-controlled stroke.",

            "1. Hold the cue with the fingers, not clenched in the palm.\n"
            "2. Grip about 5-7cm from the butt end, adjusted for your height "
            "and arm length.\n"
            "3. Keep the wrist relaxed and the forearm at roughly 90° to the "
            "cue at address.\n"
            "4. Use only enough pressure to keep the cue from dropping — like "
            "holding a small bird.",

            "- Let the grip firm up slightly at contact, not throughout the "
            "whole stroke.\n"
            "- The elbow works as a hinge; it should not travel sideways.",

            "- Gripping too tightly, which stiffens the arm and kills the "
            "stroke's smoothness.\n"
            "- Gripping too far from or too close to the butt, unbalancing "
            "the delivery.\n"
            "- Bending the wrist out of line during the stroke.",

            "- Stroke slowly and feel the looseness of the hand before adding "
            "speed.\n"
            "- Mark the correct grip position with tape to build the habit.\n"
            "- Practise in front of a mirror to check the wrist angle.",
        ),
    ),

    # =========================================================================
    # §2 Tư thế đứng (Stance) — rewrite of existing kn_stance
    # =========================================================================
    item(
        id="kn_stance",
        slug="stance",
        title="Stance",
        title_vi="Tư thế đứng",
        category="cat_fundamentals",
        difficulty="beginner",
        tags=["tag_basic", "tag_posture", "tag_stance", "tag_technique"],
        aliases=["stance", "tư thế", "tu the dung", "vào bộ", "posture"],
        keywords=["stance", "tư thế đứng", "vào bộ", "trọng tâm", "chân trụ"],
        related=["kn_grip", "kn_bridge", "kn_stroke", "kn_aiming"],
        drills=["STANCE_FORM", "STRAIGHT_NEAR"],
        vi=(
            "Tư thế cơ thể khi vào cơ, quyết định sự ổn định và độ chính xác "
            "của đường ngắm.",

            "1. Đứng chân trước chân sau theo hướng đường đánh (chân thuận lùi "
            "sau, chân không thuận tiến trước — tùy người thuận tay phải/trái).\n"
            "2. Trọng tâm dồn đều, hơi nghiêng người về phía trước.\n"
            "3. Cúi người sao cho mắt gần với đường cơ (cằm gần cơ) nhưng vẫn "
            "thoải mái.\n"
            "4. Chân trụ vững, không di chuyển trong suốt cú đánh.",

            "- Tư thế phải lặp lại giống nhau ở mọi cú đánh (tính nhất quán — "
            "consistency).\n"
            "- Đầu giữ cố định, mắt nhìn thẳng theo trục cơ.",

            "- Đứng quá thẳng khiến mắt xa đường ngắm, giảm độ chính xác.\n"
            "- Chân đặt sai hướng làm lệch trục vai — cánh tay — cơ.\n"
            "- Đầu di chuyển lên xuống khi đẩy cơ (peeking quá sớm).",

            "- Hạ thấp người hơn để mắt gần trục cơ, tăng khả năng quan sát "
            "đường bi.\n"
            "- Luyện đứng cố định tư thế và chỉ ngắm bằng mắt, giữ đầu bất "
            "động đến khi bi lăn hẳn.",
        ),
        en=(
            "The body position at address; it determines both stability and "
            "the accuracy of your aim line.",

            "1. Stand with one foot forward along the shot line (dominant foot "
            "back, other foot forward, depending on handedness).\n"
            "2. Distribute weight evenly, leaning slightly forward.\n"
            "3. Lower the body so the eyes sit close to the cue line (chin "
            "near the cue) while staying comfortable.\n"
            "4. Plant the supporting leg; it must not move during the stroke.",

            "- The stance must repeat identically on every shot — consistency "
            "matters more than any single detail.\n"
            "- Keep the head still and the eyes along the cue axis.",

            "- Standing too upright, pulling the eyes away from the aim line.\n"
            "- Misaligned feet, which twists the shoulder–arm–cue axis.\n"
            "- Head lifting during delivery (peeking too early).",

            "- Get lower so the eyes sit closer to the cue axis and the ball "
            "path is easier to read.\n"
            "- Practise holding the stance and aiming with the eyes only, "
            "keeping the head still until the balls have finished rolling.",
        ),
    ),

    # =========================================================================
    # §3 Cầu tay (Bridge) — rewrite of existing kn_bridge
    # =========================================================================
    item(
        id="kn_bridge",
        slug="bridge",
        title="Bridge",
        title_vi="Cầu tay",
        category="cat_fundamentals",
        difficulty="beginner",
        tags=["tag_basic", "tag_bridge", "tag_technique"],
        aliases=["bridge", "cầu tay", "cau tay", "tay gác", "gác cơ"],
        keywords=["bridge", "cầu tay", "cầu kín", "cầu hở", "closed bridge",
                  "open bridge"],
        related=["kn_grip", "kn_stance", "kn_stroke", "bridge.open_bridge",
                 "bridge.closed_bridge"],
        drills=["BRIDGE_FORM", "STRAIGHT_NEAR"],
        vi=(
            "Tay không thuận dùng để đỡ và dẫn hướng cơ, có 2 loại chính: cầu "
            "kín (closed bridge) và cầu hở (open bridge).",

            "- **Cầu kín:** Đặt lòng bàn tay xuống bàn, dùng ngón trỏ vòng qua "
            "ngón cái tạo thành vòng tròn để cơ luồn qua.\n"
            "- **Cầu hở:** Xòe bàn tay, dùng rãnh giữa ngón cái và ngón trỏ "
            "làm điểm tựa cho cơ (thường dùng khi bi gần rìa bàn hoặc cần nhìn "
            "rõ đường bi).\n"
            "- Khoảng cách từ cầu tay đến bi cái thường 15-20cm.",

            "- Bàn tay cầu phải áp sát mặt bàn để tạo độ vững, tránh rung.\n"
            "- Chiều cao cầu tay quyết định việc bi có bị \"spin\" ngoài ý "
            "muốn hay không.",

            "- Cầu tay quá cao khiến cơ đánh chéo xuống, gây trượt hoặc xoáy "
            "bi không mong muốn.\n"
            "- Cầu tay quá gần hoặc quá xa bi cái làm mất kiểm soát lực.",

            "- Tập cố định chiều cao cầu tay sao cho cơ nằm gần như song song "
            "mặt bàn.\n"
            "- Thực hành với nhiều khoảng cách cầu khác nhau để tìm khoảng phù "
            "hợp với sải tay.",
        ),
        en=(
            "The non-dominant hand supports and guides the cue. Two main "
            "forms: the closed bridge and the open bridge.",

            "- **Closed bridge:** palm flat on the table, index finger looped "
            "over the thumb to form a ring the cue slides through.\n"
            "- **Open bridge:** hand spread, the cue resting in the groove "
            "between thumb and index finger — useful near the rail or when you "
            "want a clear view of the shot line.\n"
            "- Bridge-to-cue-ball distance is usually 15-20cm.",

            "- Press the bridge hand flat to the cloth for stability and to "
            "stop it shaking.\n"
            "- Bridge height determines whether the cue ball picks up "
            "unintended spin.",

            "- A bridge that is too high makes the cue strike downward, "
            "causing miscues or unwanted spin.\n"
            "- A bridge too close to or too far from the cue ball costs you "
            "control of power.",

            "- Fix the bridge height so the cue sits nearly parallel to the "
            "cloth.\n"
            "- Practise at a range of bridge distances to find the one that "
            "suits your reach.",
        ),
    ),

    # =========================================================================
    # §4 Cú đẩy cơ (Stroke)
    # =========================================================================
    item(
        id="kn_stroke",
        slug="stroke",
        title="Stroke",
        title_vi="Cú đẩy cơ",
        category="cat_fundamentals",
        difficulty="beginner",
        tags=["tag_basic", "tag_technique"],
        aliases=["stroke", "đẩy cơ", "day co", "ra cơ", "vung cơ"],
        keywords=["stroke", "đẩy cơ", "follow through", "practice stroke",
                  "khuỷu tay"],
        related=["kn_grip", "kn_stance", "kn_bridge", "kn_speed_control"],
        drills=["STROKE_STRAIGHT", "STRAIGHT_NEAR", "STRAIGHT_MID"],
        vi=(
            "Chuyển động của cánh tay đẩy cơ về phía trước để truyền lực vào "
            "bi cái, là yếu tố quyết định độ chính xác và lực đánh.",

            "1. Thực hiện 2-3 lần đẩy cơ thử (practice stroke) trước khi đánh "
            "thật.\n"
            "2. Đẩy cơ theo đường thẳng, chỉ dùng khuỷu tay làm trục xoay.\n"
            "3. Điểm dừng cơ (follow-through) nên đi xuyên qua vị trí bi cái "
            "khoảng 5-10cm sau khi tiếp xúc.",

            "- Tốc độ đẩy cơ nên tăng dần đều (gia tốc), không giật cục.\n"
            "- Follow-through là yếu tố bắt buộc để đường bi đi chính xác.",

            "- Dừng cơ đột ngột ngay khi chạm bi (thiếu follow-through).\n"
            "- Đẩy cơ bị lệch trái/phải do cổ tay hoặc vai di chuyển.\n"
            "- Tốc độ không đều, giật cơ ở cuối đường đánh.",

            "- Tập trung nhìn bi cái đến khi cơ đã đi xuyên qua hoàn toàn.\n"
            "- Luyện tập \"dead stroke drill\": đánh bi thẳng vào lỗ với tốc độ "
            "chậm, chú trọng độ mượt hơn lực mạnh.",
        ),
        en=(
            "The forward arm movement that delivers the cue into the cue ball "
            "— the main determinant of both accuracy and power.",

            "1. Take 2-3 practice strokes before the real one.\n"
            "2. Deliver the cue in a straight line, pivoting only at the "
            "elbow.\n"
            "3. Follow through 5-10cm past where the cue ball was.",

            "- Cue speed should build smoothly (acceleration), never jerk.\n"
            "- Follow-through is not optional; without it the ball path is "
            "unreliable.",

            "- Stopping the cue dead at contact (no follow-through).\n"
            "- Steering left or right because the wrist or shoulder moves.\n"
            "- Uneven speed, snatching at the end of the delivery.",

            "- Keep looking at the cue ball's position until the cue has "
            "travelled fully through.\n"
            "- Drill the 'dead stroke': pot straight balls slowly, prizing "
            "smoothness over power.",
        ),
    ),

    # =========================================================================
    # §5 Ngắm cơ bản — Ghost Ball (rewrite of existing kn_aiming)
    # =========================================================================
    item(
        id="kn_aiming",
        slug="aiming",
        title="Aiming — Ghost Ball",
        title_vi="Ngắm cơ bản — Ghost Ball",
        category="cat_aiming",
        difficulty="beginner",
        tags=["tag_basic", "tag_aiming", "tag_accuracy"],
        aliases=["aiming", "ngắm", "ngam", "ghost ball", "bi ma", "bi ảo"],
        keywords=["ghost ball", "ngắm", "điểm tiếp xúc", "cut shot",
                  "bi ảo"],
        related=["kn_aiming_fractional", "kn_aiming_contact_point",
                 "kn_aiming_method_selection", "kn_stance"],
        drills=["THIN_CUT_30", "THIN_CUT_45", "THICK_CUT_30", "HALF_BALL_LEFT"],
        vi=(
            "Kỹ thuật ngắm dựa trên hình dung một \"bi ma\" (ghost ball) tại "
            "vị trí bi cái cần chạm để bi mục tiêu đi đúng hướng vào lỗ.",

            "1. Xác định đường thẳng từ tâm lỗ đến tâm bi mục tiêu, kéo dài ra "
            "sau bi mục tiêu.\n"
            "2. Hình dung một bi vô hình (ghost ball) tiếp xúc với bi mục tiêu "
            "tại điểm đó.\n"
            "3. Ngắm bi cái đi đến đúng vị trí tâm của ghost ball đó.",

            "- Ghost ball luôn cách tâm bi mục tiêu đúng bằng 1 đường kính bi.\n"
            "- Cần luyện mắt để ước lượng góc chính xác, đặc biệt với góc hẹp "
            "(cut shot khó).",

            "- Ước lượng sai vị trí ghost ball, đặc biệt ở các cú cắt góc hẹp.\n"
            "- Nhìn vào bi cái thay vì điểm tiếp xúc trên bi mục tiêu khi đánh.",

            "- Luyện tập với các bài \"cut-shot drill\" ở nhiều góc độ khác "
            "nhau (30°, 45°, 60°...).\n"
            "- Dùng bi tập có đánh dấu hoặc phần mềm mô phỏng để hiệu chỉnh "
            "cảm giác góc.",
        ),
        en=(
            "An aiming method built on visualising a 'ghost ball' occupying "
            "the position the cue ball must reach to send the object ball to "
            "the pocket.",

            "1. Draw the line from the pocket centre through the object ball's "
            "centre and extend it behind the object ball.\n"
            "2. Picture an invisible ball touching the object ball at that "
            "point.\n"
            "3. Aim to send the cue ball to that ghost ball's centre.",

            "- The ghost ball centre always sits exactly one ball diameter "
            "from the object ball centre.\n"
            "- Train the eye to judge angles, especially on thin cuts.",

            "- Misjudging the ghost ball position, most often on thin cuts.\n"
            "- Looking at the cue ball instead of the contact point on the "
            "object ball at delivery.",

            "- Drill cut shots at a spread of angles (30°, 45°, 60°...).\n"
            "- Use marked training balls or simulation software to calibrate "
            "your sense of angle.",
        ),
    ),

    # =========================================================================
    # §6 Break shot cơ bản
    # =========================================================================
    item(
        id="kn_break_shot",
        slug="break-shot",
        title="Break Shot",
        title_vi="Break shot cơ bản",
        category="cat_shotmaking",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_shotmaking", "tag_technique"],
        aliases=["break", "break shot", "phá bi", "pha bi", "cú mở màn"],
        keywords=["break", "phá bi", "8-ball", "9-ball", "tán bi"],
        related=["kn_stroke", "kn_rules_8ball", "kn_rules_9ball",
                 "pattern.break_layout"],
        drills=["BREAK_POWER", "BREAK_CONTROL", "BREAK_ACCURACY",
                "BREAK_SPLIT"],
        vi=(
            "Cú đánh mở màn ván đấu, phá vỡ hình tam giác/kim cương bi để bắt "
            "đầu ván chơi.",

            "1. Đặt bi cái ở vị trí quy định (theo luật của game: 8-ball, "
            "9-ball...).\n"
            "2. Ngắm vào bi đầu tiên của cụm bi (thường lệch nhẹ để tối ưu lực "
            "phân tán).\n"
            "3. Dùng lực mạnh nhưng vẫn giữ form đánh chuẩn, không lao người "
            "theo cơ.",

            "- Ưu tiên kiểm soát bi cái ở lại giữa bàn hơn là đánh cực mạnh "
            "không kiểm soát.\n"
            "- Với 9-ball, thường break vào bi số 1 để tối ưu tán bi.",

            "- Nhấc bi cái ra khỏi bàn do bấm cơ xuống khi break.\n"
            "- Mất tư thế, thân trên lao về phía trước làm sai đường ngắm.",

            "- Giữ cơ đánh song song mặt bàn, không chúi xuống.\n"
            "- Luyện break riêng với tốc độ tăng dần, ưu tiên đúng điểm chạm "
            "trước khi tăng lực tối đa.",
        ),
        en=(
            "The opening shot that scatters the racked balls and starts the "
            "game.",

            "1. Place the cue ball as the game's rules require (8-ball, "
            "9-ball, and so on).\n"
            "2. Aim at the head ball of the rack, usually slightly off centre "
            "to maximise the spread.\n"
            "3. Hit hard but keep your form — don't lunge after the cue.",

            "- Controlling the cue ball into the middle of the table beats "
            "raw, uncontrolled power.\n"
            "- In 9-ball the break is normally aimed at the 1 ball for the "
            "best spread.",

            "- Launching the cue ball off the table by striking downward.\n"
            "- Losing the stance as the upper body drives forward, throwing "
            "the aim off.",

            "- Keep the cue parallel to the cloth rather than angled down.\n"
            "- Practise the break on its own, building speed gradually and "
            "getting the contact point right before adding maximum power.",
        ),
    ),
]
