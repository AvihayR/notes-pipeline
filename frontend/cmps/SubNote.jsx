export default function SubNote({ note, i, onDeleteNote, handleChange, handleBlur, handleCheck }) {

    return (
        <div className="group sub-note-container relative flex justify-center items-center h-19 text-2xl font-light pl-18 text-blue-900 border-b-blue-200 border-b-1">
            <input type="checkbox" title={note.completed ? 'Mark not completed' : 'Mark completed'} name={i} onChange={() => handleCheck(note)} checked={note.completed} className=" absolute cursor-pointer left-5 z-1000 w-5 h-5 rounded-2xl mb-2.5 accent-amber-400" />
            <textarea placeholder="Your note here.." className={`w-full h-2/3 resize-none focus:outline-0 border-0 decoration-amber-400 ${note.completed && 'line-through'}`} value={note.desc} onChange={(ev) => handleChange(ev, note, i)} onBlur={() => handleBlur(note)} />
            <button title="Delete note" onClick={() => { onDeleteNote(note.note_id) }} className="p-1.5 cursor-pointer opacity-0 transition duration-300 ease-in-out group-hover:opacity-100">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" className="w-5 h-5 m-2 fill-current text-rose-700">
                    <path d="M135.2 17.7L128 32 32 32C14.3 32 0 46.3 0 64S14.3 96 32 96l384 0c17.7 0 32-14.3 32-32s-14.3-32-32-32l-96 0-7.2-14.3C307.4 6.8 296.3 0 284.2 0L163.8 0c-12.1 0-23.2 6.8-28.6 17.7zM416 128L32 128 53.2 467c1.6 25.3 22.6 45 47.9 45l245.8 0c25.3 0 46.3-19.7 47.9-45L416 128z" />
                </svg>
            </button>
        </div>
    )
}