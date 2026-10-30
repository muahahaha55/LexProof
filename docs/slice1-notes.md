# Ghi chú lát cắt 1 — Điều 2, 5, 10, 12, 13, 19 của Luật 44/2019/QH14

> ## ⚠ BẢN NHÁP DO AI — DÀNH CHO NGƯỜI DUYỆT, KHÔNG PHẢI SỰ THẬT NỀN
>
> Mọi nhận định ở đây (chủ thể, hành vi, loại, điều kiện, ngoại lệ, đa nghĩa,
> độ tin cậy, đề xuất từ vựng, act, tham số) là **suy luận của AI từ chữ của
> văn bản**. Chưa ai kiểm. Chỗ nào văn bản không nói, tôi ghi **"không rõ"** chứ
> không đoán.
>
> Không có dòng Lean nào được viết hoặc đề xuất trong tài liệu này. Tên act,
> tên fact, tên tham số ở các mục B và C chỉ là **nhãn để người duyệt đọc**.

**Nguồn văn bản**: `data/extracted/44-2019-QH14.txt`, trích từ
`data/raw/congbao-559-560-44-2019-QH14.pdf` (Công báo Số 559 + 560, 17-7-2019).
Xuất xứ và hash: [`../data/README.md`](../data/README.md). Phân loại cấp điều:
[`corpus-triage.md`](corpus-triage.md).

---

## Cách đọc

- **Dòng** = số dòng trong `data/extracted/44-2019-QH14.txt`, đếm từ 1.
- **Trích** nối các dòng bị ngắt của cùng một khoản bằng một dấu cách và **giữ
  nguyên chữ**, kể cả số khoản/điểm ở đầu. Các dòng chạy trang của Công báo
  (`CÔNG BÁO/Số 559 + 560/…`) **không** nằm trong khoảng dòng nào được trích.
  Một script đã so từng trích dẫn với khoảng dòng của nó (xem mục 0.3).
- Mỗi khoản/điểm có 14 trường. `—` = không áp dụng. `không rõ` = văn bản không
  nói. `ngầm` = không có trong chữ, tôi suy từ tiêu đề hoặc ngữ pháp.
- Loại: **cấm** (prohibition) · **nghĩa vụ** (obligation) · **cho phép**
  (permission) · **định nghĩa** · **chính sách** · **phân công** (authority or
  responsibility assignment) · **khác**. Chỗ có thể đọc thành hai loại tôi ghi
  **"ranh giới"** và giải thích.
- Độ tin cậy chỉ chấm cho trường (3)–(7): **cao / trung bình / thấp**, kèm vài
  chữ làm căn cứ.

### Số dòng phân tích

Một "dòng phân tích" là một khoản, một điểm, hoặc một tiêu đề/đoạn dẫn có mang
nội dung quy phạm. Tiêu đề điều được tách riêng ở các điều mà **loại quy phạm
hoặc điều kiện phạm vi nằm ở tiêu đề** (5, 10, 12, 13, 19).

| Điều | Tiêu đề / dẫn | Khoản, điểm | Tổng |
|---|---|---|---|
| 2 | 1 (kèm đoạn dẫn) | 8 | **9** |
| 5 | 1 | 13 | **14** |
| 10 | 1 | 7 | **8** |
| 12 | 1 | 1 (k.1) + 1 (k.2 dẫn) + 2 (2.a, 2.b) + 1 (k.3 dẫn) + 4 (3.a–d) + 3 (k.4, k.5, k.6) = 12 | **13** |
| 13 | 1 | 1 (đoạn dẫn) + 2 | **4** |
| 19 | 1 | 6 | **7** |
| **Cộng** | | | **55** |

---

## 0. Đối chiếu trích xuất với PDF

### 0.1 So ba chế độ trích văn bản (bằng máy)

Ba chế độ `pdftotext` (`-layout`, `-raw`, mặc định) trên cùng bản Công báo; bỏ
dòng chạy trang, chuẩn hóa khoảng trắng và NFC, rồi so từng điều.

| Điều | `-layout` (= file trích xuất) so với `-raw` | `-layout` so với mặc định |
|---|---|---|
| 5, 10, 12, 13, 19 | **giống hệt** | **giống hệt** |
| 2 | **khác 2 chỗ** (bên dưới) | giống hệt |

Hai khác biệt ở Điều 2 trong chế độ `-raw`, **cả hai đều không phải khác biệt
của chữ luật**:

1. Khoản 3: `-raw` ra `C2 H5 OH`, `-layout` ra `C2H5OH`. Ảnh PDF là
   C₂H₅OH với chỉ số dưới; file trích xuất mất định dạng chỉ số dưới nhưng
   không mất ký tự.
2. Giữa khoản 4 và khoản 5, `-raw` chèn khối chữ ký số của Cổng TTĐT Chính phủ
   (`Ký bởi: Cổng Thông tin điện tử Chính phủ … Thời gian ký: 25.07.2019 …`).
   Đó là dấu chữ ký in ở đầu trang 1 của PDF, bị xuất ra cuối văn bản trang đó
   khi đọc theo thứ tự nội dung.

**Giới hạn**: cả ba chế độ đọc **cùng một lớp văn bản** của PDF. Chúng phát hiện
được lỗi do cách xếp dòng, nhưng **không** phát hiện được một lỗi nằm sẵn trong
lớp văn bản.

### 0.2 So với ảnh trang PDF (bằng mắt, độc lập với lớp văn bản)

Tôi đã dựng ảnh các trang PDF chứa sáu điều và đọc đối chiếu: trang 1–3
(Điều 2, Điều 5), trang 5–7 (Điều 10, 12, 13), trang 9 (Điều 19).

- **Không thấy khác biệt nào về chữ, số hay dấu thanh** giữa file trích xuất và
  ảnh trang, ở cả sáu điều.
- Chỉ khác về **trình bày**: chỉ số dưới của C₂H₅OH; chữ nghiêng của các thuật
  ngữ được định nghĩa (*Rượu*, *Bia*, …) không còn trong văn bản thuần.
- Không có khoản nào bị ngắt giữa chừng bởi sang trang. Điều 2 chuyển trang
  (Công báo tr.39 → tr.40) đúng ở ranh giới giữa khoản 4 và khoản 5.
- Một đặc điểm **của bản gốc**, không phải lỗi trích xuất: ở Điều 10 khoản 6 và
  Điều 19 khoản 6 có "tổ chức chính trị - xã hội, tổ chức chính trị xã hội -
  nghề nghiệp" — cụm thứ hai **thiếu gạch nối** giữa "chính trị" và "xã hội".
  Ảnh PDF cũng như vậy. Tôi không sửa.

**Giới hạn**: đây là một AI đọc ảnh, **không phải** so từng ký tự hay từng điểm
ảnh; có thể sót một dấu thanh lẻ. Người duyệt phải đọc lại các điều được mã hóa
trên PDF gốc. Tôi **không** so với bản Word/HTML (chưa lấy được bản nào) và
**không** so với bản của bên xuất bản khác.

### 0.3 Kiểm tra trích dẫn trong tài liệu này

Sau khi viết, một script đã so mọi khối **Trích** với đúng khoảng **Dòng** của nó
trong `data/extracted/44-2019-QH14.txt` (bỏ dòng trống, chuẩn hóa khoảng trắng
và NFC). Kết quả:

| Kiểm tra | Kết quả |
|---|---|
| Mỗi khối **Trích** so với đúng khoảng **Dòng** của nó | **55/55 khớp từng chữ** |
| Mọi đoạn trích đặt trong dấu ngoặc kép góc, ở toàn tài liệu (kể cả Phần II), có trong file trích xuất | **172/172** (dấu chấm lửng bên trong một đoạn trích được coi là chỗ lược; mỗi đoạn còn lại phải xuất hiện nguyên văn) |
| Số khối khoản/điểm | **55** (đúng bảng đếm ở trên) |

Phạm vi kiểm: **chỉ chứng minh trích dẫn khớp file trích xuất**, tức là không
chép sai. Nó **không** chứng minh file trích xuất khớp bản in (xem 0.1, 0.2) và
**không** chứng minh các nhận định (suy luận của AI) là đúng. Script nằm ở thư
mục tạm của phiên làm việc, không thuộc kho mã.

---

## Phần I — Từng khoản, điểm

# Điều 2. Giải thích từ ngữ

### Điều 2, tiêu đề và đoạn dẫn
- **Dòng:** 25–26
- **Trích:** «Điều 2. Giải thích từ ngữ Trong Luật này, các từ ngữ dưới đây được hiểu như sau:»
- (1) id: Điều 2, đoạn dẫn
- (2) chủ thể: —
- (3) hành vi: giới hạn phạm vi hiệu lực của các định nghĩa ("Trong Luật này")
- (4) loại: định nghĩa (quy tắc về phạm vi của định nghĩa)
- (5) điều kiện: —
- (6) ngoại lệ: —
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: —
- (11) liệt kê: tám mục đánh số, đóng theo từng mục; **không nói** tám mục này là toàn bộ thuật ngữ cần định nghĩa — các từ như "uống", "quảng cáo" không có ở đây
- (12) biểu thức mở: —
- (13) đa nghĩa: "Trong Luật này" giới hạn trong luật này; các văn bản khác có thể hiểu khác (không rõ)
- (14) tin cậy: (3) cao «Trong Luật này»; (4) cao «được hiểu như sau»; (5)–(7) cao (không có)

### Điều 2, khoản 1
- **Dòng:** 27–29
- **Trích:** «1. Rượu là đồ uống có cồn thực phẩm, được sản xuất từ quá trình lên men từ một hoặc hỗn hợp của các loại nguyên liệu chủ yếu gồm tinh bột của ngũ cốc, dịch đường của cây, hoa, củ, quả hoặc là đồ uống được pha chế từ cồn thực phẩm.»
- (1) id: Điều 2, khoản 1
- (2) chủ thể: —
- (3) hành vi: định nghĩa "rượu"
- (4) loại: định nghĩa
- (5) điều kiện: hai nhánh nối bằng "hoặc là": (i) đồ uống có cồn thực phẩm sản xuất từ lên men; (ii) đồ uống pha chế từ cồn thực phẩm
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không có trích dẫn điều khoản; phụ thuộc thuật ngữ "cồn thực phẩm" (khoản 3, cùng điều)
- (9) ngưỡng: không có số; **không nêu** giới hạn dưới hay trên của độ cồn
- (10) thuật ngữ: đã định nghĩa: "cồn thực phẩm" (2.3); dùng mà chưa định nghĩa: "lên men", "pha chế", "đồ uống"
- (11) liệt kê: "chủ yếu gồm" — danh sách nguyên liệu; chữ "chủ yếu" làm danh sách **mở ngầm**
- (12) biểu thức mở: "chủ yếu" (không nêu tỷ lệ)
- (13) đa nghĩa: (a) "một hoặc hỗn hợp của các loại nguyên liệu" — tập con nào đủ điều kiện; (b) khoản 1 và khoản 2 **không nói** rượu và bia loại trừ nhau — nhánh "pha chế từ cồn thực phẩm" có thể chồng lên một đồ uống kiểu bia
- (14) tin cậy: (3) cao «Rượu là đồ uống»; (4) cao «là»; (5) trung bình «chủ yếu gồm»; (6)–(7) cao (không có)

### Điều 2, khoản 2
- **Dòng:** 30–32
- **Trích:** «2. Bia là đồ uống có cồn thực phẩm, được sản xuất từ quá trình lên men từ hỗn hợp của các loại nguyên liệu chủ yếu gồm mạch nha (malt), đại mạch, nấm men bia, hoa bia (hoa houblon), nước.»
- (1) id: Điều 2, khoản 2
- (2) chủ thể: —
- (3) hành vi: định nghĩa "bia"
- (4) loại: định nghĩa
- (5) điều kiện: sản xuất bằng lên men từ hỗn hợp nguyên liệu chủ yếu gồm năm thứ liệt kê
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không có trích dẫn; phụ thuộc "cồn thực phẩm" (2.3)
- (9) ngưỡng: không có số
- (10) thuật ngữ: đã định nghĩa: "cồn thực phẩm"; chưa định nghĩa: "lên men", "mạch nha"
- (11) liệt kê: năm thứ, không có "và/hoặc" trước thứ cuối; có "chủ yếu gồm" → không rõ có đóng hay không
- (12) biểu thức mở: "chủ yếu"
- (13) đa nghĩa: "hỗn hợp của … mạch nha, đại mạch, nấm men bia, hoa bia, nước" — phải có **đủ năm** thứ hay chỉ một số? Văn bản không nói
- (14) tin cậy: (3) cao «Bia là đồ uống»; (4) cao; (5) trung bình «chủ yếu gồm»; (6)–(7) cao (không có)

### Điều 2, khoản 3
- **Dòng:** 33–35
- **Trích:** «3. Cồn thực phẩm là hợp chất hữu cơ có công thức phân tử là C2H5OH và có tên khoa học là ethanol đã được loại bỏ tạp chất, đạt yêu cầu dùng trong thực phẩm theo quy chuẩn kỹ thuật quốc gia, có khả năng gây nghiện và gây ngộ độc cấp tính.»
- (1) id: Điều 2, khoản 3
- (2) chủ thể: —
- (3) hành vi: định nghĩa "cồn thực phẩm"
- (4) loại: định nghĩa
- (5) điều kiện: tinh khiết (đã loại tạp chất) và "đạt yêu cầu dùng trong thực phẩm theo quy chuẩn kỹ thuật quốc gia"
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: "quy chuẩn kỹ thuật quốc gia" — văn bản khác, **không nêu số hiệu** (không giải quyết được từ văn bản này)
- (9) ngưỡng: không có số
- (10) thuật ngữ: chưa định nghĩa: "quy chuẩn kỹ thuật quốc gia"
- (11) liệt kê: không
- (12) biểu thức mở: "đạt yêu cầu dùng trong thực phẩm", "khả năng gây nghiện"
- (13) đa nghĩa: "có khả năng gây nghiện và gây ngộ độc cấp tính" mô tả tính chất của chất, **không** phải điều kiện để phân loại — không thể dùng làm phép thử
- (14) tin cậy: (3) cao «Cồn thực phẩm là»; (4) cao; (5)–(7) cao (không có)
- **Ghi chú trích xuất**: file ghi `C2H5OH`; bản gốc là C₂H₅OH (chỉ số dưới).

### Điều 2, khoản 4
- **Dòng:** 36–38
- **Trích:** «4. Độ cồn là số đo chỉ hàm lượng cồn thực phẩm có trong rượu, bia tính theo phần trăm thể tích. Độ cồn được tính bằng số mililít ethanol nguyên chất trong 100 ml dung dịch ở 20°C.»
- (1) id: Điều 2, khoản 4
- (2) chủ thể: —
- (3) hành vi: định nghĩa "độ cồn" và cách đo
- (4) loại: định nghĩa
- (5) điều kiện: đo theo % thể tích, ở 20°C, trên 100 ml dung dịch
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: đơn vị: phần trăm thể tích; 100 ml; 20°C. **Không có so sánh** — đây là thước đo cho các ngưỡng 5,5 và 15 ở nơi khác
- (10) thuật ngữ: đã định nghĩa: "cồn thực phẩm"; **không định nghĩa**: "độ" làm đơn vị (các điều khác viết "15 độ" nhưng khoản này không nói 1 độ = 1% thể tích); "nồng độ cồn" (dùng ở 5.6, **khác** với "độ cồn")
- (11) liệt kê: không
- (12) biểu thức mở: —
- (13) đa nghĩa: (a) "độ cồn" là của đồ uống; "nồng độ cồn" ở 5.6 là của máu/hơi thở — hai thuật ngữ khác nhau, chỉ một cái được định nghĩa; (b) không nêu độ cồn tối thiểu để một thứ được tính là "rượu, bia" (đồ uống 0,0 độ có tính không?)
- (14) tin cậy: (3) cao «Độ cồn là số đo»; (4) cao; (5)–(7) cao (không có)

### Điều 2, khoản 5
- **Dòng:** 41–43
- **Trích:** «5. Tác hại của rượu, bia là ảnh hưởng, tác động có hại của rượu, bia đối với sức khỏe con người, gia đình, cộng đồng, an toàn giao thông, trật tự, an toàn xã hội, kinh tế và các vấn đề xã hội khác.»
- (1) id: Điều 2, khoản 5
- (2) chủ thể: —
- (3) hành vi: định nghĩa "tác hại của rượu, bia"
- (4) loại: định nghĩa
- (5) điều kiện: —
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "có hại"
- (11) liệt kê: **mở** — "và các vấn đề xã hội khác"
- (12) biểu thức mở: "có hại", "các vấn đề xã hội khác"
- (13) đa nghĩa: "gia đình, cộng đồng, an toàn giao thông, trật tự, an toàn xã hội, kinh tế" — "trật tự, an toàn xã hội" là một hay hai mục
- (14) tin cậy: (3) cao; (4) cao; (5)–(7) cao (không có)
- Dùng ở sáu điều: tiêu đề Điều 5; Điều 12 khoản 4.

