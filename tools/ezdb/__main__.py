import argparse
from .steps import STEPS

parser = argparse.ArgumentParser()
parser.add_argument("--port", type = int, default = 3306)

args = parser.parse_args()

for step in STEPS:
    if not step.should_run():
        continue

    step.run(args)

print("Done!")
