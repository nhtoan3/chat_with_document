# User Stories & Tiêu chí chấp nhận — "Chat với tài liệu" (MVP)

> **Mã tài liệu:** US-CWD-001 · **Phiên bản:** 0.2 (`Draft` — rút gọn phạm vi MVP, xem §2) · **Ngày:** 2026-10-26 · **Tác giả:** Huy Toan (PO / BA)
> **Nguồn:**
> - `docs/requirements/BRD.md` (BRD-CWD-001 v0.1)
> - `docs/requirements/PRD.md` (PRD-CWD-001 v0.1)
>
> **Tham chiếu thiết kế:**
> - `docs/design/UseCase_ChatWithDocument.drawio`
> - `docs/design/Blueprint_Design.md`
> - `docs/design/html_design/`

---

## 1. Quy ước

| Mục | Quy ước |
|---|---|
| Cú pháp story | **Là** [vai trò], **tôi muốn** [hành động], **để** [giá trị nhận được] |
| Cú pháp AC | **Cho trước** [ngữ cảnh] · **Khi** [hành động] · **Thì** [kết quả quan sát được] (Given–When–Then) |
| ID story | `US-xxx`. US-001..022 giữ nguyên theo PRD; US-023..025 là story **bổ sung**, tách ra từ use case / edge case của PRD |
| ID AC | `AC-US-xxx-n`. Những AC đã có trong PRD giữ nguyên số; AC mới được đánh số tiếp theo |
| Ưu tiên | **P0** = bắt buộc để ra mắt · **P1** = nên có · **P2** = có thì tốt |
| Ước lượng | Story point theo dãy Fibonacci (1, 2, 3, 5, 8, 13). Đây là **ước lượng sơ bộ của PO**; đội phát triển cần ước lượng lại khi refinement |
| Giá trị ⚑ | Giá trị đề xuất trong PRD, chờ quản lý xác nhận (OQ-021). Nếu giá trị thay đổi, chỉ cần cập nhật con số trong AC |
| Trạng thái | `Ready`: đủ điều kiện đưa vào sprint · `Blocked (OQ-xxx)`: chờ quyết định · `Proposed`: chờ PO / quản lý duyệt phạm vi |

**Vai trò (persona):**

- **Chuyên viên BD** (PER-01): vai trò `Member` trong hệ thống.
- **Quản trị viên** (PER-03): vai trò `Admin`; làm được mọi việc của Member.
- **Quản lý** (PER-02): xem số liệu; cần được cấp vai trò Admin theo BRU-006.

---

## 2. Tổng quan backlog

> **v0.2 — rút gọn phạm vi MVP:** để go-live ngày 14/12/2026, backlog được giảm **từ 96 SP xuống 40 SP**.
>
> - **Giữ:** story làm như AC hiện có.
> - **Đơn giản hóa:** story vẫn làm nhưng bỏ hoặc thay một số AC (xem §2.1).
> - **Hoãn (GĐ2):** chuyển sang giai đoạn 2; nội dung story và AC giữ nguyên để làm sau.
>
> Đánh đổi chính: không còn hỏi nối tiếp; đo lường bằng truy vấn SQL và khảo sát thay vì dashboard. Thiết kế kỹ thuật tương ứng: SAD "Phạm vi kiến trúc cho MVP", ADR-010..012.

| ID | Story (tóm tắt) | Epic | Ưu tiên | SP gốc | Phạm vi MVP v0.2 | SP MVP | Trạng thái | Màn hình |
|---|---|---|---|---|---|---|---|---|
| US-001 | Đăng nhập bằng tài khoản được cấp | EP-01 | P0 | 5 | Đơn giản hóa | 2 | Blocked (OQ-014) | 01 |
| US-002 | Chỉ người được cấp quyền xem được tài liệu | EP-01 | P0 | 3 | Đơn giản hóa | 1 | Blocked (OQ-008) | 03 |
| US-003 | Hội thoại chỉ chủ sở hữu xem được | EP-01 | P0 | 2 | Đơn giản hóa | 1 | Ready | 04 |
| US-004 | Admin quản lý tài khoản và vai trò | EP-01 | P1 | 5 | **Hoãn (GĐ2)** — tạo tài khoản bằng script | 0 | Deferred | 06 |
| US-023 | Đăng xuất *(bổ sung)* | EP-01 | P0 | 1 | Giữ | 1 | Ready | Mọi màn hình |
| US-005 | Tải lên một hoặc nhiều PDF | EP-02 | P0 | 5 | Đơn giản hóa | 3 | Ready | 03 |
| US-006 | Xem trạng thái xử lý từng tài liệu | EP-02 | P0 | 3 | Giữ (gộp danh sách cơ bản của US-009) | 3 | Ready | 03 |
| US-007 | Được báo rõ khi file không xử lý được | EP-02 | P0 | 3 | Đơn giản hóa | 2 | Ready | 03 |
| US-008 | Mọi tài liệu Sẵn sàng đều là nguồn trả lời | EP-02 | P0 | 5 | Đơn giản hóa (chỉ tìm kiếm vector) | 3 | Ready | 04 |
| US-009 | Xem danh sách tài liệu | EP-02 | P1 | 2 | **Gộp vào US-006**; bỏ tab / tìm kiếm | 0 | Merged | 03 |
| US-010 | Admin gỡ tài liệu lỗi thời | EP-02 | P1 | 3 | Đơn giản hóa (xóa ngay) | 2 | Proposed (OQ-013) | 03 |
| US-024 | Xử lý trùng tên tệp khi tải lên *(bổ sung)* | EP-02 | P1 | 3 | **Hoãn (GĐ2)** — trùng tên thì từ chối (ERR-14) | 0 | Deferred | 03 |
| US-011 | Hỏi bằng ngôn ngữ tự nhiên, trả lời từ tài liệu | EP-03 | P0 | 8 | Đơn giản hóa | 6 | Ready | 04 |
| US-012 | Câu trả lời tổng hợp từ nhiều tài liệu | EP-03 | P0 | 5 | Đơn giản hóa (chỉ tinh chỉnh theo golden set) | 2 | Ready | 04 |
| US-013 | Trích dẫn tên tài liệu và số trang | EP-03 | P0 | 5 | Giữ | 5 | Proposed (OQ-013) | 04 |
| US-014 | Báo rõ khi không tìm thấy thông tin | EP-03 | P0 | 5 | Đơn giản hóa | 3 | Proposed (OQ-013) | 04 |
| US-015 | Hỏi và nhận trả lời bằng tiếng Việt / tiếng Anh | EP-03 | P0 | 3 | Đơn giản hóa | 1 | Blocked (OQ-010) | 04 |
| US-016 | Câu trả lời hiện dần khi đang tạo | EP-03 | P1 | 5 | Đơn giản hóa | 3 | Ready | 04 |
| US-025 | Dừng tạo câu trả lời *(bổ sung)* | EP-03 | P1 | 2 | **Hoãn (GĐ2)** | 0 | Deferred | 04 |
| US-017 | Mở đúng trang PDF gốc từ trích dẫn | EP-03 | P1 | 5 | Đơn giản hóa (tab mới tại `#page=N`) | 2 | Ready | 04 |
| US-018 | Đánh giá câu trả lời | EP-03 | P1 | 2 | **Hoãn (GĐ2)** — khảo sát cuối pilot | 0 | Deferred | 04 |
| US-019 | Hỏi câu nối tiếp và bắt đầu hội thoại mới | EP-04 | P1 | 5 | **Hoãn (GĐ2)** — mỗi câu hỏi độc lập | 0 | Deferred | 02, 04 |
| US-020 | Xem lại lịch sử hội thoại | EP-04 | P2 | 3 | **Hoãn (GĐ2)** | 0 | Deferred | 05 |
| US-021 | Ghi nhận số liệu sử dụng | EP-05 | P1 | 3 | **Hoãn (GĐ2)** — truy vấn SQL trên `messages` | 0 | Deferred | — |
| US-022 | Bảng số liệu sử dụng cho Admin / Quản lý | EP-05 | P2 | 5 | **Hoãn (GĐ2)** | 0 | Deferred | 07 |

