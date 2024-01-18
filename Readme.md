## Extracting an Apple II/IIGS program or file from a BinSCII file


In the early days of the Internet when download speeds were slow and programs not bloated, many demos and programs were distributed via emails. Encryption schemes with the primary aim of preserving file integrity as well as compressing the file data. These encoding methods like Huffman, LZW2, etc. became widely used.

In the Apple II/AppleIIGS world, programs like ShrinkIt developed by Andy Nicholas became the standard for archiving Apple II/IIGS programs. In 1992, BinSCII was developed to help distribute AppleII programs using emails. The encoding preserves the file attributes of ProDOS programs. Refer to the Documentation folder for details on the format of BinSCII files.

The program **SCIIBinX** is based on the decoding suggested by Todd Whitesel. Given below are brief details on how to debug the Spotlight and QuickLook plugins of the program.       

To test Spotlight plugin the following arguments can be passed:

-g $(BUILD_DIR)/Debug/SpotlightBSQ.mdimporter
<br />
-d2 /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC

<br />
<br />
The spotlight plugin will output to the console when the executable is run under XCode.

To test QuickLook Plugin, the following arguments can be passed:


-g $(BUILD_DIR)/Release/QuickLookBSQ.qlgenerator
<br />
-c BSC
<br />
-p /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC
