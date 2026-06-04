import ollama, time

SYSTEM = """Sen faqat o'zbek tilida javob beradigan yordamchisan.
Hech qachon boshqa tilda javob berma.
Qisqa, aniq va tushunarli o'zbek tilida yoz.
Ruscha yoki inglizcha so'zlarni ishlatma.!"""


class Chat:
    def __init__(self):
        self.model = "gemma4:e2b"
        self.tarix = []

    def sora(self, matn: str) -> str:
        self.tarix.append({"role": "user", "content": matn})
        try:
            javob = ollama.chat(
                model=self.model,
                messages=[{"role": "system", "content": SYSTEM}] + self.tarix[-6:],
                options={"temperature": 0.7, "num_predict": 300},
            )
            matni = javob["message"]["content"].strip()
        except Exception as e:
            matni = f"Xato: {e}"
        self.tarix.append({"role": "assistant", "content": matni})
        return matni

    def tozala(self):
        self.tarix = []


if __name__ == "__main__":
    model_index = -1
    chat = Chat()
    print(f"Model: {chat.model}  |  Chiqish: Ctrl+C\n")

    while True:
        try:
            matn = input("Siz: ").strip()
            boshlanish=time.time()
            if not matn:
                continue
            print(f"AI: {chat.sora(matn)}\nSaroflangan vaqt: {(time.time() - boshlanish):.1f}")

        except KeyboardInterrupt:
            print("\nXayr!")
            break
