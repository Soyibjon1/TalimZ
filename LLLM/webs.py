import asyncio
import json
import base64
import logging

import websockets
from miyya import Chat
from Muloqot import TTS, STT

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)


class AudioServer:
    def __init__(self, host: str = "192.168.1.10", port: int = 8765):
        self.host = host
        self.port = port
        logging.info("TTS yuklanmoqda...")
        self._tts = TTS()
        logging.info("STT yuklanmoqda...")
        self._stt = STT()
        logging.info("Modellar tayyor.")

    async def _handler(self, ws):
        rec = self._stt.yangi_tanuvchi()
        chat = Chat()
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
                            audio_b = await asyncio.to_thread(self._tts.gapir, matn)
                            await ws.send(json.dumps({
                                'type': 'audio',
                                'audio': base64.b64encode(audio_b).decode(),
                                'rate': TTS.RATE
                            }))

                    elif action == 'eshit':
                        audio_b = base64.b64decode(data.get('audio', ''))
                        toliq, qisman = await asyncio.to_thread(self._stt.eshit, audio_b, rec)
                        if toliq:
                            print(toliq)
                            await ws.send(json.dumps({'type': 'matn', 'matn': toliq}))
                        elif qisman:
                            await ws.send(json.dumps({'type': 'qisman', 'matn': qisman}))

                    elif action == 'savol':
                        matn = data.get('matn', '').strip()
                        if matn:
                            javob = await asyncio.to_thread(chat.sora, matn)
                            await ws.send(json.dumps({'type': 'javob', 'matn': javob}))

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
