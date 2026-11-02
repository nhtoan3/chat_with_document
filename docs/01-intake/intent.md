# Intent — Công cụ "Chat với tài liệu" (MVP)

| Thuộc tính | Giá trị |
|---|---|
| Mã tài liệu | INT-CWD-001 |
| Phiên bản | 0.1 — `Draft`, **chưa được duyệt** |
| Ngày | 2026-11-02 |
| Phạm vi phản ánh | `docs/05-development/Implement_plan.md` v0.4 (bản này cũng chưa có bản ghi phê duyệt) |
| Chủ sở hữu | Huy Toan (PO / Tech lead) |
| Người duyệt | Quản lý giao yêu cầu (STK-001) — [TBD: OQ-001] |
| Risk tier | **High — đề xuất**, chờ người duyệt xác nhận (§8) |

> Tài liệu này được tách từ `docs/02-requirements/BRD.md` v0.1 (BRD-CWD-001) và cập nhật theo kế hoạch v0.4, sau khi dự án đã phát triển. Đây là hồ sơ bổ sung, không phải intent được lập và duyệt trước khi bắt đầu. Dấu ⚑ là giá trị đề xuất, chờ xác nhận (OQ-021).

## 1. Problem

Trong dự án kinh doanh có nhiều tài liệu PDF mà đội phát triển kinh doanh (BD) khó nắm bắt đầy đủ. Mỗi lần cần một thông tin, họ phải mất thời gian tổng hợp từ nhiều tệp (SRC-001).

Chưa có số liệu về thời gian bị mất, tần suất tìm kiếm hay tác động tài chính (OQ-002, OQ-005).

## 2. Proposed outcome

Một ứng dụng web nội bộ gồm hai tính năng:

- **F1 — Xử lý PDF:** tải lên tối đa 10 PDF mỗi lần (≤ 20 MB/tệp), theo dõi trạng thái xử lý và biết lý do khi tệp lỗi.
- **F2 — Hỏi đáp AI:** đặt câu hỏi bằng tiếng Việt và nhận câu trả lời chỉ dựa trên các tài liệu ở trạng thái Sẵn sàng. Không có thông tin thì AI báo "không tìm thấy".

MVP dùng để đánh giá giá trị của công cụ trước khi đầu tư thêm (SN-005).

## 3. Affected users

| Đối tượng | Ảnh hưởng | Nguồn |
|---|---|---|
| Đội BD (STK-002) | Người dùng chính; giảm công tổng hợp thông tin từ nhiều PDF | SRC-001 |
| Quản lý (STK-001) | Giao yêu cầu; dùng kết quả pilot để quyết định đầu tư tiếp | SRC-001 |
| Bảo mật / IT / pháp chế (STK-005) | Kiểm soát dữ liệu, cấp dải IP / VPN; có thể chặn việc đưa vào sử dụng | Chưa xác minh — OQ-008 |

Số người dùng: [TBD: OQ-005]. Danh sách đầy đủ ở [stakeholders.md](stakeholders.md).

## 4. Constraints

| ID | Ràng buộc | Trạng thái | Nguồn |
|---|---|---|---|
| CON-001 | Sản phẩm là ứng dụng web | Quản lý đã nêu | SRC-001 |
| CON-002 | Đầu vào là tệp PDF | Quản lý đã nêu | SRC-001 |
| CON-003 | Tương tác qua hình thức chat với AI | Quản lý đã nêu | SRC-001 |
| CON-004 | Sản phẩm ở mức MVP | Quản lý đã nêu | SRC-001 |
| CON-005 | Go-live 30/11/2026 | Kế hoạch đề xuất, chờ duyệt (OQ-006) | Plan v0.4 §2 |
| CON-006 | Ngân sách, gồm chi phí dịch vụ AI | [TBD: OQ-007] | BRD §9 |
| — | Bảo vệ truy cập chỉ bằng giới hạn IP / VPN của ALB, không có đăng nhập | Chờ duyệt | Plan v0.4 §1 |
| — | Gửi nội dung tài liệu tới dịch vụ AI bên ngoài | **Chưa được phép xác nhận** (OQ-008) | BRD ASM-004 |

## 5. Success measures

| Chỉ số | Mục tiêu | Khả năng đo ở v0.4 | Nguồn |
|---|---|---|---|
| Thời gian có câu trả lời đủ dùng (MET-001 / KR1.1) | Giảm ≥ 50% ⚑ so với baseline | Chưa đo được: chưa có baseline (OQ-002) | BRD §4, PRD §2.2 |
| Câu có đáp án được trả lời đúng (MET-002 / KR2.1) | ≥ 80% ⚑ | Đo bằng golden set; chưa có golden set thật và khóa API | PRD §2.2 |
| Câu không có đáp án nhận "không tìm thấy" (KR2.3) | ≥ 90% ⚑ | Như trên | PRD §2.2 |
| p90 thời gian trả lời (KR1.2 / NFR-001) | ≤ 15 s ⚑; v0.4 chấp nhận 10–20 s | Đo qua `qa_log.latency_ms`; chưa đo với Claude thật | `traceability.md` |
| PDF 50 trang chuyển Sẵn sàng (NFR-003) | ≤ 60 s | Chưa đo trên AWS | `traceability.md` |
| Mức sử dụng (MET-003 / KR3.1) | ≥ 70% ⚑ đội BD hỏi ≥ 1 câu mỗi tuần | **Không đo được đúng định nghĩa:** không đăng nhập nên chỉ đếm được số câu hỏi; bổ sung bằng khảo sát trong pilot | Plan v0.4 §1, §2 |

