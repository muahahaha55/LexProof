# -*- coding: utf-8 -*-
"""DRAFT, NOT HUMAN-REVIEWED. Concrete test situations for the sale group, written from the verbatim
clauses in data/extracted/44-2019-QH14.txt BEFORE they were run against LexProof/Laws/AlcoholSale.lean.

Expected statuses come from reading the clause text, not from the encoding. The atom codes (S04, S02, S14..S20,
P14) and band labels are the vocabulary of the module's tables; they are only the language the situations are
written in.

status of the expectation:  forbidden | required | explicitlyPermitted | clash | noNormApplies
  noNormApplies = "no norm of THIS MODULE applies"; it is never a claim that the act is lawful.
kind: positive | negativeControl | boundary | exception
"""
YOUNG = "chưa đủ 18 tuổi"
ADULT = "từ đủ 18 tuổi trở lên"
LOW = "dưới 15 độ"
HIGH = "từ 15 độ trở lên"
PLACES = ["S14", "S15", "S16", "S17", "S18", "S19", "S20"]

BAN = "ban_ruou_bia"
CUNG = "cung_cap_ruou_bia"
KM = "khuyen_mai_ruou_bia"
QUA = "dung_ruou_bia_lam_qua_khuyen_mai"
MAY = "ban_ruou_bia_bang_may_tu_dong"
KDKP = "kinh_doanh_ruou_khong_phep_hoac_dang_ky"


def ban(age, *on):
    d = {"S04": age}
    d.update({c: ("đúng" if c in on else "sai") for c in PLACES})
    return d


def c(id, act, situation, expected, kind, clause, quote, desc, conf, note="", params=None, near=False):
    return dict(id=id, act=act, situation=situation, params=params if params is not None else {},
                expected=expected, kind=kind, clause=clause, quote=quote, description=desc,
                confidence=conf, note=note, near_miss=near)


Q53 = "Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi"
Q59I = "Khuyến mại trong hoạt động kinh doanh rượu, bia có độ cồn từ 15 độ trở lên"
Q59II = "sử dụng rượu, bia có độ cồn từ 15 độ trở lên để khuyến mại dưới mọi hình thức"
Q511II = "bán rượu, bia bằng máy bán hàng tự động"
Q511I = "Kinh doanh rượu không có giấy phép hoặc không đăng ký"
P0 = {"P14": "sai"}

