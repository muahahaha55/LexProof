# ADR-0014: So cặp theo chỉ số `i < j`; ID trùng là một finding

- **Status**: Accepted
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0001](0001-incompatible-modalities.md), [ADR-0017](0017-wellformedness-validator-first.md), FR8, N8

## Bối cảnh

`cands` hiện liệt kê **cặp có thứ tự**, kể cả cặp một norm với chính nó:

```lean
def cands (ns : List Norm) : List (Cand S P) :=
  ns.flatMap fun n₁ => ns.flatMap fun n₂ => …
```

Hai hệ quả:

1. **Cặp tự-ghép `(n, n)`** chỉ vô hại *vì* `Incompatible` phản xạ-sai. Tính
   đúng đắn đang dựa vào một tính chất của bảng modality, chứ không dựa vào
   không gian tìm kiếm. Nếu sau này hai obligation trái nhau cũng tính là xung
   đột, mọi norm sẽ xung đột với chính nó.
2. **Mỗi cặp bị kiểm hai lần** — `(a, b)` và `(b, a)`. Vì `Conflict` đối xứng
   (cả `Incompatible` và `resolved` đều đối xứng ở bản hiện tại), lần thứ hai
   không cho thêm thông tin, chỉ tốn gấp đôi thời gian.

Ngoài ra, nếu hai norm **trùng `NormId`**, phản ví dụ sẽ nêu một id không phân
biệt được hai norm, làm nó không phát lại được (FR9).

## Quyết định

1. So cặp theo **chỉ số, `i < j`**, trên danh sách norm. Bỏ cặp tự-ghép, mỗi cặp
   đúng một lần.
2. **ID trùng là một finding** do validator phát hiện
   ([ADR-0017](0017-wellformedness-validator-first.md)), không phải `unknown`.

## Hệ quả

**Tốt**
- Chi phí giảm còn ~một nửa: từ `n²` xuống `n(n-1)/2` cặp. Trực tiếp giúp N8.
- Tính đúng đắn không còn ngầm dựa vào tính phản xạ-sai của `Incompatible`, nên
  mở rộng `Incompatible` về sau trở nên an toàn.
- Phản ví dụ luôn nêu hai norm phân biệt được.

**Xấu**
- `mem_cands` và `mem_of_mem_cands` phải chứng minh lại, và bản mới **khó hơn
  hẳn**: hiện `mem_cands` chỉ cần `h₁ : n₁ ∈ ns` và `h₂ : n₂ ∈ ns`; với `i < j`
  thì cần lập luận theo chỉ số, nên phát biểu của **định lý (b)** cũng phải đổi
  (không còn là `∀ n₁ ∈ ns, ∀ n₂ ∈ ns` một cách đơn giản).
- Nếu `Conflict` về sau **không** còn đối xứng (ví dụ sau
  [ADR-0013](0013-directional-priority-and-cycles.md), khi hướng ưu tiên quan
  trọng), thì chỉ xét `i < j` sẽ **bỏ sót**. Phải kiểm lại tính đối xứng trước
  khi áp dụng quyết định này — hai ADR này phải làm cùng nhau.

## Kiểm chứng

Proof (phát biểu lại và chứng minh lại định lý (b)) + Test (ca có ID trùng).

## Trong code

Hiện tại: `cands` trong `LexProof/Verify/Conflict.lean` dùng cặp có thứ tự gồm
cả `(n, n)`; `mem_cands`, `mem_of_mem_cands` viết theo dạng đó. Chưa có kiểm
tra ID trùng.
