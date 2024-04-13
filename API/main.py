import random
from fastapi import  FastAPI, UploadFile, File
# from fastapi.responses import FileResponse
from API.ML.api import sertificate_image

app = FastAPI()


@app.get("/")
def read_root():
    return "Сервис по определению типов и элементов документов"


@app.post("/file/upload-bytes")
def upload_file_bytes(file_bytes: bytes = File()):
    return {'file_bytes': str(file_bytes)}



@app.post("/detect")#/upload-file")
async def upload_file(file: UploadFile):
    
    return sertificate_image(file)


@app.post("/uploadfile/")
async def create_upload_file(file: UploadFile):
    return {"filename": file.filename}
