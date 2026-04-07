"""ICE — Intrusion Countermeasures Electronics.

Prompt injection classifier served over a Unix socket.
Loads a DeBERTa model fine-tuned for prompt injection detection
and exposes a single POST /classify endpoint.
"""

import argparse
import os
import sys

import torch
import uvicorn
from starlette.applications import Starlette
from starlette.requests import Request
from starlette.responses import JSONResponse
from starlette.routing import Route
from transformers import AutoModelForSequenceClassification, AutoTokenizer

MODEL_NAME = os.environ.get(
    "ICE_MODEL", "protectai/deberta-v3-base-prompt-injection-v2"
)
THRESHOLD = float(os.environ.get("ICE_THRESHOLD", "0.85"))
SOCKET_PATH = os.environ.get("ICE_SOCKET", "/run/user/1000/ice.sock")

tokenizer = None
model = None
label_map = {}


def load_model():
    global tokenizer, model, label_map
    print(f"ice: loading model {MODEL_NAME}", file=sys.stderr)
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
    model.eval()
    # Build label map from model config (id -> label).
    if hasattr(model.config, "id2label"):
        label_map = model.config.id2label
    else:
        label_map = {0: "SAFE", 1: "INJECTION"}
    print(f"ice: model loaded, labels={label_map}", file=sys.stderr)


def classify_text(text: str) -> dict:
    inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
    with torch.no_grad():
        outputs = model(**inputs)
    probs = torch.softmax(outputs.logits, dim=-1)[0]

    # Find the injection class index.
    injection_idx = None
    for idx, label in label_map.items():
        if "injection" in str(label).lower():
            injection_idx = idx
            break
    if injection_idx is None:
        injection_idx = 1

    score = probs[injection_idx].item()
    classification = "suspicious" if score >= THRESHOLD else "clean"

    flags = []
    if classification == "suspicious":
        flags.append("injection_detected")

    return {
        "classification": classification,
        "score": round(score, 4),
        "flags": flags,
    }


async def handle_classify(request: Request) -> JSONResponse:
    try:
        body = await request.json()
    except Exception:
        return JSONResponse({"error": "invalid JSON"}, status_code=400)

    text = body.get("text", "")
    if not text:
        return JSONResponse({"error": "text is required"}, status_code=400)

    result = classify_text(text)
    result["direction"] = body.get("direction", "read")
    return JSONResponse(result)


async def handle_health(request: Request) -> JSONResponse:
    return JSONResponse({"status": "ok", "model": MODEL_NAME})


app = Starlette(
    routes=[
        Route("/classify", handle_classify, methods=["POST"]),
        Route("/health", handle_health, methods=["GET"]),
    ]
)


def main():
    parser = argparse.ArgumentParser(description="ICE classifier daemon")
    parser.add_argument(
        "--socket", default=SOCKET_PATH, help="Unix socket path"
    )
    parser.add_argument(
        "--host", default=None, help="TCP host (overrides socket)"
    )
    parser.add_argument(
        "--port", default=9100, type=int, help="TCP port (with --host)"
    )
    args = parser.parse_args()

    load_model()

    if args.host:
        uvicorn.run(app, host=args.host, port=args.port, log_level="warning")
    else:
        # Clean up stale socket.
        if os.path.exists(args.socket):
            os.unlink(args.socket)

        print(f"ice: listening on {args.socket}", file=sys.stderr)
        uvicorn.run(app, uds=args.socket, log_level="warning")


if __name__ == "__main__":
    main()
