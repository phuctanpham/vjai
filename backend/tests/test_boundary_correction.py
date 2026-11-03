from __future__ import annotations

import base64
import json

import pytest


def _decode(value: str) -> dict[str, object]:
    return json.loads(base64.urlsafe_b64decode(value + "=" * (-len(value) % 4)))


def test_powersync_issuer_creates_scoped_short_lived_jwt() -> None:
    from app.auth.powersync import (
        DeterministicPowerSyncJwtIssuer,
        PowerSyncTokenSettings,
    )
    from app.auth.ports import Principal

    issuer = DeterministicPowerSyncJwtIssuer(
        PowerSyncTokenSettings("https://sync.example", "prod-rsa-key-1", "private", "https://sync.example")
    )
    header, claims, signature = issuer.issue(Principal("owner-1")).split(".")
    assert _decode(header)["kid"] == "prod-rsa-key-1"
    assert _decode(header)["alg"] == "RS256"
    assert _decode(claims)["sub"] == "owner-1"
    assert _decode(claims)["aud"] == "https://sync.example"
    assert _decode(claims)["exp"] > _decode(claims)["iat"]
    assert signature


def test_powersync_issuer_rejects_missing_key_material() -> None:
    from app.auth.powersync import (
        DeterministicPowerSyncJwtIssuer,
        PowerSyncTokenError,
        PowerSyncTokenSettings,
    )

    with pytest.raises(PowerSyncTokenError):
        DeterministicPowerSyncJwtIssuer(PowerSyncTokenSettings("", "", "", ""))


def test_openssl_signer_produces_a_real_rsa_signature() -> None:
    import subprocess
    from app.auth.powersync import OpenSSLRS256Signer, PowerSyncJwtIssuer, PowerSyncTokenSettings
    from app.auth.ports import Principal

    private_key = subprocess.check_output(
        ["openssl", "genpkey", "-algorithm", "RSA", "-pkeyopt", "rsa_keygen_bits:2048"],
        stderr=subprocess.DEVNULL,
        text=True,
    )
    issuer = PowerSyncJwtIssuer(
        PowerSyncTokenSettings("https://sync.example", "kid", private_key, "https://sync.example"),
        OpenSSLRS256Signer(),
    )
    token = issuer.issue(Principal("owner-1"))
    assert len(token.split(".")) == 3
    assert len(token.rsplit(".", 1)[1]) > 300


def test_rustfs_presigner_scopes_and_separates_put_and_get() -> None:
    from app.adapters.presigned import DeterministicRustFSPresigner, PresigningError

    presigner = DeterministicRustFSPresigner("https://storage.example", "secret")
    put = presigner.put_url("owner-1", "owner-1/photo.jpg")
    get = presigner.get_url("owner-1", "owner-1/photo.jpg")
    assert put.method == "PUT"
    assert get.method == "GET"
    assert put.url != get.url
    with pytest.raises(PresigningError):
        presigner.get_url("owner-1", "owner-2/photo.jpg")


def test_rustfs_production_boundary_requires_injected_s3_presigner() -> None:
    from app.adapters.presigned import PresigningError, RustFSS3Presigner

    with pytest.raises(PresigningError, match="presign"):
        RustFSS3Presigner("https://storage.example", "garblo")

    presigner = RustFSS3Presigner(
        "https://storage.example",
        "garblo",
        presign=lambda bucket, key, method, expires: f"https://signed/{method}/{key}",
    )
    result = presigner.put_url("owner-1", "owner-1/photo.jpg")
    assert result.url == "https://signed/PUT/owner-1/photo.jpg"