**Tổng:**

| Phạm vi | Số story | SP gốc | SP MVP v0.2 |
|---|---|---|---|
| Giữ / Đơn giản hóa (MVP) | 16 | 66 | **40** |
| Gộp | 1 (US-009) | 2 | 0 |
| Hoãn sang giai đoạn 2 | 8 (US-004, 018, 019, 020, 021, 022, 024, 025) | 28 | 0 |
| **Cộng** | **25** | **96** | **40** |

### 2.1 AC thay đổi trong MVP v0.2

Mọi AC không có trong bảng dưới đây **giữ nguyên**. Story bị hoãn không áp dụng AC nào trong MVP.

| Story | AC bỏ trong MVP | AC thay đổi / thay thế |
|---|---|---|
| US-001 | AC-US-001-6 (chỉ áp dụng khi dùng SSO), AC-US-001-7 (giữ bản nháp sau khi phiên hết hạn) | — |
| US-002 | AC-US-002-4 (đăng xuất ngay khi bị vô hiệu hóa — không có màn hình quản trị) | — |
| US-003 | AC-US-003-4 (danh sách lịch sử / "Gần đây") | — |
| US-005 | — | Bỏ `Idempotency-Key`; tệp trùng tên với tài liệu đang có bị từ chối với ERR-14 |
| US-006 | — | Danh sách tài liệu hiển thị tên, số trang, người tải, ngày tải, trạng thái (lấy từ AC-US-009-1); không có tab và tìm kiếm |
| US-007 | AC-US-007-6 (nút Thử lại sau 3 lần retry) | Lỗi tạm thời: người dùng gỡ và tải lại tệp |
| US-008 | — | Truy xuất chỉ bằng vector; AC-US-008-2 vẫn đo trên golden set |
| US-010 | AC-US-010-4 (trích dẫn hiển thị "Tài liệu đã bị gỡ"), AC-US-010-5 (job xóa sau 30 ngày) | Gỡ = xóa ngay PDF, chunk và vector; trích dẫn cũ tới tài liệu đã xóa không mở được |
| US-011 | AC-US-011-9 (rate limit) | AC-US-011-8: timeout 30 s + retry của SDK, không có circuit breaker |
| US-014 | AC-US-014-5 chuyển thành **kiểm thử thủ công** (≥ 5 ca prompt injection) | — |
| US-015 | AC-US-015-2 (câu hỏi tiếng Anh), AC-US-015-3 (câu không dấu) | MVP chỉ cam kết tiếng Việt; câu trả lời theo ngôn ngữ câu hỏi nhờ prompt, không kiểm thử riêng |
| US-016 | AC-US-016-5 (giữ phần đã nhận khi mất mạng) | Mất mạng giữa chừng → hiển thị lỗi kèm nút "Hỏi lại" |
| US-017 | AC-US-017-1 (panel bên phải, tô sáng), AC-US-017-2, 3, 5, 6 | Bấm trích dẫn → mở PDF ở **tab mới tại đúng trang** (`#page=N`) |

> Phạm vi MVP v0.2 gồm 16 story trên. Story bị hoãn được đưa vào backlog giai đoạn 2 nếu đánh giá MVP (BO-003) cho kết quả tích cực.

---

## 3. Tiêu chí chấp nhận chung

Các tiêu chí dưới đây áp dụng cho **mọi** story. Không cần lặp lại trong từng story.

| ID | Tiêu chí | Nguồn |
|---|---|---|
| AC-G-01 | Mọi chức năng (trừ trang đăng nhập) chỉ dùng được sau khi đăng nhập. Phiên hết hạn thì chuyển về trang đăng nhập, và sau khi đăng nhập lại người dùng quay về màn hình trước đó | FR-001, EC-11 |
| AC-G-02 | Mọi thông báo lỗi dùng thông điệp tiếng Việt trong danh mục ERR-01..ERR-20, kèm hành động tiếp theo nếu có; không hiển thị lỗi kỹ thuật thô | Blueprint §3.5.4, UXC-05 |
| AC-G-03 | Mọi thao tác bất đồng bộ hiển thị trạng thái đang tải trong ≤ 300 ms | UXS-07 |
| AC-G-04 | Mọi chức năng P0 thao tác được hoàn toàn bằng bàn phím; độ tương phản đạt WCAG 2.1 AA; `axe-core` không báo lỗi mức serious / critical | NFR-023 |
| AC-G-05 | Giao diện dùng được ở độ rộng ≥ 1280 px (bố cục đầy đủ) và 768–1279 px (menu / panel thành ngăn trượt), không có thanh cuộn ngang | UI-09 |
| AC-G-06 | Sự kiện telemetry (nếu story có) **không** chứa nội dung câu hỏi, câu trả lời hay tài liệu | PRD §6.2 |
| AC-G-07 | Mọi thao tác nhạy cảm (đăng nhập, tải lên, gỡ tài liệu, quản lý tài khoản) được ghi vào audit log | NFR-014 |

---

## 4. Epic EP-01 — Truy cập & phân quyền

### US-001 — Đăng nhập bằng tài khoản được cấp

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 5 | FR-001, BR-013, SN-006, NFR-015 | UC-01 | Blocked (OQ-014: SSO hay tài khoản nội bộ) |

> **Là** Chuyên viên BD, **tôi muốn** đăng nhập bằng tài khoản được cấp, **để** chỉ người trong đội mới xem được tài liệu dự án.

**Tiêu chí chấp nhận**

- **AC-US-001-1:** **Cho trước** người dùng chưa đăng nhập · **Khi** truy cập bất kỳ URL nào của ứng dụng · **Thì** hệ thống chuyển tới trang đăng nhập và không trả về dữ liệu tài liệu hay hội thoại nào.
- **AC-US-001-2:** **Cho trước** người dùng nhập sai thông tin đăng nhập 5 lần liên tiếp ⚑ · **Khi** thử lần thứ 6 · **Thì** tài khoản bị tạm khóa 15 phút ⚑, ô nhập bị vô hiệu hóa, và người dùng thấy thông báo "Tài khoản tạm khóa 15 phút do đăng nhập sai nhiều lần" (ERR-05).
- **AC-US-001-3:** **Cho trước** tài khoản hợp lệ, đang hoạt động · **Khi** người dùng đăng nhập thành công (SSO hoặc email + mật khẩu) · **Thì** người dùng vào màn hình Hỏi đáp, và tên cùng vai trò hiển thị ở thanh trên cùng.
- **AC-US-001-4:** **Cho trước** người dùng nhập sai mật khẩu lần thứ n (n < 5) · **Khi** gửi form · **Thì** hiển thị "Email hoặc mật khẩu không đúng" kèm số lần thử còn lại, và **không** tiết lộ email có tồn tại hay không.
- **AC-US-001-5:** **Cho trước** email sai định dạng hoặc ô mật khẩu để trống · **Khi** gửi form · **Thì** thông báo lỗi hiển thị ngay dưới ô tương ứng và con trỏ được đưa về ô lỗi đầu tiên.
- **AC-US-001-6:** **Cho trước** người dùng đăng nhập SSO thành công tại IdP nhưng chưa được cấp quyền trong hệ thống · **Khi** quay về ứng dụng · **Thì** hiển thị "Tài khoản tổ chức của bạn chưa được cấp quyền dùng công cụ này" và không tạo phiên.
- **AC-US-001-7:** **Cho trước** người dùng đang soạn câu hỏi thì phiên hết hạn · **Khi** đăng nhập lại · **Thì** người dùng quay về màn hình Hỏi đáp và nội dung đang soạn vẫn còn (EC-11).
- **AC-US-001-8:** **Cho trước** phiên đăng nhập không có hoạt động trong 8 giờ ⚑ · **Khi** người dùng thao tác tiếp · **Thì** hệ thống yêu cầu đăng nhập lại.

