## Extracting an Apple II/IIGS program or file from a BinSCII file


In the early days of the Internet when download speeds were slow and programs not bloated, many demos and programs were distributed via emails. Creative programmers develop encryption schemes with the primary aim of preserving file integrity. Various encoding methods like Huffman, LZW2, zip etc. were developed and implemented.

In the Apple II/AppleIIGS world, programs like ShrinkIt developed by Andy Nicholas became the standard for archiving Apple II/IIGS programs. Prior to that BinSCII was developed to help distribute AppleII programs using emails.

To test Spotlight plugin the following arguments can be passed:

-g $(BUILD_DIR)/Debug/SpotlightBSQ.mdimporter
-d2 /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC


(Info) Import: Import '/Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC' type 'appleii.binscii-archive' using '/Users/marklim/Desktop/Projects/IIGS/SCIIBinX/SpotlightBSQ/build/Release/SpotlightBSQ.mdimporter'
2024-01-18 11:08:39.912 mdimport[367:a0f] Imported '/Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC' of type 'appleii.binscii-archive' with plugIn /Users/marklim/Desktop/Projects/IIGS/SCIIBinX/SpotlightBSQ/build/Release/SpotlightBSQ.mdimporter.


2024-01-18 11:08:39.915 mdimport[367:a0f] Attributes: {
    ":MD:kMDItemSeedLastUsedDate" = 1;
    "_kMDItemFinderLabel" = "<null>";
    "com_apple_metadata_modtime" = 529143819;
    "com_incrementalinnovation_SCIIBinX_ItemModDate" = "1995-08-09 00:00:00 +0800";
    "com_incrementalinnovation_SCIIBinX_ItemName" = "MKALIAS.SHK";
    kMDItemContentCreationDate = "2014-02-22 20:59:33 +0800";
    kMDItemContentModificationDate = "2017-10-08 16:23:39 +0800";
    kMDItemContentType = "appleii.binscii-archive";
    kMDItemContentTypeTree =     (
        "appleii.binscii-archive",
        "public.data",
        "public.item",
        "public.archive"
    );
    kMDItemDisplayName =     {
        "" = "Alias.BSC";
    };
    kMDItemKind =     {
        "" = "BINSCII Document";
    };
}


To test QuickLook Plugin, the following arguments can be passed:


-g $(BUILD_DIR)/Release/QuickLookBSQ.qlgenerator
-c BSC
-p /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC
