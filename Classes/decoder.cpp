// This is where the action is!
#include <libgen.h>
#include <unistd.h>
#include "decoder.hpp"
#include "codingMap.h"
#include "crc.h"
#include "ErrorCodes.h"

// Lifted from a post on stackoverflow
// Returns to caller with the accumulated chars in the string object
// and the istream object ready to access the next char.
// The returned string t will not contain LF or CR
std::istream& safeGetline(std::istream& is, std::string& t)
{
    t.clear();
    
    // The characters in the stream are read one-by-one using a std::streambuf.
    // That is faster than reading them one-by-one using the std::istream.
    // Code that uses streambuf this way must be guarded by a sentry object.
    // The sentry object performs various tasks, such as thread synchronization
    // and updating the stream state.
    
    std::istream::sentry se(is, true);      // don't skip whitespaces during the additional processing
    std::streambuf* sb = is.rdbuf();

    /*
        There are 4 ways of terminating this loop:
            a) encountering a CR
            b) encountering an LF
            c) encountering a CR followed by an LF
            d) encountering an EOF
     This does not handle the situation of trailing spaces.
     */
    for(;;)
    {
        int c = sb->sbumpc();               // Returns the current character and consumes it
        
        switch (c)
        {
            case '\n':                      // LF
                return is;
            case '\r':                      // CR
                if (sb->sgetc() == '\n')    // Returns the current character without consuming it
                    sb->sbumpc();           // if true, handle CRLF; move past LF
                return is;                  // fall thru if CR only (false)
            case EOF:
                // Also handles the case when the last line has no line ending
                if (t.empty())
                    is.setstate(std::ios::eofbit);
                return is;
            default:
                t += (char)c;               // accumulate the chars
        }
    }
}

/*
 Comment: It's might be more flexible to pass the destination folder
            and pathname of the file.
 */
BinScii::BinScii()
{
    inputBuf.reserve(256);
}

BinScii::~BinScii()
{
    fInputStream.close();
}

// This method is called by an instance of an objective-C class.
bool BinScii::Open(const char *pathName, BSErrorCodes &errorCode)
{
    errorCode = kBSNoError;
    destDirectory = dirname((char *)pathName);  // Need to keep a copy

    //cout << "Destination folder:" << destDirectory << endl;
    fInputStream.open(pathName, ios::in);
    if (fInputStream.fail())
    {
        //cout << "Error opening " << pathName << endl;
        errorCode = kBSOpenFileError;
        return false;
    }
    else
    {
        return true;
    }
}

// We must handle the case of leading and trailing spaces in a line of text.
// We assume the string "t" has no LF and CR i.e. these have been removed
// from the original line of text.
void BinScii::TrimLeadingAndTrailingSpaces(string& t)
{
    if (t.empty())
    {
        return;
    }

    // Get position of first char which is not in the list of white spaces
    size_t p = t.find_first_not_of(" \t");
    if (p != string::npos)
    {   // Remove leading white spaces.
        t.erase(0, p);
    }

    // Get position of last char which is not a white space.
    p = t.find_last_not_of(" \t");
    if (string::npos != p)
    {   // Remove trailing white spaces - called whenever "t" has at least 1 non-ws.
        t.erase(p+1);
    }
}

/*
    Check for the existence of a sentinel line before the start of a segment.
    There may be extra info e.g. e-mail headers before this line.
    To skip all those, 
        1) this method will not return any error code
        2) any loop calling this method should exit only on detection of an EOF.
 This is the first line of the segment header of a block.
 */
bool BinScii::isHeaderStart(string& sentinel)
{
    const string BINSCII_HEADER =   "FiLeStArTfIlEsTaRt";
    bool success;
    //cout << sentinel << endl;

    // We should remove leading and trailing spaces from sentinel.
    TrimLeadingAndTrailingSpaces(sentinel);

    if (BINSCII_HEADER == sentinel)
    {
        //cout << "Header Match Length:" << sentinel.length() <<endl;
        //fCurrentPos = fInputStream.tellg();
        //cout << "current file position:" << fCurrentPos << endl;
        success = true;
    }
    else
    {
        //cout << "May not be a binscii file:" << sentinel << " Argh!" << endl;
        success = false;
    }
    return success;
}

