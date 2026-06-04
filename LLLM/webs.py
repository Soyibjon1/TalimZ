import asyncio
import json
import base64
import threading
import logging

import torch
import vosk
import numpy as np
import websockets

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)


class AudioServer:
    TTS_RATE = 24000
    STT_RATE = 8000

    def __init__(self, host: str = "0.0.0.0", port: int = 8765):
        self.host = host
        self.port = port
        self._tts_lock = threading.Lock()
        self._yuklash()

    def _yuklash(self):
        logging.info("TTS (Silero) yuklanmoqda...")
        self._tts, _ = torch.hub.load(
            repo_or_dir='snakers4/silero-models',
            model='silero_tts',
            language='uz',
            speaker='v4_uz',
            verbose=False
        )
        self._tts.to('cpu')

        logging.info("STT (Vosk) yuklanmoqda...")
        self._vosk = vosk.Model("vosk-model-small-uz-0.22")
        logging.info("Modellar tayyor.")

    def gapir(self, matn: str) -> bytes:
        """Matn → PCM int16 bytes (24000 Hz mono)"""
        with self._tts_lock:
            audio = self._tts.apply_tts(
                text=matn.strip() + '.',
                speaker='dilnavoz',
                sample_rate=self.TTS_RATE,
            )
        return (audio.numpy() * 32767).astype(np.int16).tobytes()

    def eshit(self, audio_bytes: bytes, rec: vosk.KaldiRecognizer) -> tuple:
        """
        Audio chunk (PCM int16, 8000 Hz) → (toliq_matn|None, qisman|None)
        rec: har bir WebSocket ulanish uchun alohida KaldiRecognizer beriladi
        """
        if rec.AcceptWaveform(audio_bytes):
            matn = json.loads(rec.Result()).get('text', '').strip()
            return (matn or None, None)
        qisman = json.loads(rec.PartialResult()).get('partial', '').strip()
        return (None, qisman or None)

    async def _handler(self, ws):
        rec = vosk.KaldiRecognizer(self._vosk, self.STT_RATE)
        addr = ws.remote_address
        logging.info(f"Yangi ulanish: {addr}")
        try:
            async for xabar in ws:
                try:
                    data = json.loads(xabar)
                    action = data.get('action')

                    if action == 'gapir':
                        matn = data.get('matn', '').strip()
                        if matn:
                            audio_b = await asyncio.to_thread(self.gapir, matn)
                            await ws.send(json.dumps({
                                'type': 'audio',
                                'audio': base64.b64encode(audio_b).decode(),
                                'rate': self.TTS_RATE
                            }))

                    elif action == 'eshit':
                        audio_b = base64.b64decode(data.get('audio', ''))
                        toliq, qisman = await asyncio.to_thread(self.eshit, audio_b, rec)
                        if toliq:
                            await ws.send(json.dumps({'type': 'matn', 'matn': toliq}))
                        elif qisman:
                            await ws.send(json.dumps({'type': 'qisman', 'matn': qisman}))

                    elif action == 'matn':
                        await ws.send(json.dumps({
                            'type': 'matn',
                            'matn': data.get('matn', '')
                        }))

                except Exception as e:
                    await ws.send(json.dumps({'type': 'xato', 'xabar': str(e)}))

        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            logging.info(f"Ulanish yopildi: {addr}")

    async def _serve(self):
        async with websockets.serve(self._handler, self.host, self.port):
            logging.info(f"WebSocket server tayyor: ws://{self.host}:{self.port}")
            await asyncio.Future()

    def run(self):
        asyncio.run(self._serve())


if __name__ == '__main__':
    AudioServer().run()
