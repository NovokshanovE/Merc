from fastapi import FastAPI, UploadFile, HTTPException, Request
from API.app.ML.api import sertificate_image

app = FastAPI()


@app.get("/")
def read_root():
    return "Сервис по определению типов и атрибутов документов"


@app.post("/detect")
async def upload_file(file: UploadFile):
    return sertificate_image(file)


@app.exception_handler(HTTPException)
async def bad_request_handler(request: Request, exc: HTTPException):
    return "No file received"