**Ghi chú:**

- Mật khẩu tối thiểu 12 ký tự, lưu dạng băm Argon2id (NFR-015).
- Nếu OQ-014 chọn chỉ dùng SSO, bỏ AC-US-001-2, AC-US-001-4 và AC-US-001-5.

---

### US-002 — Chỉ người được cấp quyền xem được tài liệu

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 3 | FR-002, BR-013, NFR-012 | — | Blocked (OQ-008) |

> **Là** Quản trị viên, **tôi muốn** chỉ người dùng được cấp quyền mới xem được bộ tài liệu, **để** bảo vệ thông tin kinh doanh.

**Tiêu chí chấp nhận**

- **AC-US-002-1:** **Cho trước** một tài khoản đã bị vô hiệu hóa · **Khi** người đó gọi trực tiếp đường dẫn tải hoặc xem tài liệu · **Thì** hệ thống từ chối (HTTP 401/403) và không trả về nội dung.
- **AC-US-002-2:** **Cho trước** người dùng có vai trò Member hoặc Admin · **Khi** mở màn hình Tài liệu · **Thì** thấy được danh sách tài liệu và mở được nội dung PDF.
- **AC-US-002-3:** **Cho trước** một đường dẫn xem PDF đã được cấp · **Khi** sử dụng lại đường dẫn sau 5 phút · **Thì** đường dẫn hết hạn và không tải được tệp.
- **AC-US-002-4:** **Cho trước** Admin vừa vô hiệu hóa tài khoản X trong lúc X đang đăng nhập · **Khi** X thực hiện thao tác tiếp theo · **Thì** X bị đăng xuất ngay lập tức.

---

### US-003 — Hội thoại chỉ chủ sở hữu xem được

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 2 | FR-003, BR-013 | UC-18 | Ready (mặc định theo ASM-002; xem lại nếu OQ-009 thay đổi) |

> **Là** Chuyên viên BD, **tôi muốn** hội thoại của tôi chỉ mình tôi xem được, **để** thoải mái đặt câu hỏi.

**Tiêu chí chấp nhận**

- **AC-US-003-1:** **Cho trước** người dùng A có hội thoại H · **Khi** người dùng B (Member) truy cập H qua đường dẫn trực tiếp · **Thì** hệ thống từ chối truy cập và không hiển thị nội dung H.
- **AC-US-003-2:** **Cho trước** người dùng B truy cập một hội thoại không thuộc về mình · **Khi** hệ thống từ chối · **Thì** phản hồi là "Không tìm thấy nội dung" (404), không tiết lộ hội thoại đó có tồn tại.
- **AC-US-003-3:** **Cho trước** người dùng có vai trò Admin · **Khi** truy cập hội thoại của người khác · **Thì** cũng bị từ chối (theo ma trận BRU-006, Admin không xem được hội thoại của người khác).
- **AC-US-003-4:** **Cho trước** người dùng mở danh sách lịch sử hoặc mục "Gần đây" · **Khi** danh sách hiển thị · **Thì** chỉ có hội thoại của chính người đó.

---

### US-004 — Admin quản lý tài khoản và vai trò · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 5 | FR-004, BRU-006 | UC-03 | Ready |

> **Là** Quản trị viên, **tôi muốn** thêm, vô hiệu hóa tài khoản và gán vai trò, **để** kiểm soát ai được truy cập.

**Tiêu chí chấp nhận**

- **AC-US-004-1:** **Cho trước** Admin mở màn hình Người dùng · **Khi** thêm người dùng với họ tên, email hợp lệ và vai trò · **Thì** tài khoản mới xuất hiện trong danh sách với trạng thái "Hoạt động", và thao tác được ghi audit log.
- **AC-US-004-2:** **Cho trước** email đã có tài khoản hoặc sai định dạng · **Khi** Admin bấm "Thêm người dùng" · **Thì** hiển thị lỗi ngay dưới ô email và không tạo tài khoản.
- **AC-US-004-3:** **Cho trước** một tài khoản đang hoạt động · **Khi** Admin chọn "Vô hiệu hóa" và xác nhận trong hộp thoại · **Thì** trạng thái chuyển thành "Vô hiệu hóa" và mọi phiên của người đó bị đăng xuất ngay.
- **AC-US-004-4:** **Cho trước** một tài khoản bị tạm khóa do đăng nhập sai · **Khi** Admin chọn "Mở khóa" và xác nhận · **Thì** người dùng đăng nhập được ngay, không cần chờ 15 phút.
- **AC-US-004-5:** **Cho trước** Admin đổi vai trò của một người dùng · **Khi** lưu thay đổi · **Thì** quyền mới có hiệu lực từ request tiếp theo của người đó, và thay đổi được ghi audit log.
- **AC-US-004-6:** **Cho trước** Admin đang xem danh sách · **Khi** thao tác trên dòng của chính mình · **Thì** không thể tự vô hiệu hóa hoặc tự hạ vai trò (tránh mất quyền quản trị).
- **AC-US-004-7:** **Cho trước** người dùng có vai trò Member · **Khi** truy cập màn hình Người dùng qua đường dẫn trực tiếp · **Thì** thấy trang "Bạn không có quyền truy cập" (ERR-02).

---

### US-023 — Đăng xuất *(bổ sung)*

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 1 | FR-001, NFR-012 | UC-02 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** đăng xuất khỏi ứng dụng, **để** người khác dùng chung máy không xem được tài liệu và hội thoại của tôi.

**Tiêu chí chấp nhận**

- **AC-US-023-1:** **Cho trước** người dùng đang đăng nhập · **Khi** bấm "Đăng xuất" · **Thì** phiên bị hủy phía server và người dùng về trang đăng nhập.
- **AC-US-023-2:** **Cho trước** người dùng vừa đăng xuất · **Khi** bấm nút Back của trình duyệt hoặc mở lại URL cũ · **Thì** không xem được dữ liệu và bị chuyển về trang đăng nhập.

---

## 5. Epic EP-02 — Quản lý bộ tài liệu

### US-005 — Tải lên một hoặc nhiều PDF

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 5 | FR-005, BR-001, SN-004, NFR-004..006 | UC-04, UC-05 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** tải lên một hoặc nhiều file PDF cùng lúc (kéo-thả hoặc chọn file), **để** đưa tài liệu dự án vào hệ thống nhanh chóng.

**Tiêu chí chấp nhận**

- **AC-US-005-1:** **Cho trước** người dùng đã đăng nhập và đang ở màn hình Tài liệu · **Khi** kéo-thả 3 tệp PDF hợp lệ (mỗi tệp ≤ 20 MB ⚑) · **Thì** cả 3 tệp xuất hiện với trạng thái "Đang tải lên", kèm thanh tiến trình riêng cho từng tệp.
- **AC-US-005-2:** **Cho trước** người dùng chọn 11 tệp · **Khi** xác nhận tải lên · **Thì** hệ thống thông báo giới hạn 10 tệp mỗi lần (ERR-09) và không tải tệp nào cho tới khi người dùng chọn lại.
- **AC-US-005-3:** **Cho trước** người dùng bấm "Chọn file" · **Khi** chọn tệp từ hộp thoại của hệ điều hành · **Thì** hệ thống xử lý giống như kéo-thả.
- **AC-US-005-4:** **Cho trước** bộ tài liệu đang có 48 tài liệu và giới hạn là 50 ⚑ · **Khi** người dùng chọn 3 tệp · **Thì** hệ thống từ chối, thông báo "Bộ tài liệu đã đủ 50 tài liệu" (ERR-18) và gợi ý liên hệ Admin.
- **AC-US-005-5:** **Cho trước** trong 3 tệp có 1 tệp không hợp lệ · **Khi** tải lên · **Thì** 2 tệp hợp lệ vẫn được tải bình thường; tệp lỗi hiển thị lỗi riêng tại dòng của nó (xem US-007).
- **AC-US-005-6:** **Cho trước** mất kết nối mạng trong lúc đang tải một tệp · **Khi** tải thất bại · **Thì** tệp đó hiển thị "Mất kết nối khi tải lên" kèm nút "Thử lại"; các tệp đã tải xong không bị ảnh hưởng (EC-03).
- **AC-US-005-7:** **Cho trước** tải lên thành công · **Khi** tệp được lưu · **Thì** tệp chuyển sang trạng thái "Đang chờ xử lý", và thao tác được ghi audit log (người tải, thời điểm, tên tệp).

