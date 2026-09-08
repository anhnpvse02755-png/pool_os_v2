"""Dictionary §5.1–§5.6 — the aiming-method family.

Before this import `cat_aiming` held a single article; these six give the
category the depth the dictionary describes.
"""

from .common import item

ITEMS = [
    # =========================================================================
    # §5.1 Ngắm mép bi (Fractional / Edge Aiming)
    # =========================================================================
    item(
        id="kn_aiming_fractional",
        slug="aiming-fractional",
        title="Fractional (Edge) Aiming",
        title_vi="Ngắm mép bi",
        category="cat_aiming",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_aiming", "tag_accuracy"],
        aliases=["fractional aiming", "edge aiming", "ngắm mép bi",
                 "ngam mep bi", "half ball"],
        keywords=["fractional", "mép bi", "half ball", "3/4 bi", "1/4 bi",
                  "góc cắt"],
        related=["kn_aiming", "kn_aiming_contact_point",
                 "kn_aiming_method_selection"],
        drills=["HALF_BALL_LEFT", "HALF_BALL_RIGHT", "THIN_CUT_30",
                "THICK_CUT_45"],
        vi=(
            "Thay vì hình dung cả một \"bi ảo\" vô hình, người chơi chia bi "
            "mục tiêu thành các phần (full, 3/4, 1/2, 1/4 bi...) và ngắm bi "
            "cái đi vào đúng phần mép bi tương ứng với góc cắt cần thiết. Đây "
            "là cách rút gọn của ghost ball, giúp ngắm nhanh hơn bằng mắt "
            "thường.",

            "1. Ước lượng góc cắt (cut angle) cần thiết giữa đường bi cái — bi "
            "mục tiêu — lỗ.\n"
            "2. Quy đổi góc đó sang tỷ lệ mép bi cần thấy: ví dụ đánh \"full "
            "ball\" (thẳng) = 0°, \"3/4 ball\" ≈ 15-20°, \"1/2 ball\" ≈ 30°, "
            "\"1/4 ball\" ≈ 45-50°.\n"
            "3. Ngắm sao cho phần bi cái \"chồng\" lên đúng tỷ lệ mép bi mục "
            "tiêu đã ước lượng, rồi đẩy cơ theo đúng đường đó.",

            "- Đây là phương pháp ước lượng nhanh, phù hợp khi đã có kinh "
            "nghiệm nhận diện góc; người mới nên đối chiếu lại bằng ghost ball "
            "để kiểm tra độ chính xác.\n"
            "- Tỷ lệ mép bi không tuyến tính với góc độ (từ 1/2 đến 1/4 bi góc "
            "tăng nhanh hơn từ full đến 3/4), cần luyện tập nhiều để cảm nhận "
            "đúng.",

            "- Ước lượng sai tỷ lệ ở các góc cắt hẹp (1/4 bi trở xuống), vì "
            "sai số nhỏ ở mép bi gây lệch góc rất lớn.\n"
            "- Nhầm lẫn giữa \"nhìn phần bi mục tiêu còn lại\" và \"nhìn phần "
            "bi cái chồng lên\" — hai cách nhìn cho tỷ lệ khác nhau nếu không "
            "nhất quán.",

            "- Luyện tập cố định một cách nhìn duy nhất (ví dụ luôn nhìn theo "
            "phần bi cái phủ lên bi mục tiêu), không đổi qua lại giữa các buổi "
            "tập.\n"
            "- Dùng bài tập \"góc cố định\" — đặt bi ở các góc 3/4, 1/2, 1/4 đã "
            "biết trước, luyện ngắm và đối chiếu kết quả thực tế để hiệu chỉnh "
            "mắt.",
        ),
        en=(
            "Instead of visualising a whole invisible ball, you divide the "
            "object ball into fractions (full, 3/4, 1/2, 1/4) and aim the cue "
            "ball at the fraction matching the required cut. It is a shorthand "
            "for ghost ball that aims faster by eye.",

            "1. Estimate the cut angle between cue ball, object ball and "
            "pocket.\n"
            "2. Convert that angle into the fraction you need to see: full "
            "ball = 0°, 3/4 ball ≈ 15-20°, 1/2 ball ≈ 30°, 1/4 ball ≈ 45-50°.\n"
            "3. Aim so the cue ball overlaps the object ball by that fraction, "
            "then deliver along that line.",

            "- This is a fast estimate suited to players who already read "
            "angles well; beginners should cross-check against ghost ball.\n"
            "- The fraction-to-angle relationship is not linear — the jump "
            "from 1/2 to 1/4 covers more degrees than full to 3/4 — so it "
            "takes practice to calibrate.",

            "- Misjudging thin cuts (1/4 ball and below), where a small edge "
            "error produces a large angular error.\n"
            "- Confusing 'the part of the object ball still visible' with 'the "
            "overlap of the cue ball' — inconsistency between the two gives "
            "different fractions.",

            "- Commit to one way of seeing it (for example always reading the "
            "cue ball's overlap) and don't switch between sessions.\n"
            "- Drill known angles: set balls at 3/4, 1/2 and 1/4 positions, "
            "aim, then compare the real result to recalibrate your eye.",
        ),
    ),

    # =========================================================================
    # §5.2 Điểm xa nhất – điểm gần nhất (Contact Point System)
    # =========================================================================
    item(
        id="kn_aiming_contact_point",
        slug="aiming-contact-point",
        title="Farthest–Nearest Point (Contact Point System)",
        title_vi="Phương pháp điểm xa nhất – điểm gần nhất",
        category="cat_aiming",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_aiming", "tag_accuracy"],
        aliases=["contact point", "điểm tiếp xúc", "diem tiep xuc",
                 "farthest nearest"],
        keywords=["contact point", "điểm xa nhất", "điểm gần nhất",
                  "điểm tiếp xúc", "ngắm"],
        related=["kn_aiming", "kn_aiming_fractional",
                 "kn_aiming_cloth_contact", "kn_aiming_method_selection"],
        drills=["THIN_CUT_45", "THICK_CUT_30", "LONG_POT_1M"],
        vi=(
            "Kỹ thuật ngắm dựa trên việc nối điểm xa nhất của bi mục tiêu "
            "(phía đối diện với lỗ) với điểm gần nhất của bi cái, giúp xác "
            "định trực tiếp điểm tiếp xúc (contact point) cần đánh trúng trên "
            "bi mục tiêu mà không cần dựng hình bi ảo.",

            "1. Xác định điểm xa nhất trên bi mục tiêu tính từ tâm lỗ (điểm ở "
            "phía \"sau\" bi mục tiêu, ngược hướng với lỗ).\n"
            "2. Xác định điểm gần nhất trên bi cái tính theo hướng bi cái sẽ "
            "di chuyển tới.\n"
            "3. Tưởng tượng một đường thẳng nối 2 điểm này chính là đường mà "
            "tâm bi cái cần đi qua — đẩy cơ để bi cái di chuyển dọc theo đường "
            "đó.",

            "- Phương pháp này giúp mắt tập trung vào các điểm cụ thể trên bề "
            "mặt bi thay vì phải hình dung cả một quả bi vô hình, phù hợp với "
            "người thích ngắm bằng điểm mốc rõ ràng.\n"
            "- Cần xác định đúng \"điểm xa nhất\" theo đúng hướng bi mục tiêu "
            "cần đi vào lỗ, không phải điểm xa nhất bất kỳ.",

            "- Xác định sai điểm xa nhất do nhìn theo hướng bi cái tới thay vì "
            "hướng bi mục tiêu cần đi.\n"
            "- Chỉ tập trung vào 2 điểm mốc mà quên kiểm tra lại bằng hình "
            "dung tổng thể đường bi, dễ gây sai số tích lũy ở góc hẹp.",

            "- Luyện xác định điểm xa nhất bằng cách luôn vẽ trước (trong đầu) "
            "đường đi của bi mục tiêu tới lỗ, rồi lấy điểm đối xứng phía sau.\n"
            "- Kết hợp kiểm tra chéo với phương pháp ghost ball ở giai đoạn "
            "đầu luyện tập để hiệu chỉnh độ chính xác.",
        ),
        en=(
            "Connect the farthest point of the object ball (the side away from "
            "the pocket) to the nearest point of the cue ball. This identifies "
            "the contact point directly, without constructing a ghost ball.",

            "1. Find the farthest point on the object ball measured from the "
            "pocket — the point 'behind' the ball, away from the pocket.\n"
            "2. Find the nearest point on the cue ball along its travel "
            "direction.\n"
            "3. The straight line joining those two points is the line the cue "
            "ball's centre must travel; deliver along it.",

            "- It lets the eye fix on concrete points on the ball surfaces "
            "rather than imagining a whole invisible ball — good for players "
            "who prefer clear landmarks.\n"
            "- The 'farthest point' must be measured along the direction the "
            "object ball needs to travel, not just any farthest point.",

            "- Picking the wrong farthest point by reading it along the cue "
            "ball's approach instead of the object ball's required path.\n"
            "- Fixating on the two landmarks and skipping a whole-path sanity "
            "check, which lets error accumulate on thin cuts.",

            "- Always trace the object ball's path to the pocket in your head "
            "first, then take the point diametrically behind it.\n"
            "- Cross-check against ghost ball while learning, to calibrate "
            "accuracy.",
        ),
    ),

    # =========================================================================
    # §5.3 Đầu gậy – mép bi (Tip-to-Edge / CTE)
    # =========================================================================
    item(
        id="kn_aiming_tip_to_edge",
        slug="aiming-tip-to-edge",
        title="Tip-to-Edge Aiming (CTE family)",
        title_vi="Phương pháp đầu gậy – mép bi",
        category="cat_aiming",
        difficulty="advanced",
        tags=["tag_advanced", "tag_aiming", "tag_technique"],
        aliases=["cte", "center to edge", "tip to edge", "đầu gậy mép bi",
                 "pivot"],
        keywords=["CTE", "tip to edge", "pivot", "address position",
                  "hệ thống ngắm"],
        related=["kn_aiming", "kn_aiming_fractional",
                 "kn_aiming_method_selection", "kn_bridge"],
        drills=["THIN_CUT_45", "HALF_BALL_RIGHT", "LONG_POT_1_5M"],
        vi=(
            "Hệ thống ngắm nâng cao dựa trên việc canh vị trí đầu gậy (tip) "
            "tại thời điểm ngắm sơ bộ (address position) thẳng hàng với một "
            "mép cụ thể của bi mục tiêu, sau đó điều chỉnh nhỏ (pivot) để có "
            "đường đánh chính xác. Đây là nguyên lý gốc của các hệ thống ngắm "
            "hiện đại như CTE (Center-to-Edge).",

            "1. Ở tư thế ngắm sơ bộ, đặt trục cơ/đầu gậy thẳng hàng với tâm bi "
            "cái và một mép (trái hoặc phải) của bi mục tiêu.\n"
            "2. Giữ nguyên điểm nhìn đó, sau đó xoay nhẹ cơ thể/cầu tay "
            "(pivot) quanh điểm cầu tay cố định để chuyển sang đường ngắm thực "
            "tế đến điểm tiếp xúc cần thiết.\n"
            "3. Khóa lại tư thế mới và thực hiện cú đánh theo trục đã pivot.",

            "- Đây là hệ thống đòi hỏi độ lặp lại (consistency) rất cao ở cầu "
            "tay và điểm pivot; sai một chút ở bước đầu sẽ khiến cả hệ thống "
            "lệch.\n"
            "- Phù hợp với người chơi đã vững các kỹ thuật cơ bản, không "
            "khuyến khích người mới học ngay từ đầu vì dễ gây rối khi chưa "
            "hiểu ghost ball.",

            "- Điểm pivot (trục xoay) không cố định giữa các cú đánh, làm hệ "
            "thống mất độ tin cậy.\n"
            "- Nhầm lẫn mép bi cần canh ban đầu (trái/phải) tùy theo hướng cắt "
            "bi, dẫn đến pivot sai chiều.",

            "- Cố định vị trí cầu tay làm điểm trục pivot duy nhất, luyện tập "
            "lặp lại nhiều lần trên cùng một cự ly để tạo phản xạ.\n"
            "- Học hệ thống với huấn luyện viên hoặc tài liệu chuyên sâu "
            "(video/sách) vì đây là kỹ thuật có nhiều biến thể (CTE, Pro One, "
            "v.v.) cần hướng dẫn đúng bài bản.",
        ),
        en=(
            "An advanced system: at the address position the cue tip is "
            "aligned with a specific edge of the object ball, then a small "
            "pivot produces the real shot line. This is the principle behind "
            "modern systems such as CTE (Center-to-Edge).",

            "1. At address, align the cue axis with the cue ball's centre and "
            "one edge (left or right) of the object ball.\n"
            "2. Holding that visual, pivot the body/bridge around a fixed "
            "bridge point onto the actual line to the required contact point.\n"
            "3. Lock the new position and deliver along the pivoted axis.",

            "- The system demands very high repeatability of the bridge and "
            "pivot point; a small error at step one throws everything off.\n"
            "- Suited to players with solid fundamentals. It is not "
            "recommended as a first system, since it confuses players who "
            "haven't internalised ghost ball.",

            "- Letting the pivot point vary between shots, which destroys the "
            "system's reliability.\n"
            "- Choosing the wrong starting edge (left vs right) for the cut "
            "direction, so the pivot goes the wrong way.",

            "- Fix the bridge position as the single pivot axis and repeat at "
            "one distance until it becomes reflex.\n"
            "- Learn it from a coach or in-depth material — the family has "
            "many variants (CTE, Pro One and others) that need proper "
            "instruction.",
        ),
    ),

    # =========================================================================
    # §5.4 Ngắm bi sát băng
    # =========================================================================
    item(
        id="kn_aiming_rail_ball",
        slug="aiming-rail-ball",
        title="Aiming Balls Near the Rail",
        title_vi="Ngắm bi sát băng",
        category="cat_aiming",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_aiming", "tag_rail"],
        aliases=["rail ball", "bi sát băng", "bi sat bang", "frozen rail"],
        keywords=["bi sát băng", "rail", "điểm tiếp xúc", "stun", "ngắm"],
        related=["kn_aiming", "kn_aiming_contact_point", "kn_stop_shot",
                 "bridge.rail_bridge"],
        drills=["THIN_CUT_30", "LONG_POT_1M", "STUN_SHOT"],
        vi=(
            "Khi bi mục tiêu nằm sát hoặc gần sát băng, việc dựng ghost ball "
            "đầy đủ khó chính xác vì không gian bị giới hạn; thay vào đó, "
            "người chơi ngắm trực tiếp vào điểm tiếp xúc giữa bi mục tiêu và "
            "băng để xác định hướng bi đi.",

            "1. Xác định điểm mà bi mục tiêu đang tiếp xúc (hoặc gần tiếp xúc) "
            "với băng.\n"
            "2. Từ điểm đó, dựng đường thẳng đến tâm lỗ cần đánh vào — đây "
            "chính là hướng bi mục tiêu cần di chuyển.\n"
            "3. Ngắm bi cái vào điểm đối xứng phía bên kia của bi mục tiêu "
            "(điểm tiếp xúc cần thiết trên bi) sao cho bi mục tiêu bật đi đúng "
            "theo hướng đã dựng.",

            "- Với bi sát băng, biên độ sai số cho phép rất nhỏ — chỉ cần lệch "
            "nhẹ bi mục tiêu dễ đi vào băng thay vì lỗ.\n"
            "- Cần đánh với lực và xoáy hạn chế (thường dùng stun hoặc xoáy "
            "nhẹ) để tránh bi cái nảy ngược vào băng gây khó kiểm soát vị trí "
            "sau đó.",

            "- Ngắm theo thói quen ghost ball thông thường mà không tính đến "
            "việc băng \"che\" một phần góc tiếp cận, dẫn đến chọn sai điểm "
            "chạm.\n"
            "- Dùng lực quá mạnh khiến bi mục tiêu dội ngược từ mép băng thay "
            "vì đi thẳng vào lỗ.",

            "- Luyện riêng bài tập \"rail-ball drill\": đặt bi mục tiêu sát "
            "băng ở nhiều vị trí, tập trung xác định điểm tiếp xúc bi–băng "
            "trước khi ngắm bi cái.\n"
            "- Giảm lực đánh, ưu tiên độ chính xác điểm chạm hơn tốc độ khi xử "
            "lý bi sát băng.",
        ),
        en=(
            "When the object ball sits on or near the rail, a full ghost-ball "
            "construction is hard to place accurately because the space is "
            "constrained. Aim instead at the contact point between object ball "
            "and rail to establish the ball's path.",

            "1. Identify where the object ball touches (or nearly touches) the "
            "rail.\n"
            "2. From that point, draw the line to the target pocket — this is "
            "the direction the object ball must travel.\n"
            "3. Aim the cue ball at the symmetrically opposite point on the "
            "object ball so it departs along that line.",

            "- The margin for error on rail balls is very small; a slight miss "
            "sends the ball into the rail rather than the pocket.\n"
            "- Use restrained power and spin (usually stun or light spin) so "
            "the cue ball doesn't rebound off the rail and cost you position.",

            "- Aiming by ordinary ghost-ball habit without accounting for the "
            "rail blocking part of the approach angle, so the contact point is "
            "wrong.\n"
            "- Hitting too hard, so the object ball rattles off the rail edge "
            "instead of running to the pocket.",

            "- Drill it separately: place object balls along the rail at "
            "various positions and fix the ball–rail contact point before "
            "aiming the cue ball.\n"
            "- Reduce power; on rail balls accuracy of contact matters more "
            "than speed.",
        ),
    ),

    # =========================================================================
    # §5.5 Điểm tiếp xúc trên mặt nỉ
    # =========================================================================
    item(
        id="kn_aiming_cloth_contact",
        slug="aiming-cloth-contact",
        title="Cloth Contact Point Aiming",
        title_vi="Ngắm theo điểm tiếp xúc trên mặt nỉ",
        category="cat_aiming",
        difficulty="intermediate",
        tags=["tag_intermediate", "tag_aiming", "tag_accuracy"],
        aliases=["cloth contact", "điểm tiếp xúc mặt nỉ", "mat ni",
                 "vệt tiếp xúc"],
        keywords=["mặt nỉ", "điểm tiếp xúc", "parallax", "góc cắt", "ngắm"],
        related=["kn_aiming", "kn_aiming_contact_point", "kn_stance",
                 "kn_aiming_method_selection"],
        drills=["THICK_CUT_45", "THIN_CUT_45", "THICK_CUT_60"],
        vi=(
            "Với các bi nằm giữa bàn (không sát băng) và cần cắt góc, một cách "
            "ngắm thay thế là xác định điểm tiếp xúc của bi mục tiêu với mặt "
            "nỉ (điểm thấp nhất bi chạm bàn) làm mốc để xác định hướng bi cần "
            "đi, thay vì chỉ dựa vào mép bi phía trên.",

            "1. Hình dung \"vệt tiếp xúc\" của bi mục tiêu với mặt nỉ (điểm bi "
            "chạm bàn ngay dưới tâm bi).\n"
            "2. Từ điểm đó, dựng đường thẳng nối đến tâm lỗ để xác định hướng "
            "bi mục tiêu cần lăn tới.\n"
            "3. Dùng đường này làm mốc phụ để kiểm tra chéo với điểm ngắm bằng "
            "ghost ball hoặc mép bi, tăng độ chính xác đặc biệt ở góc cắt "
            "trung bình đến hẹp.",

            "- Phương pháp này hữu ích như một điểm tham chiếu bổ sung (không "
            "thay thế hoàn toàn ghost ball) để mắt xác định phương hướng rõ "
            "ràng hơn khi nhìn từ trên xuống.\n"
            "- Hiệu quả rõ nhất khi kết hợp cúi thấp người (stance thấp) để "
            "mắt gần với mặt bàn, dễ quan sát điểm tiếp xúc với nỉ.",

            "- Đứng quá cao khiến khó xác định chính xác điểm tiếp xúc bi–nỉ, "
            "gây sai lệch góc nhìn (parallax).\n"
            "- Chỉ dựa vào một phương pháp duy nhất mà không đối chiếu, dẫn "
            "đến sai số không được phát hiện kịp thời.",

            "- Hạ thấp tư thế ngắm hơn khi cần xác định điểm tiếp xúc với nỉ, "
            "giữ mắt cố định theo trục cơ trước khi đánh.\n"
            "- Luyện thói quen đối chiếu nhanh 2 phương pháp (ghost ball + "
            "điểm tiếp xúc mặt nỉ) trong giai đoạn ngắm sơ bộ để tăng độ tin "
            "cậy.",
        ),
        en=(
            "For balls out in the open that need a cut, an alternative is to "
            "use the object ball's contact point with the cloth — the lowest "
            "point where it rests on the table — as the reference for its "
            "path, rather than reading only the upper edge.",

            "1. Picture the object ball's footprint on the cloth, directly "
            "below its centre.\n"
            "2. From that point draw the line to the pocket centre to fix the "
            "direction the object ball must roll.\n"
            "3. Use that line as a secondary reference to cross-check your "
            "ghost-ball or fractional aim, which sharpens medium-to-thin cuts.",

            "- Treat it as a supplementary reference rather than a replacement "
            "for ghost ball; it gives the eye a clearer sense of direction "
            "when looking down at the table.\n"
            "- It works best from a low stance, with the eyes near the cloth "
            "so the contact point is easy to see.",

            "- Standing too tall, which makes the ball–cloth contact point "
            "hard to locate and introduces parallax error.\n"
            "- Relying on one method without cross-checking, so errors go "
            "unnoticed.",

            "- Drop lower when you need to read the cloth contact point, and "
            "keep the eyes fixed along the cue axis before delivering.\n"
            "- Build the habit of cross-checking both methods (ghost ball plus "
            "cloth contact point) during your address routine.",
        ),
    ),

    # =========================================================================
    # §5.6 Mẹo tổng hợp khi chọn phương pháp ngắm
    # =========================================================================
    item(
        id="kn_aiming_method_selection",
        slug="aiming-method-selection",
        title="Choosing and Combining Aiming Methods",
        title_vi="Chọn và phối hợp các phương pháp ngắm",
        category="cat_aiming",
        difficulty="advanced",
        tags=["tag_advanced", "tag_aiming", "tag_technique"],
        aliases=["chọn phương pháp ngắm", "aiming system", "phối hợp ngắm"],
        keywords=["phương pháp ngắm", "ghost ball", "contact point",
                  "nhất quán", "hệ thống ngắm"],
        related=["kn_aiming", "kn_aiming_fractional",
                 "kn_aiming_contact_point", "kn_aiming_tip_to_edge",
                 "kn_aiming_rail_ball", "kn_aiming_cloth_contact"],
        drills=["THIN_CUT_30", "THIN_CUT_45", "THICK_CUT_30", "THICK_CUT_60"],
        vi=(
            "Tổng hợp các lưu ý thực tế giúp người chơi chọn và phối hợp linh "
            "hoạt các phương pháp ngắm (ghost ball, mép bi, điểm xa–gần, đầu "
            "gậy–mép bi, điểm tiếp xúc băng/nỉ) tùy theo tình huống trên bàn.",

            "1. Với góc cắt nhỏ đến trung bình (gần thẳng), dùng ghost ball "
            "hoặc mép bi vì độ sai số cho phép lớn hơn.\n"
            "2. Với góc cắt hẹp hoặc bi sát băng, ưu tiên phương pháp điểm "
            "tiếp xúc trực tiếp (contact point) vì độ chính xác yêu cầu cao "
            "hơn.\n"
            "3. Luôn xác nhận lại đường ngắm bằng cách nhìn \"ba lần\": nhìn "
            "bi mục tiêu — nhìn điểm tiếp xúc — nhìn lại bi cái, trước khi vào "
            "cơ.",

            "- Không có một phương pháp ngắm nào là tuyệt đối đúng cho mọi "
            "tình huống; nên xem đây là các công cụ bổ trợ lẫn nhau.\n"
            "- Sự nhất quán trong tư thế đầu và mắt quan trọng hơn việc chọn "
            "đúng \"hệ thống ngắm\" nào.",

            "- Học nhiều phương pháp cùng lúc nhưng không luyện sâu phương "
            "pháp nào, dẫn đến ngắm thiếu nhất quán.\n"
            "- Đổi phương pháp ngắm ngay giữa trận đấu khi đang gặp khó khăn, "
            "gây mất nhịp và giảm tự tin.",

            "- Chọn 1 phương pháp chính (thường là ghost ball) làm nền tảng, "
            "chỉ bổ sung các phương pháp khác cho các tình huống đặc biệt (sát "
            "băng, góc hẹp).\n"
            "- Luyện tập từng phương pháp riêng biệt theo từng buổi, tránh "
            "trộn lẫn khi mới học để không gây nhiễu phản xạ ngắm.",
        ),
        en=(
            "Practical guidance for choosing among and combining the aiming "
            "methods — ghost ball, fractions, farthest–nearest, tip-to-edge, "
            "and rail/cloth contact points — according to the situation.",

            "1. For small-to-medium cuts (near straight), use ghost ball or "
            "fractions; the tolerance is larger.\n"
            "2. For thin cuts or rail balls, prefer the direct contact-point "
            "method, since accuracy demands are higher.\n"
            "3. Confirm the line with a 'three-look' check before settling "
            "down: object ball, contact point, then back to the cue ball.",

            "- No single method is right for every situation; treat them as "
            "complementary tools.\n"
            "- Consistency of head and eye position matters more than which "
            "aiming system you pick.",

            "- Learning several methods at once without going deep on any, "
            "producing inconsistent aim.\n"
            "- Switching methods mid-match when things go wrong, which breaks "
            "rhythm and confidence.",

            "- Pick one primary method (usually ghost ball) as your base and "
            "add the others only for special cases — rail balls, thin cuts.\n"
            "- Drill each method in its own session; don't mix them while "
            "learning, or the aiming reflex gets muddled.",
        ),
    ),
]
