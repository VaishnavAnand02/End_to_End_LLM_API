import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_DIR = os.path.join(BASE_DIR,"model")
MODEL_PATH = os.path.join(MODEL_DIR,"llama.gguf")

MAX_TOKENS = 100
N_CTX = 2048