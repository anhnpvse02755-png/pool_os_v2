"""Dictionary §7–§13 — spin, position play, basic safety, table reading."""

from .common import item

ITEMS = [
    # =========================================================================
    # §7 Follow (rewrite of existing kn_follow_shot)
    # =========================================================================
    item(
        id="kn_follow_shot",
        slug="follow-shot",
        title="Follow (Topspin)",
        title_vi="Follow — Xoáy tiến",
        category="cat_shotmaking",
        difficulty="beginner",
        tags=["tag_basic", "tag_shotmaking", "tag_topspin", "tag_cueball"],
        aliases=["follow", "topspin", "xoáy tiến", "xoay tien", "cú theo"],
        keywords=["follow", "topspin", "xoáy tiến", "điểm chạm", "miscue"],
        related=["kn_draw_shot", "kn_stop_shot", "kn_position_play",
                 "kn_english"],
        drills=["FOLLOW_SHOT", "FOLLOW_FAR", "TOP_SPIN_CONTROL"],
        vi=(
            "Đánh vào bi cái ở điểm phía trên tâm, khiến bi cái tiếp tục lăn "
            "tới sau khi va chạm bi mục tiêu.",

            "1. Ngắm điểm chạm cơ ở khoảng 1/2 - 3/4 bán kính phía trên tâm bi "
            "cái.\n"
            "2. Giữ cú đánh êm, không cần lực quá mạnh vì follow tự nhiên "
            "khiến bi lăn tới.\n"
            "3. Follow-through đầy đủ để duy trì độ xoáy.",

            "- Càng đánh cao (gần rìa trên) thì độ xoáy tiến càng nhiều nhưng "
            "dễ trượt cơ (miscue).\n"
            "- Follow hiệu quả nhất khi đánh bi mục tiêu gần như đối xứng (góc "
            "nhỏ).",

            "- Đánh quá cao gây trượt cơ (miscue) hoặc nhảy bi.\n"
            "- Nhầm lẫn giữa lực đánh và độ cao điểm chạm, dẫn đến bi chạy quá "
            "xa ngoài dự tính.",

            "- Luyện tập điểm chạm bằng bài tập \"stop-follow-draw\" trên cùng "
            "một khoảng cách để cảm nhận sự khác biệt.\n"
            "- Giảm lực, tăng độ chính xác điểm chạm trước khi tăng tốc độ.",
        ),
        en=(
            "Striking the cue ball above centre so it keeps rolling forward "
            "after contacting the object ball.",

            "1. Aim the tip about 1/2 to 3/4 of a radius above the cue ball's "
            "centre.\n"
            "2. Keep the stroke smooth; follow needs no great force because "
            "the ball rolls on naturally.\n"
            "3. Follow through fully to preserve the spin.",

            "- The higher you strike, the more topspin — and the greater the "
            "miscue risk.\n"
            "- Follow works best on shots close to straight.",

            "- Striking too high, causing a miscue or hopping the cue ball.\n"
            "- Confusing stroke power with tip height, sending the cue ball "
            "much further than intended.",

            "- Drill the tip position with a 'stop-follow-draw' sequence at "
            "one fixed distance to feel the difference.\n"
            "- Reduce power and sharpen the contact point before adding "
            "speed.",
        ),
    ),

    # =========================================================================
    # §8 Draw (rewrite of existing kn_draw_shot)
    # =========================================================================
    item(
        id="kn_draw_shot",
        slug="draw-shot",
        title="Draw (Backspin)",
        title_vi="Draw — Xoáy lùi",
        category="cat_shotmaking",
        difficulty="beginner",
        tags=["tag_basic", "tag_shotmaking", "tag_backspin", "tag_cueball"],
        aliases=["draw", "backspin", "xoáy lùi", "xoay lui", "cú lùi"],
        keywords=["draw", "backspin", "xoáy lùi", "cầu tay thấp", "chalk"],
        related=["kn_follow_shot", "kn_stop_shot", "kn_position_play",
                 "kn_english"],
        drills=["DRAW_SHOT", "DRAW_BACK_FAR", "BACK_SPIN_CONTROL"],
        vi=(
            "Đánh vào bi cái ở điểm phía dưới tâm, khiến bi cái bật lùi lại "
            "sau khi chạm bi mục tiêu.",

            "1. Hạ thấp cầu tay hơn bình thường để cơ có thể chạm điểm dưới "
            "tâm bi cái.\n"
            "2. Ngắm điểm chạm cách tâm khoảng 1/2 bán kính bi về phía dưới.\n"
            "3. Đẩy cơ dứt khoát với follow-through tốt, tránh đánh \"nhát "
            "gừng\".",

            "- Draw cần lực và tốc độ cơ nhiều hơn follow để tạo đủ độ xoáy "
            "trước khi ma sát làm mất xoáy.\n"
            "- Cầu tay phải thấp và chắc để tránh trượt cơ.",

            "- Trượt cơ (miscue) do đánh quá thấp hoặc cơ không đủ vuông góc.\n"
            "- Draw không đủ lực khiến bi cái không lùi được như ý.",

            "- Kiểm tra lại chiều cao cầu tay, đảm bảo cơ có thể tiếp cận điểm "
            "dưới tâm mà không bị cấn bàn.\n"
            "- Dùng phấn (chalk) đầy đủ trước mỗi cú đánh để tăng độ bám, giảm "
            "trượt cơ.",
        ),
        en=(
            "Striking the cue ball below centre so it comes back after "
            "contacting the object ball.",

            "1. Drop the bridge lower than usual so the cue can reach below "
            "centre.\n"
            "2. Aim about half a radius below the cue ball's centre.\n"
            "3. Deliver decisively with a good follow-through — no tentative "
            "poking.",

            "- Draw needs more cue speed than follow, so the spin survives "
            "friction on the way to the object ball.\n"
            "- The bridge must be low and firm to avoid miscues.",

            "- Miscuing by striking too low, or with the cue not square.\n"
            "- Too little speed, so the cue ball fails to come back.",

            "- Re-check bridge height so the cue can reach below centre "
            "without fouling the table.\n"
            "- Chalk properly before every shot to increase grip and reduce "
            "miscues.",
        ),
    ),

    # =========================================================================
    # §9 Stun shot (rewrite of existing kn_stop_shot)
    # =========================================================================
    item(
        id="kn_stop_shot",
        slug="stop-shot",
        title="Stun / Stop Shot",
        title_vi="Stun shot — Đánh dừng",
        category="cat_shotmaking",
        difficulty="beginner",
        tags=["tag_basic", "tag_shotmaking", "tag_cueball"],
        aliases=["stun", "stop shot", "đánh dừng", "danh dung", "dừng bi cái"],
        keywords=["stun", "stop shot", "đánh dừng", "tâm bi", "position play"],
        related=["kn_follow_shot", "kn_draw_shot", "kn_position_play",
                 "kn_aiming_rail_ball"],
        drills=["STOP_BALL", "STUN_SHOT", "POSITION_BASIC"],
        vi=(
            "Đánh vào đúng tâm bi cái (không xoáy) để bi cái dừng lại ngay tại "
            "điểm va chạm với bi mục tiêu (với cú đánh không quá góc).",

            "1. Ngắm chính xác vào tâm bi cái, không lệch trên/dưới.\n"
            "2. Dùng lực vừa phải, không cần follow-through quá dài.\n"
            "3. Hiệu quả rõ nhất khi đánh bi mục tiêu gần góc 90 độ với hướng "
            "bi cái ban đầu.",

            "- Ở góc cắt quá lớn hoặc quá nhỏ, stun shot sẽ không dừng hẳn mà "
            "đi theo hướng vuông góc với đường bi mục tiêu.\n"
            "- Đây là kỹ thuật nền tảng để kiểm soát vị trí bi cái (position "
            "play).",

            "- Đánh lệch tâm khiến bi cái vẫn tiến hoặc lùi nhẹ thay vì dừng "
            "hẳn.\n"
            "- Nhầm lẫn giữa \"đánh vào tâm\" và \"đánh nhẹ\" — hai khái niệm "
            "khác nhau.",

            "- Luyện tập trên đường thẳng đơn giản trước, tăng dần độ khó góc "
            "cắt.\n"
            "- Dùng bài tập \"stun drill\": đặt bi ở nhiều góc khác nhau, quan "
            "sát bi cái dừng đúng vị trí dự tính.",
        ),
        en=(
            "Striking the cue ball dead centre (no spin) so it stops at the "
            "point of contact with the object ball, on shots that aren't too "
            "angled.",

            "1. Aim precisely at the cue ball's centre, neither high nor low.\n"
            "2. Use moderate power; a long follow-through isn't needed.\n"
            "3. It is most visible when the object ball leaves at roughly 90° "
            "to the cue ball's original path.",

            "- On very thick or very thin cuts the cue ball won't stop dead; "
            "it travels along the tangent line instead.\n"
            "- This is the foundation technique for cue ball position play.",

            "- Striking off centre, so the cue ball creeps forward or back "
            "instead of stopping.\n"
            "- Confusing 'hit centre' with 'hit softly' — they are different "
            "things.",

            "- Practise on simple straight shots first, then add cut angle "
            "gradually.\n"
            "- Use a stun drill: set the ball at various angles and check the "
            "cue ball stops where you predicted.",
        ),
    ),

    # =========================================================================
    # §10 Side spin / English
    # =========================================================================
    item(
        id="kn_english",
        slug="english-side-spin",
        title="Side Spin (English)",
        title_vi="Side spin / English",
        category="cat_shotmaking",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_shotmaking", "tag_cueball",
              "tag_technique"],
        aliases=["english", "side spin", "xoáy ngang", "xoay ngang", "spin"],
        keywords=["english", "side spin", "xoáy ngang", "squirt", "throw",
                  "deflection"],
        related=["kn_throw_squirt_swerve", "kn_follow_shot", "kn_draw_shot",
                 "kn_kick_shot", "kn_cue_selection"],
        drills=["INSIDE_ENGLISH", "LEFT_ENGLISH_NEAR", "RIGHT_ENGLISH_NEAR"],
        vi=(
            "Đánh lệch trái hoặc phải so với tâm bi cái để tạo độ xoáy ngang, "
            "ảnh hưởng đến hướng bi cái sau khi chạm băng hoặc bi khác.",

            "1. Ngắm điểm chạm lệch sang trái hoặc phải tâm bi cái (tối đa "
            "khoảng 1 tip — đầu da cơ).\n"
            "2. Điều chỉnh nhẹ hướng ngắm ban đầu để bù trừ hiệu ứng \"throw\" "
            "(bi mục tiêu bị lệch nhẹ do ma sát).\n"
            "3. Dùng lực ổn định, không đánh quá mạnh khi mới luyện.",

            "- English chỉ thực sự phát huy tác dụng rõ khi bi cái chạm băng "
            "(rail).\n"
            "- Đánh English luôn cần bù góc ngắm ban đầu (aim adjustment) vì "
            "hiệu ứng \"cue ball deflection/squirt\".",

            "- Đánh English quá xa tâm (over 1 tip) dễ gây trượt cơ.\n"
            "- Không bù góc ngắm, khiến bi cái đi sai hướng dự tính hoàn toàn "
            "(squirt effect).",

            "- Luyện tập \"English drill\" cho bi cái chạm 1 băng rồi đi đến vị "
            "trí xác định, ghi nhớ độ lệch cần bù theo từng cơ.\n"
            "- Dùng cơ có shaft low-deflection nếu chơi English thường xuyên "
            "(tùy cấp độ đầu tư).",
        ),
        en=(
            "Striking left or right of the cue ball's centre to impart side "
            "spin, which changes the cue ball's direction off a rail or "
            "another ball.",

            "1. Aim the tip left or right of centre, up to about one tip's "
            "width.\n"
            "2. Adjust the initial aim slightly to compensate for throw — the "
            "object ball deviating due to friction.\n"
            "3. Use steady power; don't hit hard while you're learning.",

            "- English shows its real effect mainly once the cue ball contacts "
            "a rail.\n"
            "- Using English always requires an aim adjustment because of cue "
            "ball deflection (squirt).",

            "- Going beyond about one tip off centre, which invites miscues.\n"
            "- Failing to compensate the aim, so the cue ball leaves on a "
            "completely different line (squirt).",

            "- Drill English by sending the cue ball off one rail to a defined "
            "target, memorising the compensation your own cue needs.\n"
            "- Consider a low-deflection shaft if you use English often.",
        ),
    ),

    # =========================================================================
    # §11 Kiểm soát vị trí (rewrite of existing kn_position_play)
    # =========================================================================
    item(
        id="kn_position_play",
        slug="position-play",
        title="Position Play (Cue Ball Control)",
        title_vi="Kiểm soát vị trí",
        category="cat_positioning",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_positioning", "tag_cueball"],
        aliases=["position play", "cue ball control", "kiểm soát vị trí",
                 "vị trí"],
        keywords=["position play", "vị trí", "target zone", "pattern play",
                  "bi cái"],
        related=["kn_stop_shot", "kn_follow_shot", "kn_draw_shot",
                 "kn_speed_control", "kn_table_layout", "kn_run_out_planning"],
        drills=["POSITION_BASIC", "POSITION_3BALL", "POSITION_CUE",
                "POSITION_TIGHT"],
        vi=(
            "Kỹ năng điều khiển bi cái dừng ở vị trí thuận lợi sau mỗi cú đánh "
            "để chuẩn bị cho cú tiếp theo.",

            "1. Trước khi đánh, xác định trước vị trí muốn bi cái dừng lại "
            "(target zone) cho cú kế tiếp.\n"
            "2. Chọn loại xoáy (follow/draw/stun/English) và lực phù hợp để "
            "đạt vị trí đó.\n"
            "3. Luôn nghĩ trước 2-3 cú đánh (pattern play), không chỉ tập "
            "trung cú hiện tại.",

            "- Ưu tiên đường bi an toàn, dễ kiểm soát hơn là cú khó nhưng vị "
            "trí đẹp.\n"
            "- Vùng để bi cái dừng nên đủ rộng (không cần chính xác tuyệt đối) "
            "để giảm rủi ro.",

            "- Chỉ tập trung đánh bi vào lỗ mà quên tính toán vị trí bi cái "
            "sau đó.\n"
            "- Dùng lực quá mạnh khiến bi cái chạy lố khỏi vùng mong muốn.",

            "- Luyện tập theo bài \"3-ball position drill\": sắp 3 bi và đánh "
            "liên tiếp, tập trung vào vị trí bi cái sau mỗi cú.\n"
            "- Giảm lực đánh tổng thể, ưu tiên độ chính xác vị trí hơn tốc độ.",
        ),
        en=(
            "Steering the cue ball to a favourable resting place after each "
            "shot, setting up the next one.",

            "1. Before shooting, decide where you want the cue ball to stop — "
            "the target zone for the next shot.\n"
            "2. Choose the spin (follow/draw/stun/English) and the power that "
            "get it there.\n"
            "3. Think two or three shots ahead, not just the one in front of "
            "you.",

            "- Prefer the safe, controllable cue ball path over a difficult "
            "route to a prettier position.\n"
            "- Aim for a generous landing zone rather than a precise spot; it "
            "lowers the risk.",

            "- Focusing only on potting and forgetting where the cue ball ends "
            "up.\n"
            "- Too much power, running the cue ball past the intended zone.",

            "- Drill three-ball position: set three balls and run them, "
            "judging yourself on cue ball placement after each shot.\n"
            "- Lower your overall power and prize positional accuracy over "
            "speed.",
        ),
    ),

    # =========================================================================
    # §12 Safety play cơ bản (rewrite of existing kn_safety_play)
    # =========================================================================
    item(
        id="kn_safety_play",
        slug="safety-play",
        title="Basic Safety Play",
        title_vi="Safety play cơ bản",
        category="cat_strategy",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_strategy", "tag_defense"],
        aliases=["safety", "safety play", "đánh an toàn", "phòng thủ",
                 "phong thu"],
        keywords=["safety", "phòng thủ", "che chắn", "snooker", "foul"],
        related=["kn_safety_advanced", "kn_position_play", "kn_kick_shot",
                 "kn_rules_8ball", "safety.fundamentals"],
        drills=["SAFETY_BASIC", "SAFETY_FORCE", "SAFETY_KICK"],
        vi=(
            "Chiến thuật đánh không nhằm ghi điểm mà nhằm gây khó khăn cho đối "
            "thủ ở lượt tiếp theo, thường dùng khi không có cú đánh ăn bi an "
            "toàn.",

            "1. Đánh bi cái để nó dừng ở vị trí đối thủ khó có đường ngắm tốt "
            "(che chắn bởi bi khác).\n"
            "2. Có thể kết hợp đẩy bi mục tiêu vào vị trí khó (kẹt sát băng, "
            "kẹt giữa các bi).\n"
            "3. Luôn đảm bảo tuân thủ luật (chạm bi hợp lệ, bi chạm băng nếu "
            "cần) để tránh phạm luật.",

            "- Safety hiệu quả cần tính toán cả vị trí bi cái lẫn bi mục tiêu, "
            "không chỉ một bên.\n"
            "- Không nên lạm dụng safety khi vẫn có cơ hội ghi điểm rõ ràng.",

            "- Đánh safety nửa vời khiến đối thủ vẫn có đường đánh dễ.\n"
            "- Quên tính toán luật chạm băng, dẫn đến phạm lỗi và mất lượt/bị "
            "phạt.",

            "- Luyện tư duy \"hai bước\": luôn hình dung bàn cờ sau cú safety "
            "từ góc nhìn của đối thủ.\n"
            "- Ôn lại luật chơi cụ thể của từng thể loại trước khi áp dụng "
            "safety phức tạp.",
        ),
        en=(
            "A shot played not to score but to leave the opponent in trouble "
            "— the standard choice when no safe pot is available.",

            "1. Leave the cue ball where the opponent has no clear line, "
            "screened by other balls.\n"
            "2. Where possible, also push the object ball somewhere awkward — "
            "tight to a rail or buried in a cluster.\n"
            "3. Always satisfy the rules (legal first contact, rail contact "
            "where required) so you don't foul.",

            "- Effective safeties account for both the cue ball and the object "
            "ball, not just one of them.\n"
            "- Don't over-use safety when a clear scoring chance exists.",

            "- Half-hearted safeties that still leave the opponent an easy "
            "shot.\n"
            "- Forgetting the rail-contact requirement and conceding a foul.",

            "- Train two-step thinking: always picture the table after your "
            "safety from the opponent's side.\n"
            "- Review the specific game's rules before attempting complex "
            "safeties.",
        ),
    ),

    # =========================================================================
    # §13 Đọc bàn / lập kế hoạch đường chạy
    # =========================================================================
    item(
        id="kn_table_layout",
        slug="table-layout-reading",
        title="Table Layout & Pattern Reading",
        title_vi="Đọc bàn và lập kế hoạch đường chạy",
        category="cat_strategy",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_strategy", "tag_positioning"],
        aliases=["đọc bàn", "doc ban", "table layout", "pattern reading",
                 "key ball"],
        keywords=["đọc bàn", "key ball", "run-out", "thứ tự đánh",
                  "pattern"],
        related=["kn_run_out_planning", "kn_position_play", "kn_safety_play",
                 "pattern.table_reading"],
        drills=["PATTERN_3_BALLS", "PATTERN_5_BALLS", "POSITION_3BALL"],
        vi=(
            "Kỹ năng quan sát toàn bộ bố cục bi trên bàn để lên kế hoạch thứ "
            "tự đánh bi tối ưu (run-out).",

            "1. Quan sát toàn bàn trước khi đánh cú đầu tiên, xác định bi khó "
            "nhất (key ball) cần xử lý sớm.\n"
            "2. Lên thứ tự đánh sao cho mỗi cú đưa bi cái đến gần bi tiếp theo "
            "một cách tự nhiên (ít di chuyển xa).\n"
            "3. Ưu tiên xử lý các bi cản đường hoặc bi khó trước khi bàn "
            "\"thoáng\" hơn.",

            "- Bi cuối cùng nên có đường thoát tốt để tiếp tục ván sau (nếu áp "
            "dụng, như 8-ball/14.1).\n"
            "- Đừng chỉ nhìn 1 cú, hãy nhìn toàn bộ chuỗi 3-5 cú tiếp theo.",

            "- Chọn đánh bi dễ trước, để lại bi khó/kẹt ở cuối khiến hỏng cả "
            "ván.\n"
            "- Không để ý bi nào đang cản đường bi cái ở các đường di chuyển "
            "dự kiến.",

            "- Luyện tập lập kế hoạch bằng cách vẽ sơ đồ bàn ra giấy trước khi "
            "đánh (giai đoạn đầu tập).\n"
            "- Chơi các bài tập \"run-out drill\" với 5-6 bi random để rèn tư "
            "duy đọc bàn nhanh.",
        ),
        en=(
            "Reading the whole layout to plan the optimal order of balls for a "
            "run-out.",

            "1. Survey the full table before the first shot and identify the "
            "hardest ball (the key ball) to deal with early.\n"
            "2. Order the balls so each shot leaves the cue ball naturally "
            "near the next one, with little travel.\n"
            "3. Handle blocking or awkward balls while the table still offers "
            "options.",

            "- The last ball should leave a good route into the next rack "
            "where that applies (8-ball, 14.1).\n"
            "- Don't look one shot ahead; read the next three to five.",

            "- Taking the easy balls first and leaving the hard or clustered "
            "ones to the end, which wrecks the rack.\n"
            "- Overlooking balls that block the cue ball's planned routes.",

            "- While learning, sketch the layout on paper and plan the order "
            "before shooting.\n"
            "- Run 'run-out drills' with five or six random balls to build "
            "quick table reading.",
        ),
    ),
]
