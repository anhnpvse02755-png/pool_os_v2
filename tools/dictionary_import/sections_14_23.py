"""Dictionary §14–§23 — advanced shots, strategy, and the mental game."""

from .common import item

ITEMS = [
    # =========================================================================
    # §14 Throw effect & Squirt / Swerve
    # =========================================================================
    item(
        id="kn_throw_squirt_swerve",
        slug="throw-squirt-swerve",
        title="Throw, Squirt and Swerve",
        title_vi="Throw, Squirt và Swerve",
        category="cat_shotmaking",
        difficulty="advanced",
        tags=["tag_advanced", "tag_shotmaking", "tag_cueball",
              "tag_technique"],
        aliases=["throw", "squirt", "swerve", "deflection", "hiệu ứng lệch"],
        keywords=["throw", "squirt", "swerve", "deflection", "low deflection",
                  "bù góc"],
        related=["kn_english", "kn_aiming", "kn_cue_selection",
                 "kn_masse_shot"],
        drills=["INSIDE_ENGLISH", "LEFT_ENGLISH_NEAR", "RIGHT_ENGLISH_NEAR"],
        vi=(
            "Các hiệu ứng vật lý làm bi đi lệch khỏi đường ngắm lý thuyết: "
            "**Throw** (bi mục tiêu bị \"kéo\" lệch do ma sát khi có xoáy "
            "ngang), **Squirt** (bi cái lệch hướng ban đầu do dùng English), "
            "**Swerve** (bi cái đi cong khi dùng English kết hợp cơ nâng cao "
            "đầu).",

            "1. Nhận diện tình huống nào sẽ gây throw (cú cắt góc hẹp + có "
            "xoáy/tốc độ chậm).\n"
            "2. Bù góc ngắm: ngắm lệch một chút theo hướng ngược lại với hiệu "
            "ứng dự kiến.\n"
            "3. Với swerve, thường dùng khi cần né vật cản (bi khác) gần bi "
            "cái.",

            "- Throw effect giảm khi lực đánh mạnh hơn, tăng khi đánh nhẹ và "
            "có xoáy ngang.\n"
            "- Squirt phụ thuộc vào loại shaft cơ (shaft carbon/low-deflection "
            "sẽ giảm squirt).",

            "- Không nhận ra throw effect khi đánh cú cắt nhẹ có xoáy, dẫn đến "
            "trượt bi liên tục.\n"
            "- Bù góc quá tay hoặc không đủ do chưa quen cơ của mình.",

            "- Luyện tập với cùng một cây cơ nhiều lần để \"học\" độ lệch đặc "
            "trưng của cơ đó.\n"
            "- Ghi chú lại (hoặc quay video) các cú lệch để điều chỉnh dần độ "
            "bù góc theo kinh nghiệm.",
        ),
        en=(
            "The physical effects that pull balls off the theoretical aim "
            "line: **throw** (the object ball dragged sideways by friction "
            "when side spin is present), **squirt** (the cue ball leaving on a "
            "different initial line because of English), and **swerve** (the "
            "cue ball curving when English is combined with an elevated cue).",

            "1. Recognise the situations that produce throw: thin cuts, side "
            "spin, slow speed.\n"
            "2. Compensate the aim slightly against the expected deviation.\n"
            "3. Swerve is normally used deliberately to bend around an "
            "obstructing ball close to the cue ball.",

            "- Throw decreases as stroke power rises, and increases on soft "
            "shots with side spin.\n"
            "- Squirt depends on the shaft: carbon and low-deflection shafts "
            "reduce it.",

            "- Missing repeatedly because throw goes unrecognised on soft cuts "
            "with spin.\n"
            "- Over- or under-compensating because you don't yet know your own "
            "cue.",

            "- Practise with one cue consistently so you learn its "
            "characteristic deflection.\n"
            "- Log or film your misses and refine the compensation from real "
            "evidence.",
        ),
    ),

    # =========================================================================
    # §15 Kick shot
    # =========================================================================
    item(
        id="kn_kick_shot",
        slug="kick-shot",
        title="Kick Shot",
        title_vi="Kick shot — Bi cái chạm băng trước",
        category="cat_shotmaking",
        difficulty="advanced",
        tags=["tag_advanced", "tag_shotmaking", "tag_rail", "tag_bank"],
        aliases=["kick", "kick shot", "đá băng", "da bang", "chạm băng trước"],
        keywords=["kick shot", "diamond system", "góc phản xạ", "băng",
                  "khóa bi"],
        related=["kn_bank_shot", "kn_safety_play", "kn_safety_advanced",
                 "kn_english", "safety.kick_safety"],
        drills=["KICK_SHOT", "SAFETY_KICK", "PATTERN_MULTI_RAIL"],
        vi=(
            "Kỹ thuật đánh bi cái chạm một hoặc nhiều băng trước khi chạm bi "
            "mục tiêu, thường dùng khi bị \"khóa\" (không có đường thẳng đến "
            "bi mục tiêu).",

            "1. Xác định băng cần chạm bằng quy tắc góc phản xạ (góc tới = góc "
            "phản xạ, có điều chỉnh theo hệ thống ngắm băng như \"diamond "
            "system\").\n"
            "2. Dùng lực và xoáy phù hợp (thường xoáy tự nhiên hoặc English "
            "nhẹ) để bù sai số ma sát băng.\n"
            "3. Luyện tập hệ thống điểm kim cương (diamond system) trên viền "
            "bàn để tính toán góc chính xác.",

            "- Chất lượng băng (cao su) và tốc độ bi ảnh hưởng lớn đến góc "
            "phản xạ thực tế.\n"
            "- Nên luyện kick 1 băng thành thạo trước khi học kick 2-3 băng.",

            "- Tính sai góc phản xạ do không tính đến hiệu ứng xoáy khi bi "
            "chạm băng.\n"
            "- Dùng lực không nhất quán khiến hệ thống tính điểm kim cương bị "
            "sai lệch.",

            "- Học và luyện hệ thống \"diamond system\" cơ bản với lực đánh "
            "chuẩn hóa (medium speed).\n"
            "- Ghi nhớ độ lệch riêng của bàn mình hay chơi (mỗi bàn có độ nảy "
            "hơi khác nhau).",
        ),
        en=(
            "Sending the cue ball off one or more rails before it contacts the "
            "object ball — the standard escape when you are hooked and have no "
            "direct line.",

            "1. Work out which rail to strike using the reflection rule (angle "
            "in equals angle out), adjusted by a rail system such as the "
            "diamond system.\n"
            "2. Use appropriate speed and spin (usually natural or light "
            "English) to offset rail friction.\n"
            "3. Practise the diamond system along the rails so the angles "
            "become calculable.",

            "- Cushion quality and ball speed both shift the real rebound "
            "angle substantially.\n"
            "- Master one-rail kicks before attempting two or three rails.",

            "- Miscalculating the rebound by ignoring how spin behaves at the "
            "cushion.\n"
            "- Inconsistent power, which invalidates the diamond system's "
            "arithmetic.",

            "- Learn the basic diamond system and drill it at a standardised "
            "medium speed.\n"
            "- Note the particular behaviour of the table you usually play on "
            "— every table rebounds slightly differently.",
        ),
    ),

    # =========================================================================
    # §16 Bank shot (rewrite of existing kn_bank_shot)
    # =========================================================================
    item(
        id="kn_bank_shot",
        slug="bank-shot",
        title="Bank Shot",
        title_vi="Bank shot — Bi mục tiêu chạm băng",
        category="cat_shotmaking",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_shotmaking", "tag_bank", "tag_rail"],
        aliases=["bank", "bank shot", "cú băng", "cu bang", "đánh băng"],
        keywords=["bank shot", "mirror pocket", "lỗ ảo", "góc phản xạ",
                  "băng"],
        related=["kn_kick_shot", "kn_aiming", "kn_speed_control",
                 "kn_combination_carom"],
        drills=["BANK_SHOT", "PATTERN_MULTI_RAIL", "LONG_POT_1M"],
        vi=(
            "Đánh bi mục tiêu bật qua băng rồi mới vào lỗ, khác với kick shot "
            "(bi cái chạm băng).",

            "1. Xác định \"lỗ ảo\" (mirror pocket) đối xứng qua băng để tìm "
            "đường ngắm.\n"
            "2. Ngắm điểm chạm trên bi mục tiêu sao cho nó đi đến đúng điểm "
            "phản xạ trên băng.\n"
            "3. Dùng lực vừa đủ, tránh đánh quá mạnh làm sai góc nảy thực tế "
            "so với lý thuyết.",

            "- Bank shot chính xác hơn khi bi mục tiêu ở gần trung tâm bàn "
            "(góc dễ tính hơn).\n"
            "- Độ xoáy của bi mục tiêu khi rời khỏi bi cái cũng ảnh hưởng đến "
            "góc bật qua băng (thường bị bỏ qua bởi người mới).",

            "- Chỉ tính góc hình học đơn giản mà quên ảnh hưởng của tốc độ và "
            "độ xoáy.\n"
            "- Chọn bank shot khi vẫn còn phương án ăn bi trực tiếp an toàn "
            "hơn.",

            "- Luyện tập bank shot với tốc độ cố định trước để tạo cảm giác "
            "chuẩn, sau đó điều chỉnh dần.\n"
            "- Chỉ ưu tiên bank shot khi thực sự không còn lựa chọn tốt hơn "
            "(do độ khó/rủi ro cao).",
        ),
        en=(
            "Sending the object ball off a cushion and into a pocket — as "
            "distinct from a kick shot, where the cue ball hits the rail.",

            "1. Find the mirror pocket reflected across the cushion to "
            "establish the aim line.\n"
            "2. Aim the contact point on the object ball so it reaches the "
            "correct rebound point on the rail.\n"
            "3. Use moderate power; hitting hard distorts the real rebound "
            "angle away from theory.",

            "- Banks are more reliable when the object ball is near the centre "
            "of the table, where angles are easier to judge.\n"
            "- The spin the object ball picks up from the cue ball also "
            "affects its rebound angle — a factor beginners often ignore.",

            "- Calculating pure geometry and forgetting the influence of speed "
            "and spin.\n"
            "- Choosing a bank when a safer direct pot is still available.",

            "- Drill banks at one fixed speed first to build the feel, then "
            "vary it.\n"
            "- Reserve banks for when nothing better exists — the risk is "
            "high.",
        ),
    ),

    # =========================================================================
    # §17 Jump shot
    # =========================================================================
    item(
        id="kn_jump_shot",
        slug="jump-shot",
        title="Jump Shot",
        title_vi="Jump shot — Đánh bi nhảy",
        category="cat_shotmaking",
        difficulty="advanced",
        tags=["tag_advanced", "tag_shotmaking", "tag_technique"],
        aliases=["jump", "jump shot", "nhảy bi", "nhay bi", "bi nhảy"],
        keywords=["jump shot", "cơ jump", "nâng cơ", "vật cản", "miscue"],
        related=["kn_masse_shot", "kn_kick_shot", "kn_safety_play",
                 "bridge.jump_bridge"],
        drills=["JUMP_SHOT"],
        vi=(
            "Kỹ thuật khiến bi cái nhảy qua một bi cản để chạm bi mục tiêu "
            "phía sau.",

            "1. Dùng cơ chuyên dụng cho jump (nếu luật cho phép) hoặc kỹ thuật "
            "jump bằng cơ thường (tùy giải đấu).\n"
            "2. Nâng cao đuôi cơ, ngắm cắm xuống phía trên tâm bi cái (không "
            "phải đâm thẳng xuống tâm).\n"
            "3. Dùng lực dứt khoát, cổ tay linh hoạt để tạo lực bật bi cái lên "
            "khỏi mặt bàn.",

            "- Nhiều giải đấu/luật chơi giới hạn hoặc cấm dùng cơ jump chuyên "
            "dụng — cần kiểm tra luật trước.\n"
            "- Đây là kỹ thuật rủi ro cao (dễ làm rách nỉ bàn nếu sai kỹ "
            "thuật), chỉ nên luyện với bàn tập/nỉ cũ.",

            "- Đâm cơ quá thẳng xuống khiến bi không nhảy mà chỉ trượt tới "
            "(miscue).\n"
            "- Dùng lực quá mạnh làm mất kiểm soát hướng đi sau khi bi tiếp "
            "đất.",

            "- Luyện tập góc nâng cơ từ nhỏ đến lớn dần, tìm góc tối thiểu đủ "
            "để bi nhảy qua vật cản.\n"
            "- Tập trên bàn cũ hoặc nỉ tập chuyên dụng để tránh hư hại bàn thi "
            "đấu.",
        ),
        en=(
            "Making the cue ball hop over a blocking ball to reach the object "
            "ball behind it.",

            "1. Use a dedicated jump cue where the rules allow, or the "
            "full-cue jump technique where they don't.\n"
            "2. Elevate the butt and strike downward above the cue ball's "
            "centre — not straight down through the centre.\n"
            "3. Deliver crisply with a loose wrist to pop the ball off the "
            "cloth.",

            "- Many tournaments restrict or ban dedicated jump cues — check "
            "the rules first.\n"
            "- This is a high-risk technique that can tear cloth when "
            "mistimed; practise on an old table.",

            "- Striking too vertically, so the ball skids forward instead of "
            "jumping (a miscue).\n"
            "- Too much power, which costs all control of direction after the "
            "ball lands.",

            "- Work up through cue elevations, finding the minimum angle that "
            "clears the obstruction.\n"
            "- Practise on an old table or dedicated practice cloth to avoid "
            "damaging match equipment.",
        ),
    ),

    # =========================================================================
    # §18 Masse shot
    # =========================================================================
    item(
        id="kn_masse_shot",
        slug="masse-shot",
        title="Massé Shot",
        title_vi="Masse — Đánh cong",
        category="cat_shotmaking",
        difficulty="expert",
        tags=["tag_expert", "tag_shotmaking", "tag_technique"],
        aliases=["masse", "massé", "đánh cong", "danh cong", "curve shot"],
        keywords=["masse", "đánh cong", "nâng cơ", "né vật cản", "swerve"],
        related=["kn_jump_shot", "kn_throw_squirt_swerve", "kn_english",
                 "kn_safety_play"],
        drills=["MASSE"],
        vi=(
            "Kỹ thuật nâng cao đuôi cơ gần như thẳng đứng để tạo đường đi cong "
            "cho bi cái, né vật cản mà không cần chạm băng.",

            "1. Nâng đuôi cơ gần vuông góc với mặt bàn (30-70 độ tùy độ cong "
            "cần thiết).\n"
            "2. Ngắm điểm chạm lệch tâm bi cái theo hướng muốn bi cong tới.\n"
            "3. Dùng lực cổ tay là chính (không dùng lực toàn thân), đẩy cơ "
            "nhanh và dứt khoát.",

            "- Đây là kỹ thuật khó và rủi ro cao nhất, dễ làm rách nỉ bàn nếu "
            "thực hiện sai.\n"
            "- Chỉ nên dùng khi thực sự cần thiết (không còn phương án "
            "safety/kick nào khả thi).",

            "- Góc nâng cơ không đủ hoặc quá nhiều khiến bi đi sai quỹ đạo dự "
            "tính.\n"
            "- Đẩy cơ quá chậm khiến bi không đủ xoáy để tạo đường cong rõ "
            "rệt.",

            "- Bắt đầu luyện với góc nâng nhỏ (masse nhẹ) trước khi tăng độ "
            "khó.\n"
            "- Luyện trên bàn/nỉ không quan trọng để tránh gây hư hỏng khi còn "
            "chưa thành thạo.",
        ),
        en=(
            "Elevating the butt of the cue to near-vertical to curve the cue "
            "ball around an obstruction without using a rail.",

            "1. Raise the butt towards perpendicular — 30-70° depending on how "
            "much curve you need.\n"
            "2. Strike off centre, on the side you want the ball to curve "
            "towards.\n"
            "3. Drive mainly with the wrist, not the whole body, in a fast and "
            "decisive stroke.",

            "- This is the hardest and riskiest shot in the game and readily "
            "tears cloth when done badly.\n"
            "- Use it only when no safety or kick remains viable.",

            "- Too little or too much elevation, sending the ball off the "
            "intended arc.\n"
            "- Stroking too slowly, so the ball never gets enough spin to "
            "curve noticeably.",

            "- Begin with light massés at low elevation before increasing "
            "difficulty.\n"
            "- Practise on a table whose cloth doesn't matter until you are "
            "competent.",
        ),
    ),

    # =========================================================================
    # §19 Combination & Carom / Kiss
    # =========================================================================
    item(
        id="kn_combination_carom",
        slug="combination-carom",
        title="Combination, Carom and Kiss Shots",
        title_vi="Combination, Carom và Kiss shot",
        category="cat_shotmaking",
        difficulty="advanced",
        tags=["tag_advanced", "tag_shotmaking", "tag_accuracy"],
        aliases=["combination", "carom", "kiss", "combo", "bi dồn"],
        keywords=["combination", "carom", "kiss shot", "thẳng hàng",
                  "sai số cộng dồn"],
        related=["kn_aiming", "kn_bank_shot", "kn_rules_9ball",
                 "kn_table_layout"],
        drills=["COMBO_SHORT", "COMBO_LONG"],
        vi=(
            "**Combination** là đánh bi cái vào một bi để bi đó tiếp tục đẩy "
            "bi khác vào lỗ; **Carom/Kiss** là bi cái hoặc bi mục tiêu chạm "
            "nhẹ (lướt) qua một bi khác để đổi hướng.",

            "1. Với combination: coi bi trung gian như \"bi cái\" của cú đánh "
            "tiếp theo, áp dụng ghost ball cho từng cặp bi liên tiếp.\n"
            "2. Căn chỉnh 2 điểm ngắm nối tiếp: điểm bi cái chạm bi trung "
            "gian, và điểm bi trung gian chạm bi cuối.\n"
            "3. Với kiss shot: tính góc lướt nhẹ để bi đổi hướng đúng ý, "
            "thường dùng lực nhẹ và chính xác cao.",

            "- Combination có sai số cộng dồn (sai lệch nhỏ ở bi đầu sẽ khuếch "
            "đại ở bi cuối), nên độ khó tăng theo khoảng cách.\n"
            "- Chỉ nên thực hiện khi 2 bi (trung gian và mục tiêu) gần thẳng "
            "hàng với lỗ.",

            "- Đánh combination khi các bi không đủ thẳng hàng, tỉ lệ thành "
            "công rất thấp.\n"
            "- Ước lượng sai điểm tiếp xúc ở bi trung gian do chỉ tập trung "
            "ngắm bi cuối.",

            "- Luyện đánh giá độ thẳng hàng trước khi chọn combination (nhìn "
            "từ nhiều góc nếu cần).\n"
            "- Chia nhỏ bài toán: ngắm chính xác từng điểm tiếp xúc một, không "
            "nhìn dồn về đích cuối.",
        ),
        en=(
            "A **combination** drives one ball into another and on into the "
            "pocket. A **carom or kiss** glances the cue ball or object ball "
            "off another ball to change its direction.",

            "1. For combinations, treat the intermediate ball as the 'cue "
            "ball' of the next contact and apply ghost ball to each pair in "
            "turn.\n"
            "2. Align two successive contact points: cue ball to intermediate "
            "ball, then intermediate ball to the final ball.\n"
            "3. For kiss shots, calculate the glancing angle carefully; they "
            "usually need soft, precise contact.",

            "- Errors compound: a small deviation on the first contact is "
            "magnified at the last, so difficulty rises with distance.\n"
            "- Attempt them mainly when the two balls are close to in line "
            "with the pocket.",

            "- Playing combinations on balls that aren't close to aligned, "
            "where the success rate is very low.\n"
            "- Misjudging the intermediate contact because your attention is "
            "on the final ball.",

            "- Practise judging alignment before committing, viewing from more "
            "than one angle.\n"
            "- Break the problem down: aim each contact point precisely rather "
            "than staring at the final destination.",
        ),
    ),

    # =========================================================================
    # §20 Kiểm soát tốc độ / Lag (rewrite of existing kn_speed_control)
    # =========================================================================
    item(
        id="kn_speed_control",
        slug="speed-control",
        title="Speed Control and the Lag",
        title_vi="Kiểm soát tốc độ và cú lag",
        category="cat_positioning",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_speed", "tag_positioning",
              "tag_cueball"],
        aliases=["speed control", "kiểm soát lực", "kiem soat luc", "lag",
                 "tốc độ"],
        keywords=["speed control", "lực đánh", "lag", "cấp lực",
                  "position play"],
        related=["kn_position_play", "kn_stroke", "kn_throw_squirt_swerve",
                 "kn_safety_advanced"],
        drills=["POSITION_CUE", "POSITION_TIGHT", "STRAIGHT_MID",
                "STRAIGHT_FAR"],
        vi=(
            "Khả năng điều chỉnh lực đánh chính xác theo nhiều cấp độ (không "
            "chỉ mạnh/nhẹ) để phục vụ position play và safety nâng cao. "
            "\"Lag\" còn là cú đánh mở màn để giành quyền break.",

            "1. Phân chia lực đánh thành nhiều cấp (ví dụ: 1-10), luyện cảm "
            "nhận từng cấp lực trên cùng một khoảng cách.\n"
            "2. Với lag: đánh bi cái từ đầu bàn chạm băng đối diện, quay lại "
            "càng gần băng xuất phát càng tốt (không chạm băng đó).\n"
            "3. Kết hợp tốc độ với xoáy để tính toán quãng đường bi cái di "
            "chuyển sau va chạm.",

            "- Tốc độ ảnh hưởng trực tiếp đến throw effect, độ xoáy còn lại "
            "sau va chạm và độ nảy băng.\n"
            "- Cảm giác lực cần được luyện trên chính bàn/bi thường xuyên sử "
            "dụng vì mỗi bàn có độ ma sát khác nhau.",

            "- Đánh không nhất quán lực giữa các cú tương tự, gây sai lệch "
            "position play.\n"
            "- Với lag, đánh quá mạnh khiến bi bật ngược lại quá xa hoặc rơi "
            "xuống khe băng.",

            "- Luyện bài tập \"speed control drill\": đánh bi cái đi rồi dừng "
            "chính xác tại các mốc định sẵn trên bàn.\n"
            "- Tập lag riêng biệt nhiều lần trên cùng một bàn thi đấu trước "
            "giải để quen độ nảy.",
        ),
        en=(
            "Regulating stroke power across a range of levels — not merely "
            "hard versus soft — in service of position play and advanced "
            "safety. The 'lag' is also the opening shot that decides who "
            "breaks.",

            "1. Divide power into levels (say 1-10) and practise feeling each "
            "one at a fixed distance.\n"
            "2. For the lag, send the cue ball from the head of the table to "
            "the far cushion and back as close as possible to the starting "
            "rail without touching it.\n"
            "3. Combine speed with spin to predict how far the cue ball runs "
            "after contact.",

            "- Speed directly affects throw, how much spin survives contact, "
            "and rebound angles off the cushion.\n"
            "- Calibrate your feel on the table and balls you actually play "
            "on; friction varies table to table.",

            "- Inconsistent power on similar shots, which wrecks position "
            "play.\n"
            "- On the lag, hitting too hard so the ball rebounds far past the "
            "rail or drops into a pocket.",

            "- Drill speed control: send the cue ball out and stop it exactly "
            "on marked targets.\n"
            "- Practise the lag repeatedly on the match table before an event "
            "to learn its rebound.",
        ),
    ),

    # =========================================================================
    # §21 Lập kế hoạch run-out
    # =========================================================================
    item(
        id="kn_run_out_planning",
        slug="run-out-planning",
        title="Run-out Planning (Advanced Pattern Play)",
        title_vi="Lập kế hoạch run-out",
        category="cat_strategy",
        difficulty="advanced",
        tags=["tag_advanced", "tag_strategy", "tag_positioning"],
        aliases=["run out", "run-out", "chạy bàn", "chay ban", "pattern play"],
        keywords=["run-out", "key ball", "break-out", "tư duy ngược",
                  "pattern"],
        related=["kn_table_layout", "kn_position_play", "kn_safety_advanced",
                 "pattern.run_out", "pattern.key_ball"],
        drills=["PATTERN_3_BALLS", "PATTERN_5_BALLS", "PATTERN_MULTI_RAIL"],
        vi=(
            "Tư duy sắp xếp thứ tự đánh toàn bộ các bi còn lại trên bàn để "
            "hoàn thành ván đấu (run-out) mà không nhường lượt cho đối thủ.",

            "1. Nhóm các bi theo khu vực (cụm bi gần nhau) và tìm bi \"chìa "
            "khóa\" (key ball) nối các cụm.\n"
            "2. Luôn để lại 1-2 phương án dự phòng (break-out) nếu bi bị kẹt "
            "cụm.\n"
            "3. Tính từ bi cuối cùng ngược về bi đầu tiên để đảm bảo đường "
            "chạy hợp lý.",

            "- Với bàn 8-ball/9-ball, bi khó nhất nên được xử lý sớm khi bàn "
            "còn nhiều lựa chọn vị trí.\n"
            "- Nên có phương án B nếu vị trí bi cái không như tính toán.",

            "- Chỉ lên kế hoạch 1-2 cú đầu, không tính hết đến bi cuối.\n"
            "- Không có phương án dự phòng khi cú đánh đầu không đạt vị trí "
            "như ý.",

            "- Luyện tư duy \"ngược\": xuất phát từ bi cuối, xác định vị trí "
            "lý tưởng của bi cái trước đó, rồi lùi dần về bi đầu.\n"
            "- Xem lại (review) các ván đã đấu để rút kinh nghiệm về các pha "
            "lập kế hoạch sai.",
        ),
        en=(
            "Sequencing every remaining ball so you finish the rack without "
            "giving the opponent a turn.",

            "1. Group the balls by area and find the key ball that links one "
            "cluster to the next.\n"
            "2. Keep one or two break-out options in reserve for clustered "
            "balls.\n"
            "3. Plan backwards from the last ball to the first to confirm the "
            "route holds together.",

            "- In 8-ball and 9-ball, deal with the hardest ball early, while "
            "the table still offers positional choices.\n"
            "- Always carry a plan B for when the cue ball doesn't land where "
            "you intended.",

            "- Planning only the first shot or two and never checking the "
            "ending.\n"
            "- Having no fallback when the first shot misses its position.",

            "- Train backwards thinking: start at the final ball, fix the "
            "ideal cue ball position before it, and work back to the first.\n"
            "- Review your played racks to learn where the planning went "
            "wrong.",
        ),
    ),

    # =========================================================================
    # §22 Chiến thuật safety nâng cao
    # =========================================================================
    item(
        id="kn_safety_advanced",
        slug="safety-advanced",
        title="Advanced Safety Strategy",
        title_vi="Chiến thuật safety nâng cao",
        category="cat_strategy",
        difficulty="advanced",
        tags=["tag_advanced", "tag_strategy", "tag_defense"],
        aliases=["safety nâng cao", "return safety", "safety chủ động",
                 "advanced safety"],
        keywords=["safety", "return safety", "push out", "xác suất",
                  "phòng thủ chủ động"],
        related=["kn_safety_play", "kn_kick_shot", "kn_run_out_planning",
                 "kn_rules_9ball", "safety.tactical_safe"],
        drills=["SAFETY_FORCE", "SAFETY_KICK", "SAFETY_BASIC"],
        vi=(
            "Vận dụng safety như một vũ khí chủ động (không chỉ phòng thủ bị "
            "động) để kiểm soát nhịp độ ván đấu và gây áp lực tâm lý cho đối "
            "thủ.",

            "1. Đánh giá tỷ lệ thành công của cú ăn bi so với rủi ro nếu đánh "
            "hỏng, để quyết định chọn safety chủ động.\n"
            "2. Sử dụng \"return safety\" (đánh trả an toàn) khi bị đối thủ "
            "safety trước đó.\n"
            "3. Kết hợp safety với việc làm khó vị trí bi mục tiêu của chính "
            "mình cho đối thủ ở lượt sau.",

            "- Safety chủ động thường dùng khi tỷ lệ ăn bi dưới 50% nhưng để "
            "mất bi lại tạo cơ hội lớn cho đối thủ.\n"
            "- Cần nắm rõ luật \"push out\" (nếu có) trong một số biến thể như "
            "9-ball.",

            "- Chọn safety khi cú đánh ăn bi có tỷ lệ thành công cao hơn nhiều "
            "so với rủi ro.\n"
            "- Đánh safety nhưng vô tình để lại vị trí thuận lợi hơn cho đối "
            "thủ.",

            "- Rèn tư duy tính xác suất trước mỗi quyết định (không chỉ dựa "
            "cảm tính).\n"
            "- Luyện tập các tình huống safety mẫu với huấn luyện viên hoặc "
            "qua video phân tích trận đấu chuyên nghiệp.",
        ),
        en=(
            "Using safety as an active weapon rather than passive defence — to "
            "control the rhythm of the match and apply psychological "
            "pressure.",

            "1. Weigh the pot's success rate against the cost of missing, then "
            "decide whether to play the active safety.\n"
            "2. Play a return safety when the opponent has just left you "
            "one.\n"
            "3. Combine the safety with leaving your own object ball awkward "
            "for the opponent's next turn.",

            "- Active safety usually earns its place when the pot is under 50% "
            "and missing hands the opponent a big chance.\n"
            "- Know the push-out rule where it applies, as in 9-ball.",

            "- Choosing safety when the pot's success rate clearly outweighs "
            "the risk.\n"
            "- Playing a safety that accidentally leaves the opponent better "
            "placed than before.",

            "- Train yourself to estimate probabilities before deciding, "
            "rather than going on feel.\n"
            "- Work through standard safety situations with a coach or by "
            "analysing professional match footage.",
        ),
    ),

    # =========================================================================
    # §23 Tâm lý thi đấu
    # =========================================================================
    item(
        id="kn_mental_game",
        slug="mental-game",
        title="The Mental Game",
        title_vi="Tâm lý thi đấu",
        category="cat_psychology",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_technique"],
        aliases=["mental game", "tâm lý", "tam ly", "pre-shot routine",
                 "tập trung"],
        keywords=["tâm lý", "pre-shot routine", "tập trung", "áp lực",
                  "hít thở"],
        related=["mental.routine", "mental.pressure", "mental.concentration",
                 "kn_run_out_planning"],
        drills=["PRESSURE_SHOT", "FOCUS_DRILL", "COMEBACK_PRACTICE"],
        vi=(
            "Yếu tố tâm lý — khả năng giữ bình tĩnh, tập trung và duy trì thói "
            "quen (routine) ổn định trong suốt trận đấu, đặc biệt ở các tình "
            "huống áp lực.",

            "1. Xây dựng một \"pre-shot routine\" cố định (các bước chuẩn bị "
            "giống nhau trước mỗi cú đánh) để tạo sự ổn định tâm lý.\n"
            "2. Tập trung vào từng cú đánh hiện tại, tránh nghĩ về kết quả "
            "chung cuộc hoặc sai lầm vừa qua.\n"
            "3. Sử dụng kỹ thuật hít thở sâu hoặc tạm dừng ngắn giữa các lượt "
            "để duy trì sự tập trung.",

            "- Routine trước cú đánh nên có thời lượng và trình tự nhất quán ở "
            "mọi tình huống, kể cả cú dễ.\n"
            "- Không nên đánh giá bản thân qua từng cú đánh đơn lẻ mà qua cả "
            "quá trình.",

            "- Đánh nhanh, vội vàng khi bị áp lực hoặc dẫn/thua điểm.\n"
            "- Giữ sự tức giận, thất vọng từ cú đánh hỏng trước sang cú đánh "
            "tiếp theo.",

            "- Luyện tập ghi hình các trận đấu của bản thân để nhận diện thời "
            "điểm mất tập trung.\n"
            "- Áp dụng kỹ thuật \"reset\" giữa các cú: một hành động nhỏ (chạm "
            "bàn, hít thở) để \"xóa\" cảm xúc cũ trước khi vào cú mới.",
        ),
        en=(
            "The psychological side — staying calm, staying focused, and "
            "keeping a stable routine through a match, especially under "
            "pressure.",

            "1. Build a fixed pre-shot routine: the same preparation steps "
            "before every shot, which stabilises the mind.\n"
            "2. Attend to the shot in front of you, not the final score or the "
            "mistake you just made.\n"
            "3. Use deep breathing or a short pause between turns to hold "
            "focus.",

            "- The routine should keep the same length and order in every "
            "situation, easy shots included.\n"
            "- Judge yourself over the whole process rather than by individual "
            "shots.",

            "- Rushing when under pressure, whether ahead or behind.\n"
            "- Carrying anger or disappointment from a missed shot into the "
            "next one.",

            "- Film your own matches to spot the moments your focus goes.\n"
            "- Adopt a reset action between shots — a touch of the table, a "
            "breath — to clear the previous emotion before starting again.",
        ),
    ),
]
