from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
 return "Сервис по определению типов и элементов документов"

@app.get("/image")
def upload_image():
 return "Здесь происходит загрузка изображений"