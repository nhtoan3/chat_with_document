from fastapi import FastAPI

from app.api.routers import documents
from app.platform.config import get_settings
from app.platform.errors import install_error_handlers
from app.platform.logging import configure_logging, install_request_logging


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings.log_level)

    app = FastAPI(
        title="Chat với tài liệu — API",
        version="0.1.0",
        docs_url="/api/v1/docs",
        openapi_url="/api/v1/openapi.json",
    )
    install_error_handlers(app)
    install_request_logging(app)

    @app.get("/healthz", include_in_schema=False)
    async def healthz() -> dict:
        return {"status": "ok"}

    app.include_router(documents.router, prefix="/api/v1")
    return app


app = create_app()