### Điều 2, khoản 6
- **Dòng:** 45–47
- **Trích:** «6. Nghiện rượu, bia là tình trạng lệ thuộc vào rượu, bia với biểu hiện đặc trưng như thường xuyên thèm uống, lượng uống có thể tăng theo thời gian, không thể tự kiểm soát lượng uống hay ngừng uống.»
- (1) id: Điều 2, khoản 6
- (2) chủ thể: —
- (3) hành vi: định nghĩa "nghiện rượu, bia"
- (4) loại: định nghĩa
- (5) điều kiện: "tình trạng lệ thuộc" với các biểu hiện nêu
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: không có số
- (10) thuật ngữ: chưa định nghĩa: "lệ thuộc"
- (11) liệt kê: "như" — ví dụ, **mở**
- (12) biểu thức mở: "thường xuyên", "đặc trưng", "có thể tăng"
- (13) đa nghĩa: "không thể tự kiểm soát lượng uống hay ngừng uống" — "hay" là "hoặc" hay "và"
- (14) tin cậy: (3) cao; (4) cao; (5)–(7) cao (không có)
- **Không dùng** trong sáu điều của lát cắt này.

### Điều 2, khoản 7
- **Dòng:** 49–50
- **Trích:** «7. Sản xuất rượu thủ công là hoạt động sản xuất rượu bằng dụng cụ truyền thống, không sử dụng máy móc, thiết bị công nghiệp.»
- (1) id: Điều 2, khoản 7
- (2) chủ thể: —
- (3) hành vi: định nghĩa "sản xuất rượu thủ công"
- (4) loại: định nghĩa
- (5) điều kiện: dụng cụ truyền thống **và** không dùng máy móc, thiết bị công nghiệp
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: không có số
- (10) thuật ngữ: chưa định nghĩa: "dụng cụ truyền thống"
- (11) liệt kê: không
- (12) biểu thức mở: "dụng cụ truyền thống", "máy móc, thiết bị công nghiệp"
- (13) đa nghĩa: quy trình dùng máy nhỏ không phải "công nghiệp" thì thuộc loại nào — khoản 7 ("không sử dụng máy móc") và khoản 8 ("máy móc, thiết bị công nghiệp") **không phủ kín nhau**
- (14) tin cậy: (3) cao; (4) cao; (5)–(7) cao (không có)
- **Không dùng** trong sáu điều.

### Điều 2, khoản 8
- **Dòng:** 52–53
- **Trích:** «8. Sản xuất rượu công nghiệp là hoạt động sản xuất rượu bằng máy móc, thiết bị công nghiệp.»
- (1) id: Điều 2, khoản 8
- (2) chủ thể: —
- (3) hành vi: định nghĩa "sản xuất rượu công nghiệp"
- (4) loại: định nghĩa
- (5) điều kiện: dùng máy móc, thiết bị công nghiệp
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: không có số
- (10) thuật ngữ: chưa định nghĩa: "máy móc, thiết bị công nghiệp"
- (11) liệt kê: không
- (12) biểu thức mở: "máy móc, thiết bị công nghiệp"
- (13) đa nghĩa: xem khoản 7 (khoảng trống giữa hai khái niệm); chỉ định nghĩa sản xuất **rượu**, không có định nghĩa sản xuất **bia**
- (14) tin cậy: (3) cao; (4) cao; (5)–(7) cao (không có)
- **Không dùng** trong sáu điều.

---

# Điều 5. Các hành vi bị nghiêm cấm

### Điều 5, tiêu đề
- **Dòng:** 86–87
- **Trích:** «Điều 5. Các hành vi bị nghiêm cấm trong phòng, chống tác hại của rượu, bia»
- (1) id: Điều 5, tiêu đề
- (2) chủ thể: không rõ — tiêu đề không nêu ai bị cấm; mọi khoản dưới đây là cụm danh từ/động từ không có "không được"
- (3) hành vi: mọi hành vi liệt kê ở khoản 1–13 là "bị nghiêm cấm"
- (4) loại: **cấm** (toàn bộ sức mạnh cấm nằm ở tiêu đề, **không** ở từng khoản). Ranh giới: cấm (quy tắc ứng xử) hoặc chỉ liệt kê hành vi vi phạm làm cơ sở xử lý — tôi đọc là cấm vì "bị nghiêm cấm", nhưng chữ không nói rõ
- (5) điều kiện: —
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không (khoản 13 dẫn chiếu "luật định")
- (9) ngưỡng: —
- (10) thuật ngữ: "rượu", "bia", "tác hại" (đã định nghĩa)
- (11) liệt kê: **mở** — khoản 13 nói "các hành vi bị nghiêm cấm khác … do luật định"
- (12) biểu thức mở: "nghiêm cấm" (không nêu chế tài ở đây)
- (13) đa nghĩa: tiêu đề áp dụng cho mọi khoản; khoản không có chủ ngữ rõ buộc phải suy từ ngữ nghĩa động từ
- (14) tin cậy: (3) cao «bị nghiêm cấm»; (4) trung bình «Các hành vi bị nghiêm cấm»; (5)–(7) cao (không có)

### Điều 5, khoản 1
- **Dòng:** 89
- **Trích:** «1. Xúi giục, kích động, lôi kéo, ép buộc người khác uống rượu, bia.»
- (1) id: Điều 5, khoản 1
- (2) chủ thể: bất kỳ ai (ngầm) — chữ không nêu
- (3) hành vi: xúi giục / kích động / lôi kéo / ép buộc người khác uống rượu, bia
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: đối tượng là "người khác"; không có điều kiện tuổi
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "uống"
- (11) liệt kê: bốn động từ, không có "và/hoặc" → không rõ; đọc ngầm là hoặc
- (12) biểu thức mở: "xúi giục", "kích động", "lôi kéo" (ranh giới giữa các động từ không nêu)
- (13) đa nghĩa: bốn động từ có ngang nhau hay lũy tiến (ép buộc nặng hơn lôi kéo) — có ảnh hưởng nếu sau này gắn chế tài
- (14) tin cậy: (3) cao «ép buộc người khác uống»; (4) trung bình (từ tiêu đề); (5) cao; (6)–(7) cao (không có); chủ thể: thấp

### Điều 5, khoản 2
- **Dòng:** 90
- **Trích:** «2. Người chưa đủ 18 tuổi uống rượu, bia.»
- (1) id: Điều 5, khoản 2
- (2) chủ thể: người chưa đủ 18 tuổi (chính người uống)
- (3) hành vi: uống rượu, bia
- (4) loại: cấm (qua tiêu đề). Ranh giới: đây là hành vi của chính người dưới 18, không phải của người cung cấp
- (5) điều kiện: người uống chưa đủ 18 tuổi
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: tuổi **< 18** ("chưa đủ 18 tuổi"; hướng nhỏ hơn)
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "uống"
- (11) liệt kê: không
- (12) biểu thức mở: —
- (13) đa nghĩa: không có giới hạn địa điểm, lượng hay hoàn cảnh (áp dụng cả trong gia đình) — **không giống** Điều 10 (theo địa điểm)
- (14) tin cậy: (3) cao «uống rượu, bia»; (4) trung bình (qua tiêu đề); (5) cao «chưa đủ 18 tuổi»; (6)–(7) cao (không có)

### Điều 5, khoản 3
- **Dòng:** 91
- **Trích:** «3. Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi.»
- (1) id: Điều 5, khoản 3
- (2) chủ thể: người bán / cung cấp / khuyến mại (ngầm)
- (3) hành vi: bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi
- (4) loại: cấm (qua tiêu đề). Ranh giới: ba hành vi nằm trong một câu; "cung cấp" rộng hơn "bán" (gồm cả cho không) — văn bản không nói
- (5) điều kiện: người nhận chưa đủ 18 tuổi
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: tuổi **< 18** của **người nhận**
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "bán", "cung cấp", "khuyến mại"
- (11) liệt kê: ba động từ, không nối → đọc ngầm là hoặc
- (12) biểu thức mở: —
- (13) đa nghĩa: "cho người chưa đủ 18 tuổi" gắn vào cả ba động từ hay chỉ "khuyến mại" — đọc tự nhiên là cả ba, nhưng chữ không khóa
- (14) tin cậy: (3) cao «Bán, cung cấp, khuyến mại … cho người chưa đủ 18 tuổi»; (4) trung bình; (5) cao; (6)–(7) cao (không có); chủ thể thấp

### Điều 5, khoản 4
- **Dòng:** 92–93
- **Trích:** «4. Sử dụng lao động là người chưa đủ 18 tuổi trực tiếp tham gia vào việc sản xuất, mua bán rượu, bia.»
- (1) id: Điều 5, khoản 4
- (2) chủ thể: bên sử dụng lao động (ngầm, từ "Sử dụng lao động")
- (3) hành vi: sử dụng lao động chưa đủ 18 tuổi trực tiếp tham gia sản xuất, mua bán rượu, bia
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: người lao động chưa đủ 18 tuổi **và** trực tiếp tham gia sản xuất hoặc mua bán rượu, bia
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không (Điều 32 khoản 3 — ngoài lát cắt — lặp lại quy tắc này cho cơ sở kinh doanh)
- (9) ngưỡng: tuổi **< 18** của người lao động
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "sử dụng lao động", "sản xuất", "mua bán"
- (11) liệt kê: hai hoạt động "sản xuất, mua bán", không nối → đọc ngầm là hoặc
- (12) biểu thức mở: "trực tiếp tham gia" (ranh giới trực tiếp/gián tiếp không nêu)
- (13) đa nghĩa: "mua bán" là cả mua lẫn bán hay một trong hai; "trực tiếp" gắn vào cả "sản xuất" lẫn "mua bán"
- (14) tin cậy: (3) cao «Sử dụng lao động»; (4) trung bình; (5) cao «chưa đủ 18 tuổi trực tiếp tham gia»; (6)–(7) cao (không có)

### Điều 5, khoản 5
- **Dòng:** 94–97
- **Trích:** «5. Cán bộ, công chức, viên chức, người lao động trong các cơ quan, tổ chức, sĩ quan, hạ sĩ quan, quân nhân chuyên nghiệp, chiến sĩ, người làm việc trong lực lượng vũ trang nhân dân, học sinh, sinh viên uống rượu, bia ngay trước, trong giờ làm việc, học tập và nghỉ giữa giờ làm việc, học tập.»
- (1) id: Điều 5, khoản 5
- (2) chủ thể: các nhóm: cán bộ, công chức, viên chức, người lao động (trong cơ quan, tổ chức); sĩ quan, hạ sĩ quan, quân nhân chuyên nghiệp, chiến sĩ, người làm việc trong lực lượng vũ trang nhân dân; học sinh, sinh viên
- (3) hành vi: uống rượu, bia vào các thời điểm quanh giờ làm việc, học tập
- (4) loại: cấm (qua tiêu đề). Ranh giới: không
- (5) điều kiện: người uống thuộc nhóm nêu **và** thời điểm là "ngay trước", "trong", hoặc "nghỉ giữa giờ" làm việc/học tập
- (6) ngoại lệ: **không có** — khác Điều 10 khoản 6
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: không có số; khoảng "ngay trước" không có độ dài
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "uống", "giờ làm việc", "giờ học tập"
- (11) liệt kê: danh sách chủ thể đóng ngầm (không có "gồm/bao gồm"); danh sách thời điểm: không rõ
- (12) biểu thức mở: "ngay trước" (không nêu khoảng thời gian)
- (13) đa nghĩa: (a) "ngay trước, trong giờ làm việc, học tập **và** nghỉ giữa giờ" — "và" đọc là hoặc (nếu là "đồng thời cả ba" thì vô nghĩa) nhưng chữ viết là "và"; (b) "ngay trước" gắn vào "giờ làm việc, học tập" hay cả "nghỉ giữa giờ"; (c) "trong các cơ quan, tổ chức" gắn vào "người lao động" hay cả bốn danh từ đầu; (d) các nhóm chủ thể chồng lấn nhau (học sinh vừa là người lao động)
- (14) tin cậy: (3) cao «uống rượu, bia ngay trước, trong giờ làm việc»; (4) trung bình; (5) trung bình «và nghỉ giữa giờ»; (6) cao (không có); (7) cao (không có)

### Điều 5, khoản 6
- **Dòng:** 98–99
- **Trích:** «6. Điều khiển phương tiện giao thông mà trong máu hoặc hơi thở có nồng độ cồn.»
- (1) id: Điều 5, khoản 6
- (2) chủ thể: người điều khiển phương tiện giao thông (ngầm, từ "Điều khiển")
- (3) hành vi: điều khiển phương tiện giao thông khi trong máu hoặc hơi thở có nồng độ cồn
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: đang điều khiển phương tiện giao thông **và** có nồng độ cồn trong máu **hoặc** hơi thở
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không (Điều 35 khoản 1 — chính luật này — sửa luật khác theo hướng tương tự; Điều 21 khoản 1 — ngoài lát cắt — liên quan)
- (9) ngưỡng: "có nồng độ cồn" — **không có số**; đọc ngầm là lớn hơn 0; hướng >
- (10) thuật ngữ: chưa định nghĩa: "nồng độ cồn" (khác "độ cồn" 2.4), "phương tiện giao thông"
- (11) liệt kê: "máu hoặc hơi thở" — hai môi trường, nối bằng "hoặc"
- (12) biểu thức mở: "phương tiện giao thông" (loại nào: đường bộ, thủy, hàng không?)
- (13) đa nghĩa: "có nồng độ cồn" không nói mức; chữ không loại trừ nồng độ cồn nội sinh
- (14) tin cậy: (3) cao «Điều khiển phương tiện giao thông»; (4) trung bình; (5) cao «trong máu hoặc hơi thở»; (6)–(7) cao (không có); ngưỡng: **thấp** — văn bản không nêu số

### Điều 5, khoản 7
- **Dòng:** 100
- **Trích:** «7. Quảng cáo rượu có độ cồn từ 15 độ trở lên.»
- (1) id: Điều 5, khoản 7
- (2) chủ thể: người quảng cáo (ngầm)
- (3) hành vi: quảng cáo rượu có độ cồn từ 15 độ trở lên
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: sản phẩm là **rượu** (không phải bia) **và** độ cồn ≥ 15
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không trích dẫn; liên quan Điều 13 (rượu 5,5 đến dưới 15 độ), cùng lát cắt
- (9) ngưỡng: độ cồn **≥ 15 độ** ("từ 15 độ trở lên")
- (10) thuật ngữ: đã định nghĩa: "rượu", "độ cồn"; chưa định nghĩa: "quảng cáo", đơn vị "độ"
- (11) liệt kê: không
- (12) biểu thức mở: —
- (13) đa nghĩa: chỉ nói "rượu", **không** nói "bia" — bia từ 15 độ không bị cấm ở khoản này (Điều 13 điều chỉnh bia từ 5,5 độ trở lên, nhưng không cấm hoàn toàn); điều này có thể là cố ý hoặc sót
- (14) tin cậy: (3) cao «Quảng cáo rượu»; (4) trung bình; (5) cao «từ 15 độ trở lên»; (6)–(7) cao (không có)

### Điều 5, khoản 8
- **Dòng:** 101–102
- **Trích:** «8. Cung cấp thông tin không chính xác, sai sự thật về ảnh hưởng của rượu, bia đối với sức khỏe.»
- (1) id: Điều 5, khoản 8
- (2) chủ thể: bất kỳ ai cung cấp thông tin (ngầm)
- (3) hành vi: cung cấp thông tin không chính xác, sai sự thật về ảnh hưởng của rượu, bia đối với sức khỏe
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: nội dung thông tin là về ảnh hưởng của rượu, bia đối với sức khỏe **và** không chính xác hoặc sai sự thật
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "thông tin"
- (11) liệt kê: "không chính xác, sai sự thật" — hai tiêu chí, không nối
- (12) biểu thức mở: "không chính xác", "sai sự thật" (ai và theo chuẩn nào quyết định)
- (13) đa nghĩa: hai tiêu chí có phân biệt hay đồng nghĩa; không giới hạn kênh hay đối tượng cung cấp
- (14) tin cậy: (3) cao «Cung cấp thông tin không chính xác, sai sự thật»; (4) trung bình; (5)–(7) cao (không có)

