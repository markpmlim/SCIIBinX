## Extracting an Apple II/IIGS program or file from a BinSCII file


In the early days of the Internet when download speeds were slow and programs not bloated, many demos and programs were distributed via emails. Creative programmers develop encryption schemes with the primary aim of preserving file integrity. Various encoding methods like Huffman, LZW2, zip etc. were developed and implemented.

In the Apple II/AppleIIGS world, programs like ShrinkIt developed by Andy Nicholas became the standard for archiving Apple II/IIGS programs. Prior to that BinSCII was developed to help distribute AppleII programs using emails.

To test Spotlight plugin the following arguments can be passed:

-g $(BUILD_DIR)/Debug/SpotlightBSQ.mdimporter
-d2 /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC

The spotlight plugin will output to the console when the executable is run under XCode.

To test QuickLook Plugin, the following arguments can be passed:


-g $(BUILD_DIR)/Release/QuickLookBSQ.qlgenerator
-c BSC
-p /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC
