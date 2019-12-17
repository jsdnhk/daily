FROM ubuntu:18.04 as builder

# ENV VARS:
# LANG, LC_ALL: need to set to C.UTF-8 for the var. for text encoder and spelling dictionary
# DEBIAN_FRONTEND: required to set as it can skip querying prompts when installing modules
# TESSERACT_VERSION: the version used of the Google OCR inside the container
# TESSERACT_LANGS: the langs selected to install in the OCR engine(separated with ';')
# TESSERACT_LANGS_USED: the langs selected to run in the OCR engine(separated with '+')
# OCRMYPDF_VERSION: OCRmypdf version selected to use
# OCR_SCRIPT_DIR: the dir. which store the exec. scripts inside the container
# OCR_DIR: the dir. of the input/output doc., need to be shared in volume to the host
# SUFFIX_OUTPUT_FILE: the string value of suffix of the output file
# DAYS_TO_CLEAR_DOCS: clear the input/output files which is created over the days input(integer, >= 1)

ENV LANG='C.UTF-8'
ENV LC_ALL='C.UTF-8'
ENV DEBIAN_FRONTEND='noninteractive'
ENV TESSERACT_VERSION="4.1.0-rc4"
ENV TESSERACT_LANGS="chi_sim;chi_sim_vert;chi_tra;chi_tra_vert;eng;spa;fra;equ;osd"
ENV TESSERACT_LANGS_USED="chi_tra+chi_tra_vert+eng+osd"
ENV OCRMYPDF_VERSION="9.0.1"
ENV OCR_SCRIPT_DIR='/ocr_scripts'
ENV OCR_DIR='/ocr'
ENV SUFFIX_OUTPUT_FILE="_ocr"
ENV DAYS_TO_CLEAR_DOCS=0

# Install the base required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool pkg-config \
    apt-utils \
    libleptonica-dev \
    zlib1g \
    zlib1g-dev \
    ocrmypdf \
    pngquant \
    python3 \
    python3-venv \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    tesseract-ocr \
    tesseract-ocr-eng \
    unpaper \
    wget \
    git \
    ghostscript \
    img2pdf \
    liblept5 \
    libsm6 libxext6 libxrender-dev \
    qpdf

COPY ocr_scripts/ $OCR_SCRIPT_DIR
WORKDIR $OCR_SCRIPT_DIR

# Update the tools version and pass the exec. scripts
RUN ./gen_ocr_pdf_bootstrap.sh
# ENTRYPOINT ["entrypoint_test"]
ENTRYPOINT ["gen_ocr_pdf"]