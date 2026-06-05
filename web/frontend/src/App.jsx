import { useState, useEffect, useRef, useCallback } from 'react'
import { Link } from 'react-router-dom'
import './App.css'
import Chat from './components/Chat'
import Voice from './components/Voice'
import TestGen from './components/TestGen'

// Set VITE_WS_URL in your .env file, e.g.:
//   VITE_WS_URL=ws://localhost:8000
//   VITE_WS_URL=wss://your-ngrok-url.ngrok-free.app
const WS_URL = import.meta.env.VITE_WS_URL || 'ws://localhost:8000'

export default function App() {
  const [tab, setTab] = useState('chat')
  const [holat, setHolat] = useState('uzilgan')
  const wsRef = useRef(null)
  const handlersRef = useRef({})
  const retryRef = useRef(null)

  const ulash = useCallback(() => {
    // Clear any pending retry
    if (retryRef.current) clearTimeout(retryRef.current)

    try {
      const ws = new WebSocket(WS_URL)

      ws.onopen = () => {
        setHolat('ulandi')
        console.log('WS connected to', WS_URL)
      }

      ws.onclose = (e) => {
        setHolat('uzilgan')
        console.log('WS closed, reconnecting in 3s...', e.code)
        retryRef.current = setTimeout(ulash, 3000)
      }

      ws.onerror = (e) => {
        setHolat('xato')
        console.error('WS error', e)
      }

      ws.onmessage = (e) => {
        try {
          const data = JSON.parse(e.data)
          Object.values(handlersRef.current).forEach(fn => fn(data))
        } catch (err) {
          console.error('WS parse error', err)
        }
      }

      wsRef.current = ws
    } catch (err) {
      setHolat('xato')
      retryRef.current = setTimeout(ulash, 3000)
    }
  }, [])

  useEffect(() => {
    ulash()
    return () => {
      if (retryRef.current) clearTimeout(retryRef.current)
      wsRef.current?.close()
    }
  }, [ulash])

  const yuborish = useCallback((msg) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(msg))
    } else {
      console.warn('WS not open, dropping message', msg)
    }
  }, [])

  const handlerQoshish = useCallback((kalit, fn) => {
    handlersRef.current[kalit] = fn
    return () => delete handlersRef.current[kalit]
  }, [])

  const tablar = [
    { id: 'chat', nom: '💬 Chat' },
    { id: 'ovoz', nom: '🎤 Ovoz' },
    { id: 'test', nom: '📝 Test' },
  ]

  const holatLabel = {
    ulandi:  '● Ulandi',
    xato:    '● Xato',
    uzilgan: '○ Uzilgan',
  }[holat]

  return (
    <div className="ilova">
      <header className="sarlavha">
        <h1>LLLM</h1>
        <Link to="/" style={{ fontSize: 13, opacity: 0.85 }}>← TalimZ</Link>
        <span className={`holat holat-${holat}`}>{holatLabel}</span>
      </header>

      <nav className="tablar">
        {tablar.map(t => (
          <button
            key={t.id}
            className={`tab ${tab === t.id ? 'faol' : ''}`}
            onClick={() => setTab(t.id)}
          >
            {t.nom}
          </button>
        ))}
      </nav>

      <main className="asosiy">
        {tab === 'chat' && <Chat yuborish={yuborish} handlerQoshish={handlerQoshish} />}
        {tab === 'ovoz' && <Voice yuborish={yuborish} handlerQoshish={handlerQoshish} />}
        {tab === 'test' && <TestGen yuborish={yuborish} handlerQoshish={handlerQoshish} />}
      </main>
    </div>
  )
}
