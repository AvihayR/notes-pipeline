import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";


export const getNotes = async () => {
    try {
        const response = await axios.get(`${API_URL}/notes`)
        console.log(response.data)
        return response.data
    } catch (error) {
        console.error("There was an error fetching notes:", error)
        throw error
    }
}

export const getNote = async (note_id) => {
    try {
        const response = await axios.get(`${API_URL}/notes/${note_id}`)
        console.log(response.data)
        return response.data
    } catch (error) {
        console.log("There was an error fetching the note:", error)
    }
}


export const createNote = async (note) => {
    const { note_id, desc } = note

    try {
        const response = await axios.post(`${API_URL}/notes/`, {
            desc: desc
        })
        console.log(response.data)
        return response.data
    } catch (error) {
        console.error("There was an error creating the note:", error)
        throw error
    }
}


export const updateNote = async (note) => {
    const { note_id, desc, completed } = note

    try {
        const response = await axios.put(`${API_URL}/notes/${note_id}`, {
            note_id: note_id,
            desc: desc,
            completed: completed
        })
        console.log(response.data)
        return response.data
    } catch (error) {
        console.error("There was an error updating the note:", error)
        throw error
    }
}

export const deleteNote = async (note_id) => {
    try {
        const response = await axios.delete(`${API_URL}/notes/${note_id}`)
        console.log(response.data)
        return response.data
    } catch (error) {
        console.error("There was an error deleting the note:", error)
        throw error
    }
}
