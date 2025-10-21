import uuid
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import db
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

def create_id():
    id = uuid.uuid4()
    return str(id)

class Note(BaseModel):
    note_id: str | None = None
    desc: str
    completed: bool = False

# Use env vars for CORS origins
load_dotenv()
allowed_origins = os.getenv("ALLOWED_ORIGINS")

if allowed_origins:
    origins = [origin.strip() for origin in allowed_origins.split(",")]
else:
    origins = [
        "http://localhost:8080",
        "http://127.0.0.1:8080",
    ]

app = FastAPI()

# Allow CORS for allowed Origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"status": "ok"}

# GET - Read all notes
@app.get("/notes")
@app.get("/notes/")
async def root():
    try:
        notes = db.get_notes()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to get notes at this time. Error: {e}')
    return {"message": f"Notes has been successfully fetched.", "notes": notes}

# GET - Read a single note 
@app.get("/notes/{note_id}")
async def get_note(note_id):
    try:
        note = db.get_note(note_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to get note with the ID of: {note_id} at this time. Error: {e}')
    
    return {"message": f"Note with ID {note_id} has been successfully fetched.", "note": note}

# POST - Create a new note
@app.post("/notes/")
async def create_note(note: Note):
    new_note = Note(note_id=create_id(), desc=note.desc, completed=note.completed)
    try:
        db.create_note(**new_note.__dict__)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Failed to create note with the ID of: {new_note.note_id} at this time. Error: {e}')
    return {"message": f"Note with ID {new_note.note_id} has been successfully created.", "note": new_note}

# PUT - Update an existing note
@app.put("/notes/{note_id}")
async def update_note(note_id: str, note: Note):
    note = Note(note_id=note_id, desc=note.desc, completed=note.completed)
    try:
        updated_note = db.update_note(**note.__dict__)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update note with ID {note_id}. Error: {e}")
        
    return {"message": f"Note with ID {note_id} has been successfully updated.", "note_id": note_id}

# DELETE - Delete an existing note
@app.delete("/notes/{note_id}")
async def delete_note(note_id: str):
    try:
        db.delete_note(note_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete note with ID {note_id}. Error: {e}")
    
    return {"message": f"Note with ID {note_id} has been successfully deleted."}