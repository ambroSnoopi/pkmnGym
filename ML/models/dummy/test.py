from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("-tc", "--turnCount", type=int)
parser.add_argument("-sm", "--smth", type=str)
args = vars(parser.parse_args())

print(args)