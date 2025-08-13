# Fram Strait plankton eDNA — MATLAB scripts & data

Materials for: **“Seasonal dynamics, spatial variability and shifts in plankton communities in Fram Strait: insights from 13 years of eDNA surveys”** by Ryabov et al., submitted to **Deep-Sea Research Part II (DSR II)**.

## Contents

**Scripts**

* `publTrends_HG_sd_AvgDynamics.m` — figures of seasonal dynamics and spatial variability.
* `publTrends_HG_sd_Richness.m` — richness/diversity figures.
* Other `.m` files are helper plotting functions.

**Data**

* `Bio.xlsx` — normalized ASV abundances (columns = samples; rows = ASVs).
* `Env.xlsx` — sample metadata and local environmental factors (sample IDs match `Bio.xlsx`).
* `Traits.xlsx` — taxonomic annotations for ASVs.

## Usage

Run the  `publTrends*` scripts to reproduce the figures. Adjust file paths if your data are stored elsewhere.

## Requirements

MATLAB (recent version recommended). Standard toolboxes as required by the scripts.

## Citation

Ryabov et al. (submitted). *Seasonal dynamics, spatial variability and shifts in plankton communities in Fram Strait: insights from 13 years of eDNA surveys*. Deep-Sea Research Part II.

## License

* **Code** (all `.m` files): released under the **MIT License** (© Ryabov et al.).
  *Academic use requires citation of the paper below.* Please also retain copyright and license notices.

* **Data & derived results** (`Bio.xlsx`, `Env.xlsx`, `Traits.xlsx`, and figures/analyses produced from them): released under **CC BY 4.0**.
  *Attribution is required.* Cite the paper below and link to this repository (and DOI when available).

### How to cite

Ryabov, A. et al. (submitted, 2025). *Seasonal dynamics, spatial variability and shifts in plankton communities in Fram Strait: insights from 13 years of eDNA surveys.* Deep-Sea Research Part II.

## Contact

Please open a GitHub issue or contact the authors.
