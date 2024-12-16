// CZI File Loader Macro for ImageJ
// Loads CZI files with two channels and provides basic processing options
// Run with  fiji -macro test.ijm
// Install in Plugins > Macros menu

// Enables to use Ext functions (display help with Plugins>Bio-Formats>Bio-Formats Macro Extensions)
run("Bio-Formats Macro Extensions");

macro "Generate siRNA pngs" {
    args = split(getArgument(), ',');
    if (args.length==0) {
        // Prompt user to select CZI file
        filepath=File.openDialog("Select CZI File");
    } else {
        filepath=args[0];
    }
    if (!File.exists(filepath) || !endsWith(toLowerCase(filepath), ".czi")) {
        exit("Invalid file. Please select a CZI file.");
    }
    todo=split(getString("Which images should be processed?",'1'),',');
    //todo=newArray(2);todo[0]=2;todo[1]=7;
    for (ii=0; ii<todo.length; ii++){ // Open each image one by one, opening all and processing with selectImage is a risk for the memory of the computer.
        print("Processing image " + todo[ii]);
        roi=todo[ii];
        roi_name=roi;
        if (startsWith(roi, '0')) { roi=substring(roi,1,1); }
        if (lengthOf(roi)==1){ roi_name="0"+roi; }
        run("Bio-Formats Importer", "open=[" + filepath + "] color_mode=Composite series_" + roi + " specify_range view=Hyperstack stack_order=XYCZT");
        // Alternatively open_all_series instead of series_X
        Ext.setId(filepath);
        // Interesting fields: Experiment|AcquisitionBlock|FocusSetup|FocusStrategy|TilesIntervalInfo|MainInterval #1
        // Information|Image|S|Scene|ArrayName #01 = A2
        Ext.getMetadataValue("Information|Image|S|Scene|ArrayName #"+roi_name,well);
        
        Stack.setChannel(1); // Phase contrast
        Stack.setChannel(2); // TYE567
        run("Brightness/Contrast...");
        min=3;
        max=100;
        setMinAndMax(min,max);

        //dir = getDirectory("Choose save directory");
        title = split(getTitle()," - ");
        filename = "Images/" + title[0] + "_"+well + "_"+roi_name + "_"+min+"-"+max + ".png";
        print("Saving at " + filename);
        saveAs("png", filename);
        close(); // Very important
    }
    run("Quit");
}

// Additional utility macro (written by Claude, not tested)
macro "Print Image Info" {
    if (nImages == 0) {
        exit("No images open.");
    }
    
    // Print dimensions and type for each open image
    for (i = 1; i <= nImages; i++) {
        selectImage(i);
        
        print("Image " + i + " Information:");
        print("Title: " + getTitle());
        print("Dimensions: " + getWidth() + " x " + getHeight());
        print("Bit Depth: " + bitDepth());
        print("Channels: " + getNChannels());
        print("Slices: " + getNSlices());
        print("Frames: " + getNFrames());
        print("---");
    }
}
