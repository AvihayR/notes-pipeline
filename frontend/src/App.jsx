import { useState } from 'react'
import './App.css'
import Header from '../cmps/Header'
import BigNote from '../cmps/BigNote'
import Footer from '../cmps/Footer'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <Header />
      <BigNote />
      <Footer />
    </>
  )
}

export default App
