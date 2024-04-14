import os

from fastapi import FastAPI, UploadFile, HTTPException, Request
from API.app.ML.api import sertificate_image
import cv2

app = FastAPI()


@app.get("/")
def read_root():
    return "Сервис по определению типов и атрибутов документов"


@app.post("/detect")
async def upload_file(file: UploadFile):
    try:
        contents = file.file.read()
        with open(file.filename, 'wb') as f:
            f.write(contents)
        img = cv2.imread(file.filename)
        os.remove(file.filename)
        return sertificate_image(img)
    except Exception as e:
        print(e)
        return {"message": "There was an error uploading the file"}
    finally:
        file.file.close()


@app.exception_handler(HTTPException)
async def bad_request_handler(request: Request, exc: HTTPException):
    return "No file received"
