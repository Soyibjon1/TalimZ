import { useState, useEffect, useRef } from 'react'

// Convert Float32 mic audio to Int16 base64 for the backend
const f32ToI16B64 = (f32) => {
  const i16 = new Int16Array(f32.length)
  for (let i = 0; i < f32.length; i++) {
    i16[i] = Math.max(-32768, Math.min(32767, f32[i] * 32767))
  }
  const bytes = new Uint8Array(i16.buffer)
  let bin = ''
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i])
  return btoa(bin)
}

// Play Int16 PCM audio from base64
const audioIjro = async (b64, rate) => {
  if (!b64) return // TTS not configured yet
  try {
    const bytes = Uint8Array.from(atob(b64), c => c.charCodeAt(0))
    const i16 = new Int16Array(bytes.buffer)
    const ctx = new AudioContext({ sampleRate: rate })
    const buf = ctx.createBuffer(1, i16.length, rate)
    const ch = buf.getChannelData(0)
    for (let i = 0; i < i16.length; i++) ch[i] = i16[i] / 32767
    const src = ctx.createBufferSource()
    src.buffer = buf
    src.connect(ctx.destination)
    src.start()
    src.onended = () => ctx.close()
  } catch (err) {
    console.error('Audio playback error:', err)
  }
}

export default function Voice({ yuborish, handlerQoshish }) {
  const [tinglayapti, setTinglayapti] = useState(false)
  const [aniqlangan, setAniqlangan] = useState('')
  const [qisman, setQisman] = useState('')
  const [ttsMatn, setTtsMatn] = useState('')
  const [ttsYuklanmoqda, setTtsYuklanmoqda] = useState(false)
  const audioCtxRef = useRef(null)
  const processorRef = useRef(null)
  const streamRef = useRef(null)

  useEffect(() => {
    return handlerQoshish('voice', (data) => {
      if (data.type === 'matn') {
        setAniqlangan(prev => prev + (prev ? '\n' : '') + data.matn)
        setQisman('')
      } else if (data.type === 'qisman') {
        setQisman(data.matn)
      } else if (data.type === 'audio') {
        setTtsYuklanmoqda(false)
        audioIjro(data.audio, data.rate)
      } else if (data.type === 'xato') {
        setTtsYuklanmoqda(false)
        console.error('Voice error:', data.xabar)
      }
    })
  }, [handlerQoshish])

  const tinglashBoshlash = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      streamRef.current = stream

      const ctx = new AudioContext({ sampleRate: 8000 })
      audioCtxRef.current = ctx

      const source = ctx.createMediaStreamSource(stream)
      const processor = ctx.createScriptProcessor(4096, 1, 1)
      processorRef.current = processor

      processor.onaudioprocess = (e) => {
        const f32 = e.inputBuffer.getChannelData(0)
        yuborish({ action: 'eshit', audio: f32ToI16B64(f32) })
      }

      source.connect(processor)
      processor.connect(ctx.destination)
      setTinglayapti(true)
    } catch (err) {
      alert('Mikrofonga ruxsat berilmadi: ' + err.message)
    }
  }

  const tinglashToxtatish = () => {
    processorRef.current?.disconnect()
    audioCtxRef.current?.close()
    streamRef.current?.getTracks().forEach(t => t.stop())
    processorRef.current = null
    audioCtxRef.current = null
    streamRef.current = null
    setTinglayapti(false)
  }

  const gapirtir = () => {
    if (!ttsMatn.trim()) return
    yuborish({ action: 'gapir', matn: ttsMatn })
    setTtsYuklanmoqda(true)
  }

  return (
    <div className="panel">
      <section className="sektsiya">
        <h2>Nutq tanish (STT)</h2>
        <button
          className={`btn ${tinglayapti ? 'btn-xavfli' : 'btn-asosiy'} btn-katta`}
          onClick={tinglayapti ? tinglashToxtatish : tinglashBoshlash}
        >
          {tinglayapti ? '⏹  Toxtatish' : '🎤  Tinglash'}
        </button>

        {qisman && <p className="qisman-matn">... {qisman}</p>}

        <div className="natija-quti">
          {aniqlangan
            ? aniqlangan.split('\n').map((s, i) => <p key={i}>{s}</p>)
            : <span className="bosh-hint">Aniqlangan matn shu yerda chiqadi</span>
          }
        </div>

        {aniqlangan && (
          <button className="btn btn-ikkilamchi" onClick={() => setAniqlangan('')}>
            Tozalash
          </button>
        )}
      </section>

      <section className="sektsiya">
        <h2>Nutq sintezi (TTS)</h2>
        <div className="qator">
          <input
            className="kiritish"
            value={ttsMatn}
            onChange={e => setTtsMatn(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && gapirtir()}
            placeholder="Matn kiriting..."
            disabled={ttsYuklanmoqda}
          />
          <button
            className="btn btn-asosiy"
            onClick={gapirtir}
            disabled={ttsYuklanmoqda || !ttsMatn.trim()}
          >
            {ttsYuklanmoqda ? '🔊 ...' : '🔊 Gapir'}
          </button>
        </div>
      </section>
    </div>
  )
}