// Todo: check that the given alphabet corresponds to our map.
// Or use it to setup our decodeMap.
// This should be the 2nd line of the segment header of a block.
bool BinScii::CheckAlphabet(BSErrorCodes &errorCode)
{
    static const string defaultAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789()";
    errorCode = kBSNoError;

    //fInputStream.ignore();
    safeGetline(fInputStream, fAlphabet).eof();
    // we should remove leading and trailing spaces from fAlphabet
    TrimLeadingAndTrailingSpaces(fAlphabet);
    //cout << "Alphabet String:" << fAlphabet << endl;
    fCurrentPos = fInputStream.tellg();
    if (fAlphabet == defaultAlphabet)
    {
        //cout << "Alphabet matched @ pos:" << fCurrentPos << endl;
        return true;
    }
    else
    {
        //cout << "Alphabet mismatch @ pos:" << fCurrentPos << endl;
        errorCode = kBSAlphabetHeaderError;
        return false;
    }
}

// Lifted from ProDOS.cpp (CiderPress)
// Convert ProDOS Date and Time to Unix time_t object
time_t ProDOSToUnix(uint16_t prodosDate, uint16_t prodosTime)
{
    int year, month, day, hour, minute, second;

    second  = 0;
    minute  = prodosTime & 0x3f;
    hour    = (prodosTime >> 8) & 0x1f;
    day     = prodosDate & 0x1f;
    month   = (prodosDate >> 5) & 0x0f;
    year    = (prodosDate >> 9) & 0x7f;
    if (year < 40)
        year += 100;            // P8 uses 0-39 for 2000-2039

    struct tm timeBuf;
    time_t when;

    timeBuf.tm_sec  = second;
    timeBuf.tm_min  = minute;
    timeBuf.tm_hour = hour;
    timeBuf.tm_mday = day;
    timeBuf.tm_mon  = month-1;  // ProDOS uses 1-12
    timeBuf.tm_year = year;
    timeBuf.tm_wday = 0;
    timeBuf.tm_yday = 0;
    timeBuf.tm_isdst    = -1;   // let it figure DST and time zone
 
    when = mktime(&timeBuf);
    
    if (when == (time_t) -1)
        when = 0;
    
    return when;
}

/*
 Extract the name and attributes of the file currently being decoded.
 This should be the 3rd line of the segment header of a block.
 If an encoded file has several segments, the encoded data of the
 3rd line are slightly different.
 */
