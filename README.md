# PCP-SILAC
Bioinformatics pipeline for analyzing PCP-SILAC and other co-elution experiments.

* Predict protein-protein interactions
* Predict protein complexes
* Calculate protein abundance differences

Original versions of the analysis were written by Anders Kristensen<sup>1</sup> and Nichollas Scott<sup>2</sup>.


# How to use

### 1. Download pipeline.

In a browser, go to to [https://github.com/fosterlab/PCP-SILAC](https://github.com/fosterlab/PCP-SILAC). Click the green "Clone or Download" button in the top right. Then click "Download ZIP".

![Download pipeline from github](/ReadmeFigures/01download.jpg?raw=true)

### 2. Format your data.

#### Data files
You will be making one csv file for each biological condition. Each row, except for the header, is co-fractionation data from a single protein and replicate, e.g. a chromatogram. Each file is formatted like this:

* Column 1: Protein ID (must match with reference)
* Column 2: Replicate number (integer)
* Columns 3-end: Co-fractionated protein amount, e.g. isotopologue ratio for PCP-SILAC

Here's a simple dataset with one condition, two replicates, and five fractions:

![Format your data files like this](/ReadmeFigures/examplefile1.jpg?raw=true)

**Important: Ensure that files are "saved as csv", e.g. Excel --> "Save as" --> "Save as csv"**

#### Reference database of known complexes
This pipeline needs a reference database of known protein complexes, e.g. CORUM. This reference database must be a csv file in the same format as CORUM's *allComplexes.csv* file (downloadable [here](http://mips.helmholtz-muenchen.de/genre/proj/corum/)). That is, the reference database file must:
* have a header
* be semicolon-separated
* each reference complex must be on a separate line in the fourth column

Note: protein IDs in data files must match a subset of protein IDs in the reference database.


### 3. Organize your files.

Before running the pipeline, organize experiment files and code like this:

  * <working directory>/
    * Code/
    * Input/
      * Reference database file (e.g *allComplexes.csv*)
      * Data file 1 (e.g *condition1.csv*)
      * Data file 2 (e.g *condition2.csv*)
      * Data file 3 (e.g *condition1.csv*)
      * ...
    * pcpsilac.m

That is, inside a working directory, the code goes in the Code/ folder and each input file goes in the Input/ folder. The master script, pcpsilac.m, goes in the working directory. To accomplish this, create a home folder (e.g. "Pipeline/"). Unzip the code downloaded from [https://github.com/fosterlab/PCP-SILAC](https://github.com/fosterlab/PCP-SILAC) and copy pcpsilac.m and the Code/ folder into the home directory. In the home directory, create a folder called "Input", then place all data files (one for each condition) and the reference database file in this Input/ folder. The resulting file structure should look like this:

### 4. Enter the details of your experiment in pcpsilac.m.


### 5. Run analysis.
Open Matlab. In Matlab, *cd* to the PCPanalysis/ folder. In the command line type

```
pcpsilac.m
```


## References

1. Kristensen AR, Gpsoner J, Foster LJ. A high-throughput approach for measuring temporal changes in the interactome. Nat Methods. 2012 Sep;9(9):907-9. doi: 10.1038/nmeth.2131.
2. Scott NE, Brown LM, Kristensen AR, Foster LJ. Development of a computational framework for the analysis of protein correlation profiling and spatial proteomics experiments. J Proteomics. 2015 Apr 6;118:112-29. doi: 10.1016/j.jprot.2014.10.024.