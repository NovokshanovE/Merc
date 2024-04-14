import os

from fastapi import FastAPI, UploadFile, HTTPException, Request
import numpy as np
from ML.detection_module import run_pipeline
import cv2

app = FastAPI()


@app.get("/")
def read_root():
    return "Сервис по определению типов и атрибутов документов"

def concatenate_to_string(arr):
    concatenated_string = ', '.join(np.array(arr, dtype=str))
    return concatenated_string
@app.post("/detect")
async def upload_file(file: UploadFile):
    try:
        contents = file.file.read()
        with open(file.filename, 'wb') as f:
            f.write(contents)
        img = cv2.imread(file.filename)
        os.remove(file.filename)
        res = run_pipeline(img)
        res["series_numbers"]["number"] = concatenate_to_string(res["series_numbers"]["number"])
        res["series_numbers"]["series"] = concatenate_to_string(res["series_numbers"]["series"])
        print(res)
        return res
    except Exception as e:
        print(e)
        return {"message": "There was an error uploading the file"}
    finally:
        file.file.close()


@app.exception_handler(HTTPException)
async def bad_request_handler(request: Request, exc: HTTPException):
    return "No file received"