bool BinScii::GetFilenameAndAttributes(BSErrorCodes &errorCode)
{
    string fileAttr;
    bool result = true;             // assume all will be ok.

    errorCode = kBSNoError;
    safeGetline(fInputStream, fileAttr).eof();
    // We should remove leading and trailing spaces from fileAttr.
    TrimLeadingAndTrailingSpaces(fileAttr);
    //cout << "Header String:" << fileAttr << endl;
    fCurrentPos = fInputStream.tellg();
    //cout << "current file position:" << fCurrentPos << endl;

    // The ProDOS filename is 16 bytes
    fNameLength     = fileAttr[0] - 'A' + 1;
    fFileName       = fileAttr.substr(1, fNameLength);  // skip the len byte
    //cout << "Original filename:" << fFileName << endl;

    destPathname    = destDirectory + "/" + fFileName;
    //cout << "destination path:" << destPathname << endl;

    // Extract and decode the binscii header structure (cf BinSciiFormat.txt)
    string fileHeaderString = fileAttr.substr(16, 53);  // exactly 36 chars
    DecodeString(fileHeaderString, decodedData);
    
    // We check the line's CRC first before extracting the encoded file's attributes.
    uint16_t crc = 0;
    for (int i = 0; i < 24; i++)
    {
        crc = (crcTable[((crc >> 8) & 0xFF) ^ decodedData[i]] ^ (crc << 8)) & 0xFFFF;
    }
    fCRC    = decodedData[24] | (decodedData[25] << 8);
    if (fCRC != crc)
    {
        //cout << "warning: CRC error in file header" << endl;
        errorCode = kBSHeaderCRCError;
        result  = false;
        goto bailOut;
    }
    
    
    fFileSize       = decodedData[0] + (decodedData[1]<<8) + (decodedData[2]<<16);
    fSegStartOffset = decodedData[3] + (decodedData[4]<<8) + (decodedData[5]<<16);
    //cout << "file size:" << fFileSize << endl;
    //cout << "offset to start of segment:" << fSegStartOffset << endl;

    fAccessMode     = decodedData[6];
    fFileType       = decodedData[7];
    fAuxType        = decodedData[8] + (decodedData[9] << 8);
    fStorageType    = decodedData[10];
    fNumBlocks      = decodedData[11] + (decodedData[12]<<8);
    // The file creation/modification dates and times are decoded below.
    // We only decode these if the header CRC is ok.
    fSegmentLength = decodedData[21] + (decodedData[22]<<8) + (decodedData[23]<<16);
/*
    cout << "len of " << fFileName << " =" << fNameLength << endl;
    cout << "header string " << headerString << endl; 
    cout << "Access: " << hex << (short)fAccessMode << endl;
    cout << "fileType: " << hex << (short)fFileType << endl;
    cout << "Aux Type: " << hex << (short)fAuxType << endl;
    cout << "Storage type: " << hex << (short)fStorageType << endl;
    cout << "Number of blocks: " << dec << fNumBlocks << endl;
    cout << "SegmentLength: " << dec << fSegmentLength << endl;
*/
    // decodedData[13..20] have the decoded information of
    // the original file's creation/modification dates and times.
    uint16_t proDate, proTime;
    proDate                 = decodedData[13] | (decodedData[14] << 8);
    proTime                 = decodedData[15] | (decodedData[16] << 8);
    fCreationDateTime       = ProDOSToUnix(proDate, proTime );

    proDate                 = decodedData[17] | (decodedData[18] << 8);
    proTime                 = decodedData[19] | (decodedData[20] << 8);
    fModificationDateTime   = ProDOSToUnix(proDate, proTime);
bailOut:
    return result;
}

/*
 * Decode a string of binscii characters to binary data, meanwhile
 * calculating crc.
 * The decoding scheme takes 4 bytes (6 valid bit each) and convert them
 * to 3 binary bytes (8 bits each)
 * The length of the decoded string is returned; binary data is returned as
 * an array of bytes. 
 * Notes: the outputData is not zeroed; that's ok since the output len is returned.
 * We can't use a C++ string object for output.
 * Reason: the underlying default char class used is standard 7-bit ASCII.
 */
uint16_t BinScii::DecodeString(string& inputData, uint8_t *outputData)
{
    uint16_t len = 0;
    char c0, c1, c2, c3;

    //cout << "decoding string:" << inputData << endl;
    for (int i=0, j=0; i < inputData.length(); i += 4, j +=3)
    {
        c0 = inputData[i+0];
        c1 = inputData[i+1];
        c2 = inputData[i+2];
        c3 = inputData[i+3];
/*
        cout << c0 << ":" << (short) decodeMap[c0] << " " <<
                c1 << ":" << (short) decodeMap[c1] << " " <<
                c2 << ":" << (short) decodeMap[c2] << " " <<
                c3 << ":" << (short) decodeMap[c3] << " " << endl;
*/
        outputData[j+0] = ((decodeMap[c3] << 2) | (decodeMap[c2] >> 4)) & 0xff;
        outputData[j+1] = ((decodeMap[c2] << 4) | (decodeMap[c1] >> 2)) & 0xff;
        outputData[j+2] = ((decodeMap[c1] << 6) | (decodeMap[c0]))    & 0xff;
        len += 3;
    }
    return len;
}

