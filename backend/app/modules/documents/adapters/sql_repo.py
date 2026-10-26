"""SQL access for documents (T-009)."""

import uuid

from sqlalchemy import func, insert, select
from sqlalchemy.ext.asyncio import AsyncConnection

from app.platform.db_schema import documents, ingestion_jobs


async def count_documents(conn: AsyncConnection) -> int:
    return (await conn.execute(select(func.count()).select_from(documents))).scalar_one()


async def existing_filenames(conn: AsyncConnection, names: list[str]) -> set[str]:
    if not names:
        return set()
    rows = await conn.execute(select(documents.c.filename).where(documents.c.filename.in_(names)))
    return {r[0] for r in rows}


async def insert_document_with_job(
    conn: AsyncConnection, *, doc_id: uuid.UUID, filename: str, size_bytes: int, storage_key: str
) -> None:
    await conn.execute(
        insert(documents).values(
            id=doc_id, filename=filename, size_bytes=size_bytes, storage_key=storage_key, status="queued"
        )
    )
    await conn.execute(insert(ingestion_jobs).values(document_id=doc_id))