### Điều 5, khoản 9
- **Dòng:** 103–104
- **Trích:** «9. Khuyến mại trong hoạt động kinh doanh rượu, bia có độ cồn từ 15 độ trở lên; sử dụng rượu, bia có độ cồn từ 15 độ trở lên để khuyến mại dưới mọi hình thức.»
- (1) id: Điều 5, khoản 9
- (2) chủ thể: bên khuyến mại / bên kinh doanh (ngầm)
- (3) hành vi: (i) khuyến mại trong kinh doanh rượu, bia ≥ 15 độ; (ii) dùng rượu, bia ≥ 15 độ để khuyến mại
- (4) loại: cấm (qua tiêu đề). Ranh giới: hai hành vi khác nhau trong một khoản (khuyến mại **sản phẩm rượu** so với dùng **rượu làm quà**)
- (5) điều kiện: độ cồn ≥ 15 ở cả hai nhánh
- (6) ngoại lệ: không (nhánh (ii) nhấn "dưới mọi hình thức")
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không trích dẫn; đối ứng với Điều 11 (dưới 15 độ) — ngoài lát cắt
- (9) ngưỡng: độ cồn **≥ 15 độ**
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia", "độ cồn"; chưa định nghĩa: "khuyến mại"
- (11) liệt kê: hai nhánh nối bằng dấu chấm phẩy
- (12) biểu thức mở: "dưới mọi hình thức"
- (13) đa nghĩa: "trong hoạt động kinh doanh rượu, bia" có ràng buộc nhánh (i) vào kinh doanh chính sản phẩm đó hay mọi kinh doanh rượu, bia
- (14) tin cậy: (3) cao «Khuyến mại … từ 15 độ trở lên»; (4) trung bình; (5) cao; (6)–(7) cao (không có)

### Điều 5, khoản 10
- **Dòng:** 105–108
- **Trích:** «10. Sử dụng nguyên liệu, phụ gia, chất hỗ trợ chế biến không được phép dùng trong thực phẩm; nguyên liệu, phụ gia thực phẩm, chất hỗ trợ chế biến thực phẩm không bảo đảm chất lượng và không rõ nguồn gốc, xuất xứ để sản xuất, pha chế rượu, bia.»
- (1) id: Điều 5, khoản 10
- (2) chủ thể: người sản xuất, pha chế rượu, bia (ngầm)
- (3) hành vi: sử dụng (i) nguyên liệu/phụ gia/chất hỗ trợ không được phép dùng trong thực phẩm; (ii) nguyên liệu/phụ gia/chất hỗ trợ không bảo đảm chất lượng **và** không rõ nguồn gốc — để sản xuất, pha chế rượu, bia
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: mục đích sản xuất hoặc pha chế rượu, bia; tình trạng nguyên liệu như nêu
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: "không được phép dùng trong thực phẩm" — ngầm tới pháp luật an toàn thực phẩm, **không nêu**
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "phụ gia", "chất hỗ trợ chế biến", "nguồn gốc, xuất xứ"
- (11) liệt kê: ba loại nguyên liệu liệt kê; hai nhánh nối bằng dấu chấm phẩy
- (12) biểu thức mở: "không bảo đảm chất lượng", "không rõ nguồn gốc, xuất xứ"
- (13) đa nghĩa: (a) nhánh (ii) viết "**và**" (đủ cả hai tiêu chí?) trong khi khoản 12 viết bằng dấu phẩy (đọc là hoặc) — soạn thảo không nhất quán; (b) "để sản xuất, pha chế rượu, bia" gắn vào cả hai nhánh hay chỉ nhánh (ii)
- (14) tin cậy: (3) trung bình «Sử dụng nguyên liệu»; (4) trung bình; (5) thấp «và không rõ nguồn gốc»; (6)–(7) cao (không có)

### Điều 5, khoản 11
- **Dòng:** 109–110
- **Trích:** «11. Kinh doanh rượu không có giấy phép hoặc không đăng ký; bán rượu, bia bằng máy bán hàng tự động.»
- (1) id: Điều 5, khoản 11
- (2) chủ thể: người kinh doanh / người bán (ngầm)
- (3) hành vi: (i) kinh doanh rượu mà thiếu giấy phép hoặc thiếu đăng ký; (ii) bán rượu, bia bằng máy bán hàng tự động
- (4) loại: cấm (qua tiêu đề). Ranh giới: nhánh (i) thực chất là nghĩa vụ phải có giấy phép/đăng ký, diễn đạt bằng cấm
- (5) điều kiện: (i) sản phẩm là **rượu**; thiếu giấy phép **hoặc** thiếu đăng ký; (ii) rượu **hoặc** bia; phương thức bán là máy bán hàng tự động
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không trích dẫn; ngầm liên quan Điều 15 (cấp phép, đăng ký) — ngoài lát cắt
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "giấy phép", "đăng ký", "máy bán hàng tự động"
- (11) liệt kê: hai hành vi nối bằng dấu chấm phẩy
- (12) biểu thức mở: —
- (13) đa nghĩa: (a) "giấy phép" hay "đăng ký" áp dụng cho loại hình nào không nói ở đây (phụ thuộc Điều 15); (b) nhánh (i) chỉ nói "rượu", nhánh (ii) nói "rượu, bia" — bia không nằm trong nhánh (i)
- (14) tin cậy: (3) cao «bán rượu, bia bằng máy bán hàng tự động»; (4) trung bình; (5) trung bình «không có giấy phép hoặc không đăng ký»; (6)–(7) cao (không có)

### Điều 5, khoản 12
- **Dòng:** 111–112
- **Trích:** «12. Kinh doanh, tàng trữ, vận chuyển rượu, bia giả, nhập lậu, không bảo đảm chất lượng, không rõ nguồn gốc, xuất xứ; nhập lậu rượu, bia.»
- (1) id: Điều 5, khoản 12
- (2) chủ thể: người kinh doanh, tàng trữ, vận chuyển, nhập khẩu (ngầm)
- (3) hành vi: kinh doanh / tàng trữ / vận chuyển rượu, bia giả, nhập lậu, không bảo đảm chất lượng, không rõ nguồn gốc; và nhập lậu rượu, bia
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: tình trạng sản phẩm (giả; nhập lậu; không bảo đảm chất lượng; không rõ nguồn gốc)
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không trích dẫn (Điều 20 — ngoài lát cắt — nói xử lý hàng này)
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "giả", "nhập lậu", "tàng trữ", "vận chuyển"
- (11) liệt kê: ba hành vi và bốn tình trạng, ngăn bằng dấu phẩy, không "hoặc"; đọc ngầm là hoặc
- (12) biểu thức mở: "không bảo đảm chất lượng", "không rõ nguồn gốc, xuất xứ"
- (13) đa nghĩa: "nhập lậu" xuất hiện hai lần — lần đầu là **tình trạng** của sản phẩm, lần sau là **hành vi**; trùng một phần; "không rõ nguồn gốc, xuất xứ" là một hay hai tiêu chí
- (14) tin cậy: (3) trung bình «Kinh doanh, tàng trữ, vận chuyển»; (4) trung bình; (5) trung bình; (6)–(7) cao (không có)

### Điều 5, khoản 13
- **Dòng:** 113
- **Trích:** «13. Các hành vi bị nghiêm cấm khác liên quan đến rượu, bia do luật định.»
- (1) id: Điều 5, khoản 13
- (2) chủ thể: không rõ
- (3) hành vi: các hành vi bị cấm khác do luật khác quy định
- (4) loại: **khác** — dẫn chiếu mở (renvoi). Ranh giới: cấm so với con trỏ rỗng; nội dung nằm hoàn toàn ngoài văn bản
- (5) điều kiện: "do luật định"
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: "luật" — **luật khác, không nêu**; không giải quyết được từ văn bản này
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "liên quan đến rượu, bia"
- (11) liệt kê: **mở** theo định nghĩa
- (12) biểu thức mở: "liên quan đến"
- (13) đa nghĩa: "luật" là đạo luật (Luật) hay mọi văn bản pháp luật (nghị định…) — chữ là "luật"
- (14) tin cậy: (3) cao «do luật định»; (4) cao (là dẫn chiếu); (5)–(7) cao (không có)

---

# Điều 10. Địa điểm không uống rượu, bia

### Điều 10, tiêu đề
- **Dòng:** 192
- **Trích:** «Điều 10. Địa điểm không uống rượu, bia»
- (1) id: Điều 10, tiêu đề
- (2) chủ thể: không rõ — ngầm: người đang ở địa điểm
- (3) hành vi: uống rượu, bia tại các địa điểm liệt kê ở khoản 1–7
- (4) loại: **cấm** — **chỉ nhờ tiêu đề**: không khoản nào có động từ "cấm" hay "không được", mỗi khoản là một cụm danh từ chỉ nơi chốn. Ranh giới: cấm so với danh mục địa điểm (định nghĩa)
- (5) điều kiện: địa điểm thuộc danh mục
- (6) ngoại lệ: không ở tiêu đề (có ở khoản 6)
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không (Điều 33 khoản 3 — ngoài lát cắt — giao trách nhiệm cho người đứng đầu địa điểm theo Điều 10 và Điều 19)
- (9) ngưỡng: —
- (10) thuật ngữ: "rượu", "bia"; chưa định nghĩa: "uống"
- (11) liệt kê: danh mục bảy khoản, không có "gồm/bao gồm" → đóng ngầm, với khe mở ở khoản 7
- (12) biểu thức mở: —
- (13) đa nghĩa: tiêu đề nói "không uống" nhưng chữ không nói **ai** không được uống, **bao gồm cả người ngoài cuộc** hay chỉ người làm việc tại đó
- (14) tin cậy: (3) cao «không uống rượu, bia»; (4) **trung bình** «Địa điểm không uống»; (5)–(7) cao (không có)

### Điều 10, khoản 1
- **Dòng:** 193
- **Trích:** «1. Cơ sở y tế.»
- (1) id: Điều 10, khoản 1
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại cơ sở y tế (từ tiêu đề)
- (4) loại: cấm (qua tiêu đề); khoản là mảnh vụn không có động từ
- (5) điều kiện: địa điểm là cơ sở y tế; **không có điều kiện thời gian**
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ sở y tế"
- (11) liệt kê: —
- (12) biểu thức mở: "cơ sở y tế" (gồm căng-tin, bãi xe, khuôn viên không?)
- (13) đa nghĩa: cơ sở y tế là tòa nhà hay cả khuôn viên
- (14) tin cậy: (3) cao (từ tiêu đề); (4) trung bình; (5) cao «Cơ sở y tế»; (6)–(7) cao (không có)

### Điều 10, khoản 2
- **Dòng:** 194
- **Trích:** «2. Cơ sở giáo dục trong thời gian giảng dạy, học tập, làm việc.»
- (1) id: Điều 10, khoản 2
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại cơ sở giáo dục trong khung thời gian nêu
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là cơ sở giáo dục **và** đang trong "thời gian giảng dạy, học tập, làm việc"
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: không có số; khung giờ cụ thể phụ thuộc lịch của từng cơ sở (ngoài văn bản)
- (10) thuật ngữ: chưa định nghĩa: "cơ sở giáo dục"
- (11) liệt kê: ba loại thời gian "giảng dạy, học tập, làm việc", không nối → đọc ngầm là hoặc
- (12) biểu thức mở: "thời gian giảng dạy, học tập, làm việc"
- (13) đa nghĩa: **khác Điều 19 khoản 2** (bán, cơ sở giáo dục, **không** có khung thời gian) — xem E và G
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao «trong thời gian giảng dạy, học tập, làm việc»; (6)–(7) cao (không có)

### Điều 10, khoản 3
- **Dòng:** 195–196
- **Trích:** «3. Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi.»
- (1) id: Điều 10, khoản 3
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại cơ sở/khu vực dành cho người chưa đủ 18 tuổi
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là cơ sở hoặc khu vực chăm sóc/nuôi dưỡng/vui chơi/giải trí **dành cho** người chưa đủ 18 tuổi; không có điều kiện thời gian
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: tuổi **< 18** (đối tượng phục vụ của cơ sở)
- (10) thuật ngữ: chưa định nghĩa: "cơ sở", "khu vực"
- (11) liệt kê: bốn chức năng, không nối → đọc ngầm là hoặc
- (12) biểu thức mở: "dành cho", "khu vực"
- (13) đa nghĩa: (a) "dành cho" = chủ yếu phục vụ hay chỉ cho phép sử dụng; (b) "khu vực" có thể là một phần của nơi lớn hơn (khu trò chơi trong trung tâm thương mại); (c) "dành cho người chưa đủ 18 tuổi" gắn vào cả bốn chức năng hay chỉ "giải trí"
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao «dành cho người chưa đủ 18 tuổi»; (6)–(7) cao (không có)

### Điều 10, khoản 4
- **Dòng:** 197–198
- **Trích:** «4. Cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân và cơ sở giam giữ khác.»
- (1) id: Điều 10, khoản 4
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại các cơ sở nêu
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là một trong năm loại cơ sở; không điều kiện thời gian
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: tất cả năm loại cơ sở
- (11) liệt kê: **mở ở cuối** — "cơ sở giam giữ khác"
- (12) biểu thức mở: "cơ sở giam giữ khác"
- (13) đa nghĩa: "và" nối cuối danh sách đóng vai trò hoặc
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao; (6)–(7) cao (không có)

### Điều 10, khoản 5
- **Dòng:** 199
- **Trích:** «5. Cơ sở bảo trợ xã hội.»
- (1) id: Điều 10, khoản 5
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại cơ sở bảo trợ xã hội
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là cơ sở bảo trợ xã hội; không điều kiện thời gian
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ sở bảo trợ xã hội"
- (11) liệt kê: —
- (12) biểu thức mở: —
- (13) đa nghĩa: không phát hiện
- (14) tin cậy: (3) cao; (4) trung bình; (5)–(7) cao

### Điều 10, khoản 6
- **Dòng:** 200–202
- **Trích:** «6. Nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập trong thời gian làm việc, trừ địa điểm được phép kinh doanh rượu, bia.»
- (1) id: Điều 10, khoản 6
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại nơi làm việc của các cơ quan/tổ chức nêu trong thời gian làm việc
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là nơi làm việc của một trong năm loại tổ chức **và** đang "trong thời gian làm việc"
- (6) ngoại lệ: **"trừ địa điểm được phép kinh doanh rượu, bia"** — loại các địa điểm có phép kinh doanh rượu, bia ra khỏi phạm vi cấm
- (7) ưu tiên: không có chữ ưu tiên; ngoại lệ chỉ thu hẹp khoản này, **không** nói gì về Điều 5 khoản 5
- (8) tham chiếu ra: không trích dẫn; "được phép kinh doanh" phụ thuộc chế độ cấp phép (Điều 15, ngoài lát cắt, không được nêu)
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ quan nhà nước", "tổ chức chính trị", "đơn vị sự nghiệp công lập"
- (11) liệt kê: năm loại tổ chức; không "gồm/bao gồm" → đóng ngầm
- (12) biểu thức mở: "thời gian làm việc", "địa điểm được phép kinh doanh" (ai cấp phép, cấp loại nào)
- (13) đa nghĩa: (a) "trong thời gian làm việc" gắn vào cả danh sách hay chỉ "đơn vị sự nghiệp công lập"; (b) "trừ địa điểm …" gắn vào cả khoản; (c) bản gốc thiếu gạch nối ở "chính trị xã hội - nghề nghiệp" (đặc điểm của bản gốc); (d) tương tác với Điều 5 khoản 5 — xem E
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao «trong thời gian làm việc»; (6) cao «trừ địa điểm được phép kinh doanh rượu, bia»; (7) cao (không có)

### Điều 10, khoản 7
- **Dòng:** 203
- **Trích:** «7. Các địa điểm công cộng theo quy định của Chính phủ.»
- (1) id: Điều 10, khoản 7
- (2) chủ thể: không rõ
- (3) hành vi: uống rượu, bia tại các địa điểm công cộng do Chính phủ quy định
- (4) loại: cấm (qua tiêu đề). Ranh giới: đồng thời là **ủy quyền** — danh mục địa điểm do văn bản khác điền
- (5) điều kiện: địa điểm nằm trong danh mục do Chính phủ quy định
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: "quy định của Chính phủ" — **văn bản khác, chưa xác định, chưa đọc**
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "địa điểm công cộng"
- (11) liệt kê: **mở** — nội dung do văn bản khác bổ sung
- (12) biểu thức mở: "địa điểm công cộng" (nội dung nằm ngoài văn bản)
- (13) đa nghĩa: **Điều 19 không có khoản tương ứng** — danh mục "không bán" không tự động kèm các địa điểm công cộng này
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao; (6)–(7) cao (không có)

---

# Điều 12. Quản lý việc quảng cáo rượu, bia có độ cồn dưới 5,5 độ