/*
 Decode the body of the segment and calculate its CRC.
 Returns an error code - EOF, corrupted, i/o failure, mismatched CRC etc.
 */
bool BinScii::DecodeSegmentBodyAndCRC(BSErrorCodes &errorCode)
{
    
    bool result = true;
    errorCode = kBSNoError;
    uint16_t crc = 0;
    uint16_t len = 0;

    fOutputStream.seekp(fSegStartOffset);   // This is important
    //cout << "writing @ offset:" << fSegStartOffset << endl;
    /* fSegmentLength must be a signed integer */
    while (fSegmentLength > 0)
    {
        if (safeGetline(fInputStream, inputBuf).eof())
        {   // no more input text lines
            //cout << "Unexpected end of file:" << inputBuf <<  endl;
            errorCode = kBSUnexpectedEOFError;
            result = false;
            goto bailOut;
        }

        // We should remove leading and trailing spaces from input line.
        TrimLeadingAndTrailingSpaces(inputBuf);
        //cout << "String to be decoded:" << inputBuf << endl;
        if ((len = DecodeString(inputBuf, decodedData)) != 48)
        {
            //cout << "length is corrupted" << endl;
            errorCode = kBSBadLengthError;
            result = false;
            goto bailOut;
        }

        //cout << "Writing " << len << " bytes to file" << endl;
        for (int i = 0; i < 48; i++)
        {
            crc = (crcTable[((crc >> 8) & 0xFF) ^ decodedData[i]] ^ (crc << 8)) & 0xFFFF;
        }

        fOutputStream.write((const char*)decodedData, len);
        if (fOutputStream.fail())
        {
            //cout << "Error writing to output file" << endl;
            errorCode = kBSWriteError;
            result = false;
            goto bailOut;
        }
        fSegmentLength -= len;
        //cout << "# of bytes left to write:" << fSegmentLength << endl;
    } // while


    // Now read in the last 4 chars which is the segment's encoded CRC.
    if (safeGetline(fInputStream, inputBuf).eof())
    {
        errorCode = kBSUnexpectedEOFError;
        result = false;
        goto bailOut;
    }

    // We should remove leading and trailing spaces from input line.
    TrimLeadingAndTrailingSpaces(inputBuf);
    // The last string is 4 bytes; it is encoded from 3 bytes.
    //cout << "last string of segment to be decoded:" << inputBuf << endl;
    if ((len = DecodeString(inputBuf, decodedData)) == 3)
    {
        uint16_t segmentCRC = 0;
        // Only the first 2 bytes are examined; third byte is (and should be) a 0.
        segmentCRC = (decodedData[0] | (decodedData[1] << 8));
        //cout << "Segment's CRC:" << segmentCRC << " Calculated CRC:"  << crc << endl;
        if (segmentCRC != crc)
        {
            //cout << "warning: expected segment CRC don't match calculated CRC" << endl;
            errorCode = kBSBadSegmentCRCError;
        }
    }
    else
    {
        errorCode = kBSBadLengthError;
    }

bailOut:
    return result;
}

/*
 Return the original file's attributes. The messages isHeaderStart, CheckAlphabet and
 GetFilenameAndAttributes should be send to a BINSCII object first. One way is to call
 the method Verify. Another way is to read the entire BSC/BSQ file and extract the
 information. We choose the simplest (and fastest) procedure which is Verify.
 */
void BinScii::GetAttributes(FileAttributes& attr)
{
    attr.accessMode             = fAccessMode;
    attr.fileType               = fFileType;
    attr.auxType                = fAuxType;
    attr.creationDateTime       = fCreationDateTime;
    attr.modificationDateTime   = fModificationDateTime;
    attr.fileSize               = fFileSize;
}

/*
 Checks the integrity of the header and confirm it's indeed a BSQ file.
 We must start the scan from the beginning of the file. It's possible that
 there are e-mail headers and other stuff in ASCII before the first line of a
 segment header.
 This method can be called as a preliminary check that the file being processed
 has some characteristics of a BSC/BSQ file. Not failed-proof.
 */
