
import asyncio
import json
import base64
import sys
import queue
import threading

import sounddevice as sd
import numpy as np
import websockets

SAMPLE_RATE = 8000
CHUNK = 4096

_audio_queue: queue.Queue = queue.Queue()


def _mikrofon_callback(indata, frames, time, status):
    _audio_queue.put(bytes(indata))


def _klaviatura_oqimi(send_queue: asyncio.Queue, loop: asyncio.AbstractEventLoop):
    while True:
        try:
            kiritish = input()
            asyncio.run_coroutine_threadsafe(send_queue.put(kiritish), loop)
        except EOFError:
            break


async def main(url: str):
    async with websockets.connect(url) as ws:
        print(f"Ulandi: {url}")
        print("Gapiring...  |  'g: <matn>' — TTS so'rovi  |  Ctrl+C — chiqish\n")

        stream = sd.RawInputStream(
            samplerate=SAMPLE_RATE,
            blocksize=CHUNK,
            dtype='int16',
            channels=1,
            callback=_mikrofon_callback
        )
        stream.start()

        send_queue: asyncio.Queue = asyncio.Queue()
        loop = asyncio.get_event_loop()

        threading.Thread(
            target=_klaviatura_oqimi,
            args=(send_queue, loop),
            daemon=True
        ).start()

        async def yuboruvchi():
            while True:
                # Mikrofon audio chunklar
                chunks = []
                while not _audio_queue.empty():
                    try:
                        chunks.append(_audio_queue.get_nowait())
                    except queue.Empty:
                        break
                if chunks:
                    audio = b''.join(chunks)
                    await ws.send(json.dumps({
                        'action': 'eshit',
                        'audio': base64.b64encode(audio).decode()
                    }))

                # Klaviatura xabarlari
                while not send_queue.empty():
                    matn = send_queue.get_nowait()
                    if matn.lower().startswith('g:'):
                        text = matn[2:].strip()
                        await ws.send(json.dumps({'action': 'gapir', 'matn': text}))
                        print(f"TTS yuborildi: {text}")
                    else:
                        await ws.send(json.dumps({'action': 'matn', 'matn': matn}))

                await asyncio.sleep(0.05)

        async def qabul_qiluvchi():
            async for xabar in ws:
                data = json.loads(xabar)
                t = data.get('type')
                if t == 'matn':
                    print(f"\nAniqlandi: {data['matn']}")
                elif t == 'qisman':
                    print(f"  ... {data['matn']:<50}", end='\r')
                elif t == 'audio':
                    rate = data.get('rate', 24000)
                    audio_np = np.frombuffer(
                        base64.b64decode(data['audio']), dtype=np.int16
                    ).astype(np.float32) / 32767
                    sd.play(audio_np, samplerate=rate)
                elif t == 'xato':
                    print(f"\nServer xatosi: {data['xabar']}")

        try:
            await asyncio.gather(yuboruvchi(), qabul_qiluvchi())
        finally:
            stream.stop()
            stream.close()


if __name__ == '__main__':
    url = sys.argv[1] if len(sys.argv) > 1 else "ws://localhost:8765"
    try:
        asyncio.run(main(url))
    except KeyboardInterrupt:
        print("\nChiqildi.")