### Điều 12, tiêu đề
- **Dòng:** 209
- **Trích:** «Điều 12. Quản lý việc quảng cáo rượu, bia có độ cồn dưới 5,5 độ»
- (1) id: Điều 12, tiêu đề
- (2) chủ thể: —
- (3) hành vi: nêu đối tượng điều chỉnh của điều: quảng cáo rượu, bia **dưới 5,5 độ**
- (4) loại: chính sách (tiêu đề). Ranh giới: tiêu đề có thể là **điều kiện phạm vi** áp dụng cho mọi khoản, hay chỉ là nhãn — xem đa nghĩa
- (5) điều kiện: độ cồn < 5,5
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không (Điều 13 trỏ vào điều này)
- (9) ngưỡng: độ cồn **< 5,5 độ** ("dưới 5,5 độ")
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia", "độ cồn"
- (11) liệt kê: —
- (12) biểu thức mở: —
- (13) đa nghĩa: **khoản 1 viết "quảng cáo rượu, bia" không kèm độ cồn**; nhưng Điều 13 buộc rượu/bia từ 5,5 độ cũng "phải tuân thủ quy định tại Điều 12" — nên nội dung Điều 12 không thể chỉ áp dụng cho dưới 5,5 độ. Tiêu đề có hiệu lực giới hạn các khoản hay không: **không rõ**
- (14) tin cậy: (3) trung bình «Quản lý việc quảng cáo»; (4) thấp; (5) cao «dưới 5,5 độ»; (6)–(7) cao (không có)

### Điều 12, khoản 1
- **Dòng:** 210–211
- **Trích:** «1. Tổ chức, cá nhân thực hiện quảng cáo rượu, bia phải tuân thủ các quy định của Luật này và quy định khác của pháp luật về quảng cáo.»
- (1) id: Điều 12, khoản 1
- (2) chủ thể: tổ chức, cá nhân thực hiện quảng cáo rượu, bia
- (3) hành vi: tuân thủ quy định của Luật này và pháp luật về quảng cáo
- (4) loại: nghĩa vụ ("phải tuân thủ"). Ranh giới: **nghĩa vụ hay dẫn chiếu** — không đặt thêm nội dung mới, chỉ trỏ tới các quy tắc khác
- (5) điều kiện: thực hiện quảng cáo rượu, bia; **không có điều kiện độ cồn trong chữ**
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: "Luật này" (toàn bộ luật, gồm Điều 5 khoản 7) — nội bộ; "quy định khác của pháp luật về quảng cáo" — **luật khác, không nêu số hiệu**
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "quảng cáo"
- (11) liệt kê: —
- (12) biểu thức mở: —
- (13) đa nghĩa: tiêu đề giới hạn dưới 5,5 độ, khoản này thì không — xem tiêu đề; "các quy định của Luật này" gồm cả những quy định cấm hoàn toàn ở Điều 5
- (14) tin cậy: (3) cao «phải tuân thủ»; (4) trung bình; (5) trung bình; (6)–(7) cao (không có)

### Điều 12, khoản 2 (đoạn dẫn)
- **Dòng:** 212
- **Trích:** «2. Quảng cáo không thể hiện các nội dung sau đây:»
- (1) id: Điều 12, khoản 2, đoạn dẫn
- (2) chủ thể: ngầm: người thực hiện quảng cáo (chủ ngữ ngữ pháp là "Quảng cáo")
- (3) hành vi: quảng cáo thể hiện các nội dung ở điểm a, b
- (4) loại: cấm. Ranh giới: quy tắc về **nội dung của quảng cáo** chứ không phải hành vi của một người
- (5) điều kiện: có quảng cáo
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: điểm a, b (nội bộ, giải quyết được)
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "quảng cáo"
- (11) liệt kê: "sau đây" — danh sách đóng hai điểm
- (12) biểu thức mở: —
- (13) đa nghĩa: chủ ngữ là "Quảng cáo" (một vật), không phải một người — ai chịu nghĩa vụ không rõ
- (14) tin cậy: (3) cao «không thể hiện»; (4) cao; (5)–(7) cao (không có)

### Điều 12, khoản 2, điểm a
- **Dòng:** 213–215
- **Trích:** «a) Có thông tin, hình ảnh nhằm khuyến khích uống rượu, bia; thông tin rượu, bia có tác dụng tạo sự trưởng thành, thành đạt, thân thiện, hấp dẫn về giới tính; hướng đến trẻ em, học sinh, sinh viên, thanh niên, phụ nữ mang thai;»
- (1) id: Điều 12, khoản 2, điểm a
- (2) chủ thể: ngầm: người quảng cáo
- (3) hành vi: ba nhánh: (i) thông tin, hình ảnh nhằm khuyến khích uống; (ii) thông tin nói rượu, bia tạo sự trưởng thành, thành đạt, thân thiện, hấp dẫn về giới tính; (iii) hướng đến trẻ em, học sinh, sinh viên, thanh niên, phụ nữ mang thai
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: nội dung quảng cáo thuộc một trong ba nhánh
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "trẻ em", "thanh niên", "phụ nữ mang thai" (định nghĩa ở luật khác, không nêu)
- (11) liệt kê: ba nhánh chấm phẩy; năm nhóm người; không nối → đọc ngầm là hoặc
- (12) biểu thức mở: "nhằm khuyến khích" (ý định), "có tác dụng tạo" (hiệu quả), "hướng đến" (đối tượng nhắm), "thân thiện", "hấp dẫn về giới tính"
- (13) đa nghĩa: ba nhánh có khung ngữ pháp khác nhau (nhánh (ii), (iii) không có "Có"); "nhằm" là ý định chủ quan hay ý nghĩa khách quan của quảng cáo; "trẻ em" không có ngưỡng tuổi trong văn bản này
- (14) tin cậy: (3) trung bình «Có thông tin, hình ảnh nhằm khuyến khích uống»; (4) cao; (5) trung bình; (6)–(7) cao (không có)

### Điều 12, khoản 2, điểm b
- **Dòng:** 216–218
- **Trích:** «b) Sử dụng vật dụng, hình ảnh, biểu tượng, âm nhạc, nhân vật trong phim, nhãn hiệu sản phẩm dành cho trẻ em, học sinh, sinh viên; sử dụng người chưa đủ 18 tuổi hoặc hình ảnh của người chưa đủ 18 tuổi trong quảng cáo rượu, bia.»
- (1) id: Điều 12, khoản 2, điểm b
- (2) chủ thể: ngầm: người quảng cáo
- (3) hành vi: (i) dùng vật dụng/hình ảnh/biểu tượng/âm nhạc/nhân vật phim/nhãn hiệu sản phẩm dành cho trẻ em, học sinh, sinh viên; (ii) dùng người chưa đủ 18 tuổi hoặc hình ảnh của họ trong quảng cáo
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: quảng cáo có một trong các yếu tố trên
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: tuổi **< 18** (nhánh (ii))
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia"; chưa định nghĩa: "trẻ em", "học sinh", "sinh viên"
- (11) liệt kê: sáu thứ liệt kê ở nhánh (i); không nối → đọc ngầm là hoặc
- (12) biểu thức mở: "dành cho" (nhánh (i))
- (13) đa nghĩa: **"dành cho trẻ em, học sinh, sinh viên" gắn vào cả sáu thứ liệt kê hay chỉ "nhãn hiệu sản phẩm"** — khác biệt lớn; "sinh viên" thường đã đủ 18 tuổi nên nhánh (i) và (ii) có phạm vi tuổi khác nhau
- (14) tin cậy: (3) cao «sử dụng người chưa đủ 18 tuổi»; (4) cao; (5) trung bình «dành cho trẻ em, học sinh, sinh viên»; (6)–(7) cao (không có)

### Điều 12, khoản 3 (đoạn dẫn)
- **Dòng:** 219–220
- **Trích:** «3. Không thực hiện quảng cáo trên các phương tiện quảng cáo trong trường hợp sau đây:»
- (1) id: Điều 12, khoản 3, đoạn dẫn
- (2) chủ thể: ngầm: người thực hiện quảng cáo
- (3) hành vi: thực hiện quảng cáo trong các trường hợp ở điểm a–d
- (4) loại: cấm ("Không thực hiện")
- (5) điều kiện: một trong bốn trường hợp a–d
- (6) ngoại lệ: không ở đoạn dẫn (có ở điểm c)
- (7) ưu tiên: không nói
- (8) tham chiếu ra: điểm a–d (nội bộ, giải quyết được)
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "phương tiện quảng cáo"
- (11) liệt kê: "sau đây" — đóng bốn điểm
- (12) biểu thức mở: —
- (13) đa nghĩa: "trên các phương tiện quảng cáo" nhưng điểm a liệt kê cả "sự kiện" và "sản phẩm" — không chỉ là phương tiện
- (14) tin cậy: (3) cao «Không thực hiện quảng cáo»; (4) cao; (5)–(7) cao (không có)

### Điều 12, khoản 3, điểm a
- **Dòng:** 221–222
- **Trích:** «a) Sự kiện, phương tiện quảng cáo, sản phẩm dành cho người chưa đủ 18 tuổi, học sinh, sinh viên, thanh niên, phụ nữ mang thai;»
- (1) id: Điều 12, khoản 3, điểm a
- (2) chủ thể: ngầm: người quảng cáo
- (3) hành vi: quảng cáo trên sự kiện/phương tiện quảng cáo/sản phẩm dành cho nhóm người nêu
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: đối tượng của sự kiện/phương tiện/sản phẩm là một trong năm nhóm
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: tuổi **< 18**
- (10) thuật ngữ: chưa định nghĩa: "thanh niên", "phụ nữ mang thai"
- (11) liệt kê: ba loại vật mang và năm nhóm người; không nối
- (12) biểu thức mở: "dành cho"
- (13) đa nghĩa: "dành cho" gắn vào cả ba (sự kiện, phương tiện quảng cáo, sản phẩm) hay chỉ "sản phẩm"; trùng một phần với điểm 2.a và 2.b
- (14) tin cậy: (3) cao; (4) cao; (5) trung bình «dành cho»; (6)–(7) cao (không có)

### Điều 12, khoản 3, điểm b
- **Dòng:** 223
- **Trích:** «b) Phương tiện giao thông;»
- (1) id: Điều 12, khoản 3, điểm b
- (2) chủ thể: ngầm: người quảng cáo
- (3) hành vi: quảng cáo trên phương tiện giao thông
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: phương tiện quảng cáo là phương tiện giao thông
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "phương tiện giao thông"
- (11) liệt kê: —
- (12) biểu thức mở: "phương tiện giao thông" (mọi loại? bên trong hay bên ngoài xe?)
- (13) đa nghĩa: cụm danh từ, không có động từ riêng
- (14) tin cậy: (3) trung bình; (4) cao (từ đoạn dẫn); (5)–(7) cao (không có)

### Điều 12, khoản 3, điểm c
- **Dòng:** 224–227
- **Trích:** «c) Báo nói, báo hình ngay trước, trong và ngay sau chương trình dành cho trẻ em; trong thời gian từ 18 giờ đến 21 giờ hằng ngày, trừ trường hợp quảng cáo có sẵn trong các chương trình thể thao mua bản quyền tiếp sóng trực tiếp từ nước ngoài và trường hợp khác theo quy định của Chính phủ;»
- (1) id: Điều 12, khoản 3, điểm c
- (2) chủ thể: ngầm: người quảng cáo
- (3) hành vi: quảng cáo trên báo nói, báo hình (i) ngay trước/trong/ngay sau chương trình dành cho trẻ em; (ii) từ 18 giờ đến 21 giờ hằng ngày
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: phương tiện là báo nói hoặc báo hình **và** (thời điểm quanh chương trình trẻ em **hoặc** trong khung 18–21 giờ)
- (6) ngoại lệ: **"trừ trường hợp quảng cáo có sẵn trong các chương trình thể thao mua bản quyền tiếp sóng trực tiếp từ nước ngoài và trường hợp khác theo quy định của Chính phủ"**
- (7) ưu tiên: không có chữ ưu tiên; ngoại lệ chỉ thu hẹp điểm này, không nói gì về Điều 13 khoản 1
- (8) tham chiếu ra: "quy định của Chính phủ" — **văn bản khác, chưa xác định, chưa đọc**
- (9) ngưỡng: khung giờ **18 giờ đến 21 giờ** ("từ … đến …": biên 21 giờ có thuộc khung hay không — không rõ)
- (10) thuật ngữ: chưa định nghĩa: "báo nói", "báo hình", "chương trình dành cho trẻ em", "quảng cáo có sẵn"
- (11) liệt kê: ngoại lệ có **khe mở**: "và trường hợp khác theo quy định của Chính phủ"
- (12) biểu thức mở: "ngay trước", "ngay sau", "dành cho trẻ em", "quảng cáo có sẵn", "trường hợp khác theo quy định của Chính phủ"
- (13) đa nghĩa: (a) ngoại lệ gắn vào cả (i) và (ii) hay chỉ (ii); (b) "ngay trước, trong **và** ngay sau" — và đọc là hoặc; (c) "hằng ngày" nghĩa mọi ngày; (d) ngoại lệ "quảng cáo có sẵn trong chương trình thể thao" có trùng với "quảng cáo trong chương trình thể thao" bị cấm ở Điều 13 khoản 1 không — xem E
- (14) tin cậy: (3) cao «Báo nói, báo hình»; (4) cao; (5) trung bình «ngay trước, trong và ngay sau»; (6) cao «trừ trường hợp»; (7) cao (không có)

### Điều 12, khoản 3, điểm d
- **Dòng:** 228–230
- **Trích:** «d) Phương tiện quảng cáo ngoài trời vi phạm quy định về kích thước, khoảng cách đặt phương tiện quảng cáo tính từ khuôn viên của cơ sở giáo dục, cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi.»
- (1) id: Điều 12, khoản 3, điểm d
- (2) chủ thể: ngầm: người quảng cáo
- (3) hành vi: quảng cáo trên phương tiện quảng cáo ngoài trời vi phạm quy định về kích thước, khoảng cách đặt
- (4) loại: cấm (từ đoạn dẫn). Ranh giới: thực chất là **nghĩa vụ tuân thủ một quy định khác** (kích thước, khoảng cách) — nội dung số của quy định nằm ngoài văn bản
- (5) điều kiện: phương tiện ngoài trời **và** vi phạm quy định về kích thước/khoảng cách tính từ khuôn viên các cơ sở nêu
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: khoản 6 cùng điều (giải quyết được) ủy quyền cho Chính phủ quy định chi tiết điểm này
- (9) ngưỡng: **không có số** — số về kích thước, khoảng cách nằm ở văn bản của Chính phủ
- (10) thuật ngữ: chưa định nghĩa: "phương tiện quảng cáo ngoài trời", "khuôn viên"
- (11) liệt kê: các cơ sở: "cơ sở giáo dục"; "cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi"
- (12) biểu thức mở: "vi phạm quy định về kích thước, khoảng cách" (nội dung do văn bản khác xác định)
- (13) đa nghĩa: "dành cho người chưa đủ 18 tuổi" gắn vào cả "cơ sở giáo dục" hay chỉ cụm sau (giống cấu trúc Điều 10 khoản 3 và Điều 19 khoản 3, nơi "cơ sở giáo dục" là mục riêng)
- (14) tin cậy: (3) cao; (4) trung bình; (5) trung bình «vi phạm quy định»; (6)–(7) cao (không có)

### Điều 12, khoản 4
- **Dòng:** 231
- **Trích:** «4. Quảng cáo phải có cảnh báo để phòng, chống tác hại của rượu, bia.»
- (1) id: Điều 12, khoản 4
- (2) chủ thể: ngầm: người quảng cáo (chủ ngữ ngữ pháp là "Quảng cáo")
- (3) hành vi: quảng cáo có cảnh báo để phòng, chống tác hại
- (4) loại: **nghĩa vụ** ("phải có"). Ranh giới: nghĩa vụ về **hình thức** của quảng cáo (có điều kiện: nếu quảng cáo thì phải có cảnh báo), **không** phải nghĩa vụ phải quảng cáo
- (5) điều kiện: có quảng cáo
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: khoản 6 cùng điều (Chính phủ quy định chi tiết); "tác hại" (Điều 2 khoản 5)
- (9) ngưỡng: —
- (10) thuật ngữ: đã định nghĩa: "tác hại của rượu, bia" (2.5); chưa định nghĩa: "cảnh báo"
- (11) liệt kê: —
- (12) biểu thức mở: "cảnh báo" (nội dung, kích cỡ, vị trí — ủy quyền cho Chính phủ)
- (13) đa nghĩa: phạm vi theo tiêu đề (dưới 5,5 độ) hay mọi quảng cáo rượu, bia
- (14) tin cậy: (3) cao «phải có cảnh báo»; (4) cao «phải»; (5) trung bình; (6)–(7) cao (không có)