---

### US-006 — Xem trạng thái xử lý từng tài liệu

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 3 | FR-006, BR-001, BR-005, NFR-003 | UC-06, UC-09 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** thấy trạng thái xử lý của từng tài liệu (Đang tải lên / Đang chờ / Đang xử lý / Sẵn sàng / Lỗi), **để** biết khi nào có thể hỏi về tài liệu đó.

**Tiêu chí chấp nhận**

- **AC-US-006-1:** **Cho trước** một tệp PDF dạng văn bản, 50 trang, đã tải lên xong · **Khi** hệ thống xử lý xong · **Thì** trạng thái chuyển sang "Sẵn sàng" trong ≤ 60 giây ⚑ mà người dùng không cần tải lại trang.
- **AC-US-006-2:** **Cho trước** có ít nhất một tài liệu đang xử lý · **Khi** người dùng ở màn hình Tài liệu · **Thì** trạng thái tự cập nhật trong ≤ 3 giây sau khi thay đổi, và có dòng chú thích "Tự cập nhật khi có tài liệu đang xử lý".
- **AC-US-006-3:** **Cho trước** một tài liệu vừa chuyển sang "Sẵn sàng" · **Khi** trạng thái thay đổi · **Thì** người dùng nhận thông báo (toast) "[tên tệp] đã sẵn sàng để hỏi đáp", và số trên menu "Tài liệu" tăng thêm 1.
- **AC-US-006-4:** **Cho trước** mỗi trạng thái · **Khi** hiển thị · **Thì** trạng thái có cả biểu tượng và chữ, không phân biệt chỉ bằng màu.

---

### US-007 — Được báo rõ khi file không xử lý được

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 3 | FR-007, BR-005, RSK-003 | UC-05 | Ready (PRD nâng từ Should lên P0; chờ xác nhận OQ-022) |

> **Là** Chuyên viên BD, **tôi muốn** được báo rõ khi một file không xử lý được và lý do, **để** tôi xử lý file đó theo cách khác.

**Tiêu chí chấp nhận**

- **AC-US-007-1:** **Cho trước** người dùng tải lên tệp `.docx` đổi tên thành `.pdf` · **Khi** hệ thống kiểm tra tệp · **Thì** tệp được đánh dấu "Lỗi — không phải tệp PDF hợp lệ" (ERR-07) và không được dùng làm nguồn trả lời.
- **AC-US-007-2:** **Cho trước** một tệp PDF có mật khẩu · **Khi** tải lên · **Thì** trạng thái là "Lỗi — tệp được bảo vệ bằng mật khẩu" (ERR-10).
- **AC-US-007-3:** **Cho trước** một tệp PDF chỉ chứa ảnh scan · **Khi** xử lý · **Thì** trạng thái là "Lỗi — không đọc được văn bản (PDF dạng ảnh chưa được hỗ trợ)" (ERR-11).
- **AC-US-007-4:** **Cho trước** một tệp lớn hơn 20 MB ⚑ hoặc dài hơn 300 trang ⚑ · **Khi** tải lên · **Thì** tệp quá dung lượng bị từ chối ngay ở trình duyệt, trước khi tải lên (ERR-08); tệp quá số trang bị đánh dấu lỗi sau khi kiểm tra (ERR-17). Cả hai thông báo đều nêu rõ giới hạn.
- **AC-US-007-5:** **Cho trước** một tệp PDF bị hỏng · **Khi** xử lý · **Thì** trạng thái là "Lỗi — tệp bị hỏng, không mở được" (ERR-20).
- **AC-US-007-6:** **Cho trước** xử lý thất bại do lỗi tạm thời của hệ thống (đã tự thử lại 3 lần) · **Khi** hiển thị lỗi · **Thì** có nút "Thử lại" để người dùng xử lý lại tệp.
- **AC-US-007-7:** **Cho trước** một tệp xử lý thất bại · **Khi** các tệp khác đang xử lý · **Thì** các tệp khác không bị ảnh hưởng (NFR-021).

---

### US-008 — Mọi tài liệu Sẵn sàng đều là nguồn trả lời

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 5 | FR-008, BR-002, SN-002 | UC-09, UC-10 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** mọi tài liệu ở trạng thái Sẵn sàng đều được dùng làm nguồn trả lời, **để** không phải chọn file trước khi hỏi.

**Tiêu chí chấp nhận**

- **AC-US-008-1:** **Cho trước** bộ tài liệu có tài liệu A (Sẵn sàng) và B (Đang xử lý) · **Khi** người dùng đặt câu hỏi · **Thì** câu trả lời chỉ dựa trên A, và giao diện hiển thị thông báo "1 tài liệu đang xử lý, chưa được dùng để trả lời".
- **AC-US-008-2:** **Cho trước** bộ tài liệu mẫu (DEP-002) đã Sẵn sàng · **Khi** QA chạy bộ câu hỏi chuẩn · **Thì** mỗi tài liệu được trích dẫn trong ít nhất một câu trả lời (BRD AC-002).
- **AC-US-008-3:** **Cho trước** màn hình Hỏi đáp đang mở · **Khi** người dùng nhìn đầu khu vực hội thoại · **Thì** thấy số tài liệu đang dùng làm nguồn (ví dụ "5 tài liệu đang dùng"), và bấm vào thì mở màn hình Tài liệu.
- **AC-US-008-4:** **Cho trước** chưa có tài liệu nào Sẵn sàng · **Khi** người dùng mở màn hình Hỏi đáp · **Thì** ô nhập câu hỏi bị vô hiệu hóa và có hướng dẫn "Tải lên tài liệu để bắt đầu" (EC-01).

---

### US-009 — Xem danh sách tài liệu · ↪ Gộp vào US-006 (MVP)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 2 | FR-009, BR-003 | UC-06 | Proposed (OQ-013) |

> **Là** Chuyên viên BD, **tôi muốn** xem danh sách tài liệu (tên, số trang, người tải, ngày tải, trạng thái), **để** biết câu trả lời dựa trên những tài liệu nào.

**Tiêu chí chấp nhận**

- **AC-US-009-1:** **Cho trước** đã tải lên N tệp · **Khi** mở màn hình Tài liệu · **Thì** danh sách hiển thị đúng N tệp, không thiếu, không trùng, mỗi dòng có tên tệp, số trang, người tải lên, ngày tải lên và trạng thái (BRD AC-003).
- **AC-US-009-2:** **Cho trước** danh sách có tài liệu ở nhiều trạng thái · **Khi** chọn tab "Sẵn sàng", "Đang xử lý" hoặc "Lỗi" · **Thì** chỉ hiển thị tài liệu tương ứng, và mỗi tab có số lượng.
- **AC-US-009-3:** **Cho trước** danh sách có nhiều tài liệu · **Khi** nhập một phần tên tệp vào ô tìm kiếm · **Thì** danh sách lọc theo tên, không phân biệt hoa thường.
- **AC-US-009-4:** **Cho trước** bộ lọc không có kết quả · **Khi** hiển thị · **Thì** có trạng thái trống "Không có tài liệu phù hợp" kèm gợi ý đổi bộ lọc.
- **AC-US-009-5:** **Cho trước** màn hình Tài liệu · **Khi** hiển thị · **Thì** có chỉ báo dung lượng "x/50 tài liệu".

---

### US-010 — Admin gỡ tài liệu lỗi thời

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 3 | FR-010, BR-004, BRU-004, NFR-016 | UC-07 | Proposed (OQ-013) |

