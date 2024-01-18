## Extracting an Apple II/IIGS program or file from a BinSCII file


In the early days of the Internet when download speeds were slow and programs not bloated, many demos and programs were distributed via emails. Encryption schemes with the primary aim of preserving file integrity as well as compressing the file data. These encoding methods like Huffman, LZW2, etc. became widely used.

In 1992, BinSCII was developed to help distribute AppleII programs via emails. The proposed scheme uses printable ASCII characters to encode (and decode) Apple II files in particular preserving the file attributes of ProDOS programs. It cannot handle the resource forks of Apple IIGS files. Programs like ShrinkIt and GS-ShrinkIt developed by Andy Nicholas became the standard for archiving Apple II/IIGS programs. 



The program **SCIIBinX** is based on the decoding suggested by Todd Whitesel. Refer to the Documentation folder for details on the format of **BinSCII** files. To facilitate the decoding of **BinSCII** files on the macOS, the program recognises two file extensions viz. **BSC** and **BSQ**. Usually, **BSQ** files encode a ShrinkIt Archive whereas **BSC** files encode AppleII a single program or data file.

There is user documentation under the program's **Help** Menu. **SCIIBinX** comes with 2 plugins to help the user decide if it's worth while decoding a **BSC** or **BSQ** file. The program can change to file extension of any *TEXT* file to **BSC** or **BSQ**.

Given below are brief details on how to debug the Spotlight and QuickLook plugins of the program.       

To test Spotlight plugin the following arguments can be passed:

-g $(BUILD_DIR)/Debug/SpotlightBSQ.mdimporter
<br />
-d2 /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC

<br />
<br />
The spotlight plugin will output to the console when the executable is run under XCode. The programmer/tester will have to change the pathname to point at the correc location of a test file.

<br />
<br />

To test QuickLook Plugin, the following arguments can be passed:
<br />
<br />

-g $(BUILD_DIR)/Release/QuickLookBSQ.qlgenerator
<br />
-c BSC
<br />
-p /Users/marklim/Desktop/Resources/SampleBSQs/Alias.BSC
