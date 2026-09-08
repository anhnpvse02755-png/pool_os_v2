"""Dictionary §24–§30 — game rules and equipment.

These fill `cat_rules` and `cat_equipment`, which existed as categories but
held no articles before this import.
"""

from .common import item

ITEMS = [
    # =========================================================================
    # §24 8-Ball
    # =========================================================================
    item(
        id="kn_rules_8ball",
        slug="rules-8-ball",
        title="8-Ball Rules",
        title_vi="Luật 8-Ball",
        category="cat_rules",
        difficulty="beginner",
        tags=["tag_basic", "tag_strategy"],
        aliases=["8 ball", "8-ball", "tám bi", "bi-a 8 bi", "eight ball"],
        keywords=["8-ball", "call shot", "bi trơn", "bi sọc", "luật"],
        related=["kn_rules_9ball", "kn_break_shot", "kn_run_out_planning",
                 "kn_safety_play"],
        drills=["PATTERN_5_BALLS", "BREAK_CONTROL"],
        vi=(
            "Thể loại phổ biến nhất, hai người/đội chia nhau nhóm bi trơn "
            "(1-7) hoặc bi sọc (9-15), ai vào hết nhóm bi của mình và vào bi "
            "số 8 hợp lệ sẽ thắng.",

            "1. Break hợp lệ để xác định ai chơi nhóm bi nào (dựa vào bi đầu "
            "tiên vào lỗ sau break, tùy luật địa phương/giải đấu).\n"
            "2. Đánh lần lượt các bi trong nhóm của mình, gọi bi và lỗ trước "
            "khi đánh (call shot) nếu chơi theo luật giải đấu.\n"
            "3. Chỉ được đánh bi số 8 sau khi đã vào hết nhóm bi của mình.",

            "- Luật \"call shot\" yêu cầu gọi rõ bi và lỗ định đánh, tránh "
            "tranh cãi khi bi vào ăn may.\n"
            "- Thua ngay lập tức nếu vào bi số 8 sai lỗ, sai lượt, hoặc khi bi "
            "cái cùng rơi lỗ với bi số 8.",

            "- Đánh bi số 8 khi chưa xử lý hết bi của nhóm mình.\n"
            "- Không gọi bi/lỗ rõ ràng dẫn đến tranh cãi luật.",

            "- Luôn kiểm đếm số bi còn lại của nhóm mình trước khi cân nhắc "
            "đánh bi số 8.\n"
            "- Thống nhất luật chơi (call shot hay không) với đối thủ trước "
            "khi bắt đầu ván.",
        ),
        en=(
            "The most widely played format. Two players or teams take the "
            "solids (1-7) or the stripes (9-15); the first to clear their "
            "group and legally pot the 8 ball wins.",

            "1. A legal break decides who takes which group, usually from the "
            "first ball potted after the break (local and tournament rules "
            "vary).\n"
            "2. Pot your group in any order, calling ball and pocket before "
            "each shot if you're playing call-shot rules.\n"
            "3. The 8 ball may only be played once your whole group is "
            "cleared.",

            "- Call-shot rules require naming both ball and pocket, which "
            "prevents arguments over flukes.\n"
            "- You lose immediately for potting the 8 in the wrong pocket, out "
            "of turn, or together with the cue ball.",

            "- Playing the 8 ball before the group is finished.\n"
            "- Failing to call ball and pocket clearly, which causes rules "
            "disputes.",

            "- Count your remaining group balls before even considering the 8 "
            "ball.\n"
            "- Agree the ruleset (call shot or not) with your opponent before "
            "the rack starts.",
        ),
    ),

    # =========================================================================
    # §25 9-Ball
    # =========================================================================
    item(
        id="kn_rules_9ball",
        slug="rules-9-ball",
        title="9-Ball Rules",
        title_vi="Luật 9-Ball",
        category="cat_rules",
        difficulty="beginner",
        tags=["tag_basic", "tag_strategy"],
        aliases=["9 ball", "9-ball", "chín bi", "nine ball"],
        keywords=["9-ball", "push out", "ball in hand", "bi nhỏ nhất",
                  "luật"],
        related=["kn_rules_8ball", "kn_rules_10ball", "kn_break_shot",
                 "kn_combination_carom", "kn_safety_advanced"],
        drills=["PATTERN_3_BALLS", "BREAK_POWER", "SAFETY_BASIC"],
        vi=(
            "Chơi với 9 bi đánh số, phải đánh trúng bi có số nhỏ nhất trên bàn "
            "trước (dù không cần vào lỗ bi đó), ai vào bi số 9 (theo luật hợp "
            "lệ) sẽ thắng ván.",

            "1. Xác định bi số nhỏ nhất hiện có trên bàn, bi cái phải chạm bi "
            "này đầu tiên trong mỗi lượt.\n"
            "2. Có thể thắng ngay nếu vào bi số 9 hợp lệ ở bất kỳ thời điểm "
            "nào (kể cả cú break).\n"
            "3. Sử dụng chiến thuật \"push out\" (nếu luật cho phép) ngay sau "
            "break để đổi lượt cho đối thủ nếu vị trí xấu.",

            "- Đây là thể loại thiên về vị trí và safety cao vì luôn phải chạm "
            "đúng bi nhỏ nhất.\n"
            "- Luật \"combination\" cho phép đánh bi nhỏ nhất chạm rồi dồn vào "
            "bi số 9 để thắng.",

            "- Không chạm bi số nhỏ nhất trước (foul), tạo cơ hội \"ball in "
            "hand\" cho đối thủ.\n"
            "- Bỏ lỡ cơ hội push-out hợp lệ khi vị trí break không tốt.",

            "- Luôn xác nhận lại bi số nhỏ nhất trước khi vào cơ (đặc biệt sau "
            "các pha safety phức tạp).\n"
            "- Học kỹ luật push-out và tình huống nên/không nên sử dụng.",
        ),
        en=(
            "Played with nine numbered balls. The cue ball must contact the "
            "lowest-numbered ball first (though that ball need not be potted); "
            "legally potting the 9 wins the rack.",

            "1. Identify the lowest-numbered ball on the table — the cue ball "
            "must strike it first every turn.\n"
            "2. You win instantly on a legal 9 ball at any point, including on "
            "the break.\n"
            "3. Where the rules allow, use the push out right after the break "
            "to hand a bad layout back to your opponent.",

            "- The format leans heavily on position and safety, since you must "
            "always contact the lowest ball.\n"
            "- Combinations count: hit the lowest ball first and send it into "
            "the 9 to win.",

            "- Failing to contact the lowest ball first — a foul that gives "
            "the opponent ball in hand.\n"
            "- Passing up a legal push out when the break leaves a bad "
            "layout.",

            "- Re-confirm the lowest ball before settling into your stance, "
            "especially after complex safety exchanges.\n"
            "- Study the push-out rule and when it is and isn't worth using.",
        ),
    ),

    # =========================================================================
    # §26 10-Ball
    # =========================================================================
    item(
        id="kn_rules_10ball",
        slug="rules-10-ball",
        title="10-Ball Rules",
        title_vi="Luật 10-Ball",
        category="cat_rules",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_strategy"],
        aliases=["10 ball", "10-ball", "mười bi", "ten ball"],
        keywords=["10-ball", "call shot", "gọi lỗ", "luật", "chuyên nghiệp"],
        related=["kn_rules_9ball", "kn_rules_8ball", "kn_safety_advanced",
                 "kn_run_out_planning"],
        drills=["PATTERN_5_BALLS", "SAFETY_BASIC", "BREAK_ACCURACY"],
        vi=(
            "Biến thể khắt khe hơn 9-ball, chơi với 10 bi, yêu cầu \"call "
            "shot\" bắt buộc kể cả với bi số 10 (bi thắng), giảm yếu tố may "
            "rủi.",

            "1. Tương tự 9-ball: luôn chạm bi số nhỏ nhất trước.\n"
            "2. Bắt buộc gọi lỗ khi đánh bi số 10 (khác với 9-ball, có thể ăn "
            "may bi số 9).\n"
            "3. Yêu cầu độ chính xác và chiến thuật cao hơn do không được tính "
            "bi vào \"ăn may\".",

            "- Thường được xem là thể loại thi đấu chuyên nghiệp cao cấp vì "
            "giảm thiểu yếu tố may rủi.\n"
            "- Safety và pattern play quan trọng hơn nhiều so với 9-ball.",

            "- Quên gọi lỗ khi đánh bi số 10, dẫn đến bi vào không được tính.\n"
            "- Áp dụng chiến thuật 9-ball (dựa vào may rủi) không phù hợp với "
            "10-ball.",

            "- Rèn thói quen gọi lỗ rõ ràng cho MỌI bi, không chỉ bi cuối.\n"
            "- Tập trung nhiều hơn vào an toàn (safety) và độ chính xác thay "
            "vì các cú đánh liều.",
        ),
        en=(
            "A stricter variant of 9-ball played with ten balls, where calling "
            "the shot is mandatory — including for the winning 10 ball — which "
            "removes most of the luck.",

            "1. As in 9-ball, always contact the lowest-numbered ball first.\n"
            "2. The pocket must be called on the 10 ball, unlike 9-ball where "
            "a fluked 9 counts.\n"
            "3. Because flukes don't count, both accuracy and tactics matter "
            "more.",

            "- It is widely regarded as the premier professional format, "
            "precisely because it minimises luck.\n"
            "- Safety and pattern play weigh far more heavily than in 9-ball.",

            "- Forgetting to call the pocket on the 10, so a potted ball "
            "doesn't count.\n"
            "- Carrying over 9-ball's luck-tolerant tactics, which don't fit "
            "10-ball.",

            "- Build the habit of calling the pocket on EVERY ball, not just "
            "the last one.\n"
            "- Weight your game towards safety and accuracy rather than "
            "low-percentage attempts.",
        ),
    ),

    # =========================================================================
    # §27 Straight Pool / 14.1 Continuous
    # =========================================================================
    item(
        id="kn_rules_14_1",
        slug="rules-straight-pool-14-1",
        title="Straight Pool (14.1 Continuous) Rules",
        title_vi="Luật Straight Pool / 14.1 Continuous",
        category="cat_rules",
        difficulty="advanced",
        tags=["tag_advanced", "tag_strategy"],
        aliases=["straight pool", "14.1", "14-1", "continuous",
                 "bi-a điểm"],
        keywords=["14.1", "straight pool", "break ball", "rack", "tính điểm"],
        related=["kn_rules_8ball", "kn_run_out_planning", "kn_table_layout",
                 "kn_break_shot"],
        drills=["PATTERN_MULTI_RAIL", "PATTERN_5_BALLS", "POSITION_TIGHT"],
        vi=(
            "Thể loại cổ điển, người chơi có thể đánh bất kỳ bi nào (trừ bi "
            "cuối cùng để lại làm \"break ball\"), tính điểm theo số bi vào "
            "lỗ, thường thi đấu đến 100-150 điểm.",

            "1. Đánh bi bất kỳ (trừ bi cuối) cho đến khi bàn còn 1 bi + bi "
            "cái.\n"
            "2. Sắp lại 14 bi còn lại thành hình tam giác, giữ nguyên bi cuối "
            "(break ball) và bi cái.\n"
            "3. Dùng bi cuối để \"break\" nhẹ cụm bi mới, tiếp tục đếm điểm "
            "liên tục qua nhiều rack.",

            "- Đòi hỏi kỹ năng lập kế hoạch dài hạn cao nhất trong các thể "
            "loại (phải tính cả bi break kế tiếp).\n"
            "- Một lỗi (foul) liên tiếp nhiều lần sẽ bị trừ điểm nặng (theo "
            "luật cụ thể).",

            "- Không để ý bi cuối cùng, làm hỏng cơ hội break rack tiếp theo.\n"
            "- Tính điểm/foul sai do đây là luật phức tạp hơn 8-ball/9-ball.",

            "- Luôn hình dung trước hình dạng cụm bi mới khi chỉ còn khoảng "
            "3-4 bi trên bàn.\n"
            "- Ôn kỹ luật foul và cách tính điểm trước khi thi đấu thể loại "
            "này.",
        ),
        en=(
            "The classic format: any ball may be played except the last one, "
            "kept back as the break ball. You score one point per ball potted, "
            "usually racing to 100-150.",

            "1. Pot any ball, except the final one, until only one object ball "
            "and the cue ball remain.\n"
            "2. Re-rack the other fourteen into a triangle, leaving the break "
            "ball and cue ball in place.\n"
            "3. Use the break ball to open the new rack softly and keep the "
            "run going across racks.",

            "- It demands the longest-range planning of any format, since you "
            "must set up the next rack's break too.\n"
            "- Repeated fouls carry heavy point penalties under the specific "
            "ruleset.",

            "- Neglecting the last ball and ruining the next rack's break.\n"
            "- Miscounting points or fouls — the rules are more intricate than "
            "8-ball or 9-ball.",

            "- Start picturing the new rack's shape while three or four balls "
            "remain.\n"
            "- Review the foul and scoring rules carefully before playing this "
            "format competitively.",
        ),
    ),

    # =========================================================================
    # §28 One Pocket
    # =========================================================================
    item(
        id="kn_rules_one_pocket",
        slug="rules-one-pocket",
        title="One Pocket Rules",
        title_vi="Luật One Pocket",
        category="cat_rules",
        difficulty="expert",
        tags=["tag_expert", "tag_strategy", "tag_defense"],
        aliases=["one pocket", "one-pocket", "một lỗ", "mot lo"],
        keywords=["one pocket", "chiến thuật", "khóa bi", "phòng thủ",
                  "luật"],
        related=["kn_safety_advanced", "kn_safety_play", "kn_table_layout",
                 "kn_rules_14_1"],
        drills=["SAFETY_FORCE", "SAFETY_KICK", "POSITION_TIGHT"],
        vi=(
            "Thể loại chiến thuật cao, mỗi người chỉ được ghi điểm vào 1 trong "
            "2 lỗ được chỉ định (đối xứng chéo nhau), ai vào đủ 8 bi vào đúng "
            "lỗ của mình trước sẽ thắng.",

            "1. Xác định lỗ của mình (một trong hai lỗ ở cuối bàn, đối xứng "
            "với lỗ của đối thủ).\n"
            "2. Ưu tiên safety và kiểm soát vị trí bi hơn là ăn bi ngay, vì cơ "
            "hội ăn bi vào đúng lỗ mình rất hẹp.\n"
            "3. Tính toán để \"khóa\" bi của đối thủ xa khỏi lỗ của họ trong "
            "khi vẫn giữ bi gần lỗ của mình.",

            "- Đây là thể loại được xem là \"cờ vua của billiard\" do độ sâu "
            "chiến thuật.\n"
            "- Foul nghiêm trọng (như đẩy bi vào lỗ sai của đối thủ) có thể "
            "đổi cục diện hoàn toàn.",

            "- Chơi thể loại này như 8-ball/9-ball (ưu tiên ăn bi thay vì "
            "chiến thuật vị trí).\n"
            "- Không tính đến việc vô tình đưa bi đến gần lỗ của đối thủ.",

            "- Luyện tư duy phòng thủ trước, chỉ tấn công khi cơ hội ăn bi vào "
            "đúng lỗ rất rõ ràng.\n"
            "- Học từ các ván đấu one-pocket chuyên nghiệp để hiểu tư duy kiểm "
            "soát bàn dài hạn.",
        ),
        en=(
            "A deeply tactical format: each player may only score into one of "
            "two designated pockets, diagonally opposite each other. First to "
            "eight balls in their own pocket wins.",

            "1. Establish which pocket is yours — one of the two at the foot "
            "of the table, opposite your opponent's.\n"
            "2. Favour safety and ball control over immediate potting; genuine "
            "chances at your own pocket are rare.\n"
            "3. Work to move the opponent's balls away from their pocket while "
            "keeping yours near yours.",

            "- It is often called the chess of billiards for its tactical "
            "depth.\n"
            "- A serious foul — such as knocking a ball into the opponent's "
            "pocket — can swing the whole game.",

            "- Playing it like 8-ball or 9-ball, prioritising pots over "
            "positional strategy.\n"
            "- Failing to notice you are feeding balls towards the opponent's "
            "pocket.",

            "- Build the defensive instinct first and attack only when the "
            "chance at your own pocket is clear.\n"
            "- Study professional one-pocket matches to absorb the long-range "
            "table control.",
        ),
    ),

    # =========================================================================
    # §29 Chọn cơ (Cue Selection)
    # =========================================================================
    item(
        id="kn_cue_selection",
        slug="cue-selection",
        title="Choosing a Cue",
        title_vi="Chọn cơ phù hợp",
        category="cat_equipment",
        difficulty="beginner",
        tags=["tag_basic", "tag_technique"],
        aliases=["cue selection", "chọn cơ", "chon co", "mua cơ", "cây cơ"],
        keywords=["cơ", "trọng lượng", "đầu da", "tip", "low deflection",
                  "shaft"],
        related=["kn_cue_maintenance", "kn_english", "kn_throw_squirt_swerve",
                 "kn_grip"],
        drills=["STROKE_STRAIGHT", "STRAIGHT_MID"],
        vi=(
            "Việc lựa chọn cây cơ (trọng lượng, kích thước đầu da, loại shaft) "
            "phù hợp với phong cách và trình độ chơi.",

            "1. Chọn trọng lượng cơ phù hợp (thường 18-21 oz), thử nhiều mức "
            "để cảm nhận độ thuận tay.\n"
            "2. Kích thước đầu da (tip) phổ biến 12-13mm cho pool; đầu nhỏ hơn "
            "dễ dùng English hơn nhưng dễ trượt cơ hơn.\n"
            "3. Cân nhắc shaft low-deflection nếu chơi nhiều kỹ thuật "
            "English/spin nâng cao.",

            "- Cơ quá nặng/nhẹ so với thể trạng sẽ ảnh hưởng đến cảm giác lực "
            "và độ chính xác lâu dài.\n"
            "- Nên thử cơ trực tiếp tại cửa hàng/CLB trước khi mua nếu có "
            "thể.",

            "- Chọn cơ theo giá tiền/thương hiệu mà không thử cảm giác cầm "
            "thực tế.\n"
            "- Dùng đầu da quá cũ, mòn, hoặc sai kích thước gây trượt cơ liên "
            "tục.",

            "- Thử tối thiểu 3-4 cây cơ khác trọng lượng trước khi quyết định "
            "mua.\n"
            "- Thay đầu da định kỳ (tùy tần suất chơi) và bảo dưỡng đúng "
            "cách.",
        ),
        en=(
            "Choosing a cue — weight, tip size, shaft type — that suits your "
            "style and level.",

            "1. Pick a workable weight (typically 18-21 oz), trying several to "
            "find what feels natural.\n"
            "2. Pool tips are commonly 12-13mm; a smaller tip makes English "
            "easier but miscues more likely.\n"
            "3. Consider a low-deflection shaft if you use a lot of English "
            "and advanced spin.",

            "- A cue too heavy or light for your build will affect your feel "
            "for power and your long-term accuracy.\n"
            "- Try cues in person at a shop or club before buying where you "
            "can.",

            "- Choosing on price or brand without ever holding the cue.\n"
            "- Playing with a worn-out or wrongly sized tip, which causes "
            "repeated miscues.",

            "- Try at least three or four cues of different weights before "
            "deciding.\n"
            "- Replace the tip on a regular schedule suited to how often you "
            "play, and maintain it properly.",
        ),
    ),

    # =========================================================================
    # §30 Bảo trì cơ và dụng cụ
    # =========================================================================
    item(
        id="kn_cue_maintenance",
        slug="cue-maintenance",
        title="Cue and Equipment Maintenance",
        title_vi="Bảo trì cơ và dụng cụ",
        category="cat_equipment",
        difficulty="beginner",
        tags=["tag_basic", "tag_technique"],
        aliases=["bảo trì cơ", "bao tri co", "maintenance", "chăm sóc cơ",
                 "đầu da"],
        keywords=["bảo trì", "shaft", "đầu da", "phấn", "chalk", "roll test"],
        related=["kn_cue_selection", "kn_draw_shot", "kn_grip"],
        drills=["STROKE_STRAIGHT"],
        vi=(
            "Các thói quen chăm sóc cơ, đầu da, và phụ kiện để duy trì độ "
            "chính xác và tuổi thọ dụng cụ.",

            "1. Lau shaft cơ bằng khăn/giấy chuyên dụng sau mỗi buổi chơi để "
            "loại bỏ phấn và mồ hôi tay.\n"
            "2. Kiểm tra và tạo hình đầu da (shaping tip) định kỳ để giữ độ "
            "cong chuẩn (giúp kiểm soát điểm chạm chính xác).\n"
            "3. Bảo quản cơ trong hộp/ống cứng, tránh để nơi ẩm hoặc nhiệt độ "
            "cao gây cong vênh.",

            "- Không dùng quá nhiều phấn (chalk) trong một lần, chỉ cần lớp "
            "mỏng đều.\n"
            "- Kiểm tra độ thẳng của cơ (roll test trên mặt phẳng) định kỳ.",

            "- Để cơ tựa vào tường hoặc nơi có nhiệt độ/độ ẩm thay đổi liên "
            "tục, gây cong shaft.\n"
            "- Đầu da quá cứng hoặc quá mòn nhưng không thay/bảo dưỡng kịp "
            "thời.",

            "- Luôn cất cơ trong ống/hộp chuyên dụng sau khi chơi, để nơi khô "
            "ráo, thoáng mát.\n"
            "- Lên lịch bảo dưỡng đầu da (dũa, làm nhám) mỗi 1-2 tháng tùy tần "
            "suất sử dụng.",
        ),
        en=(
            "The habits that keep a cue, its tip, and your accessories "
            "accurate and long-lived.",

            "1. Wipe the shaft with a proper cloth after every session to "
            "remove chalk and hand oils.\n"
            "2. Check and shape the tip regularly so it keeps its curve, which "
            "is what makes the contact point predictable.\n"
            "3. Store the cue in a hard case, away from damp or heat that "
            "warps it.",

            "- Don't over-chalk; a thin, even layer is all you need.\n"
            "- Roll-test the cue on a flat surface periodically to check it is "
            "still straight.",

            "- Leaning the cue against a wall or leaving it where temperature "
            "and humidity swing, which warps the shaft.\n"
            "- Letting the tip glaze over or wear down without maintaining or "
            "replacing it.",

            "- Always return the cue to its case after playing and keep it "
            "somewhere dry and cool.\n"
            "- Schedule tip maintenance (filing, scuffing) every one to two "
            "months depending on how much you play.",
        ),
    ),
]
