import sys
import os
import datetime


print(f"Wayway-py!! {sys.argv}")

time = datetime.datetime.now()
print(f"::set-output name=time::{time}")
