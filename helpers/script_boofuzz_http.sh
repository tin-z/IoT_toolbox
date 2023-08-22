#!/bin/bash




python3 -m pip install virtualenv
mkdir boofuzz_virtualenv
python3 -m venv boofuzz_virtualenv

cd boofuzz_virtualenv && \
git clone https://github.com/tin-z/boofuzz && \
git clone https://github.com/tin-z/boofuzz-http && \
source bin/activate && \
cd boofuzz && \
python setup.py install


echo "# Done!"
echo ""
echo "Now run boofuzz-http script"


