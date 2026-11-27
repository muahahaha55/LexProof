# Mục tiêu tạp chí Q1: chuẩn, quy trình, khoảng cách

Cập nhật: 2026-11-21. Đây là tài liệu lập kế hoạch, **không** phải quyết định (không phải ADR), không đổi phạm vi kỹ thuật.
Đi kèm [related-work.md](related-work.md).

**Nguồn số liệu.** Quartile và SJR lấy từ SCImago (SJR 2025), tra ngày 2026-11-21. Impact factor và thời gian quyết định đầu tiên
lấy từ trang tạp chí của Springer. Ước lượng của tôi được ghi rõ là ước lượng.

## 0. Kết luận thẳng

1. **LexProof hiện chưa đủ để nộp Q1.** Phần lõi (chứng minh kernel, kiểm axiom, thí nghiệm 410 mutant) ở mức tốt. Nhưng phần bằng chứng
   mới ở mức thử nghiệm ban đầu: một văn bản (44/2019/QH14), 9/141 khoản mã hóa tay, ba điều dịch bằng AI, một người duyệt,
   **chưa có mâu thuẫn nào được chuyên gia xác nhận là có thật trong luật**, và chưa có so sánh với cách làm khác.
2. Riêng soundness thì không đủ để được nhận bài: reviewer mặc định một hệ dùng Lean thì phải sound. Bài sẽ được đánh giá ở
   **faithfulness, quy mô, và việc có tìm ra điều gì đáng kể trong luật thật hay không**.
3. Tạp chí hợp nhất: **Artificial Intelligence and Law** (Springer). Lưu ý: tạp chí này là Q1 ở nhóm *Law* nhưng Q2 ở nhóm *Artificial Intelligence*.
   Phải kiểm quy định của trường bạn tính quartile thế nào (mục 1).
4. Nút thắt không phải mã. Nút thắt là **người có chuyên môn luật** gán nhãn độc lập, và **viết bằng tiếng Anh**.
5. ASE và NeurIPS (đang ghi trong CLAUDE.md) là **hội nghị**. Phần lớn quy định tính «bài Q1» chỉ tính bài **tạp chí**. Cần chọn một trong hai lộ trình (mục 6).

## 1. «Q1» nghĩa là gì — cần chốt trước

- Có **hai hệ** xếp hạng: **SJR** (SCImago, dữ liệu Scopus, miễn phí) và **JCR** (Clarivate, Web of Science, có phí).
  Cùng một tạp chí có thể Q1 ở hệ này mà Q2 ở hệ kia.
- Quartile tính **theo từng nhóm ngành**. Một tạp chí nằm ở nhiều nhóm có thể Q1 ở nhóm này và Q2 ở nhóm khác. Nhiều nơi lấy «best quartile», có nơi lấy nhóm đúng ngành của bạn.
- Quartile **đổi theo năm**. Ví dụ: TOSEM là Q2 (Software) giai đoạn 2016–2020, rồi Q1 từ 2021.
- **Rủi ro cụ thể với AI & Law:** theo một trang tra cứu WoS bên thứ ba (wos-journal.info, chưa đối chiếu với JCR gốc), trong Web of Science
  tạp chí này được xếp ở nhóm *Computer Science, Artificial Intelligence* (SCIE), **không thấy nhóm Law**. Nếu đúng, thì theo JCR
  «Q1 nhóm Law» không tồn tại, và quartile của nó là quartile trong nhóm AI (chưa kiểm). Cần tra JCR qua thư viện trường.
- **Việc của bạn:** hỏi khoa / trường / quỹ (nếu có, ví dụ NAFOSTED) xem họ dùng SJR hay JCR, «best quartile» hay nhóm ngành, và lấy năm nào.
  Câu trả lời quyết định AI & Law có được tính Q1 hay không.

## 2. Tạp chí ứng viên