### Điều 12, khoản 5
- **Dòng:** 232–235
- **Trích:** «5. Quảng cáo trên báo điện tử, trang thông tin điện tử, phương tiện điện tử, thiết bị đầu cuối và thiết bị viễn thông khác phải có hệ thống công nghệ chặn lọc, phần mềm kiểm soát tuổi của người truy cập để ngăn ngừa người chưa đủ 18 tuổi tiếp cận, truy cập, tìm kiếm thông tin về rượu, bia.»
- (1) id: Điều 12, khoản 5
- (2) chủ thể: **không rõ** — chủ ngữ ngữ pháp là "Quảng cáo"; ai phải lắp hệ thống (người quảng cáo hay chủ nền tảng) không nói
- (3) hành vi: quảng cáo điện tử có hệ thống chặn lọc, phần mềm kiểm soát tuổi để ngăn người chưa đủ 18 tuổi tiếp cận thông tin
- (4) loại: **nghĩa vụ** ("phải có"). Ranh giới: nghĩa vụ hay đặt yêu cầu kỹ thuật cho phương tiện — ai là người chịu nghĩa vụ không rõ
- (5) điều kiện: quảng cáo trên phương tiện điện tử (năm loại nêu)
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: khoản 6 cùng điều
- (9) ngưỡng: tuổi **< 18**
- (10) thuật ngữ: chưa định nghĩa: "báo điện tử", "trang thông tin điện tử", "phương tiện điện tử", "thiết bị đầu cuối"
- (11) liệt kê: năm loại phương tiện; "thiết bị viễn thông khác" làm danh sách **mở**
- (12) biểu thức mở: "hệ thống công nghệ chặn lọc, phần mềm kiểm soát tuổi" (hiệu quả đến đâu), "ngăn ngừa"
- (13) đa nghĩa: "chặn lọc, phần mềm kiểm soát tuổi" là một hay hai thứ; "ngăn ngừa" là yêu cầu kết quả hay chỉ yêu cầu có biện pháp
- (14) tin cậy: (3) trung bình; (4) trung bình; (5) cao «trên báo điện tử»; (6)–(7) cao (không có); chủ thể: **thấp**

### Điều 12, khoản 6
- **Dòng:** 236
- **Trích:** «6. Chính phủ quy định chi tiết điểm d khoản 3, khoản 4 và khoản 5 Điều này.»
- (1) id: Điều 12, khoản 6
- (2) chủ thể: Chính phủ
- (3) hành vi: quy định chi tiết điểm d khoản 3, khoản 4, khoản 5 của Điều 12
- (4) loại: **phân công** (ủy quyền ban hành văn bản chi tiết). Ranh giới: **nghĩa vụ ban hành** (Chính phủ "quy định") hay **thẩm quyền** — chữ không phân biệt
- (5) điều kiện: —
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: điểm d khoản 3, khoản 4, khoản 5 của Điều 12 — nội bộ, giải quyết được; **không** gồm điểm c khoản 3 (có ủy quyền riêng)
- (9) ngưỡng: —
- (10) thuật ngữ: —
- (11) liệt kê: ba mục đích danh
- (12) biểu thức mở: "chi tiết"
- (13) đa nghĩa: khi văn bản của Chính phủ chưa có hoặc có nội dung khác thì các điểm được ủy quyền ở trạng thái nào — văn bản không nói
- (14) tin cậy: (3) cao «Chính phủ quy định chi tiết»; (4) trung bình; (5)–(7) cao (không có)

---

# Điều 13. Quảng cáo rượu từ 5,5 đến dưới 15 độ và bia từ 5,5 độ trở lên

### Điều 13, tiêu đề
- **Dòng:** 239–240
- **Trích:** «Điều 13. Quản lý việc quảng cáo rượu có độ cồn từ 5,5 độ đến dưới 15 độ và bia có độ cồn từ 5,5 độ trở lên»
- (1) id: Điều 13, tiêu đề
- (2) chủ thể: —
- (3) hành vi: nêu đối tượng: rượu 5,5 ≤ độ < 15 và bia độ ≥ 5,5
- (4) loại: chính sách (tiêu đề). Ranh giới: như Điều 12
- (5) điều kiện: (rượu **và** 5,5 ≤ độ cồn < 15) **hoặc** (bia **và** độ cồn ≥ 5,5)
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không ở tiêu đề (đoạn dẫn trỏ Điều 12)
- (9) ngưỡng: rượu: **≥ 5,5 và < 15**; bia: **≥ 5,5** (không có cận trên)
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia", "độ cồn"
- (11) liệt kê: —
- (12) biểu thức mở: —
- (13) đa nghĩa: ba dải độ cồn của rượu (dưới 5,5; 5,5 đến dưới 15; từ 15) khớp với Điều 12 tiêu đề và Điều 5 khoản 7 mà **không chồng và không hở**; với bia chỉ có hai dải (dưới 5,5; từ 5,5), bia từ 15 độ **không** bị cấm riêng
- (14) tin cậy: (3) cao; (4) thấp; (5) cao «từ 5,5 độ đến dưới 15 độ»; (6)–(7) cao (không có)

### Điều 13, đoạn dẫn
- **Dòng:** 242–244
- **Trích:** «Tổ chức, cá nhân thực hiện quảng cáo rượu có độ cồn từ 5,5 độ đến dưới 15 độ và bia có độ cồn từ 5,5 độ trở lên phải tuân thủ quy định tại Điều 12 của Luật này và không quảng cáo trong trường hợp sau đây:»
- (1) id: Điều 13, đoạn dẫn
- (2) chủ thể: tổ chức, cá nhân thực hiện quảng cáo rượu/bia trong dải độ cồn nêu
- (3) hành vi: (i) tuân thủ Điều 12; (ii) không quảng cáo trong các trường hợp ở khoản 1, 2
- (4) loại: **nghĩa vụ** (i) **và cấm** (ii) trong một câu. Ranh giới: (i) vừa là nghĩa vụ vừa là **dẫn chiếu có hiệu lực** (kéo Điều 12 sang dải 5,5 trở lên)
- (5) điều kiện: quảng cáo rượu 5,5–<15 độ hoặc bia ≥ 5,5 độ
- (6) ngoại lệ: không ở đoạn dẫn (có ở khoản 2)
- (7) ưu tiên: không nói
- (8) tham chiếu ra: **Điều 12** — nội bộ, giải quyết được, **có hiệu lực** (áp dụng nội dung Điều 12 cho dải khác)
- (9) ngưỡng: như tiêu đề
- (10) thuật ngữ: đã định nghĩa: "rượu", "bia", "độ cồn"; chưa định nghĩa: "quảng cáo"
- (11) liệt kê: "trường hợp sau đây" — đóng hai khoản
- (12) biểu thức mở: —
- (13) đa nghĩa: "tuân thủ quy định tại Điều 12" — **toàn bộ** Điều 12 (cả khoản 1 và khoản 6) hay chỉ các khoản có nội dung quy phạm (2–5); Điều 12 tự giới hạn "dưới 5,5 độ" — dẫn chiếu này **mở rộng** phạm vi đó
- (14) tin cậy: (3) cao «phải tuân thủ quy định tại Điều 12»; (4) cao (hai loại); (5) cao; (6)–(7) cao (không có)

### Điều 13, khoản 1
- **Dòng:** 246
- **Trích:** «1. Trong các chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao;»
- (1) id: Điều 13, khoản 1
- (2) chủ thể: như đoạn dẫn
- (3) hành vi: quảng cáo trong các chương trình, hoạt động văn hóa/sân khấu/điện ảnh/thể thao
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: quảng cáo xuất hiện trong chương trình hoặc hoạt động thuộc bốn lĩnh vực
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "chương trình", "hoạt động"
- (11) liệt kê: bốn lĩnh vực, không nối
- (12) biểu thức mở: "trong các chương trình, hoạt động"
- (13) đa nghĩa: "chương trình, hoạt động" gắn vào cả bốn lĩnh vực; chương trình phát sóng hay hoạt động trực tiếp, hay cả hai; **không có ngoại lệ nào** — trong khi Điều 12 khoản 3 điểm c cho một ngoại lệ về chương trình thể thao
- (14) tin cậy: (3) cao; (4) cao; (5) trung bình; (6)–(7) cao (không có)

### Điều 13, khoản 2
- **Dòng:** 247–248
- **Trích:** «2. Trên các phương tiện quảng cáo ngoài trời, trừ biển hiệu của cơ sở kinh doanh rượu, bia.»
- (1) id: Điều 13, khoản 2
- (2) chủ thể: như đoạn dẫn
- (3) hành vi: quảng cáo trên phương tiện quảng cáo ngoài trời
- (4) loại: cấm (từ đoạn dẫn)
- (5) điều kiện: phương tiện quảng cáo ngoài trời
- (6) ngoại lệ: **"trừ biển hiệu của cơ sở kinh doanh rượu, bia"**
- (7) ưu tiên: không có chữ ưu tiên; ngoại lệ chỉ thu hẹp khoản này, **không** nói gì về Điều 12 khoản 3 điểm d (mà Điều 13 kéo vào qua đoạn dẫn)
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "biển hiệu", "cơ sở kinh doanh rượu, bia"
- (11) liệt kê: —
- (12) biểu thức mở: "biển hiệu" (không nêu kích thước)
- (13) đa nghĩa: biển hiệu được miễn khỏi khoản 2 nhưng có còn chịu Điều 12 khoản 3 điểm d (kích thước, khoảng cách) không; "cơ sở kinh doanh rượu, bia" gồm cả nhà sản xuất không
- (14) tin cậy: (3) cao; (4) cao; (5) cao; (6) cao «trừ biển hiệu của cơ sở kinh doanh rượu, bia»; (7) cao (không có)

---

# Điều 19. Địa điểm không bán rượu, bia

### Điều 19, tiêu đề
- **Dòng:** 308
- **Trích:** «Điều 19. Địa điểm không bán rượu, bia»
- (1) id: Điều 19, tiêu đề
- (2) chủ thể: không rõ — ngầm: người bán
- (3) hành vi: bán rượu, bia tại các địa điểm liệt kê
- (4) loại: **cấm** — **chỉ nhờ tiêu đề** (giống Điều 10). Ranh giới: cấm so với danh mục địa điểm
- (5) điều kiện: địa điểm thuộc danh mục
- (6) ngoại lệ: không ở tiêu đề (có ở khoản 6)
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không (Điều 33 khoản 3 — ngoài lát cắt — trỏ vào điều này)
- (9) ngưỡng: —
- (10) thuật ngữ: "rượu", "bia"; chưa định nghĩa: "bán"
- (11) liệt kê: sáu khoản, không "gồm/bao gồm" → đóng ngầm
- (12) biểu thức mở: —
- (13) đa nghĩa: chỉ nói "bán"; **không** nói "cung cấp" hay "khuyến mại" (Điều 5 khoản 3 có cả ba) — cho không tại địa điểm này thì sao; **không có khoản "địa điểm công cộng theo quy định của Chính phủ"** như Điều 10 khoản 7
- (14) tin cậy: (3) cao «không bán rượu, bia»; (4) trung bình «Địa điểm không bán»; (5)–(7) cao (không có)

### Điều 19, khoản 1
- **Dòng:** 309
- **Trích:** «1. Cơ sở y tế.»
- (1) id: Điều 19, khoản 1
- (2) chủ thể: không rõ
- (3) hành vi: bán rượu, bia tại cơ sở y tế
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là cơ sở y tế
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ sở y tế"
- (11) liệt kê: —
- (12) biểu thức mở: "cơ sở y tế" (căng-tin trong bệnh viện?)
- (13) đa nghĩa: như Điều 10 khoản 1
- (14) tin cậy: (3) cao (từ tiêu đề); (4) trung bình; (5)–(7) cao

### Điều 19, khoản 2
- **Dòng:** 310
- **Trích:** «2. Cơ sở giáo dục.»
- (1) id: Điều 19, khoản 2
- (2) chủ thể: không rõ
- (3) hành vi: bán rượu, bia tại cơ sở giáo dục
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là cơ sở giáo dục; **không có khung thời gian**
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ sở giáo dục"
- (11) liệt kê: —
- (12) biểu thức mở: —
- (13) đa nghĩa: **Điều 10 khoản 2 có "trong thời gian giảng dạy, học tập, làm việc", khoản này không** — nghĩa là bán bị cấm cả ngoài giờ, hay là sót; chữ viết như vậy
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao «Cơ sở giáo dục.» (không có điều kiện thời gian); (6)–(7) cao (không có)

### Điều 19, khoản 3
- **Dòng:** 312–313
- **Trích:** «3. Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi.»
- (1) id: Điều 19, khoản 3
- (2) chủ thể: không rõ
- (3) hành vi: bán rượu, bia tại cơ sở/khu vực dành cho người chưa đủ 18 tuổi
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: như Điều 10 khoản 3
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: tuổi **< 18**
- (10) thuật ngữ: chưa định nghĩa: "cơ sở", "khu vực"
- (11) liệt kê: bốn chức năng, không nối
- (12) biểu thức mở: "dành cho", "khu vực"
- (13) đa nghĩa: như Điều 10 khoản 3
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao; (6)–(7) cao (không có)

### Điều 19, khoản 4
- **Dòng:** 315–316
- **Trích:** «4. Cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân và cơ sở giam giữ khác.»
- (1) id: Điều 19, khoản 4
- (2) chủ thể: không rõ
- (3) hành vi: bán rượu, bia tại các cơ sở nêu
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm thuộc năm loại cơ sở
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: năm loại cơ sở
- (11) liệt kê: **mở ở cuối** — "cơ sở giam giữ khác"
- (12) biểu thức mở: "cơ sở giam giữ khác"
- (13) đa nghĩa: giống Điều 10 khoản 4; hai khoản giống hệt chữ
- (14) tin cậy: (3) cao; (4) trung bình; (5) cao; (6)–(7) cao (không có)

### Điều 19, khoản 5
- **Dòng:** 318
- **Trích:** «5. Cơ sở bảo trợ xã hội.»
- (1) id: Điều 19, khoản 5
- (2) chủ thể: không rõ
- (3) hành vi: bán rượu, bia tại cơ sở bảo trợ xã hội
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là cơ sở bảo trợ xã hội
- (6) ngoại lệ: không
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ sở bảo trợ xã hội"
- (11) liệt kê: —
- (12) biểu thức mở: —
- (13) đa nghĩa: không phát hiện
- (14) tin cậy: (3) cao; (4) trung bình; (5)–(7) cao

### Điều 19, khoản 6
- **Dòng:** 319–321
- **Trích:** «6. Nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập, trừ địa điểm được phép kinh doanh rượu, bia.»
- (1) id: Điều 19, khoản 6
- (2) chủ thể: không rõ
- (3) hành vi: bán rượu, bia tại nơi làm việc của các cơ quan/tổ chức nêu
- (4) loại: cấm (qua tiêu đề)
- (5) điều kiện: địa điểm là nơi làm việc của một trong năm loại tổ chức; **không có điều kiện "trong thời gian làm việc"** (khác Điều 10 khoản 6)
- (6) ngoại lệ: **"trừ địa điểm được phép kinh doanh rượu, bia"**
- (7) ưu tiên: không nói
- (8) tham chiếu ra: không trích dẫn; "được phép kinh doanh" phụ thuộc cấp phép (Điều 15, ngoài lát cắt)
- (9) ngưỡng: —
- (10) thuật ngữ: chưa định nghĩa: "cơ quan nhà nước", "tổ chức chính trị", "đơn vị sự nghiệp công lập"
- (11) liệt kê: năm loại tổ chức, đóng ngầm
- (12) biểu thức mở: "địa điểm được phép kinh doanh"
- (13) đa nghĩa: cấm bán tại nơi làm việc "trừ địa điểm được phép kinh doanh rượu, bia" — đọc theo chữ thì chỉ còn bị cấm bán ở nơi **không** được phép kinh doanh; phần cấm đó có thể **trùng một phần** với Điều 5 khoản 11 (cấm kinh doanh không phép/không đăng ký) — tôi **không rõ** hai điều có cùng phạm vi hay không; đây là chỗ cần người duyệt đọc
- (14) tin cậy: (3) cao; (4) trung bình; (5) trung bình; (6) cao «trừ địa điểm được phép kinh doanh rượu, bia»; (7) cao (không có)

---

## Phần II — Các mục xuyên điều

> Từ đây trở đi **không còn trích dẫn nguyên văn từng khoản**; mọi nhận định
> trỏ về một khoản đã trích ở Phần I (ghi dạng "5.7" = Điều 5 khoản 7;
> "12.3.c" = Điều 12 khoản 3 điểm c; "10.t", "19.t" = tiêu đề).

### A. Bảng thuật ngữ

**Đã được định nghĩa tại Điều 2**

