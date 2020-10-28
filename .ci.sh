#!/bin/bash
# CI testing script
#  Installs SCT from scratch and runs all the tests we've ever written for it.

set -e # Error build immediately if install script exits with non-zero

travis_fold start "install.sct"
	travis_time_start
    yes | ASK_REPORT_QUESTION=false PIP_PROGRESS_BAR=off ./install_sct
    echo $?
    echo "... STATUS"
	travis_time_finish
travis_fold end "install.sct"

travis_fold start "check.path"
	travis_time_start
    echo *** CHECK PATH ***
    ls -lA bin  # Make sure all binaries and aliases are there
    source python/etc/profile.d/conda.sh  # to be able to call conda
    conda activate venv_sct  # reactivate conda for the pip install below
	travis_time_finish
travis_fold end "check.path"

travis_fold start "testing.unittests"
	travis_time_start
    echo *** UNIT TESTS ***
    pip install coverage
    echo -ne "import coverage\ncov = coverage.process_startup()\n" > sitecustomize.py
    echo -ne "[run]\nconcurrency = multiprocessing\nparallel = True\n" > .coveragerc
    COVERAGE_PROCESS_START="$PWD/.coveragerc" COVERAGE_FILE="$PWD/.coverage" \
      pytest
    coverage combine
	travis_time_finish
travis_fold end "testing.unittests"

# TODO: move this part to a separate travis job; there's no need for each platform to lint the code
travis_fold start "testing.linting"
	travis_time_start
    echo *** ANALYZE CODE ***
    pip install pylint
    bash -c 'PYTHONPATH="$PWD/scripts:$PWD" pylint -j3 --py3k --output-format=parseable --errors-only $(git ls-tree --name-only -r HEAD | sort | grep -E "(spinalcordtoolbox|scripts|testing).*\.py" | xargs); exit $(((($?&3))!=0))'
	travis_time_finish
travis_fold end "testing.linting"
#
# echo *** BUILD DOCUMENTATION ***
# pip install sphinx sphinxcontrib.programoutput sphinx_rtd_theme
# cd documentation/sphinx
# make html
# cd -

# python create_package.py -s ${TRAVIS_OS_NAME}  # test package creation
# cd ../spinalcordtoolbox_v*
# yes | ./install_sct  # test installation of package

