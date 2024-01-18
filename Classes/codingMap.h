// In our decoding map (see below), A=0, B=1, C=2, ... (=62 )=63 giving a total of 64 chars
char encodeMap[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789()";

// Instead of reading the file for the alphabet used during encoding,
// we use a decoding map.
// Require only a 128-char ASCII table. An entry of -1 means the
// ASCII character being compared against is invalid.
signed char decodeMap[256] =
{                                       // char value
    -1, -1, -1, -1, -1, -1, -1, -1,     // 0-7
    -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1,     // 16-
    -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1,     // 32
    62, 63, -1, -1, -1, -1, -1, -1,     //    ( )
    52, 53, 54, 55, 56, 57, 58, 59,     // 48 '0'-'9'
    60, 61, -1, -1, -1, -1, -1, -1,
    -1, 0,  1,  2,  3,  4,  5,  6,      // 64 'A'-'Z'
    7,  8,  9,  10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22,     // 80
    23, 24, 25, -1, -1, -1, -1, -1, 
    -1, 26, 27, 28, 29, 30, 31, 32,     // 96 'a'-'z'
    33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48,     // 112
    49, 50, 51, -1, -1, -1, -1, -1
};
