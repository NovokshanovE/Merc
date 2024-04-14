from functools import cache
from ultralytics import YOLO
import cv2
from ML.myutils import crop_image, get_grayscale, thresholding, result_postprocess
import pytesseract
import sys

pytesseract.pytesseract.tesseract_cmd = 'tesseract' # TESSERACT DIR

def cv_pipeline(image, doc_type_detect_model, series_number_detect_model):
    result_to_server={'confidence': None, 'doc_type': None}
    doc_type_pred = doc_type_detect_model.predict(source=image)

    try:
        confidence = doc_type_pred[0].boxes.conf[0].cpu().item()
        doc_type = doc_type_pred[0].names[int(doc_type_pred[0].boxes.cls[0].cpu().item())]

        result_to_server['confidence'] = confidence
        result_to_server['doc_type'] = doc_type

        xyxy_coordinates = doc_type_pred[0].boxes.xyxy[0].cpu().numpy().astype(int) 
        x1, y1, x2, y2 = xyxy_coordinates  

        cropped_image = crop_image(image, x1, y1, x2, y2)

        series_numbers_pred = series_number_detect_model.predict(source=cropped_image)

        xyxy_coordinates = series_numbers_pred[0].boxes.xyxy.cpu().numpy().astype(int) 

        try:
            labels = [series_numbers_pred[0].names[item] for item in series_numbers_pred[0].boxes.cls.cpu().numpy()]
            print("icewc")

            i = 0

            ocr_dict = {'number': [], 'series': []}

            for item in xyxy_coordinates:
                x1, y1, x2, y2 = item
                cropped_image_tes = crop_image(cropped_image, x1, y1, x2, y2)
                print("_____1")
                gray = get_grayscale(cropped_image_tes)
                thresh = thresholding(gray)
                print("_____2")
                ocr_result = pytesseract.image_to_string(cropped_image_tes, lang='rus', config='--psm 13 --oem 3')
                print(ocr_result)
                print("_____3")
                final_res = result_postprocess(ocr_result)
                print("_____4")
                if labels[i] == 'number':
                    ocr_dict['number'].append(final_res)
                if labels[i] == 'series':
                    ocr_dict['series'].append(final_res)

                i += 1
            print("icewc")
            result_to_server['series_numbers'] = ocr_dict

        except Exception as e: print(e)
    except:
        return "Error"
    
    return result_to_server

def run_pipeline(image_cv2):
    try:

        if image_cv2 is not None:

            doc_type_detect_model = YOLO("./ML/models/doc_detect.pt")
            series_number_detect_model = YOLO("./ML/models/series_nums_detect.pt")

            result = cv_pipeline(image_cv2, doc_type_detect_model, series_number_detect_model)

            if result != "Error":
                print("Processed result:", result)
            else:
                print("An error occurred during image processing.")
            return result
        else:
            print("Failed to load image from path:", image_cv2)
    except Exception as e:
        print("An error occurred:", e)


# image = cv2.imread("./documents/train/images/image_380.png")

# print(run_pipeline(image))