CASES = [
    # ---------------- Điều 5 khoản 3: bán / cung cấp / khuyến mại cho người chưa đủ 18 tuổi
    c("C01", BAN, ban(YOUNG), "forbidden", "positive", "5.3", Q53,
      "Một cửa hàng tạp hóa (không thuộc loại địa điểm nào ở Điều 19) bán một chai rượu cho một em 16 tuổi.", "high", params=P0),
    c("C02", BAN, ban(ADULT), "noNormApplies", "negativeControl", "5.3", Q53,
      "Cùng cửa hàng tạp hóa bán một chai rượu cho một người 30 tuổi.", "high",
      "Chỉ có nghĩa là khoản này không cấm; không khẳng định việc bán là hợp pháp (còn giấy phép, v.v.).", params=P0),
    c("C03", BAN, ban(YOUNG), "forbidden", "boundary", "5.3", Q53,
      "Cửa hàng tạp hóa bán một chai rượu cho một người 17 tuổi 11 tháng (chưa đủ 18 tuổi).", "high", params=P0),
    c("C04", BAN, ban(ADULT), "noNormApplies", "boundary", "5.3", Q53,
      "Cửa hàng tạp hóa bán một chai rượu cho một người đúng 18 tuổi (vừa đủ 18).", "high", params=P0),
    c("C05", CUNG, {"S04": YOUNG}, "forbidden", "positive", "5.3", Q53,
      "Một người cho không (tặng) một chai rượu cho một em 15 tuổi.", "high"),
    c("C06", CUNG, {"S04": ADULT}, "noNormApplies", "negativeControl", "5.3", Q53,
      "Một người cho không (tặng) một chai rượu cho một người 30 tuổi.", "high"),
    c("C07", CUNG, {"S04": YOUNG}, "forbidden", "boundary", "5.3", Q53,
      "Một người cho không một chai bia cho một người 17 tuổi 11 tháng.", "high"),
    c("C08", CUNG, {"S04": ADULT}, "noNormApplies", "boundary", "5.3", Q53,
      "Một người cho không một chai bia cho một người đúng 18 tuổi.", "high"),
    c("C09", KM, {"S04": YOUNG, "S02": LOW}, "forbidden", "positive", "5.3", Q53,
      "Một cửa hàng khuyến mại (tặng kèm) rượu 10 độ cho một em 16 tuổi.", "high"),
    c("C10", KM, {"S04": ADULT, "S02": LOW}, "noNormApplies", "negativeControl", "5.3", Q53,
      "Một cửa hàng khuyến mại (tặng kèm) rượu 10 độ cho một người 30 tuổi.", "medium",
      "Điều 5 chỉ cấm khuyến mại cho người chưa đủ 18 tuổi hoặc với rượu, bia từ 15 độ; khuyến mại rượu dưới 15 độ cho người lớn không bị cấm bởi Điều 5. "
      "Điều 11 chỉ yêu cầu «tuân thủ» pháp luật về khuyến mại (ngoài lát cắt).", near=True),
    c("C11", KM, {"S04": YOUNG, "S02": LOW}, "forbidden", "boundary", "5.3", Q53,
      "Khuyến mại rượu 10 độ cho một người 17 tuổi 11 tháng.", "high"),
    c("C12", KM, {"S04": ADULT, "S02": LOW}, "noNormApplies", "boundary", "5.3", Q53,
      "Khuyến mại rượu 10 độ cho một người đúng 18 tuổi.", "high"),
    # ---------------- Điều 5 khoản 9: độ cồn từ 15 độ trở lên
    c("C13", KM, {"S04": ADULT, "S02": HIGH}, "forbidden", "positive", "5.9", Q59I,
      "Một cơ sở kinh doanh khuyến mại một loại rượu 40 độ cho một người 30 tuổi.", "high"),
    c("C14", KM, {"S04": ADULT, "S02": HIGH}, "forbidden", "boundary", "5.9", Q59I,
      "Một cơ sở kinh doanh khuyến mại một loại rượu đúng 15 độ cho một người 30 tuổi.", "high"),
    c("C15", KM, {"S04": ADULT, "S02": LOW}, "noNormApplies", "boundary", "5.9", Q59I,
      "Một cơ sở kinh doanh khuyến mại một loại rượu 14,9 độ cho một người 30 tuổi.", "medium",
      "Khoản 9 chỉ cấm từ 15 độ trở lên; dưới 15 độ thuộc Điều 11 (ngoài lát cắt).", near=True),
    c("C16", KM, {"S04": ADULT, "S02": LOW}, "noNormApplies", "negativeControl", "5.9", Q59I,
      "Một cơ sở kinh doanh khuyến mại bia 4,5 độ cho một người 30 tuổi.", "medium",
      "Như C15: dưới 15 độ không bị khoản 9 cấm.", near=True),
    c("C17", KM, {"S04": YOUNG, "S02": HIGH}, "forbidden", "positive", "5.9", Q59I,
      "Khuyến mại rượu 40 độ cho một em 16 tuổi (vi phạm cả hai: tuổi và độ cồn).", "high"),
    c("C18", QUA, {"S02": HIGH}, "forbidden", "positive", "5.9", Q59II,
      "Dùng một chai rượu 40 độ làm quà khuyến mại.", "high"),
    c("C19", QUA, {"S02": HIGH}, "forbidden", "boundary", "5.9", Q59II,
      "Dùng một chai rượu đúng 15 độ làm quà khuyến mại.", "high"),
    c("C20", QUA, {"S02": LOW}, "noNormApplies", "boundary", "5.9", Q59II,
      "Dùng một chai rượu 14,9 độ làm quà khuyến mại.", "medium",
      "Khoản 9 chỉ cấm từ 15 độ trở lên.", near=True),
    c("C21", QUA, {"S02": LOW}, "noNormApplies", "negativeControl", "5.9", Q59II,
      "Dùng một thùng bia 4,5 độ làm quà khuyến mại.", "medium", "Như C20.", near=True),
    # ---------------- Điều 5 khoản 11
    c("C22", MAY, {}, "forbidden", "positive", "5.11ii", Q511II,
      "Một máy bán hàng tự động đặt ở sảnh khu chung cư bán bia lon.", "high"),
    c("C23", BAN, ban(ADULT), "noNormApplies", "negativeControl", "5.11ii", Q511II,
      "Một cửa hàng bán một chai bia cho một người 30 tuổi qua quầy có người bán (không dùng máy tự động).", "medium",
      "Phép thử yếu: phương thức bán nằm trong tên act, không có atom 'bán bằng máy'. Câu hỏi thật là liệu khoản 11 cấm việc này (không).", params=P0),
    c("C24", KDKP, {}, "forbidden", "positive", "5.11i", Q511I,
      "Một người bán rượu mà không có giấy phép kinh doanh rượu.", "high",
      "Nhánh (i) của khoản 11 thuộc nhóm act khác, mô-đun bán/cung cấp/khuyến mại không mã hóa; dự kiến KHÔNG đạt (lỗ hổng phủ)."),
    # ---------------- Điều 19: địa điểm không bán rượu, bia
    c("C25", BAN, ban(ADULT, "S14"), "forbidden", "positive", "19.1", "Cơ sở y tế",
      "Bán một chai rượu cho người 30 tuổi tại một phòng khám đa khoa (cơ sở y tế).", "high", params=P0),
    c("C26", BAN, ban(ADULT), "noNormApplies", "negativeControl", "19.1", "Cơ sở y tế",
      "Bán một chai rượu cho người 30 tuổi tại một cửa hàng tạp hóa cách cổng bệnh viện 50 m.", "medium",
      "Khoản 19.1 chỉ nói «Cơ sở y tế»; cửa hàng bên ngoài không phải cơ sở y tế. Điều 32 khoản 7 (cấm mở mới điểm bán trong bán kính 100 m) có thể áp dụng nhưng ngoài mô-đun.",
      params=P0, near=True),
    c("C27", BAN, ban(ADULT, "S15"), "forbidden", "positive", "19.2", "Cơ sở giáo dục",
      "Bán một chai rượu cho người 30 tuổi trong khuôn viên một trường học vào ngày nghỉ.", "medium",
      "Khoản 19.2 không có điều kiện thời gian (khác Điều 10 khoản 2): đọc theo chữ thì cấm cả ngoài giờ.", params=P0),
    c("C28", BAN, ban(ADULT), "noNormApplies", "negativeControl", "19.2", "Cơ sở giáo dục",
      "Bán một chai rượu cho người 30 tuổi tại một quán nước cách cổng trường 200 m.", "medium",
      "Quán không phải cơ sở giáo dục.", params=P0, near=True),
    c("C29", BAN, ban(ADULT, "S16"), "forbidden", "positive", "19.3",
      "Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi",
      "Bán một chai rượu cho người 30 tuổi tại một khu vui chơi dành cho trẻ em.", "high", params={"P14": "đúng"}),
    c("C30", BAN, ban(ADULT, "S16"), "noNormApplies", "negativeControl", "19.3",
      "Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi",
      "Bán một chai rượu cho người 30 tuổi tại một khu vui chơi giải trí chỉ dành cho người lớn.", "medium",
      "«dành cho người chưa đủ 18 tuổi» là khái niệm mở (luật không định nghĩa): thế nào là khu vực «dành cho» người dưới 18 tuổi?",
      params={"P14": "sai"}, near=True),
    c("C31", BAN, ban(ADULT, "S17"), "forbidden", "positive", "19.4",
      "Cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân và cơ sở giam giữ khác",
      "Bán một chai rượu cho người 30 tuổi tại một trại giam.", "high", params=P0),
    c("C32", BAN, ban(ADULT, "S18"), "forbidden", "positive", "19.5", "Cơ sở bảo trợ xã hội",
      "Bán một chai rượu cho người 30 tuổi tại một cơ sở bảo trợ xã hội.", "high", params=P0),
    c("C33", BAN, ban(ADULT, "S19"), "forbidden", "exception", "19.6", "Nơi làm việc của cơ quan nhà nước, tổ chức chính trị",
      "Bán một chai rượu cho người 30 tuổi tại căng-tin trong trụ sở một ủy ban nhân dân; căng-tin KHÔNG được phép kinh doanh rượu, bia.", "medium",
      "Trường hợp ngoại lệ «trừ ...» không thỏa.", params=P0),
    c("C34", BAN, ban(ADULT, "S19", "S20"), "noNormApplies", "exception", "19.6",
      "trừ địa điểm được phép kinh doanh rượu, bia",
      "Bán một chai rượu cho người 30 tuổi tại căng-tin trong trụ sở một ủy ban nhân dân; căng-tin ĐƯỢC phép kinh doanh rượu, bia.", "low",
      "Cần: (1) liệu «trừ ...» chỉ thu hẹp lệnh cấm hay còn tạo ra quyền bán (người duyệt có thể trả lời «được phép»); "
      "(2) «địa điểm được phép kinh doanh rượu, bia» nghĩa là gì (Điều 15, ngoài lát cắt).", params=P0, near=True),
    c("C35", BAN, ban(ADULT), "noNormApplies", "negativeControl", "19.6", "Nơi làm việc của cơ quan nhà nước, tổ chức chính trị",
      "Bán một chai rượu cho người 30 tuổi tại căng-tin trong văn phòng một công ty tư nhân.", "medium",
      "Công ty tư nhân không thuộc danh sách tổ chức ở khoản 6 (danh sách coi là đóng; slice1-notes G10).", params=P0, near=True),
    c("C36", BAN, ban(YOUNG, "S14"), "forbidden", "positive", "19.1", "Cơ sở y tế",
      "Bán một chai rượu cho một em 16 tuổi tại phòng khám đa khoa (vi phạm cả tuổi và địa điểm).", "high",
      "Cũng là Điều 5 khoản 3.", params=P0),
    c("C37", CUNG, {"S04": ADULT}, "noNormApplies", "negativeControl", "D19H", "Địa điểm không bán rượu, bia",
      "Một người cho không (không bán) một chai rượu cho người 30 tuổi tại một phòng khám.", "low",
      "Tiêu đề Điều 19 chỉ nói «bán»; Điều 5 khoản 3 phủ «cung cấp» chỉ với người chưa đủ 18 tuổi. Việc «cung cấp» cho người lớn tại cơ sở y tế có bị cấm không "
      "là chỗ luật không nói; cần biết liệu «bán» được hiểu rộng bao nhiêu.", near=True),
]

if __name__ == "__main__":
    from collections import Counter
    print(len(CASES), Counter(x["kind"] for x in CASES), Counter(x["expected"] for x in CASES))
