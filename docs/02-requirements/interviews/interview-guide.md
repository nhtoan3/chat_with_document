# Bộ câu hỏi phỏng vấn

> Soạn từ `sdlc/analysis/BRD_Elicitation_Prompt_IEEE_standard.md` và các câu hỏi mở trong BRD §12, PRD §11. Phạm vi hiện hành: `docs/05-development/Implement_plan.md` v0.4.

**Khi phỏng vấn:** hỏi về việc đã xảy ra gần đây trước khi hỏi ý kiến. Nếu câu trả lời mơ hồ ("nhanh hơn", "nhiều"), hỏi tiếp "bao nhiêu?", "so với hiện nay?", "lần gần nhất là khi nào?". Nếu câu trả lời là một giải pháp, hỏi "việc đó giúp anh/chị đạt được gì?".

## 1. Quản lý giao yêu cầu (STK-001)

| # | Câu hỏi | Đóng |
|---|---|---|
| 1 | Ai là nhà tài trợ, chủ sở hữu nghiệp vụ, người duyệt và người review từng loại tài liệu? | OQ-001 |
| 2 | Điều gì khiến anh/chị giao việc này vào lúc này? Nếu không làm thì mất gì? | BRD §3.4, §3.6 |
| 3 | Sau pilot, kết quả nào khiến anh/chị quyết định đầu tư tiếp? Kết quả nào khiến dừng? | BO-003 |
| 4 | Đội BD có bao nhiêu người? Mức sử dụng nào được coi là đạt? | OQ-005 |
| 5 | Thời gian tìm thông tin cần giảm bao nhiêu mới đáng? | OQ-003 |
| 6 | Tỷ lệ câu trả lời đúng tối thiểu là bao nhiêu để cho đội BD dùng? | OQ-004 |
| 7 | Hạn 30/11/2026 là bắt buộc hay mong muốn? Vì sao? | OQ-006 |
| 8 | Ngân sách là bao nhiêu, gồm cả chi phí AI hằng tháng không? | OQ-007 |
| 9 | Anh/chị có chấp nhận lần lượt từng đánh đổi: không trích dẫn, không đăng nhập, chống bịa chỉ bằng prompt, không gỡ tài liệu trên giao diện? | Plan v0.4 §1 |
| 10 | Có duyệt các đề xuất của BA và các giá trị ⚑ trong PRD không? | OQ-013, OQ-021, OQ-022 |
| 11 | Mức khả dụng theo giờ hành chính 95%, RTO 1 ngày, RPO 24 giờ có chấp nhận được không? | OQ-019 |
| 12 | Toàn đội dùng chung một bộ tài liệu hay mỗi dự án một bộ? | OQ-009 |

## 2. Bảo mật / IT / pháp chế (STK-005)

| # | Câu hỏi | Đóng |
|---|---|---|
| 1 | Tài liệu của dự án thuộc mức phân loại bảo mật nào? Có hợp đồng hoặc NDA nào giới hạn việc chia sẻ không? | OQ-008 |
| 2 | Có được gửi nội dung tài liệu tới dịch vụ AI bên ngoài không? Nếu không, Claude trên AWS Bedrock của tổ chức có được không? | OQ-008 |
| 3 | Có yêu cầu dữ liệu phải lưu ở quốc gia hoặc khu vực nào không? | OQ-008 |
| 4 | Chỉ giới hạn truy cập theo IP / VPN, không đăng nhập, có đạt yêu cầu không? | OQ-014 |
| 5 | Dải IP / VPN nào được phép? Ai cấp, khi nào? | T-006 |
| 6 | Tài liệu cần lưu bao lâu và xóa như thế nào? | OQ-016 |
| 7 | Tổ chức có sẵn tài khoản đám mây hoặc SSO không? | OQ-020 |
| 8 | Có cần rà soát bảo mật trước go-live không? Ai thực hiện? | Plan v0.4 §1 |

## 3. Nhân viên BD (STK-002)

**Công việc hiện tại**

| # | Câu hỏi | Đóng |
|---|---|---|
| 1 | Lần gần nhất anh/chị phải tìm một thông tin trong tài liệu dự án là khi nào? Hãy kể lại từng bước. | BRD §3.1 |
| 2 | Lần đó mất bao lâu? Mở bao nhiêu tệp? | OQ-002 |
| 3 | Một tuần anh/chị tìm như vậy bao nhiêu lần? | OQ-005 |
| 4 | Lần nào tìm thiếu hoặc sai? Hậu quả ra sao? | RSK-001 |
| 5 | Những câu hỏi nào thường gặp nhất? Có thể đưa ra ví dụ kèm đáp án không? | DEP-002 |

**Tài liệu**

| # | Câu hỏi | Đóng |
|---|---|---|
| 6 | Dự án có khoảng bao nhiêu tệp? Tệp lớn nhất bao nhiêu trang, bao nhiêu MB? | OQ-011 |
| 7 | Có tệp dạng ảnh scan không? Khoảng bao nhiêu phần trăm? | OQ-012 |
| 8 | Tài liệu và câu hỏi dùng ngôn ngữ nào? | OQ-010 |
| 9 | Có tài liệu nào không phải ai trong đội cũng được xem không? | OQ-008, OQ-009 |

**Kỳ vọng với công cụ**

| # | Câu hỏi | Đóng |
|---|---|---|
| 10 | Khi nhận câu trả lời, anh/chị làm gì để tin được nó? Không có trích dẫn trang thì có dùng được không? | SN-003 |
| 11 | Chờ tối đa bao nhiêu giây thì còn chấp nhận được? | OQ-015 |
| 12 | Có cần dùng trên điện thoại không? | OQ-017 |
| 13 | Điều gì sẽ khiến anh/chị bỏ không dùng công cụ này? | BO-003 |
| 14 | Anh/chị có thể tham gia bài đo baseline và UAT ngày 26/11/2026 không? | OQ-002, T-024 |
