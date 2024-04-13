from random import randint, random


def sertificate_image(image):
    
    
    test = [{"type": "personal_passport",
            "confidence": 0.99,
            "series": "1234",
            "number": "123456",
            "page_number": 1 },
            {"type": "vehicle_certificate",
            "confidence": 0.67,
            "series": "3622",
            "number": "877201",
            "page_number": 1 },
            {"type": "vehicle_passport",
            "confidence": 0.92,
            "series": "3434",
            "number": "767826",
            "page_number": 2 }]
    return test[randint(0,2)]