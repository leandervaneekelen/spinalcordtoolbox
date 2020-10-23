#!/usr/bin/env python

# explicitely expose __version__ and friends in top-level package
from .utils import __version__, __sct_dir__, __data_dir__, __deepseg_dir__

from . import aggregate_slicewise
from . import cropping
from . import download
from . import image
from . import labels
from . import math
from . import metadata
from . import flattening
from . import process_seg
from . import resampling
from . import straighteningq
from . import template
from . import types

# FIXME
# from . import moco