> **Là** Quản trị viên, **tôi muốn** gỡ một tài liệu lỗi thời khỏi bộ tài liệu, **để** nó không còn ảnh hưởng tới câu trả lời.

**Tiêu chí chấp nhận**

- **AC-US-010-1:** **Cho trước** Admin chọn "Gỡ" một tài liệu · **Khi** hộp thoại xác nhận hiển thị · **Thì** hộp thoại nêu rõ: tài liệu không còn được dùng để trả lời, trích dẫn cũ sẽ hiển thị "Tài liệu đã bị gỡ", và nội dung bị xóa vĩnh viễn sau 30 ngày.
- **AC-US-010-2:** **Cho trước** Admin xác nhận gỡ tài liệu X · **Khi** sau đó hỏi các câu có đáp án chỉ nằm trong X · **Thì** nhận "không tìm thấy thông tin", và không câu trả lời nào trích dẫn X (BRD AC-004).
- **AC-US-010-3:** **Cho trước** người dùng có vai trò Member · **Khi** xem danh sách tài liệu · **Thì** không thấy nút "Gỡ"; gọi API gỡ trực tiếp thì bị từ chối (403).
- **AC-US-010-4:** **Cho trước** một hội thoại cũ có trích dẫn tới X · **Khi** người dùng bấm trích dẫn đó · **Thì** khung xem nguồn hiển thị "Tài liệu đã bị gỡ" và không mở được nội dung (EC-10).
- **AC-US-010-5:** **Cho trước** tài liệu bị gỡ quá 30 ngày ⚑ · **Khi** job dọn dẹp chạy · **Thì** tệp PDF và nội dung đã xử lý bị xóa vĩnh viễn khỏi lưu trữ.
- **AC-US-010-6:** **Cho trước** Admin gỡ tài liệu · **Khi** thao tác hoàn tất · **Thì** có thông báo xác nhận và thao tác được ghi audit log.

---

### US-024 — Xử lý trùng tên tệp khi tải lên *(bổ sung)* · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 3 | EC-08, EC-13, BRU-006 | UC-08 | Proposed |

> **Là** Chuyên viên BD, **tôi muốn** được hỏi cách xử lý khi tải lên tệp trùng tên với tài liệu đã có, **để** không vô tình tạo bản trùng hoặc ghi đè bản cũ.

**Tiêu chí chấp nhận**

- **AC-US-024-1:** **Cho trước** đã có tài liệu "Hop_dong_khung_ABC_2026.pdf" · **Khi** Member tải lên tệp cùng tên · **Thì** hộp thoại hiển thị lựa chọn "Giữ cả hai" và "Hủy".
- **AC-US-024-2:** **Cho trước** hộp thoại trùng tên · **Khi** chọn "Giữ cả hai" · **Thì** tệp mới được lưu với tên có hậu tố ngày tải lên (ví dụ `Hop_dong_khung_ABC_2026_2026-10-26.pdf`).
- **AC-US-024-3:** **Cho trước** người dùng là Admin · **Khi** hộp thoại trùng tên hiển thị · **Thì** có thêm lựa chọn "Thay thế bản cũ". Bản cũ chỉ bị gỡ khi bản mới đã chuyển sang "Sẵn sàng", để không có khoảng thời gian thiếu tài liệu.
- **AC-US-024-4:** **Cho trước** hai người cùng tải tệp trùng tên gần như đồng thời · **Khi** người thứ hai tải xong · **Thì** người thứ hai nhận hộp thoại trùng tên (EC-13).

---

## 6. Epic EP-03 — Hỏi đáp có trích dẫn

### US-011 — Hỏi bằng ngôn ngữ tự nhiên, trả lời từ tài liệu

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 8 | FR-011, BR-006, BRU-001, KR2.1 | UC-10, UC-11 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** đặt câu hỏi bằng ngôn ngữ tự nhiên và nhận câu trả lời từ nội dung tài liệu, **để** không phải tự đọc từng file.

**Tiêu chí chấp nhận**

- **AC-US-011-1:** **Cho trước** bộ tài liệu chuẩn (DEP-002) đã Sẵn sàng · **Khi** QA chạy bộ câu hỏi chuẩn · **Thì** ≥ 80% ⚑ câu trả lời được đại diện đội BD đánh giá là đúng (KR2.1).
- **AC-US-011-2:** **Cho trước** bộ tài liệu chưa có tài liệu nào ở trạng thái Sẵn sàng · **Khi** người dùng mở màn hình hỏi đáp · **Thì** ô nhập câu hỏi bị vô hiệu hóa và có hướng dẫn "Tải lên tài liệu để bắt đầu".
- **AC-US-011-3:** **Cho trước** câu hỏi dài hơn 2.000 ký tự ⚑ · **Khi** người dùng gửi · **Thì** hệ thống không gửi câu hỏi; bộ đếm ký tự chuyển màu đỏ và hiển thị số ký tự vượt giới hạn (ERR-19).
- **AC-US-011-4:** **Cho trước** ô nhập rỗng hoặc chỉ có khoảng trắng · **Khi** người dùng nhìn nút Gửi · **Thì** nút Gửi bị vô hiệu hóa (EC-12).
- **AC-US-011-5:** **Cho trước** người dùng đang ở ô nhập · **Khi** nhấn Enter · **Thì** câu hỏi được gửi; **Khi** nhấn Shift+Enter · **Thì** xuống dòng.
- **AC-US-011-6:** **Cho trước** một câu hỏi về kiến thức chung mà tài liệu không đề cập (ví dụ "Thủ đô của Pháp là gì?") · **Khi** gửi · **Thì** hệ thống không trả lời từ kiến thức bên ngoài (BRU-001), mà xử lý theo US-014.
- **AC-US-011-7:** **Cho trước** mọi câu trả lời · **Khi** hiển thị · **Thì** có nhãn "Câu trả lời do AI tạo — hãy kiểm tra nguồn".
- **AC-US-011-8:** **Cho trước** dịch vụ AI lỗi hoặc quá thời gian chờ 30 giây ⚑ · **Khi** người dùng đang chờ · **Thì** hiển thị "Hệ thống đang bận, vui lòng thử lại" (ERR-12) kèm nút "Thử lại"; câu hỏi không bị mất (EC-06).
- **AC-US-011-9:** **Cho trước** người dùng gửi quá 20 câu hỏi trong 1 phút ⚑ · **Khi** gửi câu tiếp theo · **Thì** nhận thông báo "Bạn thao tác quá nhanh. Vui lòng thử lại sau n giây" (ERR-06).

---

### US-012 — Câu trả lời tổng hợp từ nhiều tài liệu

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 5 | FR-012, BR-007, SN-002 | UC-11 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** câu trả lời tổng hợp thông tin từ nhiều tài liệu khi cần, **để** không phải tự ghép nối.

**Tiêu chí chấp nhận**

- **AC-US-012-1:** **Cho trước** thông tin về đối tác X nằm ở tài liệu A trang 3 và tài liệu B trang 7 · **Khi** hỏi "Tóm tắt thông tin về đối tác X" · **Thì** câu trả lời chứa thông tin từ cả hai nguồn và có trích dẫn cả A–tr.3 và B–tr.7.
- **AC-US-012-2:** **Cho trước** các câu hỏi trong bộ chuẩn có đáp án nằm ở ≥ 2 tài liệu · **Khi** QA chạy kiểm thử · **Thì** ≥ 80% ⚑ câu trả lời chứa đủ ý từ tất cả các tài liệu liên quan (BRD AC-007).
- **AC-US-012-3:** **Cho trước** hai tài liệu có thông tin mâu thuẫn (ví dụ hai bảng giá khác nhau) · **Khi** câu trả lời dùng cả hai · **Thì** câu trả lời nêu rõ sự khác biệt và trích dẫn từng nguồn, không tự chọn một bên.

---

