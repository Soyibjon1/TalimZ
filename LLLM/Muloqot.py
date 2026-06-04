import json
import threading

import torch
import vosk
import numpy as np


class TTS:
    RATE = 24000

    def __init__(self):
        self._lock = threading.Lock()
        self._model, _ = torch.hub.load(
            repo_or_dir='snakers4/silero-models',
            model='silero_tts',
            language='uz',
            speaker='v4_uz',
            verbose=False
        )
        self._model.to('cpu')

    def gapir(self, matn: str) -> bytes:
        with self._lock:
            audio = self._model.apply_tts(
                text=matn.strip() + '.',
                speaker='dilnavoz',
                sample_rate=self.RATE,
            )
        return (audio.numpy() * 32767).astype(np.int16).tobytes()


class STT:
    RATE = 8000

    def __init__(self, model_path: str = "vosk-model-small-uz-0.22"):
        self._model = vosk.Model(model_path)

    def yangi_tanuvchi(self) -> vosk.KaldiRecognizer:
        return vosk.KaldiRecognizer(self._model, self.RATE)

    def eshit(self, audio_bytes: bytes, rec: vosk.KaldiRecognizer) -> tuple:
        if rec.AcceptWaveform(audio_bytes):
            matn = json.loads(rec.Result()).get('text', '').strip()
            return (matn or None, None)
        qisman = json.loads(rec.PartialResult()).get('partial', '').strip()
        return (None, qisman or None)
