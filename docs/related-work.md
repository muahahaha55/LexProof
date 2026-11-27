# Công trình liên quan (2019–2026) và ý tưởng hướng tiếp

Cập nhật: 2026-11-20. Tệp này **không** phải quyết định (không phải ADR) và không đổi lộ trình. Nó gom tài liệu để viết chương
«Công trình liên quan» của đồ án và để chọn hướng nghiên cứu sau (ASE / NeurIPS 2027).

**Cách làm và giới hạn — đọc trước.**

- Tìm bằng công cụ tìm kiếm paper (arXiv, PubMed/PMC, web), khoảng 2019-01 đến 2026-11. Tôi **chỉ đọc tóm tắt** (abstract),
  không đọc toàn văn. Mỗi dòng «nói gì» bên dưới là tóm tắt lại abstract, không phải đánh giá phương pháp hay kết quả của paper.
- Nhiều paper năm 2026 là **preprint arXiv, chưa qua phản biện**. Nơi đăng chỉ ghi khi đã kiểm (ICFP, ICSE, ESWA, Scientific Data,
  PNAS, NLLP, TACAS). Chưa ghi nơi đăng nghĩa là chưa kiểm, không phải là không có.
- Các con số (độ chính xác, F1…) là con số **do tác giả báo**, trên bộ dữ liệu của họ; không so trực tiếp với nhau được.
- Chắc chắn còn sót. Các dòng nghiên cứu lâu năm (LegalRuleML/DAPRECO, Regorous/Turnip của Governatori, COLIEE) chỉ được nhắc,
  không duyệt kỹ.

## 1. Tóm tắt

1. Hướng «LLM dịch luật → logic, máy giải kiểm» bùng nổ từ 2025: Prolog, SMT (Z3), ASP, Catala, defeasible deontic logic.
   Gần như tất cả tin bộ giải (Prolog/Z3) và đo **độ chính xác trên bài toán áp dụng luật cho một vụ việc**, không phải **mâu thuẫn nội tại** của văn bản.
2. Độ trung thực (faithfulness) của bản dịch hình thức là nút thắt được nhiều nhóm gọi tên năm 2026. Các cách đang nổi:
   so hai bản mã hóa bằng các **ca biên mà chúng bất đồng** (Vernie & Grabmair), **dịch vòng** rồi kiểm tương đương (Amrollahi, Lopez, Barrett),
   hai ngôn ngữ hình thức khác nhau để lỗi không tương quan («contrapuntal languages»), kiểm vacuity cơ học.
3. Phát hiện xung đột chuẩn tắc bằng phương pháp hình thức đã có công cụ trưởng thành ở ngành yêu cầu phần mềm (N-Check, ICSE 2024; LEGOS-SLEEC),
   nhưng trên DSL do người viết, không trên văn bản luật thật, và không có chứng minh kernel.
4. Tiếng Việt: có nhiều bộ dữ liệu hỏi–đáp / truy hồi luật, **không tìm thấy** công trình nào về kiểm nhất quán hình thức của văn bản luật tiếng Việt.
5. Tôi không tìm thấy hệ thống nào kết hợp đủ: (a) kết luận xung đột / nhất quán được **kernel kiểm**, (b) ba giá trị và fail-closed,
   (c) cổng duyệt người bắt buộc trước khi vào phần tin cậy, (d) văn bản luật thật. Đây là chỗ đứng của LexProof — nhưng cũng chính là chỗ yếu:
   phần đóng góp mạnh nhất (soundness) lại là phần các paper khác ít bị chỉ trích nhất; phần các reviewer sẽ hỏi là **faithfulness**.

## 2. Danh mục theo nhóm

Ký hiệu cột «Với LexProof»: ⇒ ý tưởng dùng được; ≈ trùng một phần với cái đã có; ≠ khác hướng (dùng để định vị).

### A. Ngôn ngữ và hệ thống mã hóa luật

