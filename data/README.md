# data/ — tài liệu nguồn

Thư mục này giữ văn bản pháp luật **nguyên bản** tải từ nguồn chính thức, và
bản trích xuất văn bản từ chúng.

Quy ước:

- `data/raw/` — **không bao giờ sửa**. Đây là bản tải về nguyên trạng, dùng để
  đối chiếu và để tính lại hash.
- `data/extracted/` — bản trích xuất văn bản, là **tạo tác phái sinh**. Có thể
  tạo lại từ `raw/` bằng lệnh ghi trong bảng. Không phải nguồn chính thức.

Ngày tải: **2026-10-23** (UTC).

---

## Luật Phòng, chống tác hại của rượu, bia số 44/2019/QH14

### data/raw/congbao-559-560-44-2019-QH14.pdf — **bản dùng chính**

| Mục | Giá trị |
|---|---|
| Nguồn | Công báo (Văn phòng Chính phủ), Số 559 + 560 ngày 17-7-2019 |
| URL | `https://congbaocdn.chinhphu.vn/CongBaoCP/VanBan/2019/6/29251/27285-1-2019559-56044-2019-qh14.pdf` |
| Ngày tải | 2026-10-23 |
| SHA-256 | `5378e35e7b06245a7503eaf7947e83f4bb21a27ae6caa91c2716da28efdfa8d1` |
| Kích thước | 438 100 byte |
| Định dạng | PDF, **17 trang**, **có lớp văn bản** (font nhúng TimesNewRomanPSMT) |
| Trích từ PDF? | Có — xem `data/extracted/` |

### data/raw/44.signed.pdf — bản ký số, giữ để đối chiếu

| Mục | Giá trị |
|---|---|
| Nguồn | Cổng TTĐT Chính phủ (`vanban.chinhphu.vn`, docid 197311) |
| URL | `https://datafiles.chinhphu.vn/cpp/files/vbpq/2019/07/44.signed.pdf` |
| Ngày tải | 2026-10-23 |
| SHA-256 | `32474ddfb5594840f5a56ec8b242ad75f85c54d5d2a94f937aabe28b12f35e07` |
| Kích thước | 932 027 byte |
| Định dạng | PDF, 14 trang, **ảnh quét (CCITT), KHÔNG có lớp văn bản** |
| Trích từ PDF? | **Không trích được** — `pdftotext` chỉ trả về 188 ký tự siêu dữ liệu chữ ký số. Muốn dùng bản này phải OCR, và OCR tiếng Việt rất dễ sai dấu. Vì vậy **không dùng** bản này làm nguồn văn bản |

### data/extracted/44-2019-QH14.txt — bản trích xuất

| Mục | Giá trị |
|---|---|
| Sinh ra từ | `data/raw/congbao-559-560-44-2019-QH14.pdf` |
| Lệnh | `pdftotext -enc UTF-8 -layout data/raw/congbao-559-560-44-2019-QH14.pdf data/extracted/44-2019-QH14.txt` |
| Công cụ | `pdftotext` (Xpdf/poppler) **version 4.00** |
| SHA-256 | `e0ca5a521ff91a604523bea006c082e38655855466f7bb2379414d36bf199752` |
| Kích thước | 43 702 byte / 32 937 ký tự Unicode |
| Mã hóa | UTF-8, chuẩn hóa **NFC**, không có dấu tổ hợp rời |

**Chất lượng trích xuất — đã kiểm:**

- **Không** có ký tự thay thế `U+FFFD`, không có mojibake.
- Dấu tiếng Việt đọc đúng trên mẫu kiểm (`nghiêm cấm`, `độ cồn`, `trẻ em`,
  `phụ nữ mang thai`).
- **Rủi ro còn lại**: đây là trích xuất từ PDF, không phải bản Word/HTML chính
  thức. PDF này *có* lớp văn bản nên rủi ro sai dấu thấp hơn hẳn OCR, nhưng
  **chưa đối chiếu từng chữ** với bản in. Trước khi một điều khoản được mã hóa
  vào `LexProof/Laws/`, **người duyệt phải đọc lại điều đó trên PDF gốc**.
- **Tạo tác đã biết**: dòng chạy trang của Công báo
  (`CÔNG BÁO/Số 559 + 560/Ngày 17-7-2019`) xen vào giữa nội dung ở **17 chỗ**,
  đúng chỗ sang trang. Các dòng này **không** thuộc văn bản luật và phải được
  bỏ khi phân đoạn. Không có tiêu đề `Điều N.` nào bị cắt ngang.

**Không tìm được bản Word/HTML chính thức.** Trang `congbao.chinhphu.vn` có
phát hành `.doc` cho một số luật, nhưng tôi không tìm được trang chi tiết của
luật này; `vbpl.vn` là ứng dụng JavaScript nên công cụ của tôi không đọc được.
Vì vậy phải dùng PDF, đúng theo thứ tự ưu tiên đã nêu (HTML > Word > PDF).

---

## Đối chiếu cấu trúc (STEP 3)

Đếm từ `data/extracted/44-2019-QH14.txt`:

| Hạng mục | Kỳ vọng (nguồn thứ cấp) | Đếm được | Kết quả |
|---|---|---|---|
| Số chương | 7 | **7** (I–VII) | **Khớp** |
| Số điều | 36 | **36** | **Khớp** |
| Dãy số điều | 1–36 liên tục | 1, 2, 3, …, 36 | **Khớp**, không thiếu |
| Số điều trùng lặp | 0 | **0** | **Khớp** |
| Số điều ngoài 1–36 | 0 | **0** | **Khớp** |
| Tiêu đề điều bị cắt qua trang | — | **0** | Không có |

Ngày hiệu lực ghi tại Điều 36 khoản 1: **01/01/2020** — khớp kỳ vọng.

Biên chương (theo dòng trong bản trích xuất):

| Chương | Tên | Các điều |
|---|---|---|
| I | Những quy định chung | 1–5 |
| II | Biện pháp giảm mức tiêu thụ rượu, bia | 6–14 |
| III | Biện pháp quản lý việc cung cấp rượu, bia | 15–20 |
| IV | Biện pháp giảm tác hại của rượu, bia | 21–25 |
| V | Điều kiện bảo đảm cho hoạt động phòng, chống tác hại của rượu, bia | 26–28 |
| VI | Quản lý nhà nước và trách nhiệm của cơ quan, tổ chức, cá nhân | 29–34 |
| VII | Điều khoản thi hành | 35–36 |

---

## Tình trạng hiệu lực (STEP 1) — tóm tắt

Kết luận chi tiết và các URL nguồn nằm trong
[`../docs/corpus-triage.md`](../docs/corpus-triage.md) mục 1. Tóm tắt:

- Luật ban hành 14/6/2019, hiệu lực **01/01/2020**.
- **Không tìm thấy** luật nào sửa đổi, thay thế hay bãi bỏ phần nội dung của
  Luật 44/2019.
- **Điều 35 khoản 1** của chính luật này sửa Luật Giao thông đường bộ
  23/2008/QH12; luật đó **đã bị bãi bỏ** bởi Luật 36/2024/QH15 (Điều 88 khoản 3)
  từ 01/01/2025, nên khoản sửa đổi đó đã **hết đối tượng**.
- **Chưa xác minh được** trường "tình trạng hiệu lực" trên `vbpl.vn` (trang là
  ứng dụng JavaScript, không đọc được bằng công cụ hiện có).
