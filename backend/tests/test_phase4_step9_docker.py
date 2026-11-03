from pathlib import Path


BACKEND = Path(__file__).parents[1]


def test_phase4_step9_docker_configuration_uses_pip_and_healthcheck() -> None:
    dockerfile = (BACKEND / "Dockerfile").read_text()
    compose = (BACKEND / "compose.yaml").read_text()
    dockerignore = (BACKEND / ".dockerignore").read_text()

    assert "python -m pip install" in dockerfile
    assert "uv " not in dockerfile.lower()
    assert "HEALTHCHECK" in dockerfile
    assert "http://127.0.0.1:8000/health" in dockerfile
    assert "healthcheck:" in compose
    assert "ENV: development" in compose
    assert ".env" in dockerignore
    assert "tests" in dockerignore


def test_phase4_step9_deployment_files_do_not_embed_credentials() -> None:
    deployment_files = (
        (BACKEND / "Dockerfile").read_text(),
        (BACKEND / "compose.yaml").read_text(),
    )
    combined = "\n".join(deployment_files).lower()

    assert "password" not in combined
    assert "secret" not in combined
    assert "token" not in combined
    assert "api_key" not in combined
