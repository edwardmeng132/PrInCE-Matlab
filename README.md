# PrInCE

Predicting Interactomes via Co-Elution: a bioinformatics pipeline for analyzing PCP-SILAC and other co-elution experiments.

* Predict protein-protein interactions
* Predict protein complexes
* Calculate protein abundance differences

Original versions of the analysis were written by Anders Kristensen<sup>1</sup> and Nichollas Scott<sup>2</sup>.


# How to use

1. Download pipeline.
2. Format your data.
3. Put your data in the input folder..
4. Enter your experiment details in prince.m.
5. Run prince.m.


### 1. Download PrInCE.

In a browser, go to to [https://github.com/fosterlab/PrInCE](https://github.com/fosterlab/PRInCE). Click the green "Clone or Download" button in the top right. Then click "Download ZIP".

![Download pipeline from github](/ReadmeFigures/01download.jpg?raw=true)

### 2. Format your data.

#### Data files
Make one csv file for each biological condition. Except for the header, each row is co-elution data from a single protein and replicate, e.g. a chromatogram. File names must be of the format "condition1.csv", where "1" denotes the experimental condition. For example, for an experiment with two conditions, name the data files "condition1.csv" and "condition2.csv". Each file is formatted like this:

* Column 1: Protein ID (must match with reference database, e.g. CORUM)
* Column 2: Replicate number (integer)
* Columns 3-end: Protein amount, e.g. isotopologue ratio for PCP-SILAC

Typical datasets have hundreds or thousands of proteins and dozens of fractions. Here's a simple dataset with one condition, two replicates, and five fractions:

![Format your data files like this](/ReadmeFigures/examplefile1.jpg?raw=true)

Important: Ensure that files are "saved as csv", e.g. Excel --> "Save as" --> "Save as csv"

#### Reference database of known protein complexes
PrInCE needs a reference database of known protein complexes, e.g. CORUM. This reference database must be a file in the same format as CORUM's *allComplexes.txt* file (downloadable [here](http://mips.helmholtz-muenchen.de/corum/#download)), and we recommend this for mammalian datasets. In case a custom reference must be made, it must follow this format:

* must be tab-delimited
* must have a header
* reference complexes are in the sixth column, and members of a complex are semicolon-separated

Note: protein IDs in data files must match a subset of protein IDs in the reference database.

### 3. Unzip the pipeline, and put your data in the Input folder.

Unzip the downloaded zip file (PrInCE-master.zip). This creates four folders and a few files, like this:

  * PrInCE-master/
    * Code/
    * Input/
      * Reference database file (e.g *allComplexes.txt*)
      * Data file 1 (e.g *condition1.csv*)
      * Data file 2 (e.g *condition2.csv*)
      * ...
    * Output/
    * Standalone/
    * experimental_design.rtf
    * prince.m

Place all data files (there will be one for each biological condition) and the reference database file (typically "allcomplexes.txt" from CORUM) in the Input/ folder.

Important: PrInCE includes test data files (see below). These test files should be replaced/deleted before analyzing your data!

### 4. Enter the details of your experiment in experimental_design.rtf.

The file "experimental_design.rtf" tells PrInCE about your experiment, including paramaters such as the number of biological conditions and replicates. This file also gives the option to skip PrInCE modules and control whether plots are generated for individual proteins. (Plotting individual proteins is useful but can make quite a few plots.) To edit these parameters, open "experimental_design.rtf" in a text editor and make the necessary changes. Here are the parameters listed in the file, along with example values:

  * Desired precision of interaction list: 75% (Controls the quality-vs-quantity of the predicted interactions. Typical values are 50%, 60%, and 75%. A 50% precise interaction list has half true positives and half false positives.)
  * Major protein groups filename: Major_protein_groups.csv
  * Reference database filename: allComplexes.txt
  * Treatment condition: condition1 (FoldChanges calculates the ratio of protein amounts between two conditions. e.g. condition1/condition. "Treatment condition" is the numerator in the ratio...)
  * No-treatment condition: condition2 (... and "No-treatment condition" is the denominator.)
  * Number of fractions: 55 (If different replicates have different numbers of fractions, list the largest number here.)
  * Number of replicates: 3
  * Skip Alignment?: No (Must be "Yes" or "No")
  * Skip FoldChanges?: No (Must be "Yes" or "No")
  * Skip Interactions?: No (Must be "Yes" or "No")
  * Skip Complexes?: No (Must be "Yes" or "No")
  * Make plots of individual proteins (GaussBuild)?: Yes (Must be "Yes" or "No")
  * Make plots of individual proteins (FoldChanges)?: Yes (Must be "Yes" or "No")

Important: "experimental_design.rtf" must be saved as a .rtf file! In most text editors, go to "Save as" --> "Save as .rtf"

### 5. Run analysis.

#### In Matlab

If you have Matlab R2016a or later, we recommend you run the Matlab source code. In Matlab, navigate to the PrInCE-master folder you made in step 3. In the Matlab command line type

```
prince.m
```

As the pipeline runs, output figures and tables will be generated in the Output/ folder.

#### As standalone executable

Mac and PC users can run PrInCE without owning Matlab. This requires downloading Matlab Runtime (~1GB) and setting up the appropriate folders, so is not recommended if a copy of Matlab is available. To run a standalone version of PrInCE:

1. Run "myAppInstaller_web". _For Mac users, this is Standalone/Mac/PrInCEInstaller_web. For PC users, this is Standalone/PC/PrInCEInstaller_web._
2. Complete the installation process.
    - When prompted to choose the first installation folder (prince standalone), choose the PrInCE-master folder.
    - For the second installation folder (Matlab runtime), keep the default.
    - The "Confirmation" screen shows the folders that prince standalone and Matlab runtime are in. __Mac users, copy and paste the paths to these TWO folders! You'll need them in step 4 below.__
2. Move standalone files to the PrInCE-master folder created in step 3. __This is the folder that contains "license.txt", "experimental_design.rtf", etc.__
    - Standalone files are in a folder called "application", which is in the installation folder (i.e. the PrInCE-master folder if you're following instructions!).
    - Mac users must move "prince.app" and "run_prince.sh". 
    - PC users must move "prince.exe".
4. Run the standalone prince application.
    - Mac users: Open a Terminal window. Navigate to the PrInCE-master folder by typing 'cd /path/to/PrInCE-master/', where "/path/to/PrInCE-master/" is the first path copied from the Confirmation screen (see above). Run prince by typing './run_prince.sh /path/to/Matlab/Runtime/', where "/path/to/Matlab/Runtime/" is the second path copied from the Confirmation screen. Typical location is /Applications/MATLAB/MATLAB_Runtime/v92/. i.e. in Terminal, after navigating to the PrInCE-master folder, type './run_prince.sh /Applications/MATLAB/MATLAB_Runtime/v92/'.
    - PC users: Run prince.exe (double-click the prince.exe icon). __N.B. Only double-click prince.exe once!__ There's a lag of 5-10 seconds. __A common mistake is to start prince.exe multiple times.__

Important: Windows users may have to turn off the "check apps and files" in Windows Defender.

### Test data

PrInCE comes with test co-elution data from a recently published paper<sup>3</sup>. These files are "condition1.csv", "condition2.csv", "Major_protein_groups.csv", and "allComplexes.txt" in the Input/ folder. They give examples of what correctly formatted data files look like and ensure that you can run PrInCE correctly. To do the latter, just follow the instructions in step 5! If all is good, the Output/ folder will be populated with figures and data files within a few hours.

Important: Remove/delete these **4** test files before running your own data!


## References

1. Kristensen AR, Gpsoner J, Foster LJ. A high-throughput approach for measuring temporal changes in the interactome. Nat Methods. 2012 Sep;9(9):907-9. doi: 10.1038/nmeth.2131.
2. Scott NE, Brown LM, Kristensen AR, Foster LJ. Development of a computational framework for the analysis of protein correlation profiling and spatial proteomics experiments. J Proteomics. 2015 Apr 6;118:112-29. doi: 10.1016/j.jprot.2014.10.024.
3. Scott NE, Rogers LD, Prudova A, Brown NF, Fortelny N, Overall CM, Foster LJ. Interactome disassembly during apoptosis occurs independent of caspase cleavage. Molecular Systems Biology. 2017 13(1), 906. doi: 10.15252/msb.20167067

