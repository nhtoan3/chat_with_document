"""Dependency providers. Tests override these with fakes via app.dependency_overrides."""

from functools import lru_cache

from app.platform.storage import ObjectStoragePort, S3Storage


@lru_cache
def _storage() -> S3Storage:
    return S3Storage()


def get_storage() -> ObjectStoragePort:
    return _storage()
