import { useState, useEffect, useRef } from 'react'

// Convert ArrayBuffer to base64 in chunks (avoids stack overflow for large files)
const faylB64 = (buffer) => {
  const bytes = new Uint8Array(buffer)
  let bin = ''
  const chunk = 8192
  for (let i = 0; i < bytes.length; i += chunk) {
    bin += String.fromCharCode(...bytes.subarray(i, i + chunk))
  }
  return btoa(bin)
}

export default function TestGen({ yuborish, handlerQoshish }) {
  const [savollar, setSavollar] = useState([])
  const [javoblar, setJavoblar] = useState({})
  const [soni, setSoni] = useState(10)
  const [yuklanmoqda, setYuklanmoqda] = useState(false)
  const [natija, setNatija] = useState(null)
  const [xato, setXato] = useState('')
  const fileRef = useRef(null)

  useEffect(() => {
    return handlerQoshish('test', (data) => {
      if (data.type === 'test') {
        if (!Array.isArray(data.test) || data.test.length === 0) {
          setXato('Serverdan bo\'sh test keldi. Iltimos, qayta urinib ko\'ring.')
          setYuklanmoqda(false)
          return
        }
        setSavollar(data.test)
        setJavoblar({})
        setNatija(null)
        setXato('')
        setYuklanmoqda(false)
      } else if (data.type === 'xato') {
        setXato(data.xabar ?? 'Noma\'lum xato yuz berdi')
        setYuklanmoqda(false)
      }
    })
  }, [handlerQoshish])

  const faylTanlash = (e) => {
    const fayl = e.target.files[0]
    if (!fayl) return

    const tur = fayl.name.toLowerCase().endsWith('.pdf') ? 'pdf' : 'pptx'
    setXato('')
    setSavollar([])
    setNatija(null)

    const reader = new FileReader()
    reader.onload = () => {
      yuborish({
        action: 'test_tuz',
        fayl: faylB64(reader.result),
        fayl_turi: tur,
        soni,
      })
      setYuklanmoqda(true)
    }
    reader.onerror = () => {
      setXato('Faylni o\'qishda xato yuz berdi')
    }
    reader.readAsArrayBuffer(fayl)
    e.target.value = '' // allow re-selecting same file
  }

  const javobTanlash = (indeks, harf) => {
    if (natija) return
    setJavoblar(prev => ({ ...prev, [indeks]: harf }))
  }

  const tekshirish = () => {
    let togri = 0
    savollar.forEach((s, i) => {
      if (javoblar[i] === s.togri) togri++
    })
    setNatija({ togri, jami: savollar.length })
  }

  const qaytadan = () => {
    setSavollar([])
    setJavoblar({})
    setNatija(null)
    setXato('')
  }

  const javoblanganSoni = Object.keys(javoblar).length

  return (
    <div className="panel">
      <div className="test-boshqaruv">
        <div className="soni-kiritish">
          <label>Savollar soni:</label>
          <input
            type="number"
            value={soni}
            onChange={e => setSoni(Math.max(1, Math.min(30, +e.target.value)))}
            min={1}
            max={30}
            disabled={yuklanmoqda}
          />
        </div>

        <button
          className="btn btn-asosiy"
          onClick={() => fileRef.current?.click()}
          disabled={yuklanmoqda}
        >
          {yuklanmoqda ? '⏳ Test tuzilmoqda...' : '📄 PDF / PPTX yuklash'}
        </button>

        <input
          ref={fileRef}
          type="file"
          accept=".pdf,.pptx"
          onChange={faylTanlash}
          hidden
        />
      </div>

      {xato && (
        <div className="xato-xabar">
          ❌ {xato}
          <button
            className="btn btn-ikkilamchi"
            style={{ marginLeft: 12, padding: '4px 10px', fontSize: '0.8rem' }}
            onClick={() => setXato('')}
          >
            ✕
          </button>
        </div>
      )}

      {savollar.length > 0 && (
        <>
          <div className="savollar">
            {savollar.map((s, i) => (
              <div key={i} className="savol-karta">
                <p className="savol-matn">
                  <strong>{i + 1}.</strong> {s.savol}
                </p>
                <div className="variantlar">
                  {s.variantlar.map((v) => {
                    const harf = v[0]
                    const tanlangan = javoblar[i] === harf
                    let sinf = 'variant'
                    if (natija) {
                      if (harf === s.togri) sinf += ' togri'
                      else if (tanlangan) sinf += ' xato'
                    } else if (tanlangan) {
                      sinf += ' tanlangan'
                    }
                    return (
                      <label key={harf} className={sinf}>
                        <input
                          type="radio"
                          name={`savol-${i}`}
                          value={harf}
                          checked={tanlangan}
                          onChange={() => javobTanlash(i, harf)}
                          disabled={!!natija}
                        />
                        {v}
                      </label>
                    )
                  })}
                </div>
              </div>
            ))}
          </div>

          <div className="test-pastki">
            {!natija ? (
              <button
                className="btn btn-asosiy"
                onClick={tekshirish}
                disabled={javoblanganSoni < savollar.length}
              >
                Tekshirish ({javoblanganSoni}/{savollar.length})
              </button>
            ) : (
              <div className="natija-panel">
                <div className={`ball ${natija.togri / natija.jami >= 0.7 ? 'yaxshi' : 'yomon'}`}>
                  {natija.togri}/{natija.jami} — {Math.round(natija.togri / natija.jami * 100)}%
                </div>
                <button className="btn btn-ikkilamchi" onClick={qaytadan}>
                  Qaytadan urinish
                </button>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  )
}
