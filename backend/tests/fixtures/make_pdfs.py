"""Generate PDF fixtures for tests (T-016). Run: python tests/fixtures/make_pdfs.py

Files are small and deterministic; big ones (21 MB, 301 pages) are generated
on the fly inside the tests instead of being committed.
"""

from pathlib import Path

import pymupdf

HERE = Path(__file__).parent / "pdfs"

SAMPLE_DOCS = {
    "Hop_dong_khung_ABC_2026.pdf": [
        "HỢP ĐỒNG KHUNG SỐ 01/2026/ABC\n\nĐiều 6. Giá trị hợp đồng và phương thức thanh toán.\n\n"
        "6.2. Bên A tạm ứng cho Bên B 30% giá trị đơn hàng trong vòng 10 ngày làm việc kể từ ngày ký "
        "hợp đồng. 6.5. Bên A thanh toán 50% sau khi hai bên ký biên bản nghiệm thu giai đoạn 1; 20% còn "
        "lại được thanh toán sau nghiệm thu cuối cùng.",
        "Điều 7. Phạt vi phạm.\n\n7.2. Trường hợp Bên A chậm thanh toán, Bên A chịu phạt 0,05% mỗi ngày "
        "trên số tiền chậm trả, tổng mức phạt không vượt quá 8% giá trị phần nghĩa vụ bị vi phạm.",
    ],
    "De_xuat_hop_tac_Minh_Phat.pdf": [
        "ĐỀ XUẤT HỢP TÁC — CÔNG TY MINH PHÁT\n\nĐiều kiện hợp tác đề xuất: thời hạn hợp tác 24 tháng, áp "
        "dụng chiết khấu 12% cho các đơn hàng có giá trị từ 500 triệu đồng trở lên. Minh Phát mong muốn trở "
        "thành đối tác phân phối chiến lược tại khu vực phía Nam.",
    ],
    "Bien_ban_hop_doi_tac_15-09.pdf": [
        "BIÊN BẢN HỌP NGÀY 15/09/2026\n\nKết luận: hai bên thống nhất triển khai giai đoạn thử nghiệm 3 "
        "tháng trước khi ký hợp đồng chính thức. Minh Phát gửi hồ sơ năng lực bổ sung trước ngày 30/09.",
    ],
}


def _find_unicode_font() -> str | None:
    for path in (
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/dejavu/DejaVuSans.ttf",
    ):
        if Path(path).exists():
            return path
    return None


def text_pdf(pages: list[str]) -> bytes:
    """A real text-layer PDF with Vietnamese diacritics."""
    font = _find_unicode_font()
    doc = pymupdf.open()
    for body in pages:
        page = doc.new_page()
        rect = pymupdf.Rect(50, 50, 545, 790)
        if font:
            page.insert_textbox(rect, body, fontsize=11, fontname="vn", fontfile=font)
        else:  # Fallback: built-in font (diacritics may be lost, still a text layer)
            page.insert_textbox(rect, body, fontsize=11)
    if font:
        doc.subset_fonts()  # embed only the glyphs used, otherwise the file is ~23 MB
    data = doc.tobytes(garbage=4, deflate=True)
    doc.close()
    return data


def many_pages_pdf(n: int) -> bytes:
    doc = pymupdf.open()
    for i in range(n):
        doc.new_page().insert_text((72, 72), f"Trang {i + 1} co noi dung van ban de kiem thu.")
    data = doc.tobytes()
    doc.close()
    return data


def encrypted_pdf() -> bytes:
    doc = pymupdf.open(stream=text_pdf(["Tài liệu mật có mật khẩu bảo vệ, nội dung đủ dài để có văn bản."]))
    data = doc.tobytes(encryption=pymupdf.PDF_ENCRYPT_AES_256, user_pw="secret", owner_pw="owner")
    doc.close()
    return data


def scanned_pdf() -> bytes:
    """Pages containing only an image, no text layer."""
    doc = pymupdf.open()
    pix = pymupdf.Pixmap(pymupdf.csRGB, pymupdf.IRect(0, 0, 200, 100), False)
    pix.clear_with(200)
    for _ in range(3):
        page = doc.new_page()
        page.insert_image(pymupdf.Rect(50, 50, 450, 250), pixmap=pix)
    data = doc.tobytes()
    doc.close()
    return data


def corrupted_pdf() -> bytes:
    data = text_pdf(["Nội dung sẽ bị cắt mất phần cuối để làm hỏng tệp PDF này cho kiểm thử."])
    return b"%PDF-1.7\n" + data[9 : len(data) // 3]


def fake_pdf() -> bytes:
    return b"PK\x03\x04 this is a docx (zip) renamed to .pdf"


def write_all() -> None:
    (HERE / "sample").mkdir(parents=True, exist_ok=True)
    for name, pages in SAMPLE_DOCS.items():
        (HERE / "sample" / name).write_bytes(text_pdf(pages))
    (HERE / "encrypted.pdf").write_bytes(encrypted_pdf())
    (HERE / "scanned.pdf").write_bytes(scanned_pdf())
    (HERE / "corrupted.pdf").write_bytes(corrupted_pdf())
    (HERE / "fake.pdf").write_bytes(fake_pdf())


if __name__ == "__main__":
    write_all()
    print("fixtures written to", HERE)