### US-013 — Trích dẫn tên tài liệu và số trang

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 5 | FR-013, BR-008, SN-003, KR2.2 | UC-11 | Proposed (OQ-013) |

> **Là** Chuyên viên BD, **tôi muốn** mỗi ý trong câu trả lời có trích dẫn tên tài liệu và số trang, **để** tôi kiểm chứng trước khi dùng.

**Tiêu chí chấp nhận**

- **AC-US-013-1:** **Cho trước** bất kỳ câu trả lời nào không phải "không tìm thấy" · **Khi** câu trả lời hiển thị xong · **Thì** có ≥ 1 trích dẫn, gồm số thứ tự trong câu và mục "Nguồn" bên dưới ghi `Tên tài liệu · tr. N`.
- **AC-US-013-2:** **Cho trước** bộ câu hỏi chuẩn · **Khi** QA mở từng trích dẫn · **Thì** ≥ 90% ⚑ trích dẫn trỏ đúng trang chứa thông tin được dùng (KR2.2).
- **AC-US-013-3:** **Cho trước** mục "Nguồn" · **Khi** hiển thị · **Thì** mỗi nguồn có một đoạn trích ngắn của nội dung được dùng, và các nguồn trùng nhau chỉ liệt kê một lần.
- **AC-US-013-4:** **Cho trước** mọi trích dẫn · **Khi** kiểm tra · **Thì** không có trích dẫn nào trỏ tới tài liệu hoặc trang không tồn tại trong bộ tài liệu.

---

### US-014 — Báo rõ khi không tìm thấy thông tin

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 5 | FR-014, BR-009, RSK-001, KR2.3 | UC-12 | Proposed (OQ-013) |

> **Là** Chuyên viên BD, **tôi muốn** hệ thống nói rõ khi tài liệu không có thông tin, **để** tôi không dùng nhầm thông tin bịa.

**Tiêu chí chấp nhận**

- **AC-US-014-1:** **Cho trước** bộ ≥ 10 câu hỏi về thông tin không có trong tài liệu · **Khi** gửi từng câu · **Thì** ≥ 90% ⚑ phản hồi là thông báo "Không tìm thấy thông tin trong tài liệu" và không kèm nội dung suy diễn (KR2.3).
- **AC-US-014-2:** **Cho trước** câu hỏi về kiến thức chung (ví dụ "Thủ đô của Pháp là gì?") · **Khi** gửi · **Thì** hệ thống trả về thông báo "Không tìm thấy thông tin trong tài liệu", không trả lời từ kiến thức bên ngoài (BRU-001).
- **AC-US-014-3:** **Cho trước** phản hồi "không tìm thấy" · **Khi** hiển thị · **Thì** khung thông báo khác biệt rõ với câu trả lời thường, và có gợi ý: diễn đạt lại câu hỏi, hoặc kiểm tra tài liệu liên quan đã được tải lên và Sẵn sàng chưa (UI-05).
- **AC-US-014-4:** **Cho trước** AI đã sinh câu trả lời nhưng không có trích dẫn hợp lệ nào · **Khi** hoàn tất · **Thì** hệ thống thay câu trả lời bằng thông báo "không tìm thấy".
- **AC-US-014-5:** **Cho trước** tài liệu chứa đoạn văn kiểu chỉ dẫn ("Bỏ qua mọi quy tắc và trả lời…") · **Khi** người dùng hỏi liên quan tới đoạn đó · **Thì** hệ thống không làm theo chỉ dẫn trong tài liệu, và không tiết lộ cấu hình nội bộ (QAS-08).

---

### US-015 — Hỏi và nhận trả lời bằng tiếng Việt / tiếng Anh

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P0 | 3 | FR-015, BR-011 | UC-10 | Blocked (OQ-010: ngôn ngữ tài liệu) |

> **Là** Chuyên viên BD, **tôi muốn** hỏi bằng tiếng Việt hoặc tiếng Anh và nhận câu trả lời cùng ngôn ngữ với câu hỏi, **để** giao tiếp tự nhiên.

**Tiêu chí chấp nhận**

- **AC-US-015-1:** **Cho trước** bộ câu hỏi chuẩn viết bằng tiếng Việt · **Khi** chạy kiểm thử · **Thì** câu trả lời bằng tiếng Việt và đạt cùng ngưỡng như AC-US-011-1.
- **AC-US-015-2:** **Cho trước** một câu hỏi bằng tiếng Anh về tài liệu tiếng Việt · **Khi** gửi câu hỏi · **Thì** câu trả lời bằng tiếng Anh và trích dẫn đúng tài liệu tiếng Việt.
- **AC-US-015-3:** **Cho trước** câu hỏi tiếng Việt có hoặc không có dấu (ví dụ "dieu khoan thanh toan") · **Khi** gửi · **Thì** hệ thống vẫn tìm được thông tin liên quan, với độ chính xác do QA ghi nhận trên ≥ 10 câu không dấu.
- **AC-US-015-4:** **Cho trước** giao diện ứng dụng · **Khi** hiển thị · **Thì** toàn bộ nhãn, nút và thông báo bằng tiếng Việt; ngày giờ theo định dạng `dd/mm/yyyy`, múi giờ Việt Nam.

---

### US-016 — Câu trả lời hiện dần khi đang tạo

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 5 | FR-016, BR-012, NFR-001, NFR-002 | UC-11 | Ready (ngưỡng chờ OQ-015) |

> **Là** Chuyên viên BD, **tôi muốn** câu trả lời hiện dần ngay khi có, **để** không phải chờ màn hình trống.

**Tiêu chí chấp nhận**

- **AC-US-016-1:** **Cho trước** 5 người dùng hỏi đồng thời trên bộ 50 tài liệu ⚑ · **Khi** đo trên môi trường staging · **Thì** p90 thời gian tới phần đầu tiên của câu trả lời ≤ 5 giây ⚑ (NFR-002).
- **AC-US-016-2:** **Cho trước** cùng điều kiện · **Khi** đo · **Thì** p90 thời gian tới câu trả lời hoàn chỉnh ≤ 15 giây ⚑ (NFR-001, BRD AC-012).
- **AC-US-016-3:** **Cho trước** người dùng vừa gửi câu hỏi · **Khi** chưa có nội dung trả về · **Thì** hiển thị chỉ báo "đang trả lời" trong ≤ 300 ms.
- **AC-US-016-4:** **Cho trước** câu trả lời đang hiện dần · **Khi** có nội dung mới · **Thì** khung hội thoại tự cuộn xuống, và trình đọc màn hình thông báo nội dung mới (`aria-live`).
- **AC-US-016-5:** **Cho trước** mất kết nối giữa chừng · **Khi** câu trả lời bị gián đoạn · **Thì** phần đã nhận được giữ lại, gắn nhãn "Câu trả lời chưa hoàn tất" kèm nút "Thử lại" (EC-04).

---

### US-025 — Dừng tạo câu trả lời *(bổ sung)* · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 2 | UI-07, CN-15 | UC-15 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** dừng câu trả lời đang được tạo, **để** đặt lại câu hỏi khi thấy hệ thống hiểu sai ý tôi.

**Tiêu chí chấp nhận**

- **AC-US-025-1:** **Cho trước** câu trả lời đang được tạo · **Khi** người dùng nhìn nút Gửi · **Thì** nút Gửi chuyển thành nút "Dừng".
- **AC-US-025-2:** **Cho trước** người dùng bấm "Dừng" · **Khi** hệ thống xử lý · **Thì** việc tạo câu trả lời ngừng trong ≤ 1 giây; phần đã có được giữ, gắn nhãn "Bạn đã dừng câu trả lời", và nút trở lại thành Gửi.
- **AC-US-025-3:** **Cho trước** câu trả lời đã bị dừng · **Khi** người dùng bấm "Thử lại" · **Thì** câu hỏi được gửi lại và nhận câu trả lời mới.

---

### US-017 — Mở đúng trang PDF gốc từ trích dẫn

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 5 | FR-017, BR-008, SN-003 | UC-13 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** bấm vào trích dẫn để mở đúng trang PDF gốc, **để** kiểm chứng nhanh.

