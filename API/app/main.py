# import random
from fastapi import  FastAPI, UploadFile, File, HTTPException, Request
# from fastapi.responses import FileResponse
from app.ML.api import sertificate_image

app = FastAPI()


@app.get("/")
def read_root():
    return "Сервис по определению типов и элементов документов"


@app.post("/file/upload-bytes")
def upload_file_bytes(file_bytes: bytes = File()):
    return {'file_bytes': str(file_bytes)}



@app.post("/detect")#/upload-file")
async def upload_file(file: UploadFile):
    # if file is None:
    #     return "No file received"
        
    return sertificate_image(file)

@app.exception_handler(HTTPException)
async def bad_request_handler(request: Request, exc: HTTPException):
    
    return "No file received"



@app.post("/uploadfile/")
async def create_upload_file(file: UploadFile):
    return {"filename": file.filename}
