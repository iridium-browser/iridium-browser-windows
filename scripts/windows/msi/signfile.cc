/**
 * Simple tool to (code-)sign a file using private key / certificate.
 * Copyright (c) 2015 struktur AG
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <stdio.h>
#include <windows.h>
#include <wincrypt.h>

// API documentation available at
// https://msdn.microsoft.com/en-us/library/windows/desktop/aa387733%28v=vs.85%29.aspx
// https://msdn.microsoft.com/en-us/library/windows/desktop/aa904940%28v=vs.85%29.aspx

typedef struct _SIGNER_FILE_INFO {
  DWORD   cbSize;
  LPCWSTR pwszFileName;
  HANDLE  hFile;
} SIGNER_FILE_INFO, *PSIGNER_FILE_INFO;

typedef struct _SIGNER_BLOB_INFO {
  DWORD   cbSize;
  GUID    *pGuidSubject;
  DWORD   cbBlob;
  BYTE    *pbBlob;
  LPCWSTR pwszDisplayName;
} SIGNER_BLOB_INFO, *PSIGNER_BLOB_INFO;

typedef struct _SIGNER_SUBJECT_INFO {
  DWORD cbSize;
  DWORD *pdwIndex;
  DWORD dwSubjectChoice;
  union {
    SIGNER_FILE_INFO *pSignerFileInfo;
    SIGNER_BLOB_INFO *pSignerBlobInfo;
  };
} SIGNER_SUBJECT_INFO, *PSIGNER_SUBJECT_INFO;

const DWORD SIGNER_SUBJECT_BLOB = 0x2;  // The subject is a BLOB.
const DWORD SIGNER_SUBJECT_FILE = 0x1;  // The subject is a file.

typedef struct _SIGNER_ATTR_AUTHCODE {
  DWORD   cbSize;
  BOOL    fCommercial;
  BOOL    fIndividual;
  LPCWSTR pwszName;
  LPCWSTR pwszInfo;
} SIGNER_ATTR_AUTHCODE, *PSIGNER_ATTR_AUTHCODE;

typedef struct _SIGNER_SIGNATURE_INFO {
  DWORD             cbSize;
  ALG_ID            algidHash;
  DWORD             dwAttrChoice;
  union {
    SIGNER_ATTR_AUTHCODE *pAttrAuthcode;
  };
  PCRYPT_ATTRIBUTES psAuthenticated;
  PCRYPT_ATTRIBUTES psUnauthenticated;
} SIGNER_SIGNATURE_INFO, *PSIGNER_SIGNATURE_INFO;

const DWORD SIGNER_AUTHCODE_ATTR = 1;  // The signature has Authenticode attributes.
const DWORD SIGNER_NO_ATTR = 0;  // The signature does not have Authenticode attributes.

typedef struct _SIGNER_CERT_STORE_INFO {
  DWORD          cbSize;
  PCCERT_CONTEXT pSigningCert;
  DWORD          dwCertPolicy;
  HCERTSTORE     hCertStore;
} SIGNER_CERT_STORE_INFO, *PSIGNER_CERT_STORE_INFO;

typedef struct _SIGNER_SPC_CHAIN_INFO {
  DWORD      cbSize;
  LPCWSTR    pwszSpcFile;
  DWORD      dwCertPolicy;
  HCERTSTORE hCertStore;
} SIGNER_SPC_CHAIN_INFO, *PSIGNER_SPC_CHAIN_INFO;

typedef struct _SIGNER_CERT {
  DWORD cbSize;
  DWORD dwCertChoice;
  union {
    LPCWSTR                pwszSpcFile;
    SIGNER_CERT_STORE_INFO *pCertStoreInfo;
    SIGNER_SPC_CHAIN_INFO  *pSpcChainInfo;
  };
  HWND  hwnd;
} SIGNER_CERT, *PSIGNER_CERT;

const DWORD SIGNER_CERT_SPC_FILE = 1;  // The certificate is stored in an SPC file.
const DWORD SIGNER_CERT_STORE = 2;  // The certificate is stored in a certificate store.
const DWORD SIGNER_CERT_SPC_CHAIN = 3;  // The certificate is stored in an SPC file and is associated with a certificate chain.

typedef struct _SIGNER_PROVIDER_INFO {
  DWORD   cbSize;
  LPCWSTR pwszProviderName;
  DWORD   dwProviderType;
  DWORD   dwKeySpec;
  DWORD   dwPvkChoice;
  union {
    LPWSTR pwszPvkFileName;
    LPWSTR pwszKeyContainer;
  };
} SIGNER_PROVIDER_INFO, *PSIGNER_PROVIDER_INFO;

const DWORD PVK_TYPE_FILE_NAME = 0x1;  // The private key information is a file name.
const DWORD PVK_TYPE_KEYCONTAINER = 0x02;  // The private key information is a key container.

typedef HRESULT (WINAPI *SignerSignFunc)(
  SIGNER_SUBJECT_INFO *pSubjectInfo,
  SIGNER_CERT *pSignerCert,
  SIGNER_SIGNATURE_INFO *pSignatureInfo,
  SIGNER_PROVIDER_INFO *pProviderInfo,
  LPCWSTR pwszHttpTimeStamp,
  PCRYPT_ATTRIBUTES psRequest,
  LPVOID pSipData
);

typedef HRESULT (WINAPI *SignerTimeStampFunc)(
  SIGNER_SUBJECT_INFO *pSubjectInfo,
  LPCWSTR pwszHttpTimeStamp,
  PCRYPT_ATTRIBUTES psRequest,
  LPVOID pSipData
);

wchar_t *convertCharArrayToLPCWSTR(const char* charArray) {
  size_t len = strlen(charArray);
  wchar_t* wString = (wchar_t*) calloc(1, (1+len)*sizeof(wchar_t));
  if (wString != NULL) {
    MultiByteToWideChar(CP_ACP, 0, charArray, -1, wString, 4096);
  }
  return wString;
}

int main(int argc, char *argv[]) {
  if (argc < 4) {
    fprintf(stderr, "USAGE %s <certificate.spc> <privatekey.pvk> <filetosign.ext> [timestampurl]\n", argv[0]);
    return 1;
  }

  int returncode = 1;
  LPWSTR certificate = convertCharArrayToLPCWSTR(argv[1]);
  LPWSTR privatekey = convertCharArrayToLPCWSTR(argv[2]);
  LPWSTR signfile = convertCharArrayToLPCWSTR(argv[3]);
  LPWSTR timestampUrl = NULL;
  if (argc > 4) {
    timestampUrl = convertCharArrayToLPCWSTR(argv[4]);
  }
  HMODULE module = NULL;

  SIGNER_FILE_INFO fileinfo = { 0 };
  fileinfo.cbSize = sizeof(SIGNER_FILE_INFO);
  fileinfo.pwszFileName = signfile;

  SIGNER_SUBJECT_INFO subjectInfo = { 0 };
  DWORD dwIndex = 0;
  subjectInfo.cbSize = sizeof(SIGNER_SUBJECT_INFO);
  subjectInfo.pdwIndex = &dwIndex;
  subjectInfo.dwSubjectChoice = SIGNER_SUBJECT_FILE;
  subjectInfo.pSignerFileInfo = &fileinfo;

  SIGNER_SIGNATURE_INFO signatureInfo = { 0 };
  signatureInfo.cbSize = sizeof(SIGNER_SIGNATURE_INFO);
  signatureInfo.algidHash = CALG_SHA1;
  signatureInfo.dwAttrChoice = SIGNER_NO_ATTR;

  SIGNER_CERT cert = { 0 };
  cert.cbSize = sizeof(SIGNER_CERT);
  cert.dwCertChoice = SIGNER_CERT_SPC_FILE;
  cert.pwszSpcFile = certificate;

  SIGNER_PROVIDER_INFO providerInfo = { 0 };
  providerInfo.cbSize = sizeof(SIGNER_PROVIDER_INFO);
  providerInfo.pwszProviderName = MS_ENHANCED_PROV_W;
  providerInfo.dwProviderType = PROV_RSA_FULL;
  providerInfo.dwKeySpec = 0;
  providerInfo.dwPvkChoice = PVK_TYPE_FILE_NAME; 
  providerInfo.pwszPvkFileName = privatekey;

  module = LoadLibrary("mssign32.dll");
  if (module == NULL) {
    fprintf(stderr, "Could not load mssign32.dll: 0x%.8x\n", GetLastError());
    goto exit;
  }

  SignerSignFunc pSignerSign = (SignerSignFunc) GetProcAddress(module, "SignerSign");
  SignerTimeStampFunc pSignerTimeStamp = (SignerTimeStampFunc) GetProcAddress(module, "SignerTimeStamp");
  if (pSignerSign == NULL || pSignerTimeStamp == NULL) {
    fprintf(stderr, "mssign32.dll doesn't export necessary functions\n");
    goto exit;
  }

  fprintf(stdout, "Signing \"%S\"...\n", signfile);
  DWORD res = pSignerSign(&subjectInfo, &cert, &signatureInfo, &providerInfo, NULL, NULL, NULL);
  if (res != 0) {
    fprintf(stderr, "Error while signing: 0x%.8x\n", GetLastError());
    goto exit;
  }
  
  if (timestampUrl != NULL) {
    fprintf(stdout, "Timestamping using \"%S\"...\n", timestampUrl);
    res = pSignerTimeStamp(&subjectInfo, timestampUrl, NULL, NULL);
    if (res != 0) {
      fprintf(stderr, "Error while timestamping: 0x%.8x\n", GetLastError());
      goto exit;
    }
  }
  fprintf(stdout, "Done\n");
  returncode = 0;

exit:
  if (module != NULL) {
    FreeLibrary(module);
  }
  free(timestampUrl);
  free(signfile);
  free(privatekey);
  free(certificate);
  return returncode; 
}
