#!/usr/bin/env python3
import argparse
import logging
import sys
import boto3


def main():
    parser = get_parser()
    global opts
    opts = parser.parse_args()

    set_logging(log_level=opts.logging)

    if opts.quiet:
        logging.disable()

    if opts.file is None:
        logging.critical("Missing file option")
        # parser.print_help()
        exit(1)
    elif opts.export_csv is None:
        logging.critical("Missing filename for export CSV!")
        # parser.print_help()
        exit(1)
    else:
        # START DOING COOL STUFF
        continue


def get_parser():
    def _make_wide(formatter, w=120, h=100):
        try:
            kwargs = {'width': w, 'max_help_position': h}
            formatter(None, **kwargs)
            return lambda prog: formatter(prog, **kwargs)
        except TypeError:
            logging.warning("argparse help formatter failed, falling back.")
            return formatter

    description = "Description: Script to update a single AWS security group"
    parser = argparse.ArgumentParser(description=description,
                                     formatter_class=_make_wide(argparse.ArgumentDefaultsHelpFormatter))
    # Logging options
    logging_choices = ['critical', 'error', 'warning', 'info','debug']
    group = parser.add_mutually_exclusive_group()  # only allows one or the other to be configured
    group.add_argument("--logging", choices=logging_choices, default='info' ,help="Sets logging level")
    group.add_argument("-q", "--quiet", action="store_true", help="Disables logging (overwrites logging setting)")

    # Options for script
    parser.add_argument("-f", "--file", required=True, help="Path to file")
    parser.add_argument("-e", "--export-csv", help="Name of the exported csv file (eg. blah.csv)")

    return parser


def set_logging(log_level):
    logging.basicConfig(format='%(asctime)s %(levelname)s %(filename)s[%(lineno)d]: %(message)s',
                        datefmt='%d/%m/%Y %I:%M:%S %p',
                        stream=sys.stdout,
                        level=getattr(logging, log_level.upper()))
    logging.getLogger('requests').setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.WARNING)


if __name__ == "__main__":
    main()