| Tạp chí | SJR 2025 (quartile theo nhóm) | Hợp với LexProof | Họ coi trọng gì |
|---|---|---|---|
| **Artificial Intelligence and Law** (Springer) | 0,905. Law **Q1**, Artificial Intelligence **Q2**. IF 5,3 (2025). Trung vị nộp → quyết định đầu: 6 ngày. Hybrid | **Cao nhất.** Phạm vi ghi rõ «formal or computational models of legal knowledge, reasoning». Cộng đồng ICAIL/JURIX quen deontic logic, defeasibility, open texture | Nền tảng lý thuyết pháp lý (khái niệm xung đột, lex specialis, diễn giải), đúng với luật, có thảo luận về diễn giải |
| **ACM TOSEM** | Software **Q1** | Trung bình–cao, nếu viết thành bài *kỹ thuật phần mềm*: phương pháp + công cụ + đánh giá thực nghiệm | Câu hỏi nghiên cứu rõ, đánh giá đủ lớn, baseline, threats to validity, gói tái lập |
| **IEEE TSE** | 1,568, Software **Q1** | Như TOSEM | Như TOSEM. Có tiền lệ cùng loại: kiểm tuân thủ GDPR (Amaral Cejas và cs., TSE 2023) |
| **Empirical Software Engineering** (Springer) | 0,920, Software **Q1**. IF 3,4. Trung vị quyết định đầu: 24 ngày. Có track journal-first | Cao **nếu** bài là thí nghiệm có người (ví dụ: cách duyệt nào bắt được nhiều lỗi dịch hơn) | Thiết kế thí nghiệm, số người tham gia, thống kê, đạo đức nghiên cứu |
| **Information and Software Technology** (Elsevier) | 1,054, Software **Q1**, Information Systems **Q1** | Trung bình. Dễ hơn TOSEM/TSE | Như trên, bớt khắt khe |
| **Expert Systems with Applications** (Elsevier) | 1,939, **Q1** cả ba nhóm (AI, CS Applications, Engineering) | Trung bình. Hợp nếu bài nặng về hệ thống và so sánh định lượng | Nhiều mô hình và baseline, bảng số. Clash-of-Leges đăng ở đây (2026) |
| **Knowledge-Based Systems** (Elsevier) | 1,753, **Q1** | Trung bình | Như ESWA |
| **Computer Law & Security Review** (Elsevier) | 1,052, **Q1** cả ba nhóm (gồm Law) | Thấp cho bài công cụ. Họ đọc góc chính sách và pháp lý | Lập luận pháp lý và chính sách |

Không phải Q1 (SJR 2025), dù đúng chuyên môn: **Requirements Engineering** (Springer) Q2; **Journal of Automated Reasoning** Q3.
Nhiều tạp chí phương pháp hình thức xếp hạng thấp hơn mức uy tín thật trong giới. Nếu mục tiêu là Q1, đừng chọn theo uy tín chuyên ngành.

## 3. Bài Q1 trong mảng này đang ở tầm nào

| Bài | Nơi đăng | Quy mô bằng chứng | Điểm khiến bài được nhận (theo tóm tắt) |
|---|---|---|---|
| Amaral Cejas, Azeem, Abualhaija, Briand. *NLP-based Automated Compliance Checking of DPAs against GDPR* | IEEE TSE 2023 (Q1) | 30 thỏa thuận thật, 750 vi phạm thật; bộ yêu cầu và bảng thuật ngữ làm **cùng chuyên gia luật** | Precision 89,1%, recall 82,4%; hơn baseline 20 điểm; đo cả công sức kiểm tay |
| Italiani, Moro, Ragazzi. *Clash-of-Leges* | ESWA 2026 (Q1) | 632 cặp xung đột có nhãn từ phán quyết của tòa; hai ngôn ngữ; khoảng 10 mô hình và bộ truy hồi | Bộ dữ liệu mới, ba tác vụ, so mở với đóng, đánh giá factuality |
| Zhao và cs. *Chinese Legal Conflict Review* | Scientific Data 2026 | Bộ dữ liệu xung đột luật cấp trên – cấp dưới, kèm các tác vụ benchmark | Tài nguyên mới cho một ngôn ngữ / hệ thống pháp luật chưa có |
| Merigoux, Chataing, Protzenko. *Catala* | ICFP 2021 (PACMPL) | Luật thuế Mỹ §121, trợ cấp gia đình Pháp | **Tìm ra lỗi trong cài đặt chính thức.** Một phát hiện thật đáng giá hơn mọi con số |
| Feng và cs. *N-Check* | ICSE 2024 (hội nghị, mốc của ngành SE) | 9 ca nghiên cứu, 233 yêu cầu, 62 lỗi; các nhóm liên ngành (luật, đạo đức, kỹ sư) dùng công cụ | Người không chuyên dùng được, và tìm được lỗi |