| Công trình | Nói gì (theo abstract) | Với LexProof |
|---|---|---|
| Merigoux, Chataing, Protzenko. *Catala: A Programming Language for the Law*. ICFP 2021. [arXiv:2103.03198](https://arxiv.org/abs/2103.03198) | DSL dịch luật thành chương trình; cấu trúc «trường hợp chung / ngoại lệ» theo default logic; các bước biên dịch lõi chứng minh trong F\*; tìm ra lỗi trong cài đặt chính thức trợ cấp gia đình Pháp. | ≈ ngoại lệ và ưu tiên (ADR-0005). ≠ Catala tính toán một kết quả, không tìm mâu thuẫn giữa norm. Mốc so sánh bắt buộc. |
| Monat, Fromherz, Merigoux. *Formalizing Date Arithmetic and Statically Detecting Ambiguities for the Law*. 2024. [arXiv:2403.08935](https://arxiv.org/abs/2403.08935) | Ngữ nghĩa hình thức cho phép tính ngày (cơ giới hóa trong F\*), phân tích tĩnh phát hiện **mơ hồ** trong tính ngày; áp vào Catala trợ cấp nhà ở Pháp. | ⇒ thời hạn / hiệu lực (Level 2, ADR-0006 hoãn thời gian). Mẫu tốt: phát hiện **mơ hồ** như một loại finding riêng. |
| Goutagny, Fromherz, Monat. *CUTECat: Concolic Execution for Computational Law*. 2024. [arXiv:2410.18212](https://arxiv.org/abs/2410.18212) | Thực thi concolic (SMT) cho Catala, xử lý default logic, sinh hàng trăm nghìn ca kiểm phủ mọi nhánh, ca kiểm đọc được bởi luật sư. | ⇒ sinh tình huống để người duyệt đọc (Loop B). |
| Lim, Mahajan, Strecker, Wong. *Automating Defeasible Reasoning in Law*. 2022. [arXiv:2205.07335](https://arxiv.org/abs/2205.07335) | Các «rule modifier» (ghi đè, ngoại lệ) của L4, biến đổi để loại bỏ chúng rồi dịch sang công thức; so SMT với ASP. | ≈ ADR-0005/0013 (ngoại lệ vs ưu tiên). |
| Listenmaa và cs. *An NLG pipeline for a legal expert system* (L4). 2021. [arXiv:2107.02421](https://arxiv.org/abs/2107.02421) | Sinh ngôn ngữ tự nhiên từ mã L4 cho phỏng vấn và giải thích. | ≈ bộ dịch ngược (ADR-0019). |
| Arias và cs. *Automated legal reasoning with discretion to act using s(LAW)*. 2024. [arXiv:2401.14511](https://arxiv.org/abs/2401.14511) | s(CASP) để mô hình hóa quyền tùy nghi và khái niệm mơ hồ, có giải thích. | ≈ ADR-0003 (khái niệm mở là tham số). |
| Benzmüller, Fuenmayor, Lomfeld. *Modelling Value-oriented Legal Reasoning in LogiKEy*. 2020. [arXiv:2006.12789](https://arxiv.org/abs/2006.12789) | Mã hóa lý thuyết cân bằng giá trị pháp lý trong Isabelle/HOL. | ≠ dùng trợ lý chứng minh cho lý thuyết pháp lý, không cho một văn bản. |
| Robaldo, Pozzato. *Conflict-tolerant Deontic Traditional Scheme* (RDF/SPARQL). 2024. [arXiv:2411.19918](https://arxiv.org/abs/2411.19918) | Ontology xử lý **xung đột không giải được** (không bên nào mạnh hơn) giữa nghĩa vụ / cấm / cho phép. | ≈ đúng định nghĩa xung đột của LexProof (CLAUDE.md: «no clear priority»). Trích khi định nghĩa. |
| Nguyen, Satoh. *PYTHEN*. 2026. [arXiv:2603.15317](https://arxiv.org/abs/2603.15317) | Khung Python cho suy luận khả bác, lấy cảm hứng PROLEG. | ≠ |
| Hähnle, Laneve, Veschetti. *Formal Verification of Legal Contracts: A Translation-based Approach* (Stipula → KeY). 2025. [arXiv:2509.20421](https://arxiv.org/abs/2509.20421) | Kiểm hợp đồng Stipula bằng KeY. | ≠ hợp đồng, không phải luật. |
| *LegalLean* (Legal Engine, trang web; **không tìm thấy paper**). [legalengine.co.uk/legal-lean](https://www.legalengine.co.uk/legal-lean/) | Mã hóa luật trong Lean 4; khái niệm mở là kiểu hạng nhất (`RequiresHumanDetermination`, `Vague`); ca IRC §163(h), visa O-1. | ≈ gần nhất về công cụ (Lean 4). Không phải nguồn học thuật; chỉ nêu như công trình song song, cần theo dõi. |

### B. Phát hiện xung đột chuẩn tắc bằng phương pháp hình thức

| Công trình | Nói gì | Với LexProof |
|---|---|---|
| Feng, Marsso, Getir Yaman, …, Chechik. *Analyzing and Debugging Normative Requirements via Satisfiability Checking* (N-Check). ICSE 2024. [arXiv:2401.05673](https://arxiv.org/abs/2401.05673) | Kiểm thỏa mãn để tìm các lỗi «well-formedness» của yêu cầu chuẩn tắc: **xung đột, thừa, quá chặt, thiếu**; chẩn đoán cho người không chuyên; 9 ca nghiên cứu, 233 yêu cầu. | ⇒ **mốc so sánh chính cho ASE**. Danh sách loại lỗi (thừa, quá chặt) LexProof chưa có. ≠ họ dùng DSL do người viết, không có kernel. |
| Getir Yaman và cs. *SLEEC rules* (tock-CSP). 2023. [arXiv:2307.03697](https://arxiv.org/abs/2307.03697) | Ngôn ngữ luật + «defeater», ngữ nghĩa tock-CSP, phát hiện xung đột và thừa. | ≈ defeater ~ ngoại lệ. |
| Kolyakov và cs. *LEGOS-SLEEC*. 2025. [arXiv:2501.12544](https://arxiv.org/abs/2501.12544) | Công cụ cho người liên ngành viết và gỡ lỗi luật SLEEC. | ⇒ mẫu đánh giá tính dùng được với người không chuyên. |
| Kleijwegt, Getir Yaman, Calinescu. *SLEEC-LLM*. 2025. [arXiv:2507.05504](https://arxiv.org/abs/2507.05504) | LLM diễn giải phản ví dụ của model checker thành ngôn ngữ tự nhiên. | ≈ Loop B; ⇒ nhưng giữ diễn giải ngoài vùng tin cậy. |
| Khoja, Kölbl, Leue, Wilhelmi. *ContractCheck*. 2022 [arXiv:2212.03349](https://arxiv.org/abs/2212.03349); 2025 [arXiv:2504.18422](https://arxiv.org/abs/2504.18422) | Kiểm nhất quán hợp đồng mua bán bằng SMT; trả mô hình thỏa mãn hoặc các điều khoản mâu thuẫn. | ≈ cùng bài toán trên hợp đồng. |
| Azzopardi, Pace. *Sound Conflict Analysis for Timed Contract Automata*. 2024. [arXiv:2410.12585](https://arxiv.org/abs/2410.12585) | Thuật toán phát hiện xung đột sound nhưng không complete, có chứng minh đúng, thời gian liên tục. | ⇒ Level 2 / thời gian. Cách nói «sound, not complete» khớp ba giá trị. |
| Olson, Salas-Damian, Forbus. *A Defeasible Deontic Calculus for Resolving Norm Conflicts*. 2024. [arXiv:2407.04869](https://arxiv.org/abs/2407.04869) | Tiên đề hóa phát hiện và giải quyết xung đột, có kế thừa; chỉ ra một chiến lược giải quyết phổ biến là sai. | ⇒ đọc trước khi mở rộng priority (ADR-0013). |
| Piazza, Sabatini. *A logic for default deontic reasoning*. 2025. [arXiv:2512.18824](https://arxiv.org/abs/2512.18824) | Phép tính sequent có «control set» cho chuẩn mâu thuẫn. | ≠ lý thuyết. |
| Engesser, Ciabattoni. *A Simple Doxastic Deontic Logic for Norm-Guided Decision Making*. 2026. [arXiv:2610.00668](https://arxiv.org/abs/2610.00668) | Logic khi chuẩn mâu thuẫn; quy về weighted MaxSAT. | ≠ |
| Mustafa và cs. *What Does ODRL Mean?* (UFO-L, Isabelle/HOL). 2026. [arXiv:2606.24344](https://arxiv.org/abs/2606.24344) | Nền ontology cho permission/prohibition/duty; tiên đề kiểm trong Isabelle và bằng Vampire/E/Z3. | ⇒ chỉ ra «permission» chưa đặc tả rõ (open vs closed world) — đúng chỗ G4 đang mở. |
| Yadamsuren, Platt, Diaz. *LLM-Assisted Formalization Enables Deterministic Detection of Statutory Inconsistency in the Internal Revenue Code*. 2025. [arXiv:2511.11954](https://arxiv.org/abs/2511.11954) | GPT-4o/GPT-5 dịch IRC §121 sang Prolog; LLM thuần chỉ thấy mâu thuẫn ở 1/3 chiến lược; bản Prolog mã hóa **các cách hiểu cạnh tranh** và tìm ra một «vùng mâu thuẫn». | ⇒ **gần LexProof nhất về bài toán**. ≠ một điều luật, Prolog tin cậy, không cổng duyệt. Ý «cách hiểu cạnh tranh» là mầm của Ý tưởng 1. |

### C. LLM dịch văn bản luật sang biểu diễn hình thức

| Công trình | Nói gì | Với LexProof |
|---|---|---|
| Horner, Mateis, Governatori, Ciabattoni. *Toward Robust Legal Text Formalization into Defeasible Deontic Logic using LLMs*. 2025. [arXiv:2506.08899](https://arxiv.org/abs/2506.08899) | Tách văn bản thành đoạn nguyên tử, trích luật deontic, bước tinh chỉnh; thước đo đầy đủ (completeness) chặt hơn; TCP Code Úc. | ≈ Loop A. ⇒ thước đo completeness. |
| Zin, …, Satoh, Nguyen L.M. *Can Legislation Be Made Machine-Readable in PROLEG?* 2026. [arXiv:2601.01477](https://arxiv.org/abs/2601.01477) | Một prompt sinh luật if-then + PROLEG cho GDPR Điều 6, chuyên gia duyệt. | ≈ cổng duyệt người. |
| Nguyen H.T., …, Satoh. *GDPR Auto-Formalization with AI Agents and Human Verification*. 2026. [arXiv:2604.14607](https://arxiv.org/abs/2604.14607) | Đa tác tử sinh tình huống, luật, sự kiện; người duyệt đúng về biểu diễn, logic, pháp lý; kết luận duyệt có cấu trúc là thiết yếu. | ≈ ADR-0011. Có người Việt trong nhóm tác giả — có thể là đầu mối liên hệ. |
| Zin, Fungwacharakorn, Satoh, Nitta. *Structured Four-Stage Legal Translation: From Natural-Language Traffic Rules to PROLOG*. 2026. [arXiv:2609.20334](https://arxiv.org/abs/2609.20334) | Prompt 4 bước (vai nghĩa, hoàn thiện bối cảnh, ánh xạ logic, sinh luật): 75% so với 60% (NL→Prolog), 55% (Logical English). | ⇒ cấu trúc prompt; mẫu nhỏ (20 luật). |
| Chen, Li, Wan, Yuan. *From Statute to Control Flow: Span-Grounded Deontic Trees* (NormBench). 2026. [arXiv:2606.08932](https://arxiv.org/abs/2606.08932) | Gọi tên lỗi **Silent Scope Omission**: LLM áp luật chung mà lặng lẽ bỏ ngoại lệ lồng; biểu diễn trung gian neo mọi nhánh vào span văn bản; hiệu năng giảm mạnh theo độ sâu ngoại lệ. | ⇒ **Ý tưởng 2**. Khớp nguyên tắc «never silently skip a provision». |
| Janatian và cs. *From Text to Structure* (JusticeBot). 2023. [arXiv:2311.04911](https://arxiv.org/abs/2311.04911) | GPT-4 trích pathway; 60% được đánh giá ngang hoặc tốt hơn bản người làm (so mù). | ⇒ mẫu đánh giá so mù. |
| Zitouni và cs. *LLM-Based Generation of Formal Specifications … Symboleo*. 2024. [arXiv:2411.15898](https://arxiv.org/abs/2411.15898) | 38 tổ hợp prompt, 16 loại lỗi chia 3 mức nặng. | ⇒ **bảng phân loại lỗi dịch** cho eval/. |
| Jurayj, Holzenberger, Van Durme. *Language Models and Logic Programs for Trustworthy Tax Reasoning*. 2025. [arXiv:2508.21051](https://arxiv.org/abs/2508.21051) | Dịch trước luật sang Prolog + ví dụ truy hồi; ước lượng chi phí theo tiền phạt thật. | ⇒ ý đo chi phí lỗi. |
| Han, Takashima, Wei, Li, Genesereth. *Law and Order: Tax Law Autoformalization*. 2026. [arXiv:2610.02792](https://arxiv.org/abs/2610.02792) | Hai loại tương ứng: **cấu trúc** (thành phần luật ↔ thành phần ký hiệu) và **ngữ nghĩa**; sửa lỗi cục bộ; đánh giá trên tập giữ lại độc lập. | ⇒ tách «tương ứng cấu trúc» (ClauseRef, ADR-0016) khỏi «tương ứng nghĩa». |
| *Translating Tax Law to Code with LLMs: A Benchmark and Evaluation Framework* (Catala). NLLP 2025. [ACL Anthology 2025.nllp-1.4](https://aclanthology.org/2025.nllp-1.4/) | Benchmark luật thuế ↔ Catala. | ≠ |
| Chen, Cai, Hou, Dong. *L4L: Towards Trustworthy Legal AI through LLM Agents and Formal Reasoning*. 2025. [arXiv:2511.21033](https://arxiv.org/abs/2511.21033); *LexGuard*. 2026. [arXiv:2605.26530](https://arxiv.org/abs/2605.26530) | Tác tử công tố / bào chữa trích lập luận, SMT kiểm nhất quán; LexGuard đo độ nhạy với thay đổi **có / không** liên quan pháp lý. | ⇒ kiểm biến đổi (metamorphic): thêm sự kiện không liên quan không được đổi kết luận. |
| Sadowski, Chudziak. *On Verifiable Legal Reasoning: A Multi-Agent Framework*. 2025. [arXiv:2509.00710](https://arxiv.org/abs/2509.00710) | Tách thu nhận tri thức và áp dụng; biểu diễn trung gian kiểm được. | ≈ |
| Hsia, Yu, Jiang. *Neuro-Symbolic Compliance: LLMs and SMT Solvers for Financial Legal Analysis*. 2026. [arXiv:2601.06181](https://arxiv.org/abs/2601.06181) | LLM sinh ràng buộc SMT; bộ giải tính **sửa đổi sự kiện nhỏ nhất** để hợp pháp; 87 vụ của FSC Đài Loan. | ≠ |
| Heydari, Leowald. *Closing the Loop: Formally Verified Law as a Reward Signal*. 2026. [arXiv:2606.23913](https://arxiv.org/abs/2606.23913) | Autoformalize vào phép tính mở rộng Catala; bộ kiểm làm tín hiệu thưởng cho RL. | ⇒ Ý tưởng 4. |
| Kaewsawee, Silpasuwanchai, Anutariya. *PolicyKG*. 2026. [arXiv:2608.09028](https://arxiv.org/abs/2608.09028) | Phân loại câu thành nghĩa vụ / cho phép / cấm (86,9%), sang SHACL; «Corpus Adapter» neo vị từ vào ontology. | ≈ bảng thuật ngữ (ADR-0027) — cùng ý «neo vị từ vào từ vựng đã duyệt». |

### D. Độ trung thực của bản dịch hình thức (faithfulness)

Đây là nhóm quan trọng nhất cho LexProof, vì CLAUDE.md tách soundness khỏi faithfulness và roadmap ghi «độ trung thực hầu như chưa có bằng chứng».

| Công trình | Nói gì | Với LexProof |
|---|---|---|
| Vernie, Grabmair. *By Their Fruits You Will Know Them: Comparing Formalizations of Law by the Decisions They Encode*. 2026. [arXiv:2605.25186](https://arxiv.org/abs/2605.25186) | So nhiều bản mã hóa cùng một điều khoản **bằng các ca chúng bất đồng** (SAT liệt kê), diễn đạt ca thành tình huống cho chuyên gia; 10 điều khoản EU × 9 LLM; bất đồng hành vi **gần như không tương quan** với giống nhau về cấu trúc; một số bất đồng trùng tranh cãi thật trong bình luận pháp lý. | ⇒ **cơ sở của Ý tưởng 1**. Phải trích và phân biệt rõ. |
| Amrollahi, Lopez, Barrett. *Faithful Autoformalization via Roundtrip Verification and Repair*. 2026. [arXiv:2604.25031](https://arxiv.org/abs/2604.25031) | Mã hóa → dịch ngược → mã hóa lại → kiểm tương đương logic; khi khác, chẩn đoán bước lỗi và sửa có phạm vi; luật Texas. | ⇒ bổ sung cho ADR-0019: dịch ngược hiện cho **người** đọc; có thể thêm vòng mã hóa lại + kiểm tương đương bằng `decide` (miền hữu hạn). |
| Wang và cs. *Know Your Limits: On the Faithfulness of LLMs as Solvers and Autoformalizers in Legal Reasoning*. 2026. [arXiv:2606.16118](https://arxiv.org/abs/2606.16118) | Lỗi «**scope laundering**»: LLM báo kết luận như thể đã chạy bộ giải mà không chạy; khoảng cách giữa diễn giải pháp lý thực dụng và suy diễn hình thức chặt. | ⇒ lý do bảo vệ quyết định «LLM không bao giờ báo kết quả kiểm» (ADR-0011, ADR-0020). |
| Sadowski, Chudziak. *Solving versus Verifying: Catching Contradictions in Tax Reasoning Systems*. 2026. [arXiv:2609.05928](https://arxiv.org/abs/2609.05928) | Mô hình mạnh vẫn tính xuyên qua dữ kiện mâu thuẫn (trả đáp án như đầu vào sạch 63–76%), nhưng khi được hỏi **kiểm tra** thì bắt được phần lớn. | ⇒ baseline rẻ cho Ý tưởng 3. |
| An, Bayless, …, Cook, … *A Neurosymbolic Approach to Natural Language Formalization and Verification* (Automated Reasoning checks, AWS). 2026. [arXiv:2511.09008](https://arxiv.org/abs/2511.09008) | Nhiều lần mã hóa dư thừa, kiểm tương đương ngữ nghĩa giữa chúng; báo >99% soundness. | ⇒ «mã hóa dư thừa + kiểm tương đương» ở quy mô công nghiệp. |
| Dai và cs. *Validating Autoformalized Specifications via Contrapuntal Languages*. 2026. [arXiv:2610.30059](https://arxiv.org/abs/2610.30059) | Lỗi của các mẫu LLM **tương quan** nên bỏ phiếu không đủ; dùng hai ngôn ngữ hình thức không dịch qua lại được để lỗi không tương quan, chỉ chấp nhận khi bộ giải chứng minh hai bản tương đương. | ⇒ cảnh báo cho Ý tưởng 1: k bản từ cùng một mô hình không độc lập. |
| Amster và cs. *claimcheck: Measuring and Improving Specification Faithfulness*. 2026. [arXiv:2610.17358](https://arxiv.org/abs/2610.17358) | Dịch ngược bởi mô hình **không thấy yêu cầu gốc**, mô hình khác phán; thắng việc cho judge xem cả hai. | ⇒ quy tắc cho bộ dịch ngược: không cho thấy văn bản gốc. |
| Zhang và cs. *Beyond Compilation: Evaluating Faithful NL-to-Lean Statement Formalization*. 2026. [arXiv:2606.31002](https://arxiv.org/abs/2606.31002) | Biên dịch được ≠ trung thực (chênh tới 29,5 điểm); phần lớn khoảng chênh của mô hình mạnh là **lỗi của judge**, không phải lỗi dịch. | ⇒ không dùng LLM-judge làm bằng chứng faithfulness. |
| Li và cs. *SemantEq*. 2026. [arXiv:2610.32919](https://arxiv.org/abs/2610.32919) | Kiểm tương đương qua chứng minh dễ «chứng minh quá nhiều»; đề xuất quan hệ chặt hơn, xét proof term. | ≠ toán; ⇒ nhắc rằng «tương đương» phải định nghĩa trên cùng giao diện nguyên tử. |
| Li Z. và cs. *Autoformalize Mathematical Statements by Symbolic Equivalence and Semantic Consistency*. 2024. [arXiv:2410.20936](https://arxiv.org/abs/2410.20936) | Chọn bản tốt nhất trong k ứng viên bằng tương đương ký hiệu + nhất quán ngữ nghĩa. | ≈ |
| Singh và cs. *Beyond Solver Verdicts* (Verdict-Preserving-Unfaithfulness). 2026. [arXiv:2609.11085](https://arxiv.org/abs/2609.11085) | Mã hóa sai vẫn ra **đúng kết luận mong đợi** — kiểm chỉ theo kết luận không phát hiện được. | ⇒ lý do bộ ca kiểm (FR12) không đủ một mình. |
| Mei, Douglas. *Beyond LLM Judge: Mechanical Verification for Agentic Autoformalization*. 2026. [arXiv:2610.20573](https://arxiv.org/abs/2610.20573) | Kết hợp duyệt ngữ nghĩa với kiểm số và **kiểm vacuity** cơ học. | ≈ cờ vacuity của `analyzeReport`. |
| He, …, Henderson. *Statutory Construction and Interpretation for AI*. PNAS 2026 ([doi:10.1073/pnas.2509766123](https://doi.org/10.1073/pnas.2509766123)); arXiv 2025 [2509.01186](https://arxiv.org/abs/2509.01186) | Mơ hồ diễn giải sinh hành vi không ổn định; đo bất đồng giữa một **nhóm người diễn giải hợp lý**; sửa luật mơ hồ để giảm bất đồng. | ⇒ Ý tưởng 1: «tập cách đọc hợp lý» như một đối tượng đo được. |
| Biyani, Dvijotham. *SpecGuard: Proving a Task Is Broken Before the Agent Cheats*. 2026. [arXiv:2610.09159](https://arxiv.org/abs/2610.09159) | Autoformalize ý định và test thành Lean 4 độc lập; kernel Lean kiểm có cài đặt nào thỏa cả hai không, trả **chứng chỉ** khi không. | ≈ cùng kiến trúc «xung đột có chứng chỉ Lean» ở miền khác — dẫn chứng rằng ý tưởng được cộng đồng ML (NeurIPS-type) chấp nhận. |

### E. Benchmark suy luận theo luật / chuẩn tắc

| Công trình | Nói gì | Với LexProof |
|---|---|---|
| Holzenberger, Blair-Stanek, Van Durme. *SARA: A Dataset for Statutory Reasoning in Tax Law*. 2020. [arXiv:2005.05257](https://arxiv.org/abs/2005.05257) | Luật thuế + vụ việc, hệ Prolog viết tay giải trọn. | ≠ áp dụng, không phải nhất quán. |
| Blair-Stanek, Holzenberger, Van Durme. *Can GPT-3 Perform Statutory Reasoning?* 2023. [arXiv:2302.06100](https://arxiv.org/abs/2302.06100) | Kém trên **luật tổng hợp** chưa từng thấy. | ⇒ lý do không dùng LLM làm bộ kiểm. |
| Guha và cs. *LegalBench*. NeurIPS 2023 Datasets & Benchmarks. [arXiv:2308.11462](https://arxiv.org/abs/2308.11462) | 162 tác vụ suy luận pháp lý do giới luật đóng góp. | ≠ mốc tham chiếu chung. |
| Dou và cs. *DeonticBench*. 2026. [arXiv:2604.04443](https://arxiv.org/abs/2604.04443); *DAR*. 2026. [arXiv:2606.05009](https://arxiv.org/abs/2606.05009) | 6.232 tác vụ (thuế, hành lý, di trú, nhà ở), có chương trình Prolog tham chiếu; tốt nhất ~44–47 trên tập khó. | ≠ |
| Kouteili và cs. *DeoGen: Automatic Benchmark Generation for Reasoning over Policies*. 2026. [arXiv:2610.38687](https://arxiv.org/abs/2610.38687) | Sinh benchmark từ cây quyết định; mô hình đúng 89–92% khi đủ thông tin nhưng chỉ 22–40% **biết từ chối** khi thiếu thông tin. | ⇒ ủng hộ kết quả `unknown`: chính LLM yếu ở chỗ này. |
| Ozeki và cs. *Normative Reasoning in LLMs*. 2025. [arXiv:2510.26606](https://arxiv.org/abs/2510.26606) | LLM bất nhất ở một số mẫu suy luận chuẩn tắc, có thiên kiến giống người. | ⇒ dẫn chứng cho phần động cơ. |
| Mantravadi và cs. *LegalWiz*. 2025. [arXiv:2510.03418](https://arxiv.org/abs/2510.03418); Kumar, Roussinov. *GPT-4 to Decode Regulatory Documents*. 2024. [arXiv:2412.20602](https://arxiv.org/abs/2412.20602); Ichida, Meneguzzi. *Detecting Logical Relation in Contract Clauses*. 2021. [arXiv:2111.01856](https://arxiv.org/abs/2111.01856) | Phát hiện mâu thuẫn bằng LLM/NLI, thường trên mâu thuẫn **tiêm nhân tạo**. | ≠ baseline thuần thần kinh cho Ý tưởng 3. |

### F. Xung đột giữa các văn bản (Level 2 — chỉ để định vị, không làm)

| Công trình | Nói gì |
|---|---|
| Italiani, Moro, Ragazzi. *Clash-of-Leges: A bilingual dataset for conflict detection and explanation in statutory law*. Expert Systems with Applications 300 (2026). [doi:10.1016/j.eswa.2025.130182](https://doi.org/10.1016/j.eswa.2025.130182) | 632 cặp xung đột Ý–Anh từ phán quyết Tòa Hiến pháp Ý; phát hiện, giải thích, truy hồi tham chiếu; mô hình mở fine-tune thắng mô hình đóng zero-shot về phát hiện. |
| Zhao và cs. *Bridging the Gap in Chinese Legal Conflict Review: A Dataset, Benchmark Tasks, and Framework*. Scientific Data 2026. [doi:10.1038/s41597-026-07195-2](https://doi.org/10.1038/s41597-026-07195-2) | Xung đột giữa luật cấp trên và cấp dưới ở Trung Quốc. |

Cả hai là **NLP thuần**, nhãn lấy từ phán quyết / thẩm định; không có biểu diễn hình thức. Nếu sau này làm Level 2, đây là dữ liệu đối chứng.

### G. Luật tiếng Việt

| Công trình | Nói gì | Với LexProof |
|---|---|---|
| Bui, Tran. *Vietnamese Legal Ontology: Every legal answer, traced to the article that grounds it*. 2026. [arXiv:2611.11426](https://arxiv.org/abs/2611.11426) | Đồ thị 11,5 triệu nút; 36% câu trả lời có trích dẫn phân giải được trích luật **đã hết hiệu lực**; 2.525 trích dẫn trỏ tới số điều nay nói việc khác; 5.575 số hiệu văn bản trùng giữa nhiều địa phương. | ⇒ **dẫn chứng mạnh cho phần dangling reference** và cho lý do giữ `doc_id` + ngày hiệu lực (ADR-0007). Có thể là nguồn văn bản đã phân tích sẵn. |
| Nguyen D.T. và cs. *ViLegalExpert*. 2026. [arXiv:2609.39189](https://arxiv.org/abs/2609.39189) | 172K câu hỏi tư vấn thật, 34 lĩnh vực. | ≠ |
| Nguyen T.D. và cs. *VLegal-Bench*. 2025/2026. [arXiv:2512.14554](https://arxiv.org/abs/2512.14554) | 10.450 mẫu theo thang Bloom, chuyên gia gán nhãn. | ≠ |
| Nguyen T.M. và cs. *VLQA*. 2025. [arXiv:2507.19995](https://arxiv.org/abs/2507.19995) | Bộ hỏi–đáp luật tiếng Việt. | ≠ |
| Nguyen L.S.T. và cs. *ViHERMES*. 2026. [arXiv:2602.07361](https://arxiv.org/abs/2602.07361) | Hỏi–đáp nhiều bước trên quy định y tế; truy vết sửa đổi, tham chiếu chéo. | ⇒ đồ thị tham chiếu theo đơn vị pháp lý. |
| Nguyen M.C. và cs. *Cross-Lingual Legal QA for Vietnamese Labour Law*. 2026. [arXiv:2609.27376](https://arxiv.org/abs/2609.27376) | Chẩn đoán tự động về **modality, ngoại lệ**, trích dẫn; chẩn đoán tự động không khớp hẳn đánh giá người. | ⇒ một trong ít công trình tiếng Việt quan tâm modality / ngoại lệ. |
| Pham, Nguyen, Do 2022 [arXiv:2209.14494](https://arxiv.org/abs/2209.14494); Vuong và cs. 2023 [arXiv:2306.04841](https://arxiv.org/abs/2306.04841); NeCo@ALQAC 2023 [arXiv:2309.05500](https://arxiv.org/abs/2309.05500); Pham Tien và cs. 2024 [arXiv:2412.00657](https://arxiv.org/abs/2412.00657) | Truy hồi / hỏi–đáp luật tiếng Việt, ALQAC. | ≠ |

**Khoảng trống:** không tìm thấy công trình tiếng Việt nào về mã hóa hình thức điều khoản, phát hiện xung đột nghĩa vụ/cấm/cho phép, hay chứng minh máy.

### H. Chứng chỉ và kiểm bằng kernel (cho phần mở rộng quy mô)

| Công trình | Nói gì | Với LexProof |
|---|---|---|
| Szeider. *Streaming LRAT Certificates into Lean Theorems* (lrat-catcher). 2026. [arXiv:2607.00815](https://arxiv.org/abs/2607.00815) | Biến chứng chỉ UNSAT của SAT solver thành định lý Lean qua bộ kiểm LRAT đã kiểm chứng của Lean core. | ⇒ đường mở rộng quá giới hạn liệt kê (`docs/scaling-analysis.md`). **Xung đột chính sách**: bộ kiểm chạy dạng mã biên dịch, nên định lý phụ thuộc compiler/runtime (cùng loại tin cậy như `native_decide`), bị `#audit_axioms` cấm. Chỉ làm sau một ADR riêng. |
| Manrique, Szeider. *LeanCSP*. 2026. [arXiv:2607.28459](https://arxiv.org/abs/2607.28459); Fichte, Szeider. *count-catcher*. 2026. [arXiv:2610.36196](https://arxiv.org/abs/2610.36196) | Chứng nhận trong Lean kết quả của bộ giải ràng buộc / đếm mô hình. | ⇒ count-catcher: đếm **số tình huống** có xung đột — một thước đo «độ lớn của mâu thuẫn» có chứng chỉ. Cùng lưu ý chính sách. |
| Tan, Heule, Myreen. *cake_lpr*. TACAS 2021. [doi:10.1007/978-3-030-72013-1_12](https://doi.org/10.1007/978-3-030-72013-1_12) | Bộ kiểm chứng chỉ SAT đã kiểm chứng tới mã máy (CakeML). | ≈ ADR-0020 (tìm kiếm không tin cậy, kernel kiểm chứng chỉ). |

## 3. LexProof đứng ở đâu

Theo abstract (không phải đánh giá đầy đủ từng hệ thống):

| | Kết luận được kernel / bộ kiểm đã kiểm chứng kiểm | Tìm mâu thuẫn nội tại | Ba giá trị, fail-closed | Cổng duyệt người trước phần tin cậy | Văn bản luật thật | Tiếng Việt |
|---|---|---|---|---|---|---|
| Catala (+CUTECat) | trình biên dịch (F\*), không phải kết luận | không (tính toán) | không | — | có | không |
| N-Check / LEGOS-SLEEC | không (SAT/SMT tin cậy) | **có** (+ thừa, quá chặt, thiếu) | không rõ | người viết DSL | không | không |
| Yadamsuren và cs. (IRC) | không (Prolog) | **có** | không | không rõ | có, 1 điều | không |
| Vernie & Grabmair | không (SAT) | so hai bản mã hóa | — | chuyên gia đọc ca | có | không |
| Amrollahi và cs. | không (bộ giải) | so bản mã hóa | — | không | có | không |
| SpecGuard | **có** (Lean) | xung đột ý định–test | — | không | không (phần mềm) | không |
| **LexProof** | **có** (Lean, axiom whitelist) | **có** | **có** | **có** (ADR-0011) | có | **có** |

Hàm ý cho bài báo: «kernel-checked» một mình không đủ mới (SpecGuard, LegalLean đã dùng Lean). Cái mới phải nằm ở **faithfulness có bằng chứng**
trên văn bản thật, với chi phí duyệt người đo được.

## 4. Ý tưởng hướng tiếp (xếp theo khuyến nghị)

### Ý tưởng 1 (khuyến nghị chính) — Xung đột lượng hóa trên các cách đọc, và «tình huống phân biệt» có chứng chỉ làm giao diện duyệt

**Vấn đề.** Hiện người duyệt phải đọc bản mã hóa (hoặc bản dịch ngược) và tự thấy chỗ sai. Vernie & Grabmair cho thấy giống nhau về cấu trúc
gần như không nói gì về giống nhau về hành vi; Beyond Compilation và claimcheck cho thấy LLM-judge không thay được người. Trong khi đó,
LexProof đã có một ví dụ thật: ADR-0028 bác được cách đọc «đủ điều kiện cấp phép thì được kinh doanh». Đó là một **lựa chọn diễn giải**,
và hiện nó được xử lý bằng tay, ngoài hệ thống.

**Ý tưởng.** Nâng mơ hồ diễn giải lên thành tham số, giống hệt cách ADR-0003 đã làm với khái niệm mở:

1. Với một khoản, giữ **một tập nhỏ cách đọc** có tên (ví dụ `R1: được-phép-khi-đủ-điều-kiện`, `R2: chỉ-là-điều-kiện-cần`), mỗi cách đọc là một bản mã hóa.
   Tập này do LLM đề xuất và **người duyệt chấp nhận như một tập**, ghi `ClauseRef` nguồn của sự mơ hồ (không tin cậy, như mọi thứ khác).
2. Lean kiểm, trên cùng bảng nguyên tử (ADR-0022), hai việc:
   - hai cách đọc **tương đương** trên miền (`decide`), hoặc trả một **tình huống phân biệt** `s` với định lý «R1 và R2 cho kết quả khác nhau tại `s`»;
   - xung đột **với mọi cách đọc** trong tập (mạnh: «mâu thuẫn bất kể hiểu thế nào trong các cách đã liệt kê») so với xung đột **chỉ dưới một số cách đọc**
     (một nhãn mới, cùng kiểu với `conditionalConflict` cho tham số). Đây là phép mở rộng tự nhiên của `conflict_all_params` / `conditionalConflict_split`.
3. Người duyệt **không đọc mã**: trả lời có / không trên vài tình huống phân biệt (diễn đạt tiếng Việt, ADR-0019). Chọn tình huống chia đôi tập cách đọc
   tốt nhất (kiểu query-by-committee), nên số câu hỏi ~ log₂(số cách đọc).

**Khác gì công trình có sẵn.** Vernie & Grabmair: so các bản do **các LLM khác nhau** sinh ra, bằng SAT (tin cậy), để chuyên gia xem; không gắn vào kết luận xung đột.
Yadamsuren và cs.: mã hóa cách hiểu cạnh tranh trong Prolog cho một điều. Mới ở đây (theo những gì tôi tìm được): (a) cách đọc là **đối tượng hạng nhất được duyệt**,
(b) kết luận xung đột được **lượng hóa ∀/∃ trên cách đọc**, có định lý kernel, (c) đo được **chi phí duyệt** (số câu hỏi, phút, lỗi bắt được) so với đọc mã.

**Vì sao vừa với LexProof.** Không đổi trust boundary: tập cách đọc vẫn qua người duyệt. Không cần Mathlib. Miền hữu hạn ⇒ tương đương là `decide`.
Ba giá trị giữ nguyên, có thêm một nhãn. Loop B đã sẵn hình dạng «tình huống + hai norm + nguồn».

**Rủi ro, phải nói trong báo cáo.** «Với mọi cách đọc» chỉ là mọi cách đọc **đã liệt kê**, không phải mọi cách hiểu có thể có. Bùng nổ tổ hợp nếu nhiều khoản cùng mơ hồ
(tích các tập cách đọc) — cần giới hạn và fail-closed (`unknown`). Các cách đọc do một LLM đề xuất có lỗi tương quan (contrapuntal languages) — nên lấy từ hai nguồn khác nhau.

**Đánh giá đề xuất (ASE).** Giả thuyết H1: với cùng thời gian, người duyệt trả lời tình huống phân biệt bắt được nhiều lỗi dịch hơn người đọc bản dịch ngược
(lỗi tiêm từ toán tử đột biến đã có trong `eval/mutation/`, nên có ground truth). H2: tỉ lệ xung đột «bền với mọi cách đọc» trong các điều đã mã hóa.
Thí nghiệm H1 cần ≥ 2 người duyệt; hiện chỉ có Phong, nên đây là việc cho giai đoạn nghiên cứu, không phải cho đồ án.

**Bước nhỏ đầu tiên (đồ án được).** Lấy đúng cặp Điều 5 / Điều 15 với norm suy ra (ADR-0028): mã hóa hai cách đọc đã thảo luận, cho Lean báo
xung đột nào phụ thuộc cách đọc. Một bảng trong báo cáo, không cần công cụ mới lớn.

### Ý tưởng 2 (rẻ, hợp đồ án) — Bảo chứng độ phủ theo span: chống «bỏ sót im lặng»

NormBench gọi tên lỗi phổ biến nhất của LLM khi dịch luật: lặng lẽ bỏ ngoại lệ lồng (Silent Scope Omission), nặng dần theo độ sâu.
Tiếng Việt có dấu hiệu deontic khá đều về từ vựng («phải», «có trách nhiệm», «không được», «nghiêm cấm», «cấm», «được», «có quyền», «trừ trường hợp», «trừ…»).

- Phần không tin cậy (Python) đánh dấu mọi span có dấu hiệu deontic / ngoại lệ trong khoản.
- Mỗi span phải được nối tới **một norm** hoặc **một mục `notEncoded` có lý do**; span không được nối là một finding, khoản đó không thể `consistentOn`.
- Bộ đánh dấu bỏ sót là chấp nhận được (nó không tin cậy và báo cáo ghi rõ), nhưng không có span nào bị *nối thiếu* mà vẫn qua.

Nó biến «never silently skip a provision» từ quy ước thành một kiểm tra. Đo được ngay trên 141 khoản đã tách: bao nhiêu span không được phủ.

### Ý tưởng 3 (bắt buộc cho mọi bài báo) — Baseline LLM thuần và một bộ dữ liệu tiếng Việt nhỏ có nhãn được chứng minh

Reviewer sẽ hỏi: «sao không hỏi thẳng LLM có mâu thuẫn không?». Cần so trên cùng các khoản: (a) LLM thuần, (b) LLM với «gate» tự kiểm
(Sadowski & Chudziak 2026), (c) LexProof. Đo: xung đột thật bắt được, báo nhầm, tỉ lệ biết trả `unknown` (DeoGen cho thấy LLM yếu đúng chỗ này).
Sản phẩm phụ: bộ dữ liệu xung đột nội tại văn bản luật tiếng Việt đầu tiên (theo tìm kiếm của tôi), nhãn **có định lý Lean** cho phần đã mã hóa và có trạng thái duyệt.
Lưu ý: nhãn chỉ đáng tin bằng chất lượng duyệt; với một người duyệt, phải ghi đó là giới hạn.

### Ý tưởng 4 (dài hạn, hướng NeurIPS) — Kết luận Lean + tình huống đã phân xử làm tín hiệu thưởng

Heydari & Leowald và SpecGuard cho thấy «bộ kiểm hình thức làm reward» đang được chấp nhận. Với LexProof: thưởng cho bộ dịch khi bản mã hóa
(i) qua `analyzeP` không finding, (ii) khớp các tình huống người đã phân xử ở Ý tưởng 1. Rủi ro đã được ghi nhận: «specification hacking»
(Tan 2026, [arXiv:2605.30914](https://arxiv.org/abs/2605.30914)) và «đúng kết luận nhưng sai mã hóa» (Singh và cs. 2026). Không làm trong đồ án.

### Ý tưởng 5 (gác lại) — Vượt giới hạn liệt kê bằng chứng chỉ SAT

Xem nhóm H. Chỉ cân nhắc khi `docs/scaling-analysis.md` cho thấy văn bản thật vượt ngân sách `decide`. Cần một ADR vì đụng chính sách axiom.

### Không nên làm

- Dùng LLM-judge làm bằng chứng faithfulness (Beyond Compilation, claimcheck: judge sai nhiều, nhất là với mô hình mạnh hơn nó).
- Để LLM báo kết quả kiểm thay bộ kiểm (scope laundering, Know Your Limits).
- Bắt đầu Level 2 vì có dữ liệu sẵn (Clash-of-Leges): ngoài phạm vi (ADR-0012).

## 5. Đọc tiếp theo thứ tự ưu tiên

1. Vernie & Grabmair 2026 — trực tiếp cho Ý tưởng 1.
2. Feng và cs. (N-Check) ICSE 2024 — mốc so sánh ASE, danh mục loại lỗi.
3. Yadamsuren và cs. 2025 — cùng bài toán, để định vị.
4. Amrollahi, Lopez, Barrett 2026 — dịch vòng + kiểm tương đương.
5. Chen và cs. (NormBench) 2026 — cho Ý tưởng 2.
6. Bui & Tran (Vietnamese Legal Ontology) 2026 — dangling reference và nguồn văn bản tiếng Việt.
7. Catala 2021 + CUTECat 2024 — mốc bắt buộc trong chương công trình liên quan.
