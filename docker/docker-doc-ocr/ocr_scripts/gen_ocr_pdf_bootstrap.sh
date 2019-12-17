#!/usr/bin/env bash
# Require to exec. with sudo right

# Tesseract(from Github) : Google OCR Engine (to target version[>=4, using LSTM OCR])
readonly TESSERACT_VER="${TESSERACT_VERSION}"
readonly TESSERACT_TRAINED_LANGS="${TESSERACT_LANGS}"
readonly TESSERACT_NAME="tesseract"
readonly TESSDATA_PREFIX="/usr/local/share/tessdata"
readonly OCRMYPDF_VER="${OCRMYPDF_VERSION}"
SCRIPT_PATH="$(dirname $(realpath ${0}))"


cd /tmp
git clone https://github.com/tesseract-ocr/tesseract.git --branch $TESSERACT_VER --single-branch $TESSERACT_NAME
cd $TESSERACT_NAME
git checkout -b $TESSERACT_VER
./autogen.sh
./configure
make
make install
ldconfig
mkdir ${TESSDATA_PREFIX} &> /dev/null
cd ${TESSDATA_PREFIX}
TESSERACT_TRAINED_LANG_ARY=($(echo $TESSERACT_TRAINED_LANGS | tr ";" "\n"))
rm -rf "*.traineddata"
for LANG in "${TESSERACT_TRAINED_LANG_ARY[@]}"; do
    wget -q "https://github.com/tesseract-ocr/tessdata_best/raw/master/${LANG}.traineddata" ./
done

# OCRmypdf: Converting scanned PDF files to searched PDF files (to target version, use latest is recommended)
apt-get -y update
apt-get -y install \
    ocrmypdf \
    libxml2 \
    pngquant
pip3 install --upgrade ocrmypdf=="${OCRMYPDF_VER}"
cd /tmp
git clone https://github.com/agl/jbig2enc
cd jbig2enc
./autogen.sh
./configure && make
make install

rm -rf /tmp/*

# Tools to use
# LibreOffice writer : For exporting pdf files
add-apt-repository ppa:libreoffice/ppa
apt-get update
apt install -y libreoffice-base \
    libreoffice-writer
cd $SCRIPT_PATH

for SRC in `ls *.sh`; do
    chmod a+x ${SRC}
    fullname=$(realpath ${SRC})
    filename=$(basename ${SRC%.*})
    ln -s "$fullname" "/usr/local/bin/$filename"
done

echo "The prerequisites of using document OCR are installed successfully!"