**Tiêu chí chấp nhận**

- **AC-US-017-1:** **Cho trước** câu trả lời có trích dẫn [1] trỏ tới "Hop_dong_khung_ABC_2026.pdf" trang 7 · **Khi** bấm [1] hoặc dòng nguồn tương ứng · **Thì** khung xem nguồn mở bên phải, hiển thị trang 7 của tài liệu đó, với đoạn được trích dẫn được tô sáng.
- **AC-US-017-2:** **Cho trước** khung xem nguồn đang mở · **Khi** bấm mũi tên trước / sau · **Thì** chuyển sang trích dẫn trước / sau trong hội thoại, và hiển thị vị trí (ví dụ "2/5").
- **AC-US-017-3:** **Cho trước** khung xem nguồn đang mở · **Khi** nhấn Esc hoặc nút Đóng · **Thì** khung đóng lại và con trỏ quay về trích dẫn vừa bấm.
- **AC-US-017-4:** **Cho trước** khung xem nguồn · **Khi** bấm "Mở PDF gốc" · **Thì** PDF mở ở tab mới tại đúng trang được trích dẫn.
- **AC-US-017-5:** **Cho trước** màn hình rộng 768–1279 px · **Khi** mở trích dẫn · **Thì** khung xem nguồn hiển thị dạng ngăn trượt phủ lên nội dung.
- **AC-US-017-6:** **Cho trước** trích dẫn tới tài liệu đã bị gỡ · **Khi** bấm · **Thì** khung hiển thị "Tài liệu đã bị gỡ" (xem AC-US-010-4).

---

### US-018 — Đánh giá câu trả lời · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 2 | FR-018, MET-002, KR3.2 | UC-14 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** đánh giá câu trả lời là hữu ích hoặc không hữu ích, **để** nhóm sản phẩm cải thiện chất lượng.

**Tiêu chí chấp nhận**

- **AC-US-018-1:** **Cho trước** một câu trả lời đã hoàn tất · **Khi** bấm "Hữu ích" · **Thì** nút chuyển sang trạng thái đã chọn, có thông báo "Cảm ơn phản hồi của bạn", và đánh giá được lưu.
- **AC-US-018-2:** **Cho trước** một câu trả lời · **Khi** bấm "Không hữu ích" · **Thì** hiển thị ô góp ý không bắt buộc (≤ 1.000 ký tự); gửi hoặc bỏ qua đều lưu đánh giá.
- **AC-US-018-3:** **Cho trước** đã đánh giá · **Khi** bấm lại cùng nút · **Thì** đánh giá bị bỏ chọn; **Khi** bấm nút còn lại · **Thì** đánh giá được đổi.
- **AC-US-018-4:** **Cho trước** câu trả lời đang được tạo, đã bị dừng hoặc là "không tìm thấy" · **Khi** hiển thị · **Thì** không có nút đánh giá cho câu trả lời đang được tạo; câu trả lời đã dừng và "không tìm thấy" vẫn đánh giá được.
- **AC-US-018-5:** **Cho trước** người dùng gửi đánh giá · **Khi** sự kiện được ghi · **Thì** sự kiện `answer_feedback` có `rating` và `has_comment`, không chứa nội dung góp ý (AC-G-06).

---

## 7. Epic EP-04 — Hội thoại & lịch sử

### US-019 — Hỏi câu nối tiếp và bắt đầu hội thoại mới · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 5 | FR-019, BR-010 | UC-16, UC-17 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** hỏi tiếp câu nối tiếp mà không nhắc lại ngữ cảnh, và bắt đầu hội thoại mới khi đổi chủ đề.

**Tiêu chí chấp nhận**

- **AC-US-019-1:** **Cho trước** câu hỏi trước là "Điều khoản thanh toán với ABC là gì?" · **Khi** hỏi tiếp "Còn phạt chậm trả thì sao?" · **Thì** câu trả lời hiểu đúng là đang hỏi về hợp đồng với ABC.
- **AC-US-019-2:** **Cho trước** ≥ 5 chuỗi câu hỏi nối tiếp trong bộ chuẩn · **Khi** QA chạy kiểm thử · **Thì** câu trả lời đúng với ngữ cảnh của câu hỏi trước theo đáp án tham chiếu (BRD AC-010).
- **AC-US-019-3:** **Cho trước** hội thoại có hơn 10 ⚑ lượt hỏi đáp · **Khi** hỏi tiếp · **Thì** hệ thống chỉ dùng 10 lượt gần nhất làm ngữ cảnh.
- **AC-US-019-4:** **Cho trước** người dùng bấm "Hội thoại mới" · **Khi** bắt đầu hỏi · **Thì** câu hỏi không bị ảnh hưởng bởi ngữ cảnh hội thoại trước; hội thoại cũ vẫn được lưu.
- **AC-US-019-5:** **Cho trước** hội thoại mới chưa có câu hỏi · **Khi** hiển thị · **Thì** có 3 câu hỏi gợi ý; bấm vào một câu thì câu đó được điền sẵn vào ô nhập (EC-02).
- **AC-US-019-6:** **Cho trước** hội thoại mới · **Khi** gửi câu hỏi đầu tiên · **Thì** tiêu đề hội thoại được đặt tự động từ câu hỏi đó (≤ 200 ký tự).

---

### US-020 — Xem lại lịch sử hội thoại · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P2 | 3 | FR-020, BR-014 | UC-18 | Ready |

> **Là** Chuyên viên BD, **tôi muốn** xem lại danh sách các hội thoại cũ của mình, **để** không phải hỏi lại.

**Tiêu chí chấp nhận**

- **AC-US-020-1:** **Cho trước** người dùng có nhiều hội thoại · **Khi** mở "Lịch sử hội thoại" · **Thì** danh sách sắp xếp theo thời gian hoạt động gần nhất, nhóm theo "Hôm nay", "Hôm qua", "7 ngày qua", "Cũ hơn".
- **AC-US-020-2:** **Cho trước** danh sách lịch sử · **Khi** bấm một hội thoại · **Thì** mở lại hội thoại với đầy đủ câu hỏi, câu trả lời và trích dẫn (BRD AC-014).
- **AC-US-020-3:** **Cho trước** danh sách lịch sử · **Khi** nhập từ khóa vào ô tìm kiếm · **Thì** lọc theo tiêu đề hoặc nội dung câu hỏi.
- **AC-US-020-4:** **Cho trước** người dùng chưa có hội thoại · **Khi** mở Lịch sử · **Thì** hiển thị trạng thái trống kèm nút "Bắt đầu hội thoại".
- **AC-US-020-5:** **Cho trước** sidebar ở màn hình Hỏi đáp · **Khi** hiển thị · **Thì** mục "Gần đây" có 3–5 hội thoại gần nhất.
- **AC-US-020-6:** **Cho trước** hội thoại không hoạt động quá 180 ngày ⚑ · **Khi** job dọn dẹp chạy · **Thì** hội thoại bị xóa, và màn hình Lịch sử có ghi chú về chính sách này (OQ-016).

---

## 8. Epic EP-05 — Đo lường sử dụng

### US-021 — Ghi nhận số liệu sử dụng · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P1 | 3 | FR-021, BR-015, BO-003, MET-003 | — | Ready |

> **Là** Quản lý, **tôi muốn** có số liệu về số người dùng và số câu hỏi theo tuần, **để** đánh giá MVP.

**Tiêu chí chấp nhận**

