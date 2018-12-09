#ifndef __BINSCII_H__
#define __BINSCII_H__

#include <iostream>
#include <fstream>
#include <string>
#include <stdint.h>
//#include <map>
#include <time.h>
#include "ErrorCodes.h"
using namespace std;

/*
 Declare a custom record of attributes
 We could use
 typedef map<int,string> FileAttributes;
 since all prodos attributes including the date and time are 16-bits.
 Refer to the C function ProDOSToUnix
 */
typedef struct FileAttributes
{
    uint8_t         accessMode;
    uint8_t         fileType;
    uint16_t        auxType;
    time_t          creationDateTime;
    time_t          modificationDateTime;
    uint32_t        fileSize;
} FileAttributes;

class BinScii
{
public:
                    BinScii();
                    ~BinScii();
    bool            Open(const char *, BSErrorCodes&);
    void            GetAttributes(FileAttributes&);
    const char*     GetDestPathname()       { return destPathname.c_str(); }
    bool            Verify(BSErrorCodes&);
    bool            Unpack(BSErrorCodes&);
protected:

private:
    bool            isHeaderStart(string&);
    bool            CheckAlphabet(BSErrorCodes&);
    bool            GetFilenameAndAttributes(BSErrorCodes&);
    bool            DecodeSegmentBodyAndCRC(BSErrorCodes&);
    uint16_t        DecodeString(string&, uint8_t *);
    void            TrimLeadingAndTrailingSpaces(string&);

    // variables
    string          destDirectory;          // It's better to use string than char*
    string          destPathname;
    ifstream        fInputStream;
    ofstream        fOutputStream;
    long            fCurrentPos;            // for debugging purposes
    string          fAlphabet;              // for checking purposes
    string          inputBuf;               // At most 64 ASCII chars for each line
    uint8_t         decodedData[80];        // no decoded data are > 48 bytes

    // Extracted from the encoded file header
    uint16_t        fNameLength;
    string          fFileName;
                                            // offsets  Meaning
    uint32_t        fFileSize;              // 00-02    Total size of original file
    uint32_t        fSegStartOffset;        // 03-05    Offset into original file of start of this seg
    uint8_t         fAccessMode;            // 06       ProDOS file access mode
    uint8_t         fFileType;              // 07       ProDOS file type
    uint16_t        fAuxType;               // 08-09    ProDOS auxiliary file type
    uint8_t         fStorageType;           // 10       ProDOS file storage type
    uint16_t        fNumBlocks;             // 11-12    Number of 512-byte blocks in original file
    time_t          fCreationDateTime;      // 13-14    File creation date, in ProDOS 8 format
                                            // 15-16    File creation time, in ProDOS 8 format
    time_t          fModificationDateTime;  // 17-18    File modification date
                                            // 19-20    File modification time
    int32_t         fSegmentLength;         // 21-23    Length in bytes of this segment
    uint16_t        fCRC;                   // 24-25    CRC checksum of preceding fields
//  uint8_t filler;                         // 26       Unused filler byte
};

#endif