**Mẫu số chung** (dùng làm danh sách kiểm, khớp với *ACM SIGSOFT Empirical Standards*, Ralph và cs. 2020,
[arXiv:2010.03525](https://arxiv.org/abs/2010.03525)):

1. Một khoảng trống được nêu sắc, có câu hỏi nghiên cứu (RQ) và định vị so với các bài 2025–2026.
2. Dữ liệu thật ở quy mô có ý nghĩa: hàng trăm đơn vị, không phải vài chục.
3. **Ground truth độc lập**: ít nhất hai người có chuyên môn, gán nhãn tách biệt, có chỉ số đồng thuận (Cohen's / Fleiss' kappa) và quy trình xử lý bất đồng.
4. **Baseline**: so với cách làm hiển nhiên (ở đây là hỏi thẳng LLM).
5. **Một phát hiện có ý nghĩa** (lỗi thật, mơ hồ thật, mâu thuẫn thật được chuyên gia xác nhận), hoặc một kết quả âm được lập luận chặt.
6. Gói tái lập (mã, dữ liệu, script, DOI qua Zenodo) và một mục *threats to validity* trung thực.

## 4. LexProof so với chuẩn

| Tiêu chí | Q1 cần | LexProof hiện tại | Khoảng cách |
|---|---|---|---|
| Soundness | được mặc định | **Mạnh**: định lý G1.x, `#audit_axioms`, `#audit_encapsulation`, 410 mutant với 0 bất đồng giữa Lean / Python / `analyzeP` | Không — đây là điểm mạnh, nhưng tự nó chưa phải đóng góp |
| Định vị / tính mới | khẳng định rõ, khác các bài 2025–2026 | Chưa viết; nhiều bài gần (Yadamsuren 2025, Vernie & Grabmair 2026, SpecGuard 2026, LegalLean) | **Lớn**. Xem Ý tưởng 1 trong related-work.md |
| Quy mô dữ liệu | hàng trăm khoản, nhiều văn bản | 1 văn bản, 141 khoản đã tách, 9 khoản mã hóa tay, 3 điều dịch AI | **Lớn** |
| Ground truth | ≥ 2 người độc lập + kappa | 1 người duyệt (Phong); phiếu 37 ca là đồng thuận với bản nháp AI (thiên lệch neo) | **Lớn**, và là chỗ reviewer đánh mạnh nhất |
| Phát hiện thật | có, hoặc kết quả âm chặt | Chưa có mâu thuẫn nào được xác nhận là của luật; 3 cặp từ norm suy ra (ADR-0028) đang chờ duyệt | **Lớn** |
| Baseline | ≥ 2–3 | Không có | Trung bình (làm được trong vài tuần) |
| Faithfulness | có bằng chứng định lượng | Có công cụ (dịch ngược, phiếu, sha256), chưa có số đo | Lớn |
| Tái lập | gói + DOI | Rất tốt về quy trình (report chỉ sinh bằng `report.py`, ghim sha256) | Nhỏ |
| Viết | tiếng Anh học thuật, 25–40 trang | Tài liệu tiếng Việt, chi tiết | Trung bình |

## 5. Quy trình nộp một bài tạp chí

1. **Chọn tạp chí trước khi viết.** Đọc *Aims & Scope* và 5–10 bài gần đây của đúng tạp chí đó, rồi viết theo khuôn của họ
   (độ dài, cấu trúc, cách trình bày đánh giá).
2. **Chuẩn bị hồ sơ:** bản thảo theo template; cover letter (khoảng trống, đóng góp, vì sao hợp tạp chí); *highlights* (với Elsevier);
   tuyên bố dữ liệu / mã; gói tái lập; ORCID của mọi tác giả; danh sách reviewer gợi ý và xung đột lợi ích.
3. **Desk review:** biên tập viên đọc lướt và có thể trả bài ngay nếu lệch phạm vi hay quá mỏng. Thời gian *đến quyết định đầu tiên*
   rất ngắn (AI & Law: trung vị 6 ngày; EMSE: 24 ngày) — con số này gồm cả các bài bị trả từ vòng biên tập, không phải thời gian phản biện.
4. **Phản biện:** thường 2–3 reviewer. Kết quả hay gặp nhất ở bài được nhận cuối cùng là *major revision* trước.
5. **Sửa và thư trả lời:** trả lời **từng ý** của reviewer, chỉ rõ chỗ đã sửa trong bản thảo. Thường có 1–2 vòng.
6. **Chấp nhận → bản in thử → xuất bản.** Theo ước lượng của tôi, với tạp chí SE và AI & Law, tổng thời gian từ nộp đến chấp nhận
   thường từ vài tháng đến hơn một năm. Tôi không có số liệu đã kiểm cho từng tạp chí.
7. **Chi phí:** các tạp chí trên đều *hybrid* hoặc thuê bao, nên đăng không mất phí. Chọn open access thì có phí (APC).

Điều kiện hay bị quên:
- **Dùng AI khi viết:** Springer, Elsevier, ACM, IEEE đều yêu cầu khai báo việc dùng AI tạo sinh, và **không cho AI đứng tên tác giả**.
  Với LexProof còn có thêm: LLM là một thành phần của phương pháp, phải mô tả đúng mô hình, phiên bản, prompt, ngày chạy.
- **Người tham gia nghiên cứu:** nếu chuyên gia luật hay sinh viên luật gán nhãn hoặc tham gia thí nghiệm, nhiều nơi yêu cầu chấp thuận đạo đức
  hoặc ít nhất là văn bản đồng ý tham gia. Hỏi trường.
- **Preprint:** các nhà xuất bản trên thường cho phép đăng arXiv trước, nhưng hãy kiểm chính sách của tạp chí đã chọn.
- **Bài mở rộng từ hội nghị:** nhiều tạp chí nhận, với điều kiện có phần mới đáng kể. Tỉ lệ cụ thể tùy tạp chí.

## 6. Hai lộ trình, và khuyến nghị

**Lộ trình A — thẳng vào tạp chí (khuyến nghị).** Bài P1 nộp *Artificial Intelligence and Law*.

> Tên làm việc: *Interpretation-aware, kernel-certified detection of normative conflicts in Vietnamese statutes.*
>
> - Đóng góp 1 (mô hình hình thức): norm, ngoại lệ, ưu tiên có hướng, khái niệm mở **và các cách đọc** là tham số; kết quả ba giá trị;
>   các định lý liên kết (đã có, cộng phần ∀/∃ theo cách đọc).
> - Đóng góp 2 (phương pháp): đường dịch có LLM nhưng có cổng duyệt người; tình huống phân biệt có chứng chỉ làm giao diện duyệt.
> - Đóng góp 3 (thực nghiệm, tiếng Việt):
>   - RQ1: trên N văn bản, có bao nhiêu ứng viên xung đột, và bao nhiêu được chuyên gia xác nhận?
>   - RQ2: bao nhiêu xung đột phụ thuộc cách đọc?
>   - RQ3: so với LLM thuần và LLM có bước tự kiểm thì sao?
>   - RQ4: độ trung thực và chi phí duyệt (số đột biến bị bắt, số phút trên mỗi khoản)?

**Lộ trình B — hội nghị trước (ASE / ICAIL / JURIX), mở rộng thành tạp chí sau.** Phản hồi nhanh hơn. Nhưng bài hội nghị thường không tính là Q1,
và vẫn phải làm thêm nhiều mới mở rộng được thành bài tạp chí. Chỉ chọn nếu cần một bài sớm để lấy góp ý.

**Bài thứ hai (tùy chọn):** P2 nộp *Empirical Software Engineering* — thí nghiệm có kiểm soát: người duyệt đọc bản dịch ngược hay trả lời tình huống phân biệt,
cách nào bắt được nhiều lỗi dịch tiêm vào hơn. Cần khoảng 10–20 người tham gia (ước lượng của tôi), ví dụ sinh viên luật. Nó tái dùng các toán tử đột biến đã có.

### Mức tối thiểu tôi đề xuất trước khi nộp P1 (ước lượng, không phải quy định của tạp chí)

| Hạng mục | Mức |
|---|---|
| Văn bản | ≥ 3 luật, khác lĩnh vực (giữ 44/2019/QH14, thêm 2 luật có nhiều nghĩa vụ / cấm) |
| Khoản | ≥ 300 khoản qua pipeline; ≥ 100 khoản được người duyệt đầy đủ |
| Người gán nhãn | ≥ 2 người có chuyên môn luật, **độc lập**, không thấy bản nháp AI khi gán; báo kappa và cách xử lý bất đồng |
| Baseline | LLM thuần; LLM + bước tự kiểm; nếu kịp, một pipeline Prolog/Z3 kiểu Yadamsuren 2025 |
| Phát hiện | các xung đột / mơ hồ được xác nhận, mỗi cái có trích điều khoản; nếu không có thì là kết quả âm có lập luận |
| Gói tái lập | repo công khai + DOI Zenodo, kèm phiên bản LLM và prompt |
| Đồng tác giả luật | nên có ít nhất một người. Reviewer của AI & Law sẽ hỏi ai bảo đảm phần pháp lý đúng |

### Rủi ro thời gian

Phần chiếm thời gian là tuyển người gán nhãn và cho họ gán, không phải viết mã. Nếu đồ án tốt nghiệp có hạn trước khoảng giữa năm 2027,
thì thực tế là: **đồ án dùng bằng chứng hiện có cộng phần mở rộng nhỏ; bài Q1 là việc sau tốt nghiệp.** Theo ước lượng của tôi,
bài có thể được chấp nhận sớm nhất vào năm 2028. Muốn sớm hơn thì phải có người gán nhãn ngay từ bây giờ.

## 6b. Mục tiêu đã chốt (2026-11-21): bài để apply NUS, không vội

- **Ưu tiên cao nhất là bài tạp chí** (lộ trình A). Hội nghị (ASE, ICAIL, JURIX) chỉ là phụ, dùng để lấy góp ý; không để bài hội nghị chiếm dữ liệu hay kết quả mà bài tạp chí cần.
- Thứ tự: **Q1 nhóm Law trước** (Artificial Intelligence and Law), Q1 nhóm AI để sau.
- Hội đồng tuyển sinh NUS School of Computing **không chấm theo quartile**. Hồ sơ PhD (by Research) gồm Statement of Purpose, CV,
  bảng điểm, **hai thư giới thiệu học thuật**, TOEFL ≥ 90 iBT hoặc IELTS ≥ 6.0; GRE không bắt buộc nhưng được khuyến khích; học bổng
  yêu cầu tối thiểu hạng 2nd Class Upper hoặc tương đương (trang tuyển sinh SoC, tra 2026-11-21). Một bài là tác giả chính trong đúng
  mảng của người hướng dẫn tương lai, cộng thư giới thiệu nói cụ thể bạn đã làm gì, có sức nặng hơn con số Q1.
- **Người hướng dẫn hợp nhất đã tìm thấy:** GS. Jin Song Dong (NUS SoC). Hướng nghiên cứu của ông gồm «formal methods with LLM agents»
  và «trusted AI». Nhóm ông có L4L ([arXiv:2511.21033](https://arxiv.org/abs/2511.21033)) và LexGuard ([arXiv:2605.26530](https://arxiv.org/abs/2605.26530)):
  LLM + SMT cho suy luận pháp lý, đều đã có trong [related-work.md](related-work.md). Ở NUS còn có trung tâm TRAIL bên NUS Law
  (thiên về chính sách và pháp lý). Bài P1 nên trích và so sánh trực tiếp với L4L / LexGuard: đó là phần người đọc ở NUS sẽ nhìn đầu tiên.
- Gán nhãn: để giảm số người cần thiết, có thể cho **khoảng 20–30% khoản gán đôi** để tính kappa, phần còn lại một người gán, một người có chuyên môn
  cao hơn phân xử bất đồng. Phong có thể là một trong hai người **nếu** gán mà không thấy bản nháp AI. Tỉ lệ này là đề xuất của tôi, không phải chuẩn.

## 7. Câu hỏi cần bạn trả lời để chốt hướng

1. Trường / quỹ tính Q1 theo SJR hay JCR, best quartile hay nhóm ngành? (Quyết định AI & Law có được tính Q1 không.)
2. Cần bài Q1 **trước** khi tốt nghiệp, hay sau cũng được?
3. Có tuyển được ít nhất 2 người có chuyên môn luật gán nhãn độc lập không (ngoài Phong)? Có ai đồng ý làm đồng tác giả không?
4. ~~Giữ mục tiêu ASE / NeurIPS trong CLAUDE.md, hay đổi sang lộ trình A?~~ Đã trả lời 2026-11-21: tạp chí là ưu tiên cao nhất (lộ trình A).