Không còn áp dụng ở v0.4: KR2.2 (độ đúng của trích dẫn) và KR3.2 (phản hồi "hữu ích"), vì đã lược bỏ trích dẫn và đánh giá câu trả lời. Do đó **BO-002 "câu trả lời kiểm chứng được" không còn được đáp ứng** (Plan v0.4 §1).

## 6. Out of scope

| Nhóm | Mục | Nguồn |
|---|---|---|
| Lược bỏ ở v0.4 | Đăng nhập, phân quyền, hội thoại riêng tư (US-001, 002, 003, 023) | Plan v0.4 §1 |
| | Trích dẫn tài liệu + trang, mở PDF tại trang (US-013, 017) | Plan v0.4 §1 |
| | Kiểm tra "không tìm thấy" phía server (US-014); hành vi này chỉ dựa vào prompt | Plan v0.4 §1 |
| | Streaming câu trả lời (US-016) | Plan v0.4 §1 |
| | Gỡ tài liệu trên giao diện, tinh chỉnh đa nguồn riêng (US-010, 012) | Plan v0.4 §1 |
| | PoC, rà soát bảo mật riêng, a11y, runbook đầy đủ, quét bảo mật trong CI | Plan v0.4 §1 |
| Ngoài phạm vi từ BRD | Định dạng khác PDF; ứng dụng di động native; tích hợp Drive / SharePoint; chỉnh sửa PDF; dùng kiến thức ngoài tài liệu để trả lời | BRD §5.2 |
| Hoãn | OCR cho PDF scan; xuất câu trả lời ra tệp; báo cáo thống kê cho quản lý | BRD §5.3 |

## 7. Open questions

Trạng thái lấy theo BRD §12 và PRD §11. Tại ngày lập tài liệu chưa có bản ghi nào đóng các câu hỏi này.

| ID | Câu hỏi | Người phụ trách | Hạn | Vì sao cần gấp |
|---|---|---|---|---|
| OQ-008 | Phân loại bảo mật tài liệu; có được gửi nội dung tới AI bên ngoài không | Bảo mật / Quản lý | **06/11/2026** (Plan §3) | Có thể đổi nhà cung cấp AI và lùi go-live |
| — | Duyệt phạm vi v0.4 và 4 đánh đổi | Quản lý | 28/10/2026 — **quá hạn** | Chi phối toàn bộ phạm vi |
| OQ-001 | Nhà tài trợ, chủ sở hữu nghiệp vụ, người phê duyệt là ai | Quản lý | 27/10/2026 — **quá hạn** | Chưa ai có thể ký duyệt |
| — | Danh sách IP / VPN công ty cho ALB | Tech lead / IT | 30/10/2026 — **quá hạn** | Không có thì phải thêm lớp xác thực (Plan §4) |
| OQ-006, OQ-007 | Hạn bàn giao và ngân sách chính thức | Quản lý | 27/10/2026 — **quá hạn** | CON-005, CON-006 |
| OQ-002, OQ-003 | Baseline và mục tiêu thời gian tìm kiếm | Đội BD / Quản lý | 03/11/2026 | Không có thì không chứng minh được BO-001 |
| OQ-004, OQ-021 | Duyệt các ngưỡng ⚑ | Quản lý + Tech lead | 03/11/2026 | Là ngưỡng nghiệm thu |
| OQ-005 | Quy mô đội BD | Quản lý | 03/11/2026 | Quy mô và MET-003 |
| DEP-002 | Bộ PDF mẫu, ≥ 30 câu positive và ≥ 10 câu negative | Đội BD | 05/11/2026 (Plan §3) | Cần cho T-023 và UAT |
| OQ-016 | Thời gian lưu và cách xóa tài liệu | Bảo mật | 03/11/2026 | Tuân thủ |

## 8. Owner, tiêu chí chấp nhận và risk tier

**Owner:** Huy Toan (PO / Tech lead).

**Tiêu chí chấp nhận intent** (lấy từ UAT trong T-024):

1. PDF của dự án đều Sẵn sàng hoặc báo rõ lý do lỗi.
2. Ít nhất 8/10 câu hỏi thường gặp nhận được câu trả lời dùng được.
3. 3 câu không có trong tài liệu đều nhận "không tìm thấy".
4. Không truy cập được từ mạng ngoài công ty.
5. Biên bản UAT đã ký và có quyết định go / no-go.

**Risk tier đề xuất: High.** Lý do:

- Tài liệu kinh doanh chưa rõ phân loại bảo mật có thể được gửi tới dịch vụ AI bên ngoài (RSK-002, OQ-008).
- Không có đăng nhập: ai trong mạng công ty cũng đọc được mọi tài liệu (Plan §1, đánh đổi 2).
- Câu trả lời sai có thể dẫn tới quyết định kinh doanh sai, và người dùng không có trích dẫn để kiểm chứng (RSK-001, Plan §1, đánh đổi 1 và 3).

**Hệ quả nếu giữ mức High:** theo `agentic-sdlc-process.md`, thay đổi rủi ro cao cần inspection (L3) và demo xác nhận với stakeholder (L4), ngoài review của người (L2).

## 9. Phê duyệt

Người soạn không tự duyệt tài liệu này. Dùng phiếu [Phe_duyet_v0.4_OQ-008.md](../05-development/evidence/Phe_duyet_v0.4_OQ-008.md).