| Thuật ngữ | Định nghĩa ở | Định nghĩa (trích ngắn) | Dùng ở (trong sáu điều) |
|---|---|---|---|
| Rượu | 2.1 | «đồ uống có cồn thực phẩm» | gần như mọi khoản của 5, 10, 12, 13, 19. **Chỉ rượu (không bia)**: 5.7, 5.11(i), dải rượu của 13 |
| Bia | 2.2 | «đồ uống có cồn thực phẩm» | cùng chỗ với "rượu". **Chỉ bia**: dải bia của 13 |
| Cồn thực phẩm | 2.3 | «hợp chất hữu cơ … ethanol» | chỉ trong 2.1, 2.2, 2.4 (không có ở 5, 10, 12, 13, 19) |
| Độ cồn | 2.4 | «phần trăm thể tích» | 5.7, 5.9, 12 (tiêu đề), 13 (tiêu đề, đoạn dẫn) |
| Tác hại của rượu, bia | 2.5 | «ảnh hưởng, tác động có hại» | 5 (tiêu đề), 12.4 |
| Nghiện rượu, bia | 2.6 | «tình trạng lệ thuộc» | **không dùng** trong sáu điều |
| Sản xuất rượu thủ công | 2.7 | «dụng cụ truyền thống» | **không dùng** trong sáu điều |
| Sản xuất rượu công nghiệp | 2.8 | «máy móc, thiết bị công nghiệp» | **không dùng** trong sáu điều |

**Dùng mà không có định nghĩa trong luật này** (đa số định nghĩa ở luật khác,
tôi **chưa đọc** các luật đó)

| Thuật ngữ | Dùng ở | Ghi chú |
|---|---|---|
| uống | 5.1, 5.2, 5.5, 10, 12.2.a | hành vi trung tâm của Điều 5 và Điều 10; không có định nghĩa |
| bán | 5.3, 5.11, 19 | |
| cung cấp | 5.3, 5.8 | rộng hơn "bán"? văn bản không nói |
| khuyến mại | 5.3, 5.9 | định nghĩa ở pháp luật về khuyến mại (không nêu) |
| quảng cáo | 5.7, 12, 13 | định nghĩa ở pháp luật về quảng cáo (12.1 nhắc, không nêu số hiệu) |
| kinh doanh | 5.9, 5.11, 5.12, 10.6, 13.2, 19.6 | |
| nồng độ cồn | 5.6 | **khác** "độ cồn" 2.4 — một cái của đồ uống, một cái của máu/hơi thở |
| người chưa đủ 18 tuổi | 5.2, 5.3, 5.4, 10.3, 12.2.b, 12.3.a, 12.3.d, 12.5, 19.3 | có ngưỡng số (< 18) |
| trẻ em, học sinh, sinh viên, thanh niên, phụ nữ mang thai | 12.2.a, 12.2.b, 12.3.a, 12.3.c | **không có ngưỡng tuổi** trong văn bản này |
| phương tiện giao thông | 5.6, 12.3.b | loại nào? |
| giấy phép, đăng ký | 5.11 | phụ thuộc Điều 15 (ngoài lát cắt, không được nêu) |
| máy bán hàng tự động | 5.11 | |
| giả, nhập lậu, tàng trữ, vận chuyển | 5.12 | |
| nguyên liệu, phụ gia, chất hỗ trợ chế biến | 5.10 | |
| giờ làm việc, giờ học tập | 5.5 | |
| cán bộ, công chức, viên chức, … lực lượng vũ trang nhân dân | 5.5 | nhiều nhóm chồng lấn |
| cơ sở y tế; cơ sở giáo dục | 10.1, 10.2, 19.1, 19.2, 12.3.d | |
| cơ sở, khu vực chăm sóc … dành cho người chưa đủ 18 tuổi | 10.3, 19.3, 12.3.d | |
| cơ sở cai nghiện, … cơ sở giam giữ khác | 10.4, 19.4 | |
| cơ sở bảo trợ xã hội | 10.5, 19.5 | |
| cơ quan nhà nước, tổ chức chính trị, … đơn vị sự nghiệp công lập | 10.6, 19.6 | |
| địa điểm công cộng | 10.7 | theo quy định của Chính phủ |
| địa điểm được phép kinh doanh rượu, bia | 10.6, 19.6 | phụ thuộc cấp phép |
| phương tiện quảng cáo, phương tiện quảng cáo ngoài trời | 12.3, 13.2 | |
| báo nói, báo hình; báo điện tử, trang thông tin điện tử, … | 12.3.c; 12.5 | |
| chương trình dành cho trẻ em; chương trình thể thao | 12.3.c; 12.3.c, 13.1 | |
| biển hiệu của cơ sở kinh doanh | 13.2 | |
| cảnh báo | 12.4 | nội dung do Chính phủ quy định (12.6) |

---

### B. Từ vựng tình huống đề xuất (S) và tham số mở (P)

> Đây là **bảng đề xuất để người duyệt đọc**. Không có kiểu Lean nào được đề
> xuất. Tên chỉ là nhãn.

**Nguyên tắc chọn**: chỉ liệt kê fact xuất hiện trong **điều kiện áp dụng hoặc
ngoại lệ** của một khoản (xem F1: nó quyết định hai norm có "cùng áp dụng"
không). Hành vi tuân thủ ("quảng cáo **có** cảnh báo") không cần fact.
**Bool** = đúng/sai; **enum k** = một trong k giá trị; "bit" = log₂ của số giá trị.

#### B1. Fact S

| # | Tên đề xuất | Kiểu | Giá trị | Nguồn |
|---|---|---|---|---|
| S01 | loại đồ uống | enum 2 | rượu, bia | 2.1, 2.2; 5.7, 5.11(i), 13 |
| S02 | dải độ cồn | enum 3 | dưới 5,5 · 5,5 đến dưới 15 · từ 15 trở lên | 5.7, 5.9, 12.t, 13.t |
| S03 | người uống chưa đủ 18 tuổi | Bool | — | 5.2 |
| S04 | người nhận chưa đủ 18 tuổi | Bool | — | 5.3 |
| S05 | lao động chưa đủ 18 tuổi | Bool | — | 5.4 |
| S06 | người uống thuộc nhóm ở 5.5 | Bool | — | 5.5 |
| S07 | thời điểm uống so với giờ làm việc/học tập | enum 4 | ngay trước · trong giờ · nghỉ giữa giờ · ngoài | 5.5 |
| S08 | đang điều khiển phương tiện giao thông | Bool | — | 5.6 |
| S09 | có nồng độ cồn trong máu hoặc hơi thở | Bool | — | 5.6 |
| S10 | kinh doanh rượu thiếu giấy phép | Bool | — | 5.11(i) |
| S11 | kinh doanh rượu thiếu đăng ký | Bool | — | 5.11(i) |
| S12 | rượu, bia giả | Bool | — | 5.12 |
| S13 | nhập lậu | Bool | — | 5.12 |
| S14 | địa điểm là cơ sở y tế | Bool | — | 10.1, 19.1 |
| S15 | địa điểm là cơ sở giáo dục | Bool | — | 10.2, 19.2 |
| S16 | địa điểm là cơ sở/khu vực dành cho người chưa đủ 18 tuổi | Bool | — | 10.3, 19.3 |
| S17 | địa điểm là cơ sở cai nghiện/giáo dục bắt buộc/giam giữ | Bool | — | 10.4, 19.4 |
| S18 | địa điểm là cơ sở bảo trợ xã hội | Bool | — | 10.5, 19.5 |
| S19 | địa điểm là nơi làm việc của cơ quan nhà nước/tổ chức chính trị/… | Bool | — | 10.6, 19.6 |
| S20 | địa điểm được phép kinh doanh rượu, bia | Bool | — | 10.6, 19.6 |
| S21 | đang trong thời gian giảng dạy/học tập/làm việc | Bool | — | 10.2 |
| S22 | đang trong thời gian làm việc | Bool | — | 10.6 |
| S23 | quảng cáo trên phương tiện giao thông | Bool | — | 12.3.b |
| S24 | quảng cáo trên báo nói/báo hình | Bool | — | 12.3.c |
| S25 | quảng cáo trên phương tiện ngoài trời | Bool | — | 12.3.d, 13.2 |
| S26 | quảng cáo trên phương tiện điện tử | Bool | — | 12.5 |
| S27 | quảng cáo trong chương trình/hoạt động văn hóa, sân khấu, điện ảnh, thể thao | Bool | — | 13.1 |
| S28 | phương tiện là biển hiệu của cơ sở kinh doanh rượu, bia | Bool | — | 13.2 |
| S29 | quảng cáo ngay trước/trong/sau chương trình dành cho trẻ em | Bool | — | 12.3.c |
| S30 | quảng cáo trong khung 18–21 giờ | Bool | — | 12.3.c |
| S31 | quảng cáo có sẵn trong chương trình thể thao mua bản quyền tiếp sóng trực tiếp từ nước ngoài | Bool | — | 12.3.c |
| S32 | quảng cáo có dùng người/hình ảnh người chưa đủ 18 tuổi | Bool | — | 12.2.b |

Ba **enum** (S01 · S02 · S07) cho 2 × 3 × 4 = **24** tổ hợp; 29 fact còn lại là
**Bool**.

#### B2. Khái niệm mở có thể thành tham số P (mỗi cái một bit)

| # | Tên đề xuất | Nguồn | Vì sao mở |
|---|---|---|---|
| P01 | "ngay trước" (uống) | 5.5 | không nêu khoảng thời gian |
| P02 | "trực tiếp tham gia" | 5.4 | ranh giới trực tiếp/gián tiếp |
| P03 | thông tin "không chính xác, sai sự thật" | 5.8 | cần chuẩn khoa học bên ngoài |
| P04 | "không bảo đảm chất lượng" | 5.10, 5.12 | chuẩn nằm ở luật khác |
| P05 | "không rõ nguồn gốc, xuất xứ" | 5.10, 5.12 | một phán đoán |
| P06 | nguyên liệu "không được phép dùng trong thực phẩm" | 5.10 | danh mục ở luật khác |
| P07 | "các địa điểm công cộng theo quy định của Chính phủ" | 10.7 | danh mục ủy quyền |
| P08 | quảng cáo "nhằm khuyến khích uống" | 12.2.a | ý định |
| P09 | quảng cáo "tạo sự trưởng thành, thành đạt, thân thiện, hấp dẫn về giới tính" | 12.2.a | hiệu quả |
| P10 | quảng cáo "hướng đến" trẻ em, HS, SV, thanh niên, phụ nữ mang thai | 12.2.a | đối tượng nhắm tới |
| P11 | sản phẩm/sự kiện/chương trình "dành cho" trẻ em, HS, SV | 12.2.b, 12.3.a, 12.3.c | "dành cho" |
| P12 | "vi phạm quy định về kích thước, khoảng cách" | 12.3.d | nội dung do Chính phủ quy định (12.6) |
| P13 | "trường hợp khác theo quy định của Chính phủ" (ngoại lệ) | 12.3.c | khe mở ủy quyền |

**13 tham số.** Đây là **ước lượng thô, nhưng một số cái có thể là S thay vì P**
(P04, P05 vừa giống fact vừa giống phán đoán) — là quyết định G6. Ngoài ra
"ngay trước/ngay sau" ở 12.3.c tôi để trong S29 chứ không tách thành P.

#### B3. Cỡ miền

Quy ước: |S| = số giá trị của tất cả fact; |P| = 2 mũ số tham số; mỗi cặp
(s, π) là một điểm phải duyệt. Bộ kiểm hiện tại duyệt **mọi điểm cho mỗi cặp
norm** (đã xác nhận trong `Verify/Conflict.lean`: `cands` sinh toàn bộ tích
rồi mới lọc theo act và `valid`).

**Toàn lát cắt, một S chung** (đúng như hiện tại: `check` nhận một S)

| | Giá trị | Mũ 2 |
|---|---|---|
| \|S\| = 2²⁹ × 24 | 12 884 901 888 | ≈ 2^33,6 |
| \|P\| = 2¹³ | 8 192 | 2^13 |
| \|S\| × \|P\| (một cặp) | 105 553 116 266 496 ≈ 1,06 × 10¹⁴ | ≈ 2^46,6 |
| số norm ước lượng ~50 → ~1 225 cặp | ≈ 1,3 × 10¹⁷ điểm | ≈ 2^56,8 |

**So với trần kế hoạch** (N8: 2^14 toàn cục; ~2^8 mỗi nhóm; đã đo: 2^16 ≈ 50 s,
2^18 thất bại, bằng một vị từ rẻ, **không** phải bằng `check` thật): toàn lát
cắt vượt trần khoảng **2^43** lần.

**Nếu tách theo nhóm act, mỗi nhóm một S riêng** (chỉ dùng các fact của nhóm)

| Nhóm | Norm | \|S\| | \|P\| | Điểm/cặp | Cặp | Tổng điểm |
|---|---|---|---|---|---|---|
| **uống** (5.2, 5.5, 10.1–10.7) | 9 | 2¹¹ × 4 = 2^13 | 2² (P01, P07) | 2^15 = 32 768 | 36 | ≈ 1,2 triệu ≈ 2^20,2 |
| **bán** (5.3, 19.1–19.6) | 7 | 2⁸ = 256 | 1 | 256 | 21 | 5 376 |
| **quảng cáo** (5.7, 12.\*, 13.\*) | ~13 (≈ 21 nếu nhân bản Điều 12 cho dải ≥ 5,5) | 6 × 2¹⁰ = 6 144 | 2⁶ (P08–P13) | ≈ 2^18,6 = 393 216 | 78 (210) | ≈ 3,1 × 10⁷ ≈ 2^24,9 (8,3 × 10⁷ ≈ 2^26,3) |
| các nhóm nhỏ còn lại (5.1, 5.4, 5.6, 5.8–5.13) | mỗi act một norm | nhỏ | nhỏ | nhỏ | ít | không đáng kể |

**Điều gì chi phối**

1. **Một S chung bắt các nhóm không liên quan nhân với nhau.** Fact về địa điểm,
   về người và về quảng cáo không bao giờ xuất hiện cùng một điều kiện, nhưng
   bị tích lại: 2^33,6 so với nhóm lớn nhất 2^13.
2. **Trong nhóm quảng cáo**: 10 fact Bool về phương tiện/hoàn cảnh quảng cáo
   (S23–S32) **cộng** 6 tham số mở (P08–P13). Mỗi khái niệm mở nhân đôi chi phí
   giống một fact Bool.
3. **Trong nhóm uống**: sáu Bool địa điểm (S14–S19) cộng ba fact thời gian/ngoại
   lệ (S20–S22) và bốn giá trị thời điểm (S07).
4. `valid` **không giảm chi phí**: nó lọc sau khi đã liệt kê, và tự nó nằm trong
   trust base.

**Chưa kiểm**: tôi chưa chạy `check` trên bất kỳ norm nào của lát cắt; mọi con
số ở trên là tính tay từ bảng B1, B2.

---

### C. Act đề xuất

> Act là id mờ, hai norm chỉ có thể xung đột khi **cùng chuỗi act**
> (`Conflict` so sánh bằng nhau của chuỗi). Vì vậy **độ mịn của act quyết định
> kết quả**: tách quá mịn → bỏ sót xung đột thật; gộp quá thô → báo xung đột giả.

| Act | Mô tả | Khoản dùng |
|---|---|---|
| `xui_giuc_ep_uong` | xúi giục/kích động/lôi kéo/ép buộc người khác uống | 5.1 |
| `uong_ruou_bia` | uống rượu, bia | 5.2, 5.5, 10.1–10.7 |
| `ban_ruou_bia` | bán rượu, bia | 5.3 (nhánh bán), 19.1–19.6; có thể cả 5.11(ii) |
| `cung_cap_ruou_bia` | cung cấp rượu, bia | 5.3 (nhánh cung cấp) |
| `khuyen_mai_ruou_bia` | khuyến mại rượu, bia | 5.3 (nhánh khuyến mại), 5.9(i) |
| `dung_ruou_bia_lam_qua_khuyen_mai` | dùng rượu, bia làm phương tiện khuyến mại | 5.9(ii) |
| `su_dung_lao_dong_duoi_18_trong_ruou_bia` | sử dụng lao động chưa đủ 18 tuổi trực tiếp sản xuất/mua bán | 5.4 |
| `dieu_khien_phuong_tien_khi_co_nong_do_con` | điều khiển phương tiện giao thông khi có nồng độ cồn | 5.6 |
| `quang_cao_ruou_tu_15_do` | quảng cáo rượu từ 15 độ | 5.7 |
| `cung_cap_thong_tin_suc_khoe_sai` | cung cấp thông tin sai về ảnh hưởng sức khỏe | 5.8 |
| `dung_nguyen_lieu_khong_dat` | dùng nguyên liệu/phụ gia/chất hỗ trợ không được phép hoặc không bảo đảm | 5.10 |
| `kinh_doanh_ruou_khong_phep_hoac_dang_ky` | kinh doanh rượu thiếu giấy phép hoặc đăng ký | 5.11(i) |
| `ban_ruou_bia_bang_may_tu_dong` | bán rượu, bia bằng máy bán hàng tự động | 5.11(ii) |
| `kinh_doanh_tang_tru_van_chuyen_ruou_bia_khong_hop_phap` | kinh doanh/tàng trữ/vận chuyển rượu, bia giả, nhập lậu, … | 5.12 |
| `nhap_lau_ruou_bia` | nhập lậu rượu, bia | 5.12 (nhánh sau dấu chấm phẩy) |
| `hanh_vi_cam_khac_do_luat_dinh` | các hành vi cấm khác do luật định | 5.13 |
| `quang_cao_co_noi_dung_cam` | quảng cáo thể hiện nội dung bị cấm | 12.2.a, 12.2.b |
| `quang_cao_o_noi_khong_duoc_phep` | quảng cáo trên/trong phương tiện, sự kiện, chương trình, thời điểm bị cấm | 12.3.a–d, 13.1, 13.2 |
| `quang_cao_phai_co_canh_bao` | quảng cáo phải có cảnh báo | 12.4 |
| `quang_cao_dien_tu_phai_chan_loc_tuoi` | quảng cáo điện tử phải có hệ thống chặn lọc/kiểm soát tuổi | 12.5 |
| `tuan_thu_quy_dinh_ve_quang_cao` | tuân thủ Luật này và pháp luật về quảng cáo | 12.1, 13 (đoạn dẫn, vế "phải tuân thủ") |
| `chinh_phu_quy_dinh_chi_tiet` | Chính phủ quy định chi tiết/danh mục | 12.6, 10.7, 12.3.c (khe ngoại lệ) |

