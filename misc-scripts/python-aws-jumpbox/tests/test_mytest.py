import pytest
import sys
import os

pytestmark = pytest.mark.start


# method must start with _test (same as the filename)
@pytest.fixture()
def start_instance(ec2_module):
    yield ec2_module.start_instance()
    ec2_module.stop_instance()


def test_start_ec2(ec2_test_session):
    pass