bool BinScii::Verify(BSErrorCodes &errorCode)
{
    errorCode = kBSNoError;
    bool result;

    fInputStream.seekg(0L);         // play safe
    /*
     We scan thru the file until we got the 1st line of a segment header.
     Remember: a bsc/bsq file can contain more than 1 segment or
     the original file had been encoded into several segments with
     each segment written to a separate bsc/bsq file.
     */
    while (!safeGetline(fInputStream, inputBuf).eof())
    {
        if (isHeaderStart(inputBuf))
            break;
    } // while

    // Note: We may have exited the loop above on a EOF.
    if (!fInputStream.eof())
    {   // If we get here w/o encountering the EOF, it means we may have a valid
        // first line of a segment header. Now check that the alphabet set is ok.
        if (CheckAlphabet(errorCode))
        {   // Yes, it's ok; finally check the file header info is valid.
            if (GetFilenameAndAttributes(errorCode))
            {
                // GetFilenameAndAttributes will return an error code of 0 to confirm crc is ok
                result = true;
                //cout << "verifying successful" << endl;
            }
            else
            {
                // Problem with getting the attributes of the decoded file.
                // errorCode has the type of error.
                result = false;
            }           
        }
        else
        {
            // Problem with the alphabet set.
            // The error code is returned in the "errorCode" object.
            result = false;
        }
    }
    else
    {
        // If we get here, the entire file have been scanned but we didn't
        // find what we are looking for.
        // The header start line "FiLeStArTfIlEsTaRt" could not be found.
        errorCode = kBSNoFileStartHeaderError;
        //cout << "Problem with the header" << endl;
        result = false;
    }
    return result;
}

/*
 * This is the main method of extracting the segment(s) of one or more
 * BSC/BSQ file(s).
 * Scan through a BSC/BSQ file, processing all embedded segments.
 * We must start from the beginning of the file which might contain
 * interpersed non-block text. The segments might be part of the
 * text of a posting to a newsgroup.
 */
bool BinScii::Unpack(BSErrorCodes &errorCode)
{
    errorCode = kBSNoError;
    bool result = true;
    fInputStream.seekg(0L);
    
    // Loop until the end-of-file is detected. All BINSCII segments
    // of the input file will be processed.
    while (!safeGetline(fInputStream, inputBuf).eof())
    {
        if (isHeaderStart(inputBuf))
        {
            // Process only when the first line of a segment header is detected.
            if (!CheckAlphabet(errorCode))
            {
                // The 2nd line of the segment header is probably corrupted.
                result = false;
                goto bailOut;
            }
            if (GetFilenameAndAttributes(errorCode))
            {
                // The 3rd line of the segment header is ok.
                // Open the output file if necessary. If this file is already opened, it
                // means there are more than 1 BINSCII segment in the input file.
                if (!fOutputStream.is_open())
                {
                    //cout << "open file for output" << endl;
                    // The output file must be opened in read/write mode in order for
                    // segments from different input BSC/BSQ files to be combined successfully.
                    // This presumed that a zeroed-out decoded file have been created beforehand.
                    // cf. process method of MainWindowController
                    fOutputStream.open(destPathname.c_str(),
                                       ios::out|ios::in|ios::binary);
                    if (fOutputStream.fail())
                    {
                        //cout << "Error opening " << destPathname.c_str() << endl;
                        errorCode = kBSOutputError;
                        result = false;
                        break;                  // get out of loop
                    }
                }
                DecodeSegmentBodyAndCRC(errorCode);     // Decode & write the segment
            }
            else
            {
                result = false;
                goto bailOut;
            }
        }
    } // while
bailOut:
    fOutputStream.close();
    // Remove extra zeroes (if any) from the decoded file; may not be necessary.
    truncate(destPathname.c_str(), fFileSize);
    return result;
}
