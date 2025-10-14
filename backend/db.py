# This file is filled with CRUD operations over a MongoDB collection by the name of "notes".
import os
from pymongo import MongoClient
from pymongo.errors import PyMongoError
from dotenv import load_dotenv

load_dotenv()

# Get MongoDB URL from environment variable
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = "notes_db"
COLLECTION_NAME = "notes"

# Initialize MongoDB client
client = MongoClient(MONGODB_URL)
db = client[DATABASE_NAME]
notes_collection = db[COLLECTION_NAME]

# Read (all) operation:
def get_notes():
    try:
        notes = list(notes_collection.find({}))
        # Convert ObjectId to string for JSON serialization
        for note in notes:
            note['_id'] = str(note['_id'])
        return notes
    except PyMongoError as err:
        print('There was an issue getting notes, try again later', err)
        raise Exception('There was an issue getting notes, try again later')

# Read (single) operation:
def get_note(note_id):
    try:
        note = notes_collection.find_one({"note_id": note_id})
        
        if note:
            note['_id'] = str(note['_id'])
            return note
        else:
            raise Exception(f'No note with ID of "{note_id}" found.')
    except PyMongoError as err:
        print(f'There was an issue getting note with the ID of: {note_id}, please try again later.', err)
        raise Exception(f'There was an issue getting note with the ID of: {note_id}, please try again later.')

# Create (single) operation:
def create_note(note_id, desc, completed=False):
    try:
        note_document = {
            'note_id': note_id,
            'desc': desc,
            'completed': completed
        }
        result = notes_collection.insert_one(note_document)
        return {"inserted_id": str(result.inserted_id)}
    except PyMongoError as err:
        print('There was an issue creating a note, please try again later.', err)
        raise Exception('There was an issue creating a note, please try again later.')

# Delete (single) operation:
def delete_note(note_id):
    try:
        note = get_note(note_id)
        if note:
            result = notes_collection.delete_one({"note_id": note_id})
            return {"deleted_count": result.deleted_count}
    except PyMongoError as err:
        print(f'There was an issue with deleting the note with the ID of: "{note_id}", please try again later.', err)
        raise Exception(f'There was an issue with deleting the note with the ID of: "{note_id}", please try again later.')

# Update (single) operation:
def update_note(note_id, desc, completed):
    try:
        note = get_note(note_id)
        if note:
            result = notes_collection.update_one(
                {"note_id": note_id},
                {"$set": {
                    "desc": desc,
                    "completed": completed
                }}
            )
            return {"modified_count": result.modified_count}
    except PyMongoError as err:
        print(f'There was an issue with updating the note with the ID of: "{note_id}", please try again later.', err)
        raise Exception(f'There was an issue with updating the note with the ID of: "{note_id}", please try again later.')