import json


def sertificate_image(image):
    print(f"Определяем тип документа:\n{image}")
    return json.dumps({
        'doctype': 'test',
        'page': 0,
        'series': 4000,
        'number': 2000
    })
