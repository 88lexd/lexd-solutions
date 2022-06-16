#!/usr/bin/env python3
from netaddr import IPNetwork, cidr_merge
import ipaddress
import argparse
import os


def main():
    print("================================")
    print("Supernetting Script by Alex Dinh")
    print("================================")
    parser = get_parser()
    global opts
    opts = parser.parse_args()

    subnets_file = get_full_path_to(opts.file)
    print(f"Reading from - {subnets_file}")

    with open(subnets_file, 'r') as _file:
        lines = _file.readlines()
        subnets_from_file = [line.rstrip() for line in lines]
        subnets_from_file.sort()

    sorted_subnets = sort(subnets_from_file)
    grouped_subnets = group_by_contiguous(sorted_subnets)

    print("Begin supernetting...\n")
    result = list()
    for subnets in grouped_subnets:
        supernets = get_supernet(subnets)
        result.extend(supernets)

        for subnet in subnets:
            if str(subnet) in supernets:
                print(f"{str(subnet)} cannot be supernetted")
            else:
                print(f"{str(subnet)} is supernetted")

    print("\n========================")
    print("New Supernetted Subnets:")
    print("========================")
    for subnet in result:
        print(subnet)


def get_full_path_to(input_path):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_name = input_path.split('/')[-1]

    # First check if is next to the script file
    if os.path.exists(f'{script_dir}/{file_name}'):
        return f'{script_dir}/{file_name}'
    # Check the actual input path
    elif (os.path.exists(input_path)):
        return input_path
    else:
        raise FileNotFoundError


def get_supernet(cidrs):
    # Expects a list of IPNetwork objects
    result = [str(cidr) for cidr in cidr_merge(cidrs)]
    return result


def sort(subnets):
    sorted = list()
    for subnet in subnets:
        sorted.append(ipaddress.ip_network(subnet))
    sorted.sort()
    return sorted


def group_by_contiguous(subnets):
    # Convert IPv4Network object to IPNetwork object
    ipnetwork_subnets = [IPNetwork(str(subnet)) for subnet in subnets]

    grouped_list = list()
    contiguous_list = list()

    for index, subnet in enumerate(ipnetwork_subnets):
        # If is first index then assume is contiguous
        if index == 0:
            contiguous_list.append(subnet)
            continue  # move onto the next item in the list

        if str(contiguous_list[-1].next().ip) == str(subnet.ip):
            contiguous_list.append(subnet)
        else:
            grouped_list.append(contiguous_list)
            contiguous_list = list()
            contiguous_list.append(subnet)

        # On last index move everything into group_list
        if (index + 1) == len(ipnetwork_subnets):
            grouped_list.append(contiguous_list)

    return grouped_list


def get_parser():
    def _make_wide(formatter, w=120, h=100):
        try:
            kwargs = {'width': w, 'max_help_position': h}
            formatter(None, **kwargs)
            return lambda prog: formatter(prog, **kwargs)
        except TypeError:
            print("argparse help formatter failed, falling back.")
            return formatter

    description = "Script to supernet by taking in a file container a list of subnets"
    parser = argparse.ArgumentParser(description=description,
                                     formatter_class=_make_wide(argparse.ArgumentDefaultsHelpFormatter))

    # Options for script
    parser.add_argument("--file", required=True, help="A file containing subnets to supernet")
    return parser


if __name__ == "__main__":
    main()