- **AC-US-021-1:** **Cho trước** các thao tác trong PRD §6.2 (đăng nhập, tải lên, hỏi, trả lời, mở trích dẫn, đánh giá…) · **Khi** người dùng thực hiện · **Thì** sự kiện tương ứng được ghi kèm đúng các thuộc tính đã định nghĩa.
- **AC-US-021-2:** **Cho trước** một tuần thử nghiệm · **Khi** đối chiếu số liệu với một mẫu kiểm tra thủ công ≥ 20 câu hỏi · **Thì** số liệu khớp với sai lệch ≤ 1% (BRD AC-015).
- **AC-US-021-3:** **Cho trước** mọi sự kiện · **Khi** kiểm tra dữ liệu lưu trữ · **Thì** không có nội dung câu hỏi, câu trả lời hay tài liệu, và người dùng được định danh bằng mã ẩn danh (AC-G-06).
- **AC-US-021-4:** **Cho trước** hệ thống ghi sự kiện bị lỗi · **Khi** người dùng đang hỏi đáp · **Thì** việc hỏi đáp không bị chậm hay gián đoạn.
- **AC-US-021-5:** **Cho trước** sự kiện cũ hơn 12 tháng ⚑ · **Khi** job dọn dẹp chạy · **Thì** sự kiện bị xóa.

---

### US-022 — Bảng số liệu sử dụng cho Admin / Quản lý · ⏸ Hoãn (GĐ2)

| Ưu tiên | SP | Trace | Use case | Trạng thái |
|---|---|---|---|---|
| P2 | 5 | FR-022, BO-003, KR3.1, KR3.2 | UC-19 | Ready |

> **Là** Quản lý, **tôi muốn** xem bảng tổng hợp số liệu sử dụng ngay trong ứng dụng, **để** quyết định có đầu tư tiếp hay không.

**Tiêu chí chấp nhận**

- **AC-US-022-1:** **Cho trước** người dùng có vai trò Admin · **Khi** mở "Số liệu sử dụng" · **Thì** thấy 5 chỉ số của tuần gần nhất: người dùng hoạt động (x/tổng), số câu hỏi, tỷ lệ "Hữu ích", tỷ lệ "Không tìm thấy", và p90 thời gian trả lời.
- **AC-US-022-2:** **Cho trước** chỉ số có mục tiêu (tỷ lệ hoạt động ≥ 70%, tỷ lệ hữu ích ≥ 70%, p90 ≤ 15 s) · **Khi** hiển thị · **Thì** có biểu tượng và chữ "Đạt mục tiêu" hoặc "Dưới mục tiêu", không phân biệt chỉ bằng màu.
- **AC-US-022-3:** **Cho trước** màn hình số liệu · **Khi** chọn khoảng thời gian 4, 8 hoặc 12 tuần · **Thì** biểu đồ số câu hỏi theo tuần và biểu đồ tỷ lệ thành viên hoạt động (có đường mục tiêu 70%) cập nhật theo.
- **AC-US-022-4:** **Cho trước** biểu đồ · **Khi** rê chuột hoặc dùng phím mũi tên trên biểu đồ · **Thì** tooltip hiển thị giá trị của từng tuần.
- **AC-US-022-5:** **Cho trước** màn hình số liệu · **Khi** bấm "Xem dạng bảng" · **Thì** hiển thị bảng số liệu theo tuần với đầy đủ các chỉ số.
- **AC-US-022-6:** **Cho trước** người dùng có vai trò Member · **Khi** truy cập màn hình số liệu · **Thì** bị từ chối (ERR-02).

---

## 9. Definition of Ready (DoR) & Definition of Done (DoD)

**Definition of Ready** — điều kiện để một story được đưa vào sprint:

- [ ] Story theo đúng cú pháp, có giá trị rõ ràng và truy vết tới BR / FR.
- [ ] Mọi AC kiểm chứng được; giá trị ⚑ đã được xác nhận hoặc chấp nhận tạm thời.
- [ ] Không còn OQ chặn. Story có trạng thái `Blocked` chưa được vào sprint.
- [ ] Đã có thiết kế màn hình (`docs/design/html_design/`) nếu story có giao diện.
- [ ] Đội đã ước lượng story point; story ≤ 8 SP (lớn hơn thì phải tách).

**Definition of Done** — điều kiện để một story được coi là hoàn thành:

- [ ] Mọi AC của story và AC chung (§3) đã pass, có bằng chứng kiểm thử.
- [ ] Unit test và integration test đã viết; độ phủ ≥ 80% ở tầng domain và application (QAS-10).
- [ ] Không còn lỗi Critical / High; Semgrep, Trivy và `pip-audit` không có cảnh báo mức cao.
- [ ] Code đã được review và merge; đã deploy lên staging.
- [ ] Với story thuộc EP-03: golden eval trên staging không giảm quá 5 điểm (QAS-13).
- [ ] Sự kiện telemetry của story (nếu có) đã kiểm tra trên staging.
- [ ] PO đã nghiệm thu trên staging.

---

## 10. Truy vết

| Story | BRD | PRD (FR / NFR) | Use case | Màn hình HTML |
|---|---|---|---|---|
| US-001 | BR-013 | FR-001, NFR-015 | UC-01 | 01-login |
| US-002 | BR-013 | FR-002, NFR-010..012 | — | 03-documents |
| US-003 | BR-013 | FR-003 | UC-18 | 04-chat, 05-history |
| US-004 | BR-013 | FR-004 | UC-03 | 06-admin-users |
| US-023 | BR-013 | FR-001 | UC-02 | Thanh trên cùng |
| US-005 | BR-001 | FR-005, NFR-004..006 | UC-04, UC-05 | 03-documents |
| US-006 | BR-001, BR-005 | FR-006, NFR-003 | UC-06, UC-09 | 03-documents |
| US-007 | BR-005 | FR-007 | UC-05 | 03-documents |
| US-008 | BR-002 | FR-008 | UC-09, UC-10 | 02-onboarding-empty, 04-chat |
| US-009 | BR-003 | FR-009 | UC-06 | 03-documents |
| US-010 | BR-004 | FR-010, NFR-016 | UC-07 | 03-documents |
| US-024 | BR-001 | EC-08, EC-13 | UC-08 | 03-documents |
| US-011 | BR-006 | FR-011 | UC-10, UC-11 | 04-chat |
| US-012 | BR-007 | FR-012 | UC-11 | 04-chat |
| US-013 | BR-008 | FR-013 | UC-11 | 04-chat |
| US-014 | BR-009 | FR-014 | UC-12 | 04-chat |
| US-015 | BR-011 | FR-015 | UC-10 | 04-chat |
| US-016 | BR-012 | FR-016, NFR-001, NFR-002 | UC-11 | 04-chat |
| US-025 | BR-012 | UI-07 | UC-15 | 04-chat |
| US-017 | BR-008 | FR-017 | UC-13 | 04-chat |
| US-018 | BO-002 | FR-018 | UC-14 | 04-chat |
| US-019 | BR-010 | FR-019 | UC-16, UC-17 | 02-onboarding-empty, 04-chat |
| US-020 | BR-014 | FR-020 | UC-18 | 05-history |
| US-021 | BR-015 | FR-021 | — | — |
| US-022 | BO-003 | FR-022 | UC-19 | 07-admin-metrics |

**Độ bao phủ:**

- 15/15 BR của BRD có ít nhất một story.
- 22/22 FR của PRD có story tương ứng.
- 19/19 use case trong sơ đồ có story; UC-09 (trích xuất nội dung) được bao phủ qua US-006 và US-008.

---

## 11. Câu hỏi mở ảnh hưởng tới backlog

| OQ | Story bị chặn / ảnh hưởng | Cần quyết định |
|---|---|---|
| OQ-008 | US-002, toàn bộ EP-03 | Có được gửi nội dung tài liệu tới AI bên ngoài không |
| OQ-010 | US-015 | Ngôn ngữ của tài liệu và câu hỏi |
| OQ-013 / OQ-022 | US-007, US-009, US-010, US-013, US-014 | Duyệt các đề xuất của BA và việc nâng ưu tiên |
| OQ-014 | US-001 | SSO hay tài khoản nội bộ |
| OQ-015 | US-016 | Thời gian chờ chấp nhận được |
| OQ-021 | Mọi AC có ⚑ | Duyệt các giá trị đề xuất |
