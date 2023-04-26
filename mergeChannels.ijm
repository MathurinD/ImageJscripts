args = split(getArgument(), ',');
if (args[0]=="") exit ("No argument!");

// Extract the readout name from the filename. Expects a syntax Label_panelid_readout or Label_Label
function getReadout(fname) {
    fname = split(fname, '/');
    fname = fname[fname.length-1]; // Basename
    fname = split(fname, '_');
    if (fname.length > 2) { fname = fname[2]; }
    else { fname = fname[0]; }
    fname = split(fname, '.');
    fname = fname[0];
    return fname;
}

// Load each grey scale picture and enhance contract
nargs = args.length;
red=args[0];
open(red);
rename('red');
red = getReadout(red);
run("Enhance Contrast", "saturated=0.35");
output="merged_" + red;
if (nargs > 1) {
    green=args[1];
    open(green);
    rename('green');
    green = getReadout(green);
    run("Enhance Contrast", "saturated=0.35");
    output = output + "_" + green;
}
if (nargs > 2) {
    blue=args[2];
    open(blue);
    rename('blue');
    blue = getReadout(blue);
    run("Enhance Contrast", "saturated=0.35");
    output = output + "_" + blue;
}

// Merge the available picture and attribute them a color, first red, second green, third blue
if (nargs == 1) { run("Merge Channels...", "red=red create"); }
if (nargs == 2) { run("Merge Channels...", "red=red green=green create"); }
if (nargs == 3) { run("Merge Channels...", "red=red green=green blue=blue create"); }

// Save the output
rename(output);
saveAs('png', output);
print(output+'.png');
run('Quit');


