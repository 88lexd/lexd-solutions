from OpenSSL import SSL  # pip install pyopenssl
from datetime import datetime
import socket
import urllib3
import requests
import logging


# Suppress all SSL certificate warning (ignore expired or self signed)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def _convert_to_date(expire_date, key):
    try:
        expire_date = datetime.strptime(expire_date.decode('utf-8'), "%Y%m%d%H%M%SZ")
        return expire_date
    except Exception as e:
        print(e)


def _get_ssl_cert(url):
    ssl_sock = SSL.Connection(SSL.Context(SSL.TLSv1_2_METHOD), socket.socket())  # using TLSv1.2

    try:
        ssl_sock.set_tlsext_host_name(bytes(url, 'utf-8'))  # This will allow SNI (Server Name Indication) support
        ssl_sock.connect((url, 443))
        ssl_sock.do_handshake()
        return ssl_sock
    except Exception:
        logging.info(f"WARNING: Failed to use TLSv1.2.. using TLSv1 instead")
        ssl_sock = SSL.Connection(SSL.Context(SSL.TLSv1_METHOD), socket.socket())  # using TLSv1
        ssl_sock.set_tlsext_host_name(bytes(url, 'utf-8'))  # This will allow SNI (Server Name Indication) support
        ssl_sock.connect((url, 443))
        ssl_sock.do_handshake()
        return ssl_sock
    finally:
        ssl_sock.shutdown()
        ssl_sock.close()


def _check_response_code(url):
    # If the site returns a valid certificate, return True and valid
    try:
        response = requests.head(f'https://{url}', verify=True, timeout=3)
        code = response.status_code
        return {'status': True, 'code': code, 'cert_valid': True}
    # If the site returns an invalid certificate, return True and invalid
    except requests.ConnectionError as e:
        try:
            response = requests.head(f'https://{url}', verify=False, timeout=3)
            code = response.status_code
            logging.info(f"WARNING: Invalid certificate!")
            return {'status': True, 'code': code, 'cert_valid': False}
        # Exception for checking INVALID certs
        except Exception as e:
            logging.info(f"WARNING: Failed to check response code")
            return {'status': False}
    # Exception for checking VALID certs
    except Exception as e:
        logging.info(f"WARNING: Failed to check response code")
        return {'status': False}


def get_certificate(url):
    result = _check_response_code(url)
    if result['status']:
        try:
            ssl_sock = _get_ssl_cert(url)
            cert_info = dict()

            cert_info['secure_url'] = f"https://{url}"
            cert_info['http_status_code'] = result['code']
            cert_info['cert_valid'] = result['cert_valid']

            # =========== Begin Intermediate CA info ===========
            cert = ssl_sock.get_peer_certificate()

            # Certificate dates info
            cert_info['not_before_date'] = _convert_to_date(cert.get_notBefore(), "not_before")
            cert_info['not_after_date'] = _convert_to_date(cert.get_notAfter(), "not_after")

            # Issuer information
            issuer = cert.get_issuer()
            cert_info['issuer_country_name'] = str(issuer.countryName)
            cert_info['issuer_org_name'] = str(issuer.organizationName)
            cert_info['issuer_common_name'] = str(issuer.commonName)

            # Certificate issued to
            cert_info['issued_to'] = str(cert.get_subject().commonName)
            # =========== End Intermediate CA info ===========

            # =========== Begin Root CA info ===========
            cert_chain = ssl_sock.get_peer_cert_chain()

            if len(cert_chain) > 1:
                cert_root = ssl_sock.get_peer_cert_chain()[-1]  # This is the root CA cert

                # Root certificate dates info
                cert_info['root_not_before_date'] = _convert_to_date(cert_root.get_notBefore(), "not_before")
                cert_info['root_not_after_date'] = _convert_to_date(cert_root.get_notAfter(), "not_after")

                # Root issuer information
                root_issuer = cert_root.get_issuer()
                cert_info['root_issuer_country_name'] = str(root_issuer.countryName)
                cert_info['root_issuer_org_name'] = str(root_issuer.organizationName)
                cert_info['root_issuer_common_name'] = str(root_issuer.commonName)

                # Root certificate issued to
                cert_info['root_issued_to'] = str(cert_root.get_subject().commonName)
            else:
                cert_info['root_not_before_date'] = "null"
                cert_info['root_not_after_date'] = "null"
                cert_info['root_issuer_country_name'] = "null"
                cert_info['root_issuer_org_name'] = "null"
                cert_info['root_issuer_common_name'] = "null"
                cert_info['root_issued_to'] = "null"
            # =========== Begin Root CA info ===========

            return cert_info
        except Exception as e:
            print(e)
            print ("ERROR: cannot get SSL certificate for [ %s ]" % url)
