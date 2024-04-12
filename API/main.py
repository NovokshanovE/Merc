from fastapi import  FastAPI, UploadFile, File
# from fastapi.responses import FileResponse
from ML.api import sertificate_image

app = FastAPI()

@app.get("/")
def read_root():
    return "Сервис по определению типов и элементов документов"

@app.post("/file/upload-bytes")
def upload_file_bytes(file_bytes: bytes = File()):
    return {'file_bytes': str(file_bytes)}


@app.post("/file/upload-file")
def upload_file(file: UploadFile):
    sertificate_image(file)
    
    return file