Điều 2 không có act: định nghĩa là từ vựng (xem F7). Các tiêu đề điều không có
act riêng; chúng mượn act của khoản.

**Những chỗ có thể dùng chung act hoặc không, và vì sao quan trọng**

1. **"bán" / "cung cấp" / "khuyến mại"** (5.3). "Cung cấp" có thể bao "bán" và
   cho không. Nếu coi cùng act: một norm cấm chung, ít norm hơn. Nếu tách: cấm
   riêng từng hành vi. **Hệ quả**: 19 chỉ cấm "bán"; nếu một norm cho phép
   "cung cấp" xuất hiện về sau (ngoài lát cắt) thì xung đột chỉ phát hiện được
   nếu act khớp.
2. **"uống" ở 5.2, 5.5 và 10.\*** — cùng hành vi uống nhưng khác chủ thể và khác
   hoàn cảnh. Cùng một act sẽ cho phép Core so sánh chúng; vì cả ba đều là cấm
   nên **không** có xung đột modality, nhưng nếu một norm "cho phép" xuất hiện
   (xem E3) thì act chung là điều kiện để Core thấy nó.
3. **"quảng cáo"** — độ mịn nguy hiểm nhất. Nếu 12.4 ("quảng cáo phải có cảnh
   báo", nghĩa vụ) và 12.3/13/5.7 (cấm quảng cáo) cùng dùng act "quảng cáo", Core
   sẽ báo **obligation ~ prohibition** ở mọi chỗ hai điều kiện cùng đúng (vd.
   quảng cáo trên phương tiện giao thông): **xung đột giả**, vì 12.4 là yêu cầu
   về **hình thức** của một quảng cáo hợp pháp, không buộc ai phải quảng cáo.
   Bảng trên vì vậy tách `quang_cao_phai_co_canh_bao` khỏi
   `quang_cao_o_noi_khong_duoc_phep`.
4. **`tuan_thu_quy_dinh_ve_quang_cao`** (12.1, 13 dẫn) là nghĩa vụ "tuân thủ"
   chung; nó **không có nội dung riêng**. Nếu có act riêng thì mọi so sánh với
   nó đều vô nghĩa; nếu không mã hóa thì phải ghi lại là **không mã hóa vì chỉ là
   dẫn chiếu** (không được bỏ im lặng).
5. **5.9(i) và 5.9(ii)** — hai hành vi trong một khoản; tách act vì chủ thể và
   đối tượng khác nhau (khuyến mại sản phẩm so với dùng rượu làm quà).
6. **5.11(ii) "bán … bằng máy bán hàng tự động"** — cùng `ban_ruou_bia` với một
   điều kiện phương thức, hay act riêng. Nếu gộp, cần fact "bán bằng máy" (thêm
   S); nếu tách, thêm một act. Có ảnh hưởng đến việc 19 và 5.11(ii) có so sánh
   được với nhau không.
7. **"nhập lậu"** xuất hiện hai lần ở 5.12 (tình trạng sản phẩm; hành vi) — hai
   act hay một.
8. **Nghĩa vụ của cơ quan nhà nước** (`chinh_phu_quy_dinh_chi_tiet`): là hành vi
   của Chính phủ, không phải của người bị điều chỉnh — nếu để chung "act" với
   các hành vi khác thì vô nghĩa; xem F6.

---

### D. Đồ thị tham chiếu

**Tham chiếu tường minh trong chữ của sáu điều**

| Từ | Đến | Kiểu | Trạng thái | Có hiệu lực? |
|---|---|---|---|---|
| 12.6 | 12.3.d | nêu số | giải quyết được (nội bộ) | **ủy quyền** cho Chính phủ quy định chi tiết |
| 12.6 | 12.4 | nêu số | giải quyết được | ủy quyền |
| 12.6 | 12.5 | nêu số | giải quyết được | ủy quyền |
| 13 (đoạn dẫn) | Điều 12 | nêu số | giải quyết được | **có** — áp dụng nội dung Điều 12 cho dải khác |
| 12.1 | "Luật này" | nêu chung | toàn bộ luật (gồm 5.7…) | nghĩa vụ tuân thủ |
| 12.1 | "pháp luật về quảng cáo" | nêu chung | **luật khác, không nêu số hiệu** | nghĩa vụ tuân thủ |
| 12.3.c | "quy định của Chính phủ" | nêu chung | **văn bản khác chưa xác định** | **ngoại lệ** (khe mở) |
| 10.7 | "quy định của Chính phủ" | nêu chung | **văn bản khác chưa xác định** | **danh mục** địa điểm |
| 5.13 | "luật định" | nêu chung | **luật khác không nêu** | nội dung cấm |
| 2.3 | "quy chuẩn kỹ thuật quốc gia" | nêu chung | **văn bản khác không nêu số hiệu** | điều kiện của định nghĩa |

**Không có tham chiếu tường minh bằng số điều từ sáu điều tới điều ngoài lát
cắt.** (Tôi đã tìm các chữ "Điều", "khoản", "điểm" trong sáu điều.)

**Tham chiếu tường minh từ ngoài lát cắt vào trong**

| Từ (ngoài lát cắt) | Đến | Ghi chú |
|---|---|---|
| Điều 33, khoản 3 (dòng 584–588) | Điều 10 và Điều 19 | giao trách nhiệm cho người đứng đầu địa điểm: nhắc nhở, từ chối cung cấp dịch vụ |

**Phụ thuộc ngầm (không được nêu trong chữ — bộ kiểm tham chiếu treo sẽ không
thấy)**

| Từ | Đến (ngoài lát cắt) | Bản chất |
|---|---|---|
| 5.11 | Điều 15 (cấp phép, đăng ký) | "giấy phép", "đăng ký" lấy nghĩa từ đó |
| 5.9 | Điều 11 (khuyến mại dưới 15 độ) | phần bù theo dải độ cồn |
| 5.12 | Điều 20 (xử lý rượu, bia giả, nhập lậu) | hệ quả của hành vi bị cấm |
| 5.4 | Điều 32, khoản 3 | nhắc lại cho cơ sở kinh doanh, có thêm "quảng cáo" |
| 5.6 | Điều 21, khoản 1 | cùng chủ đề (điều khiển phương tiện) |
| 10 ↔ 19 | nhau | cùng danh mục địa điểm, **không trích dẫn lẫn nhau** |
| 5.5 ↔ 10.6 | nhau | chồng phạm vi (nơi làm việc, giờ làm việc), **không trích dẫn lẫn nhau** |
| 5.7 ↔ 12, 13 | nhau | phân dải độ cồn; **không trích dẫn lẫn nhau** (ngoại trừ 13 → 12) |

**Hệ quả cho mô-đun đầu tiên**: nếu chỉ mã hóa sáu điều, **không có** tham chiếu
tường minh nào bị treo theo số điều. Nhưng bốn khe ủy quyền (12.3.c, 10.7, 12.6,
5.13) và các phụ thuộc ngầm ở trên **không** được trường `references` của norm
nhìn thấy nếu người mã hóa không tự ghi chúng.

---

### E. Ứng viên xung đột

> **Mọi dòng dưới đây đều là "ứng viên, chưa kiểm chứng".** Tôi chưa chạy bộ
> kiểm trên bất kỳ norm nào của lát cắt; đây là lập luận từ chữ.

**Quan sát đầu tiên, quan trọng**: trong sáu điều **không có khoản "cho phép"
nào được nêu tường minh**. Chỉ có cấm (Điều 5, 10, 12, 13, 19), nghĩa vụ (12.1,
12.4, 12.5, 13 đoạn dẫn), và các ngoại lệ "trừ …" (10.6, 12.3.c, 13.2, 19.6).
Hai cặp modality xung đột trong Core (obligation~prohibition,
permission~prohibition) vì vậy chỉ có thể phát sinh qua **hai đường**: (a) dùng
chung act cho một nghĩa vụ hình thức và một lệnh cấm (E1); (b) mã hóa một
ngoại lệ thành "cho phép" (E3). Cả hai đều là **quyết định của người mã hóa**,
không phải của văn bản.

#### E-I. Cặp có thể bị Core báo xung đột

| # | Cặp | Lý do | Nhận định | Trạng thái |
|---|---|---|---|---|
| E1 | 12.4 (nghĩa vụ: quảng cáo phải có cảnh báo) với 12.3.b, 12.3.c, 12.3.d, 13.1, 13.2, 5.7 (cấm quảng cáo) | Nếu mọi khoản dùng chung act "quảng cáo": khi quảng cáo nằm trên phương tiện giao thông thì 12.4 (phải có cảnh báo) và 12.3.b (không được quảng cáo) cùng áp dụng với modality khắc nhau | **Xung đột giả**: 12.4 là yêu cầu hình thức của quảng cáo hợp pháp, không buộc ai phải quảng cáo. Biến mất nếu tách act (C, mục 3) | candidate, not verified |
| E2 | 12.1 và 13 đoạn dẫn (nghĩa vụ "phải tuân thủ") với 5.7 (cấm quảng cáo rượu ≥ 15 độ) | 12.1 viết «quảng cáo rượu, bia» không kèm dải độ cồn; nếu áp dụng cả dải ≥ 15 thì "phải tuân thủ Luật này" bao gồm tuân thủ lệnh cấm 5.7 | Không xung đột về logic (tuân thủ lệnh cấm là nhất quán), nhưng **nhập nhằng phạm vi** (xem G1) | candidate, not verified |
| E3 | 10.6 (ngoại lệ «trừ địa điểm được phép kinh doanh rượu, bia») với 5.5 (cấm uống ngay trước/trong giờ làm việc, **không** có ngoại lệ) | Nếu 10.6 được mã hóa thành "**cho phép** uống tại địa điểm được phép kinh doanh" thì permission~prohibition với 5.5 cho nhân viên cơ quan trong giờ làm việc tại căng-tin có phép. Nếu mã hóa là ngoại lệ (thu hẹp phạm vi, theo ADR-0005) thì Core **không** báo | **Căng thẳng pháp lý thật còn đó** dù Core im: một người đọc có thể hiểu 10.6 là cho phép, trong khi 5.5 vẫn cấm. Phụ thuộc quyết định G4 | candidate, not verified |

#### E-II. Cặp trông như xung đột nhưng được giải quyết (hoặc có thể được giải quyết)

| # | Cặp | Lý do trông như xung đột | Vì sao có thể không phải | Trạng thái |
|---|---|---|---|---|
| E4 | 12.3.c (ngoại lệ: «quảng cáo có sẵn trong các chương trình thể thao mua bản quyền tiếp sóng trực tiếp từ nước ngoài») với 13.1 (cấm quảng cáo «Trong các chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao») | Với rượu/bia **từ 5,5 độ** (gồm hầu hết bia), Điều 13 kéo Điều 12 vào **và** thêm lệnh cấm riêng ở 13.1; ngoại lệ ở 12.3.c chỉ thu hẹp 12.3.c, không thu hẹp 13.1 | Có thể là **khác dải độ cồn**: ngoại lệ 12.3.c còn nghĩa với dải dưới 5,5 độ. Với dải từ 5,5 độ, ngoại lệ 12.3.c gần như **bị vô hiệu hóa** bởi 13.1 — trừ khi "quảng cáo có sẵn" khác "quảng cáo trong chương trình". Cần người duyệt | candidate, not verified |
| E5 | 12.3.d (cấm quảng cáo ngoài trời **chỉ khi vi phạm** quy định kích thước/khoảng cách) với 13.2 (cấm quảng cáo ngoài trời, «trừ biển hiệu của cơ sở kinh doanh rượu, bia») | Cùng phương tiện ngoài trời, hai điều kiện cấm khác nhau, một ngoại lệ ở bên này | Cả hai là **cấm**: Core không báo (cùng modality). Câu hỏi thật là biển hiệu được miễn khỏi 13.2 có còn bị 12.3.d (qua dẫn chiếu) không — văn bản không nói | candidate, not verified |
| E6 | 5.7 (cấm quảng cáo rượu ≥ 15 độ) với 13 (quản lý quảng cáo rượu 5,5 đến dưới 15 độ) | Cùng loại sản phẩm, ranh giới tại 15 độ | **Khác điều kiện (dải)**: hai dải rời nhau, khớp tại biên 15. Lưu ý bất đối xứng: **bia** từ 15 độ không bị cấm ở 5.7 (chỉ nói "rượu"), chỉ bị hạn chế theo 13 | candidate, not verified |
| E7 | 10.2 (cấm uống ở cơ sở giáo dục, **trong thời gian** giảng dạy…) với 19.2 (cấm bán ở cơ sở giáo dục, **không** nêu thời gian) | Cùng địa điểm | **Khác act** (uống / bán): không đối nghịch. Bất đối xứng điều kiện thời gian cần xem (G11) | candidate, not verified |
| E8 | 5.2 (người chưa đủ 18 tuổi không uống) và 10.3 (không uống ở cơ sở dành cho người chưa đủ 18 tuổi) | Cùng act "uống", điều kiện chồng nhau | **Cùng modality (cấm)**: trùng lặp, không xung đột | candidate, not verified |
| E9 | 5.5 (cấm uống ngay trước/trong giờ) và 10.2, 10.6 | Cùng act, phạm vi giờ làm việc chồng nhau | **Cùng modality**: trùng lặp. Điểm khác: 10.6 có ngoại lệ, 5.5 không (xem E3) | candidate, not verified |
| E10 | 5.3 (cấm bán cho người chưa đủ 18 tuổi) và 19 (cấm bán tại địa điểm) | Cùng act "bán" | **Cùng modality**; khác điều kiện (người nhận vs nơi chốn) | candidate, not verified |
| E11 | 12.2.b nhánh (i) «dành cho trẻ em, học sinh, sinh viên» và 12.3.a «dành cho người chưa đủ 18 tuổi, học sinh, sinh viên, thanh niên, phụ nữ mang thai» | Chồng một phần nội dung | **Cùng modality**: trùng lặp | candidate, not verified |

---

### F. Khoảng trống so với `Core` hiện tại

Tham chiếu: `LexProof/Core/Norm.lean` — `Modality` (obligation, prohibition,
permission), `Cond` (tt, ff, sit i, param i, not, and, or), `Atoms` (bảng Bool
đọc từ S và P, cộng `valid`), `Norm` (id, modality, act là chuỗi mờ, condition,
exceptions, priority, source, references), `Priority`. `Conflict` đòi: cùng
act, cả hai áp dụng, modality khắc nhau, không có ưu tiên một chiều.

> Phần này **không đề xuất mã**. Với mỗi khoảng trống: chữ trích, cách Core xấp
> xỉ hiện nay, và cái bị mất.

**F1. So sánh số học và ngưỡng**
- Chữ: «từ 15 độ trở lên» (5.7) · «dưới 5,5 độ» (12.t) · «từ 5,5 độ đến dưới 15 độ» (13.t) · «chưa đủ 18 tuổi» (5.2) · «từ 18 giờ đến 21 giờ» (12.3.c)
- Xấp xỉ: `Cond` chỉ đọc Bool từ S. Ngưỡng phải được rời rạc hóa **trước**, thành một enum dải (S02) hoặc nhiều Bool.
- Mất: (a) quan hệ giữa các ngưỡng ("≥ 15" kéo theo "≥ 5,5") không biểu diễn được trong `Cond`; dùng nhiều Bool thì phải dựa vào `valid` để loại tổ hợp vô lý — mà `valid` nằm trong trust base; dùng một enum dải thì phải tin người mã hóa chọn biên đúng; (b) biên đóng/mở (≥ hay >, "đến 21 giờ" có gồm 21 giờ không) chỉ còn là một cái tên fact, hệ thống không kiểm; (c) việc dải ở Điều 5, 12, 13 có phủ kín và không chồng nhau là **khẳng định faithfulness**, không phải định lý — tôi thấy chúng khớp với rượu nhưng bia chỉ có hai dải.

**F2. Chủ thể (ai bị ràng buộc)**
- Chữ: «Người chưa đủ 18 tuổi uống rượu, bia» (5.2) · «Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi» (5.3) · «Sử dụng lao động là người chưa đủ 18 tuổi» (5.4)
- Xấp xỉ: `Norm` không có trường chủ thể. Chủ thể chỉ vào được qua một fact trong điều kiện hoặc qua tên act.
- Mất: (a) ai chịu nghĩa vụ (người bán hay người mua) không được ghi lại; (b) hai norm cùng act nhưng khác chủ thể bị coi như cùng đối tượng; (c) "chưa đủ 18 tuổi" xuất hiện ở **ba vai** (người uống, người nhận, người lao động) thành ba Bool rời không có liên hệ; (d) phản ví dụ không nói được "ai" vi phạm.

**F3. Lượng từ trên địa điểm và người**
- Chữ: «Cơ sở y tế.» (10.1) · «Nơi làm việc của cơ quan nhà nước, tổ chức chính trị» (10.6) · «Các địa điểm công cộng theo quy định của Chính phủ.» (10.7)
- Xấp xỉ: mỗi loại địa điểm là một Bool; "một trong các loại" là OR.
- Mất: (a) không có "địa điểm" như một thực thể có thuộc tính (loại, thời gian, giấy phép) — chỉ có Bool rời, nên S mô tả đúng **một** địa điểm; (b) các loại có thể chồng nhau (cơ sở giáo dục kiêm khu dành cho người chưa đủ 18 tuổi) mà các Bool không tự loại trừ nhau; (c) danh mục **mở** («cơ sở giam giữ khác», 10.7) chỉ biểu diễn được bằng một Bool/tham số bọc kín.

**F4. Thời gian**
- Chữ: «ngay trước, trong giờ làm việc, học tập và nghỉ giữa giờ làm việc, học tập» (5.5) · «trong thời gian giảng dạy, học tập, làm việc» (10.2) · «từ 18 giờ đến 21 giờ hằng ngày» (12.3.c)
- Xấp xỉ: ADR-0006 hoãn thời gian; mỗi khung thành một Bool/enum "đang trong khung".
- Mất: (a) thứ tự và độ dài khoảng ("ngay trước") — không biểu diễn; (b) quan hệ giữa các khung (khung giờ 18–21 so với giờ chương trình trẻ em); (c) lặp "hằng ngày"; (d) ngày hiệu lực: `SourceId.effective` có nhưng không dùng ở Level 1.

**F5. Điều kiện về bên thứ ba và mục đích của nghĩa vụ**
- Chữ: «để ngăn ngừa người chưa đủ 18 tuổi tiếp cận, truy cập, tìm kiếm thông tin về rượu, bia» (12.5)
- Xấp xỉ: nghĩa vụ "phải có hệ thống…" là một obligation; "người chưa đủ 18 tuổi" là một Bool nếu nó vào điều kiện.
- Mất: **mục đích/kết quả** của nghĩa vụ ("ngăn ngừa") — Core chỉ biết "norm này áp dụng khi nào", không biết "nghĩa vụ này được thỏa mãn thế nào" hay "đạt đến mức nào".

**F6. Nghĩa vụ, thẩm quyền của cơ quan nhà nước và ủy quyền chưa hoàn tất**
- Chữ: «Chính phủ quy định chi tiết điểm d khoản 3, khoản 4 và khoản 5 Điều này.» (12.6) · «trường hợp khác theo quy định của Chính phủ» (12.3.c) · «Các địa điểm công cộng theo quy định của Chính phủ.» (10.7)
- Xấp xỉ: "Chính phủ quy định" có thể là một obligation với act riêng (chủ thể chỉ nằm trong tên act). Ngoại lệ mở ở 12.3.c: hoặc `ff` (không có ngoại lệ) hoặc một tham số P.
- Mất: **không có trạng thái "norm chưa hoàn chỉnh vì chờ văn bản khác"**. Nếu mã hóa ngoại lệ mở thành `ff`, hệ thống **lặng lẽ coi như không có ngoại lệ** — đúng điều nguyên tắc fail-closed cấm. Nếu thành tham số P thì kết quả là "xung đột có điều kiện", gần đúng, nhưng không nói rằng nguyên nhân là **một văn bản chưa được đọc**. Tôi cũng **chưa đọc** văn bản của Chính phủ nên không biết nội dung ủy quyền.

**F7. Định nghĩa như norm**
- Chữ: «Rượu là đồ uống có cồn thực phẩm, được sản xuất từ quá trình lên men» (2.1) · «Độ cồn là số đo chỉ hàm lượng cồn thực phẩm» (2.4)
- Xấp xỉ: `Modality` không có "định nghĩa"; `Cond` không có tên/macro. Định nghĩa trở thành **từ vựng của S** (S01, S02), nằm ngoài `Norm`.
- Mất: (a) liên kết vết giữa chữ định nghĩa và chỗ dùng; (b) các định nghĩa **không bảo đảm loại trừ nhau** — 2.1 và 2.2 không nói rượu và bia loại trừ nhau, nhưng enum hai giá trị (S01) **ngầm khẳng định** điều đó; (c) ranh giới độ cồn tối thiểu của "rượu, bia" (2.4) không có.

**F8. Tham chiếu chéo có hiệu lực và tiêu đề như điều kiện phạm vi**
- Chữ: «phải tuân thủ quy định tại Điều 12 của Luật này» (13 đoạn dẫn) · tiêu đề «Quản lý việc quảng cáo rượu, bia có độ cồn dưới 5,5 độ» (12.t)
- Xấp xỉ: `references` chỉ là danh sách chuỗi dành cho kiểm tham chiếu treo, **không có tác dụng ngữ nghĩa**. Không có "điều kiện phạm vi của điều". Cách duy nhất: nhân bản mỗi norm của Điều 12 cho dải từ 5,5 độ, và chép điều kiện dải vào từng norm.
- Mất: (a) liên kết giữa bản gốc và bản sao — sửa Điều 12 thì bản sao không đổi theo; (b) bộ kiểm không biết hai norm là "cùng một quy tắc ở hai dải", nên lệch giữa bản gốc và bản sao là **sai faithfulness vô hình**; (c) số norm gần gấp đôi trong khi chi phí tăng theo bình phương số cặp (B3).

**F9. Một khoản liệt kê nhiều hành vi**
- Chữ: «Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi.» (5.3) · «Kinh doanh, tàng trữ, vận chuyển rượu, bia giả, nhập lậu, không bảo đảm chất lượng, không rõ nguồn gốc, xuất xứ; nhập lậu rượu, bia.» (5.12)
- Xấp xỉ: một `Norm` có **một** act, nên một khoản sinh ra nhiều norm.
- Mất: tính "một khoản" chỉ còn trong chuỗi `source.article`; số norm sinh ra là lựa chọn của người mã hóa và không kiểm được.

**F10. Nghĩa vụ về hình thức của một hành vi khác**
- Chữ: «Quảng cáo phải có cảnh báo để phòng, chống tác hại của rượu, bia.» (12.4)
- Xấp xỉ: obligation với act do người mã hóa đặt; `Conflict` so act **bằng nhau**.
- Mất: Core không phân biệt "phải làm X" với "nếu làm Y thì Y phải có hình thức Z". Chọn act sai → báo xung đột giả (E1); chọn act riêng → Core không thấy mối liên hệ giữa nghĩa vụ hình thức và hành vi quảng cáo.

**F11. Tiêu đề điều mang loại quy phạm**
- Chữ: «Điều 10. Địa điểm không uống rượu, bia» (10.t) · «Điều 19. Địa điểm không bán rượu, bia» (19.t) · «Điều 5. Các hành vi bị nghiêm cấm» (5.t)
- Xấp xỉ: loại "cấm" phải được chép vào từng norm sinh ra từ các khoản (vốn chỉ là cụm danh từ).
- Mất: dấu vết rằng loại "cấm" đến từ **tiêu đề chứ không từ khoản**; `source.article` chỉ ghi được số khoản.

**F12. Dẫn chiếu mở**
- Chữ: «Các hành vi bị nghiêm cấm khác liên quan đến rượu, bia do luật định.» (5.13)
- Xấp xỉ: không có cách biểu diễn "norm có nội dung nằm hoàn toàn ngoài văn bản". Một norm với điều kiện `tt` và một act vô nội dung thì vô hại nhưng cũng vô nghĩa; không mã hóa thì phải **ghi lại là không mã hóa** (không được bỏ im lặng).
- Mất: toàn bộ nội dung.

**F13. Ưu tiên giữa các quy tắc** *(không phải khoảng trống — là phát hiện)*
- Không có chữ nào trong sáu điều nói quy tắc này thắng quy tắc kia. "Trừ" chỉ xuất hiện như ngoại lệ **nội khoản** (10.6, 12.3.c, 13.2, 19.6). `Priority` vì vậy **không được dùng** ở lát cắt này; mọi thu hẹp phạm vi đi qua `exceptions`. Mối lo thật là E4, E5: một ngoại lệ ở điều này có thắng được lệnh cấm ở điều khác hay không — văn bản không nói, và Core không có chỗ để nói thay.

**Ba khoảng trống nghiêm trọng nhất** (xếp theo ảnh hưởng đến độ đúng): **F1** (ngưỡng và thời gian chỉ có dạng Bool, quan hệ giữa chúng dựa vào `valid` thuộc trust base, cộng với cỡ miền ở B3); **F8** (tham chiếu có hiệu lực và phạm vi theo tiêu đề buộc phải nhân bản norm); **F10 cùng F2** (act mờ và không có chủ thể làm nghĩa vụ hình thức dễ bị báo xung đột giả với lệnh cấm). **F6** (ủy quyền chưa hoàn tất) là nghiêm trọng về fail-closed nhưng hẹp hơn: chỉ ba chỗ.

---

### G. Quyết định cần người duyệt

1. **Tiêu đề Điều 12 có giới hạn các khoản không?** Tiêu đề nói «dưới 5,5 độ», khoản 1 nói «quảng cáo rượu, bia» không kèm độ cồn, và Điều 13 buộc dải từ 5,5 độ cũng tuân thủ Điều 12. (a) Điều 12 áp dụng cho **mọi** dải (tiêu đề chỉ là nhãn); (b) Điều 12 chỉ cho dải dưới 5,5 độ và Điều 13 **mở rộng** nó. Quyết định này đổi số norm và đổi ý nghĩa của E2.
2. **Nghĩa vụ hay phân công trách nhiệm?** 12.1, 12.4, 12.5, 13 đoạn dẫn viết «phải»; 12.6 viết «Chính phủ quy định». Mỗi cái là một obligation, hay chỉ ghi nhận là "dẫn chiếu/ủy quyền" và không mã hóa? Ranh giới tôi thấy rõ nhất ở 12.5 (chủ ngữ là "Quảng cáo", không rõ ai chịu nghĩa vụ).
3. **Nghĩa vụ "phải tuân thủ" chung** (12.1, 13 đoạn dẫn): mã hóa (và chịu một norm không có nội dung riêng), hay ghi "không mã hóa vì chỉ là dẫn chiếu" — theo nguyên tắc không bỏ im lặng điều khoản nào.
4. **Ngoại lệ hay cho phép?** 10.6 và 19.6 «trừ địa điểm được phép kinh doanh rượu, bia»; 12.3.c; 13.2. Theo ADR-0005 một ngoại lệ **thu hẹp phạm vi** chứ không tạo quyền. Xác nhận cách này cho cả bốn chỗ — và xử lý E3 (căng thẳng giữa 10.6 và 5.5).
5. **Ngưỡng:** (a) dải độ cồn là **một enum** (S02) hay nhiều Bool + `valid`; (b) biên: ≥ 15 / < 15 và ≥ 5,5 / < 5,5 như tôi đọc; (c) "có nồng độ cồn" ở 5.6 là > 0 hay một ngưỡng; (d) 21 giờ có thuộc khung "từ 18 giờ đến 21 giờ" không; (e) độ cồn tối thiểu để một đồ uống được tính là rượu, bia.
6. **Khái niệm mở:** cái nào thành **tham số P**, cái nào là **fact S**, cái nào gộp. Đặc biệt P04, P05 (chất lượng, nguồn gốc) và P11 ("dành cho"). Mỗi P nhân đôi chi phí (B3).
7. **Độ mịn của act:** (a) "bán", "cung cấp", "khuyến mại" là một act hay ba; (b) "uống" dùng chung giữa 5.2, 5.5, 10; (c) "quảng cáo" chia thế nào để nghĩa vụ hình thức (12.4, 12.5) không xung đột giả với lệnh cấm (E1); (d) 5.11(ii) "bán bằng máy" có chung act "bán".
8. **Chủ thể:** ghi vào fact S, vào tên act, hay bỏ qua? Quyết định này đổi cách đọc phản ví dụ (F2).
9. **"và" trong liệt kê cấm:** 5.5 «… học tập và nghỉ giữa giờ …», 12.3.c «ngay trước, trong và ngay sau …», 5.10 «không bảo đảm chất lượng và không rõ nguồn gốc». Đọc là **hoặc** (bất kỳ cái nào), hay đúng **và** (đồng thời)? Soạn thảo không nhất quán (5.12 dùng dấu phẩy).
10. **Danh sách đóng ngầm:** Điều 10 và Điều 19 là danh mục không có "gồm/bao gồm" và có một khe mở (10.7, «cơ sở giam giữ khác»). Coi là đóng, hay mở?
11. **Bất đối xứng giữa Điều 10 và Điều 19:** 10.2 có khung thời gian còn 19.2 thì không; 10.6 có «trong thời gian làm việc» còn 19.6 thì không; 10.7 không có tương ứng ở Điều 19. Mã hóa **đúng như chữ** (bất đối xứng), hay giả định đối xứng?
12. **Một S chung hay nhiều mô-đun theo nhóm act:** chi phí toàn lát cắt khoảng 2^57 điểm (B3), còn theo nhóm thì nhóm lớn nhất khoảng 2^26. Chấp nhận tách thành nhiều mô-đun `Laws` (xung đột chỉ phát sinh giữa các norm cùng act nên về logic không mất gì, nhưng mỗi mô-đun phải có S riêng), hay giữ một mô-đun và chịu trần?
13. **Điều 2:** định nghĩa chỉ làm từ vựng (S) hay còn ghi lại thành một bản ghi riêng. Và xác nhận **giả định rượu và bia loại trừ nhau** (F7) — văn bản không nói.
14. **Phạm vi lát cắt:** các phụ thuộc ngầm (5.11 → Điều 15; 5.9 ↔ Điều 11; 5.12 → Điều 20; 5.4 ↔ Điều 32.3) có kéo thêm vào lát cắt không, hay để lát cắt 1 nhận các khe đó và ghi rõ là chưa phủ?

---

## Điều tôi không xác minh được

- **Đối chiếu bản trích xuất với PDF** (mục 0): máy chỉ so được ba chế độ đọc
  **cùng một lớp văn bản**; so với ảnh là một AI **đọc ảnh**, không phải so từng
  ký tự. Không có bản Word/HTML chính thức để so thêm.
- **Mọi nhận định về loại, chủ thể, điều kiện, đa nghĩa, độ tin cậy** là suy
  luận của AI. Chỗ tôi ít chắc nhất: ranh giới nghĩa vụ/phân công (12.1, 12.5,
  12.6, 13 đoạn dẫn); ý nghĩa thật của ngoại lệ ở 19.6; hiệu lực của ngoại lệ
  12.3.c với dải từ 5,5 độ (E4).
- **Văn bản của Chính phủ** mà các điều ủy quyền (10.7, 12.3.c, 12.3.d, 12.4,
  12.5 qua 12.6) — **chưa đọc**; tôi không biết nội dung ủy quyền. Có thể là
  Nghị định 24/2020/NĐ-CP (đã thấy tên khi tra tình trạng hiệu lực), nhưng tôi
  **chưa xác minh** nó có điền các khe này hay không.
- **Luật khác được dẫn chiếu** (pháp luật về quảng cáo, khuyến mại, an toàn thực
  phẩm; định nghĩa "trẻ em", "thanh niên"…): **chưa đọc**.
- **Cỡ miền ở B3** là tính tay từ bảng B1, B2; **chưa chạy bộ kiểm** trên bất kỳ
  norm nào. Số liệu 2^16 ≈ 50 giây và 2^18 thất bại đo bằng một vị từ rẻ, không
  phải bằng `check`.
- **Số norm ước lượng (~50)** là con số thô, phụ thuộc quyết định G7.
- **Chưa đối chiếu** với bất kỳ bản của bên xuất bản khác (không phải nguồn chính
  thức).
