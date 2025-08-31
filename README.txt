Hippocampal–Prefrontal Orchestration Supports Higher-Order Learning for Creative Ideation

This repository contains the complete analysis pipeline used in our study investigating how hippocampal–prefrontal interactions and representational dimensionality reduction support higher-order learning and creative ideation.  

It integrates:  
- **Behavioral analyses (R)** for prediction error, imitation–creation trade-off, and memory effects.  
- **fMRI analyses (Python)** for dimensionality, representational similarity, connectivity, transfer, and decoding.  
- **Multivariate analyses (MATLAB)** using CoSMoMVPA and CANlab for RSA, searchlight decoding, and mediation.

All scripts are organized into modules, each corresponding to specific analyses reported in the study.

---

📂 Repository Structure and Code Descriptions

😊 Behavioral Analyses (R)

R scripts implement trial-level and subject-level models of prediction error, imitation, memory, and creativity.

- **1predicErrorMemoryGLLM.R**  
  - GLMM testing whether prediction errors improve exemplar memory.  
  - Input: trial-level memory accuracy (binary) + prediction error index.  
  - Output: fixed/random effects of prediction error on memory.  

- **2predicErrorCreativeLMM.R**  
  - LMM testing prediction error effects on creative ideation ratings.  
  - Input: trial-level creativity score (Likert scale) + prediction error index.  
  - Output: model coefficients predicting creativity.  

- **3predicErrorImitate.R**  
  - Assesses prediction error influence on exemplar imitation behavior.  
  - Input: similarity ratings between generated ideas and exemplars.  
  - Output: probability of imitation given prediction error.  

- **4ImatationMemorCreat.R**  
  - Examines how imitation relates to memory and creativity simultaneously.  
  - Input: imitation index, memory performance, creativity scores.  
  - Output: correlation and regression results.  

- **5ImatitionMedatingCreat.R / 6ImitationMediatingMemor.R**  
  - Mediation models: imitation as mediator for creativity or memory outcomes.  
  - Input: PE → imitation → creativity/memory.  
  - Output: mediation path coefficients, bootstrap CIs.  

- **7PredicError_tradeoff.R**  
  - Trade-off model quantifying how prediction error shifts balance between memory and creativity.  
  - Output: trade-off index (memory vs originality).  

- **8tradeoffMemoryGLMM.R / 9tradeoffMediatingMemor.R**  
  - GLMM/mediation of trade-off effects specifically on memory outcomes.  

- **SeriesPositionEffectAnalysis.R**  
  - Tests whether serial order of exemplars influences creativity and memory.  

---

🧠 fMRI Analyses

- **RepresentationalDimensionalityAnalysis/**  
  - Estimates hippocampal representational dimensionality using PCA + bootstrap.  
  - Includes `pc_variance_bootstrap` (variance explained by first PCs) and `bootstrap_control_region_comparison` (hippocampus vs visual cortex).  
  - Output: subject-level dimensionality estimates for HSC vs LSC.  

- **GlobalPatternSimilarity/**  
  - Computes hippocampal pattern similarity (correlation of voxel activity patterns) across conditions.  
  - Output: similarity index (HSC vs LSC).  

- **ConnectivityAnalysis/**  
  - Functional and representational connectivity analyses.  
  - Includes **PPI** (psychophysiological interaction) and **RSA-based connectivity** between hippocampus and vlPFC.  

- **ConnectivityDimensionalityRegression/**  
  - Robust regression linking hippocampal–vlPFC connectivity differences to hippocampal dimensionality differences.  

- **Robust_Control/**  
  - Control analyses to test robustness of main findings:  
    1. Controlling for univariate activation differences.  
    2. Excluding imitation/copying trials.  
    3. Controlling for exemplar-specific creative potential.  
    4. Restricting analyses to remembered exemplars.  
    5. Redefining HSC/LSC with fixed group-level cutoffs.  

- **SME_memoryEncoding/**  
  - Supplementary experiment (Exp. S2): contrasts between remembered vs forgotten exemplars.  
  - Includes dimensionality, connectivity, activation, and global similarity.  

- **BetweenCondition_RD_crAnalysis/**  
  - Between-subject correlation between hippocampal/vlPFC dimensionality and subsequent creativity.  

- **LowDimensionalTransfer_LCnps/**  
  - Cross-phase representational transfer in compressed PCA spaces.  
  - Includes:  
    - Shared PCA space (fit on learning → apply to creating, or vice versa).  
    - Category-specific PCA spaces (HSC vs LSC).  

- **ConflictIntegrationActivation/**  
  - ROI activation analysis in DLPFC, ACC, and insula during creative phase.  

- **UncompressedTransferCrossphase/**  
  - Cross-phase transfer analysis in uncompressed voxel space (anterior hippocampus, vlPFC).  

- **CrossPhaseCouplingAnalysis/**  
  - Hippocampal–vlPFC coupling analyses:  
    - Compressed (low-dimensional) space  
    - Uncompressed (full voxel space)  
  - Compared across learning and creating phases.  

- **CrossPhaseDecoding/**  
  - Cross-phase decoding with SVM classifiers:  
    - Train on learning-phase patterns, test on creating-phase.  
    - ROI-based decoding in vlPFC.    
    - Residualized decoding after regressing out hippocampal low-dimensional components.  

---


⚙️ Dependencies

### R
- R (≥ 4.0)  
- Packages: `lme4`, `lmerTest`, `mediation`, `ggplot2`  

### Python
- Python (≥ 3.9)  
- Packages: `numpy`, `scipy`, `scikit-learn`  
- Optional: `nilearn`, `nibabel`, `matplotlib`  

### MATLAB
- MATLAB (R2021a or later recommended)  
- [CoSMoMVPA toolbox](https://www.cosmomvpa.org/)  
- [CANlab Core Tools](https://github.com/canlab)  

---









 


