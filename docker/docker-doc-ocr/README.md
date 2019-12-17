# Docker Document OCR Image (VeriGuide@CUHK)

------

## About

Document Optical Character Recognition(**OCR**) Application Docker image based on Ubuntu Linux 18.04.

Mainly implemented by the OCR tool [Google Tesseract](https://github.com/tesseract-ocr/tesseract), with Python module [OCRmyPDF](https://github.com/jbarlow83/OCRmyPDF).

since Aug 2019

## Procedure

```sequence
Title: Document OCR
User->Image Processing: documents to read
Image Processing->Tesseract OCR: fine-tuned documents
Tesseract OCR->Destination: recognized documents
Destination-->>User: output results
```

## Docker

### Environment variables

* `LANG`: Language encoding setting for text encoder and spelling dictionary (default `C.UTF-8`)
* `LC_ALL`: Default language encoding used (default `C.UTF-8`)
* `DEBIAN_FRONTEND`: The frontend type of the terminal (default `noninteractive`)
* `TESSERACT_VERSION`: The version used of the Google OCR inside the container (default `4.1.0-rc4`)
* `TESSERACT_LANGS`: The langs selected to install in the OCR engine(separated with `;`) (default `english,chinese(tra,sim),france`)
* `TESSERACT_LANGS_USED`: The langs selected to run in the OCR engine(separated with `+`) (default `chi_tra+eng`)
* `OCRMYPDF_VERSION`: The OCRmypdf version selected to use (default `9.0.1`)
* `OCR_SCRIPT_DIR`: The directory which stores the exec. scripts inside the container (default `/ocr_scripts`)
* `OCR_DIR`: The directory for the input/output doc. inside the container, shared to a folder in the host (default `/ocr`)
* `SUFFIX_OUTPUT_FILE`: The string value of suffix of the output file (default `_ocr`)
* `DAYS_TO_CLEAR_DOCS`: The threshold days to housekeep the documents to clear (default `0`)

> **P.S.:** For the trained languages data from Tesseract, please lookup this GitHub repo:
> [Best (most accurate) trained LSTM models](https://github.com/tesseract-ocr/tessdata_best) from [Google@Github](https://github.com/google)

### Volumes

* `$OCR_DIR`: `/ocr` as default, should follow the rules below:
> * Have to bind $OCR_DIR to the host's folder while running the docker image
> * Have to put the documents needed to undergo OCR inside `./input/` folder
> * Have to fetch the documents output results inside `./output/` folder
> * For input doc. file types, allow to input the common imaged doc. types(pdf, doc, docx, odt, tiff...)
> * For output doc. files, enable to fetch a searchable PDF with recognized text layer with text file for each handling

## Use this image

### Command line

```bash
# build up the docker image
cd $THIS_PROJECT_DIR
sudo docker build --tag $IMAGE_NAME .

# verify the existing image in the localhost
sudo docker images

# run the docker image in container, the container will then be removed
docker run --rm -iv $VOLUME_FOLDER_HOST:$OCR_DIR $IMAGE_NAME $INPUT_DOC_INSIDE_OCR_DIR
# for example, `docker run --rm -iv /ocr:/ocr ocr /ocr/input/20190802_stat_prep.odt`
```

### Tips

```bash
# for convenience, can create a shell alias to hide the Docker command
alias $OCR_CMD_ALIAS="docker run --rm -iv $VOLUME_FOLDER_HOST:$OCR_DIR $IMAGE_NAME"
```
