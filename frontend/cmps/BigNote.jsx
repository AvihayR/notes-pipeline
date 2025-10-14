import { useState, useEffect } from "react"
import { getNotes, deleteNote, getNote, createNote, updateNote } from "../services/apiService"
import SubNote from "./SubNote"


let initialPlaceHolders = Array(7).fill({ desc: "", completed: false })


export default function BigNote() {
    const [placeHolders, setPlaceHolders] = useState(initialPlaceHolders)
    const [notes, setNotes] = useState([])

    useEffect(() => {
        getNotes().then((res) => {
            setNotes(res.notes)
        }).catch((error) => {
            console.error('Error fetching notes:', error)
        })
    }, [])

    useEffect(() => {
        if (notes.length > 0) {
            populatePlaceHolders()
        }
    }, [notes])


    function addPlaceHolder() {
        if (placeHolders.length >= 99) return
        setPlaceHolders(p => [...p, { desc: '', completed: false }])
    }


    function populatePlaceHolders() {
        let updatedPlaceHolders = [...placeHolders]

        while (updatedPlaceHolders.length < notes.length) {
            updatedPlaceHolders.unshift({ desc: "", completed: false })
        }

        updatedPlaceHolders = updatedPlaceHolders.map((placeholder, index) => {
            if (notes[index]) {
                return {
                    ...placeholder,
                    desc: notes[index].desc,
                    note_id: notes[index].note_id,
                    completed: notes[index].completed
                }
            }
            return placeholder
        })

        setPlaceHolders(updatedPlaceHolders)
    }


    async function handleUpdate(ev, note, i) {
        let updatedNote = { ...note, desc: ev.target.value }

        if (!note.note_id) {
            console.log('New note! 🎉', i)
            const res = await createNote(updatedNote)
            updatedNote = res.note

            if (i === 0) {
                const newNotes = [...notes]
                newNotes.splice(i, 0, updatedNote)
                setNotes(newNotes)
            }
        }

        setPlaceHolders(placeHolders.map((ph, index) => index === i ? updatedNote : ph))

        const updatedNotes = notes.map(n => n.note_id === note.note_id ? updatedNote : n)
        setNotes(updatedNotes)
    }


    async function handleDelete(note_id) {
        try {
            await deleteNote(note_id)
            setNotes(notes.filter(note => note.note_id !== note_id))
            setPlaceHolders(placeHolders.filter(ph => ph.note_id !== note_id))
        } catch (err) {
            console.log(err)
        }
    }


    async function handleBlur(note) {
        try {
            let res = await getNote(note.note_id)

            if (!res) {
                res = await createNote(note)
            }
            else if (res.note.desc === note.desc) return
            else {
                res = await updateNote(note)
            }


        } catch (err) {
            console.log(err)
        }
    }


    async function handleCheck(note) {
        const checkedNote = { ...note, completed: !note.completed }
        const updatedNotes = notes.map(n => n.note_id === note.note_id ? checkedNote : n)
        setNotes(updatedNotes)
        setPlaceHolders(placeHolders.map(ph => ph.note_id === note.note_id ? checkedNote : ph))

        console.log('Hello from check', note)

        await updateNote(checkedNote)
    }


    return (
        <div className="big-note w-100 md:w-150 h-180 p-1.5">
            <div className="horizontal-container w-full h-full flex bg-amber-200 rounded-lg relative">
                <div className="note-header z-100 rounded-t-2xl bg-amber-200 text-md md:text-2xl font-extralight text-amber-400 border-b-blue-200 border-b-1 w-full h-18 flex flex-col justify-center items-center absolute">
                    <div className="plus-container">
                        <button onClick={addPlaceHolder} className="add-note-btn cursor-pointer overflow-hidden text-ellipsis w-16 whitespace-nowrap  m-2.5 rounded-full text-xl p-1.5 px-3.5 leading-none font-sans font-bold outline-2 bg-amber-400 text-amber-200 hover:bg-amber-300 hover:text-amber-50 hover:outline-amber-400 hover:pr-30 transition-all duration-600 ease-out">
                            +
                            Add note
                        </button>
                    </div>
                </div>
                <div className="left-container z-100 border-r-2 border-r-pink-400 w-16 h-full relative"></div>
                <div className="right-container overflow-y-scroll w-full h-full pt-20 absolute">
                    {placeHolders.map((note, index) => (
                        <div key={index} className="note">
                            <SubNote key={index} note={note} i={index} onDeleteNote={handleDelete} handleChange={handleUpdate} handleBlur={handleBlur} handleCheck={handleCheck} />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}