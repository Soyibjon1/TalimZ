import { useState, useEffect, useRef } from 'react'

export default function Chat({ yuborish, handlerQoshish }) {
  const [xabarlar, setXabarlar] = useState([])
  const [matn, setMatn] = useState('')
  const [kutilmoqda, setKutilmoqda] = useState(false)
  const pastRef = useRef(null)
  const inputRef = useRef(null)

  useEffect(() => {
    return handlerQoshish('chat', (data) => {
      if (data.type === 'javob') {
        setXabarlar(prev => [...prev, { rol: 'ai', matn: data.matn }])
        setKutilmoqda(false)
        // Focus input after reply
        setTimeout(() => inputRef.current?.focus(), 50)
      } else if (data.type === 'xato') {
        setXabarlar(prev => [...prev, { rol: 'ai', matn: `❌ Xato: ${data.xabar}` }])
        setKutilmoqda(false)
      }
    })
  }, [handlerQoshish])

  useEffect(() => {
    pastRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [xabarlar, kutilmoqda])

  const jonatish = () => {
    const text = matn.trim()
    if (!text || kutilmoqda) return
    setXabarlar(prev => [...prev, { rol: 'user', matn: text }])
    yuborish({ action: 'savol', matn: text })
    setKutilmoqda(true)
    setMatn('')
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      jonatish()
    }
  }

  return (
    <div className="chat">
      <div className="xabarlar-list">
        {xabarlar.length === 0 && (
          <p className="bosh-xabar">Savol yozing, AI o'zbek tilida javob beradi.</p>
        )}

        {xabarlar.map((x, i) => (
          <div key={i} className={`xabar xabar-${x.rol}`}>
            <span className="xabar-rol">{x.rol === 'user' ? 'Siz' : 'AI'}</span>
            <p className="xabar-matn" style={{ whiteSpace: 'pre-wrap' }}>{x.matn}</p>
          </div>
        ))}

        {kutilmoqda && (
          <div className="xabar xabar-ai">
            <span className="xabar-rol">AI</span>
            <p className="xabar-matn yuklanish">. . .</p>
          </div>
        )}
        <div ref={pastRef} />
      </div>

      <div className="kiritish-qator">
        <input
          ref={inputRef}
          className="kiritish"
          value={matn}
          onChange={e => setMatn(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Savolingizni yozing... (Enter — yuborish)"
          disabled={kutilmoqda}
          autoFocus
        />
        <button
          className="btn btn-asosiy"
          onClick={jonatish}
          disabled={kutilmoqda || !matn.trim()}
        >
          Yuborish
        </button>
      </div>
    </div>
  )
}
