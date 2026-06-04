from threading import Thread
import vosk, joblib
import sounddevice as sd
import queue
import json
import torch
import sys
from chat import Chat

class Muloqot:
    def __init__(self):
        self.model_path = "vosk-model-small-uz-0.22"
        self.sample_rate = 8000
        self.chunk = 4096
        self.tayorlan()
        model_index = int(sys.argv[1]) if len(sys.argv) > 1 else 1
        self.chat = Chat(model_index=model_index)

    def tayorlan(self):
        device = torch.device('cpu')
        self._model, self.example_text = torch.hub.load(
            repo_or_dir='snakers4/silero-models',
            model='silero_tts',
            language='uz',
            speaker='v4_uz'
        )

        self._model.to(device)
    def gapir(self, matin):
        audio = self._model.apply_tts(
            text=matin+'.',
            speaker='dilnavoz',
            sample_rate=self.sample_rate,
        )
        sd.play(audio.numpy(), samplerate=self.sample_rate)
        sd.wait()
    def callback(self, indata, frames, time, status):
        if status:
            print("Mikrofon xatosi:", status)
        self.audio_queue.put(bytes(indata))
    def aniqla(self, rec):
        with sd.RawInputStream(
                samplerate=self.sample_rate,
                blocksize=self.chunk,
                dtype='int16',
                channels=1,
                callback=self.callback
        ):
            while True:
                data = self.audio_queue.get()

                if rec.AcceptWaveform(data):
                    natija = json.loads(rec.Result())
                    matn = natija.get('text', '').strip()
                    if matn:
                        self.aniqlandi(matn)
                else:
                    qisman = json.loads(rec.PartialResult())
                    q = qisman.get('partial', '').strip()
                    if q:
                        print(f"  ... {q}", end='\r')
    def eshit(self):
        model = vosk.Model(self.model_path)
        rec = vosk.KaldiRecognizer(model, self.sample_rate)
        self.audio_queue = queue.Queue()
        print("Boshlandi")
        self.aniqla(rec)

    def aniqlandi(self, matn):
        print("Kirish:",matn)

        if not matn:
            return
        print(f"Model: {self.chat.model}  |  Chiqish: Ctrl+C\n")
        javob=self.chat.sora(matn)
        print(f"AI: {javob}\n")
        Thread(target=self.gapir, args=(javob,)).start()

        # print("Chiqish:",self.buyuruq(matin))
    def buyuruq(self, kirish):
        model = joblib.load("roboqol_25-40.pkl")
        result = model.predict([kirish])[0]
        return result

if __name__=='__main__':
    Muloqot().eshit()