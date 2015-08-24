// AirSerial.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include "lib/FlashRuntimeExtensions.h"

OVERLAPPED recvOS;
OVERLAPPED sendOS;
char baudr[64];
char comPort[256];

void InitBaudr(int baudrate)
{
	switch (baudrate)
	{
	case     110: strcpy_s(baudr, "baud=110 data=8 parity=N stop=1");
		break;
	case     300: strcpy_s(baudr, "baud=300 data=8 parity=N stop=1");
		break;
	case     600: strcpy_s(baudr, "baud=600 data=8 parity=N stop=1");
		break;
	case    1200: strcpy_s(baudr, "baud=1200 data=8 parity=N stop=1");
		break;
	case    2400: strcpy_s(baudr, "baud=2400 data=8 parity=N stop=1");
		break;
	case    4800: strcpy_s(baudr, "baud=4800 data=8 parity=N stop=1");
		break;
	case    9600: strcpy_s(baudr, "baud=9600 data=8 parity=N stop=1");
		break;
	case   19200: strcpy_s(baudr, "baud=19200 data=8 parity=N stop=1");
		break;
	case   38400: strcpy_s(baudr, "baud=38400 data=8 parity=N stop=1");
		break;
	case   57600: strcpy_s(baudr, "baud=57600 data=8 parity=N stop=1");
		break;
	case  115200: strcpy_s(baudr, "baud=115200 data=8 parity=N stop=1");
		break;
	case  128000: strcpy_s(baudr, "baud=128000 data=8 parity=N stop=1");
		break;
	case  256000: strcpy_s(baudr, "baud=256000 data=8 parity=N stop=1");
		break;
	}
}

static FREObject Open(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
	const uint8_t *portName;
	uint32_t len;
	FREGetObjectAsUTF8(argv[0], &len, &portName);
	int baudrate;
	FREGetObjectAsInt32(argv[1], &baudrate);
	InitBaudr(baudrate);

	memset(comPort, 0, sizeof(comPort));
	MultiByteToWideChar(CP_UTF8, 0, (LPCCH)portName, len, (LPWSTR)comPort, sizeof(comPort));

	HANDLE hFile = CreateFile((LPWSTR)comPort, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);

	if (INVALID_HANDLE_VALUE == hFile){
		return NULL;
	}

	DCB portSetting;
	memset(&portSetting, 0, sizeof(DCB));
	portSetting.DCBlength = sizeof(DCB);
	portSetting.fDtrControl = DTR_CONTROL_DISABLE;

	if (!BuildCommDCBA(baudr, &portSetting)){
		CloseHandle(hFile);
		return NULL;
	}

	if (!SetCommState(hFile, &portSetting)){
		CloseHandle(hFile);
		return NULL;
	}

	COMMTIMEOUTS timeouts;
	timeouts.ReadIntervalTimeout = MAXDWORD;
	timeouts.ReadTotalTimeoutMultiplier = 0;
	timeouts.ReadTotalTimeoutConstant = 0;
	timeouts.WriteTotalTimeoutMultiplier = 50;
	timeouts.WriteTotalTimeoutConstant = 50;

	if (!SetCommTimeouts(hFile, &timeouts)){
		CloseHandle(hFile);
		return NULL;
	}

	PurgeComm(hFile, PURGE_TXCLEAR | PURGE_TXABORT | PURGE_RXCLEAR | PURGE_RXABORT);

	memset(&recvOS, 0, sizeof(OVERLAPPED));
	memset(&sendOS, 0, sizeof(OVERLAPPED));

	recvOS.hEvent = CreateEvent(0, 0, 0, 0);
	sendOS.hEvent = CreateEvent(0, 1, 0, 0);

	FREObject result;
	FRENewObjectFromUint32((uint32_t)hFile, &result);
	return result;
}

static FREObject Send(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
	HANDLE hFile = NULL;
	FREGetObjectAsUint32(argv[0], (uint32_t*)&hFile);
	FREByteArray buff;
	FREAcquireByteArray(argv[1], &buff);
	if (!WriteFile(hFile, buff.bytes, buff.length, NULL, &sendOS) && GetLastError() == ERROR_IO_PENDING){
		WaitForSingleObject(sendOS.hEvent, INFINITE);
	}
	FREReleaseByteArray(argv[1]);
	return NULL;
}

static FREObject Recv(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
	HANDLE hFile = NULL;
	FREGetObjectAsUint32(argv[0], (uint32_t*)&hFile);
	FREByteArray buff;
	FREAcquireByteArray(argv[1], &buff);
	DWORD n;
	if (!ReadFile(hFile, buff.bytes, buff.length, &n, &recvOS) && GetLastError() == ERROR_IO_PENDING){
		WaitForSingleObject(recvOS.hEvent, INFINITE);
	}
	FREReleaseByteArray(argv[1]);
	FREObject result;
	FRENewObjectFromUint32(n, &result);
	return result;
}

void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
	uint32_t* numFunctions, const FRENamedFunction** functionsToSet)
{
	static FRENamedFunction funcList[3] = {
		{ (const uint8_t*)"Open", NULL, Open },
		{ (const uint8_t*)"Send", NULL, Send },
		{ (const uint8_t*)"Recv", NULL, Recv }
	};
	*functionsToSet = funcList;
	*numFunctions = 3;
}

void ContextFinalizer(FREContext ctx)
{
	CloseHandle(recvOS.hEvent);
	CloseHandle(sendOS.hEvent);
	memset(&recvOS, 0, sizeof(OVERLAPPED));
	memset(&sendOS, 0, sizeof(OVERLAPPED));

}

extern "C"
{
	__declspec(dllexport) void SerialExtInitializer(void** extData, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
	{
		*ctxInitializerToSet = ContextInitializer;
		*ctxFinalizerToSet = ContextFinalizer;
	}

	__declspec(dllexport) void SerialExtFinalizer(void* extData)
	{
		ContextFinalizer(NULL);
	}
}


