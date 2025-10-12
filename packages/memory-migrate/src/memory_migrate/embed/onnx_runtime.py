import numpy as np
import onnxruntime as ort


class OnnxEmbedder:
    def __init__(self, model_path: str, provider: str = "CPUExecutionProvider"):
        self.model = ort.InferenceSession(model_path, providers=[provider])
        self.out_name = self.model.get_outputs()[0].name

    def encode(self, texts):
        # NOTE: Simplified placeholder, replace with real tokenizer
        vecs = np.random.randn(len(texts), 384).astype(np.float32)
        norms = np.linalg.norm(vecs, axis=1, keepdims=True) + 1e-12
        return vecs / norms
