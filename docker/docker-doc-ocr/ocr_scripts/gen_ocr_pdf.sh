#!/usr/bin/env bash

# To generate OCR PDF from the scanned doc.(readable docs. for LibreOffice)
# Command: ./gen_ocr_pdf.sh fullname_input_doc_file
# Required tools: 'tesseract', 'ocrmypdf'

# Housekeeping first before use
sh ./gen_ocr_pdf_housekeep.sh

# 1) Positional arguments
readonly PDF_EXTENSION="pdf"
readonly SUFFIX_GEN_FILE="${SUFFIX_OUTPUT_FILE}"
readonly OCR_DIR_PATH="${OCR_DIR}"
readonly INPUT_DIR_PATH="${OCR_DIR}/input"
readonly OUTPUT_DIR_PATH="${OCR_DIR}/output"
readonly LANGS_USED="${TESSERACT_LANGS_USED}"

start=`date +%s`
input_path="${INPUT_DIR_PATH}"
output_path="${OUTPUT_DIR_PATH}"
input_pdf_or_image=''
output_pdf=''
extension=''
bsname=''
filename=''

mkdir -p ${input_path} &> /dev/null
cd $input_path
if [ "$#" -ne 1 ]; then
    echo "Error: there are not correct input arg. no.[$#], require one(input doc. file with extension in input_path)." 1>&2
    exit 1
elif [ ! -f $1 ]; then
    echo "Error: the input filename[$1] is not existed" 1>&2
    exit 1
else
    mkdir -p ${output_path} &> /dev/null
    bsname=$(basename ${1})
    input_pdf_or_image=$(realpath ${1})
    extension="${bsname##*.}"
    filename="${bsname%.*}"
    output_pdf="${output_path}/${filename}${SUFFIX_GEN_FILE}.${PDF_EXTENSION}"
    echo "Executing the OCR on the input file: [${filename}] ... "
fi

# (Optional) convert to pdf file if the input file is not PDF format
if [ $extension != $PDF_EXTENSION ]; then
    echo "Converting the input file[${filename}] to PDF format ... "
    cd $input_path
    lowriter --convert-to pdf $input_pdf_or_image
    input_path=$(dirname $(realpath ${input_pdf_or_image}))
    input_pdf_or_image="${input_path}/${filename}.${PDF_EXTENSION}"
fi

# 2) Optional arguments
opt_args=''
opt_args="$opt_args --language ${LANGS_USED}"
# --image-dpi DPI : only be used in image case
# --output-type {pdfa,pdf,pdfa-1,pdfa-2} : 'pdfa', as default
opt_args="$opt_args --sidecar"

# 3) Job control options
jc_args=''
# --jobs N : use up to N CPU cores simultaneously, default use all CPU
# --quiet : may use in prod.
# --verbose : may use in debug

# 4) Metadata options
md_args=''
# --title TITLE
# --author AUTHOR
# --subject SUBJECT
# --keywords KEYWORDS

# 5) Image preprocessing options
ip_args=''
ip_args="$ip_args --rotate-pages"
# --remove-background": Clean the background (may not worked when scanning colored docs.)
ip_args="$ip_args --deskew"
ip_args="$ip_args --clean"
# --oversample DPI ： Oversample images to at least the specified DPI (may reduce the result of recognition)
# --clean-final : Clean pages from scanning artifacts before performing OCR(by unpaper) and output as final pdf, may cause data loss

# 6) OCR Options(Important for text+images mixed pages)
ocr_args=''
ocr_args="$ocr_args --force-ocr"
# --skip-text : Skip OCR on any pages that already contain text
# --skip-big MPixels : Skip OCR on pages larger than the specified amount of megapixels

# 7) Tesseract options
tsa_args=''
# --max-image-mpixels MPixels : Set maximum number of pixels to unpack
# --tesseract-config CFG : Additional Tesseract configuration files -- see documentation
# --tesseract-pagesegmode PSM : Set Tesseract page segmentation mode (see tesseract --help)
# --tesseract-oem MODE : Set Tesseract 4.0 OCR engine mode
# --pdf-renderer {auto,tesseract,hocr,sandwich} : Choose OCR PDF renderer
# --tesseract-timeout SECONDS : Give up on OCR after the timeout
# --rotate-pages-threshold CONFIDENCE : Only rotate pages when confidence is above this value
# --pdfa-image-compression {auto,jpeg,lossless} : Specify  how  to compress images in the output PDF/A
# --user-words FILE : Specify the location of the Tesseract user words file
# --user-patterns FILE : Specify the location of the Tesseract user patterns file.
# --skip-repair : Tell OCRmyPDF to skip repair with this option

# echo "ocrmypdf $opt_args $jc_args $md_args $ip_args $ocr_args $tsa_args $input_pdf_or_image $output_pdf"
cd $input_path
ocrmypdf $opt_args $jc_args $md_args $ip_args $ocr_args $tsa_args $input_pdf_or_image $output_pdf
end=`date +%s`
echo "The OCR output pdf file is generated successfully to [${output_pdf}]!"
echo "It takes $((end-start)) second(s) to generate."
exit 0