from fastapi import FastAPI


def create_app() -> FastAPI:
    app = FastAPI(
        title="Chat với tài liệu — API",
        version="0.1.0",
        docs_url="/api/v1/docs",
        openapi_url="/api/v1/openapi.json",
    )

    @app.get("/healthz", include_in_schema=False)
    async def healthz() -> dict:
        return {"status": "ok"}

    return app


app = create_app()
