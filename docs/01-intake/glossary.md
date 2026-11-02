# Thuật ngữ — "Chat với tài liệu" (MVP)

> **GLO-CWD-001** · v0.1 (`Draft`) · 2026-11-02 · Tập hợp từ `docs/02-requirements/BRD.md` §13.1 và `PRD.md` §12, bổ sung thuật ngữ đang dùng trong kế hoạch v0.4 và mã nguồn.

## 1. Nghiệp vụ

| Thuật ngữ | Định nghĩa | Nguồn |
|---|---|---|
| AI | Trí tuệ nhân tạo; ở đây là năng lực hiểu câu hỏi ngôn ngữ tự nhiên và tạo câu trả lời từ nội dung tài liệu | BRD |
| BA | Business Analyst — chuyên viên phân tích nghiệp vụ | BRD |
| BD | Business Development — đội phát triển kinh doanh | BRD |
| Bộ tài liệu | Tập hợp các tệp PDF đã tải lên, được dùng chung làm nguồn trả lời câu hỏi | BRD |
| Bộ câu hỏi chuẩn / golden set | Danh sách câu hỏi kèm đáp án tham chiếu do đội BD soạn, dùng để đo chất lượng và nghiệm thu. Trong repo: `backend/tests/eval/golden.yaml` | BRD, T-008 |
| Câu hỏi positive | Câu hỏi có đáp án trong bộ tài liệu | T-008 |
| Câu hỏi âm tính / negative | Câu hỏi về thông tin chắc chắn không có trong bộ tài liệu | PRD, T-008 |
| Câu trả lời đúng | Câu trả lời mà đại diện đội BD đánh giá là khớp nội dung với đáp án tham chiếu | BRD |
| "Bịa" (hallucination) | AI tạo thông tin không có trong tài liệu nguồn | BRD |
| MVP | Minimum Viable Product — phiên bản tối thiểu đủ để đánh giá giá trị | BRD |
| Pilot | Giai đoạn đội BD dùng thử sau go-live, 30/11 → 31/12/2026 | Plan v0.4 |
| Sẵn sàng | Trạng thái tài liệu đã xử lý xong và được dùng làm nguồn trả lời | PRD |
| Trích dẫn | Chỉ dẫn tên tài liệu và số trang chứa thông tin dùng trong câu trả lời. **Không có ở v0.4** | BRD, Plan v0.4 |
| Phiên hội thoại | Chuỗi câu hỏi và trả lời liên tiếp, câu sau có thể tham chiếu câu trước. **Không có ở v0.4:** mỗi câu hỏi độc lập | BRD, SAD |

## 2. Tài liệu PDF

| Thuật ngữ | Định nghĩa | Nguồn |
|---|---|---|
| PDF dạng văn bản | PDF có lớp chữ trích xuất được | BRD |
| PDF dạng scan | PDF chỉ chứa hình ảnh trang giấy, cần OCR để đọc chữ. MVP báo lỗi `no_text_layer` | BRD, T-011 |
| OCR | Nhận dạng ký tự quang học | BRD |

## 3. Kỹ thuật

| Thuật ngữ | Định nghĩa | Nguồn |
|---|---|---|
| Chunk / đoạn | Phần văn bản nhỏ được cắt từ tài liệu để truy xuất | T-012 |
| Embedding | Vector số biểu diễn ý nghĩa của một đoạn văn bản | T-013 |
| `bge-m3` | Mô hình embedding dùng trong dự án (vector 1024 chiều) | SAD ADR-004, T-002 |
| TEI | Text Embeddings Inference — dịch vụ chạy mô hình embedding | T-002 |
| pgvector / HNSW | Tiện ích lưu vector trong PostgreSQL / loại chỉ mục tìm kiếm vector gần đúng | SAD ADR-002, T-004 |
| Truy xuất vector | Tìm các đoạn có ý nghĩa gần câu hỏi nhất bằng độ tương đồng vector | T-017 |
| `qa_log` | Bảng lưu số liệu mỗi lần hỏi (trạng thái, độ trễ, token, số đoạn); không lưu nội dung | T-004, T-020 |
| ALB | Application Load Balancer của AWS; nơi giới hạn truy cập theo IP / VPN | T-006 |
| p90 | Giá trị mà 90% số lần đo nhỏ hơn hoặc bằng | PRD |
| RTO / RPO | Thời gian khôi phục mục tiêu / lượng dữ liệu tối đa có thể mất khi sự cố | PRD |
| SSO | Single Sign-On — đăng nhập một lần bằng tài khoản của tổ chức | PRD |

## 4. Quy ước trong tài liệu dự án

| Ký hiệu | Ý nghĩa |
|---|---|
| ⚑ | Giá trị đề xuất, chờ xác nhận (OQ-021) |
| F1 / F2 | Tính năng Xử lý PDF / Hỏi đáp AI của v0.4 |
| T-xxx | Task phát triển, trong `docs/05-development/tasks/` |
| SRC / STK / SN | Nguồn / bên liên quan / nhu cầu |
| BO / MET | Mục tiêu nghiệp vụ / chỉ số |
| BR / BRU | Yêu cầu nghiệp vụ / quy tắc nghiệp vụ |
| CON / ASM / DEP / RSK | Ràng buộc / giả định / phụ thuộc / rủi ro |
| OQ | Câu hỏi mở |
| US / AC | User story / tiêu chí chấp nhận |
| FR / NFR | Yêu cầu chức năng / phi chức năng |
| KR | Key Result trong OKR của PRD |
| ADR | Architecture Decision Record — bản ghi quyết định kiến trúc |
